-- Spec: plannig/specs/jokers/j_blueprint.yaml
local function targets(card)
    local out = {}
    for i, c in ipairs(G.jokers.cards) do
        if c == card then
            for n = 1, card.ability.extra.copies do out[#out + 1] = G.jokers.cards[i + n] end
        end
    end
    return out
end

BPlus.Joker({
    key = 'blueprint_plus',
    loc_txt = {
        name = 'Architect',
        text = {
            'Copies ability of the',
            '{C:attention}#1# Jokers{} to the right',
        },
    },
    config = { extra = { copies = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_blueprint', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        card.ability.blueprint_compat_ui = card.ability.blueprint_compat_ui or ''
        card.ability.blueprint_compat_check = nil
        local main_end = (card.area and card.area == G.jokers) and {
            { n = G.UIT.C, config = { align = 'bm', minh = 0.4 }, nodes = {
                { n = G.UIT.C, config = { ref_table = card, align = 'm', colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06, func = 'blueprint_compat' }, nodes = {
                    { n = G.UIT.T, config = { ref_table = card.ability, ref_value = 'blueprint_compat_ui', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                } },
            } },
        } or nil
        return { vars = { card.ability.extra.copies }, main_end = main_end }
    end,

    update = function(self, card, dt)
        if G.STAGE == G.STAGES.RUN and G.jokers then
            local ok = false
            for _, other in ipairs(targets(card)) do
                if other ~= card and other.config.center.blueprint_compat then ok = true end
            end
            card.ability.blueprint_compat = ok and 'compatible' or 'incompatible'
        end
    end,

    calculate = function(self, card, context)
        local rets = {}
        for _, other in ipairs(targets(card)) do
            local ret = SMODS.blueprint_effect(card, other, context)
            if ret then
                ret.colour = G.C.BLUE
                rets[#rets + 1] = ret
            end
        end
        if #rets > 0 then return SMODS.merge_effects(rets) end
    end,
})
