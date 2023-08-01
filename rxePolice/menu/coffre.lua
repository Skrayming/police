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

function Coffrepolice()
    local Cpolice = RageUI.CreateMenu("Coffre", "Los Santos Police Departement")
    Cpolice:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
        RageUI.Visible(Cpolice, not RageUI.Visible(Cpolice))
            while Cpolice do
            Citizen.Wait(0)
            RageUI.IsVisible(Cpolice, true, true, true, function()

                RageUI.Separator("↓ ~b~Objet(s)~s~ ↓")

                if  ESX.PlayerData.job.grade >= Config.GradeRetrait then
                    RageUI.ButtonWithStyle("Retirer Objet(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            FRetirerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                end
                    

                if ESX.PlayerData.job.grade >= Config.GradeDepot then
                    RageUI.ButtonWithStyle("Déposer Objet(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            ADeposerobjet()
                            RageUI.CloseAll()
                        end
                    end)
                end

					RageUI.Separator("↓ ~b~Arme(s)~s~ ↓")

                   if ESX.PlayerData.job.grade >= Config.GradeRetrait then

                    RageUI.ButtonWithStyle("Prendre Arme(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            PCoffreRetirerWeapon()
                            RageUI.CloseAll()
                        end
                    end)

                end
                    
                if ESX.PlayerData.job.grade >= Config.GradeDepot then
                    RageUI.ButtonWithStyle("Déposer Arme(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            PCoffreDeposerWeapon()
                            RageUI.CloseAll()
                        end
                    end)
                end

                end, function()
                end)

            if not RageUI.Visible(Cpolice) then
            Cpolice = RMenu:DeleteType("Coffre", true)
        end
    end
end

Citizen.CreateThread(function()
	while true do
		local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointCoffre then
		local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
		local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, Config.pos.coffre.position.x, Config.pos.coffre.position.y, Config.pos.coffre.position.z)
		if jobdist <= Config.Marker.drawdistance then
			Timer = 0
			DrawMarker(Config.Marker.type, Config.pos.coffre.position.x, Config.pos.coffre.position.y, Config.pos.coffre.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
		end
			if jobdist <= 1.0 then
				Timer = 0
					RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Coffre", time_display = 1 })
					if IsControlJustPressed(1,51) then
					Coffrepolice()
				end   
			end
		end 
	Citizen.Wait(Timer)   
end
end)

---------------------------------------------------------------------------------------------------------------------------------------

itemstock = {}
function FRetirerobjet()
    local Stockpolice = RageUI.CreateMenu("Coffre", "Los Santos Police Departement")
    Stockpolice:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    ESX.TriggerServerCallback('fpolice:getStockItems', function(items) 
    itemstock = items
   
    RageUI.Visible(Stockpolice, not RageUI.Visible(Stockpolice))
        while Stockpolice do
            Citizen.Wait(0)
                RageUI.IsVisible(Stockpolice, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = KeyboardInput("Combien ?", "", 2)
                                    TriggerServerEvent('fpolice:getStockItem', v.name, tonumber(count))
                                    FRetirerobjet()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(Stockpolice) then
            Stockpolice = RMenu:DeleteType("Coffre", true)
        end
    end
     end)
end

local PlayersItem = {}
function ADeposerobjet()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Los Santos Police Departement")
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
                                            TriggerServerEvent('fpolice:putStockItems', item.name, tonumber(count))
                                            ADeposerobjet()
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
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end


Weaponstock = {}
function PCoffreRetirerWeapon()
    local StockCoffreWeapon = RageUI.CreateMenu("Coffre", 'Los Santos Police Departement')
    StockCoffreWeapon:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    ESX.TriggerServerCallback('finalpolice:getArmoryWeapons', function(weapons)
    Weaponstock = weapons
    RageUI.Visible(StockCoffreWeapon, not RageUI.Visible(StockCoffreWeapon))
        while StockCoffreWeapon do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCoffreWeapon, true, true, true, function()
                        for k,v in pairs(Weaponstock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle("~r~→~s~ "..ESX.GetWeaponLabel(v.name), nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    ESX.TriggerServerCallback('finalpolice:removeArmoryWeapon', function()
                                        PCoffreRetirerWeapon()
                                    end, v.name)
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCoffreWeapon) then
            StockCoffreWeapon = RMenu:DeleteType("Coffre", true)
        end
    end
    end)
end

function PCoffreDeposerWeapon()
    local StockPlayerWeapon = RageUI.CreateMenu("Coffre", "Los Santos Police Departement")
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
                        --local cbDeposer = rGangBuilderKeyboardInput("Combien ?", '' , 15)
                        ESX.TriggerServerCallback('finalpolice:addArmoryWeapon', function()
                            PCoffreDeposerWeapon()
                        end, weaponList[i].name, true)
                    end
                end)
            end
            end
            end, function()
            end)
                if not RageUI.Visible(StockPlayerWeapon) then
                StockPlayerWeapon = RMenu:DeleteType("Coffre", true)
            end
        end
end

