-- Spec: plannig/specs/mechanics/M1_carpenter.yaml (redesigned by the human 2026-10-08, decision D22)
-- Carpenter: sell it to create the "+" version of the last Joker sold (fresh, no edition, no stickers).
local cfg = BPlus.balance.carpenter
local CARPENTER_KEY = 'j_bplus_carpenter'

BPlus.dict({
    k_bplus_carpenter_none = 'Nothing to build',
})

-- The "+" key Carpenter would create right now (nil = nothing).
function BPlus.carpenter_target()
    local key = G.GAME and G.GAME.bplus_last_sold
    if not key then return nil end
    if BPlus.base_map[key] then return key end
    return BPlus.upgrade_map[key]
end

local function target_name()
    local key = BPlus.carpenter_target()
    if not (key and G.P_CENTERS[key]) then return nil end
    return localize({ type = 'name_text', set = 'Joker', key = key })
end

-- Called when a Carpenter is sold (before the sell itself runs).
local function carpenter_sold(card)
    local key = BPlus.carpenter_target()
    if not key then
        card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = localize('k_bplus_carpenter_none'), colour = G.C.RED })
        return
    end
    -- After the sale this card's slot is gone; a Negative Carpenter also takes a slot of the limit with it.
    local limit_after = G.jokers.config.card_limit - ((card.edition and card.edition.negative) and 1 or 0)
    if #G.jokers.cards - 1 >= limit_after then
        card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = localize('k_no_room_ex'), colour = G.C.RED })
        return
    end
    G.GAME.bplus_last_sold = nil -- consumed
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        blocking = false,
        func = function()
            if not card.removed then return false end -- wait until the sold Carpenter is gone
            local new = SMODS.add_card({ set = 'Joker', key = key, area = G.jokers, no_edition = true })
            new:juice_up(0.8, 0.5)
            play_sound('generic1')
            return true
        end,
    }))
end

local sell_ref = Card.sell_card
function Card:sell_card()
    if self.ability and self.ability.set == 'Joker' and G.GAME then
        if self.config.center.key == CARPENTER_KEY then
            carpenter_sold(self)
        else
            G.GAME.bplus_last_sold = self.config.center.key
        end
    end
    return sell_ref(self)
end

SMODS.Joker({
    key = 'carpenter',
    loc_txt = {
        name = 'Carpenter',
        text = {
            'Sell this card to create the',
            '{C:attention}upgraded{} version of the',
            'last {C:attention}Joker{} sold',
            '{C:inactive}(Currently: {C:attention}#1#{C:inactive})',
        },
    },
    rarity = cfg.rarity, cost = cfg.cost,
    atlas = 'placeholder', pos = { x = 0, y = 0 },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    config = {},

    loc_vars = function(self, info_queue, card)
        return { vars = { target_name() or 'none' } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'target' },
                { text = ')' },
            },
            calc_function = function(card)
                card.joker_display_values.target = target_name() or 'none'
            end,
        }
    end,
})
