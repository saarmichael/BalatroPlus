-- Spec: plannig/specs/jokers/j_golden.yaml
BPlus.Joker({
    key = 'golden_plus',
    loc_txt = {
        name = 'Golden Joker+',
        text = { 'Earn {C:money}$#1#{} at', 'end of round' },
    },
    config = { extra = { dollars = 8 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_golden', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,
})
