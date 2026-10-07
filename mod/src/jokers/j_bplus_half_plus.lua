-- Spec: plannig/specs/jokers/j_half.yaml
BPlus.Joker({
    key = 'half_plus',
    loc_txt = {
        name = 'Bigger Half Joker',
        text = {
            '{C:red}+#1#{} Mult if played',
            'hand contains',
            '{C:attention}#2#{} or fewer cards',
        },
    },
    config = { extra = { mult = 40, size = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_half', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.size } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and #context.full_hand <= card.ability.extra.size then
            return { mult = card.ability.extra.mult }
        end
    end,
})
