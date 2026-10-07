-- Spec: plannig/specs/jokers/j_perkeo.yaml
BPlus.Joker({
    key = 'perkeo_plus',
    loc_txt = {
        name = 'Perkeo+',
        text = {
            'Creates a {C:dark_edition}Negative{} copy of',
            '{C:attention}1{} random {C:attention}consumable{}',
            'card in your possession',
            'at the end of the {C:attention}shop',
            '{C:green}#1# in #2#{} chance to create one more',
        },
    },
    config = { extra = { odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_perkeo', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_perkeo')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.ending_shop then
            local held = {}
            for _, c in ipairs(G.consumeables.cards) do held[#held + 1] = c end
            if #held == 0 then return end
            local picks = { (pseudorandom_element(held, pseudoseed('bplus_perkeo'))) }
            if SMODS.pseudorandom_probability(card, 'bplus_perkeo', 1, card.ability.extra.odds) then
                picks[2] = (pseudorandom_element(held, pseudoseed('bplus_perkeo')))
            end
            for _, pick in ipairs(picks) do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local copy = copy_card(pick, nil)
                        copy:set_edition({ negative = true }, true)
                        copy:add_to_deck()
                        G.consumeables:emplace(copy)
                        return true
                    end,
                }))
            end
            return { message = localize('k_duplicated_ex') }
        end
    end,
})
