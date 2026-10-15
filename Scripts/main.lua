-- DifficultyChanger: console command to change the difficulty of the active campaign or adventure.
--   difficulty        show the current difficulty
--   difficulty <1-4>  set it: 1 Normal, 2 Hard, 3 Nightmare, 4 Apocalypse
-- Host only. The value is stored on the root quest and saved with the campaign.

local NAMES = { "Normal", "Hard", "Nightmare", "Apocalypse" }

RegisterConsoleCommandHandler("difficulty", function(_, Parameters, Ar)
    local manager = FindFirstOf("RemnantQuestManager")
    local quest = manager:IsValid() and manager:GetActiveRootQuest()
    if not (quest and quest:IsValid()) then
        Ar:Log("No active campaign or adventure.")
        return true
    end

    local level = tonumber(Parameters[1])
    if NAMES[level] then
        quest.Difficulty = level
        -- Apply it now, the same way the game applies the saved difficulty on load.
        StaticFindObject("/Script/GunfireRuntime.Default__DifficultyScalingComponent")
            :GetDifficultyScalingComponent(quest):SetDifficulty(level)
    end

    -- 0 (never set) also means Normal.
    Ar:Log(string.format("Difficulty: %s. Usage: difficulty <1-4> (Normal, Hard, Nightmare, Apocalypse)",
        NAMES[quest.Difficulty] or NAMES[1]))
    return true
end)
