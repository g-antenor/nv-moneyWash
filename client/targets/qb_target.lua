local starterPedSpawned = nil

function Starter(status)
    local pedModel = Config.PedGetInfo
    local pedCoords = Config.StarterLocation
    
    if not status then
        if starterPedSpawned then
            DeleteEntity(starterPedSpawned)
            starterPedSpawned = nil
        end
        return
    end

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end

    starterPedSpawned = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z - 1.0, pedCoords.w, false, true)
    TaskStartScenarioInPlace(starterPedSpawned, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    SetBlockingOfNonTemporaryEvents(starterPedSpawned, true)
    SetEntityAsMissionEntity(starterPedSpawned, true, true)
    SetEntityInvincible(starterPedSpawned, true)
    FreezeEntityPosition(starterPedSpawned, true)

    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(starterPedSpawned, {
            options = {
                {
                    type = 'server',
                    event = 'moneywashing:server:checkStarterItem',
                    icon = 'fas fa-money',
                    label = 'Pegar informação',
                },
            },
            distance = 2.0
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(starterPedSpawned, {
            {
                icon = 'fas fa-money',
                label = 'Pegar informação',
                onSelect = function()
                    TriggerServerEvent('moneywashing:server:checkStarterItem')
                end
            },
        })
    end
end

function BuyKey(ped)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    icon = 'fa-solid fa-key',
                    label = 'Comprar Chave',
                    type = 'client',
                    event = 'moneywashing:client:GetKey',
                }
            }
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'buy_key',
                icon = 'fa-solid fa-key',
                label = 'Comprar Chave',
                onSelect = function()
                    TriggerEvent('moneywashing:client:GetKey')
                end
            }
        })
    end
end

function GetKey(location, BlipGetKey)
    local boxZoneName = "moneywashing_key_zone"

    if BlipGetKey then
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
                        label = 'Pegar Chave',
                        type = 'server',
                        event = 'moneywashing:server:GetKey',
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
                        label = 'Pegar Chave',
                        onSelect = function()
                            TriggerServerEvent('moneywashing:server:GetKey')
                        end
                    }
                }
            })
        end
    end
end


-- Starter Machine Target
function Machines()
    for _, machineWash in pairs(Config.Machines) do
        if Config.Target == 'qb' then
            exports['qb-target']:AddBoxZone("moneywashing_machine_zone_" .. machineWash.id, machineWash.coords, 1.0, 4.0, {
                name = "moneywashing_machine_zone_" .. machineWash.id,
                debugPoly = false,
                minZ = machineWash.coords.z - 1,
                maxZ = machineWash.coords.z + 1,
            }, {
                options = {
                    {
                        icon = "fas fa-sign-in-alt",
                        label = "Money laundering",
                        canInteract = function()
                            return true
                        end,
                        action = function()
                            TriggerServerEvent("moneywashing:server:startWashMoney", machineWash.id)
                        end
                    },
                },
                distance = 2.0
            })  
        elseif Config.Target == 'ox' then
            exports.ox_target:addBoxZone({
                coords = machineWash.coords,
                size = vec3(1.0, 1.0, 4.0),
                options = {
                    {
                        icon = "fas fa-sign-in-alt",
                        label = "Money laundering",
                        canInteract = function()
                            return true
                        end,
                        onSelect = function()
                            TriggerServerEvent("moneywashing:server:startWashMoney", machineWash.id)
                        end
                    },
                },
            })
        end
    end
end

function MachineGun(hasStarted, isOnCooldown)
    if Config.Target == 'qb' then
        exports['qb-target']:AddBoxZone("moneywashing_machinegun_zone", Config.MachineGun.coords, 1.0, 4.0, {
            name = "moneywashing_machinegun_zone",
            heading = Config.MachineGun.coords.w,
            debugPoly = false,
            minZ = Config.MachineGun.coords.z - 1,
            maxZ = Config.MachineGun.coords.z + 1,
        }, {
            options = {
                {
                    icon = "fas fa-sign-in-alt",
                    label = "Ligar Maquina",
                    type = 'client',
                    event = 'moneywashing:client:InitHacking',
                    canInteract = function()
                        local hasCop = lib.callback.await('moneywashing:server:getCopsAmount', false)
                        return not hasStarted and hasCop >= Config.MinCop and not isOnCooldown
                    end,
                },
                {
                    icon = "fas fa-sign-in-alt",
                    label = "Money laundering",
                    type = 'server',
                    event = "moneywashing:server:startWashMoney",
                    arg = Config.MachineGun.id,
                    canInteract = function()
                        local hasCop = lib.callback.await('moneywashing:server:getCopsAmount', false)
                        return hasStarted and hasCop >= Config.MinCop and not isOnCooldown
                    end
                },
            },
            distance = 2.0
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addBoxZone({
            coords = Config.MachineGun.target,
            size = vec3(1.0, 1.0, 1.0),
            -- debug = true,
            options = {
                {
                    icon = "fas fa-sign-in-alt",
                    label = "Ligar Maquina",
                    canInteract = function()
                        local hasCop = lib.callback.await('moneywashing:server:getCopsAmount', false)
                        return not hasStarted and hasCop >= Config.MinCop and not isOnCooldown
                    end,
                    onSelect = function()
                        TriggerServerEvent("moneywashing:client:InitHacking")
                    end
                },
                {
                    icon = "fas fa-sign-in-alt",
                    label = "Lavar Dinheiro",
                    canInteract = function()
                        local hasCop = lib.callback.await('moneywashing:server:getCopsAmount', false)
                        return hasStarted and hasCop >= Config.MinCop and not isOnCooldown
                    end,
                    onSelect = function()
                        TriggerServerEvent("moneywashing:server:startWashMoney", Config.MachineGun.id)
                    end
                },
            },
        })
    end
end

function RemoveKeyTarget()
    if Config.Target == 'qb' then
        exports['qb-target']:RemoveZone('moneywashing_key_zone')
    elseif Config.Target == 'ox' then
        exports.ox_target:removeZone('moneywashing_key_zone')
    end
end



