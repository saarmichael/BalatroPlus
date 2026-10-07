-- Spec: plannig/specs/jokers/j_steel_joker.yaml
local function steel_count()
    local n = 0
    for _, c in ipairs(G.playing_cards or {}) do
        if SMODS.has_enhancement(c, 'm_steel') then n = n + 1 end
    end
    return n
end

BPlus.Joker({
    key = 'steel_joker_plus',
    loc_txt = {
        name = 'Stainless Steel Joker',
        text = {
            'Gives {X:mult,C:white} X#1# {} Mult',
            'for each {C:attention}Steel Card',
            'in your {C:attention}full deck',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult_per = 0.4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_steel_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local per = card.ability.extra.Xmult_per
        return { vars = { per, 1 + per * steel_count() } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local n = steel_count()
            if n > 0 then
                return { xmult = 1 + card.ability.extra.Xmult_per * n }
            end
        end
    end,
})
