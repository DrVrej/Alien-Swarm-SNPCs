AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_AS/betashieldbug.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 800
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1, ACT_MELEE_ATTACK1, ACT_MELEE_ATTACK2, "attack_backhand"}
	-- Apply "ACT_MELEE_ATTACK1" twice because it contains 2 animations
ENT.MeleeAttackDistance = 90 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- ====== Sound Paths ====== --
ENT.SoundTbl_FootStep = {"vj_alienswarm/shieldbug/default01.wav","vj_alienswarm/shieldbug/default02.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/shieldbug/idle01.wav","vj_alienswarm/shieldbug/idle02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/shieldbug/alert.wav","vj_alienswarm/shieldbug/move_voc01.wav","vj_alienswarm/shieldbug/move_voc02.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/shieldbug/attack01.wav","vj_alienswarm/shieldbug/attack02.wav","vj_alienswarm/shieldbug/attack03.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav","vj_alienswarm/shieldbug/move_voc03.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav"}

local sdMeleeMissSwipe = {"vj_alienswarm/boomer/swipe01.wav","vj_alienswarm/boomer/swipe02.wav","vj_alienswarm/boomer/swipe03.wav"}
local sdMeleeMissSlam = {"vj_alienswarm/shieldbug/stomp01.wav","vj_alienswarm/shieldbug/stomp02.wav"}

local SHIELDBUG_MELEE_SWIPE = 0
local SHIELDBUG_MELEE_SLAM = 1
local SHIELDBUG_MELEE_CHARGE = 2

-- Custom
ENT.Shieldbug_MeleeType = SHIELDBUG_MELEE_SWIPE
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(45, 45, 100), Vector(-45, -45, 0))
	self:SetSurroundingBounds(Vector(150, 150, 150), Vector(-150, -150, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "move" then
		self:FootStepSoundCode()
	elseif key == "melee_hit" then
		local curSeq = self:GetSequenceName(self:GetSequence())
		if curSeq == "attack_backhand" or curSeq == "attack_swipe" then -- Swipe
			self.Shieldbug_MeleeType = SHIELDBUG_MELEE_SWIPE
			self.MeleeAttackDamage = 50
			self.SoundTbl_MeleeAttackMiss = sdMeleeMissSwipe
		elseif curSeq == "attack_clobber" then -- Slam
			self.Shieldbug_MeleeType = SHIELDBUG_MELEE_SLAM
			self.MeleeAttackDamage = 55
			self.SoundTbl_MeleeAttackMiss = sdMeleeMissSlam
		elseif curSeq == "headhit" then -- Charging
			self.Shieldbug_MeleeType = SHIELDBUG_MELEE_CHARGE
			self.MeleeAttackDamage = 12
			self.SoundTbl_MeleeAttackMiss = false
		end
		self:MeleeAttackCode()
	elseif key == "shove_roar_hit" then
		util.ScreenShake(self:GetPos(), 16, 200, 0.5, 1500)
		if self.HasSounds == true && self.HasAlertSounds == true then
			VJ.EmitSound(self,"vj_alienswarm/shieldbug/stomp01.wav", 80, math.random(90, 100))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.VJ_IsBeingControlled then return end
	if math.random(1, 2) == 1 then
		self:PlayAnim(ACT_ARM, true, false, true)
		self:PlaySoundSystem("Alert", "vj_alienswarm/shieldbug/roar.wav")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	if self.Shieldbug_MeleeType == SHIELDBUG_MELEE_SLAM then
		return self:GetForward() * math.random(170, 190) + self:GetUp() * math.random(200, 210)
	elseif self.Shieldbug_MeleeType == SHIELDBUG_MELEE_CHARGE then
		return self:GetForward() * math.random(190, 210) + self:GetUp() * math.random(80, 100)
	else -- SHIELDBUG_MELEE_SWIPE
		return self:GetForward() * math.random(270, 290) + self:GetUp() * math.random(50, 75)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_Miss()
	if self.Shieldbug_MeleeType == SHIELDBUG_MELEE_SLAM then
		util.ScreenShake(self:GetPos(), 8, 100, 0.5, 1500)
	end
end