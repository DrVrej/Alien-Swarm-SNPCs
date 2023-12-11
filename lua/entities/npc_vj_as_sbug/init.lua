AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/shieldbug.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_shieldbug_h")
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDistance = 64 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 175 -- How does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = GetConVarNumber("vj_as_shieldbug_d")
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Up1 = 50 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 50 -- How far it will push you up | Second in math.random
ENT.MeleeAttackWorldShakeOnMiss = true -- Should it shake the world when it misses during melee attack?
ENT.MeleeAttackWorldShakeOnMissAmplitude = 16 -- How much the screen will shake | From 1 to 16, 1 = really low 16 = really high
ENT.MeleeAttackWorldShakeOnMissRadius = 1500 -- How far the screen shake goes, in world units
ENT.MeleeAttackWorldShakeOnMissDuration = 0.5 -- How long the screen shake will last, in seconds
ENT.MeleeAttackWorldShakeOnMissFrequency = 100 -- Just leave it to 100

ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {"vjseq_death_02"} -- Death Animations
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/shieldbug/default01.wav","vj_alienswarm/shieldbug/default02.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/shieldbug/idle01.wav","vj_alienswarm/shieldbug/idle02.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/shieldbug/attack01.wav","vj_alienswarm/shieldbug/attack02.wav","vj_alienswarm/shieldbug/attack03.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/shieldbug/stomp01.wav","vj_alienswarm/shieldbug/stomp02.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav","vj_alienswarm/shieldbug/move_voc03.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav"}

-- Custom
ENT.Shieldbug_BlockWalking = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(70, 70, 100), Vector(-70, -70, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "ASW_ShieldBug.Movement" or key == "ASW_ShieldBug.MoveDefend" then
		self:FootStepSoundCode()
	end
	if key == "ASW_ShieldBug.Hit" then
		self:MeleeAttackCode()
	end
	if key == "ASW_ShieldBug.Stomp" && self:GetActivity() == ACT_ARM then
		util.ScreenShake(self:GetPos(),16,200,0.5,1500)
		if self.HasSounds == true && self.HasAlertSounds == true then
			VJ_EmitSound(self,"vj_alienswarm/shieldbug/stomp01.wav",80,math.random(90,100))
		end
	end
	if key == "ASW_ShieldBug.GibSplat" then
			self:SetBodygroup(0,1)
			util.VJ_SphereDamage(self,self,self:GetPos(),160,35,DMG_ACID,true,true)
			self:PlaySoundSystem("Death", {"vj_alienswarm/shieldbug/shieldbugdeath.wav","vj_alienswarm/shieldbug/shieldbuggibsplat.wav"})
			if self.HasGibDeathParticles == true then
				local attach = self:GetPos() + self:GetUp() * 100 + self:GetForward() * -40 //self:GetBonePosition(self:LookupBone("bubble")) //self:GetAttachment(self:LookupAttachment("attach_explosion")).Pos
				local bloodspray = EffectData()
				bloodspray:SetOrigin(attach)
				bloodspray:SetScale(10)
				bloodspray:SetFlags(3)
				bloodspray:SetColor(1)
				util.Effect("bloodspray",bloodspray)
				util.Effect("bloodspray",bloodspray)
				local effectdata = EffectData()
				effectdata:SetOrigin(attach)
				effectdata:SetScale(1)
				util.Effect("StriderBlood",effectdata)
				util.Effect("StriderBlood",effectdata)
				ParticleEffect("antlion_gib_02_gas",attach,Angle(0,0,0),nil)
				ParticleEffect("antlion_spit",attach,Angle(0,0,0),nil)
				ParticleEffect("antlion_gib_02",attach,Angle(0,0,0),nil)
			end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.VJ_IsBeingControlled == true then
		self.AnimTbl_Walk = {ACT_RUN}
		self.AnimTbl_Run = {ACT_COVER}
		self.Shieldbug_BlockWalking = false
	else
		if !IsValid(self:GetEnemy()) then
			self.AnimTbl_Walk = {ACT_WALK}
			self.AnimTbl_Run = {ACT_RUN}
			self.Shieldbug_BlockWalking = false
		else
			if self:GetPos():Distance(self:GetEnemy():GetPos()) < 1000 then
				self.Shieldbug_BlockWalking = true
				self.FootStepSoundLevel = 60
				self.AnimTbl_Walk = {ACT_COVER}
				self.AnimTbl_Run = {ACT_COVER}
			else
				self.Shieldbug_BlockWalking = false
				self.FootStepSoundLevel = 70
				self.AnimTbl_Walk = {ACT_WALK}
				self.AnimTbl_Run = {ACT_RUN}
			end
		end
	end
	if IsValid(self:GetEnemy()) && self.Shieldbug_BlockWalking == true && self.VJ_IsBeingControlled == false then
		self.ConstantlyFaceEnemy = true
		self.AnimTbl_IdleStand = {ACT_COWER}
		//self.AnimTbl_MeleeAttack = {"melee_attack_defend","melee_attack_defend1B"} // "melee_attack_defend2"
	else
		self.ConstantlyFaceEnemy = false
		self.AnimTbl_IdleStand = {ACT_IDLE}
		//self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1,ACT_MELEE_ATTACK2}
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	if self.VJ_IsBeingControlled == true then return end
	if math.random(1, 2) == 1 then
		self:VJ_ACT_PLAYACTIVITY(ACT_ARM,true,false,true)
		self:PlaySoundSystem("Alert", "vj_alienswarm/shieldbug/roar.wav")
	else
		self:PlaySoundSystem("Alert", {"vj_alienswarm/shieldbug/alert.wav","vj_alienswarm/shieldbug/move_voc01.wav","vj_alienswarm/shieldbug/move_voc02.wav"})
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	if math.random(1, 2) == 1 then
		if self.Shieldbug_BlockWalking == true then
		self.AnimTbl_MeleeAttack = {"vjseq_melee_attack_defend","vjseq_melee_attack_defend1B"} else
		self.AnimTbl_MeleeAttack = {"vjseq_melee_attack1","vjseq_melee_attack_1B"} end
		self.MeleeAttackKnockBack_Forward1 = 470
		self.MeleeAttackKnockBack_Forward2 = 490
	else
		if self.Shieldbug_BlockWalking == true then
		self.AnimTbl_MeleeAttack = {"vjseq_melee_attack_defend2"} else
		self.AnimTbl_MeleeAttack = {"vjseq_melee_attack2"} end
		self.MeleeAttackKnockBack_Forward1 = 970
		self.MeleeAttackKnockBack_Forward2 = 990
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
	if hitgroup == 11 then dmginfo:SetDamage(0) end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self:SetBodygroup(0, 1)
	if IsValid(self.Corpse) then
		self.Corpse:SetBodygroup(0, 1)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/