-- Spec: plannig/specs/jokers/j_reserved_parking.yaml
BPlus.Joker({
    key = 'reserved_parking_plus',
    loc_txt = {
        name = 'Valet Parking',
        text = {
            'Each {C:attention}face{} card',
            'held in hand has',
            'a {C:green}#2# in #3#{} chance',
            'to give {C:money}$#1#{}',
        },
    },
    config = { extra = { odds = 2, dollars = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_reserved_parking', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_valet_parking')
        return { vars = { card.ability.extra.dollars, num, den } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round
            and context.other_card:is_face()
            and SMODS.pseudorandom_probability(card, 'bplus_valet_parking', 1, card.ability.extra.odds) then
            if context.other_card.debuff then
                return { message = localize('k_debuffed'), colour = G.C.RED, card = card }
            end
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            G.E_MANAGER:add_event(Event({ func = function() G.GAME.dollar_buffer = 0; return true end }))
            return { dollars = card.ability.extra.dollars, card = card }
        end
    end,
})
