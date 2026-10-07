-- Spec: plannig/specs/jokers/j_erosion.yaml
BPlus.Joker({
    key = 'erosion_plus',
    loc_txt = {
        name = 'Landslide',
        text = {
            '{C:red}+#1#{} Mult for each',
            'card below {C:attention}#3#{}',
            'in your full deck',
            '{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult = 8 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_erosion', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local missing = G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0
        return { vars = { card.ability.extra.mult, math.max(0, card.ability.extra.mult * missing), G.GAME.starting_deck_size } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local missing = G.GAME.starting_deck_size - #G.playing_cards
            if missing > 0 then return { mult = missing * card.ability.extra.mult } end
        end
    end,
})
