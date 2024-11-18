Config = {}

Config.PoliceRequired = 1

-- Config resources
Config.Inventory = 'qb'             -- "qb": qb-inventory,  "ox": ox-inventory.
Config.Target    = 'qb'             -- "qb": qb-target,     "ox": ox-target.
Config.Util      = 'qb'             -- "qb": qb-progress,   "ox": ox-progress.

Config.PSDispatch = false

Config.Money = 'markedbills'
Config.Key = 'labkey'

Config.CooldownTime = 2 * 60 * 1000

-- Props
Config.ModelProp = 'prop_washer_02'                             -- Prop washing "Safe"
Config.ModelMachine = 'bkr_prop_printmachine_6rollerp_st'       -- Prop washing "PVP"

-- Config washing
Config.Cooldown = 2 * 60 * 1000                                 -- Cooldown 2min
Config.Machines = {                                             -- List of machines in map
    [1] = {
        id = 1,                                                 -- Machine identifier in DB
        coords = vector4(31.01, -2664.94, 12.05, 281.37),       -- Coords machine and spawn prop (if enabled)
        prop_enabled = true,                                    -- Enable prop or not (true or false)
        round = 0,                                              -- Machine round to enter in cooldown
    },
    [2] = {
        id = 2,
        coords = vector4(30.78, -2668.24, 12.05, 273.8),
        prop_enabled = true,
        round = 0,
    },
    [3] = {
        id = 3,
        coords = vector3(1135.05, -988.23, 46.01),
        prop_enabled = false,
        round = 0,
    },
}

-- Machine gun settings
-- For creating new, follow example and add "id" above 100
Config.MachineGun = {
    id = 100,                                                   -- Machine identifier in DB
    coords = vector4(34.9, -2656.9, 12.04, 0.25),               -- Coords spawn machine prop
    target = vector3(39.9, -2657.45, 11.63),                    -- Target machine (following estructure of machine, the panel is in this location)
    round = 0                                                   -- Machine round to enter in cooldown
}