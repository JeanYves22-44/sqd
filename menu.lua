if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
    return
end

local targetResource = "Putin"

if not targetResource or GetResourceState(targetResource) ~= "started" then
    return
end

-- Première injection
Susano.InjectResource(targetResource, [[
    local p = print
    local w = warn
    local e = error
    p = function() end
    w = function() end
    e = function() end
    
    if Citizen then
        local t = Citizen.Trace
        Citizen.Trace = function(m)
            if m and type(m) == "string" then
                local l = string.lower(m)
                if string.find(l, "debug") or string.find(l, "detect") or 
                   string.find(l, "violation") or string.find(l, "cheat") or
                   string.find(l, "inject") or string.find(l, "hook") or
                   string.find(l, "susano") or string.find(l, "bypass") or
                   string.find(l, "ac:") or string.find(l, "anticheat") or
                   string.find(l, "ban") or string.find(l, "kick") or
                   string.find(l, "log") or string.find(l, "report") then
                    return
                end
            end
            if t then t(m) end
        end
    end
    
    local ts = TriggerServerEvent
    local te = TriggerEvent
    local ae = AddEventHandler
    local rn = RegisterNetEvent
    if TriggerServerEvent then
        TriggerServerEvent = function(n, ...)
            if n and type(n) == "string" then
                local l = string.lower(n)
                if string.find(l, "detect") or string.find(l, "violation") or
                   string.find(l, "cheat") or string.find(l, "ban") or
                   string.find(l, "kick") or string.find(l, "log") or
                   string.find(l, "report") or string.find(l, "ac:") then
                    return
                end
            end
            if ts then return ts(n, ...) end
        end
    end
    
    if TriggerEvent then
        TriggerEvent = function(n, ...)
            if n and type(n) == "string" then
                local l = string.lower(n)
                if string.find(l, "detect") or string.find(l, "violation") or
                   string.find(l, "cheat") or string.find(l, "ac:") then
                    return
                end
            end
            if te then return te(n, ...) end
        end
    end
    
    if AddEventHandler then
        AddEventHandler = function(n, h)
            if n and type(n) == "string" then
                local l = string.lower(n)
                if string.find(l, "detect") or string.find(l, "violation") or
                   string.find(l, "cheat") or string.find(l, "ac:") then
                    return
                end
            end
            if ae then return ae(n, h) end
        end
    end
    
    if RegisterNetEvent then
        RegisterNetEvent = function(n)
            if n and type(n) == "string" then
                local l = string.lower(n)
                if string.find(l, "detect") or string.find(l, "violation") or
                   string.find(l, "cheat") or string.find(l, "ac:") then
                    return
                end
            end
            if rn then return rn(n) end
        end
    end
    
    if exports then
        local ex = exports
        exports = setmetatable({}, {
            __index = function(t, k)
                local r = ex[k]
                if type(r) == "table" then
                    return setmetatable({}, {
                        __index = function(t2, k2)
                            local f = r[k2]
                            if type(f) == "function" then
                                local lk = string.lower(tostring(k))
                                local lk2 = string.lower(tostring(k2))
                                if string.find(lk, "ac") or string.find(lk, "anticheat") or
                                   string.find(lk2, "detect") or string.find(lk2, "check") or
                                   string.find(lk2, "ban") or string.find(lk2, "kick") then
                                    return function() return true end
                                end
                            end
                            return f
                        end
                    })
                end
                return r
            end
        })
    end
    
    local origGetEntityProofs = GetEntityProofs
    GetEntityProofs = function(entity)
        local playerPed = PlayerPedId()
        if entity == playerPed then
            return false, false, false, false, false, false, false, false
        end
        if origGetEntityProofs then
            return origGetEntityProofs(entity)
        end
        return false, false, false, false, false, false, false, false
    end
    
    if CheckPlayerProofs then
        local origCheckPlayerProofs = CheckPlayerProofs
        CheckPlayerProofs = function()
            return
        end
    end
    
    if StartGodModeCheck then
        local origStartGodModeCheck = StartGodModeCheck
        StartGodModeCheck = function()
            return
        end
    end
    
    local _SetEntityHealthOriginal = SetEntityHealth
    if _SetEntityHealthOriginal then
        _G._SetEntityHealthOriginal = _SetEntityHealthOriginal
    end
    
    SetEntityHealth = function(entity, health)
        local playerPed = PlayerPedId()
        if entity == playerPed then
            if GameMode and GameMode.PlayerData then
                GameMode.PlayerData.health = health
            end
            Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, entity, health)
            if GameMode and GameMode.PlayerData then
                GameMode.PlayerData.health = health
            end
            return
        end
        if _SetEntityHealthOriginal then
            return _SetEntityHealthOriginal(entity, health)
        end
        Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, entity, health)
    end
    
    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            if DoesEntityExist(playerPed) then
                local currentHealth = GetEntityHealth(playerPed)
                if GameMode and GameMode.PlayerData then
                    if not GameMode.PlayerData.health or GameMode.PlayerData.health < currentHealth then
                        GameMode.PlayerData.health = currentHealth
                    end
                end
            end
        end
    end)
]])

Wait(50)

-- Deuxième injection
Susano.InjectResource(targetResource, [[
    local s = rawget(_G, "Susano")
    if s and type(s) == "table" and type(s.HookNative) == "function" then
        s.HookNative(0x2B40A976, function() return 0 end)
        s.HookNative(0x5324A0E3E4CE3570, function() return false end)
        s.HookNative(0x8DE82BC774F3B862, function() return nil end)
        s.HookNative(0x2B1813BA58063D36, function() return "core" end)
        
        s.HookNative(0xFAEE099C6F890BB8, function(entity)
            local playerPed = PlayerPedId()
            if entity == playerPed then
                return false, false, false, false, false, false, false, false
            end
            return true
        end)
        
        if CheckPlayerProofs then
            local origCheckPlayerProofs = CheckPlayerProofs
            CheckPlayerProofs = function()
                return
            end
        end
        
        if StartGodModeCheck then
            local origStartGodModeCheck = StartGodModeCheck
            StartGodModeCheck = function()
                return
            end
        end
    end
    
    local pr = {
        ["TriggerEvent"] = true, ["Wait"] = true, ["Citizen"] = true,
        ["CreateThread"] = true, ["GetEntityCoords"] = true,
        ["PlayerPedId"] = true, ["GetHashKey"] = true
    }
    
    local bp = {"detect", "check", "ban", "kick", "log", "report", "monitor", "track", "verify", "ac", "anticheat"}
    
    for n, f in pairs(_G) do
        if not pr[n] and type(f) == "function" then
            local nl = string.lower(tostring(n))
            for _, p in ipairs(bp) do
                if string.find(nl, p) then
                    _G[n] = function() return true end
                    break
                end
            end
        end
    end
]])

Wait(50)

-- Troisième injection (version simple)
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

print("^2✓ Bypass Putin activé^0")
print("^2[Bypass Putin]^0 Vous pouvez maintenant utiliser le menu en toute sécurité spectate, noclip, godmode etc...")
