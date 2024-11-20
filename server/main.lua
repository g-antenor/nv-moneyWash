QBCore = exports['qb-core']:GetCoreObject()

-- Check
QBCore.Functions.CreateCallback('moneywashing:server:checkItemCount', function(source, cb, itemName)
    cb(utils.SearchItem(source, itemName))
end)

QBCore.Functions.CreateCallback('moneywashing:server:CheckOpenMenu', function(source, cb, netId)
    local machines = getMachines()
    local currentTime = os.time()
    local machineId = NetworkGetEntityFromNetworkId(netId)
    if not machines[machineId] then return cb(false) end

    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machines[machineId].id})
    if response[1] then
        local cooldown = tonumber(response[1].cooldown)
        local washTime = tonumber(response[1].wash_time)

        if cooldown and currentTime < cooldown then
            TriggerClientEvent('moneywashing:client:Notify', source, Lang:t('notify.error.cooldown_active'), 'error', 5000)
            return cb(false)
        elseif cooldown and currentTime >= cooldown then
            MySQL.update('UPDATE money_laundry_machines SET cooldown = NULL WHERE id = ?', {machines[machineId].id})
        end

        if washTime > 0 and currentTime < washTime then
            TriggerClientEvent('moneywashing:client:Notify', source, Lang:t('notify.error.money_not_ready'), 'error', 5000)
            return cb(false)
        end
    end

    cb(true)
end)

QBCore.Functions.CreateCallback('moneywashing:server:CheckCollectMoney', function(source, cb, netId)
    local machines = getMachines()
    local currentTime = os.time()
    local machine = nil
    local machineId = NetworkGetEntityFromNetworkId(netId)
    if machines[machineId] then machine = machines[machineId] else return end
    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machine.id})
    
    if response[1] then
        local washTime = tonumber(response[1].wash_time)
        if washTime > 0 and currentTime > washTime then cb(false) end
    end
    
    cb(true)
end)


-- Washing
QBCore.Functions.CreateCallback('moneywashing:server:DepositMoney', function(source, cb, netId, amount)
    local machines = getMachines()
    local currentTime = os.time()
    local machineId = NetworkGetEntityFromNetworkId(netId)
    if not machines[machineId] then return cb(false) end

    local time = currentTime + Config.Cooldown
    local depositAmount = amount * Config.Multiply

    if utils.RemoveItem(source, Config.Money, amount) then
        MySQL.update('UPDATE money_laundry_machines SET amount = ?, on_off = ?, wash_time = ? WHERE id = ?', {
            depositAmount, 1, time, machines[machineId].id
        }, function(affectedRows)
            cb(affectedRows > 0)
        end)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('moneywashing:server:CollectMoney', function(source, cb, netId)
    local Player = QBCore.Functions.GetPlayer(source)
    local currentTime = os.time()
    local machines = getMachines()
    local machineId = NetworkGetEntityFromNetworkId(netId)
    if not machines[machineId] then return cb(false) end

    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machines[machineId].id})
    if not response[1] then return cb(false) end

    local washTime = tonumber(response[1].wash_time)
    local amount = tonumber(response[1].amount)
    local rounds = tonumber(response[1].rounds)
    local maxRounds = Config.MaxRounds

    if currentTime >= washTime then
        if rounds >= maxRounds then
            local cooldownTime = currentTime + Config.CooldownTime
            Player.Functions.AddMoney('cash', amount)
            MySQL.update('UPDATE money_laundry_machines SET cooldown = ?, rounds = 0, on_off = 0, wash_time = 0, amount = 0 WHERE id = ?', {cooldownTime, machines[machineId].id})
            TriggerClientEvent('moneywashing:client:Notify', source, Lang:t('notify.error.cooldown_set'), 'error', 5000)
            return cb(true)
        else
            MySQL.update('UPDATE money_laundry_machines SET rounds = rounds + 1, amount = 0, on_off = 0, wash_time = 0 WHERE id = ?', {machines[machineId].id}, function()
                Player.Functions.AddMoney('cash', amount)
                cb(true)
            end)
        end
    else
        cb(false)
    end
end)

