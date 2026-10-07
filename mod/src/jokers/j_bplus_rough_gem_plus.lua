-- Spec: plannig/specs/jokers/j_rough_gem.yaml
BPlus.Joker({
    key = 'rough_gem_plus',
    loc_txt = {
        name = 'Gemstone',
        text = {
            'Played cards with',
            '{C:diamonds}Diamond{} suit earn',
            '{C:money}$#1#{} when scored',
        },
    },
    config = { extra = { dollars = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_rough_gem', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Diamonds') then
            -- dollar_buffer like vanilla, so the HUD total is right while the hand is scoring
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            G.E_MANAGER:add_event(Event({ func = function() G.GAME.dollar_buffer = 0; return true end }))
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
