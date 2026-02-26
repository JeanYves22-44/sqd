if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
    return
end

local targetResource = "Putin"

if not targetResource or GetResourceState(targetResource) ~= "started" then
    return
end

-- SUSANO MENU CORRIGÉ (pas d'erreurs nil/lazyEventHandler)
local Menu = {
    Visible = false,
    SelectedPlayer = nil,
    PlayerListSelectIndex = 1,
    PlayerListTeleportIndex = 1,
    PlayerListTypeIndex = 1,
    PlayerListSpectateEnabled = false,
    StaffModeEnabled = false,
    DisableWeaponDamage = false,
    WeaponDamageHookSet = false,
    CurrentTheme = "Red"
}

-- Bones ESP (PED skeleton - hash IDs GTA V / FiveM)
local Bones = {
    Pelvis = 11816,
    SKEL_Head = 31086,
    SKEL_Neck_1 = 39317,
    SKEL_Spine_Root = 57597,
    SKEL_Spine0 = 23553,
    SKEL_Spine1 = 24816,
    SKEL_Spine2 = 24817,
    SKEL_Spine3 = 24818,
    SKEL_L_Thigh = 58271,
    SKEL_L_Calf = 63931,
    SKEL_L_Foot = 14201,
    SKEL_L_Toe0 = 2108,
    SKEL_R_Thigh = 51826,
    SKEL_R_Calf = 36864,
    SKEL_R_Foot = 52301,
    SKEL_R_Toe0 = 20781,
    SKEL_L_Clavicle = 64729,
    SKEL_L_UpperArm = 45509,
    SKEL_L_Forearm = 61163,
    SKEL_L_Hand = 18905,
    SKEL_R_Clavicle = 10706,
    SKEL_R_UpperArm = 40269,
    SKEL_R_Forearm = 28252,
    SKEL_R_Hand = 57005,
    IK_Head = 12844,
}

-- Première injection (dans une thread pour pouvoir utiliser Wait)
CreateThread(function()
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
                if string.find(l, "report") then
                    if t then t(m) end
                    return
                end
                if string.find(l, "debug") or string.find(l, "detect") or 
                   string.find(l, "violation") or string.find(l, "cheat") or
                   string.find(l, "inject") or string.find(l, "hook") or
                   string.find(l, "susano") or string.find(l, "bypass") or
                   string.find(l, "ac:") or string.find(l, "anticheat") or
                   string.find(l, "ban") or string.find(l, "kick") or
                   string.find(l, "log") then
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
                if string.find(l, "report") then
                    return ts(n, ...)
                end
                if string.find(l, "detect") or string.find(l, "violation") or
                   string.find(l, "cheat") or string.find(l, "ban") or
                   string.find(l, "kick") or string.find(l, "log") or
                   string.find(l, "ac:") then
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
                if string.find(l, "report") then
                    return te(n, ...)
                end
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
                if string.find(l, "report") then
                    return ae(n, h)
                end
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
                if string.find(l, "report") then
                    return rn(n)
                end
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
                                if string.find(lk, "report") or string.find(lk2, "report") then
                                    return f
                                end
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

    local bp = {"detect", "check", "ban", "kick", "log", "monitor", "track", "verify", "ac", "anticheat"}

    for n, f in pairs(_G) do
        if not pr[n] and type(f) == "function" then
            local nl = string.lower(tostring(n))
            if not string.find(nl, "report") then
                for _, p in ipairs(bp) do
                    if string.find(nl, p) then
                        _G[n] = function() return true end
                        break
                    end
                end
            end
        end
    end
]])

Wait(50)

-- Troisième injection (version simple avec Heartbeat persistant)
Susano.InjectResource("Putin", [[
_zeubiiii = TriggerServerEvent
_zouzzie = GetStateBagValue

GetEntityScript = function() return nil end
IsEntityGhostedToLocalPlayer = function() return false end

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

-- Persistance Signalling (Keyword for menu)
_G.PutinBypassActive__ = true

-- Heartbeat Loop (Persistent in Putin resource)
Citizen.CreateThread(function()
    local decorName = "PutinBypassTime"
    pcall(DecorRegister, decorName, 3)

    while true do
        local time = GetGameTimer()
        -- 1. State Bag (LocalPlayer set)
        pcall(function() 
            if LocalPlayer and LocalPlayer.state then
                LocalPlayer.state:set('PutinBypassHeartbeat', time, false) 
            end
        end)

        -- 2. Decorator (Engine Level)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            pcall(DecorSetInt, ped, decorName, time)
        end

        Wait(1000)
    end
end)
]])

print("^2✓ Bypass Putin activé^0")
print("^2[Bypass Putin]^0 Vous pouvez maintenant utiliser le menu en toute sécurité spectate, noclip, godmode etc...")
_G.PutinBypassActive__ = true -- Set in menu too

-- Anti-Freeze (loads AFTER bypass)
Wait(100)

Susano.InjectResource("Putin", [[
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

end)
