-- In-game test framework (BPlus.test, usually aliased `local T = BPlus.test` in test files).
-- See docs/testing.md for the full guide.
--
--   assert.lua   T.eq / T.near / T.truthy / T.contains / T.fail ...
--   actions.lua  safe actions: T.start_run, T.select_blind, T.set_hand, T.play, T.discard, T.buy ...
--   runner.lua   discovery + coroutine runner + result streaming (./dev.sh test)

BPlus.test = {}

for _, file in ipairs({ 'assert', 'actions', 'runner' }) do
    BPlus.load('src/dev/test/' .. file .. '.lua')
end
