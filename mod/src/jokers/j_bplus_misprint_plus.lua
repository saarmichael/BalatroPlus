-- Spec: plannig/specs/jokers/j_misprint.yaml
-- Vanilla shows a scrolling random number (custom UI in card.lua); this one uses plain text.
BPlus.Joker({
    key = 'misprint_plus',
    loc_txt = {
        name = 'Never Misprint',
        text = {
            '{C:red}+#1#{} to {C:red}+#2#{} Mult',
            '{C:inactive}(random each hand)',
        },
    },
    config = { extra = { min = 10, max = 50 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_misprint', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.min, card.ability.extra.max } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = pseudorandom('bplus_misprint', card.ability.extra.min, card.ability.extra.max) }
        end
    end,
})
