---=====================================
---luastg resources
---=====================================

local LOG_MODULE_NAME="[LIB][RES]"
local USE_FINDFILES=true

----------------------------------------
---脚本载入

local _included = {}    --已加载的脚本
local _curpath = { "" } --路径栈
local _varargs = {}     --储存的脚本返回值

local function _get_varargs(...) return { ... } end

---加载lua脚本，可防止重复死循环加载，代价是无法更新同路径同文件名文件
---@param filename string @文件路径，可以通过类似 "~file.lua" 的方式使用上一次使用的完整路径
---@return any @多返回值
function Include(filename)
	filename = tostring(filename)
	
	if string.sub(filename, 1, 1) == '~' then
		filename = string.format("%s%s",
			_curpath[#_curpath],
			string.sub(filename, 2))
	end
	
	local ret = {}
	if _included[filename] and _varargs[filename] then
		ret = _varargs[filename]
	else
		local dir, _ = utility.partition_path(filename)
		table.insert(_curpath, dir)
		_included[filename] = true
		ret = _get_varargs(lstg.DoFile(filename))
		_varargs[filename] = ret
		table.remove(_curpath)
	end
	return unpack(ret)
end

---清理历史记录，一般用于重新加载
function ClearIncludeHistory()
	_included = {}
	_curpath = { "" }
	lstg.Log(2,LOG_MODULE_NAME,"The script file include history has been cleared.")
end

----------------------------------------
---资源载入

local ImageList = {}

---加载图片精灵
function LoadImage(img, ...)
	local arg = { ... }
	ImageList[img] = arg
	lstg.LoadImage(img, ...)
end

---获得加载的图片的大小
function GetImageSize(img)
	local arg = ImageList[img]
	if arg then
		return arg[4], arg[5]
	end
end

---复制一个图片精灵
function CopyImage(newname, img)
	if ImageList[img] then
		LoadImage(newname, unpack(ImageList[img]))
	elseif img then
		error("The image \"" .. img .. "\" can't be copied.")
	else
		error("Wrong argument #2 (expect string get nil)")
	end
end

---加载图片精灵组
function LoadImageGroup(prefix, texname, x, y, w, h, cols, rows, a, b, rect)
	for i = 0, cols * rows - 1 do
		LoadImage(
			prefix .. (i + 1), texname,
			x + w * (i % cols), y + h * (math.floor(i / cols)),
			w, h,
			a or 0, b or 0, rect or false)
	end
end

---从文件加载图片精灵
function LoadImageFromFile(teximgname, filename, mipmap, a, b, rect)
	lstg.LoadTexture(teximgname, filename, mipmap)
	local w, h = lstg.GetTextureSize(teximgname)
	LoadImage(teximgname, teximgname, 0, 0, w, h, a or 0, b or 0, rect)
end

---从文件加载动画
function LoadAniFromFile(texaniname, filename, mipmap, n, m, intv, a, b, rect)
	lstg.LoadTexture(texaniname, filename, mipmap)
	local w, h = lstg.GetTextureSize(texaniname)
	lstg.LoadAnimation(texaniname, texaniname, 0, 0, w / n, h / m, n, m, intv, a, b, rect)
end

---从文件加载图片精灵组
function LoadImageGroupFromFile(texaniname, filename, mipmap, n, m, a, b, rect)
	lstg.LoadTexture(texaniname, filename, mipmap)
	local w, h = lstg.GetTextureSize(texaniname)
	lstg.LoadImageGroup(texaniname, texaniname, 0, 0, w / n, h / m, n, m, a, b, rect)
end

---加载TTF字体
function LoadTTF(ttfname, filename, size)
	size = size or 10
	lstg.LoadTTF(ttfname, filename, 0, size)
end

----------------------------------------
---资源判断和枚举

local ENUM_RES_TYPE = { tex = 1, img = 2, ani = 3, bgm = 4, snd = 5, psi = 6, fnt = 7, ttf = 8, fx = 9 }

local function _FileExist(filename)
	return not (lfs.attributes(filename) == nil)
end

---检查资源是否存在
---@param typename string
---@param resname string
---@return boolean
function CheckRes(typename, resname)
	local t = ENUM_RES_TYPE[typename]
	if t == nil then
		error('Invalid resource type name.')
	else
		return lstg.CheckRes(t, resname)
	end
end

---枚举资源
---@param typename string
---@return table,table
function EnumRes(typename)
	local t = ENUM_RES_TYPE[typename]
	if t == nil then
		error('Invalid resource type name.')
	else
		return lstg.EnumRes(t)
	end
end

---判断文件是否存在
---@param fullfilepath string @文件路径
---@param fullrespackpath string|nil @资源包路径（可选，如果要查找特定资源包内的资源）
---@return boolean
function FileExist(fullfilepath,fullrespackpath)
	if USE_FINDFILES then
		--统一分割符
		fullfilepath =string.gsub(fullfilepath, "\\", "/")
		fullfilepath =string.gsub(fullfilepath, "//", "/")
		--查找路径
		local path=utility.partition_path(fullfilepath)
		--查找
		local fs
		if fullrespackpath then
			--资源包内不需要处理资源包根目录的情况……
			fs=lstg.FindFiles(path,"",fullrespackpath)
		else
			--文件系统根目录下要加一个/在开头
			-- TODO:找时间把底层这个傻吊问题改了
			if string.len(path)<=0 then
				path="/"
				fullfilepath=path..fullfilepath
			end
			fs=lstg.FindFiles(path,"")
		end
		for _,v in pairs(fs) do
			if v[1]== fullfilepath then
				return true
			end
		end
		return false
	else
		return _FileExist(fullfilepath)
	end
end
