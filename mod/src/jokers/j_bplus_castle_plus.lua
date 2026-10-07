-- Spec: plannig/specs/jokers/j_castle.yaml
BPlus.Joker({
    key = 'castle_plus',
    loc_txt = {
        name = 'Citadel',
        text = {
            'This Joker gains {C:chips}+#1#{} Chips',
            'per discarded {V:1}#2#{} card,',
            'suit changes every round',
            '{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips = 0, chip_mod = 6 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_castle', state_transfer = { ['extra.chips'] = 'extra.chips' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local cr = G.GAME and G.GAME.current_round and G.GAME.current_round.castle_card
        local suit = cr and cr.suit or 'Spades'
        return { vars = { card.ability.extra.chip_mod, localize(suit, 'suits_singular'), card.ability.extra.chips,
            colours = { G.C.SUITS[suit] } } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint and not context.other_card.debuff
            and context.other_card:is_suit(G.GAME.current_round.castle_card.suit) then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'chips', scalar_value = 'chip_mod' })
            return nil, true
        end
        if context.joker_main and card.ability.extra.chips > 0 then
            return { chips = card.ability.extra.chips }
        end
    end,
})
