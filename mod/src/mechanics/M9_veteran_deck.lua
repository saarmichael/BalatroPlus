-- Spec: plannig/specs/mechanics/M9_veteran_deck.yaml
SMODS.Back({
    key = 'veteran',
    loc_txt = {
        name = 'Veteran Deck',
        text = {
            'Jokers are {C:attention}Upgraded{}',
            'after being held for',
            '{C:attention}#1#{} rounds',
        },
    },
    atlas = 'placeholder',
    pos = { x = 0, y = 0 },
    loc_vars = function(self, info_queue, back)
        return { vars = { BPlus.balance.veteran_deck.rounds } }
    end,

    calculate = function(self, back, context)
        if not (context.end_of_round and context.game_over == false and context.main_eval) then return end
        for _, joker in ipairs({ unpack(G.jokers.cards) }) do
            joker.ability.bplus_veteran_rounds = (joker.ability.bplus_veteran_rounds or 0) + 1
            if joker.ability.bplus_veteran_rounds >= BPlus.balance.veteran_deck.rounds then
                BPlus.upgrade_card(joker)
            end
        end
    end,
})
