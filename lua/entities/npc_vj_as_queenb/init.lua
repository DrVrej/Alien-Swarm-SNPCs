AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/queen.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_queenb_h")
ENT.HullType = HULL_MEDIUM_TALL
ENT.VJ_IsHugeMonster = true -- Is this a huge monster?
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 120 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 320 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = 250 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 300 -- How far it will push you forward | Second in math.random
ENT.MeleeAttackKnockBack_Up1 = 250 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 300 -- How far it will push you up | Second in math.random

ENT.HasDeathRagdoll = false -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {"vjseq_death"} -- Death Animations
ENT.DeathAnimationTime = 8 -- Time until the SNPC spawns its corpse and gets removed
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/boomer/footstep01.wav","vj_alienswarm/boomer/footstep02.wav","vj_alienswarm/boomer/footstep03.wav","vj_alienswarm/boomer/footstep04.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/shieldbug/idle01.wav","vj_alienswarm/shieldbug/idle02.wav"}
//ENT.SoundTbl_Alert = {"vj_alienswarm/shieldbug/roar.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/drone/jump.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/boomer/attack01.wav","vj_alienswarm/boomer/attack02.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav","vj_alienswarm/shieldbug/move_voc03.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/drone/die_fancy.wav"}

ENT.GeneralSoundPitch1 = 50
ENT.GeneralSoundPitch2 = 50

ENT.FootStepSoundLevel = 100
ENT.AlertSoundLevel = 100
ENT.IdleSoundLevel = 100
ENT.MeleeAttackSoundLevel = 100
ENT.RangeAttackSoundLevel = 100
ENT.MeleeAttackMissSoundLevel = 150
ENT.BeforeLeapAttackSoundLevel = 100
ENT.PainSoundLevel = 100
ENT.DeathSoundLevel = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(140, 140, 250), Vector(-140, -140, 5))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSightDirection()
	return self:GetAttachment(self:LookupAttachment("SpitSource")).Ang:Forward()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "move" then
		self:FootStepSoundCode()
	end
	if key == "attack_melee" then
		self:MeleeAttackCode()
	end
	if key == "alert_scream" then
		self:PlaySoundSystem("Alert", "vj_alienswarm/shieldbug/roar.wav")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	if self.VJ_IsBeingControlled == true then return end
	self:VJ_ACT_PLAYACTIVITY("high_scream", true, false, true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	if math.random(1, 2) == 1 then
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		self.MeleeAttackDamage = GetConVarNumber("vj_as_queenb_d_reg")
	else
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK2}
		self.MeleeAttackDamage = GetConVarNumber("vj_as_queenb_d_moving")
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/