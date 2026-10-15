# DifficultyChanger

Remnant: From the Ashes [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) Lua mod: change the difficulty of your current
campaign or adventure from the console, without rerolling it.

## Important note

Back up your saves before using the mod, so you can restore them if anything goes wrong. With the game closed, copy
the whole `SaveGames` folder somewhere safe; to restore, close the game and copy it back.

- Windows: `%LOCALAPPDATA%\Remnant\Saved\SaveGames`
- Linux (Steam/Proton): `~/.local/share/Steam/steamapps/compatdata/617290/pfx/drive_c/users/steamuser/AppData/Local/Remnant/Saved/SaveGames`

## Command Usage
```
difficulty <1-4>
```

| Value | Game mode |
|---------|--------|
| `<empty>` | Show the current difficulty |
| `1` | Normal |
| `2` | Hard |
| `3` | Nightmare |
| `4` | Apocalypse |

To open the console press `~` or F10 (UE4SS console enabler, on by default).

## Install

1. Install UE4SS (tested only with [v3.0.1 1176 (Experimental build)](https://github.com/UE4SS-RE/RE-UE4SS/releases/download/experimental/UE4SS_v3.0.1-1176-g1ba38db4.zip); for me the stable 3.0.1 release frequently crashes the game on startup, so I'd stick with the experimental build).
2. Extract `DifficultyChanger.zip` into the game folder (Steam > Remnant: From the Ashes > Manage > Browse local files).
   Result: `Remnant\Binaries\Win64\ue4ss\Mods\DifficultyChanger\`.

## Uninstall

Delete the `Remnant\Binaries\Win64\ue4ss\Mods\DifficultyChanger` folder. A changed difficulty stays in the save.

## Notes

- Applies immediately and is saved with the campaign at the next save (e.g. travel or quit to menu).
- Enemies already spawned may keep their old stats until they respawn. I did not test this.
- Only the difficulty multipliers change (enemy health/damage, spawn count, scrap/XP). Zone and enemy levels,
  items and progress are not touched. See [RESEARCH.md](RESEARCH.md) for details.
- Claude code was used in the making of this mod.

## Build

`./build.sh` -> `build/DifficultyChanger.zip`. Needs `python3`.

## How it works

The difficulty is `RemnantQuest.Difficulty` on the active root quest (saved). The command sets it and applies it to the
quest's `DifficultyScalingComponent`, the same way the game does when a campaign loads.
