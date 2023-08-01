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

listegens1 = {}
salairezebi = {}


local PlayerData = {}
local societypolicemoney = nil

local Action = {
    Attribuer = {'PPA','Permis', "Code"}, Liste = 1,
	Destituer = {'PPA','Permis', "Code"}, Listee = 1,
}

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

local function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local filterArray = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
local filter = 1

function BossPolice()
	local MenuBoss = RageUI.CreateMenu("Actions Patron", "Management")
	local societygestion = RageUI.CreateSubMenu(MenuBoss, "Actions Patron", "Gestion")
	local MenuBoss2 = RageUI.CreateSubMenu(societygestion, "Actions Patron", "Management")
	local gestsalaire = RageUI.CreateSubMenu(societygestion, "Actions Patron", "Salaires")
	local buysociety = RageUI.CreateSubMenu(MenuBoss, "Actions Patron", "Achat")
	MenuBoss:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	MenuBoss2:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	gestsalaire:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	societygestion:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)
	buysociety:SetRectangleBanner(Config.ColorMenuR, Config.ColorMenuG, Config.ColorMenuB, Config.ColorMenuA)

	RageUI.Visible(MenuBoss, not RageUI.Visible(MenuBoss))

			while MenuBoss do
				Citizen.Wait(0)
					RageUI.IsVisible(MenuBoss, true, true, true, function()
  

				if societypolicemoney ~= nil then
					RageUI.Separator("~b~Argent société : ~s~"..societypolicemoney.."$")
				end

				RageUI.ButtonWithStyle("Gestion société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
					if Selected then
						RefreshpoliceMoney()
					end
				end, societygestion)

				RageUI.ButtonWithStyle("Achat de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
				end, buysociety)

				RageUI.ButtonWithStyle("Attribuer un casier LSPD", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
					if (Selected) then   
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer ~= -1 and closestDistance <= 3.0 then
							TriggerServerEvent('rxePolice:addCasier', GetPlayerServerId(closestPlayer))
						else
							RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
						end
					end
				end)

				RageUI.ButtonWithStyle("Destituer le casier LSPD", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer ~= -1 and closestDistance <= 3.0 then
							TriggerServerEvent('rxePolice:removeCasier', GetPlayerServerId(closestPlayer))
						else
							RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
						end
					end
				end)

				RageUI.ButtonWithStyle("Attribuer un casier LSPD (Moi)", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
					if (Selected) then   
						TriggerServerEvent('rxePolice:addCasier', GetPlayerServerId(PlayerId()))
					end
				end)

				RageUI.ButtonWithStyle("Destituer le casier LSPD (Moi)", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
					if (Selected) then
						TriggerServerEvent('rxePolice:removeCasier', GetPlayerServerId(PlayerId()))
					end
				end)

				RageUI.List("Attribuer", Action.Attribuer, Action.Liste, nil, {RightLabel = ""}, not cooldown, function(Hovered, Active, Selected, Index)
					if (Selected) then 
						if Index == 1 then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
								TriggerServerEvent('add:addlic', GetPlayerServerId(closestPlayer), "weapon")
								RageUI.Popup({message = "<C>~g~Le joueur a bien reçu sont ppa"})
							else
								RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
							end 
						elseif Index == 2 then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
									TriggerServerEvent('add:addlic', GetPlayerServerId(closestPlayer), "drive")
								RageUI.Popup({message = "<C>~g~Le joueur a bien reçu sont permis"})
							else
								RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
							end 
						elseif Index == 3 then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
									TriggerServerEvent('add:addlic', GetPlayerServerId(closestPlayer), "code")
								RageUI.Popup({message = "<C>~g~Le joueur a bien reçu sont permis"})
							else
								RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
							end 	
						end
						cooldowncool(5000)
					end
					Action.Liste = Index;              
				end)

				RageUI.List("Destituer", Action.Destituer, Action.Listee, nil, {RightLabel = ""}, not cooldown, function(Hovered, Active, Selected, Index)
					if (Selected) then 
						if Index == 1 then
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
								if closestPlayer ~= -1 and closestDistance <= 3.0 then
									TriggerServerEvent('sup:addlic', GetPlayerServerId(closestPlayer), "weapon")
							else
								RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
							end 
						elseif Index == 2 then
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
								if closestPlayer ~= -1 and closestDistance <= 3.0 then
									TriggerServerEvent('sup:addlic', GetPlayerServerId(closestPlayer), "drive")
									RageUI.Popup({message = "<C>~g~Le joueur a bien reçu sont permis"})
							else
								RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
							end 
						elseif Index == 3 then
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
								TriggerServerEvent('sup:addlic', GetPlayerServerId(closestPlayer), "code")
								RageUI.Popup({message = "<C>~g~Le joueur a bien reçu sont permis"})
						else
							RageUI.Popup({message = "<C>~r~Aucun joueurs à proximité"})
						end 
						end
						cooldowncool(5000)
					end
					Action.Listee = Index;              
				end)

				RageUI.Separator("~b~Transmission")

				RageUI.ButtonWithStyle("Message employés", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
					if (Selected) then
						local msg = KeyboardInput("Message à tous les employés", "", 10)
						TriggerServerEvent('rxePolice:sendMsg', '~b~Message personnel de la police', '~b~'..msg)
						cooldowncool(5000)
					end
				end)

				RageUI.ButtonWithStyle("Annonce", nil, {RightLabel = "→→"}, not cooldown, function(Hovered, Active, Selected)
					if (Selected) then
						local msg = KeyboardInput("Annonce à tout le monde", "", 10)
						ExecuteCommand("lspd "..msg)
						cooldowncool(5000)
					end
				end)
			
			end, function()
			end)

				RageUI.IsVisible(societygestion, true, true, true, function()

					if societypolicemoney ~= nil then
						RageUI.Separator("~b~Argent société : ~s~"..societypolicemoney.."$")
					end

					RageUI.ButtonWithStyle("Retirer de l'argent",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
						if Selected then
							local amount = KeyboardInput("Montant", "", 10)
							amount = tonumber(amount)
							if amount == nil then
								RageUI.Popup({message = "<C>~r~Montant invalide"})
							else
								TriggerServerEvent('esx_society:withdrawMoney', 'police', amount)
								RefreshpoliceMoney()
							end
							cooldowncool(2500)
						end
					end)

					RageUI.ButtonWithStyle("Déposer de l'argent",nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
						if Selected then
							local amount = KeyboardInput("Montant", "", 10)
							amount = tonumber(amount)
							if amount == nil then
								RageUI.Popup({message = "<C>~r~Montant invalide"})
							else
								TriggerServerEvent('esx_society:depositMoney', 'police', amount)
								RefreshpoliceMoney()
							end
							cooldowncool(2500)
						end
					end)

					RageUI.ButtonWithStyle("Recruter", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
						if (Selected) then   
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
								TriggerServerEvent('patron:recruter', "police", false, GetPlayerServerId(closestPlayer))
							else
								RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
							end 
							cooldowncool(2500)
						end
						end)
						RageUI.ButtonWithStyle("Promouvoir", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
						if (Selected) then   
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
								TriggerServerEvent('patron:promouvoir', "police", false, GetPlayerServerId(closestPlayer))
							else
								RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
							end 
							cooldowncool(2500)
						end
						end)
						RageUI.ButtonWithStyle("Rétrograder", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
						if (Selected) then   
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
								TriggerServerEvent('patron:descendre', "police", false, GetPlayerServerId(closestPlayer))
							else
								RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
							end 
							cooldowncool(2500)
						end
						end)
						RageUI.ButtonWithStyle("Virer", nil, {RightLabel = "→"}, not cooldown, function(Hovered, Active, Selected)
						if (Selected) then   
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
							if closestPlayer ~= -1 and closestDistance <= 3.0 then
								TriggerServerEvent('patron:virer', "police", false, GetPlayerServerId(closestPlayer))
							else
								RageUI.Popup({message = "<C>~r~Aucun joueur à proximité"})
							end 
							cooldowncool(2500)
						end
						end)

					RageUI.ButtonWithStyle("Liste employés", "Pour voir la liste des employés.", {RightLabel = "→"},true, function()
					end, MenuBoss2)

					RageUI.ButtonWithStyle("Gestion salaires", nil, {RightLabel = "→"},true, function()
					end, gestsalaire)  

				end, function()
				end)



				RageUI.IsVisible(MenuBoss2, true, true, true, function()

					RageUI.List("Filtre :", filterArray, filter, nil, {}, true, function(_, _, _, i)
						filter = i
					end)

					if listegens1[i] == nil then
						RageUI.Separator("")
						RageUI.Separator("~r~Aucun employé")
						RageUI.Separator("")
					else
					for i = 1, #listegens1, 1 do
						if starts(listegens1[i].nom:lower(), filterArray[filter]:lower()) then
							RageUI.ButtonWithStyle(listegens1[i].prenom.." "..listegens1[i].nom, nil, {RightLabel = 'Virer'}, true, function(Hovered, Active, Selected)
								if (Selected) then
									TriggerServerEvent('five_society:virersql', listegens1[i].steam)
									RageUI.Popup({message = "<C>~g~La personne a été viré"})
									RageUI.CloseAll()
								end
							end)
					else 
						RageUI.Separator("")
						RageUI.Separator("~r~Aucun nom d'employé commençant par "..filterArray[filter])
						RageUI.Separator("")
					end
				end
			end

					
				end, function()
				end)

				RageUI.IsVisible(gestsalaire, true, true, true, function()

				for i = 1, #salairezebi, 1 do

					RageUI.ButtonWithStyle(salairezebi[i].nom.." - $"..salairezebi[i].salaire, nil, {RightLabel = 'Changer'}, true, function(Hovered, Active, Selected)
							if (Selected) then
								local montant = KeyboardInput('Veuillez choisir le montant', '', 8)
								montant = tonumber(montant)
								if not montant then
								RageUI.Popup({message = "<C>~r~Quantité invalide"})
								else
								if montant > 10000 then
								RageUI.Popup({message = "<C>Le salaire ne peut pas être supérieur à 10000$"})
								else         
								TriggerServerEvent('five_society:changersalaire', salairezebi[i].id, montant)
								RageUI.Popup({message = "<C>~g~Changement du salaire effectué"})
								RageUI.CloseAll()
								end
							end
						end
					end)

				end

		end, function()
		end)

			RageUI.IsVisible(buysociety, true, true, true, function()

				if societypolicemoney ~= nil then
					RageUI.Separator("~b~Argent société : ~s~"..societypolicemoney.."$")
				end

				RageUI.Separator("~b~Arme(s)")

				if Config.armesEnItems then

					for k,v in pairs(Config.armurerie) do
						RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "~g~"..v.restockprice.."$~s~ (+1)"}, not cooldown, function(Hovered, Active, Selected)
							if Selected then
								ESX.TriggerServerCallback('rxePolice:getMoneySociety', function(ifGood)
									if ifGood then
										TriggerServerEvent('rxePolice:addWeaponInAmmu', (v.arme))
										RageUI.Popup({message = "<C>".. v.nom .. "\n-"..v.restockprice.."$\nAjouté dans l'armurerie LSPD"})
										RefreshpoliceMoney()
										cooldowncool(1500)
									end
								end, v.restockprice)
							end
						end)
					end

				else

				
				for k,v in pairs(Config.armurerie) do
					RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "~g~"..v.restockprice.."$~s~ (+1)"}, not cooldown, function(Hovered, Active, Selected)
						if Selected then
							ESX.TriggerServerCallback('rxePolice:getMoneySociety', function(ifGood)
								if ifGood then
									TriggerServerEvent('rxePolice:addWeaponInAmmu', GetHashKey(v.arme))
									RageUI.Popup({message = "<C>".. v.nom .. "\n-"..v.restockprice.."$\nAjouté dans l'armurerie LSPD"})
									RefreshpoliceMoney()
									cooldowncool(1500)
								end
							end, v.restockprice)
						end
					end)
				end

			end

				RageUI.Separator("~b~Véhicule(s)")

				for k,v in pairs(police.vehicles.car) do
					if v.category == nil then 
						RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~g~"..v.restockprice.."$~s~ (+1)"}, not cooldown, function(Hovered, Active, Selected)
							if Selected then
								ESX.TriggerServerCallback('rxePolice:getMoneySociety', function(ifGood)
									if ifGood then
										TriggerServerEvent("rxePolice:addVehInGarage", GetHashKey(v.model))
								        RageUI.Popup({message = "<C>".. v.label .. "\n-"..v.restockprice.."$\nAjouté dans le garage LSPD"})
										RefreshpoliceMoney()
										cooldowncool(1500)
									end
								end, v.restockprice)			
							end
						end)
					end
				end

				RageUI.Separator("~b~Helico(s)")

				for k,v in pairs(police.vehicles.helico) do
					if v.category == nil then 
						RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~g~"..v.restockprice.."$~s~ (+1)"}, not cooldown, function(Hovered, Active, Selected)
							if Selected then
								ESX.TriggerServerCallback('rxePolice:getMoneySociety', function(ifGood)
									if ifGood then
										TriggerServerEvent("rxePolice:addVehInGarage", GetHashKey(v.model))
								        RageUI.Popup({message = "<C>".. v.label .. "\n-"..v.restockprice.."$\nAjouté dans le garage LSPD"})
										RefreshpoliceMoney()
										cooldowncool(1500)
									end
								end, v.restockprice)			
							end
						end)
					end
				end

				RageUI.Separator("~b~Bateau(x)")

				for k,v in pairs(police.vehicles.bateaux) do
					if v.category == nil then 
						RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~g~"..v.restockprice.."$~s~ (+1)"}, not cooldown, function(Hovered, Active, Selected)
							if Selected then
								ESX.TriggerServerCallback('rxePolice:getMoneySociety', function(ifGood)
									if ifGood then
										TriggerServerEvent("rxePolice:addVehInGarage", GetHashKey(v.model))
								        RageUI.Popup({message = "<C>".. v.label .. "\n-"..v.restockprice.."$\nAjouté dans le garage LSPD"})
										RefreshpoliceMoney()
										cooldowncool(1500)
									end
								end, v.restockprice)			
							end
						end)
					end
				end

			end, function()
			end)

		if not RageUI.Visible(MenuBoss) and not RageUI.Visible(MenuBoss2) and not RageUI.Visible(gestsalaire)  and not RageUI.Visible(societygestion) and not RageUI.Visible(buysociety) then
			MenuBoss = RMenu:DeleteType("Actions Patron", true)
		end
	end
end

function RefreshpoliceMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('five_society:getSocietyMoney', function(money)
            UpdateSocietypoliceMoney(money)
        end, ESX.PlayerData.job.name)
		ESX.TriggerServerCallback('five_patron:listegensjob1', function(liste)
			listegens1 = liste
		end, ESX.PlayerData.job.name)
		ESX.TriggerServerCallback('five_patron:listesalaire', function(liste)
			salairezebi = liste
		end, ESX.PlayerData.job.name)
    end
end

function UpdateSocietypoliceMoney(money)
    societypolicemoney = ESX.Math.GroupDigits(money)
end
  
Citizen.CreateThread(function()
	  while true do
		  local Timer = 800
		  if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobName and ESX.PlayerData.job.grade >= Config.GradePointBoss then
		  local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
		  local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.pos.boss.position.x, Config.pos.boss.position.y, Config.pos.boss.position.z)
		  if dist3 <= Config.Marker.drawdistance then
			  Timer = 0
			  DrawMarker(Config.Marker.type, Config.pos.boss.position.x, Config.pos.boss.position.y, Config.pos.boss.position.z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 0, 0, 255 , 200)
			end
			  if dist3 <= 2.0 then
				  Timer = 0   
						RageUI.Text({ message = "Appuyez sur ~b~[E]~s~ pour ouvrir →→ ~b~Actions Patron", time_display = 1 })
						if IsControlJustPressed(1,51) then
						RefreshpoliceMoney()
						BossPolice()
					  end   
				  end
			  end 
		  Citizen.Wait(Timer)
	  end
end)
 




RegisterCommand('bosspolice', function()
	RefreshpoliceMoney()
	BossPolice()
end)