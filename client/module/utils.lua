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

---@param location vector3
---@param typeText string
function utils.CreateBlips(location, typeText)
    local blipCreating = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blipCreating, 1)
    SetBlipColour(blipCreating, 5)
    SetBlipScale(blipCreating, 0.8)
    SetBlipAsShortRange(blipCreating, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(typeText)
    EndTextCommandSetBlipName(blipCreating)

    SetNewWaypoint(location.x, location.y)

    return blipCreating
end

---@param model string
---@param location vector4
function utils.CreatePedModel(model, location)
    local animation = 'WORLD_HUMAN_STAND_IMPATIENT'

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(1)
    end

    local pedSpawned = CreatePed(4, model, location.x, location.y, location.z - 1.0, location.w, false, true)
    TaskStartScenarioInPlace(pedSpawned, animation, 0, true)
    SetBlockingOfNonTemporaryEvents(pedSpawned, true)
    SetEntityAsMissionEntity(pedSpawned, true, true)
    SetEntityInvincible(pedSpawned, true)
    FreezeEntityPosition(pedSpawned, true)

    return pedSpawned
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