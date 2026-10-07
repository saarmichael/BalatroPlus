-- Spec: plannig/specs/jokers/j_loyalty_card.yaml
-- Counter is derived from G.GAME.hands_played and ability.hands_played_at_create (shared with the
-- vanilla joker through state_transfer), so it stays coherent across upgrades and behaviour switches.
local function hands_since(card)
    local played = G.GAME and G.GAME.hands_played or 0
    return played - (card.ability.hands_played_at_create or 0)
end

BPlus.Joker({
    key = 'loyalty_card_plus',
    loc_txt = {
        name = 'Membership Card',
        text = {
            '{X:red,C:white} X#1# {} Mult every',
            '{C:attention}#2#{} hands played',
            '{C:inactive}#3#',
        },
    },
    config = { extra = { Xmult = 4, every = 2, remaining = '2 remaining' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_loyalty_card', state_transfer = { ['hands_played_at_create'] = 'hands_played_at_create' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        local rem = (e.every - hands_since(card)) % (e.every + 1)
        local status = localize { type = 'variable', key = (rem == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { rem } }
        return { vars = { e.Xmult, e.every + 1, status } }
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
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'loyalty_text' },
                { text = ')' },
            },
            calc_function = function(card)
                local e = card.ability.extra
                local rem = (e.every - hands_since(card)) % (e.every + 1)
                card.joker_display_values.is_active = rem == 0
                card.joker_display_values.loyalty_text = localize {
                    type = 'variable',
                    key = (rem == 0 and 'loyalty_active' or 'loyalty_inactive'),
                    vars = { rem },
                }
                card.joker_display_values.x_mult = rem == 0 and e.Xmult or 1
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN
                        or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local e = card.ability.extra
            local rem = (e.every - 1 - hands_since(card)) % (e.every + 1)
            if rem == e.every then
                return { xmult = e.Xmult }
            elseif rem == 0 and not context.blueprint then
                local every, created = e.every, card.ability.hands_played_at_create or 0
                local eval = function() return (every - 1 - ((G.GAME.hands_played or 0) - created)) % (every + 1) == 0 end
                juice_card_until(card, eval, true)
            end
        end
    end,
})
