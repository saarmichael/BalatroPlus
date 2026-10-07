-- Spec: plannig/specs/jokers/j_cloud_9.yaml
local function nines()
    local n = 0
    for _, c in ipairs(G.playing_cards or {}) do
        if c:get_id() == 9 then n = n + 1 end
    end
    return n
end

BPlus.Joker({
    key = 'cloud_9_plus',
    loc_txt = {
        name = 'Nine Nines',
        text = {
            'Earn {C:money}$#1#{} for each',
            '{C:attention}9{} in your {C:attention}full deck',
            'at end of round',
            '{C:inactive}(Currently {C:money}$#2#{}{C:inactive})',
        },
    },
    config = { extra = { dollars = 3 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_cloud_9', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollars * nines() } }
    end,

    calc_dollar_bonus = function(self, card)
        local n = nines()
        if n > 0 then return card.ability.extra.dollars * n end
    end,
})
