AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/VJ_AS/betadrone_big.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = GetConVarNumber("vj_as_dronebb_h")
ENT.HullType = HULL_LARGE
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 45 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 110 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = GetConVarNumber("vj_as_dronebb_d")
ENT.MeleeAttackBleedEnemy = true -- Should the player bleed when attacked by melee
ENT.MeleeAttackBleedEnemyChance = 3 -- How chance there is that the play will bleed? | 1 = always
ENT.MeleeAttackBleedEnemyDamage = 1 -- How much damage will the enemy get on every rep?
ENT.MeleeAttackBleedEnemyTime = 1 -- How much time until the next rep?
ENT.MeleeAttackBleedEnemyReps = 4 -- How many reps?

ENT.DeathCorpseSetBoneAngles = false -- This can be used to stop the corpse glitching or flying on death
ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {ACT_DIESIMPLE} -- Death Animations
ENT.DeathAnimationChance = 2 -- Put 1 if you want it to play the animation all the time
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = {ACT_SMALL_FLINCH} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"vj_alienswarm/drone/footstep1a.wav","vj_alienswarm/drone/footstep1b.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/drone/glide01.wav","vj_alienswarm/drone/glide02.wav","vj_alienswarm/drone/glide03.wav","vj_alienswarm/drone/roar01.wav","vj_alienswarm/drone/roar02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/drone/alert01.wav","vj_alienswarm/drone/alert02.wav","vj_alienswarm/drone/alert03.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/drone/attack01.wav","vj_alienswarm/drone/attack02.wav","vj_alienswarm/drone/attack03.wav","vj_alienswarm/drone/attack04.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/drone/swipe01.wav","vj_alienswarm/drone/swipe02.wav","vj_alienswarm/drone/swipe03.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/drone/pain01.wav","vj_alienswarm/drone/pain02.wav","vj_alienswarm/drone/pain03.wav","vj_alienswarm/drone/pain04.wav","vj_alienswarm/drone/pain05.wav","vj_alienswarm/drone/pain06.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/drone/deathfire01.wav","vj_alienswarm/drone/deathfire02.wav","vj_alienswarm/drone/deathfire03.wav","vj_alienswarm/drone/deathfire04.wav","vj_alienswarm/drone/death01.wav"}

ENT.GeneralSoundPitch1 = 60
ENT.GeneralSoundPitch2 = 70

ENT.FootStepSoundLevel = 60
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(35, 35, 75), Vector(-35, -35, 0))
	self:SetSkin((math.random(1,2) == 1 and 0) or 2)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "move" then
		self:FootStepSoundCode()
	end
	if key == "melee_hit" then
		self:MeleeAttackCode()
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/