# DifficultyChanger

Remnant: From the Ashes [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) Lua mod: change the difficulty of your current
campaign or adventure from the console, without rerolling it.

| Command | Effect |
|---------|--------|
| `difficulty` | Show the current difficulty |
| `difficulty 1` | Normal |
| `difficulty 2` | Hard |
| `difficulty 3` | Nightmare |
| `difficulty 4` | Apocalypse |

Open the console with `~` or F10 (UE4SS console enabler, on by default).

## Install

1. Install UE4SS (tested only with the v3.0.1 experimental build; the stable 3.0.1 release frequently crashes the game
   on startup). Extract it into `Remnant\Binaries\Win64` (the folder with `Remnant-Win64-Shipping.exe`).
2. Extract `DifficultyChanger.zip` into the game folder (Steam > Remnant: From the Ashes > Manage > Browse local files).
   Result: `Remnant\Binaries\Win64\ue4ss\Mods\DifficultyChanger\`.

## Uninstall

Delete the `Remnant\Binaries\Win64\ue4ss\Mods\DifficultyChanger` folder. A changed difficulty stays in the save.

## Notes

- Host only. In co-op the host runs the command; other players don't need the mod.
- Applies immediately and is saved with the campaign at the next save (e.g. travel or quit to menu).
- Enemies already spawned may keep their old stats until they respawn.
- Only the difficulty multipliers change (enemy health/damage, spawn count, scrap/XP). Zone and enemy levels,
  items and progress are not touched. See [RESEARCH.md](RESEARCH.md) for details.

## Build

`./build.sh` -> `build/DifficultyChanger.zip`. Needs `python3`.

## How it works

The difficulty is `RemnantQuest.Difficulty` on the active root quest (saved). The command sets it and applies it to the
quest's `DifficultyScalingComponent`, the same way the game does when a campaign loads.
