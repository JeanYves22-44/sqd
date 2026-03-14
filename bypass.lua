Susano.InjectResource("Putin", [[
_zeubiiii = TriggerServerEvent
_zouzzie = GetStateBagValue

GetEntityScript = nil
IsEntityGhostedToLocalPlayer = nil

TriggerServerEvent = function(eventName, ...)
    print('TRIGGER EVENT ->', eventName, ...)
    if eventName:find('PutinAC') then
        return
    end
    return _zeubiiii(eventName, ...)
end

GetInvokingResource = function()
    return nil
end

GetStateBagValue = function(bag, key)
    if key == 'doCheckPlayerPed' then
        return false
    end
    return _zouzzie(bag, key)
end

Citizen.CreateThread(function()
    local decorName = "PutinBypassTime"
    while true do
        local currentTime = GetGameTimer()
        LocalPlayer.state:set('PutinBypassHeartbeat', currentTime, true)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            DecorSetInt(ped, decorName, currentTime)
        end
        _G.PutinBypassActive__ = true
        Wait(500)
    end
end)

-- Anti-Freeze (Safe Version - Only blocks FreezeEntityPosition on player ped)
local _origFreeze = FreezeEntityPosition
FreezeEntityPosition = function(entity, toggle)
    if toggle == true then
        local ped = PlayerPedId()
        if entity == ped or entity == GetVehiclePedIsIn(ped, false) then
            return -- Block admin freeze on our ped/vehicle
        end
    end
    if _origFreeze then
        return _origFreeze(entity, toggle)
    end
end

-- Block admin freeze events
AddEventHandler("admin:FreezePlayer", function(freezeState)
    if freezeState == true then
        CancelEvent()
    end
end)

_G.AntiFreezeEnabled = true
]])

print("^2✓ Anti-Freeze activé^0")
