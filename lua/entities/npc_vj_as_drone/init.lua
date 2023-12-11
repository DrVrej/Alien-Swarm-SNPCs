AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/drone.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_drone_h")
ENT.HullType = HULL_MEDIUM
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"lunge_attack01","lunge_attack02","lunge_attack03"} -- Melee Attack Animations
ENT.MeleeAttackDistance = 48 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = GetConVarNumber("vj_as_drone_d")
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.MeleeAttackBleedEnemy = true -- Should the player bleed when attacked by melee
ENT.MeleeAttackBleedEnemyChance = 3 -- How chance there is that the play will bleed? | 1 = always
ENT.MeleeAttackBleedEnemyDamage = 1 -- How much damage will the enemy get on every rep?
ENT.MeleeAttackBleedEnemyTime = 1 -- How much time until the next rep?
ENT.MeleeAttackBleedEnemyReps = 4 -- How many reps?

ENT.AnimTbl_CallForHelp = {"roar"} -- Call For Help Animations
ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {"vjseq_death01","vjseq_death_fire_02","vjseq_death_fire_04","vjseq_death_fire_05","vjseq_death_fire_07","vjseq_death_fire_08"} -- Death Animations
ENT.DeathAnimationChance = 2 -- Put 1 if you want it to play the animation all the time
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/drone/footstep1a.wav","vj_alienswarm/drone/footstep1b.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/drone/glide01.wav","vj_alienswarm/drone/glide02.wav","vj_alienswarm/drone/glide03.wav","vj_alienswarm/drone/roar01.wav","vj_alienswarm/drone/roar02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/drone/alert01.wav","vj_alienswarm/drone/alert02.wav","vj_alienswarm/drone/alert03.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_alienswarm/drone/attack01.wav","vj_alienswarm/drone/attack02.wav","vj_alienswarm/drone/attack03.wav","vj_alienswarm/drone/attack04.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/drone/swipe01.wav","vj_alienswarm/drone/swipe02.wav","vj_alienswarm/drone/swipe03.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/drone/pain01.wav","vj_alienswarm/drone/pain02.wav","vj_alienswarm/drone/pain03.wav","vj_alienswarm/drone/pain04.wav","vj_alienswarm/drone/pain05.wav","vj_alienswarm/drone/pain06.wav","vj_alienswarm/drone/pain07.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/drone/deathfire01.wav","vj_alienswarm/drone/deathfire02.wav","vj_alienswarm/drone/deathfire03.wav","vj_alienswarm/drone/deathfire04.wav","vj_alienswarm/drone/death01.wav"}
local unborrowSds = {"vj_alienswarm/drone/burrow01.wav","vj_alienswarm/drone/burrow02.wav","vj_alienswarm/drone/burrow03.wav","vj_alienswarm/drone/burrow04.wav"}

ENT.FootStepSoundLevel = 55
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(25, 25, 70), Vector(-25, -25, 0))
	self:SetBodygroup(1, math.random(0, 2))
	self:SetBodygroup(2, math.random(0, 2))
	self:SetBodygroup(3, math.random(0, 2))
	self:SetBodygroup(4, math.random(0, 2))
	if math.random(1, 6) == 1 then self:SetBodygroup(5, 1) end
	if math.random(1, 6) == 1 then
		self:SetBodygroup(0, 1)
	else
		if math.random(1, 2) == 1 then self.CustomBodyGroup = true self.DeathBodyGroupB = 2 end
	end
	
	if GetConVarNumber("ai_disabled") == 0 && math.random(1, 2) == 1 then
		self:SetNoDraw(true)
		self:SetState(VJ_STATE_FREEZE)
		VJ_EmitSound(self, unborrowSds, 70, math.random(80,100))
		timer.Simple(0.05, function() if IsValid(self) then self:VJ_ACT_PLAYACTIVITY("burrow_out", true, false, false) end end)
		timer.Simple(0.5, function() if IsValid(self) then self:SetNoDraw(false) self:SetState() end end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "ASW_Drone.Footstep" then
		self:FootStepSoundCode()
	end
	if key == "ASW_Drone.Hit" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnCallForHelp()
	timer.Simple(1,function()
		if IsValid(self) then
			ParticleEffectAttach("antlion_gib_02_gas", PATTACH_POINT_FOLLOW, self, 6)
			ParticleEffectAttach("antlion_gib_02_floaters", PATTACH_POINT_FOLLOW, self, 6)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo,hitgroup)
	if dmginfo:GetDamageForce():Length() > 10000 then -- High damage, don't ragdoll
		self.HasDeathAnimation = false
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/