AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted, 
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.SingleSpawner = true -- If set to true, it will spawn the entities once then remove itself
ENT.EntitiesToSpawn = {
	{EntityName = "NPC1",SpawnPosition = {vForward=0,vRight=0,vUp=0},Entities = {"npc_vj_as_drone","npc_vj_as_drone","npc_vj_as_drone","npc_vj_as_drone","npc_vj_as_drone","npc_vj_as_drone","npc_vj_as_droneb","npc_vj_as_droneb","npc_vj_as_droneb","npc_vj_as_droneb_big","npc_vj_as_droneb_big","npc_vj_as_droneb_elite","npc_vj_as_droneb_elite","npc_vj_as_droneb_big_elite"}},
}
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/