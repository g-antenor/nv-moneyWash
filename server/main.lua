QBCore = exports['qb-core']:GetCoreObject()
local globalCooldown = false

local function GetCurrentCops()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.type == "leo" and v.PlayerData.job.onduty then
            amount += 1
        end
    end
    return amount
end

function startGlobalCooldown(duration)
    globalCooldown = true
    TriggerClientEvent('moneywashing:client:setCooldown', -1, true) -- Sincroniza com os clientes

    SetTimeout(duration, function()
        globalCooldown = false
        TriggerClientEvent('moneywashing:client:setCooldown', -1, false) -- Sincroniza com os clientes
    end)
end

lib.callback.register('moneywashing:server:getCopsAmount', function()
    return GetCurrentCops()
end)

QBCore.Functions.CreateCallback('moneywashing:server:checkItemCount', function(source, cb, itemName)
    local itemCount = exports['qb-inventory']:GetItemCount(source, itemName)
    -- Retorna o valor encontrado ou 0 se for nulo
    cb(itemCount or 0)
end)

RegisterNetEvent('moneywashing:server:checkStarterItem', function()
    local src = source
    local hasItem = 0

    if Config.Inventory == 'ox' then 
        hasItem = exports.ox_inventory:Search(src, 'count', Config.Starter)
    elseif Config.Inventory == 'qb' then
        hasItem = exports['qb-inventory']:GetItemCount(src, Config.Starter)
    end

    if hasItem and hasItem >= 1 then
        if Config.Inventory == 'ox' then
            exports.ox_inventory:RemoveItem(src, Config.Starter, 1)
        elseif Config.Inventory == 'qb' then
            exports['qb-inventory']:RemoveItem(src, Config.Starter, 1)
        end
        TriggerClientEvent('moneywashing:client:Animation', src, 1)
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = "Você não possui o item necessário!"})
    end
end)

RegisterNetEvent('moneywashing:server:BuyKey', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Config.PriceStarter) then
        TriggerClientEvent('moneywashing:client:Animation', src)
    else
        TriggerClientEvent('QBCore:Notify', src, "Você não possui dinheiro suficiente!", "error")
    end
end)

RegisterNetEvent('moneywashing:server:GetKey', function()
    if Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(source, Config.Key, 1)
    elseif Config.Inventory == 'qb' then
        exports['qb-inventory']:AddItem(source, Config.Key, 1)
    end
    TriggerClientEvent('moneywashing:client:FinishRoute', source)
end)

RegisterNetEvent('moneywashing:server:SetDoor', function(doorId)
    local doorStatus = exports.ox_doorlock:getDoor(doorId)

    if doorStatus.state == 1 then
        exports.ox_doorlock:setDoorState(doorId, 0)
    else
        exports.ox_doorlock:setDoorState(doorId, 1)
    end
end)

-- SQL
RegisterNetEvent("moneywashing:server:startWashMoney", function(machineId)
    local src = source
    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machineId})

    if response[1] and response[1].id == machineId then
        
        local washTime = tonumber(response[1].wash_time)
        local currentTime = os.time()
        
        if currentTime >= washTime then
            TriggerClientEvent('moneywashing:client:showMenu', src, machineId, false)
        end
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'A máquina está lavando. Espere ela desligar.', 'error') 
    else
        TriggerClientEvent('moneywashing:client:showMenu', src, machineId, true)
    end
end)

RegisterNetEvent('moneywashing:server:collectMoney', function(machineId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local machine = machineId == 100 and Config.MachineGun or Config.Machines[machineId]

    if not machine then
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Não há dinheiro pronto para ser coletado.', 'error')
        return
    end

    local response = MySQL.query.await('SELECT * FROM money_laundry_machines WHERE id = ?', {machineId})

    if not response or #response == 0 then
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Não há dinheiro pronto para ser coletado.', 'error')
        return
    end

    local washTime = tonumber(response[1].wash_time)
    local amount = tonumber(response[1].amount)
    local currentTime = os.time()

    -- Verifica se 6 minutos se passaram
    if currentTime >= washTime then
        if machineId == 100 then
            startGlobalCooldown(10 * 60 * 1000)
        end
        MySQL.Async.execute('DELETE FROM money_laundry_machines WHERE id = ?', {machineId}, function(affectedRows)
            if affectedRows > 0 then
                Player.Functions.AddMoney('cash', amount) -- Retorna o valor coletado
                TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Você pegou o dinheiro: $' .. amount, 'success')
                return
            end
            TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Maquina vazia', 'error')
        end)
    else
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'O dinheiro ainda não está pronto. Espere mais um pouco.', 'error')
    end
end)

RegisterNetEvent("moneywashing:server:washingMoney",function(amount, machineId)
    local src = source
    local machines = machineId == 100 and Config.MachineGun or Config.Machines[machineId]
    local oldMoney = amount
    
    if machines.id == 100 and machines.round >= 1 then
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'A máquina está quente. Espere ela esfriar por 15 minutos.', 'error')
        return
    end

    if machines.id == machineId and machines.round >= 3 then
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'A máquina está quente. Espere ela esfriar por 15 minutos.', 'error')
        return
    end

    local removedItem = Config.Inventory == 'ox' and exports.ox_inventory:RemoveItem(src, Config.Money, amount) or exports['qb-inventory']:RemoveItem(src, Config.Money, amount)
    if removedItem then
        
        if machineId == 100 then
            machines.round = machines.round + 1
            amount = amount * 0.90
    
            local currentTime = os.time() + (1 * 60)
            MySQL.insert('INSERT INTO `money_laundry_machines` (id, amount, on_off, wash_time) VALUES (?, ?, ?, ?)', {
                machineId, amount, true, currentTime
            })    
            TriggerClientEvent('moneywashing:client:updateRound', src, machines.round)
            TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Você colocou $' .. oldMoney .. ' na máquina. Espere 15 minutos para receber seu retorno.', 'success')
            return
        else
            machines.round = machines.round + 1
            amount = amount * 0.25

            local currentTime = os.time() + (6 * 60)

            MySQL.insert('INSERT INTO `money_laundry_machines` (id, amount, on_off, wash_time) VALUES (?, ?, ?, ?)', {
                machineId, amount, true, currentTime
            })

            TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Você colocou $' .. oldMoney .. ' na máquina. Espere 6 minutos para receber seu retorno.', 'success')
            return
        end
    else
        TriggerClientEvent('moneywashing:client:receiveStatus', src, 'Você não tem dinheiro sujo suficiente.', 'error')
    end        
end)

-- Item usable
QBCore.Functions.CreateUseableItem(Config.Key, function(source)
    TriggerClientEvent('moneywashing:client:UseLabKey', source)
end)

