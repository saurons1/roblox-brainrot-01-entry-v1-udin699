# Brainrot Bay — make.fun roblox-brainrot-01

[![roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/saurons1/roblox-brainrot-01-entry-v1-udin699/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/saurons1/roblox-brainrot-01-entry-v1-udin699/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

**Brainrot Bay** is a 3D Roblox brainrot game: absurd meme characters wash
ashore on a beach dock, you catch them, keep them on your beach base, and
they earn money every second — while a tsunami sweeps the island every two
minutes and rivals try to steal your best brainrots.

## The game

- **Catch the cast**: 12 original brainrots — Soggy Cereal Sam, DJ Pickle,
  Grandma's WiFi Ghost, Turbo Toilet Titan, Emperor Eggplant, the Secret
  Forbidden Fridge and more — across 7 rarities, with Golden, Diamond,
  Rainbow and Void mutations.
- **Grow your base**: 8 plots per beach base. Brainrots stand on plots and
  earn their $/s, ticking live on the HUD.
- **Steal and defend**: grab a rival's brainrot off their base and carry it
  home — slowed, marked, and slappable. Lock your base for 45 seconds
  when the thieves circle.
- **Outrun the wave**: every 120 seconds a tsunami warning sounds. Dash to
  your base or be washed back to spawn, dropping what you carry.
- **Progress**: rebirths at the totem (permanent x2, up to x10), upgrades
  for walk speed, catch range, plots and money, and timed island events —
  Brainrot Rain, Double Money, Golden Hour.

## Controls

| Key | Action |
|-----|--------|
| E | Catch a brainrot / place the one you carry |
| F | Slap a thief carrying your brainrot |
| Q | Lock your base (45s) |
| R | Rebirth at the totem |
| U | Open upgrades |

## Layout

- `main.ts` — the entrypoint: copies the game to `/output` and writes
  `dossier.json` with the kit's library.
- `src/server/` — one module per job: `World` builds the island,
  `Spawner` runs the conveyor, `Economy` ticks the money, `Bases` holds
  the plots and locks, `Steal` runs the carrying, `Tsunami` runs the
  wave, `Events` runs the timed events, `State` holds all player data.
- `src/client/` — `Game.client` boots the client, `Hud` builds the
  ScreenGui, `Input` binds the keys.
- `src/shared/` — `Config` (cast, rarities, prices, timings) and
  `Format` (money and clock text).
- `game.rbxl` — the place, built by Rojo from `src/`:
  `rojo build default.project.json --output game.rbxl`
- `screenshots/` — 3–4 captures of the game; the first by name is the
  thumbnail, the same picture as the game's first thumbnail on Roblox.
- `PLAY.json` — the published place's play link, place id and universe id.
