local Points, Targets, EntityTargets, Peds, Zones, Objects = {}, {}, {}, {}, {}, {}
local Settings = {InZone = false, doorId = 1, CanLoot = false, vehicle = nil}

local function Reset()
    for k, v in pairs(Targets) do
        exports.ox_target:removeZone(v)
    end
    for k, v in pairs(Peds) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    for k, v in pairs(Zones) do
        v:destroy()
    end
    for k, v in pairs(Objects) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    for k, v in pairs(EntityTargets) do
        exports.ox_target:removeLocalEntity(v)
    end
    if DoesEntityExist(Settings.vehicle) then
        DeleteVehicle(Settings.vehicle)
        Settings.vehicle = nil
    end
end

-- Change the door state
-- @param coords - vec4
-- @param model - Model of door
-- @param doorState - Open Or Closed
local function DoorState(coords, model, doorState)
    local door = GetClosestObjectOfType(
        coords.x, coords.y, coords.z,
        2.5, GetHashKey(model) or model, false, false, false
    )
    if door and door ~= nil and door ~= 0 then
        if not doorState then
            FreezeEntityPosition(door, true)
            SetEntityHeading(door, coords.w)
        else
            FreezeEntityPosition(door, false)
        end
    end
end

-- Event to check if ped is in sight
-- @param npc - ped
function CheckNearbyPlayers(npc)
    local npcCoords = GetEntityCoords(npc)
    local players = GetActivePlayers()
    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local dist = #(npcCoords - targetCoords)
        if dist < Config.PedWatching.SIGHT_DISTANCE then
            -- if HasEntityClearLosToEntity(npc, targetPed, 17) then
                local npcForward = GetEntityForwardVector(npc)
                local entityToPlayer = (targetCoords - npcCoords) / dist
                local dot = (npcForward.x * entityToPlayer.x) + 
                            (npcForward.y * entityToPlayer.y) + 
                            (npcForward.z * entityToPlayer.z)
                if dot > Config.PedWatching.SIGHT_ANGLE then
                    return targetPed
                end
            -- end
        end
    end
    return nil
end

-- Make ped hate player
-- @param npc - Ped
local function MakePedHatePlayer(npc)
    local RandomPedWeapon = math.random(1, #Config.RandomPedWeapon)
    local weaponHash = GetHashKey(Config.RandomPedWeapon[RandomPedWeapon])
    GiveWeaponToPed(npc, weaponHash, 100, false, true)
    SetEntityHealth(npc, 175)
    SetPedArmour(npc, 25)
    SetCanAttackFriendly(npc, false, true)
    TaskCombatPed(npc, cache.ped or PlayerPedId(), 0, 16)
    SetPedCombatAttributes(npc, 46, true)
    SetPedCombatAbility(npc, 100)
    SetPedRelationshipGroupHash(npc, `HATES_PLAYER`)
    SetPedAccuracy(npc, math.random(50, 80))
    SetPedFleeAttributes(npc, 0, 0)
    SetPedKeepTask(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityInvincible(npc, false)
end

-- Setup the script
local function load()
    lib.callback("flex_crackhousrob:server:load", 1000, function(doors, id)
        if not doors then return end
        Settings.doorId = id or 1
        local MainDoorPoint = lib.points.new(doors[1].coords.xyz, 25)
        Points['maindoor'] = MainDoorPoint
        function MainDoorPoint:onEnter()
            lib.callback("flex_crackhousrob:server:getDoorStates", 1000, function(doors)
                local IsDoorOpen = false
                for k, v in pairs(doors) do
                    DoorState(v.coords, v.hash, v.open)
                    if v.open then
                        IsDoorOpen = true
                    end
                end
                lib.callback("flex_crackhousrob:server:getInteractions", 1000, function(interactions, pedInfo)
                    local destraction = interactions.destraction
                    if not destraction.state then
                        Targets['destraction'] = exports.ox_target:addBoxZone({
                            coords = destraction.coords.xyz,
                            size = vec3(1.0, 0.3, 1.5),
                            rotation = destraction.coords.w,
                            debug = Config.Debug,
                            drawSprite = true,
                            options = {
                                {
                                    icon = "usb",
                                    label = locale('target.destraction'),
                                    distance = 1.3,
                                    canInteract = function(entity)
                                        return true
                                    end,
                                    onSelect = function()
                                        TriggerServerEvent("flex_crackhousrob:server:destroyTarget", "destraction", true)
                                        if lib.progressBar({
                                            duration = 1000 * 3,
                                            label = locale('progress.knocking'),
                                            useWhileDead = false,
                                            canCancel = false,
                                            disable = {
                                                car = true,
                                                move = true,
                                                combat = true,
                                            },
                                            anim = {
                                                dict = "timetable@jimmy@doorknock@",
                                                clip = "knockdoor_idle",
                                                flag = 49,
                                                duration = -1
                                            },
                                        }) then
                                            ClearPedTasks(cache.ped)
                                            TriggerServerEvent("flex_crackhousrob:server:destroyPeds", true)
                                            TriggerServerEvent("flex_crackhousrob:server:registerWindowPed")
                                            TriggerServerEvent("flex_crackhousrob:server:registerLootZones")
                                            TriggerServerEvent("flex_crackhousrob:server:registerLockpickTarget", Settings.doorId)
                                        else
                                            ClearPedTasks(cache.ped)
                                        end
                                    end,
                                }
                            },
                        })
                        if not IsDoorOpen then
                            if not pedInfo.state then
                                lib.requestModel('g_m_y_armgoon_02', 10000)
                                lib.requestAnimDict("timetable@tracy@sleep@", 5000)
                                local ped = CreatePed(4, 'g_m_y_armgoon_02', pedInfo.start.xyz, pedInfo.start.w, false, false)
                                table.insert(Peds, ped)
                                FreezeEntityPosition(ped, true)
                                SetEntityInvincible(ped, true)
                                SetBlockingOfNonTemporaryEvents(ped, true)
                                lib.playAnim(ped, "timetable@tracy@sleep@", "base", 5.0, 5.0, -1, 1, 1.0, false, 0, false)
                            end
                        end
                    end
                end)
            end)
        end
        function MainDoorPoint:onExit()
            if Targets['destraction'] then
                exports.ox_target:removeZone(Targets['destraction'])
                Targets['destraction'] = nil
            end
        end
    end)
end

-- Destroy target
RegisterNetEvent("flex_crackhousrob:client:destroyTarget", function(target)
    if not target then return end
    if Targets[target] then
        exports.ox_target:removeZone(Targets[target])
        Targets[target] = nil
    end
end)

-- Destroy all peds
RegisterNetEvent("flex_crackhousrob:client:destroyPeds", function()
    for k, v in pairs(Peds) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    Peds = {}
end)

-- Register The Ped at The window
-- @param pedInfo - Table
RegisterNetEvent("flex_crackhousrob:client:registerWindowPed", function(pedInfo)
    if not pedInfo then return end
    if pedInfo.state then
        lib.requestModel('g_m_y_armgoon_02', 10000)
        lib.requestAnimDict("random@paparazzi@peek", 5000)
        lib.requestAnimDict("timetable@tracy@sleep@", 5000)
        local ped = CreatePed(4, 'g_m_y_armgoon_02', pedInfo.start.xyz, pedInfo.start.w, true, true)
        table.insert(Peds, ped)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        lib.playAnim(ped, "timetable@tracy@sleep@", "base", 5.0, 5.0, -1, 1, 1.0, false, 0, false)
        Wait(1000 * Config.WakeupTime)
        SetEntityCoords(ped, pedInfo.window.x, pedInfo.window.y, pedInfo.window.z, false, false, false, false)
        SetEntityHeading(ped, pedInfo.window.w)
        lib.playAnim(ped, "random@paparazzi@peek", "left_peek_a", 5.0, 5.0, -1, 1, 1.0, false, 0, false)
        CreateThread(function()
            local FoundPed = false
            while not FoundPed do
                FoundPed = CheckNearbyPlayers(ped)
                Wait(1000)
            end
            if FoundPed then
                TriggerServerEvent("flex_crackhousrob:server:registerAttackPed")
                TriggerServerEvent("flex_crackhousrob:server:setDoorState", Settings.doorId, true)
                Config.CallPolice(GetEntityCoords(cache.ped), locale("error.call_police"))
            end
        end)
    end
end)

-- Register loot zones
-- @param zones - Array
RegisterNetEvent("flex_crackhousrob:client:registerLootZones", function(zones)
    for k, zone in pairs(zones) do
        if zone.prop then
            lib.requestModel(zone.prop, 10000)
            local obj = CreateObjectNoOffset(zone.prop, zone.coords.x, zone.coords.y, zone.coords.z, false, false, false)
            SetEntityHeading(obj, zone.coords.w)
            FreezeEntityPosition(obj, true)
            Objects[k] = obj
            EntityTargets[k] = exports.ox_target:addLocalEntity(obj, {
                {
                    name        = 'flex_crackhousrob_loot_area_'..k,
                    label       = locale('target.loot'),
                    icon        = 'fas fa-bell',
                    distance    = 1.5,
                    canInteract = function()
                        return true
                    end,
                    onSelect = function()
                        TriggerServerEvent("flex_crackhousrob:server:DestroyLootZone", k)
                        if lib.progressBar({
                            duration = 3 * 1000,
                            label = locale('progress.loot'),
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                            anim = {
                                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                clip = 'machinic_loop_mechandplayer',
                            }
                        }) then
                            ClearPedTasks(cache.ped)
                            TriggerServerEvent("flex_crackhousrob:server:DestroyProp", k)
                            TriggerServerEvent("flex_crackhousrob:server:Reward", k)
                        end
                    end,
                }
            })
        else
            Targets[k] = exports.ox_target:addBoxZone({
                coords = zone.coords.xyz,
                size = vec3(0.4, 0.4, 0.4),
                rotation = zone.coords.w,
                debug = Config.Debug,
                drawSprite = true,
                options = {
                    {
                        name = 'flex_crackhousrob_loot_area_'..k,
                        icon = "usb",
                        label = locale('target.loot'),
                        distance = 1.0,
                        -- canInteract = function(entity)
                        --     return Settings.InZone
                        -- end,
                        onSelect = function()
                            TriggerServerEvent("flex_crackhousrob:server:DestroyLootZone", k)
                            if lib.progressBar({
                                duration = 1000 * 3,
                                label = locale('progress.loot'),
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    car = true,
                                    move = true,
                                    combat = true,
                                },
                                anim = {
                                    dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                                    clip = 'machinic_loop_mechandplayer',
                                },
                            }) then
                                ClearPedTasks(cache.ped)
                                TriggerServerEvent("flex_crackhousrob:server:Reward", k)
                            end
                        end,
                    }
                },
            })
        end
    end
end)

-- Register The target to lockpick
-- @param model - model of the door
RegisterNetEvent("flex_crackhousrob:client:registerLockpickTarget", function(coords, model)
    local door = GetClosestObjectOfType(
        coords.x, coords.y, coords.z,
        2.5, GetHashKey(model) or model, false, false, false
    )
    if door and door ~= nil and door ~= 0 then
        EntityTargets[model] = exports.ox_target:addLocalEntity(door, {
            {
                name        = 'flex_crackhousrob_lockpick_'..model,
                label       = locale('target.lockpick'),
                icon        = 'fas fa-bell',
                distance    = 1.5,
                canInteract = function()
                    return true
                end,
                onSelect = function()
                    lib.callback("flex_crackhousrob:server:HasItem", 1000, function(hasItem)
                        if hasItem then
                            local animDict = lib.requestAnimDict('veh@break_in@0h@p_m_one@')
                            TaskPlayAnim(cache.ped, 'veh@break_in@0h@p_m_one@', 'low_force_entry_ds', 3.0, 1.0, -1, 49, 0, true, true, true)
                            if Config.Minigame.door() then
                                ClearPedTasks(cache.ped)
                                lib.callback("flex_crackhousrob:server:HasItem", 1000, function(hasItem)
                                    if hasItem then
                                        lib.callback("flex_crackhousrob:server:load", 1000, function(doors, id)
                                            TriggerServerEvent("flex_crackhousrob:server:DestroyLockpickZone", id)
                                            TriggerServerEvent("flex_crackhousrob:server:setDoorState", id, true)
                                        end)
                                    else
                                        Config.Notify.client(locale("error.dont_have_item"), "info", 3000)
                                    end
                                end, Config.NeededItems.lockpick, true)
                            else
                                ClearPedTasks(cache.ped)
                            end
                        else
                            Config.Notify.client(locale("error.dont_have_item"), "info", 3000)
                        end
                    end, Config.NeededItems.lockpick, false)
                end,
            }
        })
    end
end)

-- Destroy lockpick zone
-- @param model - model of door
RegisterNetEvent("flex_crackhousrob:client:DestroyLockpickZone", function(coords, model)
    if not coords or not model then return end
    local door = GetClosestObjectOfType(
        coords.x, coords.y, coords.z,
        2.5, GetHashKey(model) or model, false, false, false
    )
    if door and door ~= nil and door ~= 0 then
        if EntityTargets[model] then
            exports.ox_target:removeLocalEntity(EntityTargets[model])
            EntityTargets[model] = nil
        end
    end
end)

-- Destroy loot zone
-- @param id - number
RegisterNetEvent("flex_crackhousrob:client:DestroyLootZone", function(id)
    if not id then return end
    if EntityTargets[id] then
        exports.ox_target:removeLocalEntity(EntityTargets[id])
        EntityTargets[id] = nil
    end
    if Targets[id] then
        exports.ox_target:removeZone(Targets[id])
        Targets[id] = nil
    end
end)

-- Destroy prop
-- @param id - number
RegisterNetEvent("flex_crackhousrob:client:DestroyProp", function(id)
    if DoesEntityExist(Objects[id]) then
        DeleteEntity(Objects[id])
        Objects[id] = nil
    end
end)

-- Register Zone of the house
-- @param Zone - Table
RegisterNetEvent("flex_crackhousrob:client:registerHouseZone", function(zone)
    Zones['house'] = PolyZone:Create(zone, {
        name = "flex_crackhousrob_zone_main",
        minZ = zone[1].z-1,
        maxZ = zone[1].z+4,
        debugPoly = Config.Debug
    })
    Zones['house']:onPlayerInOut(function(isPointInside)
        Settings.InZone = isPointInside
        if isPointInside then
            CreateThread(function()
                while Settings.InZone do
                    Citizen.Wait(100)
                    local playerPed = cache.ped
                    if not IsPedStill(playerPed) or IsPedWalking(playerPed) or IsPedRunning(playerPed) then
                        local speed = GetEntitySpeed(playerPed)
                        local isSneaking = GetPedStealthMovement(playerPed)
                        if not isSneaking and speed > 1.8 then
                            Settings.InZone = false
                            TriggerServerEvent("flex_crackhousrob:server:destroyHouseZone")
                            TriggerServerEvent("flex_crackhousrob:server:registerAttackPed")
                            lib.callback("flex_crackhousrob:server:load", 1000, function(doors, id)
                                TriggerServerEvent("flex_crackhousrob:server:DestroyLockpickZone", id)
                            end)
                            Config.CallPolice(GetEntityCoords(cache.ped), locale("error.call_police"))
                        end
                    end
                end
            end)
        end
    end)
end)

-- Register Attack Ped when seen by ped
-- @param pedInfo - Table
RegisterNetEvent("flex_crackhousrob:client:destroyHouseZone", function()
    if Zones['house'] then
        Zones['house']:destroy()
        Settings.InZone = false
    end
end)

-- Register Attack Ped when seen by ped
-- @param pedInfo - Table
RegisterNetEvent("flex_crackhousrob:client:registerAttackPed", function(pedInfo)
    if not pedInfo then return end
    if pedInfo.state then
        lib.requestModel('g_m_y_armgoon_02', 10000)
        local ped = CreatePed(4, 'g_m_y_armgoon_02', pedInfo.window.xyz, pedInfo.window.w, true, true)
        table.insert(Peds, ped)
        MakePedHatePlayer(ped)
        CreateThread(function()
            while GetEntityHealth(ped) >= 10 do
                Wait(1000)
            end
            lib.callback("flex_crackhousrob:server:getBackup", 1000, function(backup)
                if not backup then return end
                lib.requestModel(backup.vehicle, 10000)
                Settings.vehicle = CreateVehicle(GetHashKey(backup.vehicle), backup.coords.x, backup.coords.y, backup.coords.z, 269.4, true, false)
                for i = 1, 4 do
                    if backup.peds[i] then
                        lib.requestModel(backup.peds[i], 10000)
                        local ped = CreatePedInsideVehicle(Settings.vehicle, 0, backup.peds[i], i-2, true, true)
                        SetEntityInvincible(ped, true)
                        SetBlockingOfNonTemporaryEvents(ped, true)
                        table.insert(Peds, ped)
                    end
                end
                local driver = GetPedInVehicleSeat(Settings.vehicle, -1)
                if DoesEntityExist(driver) then
                    TaskVehicleDriveToCoord(driver, Settings.vehicle, backup.endcoords.x, backup.endcoords.y, backup.endcoords.z, 20.0, 0, GetHashKey(backup.vehicle), 786603, 5.0, true)
                end
                while #(GetEntityCoords(Settings.vehicle) - vector3(backup.endcoords.x, backup.endcoords.y, backup.endcoords.z)) > 6.0 do
                    Wait(500)
                end
                for k, v in pairs(Peds) do
                    if DoesEntityExist(v) then
                        -- ClearPedTasksImmediately(v)
                        TaskLeaveVehicle(v, Settings.vehicle, 256)
                        Citizen.CreateThread(function()
                            Wait(1500)
                            MakePedHatePlayer(v)
                            TaskCombatPed(v, PlayerPedId(), 0, 16)
                        end)
                    end
                end
            end)
        end)
    end
end)

-- Open Door
-- @param door - Table
RegisterNetEvent("flex_crackhousrob:client:setDoorState", function(door, state)
    if not door or state == nil then return end
    DoorState(door.coords, door.hash, state)
end)

-- Player load event
RegisterNetEvent(onPlayerLoaded(), function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end
    load()
end)

-- Resource start event
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        while not LocalPlayer.state.isLoggedIn do
            Wait(1000)
        end
        load()
    end
end)

RegisterNetEvent("flex_crackhousrob:client:Reset", function()
    Reset()
    load()
end)

-- Player unload event
RegisterNetEvent(onPlayerUnLoaded(), function()
    Reset()
end)

-- Resource stop event
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        Reset()
    end
end)