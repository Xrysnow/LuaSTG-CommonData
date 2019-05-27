---=====================================
---luastg screen
---=====================================

----------------------------------------
---screen

---@class screen
screen={}

---刷新并重置游戏坐标系参数
function ResetScreen()
	ResetScreen2()
	if setting.resx>setting.resy then
		ResetWorld()
		ResetWorldOffset()
	else
		lstg.world={l=-192,r=192,b=-224,t=224,boundl=-224,boundr=224,boundb=-256,boundt=256,scrl=6,scrr=390,scrb=16,scrt=464,pl=-192,pr=192,pb=-224,pt=224}
		SetBound(lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt)
		ResetWorldOffset()
	end
end

---刷新并重置游戏坐标系参数，不重置world坐标系
function ResetScreen2()
	if setting.resx>setting.resy then
		screen.width=640
		screen.height=480
		--计算两个方向的缩放
		screen.hScale=setting.resx/screen.width
		screen.vScale=setting.resy/screen.height
		--计算游戏分辨率横纵比
		screen.resScale=setting.resx/setting.resy
		--使用最小的缩放
		screen.scale=math.min(screen.hScale,screen.vScale)
		--根据坐标系缩放来更改视口偏移
		if screen.resScale>=(screen.width/screen.height) then
			screen.dx=(setting.resx-screen.scale*screen.width)*0.5
			screen.dy=0
		else
			screen.dx=0
			screen.dy=(setting.resy-screen.scale*screen.height)*0.5
		end
		lstg.scale_3d=0.007*screen.scale
	else
		--用于启动器
		screen.width=396
		screen.height=528
		screen.scale=setting.resx/screen.width
		screen.dx=0
		screen.dy=(setting.resy-screen.scale*screen.height)*0.5
		lstg.scale_3d=0.007*screen.scale
	end
end

----------------------------------------
---world

---默认的world参数，只读，留作备份
local RAW_DEFAULT_WORLD={
	l=-192,r=192,b=-224,t=224,
	boundl=-224,boundr=224,boundb=-256,boundt=256,
	scrl=32,scrr=416,scrb=16,scrt=464,
	pl=-192,pr=192,pb=-224,pt=224,
	world=15,
}
---默认的world参数，可更改
local DEFAULT_WORLD={
	l=-192,r=192,b=-224,t=224,
	boundl=-224,boundr=224,boundb=-256,boundt=256,
	scrl=32,scrr=416,scrb=16,scrt=464,
	pl=-192,pr=192,pb=-224,pt=224,
	world=15,
}

---设置默认world参数
function OriginalSetDefaultWorld(l,r,b,t,bl,br,bb,bt,sl,sr,sb,st,pl,pr,pb,pt,m)
	local w={}
	w.l=l
	w.r=r
	w.b=b
	w.t=t
	w.boundl=bl
	w.boundr=br
	w.boundb=bb
	w.boundt=bt
	w.scrl=sl
	w.scrr=sr
	w.scrb=sb
	w.scrt=st
	w.pl=pl
	w.pr=pr
	w.pb=pb
	w.pt=pt
	w.world=m
	DEFAULT_WORLD=w
end

---设置默认world参数
function SetDefaultWorld(l,b,w,h,bound,m)
	OriginalSetDefaultWorld(
		--l,r,b,t,
		(-w/2),(w/2),(-h/2),(h/2),
		--bl,br,bb,bt,
		(-w/2)-bound,(w/2)+bound,(-h/2)-bound,(h/2)+bound,
		--sl,sr,sb,st,
		(l),(l+w),(b),(b+h),
		--pl,pr,pb,pt
		(-w/2),(w/2),(-h/2),(h/2),
		--world mask
		m
	)
end

---获取备份的默认world参数
function RawGetDefaultWorld()
	local w={}
	for k,v in pairs(RAW_DEFAULT_WORLD) do
		w[k]=v
	end
	return w
end

---获取设置好的默认world参数
function GetDefaultWorld()
	local w={}
	for k,v in pairs(DEFAULT_WORLD) do
		w[k]=v
	end
	return w
end

---完全重置回备份的world参数
function RawResetWorld()
	local w={}
	lstg.world=lstg.world or w
	for k,v in pairs(RAW_DEFAULT_WORLD) do
		w[k]=v
		lstg.world[k]=v
	end
	DEFAULT_WORLD=w
	SetBound(lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt)
end

---重置回设置好的默认world参数
function ResetWorld()
	local w={}
	lstg.world=lstg.world or w
	for k,v in pairs(DEFAULT_WORLD) do
		w[k]=v
		lstg.world[k]=v
	end
	SetBound(lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt)
end

---设置world参数
function OriginalSetWorld(l,r,b,t,bl,br,bb,bt,sl,sr,sb,st,pl,pr,pb,pt,m)
	local w=lstg.world
	w.l=l
	w.r=r
	w.b=b
	w.t=t
	w.boundl=bl
	w.boundr=br
	w.boundb=bb
	w.boundt=bt
	w.scrl=sl
	w.scrr=sr
	w.scrb=sb
	w.scrt=st
	w.pl=pl
	w.pr=pr
	w.pb=pb
	w.pt=pt
	w.world=m
end

---设置world参数
function SetWorld(l,b,w,h,bound,m)
	bound=bound or 32
	m = m or 15
	OriginalSetWorld(
		--l,r,b,t,
		(-w/2),(w/2),(-h/2),(h/2),
		--bl,br,bb,bt,
		(-w/2)-bound,(w/2)+bound,(-h/2)-bound,(h/2)+bound,
		--sl,sr,sb,st,
		(l),(l+w),(b),(b+h),
		--pl,pr,pb,pt
		(-w/2),(w/2),(-h/2),(h/2),
		--world mask
		m
	)
	SetBound(lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt)
end

----------------------------------------
---world offset
---by ETC
---用于独立world本身的数据、world坐标系中心偏移和横纵缩放、world坐标系整体偏移

---默认world坐标系偏移参数，只读
local DEFAULT_WORLD_OFFSET={
	centerx=0,centery=0,--world中心位置偏移
	hscale=1,vscale=1,--world横向、纵向缩放
	dx=0,dy=0,--整体偏移
}

---world坐标系偏移参数
lstg.worldoffset={
	centerx=0,centery=0,--world中心位置偏移
	hscale=1,vscale=1,--world横向、纵向缩放
	dx=0,dy=0,--整体偏移
}

---重置world偏移
function ResetWorldOffset()
	lstg.worldoffset=lstg.worldoffset or {}
	for k,v in pairs(DEFAULT_WORLD_OFFSET) do
		lstg.worldoffset[k]=v
	end
end

---设置world偏移
function SetWorldOffset(centerx,centery,hscale,vscale)
	lstg.worldoffset.centerx=centerx
	lstg.worldoffset.centery=centery
	lstg.worldoffset.hscale=hscale or 1.0
	lstg.worldoffset.vscale=vscale or 1.0
end

----------------------------------------
---3d

---3d坐标系参数
lstg.view3d={
	eye={0,0,-1},
	at={0,0,0},
	up={0,1,0},
	fovy=PI_2,
	z={0,2},
	fog={0,0,Color(0x00000000)},
	rotate={0,0,0},
}

---重置回默认的3d坐标系参数
function Reset3D()
	lstg.view3d.eye={0,0,-1}
	lstg.view3d.at={0,0,0}
	lstg.view3d.up={0,1,0}
	lstg.view3d.fovy=PI_2
	lstg.view3d.z={1,2}
	lstg.view3d.fog={0,0,Color(0x00000000)}
	lstg.view3d.rotate={0,0,0}
end

---设置3d坐标系参数，
---当key为"eye"时，设置的是观察者的中心位置，a、b、c参数分别为x、y、z坐标，
---当key为"at"时，设置的是观察者看向的位置，a、b、c参数分别为x、y、z坐标，且eye-at向量应该为单位向量，
---当key为"up"是，设置的是观察者头顶的向量，该向量必须与eye-at向量正交，a、b、c参数分别为x、y、z分量，
---当key为"fovy"时，设置视野，a参数为弧度制角度值，
---当key为"z"时，设置裁剪范围，a、b参数分别为最近可见距离和最远可见距离，范围外的物体将不会被看见，a、b不能设置为负数且a<b，a也不能为0，
---当key为"fog"时，设置雾的范围，a、b参数分别为雾的过渡范围，c参数为雾颜色
---@param key string @"fog", "eye", "at", "up", "fovy", "z"，要设置的内容
---@param a number
---@param b number
---@param c number
function Set3D(key,a,b,c)
	if key=='fog' then
		a=tonumber(a or 0)
		b=tonumber(b or 0)
		lstg.view3d.fog={a,b,c}
		return
	end
	a=tonumber(a or 0)
	b=tonumber(b or 0)
	c=tonumber(c or 0)
	if key=='eye' then lstg.view3d.eye={a,b,c}
	elseif key=='at' then lstg.view3d.at={a,b,c}
	elseif key=='up' then lstg.view3d.up={a,b,c}
	elseif key=='fovy' then lstg.view3d.fovy=a
	elseif key=='z' then lstg.view3d.z={a,b}
	end
end

---设置3d下观察者的参数
---@param x number @x坐标
---@param y number @y坐标，应该视为z坐标
---@param z number @z坐标，应该视为y坐标
---@param orientation number @角度制面朝向，在x-z平面上，起始方向为x轴正方向
---@param pitch number @角度制面俯仰角，起始方向为x-z平面，向y轴正方向抬头角度增大，最大为逼近90度，向负方向低头角度减小，最小为逼近-90度
---@param rotate number @角度制旋转角，旋转视野，可顺时针旋转到180度、逆时针旋转到-180度
---@param fovy number @角度制视野
function Set3DCamera(x,y,z,orientation,pitch,rotate,fovy)
	--位置
	lstg.view3d.eye[1]=x or lstg.view3d.eye[1]
	lstg.view3d.eye[2]=y or lstg.view3d.eye[2]
	lstg.view3d.eye[3]=z or lstg.view3d.eye[3]
	--控制
	lstg.view3d.rotate[1]=orientation or lstg.view3d.rotate[1]
	lstg.view3d.rotate[2]=pitch or lstg.view3d.rotate[2]
	lstg.view3d.rotate[3]=rotate or lstg.view3d.rotate[3]
	orientation=lstg.view3d.rotate[1]
	pitch=lstg.view3d.rotate[2]
	rotate=lstg.view3d.rotate[3]
	local ax,ay,az=1,0,0
	local ux,uy,uz=0,1,0
	local function vecrot(x_,y_,rot_)
		return x_*cos(rot_)-y_*sin(rot_),y_*cos(rot_)+x_*sin(rot_)
	end
	--视野旋转--y-z
	uz,uy=vecrot(uz,uy,rotate)
	--面俯仰旋转--x-y
	ax,ay=vecrot(ax,ay,pitch)
	ux,uy=vecrot(ux,uy,pitch)
	--面朝向旋转--x-z
	ax,az=vecrot(ax,az,orientation)
	ux,uz=vecrot(ux,uz,orientation)
	--应用参数
	lstg.view3d.at={x+ax, y+ay, z+az}
	lstg.view3d.up={ux, uy, uz}
	--视野
	if fovy then
		fovy = fovy*math.pi/180
		lstg.view3d.fovy=fovy
	end
end

----------------------------------------
---坐标系切换

---最后一次设置的坐标系
lstg.viewmode="world"

---全局精灵缩放，默认1.0
lstg.globalimagescale=1.0

---设置全局精灵缩放
function SetGlobalImageScale(v)
	lstg.globalimagescale=v
	SetViewMode2(lstg.viewmode)
end

---更换坐标系
function SetViewMode(mode)
	lstg.viewmode=mode
	--lstg.scale_3d=((((lstg.view3d.eye[1]-lstg.view3d.at[1])^2+(lstg.view3d.eye[2]-lstg.view3d.at[2])^2+(lstg.view3d.eye[3]-lstg.view3d.at[3])^2)^0.5)*2*math.tan(lstg.view3d.fovy*0.5))/(lstg.world.scrr-lstg.world.scrl)
	if mode=='3d' then
		SetViewport(lstg.world.scrl*screen.scale+screen.dx,lstg.world.scrr*screen.scale+screen.dx,lstg.world.scrb*screen.scale+screen.dy,lstg.world.scrt*screen.scale+screen.dy)
		SetPerspective(
			lstg.view3d.eye[1],lstg.view3d.eye[2],lstg.view3d.eye[3],
			lstg.view3d.at[1],lstg.view3d.at[2],lstg.view3d.at[3],
			lstg.view3d.up[1],lstg.view3d.up[2],lstg.view3d.up[3],
			lstg.view3d.fovy,(lstg.world.r-lstg.world.l)/(lstg.world.t-lstg.world.b),
			lstg.view3d.z[1],lstg.view3d.z[2]
		)
		SetFog(lstg.view3d.fog[1],lstg.view3d.fog[2],lstg.view3d.fog[3])
		SetImageScale(((((lstg.view3d.eye[1]-lstg.view3d.at[1])^2+(lstg.view3d.eye[2]-lstg.view3d.at[2])^2+(lstg.view3d.eye[3]-lstg.view3d.at[3])^2)^0.5)*2*math.tan(lstg.view3d.fovy*0.5))/(lstg.world.scrr-lstg.world.scrl))
	elseif mode=='world' then
		--设置视口
		SetViewport(
			lstg.world.scrl*screen.scale+screen.dx,
			lstg.world.scrr*screen.scale+screen.dx,
			lstg.world.scrb*screen.scale+screen.dy,
			lstg.world.scrt*screen.scale+screen.dy
		)
		--计算world宽高和偏移
		local offset=lstg.worldoffset
		local world={
			height=(lstg.world.t-lstg.world.b),--world高度
			width=(lstg.world.r-lstg.world.l),--world宽度
		}
		world.setheight=world.height*(1/offset.vscale)--缩放后的高度
		world.setwidth=world.width*(1/offset.hscale)--缩放后的宽度
		world.setdx=offset.dx*(1/offset.hscale)--水平整体偏移
		world.setdy=offset.dy*(1/offset.vscale)--垂直整体偏移
		--计算world最终参数
		world.l=offset.centerx-(world.setwidth/2)+world.setdx
		world.r=offset.centerx+(world.setwidth/2)+world.setdx
		world.b=offset.centery-(world.setheight/2)+world.setdy
		world.t=offset.centery+(world.setheight/2)+world.setdy
		--应用参数
		SetOrtho(world.l,world.r,world.b,world.t)
		SetFog()
		SetImageScale(lstg.globalimagescale)
	elseif mode=='ui' then
		SetOrtho(0,screen.width,0,screen.height)
		SetViewport(screen.dx,screen.width*screen.scale+screen.dx,screen.dy,screen.height*screen.scale+screen.dy)
		SetFog()
		SetImageScale(lstg.globalimagescale)
	else
		error('Invalid arguement.')
	end
end

---更换坐标系，固定缩放
function SetViewMode2(mode)
	lstg.viewmode=mode
	--lstg.scale_3d=((((lstg.view3d.eye[1]-lstg.view3d.at[1])^2+(lstg.view3d.eye[2]-lstg.view3d.at[2])^2+(lstg.view3d.eye[3]-lstg.view3d.at[3])^2)^0.5)*2*math.tan(lstg.view3d.fovy*0.5))/(lstg.world.scrr-lstg.world.scrl)
	if mode=='3d' then
		SetViewport(lstg.world.scrl*screen.scale+screen.dx,lstg.world.scrr*screen.scale+screen.dx,lstg.world.scrb*screen.scale+screen.dy,lstg.world.scrt*screen.scale+screen.dy)
		SetPerspective(
			lstg.view3d.eye[1],lstg.view3d.eye[2],lstg.view3d.eye[3],
			lstg.view3d.at[1],lstg.view3d.at[2],lstg.view3d.at[3],
			lstg.view3d.up[1],lstg.view3d.up[2],lstg.view3d.up[3],
			lstg.view3d.fovy,(lstg.world.r-lstg.world.l)/(lstg.world.t-lstg.world.b),
			lstg.view3d.z[1],lstg.view3d.z[2]
		)
		SetFog(lstg.view3d.fog[1],lstg.view3d.fog[2],lstg.view3d.fog[3])
		SetImageScale(lstg.globalimagescale)-- TODO:这样的缩放可能会太过于巨大……但是统一了缩放级别
	elseif mode=='world' then
		--设置视口
		SetViewport(
			lstg.world.scrl*screen.scale+screen.dx,
			lstg.world.scrr*screen.scale+screen.dx,
			lstg.world.scrb*screen.scale+screen.dy,
			lstg.world.scrt*screen.scale+screen.dy
		)
		--计算world宽高和偏移
		local offset=lstg.worldoffset
		local world={
			height=(lstg.world.t-lstg.world.b),--world高度
			width=(lstg.world.r-lstg.world.l),--world宽度
		}
		world.setheight=world.height*(1/offset.vscale)--缩放后的高度
		world.setwidth=world.width*(1/offset.hscale)--缩放后的宽度
		world.setdx=offset.dx*(1/offset.hscale)--水平整体偏移
		world.setdy=offset.dy*(1/offset.vscale)--垂直整体偏移
		--计算world最终参数
		world.l=offset.centerx-(world.setwidth/2)+world.setdx
		world.r=offset.centerx+(world.setwidth/2)+world.setdx
		world.b=offset.centery-(world.setheight/2)+world.setdy
		world.t=offset.centery+(world.setheight/2)+world.setdy
		--应用参数
		SetOrtho(world.l,world.r,world.b,world.t)
		SetFog()
		SetImageScale(lstg.globalimagescale)
	elseif mode=='ui' then
		SetOrtho(0,screen.width,0,screen.height)
		SetViewport(screen.dx,screen.width*screen.scale+screen.dx,screen.dy,screen.height*screen.scale+screen.dy)
		SetFog()
		SetImageScale(lstg.globalimagescale)
	else
		error('Invalid arguement.')
	end
end

----------------------------------------
---坐标系映射

---world坐标系映射到ui坐标系
function WorldToUI(x,y)
	local w=lstg.world
	return w.scrl+(w.scrr-w.scrl)*(x-w.l)/(w.r-w.l),w.scrb+(w.scrt-w.scrb)*(y-w.b)/(w.t-w.b)
end

---world坐标系映射到窗口坐标系
function WorldToScreen(x,y)
	local w=lstg.world
	if setting.resx>setting.resy then
		return (setting.resx-setting.resy*screen.width/screen.height)/2/screen.scale+w.scrl+(w.scrr-w.scrl)*(x-w.l)/(w.r-w.l),w.scrb+(w.scrt-w.scrb)*(y-w.b)/(w.t-w.b)
	else
		return w.scrl+(w.scrr-w.scrl)*(x-w.l)/(w.r-w.l),(setting.resy-setting.resx*screen.height/screen.width)/2/screen.scale+w.scrb+(w.scrt-w.scrb)*(y-w.b)/(w.t-w.b)
	end
end

---窗口坐标系映射到world坐标系
function ScreenToWorld(x,y)
	local dx,dy=WorldToScreen(0,0)
	return x-dx,y-dy
end

----------------------------------------
---init

ResetScreen()--先初始化一次，！！！注意不能漏掉这一步
