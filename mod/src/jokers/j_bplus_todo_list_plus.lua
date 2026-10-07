-- Spec: plannig/specs/jokers/j_todo_list.yaml
local function pick_hand(card, avoid)
    if not (G.GAME and G.GAME.hands) then return end
    local list = {}
    for k in pairs(G.GAME.hands) do
        if SMODS.is_poker_hand_visible(k) and k ~= avoid then list[#list + 1] = k end
    end
    table.sort(list)
    if not list[1] then return end
    local in_title = card.area and card.area.config.type == 'title'
    return pseudorandom_element(list, pseudoseed(in_title and 'bplus_wishlist_title' or 'bplus_wishlist'))
end

BPlus.Joker({
    key = 'todo_list_plus',
    loc_txt = {
        name = 'Wishlist',
        text = {
            'Earn {C:money}$#1#{} if played hand',
            'contains {C:attention}#2#{},',
            'poker hand changes',
            'at end of round',
        },
    },
    config = { extra = { dollars = 5, poker_hand = 'High Card' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = {
        vanilla_key = 'j_todo_list',
        state_transfer = { ['to_do_poker_hand'] = 'extra.poker_hand' },
        carpenter_compat = true,
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, localize(card.ability.extra.poker_hand, 'poker_hands') } }
    end,

    set_ability = function(self, card, initial, delay_sprites)
        local hand = pick_hand(card, card.ability.extra.poker_hand)
        if hand then card.ability.extra.poker_hand = hand end
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.poker_hands
            and next(context.poker_hands[card.ability.extra.poker_hand] or {}) then
            return { dollars = card.ability.extra.dollars }
        end
        if context.end_of_round and context.main_eval and not context.blueprint then
            local hand = pick_hand(card, card.ability.extra.poker_hand)
            if hand then card.ability.extra.poker_hand = hand end
            return { message = localize('k_reset') }
        end
    end,
})
