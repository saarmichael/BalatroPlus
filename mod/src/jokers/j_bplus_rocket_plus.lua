-- Spec: plannig/specs/jokers/j_rocket.yaml
BPlus.Joker({
    key = 'rocket_plus',
    loc_txt = {
        name = 'Spaceship',
        text = {
            'Earn {C:money}$#1#{} at end of round',
            'Payout increases by {C:money}$#2#{}',
            'when {C:attention}Boss Blind{} is defeated',
        },
    },
    config = { extra = { dollars = 1, increase = 4 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_rocket', state_transfer = { ['extra.dollars'] = 'extra.dollars' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.increase } }
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint and G.GAME.blind.boss then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'dollars',
                scalar_value = 'increase',
                message_colour = G.C.MONEY,
            })
            return nil, true
        end
    end,
})
