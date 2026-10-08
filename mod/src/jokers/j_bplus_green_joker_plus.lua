-- Spec: plannig/specs/jokers/j_green_joker.yaml
BPlus.Joker({
    key = 'green_joker_plus',
    loc_txt = {
        name = 'Evergreen Joker',
        text = {
            '{C:mult}+#1#{} Mult per hand played',
            '{C:mult}-#2#{} Mult per discard',
            '{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)',
        },
    },
    config = { extra = { hand_add = 2, discard_sub = 1, mult = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_green_joker', state_transfer = { ['mult'] = 'extra.mult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.hand_add, e.discard_sub, e.mult } }
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
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'mult', scalar_value = 'hand_add' })
        end
        if context.discard and not context.blueprint and context.other_card == context.full_hand[#context.full_hand]
            and card.ability.extra.mult ~= 0 then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'mult',
                scalar_value = 'discard_sub',
                operation = function(ref_table, ref_value, initial, change)
                    ref_table[ref_value] = math.max(0, initial - change)
                end,
                message_key = 'a_mult_minus',
                message_colour = G.C.RED,
            })
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
