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

---@param model string
---@param location vector4
---@return number
function utils.SpawnMachine(model, location)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local prop = CreateObject(model, location.x, location.y, location.z, true, true, true)
    SetEntityHeading(prop, location.w)
    SetEntityAsMissionEntity(prop, true, true)
    SetEntityInvincible(prop, true)
    FreezeEntityPosition(prop, true)

    SetModelAsNoLongerNeeded(model)

    return prop
end

---@param dict string
---@param clip string
---@param time number
---@param txt string
---@return boolean
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

---@param text string
---@param position string
function utils.textUI(text, position)
    if Config.Util == 'qb' then
        exports['qb-core']:DrawText(text, position)
    elseif Config.Util == 'ox' then
        lib.showTextUI(text, {position = position})
    end
end

function utils.removeTextUI()
    if Config.Util == 'qb' then
        exports['qb-core']:HideText()
    elseif Config.Util == 'ox' then
        lib.hideTextUI()
    end
end
