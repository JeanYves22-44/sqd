local function ToggleFullGodmode(enable)
    if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
        print("^1[Godmode]^0 Susano not available")
        return
    end

    local code = string.format([[
        if _G.FullGodmodeEnabled == nil then _G.FullGodmodeEnabled = false end
        _G.FullGodmodeEnabled = %s

        if _G.FullGodmodeEnabled and not _G.FullGodmodeLoopStarted then
            _G.FullGodmodeLoopStarted = true

            Citizen.CreateThread(function()
                while _G.FullGodmodeEnabled do
                    Wait(0)
                    local ped = PlayerPedId()
                    if ped and ped ~= 0 and DoesEntityExist(ped) then
                        local maxHealth = GetEntityMaxHealth(ped)
                        SetEntityHealth(ped, maxHealth)
                    end
                end
                _G.FullGodmodeLoopStarted = false
            end)
        end
    ]], tostring(enable))

    Susano.InjectResource("any", code)
    print("^2[Godmode]^0 Full Godmode: " .. (enable and "^2✓ ACTIVÉ^0" or "^1✗ DÉSACTIVÉ^0"))
end

local function ToggleSemiGodmode(enable)
    if type(Susano) ~= "table" or type(Susano.InjectResource) ~= "function" then
        print("^1[Godmode]^0 Susano not available")
        return
    end

    local code = string.format([[
        if _G.SemiGodmodeEnabled == nil then _G.SemiGodmodeEnabled = false end
        _G.SemiGodmodeEnabled = %s

        if _G.SemiGodmodeEnabled and not _G.SemiGodmodeLoopStarted then
            _G.SemiGodmodeLoopStarted = true
            _G.LastHealth = nil

            -- Regen lente
            Citizen.CreateThread(function()
                while _G.SemiGodmodeEnabled do
                    Wait(200)
                    local ped = PlayerPedId()
                    if ped and ped ~= 0 and DoesEntityExist(ped) then
                        local currentHealth = GetEntityHealth(ped)
                        local maxHealth = GetEntityMaxHealth(ped)

                        if currentHealth < maxHealth then
                            SetEntityHealth(ped, currentHealth + 3)
                        end
                        _G.LastHealth = currentHealth
                    end
                end
                _G.SemiGodmodeLoopStarted = false
            end)

            -- Regen rapide sur dégâts
            Citizen.CreateThread(function()
                while _G.SemiGodmodeEnabled do
                    Wait(10)
                    local ped = PlayerPedId()
                    if ped and ped ~= 0 and DoesEntityExist(ped) then
                        local currentHealth = GetEntityHealth(ped)
                        local maxHealth = GetEntityMaxHealth(ped)

                        if _G.LastHealth and currentHealth < _G.LastHealth then
                            local damageTaken = _G.LastHealth - currentHealth
                            if damageTaken > 10 then
                                SetEntityHealth(ped, maxHealth)
                            end
                        end

                        if currentHealth < (maxHealth * 0.5) then
                            SetEntityHealth(ped, maxHealth)
                        end

                        _G.LastHealth = currentHealth
                    end
                end
                _G.SemiGodmodeLoopStarted = false
            end)
        end
    ]], tostring(enable))

    Susano.InjectResource("any", code)
    print("^2[Godmode]^0 Semi Godmode: " .. (enable and "^2✓ ACTIVÉ^0" or "^1✗ DÉSACTIVÉ^0"))
end

-- ============================================
-- KEYBIND GODMODE - TOUCHE H (74)
-- ============================================

CreateThread(function()
    while true do
        Wait(0)
        
        -- Touche H = 74
        if IsControlJustPressed(0, 74) then
            if _G.FullGodmodeEnabled then
                _G.FullGodmodeEnabled = false
                print("^1[Godmode]^0 DÉSACTIVÉ (H)")
                ToggleFullGodmode(false)
            else
                _G.FullGodmodeEnabled = true
                print("^2[Godmode]^0 ACTIVÉ (H)")
                ToggleFullGodmode(true)
            end
        end
    end
end)

-- ============================================
-- SETUP - Attendre que Menu soit chargé
-- ============================================

CreateThread(function()
    while not _G.Menu or not _G.Menu.Categories do
        Wait(100)
    end
    
    Wait(500)
    
    local function FindItem(categoryName, tabName, itemName)
        if not _G.Menu or not _G.Menu.Categories then return nil end

        for _, cat in ipairs(_G.Menu.Categories) do
            if cat and cat.name == categoryName and cat.tabs then
                for _, tab in ipairs(cat.tabs) do
                    if tab and tab.name == tabName and tab.items then
                        for _, item in ipairs(tab.items) do
                            if item and item.name == itemName then
                                return item
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
    
    -- Godmode
    local godmodeItem = FindItem("Player", "Self", "Godmode")
    if godmodeItem then
        godmodeItem.onClick = function(value)
            _G.FullGodmodeEnabled = value
            ToggleFullGodmode(value)
        end
        print("^2[Godmode]^0 Full Godmode loaded ✓ (Menu + H)")
    end
    
    -- Semi Godmode
    local semiGodmodeItem = FindItem("Player", "Self", "Semi Godmode")
    if semiGodmodeItem then
        semiGodmodeItem.onClick = function(value)
            _G.SemiGodmodeEnabled = value
            ToggleSemiGodmode(value)
        end
        print("^2[Godmode]^0 Semi Godmode loaded ✓")
    end
    
    print("^5[Godmode]^0 Appuie sur H pour toggle rapide!")
end)
