-- Shared helper for the shop/pack upgrade mechanics (M5 Salesman, M6 Craftsmanship/Masterwork,
-- M7 Masterwork Tag, M8 Workshop Pack). Spec: plannig/specs/mechanics/M5_salesman.yaml.
--
--   BPlus.shop_upgrade.rate()        chance that a freshly created shop joker is upgraded right now
--   BPlus.shop_upgrade.roll(rate)    the roll (tests can set BPlus.shop_upgrade.force = true/false)
--   BPlus.shop_upgrade.maybe(card)   upgrade a fresh shop joker with the shop rate; returns true if upgraded
--   BPlus.shop_upgrade.upgrade(card) unconditional fresh upgrade (tag, packs)
--
-- An upgraded shop/pack joker is a FRESH "+" card (no state transfer); the price stays the base price.

local S = {}
BPlus.shop_upgrade = S

-- nil = real RNG. true/false = force the outcome of every roll (tests).
S.force = nil

S.SALESMAN = 'j_bplus_ring_master_plus'

function S.rate()
    local b = BPlus.balance
    local rate = 0
    if G.jokers and next(BPlus.find_behaving(S.SALESMAN)) then rate = rate + b.salesman.upgrade_rate end
    local used = G.GAME and G.GAME.used_vouchers or {}
    if used.v_bplus_masterwork then
        rate = rate + b.masterwork.upgrade_rate
    elseif used.v_bplus_craftsmanship then
        rate = rate + b.craftsmanship.upgrade_rate
    end
    return rate
end

function S.roll(rate)
    if S.force ~= nil then return S.force end
    if rate <= 0 then return false end
    return pseudorandom(pseudoseed('bplus_shop_upgrade' .. (G.GAME.round_resets.ante or 1))) < rate
end

function S.upgrade(card)
    return BPlus.upgrade_card(card, { fresh = true, silent = true })
end

function S.maybe(card)
    if not BPlus.is_eligible(card) or card.bplus_pending_upgrade then return false end
    local rate = S.rate()
    if rate <= 0 or not S.roll(rate) then return false end
    return S.upgrade(card)
end

-- Every joker the shop creates (normal slots, rerolls, tag-created, dev-forced) goes through here.
local create_shop_card_ui_ref = create_shop_card_ui
function create_shop_card_ui(card, type, area)
    if card and card.ability and card.ability.set == 'Joker' then S.maybe(card) end
    return create_shop_card_ui_ref(card, type, area)
end
