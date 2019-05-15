---=====================================
---core
---所有基础的东西都会在这里定义
---=====================================

---@class lstg @内建函数库
lstg=lstg or {}

----------------------------------------
---各个模块

lstg.DoFile("plus/plus.lua")--CHU神的plus库
lstg.DoFile("lib/Llib.lua")--luastg base library

----------------------------------------
---用户定义的一些函数

---行为帧动作(和游戏循环的帧更新分开)
function DoFrame()
	--设置标题
	SetTitle(setting.mod..' | FPS='..GetFPS()..' | OBJ='..GetnObj())
	--获取输入
	GetInput()
	--切关处理
	if stage.next_stage then
		stage.current_stage=stage.next_stage
		stage.next_stage=nil
		stage.current_stage.timer=0
		stage.current_stage:init()
	end
	task.Do(stage.current_stage)
	stage.current_stage:frame()
	stage.current_stage.timer=stage.current_stage.timer+1
	--object frame function
	ObjFrame()
	--碰撞检测
	BoundCheck()
	CollisionCheck(GROUP_PLAYER,GROUP_ENEMY_BULLET)
	CollisionCheck(GROUP_PLAYER,GROUP_ENEMY)
	CollisionCheck(GROUP_PLAYER,GROUP_INDES)
	CollisionCheck(GROUP_ENEMY,GROUP_PLAYER_BULLET)
	CollisionCheck(GROUP_NONTJT,GROUP_PLAYER_BULLET)
	CollisionCheck(GROUP_ITEM,GROUP_PLAYER)
	--后更新
	UpdateXY()
	AfterFrame()
	--切关时清空资源和回收对象
	if stage.next_stage and stage.current_stage then
		stage.current_stage:del()
		task.Clear(stage.current_stage)
		if stage.preserve_res then
			stage.preserve_res=nil
		else
			RemoveResource'stage'
		end
		ResetPool()
	end
end

function BeforeRender() end

function AfterRender() end

function GameExit() end

----------------------------------------
---全局回调函数，底层调用

function GameInit()
	--加载mod包
	if setting.mod~='launcher' then
		Include 'root.lua'
	else
		Include 'launcher.lua'
	end
	if setting.mod~='launcher' then
		_mod_version=_mod_version or 0
		if _mod_version>_luastg_version or _mod_version<_luastg_min_support then
			error(string.format(
				"Mod version and engine version mismatch. Mod version is %.2f, LuaSTG version is %.2f.",
				_mod_version/100,
				_luastg_version/100
			))
		end
	end
	--最后的准备
	InitAllClass()--对所有class的回调函数进行整理，给底层调用
	InitScoreData()--装载玩家存档
	
	SetViewMode("world")
	if stage.next_stage==nil then
		error('Entrance stage not set.')
	end
	SetResourceStatus("stage")
end

function FrameFunc()
	DoFrame(true,true)
	if lstg.quit_flag then GameExit() end
	return lstg.quit_flag
end

function RenderFunc()
	if stage.current_stage.timer>=0 and stage.next_stage==nil then
		BeginScene()
		BeforeRender()
		stage.current_stage:render()
		ObjRender()
		AfterRender()
		EndScene()
	end
end

function FocusLoseFunc() end

function FocusGainFunc() end
