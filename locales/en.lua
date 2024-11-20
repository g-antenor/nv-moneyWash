local Translations = {
    notify ={
        success = {
            ['collected_money'] = 'You collect',
            ['put_money_success'] = 'Wait 2 minutes for collect the money',
        },
        error = {
            ['not_money'] = 'You don\'t have money',
            ['money_not_ready'] = 'The money not ready',
            ['too_close'] = 'Too close to the machine',
            ['cooldown_set'] = 'Machine hot, wait a minutes',
            ['cooldown_active'] = 'Wait a minutes, the machine is hot',
        },
    },
    text = {
        info = {
            ['place_cancel'] = '[E] - Put on ground / [G] - Cancel',
        },
    },
    target ={
        ['laundry'] = 'Wash Clothing',
        ['remove_machine'] = 'Remove Machine',
    },
    progress = {
        ['put_money_in_machine'] = 'Put money in the machine',
        ['put_object'] = 'Put the object',
    },
    menu = {
        ['header'] = 'Laundry',

        ['deposit_title'] = 'Put your durty clothing here',
        ['deposit_description'] = 'Wash your clothing here 😉.',

        ['withdraw_title'] = 'Take washing money',
        ['withdraw_description'] = 'Your money is clear.'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})