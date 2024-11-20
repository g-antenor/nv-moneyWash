QBCore = exports['qb-core']:GetCoreObject()
local machines = {}

function getMachines() return machines end

local function setupMachines()
    local result = MySQL.Sync.fetchAll('SELECT * FROM money_laundry_machines')

    for _, v in pairs(result) do
        local modelHash = GetHashKey(Config.ModelProp)
        local coords = json.decode(v.coords)
        local machine = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z + 0.5, true, true, false)
        SetEntityHeading(machine, v.heading)
        FreezeEntityPosition(machine, true)

        machines[machine] = {
            id = v.id,
            coords = v.coords,
            round = 0
        }
    end
end

local function destroyAllMachines()    
    for k, v in pairs(machines) do
        if DoesEntityExist(k) then
            DeleteEntity(k)
            machines[k] = nil
        end
    end
end

RegisterNetEvent('moneywashing:server:CreateMachine', function(coords, heading, model, slot)
    if utils.RemoveItem(source, Config.Item, 1, slot) then
        local modelHash = GetHashKey(model)
        local machine = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z + 0.5, true, true, false)
        SetEntityHeading(machine, heading)
        FreezeEntityPosition(machine, true)

        MySQL.Async.insert('INSERT INTO money_laundry_machines (coords, heading, on_off) VALUES (?, ?, ?)', {
            json.encode({x = coords.x, y = coords.y, z = coords.z}),
            heading,
            0
        }, function(id)
            machines[machine] = {
                id = id,
                coords = coords,
                heading = heading
            }
            TriggerClientEvent('moneywashing:client:syncPlantList', -1)
        end)
    end
end)

RegisterNetEvent('moneywashing:server:destroyMachine', function(netId)
    local src = source
    local currentTime = os.time()
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not machines[entity] then return end
    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machines[entity].id})
    local cooldown = tonumber(response[1].cooldown)
    local timeWash = tonumber(response[1].wash_time)
    
    if cooldown and currentTime < cooldown or timeWash > 0 and currentTime < timeWash then 
        TriggerClientEvent('moneywashing:client:Notify', src, Lang:t('notify.error.cooldown_active'), 'error', 5000)

    elseif DoesEntityExist(entity) then
        MySQL.query('DELETE from money_laundry_machines WHERE id = ?', { machines[entity].id })

        utils.AddItem(src, Config.Item, 1)
        DeleteEntity(entity)

        machines[entity] = nil
        TriggerClientEvent('moneywashing:client:syncPlantList', -1)
    end
end)

AddEventHandler('onResourceStart', function()
    setupMachines()
    if Config.ClearOnStartup then
        Wait(5000)
        for k, v in pairs(machines) do
            if machines[k].health == 0 then
                DeleteEntity(k)
                MySQL.query('DELETE from money_laundry_machines WHERE id = :id', { ['id'] = machines[k].id })
                machines[k] = nil
            end
        end
    end

    TriggerClientEvent('moneywashing:client:syncPlantList', -1)
end)

AddEventHandler('onResourceStop', function()
    destroyAllMachines()
end)

QBCore.Functions.CreateCallback('moneywashing:server:GetMachines', function(source, cb)
    local result = MySQL.query.await('SELECT * FROM money_laundry_machines')
    local machines = {}

    for _, row in pairs(result) do
        local coords = json.decode(row.coords)

        table.insert(machines, {
            id = row.id,
            coords = vector4(coords.x, coords.y, coords.z, row.heading),
            model = Config.ModelProp
        })
    end

    cb(machines)
end)

QBCore.Functions.CreateUseableItem(Config.Item, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then TriggerClientEvent("moneyWash:client:placeProp", src, item) end
end)