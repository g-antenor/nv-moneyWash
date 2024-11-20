QBCore = exports['qb-core']:GetCoreObject()

function Menu(netId)
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
                    args = netId
                }
            })
    
            table.insert(menu, {
                header = Lang:t('menu.withdraw_title'),
                txt = Lang:t('menu.withdraw_description'),
                icon = 'fas fa-hand-holding-usd',
                disabled = status,
                params = {
                    event = 'moneywashing:client:Collect',
                    args = netId
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
                                TriggerEvent('moneywashing:client:Deposit', netId)
                            end
                        end,
                    },
                    {
                        icon = 'hand',
                        title = Lang:t('menu.withdraw_title'),
                        description = Lang:t('menu.withdraw_description'),
                        disabled = status,
                        onSelect = function()
                            TriggerEvent('moneywashing:client:Collect', netId)
                        end
                    }
                }
            })
            lib.showContext('washMoney_menu')
        end
    end, netId)
end

RegisterNetEvent('moneywashing:client:Deposit', function(netId)
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
                    utils.Notify(Lang:t('notify.error.not_money'), 'error', 5000)
                end
            end, netId, wash)
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

RegisterNetEvent('moneywashing:client:Notify', function(message, type, time)
    utils.Notify(message, type, time)
end)

CreateThread(function()
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetModel(Config.ModelProp, {  
            options = {
                {
                    icon = "fas fa-sign-in-alt",
                    label = Lang:t('target.laundry'),
                    action = function(entity)
                        local netId = NetworkGetNetworkIdFromEntity(entity)
                        QBCore.Functions.TriggerCallback('moneywashing:server:CheckOpenMenu', function(status)
                            if status then
                                Menu(netId)
                            end
                        end, netId)
                    end
                },
                {
                    icon = "fas fa-trash",
                    label = Lang:t('target.remove_machine'),
                    action = function(entity)
                        TriggerServerEvent('moneywashing:server:destroyMachine', NetworkGetNetworkIdFromEntity(entity))
                    end
                }
            },
            distance = 2.0
        }) 
    elseif Config.Target == 'ox' then
        exports.ox_target:addModel(Config.ModelProp, {
            {
                icon = "fas fa-sign-in-alt",
                label = Lang:t('target.laundry'),
                onSelect = function(data)
                    local netId = NetworkGetNetworkIdFromEntity(data.entity)
                    QBCore.Functions.TriggerCallback('moneywashing:server:CheckOpenMenu', function(status)
                        if status then
                            Menu(netId)
                        end
                    end, netId)
                end
            },
            {
                icon = "fas fa-trash",
                label = Lang:t('target.remove_machine'),
                onSelect = function(data)
                    TriggerServerEvent('moneywashing:server:destroyMachine', NetworkGetNetworkIdFromEntity(data.entity))
                end
            }
        })
    end
end)
