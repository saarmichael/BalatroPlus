-- Spec: plannig/specs/jokers/j_greedy_joker.yaml
BPlus.Joker({
    key = 'greedy_joker_plus',
    loc_txt = {
        name = 'Avaricious Joker',
        text = {
            'Played cards with',
            '{C:diamonds}#2#{} suit give',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { s_mult = 5, suit = 'Diamonds' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_greedy_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) then
            return { mult = card.ability.extra.s_mult }
        end
    end,
})
