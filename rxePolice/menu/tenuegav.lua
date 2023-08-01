ESX = nil

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

function TenueGAV()
    local maintenuegav = RageUI.CreateMenu("Se changer", "Los Santos Police Departement")

	maintenuegav:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)

    RageUI.Visible(maintenuegav, not RageUI.Visible(maintenuegav))
    while maintenuegav do
        Citizen.Wait(0)
            RageUI.IsVisible(maintenuegav, true, true, true, function()

            RageUI.ButtonWithStyle("Reprendre sa tenue", nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                if (Selected) then   
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                        TriggerEvent('skinchanger:loadSkin', skin)
                    end)
                end
            end)

            RageUI.Separator("~b~Vestiaire G.A.V")

			RageUI.ButtonWithStyle("Se changer", nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                if (Selected) then   
                    SetPedComponentVariation(GetPlayerPed(-1) , 8, 15, 0) --tshirt 
                    SetPedComponentVariation(GetPlayerPed(-1) , 11, 146, 0)  --torse
                    SetPedComponentVariation(GetPlayerPed(-1) , 10, 0, 0)  --decals
                    SetPedComponentVariation(GetPlayerPed(-1) , 3, 41, 0)  -- bras
                    SetPedComponentVariation(GetPlayerPed(-1) , 4, 3, 7)   --pants
                    SetPedComponentVariation(GetPlayerPed(-1) , 6, 12, 12)   --shoes
                    SetPedComponentVariation(GetPlayerPed(-1) , 7, 50, 0)   --Chaine
                    SetPedPropIndex(GetPlayerPed(-1) , 0, -1, 0)   --helmet
                    SetPedPropIndex(GetPlayerPed(-1) , 2, 0, 0)   --ears
                end
			end)
 
            
    end, function()
	end)
	
        if not RageUI.Visible(maintenuegav) then
            maintenuegav = RMenu:DeleteType("maintenuegav", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 800
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.tenueGav.position.x, Config.pos.tenueGav.position.y, Config.pos.tenueGav.position.z)
		if dist3 <= Config.Marker.drawdistance then 
			Timer = 0
		DrawMarker(Config.Marker.type, Config.pos.tenueGav.position.x, Config.pos.tenueGav.position.y, Config.pos.tenueGav.position.z, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
		end
		if dist3 <= 2.0 then 
                Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Vestiaire G.A.V", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            ESX.TriggerServerCallback('rxePolice:getAllPlayerInGAVForGAV', function(result)
                                if result then
                                    TenueGAV()
                                else
                                    RageUI.Popup({message = "~r~Vous n'êtes pas dans le G.A.V"})
                                end
                            end, GetPlayerServerId(PlayerId()))
                    end   
                end
        Citizen.Wait(Timer)
    end
end)