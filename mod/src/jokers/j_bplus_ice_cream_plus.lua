-- Spec: plannig/specs/jokers/j_ice_cream.yaml
BPlus.Joker({
    key = 'ice_cream_plus',
    loc_txt = {
        name = 'Chocolate Bar',
        text = {
            '{C:chips}+#1#{} Chips',
            '{C:chips}-#2#{} Chips for',
            'every hand played',
        },
    },
    config = { extra = { chips = 150, chip_mod = 5 } },
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_ice_cream', state_transfer = {}, carpenter_compat = false },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
        if context.after and not context.blueprint then
            if card.ability.extra.chips - card.ability.extra.chip_mod <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return { message = localize('k_melted_ex'), colour = G.C.CHIPS }
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra, ref_value = 'chips', scalar_value = 'chip_mod',
                    operation = '-', message_key = 'a_chips_minus',
                })
            end
        end
    end,
})
