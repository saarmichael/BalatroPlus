-- Spec: plannig/specs/jokers/j_egg.yaml
-- Not Carpenter-compatible. extra_value lives on the card and survives set_ability.
BPlus.Joker({
    key = 'egg_plus',
    loc_txt = {
        name = 'Free Range Egg',
        text = { 'Gains {C:money}$#1#{} of', '{C:attention}sell value{} at', 'end of round' },
    },
    config = { extra = { sell_gain = 5 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_egg', state_transfer = {}, carpenter_compat = false },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_gain } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { text = '$', colour = G.C.GOLD },
                { ref_table = 'card', ref_value = 'sell_cost', colour = G.C.GOLD },
                { text = ')' },
            },
            reminder_text_config = { scale = 0.35 },
        }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability,
                ref_value = 'extra_value',
                scalar_table = card.ability.extra,
                scalar_value = 'sell_gain',
                scaling_message = { message = localize('k_val_up'), colour = G.C.MONEY },
            })
            card:set_cost()
            return nil, true
        end
    end,
})
