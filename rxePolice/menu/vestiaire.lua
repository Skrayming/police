ESX = nil
local allCasier = {}
local allContentCasier = {}
local allWeaponInCasier = {}
local allItemsInCasier = {}

local allContentCasier2 = {}
local allWeaponInCasier2 = {}
local allItemsInCasier2 = {}

local ifHaveCasier = false
local identifierSelected = nil
local nameSelected = nil

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

function CloackRoomPolice()
	local ckr = RageUI.CreateMenu("L.S.P.D", "Los Santos Police Departement")
	local moncasier = RageUI.CreateSubMenu(ckr, "Casier", "Los Santos Police Departement")
    local moncasiersub = RageUI.CreateSubMenu(moncasier, "Casier", "Los Santos Police Departement")
    local moncasiersub2 = RageUI.CreateSubMenu(moncasier, "Casier", "Los Santos Police Departement")
	local depotobj = RageUI.CreateSubMenu(moncasier, "Casier", "Los Santos Police Departement")
	ckr:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	moncasier:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    moncasiersub:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    moncasiersub2:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	depotobj:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)

	RageUI.Visible(ckr, not RageUI.Visible(ckr))
	while ckr do
		Citizen.Wait(0)
			RageUI.IsVisible(ckr, true, true, true, function()

					RageUI.ButtonWithStyle("Casier de rangement", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            ESX.TriggerServerCallback('rxePolice:getIfHaveCasier', function(result)
                                ifHaveCasier = result
                            end)
                        end
					end, moncasier)

					RageUI.Separator("~o~"..GetPlayerName(PlayerId()).. "~w~ - ~o~" ..ESX.PlayerData.job.grade_label.. "")

						for index,infos in pairs(police.clothes.specials) do
							RageUI.ButtonWithStyle(infos.label,nil, {RightBadge = RageUI.BadgeStyle.Clothes}, ESX.PlayerData.job.grade >= infos.minimum_grade, function(_,_,s)
								if s then
									ApplySkin(infos)
								end
							end)
						end

                        RageUI.Separator("~o~Gestion G.P.B")

						for index,infos in pairs(police.clothes.grades) do
							RageUI.ButtonWithStyle(infos.label,nil, {RightBadge = RageUI.BadgeStyle.Clothes}, ESX.PlayerData.job.grade >= infos.minimum_grade, function(_,_,s)
							if s then
								ApplySkin(infos)
								SetPedArmour(PlayerPedId(), 100)
							end
						end)
					end
				
				end, function() 
				end)

				RageUI.IsVisible(moncasier, true, true, true, function()

                    RageUI.ButtonWithStyle("Accéder à mon casier", nil, {RightLabel = "→→"}, ifHaveCasier, function(Hovered, Active, Selected)
                        if (Selected) then
                            getAllContentCasier()
                        end
                    end, moncasiersub)

                    RageUI.Separator("~o~Casier de rangement")

                    for k,v in pairs(allCasier) do
                    for id,_ in pairs(json.decode(v.guest)) do
                        if id == ESX.PlayerData.identifier then
                        RageUI.ButtonWithStyle(v.name, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                getAllContentCasierNotOwner(v.owner)
                                identifierSelected = v.owner
                                nameSelected = v.name
                            end
                        end, moncasiersub2)
                    else
                        RageUI.ButtonWithStyle(v.name, nil, {RightLabel = ""}, false, function(Hovered, Active, Selected)
                        end)
                    end
                    end
                    end

                end, function()
                end)


                RageUI.IsVisible(moncasiersub, true, true, true, function()

                for k,v in pairs(allContentCasier) do
                    if v.type == "blackmoney" then
                    RageUI.Separator("~r~Argent sale : "..v.amount)
                    elseif v.type == "cash" then
                    RageUI.Separator("~g~Argent : "..v.amount)
                    end
                end

                RageUI.Separator("~o~Gestion argent")

                RageUI.ButtonWithStyle("Ajouter argent", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local amount = KeyboardInput("Montant", "", 10)
                        if amount ~= nil then
                            TriggerServerEvent('rxePolice:addMoneyToCasier', tonumber(amount))
                            Citizen.Wait(500)
                            getAllContentCasier()
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Retirer argent", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local amount = KeyboardInput("Montant", "", 10)
                        if amount ~= nil then
                            TriggerServerEvent('rxePolice:removeMoneyFromCasier', tonumber(amount))
                            Citizen.Wait(500)
                            getAllContentCasier()
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Ajouter argent sale", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local amount = KeyboardInput("Montant", "", 10)
                        if amount ~= nil then
                            TriggerServerEvent('rxePolice:addBlackMoneyToCasier', tonumber(amount))
                            Citizen.Wait(500)
                            getAllContentCasier()
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Retirer argent sale", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local amount = KeyboardInput("Montant", "", 10)
                        if amount ~= nil then
                            TriggerServerEvent('rxePolice:removeBlackMoneyFromCasier', tonumber(amount))
                            Citizen.Wait(500)
                            getAllContentCasier()
                        end
                    end
                end)


                RageUI.Separator("~o~Gestion des objets")
                

                RageUI.ButtonWithStyle("Déposer objet(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        menuDepoItems()
                    end
                end)

                RageUI.ButtonWithStyle("Retirer objet(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        menuRetraitItems()
                    end
                end)

                RageUI.Separator("~o~Gestion des armes")

                RageUI.ButtonWithStyle("Déposer arme(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        menuDepoWeapons()
                    end
                end)

                RageUI.ButtonWithStyle("Retirer arme(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        menuRetraitWeapons()
                    end
                end)



                RageUI.Separator("~o~Gestion casier de rangement")

                RageUI.ButtonWithStyle("Ajouter quelqu'un au casier", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent("rxePolice:addPlayerToCasier", GetPlayerServerId(closestPlayer))
                        else
                            RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Retirer quelqu'un du casier", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestPlayer ~= -1 and closestDistance <= 3.0 then
                            TriggerServerEvent("rxePolice:removePlayerFromCasier", GetPlayerServerId(closestPlayer))
                        else
                            RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Vider le casier", "Retirer tout le monde du casier", {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent("rxePolice:clearCasier")
                    end
                end)

                end, function()
                end)

                RageUI.IsVisible(moncasiersub2, true, true, true, function()

                    RageUI.Separator("~o~Casier de "..nameSelected)

                    RageUI.Line()

                    for k,v in pairs(allContentCasier2) do
                        if v.type == "blackmoney" then
                        RageUI.Separator("~r~Argent sale : "..v.amount)
                        elseif v.type == "cash" then
                        RageUI.Separator("~g~Argent : "..v.amount)
                        end
                    end
    
                    RageUI.Separator("~o~Gestion argent")
    
                    RageUI.ButtonWithStyle("Ajouter argent", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local amount = KeyboardInput("Montant", "", 10)
                            if amount ~= nil then
                                TriggerServerEvent('rxePolice:addMoneyToCasier2', tonumber(amount), identifierSelected)
                                Citizen.Wait(500)
                                getAllContentCasierNotOwner(identifierSelected)
                            end
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Retirer argent", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local amount = KeyboardInput("Montant", "", 10)
                            if amount ~= nil then
                                TriggerServerEvent('rxePolice:removeMoneyFromCasier2', tonumber(amount), identifierSelected)
                                Citizen.Wait(500)
                                getAllContentCasierNotOwner(identifierSelected)
                            end
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Ajouter argent sale", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local amount = KeyboardInput("Montant", "", 10)
                            if amount ~= nil then
                                TriggerServerEvent('rxePolice:addBlackMoneyToCasier2', tonumber(amount), identifierSelected)
                                Citizen.Wait(500)
                                getAllContentCasierNotOwner(identifierSelected)
                            end
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Retirer argent sale", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local amount = KeyboardInput("Montant", "", 10)
                            if amount ~= nil then
                                TriggerServerEvent('rxePolice:removeBlackMoneyFromCasier2', tonumber(amount), identifierSelected)
                                Citizen.Wait(500)
                                getAllContentCasierNotOwner(identifierSelected)
                            end
                        end
                    end)
    
    
                    RageUI.Separator("~o~Gestion des objets")
                    
    
                    RageUI.ButtonWithStyle("Déposer objet(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            menuDepoItems2()
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Retirer objet(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            menuRetraitItems2()
                        end
                    end)
    
                    RageUI.Separator("~o~Gestion des armes")
    
                    RageUI.ButtonWithStyle("Déposer arme(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            menuDepoWeapons2()
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Retirer arme(s)", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            menuRetraitWeapons2()
                        end
                    end)
    
                    end, function()
                    end)


            if not RageUI.Visible(ckr) and not RageUI.Visible(moncasier) and not RageUI.Visible(moncasiersub) and not RageUI.Visible(moncasiersub2) then
            ckr = RMenu:DeleteType("ckr", true)
		end
	end
end



Citizen.CreateThread(function()
    while true do
        local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointVestiaire then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.vestiaire.position.x, Config.pos.vestiaire.position.y, Config.pos.vestiaire.position.z)
        if dist3 <= Config.Marker.drawdistance then
            Timer = 0
			DrawMarker(Config.Marker.type, Config.pos.vestiaire.position.x, Config.pos.vestiaire.position.y, Config.pos.vestiaire.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
		end
        if dist3 <= 2.0 then
            Timer = 0   
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Vestiaire", time_display = 1 })
                    if IsControlJustPressed(1,51) then
                        getAllCasier()
                        CloackRoomPolice()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

function ApplySkin(infos)
	TriggerEvent('skinchanger:getSkin', function(skin)
		local uniformObject

		if skin.sex == 0 then
			uniformObject = infos.variations.male
		else
			uniformObject = infos.variations.female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
		end

		infos.onEquip()
	end)
end


function getAllCasier()
    ESX.TriggerServerCallback('rxePolice:getAllCasier', function(all)
        allCasier = all
    end)
end


function getAllContentCasier()
    ESX.TriggerServerCallback('rxePolice:getAllContentCasier', function(all)
        allContentCasier = all
    end)
    ESX.TriggerServerCallback('rxePolice:getAllWeaponInCasier', function(weapons)
        allWeaponInCasier = weapons
    end)
    ESX.TriggerServerCallback('rxePolice:getAllItemsInCasier', function(items)
        allItemsInCasier = items
    end)
end

function getAllContentCasierNotOwner(identifier)
    ESX.TriggerServerCallback('rxePolice:getAllContentCasier2', function(all)
        allContentCasier2 = all
    end, identifier)
    ESX.TriggerServerCallback('rxePolice:getAllWeaponInCasier2', function(weapons)
        allWeaponInCasier2 = weapons
    end, identifier)
    ESX.TriggerServerCallback('rxePolice:getAllItemsInCasier2', function(items)
        allItemsInCasier2 = items
    end, identifier)
end


function menuDepoItems()
    local StockPlayer = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockPlayer:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    ESX.TriggerServerCallback('fpolice:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                    RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                        if Selected then
                                            local count = KeyboardInput("Combien ?", '' , 8)
                                            TriggerServerEvent('rxePolice:addItemToCasier', item.name, tonumber(count))
                                            RageUI.CloseAll()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Casier", true)
            end
        end
    end)
end


function menuRetraitItems()
    local StockCasier = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockCasier:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(StockCasier, not RageUI.Visible(StockCasier))
        while StockCasier do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCasier, true, true, true, function()
                        for k,v in pairs(allItemsInCasier) do 
                            if v.amount > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.amount}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", "", 2)
                                    TriggerServerEvent('rxePolice:removeItemFromCasier', v.name, tonumber(count))
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCasier) then
            StockCasier = RMenu:DeleteType("Casier", true)
        end
    end
end


function menuDepoWeapons()
    local StockPlayerWeapon = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockPlayerWeapon:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
        RageUI.Visible(StockPlayerWeapon, not RageUI.Visible(StockPlayerWeapon))
    while StockPlayerWeapon do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayerWeapon, true, true, true, function()
                
                local weaponList = ESX.GetWeaponList()

                for i=1, #weaponList, 1 do
                    local weaponHash = GetHashKey(weaponList[i].name)
                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                    RageUI.ButtonWithStyle("~r~→~s~ "..weaponList[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('rxePolice:addWeaponToCasier', weaponList[i].name, 1)
                            RageUI.CloseAll()
                        end
                    end)
            end
            end
            end, function()
            end)
                if not RageUI.Visible(StockPlayerWeapon) then
                StockPlayerWeapon = RMenu:DeleteType("Casier", true)
            end
        end
end


function menuRetraitWeapons()
    local StockWeaponCasier = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockWeaponCasier:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(StockWeaponCasier, not RageUI.Visible(StockWeaponCasier))
        while StockWeaponCasier do
            Citizen.Wait(0)
                RageUI.IsVisible(StockWeaponCasier, true, true, true, function()
                        for k,v in pairs(allWeaponInCasier) do 
                            if v.amount > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.amount}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", "", 2)
                                    TriggerServerEvent('rxePolice:removeWeaponFromCasier', v.name, tonumber(count))
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockWeaponCasier) then
            StockWeaponCasier = RMenu:DeleteType("Casier", true)
        end
    end
end




function menuDepoItems2()
    local StockPlayer = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockPlayer:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    ESX.TriggerServerCallback('fpolice:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                    RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                        if Selected then
                                            local count = KeyboardInput("Combien ?", '' , 8)
                                            TriggerServerEvent('rxePolice:addItemToCasier2', item.name, tonumber(count), identifierSelected)
                                            RageUI.CloseAll()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Casier", true)
            end
        end
    end)
end


function menuRetraitItems2()
    local StockCasier = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockCasier:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(StockCasier, not RageUI.Visible(StockCasier))
        while StockCasier do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCasier, true, true, true, function()
                        for k,v in pairs(allItemsInCasier) do 
                            if v.amount > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.amount}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", "", 2)
                                    TriggerServerEvent('rxePolice:removeItemFromCasier2', v.name, tonumber(count), identifierSelected)
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCasier) then
            StockCasier = RMenu:DeleteType("Casier", true)
        end
    end
end


function menuDepoWeapons2()
    local StockPlayerWeapon = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockPlayerWeapon:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
        RageUI.Visible(StockPlayerWeapon, not RageUI.Visible(StockPlayerWeapon))
    while StockPlayerWeapon do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayerWeapon, true, true, true, function()
                
                local weaponList = ESX.GetWeaponList()

                for i=1, #weaponList, 1 do
                    local weaponHash = GetHashKey(weaponList[i].name)
                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                    RageUI.ButtonWithStyle("~r~→~s~ "..weaponList[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('rxePolice:addWeaponToCasier2', weaponList[i].name, 1, identifierSelected)
                            RageUI.CloseAll()
                        end
                    end)
            end
            end
            end, function()
            end)
                if not RageUI.Visible(StockPlayerWeapon) then
                StockPlayerWeapon = RMenu:DeleteType("Casier", true)
            end
        end
end


function menuRetraitWeapons2()
    local StockWeaponCasier = RageUI.CreateMenu("Casier", "Los Santos Police Departement")
    StockWeaponCasier:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(StockWeaponCasier, not RageUI.Visible(StockWeaponCasier))
        while StockWeaponCasier do
            Citizen.Wait(0)
                RageUI.IsVisible(StockWeaponCasier, true, true, true, function()
                        for k,v in pairs(allWeaponInCasier2) do 
                            if v.amount > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.amount}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", "", 2)
                                    TriggerServerEvent('rxePolice:removeWeaponFromCasier2', v.name, tonumber(count), identifierSelected)
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockWeaponCasier) then
            StockWeaponCasier = RMenu:DeleteType("Casier", true)
        end
    end
end