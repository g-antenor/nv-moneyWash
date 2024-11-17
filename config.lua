Config = {}

Config.PoliceRequired = 1

-- Config resources
Config.Inventory = 'ox'             -- "qb": qb-inventory,  "ox": ox-inventory.
Config.Target    = 'ox'             -- "qb": qb-target,     "ox": ox-target.
Config.Util      = 'ox'             -- "qb": qb-progress,   "ox": ox-progress.

Config.PSDispatch = false

-- Config PED and locations
Config.PedGetInfo = 'a_m_m_business_01'
Config.StarterLocation = vector4(610.74, -428.9, 24.74, 87.46)

Config.PedModel = 'g_f_y_vagos_01'
Config.Locations = {
    vector4(605.16, -385.27, 24.75, 358.05),
    vector4(623.13, -384.74, 24.73, 110.31),
    vector4(594.25, -398.34, 24.73, 281.55),
}

Config.KeyLocations = {
    vector3(597.84, -431.28, 24.74),
    vector3(605.65, -448.13, 24.69),
}

-- Route with items or money
Config.Starter = 'weed_brick'
Config.Money = 'markedbills'
Config.Order = 'weapon_garbagebag'
Config.Key = 'labkey'

Config.CooldownTime = 2 * 60 * 1000
Config.HoursInit = 0
Config.HoursEnd = 3
Config.PriceKey = math.random(5000, 10000) 

-- Config washing
Config.Cooldown = 2 * 60 * 1000                            -- Cooldown 2min
Config.Machines = {
    [1] = {
        id = 1,
        coords = vector3(1135.51, -992.28, 46.01),
        round = 0,
    },
    [2] = {
        id = 2,
        coords = vector3(1135.17, -989.54, 46.01),
        round = 0,
    },
    [3] = {
        id = 3,
        coords = vector3(1135.05, -988.23, 46.01),
        round = 0,
    },
}

Config.ModelMachine = 'bkr_prop_printmachine_6rollerp_st'
Config.MachineGun = {
    id = 100,
    coords = vector4(34.9, -2656.9, 11.04, 0.25),
    target = vector3(39.9, -2657.45, 11.63),
    round = 0
}

Config.DoorsWashing = {
    [1] = {
        doorId = 2,
        coords = vector3(1130.82, -989.19, 46.27),
    }
}