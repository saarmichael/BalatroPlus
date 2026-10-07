-- Spec: plannig/specs/jokers/j_selzer.yaml
-- Shrinking joker: state_transfer is the vanilla bare `ability.extra` (hands left) -> extra.hands_left
-- as the ticket says; carpenter_compat is false so Carpenter / The Rust never switch it.
BPlus.Joker({
    key = 'selzer_plus',
    loc_txt = {
        name = 'Fizzy Bubbelech',
        text = {
            'Retrigger all',
            'cards played for',
            'the next {C:attention}#3#{} hands,',
            '{C:green}#1# in #2#{} chance to',
            'retrigger them again',
        },
    },
    config = { extra = { retriggers = 1, odds = 2, hands_left = 10 } },
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_selzer', state_transfer = { ['extra'] = 'extra.hands_left' }, carpenter_compat = false },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_fizzy_bubbelech')
        return { vars = { num, den, card.ability.extra.hands_left } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local bonus = SMODS.pseudorandom_probability(card, 'bplus_fizzy_bubbelech', 1, card.ability.extra.odds)
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers + (bonus and 1 or 0),
                card = card,
            }
        end
        if context.after and not context.blueprint then
            if card.ability.extra.hands_left - 1 <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return { message = localize('k_drank_ex'), colour = G.C.FILTER }
            else
                card.ability.extra.hands_left = card.ability.extra.hands_left - 1
                return { message = card.ability.extra.hands_left .. '', colour = G.C.FILTER }
            end
        end
    end,
})
