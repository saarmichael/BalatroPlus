-- Spec: plannig/specs/mechanics/M3_wheel_of_fortune.yaml
-- The Wheel of Fortune gets a fourth success outcome: upgrade a joker.

local OUTCOMES = { 'upgrade', 'foil', 'holo', 'polychrome' }
local EDITIONS = { foil = { foil = true }, holo = { holo = true }, polychrome = { polychrome = true } }

local function edition_less_jokers()
    local list = {}
    for _, c in ipairs(G.jokers and G.jokers.cards or {}) do
        if c.ability.set == 'Joker' and not c.edition then list[#list + 1] = c end
    end
    return list
end

-- Which outcomes have a valid joker. Returns the pools per outcome (only non-empty ones).
function BPlus.wheel_pools()
    local pools = {}
    local eligible = BPlus.eligible_jokers()
    if #eligible > 0 then pools.upgrade = eligible end
    local plain = edition_less_jokers()
    if #plain > 0 then
        pools.foil, pools.holo, pools.polychrome = plain, plain, plain
    end
    return pools
end

-- Picks an outcome by the balance shares, renormalised over the outcomes in `pools`. `roll` is in [0, 1).
function BPlus.wheel_pick_outcome(pools, roll)
    local shares, total = {}, 0
    for _, name in ipairs(OUTCOMES) do
        if pools[name] then
            shares[name] = BPlus.balance.wheel_of_fortune[name]
            total = total + shares[name]
        end
    end
    if total <= 0 then return nil end
    local target, acc = roll * total, 0
    local last
    for _, name in ipairs(OUTCOMES) do
        if shares[name] then
            acc = acc + shares[name]
            last = name
            if target < acc then return name end
        end
    end
    return last
end

SMODS.Consumable:take_ownership('wheel_of_fortune', {
    loc_txt = {
        name = 'The Wheel of Fortune',
        text = {
            '{C:green}#1# in #2#{} chance to add',
            '{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, or',
            '{C:dark_edition}Polychrome{} edition, or an',
            '{C:attention}Upgrade{}, to a random {C:attention}Joker',
        },
    },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra, 'wheel_of_fortune')
        return { vars = { numerator, denominator } }
    end,
    can_use = function(self, card)
        return next(BPlus.wheel_pools()) ~= nil
    end,
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        local success = SMODS.pseudorandom_probability(card, 'wheel_of_fortune', 1, card.ability.extra)
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.4, func = function()
            if success then
                local pools = BPlus.wheel_pools()
                local outcome = BPlus.wheel_pick_outcome(pools, pseudorandom('bplus_wheel_outcome'))
                if outcome then
                    local joker = pseudorandom_element(pools[outcome], pseudoseed('wheel_of_fortune'))
                    if outcome == 'upgrade' then
                        BPlus.upgrade_card(joker)
                    else
                        joker:set_edition(EDITIONS[outcome], true)
                        check_for_unlock({ type = 'have_edition' })
                    end
                end
                used_tarot:juice_up(0.3, 0.5)
            else
                attention_text({
                    text = localize('k_nope_ex'),
                    scale = 1.3, hold = 1.4, major = used_tarot,
                    backdrop_colour = G.C.SECONDARY_SET.Tarot,
                    align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and 'tm' or 'cm',
                    offset = { x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0 },
                    silent = true,
                })
                G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.06 * G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                    play_sound('tarot2', 0.76, 0.4); return true end }))
                play_sound('tarot2', 1, 0.4)
                used_tarot:juice_up(0.3, 0.5)
            end
            return true
        end }))
        delay(0.6)
    end,
})
