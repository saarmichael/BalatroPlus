-- Spec: plannig/specs/jokers/j_ancient.yaml
-- Ur-Joker keeps its own suit in G.GAME.current_round.bplus_ur_card (separate from vanilla's ancient_card),
-- shared by every Ur-Joker. Picked weighted by how common each suit is in the full deck.

local SUITS = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }

function BPlus.reset_ur_card()
    local counts, total = {}, 0
    for _, s in ipairs(SUITS) do counts[s] = 0 end
    for _, c in ipairs(G.playing_cards or {}) do
        if not SMODS.has_no_suit(c) and counts[c.base.suit] then
            counts[c.base.suit] = counts[c.base.suit] + 1
            total = total + 1
        end
    end
    local roll = pseudorandom(pseudoseed('bplus_ur_joker' .. G.GAME.round_resets.ante))
    local pick
    if total == 0 then
        pick = SUITS[math.min(#SUITS, math.floor(roll * #SUITS) + 1)]
    else
        local acc = 0
        for _, s in ipairs(SUITS) do
            acc = acc + counts[s] / total
            if roll < acc then pick = s; break end
        end
        if not pick then -- float rounding: last suit with cards
            for i = #SUITS, 1, -1 do if counts[SUITS[i]] > 0 then pick = SUITS[i]; break end end
        end
    end
    G.GAME.current_round.bplus_ur_card = { suit = pick }
end

-- reset_ancient_card runs at run start and at the end of every round
local reset_ancient_card_ref = reset_ancient_card
function reset_ancient_card(...)
    local ret = reset_ancient_card_ref(...)
    BPlus.reset_ur_card()
    return ret
end

local function ur_suit()
    local cr = G.GAME and G.GAME.current_round
    return cr and cr.bplus_ur_card and cr.bplus_ur_card.suit or 'Spades'
end

BPlus.Joker({
    key = 'ancient_plus',
    loc_txt = {
        name = 'Ur-Joker',
        text = {
            'Each played card with',
            '{V:1}#2#{} suit gives',
            '{X:mult,C:white} X#1# {} Mult when scored,',
            '{s:0.8}suit changes at end of round,',
            '{s:0.8}favouring suits common in your deck',
        },
    },
    config = { extra = { Xmult = 1.5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_ancient', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local suit = ur_suit()
        return { vars = { card.ability.extra.Xmult, localize(suit, 'suits_singular') }, colours = { G.C.SUITS[suit] } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(ur_suit()) then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
