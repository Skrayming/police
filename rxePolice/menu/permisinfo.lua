local ESX = nil
local allLicensesClient = {}
local lSelected = {}
local indexMenu = 1
local TypeDispo = {
    [1] = 'drive', -- permis voiture
    [2] = 'drive_bike', -- permis moto
    [3] = 'drive_truck', -- permis camion
    [4] = 'weapon', -- permis d'arme
    [5] = 'dmv' -- code
}

Citizen.CreateThread(function()
    TriggerEvent(Config.esxGet, function(lib) ESX = lib end)
    while ESX == nil do Citizen.Wait(100) end

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

local function menuPointLicenses()
    local menuP = RageUI.CreateMenu("Gestions Permis", ' ')
    local menuS = RageUI.CreateSubMenu(menuP, "Gestions Permis", ' ')
	menuP:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    menuS:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(menuP, not RageUI.Visible(menuP))
    while menuP do
        Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()

                RageUI.List('Type de permis : ', {'Voiture', 'Moto', 'Camion', 'PPA', 'Code'}, indexMenu, nil, {}, true, function(Hovered, Active, Selected, Index)
                    indexMenu = Index
                end)
            
                for k,v in pairs(allLicensesClient) do
                    if v.Type == TypeDispo[indexMenu] then
                    RageUI.ButtonWithStyle(v.Name, nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            lSelected = v
                        end
                    end, menuS)
                end
            end
        end)

        RageUI.IsVisible(menuS, true, true, true, function()

            RageUI.Separator(lSelected.Name.." - "..lSelected.Type)

            RageUI.ButtonWithStyle("Supprimer le permis", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('rPermisPoint:removePoint', lSelected.Type, qty, lSelected.Owner)
                    RageUI.CloseAll()
                    end
                end)

        end)

        if not RageUI.Visible(menuP) and not RageUI.Visible(menuS) then
            menuP = RMenu:DeleteType("Menu Point", true)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointGestionPermis then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.menuPermisInfo.position.x, Config.pos.menuPermisInfo.position.y, Config.pos.menuPermisInfo.position.z)
        if dist3 <= Config.Marker.drawdistance then
            Timer = 0
			DrawMarker(Config.Marker.type, Config.pos.menuPermisInfo.position.x, Config.pos.menuPermisInfo.position.y, Config.pos.menuPermisInfo.position.z, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
		end
            if dist3 <= 2.0 then
                Timer = 0   
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Gestion permis", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                                ESX.TriggerServerCallback('rPermisPoint:getAllLicenses', function(result)
                                allLicensesClient = result
                                menuPointLicenses()
                            end, GetPlayerServerId(closestPlayer))
                            else
                                RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
                            end
                        end 
                end
            end 
        Citizen.Wait(Timer)
    end
end)