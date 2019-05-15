---=====================================
---touhou style bullet
---=====================================

----------------------------------------
---资源载入

local function loadres()
	------etbreak-------------
	LoadTexture('etbreak','THlib/bullet/etbreak.png')
	for j=1,16 do
		LoadAnimation('etbreak'..j,'etbreak',0,0,64,64,4,2,3)
	end
	local BulletBreakIndex={
		Color(0xC0FF3030),--red
		Color(0xC0FF30FF),--purple
		Color(0xC03030FF),--blue
		Color(0xC030FFFF),--cyan
		Color(0xC030FF30),--green
		Color(0xC0FFFF30),--yellow
		Color(0xC0FF8030),--orange
		Color(0xC0D0D0D0),--gray
	}
	for j=1,16 do
		if j%2==0 then
			SetAnimationState('etbreak'..j,'mul+add',BulletBreakIndex[j/2])
		elseif j==15 then
			SetAnimationState('etbreak'..j,'',0.5*BulletBreakIndex[(j+1)/2]+Color(0x60000000))
		else
			SetAnimationState('etbreak'..j,'mul+add',0.5*BulletBreakIndex[(j+1)/2]+Color(0x60000000))
		end
	end
end

loadres()

----------------------------------------
---static color enum

COLOR_DEEP_RED=1
COLOR_RED=2
COLOR_DEEP_PURPLE=3
COLOR_PURPLE=4
COLOR_DEEP_BLUE=5
COLOR_BLUE=6
COLOR_ROYAL_BLUE=7
COLOR_CYAN=8
COLOR_DEEP_GREEN=9
COLOR_GREEN=10
COLOR_CHARTREUSE=11
COLOR_YELLOW=12
COLOR_GOLDEN_YELLOW=13
COLOR_ORANGE=14
COLOR_DEEP_GRAY=15
COLOR_GRAY=16

----------------------------------------
---基础bullet类

---默认消弹效果
BulletBreak=Class(object)

function BulletBreak:init(x,y,index)
	self.x=x
	self.y=y
	self.group=GROUP_GHOST
	self.layer=LAYER_ENEMY_BULLET-50
	self.img='etbreak'..index
	local s = ran:Float(0.5,0.75)
	self.hscale=s self.vscale=s
	self.rot=ran:Float(0,360)
end

function BulletBreak:frame()
	if self.timer==23 then Del(self) end
end


---基础弹型class
bullet=Class(object)

function bullet:init(imgclass,index,stay,destroyable)
	self.logclass=self.class
	self.imgclass=imgclass
	self.class=imgclass
	if destroyable then self.group=GROUP_ENEMY_BULLET else self.group=GROUP_INDES end
	if type(index)=='number' then
		self.colli=true
		self.stay=stay
		index=int(min(max(1,index),16))
		self.layer=LAYER_ENEMY_BULLET_EF-imgclass.size*0.001+index*0.00001
		self._index=index
		self.index=int((index+1)/2)
	end
	imgclass.init(self,index)
end

function bullet:frame()
	task.Do(self)
end

function bullet:render()
	if self._blend and self._a and self._r and self._g and self._b then
		SetImgState(self,self._blend,self._a,self._r,self._g,self._b)
		DefaultRenderFunc(self)
		SetImgState(self,'',255,255,255,255)
	else
		DefaultRenderFunc(self)
	end
end

function bullet:del()
	local w=lstg.world
	if self.imgclass.size==2.0 then
		self.imgclass.del(self)
	end
	if self._index and BoxCheck(self,w.boundl,w.boundr,w.boundb,w.boundt) then
		New(BulletBreak,self.x,self.y,self._index)
	end
end

function bullet:kill()
	local w=lstg.world
	if self.imgclass.size==2.0 then
		self.imgclass.del(self)
	end
	if self._index and BoxCheck(self,w.boundl,w.boundr,w.boundb,w.boundt) then
		New(BulletBreak,self.x,self.y,self._index)
	end
	New(item_faith_minor,self.x,self.y)
end


---基础弹型class，弹雾效果的实现
img_class=Class(object)

function img_class:frame()
	if not self.stay then
		if not(self._forbid_ref) then--by OLC，修正了defaul action死循环的问题
			self._forbid_ref=true
			self.logclass.frame(self)
			self._forbid_ref=nil
		end
	else
		self.x=self.x-self.vx
		self.y=self.y-self.vy
		self.rot=self.rot-self.omiga
	end
	if self.timer==11 then
		self.class=self.logclass
		self.layer=LAYER_ENEMY_BULLET-self.imgclass.size*0.001+self._index*0.00001
		if self.stay then self.timer=-1 end
	end
end

function img_class:del()
	New(bubble2,'preimg'..self.index,
		self.x,self.y,
		self.dx,self.dy,
		11,self.imgclass.size,0,
		Color(0xFFFFFFFF),Color(0xFFFFFFFF),self.layer,'mul+add')
end

function img_class:kill()
	img_class.del(self)
	--New(BulletBreak,self.x,self.y,self._index)
	New(item_faith_minor,self.x,self.y)
end

function img_class:render()
	if self._blend then
		SetImageState('preimg'..self.index,self._blend,Color(255*self.timer/11,255,255,255))
	else
		SetImageState('preimg'..self.index,'',Color(255*self.timer/11,255,255,255))
	end
	Render('preimg'..self.index,self.x,self.y,self.rot,((11-self.timer)/11*3+1)*self.imgclass.size)
end


---改变弹型
---@param obj object
---@param imgclass lstgClass
---@param index number @颜色
function ChangeBulletImage(obj,imgclass,index)
	if obj.class==obj.imgclass then
		obj.class=imgclass
		obj.imgclass=imgclass
	else
		obj.imgclass=imgclass
	end
	obj._index=index
	imgclass.init(obj,obj._index)
end

Include("Thlib/bullet/bullet_library.lua")--弹型读取

----------------------------------------
---导入弹型

Include("Thlib/bullet/bulletdef_default.lua")--默认弹型

----------------------------------------
---simple bullet

straight=Class(bullet)

function straight:init(imgclass,index,stay,x,y,v,angle,omiga)
	self.x=x self.y=y
	SetV(self,v,angle,true)
	self.omiga=omiga or 0
	bullet.init(self,imgclass,index,stay,true)
end


straight_indes=Class(bullet)

function straight_indes:init(imgclass,index,stay,x,y,v,angle,omiga)
	self.x=x self.y=y
	SetV(self,v,angle,true)
	self.omiga=omiga or 0
	bullet.init(self,imgclass,index,stay,false)
	self.group=GROUP_INDES
end


straight_495=Class(bullet)

function straight_495:init(imgclass,index,stay,x,y,v,angle,omiga)
	self.x=x self.y=y
	SetV(self,v,angle,true)
	self.omiga=omiga or 0
	bullet.init(self,imgclass,index,stay,true)
end

function straight_495:frame()
	if not self.reflected then
		local world = lstg.world
		local x, y = self.x, self.y
		if y > world.t then
			self.vy = -self.vy
			self.ay = -self.ay
			self.rot = -self.rot
			self.reflected = true
			return
		end
		if x > world.r then
			self.vx = -self.vx
			self.ay = -self.ay
			self.rot = 180 - self.rot
			self.reflected = true
			return
		end
		if x < world.l then
			self.vx = -self.vx
			self.ax = -self.ax
			self.rot = 180 - self.rot
			self.reflected = true
			return
		end
	end
end

----------------------------------------
---bullet killer

bullet_killer=Class(object)

function bullet_killer:init(x,y,kill_indes)
	self.x=x
	self.y=y
	self.group=GROUP_GHOST
	self.hide=true
	self.kill_indes=kill_indes
end

function bullet_killer:frame()
	if self.timer==40 then Del(self) end
	for i,o in ObjList(GROUP_ENEMY_BULLET) do
		if Dist(self,o)<self.timer*20 then Kill(o) end
	end
	if self.kill_indes then
		for i,o in ObjList(GROUP_INDES) do
			if Dist(self,o)<self.timer*20 then Kill(o) end
		end
	end
end


bullet_deleter=Class(object)

function bullet_deleter:init(x,y,kill_indes)
	self.x=x
	self.y=y
	self.group=GROUP_GHOST
	self.hide=true
	self.kill_indes=kill_indes
end

function bullet_deleter:frame()
	if self.timer==60 then Del(self) end
	for i,o in ObjList(GROUP_ENEMY_BULLET) do
		if Dist(self,o)<self.timer*20 then Del(o) end
	end
	if self.kill_indes then
		for i,o in ObjList(GROUP_INDES) do
			if Dist(self,o)<self.timer*20 then Del(o) end
		end
	end
end


bullet_deleter2=Class(object)

function bullet_deleter:init(x,y,kill_indes)
	self.player=Player(self)--by ETC，多玩家时处理
	self.x=self.player.x
	self.y=self.player.y
	self.group=GROUP_GHOST
	self.hide=true
	self.kill_indes=kill_indes
end

function bullet_deleter2:frame()
	self.x=self.player.x
	self.y=self.player.y
	if self.timer==30 then Del(self) end
	for i,o in ObjList(GROUP_ENEMY_BULLET) do
		if Dist(self,o)<self.timer*5 then Del(o) end
	end
	if self.kill_indes then
		for i,o in ObjList(GROUP_INDES) do
			if Dist(self,o)<self.timer*5 then Del(o) end
		end
	end
end


bomb_bullet_killer=Class(object)

function bomb_bullet_killer:init(x,y,a,b,kill_indes)
	self.x=x self.y=y
	self.a=a self.b=b
	if self.a~=self.b then self.rect=true end
	self.group=GROUP_PLAYER
	self.hide=true
	self.kill_indes=kill_indes
end

function bomb_bullet_killer:frame()
	if self.timer==1 then Del(self) end
end

function bomb_bullet_killer:colli(other)
	if self.kill_indes then
		if other.group==GROUP_INDES then
			Kill(other)
		end
	end
	if other.group==GROUP_ENEMY_BULLET then Kill(other) end
end

----------------------------------------
---基础bullet集合

BULLETSTYLE=
{
	arrow_big,arrow_mid,arrow_small,gun_bullet,butterfly,square,
	ball_small,ball_mid,ball_mid_c,ball_big,ball_huge,ball_light,
	star_small,star_big,grain_a,grain_b,grain_c,kite,knife,knife_b,
	water_drop,mildew,ellipse,heart,money,music,silence,
	water_drop_dark,ball_huge_dark,ball_light_dark
}--30
