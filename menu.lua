-- ============================================
-- MENU LOADER - VERSION CORRIGÉE
-- ============================================

-- Vérification Susano (AVANT tout)
if not Susano or type(Susano) ~= "table" or type(Susano.HttpGet) ~= "function" then
    print("^1[Menu ERROR]^0 Susano not available")
    return
end

-- Éviter les chargements multiples
if _G.MenuAlreadyLoaded then
    print("^3[Menu]^0 Menu already loaded, skipping...")
    return
end
_G.MenuAlreadyLoaded = true

print("^5[Menu]^0 Initialization starting...")

-- ============================================
-- TABLE MENU GLOBALE
-- ============================================

_G.Menu = {
    Visible = false,
    SelectedPlayer = nil,
    SelectedPlayers = {},
    Categories = {},
    FOVWarp = false,
    WarpPressW = false,
    shooteyesEnabled = false,
    silentAimEnabled = false,
    magicbulletEnabled = false,
    superPunchEnabled = false,
    PlayerListSpectateEnabled = false,
    PlayerListTypeIndex = 0,
    KeybindsPositionMode = 0,
    PreventResetFrame = false,
    unlockAllVehicleEnabled = false,
}

local Menu = _G.Menu

-- ============================================
-- NATIVES FALLBACK (Éviter les crashes)
-- ============================================

if type(GetEntityScript) ~= "function" then 
    GetEntityScript = function() return nil end 
end

if type(IsEntityGhostedToLocalPlayer) ~= "function" then 
    IsEntityGhostedToLocalPlayer = function() return false end 
end

if type(GetScreenCoordFromWorldCoord) ~= "function" then
    GetScreenCoordFromWorldCoord = function(x, y, z)
        if World3dToScreen2d then
            return World3dToScreen2d(x, y, z)
        end
        return false, 0, 0
    end
end

-- Wrapper ipairs sécurisé
local _ipairs = ipairs
ipairs = function(t)
    if type(t) ~= "table" then 
        return function() end 
    end
    return _ipairs(t)
end

-- ============================================
-- STRUCTURE DU MENU
-- ============================================

Menu.Categories = {
    { name = "Main Menu", icon = "P" },
    { name = "Player", icon = "👤", hasTabs = true, tabs = {
        { name = "Self", items = {
            { name = "Godmode", type = "toggle", value = false },
            { name = "Revive", type = "action" },
            { name = "Max Health", type = "action" },
            { name = "Max Armor", type = "action" },
            { name = "Detach All Entitys", type = "action" },
            { name = "TP all vehicle to me", type = "action" },
            { name = "Solo Session", type = "toggle", value = false },
            { name = "Throw Vehicle", type = "toggle", value = false },
            { name = "Tiny Player", type = "toggle", value = false },
            { name = "Infinite Stamina", type = "toggle", value = false }
        }},
        { name = "Movement", items = {
            { name = "Noclip", type = "toggle", value = false, hasSlider = true, sliderValue = 1.0, sliderMin = 1.0, sliderMax = 20.0 },
            { name = "Fast Run", type = "toggle", value = false },
            { name = "No Ragdoll", type = "toggle", value = false }
        }}
    }},
    { name = "Vehicle", icon = "🚗", hasTabs = true, tabs = {
        { name = "Spawn", items = {
            { name = "Teleport Into", type = "toggle", value = false }
        }},
        { name = "Performance", items = {
            { name = "Max Upgrade", type = "action" },
            { name = "Repair Vehicle", type = "action" },
            { name = "Delete Vehicle", type = "action" }
        }}
    }},
    { name = "Visual", icon = "👁", hasTabs = true, tabs = {
        { name = "ESP", items = {
            { name = "Enable Player ESP", type = "toggle", value = false }
        }}
    }},
    { name = "Settings", icon = "⚙", hasTabs = true, tabs = {
        { name = "General", items = {
            { name = "Menu Visible", type = "toggle", value = false }
        }}
    }}
}

-- ============================================
-- FONCTIONS DE BASE DU MENU
-- ============================================

function Menu.ActionRevive()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetEntityHealth(ped, 200)
    print("^2[Menu]^0 Revived")
end

function Menu.ActionMaxHealth()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    SetEntityHealth(ped, 200)
    print("^2[Menu]^0 Max Health activated")
end

function Menu.ActionMaxArmor()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    SetPedArmour(ped, 100)
    print("^2[Menu]^0 Max Armor activated")
end

function Menu.ActionDetachAllEntitys()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    DetachEntity(ped, true, false)
    ClearPedTasksImmediately(ped)
    print("^2[Menu]^0 Detached all entities")
end

function Menu.ActionTPAllVehiclesToMe()
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", [[
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            
            local handle, veh = FindFirstVehicle()
            local success = true
            
            repeat
                if veh ~= GetVehiclePedIsIn(ped, false) and DoesEntityExist(veh) then
                    SetEntityCoords(veh, pedCoords.x + 5, pedCoords.y + 5, pedCoords.z, false, false, false, false)
                end
                success, veh = FindNextVehicle(handle)
            until not success
            
            EndFindVehicle(handle)
        ]])
    end
    print("^2[Menu]^0 Vehicles teleported to you")
end

function Menu.ActionTPToWaypoint()
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", [[
            local ped = PlayerPedId()
            local waypointBlip = GetFirstBlipInfoId(8)
            
            if DoesBlipExist(waypointBlip) then
                local coords = GetBlipCoords(waypointBlip)
                SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
            end
        ]])
    end
    print("^2[Menu]^0 Teleported to waypoint")
end

function Menu.ActionMaxUpgrade()
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", [[
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            
            if veh and veh ~= 0 then
                SetVehicleModKit(veh, 0)
                for i = 0, 49 do
                    local count = GetNumVehicleMods(veh, i)
                    if count > 0 then
                        SetVehicleMod(veh, i, count - 1, false)
                    end
                end
            end
        ]])
    end
    print("^2[Menu]^0 Vehicle upgraded")
end

function Menu.ActionRepairVehicle()
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", [[
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            
            if veh and veh ~= 0 then
                SetVehicleFixed(veh)
                SetVehicleDeformationFixed(veh)
                SetVehicleEngineHealth(veh, 1000.0)
                SetVehicleBodyHealth(veh, 1000.0)
            end
        ]])
    end
    print("^2[Menu]^0 Vehicle repaired")
end

function Menu.ActionDeleteVehicle()
    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", [[
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            
            if veh and veh ~= 0 then
                SetEntityAsMissionEntity(veh, true, true)
                DeleteEntity(veh)
            end
        ]])
    end
    print("^2[Menu]^0 Vehicle deleted")
end

-- ============================================
-- SETUP DES ACTIONS DU MENU
-- ============================================

CreateThread(function()
    Wait(500)
    
    -- Binder les actions aux éléments du menu
    for _, cat in ipairs(Menu.Categories) do
        if cat.tabs then
            for _, tab in ipairs(cat.tabs) do
                for _, item in ipairs(tab.items) do
                    if item.name == "Revive" then
                        item.onClick = function() Menu.ActionRevive() end
                    elseif item.name == "Max Health" then
                        item.onClick = function() Menu.ActionMaxHealth() end
                    elseif item.name == "Max Armor" then
                        item.onClick = function() Menu.ActionMaxArmor() end
                    elseif item.name == "Detach All Entitys" then
                        item.onClick = function() Menu.ActionDetachAllEntitys() end
                    elseif item.name == "TP all vehicle to me" then
                        item.onClick = function() Menu.ActionTPAllVehiclesToMe() end
                    elseif item.name == "Max Upgrade" then
                        item.onClick = function() Menu.ActionMaxUpgrade() end
                    elseif item.name == "Repair Vehicle" then
                        item.onClick = function() Menu.ActionRepairVehicle() end
                    elseif item.name == "Delete Vehicle" then
                        item.onClick = function() Menu.ActionDeleteVehicle() end
                    end
                end
            end
        end
    end
    
    print("^2[Menu]^0 Actions bound successfully")
end)

-- ============================================
-- KEYBIND - Touche G pour ouvrir/fermer le menu
-- ============================================

-- Touche G = 47 (voir les codes en bas)
local MENU_TOGGLE_KEY = 47 -- G

CreateThread(function()
    print("^5[Menu]^0 Keybind system initialized - Press G to toggle menu")
    
    while true do
        Wait(0)
        
        -- Détecter si G est pressé
        if IsControlJustPressed(0, MENU_TOGGLE_KEY) then
            Menu.Visible = not Menu.Visible
            
            if Menu.Visible then
                print("^2[Menu]^0 Menu opened (G pressed)")
            else
                print("^3[Menu]^0 Menu closed (G pressed)")
            end
        end
    end
end)

-- ============================================
-- RENDER LOOP PRINCIPAL
-- ============================================

Menu.OnRender = function()
    -- À exécuter chaque frame
    if Menu.Visible then
        -- Le menu est visible, on peut afficher les éléments
    end
end

-- ============================================
-- FIN INITIALISATION
-- ============================================

print("^2[Menu]^0 Menu loaded successfully!")
print("^5[Menu]^0 Press G to toggle the menu")

return Menu
