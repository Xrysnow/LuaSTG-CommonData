---=====================================
---Thlib
---Touhou style library
---=====================================

----------------------------------------
---需求包

lstg.package.RequirePackage("Touhou SE")--正作音效包，整数作
lstg.package.RequirePackage("Touhou SE 2")--正作音效包，拍照作
lstg.package.RequirePackage("Touhou SE misc")--正作音效包，各种杂项

----------------------------------------
---加载脚本

Include("THlib/misc/misc.lua")
Include("THlib/WalkImageSystem.lua")
Include("THlib/music/music.lua")
Include("THlib/item/item.lua")
Include("THlib/player/player.lua")
Include("THlib/player/playersystem.lua")
Include("THlib/enemy/enemy.lua")
Include("THlib/bullet/bullet.lua")
Include("THlib/laser/laser.lua")
Include("THlib/background/background.lua")
Include("THlib/ext/ext.lua")
Include("THlib/ui/menu.lua")
Include("THlib/editor.lua")
Include("THlib/ui/ui.lua")
Include("ex/javastage.lua")
Include("ex/crazystorm.lua")
Include("ex/system.lua")
Include("ex/systems/act7/system_act7.lua")
Include("ex/ex.lua")--ESC神的ex库
Include("sp/sp.lua")--OLC神的sp加强库
