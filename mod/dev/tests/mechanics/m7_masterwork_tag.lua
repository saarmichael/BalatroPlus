-- M7 Masterwork Tag. Spec: plannig/specs/mechanics/M7_masterwork_tag.yaml
local T = BPlus.test

local function give_tag()
    add_tag(Tag('tag_bplus_masterwork'))
    T.wait_idle()
end

-- Same loop the game runs for every freshly created shop card (create_card_for_shop).
local function offer_to_tags(card)
    for _, tag in ipairs(G.GAME.tags) do
        if tag:apply_to_run({ type = 'store_joker_modify', card = card }) then break end
    end
    T.wait_idle()
end

-- Real shop flow: the shop rolls Jokers only, and every Joker is a Ride the Bus.
local create_card_ref
local function force_shop_jokers()
    G.GAME.joker_rate, G.GAME.tarot_rate, G.GAME.planet_rate = 1e6, 0, 0
    G.GAME.playing_card_rate, G.GAME.spectral_rate = 0, 0
    create_card_ref = SMODS.create_card
    SMODS.create_card = function(args)
        if args.set == 'Joker' and args.key_append == 'sho' then args.key = 'j_ride_the_bus' end
        return create_card_ref(args)
    end
end
local function restore()
    if create_card_ref then SMODS.create_card = create_card_ref end
    create_card_ref = nil
end

T.test('Masterwork Tag: the next eligible shop joker appears upgraded, the tag is used up', function()
    BPlus.shop_upgrade.force = nil
    T.start_run({ ante = 3 })
    give_tag()
    T.eq(#G.GAME.tags, 1)
    force_shop_jokers()
    local ok, err = pcall(T.to_shop)
    restore()
    if not ok then error(err, 0) end
    T.eq(G.shop_jokers.cards[1].config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(G.shop_jokers.cards[1].base_cost, G.P_CENTERS.j_ride_the_bus.cost, 'base price (an edition may add its own surcharge)')
    T.eq(G.shop_jokers.cards[2].config.center.key, 'j_ride_the_bus', 'only one joker per tag')
    T.eq(#G.GAME.tags, 0, 'tag consumed')
end)

T.test('Masterwork Tag: skips ineligible jokers ("+" already) and upgrades the next one', function()
    BPlus.shop_upgrade.force = nil
    T.start_run({ shop_queue = { 'bplus_joker_plus', 'ride_the_bus' }, ante = 3 })
    T.to_shop()
    give_tag()
    offer_to_tags(G.shop_jokers.cards[1])
    T.eq(G.shop_jokers.cards[1].config.center.key, 'j_bplus_joker_plus')
    T.eq(#G.GAME.tags, 1, 'tag waits')
    offer_to_tags(G.shop_jokers.cards[2])
    T.eq(G.shop_jokers.cards[2].config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(#G.GAME.tags, 0, 'tag consumed')
end)
