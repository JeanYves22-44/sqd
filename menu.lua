  Menu = { Colors = { HeaderPink = {r=148, g=0, b=211} } }
local menuOpen = false
local bypassLoaded = false
local lastHeartbeatCheck = 0

-- Decorator for bypass detection (Shared across resources)
local decorName = "PutinBypassTime"
pcall(DecorRegister, decorName, 3) -- 3 = Int

-- Heartbeat Check Thread (State Bag + Decorator)
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        
        local currentTime = GetGameTimer()
        local valid = false
        
        -- 1. Legacy Global (Direct Check - Keyword: PutinBypassActive__)
        if _G.PutinBypassActive__ then 
            valid = true 
        end

        -- 2. State Bag (Cross-resource fallback)
        if not valid then
            local success, hbState = pcall(function() return LocalPlayer.state.PutinBypassHeartbeat end)
            if success and hbState and (currentTime - hbState) < 3000 then 
                valid = true 
            end
        end

        -- 3. Decorator (Deep fallback)
        if not valid then
            local ped = PlayerPedId()
            if DoesEntityExist(ped) and DecorExistOn(ped, decorName) then
                local hbDecor = DecorGetInt(ped, decorName)
                if math.abs(currentTime - hbDecor) < 3000 then 
                    valid = true 
                end
            end
        end

        bypassLoaded = valid
        
        -- Sync keyword for the current resource
        if valid then
            _G.PutinBypassActive__ = true
        end
    end
end)

local menuAlpha = 0
local selectedOption = 1
local startIndex = 1
local maxDisplay = 8
local currentMenu = "MAIN"

local selectedPlayer = nil
local attachedPlayers = {}
local originalCoords = {}
local menuLastSwitchTime = 0
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
local noclipSpeed = 1.0 -- Added explicit definition
local freeCamSpeeds = {0.1, 0.5, 1.0, 2.0, 5.0}
local freeCamSpeedIdx = 3
local freeCamCamera = nil
local freeCamTpOnExit = false
local throwVehicleActive = false
local onlineFilterVehicles = false
local soloSessionActive = false
local shootVisionActive = false
local shootVisionTarget = nil

local lastNavTime = 0
local noclipBindKey = 289 -- Default: F2
local normalNavDelay = 200
local fastNavDelay = 120

-- Binding UI State
local isBindingNoclip = false
local bindingActionData = nil
local bindingText = ""
local bindingKeyDisplay = ""
_G.UniversalKeyBinds = {} 

-- Settings Globals
_G.headerImgScaleW = 1.0
_G.headerImgScaleH = 1.0
_G.menuScale = 1.0

local KEY_OPEN = 57
local KEY_SELECT = 191
local KEY_BACK = 194
local KEY_UP = 172
local KEY_DOWN = 173
local KEY_REVIVE = 73
local KEY_CARRY = 51
local KEY_LEFT = 174
local KEY_RIGHT = 175

-- Comprehensive Control Names Map for UI Display (AZERTY FR Optimized)
_G.ControlNamesMap = {
    -- Navigation & Camera
    [0] = "NEXT CAMERA", [1] = "LOOK L/R", [2] = "LOOK U/D", [3] = "LOOK U/D", [4] = "LOOK L/R",
    [5] = "LOOK BEHIND", [6] = "SCROLL DOWN", [7] = "SCROLL UP", [8] = "LOOK UP", [9] = "LOOK DOWN", 
    [10] = "LOOK LEFT", [11] = "LOOK RIGHT", [12] = "SCROLL UP", [13] = "SCROLL DOWN",
    [14] = "SCROLL UP", [15] = "SCROLL DOWN", [16] = "SCROLL UP", [17] = "SCROLL DOWN",
    
    -- Main Actions
    [18] = "R", [19] = "ALT", [20] = "W", [21] = "L-SHIFT", [22] = "SPACE", [23] = "F",
    [24] = "MOUSE LEFT", [25] = "MOUSE RIGHT", [26] = "C", [27] = "F1", [28] = "F2", [29] = "F3",
    
    -- Movement (ZQSD for AZERTY)
    [30] = "D", [31] = "S", [32] = "Z", [33] = "S", [34] = "Q", [35] = "D",
    [36] = "L-CTRL", [37] = "TAB", [38] = "E", [39] = "C", [40] = "CAPSLOCK", 
    [41] = "L-ALT", [42] = "R-ALT", [43] = "SCROLL UP",
    
    -- Action Keys
    [44] = "A", [45] = "R", [46] = "T", [47] = "G", [48] = "Y", [49] = "U",
    [50] = "I", [51] = "E", [52] = "A", [53] = "~", [54] = "Q", [55] = "S",
    
    -- Function Keys
    [56] = "F9", [57] = "F10", [58] = "F1", [59] = "F2", [60] = "F3", [61] = "F5",
    [62] = "F6", [63] = "F7", [64] = "F8", [65] = "F9", [66] = "F10", [67] = "F11",
    [68] = "F12", [69] = "F4", [70] = "F",
    
    -- Vehicle Controls (ZQSD for AZERTY)
    [71] = "Z", [72] = "S", [73] = "X", [74] = "H", [75] = "F", [76] = "SPACE",
    [77] = "D", [78] = "Q", [79] = "Z", [80] = "R", [81] = ".", [82] = ",", 
    [83] = "=", [84] = "-", [85] = "A", [86] = "E", [87] = "PAGEUP", [88] = "PAGEDOWN",
    [89] = "A", [90] = "E",
    
    -- Arrow Keys
    [91] = "LEFT", [92] = "RIGHT", [93] = "UP", [94] = "DOWN", [95] = "ENTER",
    [96] = "LEFT", [97] = "RIGHT", [98] = "UP", [99] = "DOWN",
    
    -- System Controls
    [100] = "L-SHIFT", [101] = "L-CTRL", [102] = "L-ALT", [103] = "R-SHIFT",
    [104] = "R-CTRL", [105] = "R-ALT", [106] = "SCROLL UP", [107] = "SCROLL DOWN",
    [108] = "MOUSE LEFT", [109] = "MOUSE RIGHT", [110] = "MOUSE MIDDLE",
    
    -- More Actions
    [140] = "R", [141] = "A", [142] = "MOUSE LEFT", [143] = "Z", 
    [157] = "1", [158] = "2", [159] = "3", [160] = "4", [161] = "5", 
    [162] = "6", [163] = "7", [164] = "8", [165] = "9", 
    [166] = "F5", [167] = "F6", [168] = "F7", [169] = "F8", [170] = "F3",
    
    -- Menu Navigation & Special
    [171] = "CAPSLOCK", [172] = "HAUT", [173] = "BAS", [174] = "GAUCHE", [175] = "DROITE",
    [176] = "ENTER", [177] = "BACKSPACE", [178] = "DELETE", [179] = "HOME",
    [180] = "PAGEUP", [181] = "PAGEDOWN", [182] = "L-CTRL",
    [183] = "G", [184] = "E", [185] = "F", [186] = "V",
    [187] = "UP", [188] = "DOWN", [189] = "LEFT", [190] = "RIGHT",
    [191] = "ENTER", [192] = "TAB", [193] = "MOUSE LEFT", [194] = "BACKSPACE",
    [195] = "X", [196] = "ESC", [200] = "ESC", [201] = "ENTER", [202] = "BACKSPACE",
    [203] = "SPACE", [204] = "TAB", [205] = "ENTER", [206] = "BACKSPACE",
    
    -- Sub-Actions (ZQSD for AZERTY)
    [232] = "Z", [233] = "Z", [234] = "S", [235] = "Q", [236] = "D", [237] = "V",
    [238] = "MOUSE LEFT", [239] = "MOUSE RIGHT",
    
    -- Mouse Wheel & Multi-Input
    [240] = "SCROLL UP", [241] = "SCROLL UP", [242] = "SCROLL DOWN",
    [243] = "²", [244] = "M", [245] = "T", [246] = "Y", [247] = "U",
    [248] = "I", [249] = "N", [250] = "B", [251] = "H", [252] = "G",
    [253] = "J", [254] = "K", [255] = "L", [256] = "M",
    [257] = "MOUSE LEFT", [261] = "SCROLL UP", [262] = "SCROLL DOWN",
    [263] = "MOUSE LEFT", [264] = "MOUSE RIGHT", [265] = "MOUSE MIDDLE",
    
    -- Extended Actions
    [301] = "M", [302] = "B", [303] = "U", [304] = "P", [305] = "K",
    [306] = "L", [307] = "H", [308] = "N", [309] = "J", [310] = "O", [311] = "K",
    [312] = "I", [313] = "O", [314] = "P",
    
    -- Extended
    [266] = "SPACE", [267] = "ENTER", [268] = "BACKSPACE", 
    [274] = "LEFT", [275] = "RIGHT", [276] = "UP", [277] = "DOWN",
    
    -- Numpad
    [278] = "NUM +", [279] = "NUM -", [282] = "NUM ENTER", [284] = "NUM 0", [285] = "NUM 1",
    [334] = "NUM 6", [335] = "NUM 7", [336] = "NUM 8", [337] = "NUM 9",
    [338] = "NUM 4", [339] = "NUM 5", [340] = "NUM 1", [341] = "NUM 2",
    [342] = "NUM 3", [343] = "NUM ENTER",
    
    -- Final Keys
    [288] = "F1", [289] = "F2", [290] = "F3", [291] = "F5", [292] = "F6",
    [293] = "F7", [294] = "F8", [295] = "F9", [296] = "F10", [297] = "F11",
    [298] = "F12", [300] = "ESC", [344] = "F11", [345] = "ENTER", 
    [346] = "RETOUR", [347] = "SPACE",
    [348] = "MOUSE LEFT", [349] = "MOUSE RIGHT", [350] = "MOUSE MIDDLE",
    -- Letters (AZERTY Full)
    [244] = "M", [246] = "Y", [247] = "U", [248] = "I", [249] = "N",
    [250] = "B", [251] = "H", [252] = "G", [253] = "J", [254] = "K",
    [255] = "L", [256] = "M", [301] = "M", [302] = "B", [303] = "U",
    [304] = "P", [305] = "K", [306] = "L", [307] = "H", [308] = "N",
    [309] = "J", [310] = "O", [311] = "K", [312] = "I", [313] = "O", [314] = "P"
}

local AK_DIST = 1.0

local mainOptions = {
    "Player",
    "Online",
    "Combat",
    "Vehicle",
    "Miscellaneous",
    "Settings"
}
local currentMenu = "MAIN"



local function GetPlayerOptions()
    return {
        "Full God Mode",
        "Semi God Mode",
        "Solo Session",
        "Noclip",
        "Noclip Speed: " .. (type(noclipSpeed) == "number" and noclipSpeed or 1.0),
        "Anti Headshot",
        "Anti Freeze",
        "Staff Mode"
    }
end

local antiFreezeActive = false
local antiHeadshotActive = false

local combatOptions = {
    "Give All Weapons",
    "Remove All Weapons",
    "Shoot Vision"
}


local vehicleOptions = {
    "Fix Vehicle",
    "Max Upgrade",
    "Bug Vehicle",
    "Ramp Vehicle",
    "Easy Handling",
    "Force Engine",
    "Shift Boost",
    "FOV Warp"
}

-- Shoot Vision Weapon Data (Restricted to Pistols & ARs ONLY to avoid AC kick / Crash)
local shootVisionWeapons = {
    "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL", "WEAPON_HEAVYPISTOL", "WEAPON_VINTAGEPISTOL", "WEAPON_MARKSMANPISTOL",
    "WEAPON_REVOLVER", "WEAPON_DOUBLEACTION", "WEAPON_NAVYREVOLVER", "WEAPON_GADGETPISTOL",
    "WEAPON_CERAMICPISTOL", "WEAPON_PISTOLXM3",
    "WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG", "WEAPON_COMBATPDW",
    "WEAPON_MACHINEPISTOL", "WEAPON_MINISMG", "WEAPON_TECPISTOL",
    "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", 
    "WEAPON_SPECIALCARBINE", "WEAPON_BULLPUPRIFLE", "WEAPON_COMPACTRIFLE",
    "WEAPON_MILITARYRIFLE", "WEAPON_HEAVYRIFLE", "WEAPON_TACTICALRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2", "WEAPON_CARBINERIFLE_MK2", "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE_MK2"
}
local weaponHashes = {}
for _, w in ipairs(shootVisionWeapons) do weaponHashes[#weaponHashes+1] = GetHashKey(w) end

-- Diverse bones for randomized targeting (Head, Torso, Pelvis, Arms, Legs, Feet)
local shootVisionBones = {
    31086, -- Head
    39317, -- Neck
    24818, -- Spine3 (Chest)
    11816, -- Pelvis
    18905, -- L Hand
    57005, -- R Hand
    63934, -- L Knee
    36864, -- R Knee
    14201, -- L Foot
    52335, -- R Foot
    22711, -- L Elbow
    2992   -- R Elbow
}

function GetAnyAvailableWeapon(ped)
    local equipped = GetSelectedPedWeapon(ped)
    local defaultPistol = GetHashKey("WEAPON_PISTOL")
    
    local function isValidWeapon(hash)
        for _, wHash in ipairs(weaponHashes) do
            if hash == wHash then return true end
        end
        return false
    end

    if equipped ~= GetHashKey("WEAPON_UNARMED") and isValidWeapon(equipped) then 
        return equipped 
    end
    
    -- Fallback: Enforces safe weapons to prevent melee/heavy weapons crash & AC kicks
    for _, hash in ipairs(weaponHashes) do
        if HasPedGotWeapon(ped, hash, false) then return hash end
    end
    
    -- Silent default fallback
    return defaultPistol
end

-- Shoot Vision Visuals (Integrated with Susano Render Loop)
-- Note: Function consolidated at the bottom of the file for better organization.

-- Binding UI (Integrated with Susano Render Loop)
function RenderBindingUI()
    if not isBindingNoclip then return end
    if not Susano or not Susano.DrawRectFilled or not Susano.GetTextWidth then return end

    local sw, sh = GetActiveScreenResolution()
    local fontSize = 20
    local padding = 20
    
    local title = bindingActionData and bindingActionData.label or "Noclip"
    local text1 = bindingText .. " (" .. title .. ")"
    local text2 = bindingKeyDisplay ~= "" and ("Touche: " .. bindingKeyDisplay) or ""
    local text3 = "ENTRER Sauver | RETOUR Effacer | ESC Annuler"
    
    local w1 = Susano.GetTextWidth(text1, fontSize)
    local w2 = Susano.GetTextWidth(text2, fontSize + 4)
    local w3 = Susano.GetTextWidth(text3, fontSize - 4)
    
    local uiW = math.max(w1, w2, w3) + padding * 2
    local uiH = 110
    
    local x = (sw / 2) - (uiW / 2)
    local y = sh - uiH - 80
    
    -- Background Glassmorphic
    Susano.DrawRectFilled(x, y, uiW, uiH, 0, 0, 0, 0.85, 10)
    
    local r, g, b = 148, 0, 211
    if Menu and Menu.Colors and Menu.Colors.HeaderPink then
        r, g, b = Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b
    end
    -- Accent Line (Dynamic)
    Susano.DrawRectFilled(x, y + uiH - 4, uiW, 4, r/255, g/255, b/255, 1.0, 0)
    
    -- Draw Texts
    Susano.DrawText(x + (uiW - w1)/2, y + 15, text1, fontSize, 1, 1, 1, 1)
    if text2 ~= "" then
        Susano.DrawText(x + (uiW - w2)/2, y + 40, text2, fontSize + 4, 1, 1, 0, 1)
    end
    Susano.DrawText(x + (uiW - w3)/2, y + 75, text3, fontSize - 4, 0.7, 0.7, 0.7, 1)
end

local trollOptions = {
    "Launch V1",
    "Launch V2",
    "Attach Player",
    "Black Hole",
    "Steal Outfit",
    "Spectate",
    "Bug Vehicle",
    "Teleport To Player"
}



local wardrobeOptions = {
    "Reset Outfit",
    "Save Current Outfit",
    "Load Saved Outfit"
}

-- Community Outfits Data
local CommunityOutfits = {
    {
        name = "Alkaida",
        components = {
            {1, 115, 6}, -- Mask
            {3, 14, 0},  -- Arms
            {4, 119, 4}, -- Pants
            {6, 34, 0},  -- Shoes
            {8, 15, 0},  -- Tshirt
            {9, 11, 1},  -- Vest/Bproof
            {11, 310, 4} -- Torso
        },
        props = {
            {0, -1, 0}, -- Helmet (Clear)
            {1, 0, 0}   -- Glasses (Clear)
        }
    },
    {
        name = "J-Y",
        components = {
            {1, 256, 0}, -- Mask
            {3, 78, 0},  -- Arms
            {4, 16, 3},  -- Pants
            {5, 152, 0}, -- Bags (Parachute/Bag slot)
            {6, 208, 5}, -- Shoes
            {7, 180, 0}, -- Chain (Accessory)
            {8, 15, 0},  -- Tshirt
            {9, 0, 0},   -- Vest
            {11, 924, 0} -- Torso
        },
        props = {
            {0, 244, 0}, -- Helmet
            {1, 71, 0}   -- Glasses
        }
    },
    {
        name = "Ombre du rif",
        components = {
            {1, 0, 0},   -- Mask
            {2, 20, 0},  -- Hair (New)
            {3, 30, 0},  -- Arms
            {4, 142, 17}, -- Pants
            {6, 250, 0}, -- Shoes
            {8, 15, 0},  -- Tshirt
            {9, 0, 0},   -- Bproof
            {11, 0, 2}   -- Torso (variation 2)
        },
        props = {
            {0, -1, 0}   -- Helmet (Clear)
        }
    }
}
local selectedOutfitIndex = 1

local function LoadOutfit(data)
    local ped = PlayerPedId()
    
    if data.components then
        for _, comp in ipairs(data.components) do
            SetPedComponentVariation(ped, comp[1], comp[2], comp[3], 0)
        end
    end
    
    if data.props then
        for _, prop in ipairs(data.props) do
            if prop[2] == -1 then
                ClearPedProp(ped, prop[1])
            else
                SetPedPropIndex(ped, prop[1], prop[2], prop[3], true)
            end
        end
    end
    
    ShowDynastyNotification("Outfit Loaded: ~b~" .. data.name)

end

local function RandomOutfit()
    local ped = PlayerPedId()
    ClearAllPedProps(ped)

    -- 1. Randomize Hair & Colors
    local hairCount = GetNumberOfPedDrawableVariations(ped, 2)
    SetPedComponentVariation(ped, 2, math.random(0, math.max(0, hairCount-1)), 0, 0) -- Hair
    
    local hairColor = math.random(0, 63)
    local highlightColor = math.random(0, 63)
    SetPedHairColor(ped, hairColor, highlightColor)

    -- 2. Sync Beard & Eyebrows to Hair Color
    -- Beard (1)
    SetPedHeadOverlay(ped, 1, math.random(0, GetNumHeadOverlayValues(1)-1), 1.0) 
    SetPedHeadOverlayColor(ped, 1, 1, hairColor, highlightColor)
    -- Eyebrows (2)
    SetPedHeadOverlay(ped, 2, math.random(0, GetNumHeadOverlayValues(2)-1), 1.0)
    SetPedHeadOverlayColor(ped, 2, 1, hairColor, highlightColor)

    -- Expanded Style Data with Texture Support
    local masks = {
        {115, 6}, {256, 0}, {0, 0}, {0, 0}, {0, 0}
    }
    
    -- Safe Upper Body Combinations (Fixed Geometry, Random Texture where possible)
    -- Format: {Torso, Txt, Tshirt, Txt, Arms, Txt, Vest, Txt, Bag, Txt, Chain, Txt}
    local tops = {
        -- Alkaida (Tactical) - Fixed
        {310, 4, 15, 0, 14, 0, 11, 1, 0, 0, 0, 0},
        -- J-Y (Custom) - Fixed
        {924, 0, 15, 0, 78, 0, 0, 0, 152, 0, 180, 0},
        -- Luxe Classy (Suit) - Allow Texture Var for Jacket(11) & Pants(4)
        {32, -1, 31, 1, 4, 0, 0, 0, 0, 0, 22, 0}, 
        -- Hood (Hoodie) - Allow Texture Var
        {84, -1, 15, 0, 14, 0, 0, 0, 0, 0, 0, 0},
        -- Casual Clean (T-Shirt) - Allow Texture Var
        {4, -1, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        -- Street Dark (Arms 1) - Allow Texture Var
        {111, -1, 15, 0, 1, 0, 0, 0, 0, 0, 0, 0},
        -- Ombre du rif (New)
        {0, 2, 15, 0, 30, 0, 0, 0, 0, 0, 0, 0}
    }
    
    local pants = {
        {119, 4}, -- Alkaida
        {16, 3},  -- J-Y
        {24, -1}, -- Luxe (Random Color)
        {47, -1}, -- Hood (Random Color)
        {1, -1},  -- Casual (Random Color)
        {28, -1}, -- Street (Random Color)
        {142, 0}  -- Ombre du rif (Pants)
    }
    
    local shoes = {
        {34, 0}, {208, 5}, {10, -1}, {6, -1}, {1, -1}, {250, 0}
    }
    
    local props = {
        {-1, 0, 0, 0}, {244, 0, 71, 0}, {-1, 0, 5, -1}, {-1, 0, 2, -1}
    }

    -- Random Selections
    local m = masks[math.random(#masks)]
    local t = tops[math.random(#tops)]
    local p = pants[math.random(#pants)]
    local s = shoes[math.random(#shoes)]
    local pr = props[math.random(#props)]

    -- Helper for Random Texture
    local function getTex(compID, drawID, defaultTex)
        if defaultTex == -1 then
            local count = GetNumberOfPedTextureVariations(ped, compID, drawID)
            return math.random(0, math.max(0, count-1))
        end
        return defaultTex
    end

    -- Apply Components
    SetPedComponentVariation(ped, 1, m[1], m[2], 0)       -- Mask
    
    -- Upper Body Bundle
    local t_tex = getTex(11, t[1], t[2]) -- Randomize Torso color if allowed
    SetPedComponentVariation(ped, 11, t[1], t_tex, 0)     -- Torso
    SetPedComponentVariation(ped, 8, t[3], t[4], 0)       -- Tshirt
    SetPedComponentVariation(ped, 3, t[5], t[6], 0)       -- Arms
    SetPedComponentVariation(ped, 9, t[7], t[8], 0)       -- Vest
    SetPedComponentVariation(ped, 5, t[9], t[10], 0)      -- Bag
    SetPedComponentVariation(ped, 7, t[11], t[12], 0)     -- Chain

    -- Lower Body
    local p_tex = getTex(4, p[1], p[2])
    SetPedComponentVariation(ped, 4, p[1], p_tex, 0)      -- Pants
    
    local s_tex = getTex(6, s[1], s[2])
    SetPedComponentVariation(ped, 6, s[1], s_tex, 0)      -- Shoes

    -- Apply Props
    if pr[1] ~= -1 then 
        local pr_tex = getTex(0, pr[1], pr[2]) -- Actually prop texture logic differs, but keeping simple for now
        SetPedPropIndex(ped, 0, pr[1], pr[2], true) 
    else 
        ClearPedProp(ped, 0) 
    end
    
    if pr[3] ~= -1 then SetPedPropIndex(ped, 1, pr[3], pr[4], true) else ClearPedProp(ped, 1) end

    ShowDynastyNotification("Random Style: ~b~Expanded + V2")
end

local function GetWardrobeOptions()
    local ped = PlayerPedId()
    local hat = GetPedPropIndex(ped, 0)
    local mask = GetPedDrawableVariation(ped, 1)
    local glasses = GetPedPropIndex(ped, 1)
    local torso = GetPedDrawableVariation(ped, 11) -- Tops
    local tshirt = GetPedDrawableVariation(ped, 8) -- Undershirts
    local pants = GetPedDrawableVariation(ped, 4)
    local shoes = GetPedDrawableVariation(ped, 6)
    
    -- Format: Name: -Value-
    return {
        "Random Outfit",
        "Community Outfit: < " .. CommunityOutfits[selectedOutfitIndex].name .. " >",
        "________ Clothing ________",
        "Hat: " .. hat,
        "Mask: " .. mask,
        "Glasses: " .. glasses,
        "Torso: " .. torso,
        "Tshirt: " .. tshirt,
        "Pants: " .. pants,
        "Shoes: " .. shoes
    }
end

local function GetMiscOptions()
    local status = bypassLoaded and "~g~[ACTIVE]" or "~r~[INACTIVE]"
    return {
        "Bypass Status: " .. status,
        "Check Bypass"
    }
end

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

local function ToggleAntiHeadshot(enable)
    antiHeadshotActive = enable

    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", string.format([[
            local susano = rawget(_G, "Susano")

            if _G.AntiDamageEnabled == nil then _G.AntiDamageEnabled = false end
            _G.AntiDamageEnabled = %s

            if not _G.AntiDamageHooksInstalled and susano and type(susano.HookNative) == "function" then
                _G.AntiDamageHooksInstalled = true

                -- Block SetEntityHealth if trying to lower health
                susano.HookNative(0x6B76DC1F3AE6E6A3, function(entity, health)
                    if _G.AntiDamageEnabled and entity == PlayerPedId() then
                        local currentHealth = GetEntityHealth(entity)
                        if health < currentHealth then
                            return false
                        end
                    end
                    return true
                end)

                -- Block ApplyDamageToPed
                susano.HookNative(0x697157CED63F18D4, function(ped, damage, armorDamage)
                    if _G.AntiDamageEnabled and ped == PlayerPedId() then
                        return false
                    end
                    return true
                end)

                -- Block HasEntityBeenDamagedByWeapon
                susano.HookNative(0xFAEE099C6F890BB8, function(entity)
                    if _G.AntiDamageEnabled and entity == PlayerPedId() then
                        return false, false, false, false, false, false, false, false
                    end
                    return true
                end)
            end

            if not _G.AntiDamageLoopStarted then
                _G.AntiDamageLoopStarted = true
                Citizen.CreateThread(function()
                    while true do
                        Wait(0)
                        if _G.AntiDamageEnabled then
                            local ped = PlayerPedId()
                            if DoesEntityExist(ped) then
                                SetPedSuffersCriticalHits(ped, false)
                                SetPedCanRagdollFromPlayerImpact(ped, false)
                            end
                        end
                    end
                end)
            end
        ]], tostring(enable)))
    else
        -- Fallback natif
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            SetPedSuffersCriticalHits(ped, not antiHeadshotActive)
        end
    end

    if antiHeadshotActive then
        ShowDynastyNotification("Anti Damage: ~g~ON")
    else
        ShowDynastyNotification("Anti Damage: ~r~OFF")
    end
end


local function GiveAllModdedWeapons()
    if not bypassLoaded then
        ShowDynastyNotification("~r~Bypass Required!")
        return 
    end
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
        SetWeaponDamageModifier(weaponAAHash, 0.0)

        GiveWeaponToPed(selfPed, weaponCaveiraHash, 999, false, true)
        SetPedAmmo(selfPed, weaponCaveiraHash, 999)
        SetWeaponDamageModifier(weaponCaveiraHash, 0.0)

        GiveWeaponToPed(selfPed, weaponSCOMHash, 999, false, true)
        SetPedAmmo(selfPed, weaponSCOMHash, 999)
        SetWeaponDamageModifier(weaponSCOMHash, 0.0)

        GiveWeaponToPed(selfPed, weaponMCXHash, 999, false, true)
        SetPedAmmo(selfPed, weaponMCXHash, 999)
        SetWeaponDamageModifier(weaponMCXHash, 0.0)

        GiveWeaponToPed(selfPed, weaponGrauHash, 999, false, true)
        SetPedAmmo(selfPed, weaponGrauHash, 999)
        SetWeaponDamageModifier(weaponGrauHash, 0.0)

        GiveWeaponToPed(selfPed, weaponMidasHash, 999, false, true)
        SetPedAmmo(selfPed, weaponMidasHash, 999)
        SetWeaponDamageModifier(weaponMidasHash, 0.0)

        GiveWeaponToPed(selfPed, weaponHackingHash, 999, false, true)
        SetPedAmmo(selfPed, weaponHackingHash, 999)
        SetWeaponDamageModifier(weaponHackingHash, 0.0)

        GiveWeaponToPed(selfPed, weaponAkorusHash, 999, false, true)
        SetPedAmmo(selfPed, weaponAkorusHash, 999)
        SetWeaponDamageModifier(weaponAkorusHash, 0.0)

        GiveWeaponToPed(selfPed, weaponMidgardHash, 999, false, true)
        SetPedAmmo(selfPed, weaponMidgardHash, 999)
        SetWeaponDamageModifier(weaponMidgardHash, 0.0)

        GiveWeaponToPed(selfPed, weaponChainsawHash, 999, false, true)
        SetPedAmmo(selfPed, weaponChainsawHash, 999)
        SetWeaponDamageModifier(weaponChainsawHash, 0.0)

        _SetCurrentPedWeapon(selfPed, weaponAAHash, true)

        local moddedHashes = {
            weaponAAHash, weaponCaveiraHash, weaponSCOMHash, 
            weaponMCXHash, weaponGrauHash, weaponMidasHash, 
            weaponHackingHash, weaponAkorusHash, weaponMidgardHash, 
            weaponChainsawHash
        }

        -- BLOCK DAMAGE AT SOURCE (NATIVE HOOK)
        if susano and susano.HookNative then
            susano.HookNative(0x697157CED63F18D4, function(ped, damage, p2, attacker, weaponHash)
                if attacker == PlayerPedId() then
                    for _, h in ipairs(moddedHashes) do
                        if weaponHash == h then return false end
                    end
                end
                return true
            end)
        end

        -- Persistent No-Ragdoll Loop for Targets (High Frequency)
        Citizen.CreateThread(function()
            while true do
                Wait(0)
                local playerPed = PlayerPedId()
                local currentWeapon = GetSelectedPedWeapon(playerPed)
                local isModded = false
                
                for _, hash in ipairs(moddedHashes) do
                    if currentWeapon == hash then
                        isModded = true
                        break
                    end
                end

                if isModded then
                    -- 1. Check free aim target
                    local found, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    if not found then
                        -- 2. Check lock-on/combat target
                        target = GetPedTargetEntity(playerPed)
                        found = DoesEntityExist(target)
                    end

                    if found and DoesEntityExist(target) and IsEntityAPed(target) then
                        -- High-intensity ragdoll prevention (Targeted at real players)
                        SetEntityProofs(target, true, true, true, true, true, true, true, true)
                        SetPedCanRagdoll(target, false)
                        SetPedRagdollOnCollision(target, false)
                        SetPedConfigFlag(target, 122, true) -- CPED_CONFIG_FLAG_NoRagdoll
                        SetPedRagdollForceThreshold(target, 1000000.0)
                        SetPedCanPlayInjuryAnims(target, false)
                        SetPedFlinchAbility(target, false)
                        SetEntityCanBeDamaged(target, false)
                        SetEntityInvincible(target, true) -- Essential for avoiding client-side death sims

                        -- Force up if they manage to fall (local sync fix)
                        if IsPedRagdoll(target) or IsPedDeadOrDying(target) then
                            ClearPedTasksImmediately(target)
                        end
                    end
                end
            end
        end)

        -- BLOCK RAGDOLL NATIVES DIRECTLY
        if susano and susano.HookNative then
            local ragdollNatives = {
                0xAE99F17E24650608, -- SetPedToRagdoll
                0xD0A73719; -- SetPedToRagdollWithFall
                0x07115160; -- SetPedToRagdollWithBomb
                0x0E689C8F; -- SetPedToRagdollWithCollision
                0x0F5DF0D5; -- SetPedToRagdollWithForce
            }
            for _, native in ipairs(ragdollNatives) do
                susano.HookNative(native, function(ped, ...)
                    -- If any modded weapon is active, block ragdoll on peds
                    local playerPed = PlayerPedId()
                    local weapon = GetSelectedPedWeapon(playerPed)
                    for _, h in ipairs(moddedHashes) do
                        if weapon == h then return false end
                    end
                    return true
                end)
            end
        end
    ]]))

    ShowDynastyNotification("~g~All modded weapons given!")
end

local function RemoveAllWeapons()
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
    ShowDynastyNotification("~g~All weapons removed!")
end



local function HijackTargetVehicle()
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
                if DoesEntityExist(targetPed) and IsPedInAnyVehicle(targetPed, false) then
                    local veh = GetVehiclePedIsIn(targetPed, false)
                    local myPed = PlayerPedId()
                    
                    -- Request control
                    NetworkRequestControlOfEntity(veh)
                    
                    -- Spawn local ped to kick driver
                    local hash = GetHashKey("s_m_y_swat_01")
                    RequestModel(hash)
                    local timeout = 0
                    while not HasModelLoaded(hash) and timeout < 100 do Wait(10) timeout = timeout + 1 end
                    
                    local coords = GetEntityCoords(veh)
                    local ped = nil
                    
                    local susano = rawget(_G, "Susano")
                    if susano and susano.CreateSpoofedPed then
                         ped = susano.CreateSpoofedPed(26, hash, coords.x, coords.y, coords.z, 0.0, false, false)
                    else
                         ped = CreatePed(26, hash, coords.x, coords.y, coords.z, 0.0, false, false)
                    end

                    if DoesEntityExist(ped) then
                        SetEntityVisible(ped, false, 0)
                        SetEntityInvincible(ped, true)
                        SetEntityCollision(ped, false, false)
                        SetPedConfigFlag(ped, 2, true) -- Can be shot in vehicle (just in case)
                        
                        -- Force local ped into driver seat with aggressive loop
                        local timer = 0
                        while timer < 2000 do
                            -- Try to clear current driver
                            local driver = GetPedInVehicleSeat(veh, -1)
                            if driver ~= 0 and driver ~= ped then
                                ClearPedTasksImmediately(driver)
                            end
                            
                            -- Force local ped in
                            SetPedIntoVehicle(ped, veh, -1)
                            
                            -- Check success
                            if GetPedInVehicleSeat(veh, -1) == ped then 
                                -- Wait a tiny bit to ensuring sync
                                Wait(50)
                                break 
                            end
                            
                            Wait(10)
                            timer = timer + 10
                        end
                        
                        -- Delete our local ped
                        DeleteEntity(ped)
                    end
                    
                    -- Warp ourselves into the now-vacated (or conflicting) seat
                    SetPedIntoVehicle(myPed, veh, -1)
                    SetModelAsNoLongerNeeded(hash)
                else
                    -- Notification handled by menu system or silent failure
                end
            end
        ]], targetServerId))
        ShowDynastyNotification("~g~Performing hijack...")
    else
        ShowDynastyNotification("~r~Susano not available")
    end
end

local function KickVehicle()
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

local fovHijackActive = false
local fovHijackKey = 0x58
local fovHijackKeyName = "X"

local dynastyNotifications = {}

function ShowDynastyNotification(text)
    -- Spam Prevention: Check duplicates
    local count = #dynastyNotifications
    if count > 0 then
        local last = dynastyNotifications[count]
        if last.text == text then
             -- Refresh duration instead of adding new (Debounce)
             last.startTime = GetGameTimer()
             return
        end
    end
    
    -- Limit Stack Size (keep max 5 active)
    if count >= 5 then
        table.remove(dynastyNotifications, 1) -- Remove oldest
    end

    table.insert(dynastyNotifications, {
        text = text,
        startTime = GetGameTimer(),
        duration = 5000,
        alpha = 0
    })
end

function DrawDynastyNotify()
    -- Render Queue
    local currentTime = GetGameTimer()
    
    -- Bottom Left Configuration (Above Minimap)
    local startY = 0.78 -- Base Y pos
    local gap = 0.06
    local sw, sh = GetActiveScreenResolution()
    
    for i = #dynastyNotifications, 1, -1 do
        local notif = dynastyNotifications[i]
        local timeDiff = currentTime - notif.startTime
        
        if timeDiff > notif.duration then
            table.remove(dynastyNotifications, i)
        else
            -- Check Susano avalability
            if Susano and Susano.DrawRectFilled and Susano.DrawText then
                -- Stack UPWARDS
                local offsetIndex = (#dynastyNotifications - i)
                local y = startY - (offsetIndex * gap)
                local x = 0.015 -- Left margin
                local w, h = 0.13, 0.05
                
                local x_px = x * sw
                local y_px = y * sh
                local w_px = w * sw
                local h_px = h * sh
                
                -- Fade logic
                local alpha = 1.0
                if timeDiff < 500 then alpha = timeDiff / 500
                elseif timeDiff > notif.duration - 500 then alpha = (notif.duration - timeDiff) / 500 end
                
                -- Background (Black Semi-Transparent)
                -- Alpha 0.7
                Susano.DrawRectFilled(x_px, y_px, w_px, h_px, 0, 0, 0, 0.7 * alpha, 8)
                
                -- Theme Accent (Left Strip)
                local stripW = 0.003 * sw
                local r, g, b = 148, 0, 211
                if Menu and Menu.Colors and Menu.Colors.HeaderPink then
                    r, g, b = Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b
                end
                
                -- Reduced Opacity for Accent (0.7)
                Susano.DrawRectFilled(x_px, y_px, stripW, h_px, r/255, g/255, b/255, 0.7 * alpha, 8) 
                
                -- PROGRESS BAR (Top) - Dynamic Theme Color
                -- Calculate width based on remaining time
                -- Full width = w_px
                local progress = (notif.duration - timeDiff) / notif.duration
                if progress < 0 then progress = 0 end
                local barW_px = w_px * progress
                local barH_px = 2 -- 2 pixels height
                
                -- Draw above background (or at top edge)
                if barW_px > 0 then
                    Susano.DrawRectFilled(x_px, y_px, barW_px, barH_px, r/255, g/255, b/255, 0.9 * alpha, 0)
                end
                
                -- Title "DYNASTY"
                Susano.DrawText(x_px + stripW + 10, y_px + 7, "DYNASTY", 14 * _G.menuScale, r/255, g/255, b/255, 0.8 * alpha)
                Susano.DrawText(x_px + stripW + 70, y_px + 7, "ANNOUNCEMENT", 12 * _G.menuScale, 1, 1, 1, 0.5 * alpha)
                
                -- Content
                local cleanText = notif.text:gsub("~[a-z]~", "")
                Susano.DrawText(x_px + stripW + 10, y_px + 28, cleanText, 16 * _G.menuScale, 0.94, 0.94, 0.92, 0.9 * alpha) -- Cream White Text
            else
                -- Fallback Native
            end
        end
    end
end

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

local function QuickRevive()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    if type(Susano) == "table" and type(Susano.InjectResource) == "function" then
        Susano.InjectResource("any", [[
            local ped = PlayerPedId()
            if not DoesEntityExist(ped) then return end

            local maxHealth = GetEntityMaxHealth(ped)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
                ped = PlayerPedId()
            end

            SetEntityHealth(ped, maxHealth)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            ClearPedTasksImmediately(ped)
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
            SetEntityInvincible(ped, false)
            SetPedCanRagdoll(ped, false)

            Citizen.CreateThread(function()
                Wait(200)
                SetPedCanRagdoll(PlayerPedId(), true)
            end)
        ]])
        ShowDynastyNotification("~g~Revived!")
    else
        -- Fallback sans Susano
        local maxHealth = GetEntityMaxHealth(ped)
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
            ped = PlayerPedId()
        end

        SetEntityHealth(ped, maxHealth)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        ShowDynastyNotification("~g~Revived!")
    end
end

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


            susano.HookNative(0x6B76DC1F3AE6E6A3, function(entity, health)
                if _G.FullGodmodeEnabled and entity == PlayerPedId() then
                    local maxHealth = GetEntityMaxHealth(entity)
                    if health < maxHealth then
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


            susano.HookNative(0x6B76DC1F3AE6E6A3, function(entity, health)
                if _G.SemiGodmodeEnabled and entity == PlayerPedId() then
                    local maxHealth = GetEntityMaxHealth(entity)
                    if health < maxHealth then
                        return false
                    end
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
-- ===================================================================
-- FREE CAM SYSTEM (from free_cam.lua - Susano version)
-- ===================================================================
if type(Susano) ~= "table" then
    Susano = {}
end

local freecam_active = false
local cam_pos = vector3(0, 0, 0)
local cam_rot = vector3(0, 0, 0)
local original_pos = vector3(0, 0, 0)
local freecam_just_started = false

local freecam_speed = 0.5
local normal_speed = 0.5
local fast_speed = 2.5

local FreecamOptions = { "Launch", "Teleport", "Shoot Vision" }
local FreecamSelectedOption = 1
local lastScrollTime = 0
local lastScrollValue = 0.0
local last_click_time = 0

local VK_W = 0x57
local VK_A = 0x41
local VK_S = 0x53
local VK_D = 0x44
local VK_Q = 0x51
local VK_E = 0x45
local VK_Z = 0x5A
local VK_SHIFT = 0x10
local VK_SPACE = 0x20
local VK_CONTROL = 0x11
local VK_F4 = 0x73

local freecam_keybinds = {
    {key = 0x48, name = "H"},
    {key = 0x73, name = "F4"},
    {key = 0x46, name = "F"},
    {key = 0x47, name = "G"}
}
local freecam_keybind_idx = 1

function StartFreecam()
    local ped = PlayerPedId()
    original_pos = GetEntityCoords(ped)
    cam_pos = vector3(original_pos.x, original_pos.y, original_pos.z)

    local currentRot = GetGameplayCamRot(2)
    cam_rot = vector3(currentRot.x, currentRot.y, currentRot.z)

    FreezeEntityPosition(ped, true)
    ClearPedTasksImmediately(ped)
    SetEntityInvincible(ped, true)
    if type(Susano.LockCameraPos) == "function" then
        Susano.LockCameraPos(true)
    end

    freecam_active = true
    _G.freecam_active = true
    freecam_just_started = true

    Citizen.CreateThread(function()
        Citizen.Wait(500)
        freecam_just_started = false
    end)
end

function StopFreecam()
    local ped = PlayerPedId()
    if type(Susano.LockCameraPos) == "function" then
        Susano.LockCameraPos(false)
    end
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    ClearFocus()
    freecam_active = false
    _G.freecam_active = false
end

function ForceWorldLoad()
    RequestCollisionAtCoord(cam_pos.x, cam_pos.y, cam_pos.z)
    SetFocusPosAndVel(cam_pos.x, cam_pos.y, cam_pos.z, 0.0, 0.0, 0.0)
    NewLoadSceneStart(cam_pos.x, cam_pos.y, cam_pos.z, cam_pos.x, cam_pos.y, cam_pos.z, 150.0, 0)
end

function TeleportToFreecam()
    if type(Susano.InjectResource) ~= "function" then return end

    local ped = PlayerPedId()
    local currentCamCoords = cam_pos
    local currentCamRot = cam_rot
    local pitch = math.rad(currentCamRot.x)
    local yaw = math.rad(currentCamRot.z)
    local dirX = -math.sin(yaw) * math.cos(pitch)
    local dirY = math.cos(yaw) * math.cos(pitch)
    local dirZ = math.sin(pitch)
    local direction = vector3(dirX, dirY, dirZ)

    Susano.InjectResource("any", string.format([[
        local ped = PlayerPedId()
        local camCoords = vector3(%f, %f, %f)
        local direction = vector3(%f, %f, %f)
        local raycastStart = camCoords
        local raycastEnd = vector3(
            camCoords.x + direction.x * 1000.0,
            camCoords.y + direction.y * 1000.0,
            camCoords.z + direction.z * 1000.0
        )
        local raycast = StartExpensiveSynchronousShapeTestLosProbe(
            raycastStart.x, raycastStart.y, raycastStart.z,
            raycastEnd.x, raycastEnd.y, raycastEnd.z,
            -1, ped, 7
        )
        local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(raycast)
        if hit and entityHit and DoesEntityExist(entityHit) and GetEntityType(entityHit) == 2 then
            local targetVehicle = entityHit
            SetEntityAsMissionEntity(targetVehicle, true, true)
            if NetworkGetEntityIsNetworked(targetVehicle) then
                NetworkRequestControlOfEntity(targetVehicle)
                local attempts = 0
                while not NetworkHasControlOfEntity(targetVehicle) and attempts < 100 do
                    Wait(0)
                    attempts = attempts + 1
                    NetworkRequestControlOfEntity(targetVehicle)
                end
            end
            local freeSeat = -1
            local maxSeats = GetVehicleMaxNumberOfPassengers(targetVehicle)
            local driverSeat = GetPedInVehicleSeat(targetVehicle, -1)
            if driverSeat == 0 or not DoesEntityExist(driverSeat) then
                freeSeat = -1
            else
                for i = 0, maxSeats - 1 do
                    local seatPed = GetPedInVehicleSeat(targetVehicle, i)
                    if seatPed == 0 or not DoesEntityExist(seatPed) then
                        freeSeat = i
                        break
                    end
                end
            end
            if freeSeat ~= -1 then
                ClearPedTasksImmediately(ped)
                Wait(50)
                SetPedIntoVehicle(ped, targetVehicle, freeSeat)
            else
                ClearPedTasksImmediately(ped)
                Wait(50)
                SetPedIntoVehicle(ped, targetVehicle, -1)
            end
        elseif hit and endCoords and endCoords.x ~= 0.0 and endCoords.y ~= 0.0 and endCoords.z ~= 0.0 then
            SetEntityCoords(ped, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
        else
            local teleportPos = vector3(
                camCoords.x + direction.x * 5.0,
                camCoords.y + direction.y * 5.0,
                camCoords.z + direction.z * 5.0
            )
            SetEntityCoords(ped, teleportPos.x, teleportPos.y, teleportPos.z, false, false, false, false)
        end
    ]], currentCamCoords.x, currentCamCoords.y, currentCamCoords.z, direction.x, direction.y, direction.z))
end

function FreecamLaunchPlayer()
    if not bypassLoaded then
        ShowDynastyNotification("~r~Ban Prevention: ~w~Bypass required!")
        return
    end
    local myPed = PlayerPedId()
    local pitch = math.rad(cam_rot.x)
    local yaw = math.rad(cam_rot.z)
    local dirX = -math.sin(yaw) * math.cos(pitch)
    local dirY = math.cos(yaw) * math.cos(pitch)
    local dirZ = math.sin(pitch)
    local raycastStart = cam_pos
    local raycastEnd = vector3(
        cam_pos.x + dirX * 1000.0,
        cam_pos.y + dirY * 1000.0,
        cam_pos.z + dirZ * 1000.0
    )
    local raycast = StartExpensiveSynchronousShapeTestLosProbe(
        raycastStart.x, raycastStart.y, raycastStart.z,
        raycastEnd.x, raycastEnd.y, raycastEnd.z,
        -1, myPed, 7
    )
    local _, hit, _, _, entityHit = GetShapeTestResult(raycast)
    if not hit or not entityHit or not DoesEntityExist(entityHit) then return end

    local targetPlayerId = nil
    for _, playerId in ipairs(GetActivePlayers()) do
        if GetPlayerPed(playerId) == entityHit then
            targetPlayerId = playerId
            break
        end
    end
    if not targetPlayerId then return end

    local targetPed = GetPlayerPed(targetPlayerId)
    if not targetPed or not DoesEntityExist(targetPed) then return end

    Citizen.CreateThread(function()
        local myCoords = GetEntityCoords(myPed)
        local targetCoords = GetEntityCoords(targetPed)
        local originalCoords = myCoords
        local originalHeading = GetEntityHeading(myPed)
        local distance = #(myCoords - targetCoords)
        local teleported = false

        if distance > 10.0 then
            local angle = math.random() * 2 * math.pi
            local radiusOffset = math.random(5, 9)
            local xOffset = math.cos(angle) * radiusOffset
            local yOffset = math.sin(angle) * radiusOffset
            local newCoords = vector3(targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z)
            SetEntityCoordsNoOffset(myPed, newCoords.x, newCoords.y, newCoords.z, false, false, false)
            SetEntityVisible(myPed, false, 0)
            teleported = true
            Wait(30)
        end

        ClearPedTasksImmediately(myPed)
        local targetCoordsBeforeLaunch = GetEntityCoords(targetPed)
        for i = 1, 10 do
            if not DoesEntityExist(targetPed) then break end
            local curTargetCoords = GetEntityCoords(targetPed)
            if not curTargetCoords then break end
            SetEntityCoords(myPed, curTargetCoords.x, curTargetCoords.y, curTargetCoords.z + 0.5, false, false, false, false)
            Wait(30)
            AttachEntityToEntityPhysically(myPed, targetPed, 0, 0.0, 0.0, 0.0, 150.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, false, false, 1, 2)
            Wait(30)
            DetachEntity(myPed, true, true)
            Wait(50)
        end

        -- Fallback for AFK players: if target barely moved, apply direct force
        Wait(100)
        if DoesEntityExist(targetPed) then
            local targetCoordsAfter = GetEntityCoords(targetPed)
            local movedDist = #(targetCoordsBeforeLaunch - targetCoordsAfter)
            if movedDist < 5.0 then
                -- Direct force launch on AFK player
                SetEntityCoords(myPed, targetCoordsAfter.x, targetCoordsAfter.y, targetCoordsAfter.z + 0.3, false, false, false, false)
                Wait(30)
                for j = 1, 5 do
                    if not DoesEntityExist(targetPed) then break end
                    ApplyForceToEntity(targetPed, 1, 0.0, 0.0, 50000.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                    Wait(50)
                end
            end
        end

        Wait(200)
        ClearPedTasksImmediately(myPed)
        SetEntityCoordsNoOffset(myPed, originalCoords.x, originalCoords.y, originalCoords.z + 1.0, false, false, false)
        Wait(100)
        SetEntityCoordsNoOffset(myPed, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
        SetEntityHeading(myPed, originalHeading)
        if teleported then SetEntityVisible(myPed, true, 0) end
    end)
end

function TeleportToFreecam()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) and cam_pos then
        SetEntityCoords(ped, cam_pos.x, cam_pos.y, cam_pos.z, false, false, false, false)
        ShowDynastyNotification("~g~Teleported to Camera!")
    end
end

function HandleInputMenu()
    local scrollValue = GetDisabledControlNormal(0, 14)
    local currentTime = GetGameTimer()
    if lastScrollTime == 0 then
        lastScrollTime = currentTime
        lastScrollValue = scrollValue
    end
    local scrollDelta = scrollValue - lastScrollValue
    if (currentTime - lastScrollTime) > 100 then
        if scrollDelta > 0.1 then
            FreecamSelectedOption = FreecamSelectedOption + 1
            if FreecamSelectedOption > #FreecamOptions then FreecamSelectedOption = 1 end
            lastScrollTime = currentTime
            lastScrollValue = scrollValue
        elseif scrollDelta < -0.1 then
            FreecamSelectedOption = FreecamSelectedOption - 1
            if FreecamSelectedOption < 1 then FreecamSelectedOption = #FreecamOptions end
            lastScrollTime = currentTime
            lastScrollValue = scrollValue
        end
    end
    if math.abs(scrollValue) < 0.05 then lastScrollValue = scrollValue end

    -- Use both Enter and Left-click for context-sensitive validation
    -- Checking both disabled and enabled states for control 24 (Left-click) for absolute reliability.
    local enter_pressed = IsDisabledControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, 201)
    local click_pressed = IsDisabledControlJustPressed(0, 24) or IsControlJustPressed(0, 24)
    local validated = enter_pressed or click_pressed

    if validated and not freecam_just_started and (currentTime - last_click_time) > 150 then
        last_click_time = currentTime
        local name = FreecamOptions[FreecamSelectedOption]
        if name == "Launch" then
            shootVisionActive = false 
            ShowDynastyNotification("~b~Launching Target...")
            FreecamLaunchPlayer()
        elseif name == "Teleport" then
            shootVisionActive = false
            TeleportToFreecam()
        elseif name == "Shoot Vision" then
            if enter_pressed then
                shootVisionActive = not shootVisionActive
                ShowDynastyNotification("Shoot Vision: " .. (shootVisionActive and "~g~ON" or "~r~OFF"))
            elseif click_pressed and not shootVisionActive then
                shootVisionActive = true
                ShowDynastyNotification("Shoot Vision: ~g~ON")
            end
            
            if shootVisionActive then
                local ped = PlayerPedId()
                if not GetAnyAvailableWeapon(ped) then
                    ShowDynastyNotification("~y~Aucune arme trouvée dans l'inventaire")
                end
            end
        end
    end
end

function DrawFreecamHint()
    if not freecam_active then
        if type(Susano.BeginFrame) == "function" then Susano.BeginFrame() end
        if type(Susano.SubmitFrame) == "function" then Susano.SubmitFrame() end
        return
    end
    if type(Susano.BeginFrame) ~= "function" or type(Susano.DrawText) ~= "function" or type(Susano.SubmitFrame) ~= "function" then return end
    Susano.BeginFrame()
    local w, h = GetActiveScreenResolution()
    local cx = w / 2.0
    local options = FreecamOptions
    local selected = FreecamSelectedOption or 1
    local sizeSel, sizeNorm = 22.0, 18.0
    local spacing = 32.0
    local startY = h - 120.0
    local rSel, gSel, bSel = 148/255, 0, 211/255
    local rNorm, gNorm, bNorm = 0.85, 0.85, 0.85
    for i = 1, #options do
        local size = (i == selected) and sizeSel or sizeNorm
        local r, g, b = (i == selected) and rSel or rNorm, (i == selected) and gSel or gNorm, (i == selected) and bSel or bNorm
        local y = startY + (i - 1) * spacing
        local text = options[i]
        if i == selected then text = "> " .. text .. " <" end
        Susano.DrawText(cx - 70.0, y, text, size, r, g, b, 1.0)
    end
    Susano.SubmitFrame()
end

function UpdateFreecam()
    if not freecam_active then return end

    local forward = 0.0
    local sideways = 0.0
    local vertical = 0.0

    if type(Susano.GetAsyncKeyState) == "function" then
        if Susano.GetAsyncKeyState(VK_Z) then forward = 1.0 end
        if Susano.GetAsyncKeyState(VK_S) then forward = -1.0 end
        if Susano.GetAsyncKeyState(VK_D) then sideways = 1.0 end
        if Susano.GetAsyncKeyState(VK_Q) then sideways = -1.0 end
        if Susano.GetAsyncKeyState(VK_SPACE) then vertical = 1.0 end
        if Susano.GetAsyncKeyState(VK_CONTROL) then vertical = -1.0 end

        -- Mouse Wheel Elevation
        local scrollDelta = GetDisabledControlNormal(0, 14)
        if math.abs(scrollDelta) > 0.01 then
            vertical = vertical + (scrollDelta * 5.0) -- Multiply for responsiveness
        end

        local speed = normal_speed
        if Susano.GetAsyncKeyState(VK_SHIFT) then
            speed = fast_speed
        end

        local currentRot = GetGameplayCamRot(2)
        cam_rot = vector3(currentRot.x, currentRot.y, currentRot.z)
        local rad_pitch = math.rad(cam_rot.x)
        local rad_yaw = math.rad(cam_rot.z)

        cam_pos = vector3(
            cam_pos.x + forward * (-math.sin(rad_yaw)) * math.cos(rad_pitch) * speed,
            cam_pos.y + forward * (math.cos(rad_yaw)) * math.cos(rad_pitch) * speed,
            cam_pos.z + forward * (math.sin(rad_pitch)) * speed
        )
        cam_pos = vector3(
            cam_pos.x + sideways * (math.cos(rad_yaw)) * speed,
            cam_pos.y + sideways * (math.sin(rad_yaw)) * speed,
            cam_pos.z
        )
        cam_pos = vector3(cam_pos.x, cam_pos.y, cam_pos.z + vertical * speed)

        ForceWorldLoad()
        if type(Susano.SetCameraPos) == "function" then
            Susano.SetCameraPos(cam_pos.x, cam_pos.y, cam_pos.z)
        end
    end
end

-- Main freecam thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if freecam_active then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 14, true)
            EnableControlAction(0, 15, true)
            EnableControlAction(0, 24, true)

            -- Allow Menu Controls if Open
            if menuOpen then
                EnableControlAction(0, 172, true) -- KEY_UP
                EnableControlAction(0, 173, true) -- KEY_DOWN
                EnableControlAction(0, 174, true) -- KEY_LEFT
                EnableControlAction(0, 175, true) -- KEY_RIGHT
                EnableControlAction(0, 191, true) -- KEY_SELECT
                EnableControlAction(0, 194, true) -- KEY_BACK
            end

            if not menuOpen then
                HandleInputMenu()
            end
            UpdateFreecam()
        end

        DrawFreecamHint()
    end
end)

-- Keybind toggle thread
Citizen.CreateThread(function()
    local lastKeyPress = 0
    while true do
        Citizen.Wait(0)
        
        if type(Susano.GetAsyncKeyState) == "function" then
            local currentKeybind = freecam_keybinds[freecam_keybind_idx]
            if Susano.GetAsyncKeyState(currentKeybind.key) and (GetGameTimer() - lastKeyPress) > 400 then
                lastKeyPress = GetGameTimer()
                ToggleSusanoFreecam()
            end
        end
    end
end)

normal_speed = freecam_speed
fast_speed = freecam_speed * 5.0

-- Toggle from menu
function ToggleSusanoFreecam()
    freecam_active = not freecam_active
    _G.freecam_active = freecam_active
    if freecam_active then
        StartFreecam()
        FreecamSelectedOption = 1
        ShowDynastyNotification("Susano Freecam: ~g~ON")
    else
        StopFreecam()
        ShowDynastyNotification("Susano Freecam: ~r~OFF")
    end
end

-- Redundant Freecam Speed logic removed, using GetMiscOptions dynamic string



local noclipActive = false
-- local noclipSpeed = 1.0 (Removed to fix scope issue)

local function ToggleNoclip()
    if not bypassLoaded and not noclipActive then
        ShowDynastyNotification("~r~Bypass Required!")
        return 
    end
    noclipActive = not noclipActive
    
    if noclipActive then
        Citizen.CreateThread(function()
            local currentSpeed = noclipSpeed or 1.0
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
                
                local moveSpeed = currentSpeed
                if IsDisabledControlPressed(0, 21) then
                    moveSpeed = currentSpeed * 2.5
                end
                
                local newPos = coords
                
                if IsDisabledControlPressed(0, 32) then
                    newPos = vector3(newPos.x + vx * moveSpeed, newPos.y + vy * moveSpeed, newPos.z + vz * moveSpeed)
                end
                
                if IsDisabledControlPressed(0, 33) then
                    newPos = vector3(newPos.x - vx * moveSpeed, newPos.y - vy * moveSpeed, newPos.z - vz * moveSpeed)
                end
                
                if IsDisabledControlPressed(0, 34) then
                    newPos = vector3(newPos.x - rx * moveSpeed, newPos.y - ry * moveSpeed, newPos.z)
                end
                
                if IsDisabledControlPressed(0, 35) then
                    newPos = vector3(newPos.x + rx * moveSpeed, newPos.y + ry * moveSpeed, newPos.z)
                end
                
                if IsDisabledControlPressed(0, 22) then
                    newPos = vector3(newPos.x, newPos.y, newPos.z + moveSpeed)
                end
                
                if IsDisabledControlPressed(0, 36) then
                    newPos = vector3(newPos.x, newPos.y, newPos.z - moveSpeed)
                end
                
                SetEntityCoordsNoOffset(entity, newPos.x, newPos.y, newPos.z, true, true, true)
                
                if entity == ped then
                    SetEntityHeading(ped, camRot.z)
                end
                
                Citizen.Wait(0)
            end
            
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


-- Anti Freeze thread
-- Anti Freeze thread (Fixed: Only clear tasks ONCE, loop unfreeze state)
Citizen.CreateThread(function()
    local wasActive = false
    while true do
        if antiFreezeActive and not noclipActive and not freecam_active then
            local ped = PlayerPedId()
            
            -- On First Activation: Clear Tasks Once
            if not wasActive then
                 if DoesEntityExist(ped) then 
                    ClearPedTasksImmediately(ped) 
                    ShowDynastyNotification("Unfreeze Executed (Anti-Freeze Active)")
                 end
                 wasActive = true
            end
            
            if DoesEntityExist(ped) then
                -- Aggressive Unfreeze (Every Frame) to beat Admin Tools
                FreezeEntityPosition(ped, false)
                SetEntityCollision(ped, true, true)
                
                -- Detach if attached (e.g. carried)
                if IsEntityAttached(ped) then
                    DetachEntity(ped, true, true)
                end
                
                -- Enable Controls (In case blocked)
                EnableControlAction(0, 30, true) -- Move X
                EnableControlAction(0, 31, true) -- Move Y
                EnableControlAction(0, 21, true) -- Sprint
                EnableControlAction(0, 23, true) -- Enter Veh
                EnableControlAction(0, 75, true) -- Exit Veh
                
                local veh = GetVehiclePedIsIn(ped, false)
                if veh and veh ~= 0 then
                    FreezeEntityPosition(veh, false)
                    SetEntityCollision(veh, true, true)
                end
            end
        else
            wasActive = false
        end
        Citizen.Wait(0) -- Loop interval (Aggressive)
    end
end)

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
        
        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        
        -- Performance & Cosmetics (Loop all except Livery/Stickers)
        SetVehicleModKit(veh, 0)
        for i = 0, 49 do
            if i ~= 48 then -- Skip Livery/Stickers
                local numMods = GetNumVehicleMods(veh, i)
                if numMods > 0 then
                    SetVehicleMod(veh, i, numMods - 1, false)
                end
            end
        end

        -- Toggles
        ToggleVehicleMod(veh, 18, true) -- Turbo
        ToggleVehicleMod(veh, 20, true) -- Tire Smoke
        ToggleVehicleMod(veh, 22, true) -- Xenon

        -- Colors (Optional: Set to nice colors or keep?)
        -- User said "full custom". Usually implies maxing stats.
        -- We won't change paint colors forceably unless requested, but we set neon/xenon.
        
        -- Neon
        SetVehicleNeonLightEnabled(veh, 0, true)
        SetVehicleNeonLightEnabled(veh, 1, true)
        SetVehicleNeonLightEnabled(veh, 2, true)
        SetVehicleNeonLightEnabled(veh, 3, true)
        SetVehicleNeonLightsColour(veh, 255, 0, 255) -- Purple (Dynasty style)
        
        -- Max Stats
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        
        SetVehicleWindowTint(veh, 1) -- Pure Black
        
        ShowDynastyNotification("Vehicle: ~g~MAX UPGRADED ~p~(Full Custom - No Stickers)")
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
        
        for i = -1, maxSeats - 1 do
            local passenger = GetPedInVehicleSeat(veh, i)
            if passenger ~= 0 and passenger ~= ped and DoesEntityExist(passenger) then
                TaskLeaveVehicle(passenger, veh, 4160)
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
    ShowDynastyNotification("~g~Carry activÃ©! ~p~E~w~ = Porter/Lancer")

    CreateThread(function()
        while carryActive do
            if not carriedVehicle then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Porter vÃ©hicule")
                EndTextCommandDisplayHelp(0, false, true, -1)
            else
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Lancer vÃ©hicule")
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
                        ShowDynastyNotification("~g~VÃ©hicule portÃ©!")
                    else
                        ShowDynastyNotification("~r~Aucun vÃ©hicule proche!")
                    end
                else
                    DetachEntity(carriedVehicle, true, true)
                    local ped = PlayerPedId()
                    local forward = GetEntityForwardVector(ped)
                    SetEntityVelocity(carriedVehicle, forward.x * 150, forward.y * 150, 80.0)
                    ApplyForceToEntity(carriedVehicle, 1, 0, 0, 0, math.random(-50, 50), math.random(-50, 50), math.random(-50, 50), 0, false, true, true, false, true)
                    SetEntityCollision(carriedVehicle, true, true)
                    ShowDynastyNotification("~r~ðŸš€ LANCÃ‰!")
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
    ShowDynastyNotification("~r~Carry dÃ©sactivÃ©!")
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

            if not throwCarriedVehicle then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Pick up vehicle")
                EndTextCommandDisplayHelp(0, false, true, -1)
            else
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName("~p~[E]~w~ Throw vehicle")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end

            if IsControlJustPressed(0, 51) then
                local ped = PlayerPedId()

                if not throwCarriedVehicle then
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
                    DetachEntity(throwCarriedVehicle, true, true)
                    local forward = GetEntityForwardVector(ped)
                    SetEntityVelocity(throwCarriedVehicle, forward.x * 150.0, forward.y * 150.0, 80.0)
                    ApplyForceToEntity(throwCarriedVehicle, 1, 0.0, 0.0, 0.0, math.random(-50, 50) + 0.0, math.random(-50, 50) + 0.0, math.random(-50, 50) + 0.0, 0, false, true, true, false, true)
                    SetEntityCollision(throwCarriedVehicle, true, true)
                    ShowDynastyNotification("~r~ðŸš€ THROWN!")
                    throwCarriedVehicle = nil
                end
            end
        end

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

local lunchingActive = false
local cachedReturnCoords = nil

local function ToggleSusanoFreecam()
    if _G.freecam_active then
        if type(StopFreecam) == "function" then
            StopFreecam()
        end
        ShowDynastyNotification("Freecam: ~r~OFF")
    else
        if type(StartFreecam) == "function" then
            StartFreecam()
        else
            ShowDynastyNotification("~r~Freecam not available")
            return
        end
        ShowDynastyNotification("Freecam: ~g~ON ~w~(H to toggle)")
    end
end

local freecamSpeedOptions = {0.1, 0.25, 0.5, 1.0, 2.0, 5.0}
local freecamSpeedIdx = 3

local function ChangeSusanoFreecamSpeed()
    freecamSpeedIdx = (freecamSpeedIdx % #freecamSpeedOptions) + 1
    local newSpeed = freecamSpeedOptions[freecamSpeedIdx]
    _G.freecam_speed = newSpeed
    if type(SetFreecamSpeed) == "function" then
        SetFreecamSpeed(newSpeed)
    end
    ShowDynastyNotification("Freecam Speed: ~b~" .. tostring(newSpeed))
end

local function ChangeSusanoFreecamKeybind()
    ShowDynastyNotification("Freecam Keybind: ~b~H ~w~(fixed)")
end

local function LaunchPlayer()
    if not bypassLoaded then ShowDynastyNotification("~r~Bypass Required!") return end
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
        
        if not lunchingActive then
            cachedReturnCoords = myCoords
            lunchingActive = true
        end
        
        local returnCoords = cachedReturnCoords or myCoords
        local targetCoords = GetEntityCoords(targetPed)

        if returnCoords and targetCoords then
            local angle = math.random() * 2 * math.pi
            local radiusOffset = math.random(5, 9)
            local xOffset = math.cos(angle) * radiusOffset
            local yOffset = math.sin(angle) * radiusOffset
            local newCoords = vector3(targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z)
            
            SetEntityCoordsNoOffset(myPed, newCoords.x, newCoords.y, newCoords.z, false, false, false)
            SetEntityVisible(myPed, false, 0)
            Wait(100)

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

            ClearPedTasksImmediately(myPed)
            if returnCoords then
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z + 1.0, false, false, false, false)
                Wait(100)
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z, false, false, false, false)
            end
            SetEntityVisible(myPed, true, 0)
            
            lunchingActive = false
            
            -- Notification removed
        end
    end)
end

local function LunchPlayer2()
    if not bypassLoaded then ShowDynastyNotification("~r~Bypass Required!") return end
    local myPed = PlayerPedId()
    if not myPed then return end

    local targetPed = nil

    -- Si freecam active: raycast depuis la camera pour trouver la cible
    if _G.freecam_active and _G.cam_pos and _G.cam_rot then
        local pitch = math.rad(_G.cam_rot.x)
        local yaw = math.rad(_G.cam_rot.z)
        local dirX = -math.sin(yaw) * math.cos(pitch)
        local dirY = math.cos(yaw) * math.cos(pitch)
        local dirZ = math.sin(pitch)
        local raycastStart = _G.cam_pos
        local raycastEnd = vector3(
            _G.cam_pos.x + dirX * 1000.0,
            _G.cam_pos.y + dirY * 1000.0,
            _G.cam_pos.z + dirZ * 1000.0
        )
        local raycast = StartExpensiveSynchronousShapeTestLosProbe(
            raycastStart.x, raycastStart.y, raycastStart.z,
            raycastEnd.x, raycastEnd.y, raycastEnd.z,
            -1, myPed, 7
        )
        local _, hit, _, _, entityHit = GetShapeTestResult(raycast)
        if hit and entityHit and DoesEntityExist(entityHit) then
            -- Verifier si c'est un joueur
            for _, playerId in ipairs(GetActivePlayers()) do
                if GetPlayerPed(playerId) == entityHit then
                    targetPed = entityHit
                    break
                end
            end
            -- Si c'est un vehicule, viser le conducteur
            if not targetPed and IsEntityAVehicle(entityHit) then
                local driver = GetPedInVehicleSeat(entityHit, -1)
                if driver and driver ~= 0 and DoesEntityExist(driver) then
                    for _, playerId in ipairs(GetActivePlayers()) do
                        if GetPlayerPed(playerId) == driver then
                            targetPed = driver
                            break
                        end
                    end
                end
            end
        end
        if not targetPed then
            ShowDynastyNotification("~r~No player in crosshair")
            return
        end
    else
        -- Mode normal: utiliser le joueur selectionne
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
        targetPed = GetPlayerPed(clientId)
        if not targetPed or not DoesEntityExist(targetPed) then
            ShowDynastyNotification("~r~Target invalid")
            return
        end
    end

    CreateThread(function()
        local myCoords = GetEntityCoords(myPed)

        if not lunchingActive then
            cachedReturnCoords = myCoords
            lunchingActive = true
        end

        local returnCoords = cachedReturnCoords or myCoords
        local targetCoords = GetEntityCoords(targetPed)

        if returnCoords and targetCoords then
            -- Request network control de la cible pour pouvoir la bouger
            NetworkRequestControlOfEntity(targetPed)
            local attempts = 0
            while not NetworkHasControlOfEntity(targetPed) and attempts < 30 do
                NetworkRequestControlOfEntity(targetPed)
                Wait(10)
                attempts = attempts + 1
            end

            -- TP a cote de la cible
            local angle = math.random() * 2 * math.pi
            local radiusOffset = math.random(5, 9)
            local xOffset = math.cos(angle) * radiusOffset
            local yOffset = math.sin(angle) * radiusOffset
            local newCoords = vector3(targetCoords.x + xOffset, targetCoords.y + yOffset, targetCoords.z)

            SetEntityCoordsNoOffset(myPed, newCoords.x, newCoords.y, newCoords.z, false, false, false)
            SetEntityVisible(myPed, false, 0)
            Wait(100)

            -- Forcer le ragdoll sur la cible (fix AFK)
            NetworkRequestControlOfEntity(targetPed)
            SetPedToRagdoll(targetPed, 5000, 5000, 0, false, false, false)
            Wait(50)

            local curTargetCoords = GetEntityCoords(targetPed)
            if curTargetCoords then
                ClearPedTasksImmediately(myPed)
                SetEntityCoords(myPed, curTargetCoords.x, curTargetCoords.y, curTargetCoords.z + 0.5, false, false, false, false)
                Wait(50)

                -- Attach + detach avec force
                for i = 1, 10 do
                    if not DoesEntityExist(targetPed) then break end
                    curTargetCoords = GetEntityCoords(targetPed)
                    SetEntityCoords(myPed, curTargetCoords.x, curTargetCoords.y, curTargetCoords.z + 0.5, false, false, false, false)
                    Wait(30)
                    AttachEntityToEntityPhysically(myPed, targetPed, 0, 0.0, 0.0, 0.0, 150.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, false, false, 1, 2)
                    Wait(30)
                    DetachEntity(myPed, true, true)

                    -- Appliquer une velocite vers le haut sur la cible (fix AFK)
                    NetworkRequestControlOfEntity(targetPed)
                    if NetworkHasControlOfEntity(targetPed) then
                        SetEntityVelocity(targetPed, 0.0, 0.0, 300.0)
                    end
                    Wait(50)
                end
            end

            ClearPedTasksImmediately(myPed)
            if returnCoords then
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z + 1.0, false, false, false, false)
                Wait(100)
                SetEntityCoords(myPed, returnCoords.x, returnCoords.y, returnCoords.z, false, false, false, false)
            end
            SetEntityVisible(myPed, true, 0)

            lunchingActive = false

            -- Notification removed
        end
    end)
end

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
            SetEntityCollision(ped, true, true)
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
    -- Notification removed
end

local spectateActive = false

local function AttachPlayerToMe(id)
    if not id then return end

    local ped = GetPlayerPed(id)
    if DoesEntityExist(ped) then
        if attachedPlayers[id] then
            DetachPlayer(id)
        else
            attachedPlayers[id] = ped
            originalCoords[id] = GetEntityCoords(ped)
            
            SetEntityCollision(ped, false, false)
            
            -- Thread to keep them attached
            CreateThread(function()
                while attachedPlayers[id] and DoesEntityExist(attachedPlayers[id]) do
                    local myPed = PlayerPedId()
                    local myCoords = GetEntityCoords(myPed)
                    local myForward = GetEntityForwardVector(myPed)
                    
                    -- Attach in front
                    local attachPos = myCoords + (myForward * 0.5) + vector3(0, 0, 0.5)
                    
                    SetEntityCoordsNoOffset(attachedPlayers[id], attachPos.x, attachPos.y, attachPos.z, false, false, false)
                    SetEntityHeading(attachedPlayers[id], GetEntityHeading(myPed))
                    Wait(0)
                end
            end)
            
            -- Notification removed
        end
    else
        ShowDynastyNotification("~r~Player not found (too far?)")
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

local function ResetOutfit()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(ped)
    ShowDynastyNotification("Outfit Reset")
end

local spectateActive = false

local function ToggleSpectate(enable)
    if not bypassLoaded then ShowDynastyNotification("~r~Bypass Required!") return end
    if not selectedPlayer then return end
    
    if enable then
        spectateActive = true
        CreateThread(function()
            local ped = PlayerPedId()
            
            -- Susano Lock Camera
            if type(Susano) == "table" and type(Susano.LockCameraPos) == "function" then
                Susano.LockCameraPos(true)
            end
            
            while spectateActive do
                local targetPed = GetPlayerPed(selectedPlayer.id)
                if DoesEntityExist(targetPed) then
                    local tCoords = GetEntityCoords(targetPed)
                    
                    -- Smoothly follow the target
                    SetFocusPosAndVel(tCoords.x, tCoords.y, tCoords.z, 0.0, 0.0, 0.0)
                    
                    if type(Susano) == "table" and type(Susano.SetCameraPos) == "function" then
                        local forward = GetEntityForwardVector(targetPed)
                        local camPos = tCoords - (forward * 3.5) + vector3(0.0, 0.0, 1.5)
                        Susano.SetCameraPos(camPos.x, camPos.y, camPos.z)
                    end
                end
                Wait(0)
            end
            
            -- Cleanup
            if type(Susano) == "table" and type(Susano.LockCameraPos) == "function" then
                Susano.LockCameraPos(false)
            end
            ClearFocus()
        end)
    else
        spectateActive = false
    end
end

local function TeleportToPlayer()
    if not bypassLoaded then ShowDynastyNotification("~r~Bypass Required!") return end
    if not selectedPlayer then return end
    local targetPed = GetPlayerPed(selectedPlayer.id)
    
    -- Direct method
    if DoesEntityExist(targetPed) then
        local coords = GetEntityCoords(targetPed)
        if coords ~= vector3(0,0,0) then
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 1.0, false, false, false, false)
            -- Notification removed
            return
        end
    end

    -- Indirect method: Spectate to load
    ShowDynastyNotification("~y~Target not streamed, forcing load...")
    
    NetworkSetInSpectatorMode(true, targetPed)
    
    CreateThread(function()
        local attempts = 0
        while attempts < 20 do
            Wait(100)
            if DoesEntityExist(targetPed) then
                local coords = GetEntityCoords(targetPed)
                if coords ~= vector3(0,0,0) then
                    NetworkSetInSpectatorMode(false, targetPed)
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 1.0, false, false, false, false)
                    -- Notification removed
                    return
                end
            end
            attempts = attempts + 1
        end
        NetworkSetInSpectatorMode(false, targetPed)
        ShowDynastyNotification("~r~Failed to load target")
    end)
end

local function ToggleBlackHole()
    blackHoleActive = not blackHoleActive

    if not blackHoleActive then
        if _G.black_hole_active then
            _G.black_hole_active = false
            _G.black_hole_vehicles = {}
            _G.black_hole_target_player = nil
        end
        -- Notification removed
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

            -- Notification removed

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

    local myPed = PlayerPedId()

    -- Try Pulse/Susano Injection first for perfect clone
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
                local myPed = PlayerPedId()
                if DoesEntityExist(targetPed) and DoesEntityExist(myPed) then
                    ClonePedToTarget(targetPed, myPed)
                end
            end
         ]], selectedPlayer.serverId))
         -- Notification removed
         return
    end

    -- Manual Fallback
    
    -- Copy Components
    for i = 0, 11 do
        local drawable = GetPedDrawableVariation(targetPed, i)
        local texture = GetPedTextureVariation(targetPed, i)
        local palette = GetPedPaletteVariation(targetPed, i)
        SetPedComponentVariation(myPed, i, drawable, texture, palette)
    end

    -- Copy Props
    for i = 0, 7 do
        local propIndex = GetPedPropIndex(targetPed, i)
        local propTexture = GetPedPropTextureIndex(targetPed, i)
        if propIndex ~= -1 then
            SetPedPropIndex(myPed, i, propIndex, propTexture, true)
        else
            ClearPedProp(myPed, i)
        end
    end

    -- Copy Skin / Head Blend
    local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = GetPedHeadBlendData(targetPed)
    SetPedHeadBlendData(myPed, shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix, false)

    -- Copy Hair Color
    SetPedHairColor(myPed, GetPedHairColor(targetPed), GetPedHairHighlightColor(targetPed))
    SetPedEyeColor(myPed, GetPedEyeColor(targetPed))

    -- Copy Head Overlays (Makeup, Eyebrows etc)
    for i = 0, 12 do
        local success, overlayValue, colourType, firstColour, secondColour, opacity = GetPedHeadOverlayData(targetPed, i)
        if success then
            SetPedHeadOverlay(myPed, i, overlayValue, opacity)
            SetPedHeadOverlayColor(myPed, i, colourType, firstColour, secondColour)
        end
    end

    -- Copy Face Features
    for i = 0, 19 do
        local val = GetPedFaceFeature(targetPed, i)
        SetPedFaceFeature(myPed, i, val)
    end

    -- Notification removed
end

local fovWarpActive = false

local function ToggleFOVWarp()
    fovWarpActive = not fovWarpActive
    
    if fovWarpActive then
        ShowDynastyNotification("FOV Warp: ~g~ON~w~ | Press ~p~E~w~ to warp")
        
        CreateThread(function()
            if not HasStreamedTextureDictLoaded("commonmenu") then
                RequestStreamedTextureDict("commonmenu", true)
            end

            while fovWarpActive do
                Wait(0)
                
                -- FOV Circle (Black Transparent Round - BIG)
                if not HasStreamedTextureDictLoaded("commonmenu") then
                    RequestStreamedTextureDict("commonmenu", true)
                end
                
                local aspect = GetAspectRatio(false)
                local scale = 0.42
                
                if not HasStreamedTextureDictLoaded("mp_inventory") then
                    RequestStreamedTextureDict("mp_inventory", true)
                end
                
                if HasStreamedTextureDictLoaded("mp_inventory") then
                    -- Draw the ring (contour only)
                    -- Black, semi-transparent (120 alpha)
                    DrawSprite("mp_inventory", "tab_selector", 0.5, 0.5, scale / aspect, scale, 0.0, 0, 0, 0, 120)
                end

                if IsControlJustPressed(0, 51) then -- E key
                    local playerPed = PlayerPedId()
                    local camCoords = GetGameplayCamCoord()
                    
                    if not HasStreamedTextureDictLoaded("commonmenu") then
                        RequestStreamedTextureDict("commonmenu", true)
                    end

                    -- Find closest vehicle/entity within FOV circle
                    local screenW, screenH = GetActiveScreenResolution()
                    local centerX, centerY = 0.5, 0.5
                    local aspect = GetAspectRatio(false)
                    local scale = 0.45 -- Circle Scale
                    
                    local vehicles = (type(GetGamePool) == "function" and GetGamePool("CVehicle")) or {}
                    local bestTarget = nil
                    local minDistanceToCenter = scale / 2.0
                    
                    if type(vehicles) == "table" then
                        for _, veh in ipairs(vehicles) do
                            if DoesEntityExist(veh) then
                                local vCoords = GetEntityCoords(veh)
                                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(vCoords.x, vCoords.y, vCoords.z)
                                
                                if onScreen then
                                    local dx = (screenX - centerX) * aspect
                                    local dy = screenY - centerY
                                    local dist = math.sqrt(dx*dx + dy*dy)
                                    
                                    if dist < minDistanceToCenter then
                                        minDistanceToCenter = dist
                                        bestTarget = veh
                                    end
                                end
                            end
                        end
                    end

                    if bestTarget then
                         -- Advanced Hijack (Warp Logic)
                        local targetVeh = bestTarget
                        local driver = GetPedInVehicleSeat(targetVeh, -1)
                        
                        -- 1. Passenger
                        SetPedIntoVehicle(playerPed, targetVeh, 0) 
                        Wait(100)
                        
                        -- 2. Kick Driver
                        if driver ~= 0 and DoesEntityExist(driver) and driver ~= playerPed then
                            ClearPedTasksImmediately(driver)
                            Wait(50)
                            SmashVehicleWindow(targetVeh, 0)
                            SmashVehicleWindow(targetVeh, 1)
                            DeleteEntity(driver)
                            Wait(100)
                        end
                        
                        -- 3. Take Driver Seat
                        SetPedIntoVehicle(playerPed, targetVeh, -1)
                        ShowDynastyNotification("~g~Vehicle Hijacked!")
                    end
                end
            end
        end)
    else
        ShowDynastyNotification("FOV Warp: ~r~OFF")
    end
end

local staffModeActive = false

local function ToggleStaffMode()
    staffModeActive = not staffModeActive
    if staffModeActive then
        ShowDynastyNotification("Staff Mode: ~g~ON ~w~(Shoot player to open menu)")
        
        CreateThread(function()
            while staffModeActive do
                Wait(0)
                local ped = PlayerPedId()
                if IsPedShooting(ped) then
                    local found, coords = GetPedLastWeaponImpactCoord(ped)
                    if found then
                        local peds = GetGamePool("CPed")
                        local closestPed = nil
                        local minDst = 2.0
                        for _, p in ipairs(peds) do
                            if p ~= ped and IsPedAPlayer(p) then
                                local dst = #(GetEntityCoords(p) - coords)
                                if dst < minDst then
                                    minDst = dst
                                    closestPed = p
                                end
                            end
                        end
                        
                        if closestPed then
                            local pId = NetworkGetPlayerIndexFromPed(closestPed)
                            local sId = GetPlayerServerId(pId)
                            local name = GetPlayerName(pId)
                            
                            selectedPlayer = {
                                id = pId,
                                serverId = sId,
                                name = name
                            }
                            currentMenu = "TROLL"
                            selectedOption = 1 -- Fix: use correct variable
                            startIndex = 1
                            menuOpen = true -- Open the menu!
                            menuAlpha = 1.0
                            ShowDynastyNotification("Selected: ~b~" .. name)
                            Wait(500)
                        end
                    end
                end
            end
        end)
    else
        ShowDynastyNotification("Staff Mode: ~r~OFF")
    end
end


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

        if not success then
            ShowDynastyNotification("~r~Bypass error: " .. tostring(err))
        else
            bypassLoaded = true
            _G.PutinBypassActive__ = true -- Set global flag for persistence
            ShowDynastyNotification("~g~Bypass Loaded [OK]")
        end
    end)
end

-- GetSettingsOptions Moved below Menu init

-- Banner Texture State
Menu = Menu or {} -- Ensure table exists
local bannerTex, bannerW, bannerH = nil, 0, 0
local bannerLoading = false
local bannerCurrentUrl = nil
local bannerTextureCache = {}

Menu.Banner = {
    enabled = true,
    imageUrl = "https://i.imgur.com/wnfIaIg.jpeg",
    height = 92
}

Menu.Colors = Menu.Colors or {}

function Menu.PreloadBanners()
    Citizen.CreateThread(function()
        if not Susano or type(Susano.HttpGet) ~= "function" or type(Susano.LoadTextureFromBuffer) ~= "function" then return end
        
        for _, b in ipairs(Menu.AvailableBanners) do
            local url = b.url
            if url and not bannerTextureCache[url] then
                local status, data = Susano.HttpGet(url)
                if status == 200 and data and #data > 0 then
                    local tex, w, h = Susano.LoadTextureFromBuffer(data)
                    if tex then
                        bannerTextureCache[url] = { tex = tex, w = w, h = h }
                        if bannerCurrentUrl == url and not bannerTex then
                            bannerTex, bannerW, bannerH = tex, w, h
                        end
                    end
                end
            end
        end
    end)
end

function Menu.LoadBannerTexture(url)
    if not url then return end
    bannerCurrentUrl = url
    
    if bannerTextureCache[url] then
        bannerTex = bannerTextureCache[url].tex
        bannerW = bannerTextureCache[url].w
        bannerH = bannerTextureCache[url].h
        bannerLoading = false
        return
    end

    if bannerLoading then return end
    bannerLoading = true
    bannerTex = nil 

    Citizen.CreateThread(function()
        -- Download Image
        if Susano and type(Susano.HttpGet) == "function" and type(Susano.LoadTextureFromBuffer) == "function" then
            local status, data = Susano.HttpGet(url)
            
            if status == 200 and data and #data > 0 then
                -- Load from Buffer (Memory)
                local tex, w, h = Susano.LoadTextureFromBuffer(data)
                if tex then
                    bannerTextureCache[url] = { tex = tex, w = w, h = h }
                    if bannerCurrentUrl == url then
                        bannerTex, bannerW, bannerH = tex, w, h
                    end
                else
                    print("[Menu] Failed to create texture from buffer.")
                end
            else
                print("[Menu] HTTP Get failed: " .. tostring(status))
            end
        else
            print("[Menu] Susano/HttpGet/LoadTextureFromBuffer missing.")
        end
        
        bannerLoading = false
    end)
end

-- Theme & Banner State
Menu.ThemeIndex = 1
Menu.BannerIndex = 1
Menu.AvailableThemes = {"Purple", "Red", "Purple 1", "Sabry"}
Menu.AvailableBanners = {
    {name="Gengar", url="https://i.imgur.com/wnfIaIg.jpeg"},
    {name="Red Style", url="https://i.imgur.com/L9M3sir.png"},
    {name="Gengar 2", url="https://i.imgur.com/XABOGma.jpeg"},
    {name="Sabry", url="https://i.imgur.com/jtzj4am.jpeg"}
}

function Menu.ApplyTheme(themeName)
    if themeName == "Red" then
        Menu.Colors.HeaderPink = { r = 255, g = 0, b = 0, a = 0.35 }
        Menu.Colors.SelectedBg  = { r = 255, g = 0, b = 0, a = 0.35 }
    elseif themeName == "Purple 1" then
        Menu.Colors.HeaderPink = { r = 20, g = 20, b = 80 }
        Menu.Colors.SelectedBg  = { r = 20, g = 20, b = 80 }
    elseif themeName == "Purple" then
        Menu.Colors.HeaderPink = { r = 148, g = 0, b = 211 } 
        Menu.Colors.SelectedBg  = { r = 148, g = 0, b = 211 }
    elseif themeName == "Sabry" then
        Menu.Colors.HeaderPink = { r = 50, g = 50, b = 50 }
        Menu.Colors.SelectedBg = { r = 50, g = 50, b = 50 }
    end
end

local function GetSettingsOptions()
    local themeName = Menu.AvailableThemes[Menu.ThemeIndex] or "Purple"
    local bannerName = Menu.AvailableBanners[Menu.BannerIndex] and Menu.AvailableBanners[Menu.BannerIndex].name or "Custom"

    return {
        "Menu Size: " .. string.format("%.2f", _G.menuScale),
        "Reset Size",
        "Color: " .. themeName,
        "Banner: " .. bannerName
    }
end

local gengarTex, gengarW, gengarH

local cachedPlayerList = {}
local lastPlayerListUpdate = 0

local function GetCachedPlayerList()
    local success, result = pcall(function()
        local currentTime = GetGameTimer()
        if currentTime - lastPlayerListUpdate < 400 and #cachedPlayerList > 0 then
            return cachedPlayerList
        end
        
        lastPlayerListUpdate = currentTime
        local players = GetActivePlayers()
        local pCoords = GetEntityCoords(PlayerPedId())
        
        local list = {}
        if players then
            for i = 1, #players do
                local pid = players[i]
                if pid ~= PlayerId() then -- Skip self
                    local ped = GetPlayerPed(pid)
                    local exists = DoesEntityExist(ped)
                    local coords = vector3(0,0,0)
                    local dist = 99999
                    local distStr = "Far"
                    
                    if exists then
                        coords = GetEntityCoords(ped)
                        local pCoords = GetEntityCoords(PlayerPedId())
                        dist = #(pCoords - coords)
                        distStr = math.floor(dist) .. "m"
                    end

                    local pName = GetPlayerName(pid) or ("Player " .. pid)
                    if not onlineFilterVehicles or (exists and IsPedInAnyVehicle(ped, false)) then
                        table.insert(list, {
                            name = pName .. " [" .. distStr .. "]", 
                            id = pid, 
                            serverId = GetPlayerServerId(pid) or 0,
                            dist = dist or 0
                        })
                    end
                end
            end
            table.sort(list, function(a,b) return (a.dist or 0) < (b.dist or 0) end)
        end
        return list
    end)

    if success then
        cachedPlayerList = result
        return result
    else
        ShowDynastyNotification("~r~List Error: " .. tostring(result)) -- Debug
        return cachedPlayerList
    end
end

-- Alias for compatibility (Fixes 'launch un joueur au pif' mismatch)
local GetDisplayedPlayerList = GetCachedPlayerList -- Ensures logic uses same list as render

Citizen.CreateThread(function()
    -- Preload ALL banners in the background so switching is instant
    if Menu.PreloadBanners then Menu.PreloadBanners() end

    -- Preload banner depuis URL au démarrage (IMMEDIAT)
    if Menu.ApplyTheme then Menu.ApplyTheme("Purple") end -- Force Theme Purple by default
    
    if Menu.Banner.enabled and Menu.Banner.imageUrl then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end

    -- Load Custom Font (Remote - Roboto Bold)
    Citizen.CreateThread(function()
        if Susano and type(Susano.HttpGet) == "function" and type(Susano.LoadFontFromBuffer) == "function" then
            -- Use confirmed working mirror for Roboto Bold
            local fontUrl = "https://raw.githubusercontent.com/openmaptiles/fonts/master/roboto/Roboto-Bold.ttf"
            local status, data = Susano.HttpGet(fontUrl)
            
            if status == 200 and data and #data > 0 then
                local id, err = Susano.LoadFontFromBuffer(data, 20)
                if id then
                    _G.menuFontId = id
                else
                    print("[Menu] Remoto Font Load Fail (Buffer): " .. tostring(err))
                end
            else
                print("[Menu] Remote Font Download Fail: " .. tostring(status))
            end
        end
    end)
end)


local function RenderMenu()
    if not menuOpen and menuAlpha <= 0 then return end

    menuAlpha = menuOpen and math.min(menuAlpha + 20, 255) or math.max(menuAlpha - 20, 0)
    local a = menuAlpha

    local sw, sh = GetActiveScreenResolution()
    
    -- Dynamic Resolution Scaling Factor (baseline 1080p)
    local resScale = string.format("%.2f", sh / 1080.0) 
    local menuScale = (_G.menuScale or 1.0) * resScale

    local baseX = 0.13
    local menuWidth = 0.14 * menuScale -- Reduced from 0.20 to match screen
    local optionHeight = 0.035 * menuScale
    local headerImgHeight = 0.12 * menuScale
    local titleBarHeight = 0.03 * menuScale
    local headerTotalHeight = headerImgHeight + titleBarHeight
    local headerTopY = 0.08
    local imgCenterY = headerTopY + headerImgHeight / 2
    local titleBarY = headerTopY + headerImgHeight + titleBarHeight / 2

    -- Calculate pixel coordinates for Susano
    local x_px = (baseX - menuWidth/2) * sw
    local y_px = headerTopY * sh
    local w_px = menuWidth * sw
    local h_px = headerImgHeight * sh
    
    -- Draw Header Background (Black)
    if Susano and Susano.DrawRectFilled then
        -- DrawRectFilled(x, y, w, h, r, g, b, a, rounding)
        Susano.DrawRectFilled(x_px, y_px, w_px, h_px, 0, 0, 0, 1.0, 10)
    else
        -- Fallback Native
        DrawRect(baseX, imgCenterY, menuWidth, headerImgHeight, 0, 0, 0, 255)
    end

    -- Draw Banner (priority: bannerTex > gengarTex)
    if bannerTex and Susano and Susano.DrawImage then
        local imgW = w_px * (_G.headerImgScaleW or 1.0)
        local imgH = h_px * (_G.headerImgScaleH or 1.0)
        local imgX = x_px + (w_px - imgW) / 2
        local imgY = y_px + (h_px - imgH) / 2
        Susano.DrawImage(bannerTex, imgX, imgY, imgW, imgH, 1,1,1,1, 10, 0,0,1,1)
    elseif gengarTex and Susano and Susano.DrawImage then
        local imgW = w_px * (_G.headerImgScaleW or 1.0)
        local imgH = h_px * (_G.headerImgScaleH or 1.0)
        local imgX = x_px + (w_px - imgW) / 2
        local imgY = y_px + (h_px - imgH) / 2
        Susano.DrawImage(gengarTex, imgX, imgY, imgW, imgH, 1,1,1,1, 10, 0,0,1,1)
    end
    
    -- Draw Tab Bar for Player/Wardrobe or Online/Vehicles
    if currentMenu == "PLAYER" or currentMenu == "WARDROBE" or currentMenu == "ONLINE" then
        local tabY = y_px + h_px
        local tabH = titleBarHeight * sh
        
        -- Draw Tab Bar Background
        if Susano and Susano.DrawRectFilled then
             Susano.DrawRectFilled(x_px, tabY, w_px, tabH, 0, 0, 0, 0.85, 0)
        else
             DrawRect(baseX, titleBarY, menuWidth, titleBarHeight, 0, 0, 0, 200)
        end
        
        -- Draw tabs
        if Susano and Susano.DrawText then
            local fontSize = 16 * _G.menuScale
            local offY = tabY + (tabH - fontSize)/2
            
            local tabs, activeLayout
            if currentMenu == "ONLINE" then
                tabs = {"Players", "Vehicles"}
                activeLayout = onlineFilterVehicles and 2 or 1
            else
                tabs = {"Player", "Wardrobe"}
                activeLayout = (currentMenu == "WARDROBE") and 2 or 1
            end
            
            -- Calculate widths
            local t1W = Susano.GetTextWidth(tabs[1], fontSize)
            local t2W = Susano.GetTextWidth(tabs[2], fontSize)
            local gap = 20 * _G.menuScale
            local totalW = t1W + gap + t2W
            local startX = x_px + (w_px - totalW)/2
            
            -- Draw Tab 1
            local alpha1 = (activeLayout == 1) and 1.0 or 0.5
            Susano.DrawText(startX, offY, tabs[1], fontSize, 1, 1, 1, alpha1)
            
            -- Draw Tab 2
            local alpha2 = (activeLayout == 2) and 1.0 or 0.5
            Susano.DrawText(startX + t1W + gap, offY, tabs[2], fontSize, 1, 1, 1, alpha2)
            
            -- Highlight Line
            local hlX = (activeLayout == 1) and startX or (startX + t1W + gap)
            local hlW = (activeLayout == 1) and t1W or t2W
            local hlR, hlG, hlB = (Menu.Colors.SelectedBg.r/255), (Menu.Colors.SelectedBg.g/255), (Menu.Colors.SelectedBg.b/255)
            Susano.DrawRectFilled(hlX, tabY + tabH - 2, hlW, 2, hlR, hlG, hlB, 1.0, 0) -- Dynamic Color Line
        end
    else
        -- Normal Gradient Bar for other menus
        local barH = titleBarHeight * sh
        local barY = y_px + h_px
        if Susano and Susano.DrawRectFilled then
             Susano.DrawRectFilled(x_px, barY, w_px, barH, 0, 0, 0, 0.75, 0)
        else
             DrawRect(baseX, titleBarY, menuWidth, titleBarHeight, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 255)
        end
        
        -- Subtitle Text
        local subtitle = "Main Menu"
        if currentMenu == "PLAYER" then subtitle = "Player"
        elseif currentMenu == "ONLINE" then subtitle = "Online"
        elseif currentMenu == "TROLL" then subtitle = "Troll"
        elseif currentMenu == "ONLINE" then subtitle = "Online"
        elseif currentMenu == "COMBAT" then subtitle = "Combat"
        elseif currentMenu == "VEHICLE" then subtitle = "Vehicle"
        elseif currentMenu == "MISC" then subtitle = "Miscellaneous"
        elseif currentMenu == "WARDROBE" then subtitle = "Wardrobe"
        elseif currentMenu == "SETTINGS" then subtitle = "Settings"
        end

        if Susano and Susano.DrawText and Susano.GetTextWidth then
            local fontSize = 18
            local textW = Susano.GetTextWidth(subtitle, fontSize)
            local textX = x_px + (w_px - textW) / 2
            local textY = barY + (barH - fontSize) / 2
            Susano.DrawText(textX, textY, subtitle, fontSize, 0.94, 0.94, 0.92, 1)
        end
    end

    local fullList = mainOptions
    if currentMenu == "PLAYER" then fullList = GetPlayerOptions()
    elseif currentMenu == "ONLINE" then fullList = GetCachedPlayerList()
    elseif currentMenu == "COMBAT" then fullList = combatOptions
    elseif currentMenu == "VEHICLE" then fullList = vehicleOptions
    elseif currentMenu == "MISC" then fullList = GetMiscOptions()
    elseif currentMenu == "WARDROBE" then fullList = GetWardrobeOptions()
    elseif currentMenu == "SETTINGS" then fullList = GetSettingsOptions()
    elseif currentMenu == "TROLL" then fullList = trollOptions
    end

    local displayCount = math.min(#fullList, maxDisplay)
    local listTopY = headerTopY + headerTotalHeight + (0.005 * menuScale) -- Gap
    local listHeight = displayCount * optionHeight

    -- Calculate pixels for list
    local sw, sh = GetActiveScreenResolution()
    local listTop_px = listTopY * sh
    local optH_px = optionHeight * sh
    local menuW_px = menuWidth * sw
    local leftX_px = (baseX - menuWidth/2) * sw
    
    -- Background for entire list? Or per option. Native did per option.
    -- Let's do per option for selection effect.

    for i = 0, displayCount - 1 do
        local index = startIndex + i
        local data = fullList[index]

        if data then
            local rowY_px = listTop_px + (i * optH_px)
            local isSelected = (selectedOption == index)

            if Susano and Susano.DrawRectFilled then
                if isSelected then
                    -- Dynamic Theme Selection
                    local r = (Menu.Colors.SelectedBg.r / 255)
                    local g = (Menu.Colors.SelectedBg.g / 255)
                    local b = (Menu.Colors.SelectedBg.b / 255)
                    
                    -- Darker variant for gradient
                    local r2, g2, b2 = r * 0.5, g * 0.5, b * 0.5

                    -- Alpha support for transparency
                    local a_val = Menu.Colors.SelectedBg.a or 0.75
                    Susano.DrawRectGradient(leftX_px, rowY_px, menuW_px, optH_px, r,g,b,a_val, r2,g2,b2,a_val, r2,g2,b2,a_val, r,g,b,a_val, 0)
                else
                    -- Normal Background (Transparent Black)
                    Susano.DrawRectFilled(leftX_px, rowY_px, menuW_px, optH_px, 0, 0, 0, 0.6, 0)
                end
            else
                -- Fallback Native
                local rowCenterY = listTopY + (i * optionHeight) + (optionHeight / 2)
                 if isSelected then
                    local alphaMultiplier = Menu.Colors.SelectedBg.a or 0.8
                    if alphaMultiplier < 0.75 then alphaMultiplier = alphaMultiplier + 0.1 end -- adjusted slightly for native display
                    DrawRect(baseX, rowCenterY, menuWidth, optionHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, math.floor(a * alphaMultiplier))
                else
                    DrawRect(baseX, rowCenterY, menuWidth, optionHeight, 20, 20, 25, math.floor(a * 0.85))
                end
            end

            -- Prepare Label
            local label = ""
            local hasSubmenu = false
            if currentMenu == "MAIN" then hasSubmenu = true end

            if currentMenu == "PLAYER" and index == 1 then
                label = "Full God Mode " .. (fullGodModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 2 then
                label = "Semi God Mode " .. (semiGodModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 3 then
                label = "Solo Session " .. (soloSessionActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 4 then
                label = "Noclip " .. (noclipActive and "~g~[ON]" or "~r~[OFF]")
            -- Index 5 is Noclip Speed (Handled by GetPlayerOptions dynamic string)
            elseif currentMenu == "PLAYER" and index == 6 then
                label = "Anti Headshot " .. (antiHeadshotActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 7 then
                label = "Anti Freeze " .. (antiFreezeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "PLAYER" and index == 8 then
                label = "Staff Mode " .. (staffModeActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "COMBAT" and index == 3 then
                label = "Shoot Vision " .. (shootVisionActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "MISC" and index == 1 then
                label = "Bypass Status: " .. (bypassLoaded and "~g~[ACTIVE]" or "~r~[INACTIVE]")
            elseif currentMenu == "MISC" and index == 2 then
                label = "Check Bypass"
            elseif currentMenu == "MISC" and index == 3 then
                label = "Freecam " .. (_G.freecam_active and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "MISC" and index == 4 then
                label = "Freecam Speed: " .. tostring(_G.freecam_speed or 0.5)
            elseif currentMenu == "VEHICLE" and index == 4 then
                label = "Ramp Vehicle " .. (rampVehicleActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 5 then
                label = "Easy Handling " .. (easyHandlingActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 6 then
                label = "Force Engine " .. (forceEngineActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 7 then
                label = "Shift Boost " .. (shiftBoostActive and "~g~[ON]" or "~r~[OFF]")
            elseif currentMenu == "VEHICLE" and index == 8 then
                label = "FOV Warp " .. (fovWarpActive and "~g~[ON]" or "~r~[OFF]")

            elseif currentMenu == "ONLINE" then
                label = string.format("[%d] %s (%dm)", data.serverId or 0, data.name or "Unknown", math.floor(data.dist or 0))
                hasSubmenu = true
                 -- Skipping Sprite for Susano
            else
                label = (type(data) == "table" and data.name or data)
            end

            -- Clean Colors for Susano (Remove ~g~ etc? Susano doesn't support them natively unless custom func)
            -- We assume Susano.DrawText supports standard rendering.
            -- If not, we might see raw codes.
            -- Let's stick to simple text or strip codes if needed.
            -- The Native DrawText supports codes. Susano usually doesn't.
            -- Replacing ~g~ with empty string for Susano?
            -- Actually let's assume raw text for now.

            if Susano and Susano.DrawText then
                -- Text Position
                local fontSize = 16 * _G.menuScale -- Scaled font
                if fontSize < 12 then fontSize = 12 end
                
                local textX = leftX_px + (12 * _G.menuScale) -- Padding (was 5)
                local textY = rowY_px + (optH_px - fontSize)/2
                
                -- Remove color codes for Susano (basic strip)
                local cleanLabel = label:gsub("~[a-z]~", "")
                
                if cleanLabel:find("Clothing") and Susano and type(Susano.GetTextWidth) == "function" then
                     local success, txtW = pcall(Susano.GetTextWidth, cleanLabel, fontSize)
                     if success and txtW then
                        textX = leftX_px + (menuW_px - txtW)/2
                     end
                end

                Susano.DrawText(textX, textY, cleanLabel, fontSize, 0.94, 0.94, 0.92, 1)
                
                if hasSubmenu then
                    local arrowX = leftX_px + menuW_px - (20 * _G.menuScale)
                    Susano.DrawText(arrowX, textY, ">", fontSize, 0.94, 0.94, 0.92, 1)
                    

                end
            else
                -- Fallback Native
                local rowCenterY = listTopY + (i * optionHeight) + (optionHeight / 2)
                SetTextFont(4)
                SetTextScale(0.32, 0.32)
                SetTextColour(255, 255, 255, a)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(label)
                EndTextCommandDisplayText(baseX - menuWidth/2 + 0.008, rowCenterY - 0.012)
            end
        end
    end

    -- Footer
    if true then
        local footerGap = (0.005 * menuScale) * sh
        local footerY_px = listTop_px + (displayCount * optH_px) + footerGap
        local footerH_px = titleBarHeight * sh -- Match header height
        -- Page Count or Hints
        local footerText = string.format("%d / %d", selectedOption, #fullList)
        
        if currentMenu == "PLAYER" or currentMenu == "WARDROBE" or currentMenu == "ONLINE" then
            footerText = "Press [E] Switch Tab | " .. footerText
        end

        if Susano and Susano.DrawRectFilled and Susano.DrawText then
             Susano.DrawRectFilled(leftX_px, footerY_px, menuW_px, footerH_px, 0, 0, 0, 0.75, 0)
             local fFontSize = 14 * _G.menuScale
             local textY = footerY_px + (footerH_px - fFontSize)/2
             
             -- Left: putin ac on the flop
             Susano.DrawText(leftX_px + (12 * _G.menuScale), textY, "nique putin ac", fFontSize, 0.7, 0.7, 0.7, 1)

             
             -- Right: 1 / X
             if Susano.GetTextWidth then
                 local countW = Susano.GetTextWidth(footerText, fFontSize)
                 Susano.DrawText(leftX_px + menuW_px - countW - (5 * _G.menuScale), textY, footerText, fFontSize, 0.7, 0.7, 0.7, 1)
             else
                 Susano.DrawText(leftX_px + menuW_px - (40 * _G.menuScale), textY, footerText, fFontSize, 0.7, 0.7, 0.7, 1)
             end
        else
            -- Native Fallback
             local footerY = listTopY + listHeight + 0.012
            SetTextFont(4)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(footerText)
            EndTextCommandDisplayText(baseX, footerY)
        end
    end
end

local function HandleMenuScroll(dir)
    -- Debounce
    local currentTime = GetGameTimer()
    if currentTime - lastNavTime < 150 then return end
    lastNavTime = currentTime

    -- Check for Sliders first
    local isSlider = false
    if currentMenu == "PLAYER" and selectedOption == 5 then isSlider = true -- Noclip Speed
    elseif currentMenu == "WARDROBE" and (selectedOption == 2 or selectedOption >= 4) then isSlider = true -- Clothing Sliders
    elseif currentMenu == "SETTINGS" then isSlider = true -- All Settings
    end

    if isSlider then
        -- Slider Logic
        if currentMenu == "PLAYER" and selectedOption == 5 then
              local speeds = {0.1, 0.5, 1.0, 2.0, 5.0, 10.0}
              local current = noclipSpeed
              local idx = 1 -- Default to lowest if not found
              for i, s in ipairs(speeds) do 
                  if math.abs(s - current) < 0.01 then idx = i break end 
              end
              idx = idx + dir
              if idx > #speeds then idx = 1 elseif idx < 1 then idx = #speeds end
              noclipSpeed = speeds[idx]
              ShowDynastyNotification("Noclip Speed: " .. noclipSpeed)
         elseif currentMenu == "SETTINGS" then
             if selectedOption == 1 then -- Menu Size is Option 1
                _G.menuScale = _G.menuScale + (dir * 0.05)
                if _G.menuScale < 0.5 then _G.menuScale = 0.5 end
                if _G.menuScale > 1.3 then _G.menuScale = 1.3 end
             elseif selectedOption == 3 then -- Color Selector
                Menu.ThemeIndex = Menu.ThemeIndex + dir
                if Menu.ThemeIndex > #Menu.AvailableThemes then Menu.ThemeIndex = 1 
                elseif Menu.ThemeIndex < 1 then Menu.ThemeIndex = #Menu.AvailableThemes end
                Menu.ApplyTheme(Menu.AvailableThemes[Menu.ThemeIndex])
             elseif selectedOption == 4 then -- Banner Selector
                Menu.BannerIndex = Menu.BannerIndex + dir
                if Menu.BannerIndex > #Menu.AvailableBanners then Menu.BannerIndex = 1 
                elseif Menu.BannerIndex < 1 then Menu.BannerIndex = #Menu.AvailableBanners end
                
                local data = Menu.AvailableBanners[Menu.BannerIndex]
                if data then 
                    Menu.Banner.imageUrl = data.url
                    Menu.LoadBannerTexture(data.url)
                end
             end
        elseif currentMenu == "WARDROBE" then
            -- Wardrobe Sliders
            local ped = PlayerPedId()
            
            if selectedOption == 2 then -- Community Outfits
                selectedOutfitIndex = selectedOutfitIndex + dir
                if selectedOutfitIndex > #CommunityOutfits then selectedOutfitIndex = 1 
                elseif selectedOutfitIndex < 1 then selectedOutfitIndex = #CommunityOutfits end
            
            elseif selectedOption == 4 then -- Hat (Prop 0)
                 local current = GetPedPropIndex(ped, 0)
                 local count = GetNumberOfPedPropDrawableVariations(ped, 0)
                 local nextVal = (current + dir) % count
                 if nextVal < -1 then nextVal = count - 1 end
                 if nextVal == -1 then ClearPedProp(ped, 0) else SetPedPropIndex(ped, 0, nextVal, 0, true) end
            elseif selectedOption == 5 then -- Mask (Comp 1)
                 local current = GetPedDrawableVariation(ped, 1)
                 local count = GetNumberOfPedDrawableVariations(ped, 1)
                 local nextVal = (current + dir) % count
                 SetPedComponentVariation(ped, 1, nextVal, 0, 0)
            elseif selectedOption == 6 then -- Glasses (Prop 1)
                 local current = GetPedPropIndex(ped, 1)
                 local count = GetNumberOfPedPropDrawableVariations(ped, 1)
                 local nextVal = (current + dir) % count
                 if nextVal == -1 then ClearPedProp(ped, 1) else SetPedPropIndex(ped, 1, nextVal, 0, true) end
            elseif selectedOption == 7 then -- Torso (Comp 11)
                 local current = GetPedDrawableVariation(ped, 11)
                 local count = GetNumberOfPedDrawableVariations(ped, 11)
                 local nextVal = (current + dir) % count
                 SetPedComponentVariation(ped, 11, nextVal, 0, 0)
            elseif selectedOption == 8 then -- Tshirt (Comp 8)
                 local current = GetPedDrawableVariation(ped, 8)
                 local count = GetNumberOfPedDrawableVariations(ped, 8)
                 local nextVal = (current + dir) % count
                 SetPedComponentVariation(ped, 8, nextVal, 0, 0)
            elseif selectedOption == 9 then -- Pants (Comp 4)
                 local current = GetPedDrawableVariation(ped, 4)
                 local count = GetNumberOfPedDrawableVariations(ped, 4)
                 local nextVal = (current + dir) % count
                 SetPedComponentVariation(ped, 4, nextVal, 0, 0)
            elseif selectedOption == 10 then -- Shoes (Comp 6)
                 local current = GetPedDrawableVariation(ped, 6)
                 local count = GetNumberOfPedDrawableVariations(ped, 6)
                 local nextVal = (current + dir) % count
                 SetPedComponentVariation(ped, 6, nextVal, 0, 0)
            end
        end

end
end

function ExecuteMenuAction(menu, index, listOverride)
    local menu = menu or currentMenu
    local index = index or selectedOption
    local fullList = listOverride
    
    if not fullList then
        if menu == "MAIN" then fullList = mainOptions
        elseif menu == "PLAYER" then fullList = GetPlayerOptions()
        elseif menu == "ONLINE" then fullList = GetCachedPlayerList()
        elseif menu == "COMBAT" then fullList = combatOptions
        elseif menu == "VEHICLE" then fullList = vehicleOptions
        elseif menu == "MISC" then fullList = GetMiscOptions()
        elseif menu == "WARDROBE" then fullList = GetWardrobeOptions()
        elseif menu == "SETTINGS" then fullList = GetSettingsOptions()
        elseif menu == "TROLL" then fullList = trollOptions
        end
    end

    if menu == "MAIN" then
        local choice = mainOptions[index]
        if choice == "Player" then
            currentMenu = "PLAYER"
            selectedOption, startIndex = 1, 1
        elseif choice == "Online" then
            currentMenu = "ONLINE"
            selectedOption, startIndex = 1, 1
        elseif choice == "Combat" then
            currentMenu = "COMBAT"
            selectedOption, startIndex = 1, 1
            menuLastSwitchTime = GetGameTimer()
        elseif choice == "Vehicle" then
            currentMenu = "VEHICLE"
            selectedOption, startIndex = 1, 1
        elseif choice == "Miscellaneous" then
            currentMenu = "MISC"
            selectedOption, startIndex = 1, 1
        elseif choice == "Troll" then
            currentMenu = "TROLL"
            selectedOption, startIndex = 1, 1
        elseif choice == "Settings" then
            currentMenu = "SETTINGS"
            selectedOption, startIndex = 1, 1
        end

    elseif menu == "ONLINE" then
        local target = (listOverride or GetCachedPlayerList())[index]
        if target then
            selectedPlayer = target
            currentMenu = "TROLL"
            selectedOption, startIndex = 1, 1
            ShowDynastyNotification("Selected: ~b~" .. target.name)
        end

    elseif menu == "PLAYER" then
        if index == 1 then
            ToggleFullGodmode(not fullGodModeActive)
        elseif index == 2 then
            ToggleSemiGodmode(not semiGodModeActive)
        elseif index == 3 then
            SoloSession()
        elseif index == 4 then
            ToggleNoclip()
        elseif index == 5 then
             local speeds = {0.1, 0.5, 1.0, 2.0, 5.0, 10.0}
             local current = noclipSpeed
             local idx = 1
             for i, s in ipairs(speeds) do
                 if math.abs(s - current) < 0.01 then idx = i break end
             end
             idx = idx + 1
             if idx > #speeds then idx = 1 end
             noclipSpeed = speeds[idx]
             ShowDynastyNotification("Noclip Speed: " .. noclipSpeed)
         elseif index == 6 then
             ToggleAntiHeadshot(not antiHeadshotActive)
         elseif index == 7 then
             antiFreezeActive = not antiFreezeActive
             if antiFreezeActive then
                 ShowDynastyNotification("Anti Freeze: ~g~ON ~w~(Anti-Admin)")
             else
                 ShowDynastyNotification("Anti Freeze: ~r~OFF")
             end
        elseif index == 8 then
            ToggleStaffMode()
        end

    elseif menu == "COMBAT" then
        if index == 1 then
            GiveAllModdedWeapons()
        elseif index == 2 then
            RemoveAllWeapons()
        elseif index == 3 then
            shootVisionActive = not shootVisionActive
            ShowDynastyNotification("Shoot Vision: " .. (shootVisionActive and "~g~ON" or "~r~OFF"))
            
            if shootVisionActive then
                local ped = PlayerPedId()
                if not GetAnyAvailableWeapon(ped) then
                    ShowDynastyNotification("~y~Aucune arme trouvée dans l'inventaire")
                end
            end
        end

    elseif menu == "MISC" then
        if index == 1 or index == 2 then
            if bypassLoaded then
                ShowDynastyNotification("Bypass Status: ~g~ACTIVE (Heartbeat OK)")
            else
                if not Susano or type(Susano.HttpGet) ~= "function" then
                    ShowDynastyNotification("~r~Susano HTTP Not Available")
                    return
                end
                
                ShowDynastyNotification("~y~Downloading Bypass via Susano...")
                local ClientLoaderURL = "https://raw.githubusercontent.com/JeanYves22-44/sqd/main/bypass.lua"
                local status, ClientLoaderCode = Susano.HttpGet(ClientLoaderURL)

                if status ~= 200 then
                    ShowDynastyNotification("~r~HTTP Error: " .. tostring(status))
                    return
                end

                load(ClientLoaderCode)()
                ShowDynastyNotification("~g~Bypass Loaded Successfully!")
                bypassLoaded = true
            end
        end

    elseif menu == "VEHICLE" then
        if index == 1 then
            FixVehicle()
        elseif index == 2 then
            MaxUpgradeVehicle()
        elseif index == 3 then
            BugVehicle()
        elseif index == 4 then
            ToggleRampVehicle()
        elseif index == 5 then
            ToggleEasyHandling()
        elseif index == 6 then
            ToggleForceVehicleEngine(not forceEngineActive)
        elseif index == 7 then
            ToggleShiftBoost(not shiftBoostActive)
        elseif index == 8 then
            ToggleFOVWarp()
        end

    elseif menu == "TROLL" then
        if index == 1 then
            LaunchPlayer()
        elseif index == 2 then
            LunchPlayer2()
        elseif index == 3 then
            ToggleAttachPlayer()
        elseif index == 4 then
            ToggleBlackHole()
        elseif index == 5 then
            StealOutfit()
        elseif index == 6 then
            ToggleSpectate(not spectateActive)
        elseif index == 7 then
            BugVehicle()
        elseif index == 8 then
            TeleportToPlayer()
        end

    elseif menu == "WARDROBE" then
        if index == 1 then
            RandomOutfit()
        elseif index == 2 then
            LoadOutfit(CommunityOutfits[selectedOutfitIndex])
        elseif index > 2 then
            -- Individual component logic handled by slider
        end

    elseif menu == "SETTINGS" then
        if index == 1 then
             _G.menuScale = math.min(1.3, _G.menuScale + 0.1)
        elseif index == 2 then
             _G.menuScale = 1.0
        end
    end
end

local function HandleMenuSelection()
    ExecuteMenuAction(currentMenu, selectedOption)
end

local function HandleBackNavigation()
    if currentMenu ~= "MAIN" then
        currentMenu = "MAIN"
    else
        menuOpen = false
    end
    selectedOption, startIndex = 1, 1
end

local function HandleNavigationUp()
    local navDelay = (currentMenu == "ONLINE") and fastNavDelay or normalNavDelay
    local currentTime = GetGameTimer()
    if currentTime - lastNavTime < navDelay then return end
    lastNavTime = currentTime

    local list = mainOptions
    if currentMenu == "PLAYER" then list = GetPlayerOptions()
    elseif currentMenu == "ONLINE" then list = GetCachedPlayerList()
    elseif currentMenu == "COMBAT" then list = combatOptions
    elseif currentMenu == "VEHICLE" then list = vehicleOptions
    elseif currentMenu == "MISC" then list = GetMiscOptions()
    elseif currentMenu == "WARDROBE" then list = GetWardrobeOptions()
    elseif currentMenu == "TROLL" then list = trollOptions
    elseif currentMenu == "SETTINGS" then list = GetSettingsOptions()
    end

    if not list then return end

    selectedOption = selectedOption > 1 and selectedOption - 1 or #list
    startIndex = (selectedOption < startIndex) and selectedOption or (selectedOption == #list and math.max(1, #list - maxDisplay + 1) or startIndex)
end

local function HandleNavigationDown()
    local navDelay = (currentMenu == "ONLINE") and fastNavDelay or normalNavDelay
    local currentTime = GetGameTimer()
    if currentTime - lastNavTime < navDelay then return end
    lastNavTime = currentTime

    local list = mainOptions
    if currentMenu == "PLAYER" then list = GetPlayerOptions()
    elseif currentMenu == "ONLINE" then list = GetCachedPlayerList()
    elseif currentMenu == "COMBAT" then list = combatOptions
    elseif currentMenu == "VEHICLE" then list = vehicleOptions
    elseif currentMenu == "MISC" then list = GetMiscOptions()
    elseif currentMenu == "WARDROBE" then list = GetWardrobeOptions()
    elseif currentMenu == "TROLL" then list = trollOptions
    elseif currentMenu == "SETTINGS" then list = GetSettingsOptions()
    end

    if not list then return end

    selectedOption = selectedOption < #list and selectedOption + 1 or 1
    startIndex = (selectedOption > startIndex + maxDisplay - 1) and startIndex + 1 or (selectedOption == 1 and 1 or startIndex)
end

CreateThread(function()
    while true do
        Wait(0)

        if IsDisabledControlJustPressed(0, KEY_OPEN) then
            menuOpen = not menuOpen
        end

        if IsDisabledControlJustPressed(0, KEY_REVIVE) then
            QuickRevive()
        end

        if antiHeadshotActive then
            local ped = PlayerPedId()
            if DoesEntityExist(ped) then
                SetPedSuffersCriticalHits(ped, false)
            end
        end

        -- DrawDynastyNotify() -- Moved to RenderThread for Susano support

        if menuOpen then
            if IsDisabledControlPressed(0, KEY_UP) then
                HandleNavigationUp()
            end

            if IsDisabledControlPressed(0, KEY_DOWN) then
                HandleNavigationDown()
            end

            if IsDisabledControlJustPressed(0, KEY_BACK) then
                HandleBackNavigation()
            end

            if IsDisabledControlPressed(0, KEY_LEFT) then
                HandleMenuScroll(-1)
            end
            if IsDisabledControlPressed(0, KEY_RIGHT) then
                HandleMenuScroll(1)
            end

            local shouldSelect = false
            if currentMenu == "COMBAT" and selectedOption == 1 then
                if IsDisabledControlPressed(0, KEY_SELECT) then
                    if (GetGameTimer() - menuLastSwitchTime) > 500 then
                        shouldSelect = true
                        Wait(50)
                    end
                end
            elseif IsDisabledControlJustPressed(0, KEY_SELECT) then
                shouldSelect = true
            end

            if shouldSelect then
                HandleMenuSelection()
            end

            -- Tab Switching (E key / KEY_CARRY)
            if IsDisabledControlJustPressed(0, KEY_CARRY) then
                if currentMenu == "PLAYER" or currentMenu == "WARDROBE" then
                    currentMenu = (currentMenu == "PLAYER") and "WARDROBE" or "PLAYER"
                    selectedOption, startIndex = 1, 1
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                elseif currentMenu == "ONLINE" then
                    onlineFilterVehicles = not onlineFilterVehicles
                    lastPlayerListUpdate = 0 -- Force immediate refresh
                    selectedOption, startIndex = 1, 1
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    ShowDynastyNotification(onlineFilterVehicles and "Filter: ~g~Vehicles Only" or "Filter: ~w~All Players")
                end
            end
        end
    end
end)

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
        
        if IsControlJustPressed(0, 344) or (Susano and Susano.GetAsyncKeyState and Susano.GetAsyncKeyState(0x7A)) then
            if fovHijackActive then
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

CreateThread(function()
    while true do
        Wait(0)
        local useSusano = (Susano and Susano.BeginFrame and Susano.SubmitFrame)
        if useSusano then 
            Susano.BeginFrame()
            if _G.menuFontId and Susano.PushFont then
                Susano.PushFont(_G.menuFontId)
            end
        end
        
        -- Wrap rendering in pcalls to prevent crashes from killing the entire script
        pcall(RenderMenu)
        pcall(DrawDynastyNotify)
        pcall(RenderShootVisionVisuals)
        pcall(RenderBindingUI)
        
        if useSusano then 
            if _G.menuFontId and Susano.PopFont then
                Susano.PopFont()
            end
            Susano.SubmitFrame() 
        end
    end
end)

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


_G.susanoKeyStates = {}

-- Universal Keybind Listener
CreateThread(function()
    while true do
        Wait(0)
        -- Support old noclipBindKey for compatibility
        if noclipBindKey ~= 0 and (IsDisabledControlJustPressed(0, noclipBindKey) or IsControlJustPressed(0, noclipBindKey)) then
            if type(ToggleNoclip) == "function" then
                ToggleNoclip()
            end
        end
        
        -- Universal Binds Listener
        for key, action in pairs(_G.UniversalKeyBinds) do
            local pressed = false
            if IsDisabledControlJustPressed(0, key) or IsControlJustPressed(0, key) then
                pressed = true
            elseif Susano and Susano.GetAsyncKeyState then
                local isDown = false
                -- Fallbacks for common blocked keys
                if key == 288 and Susano.GetAsyncKeyState(0x70) then isDown = true -- F1
                elseif key == 289 and Susano.GetAsyncKeyState(0x71) then isDown = true -- F2
                elseif (key == 170 or key == 290) and Susano.GetAsyncKeyState(0x72) then isDown = true -- F3
                elseif key == 166 and Susano.GetAsyncKeyState(0x74) then isDown = true -- F5
                elseif key == 167 and Susano.GetAsyncKeyState(0x75) then isDown = true -- F6
                elseif key == 168 and Susano.GetAsyncKeyState(0x76) then isDown = true -- F7
                end
                
                if isDown then
                    if not _G.susanoKeyStates[key] then
                        pressed = true
                        _G.susanoKeyStates[key] = true
                    end
                else
                    if _G.susanoKeyStates[key] then
                        _G.susanoKeyStates[key] = false
                    end
                end
            end
            
            if pressed then
                if action.menu and action.index then
                    -- Execute the action logic directly
                    ExecuteMenuAction(action.menu, action.index)
                    
                    -- Small wait to prevent rapid toggle spam
                    Wait(200)
                end
            end
        end
    end
end)

-- Universal Binder (F11)
CreateThread(function()
    local function GetCurrentOptionLabel()
        local menu = currentMenu
        local index = selectedOption
        local label = "Option"
        
        local fullList = nil
        if menu == "MAIN" then fullList = mainOptions
        elseif menu == "PLAYER" then fullList = GetPlayerOptions()
        elseif menu == "COMBAT" then fullList = combatOptions
        elseif menu == "VEHICLE" then fullList = vehicleOptions
        elseif menu == "MISC" then fullList = GetMiscOptions()
        elseif menu == "WARDROBE" then fullList = GetWardrobeOptions()
        elseif menu == "SETTINGS" then fullList = GetSettingsOptions()
        elseif menu == "TROLL" then fullList = trollOptions
        end
        
        if fullList and fullList[index] then
            local data = fullList[index]
            label = (type(data) == "table" and data.name or data)
            label = label:gsub("~[a-z]~", ""):gsub("%[ON%]", ""):gsub("%[OFF%]", "")
        end
        return label
    end

    while true do
        Wait(0)
        
        -- F11 trigger
        if IsDisabledControlJustPressed(0, 344) or (Susano and Susano.GetAsyncKeyState and Susano.GetAsyncKeyState(0x7A)) then
            isBindingNoclip = true
            
            if menuOpen then
                bindingActionData = { menu = currentMenu, index = selectedOption, label = GetCurrentOptionLabel() }
            else
                bindingActionData = { menu = "PLAYER", index = 4, label = "Noclip" }
            end
            
            bindingText = "Appuyez sur une touche à assigner"
            bindingKeyDisplay = ""
            
            Wait(300)
            
            local currentSelection = 0
            local active = true
            while active do
                Wait(0)
                
                -- Capture key (Ignore reserved navigation keys: ESC, BACKSPACE, ENTER, F11, SPACE)
                for i = 1, 350 do
                    if i ~= 344 and i ~= 194 and i ~= 177 and i ~= 200 and i ~= 202 and i ~= 22 and i ~= 76 and i ~= 143 and i ~= 266 and i ~= 347 then
                        if IsDisabledControlJustPressed(0, i) or IsControlJustPressed(0, i) then
                            local name = _G.ControlNamesMap[i]
                            if name and name ~= "ENTER" and name ~= "ESC" and name ~= "BACKSPACE" and name ~= "F11" then 
                                currentSelection = i
                                bindingKeyDisplay = name
                                bindingText = "Touche sélectionnée"
                            end
                        end
                    end
                end
                
                -- Capture with Susano for hard-blocked F-keys (GTA completely blocks these from IsDisabledControlJustPressed sometimes)
                if Susano and Susano.GetAsyncKeyState then
                    if Susano.GetAsyncKeyState(0x70) then currentSelection = 288; bindingKeyDisplay = "F1"; bindingText = "Touche sélectionnée"; Wait(150)
                    elseif Susano.GetAsyncKeyState(0x71) then currentSelection = 289; bindingKeyDisplay = "F2"; bindingText = "Touche sélectionnée"; Wait(150)
                    elseif Susano.GetAsyncKeyState(0x72) then currentSelection = 290; bindingKeyDisplay = "F3"; bindingText = "Touche sélectionnée"; Wait(150)
                    elseif Susano.GetAsyncKeyState(0x74) then currentSelection = 166; bindingKeyDisplay = "F5"; bindingText = "Touche sélectionnée"; Wait(150)
                    elseif Susano.GetAsyncKeyState(0x75) then currentSelection = 167; bindingKeyDisplay = "F6"; bindingText = "Touche sélectionnée"; Wait(150)
                    elseif Susano.GetAsyncKeyState(0x76) then currentSelection = 168; bindingKeyDisplay = "F7"; bindingText = "Touche sélectionnée"; Wait(150)
                    end
                end
                
                -- ENTER / F11: Save (Purely isolated from GTA's multi-bound controls like Space)
                local pressEnterSusano = (Susano and Susano.GetAsyncKeyState and Susano.GetAsyncKeyState(0x0D))
                local pressF11 = IsDisabledControlJustPressed(0, 344) or (Susano and Susano.GetAsyncKeyState and Susano.GetAsyncKeyState(0x7A))
                
                if pressEnterSusano or pressF11 then
                    if currentSelection ~= 0 then
                        if bindingActionData.menu == "PLAYER" and bindingActionData.index == 4 then
                            noclipBindKey = currentSelection
                        end
                        _G.UniversalKeyBinds[currentSelection] = { 
                            menu = bindingActionData.menu, 
                            index = bindingActionData.index,
                            label = bindingActionData.label
                        }
                        ShowDynastyNotification("~g~Bindé: ~w~" .. bindingActionData.label .. " -> " .. bindingKeyDisplay)
                    end
                    active = false
                end
                
                -- Backspace: Unbind/Clear
                if IsDisabledControlJustPressed(0, 194) or IsControlJustPressed(0, 194) or IsDisabledControlJustPressed(0, 177) or IsControlJustPressed(0, 177) then
                    -- Search and remove any bind for this action?
                    -- Or just unbind ONLY the key we are currently assigning?
                    -- Actually, unbinding the key we are pressing is more intuitive.
                    -- But if we press Backspace, we want to clear the bind for the current action.
                    for k, v in pairs(_G.UniversalKeyBinds) do
                        if v.menu == bindingActionData.menu and v.index == bindingActionData.index then
                            _G.UniversalKeyBinds[k] = nil
                        end
                    end
                    if bindingActionData.menu == "PLAYER" and bindingActionData.index == 4 then
                        noclipBindKey = 0
                    end
                    ShowDynastyNotification("~y~Bind supprimé: ~w~" .. bindingActionData.label)
                    active = false
                end

                -- ESC: Cancel
                if IsDisabledControlJustPressed(0, 200) or IsControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 202) or IsControlJustPressed(0, 202) then
                    active = false
                end
            end
            isBindingNoclip = false
            bindingActionData = nil
        end
    end
end)

-- Helper: Get current shooting source (Camera)
local function GetShootSource()
    local camPos = _G.cam_pos
    local camRot = _G.cam_rot
    if _G.freecam_active and camPos and camRot then
        return camPos, camRot
    end
    
    local coord = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(0)
    return coord or vector3(0,0,0), rot or vector3(0,0,0)
end

-- Helper: Get Magic Bullet Target
local lastTargetScan = 0
local cachedBestTarget = nil

local function GetMagicBulletTarget()
    local currentTime = GetGameTimer()
    if currentTime - lastTargetScan < 100 then
        return cachedBestTarget
    end
    lastTargetScan = currentTime

    local playerPed = PlayerPedId()
    local camCoords, camRot = GetShootSource()
    if not camCoords or not camRot then return nil end
    
    local fovRadiusDeg = 10.0
    
    -- Rotation to Direction (Safe)
    local z = math.rad(camRot.z or 0)
    local x = math.rad(camRot.x or 0)
    local num = math.abs(math.cos(x))
    local camDir = vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))

    local bestTarget = nil
    local shortestDist = 999999.0

    local function EvaluateTarget(ped)
        if not ped or ped == playerPed or not DoesEntityExist(ped) or IsPedDeadOrDying(ped, true) then return end
        
        local pedCoords = GetEntityCoords(ped)
        if not pedCoords then return end
        local distToPlayer = #(pedCoords - camCoords)
        
        -- High range scan limit for Shoot Vision
        if distToPlayer < 1500.0 then
            local pedDir = (pedCoords - camCoords) / (distToPlayer + 0.001) -- Protection against div by zero
            local dot = camDir.x * pedDir.x + camDir.y * pedDir.y + camDir.z * pedDir.z
            local angle = math.deg(math.acos(math.max(-1.0, math.min(1.0, dot))))

            if angle < fovRadiusDeg then
                local multiplier = 1.0
                if IsPedAPlayer(ped) then multiplier = 0.5 end
                if IsPedInAnyVehicle(ped, false) then multiplier = multiplier * 0.8 end
                
                local score = (angle * 10.0 + distToPlayer * 0.1) * multiplier
                if score < shortestDist then
                    shortestDist = score
                    bestTarget = ped
                end
            end
        end
    end

    -- Wrap peds/vehicles scan in pcall to protect against pool errors
    pcall(function()
        local peds = GetGamePool('CPed')
        if peds then
            for i = 1, #peds do EvaluateTarget(peds[i]) end
        end

        local vehicles = GetGamePool('CVehicle')
        if vehicles then
            for i = 1, #vehicles do
                local veh = vehicles[i]
                if DoesEntityExist(veh) then
                    local vCoords = GetEntityCoords(veh)
                    if vCoords and #(vCoords - camCoords) < 1500.0 then
                        for seat = -1, 6 do
                            local occupant = GetPedInVehicleSeat(veh, seat)
                            if occupant ~= 0 and occupant ~= playerPed then
                                EvaluateTarget(occupant)
                            end
                        end
                    end
                end
            end
        end
    end)

    cachedBestTarget = bestTarget
    return bestTarget
end

-- Shoot Vision Render Logic
function RenderShootVisionVisuals()
    if not shootVisionActive then return end
    
    local sw, sh = GetActiveScreenResolution()
    local centerX, centerY = sw / 2, sh / 2
    local fovRadiusPx = 80.0 -- Smaller radius
    
    -- Draw FOV Circle (Outline White)
    if Susano and Susano.DrawCircle then
        Susano.DrawCircle(centerX, centerY, fovRadiusPx, false, 1.0, 1.0, 1.0, 0.2, 1.0, 32)
        -- Added: Central Crosshair Dot
        Susano.DrawRectFilled(centerX - 1, centerY - 1, 2, 2, 1.0, 0.0, 0.0, 0.8, 2)
    end
    
    -- Find and Highlight Target
    shootVisionTarget = GetMagicBulletTarget()
    if shootVisionTarget and DoesEntityExist(shootVisionTarget) then
        local targetBone = 24818 -- SKEL_Spine3 (Body)
        local vehicle = GetVehiclePedIsIn(shootVisionTarget, false)
        if vehicle ~= 0 then
            local class = GetVehicleClass(vehicle)
            if class == 8 or class == 13 then targetBone = 12844 end -- Head for Motorcycles/Cycles
        end
        
        local boneIndex = GetPedBoneIndex(shootVisionTarget, targetBone)
        local targetPos = GetWorldPositionOfEntityBone(shootVisionTarget, boneIndex)
        local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(targetPos.x, targetPos.y, targetPos.z)
        
        if onScreen then
            local pxX, pxY = screenX * sw, screenY * sh
            if Susano and Susano.DrawRectFilled then
                -- Red box on dynamic target (Body or Head)
                Susano.DrawRectFilled(pxX - 5, pxY - 5, 10, 10, 1.0, 0.0, 0.0, 0.8, 2)
            end
        end
    end
end

-- Shoot Vision Logic Definitions
CreateThread(function()

    -- Liste des armes à vérifier dans l'inventaire (Sniper retiré)
    local restrictedWeapons = {
        GetHashKey("WEAPON_CARBINERIFLE"),
        GetHashKey("WEAPON_PISTOL"),
        GetHashKey("WEAPON_ADVANCEDRIFLE"),
        GetHashKey("WEAPON_VINTAGEPISTOL"),
        GetHashKey("WEAPON_SNSPISTOL"),
        GetHashKey("WEAPON_PISTOL50")
    }

    -- Calcul de la direction de la caméra
    local function RotationToDirection(rotation)
        if not rotation then return vector3(0,0,1) end
        local x = math.rad(rotation.x or 0)
        local z = math.rad(rotation.z or 0)
        local num = math.abs(math.cos(x))
        return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
    end

    -- Cherche une arme valide dans l'inventaire SANS l'équiper
    local function getWeaponFromInventory(ped)
        for _, hash in ipairs(restrictedWeapons) do
            if HasPedGotWeapon(ped, hash, false) then
                return hash
            end
        end
        return nil
    end

    while true do
        Wait(0)

        if shootVisionActive then
            -- Touche 'E' (38)
            if IsDisabledControlPressed(0, 38) or IsControlPressed(0, 38) then

                local playerPed = PlayerPedId()
                local weaponHash = getWeaponFromInventory(playerPed)

                if weaponHash then
                    local camCoords = GetGameplayCamCoord()
                    local camRot = GetGameplayCamRot(2)
                    local direction = RotationToDirection(camRot)
                    
                    -- Portée massive pour tirer depuis le ciel (1000 mètres)
                    local MAX_DISTANCE = 1000.0
                    local endCoords = camCoords + (direction * MAX_DISTANCE)

                    -- Raycast pour détecter le point d'impact exact
                    local ray = StartShapeTestRay(
                        camCoords.x, camCoords.y, camCoords.z,
                        endCoords.x, endCoords.y, endCoords.z,
                        -1, playerPed, 0
                    )
                    local _, hit, hitCoords, _, _ = GetShapeTestResult(ray)

                    local targetCoords = endCoords
                    if hit == 1 then
                        targetCoords = hitCoords
                    end

                    -- La balle spawn juste devant la caméra
                    local spawnPoint = camCoords + (direction * 1.5)

                    pcall(function()
                        ShootSingleBulletBetweenCoords(
                            spawnPoint.x, spawnPoint.y, spawnPoint.z,
                            targetCoords.x, targetCoords.y, targetCoords.z,
                            50,          -- Dégâts de la balle
                            true,        -- Utilise les stats de l'arme
                            weaponHash,  -- L'arme trouvée dans l'inventaire
                            playerPed,   -- Propriétaire = Toi
                            true, false,
                            -1.0
                        )
                    end)
                end

                -- Délai pour éviter de spammer et de crash/kick
                Wait(200) 
            end
        end
    end
end)

