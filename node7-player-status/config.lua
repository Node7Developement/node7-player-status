Config = Config or {}

Config.CoreResource = 'node7-core'
Config.RadioResource = 'node7-radio' -- Optional; detected at runtime and not a dependency.

-- NODE7 recipe/player lifecycle behavior.
Config.HideDuringPauseMenu = true
Config.DisableCoreMoneyHUD = true -- The current NODE7 recipe already disables it; this keeps hot-loaded variants clean.
Config.RefreshMilliseconds = 1000
Config.PlayerCountFallbackMilliseconds = 30000

Config.LeftStatus = {
    enabled = true,
    showJob = true,
    showDuty = true,
    showGameTime = true,
    showRadio = true,
    showOnlinePlayers = true,

    -- name_grade: VALLAW_1
    -- label_grade: VALENTINE LAW ENFORCEMENT_1
    -- grade_name: DEPUTY
    -- label: VALENTINE LAW ENFORCEMENT
    jobDisplay = 'name_grade',
}

Config.Economy = {
    enabled = true,
    showBank = true,
    showGold = true,
    showCash = true,
}

-- Pixel placement is authored against the supplied 1920x1080 reference image.
Config.Layout = {
    referenceWidth = 1920,
    referenceHeight = 1080,
    leftX = 22,
    leftY = 54,
    leftRowGap = 34,
    economyTop = 30,
    economyRight = 250,
    economyGap = 52,
    scale = 1.0,
}
