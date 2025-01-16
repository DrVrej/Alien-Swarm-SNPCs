/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2025 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local AddonName = "Alien Swarm SNPCs"
local AddonType = "NPC"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua", "GAME")
if VJExists == true then
	include("autorun/vj_controls.lua")

	local spawnCategory = "Alien Swarm"
	
	VJ.AddNPC("Buzzer", "npc_vj_as_buzzer", spawnCategory)
	VJ.AddNPC("Drone", "npc_vj_as_drone", spawnCategory)
	VJ.AddNPC("Shieldbug", "npc_vj_as_sbug", spawnCategory)
	VJ.AddNPC("Beta Drone", "npc_vj_as_droneb", spawnCategory)
	VJ.AddNPC("Beta Drone Elite", "npc_vj_as_droneb_elite", spawnCategory)
	VJ.AddNPC("Large Beta Drone", "npc_vj_as_droneb_big", spawnCategory)
	VJ.AddNPC("Large Beta Drone Elite", "npc_vj_as_droneb_big_elite", spawnCategory)
	VJ.AddNPC("Boomer", "npc_vj_as_boomer", spawnCategory)
	VJ.AddNPC("Beta Shieldbug", "npc_vj_as_sbugb", spawnCategory)
	VJ.AddNPC("Beta Queen", "npc_vj_as_queenb", spawnCategory)
	
	VJ.AddNPC("Drone Spawner", "sent_vj_as_dronesp", spawnCategory)
	VJ.AddNPC("Random Beta Drone", "sent_vj_as_droneb", spawnCategory)
	VJ.AddNPC("Random Beta Drone Spawner", "sent_vj_as_dronebsp", spawnCategory)

	-- Precache Models --
	util.PrecacheModel("models/aliens/boomer/boomerleg.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerlega.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerlegb.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerlegc.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerparts_lower_leg.mdl")
	util.PrecacheModel("models/aliens/boomer/boomerparts_upper_leg.mdl")

-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile()
	VJ.AddAddonProperty(AddonName, AddonType)
else
	if CLIENT then
		chat.AddText(Color(0, 200, 200), AddonName, 
		Color(0, 255, 0), " was unable to install, you are missing ", 
		Color(255, 100, 0), "VJ Base!")
	end

	timer.Simple(1, function()
		if not VJBASE_ERROR_MISSING then
			VJBASE_ERROR_MISSING = true
			if CLIENT then
				// Get rid of old error messages from addons running on older code...
				if VJF && type(VJF) == "Panel" then
					VJF:Close()
				end
				VJF = true
				
				local frame = vgui.Create("DFrame")
				frame:SetSize(600, 160)
				frame:SetPos((ScrW() - frame:GetWide()) / 2, (ScrH() - frame:GetTall()) / 2)
				frame:SetTitle("Error: VJ Base is missing!")
				frame:SetBackgroundBlur(true)
				frame:MakePopup()

				local labelTitle = vgui.Create("DLabel", frame)
				labelTitle:SetPos(250, 30)
				labelTitle:SetText("VJ BASE IS MISSING!")
				labelTitle:SetTextColor(Color(255, 128, 128))
				labelTitle:SizeToContents()
				
				local label1 = vgui.Create("DLabel", frame)
				label1:SetPos(170, 50)
				label1:SetText("Garry's Mod was unable to find VJ Base in your files!")
				label1:SizeToContents()
				
				local label2 = vgui.Create("DLabel", frame)
				label2:SetPos(10, 70)
				label2:SetText("You have an addon installed that requires VJ Base but VJ Base is missing. To install VJ Base, click on the link below. Once\n                                                   installed, make sure it is enabled and then restart your game.")
				label2:SizeToContents()
				
				local link = vgui.Create("DLabelURL", frame)
				link:SetSize(300, 20)
				link:SetPos(195, 100)
				link:SetText("VJ_Base_Download_Link_(Steam_Workshop)")
				link:SetURL("https://steamcommunity.com/sharedfiles/filedetails/?id=131759821")
				
				local buttonClose = vgui.Create("DButton", frame)
				buttonClose:SetText("CLOSE")
				buttonClose:SetPos(260, 120)
				buttonClose:SetSize(80, 35)
				buttonClose.DoClick = function()
					frame:Close()
				end
			elseif (SERVER) then
				VJF = true
				timer.Remove("VJBASEMissing")
				timer.Create("VJBASE_ERROR_CONFLICT", 5, 0, function()
					print("VJ Base is missing! Download it from the Steam Workshop! Link: https://steamcommunity.com/sharedfiles/filedetails/?id=131759821")
				end)
			end
		end
	end)
end