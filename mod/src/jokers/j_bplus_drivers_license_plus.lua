-- Spec: plannig/specs/jokers/j_drivers_license.yaml
local function enhanced_count()
    local n = 0
    for _, c in ipairs(G.playing_cards or {}) do
        if next(SMODS.get_enhancements(c)) then n = n + 1 end
    end
    return n
end

BPlus.Joker({
    key = 'drivers_license_plus',
    loc_txt = {
        name = 'Fake ID',
        text = {
            '{X:mult,C:white} X#1# {} Mult if you have',
            'at least {C:attention}#3#{} Enhanced',
            'cards in your full deck',
            '{C:inactive}(Currently {C:attention}#2#{C:inactive})',
        },
    },
    config = { extra = { Xmult = 3, needed = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_drivers_license', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.Xmult, enhanced_count(), e.needed } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and enhanced_count() >= card.ability.extra.needed then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
