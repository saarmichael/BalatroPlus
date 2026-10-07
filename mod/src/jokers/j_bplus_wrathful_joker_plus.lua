-- Spec: plannig/specs/jokers/j_wrathful_joker.yaml
BPlus.Joker({
    key = 'wrathful_joker_plus',
    loc_txt = {
        name = 'Furious Joker',
        text = {
            'Played cards with',
            '{C:spades}#2#{} suit give',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { s_mult = 5, suit = 'Spades' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_wrathful_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) then
            return { mult = card.ability.extra.s_mult }
        end
    end,
})
