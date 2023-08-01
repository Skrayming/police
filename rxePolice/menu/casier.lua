ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.esxGet, function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

local current = "police"
local dangerosityTable = {[1] = "Coopératif",[2] = "Dangereux",[3] = "Dangereux et armé",[4] = "Terroriste"}
lspdCJBuilder = {dangerosity = 1}
lspdCJData = nil
lspdCJindex = 0
colorVar = "~o~"
local filterArray = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
local filter = 1

RegisterNetEvent("corp:cjGet")
AddEventHandler("corp:cjGet", function(result)
    local found = 0
    for k,v in pairs(result) do
        found = found + 1
    end
    if found > 0 then lspdCJData = result end
end)


function notNilString(str)
    if str == nil then
        return ""
    else
        return str
    end
end

local function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function CasierPolice()
	local CdePopop = RageUI.CreateMenu("Casier Judiciaire", "Los Santos Police Departement")
	local cj_infos = RageUI.CreateSubMenu(CdePopop, "Casier Judiciaire", "Los Santos Police Departement")
	local cj = RageUI.CreateSubMenu(CdePopop, "Casier Judiciaire", "Los Santos Police Departement")
	local cj_add = RageUI.CreateSubMenu(CdePopop, "Casier Judiciaire", "Los Santos Police Departement")
    CdePopop:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	cj_infos:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	cj:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	cj_add:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)

	  RageUI.Visible(CdePopop, not RageUI.Visible(CdePopop))
  
			  while CdePopop do
				  Citizen.Wait(0)
					  RageUI.IsVisible(CdePopop, true, true, true, function()

					RageUI.Separator("↓ ~b~ Intéractions~s~ ↓")
		
					RageUI.ButtonWithStyle("Consulter la base de données", nil, {RightLabel = "→"}, true, function(_,_,s)
						if s then
							lspdCJData = nil
							TriggerServerEvent("corp:cjGet")
						end
					end, cj)

					RageUI.ButtonWithStyle("Ajouter un civil à la base de données", nil, {RightLabel = "→"}, true, function()
					end, cj_add)


				end, function()
			  	end)
		
			RageUI.IsVisible(cj, true, true, true, function()
		
				RageUI.List("Filtre :", filterArray, filter, nil, {}, true, function(_, _, _, i)
                    filter = i
                end)

				if lspdCJData == nil then

					RageUI.Separator("")
					RageUI.Separator("~r~Aucun casier")
					RageUI.Separator("")

				else
					for index,cj in pairs(lspdCJData) do
						if starts(cj.firstname:lower(), filterArray[filter]:lower()) then
							RageUI.ButtonWithStyle("→ "..cj.firstname.." "..cj.lastname, nil, { RightLabel = "~b~→→" }, true, function(_,_,s)
								if s then
									lspdCJindex = index
								end
							end, cj_infos)
						else 
							RageUI.Separator("")
							RageUI.Separator("~r~Aucun casier commençant par "..filterArray[filter])
							RageUI.Separator("")
						end
					end
					
				end
		
			end, function()
			end)
		
			RageUI.IsVisible(cj_add, true, true, true, function()

				RageUI.ButtonWithStyle("Prénom : ~b~"..notNilString(lspdCJBuilder.firstname), "~r~Prénom : ~s~"..notNilString(lspdCJBuilder.firstname), { RightLabel = "→" }, true, function(_,_,s)
					if s then
						lspdCJBuilder.firstname = KeyboardInput("Prénom", "", 10)
					end
				end)
		
				RageUI.ButtonWithStyle("Nom : ~b~"..notNilString(lspdCJBuilder.lastname), "~r~Nom : ~s~"..notNilString(lspdCJBuilder.lastname), { RightLabel = "→" }, true, function(_,_,s)
					if s then
						lspdCJBuilder.lastname = KeyboardInput("Nom", "", 10)
					end
				end)
		
				RageUI.ButtonWithStyle("Motif : ~b~"..notNilString(lspdCJBuilder.reason), "~r~Motif : ~s~"..notNilString(lspdCJBuilder.reason), { RightLabel = "→" }, true, function(_,_,s)
					if s then
						lspdCJBuilder.reason = KeyboardInput("Raison", "", 100)
					end
				end)
		
				RageUI.ButtonWithStyle("~g~Ajouter", nil, { RightLabel = "→→" }, lspdCJBuilder.firstname ~= nil and lspdCJBuilder.lastname ~= nil and lspdCJBuilder.reason ~= nil, function(_,_,s)
					if s then
						RageUI.GoBack()
						TriggerServerEvent("corp:cjAdd", lspdCJBuilder)
						RageUI.Popup({message = "Civil ajouter à la base de données..."})
					end
				end)

			end, function()
			end)
		
			RageUI.IsVisible(cj_infos, true, true, true, function()
				RageUI.Separator("↓ ~r~Informations ~s~↓")
				RageUI.ButtonWithStyle("~g~Dépositaire: ~s~"..lspdCJData[lspdCJindex].author, nil, {}, true, function()end)
				RageUI.ButtonWithStyle("~g~Le: ~s~"..lspdCJData[lspdCJindex].date, nil, {}, true, function()end)
				RageUI.ButtonWithStyle("~o~Prénom/Nom: ~s~"..lspdCJData[lspdCJindex].firstname.." "..lspdCJData[lspdCJindex].lastname, nil, {}, true, function()end)
				RageUI.ButtonWithStyle("~o~Motif(s): ~s~"..lspdCJData[lspdCJindex].reason, nil, {}, true, function()end)


					RageUI.Separator("↓ ~r~Actions ~s~↓")

					RageUI.ButtonWithStyle('~b~Ajouter/Supprimer un motif ', "~r~Action irréversible", {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
						if (Selected) then
							lspdCJBuilder.newreason = KeyboardInput("Raison", lspdCJData[lspdCJindex].reason..", ", 100)
							TriggerServerEvent("corp:cjModify", lspdCJBuilder, lspdCJindex, newreason)
							RageUI.Popup({message = "Raison ajouter au casier de l'individu..."})
							RageUI.CloseAll()
						end 
					end)

					RageUI.ButtonWithStyle("~r~Supprimer le casier", nil, {RightLabel = "→→"}, true, function(_,_,s)
						if s then
							RageUI.GoBack()
							TriggerServerEvent("corp:cjDel", lspdCJindex)
							RageUI.Popup({message = "Civil retirer de la base de données..."})
						end
					end)

		
				end, function()
				end)

			  if not RageUI.Visible(CdePopop) and not RageUI.Visible(cj_infos) and not RageUI.Visible(cj) and not RageUI.Visible(cj_add) then
			  CdePopop = RMenu:DeleteType("Casier Judiciaire", true)
		  end
	  end
  end   
  
  Citizen.CreateThread(function()
	  while true do
		  local Timer = 800
		  if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointCasier then
		  local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
		  local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.casierjudiciaire.position.x, Config.pos.casierjudiciaire.position.y, Config.pos.casierjudiciaire.position.z)

		  if dist3 <= Config.Marker.drawdistance then
			  Timer = 0
			  DrawMarker(Config.Marker.type, Config.pos.casierjudiciaire.position.x, Config.pos.casierjudiciaire.position.y, Config.pos.casierjudiciaire.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
			end
			  if dist3 <= 2.0 then
				  Timer = 0   
					RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Casiers Judiciaire", time_display = 1 })
					if IsControlJustPressed(1,51) then         
					CasierPolice()
					end   
				end
			end
		  Citizen.Wait(Timer)
	end
end)
