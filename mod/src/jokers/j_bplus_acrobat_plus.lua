-- Spec: plannig/specs/jokers/j_acrobat.yaml
BPlus.Joker({
    key = 'acrobat_plus',
    loc_txt = {
        name = 'Nadia Comăneci',
        text = {
            '{X:red,C:white} X#1# {} Mult on {C:attention}final',
            '{C:attention}hand{} of round',
        },
    },
    config = { extra = { Xmult = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_acrobat', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            calc_function = function(card)
                local last = (G.GAME.current_round.hands_left == 1 and not next(G.play.cards))
                    or (G.GAME.current_round.hands_left == 0 and next(G.play.cards))
                card.joker_display_values.x_mult = last and card.ability.extra.Xmult or 1
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_left == 0 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
