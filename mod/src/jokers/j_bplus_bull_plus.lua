-- Spec: plannig/specs/jokers/j_bull.yaml
BPlus.Joker({
    key = 'bull_plus',
    loc_txt = {
        name = 'Golden Bull',
        text = {
            '{C:chips}+#1#{} Chips for',
            'each {C:money}$1{} you have',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips_per = 5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_bull', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_per, card.ability.extra.chips_per * math.max(0, G.GAME.dollars or 0) } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
            calc_function = function(card)
                card.joker_display_values.chips = card.ability.extra.chips_per * math.max(0, G.GAME.dollars or 0)
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local money = (G.GAME.dollars + (G.GAME.dollar_buffer or 0))
            if money > 0 then
                return { chips = card.ability.extra.chips_per * money }
            end
        end
    end,
})
