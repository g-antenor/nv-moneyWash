local Translations = {
    notify ={
        success = {
            ['start_route_to_buy'] = 'Route started! Follow the map for next location.',
            
            -- Blips BuyKey
            ['buyKey_blip'] = 'Information Key',
            ['getKey_blip'] = 'Take the key',
            ['collected_key'] = 'You collect the key.',

            ['collected_money'] = 'You collect $',
            ['put_money_success'] = 'Wait 2 minutes for collect the money',

            ['use_key'] = 'Use Key',
        },
        error = {
            ['no_money'] = 'You don\'t have enough money.',
            ['finish_route'] = 'You have finished the route.',
            ['not_item'] = 'You don\'t have the item',
            ['not_money'] = 'You don\'t have money',
            ['machine_on'] = 'The machine washing',
            ['money_not_ready'] = 'The money not ready',
            ['hot_machine'] = 'The machine is hot, wait 15 minutes',
            ['put_money'] = 'Not Now'
        },
    },
    target ={
        ['start_route_to_buy'] = 'Get Information',
        ['start_machine'] = 'Start Machine',
        ['laundry'] = 'Wash Clothing',
        ['buyKey'] = 'Buy Key',
        ['getKey'] = 'Get Key',
    },
    progress = {
        ['put_money_in_machine'] = 'Put money in the machine',
    },
    menu = {
        ['header'] = 'Laundry',

        ['deposit_title'] = 'Put your durty clothing here',
        ['deposit_description'] = 'Wash your clothing here 😉.',

        ['withdraw_title'] = 'Take washing money',
        ['withdraw_description'] = 'Your money is clear.'
    },
    blips = {
        ['start_buy'] = 'Get Information',
        ['getKey'] = 'Get the key'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})