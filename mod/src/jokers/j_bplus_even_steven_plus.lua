-- Spec: plannig/specs/jokers/j_even_steven.yaml
BPlus.Joker({
    key = 'even_steven_plus',
    loc_txt = {
        name = 'Steven the Even',
        text = {
            'Played cards with',
            '{C:attention}even{} rank give',
            '{C:mult}+#1#{} Mult when scored',
            '{C:inactive}(10, 8, 6, 4, 2)',
        },
    },
    config = { extra = { mult = 8 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_even_steven', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id() % 2 == 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
