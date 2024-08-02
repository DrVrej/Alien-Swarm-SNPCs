include("entities/npc_vj_as_droneb/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_AS/betadrone_big.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 220
ENT.HullType = HULL_LARGE

ENT.MeleeAttackDistance = 90 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamage = 25

ENT.GeneralSoundPitch1 = 60
ENT.GeneralSoundPitch2 = 70

ENT.FootStepSoundLevel = 60
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(30, 30, 70), Vector(-30, -30, 0))
	self:SetSurroundingBounds(Vector(70, 70, 100), Vector(-70, -70, 0))
	self:SetSkin((math.random(1, 2) == 1 and 0) or 2)
end