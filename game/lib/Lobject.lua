---=====================================
---luastg object
---=====================================

local LOG_MODULE_NAME = "[LIB][OBJECT]"

----------------------------------------
---常量

--碰撞组
GROUP_GHOST = 0
GROUP_ENEMY_BULLET = 1
GROUP_ENEMY = 2
GROUP_PLAYER_BULLET = 3
GROUP_PLAYER = 4
GROUP_INDES = 5
GROUP_ITEM = 6
GROUP_NONTJT = 7
GROUP_SPELL = 8
GROUP_ALL = 16
GROUP_NUM_OF_GROUP = 16

--图层
LAYER_BG = -700
LAYER_ENEMY = -600
LAYER_PLAYER_BULLET = -500
LAYER_PLAYER = -400
LAYER_ITEM = -300
LAYER_ENEMY_BULLET = -200
LAYER_ENEMY_BULLET_EF = -100
LAYER_TOP = 0

----------------------------------------
---class

local all_class = {}

local _blank_function1 = function(self) end
local _blank_function2 = function(self, other) end
local _blank_function3 = function(self, ...) end
local _render_function = lstg.DefaultRenderFunc

---所有class的基类，可以直接用于New方法
---@class lstgClass
object = {
	--数组部分
	_blank_function1, --init
	_blank_function3, --del
	_blank_function1, --frame
	_render_function, --render
	_blank_function2, --colli
	_blank_function3; --kill
	
	--散列部分
	is_class = true,
	init     = _blank_function1,
	del      = _blank_function3,
	frame    = _blank_function1,
	render   = _render_function,
	colli    = _blank_function2,
	kill     = _blank_function3,
}

local WARN_STRING_FORMAT = "定义新的object class类时使用了不存在的基类\
这将会等价于使用object class作为基类，即Class(object)\
谨慎检查这是否是您想要的结果：\
--->file: [%q]\
--->line: %d\
\
忽略这个警告？"

local WARN_STRING_FORMAT2 = "定义新的object class类时使用了不存在的基类\
这将会等价于使用object class作为基类，即Class(object)\
谨慎检查这是否是您想要的结果：\
--->file: [%q]\
--->line: %d"

---define new class
---@param base lstgClass
---@param define lstgClass
---@return lstgClass
function Class(base, define)
	if base == nil then
		--处理一个特殊的歧义，由于lua无法识别传入nil参数和不传入参数，所以会出现歧义，进而可能会引发最隐匿的bug
		--如果指定的基类base不存在(nil)，这个函数等效于不传入参数base，那么这个函数就会按照XXX=Class(object)处理
		local dinfo = debug.getinfo(2)
		lstg.Log(3, LOG_MODULE_NAME, string.format(WARN_STRING_FORMAT2, dinfo.source, dinfo.currentline))
		lstg.MsgBoxWarn(string.format(WARN_STRING_FORMAT, dinfo.source, dinfo.currentline))
		--忽视警告，则使用默认基类object类
		base = object
	else
		if (type(base) ~= "table") or not base.is_class then
			error("Invalid base lstgClass or base lstgClass does not exist.”")
		end
	end
	
	local result = { 0, 0, 0, 0, 0, 0 }
	result.is_class = true
	result.init     = base.init
	result.del      = base.del
	result.frame    = base.frame
	result.render   = base.render
	result.colli    = base.colli
	result.kill     = base.kill
	result.base     = base
	
	if define and type(define) == "table" then
		for k, v in pairs(define) do
			result[k] = v
		end
	end
	
	table.insert(all_class, result)
	return result
end

---将一个class的回调函数注册到[1~6]的位置，给底层调用
---@param class lstgClass
function RegisterClass(class)
	class[1] = class.init
	class[2] = class.del
	class[3] = class.frame
	class[4] = class.render
	class[5] = class.colli
	class[6] = class.kill
end

---对所有class的回调函数进行整理，给底层调用
function InitAllClass()
	for _, v in pairs(all_class) do
		RegisterClass(v)
	end
end

----------------------------------------
---单位管理

---直接标记object的状态为del
---@param o object
function RawDel(o)
	if IsValid(o) then
		o.status = "del"
	end
end

---直接标记object的状态为kill
---@param o object
function RawKill(o)
	if IsValid(o) then
		o.status = "kill"
	end
end

---直接标记object的状态为normal
---@param o object
function PreserveObject(o)
	if IsValid(o) then
		o.status = "normal"
	end
end
