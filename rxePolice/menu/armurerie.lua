ESX = nil
local stockAmmu = {}

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

function ArmureriePolice()
    local armp = RageUI.CreateMenu("Armurerie", "Los Santos Police Departement")
    armp:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(armp, not RageUI.Visible(armp))
    while armp do
        Citizen.Wait(0)
            RageUI.IsVisible(armp, true, true, true, function()

            RageUI.ButtonWithStyle("Rendre l'équipement", nil, {RightLabel = "→→"}, not cooldown, function(h, a, s)
                if s then
                    TriggerServerEvent('finalpolice:arsenalvide')
                    cooldowncool(2000)
                end
            end)

            RageUI.Separator("~b~Arme(s) & Equipement")

        if not Config.armesEnItems then

            RageUI.ButtonWithStyle("Equipement de base", nil, { },not cooldown, function(Hovered, Active, Selected)
                if (Selected) then   
                    TriggerServerEvent('equipementbase')
                    cooldowncool(2000)
                end
            end)

        end

        if Config.armesEnItems then

            for k,v in pairs(Config.armurerie) do
                if ESX.PlayerData.job.grade >= v.minimum_grade then
                RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "Stock(s): [~y~"..stockAmmu[(v.arme)].."~s~]"},not cooldown, function(Hovered, Active, Selected)
                    if (Selected) then
                        if stockAmmu[(v.arme)] > 0 then
                            TriggerServerEvent('armurerie', v.arme, v.prix)
                            TriggerServerEvent('rxePolice:removeWeaponInAmmu', (v.arme))
                            RageUI.CloseAll()
                        else
                            RageUI.Popup({message = "~r~Vous n'avez pas d'armes en stock"})
                        end
                    end
                end)
            end
        end
        else
            for k,v in pairs(Config.armurerie) do
				if ESX.PlayerData.job.grade >= v.minimum_grade then
                RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "Stock(s): [~y~"..stockAmmu[GetHashKey(v.arme)].."~s~]"},not cooldown, function(Hovered, Active, Selected)
                    if (Selected) then
                        if stockAmmu[GetHashKey(v.arme)] > 0 then
                            TriggerServerEvent('armurerie', v.arme, v.prix)
                            TriggerServerEvent('rxePolice:removeWeaponInAmmu', GetHashKey(v.arme))
                            RageUI.CloseAll()
                        else
                            RageUI.Popup({message = "~r~Vous n'avez pas d'armes en stock"})
                        end
                    end
                end)
			end
		end
        end

        end, function()
        end)
        if not RageUI.Visible(armp) then
            armp = RMenu:DeleteType("armp", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointArmu then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.armurerie.position.x, Config.pos.armurerie.position.y, Config.pos.armurerie.position.z)
        if dist3 <= Config.Marker.drawdistance then
            Timer = 0
            DrawMarker(Config.Marker.type, Config.pos.armurerie.position.x, Config.pos.armurerie.position.y, Config.pos.armurerie.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
          end
        if dist3 <= 2.0 then 
                Timer = 0
                    RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Armurerie", time_display = 1 })
                    if IsControlJustPressed(1,51) then

                        if Config.armesEnItems then
                            for k,v in pairs(Config.armurerie) do
                                ESX.TriggerServerCallback('rxePolice:getWeaponAmmu', function(amount)
                                        stockAmmu[(v.arme)] = amount
                                        ArmureriePolice()
                                end, (v.arme))
                            end
                        else
                        for k,v in pairs(Config.armurerie) do
                            ESX.TriggerServerCallback('rxePolice:getWeaponAmmu', function(amount)
                                    stockAmmu[GetHashKey(v.arme)] = amount
                                    ArmureriePolice()
                            end, GetHashKey(v.arme))
                        end
                    end
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)