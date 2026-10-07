-- Spec: plannig/specs/jokers/j_satellite.yaml
local function unique_planets()
    local n = 0
    for _, v in pairs(G.GAME and G.GAME.consumeable_usage or {}) do
        if v.set == 'Planet' then n = n + 1 end
    end
    return n
end

BPlus.Joker({
    key = 'satellite_plus',
    loc_txt = {
        name = 'Space Station',
        text = {
            'Earn {C:money}$#1#{} at end of',
            'round per unique {C:planet}Planet',
            'card used this run',
            '{C:inactive}(Currently {C:money}$#2#{C:inactive})',
        },
    },
    config = { extra = { dollars = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_satellite', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollars * unique_planets() } }
    end,

    calc_dollar_bonus = function(self, card)
        local n = unique_planets()
        if n > 0 then return card.ability.extra.dollars * n end
    end,
})
