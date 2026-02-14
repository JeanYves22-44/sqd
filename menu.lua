-- GENGAR MENU v2

-- [1. VARIABLES ET ÉTATS]
local menuOpen = false
local menuAlpha = 0
local selectedOption = 1
local startIndex = 1
local maxDisplay = 8
local currentMenu = "MAIN"

local selectedPlayer = nil
local attachedPlayers = {}
local godModeActive = false

-- Variables pour le défilement continu
local lastNavTime = 0
local normalNavDelay = 200   -- Vitesse normale (menus standards)
local fastNavDelay = 120     -- Vitesse rapide (menu Online uniquement)

-- [2. CONFIGURATION DES TOUCHES]
local KEY_OPEN = 57      -- F10
local KEY_SELECT = 191   -- ENTER
local KEY_BACK = 194     -- BACKSPACE
local KEY_UP = 172       -- Flèche HAUT
local KEY_DOWN = 173     -- Flèche BAS
local AK_DIST = 0.75     -- Distance attachement

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
    "God Mode",
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
        
        -- Fond
        DrawRect(x, y, w, h, 10, 10, 10, 225)
        
        -- Barre de progression
        DrawRect(x - (w/2) + (w*progress/2), y - (h/2), w*progress, 0.0015, 100, 0, 180, 255)
        
        -- Titre DYNASTY
        SetTextFont(4)
        SetTextScale(0.3, 0.3)
        SetTextColour(255, 255, 255, 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName("~p~D~w~ DYNASTY")
        EndTextCommandDisplayText(x - w/2 + 0.005, y - h/2 + 0.008)
        
        -- Message
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

-- [6. FONCTIONS GOD MODE]
local function ToggleGodMode()
    godModeActive = not godModeActive
    local ped = PlayerPedId()
    
    if godModeActive then
        SetEntityInvincible(ped, true)
        SetPlayerInvincible(PlayerId(), true)
        SetPedCanRagdoll(ped, false)
        ShowDynastyNotification("God Mode: ~g~Enabled")
    else
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        SetPedCanRagdoll(ped, true)
        ShowDynastyNotification("God Mode: ~r~Disabled")
    end
end

-- Thread de sécurité pour maintenir le God Mode
CreateThread(function()
    while true do
        Wait(500)
        if godModeActive then
            local ped = PlayerPedId()
            SetEntityInvincible(ped, true)
            SetPlayerInvincible(PlayerId(), true)
        end
    end
end)

-- [7. FONCTIONS PLAYER]
local function HealPlayer()
    SetEntityHealth(PlayerPedId(), 200)
    ShowDynastyNotification("Player Healed")
end

local function CleanPed()
    ClearPedBloodDamage(PlayerPedId())
    ShowDynastyNotification("Ped Cleaned")
end

-- [8. FONCTIONS MISCELLANEOUS]
local function BypassPutin()
    ShowDynastyNotification("Putin has been bypassed : Moderne")
end

-- [9. FONCTIONS TROLL/ONLINE]
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

-- [10. RENDU DU MENU]
local function RenderMenu()
    if not menuOpen and menuAlpha <= 0 then return end
    
    -- Animation du menu
    menuAlpha = menuOpen and math.min(menuAlpha + 20, 255) or math.max(menuAlpha - 20, 0)
    
    local baseX = 0.15
    local baseY = 0.20
    local menuWidth = 0.20
    local optionHeight = 0.038
    local startY = baseY + 0.075 + (optionHeight / 2)

    -- Fond du menu
    DrawRect(baseX, baseY, menuWidth, 0.15, 0, 0, 0, 255)
    
    -- Logo
    DrawSprite("gengar_menu", "logo", baseX, baseY - 0.02, 0.08, 0.12, 0.0, 255, 255, 255, math.floor(menuAlpha))
    
    -- Titre du menu
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

    -- Récupération de la liste d'options
    local fullList = mainOptions
    if currentMenu == "PLAYER" then fullList = playerOptions
    elseif currentMenu == "ONLINE" then fullList = getNearbyPlayers()
    elseif currentMenu == "COMBAT" then fullList = combatOptions
    elseif currentMenu == "VEHICLE" then fullList = vehicleOptions
    elseif currentMenu == "MISC" then fullList = miscOptions
    elseif currentMenu == "TROLL" then fullList = trollOptions
    end
    
    local displayCount = math.min(#fullList, maxDisplay)

    -- Affichage des options
    for i = 0, displayCount - 1 do
        local index = startIndex + i
        local data = fullList[index]
        
        if data then
            local currentY = startY + (i * optionHeight)
            local isSelected = (selectedOption == index)
            
            -- Fond de l'option
            DrawRect(baseX, currentY, menuWidth, optionHeight,
                isSelected and 100 or 0,
                isSelected and 0 or 0,
                isSelected and 180 or 0,
                220)
            
            -- Label de l'option
            local label = ""
            
            if currentMenu == "PLAYER" and index == 1 then
                label = "God Mode " .. (godModeActive and "~g~[ON]" or "~r~[OFF]")
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

-- [11. GESTION DES ACTIONS DU MENU]
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
            ToggleGodMode()
        elseif selectedOption == 2 then
            HealPlayer()
        elseif selectedOption == 3 then
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
    -- Déterminer la vitesse selon le menu
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
    -- Déterminer la vitesse selon le menu
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

-- [12. THREAD PRINCIPAL - CONTRÔLES]
CreateThread(function()
    while true do
        Wait(0)
        
        -- Toggle menu
        if IsControlJustPressed(0, KEY_OPEN) then
            menuOpen = not menuOpen
        end
        
        -- Affichage des notifications
        DrawDynastyNotify()
        
        if menuOpen then
            -- Navigation HAUT (appui simple ou maintien)
            if IsControlPressed(0, KEY_UP) then
                HandleNavigationUp()
            end
            
            -- Navigation BAS (appui simple ou maintien)
            if IsControlPressed(0, KEY_DOWN) then
                HandleNavigationDown()
            end
            
            -- Touche RETOUR
            if IsControlJustPressed(0, KEY_BACK) then
                HandleBackNavigation()
            end
            
            -- Touche SÉLECTION
            if IsControlJustPressed(0, KEY_SELECT) then
                HandleMenuSelection()
            end
        end
    end
end)

-- [13. THREAD - RENDU VISUEL]
CreateThread(function()
    while true do
        Wait(0)
        RenderMenu()
    end
end)

-- [14. THREAD - GESTION DES JOUEURS ATTACHÉS]
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

-- FIN DU SCRIPT
