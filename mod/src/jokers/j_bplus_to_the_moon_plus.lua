-- Spec: plannig/specs/jokers/j_to_the_moon.yaml
BPlus.Joker({
    key = 'to_the_moon_plus',
    loc_txt = {
        name = 'To the Stars',
        text = {
            'Earn an extra {C:money}$#1#{} of',
            '{C:attention}interest{} for every {C:money}$5{} you',
            'have at end of round',
        },
    },
    config = { extra = { interest = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_to_the_moon', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.interest } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount + card.ability.extra.interest
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount - card.ability.extra.interest
    end,
})
