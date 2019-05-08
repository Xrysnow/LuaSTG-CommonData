---=====================================
---luastg scoredata
---=====================================

local path="score/"

----------------------------------------
---scoredata

local function _get_path()
	local pn=string.format("%s%s",path,setting.mod)
	return pn
end

local function _get_file_name()
	local fn=string.format("%s%s/%s.dat",path,setting.mod,setting.username)
	return fn
end

---将一个表转为scoredata对象（声明）
local make_scoredata_table

---scoredata对象__newindex元方法
local function scoredata_mt_newindex(t, k, v)
	if type(k) ~= 'string' and type(k) ~= 'number' then
		error('Invalid key type \'' .. type(k) .. '\'')
	end
	if type(v) == 'function' or type(v) == 'userdata' or type(v) == 'thread' then
		error('Invalid value type \'' .. type(v) .. '\'')
	end
	if type(v) == 'table' then
		make_scoredata_table(v)
	end
	getmetatable(t).data[k] = v
	SaveScoreData()
end

---scoredata对象__index元方法
local function scoredata_mt_index(t, k)
	return getmetatable(t).data[k]
end

---将一个表转为scoredata对象
function make_scoredata_table(t)
	if type(t) ~= 'table' then
		error('t must be a table')
	end
	Serialize(t)
	setmetatable(t, {
		__newindex = scoredata_mt_newindex,
		__index = scoredata_mt_index,
		data = {}
	})
	for k, v in pairs(t) do
		if type(v) == 'table' then
			make_scoredata_table(v)
		end
		getmetatable(t).data[k] = v
		t[k] = nil
	end
end

----------------------------------------
---manager

---创建一个新的scoredata对象
function new_scoredata_table()
	local t = {}
	setmetatable(t, {
		__newindex = scoredata_mt_newindex,
		__index = scoredata_mt_index,
		data = {}
	})
	return t
end

---设置全局的scoredata对象
function DefineDefaultScoreData(t)
	scoredata = t
end

---保存全局scoredata
function SaveScoreData()
	local fname=_get_file_name()
	local score_data_file = assert(io.open(__UTF8ToANSI(fname), 'w'))
	local s = Serialize(scoredata)
	score_data_file:write(utility.format_json(s))
	score_data_file:close()
end

---从文件加载数据到scoredata
function LoadScoreData()
	local fname=_get_file_name()
	local scoredata_file = assert(io.open(__UTF8ToANSI(fname), 'r'))
	scoredata = DeSerialize(scoredata_file:read('*a'))
	scoredata_file:close()
	make_scoredata_table(scoredata)
end

---初始化全局scoredata
function InitScoreData()
	lfs.mkdir(_get_path())
	if FileExist(_get_file_name()) then
		LoadScoreData()
	else
		if scoredata == nil then
			scoredata = {}
		else
			if type(scoredata) ~= 'table' then
				error('scoredata must be a Lua table.')
			end
		end
		make_scoredata_table(scoredata)
	end
end
