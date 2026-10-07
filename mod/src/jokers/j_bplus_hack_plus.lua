-- Spec: plannig/specs/jokers/j_hack.yaml
BPlus.Joker({
    key = 'hack_plus',
    loc_txt = {
        name = 'Jerry Seinfeld',
        text = {
            'Retrigger each played',
            '{C:attention}2{}, {C:attention}3{}, {C:attention}4{}, or {C:attention}5{},',
            '{C:green}#1# in #2#{} chance to',
            'retrigger it again',
        },
    },
    config = { extra = { retriggers = 1, odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_hack', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(2,3,4,5)' },
            },
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                if held_in_hand then return 0 end
                return JokerDisplay.in_scoring(playing_card, scoring_hand)
                    and (playing_card:get_id() == 2 or playing_card:get_id() == 3
                        or playing_card:get_id() == 4 or playing_card:get_id() == 5)
                    and joker_card.ability.extra.retriggers * JokerDisplay.calculate_joker_triggers(joker_card) or 0
            end,
        }
    end,

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_jerry_seinfeld')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 2 or id == 3 or id == 4 or id == 5 then
                local bonus = SMODS.pseudorandom_probability(card, 'bplus_jerry_seinfeld', 1, card.ability.extra.odds)
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.retriggers + (bonus and 1 or 0),
                    card = card,
                }
            end
        end
    end,
})
