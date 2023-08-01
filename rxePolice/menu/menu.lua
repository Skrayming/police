ESX = nil
local playersInGAV = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.esxGet, function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	
	Citizen.Wait(5000) 
end)

Citizen.CreateThread(function()
	local comicomap = AddBlipForCoord(Config.blip.position.x, Config.blip.position.y, Config.blip.position.z)
	SetBlipSprite(comicomap, Config.blip.sprite)
	SetBlipColour(comicomap, Config.blip.color)
	SetBlipAsShortRange(comicomap, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(Config.blip.name)
	EndTextCommandSetBlipName(comicomap)
end)


object = {}
OtherItems = {}
local inventaire = false
local status = true

local function LoadAnimDict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end

local ped = PlayerPedId()
local vehicle = GetVehiclePedIsIn( ped, false )
local blip = nil
local policeDog = false
local PlayerData = {}
local currentTask = {}
local closestDistance, closestEntity = -1, nil
local Items = {}      -- Item que le joueur possède (se remplit lors d'une fouille)
local Armes = {}    -- Armes que le joueur possède (se remplit lors d'une fouille)
local ArgentSale = {}  -- Argent sale que le joueur possède (se remplit lors d'une fouille)
local IsHandcuffed, DragStatus = false, {}
DragStatus.IsDragged          = false

local function MarquerJoueur()
	local ped = GetPlayerPed(ESX.Game.GetClosestPlayer())
	local pos = GetEntityCoords(ped)
	local target, distance = ESX.Game.GetClosestPlayer()
	if distance <= 4.0 then
	DrawMarker(2, pos.x, pos.y, pos.z+1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 0, 255, 170, 0, 1, 2, 1, nil, nil, 0)
end
end

-- Reprise du menu fouille du pz_core (modifié)
local function getPlayerInv(player)
Items = {}
Armes = {}
ArgentSale = {}

ESX.TriggerServerCallback('finalpolice:getOtherPlayerData', function(data)
	for i=1, #data.accounts, 1 do
		if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
			table.insert(ArgentSale, {
				label    = ESX.Math.Round(data.accounts[i].money),
				value    = 'black_money',
				itemType = 'item_account',
				amount   = data.accounts[i].money
			})

			break
		end
	end
	for i=1, #data.weapons, 1 do
		table.insert(Armes, {
			label    = ESX.GetWeaponLabel(data.weapons[i].name),
			value    = data.weapons[i].name,
			right    = data.weapons[i].ammo,
			itemType = 'item_weapon',
			amount   = data.weapons[i].ammo
		})
	end
	for i=1, #data.inventory, 1 do
		if data.inventory[i].count > 0 then
			table.insert(Items, {
				label    = data.inventory[i].label,
				right    = data.inventory[i].count,
				value    = data.inventory[i].name,
				itemType = 'item_standard',
				amount   = data.inventory[i].count
			})
		end
	end
end, GetPlayerServerId(player))
end

function getInformations(player)
	ESX.TriggerServerCallback('finalpolice:getOtherPlayerData', function(data)
		identityStats = data
	end, GetPlayerServerId(player))
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

local current = "police"
local dangerosityTable = {[1] = "Coopératif",[2] = "Dangereux",[3] = "Dangereux et armé",[4] = "Terroriste"}
lspdADRDangerosities = {"Coopératif","Dangereux","Dangereux et armé","Terroriste"}
lspdADRBuilder = {dangerosity = 1}
lspdADRData = nil
lspdADRindex = 0
colorVar = "~o~"


function getDangerosityNameByInt(dangerosity)
    if dangerosityTable[dangerosity] ~= nil then
        return dangerosityTable[dangerosity]
    else
        return dangerosity
    end
end

RegisterNetEvent("corp:adrGet")
AddEventHandler("corp:adrGet", function(result)
    local found = 0
    for k,v in pairs(result) do
        found = found + 1
    end
    if found > 0 then lspdADRData = result end
end)

local function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local filterArray = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
local filter = 1

local function DrugsEnos()

	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

	Wait(100)
	
	ESX.TriggerServerCallback('finalpolice:getEnosStatus', function(status)

	if status.val == 0 then
		RageUI.Popup({message = "<C>[~r~Test de drogue~s~] ~r~Négatif"})
		  else
		RageUI.Popup({message = "<C>[~r~Test de drogue~s~] ~g~Positif"})
	end

end, GetPlayerServerId(closestPlayer), 'drug')
end

local function AlcoolEnos()

	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

	Wait(100)
	
	ESX.TriggerServerCallback('finalpolice:getEnosStatus', function(status)

	if status.val == 0 then
		RageUI.Popup({message = "<C>[~r~Test Alcool~s~] ~r~Négatif"})

		else
		RageUI.Popup({message = "<C>[~r~Test Alcool~s~] ~g~Positif"})
	end

end, GetPlayerServerId(closestPlayer), 'drunk')
end


-----------------------------------------------------------------------------------------------
function Menuf6Police()
	local mf6p = RageUI.CreateMenu("L.S.P.D", "Los Santos Police Departement")
	mf6p:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local inter = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	inter:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local info = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	info:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local renfort = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	renfort:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local voiture = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	voiture:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local chien = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	chien:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local megaphone = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	megaphone:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local gererlicenses = RageUI.CreateSubMenu(inter, "L.S.P.D", "Los Santos Police Departement")
	gererlicenses:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local lspd_main = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	lspd_main:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local lspd_adrcheck = RageUI.CreateSubMenu(lspd_main, "L.S.P.D", "Los Santos Police Departement")
	lspd_adrcheck:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local lspd_adr = RageUI.CreateSubMenu(lspd_main, "L.S.P.D", "Los Santos Police Departement")
	lspd_adr:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local lspd_adrlaunch = RageUI.CreateSubMenu(lspd_main, "L.S.P.D", "Los Santos Police Departement")
	lspd_adrlaunch:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local verif = RageUI.CreateSubMenu(inter, "L.S.P.D", "Los Santos Police Departement")
	verif:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local gestGAV = RageUI.CreateSubMenu(inter, "L.S.P.D", "Los Santos Police Departement")
	gestGAV:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local objets = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	objets:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    local PropsMenu = RageUI.CreateSubMenu(objets, "Menu Props", "Catégories :")
	PropsMenu:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    local PropsMenuobject = RageUI.CreateSubMenu(objets, "Props", "Appuyer sur ~g~E~w~ pour poser les objet")
	PropsMenuobject:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    local PropsMenuobjectlist = RageUI.CreateSubMenu(objets, "Suppression d'objets", "Suppression d'objets")
	PropsMenuobjectlist:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    local Gestinter = RageUI.CreateSubMenu(mf6p, "L.S.P.D", "Los Santos Police Departement")
	PropsMenuobjectlist:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local fouiller = RageUI.CreateSubMenu(verif, "L.S.P.D", "Los Santos Police Departement")
	fouiller:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	local label = "Prendre son service"

	RageUI.Visible(mf6p, not RageUI.Visible(mf6p))
	while mf6p do
		Citizen.Wait(0)
			RageUI.IsVisible(mf6p, true, true, true, function()

			RageUI.Checkbox(label, nil, policeserv, { Style = RageUI.CheckboxStyle.Tick }, function(Hovered, Selected, Active, Checked)
				policeserv = Checked;
			end, function()
				onservice = true
				TriggerServerEvent('police:PriseEtFinservice', "prise")
				TriggerServerEvent('rxePolice:logsEvent', GetPlayerName(PlayerId()).." a pris son service", Config.logs.PriseFinService)
				label = "Quitter son service"
			end, function()
				onservice = false
				TriggerServerEvent('police:PriseEtFinservice', "fin")
				TriggerServerEvent('rxePolice:logsEvent', GetPlayerName(PlayerId()).." a quitté son service", Config.logs.PriseFinService)
				label = "Prendre son service"
			end)

			if onservice then

				RageUI.Separator("↓ ~o~ Intéractions~s~ ↓")

				RageUI.ButtonWithStyle("Actions citoyens", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, inter)

				RageUI.ButtonWithStyle("Actions véhicules", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, voiture)

				RageUI.ButtonWithStyle("Actions Radio", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, info)

				if ESX.PlayerData.job.grade >= Config.GradeMenuAvisDeRecherche then
				RageUI.ButtonWithStyle("Avis de recherche", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, lspd_main)
				end

				if ESX.PlayerData.job.grade >= Config.GradeMenuObjets then
				RageUI.ButtonWithStyle("Gestion Objets", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, objets)
				end

				if ESX.PlayerData.job.grade >= Config.GradeMenuChien then
				RageUI.ButtonWithStyle("Gestion K-9", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, chien)
				end

				if ESX.PlayerData.job.grade >= Config.GradeMenuIntervention then
				RageUI.ButtonWithStyle("Gestion Intérventions", nil, {RightLabel = "→→"},true, function(h,a,s)
				end, Gestinter)
				end

			end

		end, function()
		end)

	RageUI.IsVisible(inter, true, true, true, function()

		RageUI.ButtonWithStyle('Vérifications', nil, {RightLabel = "→→"}, true, function()
		end, verif)
		
		RageUI.ButtonWithStyle('Gestion G.A.V', nil, {RightLabel = "→→"}, true, function(_,_,s)
			if s then
				ESX.TriggerServerCallback('rxePolice:getAllPlayerInGAV', function(result)
					playersInGAV = result
				end)
			end
		end, gestGAV)

		RageUI.ButtonWithStyle("Droit miranda", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if (Selected) then   
			RageUI.Popup({message = "Monsieur / Madame (Prénom et nom de la personne), je vous arrête pour (motif de l'arrestation)."})
			RageUI.Popup({message = "Vous avez le droit de garder le silence."})
			RageUI.Popup({message = "Si vous renoncez à ce droit, tout ce que vous direz pourra être et sera utilisé contre vous."})
			RageUI.Popup({message = "Vous avez le droit à un avocat, si vous n’en avez pas les moyens, un avocat vous sera fourni."})
			RageUI.Popup({message = "Vous avez le droit à une assistance médicale ainsi qu'à de la nourriture et de l'eau."})
			RageUI.Popup({message = "Avez-vous bien compris vos droits ?"})
			cooldowncool(4500)
			end
		end)

		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		RageUI.ButtonWithStyle("Facture / Amende",nil, {RightLabel = "→"}, not cooldown, function(h,a,s)
			if a then
				MarquerJoueur()
			local player, distance = ESX.Game.GetClosestPlayer()
			if s then
				local raison = ""
				local montant = 0
				AddTextEntry("FMMC_MPM_NA", "Objet de la facture")
				DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Donnez le motif de la facture :", "", "", "", "", 30)
				while (UpdateOnscreenKeyboard() == 0) do
					DisableAllControlActions(0)
					Wait(0)
				end
				if (GetOnscreenKeyboardResult()) then
					local result = GetOnscreenKeyboardResult()
					if result then
						raison = result
						result = nil
						AddTextEntry("FMMC_MPM_NA", "Montant de la facture")
						DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Indiquez le montant de la facture :", "", "", "", "", 30)
						while (UpdateOnscreenKeyboard() == 0) do
							DisableAllControlActions(0)
							Wait(0)
						end
						if (GetOnscreenKeyboardResult()) then
							result = GetOnscreenKeyboardResult()
							if result then
								montant = result
								result = nil
								if player ~= -1 and distance <= 3.0 then
									TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', ('Police'), montant)
									TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..montant.. '$ ~s~pour cette raison : ~b~' ..raison.. '', 'CHAR_BANK_FLEECA', 9)
									TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()) .. " a envoyé une facture de " .. montant .. "$ pour " .. raison .. " à " .. GetPlayerName(GetPlayerServerId(player)), Config.logs.FactureAmende)
								else
									RageUI.Popup({message = "<C>~r~Probleme~s~: Aucuns joueurs proche"})
								end
							end
						end
					end
				end
				cooldowncool(4500)
			end
			end
		end)

        RageUI.ButtonWithStyle("Menotter/démenotter", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if Active then
				MarquerJoueur()
            if (Selected) then
				local target, distance = ESX.Game.GetClosestPlayer()
				playerheading = GetEntityHeading(GetPlayerPed(-1))
				playerlocation = GetEntityForwardVector(PlayerPedId())
				playerCoords = GetEntityCoords(GetPlayerPed(-1))
				local target_id = GetPlayerServerId(target)
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent('finalpolice:handcuff', GetPlayerServerId(closestPlayer))
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()) .. " a menotté " .. GetPlayerName(GetPlayerServerId(closestPlayer)), Config.logs.Fouille)
			else
				RageUI.Popup({message = "<C>~r~Probleme~s~: Aucuns joueurs proche"})
				end
				cooldowncool(4500)
            end
		end
        end)

            RageUI.ButtonWithStyle("Escorter", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Active then
					MarquerJoueur()
                if (Selected) then
					local target, distance = ESX.Game.GetClosestPlayer()
					playerheading = GetEntityHeading(GetPlayerPed(-1))
					playerlocation = GetEntityForwardVector(PlayerPedId())
					playerCoords = GetEntityCoords(GetPlayerPed(-1))
					local target_id = GetPlayerServerId(target)
					if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent('finalpolice:drag', GetPlayerServerId(closestPlayer))
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()) .. " a escorté " .. GetPlayerName(GetPlayerServerId(closestPlayer)), Config.logs.Fouille)
			else
									RageUI.Popup({message = "<C>~r~Probleme~s~: Aucuns joueurs proche"})
				end
				cooldowncool(4500)
            end
		end
        end)

            RageUI.ButtonWithStyle("Mettre dans un véhicule", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Active then
					MarquerJoueur()
                if (Selected) then
					local target, distance = ESX.Game.GetClosestPlayer()
					playerheading = GetEntityHeading(GetPlayerPed(-1))
					playerlocation = GetEntityForwardVector(PlayerPedId())
					playerCoords = GetEntityCoords(GetPlayerPed(-1))
					local target_id = GetPlayerServerId(target)
					if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent('finalpolice:putInVehicle', GetPlayerServerId(closestPlayer))
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()) .. " a mis " .. GetPlayerName(GetPlayerServerId(closestPlayer)) .. " dans un véhicule", Config.logs.Fouille)
			else
									RageUI.Popup({message = "<C>~r~Probleme~s~: Aucuns joueurs proche"})
				end
				cooldowncool(4500)
			end
                end
            end)

            RageUI.ButtonWithStyle("Sortir du véhicule", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Active then
					MarquerJoueur()
                if (Selected) then
					local target, distance = ESX.Game.GetClosestPlayer()
					playerheading = GetEntityHeading(GetPlayerPed(-1))
					playerlocation = GetEntityForwardVector(PlayerPedId())
					playerCoords = GetEntityCoords(GetPlayerPed(-1))
					local target_id = GetPlayerServerId(target)
					if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent('finalpolice:OutVehicle', GetPlayerServerId(closestPlayer))
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()) .. " a sorti " .. GetPlayerName(GetPlayerServerId(closestPlayer)) .. " du véhicule", Config.logs.Fouille)
			else
									RageUI.Popup({message = "<C>~r~Probleme~s~: Aucuns joueurs proche"})
				end
				cooldowncool(4500)
			end
            end
        end)

    end, function()
	end)

	RageUI.IsVisible(objets, true, true, true, function()

		RageUI.ButtonWithStyle("Police", "Appuyer sur [~g~E~w~] pour poser les objet", { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
		end, PropsMenuobject)

		RageUI.ButtonWithStyle("Mode suppression", "Supprimer des objets", { RightLabel = "XXX" }, true, function(Hovered, Active, Selected)
		end, PropsMenuobjectlist)

    end, function()
	end)

	RageUI.IsVisible(verif, true, true, true, function()

		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

		if ESX.PlayerData.job.grade >= Config.GradeMenuFouille then
			RageUI.ButtonWithStyle('Fouille', nil, {RightLabel = "→"}, not cooldown, function(_, a, s)
				if a then
					MarquerJoueur()
					if s then
						if closestPlayer ~= -1 and closestDistance <= 3.0 then
							getPlayerInv(closestPlayer)
							ExecuteCommand("me fouille l'individu")
						else
							RageUI.Popup({message = "Personne autour de vous"})
						end
						cooldowncool(4500)
					end
				end
			end, fouiller) 
			end

		if ESX.PlayerData.job.grade >= Config.GradeMenuLicences then
		RageUI.ButtonWithStyle("Licences", "Permet de verifier les licences", {RightLabel = "→"}, not cooldown, function(_, a, s)
				if a then
					MarquerJoueur()
				if s then
					if closestPlayer ~= -1 and closestDistance <= 3.0 then
						getInformations(closestPlayer)
						player = closestPlayer
					else
						RageUI.Popup({message = "Personne autour de vous"})
					end
					cooldowncool(4500)
				end
			end
		end, gererlicenses)
		end

		if ESX.PlayerData.job.grade >= Config.GradeMenuDrugs then
			RageUI.ButtonWithStyle('Faire un test multidrogue', "Permet de faire un test multidrogue", {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Active then
					MarquerJoueur()
				if (Selected) then
					if closestPlayer ~= -1 and closestDistance <= 3.0 then
							DrugsEnos()
							RageUI.CloseAll()
							else
								RageUI.Popup({
									message = "Personne autour de vous"})
							end
						cooldowncool(4500)
						end 
					end
				end)
			end



		if ESX.PlayerData.job.grade >= Config.GradeMenuAlcool then
			RageUI.ButtonWithStyle('Faire un test d\'alcoolémie', "Permet de faire un test d\'alcoolémie", {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Active then
					MarquerJoueur()
				if (Selected) then
					if closestPlayer ~= -1 and closestDistance <= 3.0 then
							AlcoolEnos()
							RageUI.CloseAll()
							else
								RageUI.Popup({
									message = "Personne autour de vous"})
					end
					cooldowncool(4500)
				end
					end 
				end)
		end

    end, function()
	end)

	RageUI.IsVisible(gererlicenses, true, true, true, function()

		local data = identityStats
		if identityStats == nil then
			RageUI.Separator("")
			RageUI.Separator("~o~En attente des données...")
			RageUI.Separator("")
		else
			if data.licenses ~= nil then
				RageUI.Separator("↓ ~o~Licence ~s~↓")
				if data.licenses ~= nil then
					for i = 1, #data.licenses, 1 do
						if data.licenses[i].label ~= nil and data.licenses[i].type ~= nil then
							RageUI.ButtonWithStyle(data.licenses[i].label ,nil, {RightLabel = "Revoqué ~s~→"}, true, function(_,_,s)
								if s then
									TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.licenses[i].type)


									ESX.SetTimeout(300, function()
										RageUI.CloseAll()
										identityStats = nil
										Wait(500)
										RageUI.Visible(RMenu:Get("Police","main"), true)
									end)
								end
							end)
						end
					end
				else
					RageUI.Separator("")
					RageUI.Separator("~o~La personne n'as pas de licence...")
					RageUI.Separator("")
				end
			end
		end

	end, function()
	end)

	RageUI.IsVisible(fouiller, true, true, true, function()
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

		RageUI.Separator("↓ ~r~Argent Sale ~s~↓")
		for k,v  in pairs(ArgentSale) do
			RageUI.ButtonWithStyle("Argent sale :", nil, {RightLabel = "~r~"..v.label.."$"}, true, function(_, _, s)
				if s then
					local combien = KeyboardInput("Combien ?", '' , '', 8)
					if tonumber(combien) > v.amount then
						RageUI.Popup({message = "<C>~r~Quantité invalide"})
					else
						TriggerServerEvent('yaya:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
						TriggerEvent('Ise_Logs', Config.Logs_Fouille, 3447003, "FOUILLE POLICE", "Nom : "..GetPlayerName(PlayerId())..".\nA confisquer de l'argent sale: x"..combien.." "..v.value.." à "..GetPlayerName(closestPlayer))
					end
					RageUI.GoBack()
				end
			end)
		end

		RageUI.Separator("↓ ~g~Objets ~s~↓")
		for k,v  in pairs(Items) do
			RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~g~x"..v.right}, true, function(_, _, s)
				if s then
					local combien = KeyboardInput("Combien ?", '' , '', 8)
					if tonumber(combien) > v.amount then
						RageUI.Popup({message = "<C>~r~Quantité invalide"})
					else
						TriggerServerEvent('yaya:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
						TriggerEvent('Ise_Logs', Config.Logs_Fouille, 3447003, "FOUILLE POLICE", "Nom : "..GetPlayerName(PlayerId())..".\nA confisquer : x"..combien.." "..v.value.." à "..GetPlayerName(closestPlayer))
					end
					RageUI.GoBack()
				end
			end)
		end
			RageUI.Separator("↓ ~g~Armes ~s~↓")

			for k,v  in pairs(Armes) do
				RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "avec ~g~"..v.right.. " ~s~balle(s)"}, true, function(_, _, s)
					if s then
						local combien = KeyboardInput("Combien ?", '' , '', 8)
						if tonumber(combien) > v.amount then
							RageUI.Popup({message = "<C>~r~Quantité invalide"})
						else
							TriggerServerEvent('yaya:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
							TriggerEvent('Ise_Logs', Config.Logs_Fouille, 3447003, "FOUILLE POLICE", "Nom : "..GetPlayerName(PlayerId())..".\nA confisquer une arme : x"..combien.." "..v.value.." à "..GetPlayerName(closestPlayer))
						end
						RageUI.GoBack()
					end
				end)
			end

		end, function() 
		end)

		RageUI.IsVisible(info, true, true, true, function()

		RageUI.ButtonWithStyle("Prise de service",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'prise'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Fin de service",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'fin'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Pause de service",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'pause'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Standby",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'standby'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Control en cours",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'control'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Refus d'obtempérer",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'refus'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Crime en cours",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local info = 'crime'
				TriggerServerEvent('police:PriseEtFinservice', info)
				cooldowncool(5000)
			end
		end)

		RageUI.Separator(' ↓ ~o~Renfort~s~ ↓ ')

		RageUI.ButtonWithStyle("Petite demande",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local raison = 'petit'
				local elements  = {}
				local playerPed = PlayerPedId()
				local coords  = GetEntityCoords(playerPed)
				local name = GetPlayerName(PlayerId())
			TriggerServerEvent('renfort', coords, raison)
			cooldowncool(5000)
		end
	end)

			RageUI.ButtonWithStyle("Moyenne demande",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
				if Selected then
					local raison = 'importante'
					local elements  = {}
					local playerPed = PlayerPedId()
					local coords  = GetEntityCoords(playerPed)
					local name = GetPlayerName(PlayerId())
				TriggerServerEvent('renfort', coords, raison)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Grosse demande",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				local raison = 'omgad'
				local elements  = {}
				local playerPed = PlayerPedId()
				local coords  = GetEntityCoords(playerPed)
				local name = GetPlayerName(PlayerId())
			TriggerServerEvent('renfort', coords, raison)
			cooldowncool(5000)
		end
		end)

    end, function()
	end)

	RageUI.IsVisible(megaphone, true, true, true, function()

		RageUI.ButtonWithStyle("Arrêter vous immédiatement !", nil, {RightLabel = "→"},not cooldown, function(Hovered, Active, Selected)
			if Selected then   
				TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 30.0, "stop_the_f_car", 0.6) 
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Conducteur, STOP votre véhicule", nil, {RightLabel = "→"},not cooldown, function(Hovered, Active, Selected)
			if Selected then   
				TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 30.0, "stop_vehicle-2", 0.6)
				cooldowncool(5000)
			end
		end)
		
		RageUI.ButtonWithStyle("Stop, les mains en l'air", nil, {RightLabel = "→"},not cooldown, function(Hovered, Active, Selected)
			if Selected then   
				TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 30.0, "dont_make_me", 0.6)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Stop, plus un geste ! ou on vous tue", nil, {RightLabel = "→"},not cooldown, function(Hovered, Active, Selected)
			if Selected then   
				TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 30.0, "stop_dont_move", 0.6)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Reste ici et ne bouge plus !", nil, {RightLabel = "→"},not cooldown, function(Hovered, Active, Selected)
			if Selected then   
				TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 30.0, "stay_right_there", 0.6)
				cooldowncool(5000)
			end
		end)

		RageUI.ButtonWithStyle("Disperssez vous de suite ! ", nil, {RightLabel = "→"},not cooldown, function(Hovered, Active, Selected)
			if Selected then   
				TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 30.0, "disperse_now", 0.6)
				cooldowncool(5000)
			end
		end)

			end, function()
			end)

			RageUI.IsVisible(voiture, true, true, true, function()

				if ESX.PlayerData.job.grade >= Config.GradeMenuRadar then
				RageUI.ButtonWithStyle("Poser/Prendre Radar",nil, {RightLabel = "→"}, not cooldown, function(h,a,s)
					if s then
						RageUI.CloseAll()       
						TriggerEvent('police:POLICE_radar')
						cooldowncool(5000)
					end
				end)
				end
				
			if ESX.PlayerData.job.grade >= Config.GradeMenuMegaphone then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				RageUI.ButtonWithStyle("Mégaphone", nil, {RightLabel = "→"},true, function()
				end, megaphone)
			else
				RageUI.ButtonWithStyle('Mégaphone', "Vous devez être dans un véhicule", {RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
				end)
			end
			end

		RageUI.ButtonWithStyle("Rechercher une plaque",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if Selected then 
				LookupVehicle()
				RageUI.CloseAll()
				cooldowncool(5000)
			end
			end)

			RageUI.ButtonWithStyle("Mettre en fourrière", nil, { RightLabel = "→" }, not cooldown, function(Hovered, Active, Selected)
                if Selected then
                    local playerPed = PlayerPedId()
                    if IsPedSittingInAnyVehicle(playerPed) then
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
                        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                            ESX.Game.DeleteVehicle(vehicle)
							RageUI.Popup({message = "<C>La voiture à été placer en fourriere"})

                           
                        else
							RageUI.Popup({message = "<C>Met toi place conducteur, ou sortez de la voiture."})
                        end
                    else
                        local vehicle = ESX.Game.GetVehicleInDirection()
        
                        if DoesEntityExist(vehicle) then
                            TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CLIPBOARD', 0, true)
                            Citizen.Wait(5000)
                            ClearPedTasks(playerPed)
                            ESX.Game.DeleteVehicle(vehicle)
							RageUI.Popup({message = "<C>La voiture à été placer en fourriere"})
        
                        else
							RageUI.Popup({message = "<C>Aucun véhicule autour"})
                        end
                    end
					cooldowncool(5000)
                end
            end)

			RageUI.ButtonWithStyle("Crocheter le véhicule", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Selected then
					local playerPed = PlayerPedId()
					local vehicle = ESX.Game.GetVehicleInDirection()
					local coords = GetEntityCoords(playerPed)
		
					if IsPedSittingInAnyVehicle(playerPed) then
						RageUI.Popup({message = "<C>Sorter du véhicule"})
						return
					end
		
					if DoesEntityExist(vehicle) then
						isBusy = true
						TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
						Citizen.CreateThread(function()
							Citizen.Wait(10000)
		
							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							ClearPedTasksImmediately(playerPed)
							RageUI.Popup({message = "<C>Véhicule dévérouiller"})
							isBusy = false
						end)
					else
						RageUI.Popup({message = "<C>Pas de véhicule proche"})
					end
					cooldowncool(5000)
				end
			end)
	
	end, function()
	end)

	RageUI.IsVisible(chien, true, true, true, function()

			RageUI.ButtonWithStyle("Sortir/Rentrer le chien",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
				if Selected then
					if not DoesEntityExist(policeDog) then
                        RequestModel(351016938)
                        while not HasModelLoaded(351016938) do Wait(0) end
                        policeDog = CreatePed(4, 351016938, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -0.98), 0.0, true, false)
                        SetEntityAsMissionEntity(policeDog, true, true)
						RageUI.Popup({message = "<C>~g~Chien Spawn"})
                    else
						RageUI.Popup({message = "<C>~r~Chien Rentrer"})
                        DeleteEntity(policeDog)
                    end
					cooldowncool(1500)
				end
			end)

			RageUI.ButtonWithStyle("Assis",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
				if Selected then
					if DoesEntityExist(policeDog) then
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(policeDog), true) <= 5.0 then
                            if IsEntityPlayingAnim(policeDog, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 3) then
                                ClearPedTasks(policeDog)
                            else
                                loadDict('rcmnigel1c')
                                TaskPlayAnim(PlayerPedId(), 'rcmnigel1c', 'hailing_whistle_waive_a', 8.0, -8, -1, 120, 0, false, false, false)
                                Wait(2000)
                                loadDict("creatures@rottweiler@amb@world_dog_sitting@base")
                                TaskPlayAnim(policeDog, "creatures@rottweiler@amb@world_dog_sitting@base", "base", 8.0, -8, -1, 1, 0, false, false, false)
                            end
                        else
							RageUI.Popup({message = "<C>~r~Votre chien est mort"})
                        end
                    else
						RageUI.Popup({message = "<C>~r~Vous n\'avez pas de chien"})
                    end
					cooldowncool(1500)
				end
			end)

		RageUI.ButtonWithStyle("Cherche de drogue",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				if DoesEntityExist(policeDog) then
					if not IsPedDeadOrDying(policeDog) then
						if GetDistanceBetweenCoords(GetEntityCoords(policeDog), GetEntityCoords(PlayerPedId()), true) <= 3.0 then
							local player, distance = ESX.Game.GetClosestPlayer()
							if distance ~= -1 then
								if distance <= 3.0 then
									local playerPed = GetPlayerPed(player)
									if not IsPedInAnyVehicle(playerPed, true) then
										TriggerServerEvent('esx_policedog:hasClosestDrugs', GetPlayerServerId(player))
									end
								end
							end
						end
					else
						RageUI.Popup({message = "<C>~r~Votre chien est mort"})
					end
				else
					RageUI.Popup({message = "<C>~r~Vous n\'avez pas de chien"})
				end
				cooldowncool(1500)
			end
		end)

		RageUI.ButtonWithStyle("Dire d'attaquer",nil, {RightLabel = nil}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				if DoesEntityExist(policeDog) then
					if not IsPedDeadOrDying(policeDog) then
						if GetDistanceBetweenCoords(GetEntityCoords(policeDog), GetEntityCoords(PlayerPedId()), true) <= 3.0 then
							local player, distance = ESX.Game.GetClosestPlayer()
							if distance ~= -1 then
								if distance <= 3.0 then
									local playerPed = GetPlayerPed(player)
									if not IsPedInCombat(policeDog, playerPed) then
										if not IsPedInAnyVehicle(playerPed, true) then
											TaskCombatPed(policeDog, playerPed, 0, 16)
										end
									else
										ClearPedTasksImmediately(policeDog)
									end
								end
							end
						end
					else
						RageUI.Popup({message = "<C>~r~Votre chien est mort"})
					end
				else
					RageUI.Popup({message = "<C>~r~Vous n\'avez pas de chien"})
					
			end
			cooldowncool(1500)
		end
	end)

    end, function()
	end)

	RageUI.IsVisible(lspd_main, true, true, true, function()

		RageUI.Separator("↓ ~o~ Intéractions~s~ ↓")

		RageUI.ButtonWithStyle("Consulter les avis de recherche", nil, {RightLabel = "→→"}, true, function(_,_,s)
			if s then
				lspdADRData = nil
				TriggerServerEvent("corp:adrGet")
			end
		end, lspd_adr)

		RageUI.ButtonWithStyle("Lancer un avis de recherche", nil, {RightLabel = "→→"}, true, function()
		end, lspd_adrlaunch)

	end, function()    
	end, 1)

	RageUI.IsVisible(lspd_adr, true, true, true, function()

		RageUI.List("Filtre :", filterArray, filter, nil, {}, true, function(_, _, _, i)
			filter = i
		end)

		if lspdADRData == nil then
			RageUI.Separator("")
			RageUI.Separator("~r~Aucun avis de recherche")
			RageUI.Separator("")
		else

			RageUI.Separator("↓ ~r~ Avis de recherche~s~ ↓")

			for index,adr in pairs(lspdADRData) do
				if starts(adr.firstname:lower(), filterArray[filter]:lower()) then
				RageUI.ButtonWithStyle(colorVar.."[NV."..adr.dangerosity.."] ~s~"..adr.firstname.." "..adr.lastname, nil, { RightLabel = "~o~Consulter ~s~→→" }, true, function(_,_,s)
					if s then
						lspdADRindex = index
					end
				end, lspd_adrcheck)
			end
			end
			
		end

	end, function()    
	end, 1)


	RageUI.IsVisible(lspd_adrlaunch, true, true, true, function()
		RageUI.ButtonWithStyle("Prénom : ~s~"..notNilString(lspdADRBuilder.firstname), "~r~Prénom : ~s~"..notNilString(lspdADRBuilder.firstname), { RightLabel = "→" }, true, function(_,_,s)
			if s then
				lspdADRBuilder.firstname = KeyboardInput("Prénom", "", 10)
			end
		end)

		RageUI.ButtonWithStyle("Nom : ~s~"..notNilString(lspdADRBuilder.lastname), "~r~Nom : ~s~"..notNilString(lspdADRBuilder.lastname), { RightLabel = "→" }, true, function(_,_,s)
			if s then
				lspdADRBuilder.lastname = KeyboardInput("Nom", "", 10)
			end
		end)

		RageUI.ButtonWithStyle("Motif :", "~r~Motif : ~s~"..notNilString(lspdADRBuilder.reason), { RightLabel = "→" }, true, function(_,_,s)
			if s then
				lspdADRBuilder.reason = KeyboardInput("Raison", "", 100)
			end
		end)

		RageUI.List("Dangerosité", lspdADRDangerosities, lspdADRBuilder.dangerosity, "~r~Dangerosité (Code) : ~s~"..notNilString(lspdADRBuilder.dangerosity), {}, true, function(Hovered, Active, Selected, Index)
			lspdADRBuilder.dangerosity = Index
		end)

		RageUI.ButtonWithStyle("~g~Sauvegarder et envoyer", "~r~Motif : ~s~"..notNilString(lspdADRBuilder.reason), { RightLabel = "→→" }, lspdADRBuilder.firstname ~= nil and lspdADRBuilder.lastname ~= nil and lspdADRBuilder.reason ~= nil, function(_,_,s)
			if s then
				RageUI.GoBack()
				TriggerServerEvent("corp:adrAdd", lspdADRBuilder)
				lspdADRBuilder = {dangerosity = 1}
				RageUI.Popup({message = "Avis de recherche ajouté à la base de données..."})
			end
		end)

	end, function()    
	end, 1)

	RageUI.IsVisible(lspd_adrcheck, true, true, true, function()
		RageUI.Separator("↓ ~o~Informations ~s~↓")
		RageUI.ButtonWithStyle("~b~Dépositaire: ~s~"..lspdADRData[lspdADRindex].author, nil, {}, true, function()end)
		RageUI.ButtonWithStyle("~b~Date: ~s~"..lspdADRData[lspdADRindex].date, nil, {}, true, function()end)
		RageUI.ButtonWithStyle("~o~Prénom: ~s~"..lspdADRData[lspdADRindex].firstname, nil, {}, true, function()end)
		RageUI.ButtonWithStyle("~o~Nom: ~s~"..lspdADRData[lspdADRindex].lastname, nil, {}, true, function()end)
		RageUI.ButtonWithStyle("~r~Dangerosité: ~s~"..getDangerosityNameByInt(lspdADRData[lspdADRindex].dangerosity), nil, {}, true, function()end)
		RageUI.ButtonWithStyle("~r~Raison: ~s~"..lspdADRData[lspdADRindex].reason, nil, {}, true, function()end)

		if ESX.PlayerData.job.grade >= 4 then
			RageUI.Separator("↓ ~o~Actions ~s~↓")
			RageUI.ButtonWithStyle("~r~Enlever l'avis de recherche", nil, {RightLabel = "→→"}, true, function(_,_,s)
				if s then
					RageUI.GoBack()
					TriggerServerEvent("corp:adrDel", lspdADRindex)
					RageUI.Popup({message = "Avis de recherche retiré de la base de données..."})
				end
			end)
		end

	end, function()    
	end, 1)

	RageUI.IsVisible(PropsMenuobject, true, true, true, function()

		RageUI.ButtonWithStyle("Cone", nil, {}, true, function(Hovered, Active, Selected)
			if Selected then
				SpawnObj("prop_roadcone02a")
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()).." a spawné un cone", Config.logs.Objets)
			end
		end)
		RageUI.ButtonWithStyle("Barrière", nil, {}, true, function(Hovered, Active, Selected)
			if Selected then
				SpawnObj("prop_barrier_work05")
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()).." a spawné une barrière", Config.logs.Objets)
			end
		end)
		
		RageUI.ButtonWithStyle("Gros carton", nil, {}, true, function(Hovered, Active, Selected)
			if Selected then
				SpawnObj("prop_boxpile_07d")
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()).." a spawné un gros carton", Config.logs.Objets)
			end
		end)

		RageUI.ButtonWithStyle("Herse", nil, {}, true, function(Hovered, Active, Selected)
			if Selected then
				SpawnObj("p_ld_stinger_s")
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()).." a spawné une herse", Config.logs.Objets)
			end
		end)

		RageUI.ButtonWithStyle("Cash", nil, {}, true, function(Hovered, Active, Selected)
			if Selected then
				SpawnObj("hei_prop_cash_crate_half_full")
				TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()).." a spawné un cash", Config.logs.Objets)
			end
		end)

		end, function()
		end)

		RageUI.IsVisible(PropsMenuobjectlist, true, true, true, function()
				for k,v in pairs(object) do
					if GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))) == 0 then table.remove(object, k) end
					RageUI.ButtonWithStyle("Object: "..GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v))).." ["..v.."]", nil, {}, true, function(Hovered, Active, Selected)
						if Active then
							local entity = NetworkGetEntityFromNetworkId(v)
							local ObjCoords = GetEntityCoords(entity)
							DrawMarker(0, ObjCoords.x, ObjCoords.y, ObjCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 0, 255, 0, 170, 1, 0, 2, 1, nil, nil, 0)
						end
						if Selected then
							RemoveObj(v, k)
							TriggerServerEvent("rxePolice:logsEvent", GetPlayerName(PlayerId()).." a supprimé un objet ("..GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v)))..")", Config.logs.Objets)
						end
					end)
				end
			
		end, function()
		end)

			RageUI.IsVisible(Gestinter, true, true, true, function()

				RageUI.Checkbox("Bouclier",nil, bouclier,{},function(Hovered,Ative,Selected,Checked)
					if Selected then

						bouclier = Checked


						if Checked then
							EnableShield()
							
						else
							DisableShield()
						end
					end
				end)

				RageUI.ButtonWithStyle("Émeute de sécurité",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
					if Selected then 
						SpawnVehicle1()
						cooldowncool(5000)
					end
					end)

				RageUI.ButtonWithStyle("Moto de sécurité",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
					if Selected then 
						SpawnVehicle2()
						cooldowncool(5000)
					end
					end)
				RageUI.ButtonWithStyle("Camion de sécurité",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
					if Selected then 
						SpawnVehicle3()
						cooldowncool(5000)
					end
					end)
				RageUI.ButtonWithStyle("Vélo de sécurité",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
					if Selected then 
						SpawnVehicle4()
						cooldowncool(5000)
					end
					end)

				RageUI.ButtonWithStyle("Sécurité Hélico",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Selected then 
					SpawnVehicle5()
					cooldowncool(5000)
				end
				end)

				RageUI.ButtonWithStyle("Donne des armes",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
					if Selected then 
					GiveWeaponToPed(chasePed, Config.weapon1, 250, false, true)
					GiveWeaponToPed(chasePed2, Config.weapon2, 250, false, true)
					GiveWeaponToPed(chasePed3, Config.weapon3, 250, false, true)
					GiveWeaponToPed(chasePed4, Config.weapon4, 250, false, true)
					cooldowncool(5000)
				end
			end)

			RageUI.ButtonWithStyle("Attaque le joueur le plus proche",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Selected then 
					closestPlayer = ESX.Game.GetClosestPlayer()
					target = GetPlayerPed(closestPlayer)
					TaskShootAtEntity(chasePed, target, 60, 0xD6FF6D61);
					TaskCombatPed(chasePed, target, 0, 16)
					SetEntityAsMissionEntity(chasePed, true, true)
					SetPedHearingRange(chasePed, 15.0)
					SetPedSeeingRange(chasePed, 15.0)
					SetPedAlertness(chasePed, 15.0)
					SetPedFleeAttributes(chasePed, 0, 0)
					SetPedCombatAttributes(chasePed, 46, true)
					SetPedFleeAttributes(chasePed, 0, 0)
					TaskShootAtEntity(chasePed2, target, 60, 0xD6FF6D61);
					TaskCombatPed(chasePed2, target, 0, 16)
					SetEntityAsMissionEntity(chasePed2, true, true)
					SetPedHearingRange(chasePed2, 15.0)
					SetPedSeeingRange(chasePed2, 15.0)
					SetPedAlertness(chasePed2, 15.0)
					SetPedFleeAttributes(chasePed2, 0, 0)
					SetPedCombatAttributes(chasePed2, 46, true)
					SetPedFleeAttributes(chasePed2, 0, 0) 
					TaskShootAtEntity(chasePed3, target, 60, 0xD6FF6D61);
					TaskCombatPed(chasePed3, target, 0, 16)
					SetEntityAsMissionEntity(chasePed3, true, true)
					SetPedHearingRange(chasePed3, 15.0)
					SetPedSeeingRange(chasePed3, 15.0)
					SetPedAlertness(chasePed3, 15.0)
					SetPedFleeAttributes(chasePed3, 0, 0)
					SetPedCombatAttributes(chasePed3, 46, true)
					SetPedFleeAttributes(chasePed3, 0, 0)  
					TaskShootAtEntity(chasePed4, target, 60, 0xD6FF6D61);
					TaskCombatPed(chasePed4, target, 0, 16)
					SetEntityAsMissionEntity(chasePed4, true, true)
					SetPedHearingRange(chasePed4, 15.0)
					SetPedSeeingRange(chasePed4, 15.0)
					SetPedAlertness(chasePed4, 15.0)
					SetPedFleeAttributes(chasePed4, 0, 0)
					SetPedCombatAttributes(chasePed4, 46, true)
					SetPedFleeAttributes(chasePed4, 0, 0)
					cooldowncool(5000)
			end
		end)

			RageUI.ButtonWithStyle("Suivez-moi",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Selected then 
					local playerPed = PlayerPedId()
					TaskVehicleFollow(chasePed, chaseVehicle, playerPed, 50.0, 1, 5)
					TaskVehicleFollow(chasePed2, chaseVehicle2, playerPed, 50.0, 1, 5)
					TaskVehicleFollow(chasePed3, chaseVehicle3, playerPed, 50.0, 1, 5)
					TaskVehicleFollow(chasePed4, chaseVehicle4, playerPed, 50.0, 1, 5)
					TaskVehicleFollow(chasePed5, chaseVehicle5, playerPed, 50.0, 1, 5)
					PlayAmbientSpeech1(chasePed, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
					PlayAmbientSpeech1(chasePed2, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
					PlayAmbientSpeech1(chasePed3, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
					PlayAmbientSpeech1(chasePed4, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
					PlayAmbientSpeech1(chasePed5, "Chat_Resp", "SPEECH_PARAMS_FORCE", 1)
					cooldowncool(5000)
			end
		end)

			RageUI.ButtonWithStyle("Supprimer",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
				if Selected then 
					local playerPed = PlayerPedId()
					DeleteVehicle(chaseVehicle)
					DeletePed(chasePed)
					DeleteVehicle(chaseVehicle2)
					DeletePed(chasePed2)
					DeleteVehicle(chaseVehicle3)
					DeletePed(chasePed3)
					DeleteVehicle(chaseVehicle4)
					DeletePed(chasePed4)
					DeleteVehicle(chaseVehicle5)
					DeletePed(chasePed5)
					cooldowncool(5000)
			end
		end)
	

	end, function()
	end)


	RageUI.IsVisible(gestGAV, true, true, true, function()

		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		RageUI.ButtonWithStyle("Ajouter a la GAV",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					TriggerServerEvent("rxePolice:addPlayerInGAV", GetPlayerServerId(closestPlayer))
					ESX.TriggerServerCallback('rxePolice:getAllPlayerInGAV', function(result)
						playersInGAV = result
					end)
				else
					RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
				end
				cooldowncool(1000)
			end
		end)

		RageUI.ButtonWithStyle("Retirer de la GAV",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					TriggerServerEvent("rxePolice:removePlayerInGAV", GetPlayerServerId(closestPlayer))
					ESX.TriggerServerCallback('rxePolice:getAllPlayerInGAV', function(result)
						playersInGAV = result
					end)
				else
					RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
				end
				cooldowncool(1000)
			end
		end)

		RageUI.Separator("~b~Moi")

		RageUI.ButtonWithStyle("Ajouter a la GAV",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				TriggerServerEvent("rxePolice:addPlayerInGAV", GetPlayerServerId(PlayerId()))
				ESX.TriggerServerCallback('rxePolice:getAllPlayerInGAV', function(result)
					playersInGAV = result
				end)
				cooldowncool(1000)
			end
		end)

		RageUI.ButtonWithStyle("Retirer de la GAV",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
			if Selected then
				TriggerServerEvent("rxePolice:removePlayerInGAV", GetPlayerServerId(PlayerId()))
				ESX.TriggerServerCallback('rxePolice:getAllPlayerInGAV', function(result)
					playersInGAV = result
				end)
				cooldowncool(1000)
			end
		end)
	
		RageUI.Separator("")
		RageUI.Separator("~b~"..#playersInGAV.." joueurs dans la GAV")
		RageUI.Separator("")

	end, function()
	end)


	if not RageUI.Visible(mf6p) and not RageUI.Visible(inter) and not RageUI.Visible(info) and not RageUI.Visible(renfort) and not RageUI.Visible(chien) and not RageUI.Visible(voiture) and not RageUI.Visible(megaphone) and not RageUI.Visible(gererlicenses) and not RageUI.Visible(lspd_main) and not RageUI.Visible(lspd_adrcheck) and not RageUI.Visible(lspd_adr) and not RageUI.Visible(lspd_adrlaunch) and not RageUI.Visible(fouiller) and not RageUI.Visible(verif) and not RageUI.Visible(gestGAV) and not RageUI.Visible(objets) and not RageUI.Visible(PropsMenu) and not RageUI.Visible(PropsMenuobject) and not RageUI.Visible(PropsMenuobjectlist)  and not RageUI.Visible(Gestinter) then
		mf6p = RMenu:DeleteType(mf6p, true)
	end
end
end

Keys.Register('F6', 'Police', 'Ouvrir le menu Police', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
    	Menuf6Police()
	end
end)


RegisterNetEvent('renfort:setBlip')
AddEventHandler('renfort:setBlip', function(coords, raison)
	if raison == 'petit' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Demande de renfort', '<C>Demande de renfort demandé.\nRéponse: ~g~CODE-2\n~w~Importance: ~g~Légère.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
		color = 2
	elseif raison == 'importante' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Demande de renfort', '<C>Demande de renfort demandé.\nRéponse: ~g~CODE-3\n~w~Importance: ~o~Importante.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
		color = 47
	elseif raison == 'omgad' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
		PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Demande de renfort', '<C>Demande de renfort demandé.\nRéponse: ~g~CODE-99\n~w~Importance: ~r~URGENTE !\nDANGER IMPORTANT', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
		PlaySoundFrontend(-1, "FocusOut", "HintCamSounds", 1)
		color = 1
	end
	local blipId = AddBlipForCoord(coords)
	SetBlipSprite(blipId, 161)
	SetBlipScale(blipId, 1.2)
	SetBlipColour(blipId, color)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Demande renfort')
	EndTextCommandSetBlipName(blipId)
	Wait(80 * 1000)
	RemoveBlip(blipId)
end)

RegisterNetEvent('police:InfoService')
AddEventHandler('police:InfoService', function(service, name)
	if service == 'prise' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Prise de service', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-8\n~w~Information: ~g~Prise de service.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'fin' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Fin de service', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-10\n~w~Information: ~g~Fin de service.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'pause' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Pause de service', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-6\n~w~Information: ~g~Pause de service.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'standby' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Mise en standby', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-12\n~w~Information: ~g~Standby, en attente de dispatch.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'control' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Control routier', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-48\n~w~Information: ~g~Control routier en cours.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'refus' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Refus d\'obtemperer', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-30\n~w~Information: ~g~Refus d\'obtemperer / Delit de fuite en cours.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	elseif service == 'crime' then
		PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
		ESX.ShowAdvancedNotification('<C>Central LSPD', '~b~<C>Crime en cours', '<C>Agent: ~g~'..name..'\n~w~Code: ~g~10-31\n~w~Information: ~g~Crime en cours / poursuite en cours.', 'CHAR_CALL911', 8)
		Wait(1000)
		PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
	end
end)

RegisterNetEvent('finalpolice:handcuff')
AddEventHandler('finalpolice:handcuff', function()

IsHandcuffed    = not IsHandcuffed;
local playerPed = GetPlayerPed(-1)

Citizen.CreateThread(function()

if IsHandcuffed then

	RequestAnimDict('mp_arresting')
	while not HasAnimDictLoaded('mp_arresting') do
		Citizen.Wait(100)
	end

	TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
	DisableControlAction(2, 37, true)
	SetEnableHandcuffs(playerPed, true)
	SetPedCanPlayGestureAnims(playerPed, false)
	FreezeEntityPosition(playerPed,  true)
	DisableControlAction(0, 24, true) -- Attack
	DisableControlAction(0, 257, true) -- Attack 2
	DisableControlAction(0, 25, true) -- Aim
	DisableControlAction(0, 263, true) -- Melee Attack 1
	DisableControlAction(0, 37, true) -- Select Weapon
	DisableControlAction(0, 47, true)  -- Disable weapon
	DisplayRadar(false)

else

	ClearPedSecondaryTask(playerPed)
	SetEnableHandcuffs(playerPed, false)
	SetPedCanPlayGestureAnims(playerPed,  true)
	FreezeEntityPosition(playerPed, false)
	DisplayRadar(true)

end

  end)
end)

RegisterNetEvent('finalpolice:drag')
AddEventHandler('finalpolice:drag', function(cop)
  IsDragged = not IsDragged
  CopPed = tonumber(cop)
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('finalpolice:putInVehicle')
AddEventHandler('finalpolice:putInVehicle', function()
  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)
  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)
    if DoesEntityExist(vehicle) then
      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil
      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end
      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end
    end
  end
end)

RegisterNetEvent('finalpolice:OutVehicle')
AddEventHandler('finalpolice:OutVehicle', function(t)
  local ped = GetPlayerPed(t)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

-- Handcuff
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 30,  true) -- MoveLeftRight
      DisableControlAction(0, 31,  true) -- MoveUpDown
    end
  end
end)


function notNilString(str)
    if str == nil then
        return ""
    else
        return str
    end
end

function spawnObject(name)
	local plyPed = PlayerPedId()
	local coords = GetEntityCoords(plyPed, false) + (GetEntityForwardVector(plyPed) * 1.0)

	ESX.Game.SpawnObject(name, coords, function(obj)
		SetEntityHeading(obj, GetEntityPhysicsHeading(plyPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end

local shieldActive = false
local shieldEntity = nil

-- ANIM
local animDict = "combat@gestures@gang@pistol_1h@beckon"
local animName = "0"

local prop = "prop_ballistic_shield"

function EnableShield()
    shieldActive = true
    local ped = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(ped, false)
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(250)
    end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

    RequestModel(GetHashKey(prop))
    while not HasModelLoaded(GetHashKey(prop)) do
        Citizen.Wait(250)
    end

    local shield = CreateObject(GetHashKey(prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
    shieldEntity = shield
    AttachEntityToEntity(shieldEntity, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))
    SetEnableHandcuffs(ped, true)
end

function DisableShield()
    local ped = GetPlayerPed(-1)
    DeleteEntity(shieldEntity)
    ClearPedTasksImmediately(ped)
    SetWeaponAnimationOverride(ped, GetHashKey("Default"))
    SetEnableHandcuffs(ped, false)
    shieldActive = false
end

Citizen.CreateThread(function()
    while true do
        if shieldActive then
            local ped = GetPlayerPed(-1)
            if not IsEntityPlayingAnim(ped, animDict, animName, 1) then
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
        end
        Citizen.Wait(500)
    end
end)


----- Soutien Police

function SpawnVehicle1()
	local playerPed = PlayerPedId()
	local PedPosition = GetEntityCoords(playerPed)
	hashKey = GetHashKey(Config.ped1)
	pedType = GetPedType(hashKey)
	RequestModel(hashKey)
	while not HasModelLoaded(hashKey) do
	  RequestModel(hashKey)
	  Citizen.Wait(100)
	end
	chasePed = CreatePed(pedType, hashKey, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
	ESX.Game.SpawnVehicle(Config.vehicle1, {
	  x = PedPosition.x + 10 ,
	  y = PedPosition.y,
	  z = PedPosition.z
	},120, function(callback_vehicle)
	  chaseVehicle = callback_vehicle
	  local vehicle = GetVehiclePedIsIn(PlayerPed, true)
	  SetVehicleUndriveable(chaseVehicle, false)
	  SetVehicleEngineOn(chaseVehicle, true, true)
	  while not chasePed do Citizen.Wait(100) end;
	  PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
	  TaskWarpPedIntoVehicle(chasePed, chaseVehicle, -1)
	  TaskVehicleFollow(chasePed, chaseVehicle, playerPed, 50.0, 1, 5)
	  SetDriveTaskDrivingStyle(chasePed, 786468)
	  SetVehicleSiren(chaseVehicle, true)
	end)
end

function SpawnVehicle2()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey2 = GetHashKey(Config.ped2)
pedType2 = GetPedType(hashKey)
RequestModel(hashKey2)
while not HasModelLoaded(hashKey2) do
    RequestModel(hashKey2)
    Citizen.Wait(100)
end
chasePed2 = CreatePed(pedType2, hashKey2, PedPosition.x + 4,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(Config.vehicle2, {
    x = PedPosition.x + 15 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle2)
    chaseVehicle2 = callback_vehicle2
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle2, false)
    SetVehicleEngineOn(chaseVehicle2, true, true)
    while not chasePed2 do Citizen.Wait(100) end;
    while not chaseVehicle2 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed2, chaseVehicle2, -1)
    TaskVehicleFollow(chasePed2, chaseVehicle2, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed2, 786468)
    SetVehicleSiren(chaseVehicle2, true)
end)
end

function SpawnVehicle3()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey3 = GetHashKey(Config.ped3)
pedType3 = GetPedType(hashKey)
RequestModel(hashKey3)
while not HasModelLoaded(hashKey3) do
    RequestModel(hashKey3)
    Citizen.Wait(100)
end
chasePed3 = CreatePed(pedType3, hashKey3, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(Config.vehicle3, {
    x = PedPosition.x + 10 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle3)
    chaseVehicle3 = callback_vehicle3
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle3, false)
    SetVehicleEngineOn(chaseVehicle3, true, true)
    while not chasePed3 do Citizen.Wait(100) end;
    while not chaseVehicle3 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed3, chaseVehicle3, -1)
    TaskVehicleFollow(chasePed3, chaseVehicle3, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed3, 786468)
    SetVehicleSiren(chaseVehicle3, true)
end)
end

function SpawnVehicle4()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey4 = GetHashKey(Config.ped4)
pedType4 = GetPedType(hashKey)
RequestModel(hashKey4)
while not HasModelLoaded(hashKey4) do
    RequestModel(hashKey4)
    Citizen.Wait(100)
end
chasePed4 = CreatePed(pedType4, hashKey4, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(Config.vehicle4, {
    x = PedPosition.x + 10 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle4)
    chaseVehicle4 = callback_vehicle4
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle4, false)
    SetVehicleEngineOn(chaseVehicle4, true, true)
    while not chasePed4 do Citizen.Wait(100) end;
    while not chaseVehicle4 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed4, chaseVehicle4, -1)
    TaskVehicleFollow(chasePed4, chaseVehicle4, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed4, 786468)
    SetVehicleSiren(chaseVehicle4, true)
end)
end

function SpawnVehicle5()
local playerPed = PlayerPedId()
local PedPosition = GetEntityCoords(playerPed)
hashKey5 = GetHashKey(Config.ped5)
pedType5 = GetPedType(hashKey)
RequestModel(hashKey5)
while not HasModelLoaded(hashKey5) do
    RequestModel(hashKey5)
    Citizen.Wait(100)
end
chasePed5 = CreatePed(pedType5, hashKey5, PedPosition.x + 2,  PedPosition.y,  PedPosition.z, 250.00, 1, 1)
ESX.Game.SpawnVehicle(Config.vehicle5, {
    x = PedPosition.x + 10 ,
    y = PedPosition.y,
    z = PedPosition.z
},120, function(callback_vehicle5)
    chaseVehicle5 = callback_vehicle5
    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
    SetVehicleUndriveable(chaseVehicle5, false)
    SetVehicleEngineOn(chaseVehicle5, true, true)
    while not chasePed5 do Citizen.Wait(100) end;
    while not chaseVehicle5 do Citizen.Wait(100) end;
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    TaskWarpPedIntoVehicle(chasePed5, chaseVehicle5, freeSeat)
    TaskVehicleFollow(chasePed5, chaseVehicle5, playerPed, 50.0, 1, 5)
    SetDriveTaskDrivingStyle(chasePed5, 786468)
    SetVehicleSiren(chaseVehicle5, false)
end)
end


loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end


function OpenVehicleInfosMenu(vehicleData)
	ESX.TriggerServerCallback('finalpolice:getVehicleInfos', function(retrivedInfo)
		local elements = {{label = ("Plaque" ..retrivedInfo.plate)}}

		if retrivedInfo.owner == nil then
			table.insert(elements, {label = ('Propriétaire inconnu')})
		else
			table.insert(elements, {label = ("Propriétaire" ..retrivedInfo.owner)})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
			css      = 'police',
			title    = ('Info véhicule'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, vehicleData.plate)
end

function LookupVehicle()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle', {
		title = ('Entrer le nom dans la base de données'),
	}, function(data, menu)
		local length = string.len(data.value)
		if not data.value or length < 2 or length > 8 then
			RageUI.Popup({message = "<C>~r~Une erreur c'est produite"})
		else
			ESX.TriggerServerCallback('finalpolice:getVehicleInfos', function(retrivedInfo)
				local elements = {{label = ("Plaque: " ..retrivedInfo.plate)}}
				menu.close()

				if not retrivedInfo.owner then
					table.insert(elements, {label = ('Propriétaire inconnu')})
				else
					table.insert(elements, {label = ("Propriétaire: " ..retrivedInfo.owner)})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
					title    = ('Info véhicule'),
					align    = 'top-left',
					elements = elements
				}, nil, function(data2, menu2)
					menu2.close()
				end)
			end, data.value)

		end
	end, function(data, menu)
		menu.close()
	end)
end
