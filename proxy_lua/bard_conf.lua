return {

    -- L7降级upstream手动切换的redis key前缀
    idc_prefix = 'IDC2SWITCH#AMAP-AOS-AMAPS#',

    -- L7自动切换的redis key前缀
    layer7_prefix = 'L7_SWITCH#AMAP-AOS-AMAPS#',

    -- L7自动切换机器列表更新间隔 单位s
    update_time = 30,

    -- L7自动切换shared key
    update_flag = 'ip_list_flag',

    -- L7自动切换降级为upstream手动切换的shared key
    degrade_flag = 'autoups_degrade_flag',

    -- 柔性相关
    last_idc_flag = "last_idc_flag",
    last_ips_flag = "last_ips_flag",
    flexible_time = 100,
    flexible_interval = 3,
    flexible_start = 'flexible_start',
    flexible_up_flag  = 'flexible_up_flag',

    -- L7自动切换redis设置
    layer7_redis = {
        max_times        = 2,
        red_conn_timeout = 50,
        red_pool_size    = 50,
        red_idle_timeout = 10000
    },

    -- 机房idc白名单
    allowed_idc = {
        et2 = 1,
        su18 = 1,
        eu13 = 1,
        na62 = 1
    },

    -- sns抑制域名
    sns_domain = 'sns.amap.com',

    -- 抑制域名状态
    deny_sns_flag = 'deny_sns_flag',

    -- 分组切换状态
    ups_ids_flag = 'ups_ids_flag',

    -- 机房类型配置
    svr_group = {
        'local_ups',
        'alias_ups'
    },

    -- aos各分组的upsteream值，第三版本
    aos_upstreams = {
        misc = {
            el  = 'misc.alias.amap.com',
            ori = 'misc.local.amap.com'
        },
        poi = {
            el  = 'poi.alias.amap.com',
            ori = 'poi.local.amap.com'
        },
        s = {
            el  = 's.alias.amap.com',
            ori = 's.local.amap.com'
        },
        shield = {
            el  = 'shield.alias.amap.com',
            ori = 'shield.local.amap.com'
        },
        transfer = {
            el  = 'transfer.alias.amap.com',
            ori = 'transfer.local.amap.com'
        },
        eta = {
            el  = 'eta.alias.amap.com',
            ori = 'eta.local.amap.com'
        },
        pypy_traffic = {
            el  = 'pypy_traffic.alias.amap.com',
            ori = 'pypy_traffic.local.amap.com'
        },
        gateway = {
            el  = 'gateway.alias.amap.com',
            ori = 'gateway.local.amap.com'
        }
    }

}
