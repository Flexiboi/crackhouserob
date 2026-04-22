Config = {}

Config.Debug = true
Config.CoreName = {
    qb = 'qb-core',
    esx = 'es_extended',
    ox = 'ox_core',
    ox_inv = 'ox_inventory',
    qbx = 'qbx_core',
}

Config.Notify = {
    client = function(msg, type, time)
        lib.notify({
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
    server = function(src, msg, type, time)
        lib.notify(src, {
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
}

Config.Minigame = {
    door = function()
        -- return true
        local p = promise:new()
        local success = exports.Burevestnik_lockpick_minigame:Burevestnik_lockpick_minigame_start()
        p:resolve(success)
        return Citizen.Await(p)
    end,
}

Config.CallPolice = function(coords, msg)
    print(coords, msg)
end

Config.NeededItems = {
    lockpick = 'lockpick',
}

Config.PedWatching = {
    SIGHT_DISTANCE = 8.0,
    SIGHT_ANGLE = 0.3,
}
Config.WakeupTime = math.random(3,4) -- Seconds

Config.RandomPedWeapon = {
    "weapon_bat",
    "weapon_hammer",
    "weapon_golfclub",
    "weapon_bottle",
    "weapon_crowbar",
    "weapon_flashlight",
    "weapon_hatchet",
    "weapon_knife",
    "weapon_machete",
    "weapon_switchblade",
    "weapon_nightstick",
    "weapon_wrench",
    "weapon_battleaxe",
    "weapon_poolcue",
    -- "weapon_snspistol",
}