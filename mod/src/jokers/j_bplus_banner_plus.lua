-- Spec: plannig/specs/jokers/j_banner.yaml
BPlus.Joker({
    key = 'banner_plus',
    loc_txt = {
        name = 'War Banner',
        text = {
            '{C:chips}+#1#{} Chips for',
            'each remaining',
            '{C:attention}discard',
        },
    },
    config = { extra = { chips_per = 60 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_banner', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_per } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
            calc_function = function(card)
                card.joker_display_values.chips = card.ability.extra.chips_per * (G.GAME.current_round.discards_left or 0)
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.discards_left > 0 then
            return { chips = card.ability.extra.chips_per * G.GAME.current_round.discards_left }
        end
    end,
})
