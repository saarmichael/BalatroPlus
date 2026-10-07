-- Spec: plannig/specs/jokers/j_stencil.yaml
-- N = empty Joker slots + every held Joker Stencil / Joker Mold (itself included).
local function stencil_count()
    if not (G.jokers and G.jokers.cards) then return 0, 0 end
    local empty = G.jokers.config.card_limit - #G.jokers.cards
    local n = empty
    for _, j in ipairs(G.jokers.cards) do
        local key = j.config.center.key
        if key == 'j_stencil' or key == 'j_bplus_stencil_plus' then n = n + 1 end
    end
    return n, empty
end

BPlus.Joker({
    key = 'stencil_plus',
    loc_txt = {
        name = 'Joker Mold',
        text = {
            '{X:red,C:white} X#1# {} Mult for each',
            'empty {C:attention}Joker{} slot',
            '{s:0.8}Joker Mold included',
            '{C:inactive}(Currently {X:red,C:white} X#2# {C:inactive})',
        },
    },
    config = { extra = { Xmult_per = 1.5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_stencil', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local n = stencil_count()
        return { vars = { card.ability.extra.Xmult_per, card.ability.extra.Xmult_per * n } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local n, empty = stencil_count()
            if empty > 0 then
                return { xmult = card.ability.extra.Xmult_per * n }
            end
        end
    end,
})
