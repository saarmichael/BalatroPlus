-- Spec: plannig/specs/jokers/j_onyx_agate.yaml
BPlus.Joker({
    key = 'onyx_agate_plus',
    loc_txt = {
        name = 'Obsidian',
        text = {
            'Played cards with',
            '{C:clubs}Club{} suit give',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { mult = 15 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_onyx_agate', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Clubs') then
            return { mult = card.ability.extra.mult }
        end
    end,
})
