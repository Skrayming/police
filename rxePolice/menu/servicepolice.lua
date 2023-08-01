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

local FirstName = nil
local LastName = nil
local Subject = nil
local Desc = nil
local tel = nil
local cansend = false

function ServicePolice()
    local servpopo = RageUI.CreateMenu("Accueil de Police", "Que puis-je faire pour vous ?")
	local plainte = RageUI.CreateSubMenu(servpopo, "L.S.P.D", "Los Santos Police Departement")
	servpopo:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	plainte:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
    RageUI.Visible(servpopo, not RageUI.Visible(servpopo))
    while servpopo do
        Citizen.Wait(0)
            RageUI.IsVisible(servpopo, true, true, true, function()

			RageUI.ButtonWithStyle("Appeler un agent de police ", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
				if (Selected) then  
				TriggerServerEvent("genius:sendcall") 
                RageUI.Popup({message = "<C>~b~Votre appel à bien été pris en compte"})
				end
			end)

			RageUI.ButtonWithStyle("Déposer une plainte", nil, {RightLabel = "→"},true, function()
			end, plainte)    
            
    end, function()
	end)

	RageUI.IsVisible(plainte, true, true, true, function()

		RageUI.ButtonWithStyle("Votre Nom : ~s~"..notNilString(LastName), nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
			if (Selected) then   
                LastName = KeyboardInput("Votre Nom:",nil,20)
			end
		end)   

		RageUI.ButtonWithStyle("Votre Prénom : ~s~"..notNilString(FirstName), nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
			if (Selected) then   
                FirstName = KeyboardInput("Votre Prénom:",nil,20)
			end
		end)   

		RageUI.ButtonWithStyle("Votre Numéro de téléphone~s~ : ~s~"..notNilString(tel), nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
			if (Selected) then   
                tel = KeyboardInput("Votre Numéro :",nil,350)
			end
		end)   

		RageUI.ButtonWithStyle("Sujet de votre Plainte~s~ : ~s~"..notNilString(Subject), nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
			if (Selected) then   
                Subject = KeyboardInput("Votre Sujet:",nil,30)
			end
		end)   

		RageUI.ButtonWithStyle("Votre Plainte~s~ : ~s~"..notNilString(Desc), nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
			if (Selected) then   
                Desc = KeyboardInput("Votre Description:",nil,350)
			end
		end)  

		if LastName ~= nil and LastName ~= "" and FirstName ~= nil and FirstName ~= "" and tel ~= nil and tel ~= "" and Subject ~= nil and Subject ~= "" and Desc ~= nil and Desc ~= "" then
			cansend = true
		end

        RageUI.ButtonWithStyle("~g~~h~Envoyer", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
                RageUI.CloseAll()
                TriggerServerEvent("genius:sendplainte", LastName, FirstName,tel ,Subject, Desc)
                RageUI.Popup({message = "<C>~b~Votre plainte à bien été pris en compte"})
                reset()
            end
        end)

	end, function()
	end)
	
        if not RageUI.Visible(servpopo) and not RageUI.Visible(plainte) then
            servpopo = RMenu:DeleteType("servpopo", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 800
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.plainterdv.position.x, Config.pos.plainterdv.position.y, Config.pos.plainterdv.position.z)
		if dist3 <= Config.Marker.drawdistance then 
			Timer = 0
		DrawMarker(Config.Marker.type, Config.pos.plainterdv.position.x, Config.pos.plainterdv.position.y, Config.pos.plainterdv.position.z, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
		end
		if dist3 <= 5.0 then 
                Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Renseignement Police", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                            ServicePolice()
                    end   
                end
        Citizen.Wait(Timer)
    end
end)