/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Alien Swarm SNPCs"
local AddonName = "Alien Swarm"
local AddonType = "SNPC"
local AutorunFile = "autorun/vj_as_autorun.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	local vCat = "Alien Swarm"
	
	VJ.AddNPC("Buzzer","npc_vj_as_buzzer",vCat)
	VJ.AddNPC("Drone","npc_vj_as_drone",vCat)
	VJ.AddNPC("Shieldbug","npc_vj_as_sbug",vCat)
	VJ.AddNPC("Beta Drone","npc_vj_as_droneb",vCat)
	VJ.AddNPC("Beta Drone Elite","npc_vj_as_droneb_elite",vCat)
	VJ.AddNPC("Large Beta Drone","npc_vj_as_droneb_big",vCat)
	VJ.AddNPC("Large Beta Drone Elite","npc_vj_as_droneb_big_elite",vCat)
	VJ.AddNPC("Boomer","npc_vj_as_boomer",vCat)
	VJ.AddNPC("Beta Shieldbug","npc_vj_as_sbugb",vCat)
	VJ.AddNPC("Beta Queen","npc_vj_as_queenb",vCat)
	
	VJ.AddNPC("Random Drone","sent_vj_as_randdrone",vCat)
	VJ.AddNPC("Random Drone Spawner","sent_vj_as_randdronesp",vCat)
	VJ.AddNPC("Default Drone Spawner","sent_vj_as_randdronedsp",vCat)
	VJ.AddNPC("Random Beta Drone","sent_vj_as_randdroneb",vCat)
	VJ.AddNPC("Random Beta Drone Spawner","sent_vj_as_randdronebsp",vCat)

	-- Precache Models --
	util.PrecacheModel("models/aliens/boomer/boomerleg.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerlega.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerlegb.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerlegc.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerparts_lower_leg.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerparts_upper_leg.mdl")

	-- ConVars --
	VJ.AddConVar("vj_as_buzzer_h",30)
	VJ.AddConVar("vj_as_buzzer_d",15)
	
	VJ.AddConVar("vj_as_drone_h",60)
	VJ.AddConVar("vj_as_drone_d",15)

	VJ.AddConVar("vj_as_droneb_h",60)
	VJ.AddConVar("vj_as_droneb_d",15)
	
	VJ.AddConVar("vj_as_droneb_elite_h",150)
	VJ.AddConVar("vj_as_droneb_elite_d",35)

	VJ.AddConVar("vj_as_dronebb_h",220)
	VJ.AddConVar("vj_as_dronebb_d",25)
	
	VJ.AddConVar("vj_as_dronebb_elite_h",400)
	VJ.AddConVar("vj_as_dronebb_elite_d",45)

	VJ.AddConVar("vj_as_boomer_h",350)
	VJ.AddConVar("vj_as_boomer_d_push",65)
	VJ.AddConVar("vj_as_boomer_d_stomp",85)
	
	VJ.AddConVar("vj_as_shieldbugb_h",800)
	VJ.AddConVar("vj_as_shieldbugb_d_dual",31)
	VJ.AddConVar("vj_as_shieldbugb_d_swipe",50)
	VJ.AddConVar("vj_as_shieldbugb_d_charge",58)

	VJ.AddConVar("vj_as_shieldbug_h",800)
	VJ.AddConVar("vj_as_shieldbug_d",50)

	VJ.AddConVar("vj_as_queenb_h",8000)
	VJ.AddConVar("vj_as_queenb_d_reg",90)
	VJ.AddConVar("vj_as_queenb_d_moving",75)

-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("ERROR!")
				VJF:SetSize(790,560)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				
				local VJURL = vgui.Create("DHTML",VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				VJURL:Dock(FILL)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end