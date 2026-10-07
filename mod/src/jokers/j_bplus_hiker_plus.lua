-- Spec: plannig/specs/jokers/j_hiker.yaml
BPlus.Joker({
    key = 'hiker_plus',
    loc_txt = {
        name = 'Jogger',
        text = {
            'Every played {C:attention}card{}',
            'permanently gains',
            '{C:chips}+#1#{} Chips when scored',
        },
    },
    config = { extra = { chips = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_hiker', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {} -- vanilla Hiker shows nothing either
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            other.ability.perma_bonus = (other.ability.perma_bonus or 0) + card.ability.extra.chips
            return {
                extra = { message = localize('k_upgrade_ex'), colour = G.C.CHIPS },
                colour = G.C.CHIPS,
                card = card,
            }
        end
    end,
})
