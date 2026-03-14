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
]])
