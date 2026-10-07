-- Spec: plannig/specs/jokers/j_odd_todd.yaml
BPlus.Joker({
    key = 'odd_todd_plus',
    loc_txt = {
        name = 'Todd the Odd',
        text = {
            'Played cards with',
            '{C:attention}odd{} rank give',
            '{C:chips}+#1#{} Chips when scored',
            '{C:inactive}(A, 9, 7, 5, 3)',
        },
    },
    config = { extra = { chips = 67 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_odd_todd', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and ((context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id() % 2 == 1) or context.other_card:get_id() == 14) then
            return { chips = card.ability.extra.chips }
        end
    end,
})
