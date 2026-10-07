-- Spec: plannig/specs/jokers/j_ride_the_bus.yaml
BPlus.Joker({
    key = 'ride_the_bus_plus',
    loc_txt = {
        name = 'Express Bus',
        text = {
            'This Joker gains {C:mult}+#1#{} Mult',
            'per {C:attention}consecutive{} hand',
            'played without a',
            'scoring {C:attention}face{} card',
            '{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult_gain = 2, mult = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_ride_the_bus', state_transfer = { ['mult'] = 'extra.mult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
        }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local faces = false
            for _, c in ipairs(context.scoring_hand) do
                if c:is_face() then faces = true end
            end
            if faces then
                if card.ability.extra.mult > 0 then
                    SMODS.reset_card(card, { ref_table = card.ability.extra, ref_value = 'mult', reset_value = 0 })
                end
            else
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'mult', scalar_value = 'mult_gain', no_message = true })
            end
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
