AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/VJ_AS/boomer.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 350
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1, ACT_MELEE_ATTACK2}
ENT.MeleeAttackAnimationDecreaseLengthAmount = 0.2 -- This will decrease the time until starts chasing again. Use it to fix animation pauses until it chases the enemy.
ENT.MeleeAttackDistance = 100 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 120 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.GibOnDeathDamagesTable = {"All"} -- Damages that it gibs from | "UseDefault" = Uses default damage types | "All" = Gib from any damage
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/boomer/footstep01.wav","vj_alienswarm/boomer/footstep02.wav","vj_alienswarm/boomer/footstep03.wav","vj_alienswarm/boomer/footstep04.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/boomer/inflate.wav","vj_alienswarm/boomer/roar02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/boomer/roar01.wav","vj_alienswarm/boomer/alert01.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/boomer/land02.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/boomer/boomer_bomb01.wav","vj_alienswarm/boomer/boomer_bomb02.wav","vj_alienswarm/boomer/boomer_bomb03.wav","vj_alienswarm/boomer/boomer_bomb04.wav"}

local sdWhoosh = {"vj_alienswarm/boomer/attack01.wav", "vj_alienswarm/boomer/attack02.wav"}

-- Custom
ENT.Boomer_ControllerGallop = false
ENT.Boomer_AnimGallop = ACT_RUN
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(35, 35, 120), Vector(-35, -35, 0))
	self:SetStepHeight(60)

	local sackLight = ents.Create("light_dynamic")
	sackLight:SetKeyValue("_light", "147 112 219 200")
	sackLight:SetKeyValue("brightness", "0")
	sackLight:SetKeyValue("distance", "250")
	sackLight:SetKeyValue("style", "0")
	sackLight:SetPos(self:GetPos())
	sackLight:SetParent(self)
	sackLight:Fire("SetParentAttachment", "attach_explosion")
	sackLight:Spawn()
	sackLight:Activate()
	sackLight:Fire("TurnOn")
	self:DeleteOnRemove(sackLight)
	
	self.Boomer_AnimGallop = VJ.SequenceToActivity(self, "gallop")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key, activator, caller, data)
	if key == "ASW_Boomer.FootstepWalk" or key == "ASW_Boomer.FootstepRun" then
		self:FootStepSoundCode()
	elseif key == "ASW_Boomer.MeleeWhoosh" then
		VJ.EmitSound(self, sdWhoosh, 70)
	elseif key == "ASW_Boomer.Hit" then
		if self:GetActivity() == ACT_MELEE_ATTACK1 then -- Stomp
			self.MeleeAttackDamage = 85
			self.HasMeleeAttackKnockBack = false
			self.SoundTbl_MeleeAttackMiss = "vj_alienswarm/boomer/land02.wav"
		else -- Shove
			self.MeleeAttackDamage = 65
			self.HasMeleeAttackKnockBack = true
			self.SoundTbl_MeleeAttackMiss = false
		end
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(hitEnt)
	return self:GetForward() * 100 + self:GetUp() * 250
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_Initialize(ply, controlEnt)
	ply:ChatPrint("JUMP: Toggle between running and galloping")
	
	function controlEnt:CustomOnKeyBindPressed(key)
		local npc = self.VJCE_NPC
		-- Toggle between running and galloping
		if key == IN_JUMP then
			if !npc.Boomer_ControllerGallop then
				npc.Boomer_ControllerGallop = true
				self.VJCE_Player:ChatPrint("Changed to galloping!")
			else
				npc.Boomer_ControllerGallop = false
				self.VJCE_Player:ChatPrint("Changed to regular running!")
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_RUN && ((!self.VJ_IsBeingControlled && self.LatestEnemyDistance < 800 && (self:GetNPCState() == NPC_STATE_ALERT or self:GetNPCState() == NPC_STATE_COMBAT)) or (self.VJ_IsBeingControlled && self.Boomer_ControllerGallop)) then
		return self.Boomer_AnimGallop
	end
	return self.BaseClass.TranslateActivity(self, act)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local colorYellow = VJ.Color2Byte(Color(255, 221, 35))
local defAng = Angle(0, 0, 0)
--
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	local myPos = self:GetPos() + self:OBBCenter()
	util.BlastDamage(self, self, myPos, 300, 60)
	util.ScreenShake(myPos, 100, 200, 1, 2500)
	
	if self.HasGibDeathParticles == true then
		local effectData = EffectData()
		effectData:SetOrigin(myPos)
		effectData:SetColor(colorYellow)
		effectData:SetScale(150)
		util.Effect("VJ_Blood1", effectData)
		effectData:SetScale(1.5)
		util.Effect("StriderBlood", effectData)
		util.Effect("StriderBlood", effectData)
		ParticleEffect("antlion_gib_02", myPos, defAng)
	end
	
	self:CreateGibEntity("prop_ragdoll", "models/aliens/boomer/boomerlega.mdl", {Pos=self:GetPos() + self:GetUp()*95, Ang=self:GetAngles() + Angle(0, 200, 0), Vel=self:GetForward()*-math.Rand(450, 550)}) -- Back Leg
	self:CreateGibEntity("prop_ragdoll", "models/aliens/boomer/boomerlegb.mdl", {Pos=self:GetPos() + self:GetUp()*95 + self:GetRight()*-10, Ang=self:GetAngles() + Angle(0, 30, 0), Vel=self:GetRight()*-math.Rand(450, 550)}) -- Right Leg
	self:CreateGibEntity("prop_ragdoll", "models/aliens/boomer/boomerlegc.mdl", {Pos=self:GetPos() + self:GetUp()*95 + self:GetRight()*15, Ang=self:GetAngles() + Angle(0, -30, 0), Vel=self:GetRight()*math.Rand(450, 550)}) -- Left Leg
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib", "UseAlien_Big")
	return true
end