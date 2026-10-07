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

    calculate = function(self, card, context)
        if context.joker_main then
            local hand = G.GAME.hands[context.scoring_name]
            if hand then return { mult = card.ability.extra.mult_per * hand.played } end
        end
    end,
})
