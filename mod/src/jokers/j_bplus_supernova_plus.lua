-- Spec: plannig/specs/jokers/j_supernova.yaml
BPlus.Joker({
    key = 'supernova_plus',
    loc_txt = {
        name = 'Hypernova',
        text = {
            'Adds {C:attention}#1#X{} the number of times',
            '{C:attention}poker hand{} has been',
            'played this run to Mult',
        },
    },
    config = { extra = { mult_per = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_supernova', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_per } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                local text = JokerDisplay.evaluate_hand()
                local hand = text ~= 'Unknown' and G.GAME.hands[text]
                card.joker_display_values.mult = hand and card.ability.extra.mult_per
                    * (hand.played + (next(G.play.cards) and 0 or 1)) or 0
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local hand = G.GAME.hands[context.scoring_name]
            if hand then return { mult = card.ability.extra.mult_per * hand.played } end
        end
    end,
})
