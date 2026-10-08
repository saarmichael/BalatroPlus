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

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            reminder_text = {
                { text = '(', colour = G.C.UI.TEXT_INACTIVE },
                { ref_table = 'card.joker_display_values', ref_value = 'tally' },
                { text = '/' },
                { ref_table = 'card.ability.extra', ref_value = 'needed' },
                { text = ')', colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local n = enhanced_count()
                card.joker_display_values.tally = n
                card.joker_display_values.active = n >= card.ability.extra.needed
                card.joker_display_values.x_mult = card.joker_display_values.active and card.ability.extra.Xmult or 1
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children then
                    local colour = card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
                    for _, i in ipairs({ 2, 3, 4 }) do
                        if reminder_text.children[i] then reminder_text.children[i].config.colour = colour end
                    end
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and enhanced_count() >= card.ability.extra.needed then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
