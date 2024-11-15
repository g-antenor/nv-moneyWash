local starterPedSpawned = nil

function Starter(status)
    local pedModel = 'a_m_m_business_01' 
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

    SetEntityInvincible(starterPedSpawned, true)
    SetBlockingOfNonTemporaryEvents(starterPedSpawned, true)
    TaskStartScenarioInPlace(starterPedSpawned, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)

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

function BuyKey(ped)
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

function GetKey(location, BlipGetKey)
    local boxZoneName = "moneywashing_key_zone"

    if BlipGetKey then
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

function RemoveKeyTarget()
    exports.ox_target:removeZone('moneywashing_key_zone')
end



