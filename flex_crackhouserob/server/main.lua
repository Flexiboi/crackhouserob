local function SendWebhook(title, description)
    if SV_Config.WEBHOOK == "" or SV_Config.WEBHOOK == nil then return end

    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = 3066993,
            ["footer"] = {
                ["text"] = "VOS CRACKHOUSE",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(SV_Config.WEBHOOK, function(err, text, headers) end, 'POST', json.encode({
        username = "VOS",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Function to reset whole script
function Reset()
    CreateThread(function()
        Wait(Config.ResetTime * 1000 * 60)
        for k, v in pairs(SV_Config.Doors) do
            v.open = false
        end
        SV_Config.Interactions.destraction.state = false
        SV_Config.Ped.state = false
        for k, v in pairs(SV_Config.Interactions.loot) do
            v.looted = false
        end
        TriggerClientEvent("flex_crackhousrob:client:DestroyLockpickZone", -1, SV_Config.Doors[SV_Config.RandomDoorId].coords, SV_Config.Doors[SV_Config.RandomDoorId].hash)
        TriggerClientEvent("flex_crackhousrob:client:Reset", -1)
    end)
end

-- Function to check if player has item
-- @param source - Id of player
-- @param item - Name of item
-- @param remove - if remove or just check
local function HasItem(source, item, remove)
    local src = source
    if not item then return false end

    if type(item) == 'table' then
        for k, v in pairs(item) do
            if type(v) ~= 'number' then
                if not HasInvGotItem(src, 'count', v, nil, 1) then
                    return false
                end
            else
                if not HasInvGotItem(src, 'count', k, nil, v or 1) then
                    return false
                end
            end
        end
        if remove then
            for k, v in pairs(item) do
                if type(v) ~= 'number' then
                    if HasInvGotItem(src, 'count', v, nil, 1) then
                        RemoveItem(src, v, 1, nil, nil)
                    end
                else
                    if HasInvGotItem(src, 'count', k, nil, v or 1) then
                        RemoveItem(src, k, v or 1, nil, nil)
                    end
                end
            end
        end
        return true
    else
        if remove then
            if HasInvGotItem(src, 'count', item, nil, 1) then
                return RemoveItem(src, item, 1, nil, nil)
            else
                return false
            end
        else
            return HasInvGotItem(src, 'count', item, nil, 1)
        end
    end
end

-- Exploit check so players can trigger accros the map
-- @param src - Source id of the player who triggers
-- @param coords - Vector4
-- @param distance - Distance check
function ExploitCheck(src, coords, distance)
    if not src then return false end
    local ped = GetPlayerPed(src)
    if ped == nil or ped == 0 then return false end
    local pedCoords = GetEntityCoords(ped)
    if #(vector3(coords.x, coords.y, coords.z) - pedCoords.xyz) > distance then 
        DropPlayer(src, locale('error.exploit_kick')) 
        return false
    end
    return true
end

-- Callback to get all doors
lib.callback.register("flex_crackhousrob:server:load", function(source)
    return SV_Config.Doors, SV_Config.RandomDoorId
end)

-- Callback to get doors states
lib.callback.register("flex_crackhousrob:server:getDoorStates", function(source)
    return SV_Config.Doors
end)

-- Callback to random door id
lib.callback.register("flex_crackhousrob:server:GetDoorId", function(source)
    return SV_Config.RandomDoorId
end)

-- Callback to get the interaction on setup
lib.callback.register("flex_crackhousrob:server:getInteractions", function(source)
    return SV_Config.Interactions, SV_Config.Ped
end)

-- Callback to check if has item
lib.callback.register("flex_crackhousrob:server:HasItem", function(source, item, remove)
    return HasItem(source, item, remove)
end)

-- Callback get backuo
lib.callback.register("flex_crackhousrob:server:getBackup", function(source)
    return SV_Config.Backup
end)

-- Set de state of a door
-- @param target - Which target needs to be destroyed
-- @param state - If destroyed or not
RegisterNetEvent("flex_crackhousrob:server:destroyTarget", function(target, state)
    if not ExploitCheck(source, SV_Config.Interactions[target].coords, 30) then return end
    SV_Config.Interactions[target].state = state
    if state then
        TriggerClientEvent("flex_crackhousrob:client:destroyTarget", -1, target)
    end
end)

-- Destroy all peds
-- @param state - true or false
RegisterNetEvent("flex_crackhousrob:server:destroyPeds", function(state)
    if not ExploitCheck(source, SV_Config.Ped.start, 15) then return end
    SV_Config.Ped.state = state
    if state then
        TriggerClientEvent("flex_crackhousrob:client:destroyPeds", -1)
    end
end)

-- Register the ped infront of the window
RegisterNetEvent("flex_crackhousrob:server:registerWindowPed", function()
    if not ExploitCheck(source, SV_Config.Ped.window, 15) then return end
    Reset()
    if SV_Config.Ped.state then
        SV_Config.Interactions.destraction.state = true
        TriggerClientEvent("flex_crackhousrob:client:registerWindowPed", source, SV_Config.Ped)
        TriggerClientEvent("flex_crackhousrob:client:registerHouseZone", -1, SV_Config.HouseZone)
    end
end)

-- Register The attacking ped when seen
RegisterNetEvent("flex_crackhousrob:server:registerAttackPed", function()
    if not ExploitCheck(source, SV_Config.Ped.window, 15) then return end
    if SV_Config.Ped.state then
        TriggerClientEvent("flex_crackhousrob:client:destroyPeds", -1)
        TriggerClientEvent("flex_crackhousrob:client:registerAttackPed", source, SV_Config.Ped)
        TriggerClientEvent("flex_crackhousrob:client:destroyHouseZone", -1)
    end
end)

-- Set de state of a door
-- @param door - id of the door
-- @param state - true or false / open or closed
RegisterNetEvent("flex_crackhousrob:server:setDoorState", function(door, state)
    if not ExploitCheck(source, SV_Config.Doors[door].coords, 25) then return end
    if not SV_Config.Doors[door].open then
        SV_Config.Doors[door].open = state
        TriggerClientEvent("flex_crackhousrob:client:setDoorState", -1, SV_Config.Doors[door], state)
    end
end)

-- Destroy the zone of the house
RegisterNetEvent("flex_crackhousrob:server:destroyHouseZone", function()
    if not ExploitCheck(source, SV_Config.Ped.window, 15) then return end
    if SV_Config.Ped.state then
        TriggerClientEvent("flex_crackhousrob:client:destroyHouseZone", -1)
    end
end)

-- Register the loot zones
RegisterNetEvent("flex_crackhousrob:server:registerLootZones", function()
    if not ExploitCheck(source, SV_Config.Ped.window, 15) then return end
    if SV_Config.Ped.state then
        TriggerClientEvent("flex_crackhousrob:client:registerLootZones", -1, SV_Config.Interactions.loot)
    end
end)

-- Register the lockpick target
-- @param id -- id of the door
RegisterNetEvent("flex_crackhousrob:server:registerLockpickTarget", function(id)
    if not id then return end
    if not ExploitCheck(source, SV_Config.Doors[SV_Config.RandomDoorId].coords, 15) then return end
    if SV_Config.Ped.state then
        TriggerClientEvent("flex_crackhousrob:client:registerLockpickTarget", -1, SV_Config.Doors[SV_Config.RandomDoorId].coords, SV_Config.Doors[SV_Config.RandomDoorId].hash)
    end
end)

-- Register the lockpick target
-- @param id -- id of the door
RegisterNetEvent("flex_crackhousrob:server:DestroyLockpickZone", function(id)
    if not id then return end
    if not ExploitCheck(source, SV_Config.Doors[SV_Config.RandomDoorId].coords, 15) then return end
    if SV_Config.Ped.state then
        TriggerClientEvent("flex_crackhousrob:client:DestroyLockpickZone", -1, SV_Config.Doors[SV_Config.RandomDoorId].coords, SV_Config.Doors[SV_Config.RandomDoorId].hash)
    end
end)

-- Destroy loot zone
-- @param id - number of the zone 
-- @param prop - true if prop
RegisterNetEvent("flex_crackhousrob:server:DestroyLootZone", function(id)
    if not ExploitCheck(source, SV_Config.Interactions.loot[id].coords, 5) then return end
    if not SV_Config.Interactions.loot[id].looted then
        SV_Config.Interactions.loot[id].looted = true
        TriggerClientEvent("flex_crackhousrob:client:DestroyLootZone", -1, id)
    end
end)

-- Destroy prop
-- @param id - number of the prop in array 
RegisterNetEvent("flex_crackhousrob:server:DestroyProp", function(id)
    if not ExploitCheck(source, SV_Config.Interactions.loot[id].coords, 5) then return end
    if SV_Config.Interactions.loot[id].looted then
        TriggerClientEvent("flex_crackhousrob:client:DestroyProp", -1, id)
    end
end)

-- Reward
-- @param id - id of the looted stuff
RegisterNetEvent("flex_crackhousrob:server:Reward", function(id)
    local src = source
    Wait(5, 25)
    if not src then return end
    if not ExploitCheck(src, SV_Config.Interactions.loot[id].coords, 3) then return end
    local loot = SV_Config.Interactions.loot[id]
    if not loot then return end
    if not loot.looted then return end
    loot.looted = false
    local items = loot.loot
    if not items then return end
    if loot.chance then
        if math.random(1, 100) <= loot.chance then
            if loot.all then
                for i = 1, #items do
                    AddItem(src, items[i][1] or items[i], items[i][2] or 1, items[i][3] or nil, nil)
                end
            else
                local reward = items[math.random(1, #items)]
                if not reward then return end
                AddItem(src, reward[1] or reward, reward[2] or 1, reward[3] or nil, nil)
            end
        else
            Config.Notify.server(src, locale("error.found_nothing"), "info", 3000)
        end
    else
        if loot.all then
            for i = 1, #items do
                AddItem(src, items[i][1] or items[i], items[i][2] or 1, items[i][3] or nil, nil)
            end
        else
            local reward = items[math.random(1, #items)]
            if not reward then return end
            AddItem(src, reward[1] or reward, reward[2] or 1, reward[3] or nil, nil)
        end
    end
end)