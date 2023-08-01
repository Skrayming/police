ESX = nil

TriggerEvent(Config.esxGet, function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', Config.JobName, 'alerte police', true, true)

TriggerEvent('esx_society:registerSociety', Config.JobName, 'Police', Config.SocietyName, Config.SocietyName, Config.SocietyName, {type = 'public'})

local function getPlayerNameWhereIdentifier(identifier)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            fullName = result[1].firstname.." "..result[1].lastname
        else
            fullName = "Inconnu"
        end
    end)
    return fullName
end

ESX.RegisterServerCallback('rPermisPoint:getAllLicenses', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)
        local allLicenses = {}
        MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {['owner'] = xPlayer.identifier}, function(result)
            for k,v in pairs(result) do
                table.insert(allLicenses, {
                    Name = xPlayer.getName(),
                    Type = v.type,
                    Point = v.point,
                    Owner = v.owner
                })
            end
        cb(allLicenses)
    end)
end)

RegisterServerEvent('rPermisPoint:removePoint')
AddEventHandler('rPermisPoint:removePoint', function(permis, qty, owner)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE type = @type AND owner = @owner', {['type'] = permis, ['owner'] = owner}, function(result)
    MySQL.Async.execute('DELETE FROM user_licenses WHERE owner = @owner AND type = @type', {['type'] = permis, ['owner'] = owner})
    TriggerClientEvent('esx:showNotification', _src, "La licence de "..ESX.GetPlayerFromIdentifier(owner).getName().." a bien été retiré.")
	rxeLogsDiscord("[SUPP LICENCE] **"..xPlayer.getName().."** a retiré la licence de **"..ESX.GetPlayerFromIdentifier(owner).getName().."**", Config.logs.GestionPermis)
end)
end)

RegisterNetEvent('equipementbase')
AddEventHandler('equipementbase', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addWeapon('WEAPON_NIGHTSTICK', Config.amountAmmo)
    xPlayer.addWeapon('WEAPON_STUNGUN', Config.amountAmmo)
    xPlayer.addWeapon('WEAPON_FLASHLIGHT', Config.amountAmmo)
    TriggerClientEvent('esx:showNotification', source, "Vous avez reçu votre ~b~équipement de base")
end)

RegisterNetEvent('armurerie')
AddEventHandler('armurerie', function(arme, prix)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

	if Config.armesEnItems then
		xPlayer.addInventoryItem(arme, 1)
	else
        xPlayer.addWeapon(arme, Config.amountAmmo)
	end
    TriggerClientEvent('esx:showNotification', source, "Vous avez reçu votre arme~b~")
	rxeLogsDiscord("[ARMURERIE] "..xPlayer.getName().." a reçu une "..arme, Config.logs.Armurerie)
end)


RegisterNetEvent('finalpolice:arsenalvide')
AddEventHandler('finalpolice:arsenalvide', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

	if Config.armesEnItems then
	for k,v in pairs(Config.armurerie) do
		for _,item in ipairs(xPlayer.getInventory()) do
			if string.upper(item.name) == string.upper(v.arme) then
			xPlayer.removeInventoryItem(string.upper(v.arme), 1)
	
			MySQL.Async.execute('INSERT INTO stockpolice (type, model) VALUES (@type, @model)', {
				['@type'] = "weapon",
				['@model'] = (v.arme)
			})
			rxeLogsDiscord("[AJOUT ARME] **"..xPlayer.getName().."** a ajouté une arme **"..v.arme.."** à l'armurerie", Config.logs.Armurerie)
			end
		end
		end
	else
    for k,v in pairs(Config.armurerie) do
    for _,weapon in ipairs(xPlayer.getLoadout()) do
        if string.upper(weapon.name) == string.upper(v.arme) then
        xPlayer.removeWeapon(string.upper(v.arme))

        MySQL.Async.execute('INSERT INTO stockpolice (type, model) VALUES (@type, @model)', {
            ['@type'] = "weapon",
            ['@model'] = GetHashKey(v.arme)
        })
        rxeLogsDiscord("[AJOUT ARME] **"..xPlayer.getName().."** a ajouté une arme **"..v.arme.."** à l'armurerie", Config.logs.Armurerie)
		xPlayer.removeWeapon('WEAPON_NIGHTSTICK')
		xPlayer.removeWeapon('WEAPON_STUNGUN')
		xPlayer.removeWeapon('WEAPON_FLASHLIGHT')
        end
    end
    end
end
    TriggerClientEvent('esx:showNotification', source, "<C>Vous avez posé tous vos armes")
    rxeLogsDiscord("[ARMURERIE] "..xPlayer.getName().." a posé toutes ses armes", Config.logs.Armurerie)
end)


ESX.RegisterServerCallback('finalpolice:getFineList', function(source, cb, category)
	MySQL.Async.fetchAll('SELECT * FROM fine_types WHERE category = @category', {
		['@category'] = category
	}, function(fines)
		cb(fines)
	end)
end)

ESX.RegisterServerCallback('finalpolice:getVehicleInfos', function(source, cb, plate)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)

		local retrivedInfo = {
			plate = plate
		}

		if result[1] then
			MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				if Config.EnableESXIdentity then
					retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname
				else
					retrivedInfo.owner = result2[1].name
				end

				cb(retrivedInfo)
			end)
		else
			cb(retrivedInfo)
		end
	end)
end)

ESX.RegisterServerCallback('finalpolice:getVehicleFromPlate', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		if result[1] ~= nil then

			MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

				if Config.EnableESXIdentity then
					cb(result2[1].firstname .. ' ' .. result2[1].lastname, true)
				else
					cb(result2[1].name, true)
				end

			end)
		else
			cb(('unknown'), false)
		end
	end)
end)


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------- Casier

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------- Coffre


ESX.RegisterServerCallback('fpolice:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', Config.SocietyName, function(inventory)
		cb(inventory.items)
	end)
end)


RegisterNetEvent('fpolice:getStockItem')
AddEventHandler('fpolice:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', Config.SocietyName, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, '<C>Objet retiré', count, inventoryItem.label)
				rxeLogsDiscord("[COFFRE] "..xPlayer.getName().." a retiré "..count.." "..inventoryItem.label.." du coffre", Config.logs.CoffreObjets)
		else
			TriggerClientEvent('esx:showNotification', _source, "<C>Quantité invalide")
		end
	end)
end)

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

RegisterNetEvent('fpolice:putStockItems')
AddEventHandler('fpolice:putStockItems', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', Config.SocietyName, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, "<C>Objet déposé "..count..""..inventoryItem.label.."")
			rxeLogsDiscord("[COFFRE] "..xPlayer.getName().." a déposé "..count.." "..inventoryItem.label.." dans le coffre", Config.logs.CoffreObjets)
		else
			TriggerClientEvent('esx:showNotification', _source, "<C>Quantité invalide")
		end
	end)
end)

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

ESX.RegisterServerCallback('finalpolice:getArmoryWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', Config.SocietyName, function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end
		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('finalpolice:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)
	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
		rxeLogsDiscord("[COFFRE ARMES] "..xPlayer.getName().." a déposé "..weaponName.." du coffre", Config.logs.CoffreArmes)
	end

	TriggerEvent('esx_datastore:getSharedDataStore', Config.SocietyName, function(store)
		local weapons = store.get('weapons') or {}
		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('finalpolice:removeArmoryWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 0)
	rxeLogsDiscord("[COFFRE ARMES] "..xPlayer.getName().." a retiré "..weaponName.." du coffre", Config.logs.CoffreArmes)

	TriggerEvent('esx_datastore:getSharedDataStore', Config.SocietyName, function(store)
		local weapons = store.get('weapons') or {}

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('fpolice:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)


RegisterServerEvent('police:PriseEtFinservice')
AddEventHandler('police:PriseEtFinservice', function(PriseOuFin)
	local _source = source
	local _raison = PriseOuFin
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	local identifier = GetPlayerIdentifier(_source)
	local name = xPlayer.getName(_source)

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'police' then
			TriggerClientEvent('police:InfoService', xPlayers[i], _raison, name)
		end
	end
end)

RegisterServerEvent('renfort')
AddEventHandler('renfort', function(coords, raison)
	local _source = source
	local _raison = raison
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'police' then
			TriggerClientEvent('renfort:setBlip', xPlayers[i], coords, _raison)
		end
	end
end)

RegisterCommand('lspd', function(source, args, rawCommand)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.job.name == "police" then
        local src = source
        local msg = rawCommand:sub(5)
        local args = msg
        if player ~= false then
            local name = GetPlayerName(source)
            local xPlayers	= ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], '<C>L.S.P.D', '<C>~b~Annonce', ''..msg..'', 'CHAR_MP_FM_CONTACT', 0)
        end
    else
        TriggerClientEvent('esx:showAdvancedNotification', _source, 'Avertisement', '~b~Tu n\'pas' , '~b~policier pour faire cette commande', 'CHAR_ABIGAIL', 0)
    end
    else
    TriggerClientEvent('esx:showAdvancedNotification', _source, 'Avertisement', '~b~Tu n\'est pas' , '~b~policier pour faire cette commande', 'CHAR_ABIGAIL', 0)
    end
 end, false)

------------------------------------------------ Intéraction


RegisterServerEvent('finalpolice:handcuff')
AddEventHandler('finalpolice:handcuff', function(target)
  TriggerClientEvent('finalpolice:handcuff', target)
end)

RegisterServerEvent('finalpolice:drag')
AddEventHandler('finalpolice:drag', function(target)
  local _source = source
  TriggerClientEvent('finalpolice:drag', target, _source)
end)

RegisterServerEvent('finalpolice:putInVehicle')
AddEventHandler('finalpolice:putInVehicle', function(target)
  TriggerClientEvent('finalpolice:putInVehicle', target)
end)

RegisterServerEvent('finalpolice:OutVehicle')
AddEventHandler('finalpolice:OutVehicle', function(target)
    TriggerClientEvent('finalpolice:OutVehicle', target)
end)

ESX.RegisterServerCallback('finalpolice:getOtherPlayerData', function(source, cb, target, notify)
    local xPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent("esx:showNotification", target, "~r~Quelqu'un vous fouille ...")
	rxeLogsDiscord("[INTERACTION] "..xPlayer.getName().." se fait fouiller", Config.logs.Fouille)

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout(),
			--argentpropre = xPlayer.getMoney()
        }

        TriggerEvent('esx_license:getLicenses', target, function(licenses)
                 print(json.encode(licenses))
                data.licenses = licenses
        cb(data)
        end)
    end
end)

RegisterNetEvent('yaya:confiscatePlayerItem')
AddEventHandler('yaya:confiscatePlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)

    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		
			targetXPlayer.removeInventoryItem(itemName, amount)
			sourceXPlayer.addInventoryItem   (itemName, amount)
            TriggerClientEvent("esx:showNotification", source, "<C>Vous avez confisqué ~b~"..amount..' '..sourceItem.label.."~s~.")
            TriggerClientEvent("esx:showNotification", target, "<C>Quelqu'un vous a pris ~b~"..amount..' '..sourceItem.label.."~s~.")
			rxeLogsDiscord("[INTERACTION] "..sourceXPlayer.getName().." a confisqué "..amount..' '..sourceItem.label.." à "..targetXPlayer.getName(), Config.logs.Fouille)
        else
			TriggerClientEvent("esx:showNotification", source, "<C>~r~Quantité invalide")
		end
        
    if itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)
        sourceXPlayer.addAccountMoney   (itemName, amount)
        
        TriggerClientEvent("esx:showNotification", source, "<C>Vous avez confisqué ~b~"..amount.." d' "..itemName.."~s~.")
        TriggerClientEvent("esx:showNotification", target, "<C>Quelqu'un vous aconfisqué ~b~"..amount.." d' "..itemName.."~s~.")
		rxeLogsDiscord("[INTERACTION] "..sourceXPlayer.getName().." a confisqué "..amount.." d' "..itemName.." à "..targetXPlayer.getName(), Config.logs.Fouille)

	elseif itemType == 'item_cash' then
		targetXPlayer.removeMoney(itemName, amount)
		sourceXPlayer.addMoney   (itemName, amount)
			
		TriggerClientEvent("esx:showNotification", source, "<C>Vous avez confisqué ~b~"..amount.." d' "..itemName.."~s~.")
		TriggerClientEvent("esx:showNotification", target, "<C>Quelqu'un vous aconfisqué ~b~"..amount.." d' "..itemName.."~s~.")
		rxeLogsDiscord("[INTERACTION] "..sourceXPlayer.getName().." a confisqué "..amount.." d' "..itemName.." à "..targetXPlayer.getName(), Config.logs.Fouille)
        
    elseif itemType == 'item_weapon' then
        if amount == nil then amount = 0 end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon   (itemName, amount)

        TriggerClientEvent("esx:showNotification", source, "<C>Vous avez confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
        TriggerClientEvent("esx:showNotification", target, "<C>Quelqu'un vous a confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
		rxeLogsDiscord("[INTERACTION] "..sourceXPlayer.getName().." a confisqué "..ESX.GetWeaponLabel(itemName).." avec "..amount.." balle(s) à "..targetXPlayer.getName(), Config.logs.Fouille)
    end
end)

-------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("corp:adrGet")
AddEventHandler("corp:adrGet", function()
    local _src = source
    local table = {}
    MySQL.Async.fetchAll('SELECT * FROM adr', {}, function(result)
        for k,v in pairs(result) do
            table[v.id] = v
        end
        TriggerClientEvent("corp:adrGet", _src, table)
    end)
end)

RegisterNetEvent("corp:adrDel")
AddEventHandler("corp:adrDel", function(id)
    local _src = source

    MySQL.Async.execute('DELETE FROM adr WHERE id = @id',
    { ['id'] = id },
    function(affectedRows)
        TriggerClientEvent("corp:adrDel", _src)
		rxeLogsDiscord("[AVIS DE RECHERCHE] "..GetPlayerName(_src).." a supprimé un avis de recherche", Config.logs.AvisDeRecherche)
    end
    )
end)

RegisterNetEvent("corp:adrAdd")
AddEventHandler("corp:adrAdd", function(builder)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local name = xPlayer.getName(_src)
    local date = os.date("*t", os.time()).day.."/"..os.date("*t", os.time()).month.."/"..os.date("*t", os.time()).year.." à "..os.date("*t", os.time()).hour.."h"..os.date("*t", os.time()).min
    MySQL.Async.execute('INSERT INTO adr (author,date,firstname,lastname,reason,dangerosity) VALUES (@a,@b,@c,@d,@e,@f)',

    { 
        ['a'] = name,
        ['b'] = date,
        ['c'] = builder.firstname,
        ['d'] = builder.lastname,
        ['e'] = builder.reason,
        ['f'] = builder.dangerosity
    },


    function(affectedRows)
        TriggerClientEvent("corp:adrAdd", _src)
		rxeLogsDiscord("[AVIS DE RECHERCHE] "..name.." a ajouté un avis de recherche à "..builder.firstname.." "..builder.lastname.." pour la raison suivante : "..builder.reason, Config.logs.AvisDeRecherche)
    end
    )
end)


----------------------------------------------------------------------------------------


RegisterNetEvent("corp:cjGet")
AddEventHandler("corp:cjGet", function()
    local _src = source
    local table = {}
    MySQL.Async.fetchAll('SELECT * FROM cj', {}, function(result)
        for k,v in pairs(result) do
            table[v.id] = v
        end
        TriggerClientEvent("corp:cjGet", _src, table)
    end)
end)

RegisterNetEvent("corp:cjDel")
AddEventHandler("corp:cjDel", function(id)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.Async.execute('DELETE FROM cj WHERE id = @id',
    { ['id'] = id },
    function(affectedRows)
        TriggerClientEvent("corp:cjDel", _src)
		rxeLogsDiscord("[INTERACTION] "..xPlayer.getName().." a supprimé le casier judiciaire de ", Config.logs.Casier)
    end
    )
end)

RegisterNetEvent("corp:cjAdd")
AddEventHandler("corp:cjAdd", function(builder)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local name = xPlayer.getName(_src)
    local date = os.date("*t", os.time()).day.."/"..os.date("*t", os.time()).month.."/"..os.date("*t", os.time()).year.." à "..os.date("*t", os.time()).hour.."h"..os.date("*t", os.time()).min
    MySQL.Async.execute('INSERT INTO cj (author,date,firstname,lastname,reason) VALUES (@a,@b,@c,@d,@e)',

    { 
        ['a'] = name,
        ['b'] = date,
        ['c'] = builder.firstname,
        ['d'] = builder.lastname,
        ['e'] = builder.reason
    },

    function(affectedRows)
        TriggerClientEvent("corp:cjAdd", _src)
		rxeLogsDiscord("[INTERACTION] "..name.." a ajouté un casier judiciaire à "..builder.firstname.." "..builder.lastname.." pour "..builder.reason, Config.logs.Casier)
    end
    )
end)

RegisterNetEvent("corp:cjModify")
AddEventHandler("corp:cjModify", function(builder, id, newreason)
    local _src = source

	MySQL.Async.execute('UPDATE cj SET reason = @reason WHERE id = @id', {
		['@id'] = id,
		['@reason'] = builder.newreason
	},
    function(affectedRows)
        TriggerClientEvent("corp:cjModify", _src)
		rxeLogsDiscord("[INTERACTION] "..builder.firstname.." "..builder.lastname.." a modifié le casier judiciaire de "..builder.reason.." en "..builder.newreason, Config.logs.Casier)
    end
	)
end)

------------------------------------------------

RegisterNetEvent("genius:sendcall")
AddEventHandler("genius:sendcall", function()

	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'police' then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "<C>Central LSPD", nil, "<C>Un Citoyen demande un agent de police au commissariat", "CHAR_CALL911", 8)
			rxeLogsDiscord("[INTERACTION] Un citoyen a demandé un agent de police au commissariat", Config.logs.AcceuilPolice)
		end
	end
end)

function sendToDiscordWithSpecialURL (name,message,color,url)
    local DiscordWebHook = url
	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
			["text"]= "rxePolice by Rayan Waize & Enøs",
			},
		}
	}
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent("genius:sendplainte")
AddEventHandler("genius:sendplainte", function(lastname, firstname,phone, subject, desc)

	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'police' then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "<C>~r~Central LSPD", nil, "<C>Une Plainte à était déposer", "CHAR_CALL911", 8)
		end
	end
	sendToDiscordWithSpecialURL("Central LSPD","Plainte émise par: __"..lastname.." "..firstname.. "__ \n\nTél: **__"..phone.."__**\n\nSujet: **__"..subject.."__**\n\nPlainte: "..desc, 2061822, Config.logs.AcceuilPolice)
end)

--------------------------- BOSSSS

RegisterServerEvent('patron:recruter')
AddEventHandler('patron:recruter', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' then
  	xTarget.setJob(societe, 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été recruté")
  	TriggerClientEvent('esx:showNotification', target, "<C>Bienvenue chez la police !")
	  rxeLogsDiscord("[RECRUTEMENT] **"..xPlayer.getName().."** a recruté **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron...")
end
  else
  	if xPlayer.job2.grade_name == 'boss' then
  	xTarget.setJob2(societe, 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été recruté")
  	TriggerClientEvent('esx:showNotification', target, "<C>Bienvenue chez la police !")
	  rxeLogsDiscord("[RECRUTEMENT] **"..xPlayer.getName().."** a recruté **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron...")
end
  end
end)

RegisterServerEvent('patron:promouvoir')
AddEventHandler('patron:promouvoir', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob(societe, tonumber(xTarget.job.grade) + 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été promu")
  	TriggerClientEvent('esx:showNotification', target, "<C>Vous avez été promu chez la police!")
	  rxeLogsDiscord("[PROMOTION] **"..xPlayer.getName().."** a promu **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron ou alors le joueur ne peut pas être promu")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2(societe, tonumber(xTarget.job2.grade) + 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été promu")
  	TriggerClientEvent('esx:showNotification', target, "<C>Vous avez été promu chez la police!")
	  rxeLogsDiscord("[PROMOTION] **"..xPlayer.getName().."** a promu **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron ou alors le joueur ne peut pas être promu")
end
  end
end)

RegisterServerEvent('patron:descendre')
AddEventHandler('patron:descendre', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob(societe, tonumber(xTarget.job.grade) - 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été rétrogradé")
  	TriggerClientEvent('esx:showNotification', target, "<C>Vous avez été rétrogradé de "..societe.."!")
	  rxeLogsDiscord("[RETROGRADE] **"..xPlayer.getName().."** a rétrogradé **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron ou alors le joueur ne peut pas être promu")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2(societe, tonumber(xTarget.job2.grade) - 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été rétrogradé")
  	TriggerClientEvent('esx:showNotification', target, "<C>Vous avez été rétrogradé de "..societe.."!")
	  rxeLogsDiscord("[RETROGRADE] **"..xPlayer.getName().."** a rétrogradé **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron ou alors le joueur ne peut pas être promu")
end
  end
end)

RegisterServerEvent('patron:virer')
AddEventHandler('patron:virer', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob("unemployed", 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été viré")
  	TriggerClientEvent('esx:showNotification', target, "<C>Vous avez été viré de "..societe.."!")
	  rxeLogsDiscord("[VIREMENT] **"..xPlayer.getName().."** a viré **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron ou alors le joueur ne peut pas être viré")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2("unemployed2", 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>Le joueur a été viré")
  	TriggerClientEvent('esx:showNotification', target, "<C>Vous avez été viré de "..societe.."!")
	  rxeLogsDiscord("[VIREMENT] **"..xPlayer.getName().."** a viré **"..xTarget.getName().."**", Config.logs.Boss)
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "<C>t'es pas patron ou alors le joueur ne peut pas être viré")
end
  end
end)

ESX.RegisterServerCallback('five_patron:listesalaire', function(source, cb, job)
	local xPlayer = ESX.GetPlayerFromId(source)
	local listegens = {}
  
	MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job', {
	  ['@job'] = job
	}, function(result)
	  for i = 1, #result, 1 do
		table.insert(listegens, {
		  salaire = result[i].salary,
		  nom = result[i].label,
		  id = result[i].id
		})
	  end
  
	  cb(listegens)
	end)
  end)
  
  RegisterServerEvent('five_society:changersalaire')
  AddEventHandler('five_society:changersalaire', function (id, salaire)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
  
  
	MySQL.Async.execute(
	  'UPDATE job_grades SET salary = @salaire WHERE id = @id',
	  {
		['@salaire'] = salaire,
		['@id'] = id
	  }
	)
	
end)
  
  ESX.RegisterServerCallback('five_patron:listegensjob1', function(source, cb, job)
	local xPlayer = ESX.GetPlayerFromId(source)
	local listegens = {}
  
	MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job', {
	  ['@job'] = job
	}, function(result)
	  for i = 1, #result, 1 do
		table.insert(listegens, {
		  prenom = result[i].firstname,
		  nom = result[i].lastname,
		  steam = result[i].identifier
		})
	  end
  
	  cb(listegens)
	end)
  end)
  

  
RegisterServerEvent('five_society:virersql')
AddEventHandler('five_society:virersql', function (identifier)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute(
		'UPDATE users SET job = @job WHERE identifier = @identifier',
		{
		['@identifier'] = identifier,
		['@job'] = "unemployed"
	})
end)

RegisterServerEvent("five_banque:retraitentreprise")
AddEventHandler("five_banque:retraitentreprise", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	local xMoney = xPlayer.getBank()
	
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_police', function (account)
		if account.money >= total then
			account.removeMoney(total)
			xPlayer.addAccountMoney('bank', total)
			TriggerClientEvent('esx:showAdvancedNotification', source, '<C>Banque Société', '<C>~b~L.S.P.D', "<C>~g~Vous avez retiré "..total.." $ de votre entreprise", 'CHAR_BANK_FLEECA', 10)
		else
			TriggerClientEvent('esx:showNotification', source, "<C>~r~Vous n'avez pas assez d\'argent dans votre entreprise!")
		end
	end)

  end) 
  
  RegisterServerEvent("five_banque:depotentreprise")
  AddEventHandler("five_banque:depotentreprise", function(money)
	  local _source = source
	  local xPlayer = ESX.GetPlayerFromId(_source)
	  local total = money
	  local xMoney = xPlayer.getMoney()
	  
	  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_police', function (account)
		  if xMoney >= total then
			  account.addMoney(total)
			  xPlayer.removeAccountMoney('bank', total)
			  TriggerClientEvent('esx:showAdvancedNotification', source, '<C>Banque Société', '<C>~b~L.S.P.D', "<C>~g~Vous avez déposé "..total.." $ dans votre entreprise", 'CHAR_BANK_FLEECA', 10)
		  else
			  TriggerClientEvent('esx:showNotification', source, "<C>~r~Vous n'avez pas assez d\'argent !")
		  end
	  end)   
end)

ESX.RegisterServerCallback('five_society:getSocietyMoney', function(source, cb, societyName)
	if societyName ~= nil then
	  local society = "society_"..societyName
	  TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
		cb(account.money)
	  end)
	else
	  cb(0)
	end
end)



------------------------------------

RegisterServerEvent('add:addlic')
AddEventHandler('add:addlic', function(target, permis)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)

    MySQL.Async.execute('INSERT INTO user_licenses (type, owner) VALUES (@type, @owner)', {
        ['@type'] = permis,
        ['@owner'] = xTarget.identifier
    })
	
	rxeLogsDiscord("[AJOUT LICENCE] **"..xPlayer.getName().."** a ajouté une licence **"..permis.."** à **"..xTarget.getName().."**", Config.logs.Boss)
end)

RegisterServerEvent('sup:addlic')
AddEventHandler('sup:addlic', function(target, permis)
	local xPlayer = ESX.GetPlayerFromId(source)
  	local xTarget = ESX.GetPlayerFromId(target)

    MySQL.Async.execute('DELETE FROM user_licenses WHERE type = @type AND owner = @owner', {
        ['@type'] = permis,
        ['@owner'] = xTarget.identifier
    })

	rxeLogsDiscord("[SUPP LICENCE] **"..xPlayer.getName().."** a supprimé une licence **"..permis.."** à **"..xTarget.getName().."**", Config.logs.Boss)
end)

--- Garage Systeme ---

ESX.RegisterServerCallback('rxePolice:getVehGarage', function(source, cb, carName)
	MySQL.Async.fetchAll("SELECT * FROM stockpolice WHERE type = @type AND model = @model", {['@type'] = "car", ['@model'] = carName}, function(data)
        cb(#data)
    end)
end)

RegisterServerEvent('rxePolice:addVehInGarage')
AddEventHandler('rxePolice:addVehInGarage', function(carName)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
		MySQL.Async.execute('INSERT INTO stockpolice (type, model) VALUES (@type, @model)', {
			['@type'] = "car",
			['@model'] = carName
		})


		rxeLogsDiscord("[AJOUT VEHICULE] **"..xPlayer.getName().."** a ajouté un véhicule **"..carName.."** au garage", Config.logs.Boss)
	end
end)

RegisterServerEvent('rxePolice:removeVehInGarage')
AddEventHandler('rxePolice:removeVehInGarage', function(carName)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
	    MySQL.Async.fetchAll("SELECT * FROM stockpolice WHERE type = @type AND model = @model", {['@type'] = "car", ['@model'] = carName}, function(data)
		MySQL.Async.execute('DELETE FROM stockpolice WHERE type = @type AND model = @model AND id = @id', {
			['@id'] = data[1].id,
			['@type'] = "car",
			['@model'] = carName
		})
		end)

		rxeLogsDiscord("[SUPP VEHICULE] **"..xPlayer.getName().."** a supprimé un véhicule **"..carName.."** du garage", Config.logs.Boss)
    end
end)


--- Armurerie Systeme ---

ESX.RegisterServerCallback('rxePolice:getWeaponAmmu', function(source, cb, weaponName)
	MySQL.Async.fetchAll("SELECT * FROM stockpolice WHERE type = @type AND model = @model", {['@type'] = "weapon", ['@model'] = weaponName}, function(data)
        cb(#data)
    end)
end)

RegisterServerEvent('rxePolice:addWeaponInAmmu')
AddEventHandler('rxePolice:addWeaponInAmmu', function(weaponName)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
		MySQL.Async.execute('INSERT INTO stockpolice (type, model) VALUES (@type, @model)', {
			['@type'] = "weapon",
			['@model'] = weaponName
		})

		rxeLogsDiscord("[AJOUT ARME] **"..xPlayer.getName().."** a ajouté une arme **"..weaponName.."** à l'armurerie", Config.logs.Boss)
	end
end)

RegisterServerEvent('rxePolice:removeWeaponInAmmu')
AddEventHandler('rxePolice:removeWeaponInAmmu', function(weaponName)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
	    MySQL.Async.fetchAll("SELECT * FROM stockpolice WHERE type = @type AND model = @model", {['@type'] = "weapon", ['@model'] = weaponName}, function(data)
		MySQL.Async.execute('DELETE FROM stockpolice WHERE type = @type AND model = @model AND id = @id', {
			['@id'] = data[1].id,
			['@type'] = "weapon",
			['@model'] = weaponName
		})
		end)

		rxeLogsDiscord("[SUPP ARME] **"..xPlayer.getName().."** a supprimé une arme **"..weaponName.."** de l'armurerie", Config.logs.Boss)
    end
end)


ESX.RegisterServerCallback('rxePolice:getMoneySociety', function(source, cb, priceCar)
	local societyAccount = nil
	TriggerEvent('esx_addonaccount:getSharedAccount', Config.SocietyName, function(account)
		societyAccount = account
	end)
	if societyAccount ~= nil then
		if societyAccount.money >= priceCar then
			societyAccount.removeMoney(priceCar)
			cb(true)
		else
			cb(false)
		end
	else
		cb(false)
	end
end)


ESX.RegisterServerCallback('rxePolice:getPlayer', function(source, cb, target)
	local _targetId = target
	local xTarget = ESX.GetPlayerFromId(_targetId)

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xTarget.identifier
    }, function(result)

	local allInfo = {
		fullName = xTarget.getName(),
		cashMoney = xTarget.getMoney(),
		bankMoney = xTarget.getAccount('bank').money,
		job = xTarget.job.name,
		grade = xTarget.job.grade,
		dateAnniv = result[1].dateofbirth,
		firstname = result[1].firstname,
		lastname = result[1].lastname,
		numberTel = result[1].phone_number,
	}

	cb(allInfo)
	end)
end)


RegisterServerEvent('rxePolice:sendMsg')
AddEventHandler('rxePolice:sendMsg', function(title, msg)
	local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers, 1 do
        local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
        if thePlayer.job.name == 'police' then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], '<C>Information', '<C>'..title, '<C>'..msg, 'CHAR_MP_FM_CONTACT', 8)
        end
    end
end)

local allPlayerInGAV = {}

RegisterServerEvent('rxePolice:addPlayerInGAV')
AddEventHandler('rxePolice:addPlayerInGAV', function(target)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
		if allPlayerInGAV[target] == nil then
			allPlayerInGAV[target] = true
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..GetPlayerName(target).." dans la GAV")
			rxeLogsDiscord("[GAV] **"..xPlayer.getName().."** a ajouté **"..GetPlayerName(target).."** dans la GAV", Config.logs.GavPolice)
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~"..GetPlayerName(target).." est déjà dans la GAV")
		end
	end
end)


RegisterServerEvent('rxePolice:removePlayerInGAV')
AddEventHandler('rxePolice:removePlayerInGAV', function(target)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
		if allPlayerInGAV[target] ~= nil then
			allPlayerInGAV[target] = nil
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré "..GetPlayerName(target).." de la GAV")
			rxeLogsDiscord("[GAV] **"..xPlayer.getName().."** a retiré **"..GetPlayerName(target).."** de la GAV", Config.logs.GavPolice)
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~"..GetPlayerName(target).." n'est pas dans la GAV")
		end
	end
end)

ESX.RegisterServerCallback('rxePolice:getAllPlayerInGAV', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
		cb(allPlayerInGAV)
	end
end)

ESX.RegisterServerCallback('rxePolice:getAllPlayerInGAVForGAV', function(source, cb, target)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if xPlayer.job.name == 'police' then
		if allPlayerInGAV[target] ~= nil then
			cb(true)
		else
			cb(false)
		end
	end
end)

RegisterServerEvent('heli:spotlight')
AddEventHandler('heli:spotlight', function(state)
	local serverID = source
	TriggerClientEvent('heli:spotlight', -1, serverID, state)
end)

ESX.RegisterServerCallback('finalpolice:getEnosStatus', function(source, cb, id, statusName)
	local xPlayer = ESX.GetPlayerFromId(id)
	local status  = xPlayer.get('status')
	print(id)

	for i=1, #status, 1 do
			if status[i].name == statusName then
			cb(status[i])
			break
		end
	end
end)


ESX.RegisterServerCallback('rxePolice:getAllCasier', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspd', {}, function(result)
		cb(result)
    end)
end)


ESX.RegisterServerCallback('rxePolice:getIfHaveCasier', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspd WHERE owner = @owner', {['@owner'] = xPlayer.identifier}, function(result)
		if result[1] then
			cb(true)
		else
			cb(false)
		end
    end)
end)


RegisterServerEvent('rxePolice:addCasier')
AddEventHandler('rxePolice:addCasier', function(target)
	local _src = source
	local _target = target
	local xPlayer = ESX.GetPlayerFromId(_src)
	local xTarget = ESX.GetPlayerFromId(_target)
	if xPlayer.job.name == 'police' then
		MySQL.Async.fetchAll('SELECT * FROM casierlspd WHERE owner = @owner', {
        ['@owner'] = xTarget.identifier
    }, function(result)
        if result[1] then
            TriggerClientEvent('esx:showNotification', _src, "<C>~r~"..xTarget.getName().." a déjà un casier")
        else
            MySQL.Async.execute('INSERT INTO casierlspd (owner, name) VALUES (@owner, @name)', {
				['@owner'] = xTarget.identifier,
				['@name'] = xTarget.getName()
			})
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, name, amount) VALUES (@owner, @type, @name, @amount)', {
				['@owner'] = xTarget.identifier,
				['@type'] = "blackmoney",
				['@name'] = "Argent Sale",
				['@amount'] = 0
			})
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, name, amount) VALUES (@owner, @type, @name, @amount)', {
				['@owner'] = xTarget.identifier,
				['@type'] = "cash",
				['@name'] = "Argent Propre",
				['@amount'] = 0
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté un casier a "..xTarget.getName())
			TriggerClientEvent('esx:showNotification', _target, "<C>~g~"..xPlayer.getName().." vous a creer un casier")
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a creer un casier à **"..xTarget.getName().."**", Config.logs.CasierPolice)
        end
    end)
	end
end)


RegisterServerEvent('rxePolice:removeCasier')
AddEventHandler('rxePolice:removeCasier', function(target)
	local _src = source
	local _target = target
	local xPlayer = ESX.GetPlayerFromId(_src)
	local xTarget = ESX.GetPlayerFromId(_target)
	if xPlayer.job.name == 'police' then
		MySQL.Async.fetchAll('SELECT * FROM casierlspd WHERE owner = @owner', {
		['@owner'] = xTarget.identifier
		}, function(result)
			if result[1] then
				MySQL.Async.execute('DELETE FROM casierlspd WHERE owner = @owner', {
				['@owner'] = xTarget.identifier
				})
				
				if Config.deleteContent then
					MySQL.Async.execute('DELETE FROM casierlspdcontent WHERE owner = @owner', {
					['@owner'] = xTarget.identifier
					})
				end
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez supprimé le casier de "..xTarget.getName())
				TriggerClientEvent('esx:showNotification', _target, "<C>~g~"..xPlayer.getName().." vous a supprimer votre casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a supprimer le casier de **"..xTarget.getName().."**", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~"..xTarget.getName().." n'a pas de casier")
			end
		end)
	end
end)


ESX.RegisterServerCallback('rxePolice:getAllContentCasier', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner', {['@owner'] = xPlayer.identifier}, function(result)
		cb(result)
	end)
end)


ESX.RegisterServerCallback('rxePolice:getAllWeaponInCasier', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = xPlayer.identifier,
		['@type'] = "weapon"
	}, function(result)
		for _,v in pairs(result) do
			local weaponLabel = ESX.GetWeaponLabel(v.name)
			if weaponLabel then
				v.label = weaponLabel
			end
		end
		cb(result)
	end)
end)


ESX.RegisterServerCallback('rxePolice:getAllItemsInCasier', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = xPlayer.identifier,
		['@type'] = "item"
	}, function(result)
		for _,v in pairs(result) do
			local itemLabel = ESX.GetItemLabel(v.name)
			if itemLabel then
				v.label = itemLabel
			end
		end
		cb(result)
	end)
end)


RegisterServerEvent('rxePolice:addItemToCasier')
AddEventHandler('rxePolice:addItemToCasier', function(itemName, amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = xPlayer.identifier,
		['@type'] = "item",
		['@name'] = itemName
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
				['@owner'] = xPlayer.identifier,
				['@type'] = "item",
				['@name'] = itemName,
				['@amount'] = result[1].amount + amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..itemName.." dans le casier")
			xPlayer.removeInventoryItem(itemName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..itemName.." dans le casier", Config.logs.CasierPolice)
		else
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, name, amount) VALUES (@owner, @type, @name, @amount)', {
				['@owner'] = xPlayer.identifier,
				['@type'] = "item",
				['@name'] = itemName,
				['@amount'] = amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..itemName.." dans le casier")
			xPlayer.removeInventoryItem(itemName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..itemName.." dans le casier", Config.logs.CasierPolice)
		end
	end)
end)


RegisterServerEvent('rxePolice:removeItemFromCasier')
AddEventHandler('rxePolice:removeItemFromCasier', function(itemName, amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = xPlayer.identifier,
		['@type'] = "item",
		['@name'] = itemName
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				if result[1].amount - amount == 0 then
					MySQL.Async.execute('DELETE FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = xPlayer.identifier,
						['@type'] = "item",
						['@name'] = itemName
					})
				else
					MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = xPlayer.identifier,
						['@type'] = "item",
						['@name'] = itemName,
						['@amount'] = result[1].amount - amount
					})
				end
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré "..amount.." "..itemName.." du casier")
				xPlayer.addInventoryItem(itemName, amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré "..amount.." "..itemName.." du casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'"..itemName.." dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas de "..itemName.." dans le casier")
		end
	end)
end)


RegisterServerEvent('rxePolice:addWeaponToCasier')
AddEventHandler('rxePolice:addWeaponToCasier', function(weaponName, amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = xPlayer.identifier,
		['@type'] = "weapon",
		['@name'] = weaponName
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
				['@owner'] = xPlayer.identifier,
				['@type'] = "weapon",
				['@name'] = weaponName,
				['@amount'] = result[1].amount + amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..weaponName.." dans le casier")
			xPlayer.removeWeapon(weaponName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..weaponName.." dans le casier", Config.logs.CasierPolice)
		else
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, name, amount) VALUES (@owner, @type, @name, @amount)', {
				['@owner'] = xPlayer.identifier,
				['@type'] = "weapon",
				['@name'] = weaponName,
				['@amount'] = amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..weaponName.." dans le casier")
			xPlayer.removeWeapon(weaponName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..weaponName.." dans le casier", Config.logs.CasierPolice)
		end
	end)
end)


RegisterServerEvent('rxePolice:removeWeaponFromCasier')
AddEventHandler('rxePolice:removeWeaponFromCasier', function(weaponName, amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = xPlayer.identifier,
		['@type'] = "weapon",
		['@name'] = weaponName
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				if result[1].amount - amount == 0 then
					MySQL.Async.execute('DELETE FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = xPlayer.identifier,
						['@type'] = "weapon",
						['@name'] = weaponName
					})
				else
					MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = xPlayer.identifier,
						['@type'] = "weapon",
						['@name'] = weaponName,
						['@amount'] = result[1].amount - amount
					})
				end
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré "..amount.." "..weaponName.." du casier")
				xPlayer.addWeapon(weaponName, amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré "..amount.." "..weaponName.." du casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'"..weaponName.." dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas de "..weaponName.." dans le casier")
		end
	end)
end)


RegisterServerEvent('rxePolice:addPlayerToCasier')
AddEventHandler('rxePolice:addPlayerToCasier', function(target)
	local _src = source
	local _target = target
	local xPlayer = ESX.GetPlayerFromId(_src)
	local xTarget = ESX.GetPlayerFromId(_target)
	MySQL.Async.fetchAll('SELECT * FROM casierlspd WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier,
	}, function(result)
		local casierGuest = json.decode(result[1].guest)
		if casierGuest then
			if not casierGuest[xTarget.identifier] then
				casierGuest[xTarget.identifier] = {}
				MySQL.Async.execute('UPDATE casierlspd SET guest = @guest WHERE owner = @owner', {
					['@owner'] = xPlayer.identifier,
					['@guest'] = json.encode(casierGuest)
				})
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..xTarget.name.." dans le casier")
				TriggerClientEvent('esx:showNotification', _target, "<C>~g~Vous avez été ajouté dans le casier de "..xPlayer.name)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..xTarget.getName().." dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous avez déjà ajouté "..xTarget.name.." dans le casier")
			end
		else
			local casierGuest = {}
			casierGuest[xTarget.identifier] = {}
			MySQL.Async.execute('UPDATE casierlspd SET guest = @guest WHERE owner = @owner', {
				['@owner'] = xPlayer.identifier,
				['@guest'] = json.encode(casierGuest)
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..xTarget.name.." dans le casier")
			TriggerClientEvent('esx:showNotification', _target, "<C>~g~Vous avez été ajouté dans le casier de "..xPlayer.name)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..xTarget.getName().." dans le casier", Config.logs.CasierPolice)
		end
	end)
end)


RegisterServerEvent('rxePolice:removePlayerFromCasier')
AddEventHandler('rxePolice:removePlayerFromCasier', function(target)
	local _src = source
	local _target = target
	local xPlayer = ESX.GetPlayerFromId(_src)
	local xTarget = ESX.GetPlayerFromId(_target)
	MySQL.Async.fetchAll('SELECT * FROM casierlspd WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier,
	}, function(result)
		local casierGuest = json.decode(result[1].guest)
		if casierGuest then
			if casierGuest[xTarget.identifier] then
				casierGuest[xTarget.identifier] = nil
				MySQL.Async.execute('UPDATE casierlspd SET guest = @guest WHERE owner = @owner', {
					['@owner'] = xPlayer.identifier,
					['@guest'] = json.encode(casierGuest)
				})
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré "..xTarget.name.." du casier")
				TriggerClientEvent('esx:showNotification', _target, "<C>~g~Vous avez été retiré du casier de "..xPlayer.name)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré "..xTarget.getName().." du casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas ajouté "..xTarget.name.." dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas ajouté "..xTarget.name.." dans le casier")
		end
	end)
end)


RegisterServerEvent('rxePolice:clearCasier')
AddEventHandler('rxePolice:clearCasier', function()
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspd WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier,
	}, function(result)
		local casierGuest = json.decode(result[1].guest)
		if casierGuest then
			casierGuest = {}
			MySQL.Async.execute('UPDATE casierlspd SET guest = @guest WHERE owner = @owner', {
				['@owner'] = xPlayer.identifier,
				['@guest'] = json.encode(casierGuest)
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez vidé le casier")
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a vidé le casier", Config.logs.CasierPolice)
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas ajouté dans le casier")
		end
	end)
end)


RegisterServerEvent('rxePolice:addMoneyToCasier')
AddEventHandler('rxePolice:addMoneyToCasier', function(amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local myCash = xPlayer.getMoney()
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = xPlayer.identifier,
		['@type'] = 'cash'
	}, function(result)
		if result[1] then
			if myCash >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'cash',
					['@amount'] = result[1].amount + amount
				})
				xPlayer.removeMoney(amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		else
			if myCash >= amount then
				MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'cash',
					['@amount'] = amount
				})
				xPlayer.removeMoney(amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		end
	end)
end)


RegisterServerEvent('rxePolice:removeMoneyFromCasier')
AddEventHandler('rxePolice:removeMoneyFromCasier', function(amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)	
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = xPlayer.identifier,
		['@type'] = 'cash'
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'cash',
					['@amount'] = result[1].amount - amount
				})
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré $"..amount.." dans le casier")
				xPlayer.addMoney(amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré $"..amount.." dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'cash',
					['@amount'] = 0
			})
		end
	end)
end)


RegisterServerEvent('rxePolice:addBlackMoneyToCasier')
AddEventHandler('rxePolice:addBlackMoneyToCasier', function(amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local myCash = xPlayer.getAccount('black_money').money
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = xPlayer.identifier,
		['@type'] = 'blackmoney'
	}, function(result)
		if result[1] then
			if myCash >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'blackmoney',
					['@amount'] = result[1].amount + amount
				})
				xPlayer.removeAccountMoney('black_money', amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." d'argent sale dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		else
			if myCash >= amount then
				MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'blackmoney',
					['@amount'] = amount
				})
				xPlayer.removeAccountMoney('black_money', amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." d'argent sale dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		end
	end)
end)


RegisterServerEvent('rxePolice:removeBlackMoneyFromCasier')
AddEventHandler('rxePolice:removeBlackMoneyFromCasier', function(amount)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = xPlayer.identifier,
		['@type'] = 'blackmoney'
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'blackmoney',
					['@amount'] = result[1].amount - amount
				})
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré $"..amount.." dans le casier")
				xPlayer.addAccountMoney('black_money', amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré $"..amount.." d'argent sale dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = xPlayer.identifier,
					['@type'] = 'blackmoney',
					['@amount'] = 0
			})
		end
	end)
end)



ESX.RegisterServerCallback('rxePolice:getAllContentCasier2', function(source, cb, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner', {['@owner'] = identifier}, function(result)
		cb(result)
	end)
end)


ESX.RegisterServerCallback('rxePolice:getAllWeaponInCasier2', function(source, cb, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = identifier,
		['@type'] = "weapon"
	}, function(result)
		for _,v in pairs(result) do
			local weaponLabel = ESX.GetWeaponLabel(v.name)
			if weaponLabel then
				v.label = weaponLabel
			end
		end
		cb(result)
	end)
end)


ESX.RegisterServerCallback('rxePolice:getAllItemsInCasier2', function(source, cb, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = identifier,
		['@type'] = "item"
	}, function(result)
		for _,v in pairs(result) do
			local itemLabel = ESX.GetItemLabel(v.name)
			if itemLabel then
				v.label = itemLabel
			end
		end
		cb(result)
	end)
end)


RegisterServerEvent('rxePolice:addMoneyToCasier2')
AddEventHandler('rxePolice:addMoneyToCasier2', function(amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local myCash = xPlayer.getMoney()
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = identifier,
		['@type'] = 'cash'
	}, function(result)
		if result[1] then
			if myCash >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = identifier,
					['@type'] = 'cash',
					['@amount'] = result[1].amount + amount
				})
				xPlayer.removeMoney(amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." d'argent dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		else
			if myCash >= amount then
				MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = identifier,
					['@type'] = 'cash',
					['@amount'] = amount
				})
				xPlayer.removeMoney(amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." d'argent dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		end
	end)
end)


RegisterServerEvent('rxePolice:removeMoneyFromCasier2')
AddEventHandler('rxePolice:removeMoneyFromCasier2', function(amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)	
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = identifier,
		['@type'] = 'cash'
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = identifier,
					['@type'] = 'cash',
					['@amount'] = result[1].amount - amount
				})
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré $"..amount.." dans le casier")
				xPlayer.addMoney(amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré $"..amount.." d'argent dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = identifier,
					['@type'] = 'cash',
					['@amount'] = 0
			})
		end
	end)
end)


RegisterServerEvent('rxePolice:addBlackMoneyToCasier2')
AddEventHandler('rxePolice:addBlackMoneyToCasier2', function(amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local myCash = xPlayer.getAccount('black_money').money
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = identifier,
		['@type'] = 'blackmoney'
	}, function(result)
		if result[1] then
			if myCash >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = identifier,
					['@type'] = 'blackmoney',
					['@amount'] = result[1].amount + amount
				})
				xPlayer.removeAccountMoney('black_money', amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." d'argent sale dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		else
			if myCash >= amount then
				MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = identifier,
					['@type'] = 'blackmoney',
					['@amount'] = amount
				})
				xPlayer.removeAccountMoney('black_money', amount)
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté $"..amount.." dans le casier")
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté $"..amount.." d'argent sale dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent")
			end
		end
	end)
end)


RegisterServerEvent('rxePolice:removeBlackMoneyFromCasier2')
AddEventHandler('rxePolice:removeBlackMoneyFromCasier2', function(amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type', {
		['@owner'] = identifier,
		['@type'] = 'blackmoney'
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type', {
					['@owner'] = identifier,
					['@type'] = 'blackmoney',
					['@amount'] = result[1].amount - amount
				})
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré $"..amount.." dans le casier")
				xPlayer.addAccountMoney('black_money', amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré $"..amount.." d'argent sale dans le casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'argent dans le casier")
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, amount) VALUES (@owner, @type, @amount)', {
					['@owner'] = identifier,
					['@type'] = 'blackmoney',
					['@amount'] = 0
			})
		end
	end)
end)

RegisterServerEvent('rxePolice:addItemToCasier2')
AddEventHandler('rxePolice:addItemToCasier2', function(itemName, amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = identifier,
		['@type'] = "item",
		['@name'] = itemName
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
				['@owner'] = identifier,
				['@type'] = "item",
				['@name'] = itemName,
				['@amount'] = result[1].amount + amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..itemName.." dans le casier")
			xPlayer.removeInventoryItem(itemName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..itemName.." dans le casier", Config.logs.CasierPolice)
		else
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, name, amount) VALUES (@owner, @type, @name, @amount)', {
				['@owner'] = identifier,
				['@type'] = "item",
				['@name'] = itemName,
				['@amount'] = amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..itemName.." dans le casier")
			xPlayer.removeInventoryItem(itemName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..itemName.." dans le casier", Config.logs.CasierPolice)
		end
	end)
end)


RegisterServerEvent('rxePolice:removeItemFromCasier2')
AddEventHandler('rxePolice:removeItemFromCasier2', function(itemName, amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = identifier,
		['@type'] = "item",
		['@name'] = itemName
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				if result[1].amount - amount == 0 then
					MySQL.Async.execute('DELETE FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = identifier,
						['@type'] = "item",
						['@name'] = itemName
					})
				else
					MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = identifier,
						['@type'] = "item",
						['@name'] = itemName,
						['@amount'] = result[1].amount - amount
					})
				end
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré "..amount.." "..itemName.." du casier")
				xPlayer.addInventoryItem(itemName, amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré "..amount.." "..itemName.." du casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'"..itemName.." dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas de "..itemName.." dans le casier")
		end
	end)
end)


RegisterServerEvent('rxePolice:addWeaponToCasier2')
AddEventHandler('rxePolice:addWeaponToCasier2', function(weaponName, amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = identifier,
		['@type'] = "weapon",
		['@name'] = weaponName
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
				['@owner'] = identifier,
				['@type'] = "weapon",
				['@name'] = weaponName,
				['@amount'] = result[1].amount + amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..weaponName.." dans le casier")
			xPlayer.removeWeapon(weaponName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..weaponName.." dans le casier", Config.logs.CasierPolice)
		else
			MySQL.Async.execute('INSERT INTO casierlspdcontent (owner, type, name, amount) VALUES (@owner, @type, @name, @amount)', {
				['@owner'] = identifier,
				['@type'] = "weapon",
				['@name'] = weaponName,
				['@amount'] = amount
			})
			TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez ajouté "..amount.." "..weaponName.." dans le casier")
			xPlayer.removeWeapon(weaponName, amount)
			rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a ajouté "..amount.." "..weaponName.." dans le casier", Config.logs.CasierPolice)
		end
	end)
end)


RegisterServerEvent('rxePolice:removeWeaponFromCasier2')
AddEventHandler('rxePolice:removeWeaponFromCasier2', function(weaponName, amount, identifier)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll('SELECT * FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
		['@owner'] = identifier,
		['@type'] = "weapon",
		['@name'] = weaponName
	}, function(result)
		if result[1] then
			if result[1].amount >= amount then
				if result[1].amount - amount == 0 then
					MySQL.Async.execute('DELETE FROM casierlspdcontent WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = identifier,
						['@type'] = "weapon",
						['@name'] = weaponName
					})
				else
					MySQL.Async.execute('UPDATE casierlspdcontent SET amount = @amount WHERE owner = @owner AND type = @type AND name = @name', {
						['@owner'] = identifier,
						['@type'] = "weapon",
						['@name'] = weaponName,
						['@amount'] = result[1].amount - amount
					})
				end
				TriggerClientEvent('esx:showNotification', _src, "<C>~g~Vous avez retiré "..amount.." "..weaponName.." du casier")
				xPlayer.addWeapon(weaponName, amount)
				rxeLogsDiscord("[CASIER] **"..xPlayer.getName().."** a retiré "..amount.." "..weaponName.." du casier", Config.logs.CasierPolice)
			else
				TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas assez d'"..weaponName.." dans le casier")
			end
		else
			TriggerClientEvent('esx:showNotification', _src, "<C>~r~Vous n'avez pas de "..weaponName.." dans le casier")
		end
	end)
end)


function rxeLogsDiscord(message,url)
    local DiscordWebHook = url
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Police", content = message}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('rxePolice:logsEvent')
AddEventHandler('rxePolice:logsEvent', function(message, url)
	rxeLogsDiscord(message,url)
end)