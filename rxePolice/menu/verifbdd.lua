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

function menuVerifBddPlayer(id)
    local menuP = RageUI.CreateMenu("Base de verification", "Los Santos Police Departement")
    ESX.TriggerServerCallback('rxePolice:getPlayer', function(data)
    ESX.TriggerServerCallback('esx_billing:getTargetBills', function(allBiling)
    menuP:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(menuP, not RageUI.Visible(menuP))
    while menuP do
        Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()

            RageUI.Separator("~b~Informations personnelles")

            RageUI.ButtonWithStyle("Prenom & Nom : ", nil, {RightLabel = "~g~"..data.firstname.. " "..data.lastname}, true, function(Hovered, Active, Selected)
            end)

            RageUI.ButtonWithStyle("Né le : ", nil, {RightLabel = "~g~"..data.dateAnniv}, true, function(Hovered, Active, Selected)
            end)

            RageUI.ButtonWithStyle("Metier : ", nil, {RightLabel = "~g~"..data.job.." - "..data.grade}, true, function(Hovered, Active, Selected)
            end)

            RageUI.Separator("~b~Informations diverses")

            RageUI.ButtonWithStyle("Argent liquide : ", nil, {RightLabel = "~g~"..data.cashMoney}, true, function(Hovered, Active, Selected)
            end)

            RageUI.ButtonWithStyle("Argent banque : ", nil, {RightLabel = "~g~"..data.bankMoney}, true, function(Hovered, Active, Selected)
            end)

            RageUI.ButtonWithStyle("Numero de téléphone : ", nil, {RightLabel = "~g~"..data.numberTel}, true, function(Hovered, Active, Selected)
            end)

            RageUI.ButtonWithStyle("Ville : ", nil, {RightLabel = "~g~".."Los Santos"}, true, function(Hovered, Active, Selected)
            end)

            RageUI.Separator("~b~Facture impayée")

            if #allBiling == 0 then
                RageUI.ButtonWithStyle("Aucune facture", nil, {}, true, function(Hovered, Active, Selected)
                end)
            else
                for i = 1, #allBiling, 1 do
                    RageUI.ButtonWithStyle(allBiling[i].label, nil, {RightLabel = "~g~"..allBiling[i].amount.."$"}, true, function(Hovered, Active, Selected)
                    end)
                end
            end

        end, function()
        end)
        if not RageUI.Visible(menuP) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end, id)
end, id)
end

Citizen.CreateThread(function()
    while true do
        local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointBaseDeDonne then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.menuVerifBdd.position.x, Config.pos.menuVerifBdd.position.y, Config.pos.menuVerifBdd.position.z)
        if dist3 <= Config.Marker.drawdistance then
            Timer = 0
            DrawMarker(Config.Marker.type, Config.pos.menuVerifBdd.position.x, Config.pos.menuVerifBdd.position.y, Config.pos.menuVerifBdd.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
          end
        if dist3 <= 2.0 then 
                Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Base de verification", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                                menuVerifBddPlayer(GetPlayerServerId(closestPlayer))
                            else
                                RageUI.Popup({message = "<C>~r~Personne autour de vous !"})
                            end
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)