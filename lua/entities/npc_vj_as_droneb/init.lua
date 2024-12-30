AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2024 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_alienswarm/betadrone.mdl" -- Model(s) to spawn with | Picks a random one if it's a table
ENT.StartHealth = 80
ENT.HullType = HULL_MEDIUM
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_ALIENSWARM"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Can this NPC melee attack?
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 80 -- How close an enemy has to be to trigger a melee attack | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.MeleeAttackDamageDistance = 100 -- How far does the damage go | false = Let the base auto calculate on initialize based on the NPC's collision bounds
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 15
ENT.MeleeAttackBleedEnemy = true -- Should the player bleed when attacked by melee
ENT.MeleeAttackBleedEnemyChance = 3 -- How chance there is that the play will bleed? | 1 = always
ENT.MeleeAttackBleedEnemyDamage = 1 -- How much damage will the enemy get on every rep?
ENT.MeleeAttackBleedEnemyTime = 1 -- How much time until the next rep?
ENT.MeleeAttackBleedEnemyReps = 4 -- How many reps?

ENT.DeathCorpseSetBoneAngles = false -- This can be used to stop the corpse glitching or flying on death
ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = ACT_DIESIMPLE
ENT.DeathAnimationChance = 2 -- Put 1 if you want it to play the animation all the time
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.AnimTbl_Flinch = ACT_SMALL_FLINCH -- The regular flinch animations to play
	-- ====== Sound Paths ====== --
ENT.SoundTbl_FootStep = {"vj_alienswarm/drone/footstep1a.wav","vj_alienswarm/drone/footstep1b.wav"}
ENT.SoundTbl_Idle = {"vj_alienswarm/drone/glide01.wav","vj_alienswarm/drone/glide02.wav","vj_alienswarm/drone/glide03.wav","vj_alienswarm/drone/roar01.wav","vj_alienswarm/drone/roar02.wav"}
ENT.SoundTbl_Alert = {"vj_alienswarm/drone/alert01.wav","vj_alienswarm/drone/alert02.wav","vj_alienswarm/drone/alert03.wav"}
ENT.SoundTbl_MeleeAttack = {"vj_alienswarm/drone/attack01.wav","vj_alienswarm/drone/attack02.wav","vj_alienswarm/drone/attack03.wav","vj_alienswarm/drone/attack04.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_alienswarm/drone/swipe01.wav","vj_alienswarm/drone/swipe02.wav","vj_alienswarm/drone/swipe03.wav"}
ENT.SoundTbl_Pain = {"vj_alienswarm/drone/pain01.wav","vj_alienswarm/drone/pain02.wav","vj_alienswarm/drone/pain03.wav","vj_alienswarm/drone/pain04.wav","vj_alienswarm/drone/pain05.wav","vj_alienswarm/drone/pain06.wav"}
ENT.SoundTbl_Death = {"vj_alienswarm/drone/deathfire01.wav","vj_alienswarm/drone/deathfire02.wav","vj_alienswarm/drone/deathfire03.wav","vj_alienswarm/drone/deathfire04.wav","vj_alienswarm/drone/death01.wav"}

ENT.FootStepSoundLevel = 55
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetSurroundingBounds(Vector(60, 60, 100), Vector(-60, -60, 0))
	self:SetSkin((math.random(1, 2) == 1 and 0) or 2)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "move" then
		self:FootStepSoundCode()
	elseif key == "melee_hit" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFlinch(dmginfo, hitgroup, status)
	if status == "PriorExecution" then
		if dmginfo:GetDamage() > 20 then
			self.AnimTbl_Flinch = ACT_BIG_FLINCH
		else
			self.AnimTbl_Flinch = ACT_SMALL_FLINCH
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	-- High damage force, don't play death animation
	if status == "Initial" && dmginfo:GetDamageForce():Length() > 10000 then
		self.HasDeathAnimation = false
	end
end