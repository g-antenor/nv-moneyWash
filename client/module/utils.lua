utils = {}

---@param notification string
---@param type string
---@param time number
function utils.Notify(notification, type, time)
    local time = time or 5000

    if Config.Util == 'qb' then
        QBCore.Functions.Notify(notification, type, time)
    elseif Config.Util == 'ox' then
        lib.notify({ description = notification, type = type, time = time })
    end
end

---@return boolean
function utils.CheckPolice()
    local amountRequired = false
    QBCore.Functions.TriggerCallback('moneywashing:server:getCopsAmount', function(cb)  
        amountRequired = cb
    end, Config.PoliceRequired)

    Wait(100)
    return amountRequired
end

---@param machineId number
---@return boolean
function utils.CheckCooldown(machineId)
    local status = false
    QBCore.Functions.TriggerCallback('moneywashing:server:CheckCooldown', function(isAvailable) 
        status = isAvailable
    end, machineId)

    Wait(100)
    return status
end

---@param machineId number
---@return boolean
function utils.CheckCooldownGun(machineId)
    local status = false

    QBCore.Functions.TriggerCallback('moneywashing:server:CheckCooldownGun', function(isAvailable) 
        status = isAvailable
    end, machineId)

    Wait(100)
    return status
end

function utils.Animations(dict, clip, time, txt)
    if Config.Util == 'qb' then
        QBCore.Functions.Progressbar('money_washing', txt, time, false, false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
            }, {
                animDict = dict,
                anim = clip
            }, {}, {}
        )
    elseif Config.Util == 'ox' then
        lib.progressCircle({
            duration = time,
            label = txt,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                movement = true,
                combat = true
            },
            anim = {
                dict = dict,
                clip = clip
            },
        })
    end

    return true
end