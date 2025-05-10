local function generateRandomPlate()
    local charset = {}
    for i = 48, 57 do table.insert(charset, string.char(i)) end
    for i = 65, 90 do table.insert(charset, string.char(i)) end

    local plate = ""
    for i = 1, 8 do
        plate = plate .. charset[math.random(1, #charset)]
    end
    return plate
end

local function generateRandomColors()
    local primary = math.random(0, 160)
    local secondary = math.random(0, 160)
    return { primary = primary, secondary = secondary }
end

local function getDefaultVehicleMods()
    return {
        modEngine = 1,
        modBrakes = 1,
        modTransmission = 1,
        modSuspension = 1,
        modArmor = 1,
        modTurbo = false,
        modXenon = false,
        windowTint = 1,
        color1 = math.random(0, 160),
        color2 = math.random(0, 160)
    }
end

RegisterServerEvent("LNS_StarterPack:claimPack", function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local charId = Player.PlayerData.citizenid

    exports.oxmysql:execute('SELECT starter_pack_claimed FROM players WHERE citizenid = ?', {charId}, function(result)
        if result[1] and (result[1].starter_pack_claimed == 1 or result[1].starter_pack_claimed == true) then
            TriggerClientEvent('ox_lib:notify', src, {
                description = "You've already claimed your starter pack.",
                type = "error"
            })
            return
        end

        for _, item in pairs(Settings.Items) do
            exports.ox_inventory:AddItem(src, item.name, item.amount)
        end

        local vehicleModelList = Settings.Vehicle.model
        local vehicleModel = vehicleModelList[math.random(1, #vehicleModelList)]
        local plate = generateRandomPlate()
        local colors = generateRandomColors()
        local defaultMods = getDefaultVehicleMods()

        local vehicleData = json.encode({
            model = vehicleModel,
            plate = plate,
            fuelLevel = 100,
            engineHealth = 1000.0,
            bodyHealth = 1000.0,
            colors = colors,
            windows = {},
            doors = {},
            tires = {},
            mods = defaultMods
        })

        exports.oxmysql:insert([[
            INSERT INTO player_vehicles (
                citizenid, plate, vehicle, hash, garage, state,
                in_garage, registered, fuel, engine, body,
                status, damage, mods, glovebox, trunk
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            charId,
            plate,
            vehicleModel,
            vehicleModel,
            Settings.Vehicle.garage or "pillbox",
            0,
            1,
            1,
            100,
            1000.0,
            1000.0,
            json.encode({}),
            json.encode({}),
            json.encode(defaultMods),
            json.encode({}),
            json.encode({})
        })

        qbx.spawnVehicle({
            model = joaat(vehicleModel),
            spawnSource = Settings.Vehicle.coords,
            warp = false,
            props = { plate = plate }
        })

        TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)

        exports.oxmysql:update('UPDATE players SET starter_pack_claimed = ? WHERE citizenid = ?', {1, charId})

        TriggerClientEvent('ox_lib:notify', src, {
            description = "Starter pack claimed!",
            type = "success"
        })
    end)
end)