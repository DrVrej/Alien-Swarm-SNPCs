AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_AS/buzzer.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 30
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_AERIAL -- How the NPC moves around
ENT.Aerial_FlyingSpeed_Calm = 100 -- The speed it should fly with, when it's wandering, moving slowly, etc. | Basically walking compared to ground NPCs
ENT.Aerial_FlyingSpeed_Alerted = 200 -- The speed it should fly with, when it's chasing an enemy, moving away quickly, etc. | Basically running compared to ground NPCs
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.DisableMeleeAttackAnimation = true -- if true, it will disable the animation code
ENT.MeleeAttackDistance = 30 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 60 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = 0.3 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.6 -- How much time until it can use any attack again? | Counted in Seconds
ENT.MeleeAttackDamage = 15

ENT.HasDeathRagdoll = false -- Should the NPC spawn a corpse when it dies?
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Breath = {"vj_alienswarm/buzzer/idle01.wav","vj_alienswarm/buzzer/idle02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/buzzer/edited_onfire.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_alienswarm/buzzer/attack01.wav","vj_alienswarm/buzzer/attack02.wav","vj_alienswarm/buzzer/attack03.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/buzzer/pain.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/buzzer/death01.wav","vj_alienswarm/buzzer/death02.wav"}

ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(10, 10, 10), Vector(-10, -10, -10))
	self:SetSurroundingBounds(Vector(40, 40, 40), Vector(-40, -40, -40))
	
	-- So it doesn't spawn in the ground too much
	timer.Simple(0.05, function()
		if IsValid(self) then
			self:SetPos(self:GetPos() + self:GetUp() * 25)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle(0, 0, 0)
--
function ENT:CustomOnKilled(dmginfo,hitgroup)
	local myPos = self:GetPos()
	ParticleEffect("antlion_spit", myPos, defAng)
	ParticleEffect("antlion_gib_02_gas", myPos, defAng)
end