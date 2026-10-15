# Difficulty and save file research

Found by reading the game exe (Steamless-unpacked, build 275957), blueprints (UAssetAPI + `scripts/kis.py`) and saves.
Not everything is tested in game; inferred parts are marked.

## Where the difficulty lives

| Value | Class / file | Saved | Notes |
|-------|--------------|-------|-------|
| `RemnantQuest.Difficulty` (int, +0x484) | root quest in `save_N.sav` | yes | The real setting, one per campaign/adventure. Not written while it equals the default (Normal). |
| `DifficultyScalingComponent.Difficulty` (int, +0x138) | GunfireRuntime component | no | Live value. `SetDifficulty` stores it and broadcasts `OnDifficultyChanged` (+0xf8). |
| `BP_RemnantSaveGame.Difficulty` (Text) | top of `save_N.sav` | yes | Menu label only, rewritten from the component on every save. |
| `SavedCharacter.InitialDifficulty`, `QuestDifficulty` | `profile.sav` | yes | Character-select display (inferred). |

Values: 1 Normal, 2 Hard, 3 Nightmare, 4 Apocalypse; 0 (unset) also shows as Normal. The scaling table has rows 1-4 only.

Applying: when the root quest becomes active (`Status == 2`), C++ (`0x1405ea180`) and `Remnant_PlayerController`
call `GetDifficultyScalingComponent(quest).SetDifficulty(quest.Difficulty)`.

Built-in cheat: `URemnantCheatManager::SetDifficulty(int)` (Exec, vtable +0x510, impl `0x1405f0e20`, message
"Difficulty Set: %i") only sets the component, so it reverts when the quest is reactivated (load). Usable with UE4SS
`CheatManagerEnablerMod` + console as `SetDifficulty <n>`.

## What difficulty changes

`/Game/_Core/Stats/Stats_Scaling_Difficulty` (rows 1-4):

| Stat | Normal | Hard | Nightmare | Apocalypse |
|------|--------|------|-----------|------------|
| EnemyHealthScalar | 1 | 1.5 | 2.5 | 2.75 |
| EnemyDamageScalar | 1 | 1.65 | 3.5 | 4.5 |
| SpawnQuantityScalar | 1 | 1.05 | 1.1 | 1.15 |
| CurrencyScalar | 1 | 1.15 | 1.3 | 1.5 |
| ExperienceScalar | 1 | 1.15 | 1.3 | 1.5 |
| FriendlyFireDamageScalar | 1 | 2 | 3 | 4 |
| EliteDamageScalar | 1 | 1 | 1.05 | 1.1 |
| BruteHealthScalar / BruteDamageScalar | 1 / 1 | 1 / 1 | 1 / 1.05 | 1.05 / 1.1 |
| BossHealthScalar | 1 | 1.1 | 1.25 | 1.5 |
| BossDamageScalar | 1 | 1 | 0.75 | 0.9 |

SpawnWeightScalar and EliteHealthScalar are 1 everywhere. Survival mode uses `Stats_Scaling_Difficulty_Survival`.

Blueprints that check the difficulty (boss/enemy mechanics): Harsgaard + orbs (beam patterns, > 1), Ratmen Mage
champion ice orb (> 1), Flickering Horror champion (== 1), Root Throne (3, 4), Liz and Liz siege (3, 4), Dreamer
(`GetDifficultMode(3)`), `Action_Debuff_NightmareRealm` (== 3). UI: `Widget_HUD` icon, `Widget_ServerEntry` (server list),
`BP_RemnantSaveGame` label, `Widget_CharacterDetails`.

Not affected: vendors (`Character_Merchant_Base` / `Character_Crafter_Base` use the component only for the player
count), the 52 achievements in `AchievementList`, zone/enemy levels, items, progress.

## Zone levels (independent of difficulty)

Zone actor fields: `Level` (+0x374, saved), `LevelMin` (+0x378), `LevelMax` (+0x37c), `ZoneLevel` (+0x380, saved),
`ZoneLevelInitialized` (+0x458, saved). Update function `0x140609320`, host only:

1. If not initialized: `ZoneLevel = clamp(hostGearLevel + 1, LevelMin, LevelMax)`, set initialized. Never recomputed.
2. Always: `Level = ZoneLevel`, or `ZoneLevel + 3` if a remote player's clamped gear level exceeds `ZoneLevel + 3`.
   Pushed to the spawn managers.

Gear level (`0x1405d2db0`, stored at controller +0x88c): two inventory item categories `a`, `b` (helper
`0x1405d2450`, top 5), `round((2*max + min) / 3) + 1` (inferred: item upgrade levels).

## Save file format

Uncompressed, little-endian. `profile.sav` (account, characters) and `save_N.sav` (campaign of slot N).

```
u32 CRC32 of bytes [4:]
u32 file size
u32 5                save format version
u32 build            275957
u32 517              UE 4.22 package version
FString class        /Game/_Core/Blueprints/Base/BP_RemnantSaveGame.BP_RemnantSaveGame_C
u64 name table offset
u32 1
u64 object table offset
records              per object: u32 index, u32 size, tagged properties .. None, u8 hasComponents
                     [u32 count, per component: FString name, u32 size, tagged properties]
object table         u32 count, per object: u8 kind, FString path (+10 bytes when kind == 0)
name table           u32 count, FStrings
```

Tagged properties are standard UE4 (`name, type, size, arrayIndex, [type extras], hasGuid, value`), except names and
types are u16 indexes into the name table and object references are i32 indexes into the object table.

`save_N.sav` top object: `TimePlayed`, `QuestLabel`, `Difficulty` (Text), `LocationImage`, `ZoneIDGen`, `QuestIDGen`,
`QuestFailCount`, `Containers` (array of `PersistenceContainer`). Each container: `Key` (level path) and `Blob`
(`PersistenceBlob`): `u32 size, u32 2, u32 517, u32 length, u64 actor data offset, u64 names, u32 1, u64 objects`
(offsets relative to blob + 20), then the same record layout, with further sub-archives back to back (651 name tables
in a 0.5 MB campaign save).

Editing the difficulty in the save means inserting `Difficulty` into the root quest's sub-archive (name table,
offsets, sizes of every enclosing level, CRC). The Lua mod avoids that.

Helpers: `../scripts/save_tree.py <save> [regex]` (recursive property dump, first archive level),
`../scripts/save_names.py <save> [names]` (all name tables, values of int/bool fields).
