SV_Config = {}
SV_Config.WEBHOOK = 'https://discord.com/api/webhooks/1475113052021194854/xqtlUZXAaCj1JM69tt7LMXkDcgXECl9JVbmkHCj1h4DRNBZ5uZwkyKdqREj_n9FUhfkE'

Config.ResetTime = 30 -- Minutes

SV_Config.RandomDoorId = math.random(1,2)
SV_Config.Doors = {
    [1] = {hash = 'v_ilev_ra_door3', coords = vector4(1294.457, -1739.439, 54.354, 292.285), open = false},
    [2] = {hash = 'v_ilev_ra_door3', coords = vector4(1300.937, -1752.689, 54.361, 112.812), open = false},
}

SV_Config.Interactions = {
    destraction = {coords = vec4(1303.0491943359, -1747.4197998047, 54.583362579346, 114.35536956787), state = false},
    loot = {
        [1] = {
            coords = vec4(1300.6163330078,-1747.4157714844,54.064956665039, 350.28887939453),
            prop = 'bkr_prop_coke_powder_02',
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [2] = {
            coords = vec4(1294.2573242188,-1745.1920166016,53.547515869141, 112.21253967285),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [3] = {
            coords = vec4(1296.3894042969,-1750.873046875,54.21374130249, 116.87821960449),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [4] = {
            coords = vec4(1299.4569091797,-1739.83984375,53.714405059814, 303.67068481445),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [5] = {
            coords = vec4(1295.5665283203,-1740.9229736328,53.781852722168, 28.512321472168),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [6] = {
            coords = vec4(1301.4208984375,-1746.0904541016,53.624172210693, 199.36489868164),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [7] = {
            coords = vec4(1300.0148925781,-1742.3256835938,53.785297393799, 39.097888946533),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [8] = {
            coords = vec4(1299.0471191406,-1745.4055175781,53.954174041748, 62.562725067139),
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
        [9] = {
            coords = vec4(1297.0712890625,-1749.6839599609,53.593154907227, 206.13980102539),
            prop = 'bkr_prop_coke_powder_02',
            looted = false,
            -- chance = 10, -- random number 1 to 100 lower or equal to this (Optional)
            -- all = true, -- true = It will collect all loot (Optional)
            loot = {
                [1] = {'lockpick', 10, {}},
            }
        },
    }
}

SV_Config.Ped = {
    state = false,
    start = vector4(1298.4356689453, -1743.3037109375, 53.884159088135, 287.45074462891),
    window = vector4(1302.1859130859, -1747.6118164062, 54.275989532471, 284.79086303711),
}

SV_Config.Backup = {
    coords = vector4(1194.3527832031, -1765.2338867188, 38.69465637207, 258.18405151367),
    endcoords = vector4(1302.8620605469, -1726.0356445312, 53.501155853271, 126.80365753174),
    vehicle = "cog552",
    peds = {
        "g_m_m_armgoon_01",
        "g_m_m_armlieut_01",
        "csb_hao",
        "u_m_m_willyfist"
    },
}

SV_Config.HouseZone = {
    vec3(1305.1125488281, -1752.1248779297, 52.878650665283),
    vec3(1301.2729492188, -1753.6834716797, 52.878650665283),
    vec3(1299.7357177734, -1750.1121826172, 52.878650665283),
    vec3(1296.0958251953, -1751.5153808594, 52.878650665283),
    vec3(1291.4362792969, -1740.3531494141, 52.878650665283),
    vec3(1294.4450683594, -1739.072265625, 53.276924133301),
    vec3(1294.9959716797, -1740.5985107422, 53.290199279785),
    vec3(1299.6665039062, -1739.1337890625, 52.879322052002)
}