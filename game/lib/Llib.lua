---=====================================
---luastg base library
---=====================================

local _path = "lib/"

local function _load(m)
	lstg.DoFile(
		string.format("%s%s.lua",
			_path, m))
end

_load("Lutility")--实用功能
_load("Llog")--简单的log系统
_load("Ldebug")--简单的debug信息获取
_load("Lglobal")--用户全局变量
_load("Lmath")--数学常量、数学函数、随机数系统
_load("Lobject")--Luastg的Class、object以及单位管理
_load("Lresources")--资源的加载函数、资源枚举和判断
_load("Lscreen")--world、3d、viewmode的参数设置
_load("Linput")--按键状态更新
_load("Ltask")--协同任务系统
_load("Lstage")--stage关卡场景
_load("Ltext")--文字渲染
_load("Lscoredata")--存档
_load("Lsound")--声音播放
_load("Lpackage")--包管理
_load("Lplugin")--插件包管理
