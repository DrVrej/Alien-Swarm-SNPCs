AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_alienswarm/shieldbug.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 800
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.MeleeAttackDamage = 50
ENT.MeleeAttackDistance = 140 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 175 -- How does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy

ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = "vjseq_death_02"
ENT.DeathAnimationDecreaseLengthAmount = 0.4 -- This will decrease the time until it turns into a corpse
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound Paths ====== --
ENT.SoundTbl_FootStep = {"vj_alienswarm/shieldbug/default01.wav","vj_alienswarm/shieldbug/default02.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/shieldbug/idle01.wav","vj_alienswarm/shieldbug/idle02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/shieldbug/alert.wav","vj_alienswarm/shieldbug/move_voc01.wav","vj_alienswarm/shieldbug/move_voc02.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/shieldbug/attack01.wav","vj_alienswarm/shieldbug/attack02.wav","vj_alienswarm/shieldbug/attack03.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/shieldbug/stomp01.wav","vj_alienswarm/shieldbug/stomp02.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav","vj_alienswarm/shieldbug/move_voc03.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/shieldbug/pain01.wav","vj_alienswarm/shieldbug/pain02.wav"}

local sdGib = {"vj_alienswarm/shieldbug/shieldbugdeath.wav","vj_alienswarm/shieldbug/shieldbuggibsplat.wav"}

local animAttackReg = {ACT_MELEE_ATTACK1, ACT_MELEE_ATTACK2}

-- Custom
ENT.Shieldbug_Defending = false
ENT.Shieldbug_AnimAttackDef = -1
ENT.Shieldbug_AnimTurnLeft = -1
ENT.Shieldbug_AnimTurnRight = -1
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(70, 70, 100), Vector(-70, -70, 0))
	self:SetStepHeight(50)
	self.Shieldbug_AnimAttackDef = VJ.SequenceToActivity(self, "melee_attack_defend") -- ACT_MELEE_ATTACK1_DEFEND = "melee_attack_defend", "melee_attack_defend1B", "melee_attack_defend2"
	self.Shieldbug_AnimTurnLeft = VJ.SequenceToActivity(self, "turn_left_defend")
	self.Shieldbug_AnimTurnRight = VJ.SequenceToActivity(self, "turn_right_defend")
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle(0, 0, 0)
--
function ENT:OnInput(key, activator, caller, data)
	if key == "ASW_ShieldBug.Movement" or key == "ASW_ShieldBug.MoveDefend" then
		self:FootStepSoundCode()
	elseif key == "ASW_ShieldBug.Hit" then
		self:MeleeAttackCode()
	elseif key == "ASW_ShieldBug.Stomp" && self:GetActivity() == ACT_ARM then
		util.ScreenShake(self:GetPos(), 16, 200, 0.5, 1500)
		if self.HasSounds == true && self.HasAlertSounds == true then
			VJ.EmitSound(self, "vj_alienswarm/shieldbug/stomp01.wav", 80, math.random(90, 100))
		end
	elseif key == "ASW_ShieldBug.GibSplat" then
		self:SetBodygroup(0, 1)
		local expPos = self:GetAttachment(self:LookupAttachment("attach_explosion")).Pos
		VJ.ApplyRadiusDamage(self, self, expPos, 160, 35, DMG_ACID, true, true)
		VJ.EmitSound(self, sdGib, 80)
		if self.HasGibOnDeathEffects then
			local effectData = EffectData()
			effectData:SetOrigin(expPos)
			effectData:SetScale(1)
			util.Effect("StriderBlood", effectData)
			util.Effect("StriderBlood", effectData)
			ParticleEffect("antlion_spit", expPos, defAng)
			ParticleEffect("antlion_gib_02", expPos, defAng)
			ParticleEffect("antlion_gib_02_gas", expPos, defAng)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_Initialize(ply, controlEnt)
	ply:ChatPrint("JUMP: Toggle defense mode")
	self.Shieldbug_Defending = false
	
	-- Change the "TranslateActivity" function to the player controlled version
	controlEnt.OriginalShieldbugFunc = self.TranslateActivity
	self.TranslateActivity = function(_, act)
		if self.Shieldbug_Defending then
			if act == ACT_IDLE then
				return ACT_COWER
			elseif act == ACT_WALK or act == ACT_RUN then
				return ACT_COVER
			elseif act == ACT_TURN_LEFT then
				return self.Shieldbug_AnimTurnLeft
			elseif act == ACT_TURN_RIGHT then
				return self.Shieldbug_AnimTurnRight
			end
		end
		return self.BaseClass.TranslateActivity(self, act)
	end
	
	function controlEnt:OnKeyBindPressed(key)
		local npc = self.VJCE_NPC
		-- Toggle defending mode
		if key == IN_JUMP then
			if !npc.Shieldbug_Defending then
				npc.Shieldbug_Defending = true
				self.VJCE_Player:ChatPrint("Entering defense mode")
			else
				npc.Shieldbug_Defending = false
				self.VJCE_Player:ChatPrint("Exiting defense mode")
			end
		end
	end
	
	-- Revert the NPC's "TranslateActivity" to the original function
	function controlEnt:OnStopControlling(keyPressed)
		local npc = self.VJCE_NPC
		if IsValid(npc) then
			npc.TranslateActivity = self.OriginalShieldbugFunc
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	-- Defense mode
	if self.LatestEnemyDistance < 1000 && (self:GetNPCState() == NPC_STATE_ALERT or self:GetNPCState() == NPC_STATE_COMBAT) then
		self.Shieldbug_Defending = true
		if act == ACT_IDLE then
			return ACT_COWER
		elseif act == ACT_WALK or act == ACT_RUN then
			return ACT_COVER
		elseif act == ACT_TURN_LEFT then
			return self.Shieldbug_AnimTurnLeft
		elseif act == ACT_TURN_RIGHT then
			return self.Shieldbug_AnimTurnRight
		end
	else
		self.Shieldbug_Defending = false
	end
	return self.BaseClass.TranslateActivity(self, act)
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
function ENT:CustomOnMeleeAttack_BeforeStartTimer(seed)
	if self.Shieldbug_Defending then
		self.AnimTbl_MeleeAttack = self.Shieldbug_AnimAttackDef
	else
		self.AnimTbl_MeleeAttack = animAttackReg
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward() * math.random(470, 490) + self:GetUp() * 50
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_Miss()
	util.ScreenShake(self:GetPos(), 16, 100, 0.5, 1500)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" && hitgroup == 11 then
		dmginfo:SetDamage(0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Finish" then
		self:SetBodygroup(0, 1)
	end
end