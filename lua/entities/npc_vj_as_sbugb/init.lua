AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/betashieldbug.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_shieldbugb_h")
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 44 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 135 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/shieldbug/default01.wav","vj_alienswarm/shieldbug/default02.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/shieldbug/idle01.wav","vj_alienswarm/shieldbug/idle02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/shieldbug/alert.wav","vj_alienswarm/shieldbug/move_voc01.wav","vj_alienswarm/shieldbug/move_voc02.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/shieldbug/attack01.wav","vj_alienswarm/shieldbug/attack02.wav","vj_alienswarm/shieldbug/attack03.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav","vj_alienswarm/shieldbug/move_voc03.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(60, 60, 100), Vector(-60, -60, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "move" then
		self:FootStepSoundCode()
	end
	if key == "melee_hit" then
		self:MeleeAttackCode()
	end
	if key == "shove_roar_hit" then
		util.ScreenShake(self:GetPos(),16,200,0.5,1500)
		if self.HasSounds == true && self.HasAlertSounds == true then
			VJ_EmitSound(self,"vj_alienswarm/shieldbug/stomp01.wav",80,math.random(90,100))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	if self.VJ_IsBeingControlled == true then return end
	if math.random(1, 2) == 1 then
		self:VJ_ACT_PLAYACTIVITY(ACT_ARM, true, false, true)
		self:PlaySoundSystem("Alert", "vj_alienswarm/shieldbug/roar.wav")
	else
		self:PlaySoundSystem("Alert", {"vj_alienswarm/shieldbug/alert.wav","vj_alienswarm/shieldbug/move_voc01.wav","vj_alienswarm/shieldbug/move_voc02.wav"})
	end
end 
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	local randAttack = math.random(1, 3)
	if randAttack == 1 then
		self.AnimTbl_MeleeAttack = {"vjseq_attack_clobber"}
		self.StopMeleeAttackAfterFirstHit = false
		self.MeleeAttackDamage = GetConVarNumber("vj_as_shieldbugb_d_dual")
		self.MeleeAttackKnockBack_Forward1 = 170
		self.MeleeAttackKnockBack_Forward2 = 190
		self.MeleeAttackKnockBack_Up1 = 200
		self.MeleeAttackKnockBack_Up2 = 210
		self.MeleeAttackWorldShakeOnMiss = true
		self.MeleeAttackWorldShakeOnMissAmplitude = 8
		self.MeleeAttackWorldShakeOnMissRadius = 1500
		self.MeleeAttackWorldShakeOnMissDuration = 0.5
		self.MeleeAttackWorldShakeOnMissFrequency = 100
		self.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/shieldbug/stomp01.wav","vj_alienswarm/shieldbug/stomp02.wav"}
	elseif randAttack == 2 then
		self.AnimTbl_MeleeAttack = {"vjseq_attack_swipe"}
		self.StopMeleeAttackAfterFirstHit = false
		self.MeleeAttackDamage = GetConVarNumber("vj_as_shieldbugb_d_swipe")
		self.MeleeAttackKnockBack_Forward1 = 270
		self.MeleeAttackKnockBack_Forward2 = 290
		self.MeleeAttackKnockBack_Up1 = 50
		self.MeleeAttackKnockBack_Up2 = 50
		self.MeleeAttackWorldShakeOnMiss = false
		self.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/boomer/swipe01.wav","vj_alienswarm/boomer/swipe02.wav","vj_alienswarm/boomer/swipe03.wav"}
	elseif randAttack == 3 then
		self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK2}
		self.StopMeleeAttackAfterFirstHit = true
		self.MeleeAttackDamage = GetConVarNumber("vj_as_shieldbugb_d_charge")
		self.MeleeAttackKnockBack_Forward1 = 200
		self.MeleeAttackKnockBack_Forward2 = 200
		self.MeleeAttackKnockBack_Up1 = 240
		self.MeleeAttackKnockBack_Up2 = 250
		self.MeleeAttackWorldShakeOnMiss = false
		self.SoundTbl_MeleeAttackMiss = {}
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/