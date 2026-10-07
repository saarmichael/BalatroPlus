-- Spec: plannig/specs/jokers/j_square.yaml
BPlus.Joker({
    key = 'square_plus',
    loc_txt = {
        name = 'Square Joker Squared',
        text = {
            'This Joker gains {C:chips}+#1#{} Chips',
            'if played hand has',
            'exactly {C:attention}4{} cards',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips = 0, chip_mod = 16 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_square', state_transfer = { ['extra.chips'] = 'extra.chips' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_mod, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and #context.full_hand == 4 then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'chips', scalar_value = 'chip_mod' })
        end
        if context.joker_main and card.ability.extra.chips > 0 then
            return { chips = card.ability.extra.chips }
        end
    end,
})
