-- Spec: plannig/specs/jokers/j_riff_raff.yaml

-- Common vanilla jokers that have a "+" version and could be rolled right now (unlocked, no duplicates
-- unless Showman/Salesman allows them). Returns a list of plus keys.
local function plus_commons()
    local list = {}
    for vkey, pkey in pairs(BPlus.upgrade_map) do
        local v, p = G.P_CENTERS[vkey], G.P_CENTERS[pkey]
        if v and p and v.rarity == 1 and v.unlocked ~= false
            and (SMODS.showman(vkey) or (not next(SMODS.find_card(vkey)) and not next(SMODS.find_card(pkey)))) then
            list[#list + 1] = pkey
        end
    end
    table.sort(list)
    return list
end

BPlus.Joker({
    key = 'riff_raff_plus',
    loc_txt = {
        name = 'Nobleman',
        text = {
            'When {C:attention}Blind{} is selected,',
            'create {C:attention}#1#{} upgraded {C:blue}Common{} Jokers',
            '{C:inactive}(Must have room)',
        },
    },
    config = { extra = { jokers = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_riff_raff', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.jokers } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced
            and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local n = math.min(card.ability.extra.jokers,
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + n
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, n do
                        local pool = plus_commons()
                        local c
                        if #pool > 0 then
                            -- a fresh "+" card (equivalent to creating the vanilla joker and upgrading it)
                            local key = pseudorandom_element(pool, pseudoseed('bplus_nobleman'))
                            c = create_card('Joker', G.jokers, nil, nil, nil, nil, key, 'bplus_nobleman')
                        else
                            c = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'bplus_nobleman')
                        end
                        c:add_to_deck()
                        G.jokers:emplace(c)
                        c:start_materialize()
                        G.GAME.joker_buffer = math.max(0, G.GAME.joker_buffer - 1)
                    end
                    return true
                end,
            }))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                { message = localize('k_plus_joker'), colour = G.C.BLUE })
            return nil, true
        end
    end,
})
