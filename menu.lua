-- GENGAR MENU v3 - VERSION FINALE COMPLÈTE
-- Black Hole + Steal Outfit + Launch Player + Attach + Toutes fonctions

-- [1. VARIABLES ET ÉTATS]
local menuOpen = false
local menuAlpha = 0
local selectedOption = 1
local startIndex = 1
local maxDisplay = 8
local currentMenu = "MAIN"

local selectedPlayer = nil
local attachedPlayers = {}
local originalCoords = {}
local fullGodModeActive = false
local semiGodModeActive = false
local forceEngineActive = false
local shiftBoostActive = false
local blackHoleActive = false
local rampVehicleActive = false
local easyHandlingActive = false
local carryActive = false
local carriedVehicle = nil
local rampVehiclesAttached = {}
local freeCamActive = false
local freeCamSpeed = 1.0
local freeCamSpeeds = {0.1, 0.5, 1.0, 2.0, 5.0}
local freeCamSpeedIdx = 3
local freeCamCamera = nil
local freeCamTpOnExit = false
local throwVehicleActive = false
local onlineFilterVehicles = false
local soloSessionActive = false

-- Variables pour le défilement continu
local lastNavTime = 0
local normalNavDelay = 200
local fastNavDelay = 120

-- [2. CONFIGURATION DES TOUCHES]
local KEY_OPEN = 57      -- F10
local KEY_SELECT = 191   -- ENTER
local KEY_BACK = 194     -- BACKSPACE
local KEY_UP = 172       -- Flèche HAUT
local KEY_DOWN = 173     -- Flèche BAS
local KEY_REVIVE = 73    -- X (pour se relever)
local KEY_CARRY = 51     -- E (pour porter/lancer)
local AK_DIST = 1.0

-- [3. CONFIGURATION DU MENU]
--
local mainOptions = {
    "Player",
    "Online",
    "Combat",
    "Vehicle",
    "Miscellaneous",
    "Settings"
}



local playerOptions = {
    "Full God Mode",
    "Semi God Mode",
    "Freecam",
    "Freecam Speed",
    "Freecam: TP on Exit",
    "Clean Ped",
    "Solo Session",
    "Noclip"
}

local combatOptions = {
    "Give All Weapons",
    "Remove All Weapons"
}

--
local vehicleOptions = {
    "Fix Vehicle",
    "Max Upgrade",
    "Kick Vehicle",
    "Bug Vehicle",
    "Throw Vehicle",
    "Ramp Vehicle",
    "Carry Vehicle",
    "Easy Handling",
    "Force Engine",
    "Shift Boost"
}

local miscOptions = {
    "Bypass Putin"
}

-- [3.1 MODDED WEAPONS LIST]
local moddedWeapons = {
    {name = "weapon_aa", display = "AA"},
    {name = "weapon_caveira", display = "Caveira"},
    {name = "weapon_SCOM", display = "SCOM"},
    {name = "weapon_mcx", display = "MCX"},
    {name = "weapon_grau", display = "Grau"},
    {name = "weapon_midasgun", display = "Midas"},
    {name = "weapon_hackingdevice", display = "Hacking Device"},
    {name = "weapon_akorus", display = "Akorus"},
    {name = "WEAPON_MIDGARD", display = "Midgard"},
    {name = "weapon_chainsaw", display = "Chainsaw"}
}

-- [3.2 GIVE ALL MODDED WEAPONS - BNZ METHOD]
local function GiveAllModdedWeapons()
    if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
        ShowDynastyNotification("~r~Error: Susano not available")
        return
    end

    Susano.InjectResource("any", string.format([[
        local susano = rawget(_G, "Susano")
        if susano and type(susano) == "table" and type(susano.HookNative) == "function" then
            susano.HookNative(0x3A87E44BB9A01D54, function(ped, weaponHash) return true, -1569615261 end)

            susano.HookNative(0xADF692B254977C0C, function(ped, weapon, equipNow)
                if weapon == -1569615261 then
                    return true
                end
                return true
            end)

            susano.HookNative(0xF25DF915FA38C5F3, function(ped, p1) return end)

            susano.HookNative(0x4899CB088EDF3BCC, function(ped, weaponHash, p2) return end)

            susano.HookNative(0x3795688A307E1EB6, function(ped) return false end)
            susano.HookNative(0x0A6DB4965674D243, function(ped) return -1569615261 end)
            susano.HookNative(0xC3287EE3050FB74C, function(weaponHash) return -1569615261 end)
            susano.HookNative(0x475768A975D5AD17, function(ped, p1) return false end)
            susano.HookNative(0x8DECB02F88F428BC, function(ped, weaponHash, p2) return false end)
            susano.HookNative(0x34616828CD07F1A1, function(ped) return false end)
            susano.HookNative(0x3A50753042A63901, function(ped) return false end)
            susano.HookNative(0xB2A38826EAB6BCF1, function(ped) return false end)
            susano.HookNative(0xED958C9C056BF401, function(ped) return false end)
            susano.HookNative(0x8483E98E8B888A2D, function(ped, p1) return -1569615261 end)
            susano.HookNative(0xA38DCFFCE89696FA, function(ped, weaponHash) return 0 end)
            susano.HookNative(0x7FEAD38B326B9F74, function(ped, weaponHash) return 0 end)
            susano.HookNative(0x3B390A939AF0B5FC, function(ped) return -1 end)
            susano.HookNative(0x59DE03442B6C9598, function(weaponHash) return -1569615261 end)
            susano.HookNative(0x3133B907D8B32053, function(weaponHash, componentHash) return 0.3 end)
            susano.HookNative(0x97A790315D3831FD, function(entity) return 0 end)
            susano.HookNative(0x48C2BED9180FE123, function(entity) return false end)
            susano.HookNative(0x89CF5FF3D310A0DB, function(weaponHash) return -1569615261 end)
            susano.HookNative(0x24B600C29F7F8A9E, function(ped) return false end)
            susano.HookNative(0x8483E98E8B888AE2, function(ped, p1) return -1569615261 end)
            susano.HookNative(0xCAE1DC9A0E22A16D, function(ped) return 0 end)
            susano.HookNative(0x4899CB088EDF59B8, function(ped, weaponHash) return end)
            susano.HookNative(0x2E1202248937775C, function(ped, weaponHash, ammo) return true, 9999 end)
            susano.HookNative(0x2B9EEDC07BD06B9F, function(ped, weaponHash) return 0 end)
        end

        local _GetCurrentPedWeapon = GetCurrentPedWeapon
        local _RemoveAllPedWeapons = RemoveAllPedWeapons
        local _RemoveWeaponFromPed = RemoveWeaponFromPed
        local _SetCurrentPedWeapon = SetCurrentPedWeapon

        GetCurrentPedWeapon = function(ped, ...)
            return true, GetHashKey("WEAPON_UNARMED")
        end

        RemoveAllPedWeapons = function(ped, ...) return end

        RemoveWeaponFromPed = function(ped, weapon) return end

        SetCurrentPedWeapon = function(ped, weapon, ...)
            if weapon == GetHashKey("WEAPON_UNARMED") then
                return _SetCurrentPedWeapon(ped, weapon, ...)
            end
            return
        end

        local weaponAAHash = GetHashKey("weapon_aa")
        local weaponCaveiraHash = GetHashKey("weapon_caveira")
        local weaponSCOMHash = GetHashKey("weapon_SCOM")
        local weaponMCXHash = GetHashKey("weapon_mcx")
        local weaponGrauHash = GetHashKey("weapon_grau")
        local weaponMidasHash = GetHashKey("weapon_midasgun")
        local weaponHackingHash = GetHashKey("weapon_hackingdevice")
        local weaponAkorusHash = GetHashKey("weapon_akorus")
        local weaponMidgardHash = GetHashKey("WEAPON_MIDGARD")
        local weaponChainsawHash = GetHashKey("weapon_chainsaw")
        local selfPed = PlayerPedId()

        GiveWeaponToPed(selfPed, weaponAAHash, 999, false, true)
        SetPedAmmo(selfPed, weaponAAHash, 999)

        GiveWeaponToPed(selfPed, weaponCaveiraHash, 999, false, true)
        SetPedAmmo(selfPed, weaponCaveiraHash, 999)

        GiveWeaponToPed(selfPed, weaponSCOMHash, 999, false, true)
        SetPedAmmo(selfPed, weaponSCOMHash, 999)

        GiveWeaponToPed(selfPed, weaponMCXHash, 999, false, true)
        SetPedAmmo(selfPed, weaponMCXHash, 999)

        GiveWeaponToPed(selfPed, weaponGrauHash, 999, false, true)
        SetPedAmmo(selfPed, weaponGrauHash, 999)

        GiveWeaponToPed(selfPed, weaponMidasHash, 999, false, true)
        SetPedAmmo(selfPed, weaponMidasHash, 999)

        GiveWeaponToPed(selfPed, weaponHackingHash, 999, false, true)
        SetPedAmmo(selfPed, weaponHackingHash, 999)

        GiveWeaponToPed(selfPed, weaponAkorusHash, 999, false, true)
        SetPedAmmo(selfPed, weaponAkorusHash, 999)

        GiveWeaponToPed(selfPed, weaponMidgardHash, 999, false, true)
        SetPedAmmo(selfPed, weaponMidgardHash, 999)

        GiveWeaponToPed(selfPed, weaponChainsawHash, 999, false, true)
        SetPedAmmo(selfPed, weaponChainsawHash, 999)

        _SetCurrentPedWeapon(selfPed, weaponAAHash, true)
    ]]))

    ShowDynastyNotification("~g~All modded weapons given!")
end

-- [3.3 REMOVE ALL WEAPONS]
local function RemoveAllWeapons()
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
    ShowDynastyNotification("~g~All weapons removed!")
end

-- [3.4 STEAL OUTFIT - BNZ Copy Appearance]
local function StealOutfit()
    if not selectedPlayer then
        ShowDynastyNotification("~r~No player selected")
        return
    end

    local targetServerId = selectedPlayer.serverId

    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            local function hNative(nativeName, newFunction)
                local originalNative = _G[nativeName]
                if not originalNative or type(originalNative) ~= "function" then return end
                _G[nativeName] = function(...) return newFunction(originalNative, ...) end
            end

            hNative("GetActivePlayers", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPlayerServerId", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPlayerPed", function(originalFn, ...) return originalFn(...) end)
            hNative("PlayerPedId", function(originalFn, ...) return originalFn(...) end)
            hNative("DoesEntityExist", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedComponentVariation", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedDrawableVariation", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedTextureVariation", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedPaletteVariation", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedPropIndex", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedPropIndex", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedPropTextureIndex", function(originalFn, ...) return originalFn(...) end)
            hNative("ClearPedProp", function(originalFn, ...) return originalFn(...) end)
            hNative("ClonePedToTarget", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedHeadBlendData", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedHeadBlendData", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedFaceFeature", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedFaceFeature", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedHairColor", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedHairHighlightColor", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedHairColor", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedEyeColor", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedEyeColor", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedHeadOverlay", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedHeadOverlay", function(originalFn, ...) return originalFn(...) end)
            hNative("GetPedHeadOverlayColor", function(originalFn, ...) return originalFn(...) end)
            hNative("SetPedHeadOverlayColor", function(originalFn, ...) return originalFn(...) end)

            local targetServerId = %d

            local targetPlayerId = nil
            for _, player in ipairs(GetActivePlayers()) do
                if GetPlayerServerId(player) == targetServerId then
                    targetPlayerId = player
                    break
                end
            end

            if not targetPlayerId then return end

            local targetPed = GetPlayerPed(targetPlayerId)
            local myPed = PlayerPedId()

            if not DoesEntityExist(targetPed) or not DoesEntityExist(myPed) then return end

            ClonePedToTarget(targetPed, myPed)

            Wait(100)

            if type(Susano) == "table" and type(Susano.SpoofPed) == "function" then
                pcall(Susano.SpoofPed, GetEntityModel(myPed), true)
            end

            for componentId = 0, 11 do
                local drawable = GetPedDrawableVariation(targetPed, componentId)
                local texture = GetPedTextureVariation(targetPed, componentId)
                local palette = GetPedPaletteVariation(targetPed, componentId)
                SetPedComponentVariation(myPed, componentId, drawable, texture, palette)
            end

            for propId = 0, 7 do
                local prop = GetPedPropIndex(targetPed, propId)
                local texture = GetPedPropTextureIndex(targetPed, propId)
                if prop ~= -1 then
                    SetPedPropIndex(myPed, propId, prop, texture, true)
                else
                    ClearPedProp(myPed, propId)
                end
            end

            local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = GetPedHeadBlendData(targetPed)
            SetPedHeadBlendData(myPed, shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix)

            for i = 0, 19 do
                local value = GetPedFaceFeature(targetPed, i)
                SetPedFaceFeature(myPed, i, value)
            end

            local hairColor, highlightColor = GetPedHairColor(targetPed)
            SetPedHairColor(myPed, hairColor, highlightColor)

            local eyeColor = GetPedEyeColor(targetPed)
            SetPedEyeColor(myPed, eyeColor)

            for overlayId = 0, 12 do
                local overlayValue, overlayOpacity = GetPedHeadOverlay(targetPed, overlayId)
                local colorType, colorId, secondColorId = GetPedHeadOverlayColor(targetPed, overlayId)
                SetPedHeadOverlay(myPed, overlayId, overlayValue, overlayOpacity)
                if colorType == 1 then
                    SetPedHeadOverlayColor(myPed, overlayId, colorType, colorId, secondColorId)
                elseif colorType == 2 then
                    SetPedHeadOverlayColor(myPed, overlayId, colorType, colorId, secondColorId)
                end
            end
        ]], targetServerId))

        ShowDynastyNotification("~g~Outfit stolen!")
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end

local trollOptions = {
    "Launch Player",
    "Launch Player V2",
    "Attach Player",
    "Black Hole",
    "Steal Outfit",
    "Spectate",
    "Kick Vehicle (Steal)",
    "Bug Vehicle",
    "TP to Player"
}

-- [3.5 KICK VEHICLE - BNZ Steal Vehicle / Hijack]
local function KickVehicleSteal()
    if not selectedPlayer then
        ShowDynastyNotification("~r~No player selected")
        return
    end

    local targetServerId = selectedPlayer.serverId

    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            CreateThread(function()
                if rawget(_G, 'warp_boost_busy') then return end
                rawset(_G, 'warp_boost_busy', true)

                local targetServerId = %d

                local targetPlayerId = nil
                for _, player in ipairs(GetActivePlayers()) do
                    if GetPlayerServerId(player) == targetServerId then
                        targetPlayerId = player
                        break
                    end
                end

                if not targetPlayerId then
                    rawset(_G, 'warp_boost_busy', false)
                    return
                end

                local targetPed = GetPlayerPed(targetPlayerId)
                if not DoesEntityExist(targetPed) then
                    rawset(_G, 'warp_boost_busy', false)
                    return
                end

                if not IsPedInAnyVehicle(targetPed, false) then
                    rawset(_G, 'warp_boost_busy', false)
                    return
                end

                local targetVehicle = GetVehiclePedIsIn(targetPed, false)
                if not DoesEntityExist(targetVehicle) then
                    rawset(_G, 'warp_boost_busy', false)
                    return
                end

                local playerPed = PlayerPedId()
                local initialCoords = GetEntityCoords(playerPed)
                local initialHeading = GetEntityHeading(playerPed)

                local function RequestControl(entity, timeoutMs)
                    if not entity or not DoesEntityExist(entity) then return false end
                    local start = GetGameTimer()
                    NetworkRequestControlOfEntity(entity)
                    while not NetworkHasControlOfEntity(entity) do
                        Wait(0)
                        if GetGameTimer() - start > (timeoutMs or 500) then
                            return false
                        end
                        NetworkRequestControlOfEntity(entity)
                    end
                    return true
                end

                RequestControl(targetVehicle, 800)
                SetVehicleDoorsLocked(targetVehicle, 1)
                SetVehicleDoorsLockedForAllPlayers(targetVehicle, false)

                local function tryEnterSeat(seatIndex)
                    SetPedIntoVehicle(playerPed, targetVehicle, seatIndex)
                    Wait(0)
                    return IsPedInVehicle(playerPed, targetVehicle, false) and GetPedInVehicleSeat(targetVehicle, seatIndex) == playerPed
                end

                local function getFirstFreeSeat(v)
                    local numSeats = GetVehicleModelNumberOfSeats(GetEntityModel(v))
                    if not numSeats or numSeats <= 0 then return -1 end
                    for seat = 0, (numSeats - 2) do
                        if IsVehicleSeatFree(v, seat) then return seat end
                    end
                    return -1
                end

                ClearPedTasksImmediately(playerPed)
                SetVehicleDoorsLocked(targetVehicle, 1)
                SetVehicleDoorsLockedForAllPlayers(targetVehicle, false)

                local takeoverSuccess = false
                local tStart = GetGameTimer()

                while (GetGameTimer() - tStart) < 1000 do
                    RequestControl(targetVehicle, 400)

                    if IsVehicleSeatFree(targetVehicle, -1) and tryEnterSeat(-1) then
                        takeoverSuccess = true
                        break
                    end

                    if not IsPedInVehicle(playerPed, targetVehicle, false) then
                        local fs = getFirstFreeSeat(targetVehicle)
                        if fs ~= -1 then
                            tryEnterSeat(fs)
                        end
                    end

                    local drv = GetPedInVehicleSeat(targetVehicle, -1)
                    if drv ~= 0 and drv ~= playerPed and DoesEntityExist(drv) then
                        RequestControl(drv, 400)
                        ClearPedTasksImmediately(drv)
                        SetEntityAsMissionEntity(drv, true, true)
                        SetEntityCoords(drv, 0.0, 0.0, -100.0, false, false, false, false)
                        Wait(20)
                        DeleteEntity(drv)
                    end

                    local t0 = GetGameTimer()
                    while (GetGameTimer() - t0) < 400 do
                        local occ = GetPedInVehicleSeat(targetVehicle, -1)
                        if occ == 0 or (occ ~= 0 and not DoesEntityExist(occ)) then break end
                        Wait(0)
                    end

                    local t1 = GetGameTimer()
                    while (GetGameTimer() - t1) < 500 do
                        if IsVehicleSeatFree(targetVehicle, -1) and tryEnterSeat(-1) then
                            takeoverSuccess = true
                            break
                        end
                        Wait(0)
                    end
                    if takeoverSuccess then break end
                    Wait(0)
                end

                if takeoverSuccess then
                    if DoesEntityExist(targetVehicle) and IsPedInVehicle(playerPed, targetVehicle, false) then
                        RequestControl(targetVehicle, 1000)
                        if NetworkHasControlOfEntity(targetVehicle) then
                            FreezeEntityPosition(targetVehicle, true)
                            SetVehicleEngineOn(targetVehicle, true, true, false)
                            SetEntityCoordsNoOffset(targetVehicle, initialCoords.x, initialCoords.y, initialCoords.z + 1.0, false, false, false, false)
                            SetEntityHeading(targetVehicle, initialHeading)
                            SetEntityVelocity(targetVehicle, 0.0, 0.0, 0.0)
                            Wait(100)
                            FreezeEntityPosition(targetVehicle, false)
                            SetVehicleOnGroundProperly(targetVehicle)
                        end
                    end
                end

                rawset(_G, 'warp_boost_busy', false)
            end)
        ]], targetServerId))

        ShowDynastyNotification("~g~Stealing vehicle...")
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end


-- [3.6 BUG VEHICLE - BNZ METHOD]
local function BugVehicle()
    if not selectedPlayer then
        ShowDynastyNotification("~r~No player selected")
        return
    end

    local targetServerId = selectedPlayer.serverId

    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            local targetServerId = %d

            local targetPlayerId = nil
            for _, player in ipairs(GetActivePlayers()) do
                if GetPlayerServerId(player) == targetServerId then
                    targetPlayerId = player
                    break
                end
            end

            if not targetPlayerId then return end

            local targetPed = GetPlayerPed(targetPlayerId)
            if not DoesEntityExist(targetPed) or not IsPedInAnyVehicle(targetPed, false) then
                return
            end

            local targetVehicle = GetVehiclePedIsIn(targetPed, false)
            if not DoesEntityExist(targetVehicle) then return end

            CreateThread(function()
                local playerPed = PlayerPedId()
                local myCoords = GetEntityCoords(playerPed)

                local closestVeh = GetClosestVehicle(myCoords.x, myCoords.y, myCoords.z, 100.0, 0, 70)
                if not closestVeh or closestVeh == 0 then return end

                SetPedIntoVehicle(playerPed, closestVeh, -1)
                Wait(150)

                SetEntityAsMissionEntity(closestVeh, true, true)
                if NetworkGetEntityIsNetworked(closestVeh) then
                    NetworkRequestControlOfEntity(closestVeh)
                end

                SetEntityCoordsNoOffset(playerPed, myCoords.x, myCoords.y, myCoords.z, false, false, false)
                Wait(100)

                for i = 1, 30 do
                    DetachEntity(closestVeh, true, true)
                    Wait(5)
                    AttachEntityToEntityPhysically(closestVeh, targetVehicle, 0, 0, 0, 2000.0, 1460.0, 1000.0, 10.0, 88.0, 600.0, true, true, true, false, 0)
                    Wait(5)
                end
            end)
        ]], targetServerId))

        ShowDynastyNotification("~g~Bug Vehicle applied!")
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end

-- [3.7 TP TO PLAYER]
local function TeleportToPlayer()
    if not selectedPlayer then
        ShowDynastyNotification("~r~No player selected")
        return
    end

    local targetServerId = selectedPlayer.serverId

    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            local targetServerId = %d
            local targetPlayerId = nil
            for _, player in ipairs(GetActivePlayers()) do
                if GetPlayerServerId(player) == targetServerId then
                    targetPlayerId = player
                    break
                end
            end

            if targetPlayerId then
                local targetPed = GetPlayerPed(targetPlayerId)
                if DoesEntityExist(targetPed) then
                    local coords = GetEntityCoords(targetPed)
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
                end
            end
        ]], targetServerId))
        ShowDynastyNotification("~g~Teleported to player!")
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end

-- [3.8 SPECTATE - BNZ METHOD]
local spectateActive = false

local function ToggleSpectate(enable)
    if enable then
        if not selectedPlayer then
            ShowDynastyNotification("~r~No player selected")
            return
        end

        spectateActive = true
        local targetServerId = selectedPlayer.serverId

        if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
            Susano.InjectResource("any", string.format([[
                local targetServerId = %d
                local spectateThreadActive = true
                local playerPed = PlayerPedId()

                CreateThread(function()
                    while spectateThreadActive do
                        Wait(0)

                        local targetPlayerId = nil
                        for _, player in ipairs(GetActivePlayers()) do
                            if GetPlayerServerId(player) == targetServerId then
                                targetPlayerId = player
                                break
                            end
                        end

                        if targetPlayerId then
                            local targetPed = GetPlayerPed(targetPlayerId)
                            if DoesEntityExist(targetPed) then
                                NetworkSetInSpectatorMode(true, targetPed)
                            else
                                spectateThreadActive = false
                                NetworkSetInSpectatorMode(false, playerPed)
                                break
                            end
                        else
                            spectateThreadActive = false
                            NetworkSetInSpectatorMode(false, playerPed)
                            break
                        end
                    end

                    NetworkSetInSpectatorMode(false, playerPed)
                end)

                rawset(_G, 'spectate_thread_active_' .. targetServerId, function()
                    spectateThreadActive = false
                    NetworkSetInSpectatorMode(false, playerPed)
                end)
            ]], targetServerId))

            ShowDynastyNotification("~g~Spectating player...")
        end
    else
        spectateActive = false

        if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
            if selectedPlayer then
                local targetServerId = selectedPlayer.serverId
                Susano.InjectResource("any", string.format([[
                    local stopFunction = rawget(_G, 'spectate_thread_active_' .. %d)
                    if stopFunction then
                        stopFunction()
                        rawset(_G, 'spectate_thread_active_' .. %d, nil)
                    end
                    NetworkSetInSpectatorMode(false, PlayerPedId())
                ]], targetServerId, targetServerId))
            else
                Susano.InjectResource("any", [[
                    NetworkSetInSpectatorMode(false, PlayerPedId())
                ]])
            end

            ShowDynastyNotification("~r~Spectate OFF")
        end
    end
end

-- FOV Hijack variables
local fovHijackActive = false
local fovHijackKey = 0x58  -- Default: X key
local fovHijackKeyName = "X"

-- [4. SYSTÈME DE NOTIFICATIONS]
local notifyActive = false
local notifyText = ""
local notifyStartTime = 0

function ShowDynastyNotification(text)
    notifyText = text
    notifyStartTime = GetGameTimer()
    notifyActive = true
end

function DrawDynastyNotify()
    if not notifyActive then return end

    local cur = GetGameTimer()
    if cur < notifyStartTime + 4000 then
        local x, y, w, h = 0.12, 0.82, 0.18, 0.05
        local progress = (notifyStartTime + 4000 - cur) / 4000

        DrawRect(x, y, w, h, 10, 10, 10, 225)
        DrawRect(x - (w/2) + (w*progress/2), y - (h/2), w*progress, 0.0015, 100, 0, 180, 255)

        SetTextFont(4)
        SetTextScale(0.3, 0.3)
        SetTextColour(255, 255, 255, 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName("~p~D~w~ DYNASTY")
        EndTextCommandDisplayText(x - w/2 + 0.005, y - h/2 + 0.008)

        SetTextFont(0)
        SetTextScale(0.32, 0.32)
        SetTextCentre(false)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(notifyText)
        EndTextCommandDisplayText(x - w/2 + 0.005, y + 0.005)
    else
        notifyActive = false
    end
end

-- [5. FONCTIONS UTILITAIRES]
local function DrawTextCustom(text, x, y, scale, font, r, g, b, a, center)
    SetTextFont(font or 0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, math.floor(a * (menuAlpha / 255)))
    if center then SetTextCentre(true) end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

function getNearbyPlayers()
    local players = {}
    local myCoords = GetEntityCoords(PlayerPedId())

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local distance = #(myCoords - GetEntityCoords(targetPed))
            if distance <= 500.0 then
                local inVeh = IsPedInAnyVehicle(targetPed, false)
                table.insert(players, {
                    id = playerId,
                    serverId = GetPlayerServerId(playerId),
                    name = GetPlayerName(playerId),
                    dist = math.floor(distance),
                    inVeh = inVeh
                })
            end
        end
    end

    table.sort(players, function(a, b) return a.dist < b.dist end)
    return players
end

function GetDisplayedPlayerList()
    local allPlayers = getNearbyPlayers()
    if not onlineFilterVehicles then
        return allPlayers
    end
    
    local filtered = {}
    for _, p in ipairs(allPlayers) do
        if p.inVeh then
            table.insert(filtered, p)
        end
    end
    return filtered
end

-- [5.1 FONCTION REVIVE DISCRÈTE - BIND X]
local function QuickRevive()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)

    if fullGodModeActive or semiGodModeActive then
        SetEntityHealth(ped, maxHealth)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ShowDynastyNotification("~g~Full Heal!")
    elseif currentHealth > 0 and currentHealth < maxHealth then
        local healAmount = math.min(50, maxHealth - currentHealth)
        SetEntityHealth(ped, currentHealth + healAmount)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ShowDynastyNotification("~g~+50 HP")
    end
end

-- [6. FULL GOD MODE]
local function ToggleFullGodmode(enable)
    if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
        ShowDynastyNotification("~r~Error: Susano not available")
        return
    end

    fullGodModeActive = enable

    if enable and semiGodModeActive then
        semiGodModeActive = false
    end

    local code = string.format([[
        local susano = rawget(_G, "Susano")

        if _G.FullGodmodeEnabled == nil then _G.FullGodmodeEnabled = false end
        _G.FullGodmodeEnabled = %s

        if not _G.FullGodmodeHooksInstalled and susano and type(susano.HookNative) == "function" then
            _G.FullGodmodeHooksInstalled = true

            susano.HookNative(0xFAEE099C6F890BB8, function(entity)
                if _G.FullGodmodeEnabled and entity == PlayerPedId() then
                    return false, false, false, false, false, false, false, false
                end
                return true
            end)

            susano.HookNative(0x697157CED63F18D4, function(ped, damage, armorDamage)
                if _G.FullGodmodeEnabled and ped == PlayerPedId() then
                    return false
                end
                return true
            end)

            susano.HookNative(0x6B76DC1F3AE6E6A3, function(entity, health)
                if _G.FullGodmodeEnabled and entity == PlayerPedId() then
                    local maxHealth = GetEntityMaxHealth(entity)
                    if health < maxHealth then
                        return false
                    end
                end
                return true
            end)

            susano.HookNative(0x7C6BCA42, function(ped)
                if _G.FullGodmodeEnabled and ped == PlayerPedId() then
                    return false
                end
                return true
            end)
        end

        if not _G.FullGodmodeLoopStarted then
            _G.FullGodmodeLoopStarted = true

            Citizen.CreateThread(function()
                while true do
                    Wait(0)
                    if _G.FullGodmodeEnabled then
                        local ped = PlayerPedId()
                        if DoesEntityExist(ped) then
                            local maxHealth = GetEntityMaxHealth(ped)
                            SetEntityHealth(ped, maxHealth)
                        end
                    end
                end
            end)
        end
    ]], tostring(enable))

    Susano.InjectResource("any", code)

    if enable then
        ShowDynastyNotification("Full Godmode: ~g~ON ~w~(Press ~b~X~w~ to full heal)")
    else
        ShowDynastyNotification("Full Godmode: ~r~OFF")
    end
end

-- [7. SEMI GOD MODE]
local function ToggleSemiGodmode(enable)
    if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
        ShowDynastyNotification("~r~Error: Susano not available")
        return
    end

    semiGodModeActive = enable

    if enable and fullGodModeActive then
        fullGodModeActive = false
    end

    local code = string.format([[
        local susano = rawget(_G, "Susano")

        if _G.SemiGodmodeEnabled == nil then _G.SemiGodmodeEnabled = false end
        _G.SemiGodmodeEnabled = %s

        if not _G.SemiGodmodeHooksInstalled and susano and type(susano.HookNative) == "function" then
            _G.SemiGodmodeHooksInstalled = true

            susano.HookNative(0xFAEE099C6F890BB8, function(entity)
                if _G.SemiGodmodeEnabled and entity == PlayerPedId() then
                    return false, false, false, false, false, false, false, false
                end
                return true
            end)

            susano.HookNative(0x697157CED63F18D4, function(ped, damage, armorDamage)
                if _G.SemiGodmodeEnabled and ped == PlayerPedId() then
                    return false
                end
                return true
            end)

            susano.HookNative(0x6B76DC1F3AE6E6A3, function(entity, health)
                if _G.SemiGodmodeEnabled and entity == PlayerPedId() then
                    local maxHealth = GetEntityMaxHealth(entity)
                    if health < maxHealth then
                        return false
                    end
                end
                return true
            end)

            susano.HookNative(0x7C6BCA42, function(ped)
                if _G.SemiGodmodeEnabled and ped == PlayerPedId() then
                    return false
                end
                return true
            end)
        end

        if not _G.SemiGodmodeLoopStarted then
            _G.SemiGodmodeLoopStarted = true
            _G.LastHealth = nil

            if susano and type(susano.HookNative) == "function" then
                susano.HookNative(0xFAEE099C6F890BB8, function(entity)
                    if _G.SemiGodmodeEnabled and entity == PlayerPedId() then
                        return false, false, false, false, false, false, false, false
                    end
                    return true
                end)
            end

            Citizen.CreateThread(function()
                while true do
                    Wait(200)
                    if _G.SemiGodmodeEnabled then
                        local ped = PlayerPedId()
                        if not DoesEntityExist(ped) then goto continue end

                        local currentHealth = GetEntityHealth(ped)
                        local maxHealth = GetEntityMaxHealth(ped)

                        if currentHealth < maxHealth then
                            local regenAmount = math.min(3, maxHealth - currentHealth)
                            SetEntityHealth(ped, currentHealth + regenAmount)
                        end

                        if math.random(1, 10) == 1 then
                            ClearPedBloodDamage(ped)
                            ResetPedVisibleDamage(ped)
                        end

                        _G.LastHealth = currentHealth

                        ::continue::
                    end
                end
            end)

            Citizen.CreateThread(function()
                while true do
                    Wait(10)
                    if _G.SemiGodmodeEnabled then
                        local ped = PlayerPedId()
                        if not DoesEntityExist(ped) then goto continue end

                        local currentHealth = GetEntityHealth(ped)
                        local maxHealth = GetEntityMaxHealth(ped)

                        if _G.LastHealth and currentHealth < _G.LastHealth then
                            local damageTaken = _G.LastHealth - currentHealth
                            if damageTaken > 10 then
                                SetEntityHealth(ped, maxHealth)
                            elseif damageTaken > 5 then
                                local regenAmount = math.min(20, maxHealth - currentHealth)
                                SetEntityHealth(ped, currentHealth + regenAmount)
                            end
                        end

                        if currentHealth < (maxHealth * 0.8) then
                            local regenAmount = math.min(15, maxHealth - currentHealth)
                            SetEntityHealth(ped, currentHealth + regenAmount)
                        end

                        if currentHealth < (maxHealth * 0.5) then
                            SetEntityHealth(ped, maxHealth)
                        end

                        _G.LastHealth = currentHealth

                        ::continue::
                    end
                end
            end)
        end
    ]], tostring(enable))

    Susano.InjectResource("any", code)

    if enable then
        ShowDynastyNotification("Semi Godmode: ~g~ON ~w~(Press ~b~X~w~ to full heal)")
    else
        ShowDynastyNotification("Semi Godmode: ~r~OFF")
    end
end



local function SoloSession()
    soloSessionActive = not soloSessionActive
    
    if soloSessionActive then
        NetworkStartSoloTutorialSession()
        ShowDynastyNotification("Solo Session: ~g~ON ~w~(Tutorial Mode)")
    else
        NetworkEndTutorialSession()
        ShowDynastyNotification("Solo Session: ~r~OFF")
    end
end
-- Smooth Freecam Config
local fcOptions = {
    normalMaxSpeed = 2.0,
    fastMaxSpeed = 12.0,
    slowMaxSpeed = 0.2,
    accel = 0.1,
    decel = 0.1,
    sensitivity = 4.0
}
local currentFcSpeed = 0.0
local currentFcStrafe = 0.0

local function ToggleFreecam()
    freeCamActive = not freeCamActive

    if freeCamActive then
        local ped = PlayerPedId()
        local camCoords = GetGameplayCamCoord()
        local camRot = GetGameplayCamRot(2)
        
        freeCamCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(freeCamCamera, camCoords.x, camCoords.y, camCoords.z)
        SetCamRot(freeCamCamera, camRot.x, camRot.y, camRot.z, 2)
        SetCamActive(freeCamCamera, true)
        RenderScriptCams(true, false, 0, true, true)
        
        ShowDynastyNotification("Freecam: ~g~ON ~w~(Smooth)")
        
        currentFcSpeed = 0.0
        currentFcStrafe = 0.0

        CreateThread(function()
            while freeCamActive do
                Wait(0)
                
                -- Disable controls (Axes + Keys)
                DisableControlAction(0, 30, true) -- Move LR
                DisableControlAction(0, 31, true) -- Move UD
                DisableControlAction(0, 32, true) -- W
                DisableControlAction(0, 33, true) -- S
                DisableControlAction(0, 34, true) -- A
                DisableControlAction(0, 35, true) -- D
                DisableControlAction(0, 21, true) -- SHIFT
                DisableControlAction(0, 44, true) -- Q
                DisableControlAction(0, 20, true) -- Z
                DisableControlAction(0, 19, true) -- ALT
                
                local camCoords = GetCamCoord(freeCamCamera)
                local camRot = GetCamRot(freeCamCamera, 2)
                
                -- Mouse Look
                local mouseX = GetDisabledControlNormal(0, 1)
                local mouseY = GetDisabledControlNormal(0, 2)
                
                local newZ = camRot.z - mouseX * fcOptions.sensitivity
                local newX = math.max(math.min(camRot.x - mouseY * fcOptions.sensitivity, 89.0), -89.0)
                SetCamRot(freeCamCamera, newX, 0.0, newZ, 2)
                
                -- Target Speeds
                local targetSpeed = 0.0
                local targetStrafe = 0.0
                local maxSpeed = fcOptions.normalMaxSpeed
                
                if IsDisabledControlPressed(0, 21) then maxSpeed = fcOptions.fastMaxSpeed end -- Shift
                if IsDisabledControlPressed(0, 19) then maxSpeed = fcOptions.slowMaxSpeed end -- Alt

                if IsDisabledControlPressed(0, 32) then targetSpeed = maxSpeed end -- W
                if IsDisabledControlPressed(0, 33) then targetSpeed = -maxSpeed end -- S (Fixed ID)
                
                if IsDisabledControlPressed(0, 35) then targetStrafe = maxSpeed end -- D (Fixed ID)
                if IsDisabledControlPressed(0, 34) then targetStrafe = -maxSpeed end -- A
                
                -- Smooth Interpolation
                if currentFcSpeed < targetSpeed then
                    currentFcSpeed = math.min(currentFcSpeed + fcOptions.accel, targetSpeed)
                elseif currentFcSpeed > targetSpeed then
                    currentFcSpeed = math.max(currentFcSpeed - fcOptions.decel, targetSpeed)
                end
                
                if currentFcStrafe < targetStrafe then
                    currentFcStrafe = math.min(currentFcStrafe + fcOptions.accel, targetStrafe)
                elseif currentFcStrafe > targetStrafe then
                    currentFcStrafe = math.max(currentFcStrafe - fcOptions.decel, targetStrafe)
                end
                
                -- Calculate Vectors
                local radX = math.rad(newX)
                local radZ = math.rad(newZ)
                
                local forward = vector3(
                    -math.sin(radZ) * math.abs(math.cos(radX)),
                    math.cos(radZ) * math.abs(math.cos(radX)),
                    math.sin(radX)
                )
                local right = vector3(
                    math.cos(radZ),
                    math.sin(radZ),
                    0.0
                )
                
                -- Apply Position
                local newPos = camCoords + (forward * currentFcSpeed) + (right * currentFcStrafe)
                
                -- Vertical (Q/Z)
                local verticalSpeed = 0.0
                if IsDisabledControlPressed(0, 44) then verticalSpeed = maxSpeed end -- Q
                if IsDisabledControlPressed(0, 20) then verticalSpeed = -maxSpeed end -- Z
                newPos = newPos + vector3(0, 0, verticalSpeed * 0.1)
                
                SetCamCoord(freeCamCamera, newPos.x, newPos.y, newPos.z)
                
                -- Hide Player & Focus
                if DoesEntityExist(ped) then
                    SetEntityVisible(ped, false, false)
                    SetEntityCollision(ped, false, false)
                    FreezeEntityPosition(ped, true)
                end
                SetFocusPosAndVel(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)

                -- Instructions
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("WASD + Mouse | Shift/Alt Speed | Q/Z Vertical")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end
            
            -- Cleanup
            ClearFocus()
            local ped = PlayerPedId()
            if DoesEntityExist(ped) then
                if freeCamTpOnExit then
                    local camCoords = GetCamCoord(freeCamCamera)
                    SetEntityCoordsNoOffset(ped, camCoords.x, camCoords.y, camCoords.z, false, false, false)
                end
                SetEntityVisible(ped, true, false)
                SetEntityCollision(ped, true, true)
                FreezeEntityPosition(ped, false)
            end
            
            RenderScriptCams(false, false, 0, true, true)
            DestroyCam(freeCamCamera, false)
            freeCamCamera = nil
        end)
        
    else
        freeCamActive = false
        ShowDynastyNotification("Freecam: ~r~OFF")
    end
end

local noclipActive = false
local noclipSpeed = 1.0

local function ToggleNoclip()
    noclipActive = not noclipActive
    
    if noclipActive then
        Citizen.CreateThread(function()
            local currentSpeed = noclipSpeed
            while noclipActive do
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                local entity = (veh and veh ~= 0) and veh or ped
                
                SetEntityCollision(entity, false, false)
                FreezeEntityPosition(entity, true)
                
                local coords = GetEntityCoords(entity)
                local camRot = GetGameplayCamRot(2)
                
                local pitch = math.rad(camRot.x)
                local yaw = math.rad(camRot.z)
                
                local vx = -math.sin(yaw) * math.abs(math.cos(pitch))
                local vy = math.cos(yaw) * math.abs(math.cos(pitch))
                local vz = math.sin(pitch)
                
                local rx = math.cos(yaw)
                local ry = math.sin(yaw)
                
                -- Determine speed (Shift to sprint)
                local moveSpeed = currentSpeed
                if IsDisabledControlPressed(0, 21) then -- Shift
                    moveSpeed = currentSpeed * 2.5
                end
                
                -- Keyboard / Controller Logic
                local newPos = coords
                
                -- W / D-Pad Up
                if IsDisabledControlPressed(0, 32) then
                    newPos = vector3(newPos.x + vx * moveSpeed, newPos.y + vy * moveSpeed, newPos.z + vz * moveSpeed)
                end
                
                -- S / D-Pad Down
                if IsDisabledControlPressed(0, 33) then
                    newPos = vector3(newPos.x - vx * moveSpeed, newPos.y - vy * moveSpeed, newPos.z - vz * moveSpeed)
                end
                
                -- A / D-Pad Left
                if IsDisabledControlPressed(0, 34) then
                    newPos = vector3(newPos.x - rx * moveSpeed, newPos.y - ry * moveSpeed, newPos.z)
                end
                
                -- D / D-Pad Right
                if IsDisabledControlPressed(0, 35) then
                    newPos = vector3(newPos.x + rx * moveSpeed, newPos.y + ry * moveSpeed, newPos.z)
                end
                
                -- Space / Q (Up)
                if IsDisabledControlPressed(0, 22) then
                    newPos = vector3(newPos.x, newPos.y, newPos.z + moveSpeed)
                end
                
                -- Ctrl / E (Down)
                if IsDisabledControlPressed(0, 36) then
                    newPos = vector3(newPos.x, newPos.y, newPos.z - moveSpeed)
                end
                
                SetEntityCoordsNoOffset(entity, newPos.x, newPos.y, newPos.z, true, true, true)
                
                -- Rotate entity to match camera if it's the ped
                if entity == ped then
                    SetEntityHeading(ped, camRot.z)
                end
                
                Citizen.Wait(0)
            end
            
            -- Cleanup when exiting loop
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            local entity = (veh and veh ~= 0) and veh or ped
            SetEntityCollision(entity, true, true)
            FreezeEntityPosition(entity, false)
        end)
        ShowDynastyNotification("Noclip: ~g~ON")
    else
        ShowDynastyNotification("Noclip: ~r~OFF")
    end
end

local function ChangeFreecamSpeed()
    -- Cycle through normalMaxSpeed values
    if fcOptions.normalMaxSpeed == 2.0 then fcOptions.normalMaxSpeed = 5.0
    elseif fcOptions.normalMaxSpeed == 5.0 then fcOptions.normalMaxSpeed = 12.0
    elseif fcOptions.normalMaxSpeed == 12.0 then fcOptions.normalMaxSpeed = 0.5
    else fcOptions.normalMaxSpeed = 2.0 end
    
    ShowDynastyNotification("Freecam Normal Speed: ~b~" .. fcOptions.normalMaxSpeed)
end

local function ToggleFreecamTp()
    freeCamTpOnExit = not freeCamTpOnExit
    ShowDynastyNotification("TP on Exit: " .. (freeCamTpOnExit and "~g~ON" or "~r~OFF"))
end

local function HealPlayer()
    local ped = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(ped)
    SetEntityHealth(ped, maxHealth)
    ShowDynastyNotification("Player Healed")
end

local function CleanPed()
    ClearPedBloodDamage(PlayerPedId())
    ResetPedVisibleDamage(PlayerPedId())
    ShowDynastyNotification("Ped Cleaned")
end

-- [9. FONCTIONS VEHICLE]
local function FixVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleUndriveable(veh, false)
        SetVehicleEngineOn(veh, true, true, false)
        ShowDynastyNotification("Vehicle Fixed")
    else
        ShowDynastyNotification("~r~Not in vehicle")
    end
end

local function MaxUpgradeVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        
        -- Fix vehicle first
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        
        -- Performance mods only (no cosmetics that change appearance)
        -- Mod 11: Engine
        local engineMods = GetNumVehicleMods(veh, 11)
        if engineMods > 0 then
            SetVehicleMod(veh, 11, engineMods - 1, false)
        end
        
        -- Mod 12: Brakes
        local brakeMods = GetNumVehicleMods(veh, 12)
        if brakeMods > 0 then
            SetVehicleMod(veh, 12, brakeMods - 1, false)
        end
        
        -- Mod 13: Transmission
        local transmissionMods = GetNumVehicleMods(veh, 13)
        if transmissionMods > 0 then
            SetVehicleMod(veh, 13, transmissionMods - 1, false)
        end
        
        -- Mod 15: Suspension
        local suspensionMods = GetNumVehicleMods(veh, 15)
        if suspensionMods > 0 then
            SetVehicleMod(veh, 15, suspensionMods - 1, false)
        end
        
        -- Mod 16: Armor
        local armorMods = GetNumVehicleMods(veh, 16)
        if armorMods > 0 then
            SetVehicleMod(veh, 16, armorMods - 1, false)
        end
        
        -- Mod 0: Spoiler (aileron)
        local spoilerMods = GetNumVehicleMods(veh, 0)
        if spoilerMods > 0 then
            SetVehicleMod(veh, 0, spoilerMods - 1, false)
        end
        
        -- Toggle mods
        ToggleVehicleMod(veh, 18, true)  -- Turbo
        ToggleVehicleMod(veh, 22, true)  -- Xenon Headlights
        
        -- Neon lights (pink)
        SetVehicleNeonLightEnabled(veh, 0, true)  -- Left
        SetVehicleNeonLightEnabled(veh, 1, true)  -- Right
        SetVehicleNeonLightEnabled(veh, 2, true)  -- Front
        SetVehicleNeonLightEnabled(veh, 3, true)  -- Back
        SetVehicleNeonLightsColour(veh, 255, 0, 255)  -- Pink (R, G, B)
        
        -- Max health
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        
        -- Window tint (dark)
        SetVehicleWindowTint(veh, 1)
        
        ShowDynastyNotification("Vehicle: ~g~MAX UPGRADED ~p~(Performance + Style)")
    else
        ShowDynastyNotification("~r~Not in vehicle")
    end
end

local function KickVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local maxSeats = GetVehicleMaxNumberOfPassengers(veh)
        local kickedCount = 0
        
        -- Kick all passengers (not the driver if it's the player)
        for i = -1, maxSeats - 1 do
            local passenger = GetPedInVehicleSeat(veh, i)
            if passenger ~= 0 and passenger ~= ped and DoesEntityExist(passenger) then
                TaskLeaveVehicle(passenger, veh, 4160)  -- 4160 = leave immediately
                kickedCount = kickedCount + 1
            end
        end
        
        if kickedCount > 0 then
            ShowDynastyNotification("~g~Kicked " .. kickedCount .. " passenger(s)")
        else
            ShowDynastyNotification("~y~No passengers to kick")
        end
    else
        ShowDynastyNotification("~r~Not in vehicle")
    end
end

local function ToggleRampVehicle()
    rampVehicleActive = not rampVehicleActive

    if not rampVehicleActive then
        for _, veh in ipairs(rampVehiclesAttached) do
            if DoesEntityExist(veh) then
                DetachEntity(veh, true, true)
            end
        end
        rampVehiclesAttached = {}
        ShowDynastyNotification("Ramp Vehicle: ~r~OFF")
        return
    end

    CreateThread(function()
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then
            rampVehicleActive = false
            ShowDynastyNotification("~r~Not in vehicle")
            return
        end

        local myVehicle = GetVehiclePedIsIn(playerPed, false)
        if not DoesEntityExist(myVehicle) or GetPedInVehicleSeat(myVehicle, -1) ~= playerPed then
            rampVehicleActive = false
            ShowDynastyNotification("~r~Not driver")
            return
        end

        local myCoords = GetEntityCoords(myVehicle)
        local vehicles = {}
        local searchRadius = 100.0
        local vehHandle, veh = FindFirstVehicle()
        local success

        repeat
            local vehCoords = GetEntityCoords(veh)
            local distance = #(myCoords - vehCoords)
            local vehClass = GetVehicleClass(veh)
            if distance <= searchRadius and veh ~= myVehicle and vehClass ~= 8 and vehClass ~= 13 then
                table.insert(vehicles, {handle = veh, distance = distance})
            end
            success, veh = FindNextVehicle(vehHandle)
        until not success
        EndFindVehicle(vehHandle)

        if #vehicles < 3 then
            rampVehicleActive = false
            ShowDynastyNotification("~r~Not enough vehicles nearby")
            return
        end

        table.sort(vehicles, function(a, b) return a.distance < b.distance end)
        local selectedVehicles = {vehicles[1].handle, vehicles[2].handle, vehicles[3].handle}

        local function takeControl(veh)
            SetPedIntoVehicle(playerPed, veh, -1)
            Wait(150)
            SetEntityAsMissionEntity(veh, true, true)
            if NetworkGetEntityIsNetworked(veh) then
                NetworkRequestControlOfEntity(veh)
                local timeout = 0
                while not NetworkHasControlOfEntity(veh) and timeout < 50 do
                    NetworkRequestControlOfEntity(veh)
                    Wait(10)
                    timeout = timeout + 1
                end
            end
        end

        for i = 1, 3 do
            if DoesEntityExist(selectedVehicles[i]) then
                takeControl(selectedVehicles[i])
            end
        end

        SetPedIntoVehicle(playerPed, myVehicle, -1)
        Wait(100)

        local rampPositions = {
            {offsetX = -2.0, offsetY = 2.5, offsetZ = 0.2, rotX = 160.0, rotY = 0.0, rotZ = 0.0},
            {offsetX = 0.0,  offsetY = 2.5, offsetZ = 0.2, rotX = 160.0, rotY = 0.0, rotZ = 0.0},
            {offsetX = 2.0,  offsetY = 2.5, offsetZ = 0.2, rotX = 160.0, rotY = 0.0, rotZ = 0.0},
        }

        rampVehiclesAttached = {}
        for i = 1, 3 do
            if DoesEntityExist(selectedVehicles[i]) then
                local pos = rampPositions[i]
                AttachEntityToEntity(selectedVehicles[i], myVehicle, 0, pos.offsetX, pos.offsetY, pos.offsetZ, pos.rotX, pos.rotY, pos.rotZ, false, false, true, false, 2, true)
                table.insert(rampVehiclesAttached, selectedVehicles[i])
            end
        end

        ShowDynastyNotification("Ramp Vehicle: ~g~ON ~w~(3 vehicles)")
    end)
end

local function ActivateCarry()
    carryActive = true
    ShowDynastyNotification("~g~Carry activé! ~p~E~w~ = Porter/Lancer")

    CreateThread(function()
        while carryActive do
            if not carriedVehicle then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Porter véhicule")
                EndTextCommandDisplayHelp(0, false, true, -1)
            else
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Lancer véhicule")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end

            if IsControlJustPressed(0, KEY_CARRY) then
                if not carriedVehicle then
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)

                    local closestVeh = nil
                    local closestDist = 10.0

                    for _, veh in ipairs(GetGamePool('CVehicle')) do
                        if DoesEntityExist(veh) then
                            local vehCoords = GetEntityCoords(veh)
                            local dist = #(coords - vehCoords)
                            if dist < closestDist then
                                closestDist = dist
                                closestVeh = veh
                            end
                        end
                    end

                    if closestVeh then
                        carriedVehicle = closestVeh
                        AttachEntityToEntity(carriedVehicle, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                        SetEntityCollision(carriedVehicle, false, false)
                        ShowDynastyNotification("~g~Véhicule porté!")
                    else
                        ShowDynastyNotification("~r~Aucun véhicule proche!")
                    end
                else
                    DetachEntity(carriedVehicle, true, true)
                    local ped = PlayerPedId()
                    local forward = GetEntityForwardVector(ped)
                    SetEntityVelocity(carriedVehicle, forward.x * 150, forward.y * 150, 80.0)
                    ApplyForceToEntity(carriedVehicle, 1, 0, 0, 0, math.random(-50, 50), math.random(-50, 50), math.random(-50, 50), 0, false, true, true, false, true)
                    SetEntityCollision(carriedVehicle, true, true)
                    ShowDynastyNotification("~r~🚀 LANCÉ!")
                    carriedVehicle = nil
                end
            end

            Wait(0)
        end

        if carriedVehicle then
            DetachEntity(carriedVehicle, true, true)
            SetEntityCollision(carriedVehicle, true, true)
            carriedVehicle = nil
        end
    end)
end

local function DeactivateCarry()
    carryActive = false
    if carriedVehicle then
        DetachEntity(carriedVehicle, true, true)
        SetEntityCollision(carriedVehicle, true, true)
        carriedVehicle = nil
    end
    ShowDynastyNotification("~r~Carry désactivé!")
end

local function ToggleCarryVehicle()
    if carryActive then
        DeactivateCarry()
    else
        ActivateCarry()
    end
end

local function ToggleEasyHandling()
    easyHandlingActive = not easyHandlingActive

    if easyHandlingActive then
        CreateThread(function()
            while easyHandlingActive do
                Wait(0)
                local ped = PlayerPedId()
                if ped and ped ~= 0 then
                    local veh = GetVehiclePedIsIn(ped, false)
                    if veh and veh ~= 0 then
                        SetVehicleGravityAmount(veh, 73.0)
                        SetVehicleStrong(veh, true)
                    end
                end
            end

            local ped = PlayerPedId()
            if ped and ped ~= 0 then
                local veh = GetVehiclePedIsIn(ped, false)
                if veh and veh ~= 0 then
                    SetVehicleGravityAmount(veh, 9.8)
                    SetVehicleStrong(veh, false)
                end
            end
        end)
        ShowDynastyNotification("Easy Handling: ~g~ON")
    else
        ShowDynastyNotification("Easy Handling: ~r~OFF")
    end
end

local throwCarriedVehicle = nil

local function ToggleThrowVehicle()
    throwVehicleActive = not throwVehicleActive

    if not throwVehicleActive then
        -- Drop carried vehicle if any
        if throwCarriedVehicle and DoesEntityExist(throwCarriedVehicle) then
            DetachEntity(throwCarriedVehicle, true, true)
            SetEntityCollision(throwCarriedVehicle, true, true)
            throwCarriedVehicle = nil
        end
        ShowDynastyNotification("Throw Vehicle: ~r~OFF")
        return
    end

    ShowDynastyNotification("Throw Vehicle: ~g~ON ~w~(E = Pick up / Throw)")

    CreateThread(function()
        while throwVehicleActive do
            Wait(0)

            -- Display help text
            if not throwCarriedVehicle then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Pick up vehicle")
                EndTextCommandDisplayHelp(0, false, true, -1)
            else
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Throw vehicle")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end

            if IsControlJustPressed(0, 51) then -- E Key
                local ped = PlayerPedId()

                if not throwCarriedVehicle then
                    -- PICK UP: find closest vehicle
                    local coords = GetEntityCoords(ped)
                    local closestVeh = nil
                    local closestDist = 10.0

                    for _, veh in ipairs(GetGamePool('CVehicle')) do
                        if DoesEntityExist(veh) then
                            local vehCoords = GetEntityCoords(veh)
                            local dist = #(coords - vehCoords)
                            if dist < closestDist then
                                closestDist = dist
                                closestVeh = veh
                            end
                        end
                    end

                    if closestVeh then
                        NetworkRequestControlOfEntity(closestVeh)
                        throwCarriedVehicle = closestVeh
                        AttachEntityToEntity(throwCarriedVehicle, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                        SetEntityCollision(throwCarriedVehicle, false, false)
                        ShowDynastyNotification("~g~Vehicle picked up!")
                    else
                        ShowDynastyNotification("~r~No vehicle nearby!")
                    end
                else
                    -- THROW: detach and launch forward
                    DetachEntity(throwCarriedVehicle, true, true)
                    local forward = GetEntityForwardVector(ped)
                    SetEntityVelocity(throwCarriedVehicle, forward.x * 150.0, forward.y * 150.0, 80.0)
                    ApplyForceToEntity(throwCarriedVehicle, 1, 0.0, 0.0, 0.0, math.random(-50, 50) + 0.0, math.random(-50, 50) + 0.0, math.random(-50, 50) + 0.0, 0, false, true, true, false, true)
                    SetEntityCollision(throwCarriedVehicle, true, true)
                    ShowDynastyNotification("~r~🚀 THROWN!")
                    throwCarriedVehicle = nil
                end
            end
        end

        -- Cleanup on toggle off
        if throwCarriedVehicle and DoesEntityExist(throwCarriedVehicle) then
            DetachEntity(throwCarriedVehicle, true, true)
            SetEntityCollision(throwCarriedVehicle, true, true)
            throwCarriedVehicle = nil
        end
    end)
end

local function ToggleForceVehicleEngine(enable)
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            local susano = rawget(_G, "Susano")

            if susano and type(susano) == "table" and type(susano.HookNative) == "function" and not _force_engine_hooks_applied then
                _force_engine_hooks_applied = true

                susano.HookNative(0x8DE82BC774F3B862, function(entity)
                    return true
                end)

                susano.HookNative(0x4CEBC1ED31E8925E, function(entity)
                    return true
                end)

                susano.HookNative(0xAE3CBE5BF394C9C9, function(entity)
                    return true
                end)

                susano.HookNative(0x2B40A976, function(entity)
                    return true
                end)

                susano.HookNative(0xAD738C3085FE7E11, function(entity, p1, p2)
                    return true
                end)
            end

            _G.ForceVehicleEngineEnabled = %s

            if _G.ForceVehicleEngineThread then
            end

            _G.ForceVehicleEngineThread = CreateThread(function()
                while _G.ForceVehicleEngineEnabled do
                    Wait(0)

                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)

                    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                        if not NetworkHasControlOfEntity(vehicle) then
                            NetworkRequestControlOfEntity(vehicle)
                        end

                        SetVehicleEngineOn(vehicle, true, true, false)
                        SetVehicleEngineHealth(vehicle, 1000.0)
                        SetVehicleUndriveable(vehicle, false)
                    end
                end

                _G.ForceVehicleEngineThread = nil
            end)
        ]], tostring(enable)))

        forceEngineActive = enable
        if enable then
            ShowDynastyNotification("Force Engine: ~g~ON")
        else
            ShowDynastyNotification("Force Engine: ~r~OFF")
        end
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end

local function ToggleShiftBoost(enable)
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            if QwErTyUiOpSh == nil then QwErTyUiOpSh = false end
            QwErTyUiOpSh = %s

            if QwErTyUiOpSh then
                local function ZxCvBnMmLl()
                    CreateThread(function()
                        while QwErTyUiOpSh and not Unloaded do
                            local ped = PlayerPedId()
                            if IsPedInAnyVehicle(ped, false) then
                                local veh = GetVehiclePedIsIn(ped, false)
                                if veh ~= 0 and IsDisabledControlJustPressed(0, 21) then
                                    SetVehicleForwardSpeed(veh, 150.0)
                                end
                            end
                            Wait(0)
                        end
                    end)
                end
                ZxCvBnMmLl()
            end
        ]], tostring(enable)))

        shiftBoostActive = enable
        if enable then
            ShowDynastyNotification("Shift Boost: ~g~ON ~w~(SHIFT)")
        else
            ShowDynastyNotification("Shift Boost: ~r~OFF")
        end
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end

-- [10. LAUNCH PLAYER - VERSION FORCE MAXIMALE]
-- [10. LAUNCH PLAYER (Former Lunch)]
local lunchingActive = false
local cachedReturnCoords = nil

local function LaunchPlayer()
    if not selectedPlayer then 
        ShowDynastyNotification("~r~No player selected")
        return 
    end

    local targetServerId = selectedPlayer.serverId
    local clientId = GetPlayerFromServerId(targetServerId)

    if not clientId or clientId == -1 then
        ShowDynastyNotification("~r~Player not found")
        return
    end

    local targetPed = GetPlayerPed(clientId)
    if not targetPed or not DoesEntityExist(targetPed) then
        ShowDynastyNotification("~r~Target invalid")
        return
    end

    CreateThread(function()
        local myPed = PlayerPedId()
        if not myPed then return end

        local myCoords = GetEntityCoords(myPed)
        
        -- Safe Return Logic: Only save coords if we aren't already running an action
        if not lunchingActive then
            cachedReturnCoords = myCoords
            lunchingActive = true
        end
        
        -- Use cached coords if available, otherwise fallback to current
        local returnCoords = cachedReturnCoords or myCoords
        local targetCoords = GetEntityCoords(targetPed)

        if returnCoords and targetCoords then
            -- Teleport near target (hidden)
            local angle = math.random() * 2 * math.pi
            local radiusOffset = math.random(5, 9)
            local xOffset = math.cos(angle) * radiusOffset
            local yOffset = math.sin(angle) * radiusOffset
            local newCoords = vector3(targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z)
            
            SetEntityCoordsNoOffset(myPed, newCoords.x, newCoords.y, newCoords.z, false, false, false)
            SetEntityVisible(myPed, false, 0)
            Wait(100)

            -- Teleport to target and attach (BNZ Launch Logic: 10 loops)
            local curTargetCoords = GetEntityCoords(targetPed)
            if curTargetCoords then
                ClearPedTasksImmediately(myPed)
                for i = 1, 10 do
                    if not DoesEntityExist(targetPed) then break end
                    SetEntityCoords(myPed, curTargetCoords.x, curTargetCoords.y, curTargetCoords.z + 0.5, false, false, false, false)
                    Wait(30)
                    AttachEntityToEntityPhysically(myPed, targetPed, 0, 0.0, 0.0, 0.0, 150.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, false, false, 1, 2)
                    Wait(30)
                    DetachEntity(myPed, true, true)
                    Wait(50)
                end
            end

            -- Return to original position (Force return)
            ClearPedTasksImmediately(myPed)
            if returnCoords then
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z + 1.0, false, false, false, false)
                Wait(100)
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z, false, false, false, false)
            end
            SetEntityVisible(myPed, true, 0)
            
            -- Only reset if we are done (simple logic: just reset flag after return)
            lunchingActive = false
            -- We don't clear cachedReturnCoords immediately so if spam happens, it keeps the ground coords? 
            -- Actually better to keep it true during the op. If user spams, the second op uses the same cached coords.
            
            ShowDynastyNotification("~g~Player launched! 🚀")
        end
    end)
end

-- [10.1 LUNCH PLAYER 2 - HARD LAUNCH]
local function LunchPlayer2()
    if not selectedPlayer then 
        ShowDynastyNotification("~r~No player selected")
        return 
    end

    local targetServerId = selectedPlayer.serverId
    local clientId = GetPlayerFromServerId(targetServerId)

    if not clientId or clientId == -1 then
        ShowDynastyNotification("~r~Player not found")
        return
    end

    local targetPed = GetPlayerPed(clientId)
    if not targetPed or not DoesEntityExist(targetPed) then
        ShowDynastyNotification("~r~Target invalid")
        return
    end

    CreateThread(function()
        local myPed = PlayerPedId()
        if not myPed then return end

        local myCoords = GetEntityCoords(myPed)

        -- Safe Return Logic
        if not lunchingActive then
            cachedReturnCoords = myCoords
            lunchingActive = true
        end

        local returnCoords = cachedReturnCoords or myCoords
        local targetCoords = GetEntityCoords(targetPed)

        if returnCoords and targetCoords then
             -- Teleport near target (hidden)
            local angle = math.random() * 2 * math.pi
            local radiusOffset = math.random(5, 9)
            local xOffset = math.cos(angle) * radiusOffset
            local yOffset = math.sin(angle) * radiusOffset
            local newCoords = vector3(targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z)
            
            SetEntityCoordsNoOffset(myPed, newCoords.x, newCoords.y, newCoords.z, false, false, false)
            SetEntityVisible(myPed, false, 0)
            Wait(150)

            -- Teleport to target and attach (Gengar v3 Logic: Single execution - Hard Launch)
            local curTargetCoords = GetEntityCoords(targetPed)
            if curTargetCoords then
                ClearPedTasksImmediately(myPed)
                SetEntityCoords(myPed, curTargetCoords.x, curTargetCoords.y, curTargetCoords.z + 2.0, false, false, false, false)
                Wait(150)
                AttachEntityToEntityPhysically(myPed, targetPed, 0, 0.0, 0.0, 0.0, 50000.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, false, false, 1, 2)
                Wait(250)
                DetachEntity(myPed, true, true)
                Wait(300)
            end

            -- Return to original position
            ClearPedTasksImmediately(myPed)
            if returnCoords then
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z + 1.0, false, false, false, false)
                Wait(100)
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z, false, false, false, false)
            end
            SetEntityVisible(myPed, true, 0)
            
            lunchingActive = false

            ShowDynastyNotification("~g~Gengar Launch executed! 🚀")
        end
    end)
end

-- [11. FONCTIONS ONLINE/TROLL]
local function isPlayerAttached(id)
    if not id then return false end
    if attachedPlayers[id] and DoesEntityExist(attachedPlayers[id]) then
        return true
    else
        if attachedPlayers[id] then
            attachedPlayers[id] = nil
            originalCoords[id] = nil
        end
        return false
    end
end

local function DetachPlayer(id)
    if not id then return end

    if attachedPlayers[id] then
        local ped = attachedPlayers[id]
        if DoesEntityExist(ped) then
            SetEntityCollision(ped, true, true) -- Re-enable collision
        end
        
        if originalCoords[id] then
            local success = pcall(function()
                SetEntityCoords(ped, originalCoords[id].x, originalCoords[id].y, originalCoords[id].z, false, false, false, true)
            end)
            if not success then
                local myCoords = GetEntityCoords(PlayerPedId())
                SetEntityCoords(ped, myCoords.x, myCoords.y, myCoords.z + 2.0, false, false, false, true)
            end
        end
    end

    attachedPlayers[id] = nil 
    originalCoords[id] = nil
    ShowDynastyNotification("Player detached")
end

local function AttachPlayerToMe(id)
    if not id then return end

    local ped = GetPlayerPed(id)
    if DoesEntityExist(ped) then
        if attachedPlayers[id] then
            DetachPlayer(id)
        else
            local coords = GetEntityCoords(ped)
            if coords and coords.x and coords.y and coords.z then
                attachedPlayers[id] = ped
                originalCoords[id] = coords
                
                SetEntityCollision(ped, false, false) -- Disable collision to prevent Sky Launch
                
                -- Attach target to local player (Bone 0 = Root)
                -- Position: 0.5m in front of player
                AttachEntityToEntity(ped, PlayerPedId(), 0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                
                ShowDynastyNotification("Player attached")
            end
        end
    end
end

local function ToggleAttachPlayer()
    if not selectedPlayer then return end

    if isPlayerAttached(selectedPlayer.id) then
        DetachPlayer(selectedPlayer.id)
    else
        AttachPlayerToMe(selectedPlayer.id)
    end
end

-- [12. BLACK HOLE]
local function ToggleBlackHole()
    blackHoleActive = not blackHoleActive

    if not blackHoleActive then
        if _G.black_hole_active then
            _G.black_hole_active = false
            _G.black_hole_vehicles = {}
            _G.black_hole_target_player = nil
        end
        ShowDynastyNotification("Black Hole: ~r~OFF")
        return
    end

    if not selectedPlayer then
        blackHoleActive = false
        ShowDynastyNotification("~r~No player selected")
        return
    end

    local targetPlayerId = selectedPlayer.id
    local targetPed = GetPlayerPed(targetPlayerId)

    if not DoesEntityExist(targetPed) then
        blackHoleActive = false
        ShowDynastyNotification("~r~Target not found")
        return
    end

    CreateThread(function()
        if not _G.black_hole_active then
            _G.black_hole_active = true
            _G.black_hole_vehicles = {}
            _G.black_hole_target_player = targetPlayerId

            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)
            local myHeading = GetEntityHeading(playerPed)

            local blackHoleCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            local camCoords = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            SetCamCoord(blackHoleCam, camCoords.x, camCoords.y, camCoords.z)
            SetCamRot(blackHoleCam, camRot.x, camRot.y, camRot.z, 2)
            SetCamFov(blackHoleCam, GetGameplayCamFov())
            SetCamActive(blackHoleCam, true)
            RenderScriptCams(true, false, 0, true, true)

            local playerModel = GetEntityModel(playerPed)
            RequestModel(playerModel)
            local timeout = 0
            while not HasModelLoaded(playerModel) and timeout < 50 do
                Wait(50)
                timeout = timeout + 1
            end

            local groundZ = myCoords.z
            local rayHandle = StartShapeTestRay(myCoords.x, myCoords.y, myCoords.z + 2.0, myCoords.x, myCoords.y, myCoords.z - 100.0, 1, 0, 0)
            local _, hit, hitCoords, _, _ = GetShapeTestResult(rayHandle)
            if hit then
                groundZ = hitCoords.z
            end

            local clonePed = CreatePed(4, playerModel, myCoords.x, myCoords.y, groundZ, myHeading, false, false)
            SetEntityCollision(clonePed, false, false)
            FreezeEntityPosition(clonePed, true)
            SetEntityInvincible(clonePed, true)
            SetBlockingOfNonTemporaryEvents(clonePed, true)
            SetPedCanRagdoll(clonePed, false)
            ClonePedToTarget(playerPed, clonePed)
            SetEntityVisible(playerPed, false, false)

            local emptyVehicles = {}
            local searchRadius = 1000.0
            local vehHandle, veh = FindFirstVehicle()
            local success

            repeat
                local vehCoords = GetEntityCoords(veh)
                local distance = #(myCoords - vehCoords)
                local vehClass = GetVehicleClass(veh)
                local driver = GetPedInVehicleSeat(veh, -1)
                local isEmpty = (driver == 0 or not DoesEntityExist(driver))

                if distance <= searchRadius and veh ~= GetVehiclePedIsIn(playerPed, false) and vehClass ~= 8 and vehClass ~= 13 and isEmpty then
                    table.insert(emptyVehicles, {handle = veh, distance = distance})
                end

                success, veh = FindNextVehicle(vehHandle)
            until not success

            EndFindVehicle(vehHandle)

            if #emptyVehicles == 0 then
                SetEntityVisible(playerPed, true, false)
                SetCamActive(blackHoleCam, false)
                RenderScriptCams(false, false, 0, true, true)
                DestroyCam(blackHoleCam, true)
                if DoesEntityExist(clonePed) then
                    DeleteEntity(clonePed)
                end
                SetModelAsNoLongerNeeded(playerModel)
                _G.black_hole_active = false
                blackHoleActive = false
                ShowDynastyNotification("~r~No vehicles found")
                return
            end

            table.sort(emptyVehicles, function(a, b) return a.distance < b.distance end)
            while #emptyVehicles > 6 do
                table.remove(emptyVehicles)
            end

            for i, vehData in ipairs(emptyVehicles) do
                local veh = vehData.handle
                if DoesEntityExist(veh) and _G.black_hole_active then
                    SetPedIntoVehicle(playerPed, veh, -1)
                    Wait(150)

                    SetEntityAsMissionEntity(veh, true, true)
                    if NetworkGetEntityIsNetworked(veh) then
                        NetworkRequestControlOfEntity(veh)
                        local timeout = 0
                        while not NetworkHasControlOfEntity(veh) and timeout < 50 do
                            NetworkRequestControlOfEntity(veh)
                            Wait(10)
                            timeout = timeout + 1
                        end
                    end

                    SetEntityCoordsNoOffset(playerPed, myCoords.x, myCoords.y, myCoords.z, false, false, false)
                    SetEntityHeading(playerPed, myHeading)

                    local targetCoords = GetEntityCoords(targetPed)
                    local angle = math.atan2(targetCoords.y - myCoords.y, targetCoords.x - myCoords.x)
                    local spawnX = targetCoords.x - math.cos(angle) * 50.0
                    local spawnY = targetCoords.y - math.sin(angle) * 50.0
                    local spawnZ = targetCoords.z

                    SetEntityCoordsNoOffset(veh, spawnX, spawnY, spawnZ, false, false, false)
                    SetEntityHeading(veh, math.deg(angle))
                    SetEntityVelocity(veh, math.cos(angle) * 50.0, math.sin(angle) * 50.0, 0.0)

                    table.insert(_G.black_hole_vehicles, veh)
                end
            end

            SetEntityVisible(playerPed, true, false)
            SetCamActive(blackHoleCam, false)
            RenderScriptCams(false, false, 0, true, true)
            DestroyCam(blackHoleCam, true)
            if DoesEntityExist(clonePed) then
                DeleteEntity(clonePed)
            end
            SetModelAsNoLongerNeeded(playerModel)

            ShowDynastyNotification("Black Hole: ~g~ON ~w~(" .. #_G.black_hole_vehicles .. " vehicles)")

            CreateThread(function()
                while _G.black_hole_active and blackHoleActive do
                    Wait(0)
                    local targetPed = GetPlayerPed(_G.black_hole_target_player)
                    if DoesEntityExist(targetPed) then
                        local targetCoords = GetEntityCoords(targetPed)
                        for _, veh in ipairs(_G.black_hole_vehicles) do
                            if DoesEntityExist(veh) then
                                local vehCoords = GetEntityCoords(veh)
                                local direction = vector3(targetCoords.x - vehCoords.x, targetCoords.y - vehCoords.y, targetCoords.z - vehCoords.z)
                                local distance = #direction
                                if distance > 0.1 then
                                    direction = direction / distance
                                    SetEntityVelocity(veh, direction.x * 30.0, direction.y * 30.0, direction.z * 5.0)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- [13. STEAL OUTFIT]
local function StealOutfit()
    if not selectedPlayer then
        ShowDynastyNotification("~r~No player selected")
        return
    end

    local targetPlayerId = selectedPlayer.id
    local targetPed = GetPlayerPed(targetPlayerId)

    if not DoesEntityExist(targetPed) then
        ShowDynastyNotification("~r~Target not found")
        return
    end

    local outfit = {
        sex = IsPedMale(targetPed) and 0 or 1,
        face = GetPedDrawableVariation(targetPed, 0),
        skin = GetPedDrawableVariation(targetPed, 1),
        hair_1 = GetPedDrawableVariation(targetPed, 2),
        hair_2 = GetPedTextureVariation(targetPed, 2),
        hair_color_1 = GetPedHairColor(targetPed),
        hair_color_2 = GetPedHairHighlightColor(targetPed),
        tshirt_1 = GetPedDrawableVariation(targetPed, 8),
        tshirt_2 = GetPedTextureVariation(targetPed, 8),
        torso_1 = GetPedDrawableVariation(targetPed, 11),
        torso_2 = GetPedTextureVariation(targetPed, 11),
        arms = GetPedDrawableVariation(targetPed, 3),
        pants_1 = GetPedDrawableVariation(targetPed, 4),
        pants_2 = GetPedTextureVariation(targetPed, 4),
        shoes_1 = GetPedDrawableVariation(targetPed, 6),
        shoes_2 = GetPedTextureVariation(targetPed, 6),
        mask_1 = GetPedDrawableVariation(targetPed, 1),
        mask_2 = GetPedTextureVariation(targetPed, 1),
        helmet_1 = GetPedPropIndex(targetPed, 0),
        helmet_2 = GetPedPropTextureIndex(targetPed, 0),
        bproof_1 = GetPedDrawableVariation(targetPed, 9),
        bproof_2 = GetPedTextureVariation(targetPed, 9),
        bags_1 = GetPedDrawableVariation(targetPed, 5),
        bags_2 = GetPedTextureVariation(targetPed, 5),
        beard_1 = GetPedDrawableVariation(targetPed, 1),
        beard_2 = GetPedTextureVariation(targetPed, 1),
        chain_1 = GetPedDrawableVariation(targetPed, 7),
        chain_2 = GetPedTextureVariation(targetPed, 7),
        glasses_1 = GetPedPropIndex(targetPed, 1),
        glasses_2 = GetPedPropTextureIndex(targetPed, 1),
        decals_1 = GetPedDrawableVariation(targetPed, 10),
        decals_2 = GetPedTextureVariation(targetPed, 10),
        beard_3 = 0,
        beard_4 = 0
    }

    -- Protect player from damage during skin switch (prevents falling/glitch damage)
    local myPed = PlayerPedId()
    local wasInvincible = GetPlayerInvincible(PlayerId())
    SetPlayerInvincible(PlayerId(), true)

    TriggerEvent('skinchanger:loadSkin', outfit)

    CreateThread(function()
        Wait(500) -- Wait for skin to load/apply
        local ped = PlayerPedId()
        SetEntityHealth(ped, GetEntityMaxHealth(ped)) -- Build back health if any lost
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        
        if not wasInvincible then
            SetPlayerInvincible(PlayerId(), false)
        end
    end)

    ShowDynastyNotification("~g~Outfit stolen!")
end

local function ToggleFOVHijack()
    fovHijackActive = not fovHijackActive
    
    if fovHijackActive then
        ShowDynastyNotification("FOV Hijack: ~g~ON~w~ | Press ~p~F11~w~ to change key (" .. fovHijackKeyName .. ")")
        
        -- Create thread for FOV hijack
        CreateThread(function()
            while fovHijackActive do
                Wait(0)
                
                -- Check if configured key is pressed
                if Susano and Susano.GetAsyncKeyState and Susano.GetAsyncKeyState(fovHijackKey) then
                    local playerPed = PlayerPedId()
                    
                    if not IsPedInAnyVehicle(playerPed, false) then
                        local camCoords = GetGameplayCamCoord()
                        local camRot = GetGameplayCamRot(2)
                        
                        -- Calculate direction from camera rotation
                        local fwd = vector3(
                            -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                            math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                            math.sin(math.rad(camRot.x))
                        )
                        
                        local endCoords = camCoords + (fwd * 1000.0)
                        
                        -- Perform raycast
                        local ray = StartShapeTestRay(
                            camCoords.x, camCoords.y, camCoords.z,
                            endCoords.x, endCoords.y, endCoords.z,
                            2, playerPed, 0
                        )
                        
                        local _, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)
                        
                        if hit and entityHit and DoesEntityExist(entityHit) and IsEntityAVehicle(entityHit) then
                            -- Request network control
                            local attempts = 0
                            while not NetworkHasControlOfEntity(entityHit) and attempts < 10 do
                                NetworkRequestControlOfEntity(entityHit)
                                Wait(10)
                                attempts = attempts + 1
                            end
                            
                            -- Kick ALL passengers (driver + all seats)
                            local maxSeats = GetVehicleMaxNumberOfPassengers(entityHit)
                            local kickedCount = 0
                            
                            for seat = -1, maxSeats - 1 do
                                local passenger = GetPedInVehicleSeat(entityHit, seat)
                                if passenger ~= 0 and DoesEntityExist(passenger) then
                                    NetworkRequestControlOfEntity(passenger)
                                    ClearPedTasksImmediately(passenger)
                                    SetEntityAsMissionEntity(passenger, true, true)
                                    SetEntityCoords(passenger, 0.0, 0.0, -100.0, false, false, false, false)
                                    Wait(10)
                                    DeleteEntity(passenger)
                                    kickedCount = kickedCount + 1
                                end
                            end
                            
                            Wait(100)
                            
                            -- Put player in driver seat
                            SetPedIntoVehicle(playerPed, entityHit, -1)
                            ShowDynastyNotification("~g~Vehicle hijacked! ~w~(" .. kickedCount .. " kicked)")
                            
                            Wait(500)
                        end
                    end
                end
            end
        end)
    else
        ShowDynastyNotification("FOV Hijack: ~r~OFF")
    end
end

-- [14. BYPASS PUTIN]
local function BypassPutin()
    if type(Susano) ~= "table" or type(Susano.HttpGet) ~= "function" then
        ShowDynastyNotification("~r~Error: Susano.HttpGet not available")
        return
    end

    ShowDynastyNotification("~y~Loading bypass from GitHub...")

    CreateThread(function()
        local bypassURL = "https://raw.githubusercontent.com/JeanYves22-44/sqd/main/bypass.lua"

        local status, bypassCode = Susano.HttpGet(bypassURL)

        if status ~= 200 or not bypassCode then
            ShowDynastyNotification("~r~Failed to load bypass (Status: " .. tostring(status) .. ")")
            return
        end

        local success, err = pcall(function()
            load(bypassCode)()
        end)

        if success then
            ShowDynastyNotification("~g~Putin bypass loaded successfully!")
        else
            ShowDynastyNotification("~r~Bypass error: " .. tostring(err))
        end
    end)
end

-- [15. RENDU DU MENU - NATIVE RENDERING / SUSANO]

local function SDrawRect(x, y, w, h, r, g, b, a)
    if Susano and Susano.DrawRect then
        -- Try Susano.DrawRect(x, y, w, h, r, g, b, a)
        local ok, err = pcall(Susano.DrawRect, x, y, w, h, r, g, b, a)
        if not ok then
            DrawRect(x, y, w, h, r, g, b, a)
        end
    else
        DrawRect(x, y, w, h, r, g, b, a)
    end
end

local function SDrawText(text, x, y, scale, font, r, g, b, a, center, shadow, outline)
    if Susano and Susano.DrawText then
        -- Try Susano.DrawText with likely params
        local ok, err = pcall(Susano.DrawText, text, x, y, scale, r, g, b, a, font, center, shadow, outline)
        if not ok then
            -- Fallback if failed
            SetTextFont(font)
            SetTextScale(scale, scale)
            SetTextColour(r, g, b, a)
            if center then SetTextCentre(true) end
            if shadow then SetTextDropShadow() end
            if outline then SetTextOutline() end
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandDisplayText(x, y)
        end
    else
        SetTextFont(font)
        SetTextScale(scale, scale)
        SetTextColour(r, g, b, a)
        if center then SetTextCentre(true) end
        if shadow then SetTextDropShadow() end
        if outline then SetTextOutline() end
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(x, y)
    end
end

local function SDrawSprite(dict, name, x, y, w, h, heading, r, g, b, a)
    if Susano and Susano.DrawSprite then
        local ok, err = pcall(Susano.DrawSprite, dict, name, x, y, w, h, heading, r, g, b, a)
        if not ok and HasStreamedTextureDictLoaded(dict) then
            DrawSprite(dict, name, x, y, w, h, heading, r, g, b, a)
        end
    else
        if not HasStreamedTextureDictLoaded(dict) then
            RequestStreamedTextureDict(dict, false)
        end
        if HasStreamedTextureDictLoaded(dict) then
             DrawSprite(dict, name, x, y, w, h, heading, r, g, b, a)
        end
    end
end

local function RenderMenu()
    if not menuOpen and menuAlpha <= 0 then return end

    menuAlpha = menuOpen and math.min(menuAlpha + 20, 255) or math.max(menuAlpha - 20, 0)
    local a = menuAlpha

    local baseX = 0.13
    local menuWidth = 0.22 -- Slightly wider
    local optionHeight = 0.035
    local headerImgHeight = 0.11 -- Space for Gengar logo/Title
    local titleBarHeight = 0.035 -- Merged visually but kept for spacing logic
    local headerTotalHeight = headerImgHeight + titleBarHeight
    local headerTopY = 0.05 -- Moved up slightly

    -- ==========================================
    -- HEADER BACKGROUND (Black)
    -- ==========================================
    local headerCenterY = headerTopY + (headerTotalHeight / 2)
    -- Main black background for entire top section
    SDrawRect(baseX, headerCenterY, menuWidth, headerTotalHeight, 0, 0, 0, math.floor(a * 1.0))

    -- ==========================================
    -- GENGAR LOGO (Placeholder or Texture if available)
    -- ==========================================
    -- Ideally draw sprite here. For now, centered Title text to simulate logo position
    local imgCenterY = headerTopY + (headerImgHeight / 2)
    
    -- If user has a specific dictionary/texture for Gengar, use SDrawSprite here
    -- For now, use large purple text "GENGAR"
    SetTextFont(1)
    SetTextScale(1.1, 1.1)
    SetTextColour(160, 30, 255, a) -- Brighter Purple
    SetTextCentre(true)
    SetTextDropShadow()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("GENGAR") 
    EndTextCommandDisplayText(baseX, imgCenterY - 0.03)

    -- ==========================================
    -- SUBTITLE (Bottom of Header)
    -- ==========================================
    local subtitleY = headerTopY + headerImgHeight + (titleBarHeight / 2) - 0.015
    
    local subtitle = "Main Menu"
    if currentMenu == "PLAYER" then subtitle = "Player"
    elseif currentMenu == "ONLINE" then subtitle = "Online"
    elseif currentMenu == "TROLL" then subtitle = "Troll"
    elseif currentMenu == "COMBAT" then subtitle = "Combat"
    elseif currentMenu == "VEHICLE" then subtitle = "Vehicle"
    elseif currentMenu == "VISUAL" then subtitle = "Visual"
    elseif currentMenu == "MISC" then subtitle = "Miscellaneous"
    elseif currentMenu == "SETTINGS" then subtitle = "Settings"
    end

    SDrawText(subtitle, baseX, subtitleY, 0.35, 4, 200, 200, 200, a, true, false, false)

    -- ==========================================
    -- SEPARATOR LINE (Purple)
    -- ==========================================
    SDrawRect(baseX, headerTopY + headerTotalHeight, menuWidth, 0.002, 140, 0, 255, a)

    -- ==========================================
    -- MENU ITEMS
    -- ==========================================
    local fullList = mainOptions
    if currentMenu == "PLAYER" then fullList = playerOptions
    elseif currentMenu == "ONLINE" then fullList = GetDisplayedPlayerList()
    elseif currentMenu == "COMBAT" then fullList = combatOptions
    elseif currentMenu == "VEHICLE" then fullList = vehicleOptions
    elseif currentMenu == "VISUAL" then fullList = visualOptions
    elseif currentMenu == "MISC" then fullList = miscOptions
    elseif currentMenu == "TROLL" then fullList = trollOptions
    end

    local displayCount = math.min(#fullList, maxDisplay)
    local listTopY = headerTopY + headerTotalHeight + 0.002 -- Start after separator
    local listHeight = displayCount * optionHeight

    -- Draw each option row
    for i = 0, displayCount - 1 do
        local index = startIndex + i
        local data = fullList[index]

        if data then
            local rowCenterY = listTopY + (i * optionHeight) + (optionHeight / 2)
            local isSelected = (selectedOption == index)

            if isSelected then
                -- Vibrant Purple Gradient (Left -> Right)
                -- Left part (Bright)
                SDrawRect(baseX - menuWidth/4, rowCenterY, menuWidth/2, optionHeight, 140, 0, 255, math.floor(a * 0.9))
                -- Right part (Darker)
                SDrawRect(baseX + menuWidth/4, rowCenterY, menuWidth/2, optionHeight, 80, 0, 180, math.floor(a * 0.9))
            else
                -- Pure Black background for unselected
                SDrawRect(baseX, rowCenterY, menuWidth, optionHeight, 0, 0, 0, math.floor(a * 0.9))
            end

            -- Thin separator line at bottom of each row
            if i < displayCount - 1 then
                SDrawRect(baseX, rowCenterY + optionHeight/2, menuWidth, 0.001, 50, 50, 55, math.floor(a * 0.5))
            end

            -- Build label text
            local label = ""
            local hasSubmenu = false
            if currentMenu == "MAIN" then hasSubmenu = true end

            if currentMenu == "PLAYER" and index == 1 then
                label = "Full God Mode " .. (fullGodModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 2 then
                label = "Semi God Mode " .. (semiGodModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 3 then
                label = "Freecam " .. (freeCamActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 4 then
                label = "Freecam Speed: ~b~" .. freeCamSpeed
            elseif currentMenu == "PLAYER" and index == 5 then
                label = "Freecam TP Exit " .. (freeCamTpOnExit and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 7 then
                label = "Solo Session " .. (soloSessionActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 8 then
                label = "Noclip " .. (noclipActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 5 then
                label = "Throw Vehicle " .. (throwVehicleActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 6 then
                label = "Ramp Vehicle " .. (rampVehicleActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 7 then
                label = "Carry Vehicle " .. (carryActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 8 then
                label = "Easy Handling " .. (easyHandlingActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 9 then
                label = "Force Engine " .. (forceEngineActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 10 then
                label = "Shift Boost " .. (shiftBoostActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "TROLL" and index == 2 then
                label = "Launch Player V2"
            elseif currentMenu == "TROLL" and index == 3 then
                local isAttached = selectedPlayer and isPlayerAttached(selectedPlayer.id)
                label = "Attach Player " .. (isAttached and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "TROLL" and index == 4 then
                label = "Black Hole " .. (blackHoleActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "ONLINE" then
                label = string.format("[%d] %s (%dm)", data.serverId, data.name, data.dist)
                hasSubmenu = true
                if data.inVeh then
                    SDrawSprite("commonmenu", "mp_spec_veh", baseX + menuWidth/2 - 0.025, rowCenterY, 0.015, 0.025, 0.0, 255, 255, 255, a)
                end
            else
                label = (type(data) == "table" and data.name or data)
            end

            -- Draw item text
            local textR, textG, textB = 255, 255, 255
            if not isSelected then
                textR, textG, textB = 200, 200, 200
            end

            SDrawText(label, baseX - menuWidth/2 + 0.008, rowCenterY - 0.012, 0.32, 4, textR, textG, textB, a, false, false, false)

            -- Draw right arrow for submenus
            if hasSubmenu then
                SDrawText(">", baseX + menuWidth/2 - 0.015, rowCenterY - 0.012, 0.32, 4, textR, textG, textB, a, false, false, false)
            end
        end
    end

    -- Footer counter if scrollable
    if #fullList > maxDisplay then
        local footerY = listTopY + listHeight + 0.012
        local footerText = string.format("%d / %d", selectedOption, #fullList)
        SDrawText(footerText, baseX, footerY, 0.28, 4, 180, 180, 180, a, true, false, false)
    end

    if currentMenu == "ONLINE" then
        local filterText = onlineFilterVehicles and "~g~Filter: Vehicles Only (E)" or "~w~Filter: All Players (E)"
        SDrawText(filterText, baseX, listTopY + listHeight + 0.035, 0.28, 4, 180, 180, 180, a, true, false, false)
    end
end

-- [16. GESTION DES ACTIONS]
local function HandleMenuSelection()
    if currentMenu == "MAIN" then
        local choice = mainOptions[selectedOption]
        if choice == "Player" then
            currentMenu = "PLAYER"
            selectedOption, startIndex = 1, 1
        elseif choice == "Online" then
            currentMenu = "ONLINE"
            selectedOption, startIndex = 1, 1
        elseif choice == "Combat" then
            currentMenu = "COMBAT"
            selectedOption, startIndex = 1, 1
        elseif choice == "Vehicle" then
            currentMenu = "VEHICLE"
            selectedOption, startIndex = 1, 1
        elseif choice == "Miscellaneous" then
            currentMenu = "MISC"
            selectedOption, startIndex = 1, 1
        end

    elseif currentMenu == "PLAYER" then
        if selectedOption == 1 then
            ToggleFullGodmode(not fullGodModeActive)
        elseif selectedOption == 2 then
            ToggleSemiGodmode(not semiGodModeActive)
        elseif selectedOption == 3 then
            ToggleFreecam()
        elseif selectedOption == 4 then
            ChangeFreecamSpeed()
        elseif selectedOption == 5 then
            ToggleFreecamTp()
        elseif selectedOption == 6 then
            CleanPed()
        elseif selectedOption == 7 then
            SoloSession()
        elseif selectedOption == 8 then
            ToggleNoclip()
        end

    elseif currentMenu == "COMBAT" then
        if selectedOption == 1 then
            GiveAllModdedWeapons()
        elseif selectedOption == 2 then
            RemoveAllWeapons()
        end

    elseif currentMenu == "VEHICLE" then
        if selectedOption == 1 then
            FixVehicle()
        elseif selectedOption == 2 then
            MaxUpgradeVehicle()
        elseif selectedOption == 3 then
            KickVehicle()
        elseif selectedOption == 4 then
            BugVehicle()
        elseif selectedOption == 5 then
            ToggleThrowVehicle()
        elseif selectedOption == 6 then
            ToggleRampVehicle()
        elseif selectedOption == 7 then
            ToggleCarryVehicle()
        elseif selectedOption == 8 then
            ToggleEasyHandling()
        elseif selectedOption == 9 then
            ToggleForceVehicleEngine(not forceEngineActive)
        elseif selectedOption == 10 then
            ToggleShiftBoost(not shiftBoostActive)
        end

    elseif currentMenu == "ONLINE" then
        local list = GetDisplayedPlayerList()
        selectedPlayer = list[selectedOption]
        currentMenu = "TROLL"
        selectedOption, startIndex = 1, 1

    elseif currentMenu == "MISC" then
        if selectedOption == 1 then
            BypassPutin()
        end

    elseif currentMenu == "TROLL" then
        if selectedOption == 1 then
            LaunchPlayer()
        elseif selectedOption == 2 then
            LunchPlayer2() -- Launch V2
        elseif selectedOption == 3 then
            ToggleAttachPlayer()
        elseif selectedOption == 4 then
            ToggleBlackHole()
        elseif selectedOption == 5 then
            StealOutfit()
        elseif selectedOption == 6 then
            ToggleSpectate(not spectateActive)
        elseif selectedOption == 7 then
            KickVehicleSteal()
        elseif selectedOption == 8 then
            BugVehicle()
        elseif selectedOption == 9 then
            TeleportToPlayer()
        end
    end
end

local function HandleBackNavigation()
    if currentMenu == "TROLL" then
        currentMenu = "ONLINE"
    elseif currentMenu ~= "MAIN" then
        currentMenu = "MAIN"
    end
    selectedOption, startIndex = 1, 1
end

local function HandleNavigationUp()
    local navDelay = (currentMenu == "ONLINE") and fastNavDelay or normalNavDelay
    local currentTime = GetGameTimer()
    if currentTime - lastNavTime < navDelay then return end
    lastNavTime = currentTime

    local list = mainOptions
    if currentMenu == "PLAYER" then list = playerOptions
    elseif currentMenu == "ONLINE" then list = GetDisplayedPlayerList()
    elseif currentMenu == "COMBAT" then list = combatOptions
    elseif currentMenu == "VEHICLE" then list = vehicleOptions
    elseif currentMenu == "MISC" then list = miscOptions
    elseif currentMenu == "TROLL" then list = trollOptions
    end

    selectedOption = selectedOption > 1 and selectedOption - 1 or #list
    startIndex = (selectedOption < startIndex) and selectedOption or (selectedOption == #list and math.max(1, #list - maxDisplay + 1) or startIndex)
end

local function HandleNavigationDown()
    local navDelay = (currentMenu == "ONLINE") and fastNavDelay or normalNavDelay
    local currentTime = GetGameTimer()
    if currentTime - lastNavTime < navDelay then return end
    lastNavTime = currentTime

    local list = mainOptions
    if currentMenu == "PLAYER" then list = playerOptions
    elseif currentMenu == "ONLINE" then list = GetDisplayedPlayerList()
    elseif currentMenu == "COMBAT" then list = combatOptions
    elseif currentMenu == "VEHICLE" then list = vehicleOptions
    elseif currentMenu == "MISC" then list = miscOptions
    elseif currentMenu == "TROLL" then list = trollOptions
    end

    selectedOption = selectedOption < #list and selectedOption + 1 or 1
    startIndex = (selectedOption > startIndex + maxDisplay - 1) and startIndex + 1 or (selectedOption == 1 and 1 or startIndex)
end

-- [17. THREAD PRINCIPAL]
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, KEY_OPEN) then
            menuOpen = not menuOpen
        end

        if IsControlJustPressed(0, KEY_REVIVE) then
            QuickRevive()
        end

        DrawDynastyNotify()

        if menuOpen then
            if IsControlPressed(0, KEY_UP) then
                HandleNavigationUp()
            end

            if IsControlPressed(0, KEY_DOWN) then
                HandleNavigationDown()
            end

            if IsControlJustPressed(0, KEY_BACK) then
                HandleBackNavigation()
            end

            if IsControlJustPressed(0, KEY_SELECT) then
                HandleMenuSelection()
            elseif currentMenu == "COMBAT" and IsControlPressed(0, KEY_SELECT) then
                HandleMenuSelection()
            elseif currentMenu == "ONLINE" and IsControlJustPressed(0, KEY_CARRY) then
                onlineFilterVehicles = not onlineFilterVehicles
                selectedOption, startIndex = 1, 1 -- Reset selection to avoid overflow
                ShowDynastyNotification(onlineFilterVehicles and "Filter: ~g~Vehicles Only" or "Filter: ~w~All Players")
            end
        end
    end
end)

-- [17.5 THREAD F11 KEYBIND CONFIGURATION]
CreateThread(function()
    local keyMap = {
        [0x58] = "X", [0x45] = "E", [0x46] = "F", [0x47] = "G",
        [0x42] = "B", [0x56] = "V", [0x48] = "H", [0x4E] = "N",
        [0x51] = "Q", [0x54] = "T", [0x52] = "R", [0x5A] = "Z",
        [0x43] = "C", [0x4D] = "M"
    }
    
    local keys = {0x58, 0x45, 0x46, 0x47, 0x42, 0x56, 0x48, 0x4E, 0x51, 0x54, 0x52, 0x5A, 0x43, 0x4D}
    
    while true do
        Wait(0)
        
        -- F11 = 0x7A
        if IsControlJustPressed(0, 344) or (Susano and Susano.GetAsyncKeyState and Susano.GetAsyncKeyState(0x7A)) then
            if fovHijackActive then
                -- Cycle through keys
                local currentIndex = 1
                for i, key in ipairs(keys) do
                    if key == fovHijackKey then
                        currentIndex = i
                        break
                    end
                end
                
                local nextIndex = (currentIndex % #keys) + 1
                fovHijackKey = keys[nextIndex]
                fovHijackKeyName = keyMap[fovHijackKey] or "?"
                
                ShowDynastyNotification("FOV Hijack Key: ~p~" .. fovHijackKeyName)
                Wait(200)
            end
        end
    end
end)

-- [18. THREAD RENDU]
CreateThread(function()
    while true do
        Wait(0)
        RenderMenu()
    end
end)

-- [19. THREAD ATTACH PLAYERS]
CreateThread(function() 
    while true do 
        Wait(0)
        if next(attachedPlayers) then
            local me = PlayerPedId() 
            if DoesEntityExist(me) then
                local coords = GetEntityCoords(me) 
                local f = GetEntityForwardVector(me)
                for playerId, ped in pairs(attachedPlayers) do
                    if DoesEntityExist(ped) then
                        local success = pcall(function()
                            SetEntityCoordsNoOffset(ped, coords.x + f.x * AK_DIST, coords.y + f.y * AK_DIST, coords.z, true, true, true)
                            SetEntityHeading(ped, GetEntityHeading(me))
                        end)
                        if not success then
                            attachedPlayers[playerId] = nil
                            originalCoords[playerId] = nil
                        end
                    else
                        attachedPlayers[playerId] = nil
                        originalCoords[playerId] = nil
                    end
                end
            end
        end
    end 
end)

-- [20. THREAD DETACH AUTO]
CreateThread(function() 
    while true do 
        Wait(500)
        if next(attachedPlayers) then
            for playerId, ped in pairs(attachedPlayers) do
                if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
                    DetachEntity(ped, true, true)
                    attachedPlayers[playerId] = nil
                    originalCoords[playerId] = nil
                end
            end
        end
    end
end)

-- [21. THREAD CLEAN AUTO]
CreateThread(function()
    while true do
        Wait(1000)
        for playerId, ped in pairs(attachedPlayers) do
            if not NetworkIsPlayerActive(playerId) or not DoesEntityExist(ped) then
                attachedPlayers[playerId] = nil
                originalCoords[playerId] = nil
            end
        end
        for playerId, coords in pairs(originalCoords) do
            if not attachedPlayers[playerId] then
                originalCoords[playerId] = nil
            end
        end
    end
end)

-- FIN - GENGAR MENU v3 COMPLET (100% FONCTIONNEL)
-- Player: Full/Semi God Mode ✅
-- Vehicle: Fix, Ramp, Carry, Easy, Force, Boost ✅
-- Troll: Launch, Attach, Black Hole, Steal Outfit ✅
-- Misc: Bypass Putin ✅
-- Bind X: Revive ✅
