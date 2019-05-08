---=====================================
---luastg math
---=====================================

----------------------------------------
---常量

PI = math.pi
PIx2 = math.pi * 2
PI_2 = math.pi * 0.5
PI_4 = math.pi * 0.25
SQRT2 = math.sqrt(2)
SQRT3 = math.sqrt(3)
SQRT2_2 = math.sqrt(0.5)
GOLD = 360 * (math.sqrt(5) - 1) / 2

----------------------------------------
---数学函数

int = math.floor
abs = math.abs
max = math.max
min = math.min
rnd = math.random
sqrt = math.sqrt
math.mod = math.mod or math.fmod
mod = math.mod

---获得数字的符号(1/-1/0)
---@param x number
---@return number
function sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

---获得(x,y)向量的模长
---@param x number
---@param y number
---@return number
function hypot(x, y)
	return sqrt(x * x + y * y)
end

local _fac = {}
---阶乘，目前用于组合数和贝塞尔曲线
---@param num number
---@return number
function Factorial(num)
	if num < 0 then
		error("Can't get factorial of a minus number.")
	end
	if num < 2 then
		return 1
	end
	num = int(num)
	if _fac[num] then
		return _fac[num]
	end
	local result = 1
	for i = 1, num do
		if _fac[i] then
			result = _fac[i]
		else
			result = result * i
			_fac[i] = result
		end
	end
	return result
end

---组合数，目前用于贝塞尔曲线
---@param ord number @数量
---@param sum number @组合
---@return number
function combinNum(ord, sum)
	if sum < 0 or ord < 0 then
		error("Can't get combinatorial of minus numbers.")
	end
	ord = int(ord)
	sum = int(sum)
	return Factorial(sum) / (Factorial(ord) * Factorial(sum - ord))
end

----------------------------------------
---额外数学函数

---@class Math
Math = {}

---对两个数进行线性插值
---@param v1 number
---@param v2 number
---@param k number
---@return number
function Math.SimpleLerp(v1, v2, k)
	return (1 - k) * v1 + k * v2
end

---对两个对象进行线性插值
---@param t1 number|table
---@param t2 number|table
---@param k number
---@return number|table
function Math.Lerp(t1, t2, k)
	k = math.max(0, math.min(k, 1))
	if type(t1)=="number" and type(t2)=="number" then
		return Math.SimpleLerp(t1, t2, k)
	elseif type(t1)=="table" and type(t2)=="table" then
		local ret = {}
		local _key = {}
		for key, v1 in pairs(t1) do
			local v2 = t2[key]
			if v2 then
				_key[key] = true
				if type(v1) == "number" and type(v2) == "number" then
					ret[key] = Math.SimpleLerp(v1, v2, k)
				elseif type(v1) == "table" and type(v2) == "table" then
					ret[key] = Math.Lerp(v1, v2, k)
				end
			end
		end
		for key, v2 in pairs(t2) do
			if not _key[key] then
				local v1 = t1[key]
				if v1 then
					if type(v1) == "number" and type(v2) == "number" then
						ret[key] = Math.SimpleLerp(v1, v2, k)
					elseif type(v1) == "table" and type(v2) == "table" then
						ret[key] = Math.Lerp(v1, v2, k)
					end
				end
			end
		end
		return ret
	else
		error("Invalid parameter. Need value type : number or table.")
	end
end

local function dB2V(dB)
	return 10^(dB/20)
end
local function V2dB(v)
	return 20*math.log(v,10)
end

---音量的线性转对数
---@param v number @[0~1]，归一化线性音量
---@return number @[0~1]，归一化分贝衰减模型对数音量
function Math.LinearToLog(v)
	if v<=0.0 then
		return 0.0
	else
		v=math.min(v,1.0)
		local dB=V2dB(v)
		local rate=(dB+100)/100
		return rate
	end
end

---音量的对数转线性
---@param v number @[0~1]，归一化分贝衰减模型对数音量
---@return number @[0~1]，归一化线性音量
function Math.LogToLinear(v)
	if v<=0.0 then
		return 0.0
	else
		v=math.min(v,1.0)
		local dB=100*v-100
		local rate=dB2V(dB)
		return rate
	end
end

----------------------------------------
---随机数系统，用于支持replay系统

local ranx = Rand()

---公共随机数发生器
---@class ran
ran = {}

---生成随机整数
---@param a number @下限
---@param b number @上限
---@return number
function ran:Int(a, b)
	if a > b then
		return ranx:Int(b, a)
	else
		return ranx:Int(a, b)
	end
end

---生成随机浮点数
---@param a number @下限
---@param b number @上限
---@return number
function ran:Float(a, b)
	return ranx:Float(a, b)
end

---生成符号
---@return number @1 or -1
function ran:Sign()
	return ranx:Sign()
end

---设置随机数种子
---@param seed number
function ran:Seed(seed)
	ranx:Seed(seed)
end

---获取随机数种子
---@return number
function ran:GetSeed()
	return ranx:GetSeed()
end
