local pedSpawned = false
local pedEntity

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(100) end

    local pedData = Settings.Ped
    local modelHash = joaat(pedData.model)

    lib.requestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    pedEntity = CreatePed(4, modelHash, pedData.coords, pedData.heading, false, true)
    FreezeEntityPosition(pedEntity, true)
    SetEntityInvincible(pedEntity, true)
    SetBlockingOfNonTemporaryEvents(pedEntity, true)

    pedSpawned = true
end)

CreateThread(function()
    while not pedSpawned do Wait(100) end

    exports.ox_target:addLocalEntity(pedEntity, {
        {
            label = "Claim Starter Pack",
            icon = "fa-solid fa-box",
            distance = Settings.Ped.interactDistance,
            onSelect = function()
                TriggerServerEvent("LNS_StarterPack:claimPack")
            end
        }
    })
end)