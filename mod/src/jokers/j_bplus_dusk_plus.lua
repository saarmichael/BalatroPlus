-- Spec: plannig/specs/jokers/j_dusk.yaml
BPlus.Joker({
    key = 'dusk_plus',
    loc_txt = {
        name = 'Twilight',
        text = {
            'Retrigger all played',
            'cards in {C:attention}final',
            '{C:attention}hand{} of round,',
            '{C:green}#1# in #2#{} chance to',
            'retrigger them again',
        },
    },
    config = { extra = { retriggers = 1, odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_dusk', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_twilight')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and G.GAME.current_round.hands_left == 0 then
            local bonus = SMODS.pseudorandom_probability(card, 'bplus_twilight', 1, card.ability.extra.odds)
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers + (bonus and 1 or 0),
                card = card,
            }
        end
    end,
})
