---=====================================
---luastg plugin helper
---=====================================

local LOG_MODULE_NAME = "[LIB][PLUGIN]"

----------------------------------------
---插件包辅助

---@class plugin @插件包辅助
local plugin = {}

local PLUGIN_PATH = { "Library", "plugins" } --插件路径
local ENTRY_POINT_SCRIPT_PATH = ""        --入口点文件路径
local ENTRY_POINT_SCRIPT = "__init__.lua" --入口点文件
local UNLOAD_SCRIPT_PATH = ""             --移除脚本路径
local UNLOAD_SCRIPT = "__remove__.lua"    --可选的移除脚本

---获取设置好的插件文件夹路径
---@return string
function plugin.GetDirectory()
	local dir = ""
	for _, v in ipairs(PLUGIN_PATH) do
		dir = dir .. v .. "/"
	end
	return dir
end

---设置插件所在路径
---@param dir table @{lv1:string, lv2:string, ... }, 分级路径
---@return boolean @路径是否有效
function plugin.SetDirectory(dir)
	if type(dir) == "table" then
		for _, v in ipairs(dir) do
			if type(v) ~= "string" then
				return false
			end
		end
		PLUGIN_PATH = dir
		return true
	else
		return false
	end
end

---罗列插件目录下所有的插件
---该方法没有对插件包合法性进行检测，即使插件中没有入口点脚本也会罗列出来
---@return table @{string, string, ... }
function plugin.ListPlugins()
	local path = plugin.GetDirectory()
	local fs = lstg.FindFiles(path, "zip", "")
	local rs = {}
	for _, v in pairs(fs) do
		local filename = string.sub(v[1], string.len(path) + 1, -5)
		table.insert(rs, filename)
	end
	return rs
end

---检查一个已加载的插件包是否合法（有入口点文件）
---@param pluginpath string @插件包路径
---@return boolean
function plugin.CheckValidity(pluginpath)
	local fs = lstg.FindFiles("", "lua", pluginpath)
	for _, v in pairs(fs) do
		local filename = string.sub(v[1], string.len(ENTRY_POINT_SCRIPT_PATH) + 1, -1)
		if filename == ENTRY_POINT_SCRIPT then
			return true
		end
	end
	lstg.Log(3, LOG_MODULE_NAME, "插件\"" .. pluginpath .. "\"不是有效的插件，没有入口点文件\"" .. ENTRY_POINT_SCRIPT .. "\"")
	return false
end

---检查一个插件包是否合法（有入口点文件）
---该函数会装载插件包，然后进行检查，如果不是合法的插件包，将会卸载掉
---@param pluginpath string @插件包路径
---@return boolean
function plugin.LoadAndCheckValidity(pluginpath)
	lstg.LoadPack(pluginpath)
	local fs = lstg.FindFiles("", "lua", pluginpath)
	for _, v in pairs(fs) do
		local filename = string.sub(v[1], string.len(ENTRY_POINT_SCRIPT_PATH) + 1, -1)
		if filename == ENTRY_POINT_SCRIPT then
			return true
		end
	end
	lstg.UnloadPack(pluginpath)
	lstg.Log(4, LOG_MODULE_NAME, "插件\"" .. pluginpath .. "\"不是有效的插件，没有入口点文件\"" .. ENTRY_POINT_SCRIPT .. "\"")
	return false
end

---检查一个插件是否有移除脚本
---@param pluginpath string @插件包路径
---@return boolean
function plugin.CheckRemoveScript(pluginpath)
	local fs = lstg.FindFiles("", "lua", pluginpath)
	for _, v in pairs(fs) do
		local filename = string.sub(v[1], string.len(UNLOAD_SCRIPT_PATH) + 1, -1)
		if filename == UNLOAD_SCRIPT then
			return true
		end
	end
	return false
end

---执行移除脚本，无该脚本则跳过
---@param pluginpath string @插件包路径
function plugin.DoRemoveScript(pluginpath)
	if plugin.CheckRemoveScript(pluginpath) then
		lstg.DoFile(UNLOAD_SCRIPT_PATH .. UNLOAD_SCRIPT, pluginpath)
	end
end

---装载一个插件包，然后执行入口点脚本
---失败则返回false
---@param pluginpath string @插件包路径
---@return boolean
function plugin.LoadPlugin(pluginpath)
	local ret = plugin.LoadAndCheckValidity(pluginpath)
	if ret then
		lstg.DoFile(ENTRY_POINT_SCRIPT_PATH .. ENTRY_POINT_SCRIPT, pluginpath)
	end
	return ret
end

---卸载一个插件包
---@param pluginpath string @插件包路径
function plugin.UnloadPlugin(pluginpath)
	plugin.DoRemoveScript(pluginpath)--尝试执行移除脚本
	lstg.UnloadPack(pluginpath)--尝试移除资源包
end

---根据一个列表，按照顺序加载插件，用于直接加载所有可用的插件包
---列表的形式如下：{string, string, ... }
---每一个单位为一段字符串，为插件的文件名（不带后缀）
---@param list table @{string, string, ... }
function plugin.LoadPluginsByList(list)
	local path = plugin.GetDirectory()
	for _, v in ipairs(list) do
		local pluginpath = path .. v .. ".zip"
		local ret = plugin.LoadAndCheckValidity(pluginpath)
		if ret then
			lstg.DoFile(ENTRY_POINT_SCRIPT_PATH .. ENTRY_POINT_SCRIPT, pluginpath)
		end
	end
end

----------------------------------------
---配置文件相关的操作

local CONFIG_FILE = "PluginConfig"

---检查没一级目录是否存在，不存在则创建
local function check_directory()
	local depth = #PLUGIN_PATH
	for i = 1, depth do
		--获取某层级的路径
		local path = ""
		for d = 1, i do
			path = path .. PLUGIN_PATH[d] .. "/"
		end
		--检查
		if not plus.DirectoryExists(path) then
			plus.CreateDirectory(path)
		end
	end
end

---加载配置文件
---@return table @{{PluginName,PluginPath,Enable}, ... }
function plugin.LoadConfig()
	check_directory()
	local f, msg
	f, msg = io.open(plugin.GetDirectory() .. CONFIG_FILE, "r")
	if f == nil then
		return {}
	else
		local ret = cjson.decode(f:read('*a'))
		f:close()
		return ret
	end
end

---保存配置文件
---@param cfg table @{{PluginName,PluginPath,Enable}, ... }
function plugin.SaveConfig(cfg)
	check_directory()
	local f, msg
	f, msg = io.open(plugin.GetDirectory() .. CONFIG_FILE, "w")
	if f == nil then
		error(msg)
	else
		f:write(utility.format_json(cjson.encode(cfg)))
		f:close()
	end
end

---遍历插件目录下所有的插件，来获得一个配置表
---如果传入了一个配置表，则对传入的配置表进行刷新
---该方法没有对插件包合法性进行检测，即使插件中没有入口点脚本也会罗列出来
---@param cfg table @{{PluginName,PluginPath,Enable}, ... }
---@return table @{{PluginName,PluginPath,Enable}, ... }
function plugin.FreshConfig(cfg)
	local path = plugin.GetDirectory()
	local fs = lstg.FindFiles(path, "zip", "")
	local rs = {}
	for _, v in pairs(fs) do
		local filename = string.sub(v[1], string.len(path) + 1, -5)
		table.insert(rs, { filename, v[1], false })--插件名、插件路径、是否启用插件
	end
	if type(cfg) == "table" then
		local ret = {}
		--读取已有的配置表的enable属性
		--同时去除无效的插件
		for _, i in ipairs(cfg) do
			for _, v in ipairs(rs) do
				if v[1] == i[1] and v[2] == i[2] then
					v[3] = i[3]
					table.insert(ret, v)
					break
				end
			end
		end
		local oldn = #ret
		--将新增的插件排在后面
		for _, v in ipairs(rs) do
			local flag = true
			--查重，如果重复跳过
			for i = 1, oldn do
				if v[1] == ret[i][1] and v[2] == ret[i][2] then
					flag = false
					break
				end
			end
			if flag then
				table.insert(ret, v)
			end
		end
		return ret
	else
		return rs
	end
end

---根据一个配置表，按照顺序加载插件
---@param cfg table @{{PluginName,PluginPath,Enable}, ... }
function plugin.LoadPluginsByConfig(cfg)
	for _, v in ipairs(cfg) do
		--跳过禁用的插件
		if v[3] then
			local pluginpath = v[2]
			plugin.LoadPlugin(pluginpath)
		end
	end
end

----------------------------------------
---接口

---加载所有插件包
function plugin.LoadPlugins()
	local cfg = plugin.LoadConfig()
	local tcfg = plugin.FreshConfig(cfg)
	plugin.SaveConfig(tcfg)
	plugin.LoadPluginsByConfig(tcfg)
end

---卸载所有插件包
function plugin.UnloadPlugins()
	local cfg = plugin.LoadConfig()
	local pluginpath = ""
	for _, v in ipairs(cfg) do
		pluginpath = v[2]
		plugin.UnloadPlugin(pluginpath)
	end
end

----------------------------------------
---导出类

lstg.plugin = plugin
