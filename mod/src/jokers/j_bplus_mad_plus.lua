-- Spec: plannig/specs/jokers/j_mad.yaml
BPlus.Joker({
    key = 'mad_plus',
    loc_txt = {
        name = 'Livid Joker',
        text = { '{C:red}+#1#{} Mult if played', 'hand contains', '{C:attention}#2#{}' },
    },
    config = { extra = { t_mult = 24, type = 'Two Pair' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_mad', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
})
