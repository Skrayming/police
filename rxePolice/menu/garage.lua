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

-----------------------------------------------------------------------------------------------
---- Voiture ---------
-----------------------------------------------------------------------------------------------
local stockCar = {}

function GaragePolice()
    local gp = RageUI.CreateMenu("Garage", "Liste des voitures")
    gp:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(gp, not RageUI.Visible(gp))
    while gp do
        Citizen.Wait(0)
            RageUI.IsVisible(gp, true, true, true, function()

				RageUI.ButtonWithStyle("Ranger le véhicule dans le stock", nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                    if Selected then

                        local veh, dist4 = ESX.Game.GetClosestVehicle()
                        TriggerServerEvent("rxePolice:addVehInGarage", GetEntityModel(veh))
                        if dist4 < 4 then
                            DeleteEntity(veh)
                            RageUI.Popup({message = "<C>~b~- Stock LSPD\n~g~Rangement du véhicule. . ."})
                            TriggerServerEvent('ddx_vehiclelock:deletekeyjobs', 'no')
                            RageUI.CloseAll()
                        end

                    end
				end)
	
			for k,v in pairs(police.vehicles.car) do
				if v.category ~= nil then 
					RageUI.Separator(v.category)
				else
					RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "Stock(s): [~b~"..stockCar[GetHashKey(v.model)].."~s~]"}, ESX.PlayerData.job.grade >= v.minimum_grade, function(_,_,s)
						if s then
							if stockCar[GetHashKey(v.model)] > 0 then
                                SpawnVoiture(v.model)
                                TriggerServerEvent("rxePolice:removeVehInGarage", GetHashKey(v.model))
                                RageUI.Popup({message = "<C>~b~- Stock LSPD\n~g~"..v.label.." sortie du stock LSPD"})
                                RageUI.CloseAll()
							else 
                                RageUI.Popup({message = "<C>~b~"..v.label.."\n~r~Aucun stock"})
                                RageUI.CloseAll()
							end
						end
					end)
				end
			end

			end, function()    
			end)

		if not RageUI.Visible(gp) then
			gp = RMenu:DeleteType("gp", true)
		end
	end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointGarage then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.garagevoiture.position.x, Config.pos.garagevoiture.position.y, Config.pos.garagevoiture.position.z)
        if dist3 <= Config.Marker.drawdistance then
            Timer = 0
            DrawMarker(Config.Marker.type, Config.pos.garagevoiture.position.x, Config.pos.garagevoiture.position.y, Config.pos.garagevoiture.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
          end
        if dist3 <= 5.0 then 
                Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Garage (Voiture)", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            for k,v in pairs(police.vehicles.car) do
                            if v.category == nil then
                                ESX.TriggerServerCallback('rxePolice:getVehGarage', function(amount)
                                        stockCar[GetHashKey(v.model)] = amount
                                        GaragePolice()
                                end, GetHashKey(v.model))
                            end
                        end
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

function SpawnVoiture(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, Config.spawn.spawnvoiture.position.x, Config.spawn.spawnvoiture.position.y, Config.spawn.spawnvoiture.position.z, Config.spawn.spawnvoiture.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "LSPD"..math.random(1,15)
    SetVehicleNumberPlateText(vehicle, plaque) 
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
    SetVehicleMaxMods(vehicle)
    TriggerServerEvent('ddx_vehiclelock:givekey', 'no', GetVehicleNumberPlateText(vehicle))
end

-----------------------------------------------------------------------------------------------
---- Helico ---------
-----------------------------------------------------------------------------------------------

local stockHelico = {}

function GarageHeliPolice()
	local ghp = RageUI.CreateMenu("Garage", "Liste des hélicoptère")
    ghp:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
		RageUI.Visible(ghp, not RageUI.Visible(ghp))
			while ghp do
    			Citizen.Wait(0)
        			RageUI.IsVisible(ghp, true, true, true, function()
  
				RageUI.ButtonWithStyle("Ranger le véhicule dans le stock", nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                    if Selected then
                        local veh, dist4 = ESX.Game.GetClosestVehicle()
                        TriggerServerEvent("rxePolice:addVehInGarage", GetHashKey(GetDisplayNameFromVehicleModel(GetEntityModel(veh))))
                        if dist4 < 4 then
                            DeleteEntity(veh)
                            RageUI.Popup({message = "<C>~b~- Stock LSPD\n~g~Rangement du véhicule. . ."})
                            TriggerServerEvent('ddx_vehiclelock:deletekeyjobs', 'no')
                            RageUI.CloseAll()
                        end
                    end
				end)
                
                for k,v in pairs(police.vehicles.helico) do
                    if v.category ~= nil then 
                        RageUI.Separator(v.category)
                    else
                        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "Stock(s): [~b~"..stockHelico[GetHashKey(v.model)].."~s~]"}, ESX.PlayerData.job.grade >= v.minimum_grade, function(_,_,s)
                            if s then
                                if stockHelico[GetHashKey(v.model)] > 0 then
                                    SpawnHelico(v.model)
                                    TriggerServerEvent("rxePolice:removeVehInGarage", GetHashKey(v.model))
                                    RageUI.Popup({message = "<C>~b~- Stock LSPD\n~g~"..v.label.." sortie du stock LSPD"})
                                    RageUI.CloseAll()
                                else 
                                    RageUI.Popup({message = "<C>~b~"..v.label.."\n~r~Aucun stock"})
                                    RageUI.CloseAll()
                                end
                            end
                        end)
                    end
                end
              
                end, function()
                end)
   
		if not RageUI.Visible(ghp) then
			ghp = RMenu:DeleteType("ghp", true)
		end
	end
end
      
Citizen.CreateThread(function()
while true do
    local Timer = 800
    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointGarageHeli then
    local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
    local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.garageheli.position.x, Config.pos.garageheli.position.y, Config.pos.garageheli.position.z)
    if dist3 <= Config.Marker.drawdistance then
        Timer = 0
        DrawMarker(Config.Marker.type, Config.pos.garageheli.position.x, Config.pos.garageheli.position.y, Config.pos.garageheli.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
      end    
    if dist3 <= 2.0 then 
            Timer = 0
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Garage (Hélicoptère)", time_display = 1 })
                    if IsControlJustPressed(1,51) then
                        for k,v in pairs(police.vehicles.helico) do
                            if v.category == nil then
                                ESX.TriggerServerCallback('rxePolice:getVehGarage', function(amount)
                                    stockHelico[GetHashKey(v.model)] = amount
                                    GarageHeliPolice()
                                end, GetHashKey(v.model))
                            end
                        end
                end   
            end
        end 
        Citizen.Wait(Timer)
    end
end)

function SpawnHelico(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, Config.spawn.spawnheli.position.x, Config.spawn.spawnheli.position.y, Config.spawn.spawnheli.position.z, Config.spawn.spawnheli.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "LSPD"..math.random(1,15)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
    SetVehicleMaxMods(vehicle)
    TriggerServerEvent('ddx_vehiclelock:givekey', 'no', GetVehicleNumberPlateText(vehicle))
end

-----------------------------------------------------------------------------------------------
---- Bato ---------
-----------------------------------------------------------------------------------------------
local stockBato = {}

function BateauPolice()
    local batp = RageUI.CreateMenu("Garage", "Pour sortir des bateau de police.")
    batp:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(batp, not RageUI.Visible(batp))
    while batp do
        Citizen.Wait(0)
            RageUI.IsVisible(batp, true, true, true, function()

				RageUI.ButtonWithStyle("Ranger le véhicule dans le stock", nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                    if Selected then
                        local veh, dist4 = ESX.Game.GetClosestVehicle()
                        TriggerServerEvent("rxePolice:addVehInGarage", GetHashKey(GetDisplayNameFromVehicleModel(GetEntityModel(veh))))
                        if dist4 < 4 then
                            DeleteEntity(veh)
                            RageUI.Popup({message = "<C>~b~- Stock LSPD\n~g~Rangement du véhicule. . ."})
                            TriggerServerEvent('ddx_vehiclelock:deletekeyjobs', 'no')
                            RageUI.CloseAll()
                        end
                    end
				end)
                
                for k,v in pairs(police.vehicles.bateaux) do
                    if v.category ~= nil then 
                        RageUI.Separator(v.category)
                    else
                        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "Stock(s): [~b~"..stockBato[GetHashKey(v.model)].."~s~]"}, ESX.PlayerData.job.grade >= v.minimum_grade, function(_,_,s)
                            if s then
                                if stockBato[GetHashKey(v.model)] > 0 then
                                    SpawnBato(v.model)
                                    TriggerServerEvent("rxePolice:removeVehInGarage", GetHashKey(v.model))
                                    RageUI.Popup({message = "<C>~b~- Stock LSPD\n~g~"..v.label.." sortie du stock LSPD"})
                                    RageUI.CloseAll()
                                else 
                                    RageUI.Popup({message = "<C>~b~"..v.label.."\n~r~Aucun stock"})
                                    RageUI.CloseAll()
                                end
                            end
                        end)
                    end
                end

            
        end, function()
        end)
        if not RageUI.Visible(batp) then
            batp = RMenu:DeleteType("batp", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
    local Timer = 800
    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointGarageBateau then
    local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
    local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.garagebateau.position.x, Config.pos.garagebateau.position.y, Config.pos.garagebateau.position.z)
    if dist3 <= Config.Marker.drawdistance then
        Timer = 0
        DrawMarker(Config.Marker.type, Config.pos.garagebateau.position.x, Config.pos.garagebateau.position.y, Config.pos.garagebateau.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
        end        
    if dist3 <= 2.0 then 
            Timer = 0
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Garage (Bateau)", time_display = 1 })
                    if IsControlJustPressed(1,51) then
                        for k,v in pairs(police.vehicles.bateaux) do
                            if v.category == nil then
                                ESX.TriggerServerCallback('rxePolice:getVehGarage', function(amount)
                                    stockBato[GetHashKey(v.model)] = amount
                                    BateauPolice()
                                end, GetHashKey(v.model))
                            end
                        end
                end   
            end
        end 
        Citizen.Wait(Timer)
    end
end)

function SpawnBato(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local vehicle = CreateVehicle(car, Config.spawn.spawnbato.position.x, Config.spawn.spawnbato.position.y, Config.spawn.spawnbato.position.z, Config.spawn.spawnbato.position.h, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = "LSPD"..math.random(1,15)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1) 
    SetVehicleMaxMods(vehicle)
    TriggerServerEvent('ddx_vehiclelock:givekey', 'no', GetVehicleNumberPlateText(vehicle))
end

-----------------------------------------------------------------------------------------------
---- Extra ---------
-----------------------------------------------------------------------------------------------

function ExtraPolice()
    local mainextra = RageUI.CreateMenu("Extras", "Los Santos Police Departement")
    local subextra = RageUI.CreateSubMenu(mainextra, "Extras", "Los Santos Police Departement")
    local livery = RageUI.CreateSubMenu(mainextra, "Extras", "Los Santos Police Departement")
    mainextra:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    subextra:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    livery:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)

    RageUI.Visible(mainextra, not RageUI.Visible(mainextra))
    while mainextra do
        Citizen.Wait(0)

            RageUI.IsVisible(mainextra, true, true, true, function()

                RageUI.ButtonWithStyle("Extras & Liverys", nil, {}, true, function(_, _, s)
                end, livery)

                RageUI.ButtonWithStyle("Couleurs", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)  
                end, subextra)

                RageUI.ButtonWithStyle("Nettoyer le véhicule", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)  
                    if Selected then 
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                        SetVehicleDirtLevel(vehicle, 0)
                        RageUI.Popup({message = "<C>Véhicule nettoyer"})
                    end
                end)

            end, function()
            end)

            RageUI.IsVisible(livery, true, true, true, function()

                local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
                local liveryCount = GetVehicleLiveryCount(vehicle)

                RageUI.Separator("~r~Livery(s)")
        
                    for i = 1, liveryCount do
                        local state = GetVehicleLivery(vehicle) 
                        
                        if state == i then
                            RageUI.ButtonWithStyle("Livery: "..i, nil, {RightLabel = "~g~ON"}, true, function(Hovered, Active, Selected)
                                if (Selected) then   
                                    SetVehicleLivery(vehicle, i, not state)
                                end      
                            end)
                        else
                            RageUI.ButtonWithStyle("Livery: "..i, nil, {RightLabel = "~r~OFF"}, true, function(Hovered, Active, Selected)
                                if (Selected) then
                                    SetVehicleLivery(vehicle, i, state)
                                end      
                            end)
                        end
                    end

                RageUI.Separator("~b~Extra(s)")

                for id=0, 12 do
                        if DoesExtraExist(vehicle, id) then
                            local state2 = IsVehicleExtraTurnedOn(vehicle, id)
                        
                        if state2 then
                            RageUI.ButtonWithStyle("Extra: "..id, nil, {RightLabel = "~g~ON"}, true, function(Hovered, Active, Selected)
                                if (Selected) then   
                                    SetVehicleExtra(vehicle, id, state2)
                                end      
                            end)
                        else
                            RageUI.ButtonWithStyle("Extra: "..id, nil, {RightLabel = "~r~OFF"}, true, function(Hovered, Active, Selected)
                                if (Selected) then
                                    SetVehicleExtra(vehicle, id, state2)
                                end      
                            end)
                        end
                    end
                end

            end, function()
            end)

            RageUI.IsVisible(subextra, true, true, true, function()

                RageUI.ButtonWithStyle("Bleu", "Couleur bleu", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if (Selected) then   
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                    SetVehicleCustomPrimaryColour(vehicle, 0, 0, 255)
                    SetVehicleCustomSecondaryColour(vehicle, 0, 0, 255)
                    end      
                end)
                RageUI.ButtonWithStyle("Rouge", "Couleur rouge", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if (Selected) then   
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                        SetVehicleCustomPrimaryColour(vehicle, 255, 0, 0)
                        SetVehicleCustomSecondaryColour(vehicle, 255, 0, 0)
                    end      
                end)
                RageUI.ButtonWithStyle("Vert", "Couleur verte", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if (Selected) then   
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                    SetVehicleCustomPrimaryColour(vehicle, 0, 255, 0)
                    SetVehicleCustomSecondaryColour(vehicle, 0, 255, 0)
                    end      
                end)
                RageUI.ButtonWithStyle("Noir", "Couleur noir", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if (Selected) then   
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                    SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
                    SetVehicleCustomSecondaryColour(vehicle, 0, 0, 0)
                    end      
                end)
                RageUI.ButtonWithStyle("Rose", "Couleur rose", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if (Selected) then   
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                    SetVehicleCustomPrimaryColour(vehicle, 100, 0, 60)
                    SetVehicleCustomSecondaryColour(vehicle, 100, 0, 60)
                    end      
                end)
                RageUI.ButtonWithStyle("Blanc", "Couleur blanc", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if (Selected) then   
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                    SetVehicleCustomPrimaryColour(vehicle, 255, 255, 255)
                    SetVehicleCustomSecondaryColour(vehicle, 255, 255, 255)
                    end      
                end)

        
            end, function()
            end)

        if not RageUI.Visible(mainextra) and not RageUI.Visible(subextra)  and not RageUI.Visible(livery) then
            mainextra = RMenu:DeleteType(mainextra, true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
    local Timer = 800
    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointExtra then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.extrascustom.position.x, Config.pos.extrascustom.position.y, Config.pos.extrascustom.position.z)
        if dist3 <= Config.Marker.drawdistance then
            Timer = 0
            DrawMarker(Config.Marker.type, Config.pos.extrascustom.position.x, Config.pos.extrascustom.position.y, Config.pos.extrascustom.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
            end        
        if dist3 <= 2.0 then 
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Extras", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    ExtraPolice()
                end   
            end
        end 
        Citizen.Wait(Timer)
    end
end)

function SetVehicleMaxMods(vehicle)
    local props = {
      modEngine       = 2,
      modBrakes       = 2,
      modTransmission = 2,
      modSuspension   = 3,
      modTurbo        = true,
    }
    ESX.Game.SetVehicleProperties(vehicle, props)
end