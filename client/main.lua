QBCore = exports['qb-core']:GetCoreObject()

local targetGetKey = false
local starterCalled = false
local blipGetKey = false
local inRoute = false
local currentPed = nil
local currentBlip = nil
local currentLocation = nil

local maxVelue = 5000
local maxVelueGun = 15000
local targetWashing = false

local hasStarted = false
local isOnCooldown = false

-- Functions
-- CreateBlips 
local function CreateBlips(location)
    currentLocation = location
    -- Criar uma rota no mapa
    currentBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(currentBlip, 1)
    SetBlipColour(currentBlip, 5)
    SetBlipScale(currentBlip, 0.8)
    SetBlipAsShortRange(currentBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Rota de Lavagem de Dinheiro")
    EndTextCommandSetBlipName(currentBlip)

    -- Rota no GPS
    SetNewWaypoint(location.x, location.y)

    if Config.Util == 'qb' then
        QBCore.Functions.Notify("Rota iniciada! Siga o mapa para a localização.", "success")
    elseif Config.Util == 'ox' then
        lib.notify({ title = "Rota iniciada!", description = "Siga o mapa para a localização.", type = 'success'})
    end
end

local function RemoveCurrentPedAndBlip()
    if currentPed then
        DeleteEntity(currentPed)
        currentPed = nil
    end

    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end
end

local function Animations(wash, machineId)
    local dict = 'anim@heists@ornate_bank@grab_cash'
    local clip = 'cart_cash_dissapear'

    if Config.Util == 'qb' then
        QBCore.Functions.Progressbar('money_washing', 'Put money in the machine', 1500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
            }, {}, {}, {}, function()
                TriggerServerEvent('moneywashing:server:washingMoney', wash, machineId)
            end
        )
    elseif Config.Util == 'ox' then
        if lib.progressCircle({
            duration = machineId == 100 and 15000 or 7000,
            label = 'Put money in the machine',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                dict = dict,
                clip = clip
            },
        }) then
            TriggerServerEvent('moneywashing:server:washingMoney', wash, machineId)
        end
    end
end

RegisterNetEvent('moneywashing:client:Deposit', function(machineId)
    local allValues = 0
    local wash = 0

    if Config.Util == 'qb' then
        QBCore.Functions.TriggerCallback('moneywashing:server:checkItemCount', function(amount)
            allValues = allValues + amount
        end, Config.Money)
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
        wash = tonumber(wash.valuewash)
    elseif Config.Util == 'ox' then
        allValues = exports.ox_inventory:Search('count', Config.Money)
        wash = lib.inputDialog('Value wash', {{type = 'number', default = maxVelue, icon = 'hashtag'}})
    end

    local machineGun = Config.Util == 'qb' and machineId == 100 and not (wash > maxVelueGun and allValues < wash) and wash[1] > 0 or machineId == 100 and not (wash[1] > maxVelueGun and allValues < wash[1]) and wash[1] > 0
    local machine = Config.Util == 'qb' and not (wash > maxVelue and allValues < wash) and wash > 0 or not (wash[1] > maxVelue and allValues < wash[1]) and wash[1] > 0
    
    if wash then
        if machineGun then
            local wash = Config.Util == 'qb' and wash or wash[1]
            Animations(wash, machineId)
        elseif machine then
            local wash = Config.Util == 'qb' and wash or wash[1]
            Animations(wash, machineId)
        else
            if Config.Util == 'qb' then
                QBCore.Functions.Notify("Don't have amount", 'error')
            elseif Config.Util == 'ox' then
                lib.notify({description = "Don't have amount", type = 'error'})
            end
        end
    end
end)

local function Menu(status, machineId)
    if Config.Util == 'qb' then
        local menu = {}

        table.insert(menu, {
            header = 'Lavanderia',
            isMenuHeader = true
        })

        table.insert(menu, {
            header = 'Colocar Roupa Suja',
            txt = 'Uma máquina para lavar suas coisas 😉',
            icon = 'fas fa-tshirt',
            params = {
                event = 'moneywashing:client:Deposit',
                args = machineId
            }
        })

        table.insert(menu, {
            header = 'Sacar',
            txt = 'Eu falei sacar? ops...',
            icon = 'fas fa-hand-holding-usd',
            disabled = status, -- Habilite ou desabilite com base no status
            params = {
                isServer = true,
                event = 'moneywashing:server:collectMoney',
                args = machineId
            }
        })

        exports['qb-menu']:openMenu(menu)

    elseif Config.Util == 'ox' then
        lib.registerContext({
            id = 'washMoney_menu',
            title = 'Lavanderia',
            options = {
                {
                    title = 'Colocar Roupa Suja',
                    description = 'Uma máquina para lavar suas coisas 😉',
                    icon = 'shirt',
                    onSelect = function()
                        if status then
                            TriggerEvent('moneywashing:client:Deposit', machineId)
                        end
                    end,
                },
                {
                    title = 'Sacar',
                    description = 'Eu falei sacar? ops...',
                    icon = 'hand',
                    onSelect = function()
                        TriggerServerEvent('moneywashing:server:collectMoney', machineId)
                    end
                }
            }
        })
        lib.showContext('washMoney_menu')
    end
end

local function SpawnMachineGun()
    local model = Config.ModelMachine
    local location = Config.MachineGun.coords

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    local prop = CreateObject(model, location.x, location.y, location.z, true, true, true)
    SetEntityAsMissionEntity(prop, true, true)
    SetEntityInvincible(prop, true)
    FreezeEntityPosition(prop, true)

    -- Liberar o modelo da memória
    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('moneywashing:client:InitHacking', function()
    local ped = PlayerPedId()
    local lootDict = 'mp_fbi_heist'
    local lootClip = 'loop'
    local time = 70 * 1000

    RequestAnimDict(lootDict)
	while not HasAnimDictLoaded(lootDict) do
	    Wait(100)
	end
	TaskPlayAnim(ped, lootDict, lootClip, 1.0, -1.0, 1.0, 11, 0, 0, 0, 0)

    if exports.bl_ui:WaveMatch(1, {duration = time}) then
        hasStarted = true
    elseif Config.PSDispatch then
        exports['ps-dispatch']:ArtGalleryRobbery()
    end 
    ClearPedTasks(ped)
end)

RegisterNetEvent('moneywashing:client:setCooldown', function(state)
    isOnCooldown = state
    hasStarted = state
end)


-- Events 
-- Route to buy key
RegisterNetEvent('moneywashing:client:Animation', function(typeAction)
    if currentPed and typeAction == 1 then 
        TriggerEvent('QBCore:Notify', "Finish first the Route", "error")
        return
    end
    
    if typeAction == 3 then
        if lib.progressCircle({
            duration = 2000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                clip = "machinic_loop_mechandplayer",
            }
        }) then 
            TriggerServerEvent('moneywashing:server:GetKey')
        else 
            lib.notify({type = 'error', description = "Ação cancelada!"})
        end 
    else
        if lib.progressCircle({
            duration = 2000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = "cellphone@",
                clip = "cellphone_text_read_base",
            }
        }) then 
            TriggerEvent('moneywashing:client:StartRouter')
        else 
            lib.notify({type = 'error', description = "Ação cancelada!"})
        end 
    end
end)

RegisterNetEvent('moneywashing:client:StartRouter', function()
    inRoute = true
    local location = Config.Locations[math.random(#Config.Locations)]

    RequestModel(Config.PedModel)
    while not HasModelLoaded(Config.PedModel) do
        Wait(1)
    end

    currentPed = CreatePed(4, Config.PedModel, location.x, location.y, location.z, location.w, false, true)
    SetEntityAsMissionEntity(currentPed, true, true)
    TaskStartScenarioInPlace(currentPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
    SetBlockingOfNonTemporaryEvents(currentPed, true)
    SetEntityInvincible(currentPed, true)
    FreezeEntityPosition(currentPed, true)

    CreateBlips(location)
    BuyKey(currentPed)
end)

RegisterNetEvent('moneywashing:client:GetKey', function()
    RemoveCurrentPedAndBlip()
    CreateBlips(Config.KeyLocations[math.random(#Config.KeyLocations)])
    blipGetKey = true
end)

RegisterNetEvent('moneywashing:client:FinishRoute', function()
    inRoute = false
    blipGetKey = false
    RemoveCurrentPedAndBlip()
end)


-- Washing locale
RegisterNetEvent('moneywashing:client:UseLabKey', function()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    
    for _, door in pairs(Config.DoorsWashing) do
        local dist = GetDistanceBetweenCoords(pos, door.coords)
        
        if dist < 1.5 then
            TriggerServerEvent('moneywashing:server:SetDoor', door.doorId)
        end
    end
end)

RegisterNetEvent('moneywashing:client:showMenu', function(machineId, status)
    Menu(status, machineId)
end)

RegisterNetEvent('moneywashing:client:receiveStatus', function(message, types)
    lib.notify({description = message, type = types})
end)

RegisterNetEvent('moneywashing:client:updateRound', function(round, status)
    Config.MachineGun.round = round
end)

-- Threads
CreateThread(function()
    -- Set doors locked
    for _, door in pairs(Config.DoorsWashing) do
        AddDoorToSystem(door.hash, door.hash, door.coords.x, door.coords.y, door.coords.z, false, false, false)
        DoorSystemSetDoorState(door.hash, 1, false, true)
    end

    -- Verification time for BuyKey
    while true do
        local time = GetClockHours()

        if time >= 0 and time <= 3 and not inRoute and not starterCalled then
            Starter(true)
            starterCalled = true
        elseif time > 3 and starterCalled then
            Starter(false)
            starterCalled = false
        end


        if currentLocation and blipGetKey then
            if not targetGetKey then
                GetKey(currentLocation, blipGetKey)
                targetGetKey = true
            end
        else
            if targetGetKey then
                RemoveKeyTarget()
                targetGetKey = false
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        if not targetWashing then
            Machines()

            SpawnMachineGun()
            
            MachineGun(hasStarted, isOnCooldown)

            targetWashing = true
        end
        Wait(500)
    end
end)
