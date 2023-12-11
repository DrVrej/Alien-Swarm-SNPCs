AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/buzzer.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_buzzer_h")
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_AERIAL -- How does the SNPC move?
ENT.Aerial_FlyingSpeed_Calm = 100 -- The speed it should fly with, when it's wandering, moving slowly, etc. | Basically walking compared to ground SNPCs
ENT.Aerial_FlyingSpeed_Alerted = 200 -- The speed it should fly with, when it's chasing an enemy, moving away quickly, etc. | Basically running compared to ground SNPCs
ENT.Aerial_AnimTbl_Calm = {ACT_WALK} -- Animations it plays when it's wandering around while idle
ENT.Aerial_AnimTbl_Alerted = {ACT_RUN} -- Animations it plays when it's moving while alerted
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.BloodPoolSize = "Small" -- What's the size of the blood pool?

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.DisableMeleeAttackAnimation = true -- if true, it will disable the animation code
ENT.MeleeAttackDistance = 60 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.3 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.6 -- How much time until it can use any attack again? | Counted in Seconds
ENT.MeleeAttackDamage = GetConVarNumber("vj_as_buzzer_d")

ENT.HasExtraMeleeAttackSounds = false -- Set to true to use the extra melee attack sounds
ENT.HasDeathRagdoll = false -- If set to false, it will not spawn the regular ragdoll of the SNPC
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
	self:SetCollisionBounds(Vector(25, 25, 20), Vector(-25, -25, -30))
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle(0, 0, 0)
--
function ENT:CustomOnKilled(dmginfo,hitgroup)
	ParticleEffect("antlion_gib_02_gas", self:GetPos(), defAng, nil)
	ParticleEffect("antlion_spit", self:GetPos(), defAng, nil)
	ParticleEffect("antlion_gib_02", self:GetPos(), defAng, nil)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/