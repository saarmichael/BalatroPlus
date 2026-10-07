-- Spec: plannig/specs/jokers/j_walkie_talkie.yaml
BPlus.Joker({
    key = 'walkie_talkie_plus',
    loc_txt = {
        name = 'Ham Radio',
        text = {
            'Each played {C:attention}10{} gives',
            '{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult,',
            'each played {C:attention}4{} gives',
            '{C:chips}+#3#{} Chips and {C:mult}+#4#{} Mult',
            'when scored',
        },
    },
    config = { extra = { ten_chips = 100, ten_mult = 4, four_chips = 10, four_mult = 40 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_walkie_talkie', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.ten_chips, card.ability.extra.ten_mult, card.ability.extra.four_chips, card.ability.extra.four_mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 10 then
                return { chips = card.ability.extra.ten_chips, mult = card.ability.extra.ten_mult }
            elseif context.other_card:get_id() == 4 then
                return { chips = card.ability.extra.four_chips, mult = card.ability.extra.four_mult }
            end
        end
    end,
})
