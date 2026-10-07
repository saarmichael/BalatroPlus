-- Spec: plannig/specs/jokers/j_delayed_grat.yaml
BPlus.Joker({
    key = 'delayed_grat_plus',
    loc_txt = {
        name = 'Instant Gratification',
        text = { 'Earn {C:money}$#1#{} per remaining', '{C:attention}discard{} at end of the round' },
    },
    config = { extra = { dollars = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_delayed_grat', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calc_dollar_bonus = function(self, card)
        local left = G.GAME.current_round.discards_left
        if left > 0 then return left * card.ability.extra.dollars end
    end,
})
