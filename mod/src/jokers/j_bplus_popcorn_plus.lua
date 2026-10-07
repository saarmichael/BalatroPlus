-- Spec: plannig/specs/jokers/j_popcorn.yaml
BPlus.Joker({
    key = 'popcorn_plus',
    loc_txt = {
        name = 'Nacho Chips',
        text = {
            '{C:mult}+#1#{} Mult',
            '{C:mult}-#2#{} Mult per',
            'round played',
        },
    },
    config = { extra = { mult = 50, mult_mod = 5 } },
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_popcorn', state_transfer = {}, carpenter_compat = false },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
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
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
        if context.end_of_round and context.main_eval and not context.game_over and not context.blueprint then
            if card.ability.extra.mult - card.ability.extra.mult_mod <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return { message = localize('k_eaten_ex'), colour = G.C.RED }
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra, ref_value = 'mult', scalar_value = 'mult_mod',
                    operation = '-', message_key = 'a_mult_minus', colour = G.C.MULT,
                })
            end
        end
    end,
})
