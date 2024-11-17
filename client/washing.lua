QBCore = exports['qb-core']:GetCoreObject()

local targetWashing = false
local hasStarted = false

local function InitHacked()
    local ped = PlayerPedId()
    local time = 70 * 1000

    RequestAnimDict('mp_fbi_heist')
	while not HasAnimDictLoaded('mp_fbi_heist') do
	    Wait(100)
	end
	TaskPlayAnim(ped, 'mp_fbi_heist', 'loop', 1.0, -1.0, 1.0, 11, 0, 0, 0, 0)

    if exports.bl_ui:WaveMatch(1, {duration = time}) then
        hasStarted = true
    elseif Config.PSDispatch then
        exports['ps-dispatch']:ArtGalleryRobbery()
    end 

    ClearPedTasks(ped)
end

local function Menu(machineId)
    QBCore.Functions.TriggerCallback('moneywashing:server:CheckCollectMoney', function(status)
        if Config.Util == 'qb' then
            local menu = {}
            table.insert(menu, {
                header = Lang:t('menu.header'),
                isMenuHeader = true
            })
    
            table.insert(menu, {
                header = Lang:t('menu.deposit_title'),
                txt = Lang:t('menu.deposit_description'),
                icon = 'fas fa-tshirt',
                params = {
                    event = 'moneywashing:client:Deposit',
                    args = machineId
                }
            })
    
            table.insert(menu, {
                header = Lang:t('menu.withdraw_title'),
                txt = Lang:t('menu.withdraw_description'),
                icon = 'fas fa-hand-holding-usd',
                disabled = status,
                params = {
                    event = 'moneywashing:client:Collect',
                    args = machineId
                }
            })
    
            exports['qb-menu']:openMenu(menu)
    
        elseif Config.Util == 'ox' then
            lib.registerContext({
                id = 'washMoney_menu',
                title = Lang:t('menu.header'),
                options = {
                    {
                        icon = 'shirt',
                        title = Lang:t('menu.deposit_title'),
                        description = Lang:t('menu.deposit_description'),
                        onSelect = function()
                            if status then
                                TriggerEvent('moneywashing:client:Deposit', machineId)
                            end
                        end,
                    },
                    {
                        icon = 'hand',
                        title = Lang:t('menu.withdraw_title'),
                        description = Lang:t('menu.withdraw_description'),
                        disabled = status,
                        onSelect = function()
                            TriggerEvent('moneywashing:client:Collect', machineId)
                        end
                    }
                }
            })
            lib.showContext('washMoney_menu')
        end
    end, machineId)
end

local function Machines()
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
                        label = Lang:t('target.laundry'),
                        canInteract = function()
                            return utils.CheckCooldown(machineWash.id)
                        end,
                        action = function()
                            QBCore.Functions.TriggerCallback('moneywashing:server:CheckOpenMenu', function(status)
                                if status then
                                    Menu(machineWash.id)
                                else
                                    utils.Notify(Lang:t('notify.error.money_not_ready'), 'error', 5000)
                                end
                            end, machineWash.id)
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
                        label = Lang:t('target.laundry'),
                        canInteract = function()
                            return utils.CheckCooldown(machineWash.id)
                        end,
                        onSelect = function()
                            QBCore.Functions.TriggerCallback('moneywashing:server:CheckOpenMenu', function(status)
                                if status then
                                    Menu(machineWash.id)
                                else
                                    utils.Notify(Lang:t('notify.error.money_not_ready'), 'error', 5000)
                                end
                            end, machineWash.id)
                        end
                    },
                },
            })
        end
    end
end

local function SpawnMachineGun(model, location)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    local prop = CreateObject(model, location.x, location.y, location.z, true, true, true)
    SetEntityAsMissionEntity(prop, true, true)
    SetEntityInvincible(prop, true)
    FreezeEntityPosition(prop, true)

    SetModelAsNoLongerNeeded(model)
end

local function TargetMachineGun()
    if Config.Target == 'qb' then
        exports['qb-target']:AddBoxZone("moneywashing_machinegun_zone", Config.MachineGun.target, 1.0, 4.0, {
            name = "moneywashing_machinegun_zone",
            debugPoly = false,
            minZ = Config.MachineGun.target.z - 1,
            maxZ = Config.MachineGun.target.z + 1,
        }, {
            options = {
                {
                    icon = "fas fa-sign-in-alt",
                    label = Lang:t('target.start_machine'),
                    canInteract = function()
                        local hasCop = utils.CheckPolice()
                        local isOnCooldown = utils.CheckCooldownGun(Config.MachineGun.id)
                        return not hasStarted and hasCop and isOnCooldown
                    end,
                    action = function()
                        InitHacked()
                    end
                },
                {
                    icon = "fas fa-sign-in-alt",
                    label = Lang:t('target.laundry'),
                    canInteract = function()
                        local hasCop = utils.CheckPolice()
                        local isOnCooldown = utils.CheckCooldownGun(Config.MachineGun.id)
                        return hasStarted and hasCop and isOnCooldown
                    end,
                    action = function()
                        QBCore.Functions.TriggerCallback('moneywashing:server:CheckOpenMenu', function(status)
                            if status then
                                Menu(Config.MachineGun.id)
                            else
                                utils.Notify(Lang:t('notify.error.money_not_ready'), 'error', 5000)
                            end
                        end, Config.MachineGun.id)
                    end
                },
            },
            distance = 2.0
        })
    elseif Config.Target == 'ox' then
        exports.ox_target:addBoxZone({
            coords = Config.MachineGun.target,
            size = vec3(1.0, 1.0, 1.0),
            debug = false,
            options = {
                {
                    icon = "fas fa-sign-in-alt",
                    label = Lang:t('target.start_machine'),
                    canInteract = function()
                        local hasCop = utils.CheckPolice()
                        local isOnCooldown = utils.CheckCooldownGun(Config.MachineGun.id)
                        return not hasStarted and hasCop and isOnCooldown
                    end,
                    onSelect = function()
                        InitHacked()
                    end
                },
                {
                    icon = "fas fa-sign-in-alt",
                    label = Lang:t('target.laundry'),
                    canInteract = function()
                        local hasCop = utils.CheckPolice()
                        local isOnCooldown = utils.CheckCooldownGun(Config.MachineGun.id)
                        return hasStarted and hasCop and isOnCooldown
                    end,
                    onSelect = function()
                        QBCore.Functions.TriggerCallback('moneywashing:server:CheckOpenMenu', function(status)
                            if status then
                                Menu(Config.MachineGun.id)
                            else
                                utils.Notify(Lang:t('notify.error.money_not_ready'), 'error', 5000)
                            end
                        end, Config.MachineGun.id)
                    end
                },
            },
        })
    end
end

RegisterNetEvent('moneywashing:client:Deposit', function(machineId)
    local checkValues = false
    local maxVelue = 5000
    local allValues = 0
    local wash = 0
    
    QBCore.Functions.TriggerCallback('moneywashing:server:checkItemCount', function(amount) allValues = allValues + amount end, Config.Money)
    
    if Config.Util == 'qb' then
        wash = exports['qb-input']:ShowInput({
            header = "Money Wash",
            text = "Enter the amount to wash (Max: " .. maxVelue .. ")",
            inputs = {
                {
                    text = "Value wash",
                    name = "valuewash",
                    type = "number",
                    isRequired = true,
                },
            }
        })
        wash = wash == nil and 0 or tonumber(wash.valuewash)
    elseif Config.Util == 'ox' then
        wash = lib.inputDialog('Value wash', {{type = 'number', default = maxVelue, icon = 'hashtag'}})
    end

    if not wash then return end

    if Config.Util == 'qb' then
        checkValues = not (wash > maxVelue and allValues < wash) and wash > 0
    elseif Config.Util == 'ox' then
        checkValues = not (wash[1] > maxVelue and allValues < wash[1]) and wash[1] > 0
    end

    if wash and checkValues then
        local wash = Config.Util == 'qb' and wash or wash[1]
        local animation = utils.Animations("anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2000, Lang:t('progress.put_money_in_machine'))
        
        if animation then
            QBCore.Functions.TriggerCallback('moneywashing:server:DepositMoney', function(result)
                if result then
                    utils.Notify(Lang:t('notify.success.put_money_success'), 'success', 5000)
                else
                    utils.Notify(Lang:t('notify.error.put_money'), 'error', 5000)
                end
            end, machineId, wash)
        end
    elseif not wash or checkValues then
        utils.Notify(Lang:t('notify.error.not_money'), 'error', 5000)
    end
end)

RegisterNetEvent('moneywashing:client:Collect', function(machineId)
    local animation = utils.Animations("anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2000, Lang:t('progress.put_money_in_machine'))
        
    if animation then
        QBCore.Functions.TriggerCallback('moneywashing:server:CollectMoney', function(result)
            if result then
                utils.Notify(Lang:t('notify.success.collected_money'), 'success', 5000)
            else
                utils.Notify(Lang:t('notify.error.money_not_ready'), 'error', 5000)
            end
        end, machineId)
    end
end)

CreateThread(function()
    while true do
        if not targetWashing then
            SpawnMachineGun(Config.ModelMachine, Config.MachineGun.coords)
            
            Machines()
            
            TargetMachineGun()
            
            targetWashing = true
        end
        Wait(500)
    end
end)





