-- M8 Workshop Pack. Spec: plannig/specs/mechanics/M8_workshop_pack.yaml
-- A Buffoon-style Joker pack; each joker in it is upgraded (fresh "+" card) with probability
-- 1 in balance.workshop_pack.odds.

SMODS.Atlas({ key = 'mc_boosters', path = 'bplus_boosters.png', px = 71, py = 95 })

BPlus.dict({ k_bplus_workshop_pack = 'Workshop Pack' })

local function create_card(self, card, i)
    local joker = SMODS.create_card({
        set = 'Joker', area = G.pack_cards, skip_materialize = true, soulable = true, key_append = 'bpw',
    })
    if BPlus.is_eligible(joker) then
        local S = BPlus.shop_upgrade
        local hit = S.force
        if hit == nil then
            hit = SMODS.pseudorandom_probability(card, 'bplus_workshop_pack', 1, BPlus.balance.workshop_pack.odds)
        end
        if hit then S.upgrade(joker) end
    end
    return joker
end

local function loc_vars(self, info_queue, card)
    local cfg = (card and card.ability) or self.config
    local size = math.max(1, cfg.extra + (G.GAME.modifiers.booster_size_mod or 0))
    local choose = math.min(cfg.choose + (G.GAME.modifiers.booster_choice_mod or 0), size)
    local num, den = SMODS.get_probability_vars(card or self, 1, BPlus.balance.workshop_pack.odds, 'bplus_workshop_pack')
    return { vars = { choose, size, num, den } }
end

local function pack(key, name, size_key, pos, text_first)
    local b = BPlus.balance.workshop_pack[size_key]
    SMODS.Booster({
        key = key,
        atlas = 'mc_boosters', pos = { x = pos, y = 0 },
        kind = 'bplus_workshop',
        weight = b.weight, cost = b.cost,
        config = { extra = b.extra, choose = b.choose },
        discovered = false,
        loc_txt = {
            name = name,
            text = {
                'Choose {C:attention}#1#{} of up to',
                '{C:attention}#2#{} {C:attention}Joker{} cards, each',
                'with a {C:green}#3# in #4#{} chance',
                'to be {C:attention}upgraded{}',
            },
            group_name = 'Workshop Pack',
        },
        create_card = create_card,
        loc_vars = loc_vars,
        ease_background_colour = function(self) ease_background_colour_blind(G.STATES.BUFFOON_PACK) end,
    })
end

pack('workshop_normal_1', 'Workshop Pack', 'normal', 0)
pack('workshop_normal_2', 'Workshop Pack', 'normal', 1)
pack('workshop_jumbo_1', 'Jumbo Workshop Pack', 'jumbo', 2)
pack('workshop_mega_1', 'Mega Workshop Pack', 'mega', 3)
