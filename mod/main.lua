-- Balatro Plus: entry point loaded by Steamodded.
-- Keep this file a thin loader; features live in src/.

BPlus = SMODS.current_mod

function BPlus.load(path)
    local chunk, err = SMODS.load_file(path, BPlus.id)
    if not chunk then error(('[BalatroPlus] failed to load %s: %s'):format(path, err)) end
    return chunk()
end

BPlus.load('src/core.lua')
BPlus.balance = BPlus.load('src/balance.lua')
BPlus.load('src/upgrade.lua')
BPlus.load('src/behavior.lua')

SMODS.Atlas({ key = 'placeholder', path = 'placeholder.png', px = 71, py = 95 })

-- One file per "+" joker (each registers itself through BPlus.Joker), then the upgrade mechanics.
BPlus.load_dir('src/jokers')
BPlus.load_dir('src/mechanics')

if BPlus.config.dev_mode then
    BPlus.load('src/dev/init.lua')
end

sendInfoMessage('Loaded v' .. BPlus.version .. (BPlus.config.dev_mode and ' (dev mode)' or ''), 'BalatroPlus')
