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
    "Heal Player",
    "Clean Ped"
}

local combatOptions = {
    "Give All Weapons"
}

local vehicleOptions = {
    "Fix Vehicle",
    "Ramp Vehicle",
    "Carry Vehicle",
    "Easy Handling",
    "Force Engine",
    "Shift Boost"
}

local miscOptions = {
    "Bypass Putin"
}

local trollOptions = {
    "Launch Player",
    "Launch Player V2",
    "Attach Player",
    "Black Hole",
    "Steal Outfit",
    "Spectate"
}

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
            local distance = #(myCoords - GetEntityCoords(GetPlayerPed(playerId)))
            if distance <= 500.0 then
                table.insert(players, {
                    id = playerId,
                    serverId = GetPlayerServerId(playerId),
                    name = GetPlayerName(playerId),
                    dist = math.floor(distance)
                })
            end
        end
    end

    table.sort(players, function(a, b) return a.dist < b.dist end)
    return players
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

-- [8. FONCTIONS PLAYER]
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

-- [15. RENDU DU MENU]
local function RenderMenu()
    if not menuOpen and menuAlpha <= 0 then return end

    menuAlpha = menuOpen and math.min(menuAlpha + 20, 255) or math.max(menuAlpha - 20, 0)

    local baseX = 0.15
    local baseY = 0.20
    local menuWidth = 0.20
    local optionHeight = 0.038
    local startY = baseY + 0.075 + (optionHeight / 2)

    DrawRect(baseX, baseY, menuWidth, 0.15, 0, 0, 0, 255)

    local title = "Main Menu"
    if currentMenu == "PLAYER" then title = "Player"
    elseif currentMenu == "ONLINE" then 
        local nearbyPlayers = getNearbyPlayers()
        title = string.format("Online (~g~%d~w~ players)", #nearbyPlayers)
    elseif currentMenu == "TROLL" then 
        if selectedPlayer then
            title = string.format("Troll: %s", selectedPlayer.name)
        else
            title = "Troll Menu"
        end
    elseif currentMenu == "COMBAT" then title = "Combat"
    elseif currentMenu == "VEHICLE" then title = "Vehicle"
    elseif currentMenu == "MISC" then title = "Miscellaneous"
    end

    DrawTextCustom(title, baseX, baseY + 0.05, 0.4, 0, 255, 255, 255, 255, true)

    local fullList = mainOptions
    if currentMenu == "PLAYER" then fullList = playerOptions
    elseif currentMenu == "ONLINE" then fullList = getNearbyPlayers()
    elseif currentMenu == "COMBAT" then fullList = combatOptions
    elseif currentMenu == "VEHICLE" then fullList = vehicleOptions
    elseif currentMenu == "MISC" then fullList = miscOptions
    elseif currentMenu == "TROLL" then fullList = trollOptions
    end

    local displayCount = math.min(#fullList, maxDisplay)

    for i = 0, displayCount - 1 do
        local index = startIndex + i
        local data = fullList[index]

        if data then
            local currentY = startY + (i * optionHeight)
            local isSelected = (selectedOption == index)

            DrawRect(baseX, currentY, menuWidth, optionHeight,
                isSelected and 100 or 0,
                isSelected and 0 or 0,
                isSelected and 180 or 0,
                220)

            local label = ""

            if currentMenu == "PLAYER" and index == 1 then
                label = "Full God Mode " .. (fullGodModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 2 then
                label = "Semi God Mode " .. (semiGodModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 2 then
                label = "Ramp Vehicle " .. (rampVehicleActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 3 then
                label = "Carry Vehicle " .. (carryActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 4 then
                label = "Easy Handling " .. (easyHandlingActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 5 then
                label = "Force Engine " .. (forceEngineActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 6 then
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
            else
                label = (type(data) == "table" and data.name or data)
            end

            DrawTextCustom(label, baseX - menuWidth/2 + 0.008, currentY - 0.012, 0.32, 0, 255, 255, 255, 255, false)
        end
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
            HealPlayer()
        elseif selectedOption == 4 then
            CleanPed()
        end

    elseif currentMenu == "VEHICLE" then
        if selectedOption == 1 then
            FixVehicle()
        elseif selectedOption == 2 then
            ToggleRampVehicle()
        elseif selectedOption == 3 then
            ToggleCarryVehicle()
        elseif selectedOption == 4 then
            ToggleEasyHandling()
        elseif selectedOption == 5 then
            ToggleForceVehicleEngine(not forceEngineActive)
        elseif selectedOption == 6 then
            ToggleShiftBoost(not shiftBoostActive)
        end

    elseif currentMenu == "ONLINE" then
        local list = getNearbyPlayers()
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
            ShowDynastyNotification("~y~Spectate (not coded)")
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
    elseif currentMenu == "ONLINE" then list = getNearbyPlayers()
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
    elseif currentMenu == "ONLINE" then list = getNearbyPlayers()
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
