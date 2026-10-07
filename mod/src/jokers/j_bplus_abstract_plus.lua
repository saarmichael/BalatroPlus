-- Spec: plannig/specs/jokers/j_abstract.yaml
BPlus.Joker({
    key = 'abstract_plus',
    loc_txt = {
        name = 'Abstract Abstract Joker',
        text = {
            '{C:mult}+#1#{} Mult for',
            'each {C:attention}Joker{} card',
            '{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_abstract', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local n = G.jokers and G.jokers.cards and #G.jokers.cards or 0
        return { vars = { card.ability.extra.mult, n * card.ability.extra.mult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                card.joker_display_values.mult = (G.jokers and G.jokers.cards and #G.jokers.cards or 0) * card.ability.extra.mult
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = #G.jokers.cards * card.ability.extra.mult }
        end
    end,
})
