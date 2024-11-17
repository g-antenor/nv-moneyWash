QBCore = exports['qb-core']:GetCoreObject()
local globalCooldown = {}

local function startGlobalCooldown(duration)
    TriggerClientEvent('moneywashing:client:setCooldown', -1, true) -- Sincroniza com os clientes

    SetTimeout(duration, function()
        TriggerClientEvent('moneywashing:client:setCooldown', -1, false) -- Sincroniza com os clientes
    end)
end

-- Check
QBCore.Functions.CreateCallback('moneywashing:server:checkItemCount', function(source, cb, itemName)
    cb(utils.SearchItem(source, itemName))
end)

QBCore.Functions.CreateCallback('moneywashing:server:CheckCooldownGun', function(source, cb, machineId)
    local currentTime = os.time()
    
    if machineId == 100 then
        if globalCooldown[machineId] and currentTime < globalCooldown[machineId].time then cb(false) end
        if globalCooldown[machineId] and currentTime > globalCooldown[machineId].time then globalCooldown[machineId] = nil end
    end

    cb(true)
end)

QBCore.Functions.CreateCallback('moneywashing:server:CheckCooldown', function(source, cb, machineId)
    for _, v in pairs(Config.Machines) do
        if v.id == machineId then
            if v.round >= 3 then cb(false) end
        end
    end
    
    cb(true)
end)

QBCore.Functions.CreateCallback('moneywashing:server:CheckOpenMenu', function(source, cb, machineId)
    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machineId})
    local currentTime = os.time()
    
    if response[1] then
        local washTime = tonumber(response[1].wash_time)
        if currentTime < washTime then cb(false) end
    end
    
    cb(true)
end)

QBCore.Functions.CreateCallback('moneywashing:server:CheckCollectMoney', function(source, cb, machineId)
    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machineId})
    local currentTime = os.time()
    
    if response[1] then
        local washTime = tonumber(response[1].wash_time)
        if currentTime >= washTime then cb(false) end
    end
    
    cb(true)
end)


QBCore.Functions.CreateCallback('moneywashing:server:DepositMoney', function(source, cb, machineId, amount)
    local machines = machineId == 100 and Config.MachineGun or Config.Machines[machineId]
    local currentTime = os.time()
    
    if machines.id == 100 and machines.round >= 1 then
         
        if not globalCooldown[machineId] then 
            globalCooldown[machineId] = { time = currentTime + 10 * 60 }
        elseif currentTime > globalCooldown[machineId].time then
            globalCooldown[machineId] = nil
            machines.round = 0
        end

        cb(false)
    elseif machines.id == machineId and machines.round >= 2 then
        cb(false)
    else
        if utils.RemoveItem(source, Config.Money, amount) then
        
            if machineId == 100 then
                local time = currentTime + (2 * 60)
                machines.round = machines.round + 1
                amount = amount * 0.90
        
                MySQL.insert('INSERT INTO `money_laundry_machines` (id, amount, on_off, wash_time) VALUES (?, ?, ?, ?)', {
                    machineId, amount, true, time
                })
    
                cb(true)
            else
                local time = currentTime + (2 * 60)
                machines.round = machines.round + 1
                amount = amount * 0.25
    
    
                MySQL.insert('INSERT INTO `money_laundry_machines` (id, amount, on_off, wash_time) VALUES (?, ?, ?, ?)', {
                    machineId, amount, true, time
                })
    
                cb(true)
            end
        end 
    end  
end)


-- Drop
QBCore.Functions.CreateCallback('moneywashing:server:DropKey', function(source, cb, itemName)
    cb(utils.AddItem(source, itemName))
end)

QBCore.Functions.CreateCallback('moneywashing:server:CollectMoney', function(source, cb, machineId)
    local Player = QBCore.Functions.GetPlayer(source)
    local machine = machineId == 100 and Config.MachineGun or Config.Machines[machineId]
    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machineId})
    local washTime = tonumber(response[1].wash_time)
    local amount = tonumber(response[1].amount)
    local currentTime = os.time()
    
    if not machine then cb(false) end

    if not response or #response == 0 then cb(false) end

    if currentTime >= washTime then
        if machineId == 100 then startGlobalCooldown(Config.CooldownTime) end
        
        MySQL.Async.execute('DELETE FROM money_laundry_machines WHERE id = ?', {machineId}, function(affectedRows)
            if affectedRows > 0 then Player.Functions.AddMoney('cash', amount) cb(true) end
            cb(false)
        end)
    end
end)


QBCore.Functions.CreateCallback('moneywashing:server:InitBuy', function(source, cb, itemName)
    if utils.SearchItem(source, itemName) > 0 then
        utils.RemoveItem(source, itemName, 1)
        cb(true)
    else
        cb(false)
    end
end)


QBCore.Functions.CreateCallback('moneywashing:server:getCopsAmount', function(source, cb, policeMin)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()

    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == "leo" and v.PlayerData.job.onduty then
            amount += 1
        end
    end

    cb(amount >= policeMin)
end)


QBCore.Functions.CreateCallback('moneywashing:server:ToggleDoor', function(source, cb, doorId)
    local doorStatus = exports.ox_doorlock:getDoor(doorId)

    if doorStatus.state == 1 then
        exports.ox_doorlock:setDoorState(doorId, 0)
    else
        exports.ox_doorlock:setDoorState(doorId, 1)
    end
    cb(true)
end)

QBCore.Functions.CreateUseableItem(Config.Key, function(source) 
    TriggerClientEvent('moneywashing:client:UseLabKey', source)
end)