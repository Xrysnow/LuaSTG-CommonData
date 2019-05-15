local PATH="Thlib/bullet/"

----------通用弹型----------

local def={}

--name,image,colorcnt,size,a,b,rect
def.type={
	--region bullet1
	{      "arrow_big",      "arrow_big",16,  0.6,2.5,2.5,false},
	{     "gun_bullet",     "gun_bullet",16,  0.4,2.5,2.5,false},
	{"gun_bullet_void","gun_bullet_void",16,  0.4,2.5,2.5,false},
	{      "butterfly",      "butterfly", 8,  0.7,  4,  4,false},
	{         "square",         "square",16,  0.8,  3,  3,false},
	{       "ball_mid",       "ball_mid", 8, 0.75,  4,  4,false},
	{         "mildew",         "mildew",16,0.401,  2,  2,false},
	{        "ellipse",        "ellipse", 8,0.701,4.5,4.5,false},
	--endregion
	--region bullet2
	{"star_small","star_small",16,  0.5,  3,  3,false},
	{  "star_big",  "star_big", 8,0.998,5.5,5.5,false},
	{  "ball_big",  "ball_big", 8,  1.0,  8,  8,false},
	{"ball_small","ball_small",16,0.402,  2,  2,false},
	{   "grain_a",   "grain_a",16,0.403,2.5,2.5,false},
	{   "grain_b",   "grain_b",16,0.404,2.5,2.5,false},
	--endregion
	--region bullet3
	{      "knife",      "knife", 8,0.754,  4,  4,false},
	{    "grain_c",    "grain_c",16,0.405,2.5,2.5,false},
	{"arrow_small","arrow_small",16,0.407,2.5,2.5,false},
	{       "kite",       "kite",16,0.406,2.5,2.5,false},
	--endregion
	--region bullet4
	{"star_big_b","star_big_b", 8,0.999,  6,  6,false},
	{"ball_mid_b","ball_mid_b", 8,0.751,  4,  4,false},
	{ "arrow_mid", "arrow_mid", 8, 0.61,3.5,3.5,false},
	{     "heart",     "heart", 8,  1.0,  9,  9,false},
	{   "knife_b",   "knife_b", 8,0.755,3.5,3.5,false},
	{"ball_mid_c","ball_mid_c", 8,0.752,  4,  4,false},
	{     "money",     "money", 8,0.753,  4,  4,false},
	{"ball_mid_d","ball_mid_d", 8,0.753,  3,  3,false},
	--endregion
	--region bullet6
	{"silence","silence",8,0.8,4.5,4.5,false},
	--endregion
}

--imagename,texturefile,x,y,width,height,col,row,cx,cy,blend,color
def.res={
	--region bullet1
	{      "arrow_big","bullet1",  0,0,16,16,1,16},
	{     "gun_bullet","bullet1", 24,0,16,16,1,16},
	{"gun_bullet_void","bullet1", 56,0,16,16,1,16},
	{      "butterfly","bullet1",112,0,32,32,1, 8},
	{         "square","bullet1",152,0,16,16,1,16},
	{       "ball_mid","bullet1",176,0,32,32,1, 8},
	{         "mildew","bullet1",208,0,16,16,1,16},
	{        "ellipse","bullet1",224,0,32,32,1, 8},
	{         "preimg","bullet1", 80,0,32,32,1, 8},--preimg,no def
	--endregion
	--region bullet2
	{"star_small","bullet2", 96,0,16,16,1,16},
	{  "star_big","bullet2",224,0,32,32,1, 8,15.5,  16},--cx,cy
	{  "ball_big","bullet2",192,0,32,32,1, 8,  16,16.5},--cx,cy
	{"ball_small","bullet2",176,0,16,16,1,16},
	{   "grain_a","bullet2",160,0,16,16,1,16},
	{   "grain_b","bullet2",128,0,16,16,1,16},
	--endregion
	--region bullet3
	{      "knife","bullet3",  0,0,32,32,1, 8},
	{    "grain_c","bullet3", 48,0,16,16,1,16},
	{"arrow_small","bullet3", 80,0,16,16,1,16},
	{       "kite","bullet3",112,0,16,16,1,16},
	--endregion
	--region bullet4
	{"star_big_b","bullet4", 32,  0,32,32,1,8},
	{"ball_mid_b","bullet4", 64,  0,32,32,1,8,nil,nil,"mul+add",{200,200,200,200}},--blend,color
	{ "arrow_mid","bullet4", 96,  0,32,32,1,8, 24, 16},--cx,cy
	{     "heart","bullet4",128,  0,32,32,1,8},
	{   "knife_b","bullet4",192,  0,32,32,1,8},
	{"ball_mid_c","bullet4",224,  0,32,32,1,8},
	{     "money","bullet4",168,  0,16,16,1,8},
	{"ball_mid_d","bullet4",168,128,16,16,1,8,nil,nil,"mul+add"},--blend
	--endregion
	--region bullet6
	{"silence","bullet6", 32,  0,32,32,1,8},
	--endregion
	
	--load path
	path=PATH,
	--texturename,texturefile,mipmap
	texture={
		{"bullet1","bullet1.png",false},
		{"bullet2","bullet2.png",false},
		{"bullet3","bullet3.png",false},
		{"bullet4","bullet4.png",false},
		{"bullet6","bullet6.png",false},
	},
}

BulletLibrary.addBulletStyles("default",def.res,def.type,BulletLibrary.classCreatorBase)

---大弹型，需要特殊的消弹效果---

local def={}

--name,image,fadeimage,colorcnt,size,a,b,rect,darktype
def.type={
	--region bullet5(ball_light)
	{     "ball_light",     "ball_light",     "fade_ball_light",8,2.0,11.5,11.5,false,false},
	{"ball_light_dark","ball_light_dark","fade_ball_light_dark",8,2.0,11.5,11.5,false, true},
	--endregion
	--region bullet_ball_huge
	{     "ball_huge",     "ball_huge",     "fade_ball_huge",8,2.0,13.5,13.5,false,false},
	{"ball_huge_dark","ball_huge_dark","fade_ball_huge_dark",8,2.0,13.5,13.5,false, true},
	--endregion
}

--imagename,texturefile,x,y,width,height,col,row,cx,cy,blend,color
def.res={
	--region bullet5(ball_light)
	{          "ball_light","bullet5",0,0,64,64,4,2,nil,nil,"mul+add"},--blend
	{     "fade_ball_light","bullet5",0,0,64,64,4,2},--ball_light fade image
	{     "ball_light_dark","bullet5",0,0,64,64,4,2},
	{"fade_ball_light_dark","bullet5",0,0,64,64,4,2},--ball_light_dark fade image
	--endregion
	--region bullet_ball_huge
	{          "ball_huge","bullet_ball_huge",0,0,64,64,4,2,nil,nil,"mul+add"},--blend
	{     "fade_ball_huge","bullet_ball_huge",0,0,64,64,4,2},--ball_light fade image
	{     "ball_huge_dark","bullet_ball_huge",0,0,64,64,4,2},
	{"fade_ball_huge_dark","bullet_ball_huge",0,0,64,64,4,2},--ball_light_dark fade image
	--endregion
	
	--load path
	path=PATH,
	--texturename,texturefile,mipmap
	texture={
		{         "bullet5",         "bullet5.png",false},
		{"bullet_ball_huge","bullet_ball_huge.png",false},
	},
}

BulletLibrary.addBulletStyles("default",def.res,def.type,BulletLibrary.classCreatorBaseHuge)

----------特殊弹型----------

--water_drop
LoadTexture('bullet_water_drop',PATH..'bullet_water_drop.png')
for i=1,8 do
	LoadAnimation('water_drop'..i,'bullet_water_drop',48*(i-1),0,48,32,1,4,4,4,4)
	SetAnimationState('water_drop'..i,'mul+add')
end
for i=1,8 do
	LoadAnimation('water_drop_dark'..i,'bullet_water_drop',48*(i-1),0,48,32,1,4,4,4,4)
end

--music
LoadTexture('bullet_music',PATH..'bullet_music.png')
for i=1,8 do
	LoadAnimation('music'..i,'bullet_music',60*(i-1),0,60,32,1,3,8,4,4)
end

local water_drop=Class(img_class)--2 4 6 10 12

water_drop.size=0.702

function water_drop:init(index)
	self.img='water_drop'..int((index+1)/2)
end

function water_drop:render()
	SetImageState('preimg'..self.index,'mul+add',Color(255*self.timer/11,255,255,255))
	Render('preimg'..self.index,self.x,self.y,self.rot,((11-self.timer)/11*2+1)*self.imgclass.size)
end


local water_drop_dark=Class(img_class)--2 4 6 10 12

water_drop_dark.size=0.702

function water_drop_dark:init(index)
	self.img='water_drop_dark'..int((index+1)/2)
end


local music=Class(img_class)

music.size=0.8

function music:init(index)
	self.img='music'..int((index+1)/2)
end

local def={}

def.type={
	{     "water_drop",     water_drop},
	{"water_drop_dark",water_drop_dark},
	{          "music",          music},
}

BulletLibrary.addBulletStyles2("default",def.type)

------------使用------------

BulletLibrary.usingBulletStyles("default")
