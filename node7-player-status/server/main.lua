local lastCount = -1

local function playerCount()
    return #GetPlayers()
end

local function sendCount(target, force)
    local count = playerCount()
    if target == -1 and not force and count == lastCount then return end

    lastCount = count
    TriggerClientEvent('node7-player-status:client:setCount', target or -1, count)
end

RegisterNetEvent('node7-player-status:server:requestCount', function()
    sendCount(source, true)
end)

AddEventHandler('playerJoining', function()
    SetTimeout(500, function()
        sendCount(-1, true)
    end)
end)

AddEventHandler('playerDropped', function()
    SetTimeout(250, function()
        sendCount(-1, true)
    end)
end)

CreateThread(function()
    while true do
        Wait(30000)
        sendCount(-1, false)
    end
end)
