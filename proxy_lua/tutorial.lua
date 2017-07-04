-- demo
print("Hello World!")
-- 单行注释

--[[
	多行注释
	print("注释")
--]]

-- 标识符
-- demo
-- 标识符
-- 关键词
-- 一般约定，以下划线开头连接一串大写字母的名字（_VERSION）被保留用于Lua内部全局变量

-- 全局变量

print(type("Hello world"))
print(type(10*4*3))
print(type(print))
print(type(true))
print(type(nil))
print(type(type(X)))

s, e = string.find("www.runoob.com", "runoob")
print(s, e)




print(type(a))

tab1 = { key1 = "val1", key2 = "val2", "val3"}
for k, v in pairs(tab1) do
	print(k.."-"..v)
end

tab1.key1 = nil
for k,v in pairs(tab1) do
	print(k.."-"..v)
end

-- 内置函数pairs

-- boolean 布尔类型
print(type(true))
print(type(false))
print(type(nil))
if false or nil then
	print("至少有一个是true")
else
	print("false和nil都为false!")
end
-- number(数字),默认都只有double类型
print(type(3))

-- string (字符串)

string1 = "this is string1"
string2 = "this is string2"

html = [[ 
<html>
</html>
]]

print(html)

len = "www"
print(#len)
print(#"where do you come from?")

-- table
local tbl1 = {}
local tbl2 = {"apple", "pear", "orange", "grape"}

a = {}
a["key"] = "value"
key = 10
a[key] = 22
print(a)

for k,v in pairs(a) do 
	print(k.."-"..v)
end

for k,v in pairs(tbl2) do
	print(k..":"..v)
end
print(tbl2[2])
 


-- function 

function factorial(n)
	if n == 0 then 
		return 1
	else 
		return n * factorial(n-1)
	end
end

print(factorial(6))
 

-- thread 
--[[
	lua中，最主要的线程是协同程序，它跟thread差不多，拥有自己独立的堆栈，局部变量和指令指针，可以跟其他协同程序共享全局变量和其他大部分东西。
	
--]]


-- userdata 自定义类型

-- 全局变量和局部变量

-- userdata 自定义类型



-- 循环

while(true)
do 
break 
print("ok")
end


-- 0为true
if (0)
then 
	print("0为true")
end


function max(num1, num2)
	if (num1>num2) then
		result = num1;
	else
		result = num2;
	end
	return result;
end
print("两值比较最大值为", max(10, 4))


myprint = function (param)
	print("这是打印函数 - ##", param, "##")
end


function add(num1, num2, functionPrint)
	result = num1 + num2
	-- 调用传递的函数参数
	functionPrint(result)
end
myprint(10)
--myprint 
add(2, 5, myprint)

print(s, e)
 
function maximum (a)
	local mi = 1
	local m = a[mi]
	for i,val in ipairs(a) do
		if val>m then
			mi = i
			m = val
		end
	end
	return m,mi
end


function average(...)
	result = 0
	local arg = {...}
	for i,v in ipairs(arg) do
		result = result + v
	end
	print("总共传入"..#arg.."个数")
	return result/#arg
end


print(average(1,2,3,4,5,6))
for i=1,10 do
	print(i)
end

for i=-2,10 do
	print(i)
end


