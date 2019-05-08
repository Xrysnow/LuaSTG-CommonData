---=====================================
---luastg utility
---=====================================

---实用方法
---@class utility
utility = {}

----------------------------------------
---cjson

---格式化cjson格式化得到的字符串，增加换行、缩进
---@author @Xrysnow
---@param str string
---@return string
function utility.format_json(str)
	local ret = ''
	local indent = '	'
	local level = 0
	local in_string = false
	for i = 1, #str do
		local s = string.sub(str, i, i)
		if s == '{' and (not in_string) then
			level = level + 1
			ret = ret .. '{\n' .. string.rep(indent, level)
		elseif s == '}' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s}', ret, string.rep(indent, level))
		elseif s == '"' then
			in_string = not in_string
			ret = ret .. '"'
		elseif s == ':' and (not in_string) then
			ret = ret .. ': '
		elseif s == ',' and (not in_string) then
			ret = ret .. ',\n'
			ret = ret .. string.rep(indent, level)
		elseif s == '[' and (not in_string) then
			level = level + 1
			ret = ret .. '[\n' .. string.rep(indent, level)
		elseif s == ']' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s]', ret, string.rep(indent, level))
		else
			ret = ret .. s
		end
	end
	return ret
end

---从路径中分离出文件夹路径和文件名
---@param path string
---@return string,string
function utility.partition_path(path)
	local dir, fname = "", ""
	local i, j = string.find(path, "^.+[\\/]+")
	if i then
		dir = string.sub(path, i, j)
		fname = string.sub(path, j + 1)
	else
		fname = path
	end
	return dir, fname
end
