---=====================================
---luastg package manager
---code by Xiliusha
---用于管理data包
---=====================================

local LOG_MODULE_NAME = "[LIB][PACK]"

local function _get_args( ... ) return { ... } end

local function _debug( ... ) lstg.Log(1, LOG_MODULE_NAME, ... ) end

----------------------------------------
---package manager

local PACKAGE_ROOT_DIR     = ""               --各种文件根目录
local PACKAGE_INSTALL_FILE = "__init__.lua"   --装载入口点文件
local PACKAGE_REMOVE_FILE  = "__remove__.lua" --卸载入口点文件
local PACKAGE_INFO_FILE    = "__info__.lua"   --描述文件

---包管理器
---@class PackageManager
local lib = {}

---包信息
---@class PachageInfo : table
local PACKAGE_INFO = {
	---包名称（必须）
	---@type string
	name = "package",
	
	---版本（可选）
	---@type number
	version = 0,
	
	---作者（可选）
	---@type string
	author = "Unkown",
	
	---时间（可选）
	---@type string
	time = "Unkown",
	
	---额外信息，包的描述
	---@type string
	desc = "This is a package.",
}

----------------------------------------
---directory

---包目录分级路径
---@type string[]
local path = {"Library", "package"}

---目录迭代器，逐级返回分级目录
---@return fun():string
function lib.Directory()
	local index = 0
	local count = #path
	if count > 0 then
		--正常的迭代
		return function()
			index = index + 1
			if index <= count then
				local dir=""
				for i,v in ipairs(path) do
					if i <= index then
						dir = string.format("%s%s/", dir, v)
					else
						break
					end
				end
				return dir
			end
		end
	else
		--处理根目录的情况
		return function()
			if index < 1 then
				index = index + 1
				return ""
			end
		end
	end
end

---返回当前插件管理器设置的包目录路径
---@return string
function lib.GetDirectory()
	local dir=""
	for _,v in ipairs(path) do
		dir = string.format("%s%s/", dir, v)
	end
	return dir
end

---设置当前插件管理器管理的包目录路径
---@param s string
function lib.SetDirectory(s)
	s = string.gsub(s,"\\","/")
	s = string.gsub(s,"//","/")
	if string.len(s) < 1 then--根目录
		path={}
		return
	elseif string.sub(s, -1 ,-1) ~= '/' then--处理路径末尾不带分割符的情况
		s = string.format("%s/", s)
	end
	local t={}
	for v in string.gmatch(s,"[^/]+") do--匹配除了/外的所有字符
		if string.len(v) < 1 then
			error("Directory format error.")
		end
		table.insert(t, v)
	end
	path=t
	
	for v in lib.Directory() do
		if not plus.DirectoryExists(v) then
			plus.CreateDirectory(v)
		end
	end
	lstg.Log(2, LOG_MODULE_NAME, string.format("The package directory is set to : %q", lib.GetDirectory()))
end

----------------------------------------
---packages

---包信息汇总
local _packages = {}

---已打开的zip文件
local _openzipfiles = {}

---已打开的包
local _openpacks = {}

---枚举包目录路径下的压缩包文件
---@return table @{path:string, name:string, name2:string}
function lib.EnumZipFiles()
	_debug("EnumZipFiles")
	local searchdir = lib.GetDirectory()
	local flag = false
	if string.len(searchdir) < 1 then
		searchdir = "/"
		flag = true
	end
	local ext = "zip"
	local fs = lstg.FindFiles(searchdir, ext, "")
	local ret = {}
	for _,f in ipairs(fs) do
		if flag then
			table.insert(ret, {
				path = string.sub(f[1], 2, -1),
				name = string.sub(f[1], string.len(searchdir) + 1, -1 - string.len(ext)),
				name2 = string.sub(f[1], string.len(searchdir) + 1, -1),
			})
		else
			table.insert(ret, {
				path = f[1],
				name = string.sub(f[1], string.len(searchdir) + 1, -1 - string.len(ext)),
				name2 = string.sub(f[1], string.len(searchdir) + 1, -1),
			})
		end
	end
	return ret
end

---枚举包目录下的文件夹
---@return table @{path:string, name:string, name2:string}
function lib.EnumDirectories()
	_debug("EnumDirectories")
	local dir = lib.GetDirectory()
	local searchdir = string.format("./%s", dir)
	local ds = plus.EnumFiles(searchdir)
	local ret = {}
	for _,f in ipairs(ds) do
		if f.isDirectory then
			table.insert(ret,{
				path = string.format("%s%s/", dir, f.name),
				name = f.name,
				name2 = f.name,
			})
		end
	end
	return ret
end

---获取压缩包文件内几种基本文件的存在情况
---@param s string @zip包文件完整路径，不是包名！
---@param pw string|nil @可选的密码，在包没有密码或者包已加载的时候不需要
---@param loaded boolean|nil @已加载包文件
---@return table<string, boolean> @{init:boolean, remove:boolean, info:boolean}
function lib.CheckZipFileRootFiles(s, pw, loaded)
	_debug("CheckZipFileRootFiles")
	if not loaded then
		if pw then
			lstg.LoadPack(s, pw)
		else
			lstg.LoadPack(s)
		end
	end
	
	local _check={
		init = false,
		remove = false,
		info = false,
	}
	local _flag={
		init = false,
		remove = false,
		info = false,
	}
	--查找文件
	local fs = lstg.FindFiles(PACKAGE_ROOT_DIR, "lua", s)
	for _,v in pairs(fs) do
		local filename = string.sub(v[1], string.len(PACKAGE_ROOT_DIR) + 1 ,-1)--获取文件名
		if filename == PACKAGE_INFO_FILE then
			if not _flag.info then
				_check.info = true
				_flag.info = true
			end
		elseif filename == PACKAGE_INSTALL_FILE then
			if not _flag.init then
				_check.init = true
				_flag.init = true
			end
		elseif filename == PACKAGE_REMOVE_FILE then
			if not _flag.remove then
				_check.remove = true
				_flag.remove = true
			end
		end
	end
	
	if not loaded then
		lstg.UnloadPack(s)
	end
	
	return _check
end

---获取文件夹内几种基本文件的存在情况
---@param s string @文件夹完整路径，不是包名！
---@return table<string, boolean> @{init:boolean, remove:boolean, info:boolean}
function lib.CheckDirectoryRootFiles(s)
	_debug("CheckDirectoryRootFiles")
	
	local _check={
		init = false,
		remove = false,
		info = false,
	}
	local _flag={
		init = false,
		remove = false,
		info = false,
	}
	local searchdir = string.format("%s%s", s, PACKAGE_ROOT_DIR)
	if string.len(searchdir) < 1 then
		searchdir = "/"
	end
	--查找
	local fs = lstg.FindFiles(searchdir, "lua", "")
	for _,v in pairs(fs) do
		local filename = string.sub(v[1], string.len(searchdir) + 1 ,-1)--获取文件名
		if filename == PACKAGE_INFO_FILE then
			if not _flag.info then
				_check.info = true
				_flag.info = true
			end
		elseif filename == PACKAGE_INSTALL_FILE then
			if not _flag.init then
				_check.init = true
				_flag.init = true
			end
		elseif filename == PACKAGE_REMOVE_FILE then
			if not _flag.remove then
				_check.remove = true
				_flag.remove = true
			end
		end
	end
	
	return _check
end

---加载zip包内指定基本文件
---@param ftype string @"init", "remove", "info" 文件类型
---@param s string @zip包文件完整路径，不是包名！
---@param pw string|nil @可选的密码，在包没有密码或者包已加载的时候不需要
---@param loaded boolean|nil @已加载包文件
---@return any
function lib.LoadZipFileRootFile(ftype, s, pw, loaded)
	_debug("LoadZipFileRootFile")
	if not loaded then
		if pw then
			lstg.LoadPack(s, pw)
		else
			lstg.LoadPack(s)
		end
	end
	
	local KV = {
		["init"] = PACKAGE_INSTALL_FILE,
		["remove"] = PACKAGE_REMOVE_FILE,
		["info"] = PACKAGE_INFO_FILE,
	}
	local ret = _get_args(lstg.DoFile(string.format("%s%s", PACKAGE_ROOT_DIR, KV[ftype]), s))
	
	if not loaded then
		lstg.UnloadPack(s)
	end
	
	return unpack(ret)
end

---加载文件夹内指定基本文件
---@param ftype string @"init", "remove", "info" 文件类型
---@param s string @文件夹完整路径，不是包名！
---@return any
function lib.LoadDirectoryRootFile(ftype, s)
	_debug("LoadDirectoryRootFile")
	
	local KV = {
		["init"] = PACKAGE_INSTALL_FILE,
		["remove"] = PACKAGE_REMOVE_FILE,
		["info"] = PACKAGE_INFO_FILE,
	}
	return lstg.DoFile(string.format("%s%s%s", s, PACKAGE_ROOT_DIR, KV[ftype]))
end

---刷新包管理器
function lib.RefreshPackages()
	_packages = {}
	
	for _,f in ipairs(lib.EnumZipFiles()) do
		--检查基本文件
		local check = lib.CheckZipFileRootFiles(f.path, nil, _openzipfiles[f.path])--这时候压缩包应该还没加载……
		--获取信息
		local _info
		do
			if check.info then--尝试加载zip包内的内置信息
				_info = lib.LoadZipFileRootFile("info", f.path, nil, _openzipfiles[f.path])--这时候压缩包应该还没加载……
			end
			local flag = false
			if type(_info) == "table" then--检查信息是否合法
				if _info.name then
					flag = true
				end
			end
			if not flag then--info信息失效，使用zip文件名作为包名
				_info = {
					name = f.name,
					version = PACKAGE_INFO.version,
					author = PACKAGE_INFO.author,
					time = PACKAGE_INFO.time,
				}
			end
		end
		--记录
		if _packages[_info.name] then
			lstg.Log(3, LOG_MODULE_NAME, string.format("The package name %q repetition", _info.name))
		else
			_packages[_info.name] = {
				name = _info.name,--包名
				
				path = f.path,--zip文件路径
				filename = f.name,--zip文件名
				filename2 = f.name2,--zip文件名（带拓展名）
				directory = false,--是文件夹包
				
				info = _info,--包信息
				files = check,--包内基本文件
			}
		end
	end
	
	for _,f in ipairs(lib.EnumDirectories()) do
		--检查基本文件
		local check = lib.CheckDirectoryRootFiles(f.path)
		--获取信息
		local _info
		do
			if check.info then--尝试加载zip包内的内置信息
				_info = lib.LoadDirectoryRootFile("info", f.path)
			end
			local flag = false
			if type(_info) == "table" then--检查信息是否合法
				if _info.name then
					flag = true
				end
			end
			if not flag then--info信息失效，使用zip文件名作为包名
				_info = {
					name = f.name,
					version = PACKAGE_INFO.version,
					author = PACKAGE_INFO.author,
					time = PACKAGE_INFO.time,
				}
			end
		end
		--记录
		if _packages[_info.name] then
			lstg.Log(3, LOG_MODULE_NAME, string.format("The package name %q repetition", _info.name))
		else
			_packages[_info.name] = {
				name = _info.name,--包名
				
				path = f.path,--文件夹路径
				filename = f.name,--文件夹名
				filename2 = f.name2,--文件夹名
				directory = true,--是文件夹包
				
				info = _info,--包信息
				files = check,--包内基本文件
			}
		end
	end
end

----------------------------------------
---interface

---获取包信息
---@param s string @包名
---@return PachageInfo|nil
function lib.GetInfo(s)
	_debug("GetInfo")
	if _packages[s] then
		return _packages[s].info
	end
end

---要求包
---@param s string @包名
---@return boolean
function lib.RequirePackage(s)
	_debug("RequirePackage")
	if _packages[s] then
		--看情况加载zip文件
		local pack = _packages[s]
		if (not pack.directory) and (not _openzipfiles[pack.path]) then--不是文件夹而且包没有加载
			lstg.LoadPack(pack.path)
			_openzipfiles[pack.path] = true
		end
		--看情况加载入口点文件
		if pack.files.init then
			if pack.directory then
				__args__={pack.path, true}--文件夹路径，是文件夹
				lib.LoadDirectoryRootFile("init", pack.path)
				__args__=nil
				lstg.Log(2, LOG_MODULE_NAME,
					string.format("Load package : %q, full package directory : %q.", s, pack.path))
			else
				__args__={pack.path, false}--zip包文件路径，不是文件夹
				lib.LoadZipFileRootFile("init", pack.path, nil, _openzipfiles[pack.path])
				__args__=nil
				lstg.Log(2, LOG_MODULE_NAME,
					string.format("Load package : %q, full package file name : %q.", s, pack.path))
			end
		else
			lstg.Log(3, LOG_MODULE_NAME,
				string.format("Load package : %q, without init script.", s))
		end
		--标记打开的包
		_openpacks[s] = true
		return true
	else
		lstg.Log(4, LOG_MODULE_NAME, string.format("Failed to find package : %q.", s))
		return false
	end
end

---移除包
---@param s string @包名
function lib.RemovePackage(s)
	if _packages[s] and _openpacks[s] then
		local pack = _packages[s]
		--看情况执行remove文件
		if pack.directory then
			__args__={pack.path, true}--文件夹路径，是文件夹
			lib.LoadDirectoryRootFile("remove", pack.path)
			__args__=nil
		else
			__args__={pack.path, false}--zip包文件路径，不是文件夹
			lib.LoadZipFileRootFile("remove", pack.path, nil, _openzipfiles[pack.path])
			__args__=nil
			--看情况卸载zip文件
			if _openzipfiles[pack.path] then
				_openzipfiles[pack.path] = false
				lstg.UnloadPack(pack.path)
			end
		end
		--取消标记打开的包
		_openpacks[s] = false
		lstg.Log(2, LOG_MODULE_NAME,
			string.format("Unload package : %q.", s))
	end
end

----------------------------------------
---out

---@type PackageManager
lstg.package = lib

lstg.package.SetDirectory("Library/package/")--默认路径
lstg.package.RefreshPackages()--先刷新一次
