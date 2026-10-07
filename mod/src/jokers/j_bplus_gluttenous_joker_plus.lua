-- Spec: plannig/specs/jokers/j_gluttenous_joker.yaml
BPlus.Joker({
    key = 'gluttenous_joker_plus',
    loc_txt = {
        name = 'Edacious Joker',
        text = {
            'Played cards with',
            '{C:clubs}#2#{} suit give',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { s_mult = 5, suit = 'Clubs' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_gluttenous_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) then
            return { mult = card.ability.extra.s_mult }
        end
    end,
})
