-- Spec: plannig/specs/jokers/j_mystic_summit.yaml
BPlus.Joker({
    key = 'mystic_summit_plus',
    loc_txt = {
        name = 'Mystic Zenith',
        text = {
            '{C:mult}+#1#{} Mult when',
            '{C:attention}#2#{} discards',
            'remaining',
        },
    },
    config = { extra = { mult = 35, d_remaining = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_mystic_summit', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.d_remaining } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.discards_left == card.ability.extra.d_remaining then
            return { mult = card.ability.extra.mult }
        end
    end,
})
