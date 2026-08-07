local RESOURCE = GetCurrentResourceName()
local Core
local playerLoaded = false
local pauseMenuOpen = false
local onlinePlayers = 0
local lastPayload
local radioFrequency = 0.0
local radioPowered = false

local function getCore()
    if Core then return Core end
    if GetResourceState(Config.CoreResource) ~= 'started' then return nil end

    local ok, object = pcall(function()
        return exports[Config.CoreResource]:GetCoreObject()
    end)

    if ok and type(object) == 'table' then
        Core = object
    end

    return Core
end

local function applyCoreHudPreference()
    if Config.DisableCoreMoneyHUD ~= true then return end

    local core = getCore()
    if not core or not core.Config then return end

    core.Config.StatusHUD = core.Config.StatusHUD or {}
    core.Config.StatusHUD.Enabled = false
    core.Config.StatusHUD.DefaultVisible = false
end

local function getPlayerData()
    local core = getCore()
    if not core then return {} end

    if core.Functions and core.Functions.GetPlayerData then
        local ok, data = pcall(core.Functions.GetPlayerData)
        if ok and type(data) == 'table' then return data end
    end

    return type(core.PlayerData) == 'table' and core.PlayerData or {}
end

local function isActuallyLoaded()
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn == true then
        return true
    end

    return playerLoaded == true
end

local function readPauseState()
    if Config.HideDuringPauseMenu == false then return false end

    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.node7PauseMenuOpen == true then
        return true
    end

    if type(IsPauseMenuActive) == 'function' then
        local ok, active = pcall(IsPauseMenuActive)
        if ok and active == true then return true end
    end

    if type(GetPauseMenuState) == 'function' then
        local ok, state = pcall(GetPauseMenuState)
        if ok and tonumber(state) and tonumber(state) > 0 then return true end
    end

    return pauseMenuOpen == true
end

local function formatGameTime()
    local hour = tonumber(GetClockHours()) or 0
    local minute = tonumber(GetClockMinutes()) or 0
    local suffix = hour >= 12 and 'PM' or 'AM'
    local displayHour = hour % 12
    if displayHour == 0 then displayHour = 12 end
    return ('%02d:%02d %s'):format(displayHour, minute, suffix)
end

local function formatJob(job)
    job = type(job) == 'table' and job or {}
    local grade = type(job.grade) == 'table' and job.grade or {}
    local name = tostring(job.name or 'unemployed')
    local label = tostring(job.label or name)
    local gradeLevel = tonumber(grade.level) or 0
    local gradeName = tostring(grade.name or gradeLevel)
    local mode = Config.LeftStatus.jobDisplay

    if mode == 'label_grade' then
        return ('%s_%d'):format(label, gradeLevel):upper()
    elseif mode == 'grade_name' then
        return gradeName:upper()
    elseif mode == 'label' then
        return label:upper()
    end

    return ('%s_%d'):format(name, gradeLevel):upper()
end

local function refreshRadioStatus()
    radioPowered = false
    radioFrequency = 0.0

    if Config.LeftStatus.showRadio ~= true then return end
    if GetResourceState(Config.RadioResource) ~= 'started' then return end

    local okPower, power = pcall(function()
        return exports[Config.RadioResource]:IsPowered()
    end)
    if okPower then radioPowered = power == true end

    local okFrequency, frequency = pcall(function()
        return exports[Config.RadioResource]:GetFrequency()
    end)
    if okFrequency then radioFrequency = tonumber(frequency) or 0.0 end
end

local function radioText()
    if not radioPowered then return 'OFF' end
    if radioFrequency > 0 then return ('%.2f MHZ'):format(radioFrequency) end
    return 'ON'
end

local function sendStatus(force)
    local visible = isActuallyLoaded() and not readPauseState()

    if not visible then
        local payload = { action = 'visibility', visible = false }
        local encoded = json.encode(payload)
        if force or encoded ~= lastPayload then
            lastPayload = encoded
            SendNUIMessage(payload)
        end
        return
    end

    local data = getPlayerData()
    local job = type(data.job) == 'table' and data.job or {}
    local money = type(data.money) == 'table' and data.money or {}

    local payload = {
        action = 'update',
        visible = true,
        layout = Config.Layout,
        sections = {
            left = Config.LeftStatus,
            economy = Config.Economy,
        },
        status = {
            job = formatJob(job),
            duty = job.onduty == true and 'ON DUTY' or 'OFF DUTY',
            dutyActive = job.onduty == true,
            time = formatGameTime(),
            radio = radioText(),
            radioActive = radioPowered and radioFrequency > 0,
            online = onlinePlayers,
        },
        economy = {
            bank = tonumber(money.bank) or 0,
            gold = tonumber(money.gold) or 0,
            cash = tonumber(money.cash) or 0,
        }
    }

    local encoded = json.encode(payload)
    if force or encoded ~= lastPayload then
        lastPayload = encoded
        SendNUIMessage(payload)
    end
end

RegisterNetEvent('Node7Core:Client:OnPlayerLoaded', function()
    playerLoaded = true
    applyCoreHudPreference()
    Wait(250)
    TriggerServerEvent('node7-player-status:server:requestCount')
    refreshRadioStatus()
    sendStatus(true)
end)

RegisterNetEvent('Node7Core:Client:OnPlayerUnload', function()
    playerLoaded = false
    lastPayload = nil
    sendStatus(true)
end)

RegisterNetEvent('Node7Core:Player:SetPlayerData', function(data)
    local core = getCore()
    if core then core.PlayerData = type(data) == 'table' and data or {} end
    sendStatus(true)
end)

RegisterNetEvent('Node7Core:Client:OnMoneyChange', function()
    Wait(50)
    sendStatus(true)
end)

RegisterNetEvent('Node7Core:Client:OnJobUpdate', function(job)
    local core = getCore()
    if core then
        core.PlayerData = core.PlayerData or {}
        core.PlayerData.job = type(job) == 'table' and job or core.PlayerData.job
    end
    sendStatus(true)
end)

RegisterNetEvent('Node7Core:Client:SetDuty', function(onDuty)
    local core = getCore()
    if core and core.PlayerData and core.PlayerData.job then
        core.PlayerData.job.onduty = onDuty == true
    end
    sendStatus(true)
end)

RegisterNetEvent('Node7Core:Client:OnPlayerUpdated', function()
    sendStatus(true)
end)

RegisterNetEvent('node7-player-status:client:setCount', function(count)
    onlinePlayers = math.max(0, tonumber(count) or 0)
    sendStatus(true)
end)

-- Optional node7-radio integration. These events and exports do not create a dependency.
RegisterNetEvent('node7-radio:client:joined', function(frequency)
    radioPowered = true
    radioFrequency = tonumber(frequency) or 0.0
    sendStatus(true)
end)

RegisterNetEvent('node7-radio:client:left', function()
    radioFrequency = 0.0
    refreshRadioStatus()
    sendStatus(true)
end)

RegisterNetEvent('node7-radio:client:powerChanged', function(powered)
    radioPowered = powered == true
    if not radioPowered then radioFrequency = 0.0 end
    sendStatus(true)
end)

AddEventHandler('Node7Core:Client:PauseMenuStateChanged', function(isOpen)
    pauseMenuOpen = isOpen == true
    sendStatus(true)
end)

AddEventHandler('node7-core:client:PauseMenuStateChanged', function(isOpen)
    pauseMenuOpen = isOpen == true
    sendStatus(true)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == Config.CoreResource then
        Core = nil
        Wait(250)
        applyCoreHudPreference()
        sendStatus(true)
    elseif resourceName == Config.RadioResource then
        Wait(250)
        refreshRadioStatus()
        sendStatus(true)
    elseif resourceName == RESOURCE then
        CreateThread(function()
            Wait(250)
            applyCoreHudPreference()
            playerLoaded = LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn == true or false
            TriggerServerEvent('node7-player-status:server:requestCount')
            refreshRadioStatus()
            sendStatus(true)
        end)
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == Config.RadioResource then
        radioPowered = false
        radioFrequency = 0.0
        sendStatus(true)
    elseif resourceName == RESOURCE then
        SendNUIMessage({ action = 'visibility', visible = false })
    end
end)

CreateThread(function()
    while true do
        if isActuallyLoaded() then
            refreshRadioStatus()
            sendStatus(false)
            Wait(math.max(250, tonumber(Config.RefreshMilliseconds) or 1000))
        else
            sendStatus(false)
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(math.max(5000, tonumber(Config.PlayerCountFallbackMilliseconds) or 30000))
        if isActuallyLoaded() then
            TriggerServerEvent('node7-player-status:server:requestCount')
        end
    end
end)
