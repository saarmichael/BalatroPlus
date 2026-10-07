-- Spec: plannig/specs/jokers/j_fibonacci.yaml
BPlus.Joker({
    key = 'fibonacci_plus',
    loc_txt = {
        name = 'Perfect Storm',
        text = {
            'Each played {C:attention}Ace{},',
            '{C:attention}2{}, {C:attention}3{}, {C:attention}5{}, or {C:attention}8{} gives',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { mult = 13 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_fibonacci', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 14 or context.other_card:get_id() == 2 or context.other_card:get_id() == 3 or context.other_card:get_id() == 5 or context.other_card:get_id() == 8) then
            return { mult = card.ability.extra.mult }
        end
    end,
})
