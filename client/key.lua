QBCore = exports['qb-core']:GetCoreObject()

local inRoute = false
local starterCalled = false

local currentLocation = nil
local currentBlip = nil
local starterPed = nil
local currentPed = nil

local function RemoveKeyTarget()
    if Config.Target == 'qb' then
        exports['qb-target']:RemoveZone('moneywashing_key_zone')
    elseif Config.Target == 'ox' then
        exports.ox_target:removeZone('moneywashing_key_zone')
    end
end

local function Finish()
    QBCore.Functions.TriggerCallback('moneywashing:server:DropKey', function(result)
        if result then
            utils.Notify(Lang:t('notify.success.collected_key'), 'success', 5000)

            if currentPed then
                DeleteEntity(currentPed)
                currentPed = nil
            end
        
            if currentBlip then
                RemoveBlip(currentBlip)
                currentBlip = nil
            end

            RemoveKeyTarget()
            inRoute = false
        end
    end, Config.Key)
end

local function GetKey(location)
    local boxZoneName = "moneywashing_key_zone"

    if Config.Target == 'qb' then
        exports['qb-target']:AddBoxZone(boxZoneName, vector3(location.x, location.y, location.z), 2.0, 2.0, {
            name = boxZoneName,
            heading = location.w,
            debugPoly = false,
            minZ = location.z - 1,
            maxZ = location.z + 1,
        }, {
            options = {
                {
                    icon = 'fa-solid fa-key',
                    label = Lang:t('target.getKey'),
                    action = function()
                        Finish()
                    end
                }
            },
            distance = 2.0
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addBoxZone({
            name = boxZoneName,
            coords = vector3(location.x, location.y, location.z),
            size = vec3(2.0, 2.0, 2.0),
            rotation = location.w,
            debug = false,
            options = {
                {
                    name = 'collect_key',
                    icon = 'fa-solid fa-key',
                    label = Lang:t('target.getKey'),
                    onSelect = function()
                        Finish()
                    end
                }
            }
        })
    end
end

local function ClearCurrents(location)
    if currentPed then
        DeleteEntity(currentPed)
        currentPed = nil
    end

    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end
    
    currentBlip = utils.CreateBlips(location, Lang:t('notify.success.buyKey_blip'))
    utils.Notify(Lang:t('notify.success.getKey_blip'), 'success', 5000)
    GetKey(location)
end

local function BuyKey(ped)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    icon = 'fa-solid fa-key',
                    label = Lang:t('target.buyKey'),
                    action = function()
                        local location = Config.KeyLocations[math.random(1, #Config.KeyLocations)]
                        ClearCurrents(location)
                        utils.CreateBlips(location, Lang:t('notify.success.buyKey_blip'))
                    end
                }
            }
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'buy_key',
                icon = 'fa-solid fa-key',
                label = Lang:t('target.buyKey'),
                onSelect = function()
                    local location = Config.KeyLocations[math.random(1, #Config.KeyLocations)]
                    ClearCurrents(location)
                    utils.CreateBlips(location, Lang:t('notify.success.buyKey_blip'))
                end
            }
        })
    end
end

local function Starter()
    if starterPed then
        DeleteEntity(starterPed)
        starterPed = nil
    end

    starterPed = utils.CreatePedModel(Config.PedGetInfo, Config.StarterLocation)

    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(starterPed, {
            options = {
                {
                    icon = 'fas fa-money',
                    label = Lang:t('target.start_route_to_buy'),
                    action = function()
                        QBCore.Functions.TriggerCallback('moneywashing:server:InitBuy', function(amount)
                            if amount then 
                                currentLocation = Config.Locations[math.random(1, #Config.Locations)]
                                currentPed      = utils.CreatePedModel(Config.PedModel, currentLocation)
                                currentBlip     = utils.CreateBlips(currentLocation, Lang:t('blips.start_buy'))
                                inRoute = true

                                utils.Notify(Lang:t('notify.success.start_route_to_buy'), 'success', 5000)
                                local animation = utils.Animations("cellphone@", "cellphone_text_read_base", 2000, Lang:t('progress.put_money_in_machine'))
                                if animation then BuyKey(currentPed) end
                            else
                                utils.Notify(Lang:t('notify.error.not_item'), 'error', 5000)
                            end
                        end, Config.Starter)
                    end
                },
            },
            distance = 2.0
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(starterPed, {
            {
                icon = 'fas fa-money',
                label = Lang:t('target.start_route_to_buy'),
                onSelect = function()
                    QBCore.Functions.TriggerCallback('moneywashing:server:checkItemCount', function(amount)
                        if amount > 0 then 
                            currentLocation = Config.Locations[math.random(1, #Config.Locations)]
                            currentPed      = utils.CreatePedModel(Config.PedModel, currentLocation)
                            currentBlip     = utils.CreateBlips(currentLocation, Lang:t('blips.start_buy'))
                            inRoute = true

                            utils.Notify(Lang:t('notify.success.start_route_to_buy'), 'success', 5000)

                            local animation = utils.Animations("cellphone@", "cellphone_text_read_base", 2000, Lang:t('progress.put_money_in_machine'))
                            if animation then BuyKey(currentPed) end
                        else
                            utils.Notify(Lang:t('notify.error.not_item'), 'error', 5000)
                        end
                    end, Config.Starter)
                end
            },
        })
    end
end

RegisterNetEvent('moneywashing:client:UseLabKey', function()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    
    for _, door in pairs(Config.DoorsWashing) do
        local dist = GetDistanceBetweenCoords(pos, door.coords)
        
        if dist < 1.5 then
            QBCore.Functions.TriggerCallback('moneywashing:server:ToggleDoor', function(status)
                if status then
                    utils.Notify(Lang:t('notify.success.use_key'), 'success', 5000)
                end
            end, door.doorId)
        end
    end
end)

CreateThread(function()
    for _, door in pairs(Config.DoorsWashing) do
        AddDoorToSystem(door.hash, door.hash, door.coords.x, door.coords.y, door.coords.z, false, false, false)
        DoorSystemSetDoorState(door.hash, 1, false, true)
    end

    while true do
        local time = GetClockHours()

        if time >= 0 and time <= 3 and not inRoute and not starterCalled then
            starterCalled = true
            Starter()
        elseif time > 3 and starterCalled then
            starterCalled = false
            
            if starterPed then
                DeleteEntity(starterPed)
                starterPed = nil
            end
        end

        Wait(1000)
    end
end)
