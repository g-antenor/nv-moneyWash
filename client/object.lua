local function RotationToDirection(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local function RayCastCamera()
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * 7.0)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit, surfaceNormal
end

RegisterNetEvent('moneyWash:client:placeProp', function(data)
    local placed = false
    local modelHash = Config.ModelProp
    local pedHeading = GetEntityHeading(PlayerPedId())
    local hit, dest, _, _ = RayCastCamera()
    local obj = CreateObject(modelHash, dest.x, dest.y, dest.z, false, false, false)

    if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then return end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    utils.textUI(Lang:t('text.info.place_cancel'), 'left')
    SetEntityCollision(obj, false, false)
    SetEntityAlpha(obj, 150, true)
    SetEntityHeading(obj, pedHeading)

    while not placed do
        Wait(0)
        hit, dest, _, _ = RayCastCamera()
        if hit == 1 then
            SetEntityCoords(obj, dest.x, dest.y, dest.z + 0.5)

            if IsControlJustPressed(0, 38) then -- Tecla para confirmar
                QBCore.Functions.TriggerCallback('moneywashing:server:GetMachines', function(machines)
                    for _, machine in pairs(machines) do
                        if #(vector3(dest.x, dest.y, dest.z) - vector3(machine.coords.x, machine.coords.y, machine.coords.z)) <= 1.0 then
                            utils.Notify(Lang:t('notify.error.too_close'), 'error', 5000)
                            DeleteObject(obj)
                            utils.removeTextUI()
                            return
                        end
                    end

                    local heading = GetEntityHeading(obj)
                    placed = true
                    utils.removeTextUI()
                    DeleteObject(obj)

                    local success = utils.Animations("anim@narcotics@trash", "drop_front", 2000, Lang:t('progress.put_object'))
                    if success then
                        TriggerServerEvent('moneywashing:server:CreateMachine', dest, heading, modelHash, data.slot)
                        utils.Notify(Lang:t('notify.success.object_placed'), 'success', 5000)
                    end
                end)
                break
            end

            -- Rotação com scroll do mouse
            if IsControlJustPressed(0, 241) then
                local head = GetEntityHeading(obj)
                SetEntityHeading(obj, head + 5)
            end
            if IsControlJustPressed(0, 242) then
                local head = GetEntityHeading(obj)
                SetEntityHeading(obj, head - 5)
            end

            -- Cancelar
            if IsControlJustPressed(0, 47) then
                placed = false
                utils.removeTextUI()
                DeleteObject(obj)
                return
            end
        end
    end
end)
