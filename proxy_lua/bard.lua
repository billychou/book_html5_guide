local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end
local _M = new_tab(0, 15)
local mt = { __index = _M }

local common    = require "lib.common"
local config    = require "lib.config"
local redis     = require "lib.resty.redis"
local cjson     = require "cjson.safe"
local dyups     = require "ngx.dyups"
local math      = require "math"
local bard_conf = require "plugins.bard.bardConf"
local utils     = require "tools.utils"
local checker   = utils.type_checker
local sh_bard   = ngx.shared.sh_red
local sh_valve  = ngx.shared.valve

local allowed_idc      = bard_conf['allowed_idc']
local update_flag    = bard_conf["update_flag"]       -- 是否刚更新过
local update_time    = bard_conf["update_time"]       -- 更新间隔时间
local deny_sns_flag  = bard_conf["deny_sns_flag"]     -- 抑制状态
local ups_ids_flag   = bard_conf["ups_ids_flag"]     -- 分组切换状态
local last_idc_flag  = bard_conf["last_idc_flag"]     -- 最后一次更新，所在IDC
local last_ips_flag  = bard_conf["last_ips_flag"]     -- 最后一次更新，生效的ip列表
local flexible_time  = bard_conf["flexible_time"]     -- 柔性时间
local flexible_interval = bard_conf["flexible_interval"]     -- 柔性间隔时间
local flexible_start = bard_conf["flexible_start"]    -- 柔性开始时间
local flexible_up_flag  = bard_conf["flexible_up_flag"]      -- 是否刚进行过柔性更新
local svr_group      = bard_conf["svr_group"]
local aos_upstreams  = bard_conf["aos_upstreams"]     -- 反向代理配置
local last_idc       = sh_bard:get(last_idc_flag)

-- 日志字段格式化
function _M:pretty_log(plan, idc)--{{{
    return tostring(plan) .. ':' .. string.upper(idc) .. ':' .. tostring(self.locate)
end
--}}}

-- 检查ip列表配置格式
function _M:check_ip_list(ip_list) --{{{
    if type(ip_list) ~= "table" then
        return false
    end

    -- 检查切换机房是否合法
    local idc_to = tostring(ip_list['to'])
    idc_to = string.lower(idc_to)
    if allowed_idc[idc_to] ~= 1 then
        return false
    end

    -- 检查两个机房配置（本地、切换）
    for i, svr in pairs(svr_group) do
        if type(ip_list[svr]) ~= "table" then
            return false
        end
        -- 检查各个服务配置
        for loc, upsn in pairs(aos_upstreams) do
            if type(ip_list[svr][loc]) ~= "table" or type(ip_list[svr][loc]["ips"]) ~= "table" or #ip_list[svr][loc]["ips"] <= 0 then
                return false
            end
            -- 检查IP列表
            for j, ip in pairs(ip_list[svr][loc]["ips"]) do
                if type(ip) ~= "string" or ip == "" then
                    return false
                end
            end
        end
    end

    return true
end --}}}


function _M:get_red_ip_list(ip_list_key)--{{{

    local layer7_redis     = bard_conf['layer7_redis']
    local max_times        = layer7_redis['max_times'] or 2
    local red_conn_timeout = layer7_redis['red_conn_timeout'] or 100
    local red_pool_size    = layer7_redis['red_pool_size'] or 100
    local red_idle_timeout = layer7_redis['red_idle_timeout'] or 10000

    --local host = "redis_" .. self.pos .. "_host"
    --local port = "redis_" .. self.pos .. "_port"
    local red = redis:new()
    local red_env =common:get_redis_env()

    red:set_timeout(red_conn_timeout)
    local ok, err = red:connect(red_env.host, red_env.port)
    if not ok then
        ngx.log(ngx.WARN, err)
        return nil
    end
    local count, _ = red:get_reused_times()
    if count == 0 then
        local pass = "redis_" .. self.env .. "_pwd"
        if checker.is_empty(red_env.pass) ~= true then
            local ret, err = red:auth(red_env.pass)
            if not ret or err ~= nil then
                ngx.log(ngx.ERR, "redis_auth_err: ", err)
                return
            end
        end
    end

    local ip_list = nil
    for i = max_times, 1, -1
    do
        ip_list = red:get(ip_list_key)
        if ip_list ~= nil then
            break
        end
    end
    ok, err = red:set_keepalive(red_idle_timeout, red_pool_size)
    if not ok then
        ngx.log(ngx.WARN, err)
        red:close()
    end
    return ip_list
end
--}}}


-- 将数组顺序随机
function _M:get_rand_list(ip_list) --{{{
    local rand_ip_list = {}

    while #ip_list > 0 do
        local index = math.random(#ip_list)
        local ip = ip_list[index]
        table.insert(rand_ip_list, ip)
        table.remove(ip_list, index)
    end

    return rand_ip_list
end --}}}


-- 计算要更新到upstream的ip列表，不需要更新返回false
function _M:get_ips()--{{{
    -- 没到更新时间，且不在柔性时间；在柔性时间，柔性不需要更新
    local up_flag = sh_bard:get(update_flag)
    local now = ngx.time()
    local flex_start = sh_bard:get(flexible_start) or 0
    local flex_up_flag = sh_bard:get(flexible_up_flag)
    if up_flag ~= nil and up_flag ~= ngx.null and now - flex_start > flexible_time then
        return false, nil, nil
    end
    if flex_up_flag ~= nil and flex_up_flag ~= ngx.null and up_flag ~= nil and up_flag ~= ngx.null then
        return false, nil, nil
    end

    -- 更新时间记录
    sh_bard:safe_set(update_flag, 1, update_time)
    sh_bard:safe_set(flexible_up_flag, 1, flexible_interval)

    -- 获取IDC的ip列表
    local ips = self:get_red_ip_list(self.ip_list_key)
    local ip_tb = nil
    local ip_list = nil
    if ips ~= nil and type(ips) == "string" then
        ip_tb = cjson.decode(ips)
        local ok = self:check_ip_list(ip_tb)
        if not ok then
            return false, nil, nil
        end
    else
        return false, nil, nil
    end
    if string.upper(ip_tb["to"]) == string.upper(self.pos) then
        ip_list = ip_tb["local_ups"]
    else
        ip_list = ip_tb["alias_ups"]
    end

    if type(ip_tb['_upids']) == 'string' and ip_tb['_upids'] ~= '' then
        sh_bard:safe_set(ups_ids_flag, ip_tb['_upids'])
    else
        sh_bard:safe_set(ups_ids_flag, '')
    end

    -- 更新域名抑制
    if ip_tb["deny_sns"] == 1 then
        sh_bard:safe_set(deny_sns_flag, 1)
    else
        sh_bard:safe_set(deny_sns_flag, 0)
    end

    -- 首次启动更新IDC配置
    local last_ips = sh_bard:get(last_ips_flag)
    if not last_idc or last_idc == ngx.null then
        last_idc = ip_tb["to"]
        last_ips = cjson.encode(ip_list)
        sh_bard:safe_set(last_idc_flag, last_idc)
        sh_bard:safe_set(last_ips_flag, last_ips)
    end

    -- 检查是否进行了流量切换，如果进行，配置柔性信息
    if string.upper(ip_tb["to"]) ~= string.upper(last_idc) then
        flex_start = now
        last_idc = ip_tb["to"]
        sh_bard:safe_set(flexible_start, flex_start)
        sh_bard:safe_set(last_idc_flag, last_idc)
    end

    local last_ip_list = cjson.decode(last_ips)

    -- 如果在柔性时间，拼接ip列表
    if now - flex_start <= flexible_time then
        --math.randomseed(tostring(ngx.time()):reverse():sub(1, 6))

        for loc, ups in pairs(last_ip_list) do
            local index = math.ceil(#ip_list[loc]["ips"] * (now - flex_start) / flexible_time)
            ip_list[loc]["ips"] = self:get_rand_list(ip_list[loc]["ips"])
            for i, ip in ipairs(ip_list[loc]["ips"]) do
                if i >= index then
                    break
                end
                last_ip_list[loc]["ips"][i] = ip
            end
            ip_list[loc]["ips"] = last_ip_list[loc]["ips"]
        end
    end

    -- 更新ip列表缓存
    last_ips = cjson.encode(ip_list)
    sh_bard:safe_set(last_ips_flag, last_ips)

    return true, ip_list
end
--}}}

-- 更新upstream配置
function _M:set_upstream(ip_list, loc_up_dict)--{{{
    for loc, up in pairs(aos_upstreams) do
        local ips = ""
        local up_name = up["el"]

        -- 更新upstream操作
        for k, v in pairs(ip_list[loc]["ips"]) do
            ips = ips .. "server " ..  v .. ";"
        end
        local status, rv = dyups.update(up_name, ips)
        if status ~= ngx.HTTP_OK then
            ngx.log(ngx.ERR, "dyups_update_error status: ", status, "ret: ", rv)
        end
    end
end
--}}}


function _M:split(str, sep) --{{{

    local sep, fields = sep or ",", {}
    if not str or type(str) ~= "string" then
        return fields
    else
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[c] = 1 end)
        return fields
    end
end
---}}}


function _M:run()--{{{

    local degrade_flag  = config['valve_bard']
    local degrade_value = sh_valve:get(degrade_flag)    -- 降级标记
    local server_name   = ngx.var.host or ''           -- 访问域名
    local sns_domain    = bard_conf["sns_domain"]      -- 启用抑制域名
    local deny_sns      = sh_bard:get(deny_sns_flag)   -- 抑制切换
    if degrade_value == 1 or (server_name == sns_domain and deny_sns == 1 and string.upper(last_idc) ~= string.upper(self.pos)) then
    -- 降级状态或sns抑制，不切流量使用备份upstream
        ngx.var.idc_switch_status = self:pretty_log('B', self.pos)
        ngx.var.layer7_ups = aos_upstreams[self.locate]['ori']
    else
        local ok, ip_list = self:get_ips()
        if ok then
            self:set_upstream(ip_list)
        end

        local ups_ids_str = sh_bard:get(ups_ids_flag) or ""
        local ups_ids_tbl = self:split(ups_ids_str, "|")
        if type(ups_ids_tbl) == "table" and ups_ids_tbl[self.locate] then
            ngx.var.idc_switch_status = self:pretty_log('A', last_idc)
        else
            ngx.var.idc_switch_status = self:pretty_log('A', self.pos)
        end

        ngx.var.layer7_ups = aos_upstreams[self.locate]['el']
    end
    return true
end
--}}}


function _M.new()--{{{

    local pos      = common.get_env(ngx.var.hostname)
    local env      = pos == "dev" and "et2" or pos
    local last_idc = sh_bard:get(last_idc_flag) or env
    local ip_list_key    = bard_conf["layer7_prefix"] .. string.upper(env)
    local tb_index = {pos = pos, env = env, last_idc = last_idc, ip_list_key = ip_list_key, locate = ngx.var.layer7_locate}

    return setmetatable(tb_index, mt)
end
--}}}

return _M
