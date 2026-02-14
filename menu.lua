-- GENGAR MENU v2 - CODE NOBLAZ + BYPASS GITHUB

-- [1. VARIABLES ET ÉTATS]
local menuOpen = false
local menuAlpha = 0
local selectedOption = 1
local startIndex = 1
local maxDisplay = 8
local currentMenu = "MAIN"

local selectedPlayer = nil
local attachedPlayers = {}
local fullGodModeActive = false
local semiGodModeActive = false
local putinBypassed = false

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
local AK_DIST = 0.75

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
    "Easy Handling",
    "Ramp Vehicle"
}

local miscOptions = {
    "Bypass Putin"
}

local trollOptions = {
    "Launch Player",
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
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)

    if currentHealth > 0 and currentHealth < maxHealth then
        local healAmount = math.min(50, maxHealth - currentHealth)
        SetEntityHealth(ped, currentHealth + healAmount)

        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)

        ShowDynastyNotification("~g~+50 HP")
    end
end

-- [6. FULL GOD MODE - CODE EXACT DE NOBLAZ]
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

            susano.HookNative(0xFAEE099C6F890BB8, function(entity, toggle)
                if _G.FullGodmodeEnabled and entity == PlayerPedId() then
                    if not toggle then
                        return false
                    end
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

            susano.HookNative(0x7C6BCA42, function(ped, toggle)
                if _G.FullGodmodeEnabled and ped == PlayerPedId() then
                    if toggle then
                        return false
                    end
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
                            local currentHealth = GetEntityHealth(ped)

                            if currentHealth < maxHealth then
                                SetEntityHealth(ped, maxHealth)
                            end

                            SetEntityInvincible(ped, true)
                            SetPlayerInvincible(PlayerId(), true)
                            SetPedCanRagdoll(ped, false)
                        end
                    else
                        local ped = PlayerPedId()
                        if DoesEntityExist(ped) then
                            SetEntityInvincible(ped, false)
                            SetPlayerInvincible(PlayerId(), false)
                            SetPedCanRagdoll(ped, true)
                        end
                    end
                end
            end)
        end
    ]], tostring(enable))

    Susano.InjectResource("any", code)

    if enable then
        ShowDynastyNotification("Full Godmode: ~g~ON ~w~(Press ~b~X~w~ to heal)")
    else
        ShowDynastyNotification("Full Godmode: ~r~OFF")
    end
end

-- [7. SEMI GOD MODE - CODE EXACT DE NOBLAZ]
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

            susano.HookNative(0xFAEE099C6F890BB8, function(entity, toggle)
                if _G.SemiGodmodeEnabled and entity == PlayerPedId() then
                    if not toggle then
                        return false
                    end
                end
                return true
            end)

            susano.HookNative(0x697157CED63F18D4, function(ped, damage, armorDamage)
                if _G.SemiGodmodeEnabled and ped == PlayerPedId() then
                    if damage > 20 then
                        return false
                    end
                end
                return true
            end)

            susano.HookNative(0x6B76DC1F3AE6E6A3, function(entity, health)
                if _G.SemiGodmodeEnabled and entity == PlayerPedId() then
                    local currentHealth = GetEntityHealth(entity)
                    if health < currentHealth - 20 then
                        return false
                    end
                end
                return true
            end)

            susano.HookNative(0x7C6BCA42, function(ped, toggle)
                if _G.SemiGodmodeEnabled and ped == PlayerPedId() then
                    if toggle then
                        return false
                    end
                end
                return true
            end)
        end

        if not _G.SemiGodmodeLoopStarted then
            _G.SemiGodmodeLoopStarted = true
            _G.LastHealth = nil

            Citizen.CreateThread(function()
                while true do
                    Wait(200)
                    if _G.SemiGodmodeEnabled then
                        local ped = PlayerPedId()
                        if DoesEntityExist(ped) then
                            local currentHealth = GetEntityHealth(ped)
                            local maxHealth = GetEntityMaxHealth(ped)

                            if currentHealth < maxHealth and currentHealth > 0 then
                                local regenAmount = math.min(3, maxHealth - currentHealth)
                                SetEntityHealth(ped, currentHealth + regenAmount)
                            end

                            if math.random(1, 10) == 1 then
                                ClearPedBloodDamage(ped)
                                ResetPedVisibleDamage(ped)
                            end

                            _G.LastHealth = currentHealth
                        end
                    end
                end
            end)

            Citizen.CreateThread(function()
                while true do
                    Wait(10)
                    if _G.SemiGodmodeEnabled then
                        local ped = PlayerPedId()
                        if DoesEntityExist(ped) then
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

                            if currentHealth < (maxHealth * 0.8) and currentHealth > 0 then
                                local regenAmount = math.min(15, maxHealth - currentHealth)
                                SetEntityHealth(ped, currentHealth + regenAmount)
                            end

                            if currentHealth < (maxHealth * 0.5) and currentHealth > 0 then
                                SetEntityHealth(ped, maxHealth)
                            end

                            _G.LastHealth = currentHealth
                        end
                    else
                        _G.LastHealth = nil
                    end
                end
            end)
        end
    ]], tostring(enable))

    Susano.InjectResource("any", code)

    if enable then
        ShowDynastyNotification("Semi Godmode: ~g~ON ~w~(Press ~b~X~w~ to heal)")
    else
        ShowDynastyNotification("Semi Godmode: ~r~OFF")
    end
end

-- [8. BYPASS PUTIN - CHARGÉ DEPUIS GITHUB]
local function BypassPutin()
    if type(Susano) ~= "table" or type(Susano.HttpGet) ~= "function" then
        ShowDynastyNotification("~r~Error: Susano.HttpGet not available")
        return
    end

    if putinBypassed then
        ShowDynastyNotification("~y~Putin already bypassed!")
        return
    end

    ShowDynastyNotification("~y~Loading bypass from GitHub...")

    CreateThread(function()
        local bypassURL = "https://raw.githubusercontent.com/JeanYves22-44/sqd/main/bypass.lua"
        local status, bypassCode = Susano.HttpGet(bypassURL)

        if status ~= 200 or not bypassCode then
            ShowDynastyNotification("~r~Failed to load bypass (HTTP " .. tostring(status) .. ")")
            return
        end

        -- Exécute le code du bypass
        local success, err = pcall(function()
            load(bypassCode)()
        end)

        if success then
            putinBypassed = true
            ShowDynastyNotification("~g~Putin bypassed! (from GitHub)")
        else
            ShowDynastyNotification("~r~Bypass error: " .. tostring(err))
        end
    end)
end

-- [9. FONCTIONS PLAYER]
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

-- [10. FONCTIONS TROLL/ONLINE]
local function ToggleAttachPlayer()
    if not selectedPlayer then return end

    if attachedPlayers[selectedPlayer.id] then
        attachedPlayers[selectedPlayer.id] = nil
        ShowDynastyNotification("Player detached")
    else
        attachedPlayers[selectedPlayer.id] = GetPlayerPed(selectedPlayer.id)
        ShowDynastyNotification("Player attached")
    end
end

-- [11. RENDU DU MENU]
local function RenderMenu()
    if not menuOpen and menuAlpha <= 0 then return end

    menuAlpha = menuOpen and math.min(menuAlpha + 20, 255) or math.max(menuAlpha - 20, 0)

    local baseX = 0.15
    local baseY = 0.20
    local menuWidth = 0.20
    local optionHeight = 0.038
    local startY = baseY + 0.075 + (optionHeight / 2)

    DrawRect(baseX, baseY, menuWidth, 0.15, 0, 0, 0, 255)
    DrawSprite("gengar_menu", "logo", baseX, baseY - 0.02, 0.08, 0.12, 0.0, 255, 255, 255, math.floor(menuAlpha))

    local title = "Main Menu"
    if currentMenu == "PLAYER" then title = "Player"
    elseif currentMenu == "ONLINE" then 
        local nearbyPlayers = getNearbyPlayers()
        title = string.format("Online (~g~%d~w~ players)", #nearbyPlayers)
    elseif currentMenu == "TROLL" then title = "Troll Menu"
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
            elseif currentMenu == "MISC" and index == 1 then
                label = "Bypass Putin " .. (putinBypassed and "~g~[BYPASSED]" or "")
            elseif currentMenu == "ONLINE" then
                label = string.format("[%d] %s (%dm)", data.serverId, data.name, data.dist)
            elseif currentMenu == "TROLL" and index == 2 then
                local isAttached = selectedPlayer and attachedPlayers[selectedPlayer.id]
                label = "Attach Player " .. (isAttached and "~g~[ON]" or "~r~[OFF]")
            else
                label = (type(data) == "table" and data.name or data)
            end

            DrawTextCustom(label, baseX - menuWidth/2 + 0.008, currentY - 0.012, 0.32, 0, 255, 255, 255, 255, false)
        end
    end
end

-- [12. GESTION DES ACTIONS DU MENU]
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
        if selectedOption == 2 then
            ToggleAttachPlayer()
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

-- [13. THREAD PRINCIPAL - CONTRÔLES]
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, KEY_OPEN) then
            menuOpen = not menuOpen
        end

        if (fullGodModeActive or semiGodModeActive) and IsControlJustPressed(0, KEY_REVIVE) then
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

-- [14. THREAD - RENDU VISUEL]
CreateThread(function()
    while true do
        Wait(0)
        RenderMenu()
    end
end)

-- [15. THREAD - GESTION DES JOUEURS ATTACHÉS]
CreateThread(function()
    while true do
        Wait(0)

        for playerId, ped in pairs(attachedPlayers) do
            if DoesEntityExist(ped) then
                local myCoords = GetEntityCoords(PlayerPedId())
                local forward = GetEntityForwardVector(PlayerPedId())

                SetEntityCoordsNoOffset(
                    ped,
                    myCoords.x + forward.x * AK_DIST,
                    myCoords.y + forward.y * AK_DIST,
                    myCoords.z,
                    true, true, true
                )

                SetEntityHeading(ped, GetEntityHeading(PlayerPedId()))
            else
                attachedPlayers[playerId] = nil
            end
        end
    end
end)

-- FIN DU SCRIPT - GENGAR MENU v2 (BYPASS GITHUB)
