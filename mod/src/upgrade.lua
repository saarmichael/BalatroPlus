-- "+" joker registry and the one permanent-upgrade entry point.
--
--   BPlus.Joker{ ... }          declare a "+" joker (wraps SMODS.Joker, registers the map entry)
--   BPlus.upgrade_map           vanilla_key -> plus_key   (built from the BPlus.Joker calls)
--   BPlus.base_map              plus_key -> vanilla_key
--   BPlus.is_plus(card)         is this card a "+" joker?
--   BPlus.is_eligible(card)     can it be upgraded? (has a "+" version, isn't one already)
--   BPlus.upgrade_card(card)    permanent upgrade in place; returns true if it upgraded
--
-- See plannig/CONVENTIONS.md section 4 and 6.

BPlus.upgrade_map = {}
BPlus.base_map = {}

-- def.bplus = { vanilla_key = 'j_x', state_transfer = { ['src.path'] = 'dst.path' }, carpenter_compat = true }
-- Defaults filled in: rarity and cost (= the vanilla joker's), placeholder art, unlocked, never
-- spawns on its own (in_pool false: "+" jokers only appear through the upgrade mechanics).
function BPlus.Joker(def)
    local info = def.bplus
    assert(info and info.vanilla_key, 'BPlus.Joker: bplus.vanilla_key is required')
    local vanilla = G.P_CENTERS[info.vanilla_key]
    assert(vanilla, 'BPlus.Joker: unknown vanilla key ' .. tostring(info.vanilla_key))
    info.state_transfer = info.state_transfer or {}
    if info.carpenter_compat == nil then info.carpenter_compat = true end

    if def.rarity == nil then def.rarity = vanilla.rarity end
    if def.cost == nil then def.cost = vanilla.cost end
    if def.atlas == nil then
        def.atlas = 'placeholder'
        def.pos = def.pos or { x = 0, y = 0 }
    end
    if def.unlocked == nil then def.unlocked = true end
    if def.discovered == nil then def.discovered = false end
    if def.in_pool == nil then def.in_pool = function() return false end end

    local obj = SMODS.Joker(def)
    BPlus.upgrade_map[info.vanilla_key] = obj.key
    BPlus.base_map[obj.key] = info.vanilla_key
    return obj
end

function BPlus.is_plus(card)
    return card and card.config and card.config.center and BPlus.base_map[card.config.center.key] ~= nil or false
end

function BPlus.is_eligible(card)
    if not (card and card.ability and card.ability.set == 'Joker') then return false end
    local key = card.config.center.key
    return BPlus.upgrade_map[key] ~= nil and not BPlus.is_plus(card)
end

-- All eligible jokers in G.jokers (for "pick a random eligible joker" mechanics).
function BPlus.eligible_jokers()
    local list = {}
    for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
        if BPlus.is_eligible(card) then list[#list + 1] = card end
    end
    return list
end

-- Permanently turns a vanilla joker into its "+" version, in place. Keeps position, edition and
-- stickers; copies the fields in the "+" joker's bplus.state_transfer. Does nothing (returns false)
-- for jokers without an upgrade or already upgraded. `opts.silent` skips the juice + message.
function BPlus.upgrade_card(card, opts)
    if not BPlus.is_eligible(card) then return false end
    opts = opts or {}
    local plus = G.P_CENTERS[BPlus.upgrade_map[card.config.center.key]]

    -- Drop any alternate-behaviour state first, so the card is in its own shape.
    BPlus.reset_behavior(card)

    local moved = {}
    for src, dst in pairs(plus.bplus.state_transfer) do
        moved[dst] = BPlus.copy(BPlus.get_path(card.ability, src))
    end
    local edition = card.edition and copy_table(card.edition)
    local stickers = {}
    for _, k in ipairs({ 'eternal', 'perishable', 'rental' }) do stickers[k] = card.ability[k] end
    local perish_tally = card.ability.perish_tally

    card:set_ability(plus)

    for dst, v in pairs(moved) do
        if v ~= nil then BPlus.set_path(card.ability, dst, v) end
    end
    -- set_ability keeps these today; re-assert in case smods changes that.
    for k, v in pairs(stickers) do
        if v and not card.ability[k] then card:add_sticker(k, true) end
    end
    card.ability.perish_tally = perish_tally
    if edition and not card.edition then card:set_edition(edition.key or edition, true, true) end
    card:set_cost()

    if not opts.silent then
        card:juice_up(0.8, 0.5)
        card_eval_status_text(card, 'extra', nil, nil, nil,
            { message = localize('k_bplus_upgraded'), colour = G.C.PURPLE })
        play_sound('generic1')
    end
    SMODS.calculate_context({ bplus_upgraded = true, card = card })
    return true
end
