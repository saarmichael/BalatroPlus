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

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$' },
                { ref_table = 'card.joker_display_values', ref_value = 'dollars' },
            },
        text_config = { colour = G.C.GOLD },
        reminder_text = {
            { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
        },
            calc_function = function(card)
                card.joker_display_values.dollars = math.max(G.GAME.current_round.discards_left, 0) * card.ability.extra.dollars
                card.joker_display_values.localized_text = '(' .. localize('k_round') .. ')'
            end,
        }
    end,

    calc_dollar_bonus = function(self, card)
        local left = G.GAME.current_round.discards_left
        if left > 0 then return left * card.ability.extra.dollars end
    end,
})
