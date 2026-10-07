-- Spec: plannig/specs/jokers/j_arrowhead.yaml
BPlus.Joker({
    key = 'arrowhead_plus',
    loc_txt = {
        name = 'Spearhead',
        text = {
            'Played cards with',
            '{C:spades}Spade{} suit give',
            '{C:chips}+#1#{} Chips when scored',
        },
    },
    config = { extra = { chips = 80 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_arrowhead', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Spades') then
            return { chips = card.ability.extra.chips }
        end
    end,
})
