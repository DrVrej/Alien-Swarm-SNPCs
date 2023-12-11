AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/boomer.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_boomer_h")
ENT.HullType = HULL_MEDIUM_TALL
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackAnimationDecreaseLengthAmount = 0.2 -- This will decrease the time until starts chasing again. Use it to fix animation pauses until it chases the enemy.
ENT.MeleeAttackDistance = 55 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 145 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.GibOnDeathDamagesTable = {"All"} -- Damages that it gibs from | "UseDefault" = Uses default damage types | "All" = Gib from any damage
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/boomer/footstep01.wav","vj_alienswarm/boomer/footstep02.wav","vj_alienswarm/boomer/footstep03.wav","vj_alienswarm/boomer/footstep04.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/boomer/inflate.wav","vj_alienswarm/boomer/roar02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/boomer/roar01.wav","vj_alienswarm/boomer/alert01.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/boomer/attack01.wav","vj_alienswarm/boomer/attack02.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/boomer/land02.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/boomer/boomer_bomb01.wav","vj_alienswarm/boomer/boomer_bomb02.wav","vj_alienswarm/boomer/boomer_bomb03.wav","vj_alienswarm/boomer/boomer_bomb04.wav"}

-- Custom
ENT.Boomer_ControllerCharge = 0
ENT.Boomer_NextControllerChargeT = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(50, 50, 120), Vector(-50, -50, 0))

	local sackLight = ents.Create("light_dynamic")
	sackLight:SetKeyValue("_light","147 112 219 200")
	sackLight:SetKeyValue("brightness","0")
	sackLight:SetKeyValue("distance","250")
	sackLight:SetKeyValue("style","0")
	sackLight:SetPos(self:GetPos())
	sackLight:SetParent(self)
	sackLight:Fire("SetParentAttachment","eyes")
	sackLight:Spawn()
	sackLight:Activate()
	sackLight:Fire("TurnOn","",0)
	self:DeleteOnRemove(sackLight)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "ASW_Boomer.FootstepWalk" or key == "ASW_Boomer.FootstepRun" then
		self:FootStepSoundCode()
	end
	if key == "ASW_Boomer.Hit" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_Initialize(ply)
	self.AnimTbl_Run = {ACT_RUN}
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_IntMsg(ply)
	ply:ChatPrint("JUMP: Toggle fast move between Run & Charge")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()
	if self.VJ_IsBeingControlled == true then
		self.AnimTbl_Walk = {ACT_WALK}
		if self.VJ_TheController:KeyDown(IN_JUMP) && CurTime() > self.Boomer_NextControllerChargeT then
			if self.Boomer_ControllerCharge == 1 then
				self.VJ_TheController:PrintMessage(HUD_PRINTCENTER,"Changed Fast Move Type to Regular Running!")
				self.AnimTbl_Run = {ACT_RUN}
				self.FootStepTimeRun = 0.35
				self.Boomer_ControllerCharge = 0
			elseif self.Boomer_ControllerCharge == 0 then
				self.VJ_TheController:PrintMessage(HUD_PRINTCENTER,"Changed Fast Move Type to Charging!")
				self.AnimTbl_Run = {VJ_SequenceToActivity(self,"gallop")}
				self.FootStepTimeRun = 0.25
				self.Boomer_ControllerCharge = 1
			end
			self.Boomer_NextControllerChargeT = CurTime() + 0.5
		end
		self.FootStepTimeRun = 0.35
	else
		if !IsValid(self:GetEnemy()) then
			self.AnimTbl_Walk = {ACT_WALK}
			self.AnimTbl_Run = {ACT_RUN}
			self.FootStepTimeRun = 0.35
		else
			if self:GetPos():Distance(self:GetEnemy():GetPos()) < 800 then
				self.AnimTbl_Walk = {ACT_WALK}
				self.AnimTbl_Run = {VJ_SequenceToActivity(self,"gallop")}
				self.FootStepTimeRun = 0.25
			else
				self.AnimTbl_Walk = {ACT_WALK}
				self.AnimTbl_Run = {ACT_RUN}
				self.FootStepTimeRun = 0.35
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	if math.random(1, 2) == 1 then
		self.AnimTbl_MeleeAttack = {"vjseq_melee_02b"}
		self.MeleeAttackDamage = GetConVarNumber("vj_as_boomer_d_push")
		self.HasMeleeAttackKnockBack = true
		self.MeleeAttackKnockBack_Forward1 = 100
		self.MeleeAttackKnockBack_Forward2 = 100
		self.MeleeAttackKnockBack_Up1 = 250
		self.MeleeAttackKnockBack_Up2 = 250
		self.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/boomer/attack01.wav","vj_alienswarm/boomer/attack02.wav"}
	else
		self.AnimTbl_MeleeAttack = {"vjseq_melee_03"}
		self.MeleeAttackDamage = GetConVarNumber("vj_as_boomer_d_stomp")
		self.HasMeleeAttackKnockBack = false
		self.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/boomer/dronehitheavy01.wav"}
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	util.BlastDamage(self,self,self:GetPos(),300,60)
	util.ScreenShake(self:GetPos(), 100, 200, 1, 2500)
	if self.HasGibDeathParticles == true then
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
		bloodeffect:SetScale(150)
		util.Effect("VJ_Blood1",bloodeffect)
		
		local bloodspray = EffectData()
		bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
		bloodspray:SetScale(10)
		bloodspray:SetFlags(3)
		bloodspray:SetColor(1)
		util.Effect("bloodspray",bloodspray)
		util.Effect("bloodspray",bloodspray)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos() +self:OBBCenter())
		effectdata:SetScale(1.3)
		util.Effect("StriderBlood",effectdata)
		util.Effect("StriderBlood",effectdata)
		ParticleEffect("antlion_gib_02", self:GetPos(), Angle(0,0,0), nil)
	end
	self:CreateGibEntity("prop_ragdoll","models/aliens/boomer/boomerlega.mdl",{Pos=self:GetPos()+self:GetUp()*95,Ang=self:GetAngles()+Angle(0,200,0),Vel=self:GetForward()*-math.Rand(450,550)}) -- Back Leg
	self:CreateGibEntity("prop_ragdoll","models/aliens/boomer/boomerlegb.mdl",{Pos=self:GetPos()+self:GetUp()*95+self:GetRight()*-10,Ang=self:GetAngles()+Angle(0,30,0),Vel=self:GetRight()*-math.Rand(450,550)}) -- Right Leg
	self:CreateGibEntity("prop_ragdoll","models/aliens/boomer/boomerlegc.mdl",{Pos=self:GetPos()+self:GetUp()*95+self:GetRight()*15,Ang=self:GetAngles()+Angle(0,-30,0),Vel=self:GetRight()*math.Rand(450,550)}) -- Left Leg
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	return true
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/