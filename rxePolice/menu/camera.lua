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

local EnosAKA = false

function CameraMenu()
    local cameraeha = RageUI.CreateMenu("Vidéo surveillance", "Los Santos Police Departement")
    cameraeha:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)

    RageUI.Visible(cameraeha, not RageUI.Visible(cameraeha))
    while cameraeha do
        Citizen.Wait(0)
            RageUI.IsVisible(cameraeha, true, true, true, function()

                if EnosAKA then 

                    RageUI.ButtonWithStyle("~r~Retour", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then   
                            TriggerEvent('cctv:camera', 0)
                            EnosAKA = false
                            cooldowncool(2000)
                        end
                    end)

                else

                RageUI.ButtonWithStyle("Caméra 1 (Ballas)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 25)
                        EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 2 (Families)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 26) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 3 (Vagos)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 27) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)

                RageUI.ButtonWithStyle("Caméra 4 ( Bijouterie )", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 22) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 5 (Paleto Bank Outside)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 23) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)

                RageUI.ButtonWithStyle("Caméra 6 (Main Bank 1)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 24) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 7 (Superette Unicorn)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 1) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
        
                RageUI.ButtonWithStyle("Caméra 8 (Superette Ballas)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 2) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 9 (Superette Ballas)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 3) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 10 (Superette BurgerShot)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 4) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 11 (Superette Taxi)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 5) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 12 (Superette Vinewood)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 6) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 13 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 7) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 14 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 8) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 15 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 9) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 16 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 10) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 17 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 11) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 18 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 12) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 19 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 13) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 20 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 14) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 21 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 15) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 22 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 16) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 23 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 17) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 24 (Superette)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 18) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 25 (Cam Power)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 19) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 26 (Avant Prison)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 20) 
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
        
                RageUI.ButtonWithStyle("Caméra 27 (Cellule)", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
                    if Selected then   
                        TriggerEvent('cctv:camera', 21)
                                                EnosAKA = true
                        cooldowncool(2000)
                    end
                end)
            end
        
  
            
            end, function()
            end)
	
        if not RageUI.Visible(cameraeha) and not RageUI.Visible(plainte) then
            cameraeha = RMenu:DeleteType("cameraeha", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 800
        if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointCamera then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.cameraview.position.x, Config.pos.cameraview.position.y, Config.pos.cameraview.position.z)
		if dist3 <= Config.Marker.drawdistance then 
			Timer = 0
            DrawMarker(Config.Marker.type, Config.pos.cameraview.position.x, Config.pos.cameraview.position.y, Config.pos.cameraview.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
		end
		if dist3 <= 2.0 then 
                Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Vidéo surveillance", time_display = 1 })
                        if IsControlJustPressed(1,51) then
                        CameraMenu()
                    end   
                end
            end
        Citizen.Wait(Timer)
    end
end)