local addonName, addon = ...

local COMBATLOG_FILTER_STRING_UNKNOWN_UNITS = COMBATLOG_FILTER_STRING_UNKNOWN_UNITS
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local C_Timer_After = C_Timer.After
local CanInspect = CanInspect
local ClearInspectPlayer = ClearInspectPlayer
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetBattlefieldScore = GetBattlefieldScore
local GetClassInfo = GetClassInfo
local GetInspectSpecialization = GetInspectSpecialization
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSpecializationsForClassID = GetNumSpecializationsForClassID
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetRaidRosterInfo = GetRaidRosterInfo
local GetServerTime = GetServerTime
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetSpecializationInfoForClassID = GetSpecializationInfoForClassID
local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture
local GetTime = GetTime
local GetUnitName = GetUnitName
local GetZonePVPInfo = GetZonePVPInfo
local InCombatLockdown = InCombatLockdown
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local IsRatedBattleground = C_PvP.IsRatedBattleground
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local LibStub = LibStub
local MAX_CLASSES = MAX_CLASSES
local NotifyInspect = NotifyInspect
local SlashCmdList = SlashCmdList
local UIParent = UIParent
local UNITNAME_SUMMON_TITLE1 = UNITNAME_SUMMON_TITLE1
local UNITNAME_SUMMON_TITLE2 = UNITNAME_SUMMON_TITLE2
local UNITNAME_SUMMON_TITLE3 = UNITNAME_SUMMON_TITLE3
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsPlayer = UnitIsPlayer
local UnitIsPossessed = UnitIsPossessed
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local WOW_PROJECT_CLASSIC = WOW_PROJECT_CLASSIC
local WOW_PROJECT_ID = WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local bit_band = bit.band
local date = date
local tinsert = tinsert
local wipe = wipe
local tContains = tContains
local IsRatedBattleground = C_PvP.IsRatedBattleground
local IsSoloShuffle = C_PvP and C_PvP.IsSoloShuffle
local GetSoloShuffleActiveRound = C_PvP and C_PvP.GetSoloShuffleActiveRound


local CHANNELED_SPELLS = {
    [382445] = true,

}

local CHANNELED_SPELLS_CAST_ONLY = {
    [382445] = true,
}


local function GetSpellName(id)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(id)
    else
        return GetSpellInfo(id)
    end
end

OmniBar = LibStub("AceAddon-3.0"):NewAddon("OmniBar", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("OmniBar")


for k, v in pairs(addon.Cooldowns) do
    if v.duration and type(v.duration) == "number" then
        local adjust = v.adjust or 0
        if type(adjust) == "table" then
            adjust = adjust.default or 0
        end
        addon.Cooldowns[k].duration = v.duration + adjust
    end
end

addon.CooldownReduction = {}
OmniBar.activeChannels = {}



OmniBar.guardianSpiritCasts = {}

OmniBar.debugEvents = {}
local CLASS_ORDER = {
    ["GENERAL"] = 0,
    ["DEMONHUNTER"] = 1,
    ["DEATHKNIGHT"] = 2,
    ["PALADIN"] = 3,
    ["WARRIOR"] = 4,
    ["DRUID"] = 5,
    ["PRIEST"] = 6,
    ["WARLOCK"] = 7,
    ["SHAMAN"] = 8,
    ["HUNTER"] = 9,
    ["MAGE"] = 10,
    ["ROGUE"] = 11,
    ["MONK"] = 12,
    ["EVOKER"] = 13,
}

local EMPOWERED_SPELLS = {
    [357208] = true, -- Fire Breath (Preservation)
    [355936] = true, -- Dream Breath
    [367226] = true, -- Spiritbloom
}
local TIP_THE_SCALES_ID = 370553

local ARENA_STATE = {
    inArena = false,
    inPrep = false
}

local MAX_ARENA_SIZE = addon.MAX_ARENA_SIZE or 0

local PLAYER_NAME = GetUnitName("player")

local DEFAULTS = {
    adaptive                = false,
    align                   = "CENTER",
    arena                   = true,
    battleground            = true,
    border                  = true,
    borderStyle             = "original",
    center                  = false,
    columns                 = 8,
    cooldownCount           = true,
    glow                    = true,
    growUpward              = true,
    highlightFocus          = false,
    highlightTarget         = true,
    locked                  = false,
    maxIcons                = 32,
    multiple                = true,
    names                   = false,
    padding                 = 2,
    ratedBattleground       = true,
    scenario                = true,
    showUnused              = false,
    size                    = 40,
    sortMethod              = "player",
    swipeAlpha              = 0.65,
    tooltips                = true,
    trackUnit               = "ENEMY",
    unusedAlpha             = 1.0,
    usedAlpha               = 1.0,
    world                   = true,
    readyGlow               = false,
    showAfterCast           = false,
    hideChargedCooldownText = false,
    reverseCooldown         = true,
    desaturateUsed          = false,


}

addon.DEFAULTS = DEFAULTS



local DB_VERSION = 4

local MAX_DUPLICATE_ICONS = 5

local BASE_ICON_SIZE = 36

function OmniBar:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99OmniBar|r: " .. message)
end

function OmniBar:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("OmniBarDB", {
        global = {
            version = DB_VERSION,
            cooldowns = {},
            cooldownReduction = {}
        },
        profile = { bars = {} }
    }, true)

    ARENA_STATE = {
        inArena = false,
        inPrep = false
    }

    self.evokerRateBuffs = {}
    self.evokerUpdateFrame = CreateFrame("Frame")
    self.evokerUpdateFrame:Hide()
    self.evokerUpdateElapsed = 0
    self.lastEvokerUpdate = GetTime()
    self.impishInstinctsThrottle = {}

    self.evokerUpdateFrame:SetScript("OnUpdate", function(_, elapsed)
        self.evokerUpdateElapsed = self.evokerUpdateElapsed + elapsed
        if self.evokerUpdateElapsed >= 0.1 then -- Update every 0.1 seconds for smooth reduction
            local currentTime = GetTime()
            local deltaTime = currentTime - self.lastEvokerUpdate
            self.lastEvokerUpdate = currentTime
            self.evokerUpdateElapsed = 0

            self:ProcessEvokerRateReduction(deltaTime)
        end
    end)
    self:RegisterEvent("UNIT_AURA")

    self.recentCDREvents = {}
    self.lastCDRCleanup = GetTime()
    self.lastFullCDRWipe = GetTime() -- Add this line


    self.arenaSpecMap = {}
    self.cooldowns = addon.Cooldowns
    self.bars = {}
    self.specs = {}
    self.spellCasts = {}


    self.lastRage = {}
    self.warriorSpecMap = {}


    self.inArena = false
    self.db.RegisterCallback(self, "OnProfileChanged", "OnEnable")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnEnable")
    self.db.RegisterCallback(self, "OnProfileReset", "OnEnable")


    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

    self:RegisterEvent("ARENA_OPPONENT_UPDATE")
    self:RegisterEvent("UNIT_POWER_UPDATE")

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")

    self:RegisterEvent("GROUP_ROSTER_UPDATE", "GetSpecs")
    self:RegisterComm("OmniBarSpell", function(_, payload, _, sender)
        if (not UnitExists(sender)) or sender == PLAYER_NAME then return end
        local success, event, sourceGUID, sourceName, sourceFlags, spellID, serverTime = self:Deserialize(payload)
        if (not success) then return end
        self:AddSpellCast(event, sourceGUID, sourceName, sourceFlags, spellID, serverTime)
    end)
    self:RegisterMessage("OmniBar_ResetSpellCast", "OnResetSpellCast")

    local version, major, minor = C_AddOns.GetAddOnMetadata(addonName, "Version") or "", 0, 0
    if version:sub(1, 1) == "@" then
        version = "Development"
    else
        major, minor = version:match("v(%d+)%.?(%d*)")
    end
    self.version = setmetatable({
        string = version,
        major = tonumber(major),
        minor = tonumber(minor) or 0,
    }, {
        __tostring = function()
            return version
        end
    })


    if self.version.major > 0 then
        self:RegisterComm("OmniBarVersion", "ReceiveVersion")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "SendVersion")
        C_Timer_After(10, function()
            self:SendVersion()
            if IsInGuild() then self:SendVersion("GUILD") end
            self:SendVersion("YELL")
        end)
    end


    for k, v in pairs(self.db.global.cooldowns) do
        if (not GetSpellInfo(k)) then
            self.db.global.cooldowns[k] = nil
        end
    end


    for spellId, _ in pairs(self.cooldowns) do
        local name, icon
        if C_Spell and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            name = spellInfo and spellInfo.name
            icon = spellInfo and spellInfo.iconID
        else
            name, _, icon = GetSpellInfo(spellId)
        end
        self.cooldowns[spellId].icon = self.cooldowns[spellId].icon or icon
        self.cooldowns[spellId].name = name
    end
    for triggerID, reductions in pairs(self.db.global.cooldownReduction) do
        addon.CooldownReduction[tonumber(triggerID)] = {}
        for targetID, amount in pairs(reductions) do
            addon.CooldownReduction[tonumber(triggerID)][tonumber(targetID)] = amount
        end
    end

    if not self.db.global.cooldownReduction[2139] then
        self.db.global.cooldownReduction[2139] = {}
    end
    if not self.db.global.cooldownReduction[2139][2139] then
        self.db.global.cooldownReduction[2139][2139] = {
            amount = 4,
            event = "SPELL_INTERRUPT"
        }
    end


    for spellID, spellData in pairs(addon.Cooldowns) do
        if spellData.class == "MAGE" and spellData.duration and not spellData.parent then
            if spellID ~= 382445 and spellID ~= 314791 and spellID ~= 382440 then
                if not self.db.global.cooldownReduction[382445] then
                    self.db.global.cooldownReduction[382445] = {}
                end


                if not self.db.global.cooldownReduction[382445][spellID] then
                    self.db.global.cooldownReduction[382445][spellID] = {
                        amount = 3,
                        event = "SPELL_CAST_SUCCESS"
                    }
                end


                if not addon.CooldownReduction[382445] then
                    addon.CooldownReduction[382445] = {}
                end
                addon.CooldownReduction[382445][spellID] = {
                    amount = 3,
                    event = "SPELL_CAST_SUCCESS"
                }
            end
        end
    end

    addon.CooldownReduction[2139] = addon.CooldownReduction[2139] or {}
    addon.CooldownReduction[2139][2139] = {
        amount = 4,
        event = "SPELL_INTERRUPT"
    }


    addon.CooldownReduction[342247] = addon.CooldownReduction[342247] or {}
    addon.CooldownReduction[342247][212653] = {
        amount = 25,
        event = "SPELL_CAST_SUCCESS"
    }

    addon.CooldownReduction[342247] = addon.CooldownReduction[342247] or {}
    addon.CooldownReduction[342247][1953] = {
        amount = 15,
        event = "SPELL_CAST_SUCCESS"
    }


    local HOLY_FIRE = 14914
    local SMITE = 585
    local HOLY_NOVA = 132157
    local CHASTISE = 88625
    local APOTHEOSIS = 200183
    local POM = 33076
    local PWL = 440678
    local SEREN = 2050
    local FHEAL = 2061
    local HEAL_NORM = 2060


    if not addon.CooldownReduction[HOLY_FIRE] then
        addon.CooldownReduction[HOLY_FIRE] = {}
    end
    addon.CooldownReduction[HOLY_FIRE][CHASTISE] = {
        amount = 2,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }

    if not addon.CooldownReduction[SMITE] then
        addon.CooldownReduction[SMITE] = {}
    end
    addon.CooldownReduction[SMITE][CHASTISE] = {
        amount = 4,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }

    if not addon.CooldownReduction[HOLY_NOVA] then
        addon.CooldownReduction[HOLY_NOVA] = {}
    end
    addon.CooldownReduction[HOLY_NOVA][CHASTISE] = {
        amount = 4,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }










    if not addon.CooldownReduction[APOTHEOSIS] then
        addon.CooldownReduction[APOTHEOSIS] = {}
    end
    addon.CooldownReduction[APOTHEOSIS][CHASTISE] = {
        amount = 45,
        event = "SPELL_CAST_SUCCESS"
    }


    if not addon.CooldownReduction[POM] then
        addon.CooldownReduction[POM] = {}
    end
    addon.CooldownReduction[POM][SEREN] = {
        amount = 4,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }

    if not addon.CooldownReduction[PWL] then
        addon.CooldownReduction[PWL] = {}
    end
    addon.CooldownReduction[PWL][SEREN] = {
        amount = 4,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }

    if not addon.CooldownReduction[FHEAL] then
        addon.CooldownReduction[FHEAL] = {}
    end
    addon.CooldownReduction[FHEAL][SEREN] = {
        amount = 6,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }


    if not addon.CooldownReduction[HEAL_NORM] then
        addon.CooldownReduction[HEAL_NORM] = {}
    end
    addon.CooldownReduction[HEAL_NORM][SEREN] = {
        amount = 6,
        event = "SPELL_CAST_SUCCESS",
        buffCheck = true
    }













    if not addon.CooldownReduction[APOTHEOSIS] then
        addon.CooldownReduction[APOTHEOSIS] = {}
    end
    addon.CooldownReduction[APOTHEOSIS][SEREN] = {
        amount = 45,
        event = "SPELL_CAST_SUCCESS"
    }

    for spellID, spellData in pairs(addon.Cooldowns) do
        if spellData.class == "PRIEST" and spellData.duration and not spellData.parent then
            if not addon.CooldownReduction[spellID] then
                addon.CooldownReduction[spellID] = {}
            end

            addon.CooldownReduction[spellID][spellID] = {
                amount = 7,
                event = "SPELL_CAST_SUCCESS",
                buffName = "Premonition of Insight"
            }
        end
    end

    local DISPATCH = 2098
    local BTE = 315341
    local KS = 51690
    local SND = 315496
    local VANISH = 1856
    local GRAPPLE = 195457
    local cpReduction = 6


    if not addon.CooldownReduction[DISPATCH] then
        addon.CooldownReduction[DISPATCH] = {}
    end
    addon.CooldownReduction[DISPATCH][GRAPPLE] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[BTE] then
        addon.CooldownReduction[BTE] = {}
    end
    addon.CooldownReduction[BTE][GRAPPLE] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[SND] then
        addon.CooldownReduction[SND] = {}
    end
    addon.CooldownReduction[SND][GRAPPLE] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[KS] then
        addon.CooldownReduction[KS] = {}
    end
    addon.CooldownReduction[KS][GRAPPLE] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[DISPATCH] then
        addon.CooldownReduction[DISPATCH] = {}
    end
    addon.CooldownReduction[DISPATCH][VANISH] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[BTE] then
        addon.CooldownReduction[BTE] = {}
    end
    addon.CooldownReduction[BTE][VANISH] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[SND] then
        addon.CooldownReduction[SND] = {}
    end
    addon.CooldownReduction[SND][VANISH] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }

    if not addon.CooldownReduction[KS] then
        addon.CooldownReduction[KS] = {}
    end
    addon.CooldownReduction[KS][VANISH] = {
        amount = cpReduction,
        event = "SPELL_CAST_SUCCESS",
        buffName = "True Bearing"
    }



    local BEAM = 78675
    local BEAMKICk = 97547

    addon.CooldownReduction[BEAMKICk] = addon.CooldownReduction[BEAMKICk] or {}
    addon.CooldownReduction[BEAMKICk][78675] = {
        amount = 15,
        event = "SPELL_INTERRUPT"
    }



    -- Cold Snap reduces Ice Block cooldown by 5 minutes (300 seconds)
    addon.CooldownReduction[235219] = addon.CooldownReduction[235219] or {}
    addon.CooldownReduction[235219][45438] = { -- Ice Block
        amount = 300,
        event = "SPELL_CAST_SUCCESS"
    }

    -- Also add to the global cooldown reduction
    if not self.db.global.cooldownReduction[235219] then
        self.db.global.cooldownReduction[235219] = {}
    end
    self.db.global.cooldownReduction[235219][45438] = {
        amount = 300,
        event = "SPELL_CAST_SUCCESS"
    }

    -- Charge on Leap
    if not self.db.global.cooldownReduction[100] then
        self.db.global.cooldownReduction[100] = {}
    end
    if not self.db.global.cooldownReduction[100][6544] then
        self.db.global.cooldownReduction[100][6544] = {
            amount = 2,
            event = "SPELL_CAST_SUCCESS"
        }
    end

    addon.CooldownReduction[100] = addon.CooldownReduction[100] or {}
    addon.CooldownReduction[100][6544] = {
        amount = 2,
        event = "SPELL_CAST_SUCCESS"
    }

    -- Charge on Leap (new id)
    if not self.db.global.cooldownReduction[100] then
        self.db.global.cooldownReduction[100] = {}
    end
    if not self.db.global.cooldownReduction[100][52174] then
        self.db.global.cooldownReduction[100][52174] = {
            amount = 2,
            event = "SPELL_CAST_SUCCESS"
        }
    end

    addon.CooldownReduction[100] = addon.CooldownReduction[100] or {}
    addon.CooldownReduction[100][52174] = {
        amount = 2,
        event = "SPELL_CAST_SUCCESS"
    }


    -- Leap on Charge
    if not self.db.global.cooldownReduction[52174] then
        self.db.global.cooldownReduction[52174] = {}
    end
    if not self.db.global.cooldownReduction[52174][100] then
        self.db.global.cooldownReduction[52174][100] = {
            amount = 5,
            event = "SPELL_CAST_SUCCESS"
        }
    end

    addon.CooldownReduction[52174] = addon.CooldownReduction[52174] or {}
    addon.CooldownReduction[52174][100] = {
        amount = 5,
        event = "SPELL_CAST_SUCCESS"
    }

    -- Leap on Charge new
    if not self.db.global.cooldownReduction[52174] then
        self.db.global.cooldownReduction[52174] = {}
    end
    if not self.db.global.cooldownReduction[52174][126664] then
        self.db.global.cooldownReduction[52174][126664] = {
            amount = 5,
            event = "SPELL_CAST_SUCCESS"
        }
    end

    addon.CooldownReduction[52174] = addon.CooldownReduction[52174] or {}
    addon.CooldownReduction[52174][126664] = {
        amount = 5,
        event = "SPELL_CAST_SUCCESS"
    }


    self:SetupOptions()
    self:SetupFlashAnimation()


    self:SetupCooldownUpdates()
end

function OmniBar:HasBuff(unit, buffName, filter)
    if not unit or not UnitExists(unit) then return false end

    filter = filter or "HELPFUL"
    local _, _, _, _, _, _, _, _, _, _ = AuraUtil.FindAuraByName(buffName, unit, filter)

    return _ ~= nil
end

function OmniBar:PLAYER_ENTERING_WORLD(event, isInitialLogin, isReloadingUi)
    local _, instanceType = IsInInstance()
    self.inArena = (instanceType == "arena")
    ARENA_STATE.inArena = self.inArena

    for destGUID, castInfo in pairs(self.guardianSpiritCasts) do
        if castInfo.expiryTimer then
            castInfo.expiryTimer:Cancel()
        end
    end
    wipe(self.guardianSpiritCasts)

    for _, bar in ipairs(self.bars) do
        if not bar.disabled then
            if bar.castHistory then
                wipe(bar.castHistory)
            end
            OmniBar_OnEvent(bar, "PLAYER_ENTERING_WORLD")
        end
    end
end

function OmniBar:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
    self.arenaPrepped = true
    self.warriorSpecMap = {}
    self.arenaSpecMap = {} -- ADD THIS to create it on self


    for _, bar in ipairs(self.bars) do
        if not bar.disabled then
            bar.detected = {}
            wipe(bar.active)

            bar.arenaSpecMap = {}
            if bar.castHistory then -- Add safety check
                wipe(bar.castHistory)
            end
            OmniBar_ResetIcons(bar)

            for i = 1, MAX_ARENA_SIZE do
                local specID = GetArenaOpponentSpec(i)
                if specID and specID > 0 then
                    local _, _, _, _, _, class = GetSpecializationInfoByID(specID)
                    if class then
                        bar.arenaSpecMap[i] = specID
                        self.arenaSpecMap[i] = specID -- ADD THIS to also store on self



                        if bar.settings.showUnused then
                            bar.detected[i] = class

                            if bar.settings.trackUnit == "ENEMY" or bar.settings.trackUnit == "arena" .. i then
                                for spellID, spell in pairs(addon.Cooldowns) do
                                    if OmniBar_IsSpellEnabled(bar, spellID) and spell.class == "GENERAL" then
                                        OmniBar_AddIcon(bar, { spellID = spellID, sourceGUID = i, specID = specID })
                                    end
                                end

                                for spellID, spell in pairs(addon.Cooldowns) do
                                    if OmniBar_IsSpellEnabled(bar, spellID) and spell.class == class then
                                        local belongsToSpec = true
                                        if spell.specID then
                                            belongsToSpec = false
                                            for j = 1, #spell.specID do
                                                if spell.specID[j] == specID then
                                                    belongsToSpec = true
                                                    break
                                                end
                                            end
                                        end

                                        if belongsToSpec then
                                            OmniBar_AddIcon(bar, { spellID = spellID, sourceGUID = i, specID = specID })
                                        end
                                    end
                                end
                            end
                        end

                        if class == "WARRIOR" then
                            local unit = "arena" .. i
                            local unitGUID = UnitGUID(unit)
                            if unitGUID then
                                self.warriorSpecMap[unitGUID] = specID
                            end

                            self.warriorSpecMap["arena" .. i] = specID
                        end
                    end
                end
            end

            if bar.settings.showUnused then
                OmniBar_Position(bar)
            end
        end
    end
end

function OmniBar:ARENA_OPPONENT_UPDATE(event, unit, updateType)
    if not unit or not UnitExists(unit) then return end

    if updateType == "cleared" then
        for _, bar in ipairs(self.bars) do
            if not bar.disabled then
                wipe(bar.detected)
                if bar.castHistory then -- Add safety check
                    wipe(bar.castHistory)
                end

                wipe(bar.active)
                bar.arenaSpecMap = {}
                OmniBar_ResetIcons(bar)

                self.arenaPrepped = false
                ARENA_STATE.inPrep = true
            end
        end


        for destGUID, castInfo in pairs(self.guardianSpiritCasts) do
            if castInfo.expiryTimer then
                castInfo.expiryTimer:Cancel()
            end
        end
        wipe(self.guardianSpiritCasts)
        return
    end

    if updateType == "seen" then
        local arenaIndex = tonumber(unit:match("arena(%d+)"))
        if arenaIndex and self.arenaSpecMap and self.arenaSpecMap[arenaIndex] then
            local guid = UnitGUID(unit)
            if guid then
                self.arenaGUIDMap = self.arenaGUIDMap or {}
                self.arenaGUIDMap[guid] = self.arenaSpecMap[arenaIndex]
            end
        end
    end
end

local function GetDefaultCommChannel()
    if IsInRaid() then
        return IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "RAID"
    elseif IsInGroup() then
        return IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
    elseif IsInGuild() then
        return "GUILD"
    else
        return "YELL"
    end
end

function OmniBar:ReceiveVersion(_, payload, _, sender)
    -- self.sender = sender
    -- if (not payload) or type(payload) ~= "string" then return end
    -- local major, minor = payload:match("v(%d+)%.?(%d*)")
    -- major = tonumber(major)
    -- minor = tonumber(minor) or 0
    -- if (not major) or (not minor) then return end
    -- if major < self.version.major then return end
    -- if major == self.version.major and minor <= self.version.minor then return end
    -- if (not self.outdatedSender) or self.outdatedSender == sender then
    --     self.outdatedSender = sender
    --     return
    -- end
    -- if self.nextWarn and self.nextWarn > GetTime() then return end
    -- self.nextWarn = GetTime() + 1800
    -- self:Print(L.UPDATE_AVAILABLE)
    -- self.outdatedSender = nil
end

function OmniBar:SendVersion(distribution)
    -- if (not self.version) or self.version.major == 0 then return end
    -- self:SendCommMessage("OmniBarVersion", self.version.string, distribution or GetDefaultCommChannel())
end

-- DEBUG: Let's see why my OnEnable changes aren't working at all

-- ============================================================================
-- Add this debug version of OnEnable to see what's happening:
-- ============================================================================
function OmniBar:OnEnable()
    wipe(self.specs)
    wipe(self.spellCasts)

    self.index = 1

    for i = #self.bars, 1, -1 do
        self:Delete(self.bars[i].key, true)
        table.remove(self.bars, i)
    end

    for key, _ in pairs(self.db.profile.bars) do
        self:Initialize(key)
        self.index = self.index + 1
    end

    if self.index == 1 then
        self:Initialize("OmniBar1", "OmniBar")
        self.index = 2
    end

    for key, _ in pairs(self.db.profile.bars) do
        self:AddBarToOptions(key)
    end

    self:GetSpecs()

    C_Timer.After(0.1, function()
        self:Refresh(true)
    end)
end

function OmniBar_Refresh(self)
    OmniBar_ResetIcons(self)
    OmniBar_ReplaySpellCasts(self)
end

function OmniBar:Decode(encoded)
    local LibDeflate = LibStub:GetLibrary("LibDeflate")
    local decoded = LibDeflate:DecodeForPrint(encoded)
    if (not decoded) then return self:ImportError("DecodeForPrint") end
    local decompressed = LibDeflate:DecompressZlib(decoded)
    if (not decompressed) then return self:ImportError("DecompressZlib") end
    local success, deserialized = self:Deserialize(decompressed)
    if (not success) then return self:ImportError("Deserialize") end
    return deserialized
end

function OmniBar:ExportProfile()
    local LibDeflate = LibStub:GetLibrary("LibDeflate")
    local data = {
        profile = self.db.profile,
        customSpells = self.db.global.cooldowns,
        version = 1
    }
    local serialized = self:Serialize(data)
    if (not serialized) then return end
    local compressed = LibDeflate:CompressZlib(serialized)
    if (not compressed) then return end
    return LibDeflate:EncodeForPrint(compressed)
end

function OmniBar:ImportError(message)
    if (not message) or self.import.editBox.editBox:GetNumLetters() == 0 then
        self.import.statustext:SetTextColor(1, 0.82, 0)
        self.import:SetStatusText(L["Paste a code to import an OmniBar profile."])
    else
        self.import.statustext:SetTextColor(1, 0, 0)
        self.import:SetStatusText(L["Import failed (%s)"]:format(message))
    end
    self.import.button:SetDisabled(true)
end

function OmniBar:ImportProfile(data)
    if (data.version ~= 1) then return self:ImportError(L["Invalid version"]) end

    local profile = L["Imported (%s)"]:format(date())

    self.db.profiles[profile] = data.profile
    self.db:SetProfile(profile)


    for k, v in pairs(data.customSpells) do
        self.db.global.cooldowns[k] = nil
        self.options.args.customSpells.args.spellId.set(nil, k, v)
    end

    self:OnEnable()
    LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
    return true
end

function OmniBar:ShowExport()
    self.export.editBox:SetText(self:ExportProfile())
    self.export:Show()
    self.export.editBox:SetFocus()
    self.export.editBox:HighlightText()
end

function OmniBar:ShowImport()
    self.import.editBox:SetText("")
    self:ImportError()
    self.import:Show()
    self.import.button:SetDisabled(true)
    self.import.editBox:SetFocus()
end

function OmniBar:Delete(key, keepProfile)
    local bar = _G[key]
    if (not bar) then return end
    bar:UnregisterEvent("PLAYER_ENTERING_WORLD")
    bar:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    bar:UnregisterEvent("PLAYER_TARGET_CHANGED")
    bar:UnregisterEvent("PLAYER_REGEN_DISABLED")
    bar:UnregisterEvent("GROUP_ROSTER_UPDATE")
    bar:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
    if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
        bar:UnregisterEvent("PLAYER_FOCUS_CHANGED")
        bar:UnregisterEvent("ARENA_OPPONENT_UPDATE")
    end
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        bar:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
        bar:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
        bar:UnregisterEvent("PVP_MATCH_ACTIVE")
    end
    bar:Hide()
    if (not keepProfile) then self.db.profile.bars[key] = nil end
    self.options.args.bars.args[key] = nil
    LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
end

OmniBar.BackupCooldowns = {}

function OmniBar:CopyCooldown(cooldown)
    local copy = {}

    for _, v in pairs({ "class", "charges", "parent", "name", "icon" }) do
        if cooldown[v] then
            copy[v] = cooldown[v]
        end
    end

    if cooldown.duration then
        if type(cooldown.duration) == "table" then
            copy.duration = {}
            for k, v in pairs(cooldown.duration) do
                copy.duration[k] = v
            end
        else
            copy.duration = { default = cooldown.duration }
        end
    end

    if cooldown.specID then
        copy.specID = {}
        for i = 1, #cooldown.specID do
            table.insert(copy.specID, cooldown.specID[i])
        end
    end

    return copy
end

SLASH_OBARENA1 = "/obarena"
SlashCmdList.OBARENA = function()
    print("OmniBar Arena State:")
    print("In Arena: " .. tostring(ARENA_STATE.inArena))
    print("In Prep: " .. tostring(ARENA_STATE.inPrep))
    print("Active Combat: " .. tostring(ARENA_STATE.inActiveCombat))
    print("Stealth Protection: " .. tostring(ARENA_STATE.stealthProtection))
    print("Last Stealth: " .. string.format("%.1f seconds ago", GetTime() - ARENA_STATE.lastStealthTime))
    print("Last Prep Event: " .. string.format("%.1f seconds ago", GetTime() - ARENA_STATE.lastPrepEvent))


    print("Detected Specs:")
    for i = 1, MAX_ARENA_SIZE do
        local specID = GetArenaOpponentSpec(i)
        if specID and specID > 0 then
            local _, name, _, _, _, class = GetSpecializationInfoByID(specID)
            print(string.format("Arena%d: %s (%s) - ID: %d", i, name or "Unknown", class or "Unknown", specID))
        else
            print(string.format("Arena%d: No spec detected", i))
        end
    end

    print("Stealth Events:")
    for unit, event in pairs(ARENA_STATE.stealthEvents) do
        print(string.format("Arena%d: %s (%.1f seconds ago)",
            unit, event.type, GetTime() - event.time))
    end
end

function OmniBar_ArenaAddIcon(self, info)
    if not OmniBar_IsSpellEnabled(self, info.spellID) then return end


    local spellClass = addon.Cooldowns[info.spellID].class


    if spellClass == "GENERAL" then
        return OmniBar_AddIcon(self, info)
    end


    if info.sourceGUID and type(info.sourceGUID) == "number" then
        local arenaIndex = info.sourceGUID
        local specID = info.specID or self.arenaSpecMap[arenaIndex]

        if addon.Cooldowns[info.spellID].specID and specID and specID > 0 then
            for i = 1, #addon.Cooldowns[info.spellID].specID do
                if addon.Cooldowns[info.spellID].specID[i] == specID then
                    return OmniBar_AddIcon(self, info)
                end
            end
        elseif not addon.Cooldowns[info.spellID].specID then
            return OmniBar_AddIcon(self, info)
        end
    end

    return nil
end

function OmniBar:UpdateArenaOpponents()
    local _, instanceType = IsInInstance()
    self.inArena = (instanceType == "arena")


    if not self.inArena then return end


    for i = 1, MAX_ARENA_SIZE do
        local specID = GetArenaOpponentSpec(i)
        if specID and specID > 0 then
            local _, _, _, _, _, class = GetSpecializationInfoByID(specID)
            if class then
                self.arenaSpecMap = self.arenaSpecMap or {}
                self.arenaSpecMap[i] = specID


                for _, bar in ipairs(self.bars) do
                    if not bar.disabled and bar.settings.showUnused and
                        (bar.settings.trackUnit == "ENEMY" or bar.settings.trackUnit == "arena" .. i) then
                        local hasIconsForUnit = false
                        for _, icon in ipairs(bar.active) do
                            if icon.sourceGUID == i then
                                hasIconsForUnit = true
                                break
                            end
                        end


                        if not hasIconsForUnit then
                            OmniBar_AddOpponentIcons(bar, i, specID, class)
                        end
                    end
                end
            end
        end
    end
end

function OmniBar_AddOpponentIcons(bar, arenaIndex, specID, class)
    if not class or not specID then return end


    local addedSpells = {}


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(bar, spellID) and spell.class == "GENERAL" and not addedSpells[spellID] then
            OmniBar_AddIcon(bar, { spellID = spellID, sourceGUID = arenaIndex, specID = specID })
            addedSpells[spellID] = true
        end
    end


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(bar, spellID) and spell.class == class and not addedSpells[spellID] then
            local belongsToSpec = true
            if spell.specID then
                belongsToSpec = false
                for i = 1, #spell.specID do
                    if spell.specID[i] == specID then
                        belongsToSpec = true
                        break
                    end
                end
            end

            if belongsToSpec then
                OmniBar_AddIcon(bar, { spellID = spellID, sourceGUID = arenaIndex, specID = specID })
                addedSpells[spellID] = true
            end
        end
    end


    OmniBar_Position(bar)
end

-- function OmniBar:AddCustomSpells()
--     for k, v in pairs(self.BackupCooldowns) do
--         addon.Cooldowns[k] = self:CopyCooldown(v)
--     end


--     for k, v in pairs(self.db.global.cooldowns) do
--         local name, _, icon
--         if C_Spell and C_Spell.GetSpellInfo then
--             local spellInfo = C_Spell.GetSpellInfo(k)
--             name = spellInfo and spellInfo.name
--             icon = spellInfo and spellInfo.iconID
--         else
--             name, _, icon = GetSpellInfo(k)
--         end
--         if name then
--             if addon.Cooldowns[k] and (not addon.Cooldowns[k].custom) and (not self.BackupCooldowns[k]) then
--                 self.BackupCooldowns[k] = self:CopyCooldown(addon.Cooldowns[k])
--             end
--             addon.Cooldowns[k] = v
--             addon.Cooldowns[k].icon = addon.Cooldowns[k].icon or icon
--             addon.Cooldowns[k].name = name
--             if SPELL_ID_BY_NAME then SPELL_ID_BY_NAME[name] = k end
--         else
--             self.db.global.cooldowns[k] = nil
--         end
--     end
-- end
function OmniBar:AddCustomSpells()
    for k, v in pairs(self.BackupCooldowns) do
        addon.Cooldowns[k] = self:CopyCooldown(v)
    end

    for k, v in pairs(self.db.global.cooldowns) do
        local name, _, icon
        if C_Spell and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(k)
            name = spellInfo and spellInfo.name
            icon = spellInfo and spellInfo.iconID
        else
            name, _, icon = GetSpellInfo(k)
        end
        if name then
            if addon.Cooldowns[k] and (not addon.Cooldowns[k].custom) and (not self.BackupCooldowns[k]) then
                self.BackupCooldowns[k] = self:CopyCooldown(addon.Cooldowns[k])
            end
            addon.Cooldowns[k] = v
            addon.Cooldowns[k].icon = addon.Cooldowns[k].icon or icon
            addon.Cooldowns[k].name = name
            if SPELL_ID_BY_NAME then SPELL_ID_BY_NAME[name] = k end
        else
            self.db.global.cooldowns[k] = nil
        end
    end

    if self.inArena then
        -- Just update durations on existing icons
        for _, bar in ipairs(self.bars) do
            for _, icon in ipairs(bar.active) do
                if icon.spellID and addon.Cooldowns[icon.spellID] then
                    -- Update the duration with new custom value
                    icon.duration = self:GetCooldownDuration(addon.Cooldowns[icon.spellID], icon.specID)
                end
            end
        end
    else
        self:Refresh(true)
    end
end

local function OmniBar_IsAdaptive(self)
    if self.settings.adaptive then return true end


    if self.zone == "arena" then return true end


    if self.settings.trackUnit ~= "ENEMY" then return true end
end

function OmniBar_SpellCast(self, event, name, spellID)
    if self.disabled then return end



    OmniBar_AddIcon(self, self.spellCasts[name][spellID])
end

-- function OmniBar:Initialize(key, name)
--     if (not self.db.profile.bars[key]) then
--         self.db.profile.bars[key] = { name = name }
--         for a, b in pairs(DEFAULTS) do
--             self.db.profile.bars[key][a] = b
--         end
--     end

--     self:AddCustomSpells()

--     local f = _G[key] or CreateFrame("Frame", key, UIParent, "OmniBarTemplate")
--     f:Show()
--     f.settings = self.db.profile.bars[key]
--     f.settings.align = f.settings.align or "CENTER"
--     f.settings.maxIcons = f.settings.maxIcons or DEFAULTS.maxIcons
--     f.key = key
--     f.icons = {}
--     f.active = {}
--     f.detected = {}
--     f.castHistory = f.castHistory or {} -- Initialize with safety check

--     f.spellCasts = self.spellCasts
--     f.specs = self.specs
--     f.BASE_ICON_SIZE = BASE_ICON_SIZE
--     f.numIcons = 0
--     f:RegisterForDrag("LeftButton")
--     f.sortKeys = {}
--     f.sortKeysAssigned = nil
--     f.forceResort = nil
--     f.frozenOrder = nil

--     f.anchor.text:SetText(f.settings.name)


--     f.settings.units = nil
--     if (not f.settings.trackUnit) then f.settings.trackUnit = "ENEMY" end


--     if f.settings.spells then
--         for k, _ in pairs(f.settings.spells) do
--             if (not addon.Cooldowns[k]) or addon.Cooldowns[k].parent then f.settings.spells[k] = nil end
--         end
--     end

--     f.adaptive = OmniBar_IsAdaptive(f)


--     for k, v in pairs(f.settings) do
--         local spellID = tonumber(k:match("^spell(%d+)"))
--         if spellID then
--             if (not f.settings.spells) then
--                 f.settings.spells = {}
--                 if (not f.settings.noDefault) then
--                     for k, v in pairs(addon.Cooldowns) do
--                         if v.default then f.settings.spells[k] = true end
--                     end
--                 end
--             end
--             f.settings.spells[spellID] = v
--             f.settings[k] = nil
--         end
--     end
--     f.settings.noDefault = nil


--     OmniBar_LoadSettings(f)


--     for spellID, _ in pairs(addon.Cooldowns) do
--         if OmniBar_IsSpellEnabled(f, spellID) then
--             OmniBar_CreateIcon(f)
--         end
--     end


--     for i = 1, MAX_DUPLICATE_ICONS do
--         OmniBar_CreateIcon(f)
--     end

--     OmniBar_ShowAnchor(f)
--     OmniBar_ResetIcons(f)
--     OmniBar_UpdateIcons(f)
--     OmniBar_Center(f)

--     f.OnEvent = OmniBar_OnEvent

--     f:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
--     f:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnEvent")
--     f:RegisterEvent("PLAYER_TARGET_CHANGED", "OnEvent")
--     f:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
--     f:RegisterEvent("GROUP_ROSTER_UPDATE", "OnEvent")

--     if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
--         f:RegisterEvent("PLAYER_FOCUS_CHANGED", "OnEvent")
--         f:RegisterEvent("ARENA_OPPONENT_UPDATE", "OnEvent")
--     end

--     if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
--         f:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", "OnEvent")
--         f:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")
--         f:RegisterEvent("PVP_MATCH_ACTIVE", "OnEvent")
--     end

--     f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "OnEvent")

--     table.insert(self.bars, f)
-- end

function OmniBar:Initialize(key, name)
    if (not self.db.profile.bars[key]) then
        self.db.profile.bars[key] = { name = name }
        for a, b in pairs(DEFAULTS) do
            self.db.profile.bars[key][a] = b
        end
    end

    self:AddCustomSpells()

    local f = _G[key] or CreateFrame("Frame", key, UIParent, "OmniBarTemplate")
    f:Show()
    f.settings = self.db.profile.bars[key]
    f.settings.align = f.settings.align or "CENTER"
    f.settings.maxIcons = f.settings.maxIcons or DEFAULTS.maxIcons
    f.key = key
    f.icons = {}
    f.active = {}
    f.detected = {}
    f.castHistory = f.castHistory or {}

    f.spellCasts = self.spellCasts
    f.specs = self.specs
    f.BASE_ICON_SIZE = BASE_ICON_SIZE
    f.numIcons = 0
    f:RegisterForDrag("LeftButton")
    f.sortKeys = {}
    f.sortKeysAssigned = nil
    f.forceResort = nil
    f.frozenOrder = nil

    f.anchor.text:SetText(f.settings.name)


    f.settings.units = nil
    if (not f.settings.trackUnit) then f.settings.trackUnit = "ENEMY" end


    if f.settings.spells then
        for k, _ in pairs(f.settings.spells) do
            if (not addon.Cooldowns[k]) or addon.Cooldowns[k].parent then f.settings.spells[k] = nil end
        end
    end

    f.adaptive = OmniBar_IsAdaptive(f)


    for k, v in pairs(f.settings) do
        local spellID = tonumber(k:match("^spell(%d+)"))
        if spellID then
            if (not f.settings.spells) then
                f.settings.spells = {}
                if (not f.settings.noDefault) then
                    for k, v in pairs(addon.Cooldowns) do
                        if v.default then f.settings.spells[k] = true end
                    end
                end
            end
            f.settings.spells[spellID] = v
            f.settings[k] = nil
        end
    end
    f.settings.noDefault = nil


    OmniBar_LoadSettings(f)


    for spellID, _ in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(f, spellID) then
            OmniBar_CreateIcon(f)
        end
    end


    for i = 1, MAX_DUPLICATE_ICONS do
        OmniBar_CreateIcon(f)
    end

    OmniBar_ShowAnchor(f)
    OmniBar_ResetIcons(f)
    OmniBar_UpdateIcons(f)
    OmniBar_Center(f)

    f.OnEvent = OmniBar_OnEvent

    f:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnEvent")
    f:RegisterEvent("PLAYER_TARGET_CHANGED", "OnEvent")
    f:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
    f:RegisterEvent("GROUP_ROSTER_UPDATE", "OnEvent")

    if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
        f:RegisterEvent("PLAYER_FOCUS_CHANGED", "OnEvent")
        f:RegisterEvent("ARENA_OPPONENT_UPDATE", "OnEvent")
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        f:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", "OnEvent")
        f:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")
        f:RegisterEvent("PVP_MATCH_ACTIVE", "OnEvent")
    end

    f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "OnEvent")

    table.insert(self.bars, f)
end

-- local function SanitizeBarName(name)
--     if not name or name == "" then
--         return nil
--     end

--     -- Remove spaces and convert to proper case
--     local sanitized = name:gsub("%s+", ""):gsub("^%l", string.upper)

--     -- Remove any characters that aren't alphanumeric
--     sanitized = sanitized:gsub("[^%w]", "")

--     -- Ensure it starts with a letter
--     if not sanitized:match("^%a") then
--         sanitized = "Bar" .. sanitized
--     end

--     -- Limit length to prevent issues
--     if #sanitized > 20 then
--         sanitized = sanitized:sub(1, 20)
--     end

--     return "OmniBar" .. sanitized
-- end

local function SanitizeBarName(name)
    if not name or name == "" or type(name) ~= "string" then
        return nil
    end

    -- Remove spaces and convert to proper case
    local sanitized = name:gsub("%s+", ""):gsub("^%l", string.upper)

    -- Remove any characters that aren't alphanumeric
    sanitized = sanitized:gsub("[^%w]", "")

    -- Ensure it starts with a letter
    if not sanitized:match("^%a") then
        sanitized = "Bar" .. sanitized
    end

    -- Limit length to prevent issues
    if #sanitized > 20 then
        sanitized = sanitized:sub(1, 20)
    end

    return "OmniBar" .. sanitized
end
local function GenerateUniqueKey(self, baseName)
    local baseKey = SanitizeBarName(baseName)
    if not baseKey then
        -- Fallback to old system if name can't be sanitized
        return "OmniBar" .. self.index
    end

    local key = baseKey
    local counter = 1

    -- Check if key already exists
    while self.db.profile.bars[key] do
        key = baseKey .. counter
        counter = counter + 1
    end

    return key
end

-- function OmniBar:Create()
--     while true do
--         local key = "OmniBar" .. self.index
--         self.index = self.index + 1
--         if (not self.db.profile.bars[key]) then
--             self:Initialize(key, "OmniBar " .. (self.index - 1))
--             self:AddBarToOptions(key, true)
--             self:OnEnable()
--             return
--         end
--     end
-- end
function OmniBar:Create()
    while true do
        local key = "OmniBar" .. self.index
        self.index = self.index + 1
        if (not self.db.profile.bars[key]) then
            self:Initialize(key, "OmniBar " .. (self.index - 1))
            self:AddBarToOptions(key, true)
            self:OnEnable()
            return
        end
    end
end

function OmniBar:RenameBar(oldKey, newName)
    if not self.db.profile.bars[oldKey] then
        self:Print("Bar with key '" .. oldKey .. "' not found.")
        return false
    end

    local newKey = GenerateUniqueKey(self, newName)

    if newKey == oldKey then
        -- Just update the display name
        self.db.profile.bars[oldKey].name = newName
        if _G[oldKey] then
            _G[oldKey].anchor.text:SetText(newName)
        end
        return true
    end

    -- Copy the bar data to new key
    self.db.profile.bars[newKey] = {}
    for k, v in pairs(self.db.profile.bars[oldKey]) do
        self.db.profile.bars[newKey][k] = v
    end
    self.db.profile.bars[newKey].name = newName

    -- Delete old bar and create new one
    self:Delete(oldKey, false)
    self:Initialize(newKey, newName)
    self:AddBarToOptions(newKey, true)

    self:Print("Bar renamed from '" .. oldKey .. "' to '" .. newKey .. "'")
    return true
end

-- Add utility function to list all bars with their keys
function OmniBar:ListBars()
    self:Print("Current bars:")
    for key, barData in pairs(self.db.profile.bars) do
        local displayName = barData.name or "Unnamed"
        self:Print("  Key: " .. key .. " | Name: " .. displayName)
    end
end

-- Add slash command support for the new functionality


SLASH_OMNIBAR_RENAME1 = "/obrename"
SlashCmdList.OMNIBAR_RENAME = function(args)
    local oldKey, newName = args:match("^(%S+)%s+(.+)$")
    if not oldKey or not newName then
        OmniBar:Print("Usage: /obrename <current_key> <new_name>")
        OmniBar:Print("Use /oblist to see current bar keys")
        return
    end

    OmniBar:RenameBar(oldKey, newName)
end

SLASH_OMNIBAR_LIST1 = "/oblist"
SlashCmdList.OMNIBAR_LIST = function()
    OmniBar:ListBars()
end


function OmniBar:Refresh(full)
    self:GetSpecs()
    for key, _ in pairs(self.db.profile.bars) do
        local f = _G[key]
        if f then
            f.container:SetScale(f.settings.size / BASE_ICON_SIZE)
            if full then
                f.adaptive = OmniBar_IsAdaptive(f)
                OmniBar_OnEvent(f, "PLAYER_ENTERING_WORLD")
                OmniBar_OnEvent(f, "PLAYER_TARGET_CHANGED")
                OmniBar_OnEvent(f, "PLAYER_FOCUS_CHANGED")
                OmniBar_OnEvent(f, "GROUP_ROSTER_UPDATE")
            else
                OmniBar_LoadPosition(f)
                OmniBar_UpdateIcons(f)
                OmniBar_Center(f)
            end
        end
    end
end

local Masque = LibStub and LibStub("Masque", true)


local SPEC_ID_BY_NAME = {}
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    for classID = 1, MAX_CLASSES do
        local _, classToken = GetClassInfo(classID)
        SPEC_ID_BY_NAME[classToken] = {}
        for i = 1, GetNumSpecializationsForClassID(classID) do
            local id, name = GetSpecializationInfoForClassID(classID, i)
            SPEC_ID_BY_NAME[classToken][name] = id
        end
    end
end

local function UnitIsHostile(unit)
    if (not unit) then return end
    if UnitIsUnit("player", unit) then return end
    local reaction = UnitReaction("player", unit)
    if (not reaction) then return end
    return UnitIsPlayer(unit) and reaction < 4 and (not UnitIsPossessed(unit))
end

function OmniBar_ShowAnchor(self)
    if self.disabled or self.settings.locked or #self.active > 0 then
        self.anchor:Hide()
    else
        local width = self.anchor.text:GetWidth() + 29
        self.anchor:SetSize(width, 30)
        self.anchor:Show()
    end
end

local LCG = LibStub("LibCustomGlow-1.0")


-- function OmniBar_SetupActivationOverlay(icon)
--     if not icon.spellActivationAlert then
--         icon.spellActivationAlert = CreateFrame("Frame", nil, icon, "ActionBarButtonSpellActivationAlert")
--         icon.spellActivationAlert:SetSize(icon:GetWidth() * 1.4, icon:GetHeight() * 1.4)
--         icon.spellActivationAlert:SetPoint("CENTER", icon, "CENTER", 0, 0)
--         icon.spellActivationAlert:Hide()
--     end
-- end



-- function OmniBar_HideActivationGlow(icon)
--     if not icon or not icon.spellActivationAlert then return end

--     if icon.spellActivationAlert.ProcStartAnim and icon.spellActivationAlert.ProcStartAnim:IsPlaying() then
--         icon.spellActivationAlert.ProcStartAnim:Stop()
--     end

--     icon.spellActivationAlert:Hide()
-- end


-- function OmniBar_ShowActivationGlow(icon)
--     if not icon then return end

--     OmniBar_SetupActivationOverlay(icon)

--     if not icon.spellActivationAlert:IsShown() then
--         icon.spellActivationAlert:Show()
--         icon.spellActivationAlert.ProcStartAnim:Play()
--     end
-- end
function OmniBar_SetupActivationOverlay(icon)
    if not icon.glowInitialized then
        icon.glowInitialized = true
    end
end

function OmniBar_ShowActivationGlow(icon)
    if not icon then return end

    OmniBar_HideActivationGlow(icon)


    local frameLevel = icon:GetFrameLevel() + 5


    LCG.ProcGlow_Start(icon, {
        color = { 1, 1, 1, 0.7 },
        startAnim = false,
        duration = 1,
        xOffset = 2,
        yOffset = 2,
        frameLevel = frameLevel
    })

    icon.hasCustomGlow = true
end

function OmniBar_HideActivationGlow(icon)
    if not icon then return end

    if icon.hasCustomGlow then
        LCG.ProcGlow_Stop(icon)
        icon.hasCustomGlow = nil
    end
end

function OmniBar_CreateIcon(self)
    if InCombatLockdown() then return end
    self.numIcons = self.numIcons + 1
    local name = self:GetName()
    local key = name .. "Icon" .. self.numIcons
    local f = _G[key] or CreateFrame("Button", key, _G[name .. "Icons"], "OmniBarButtonTemplate")

    f.flash:SetAlpha(0)
    f.NewItemTexture:SetAlpha(0)
    if not f.borderTop then
        f.borderTop = f:CreateTexture(nil, "OVERLAY")
        f.borderBottom = f:CreateTexture(nil, "OVERLAY")
        f.borderLeft = f:CreateTexture(nil, "OVERLAY")
        f.borderRight = f:CreateTexture(nil, "OVERLAY")
    end


    OmniBar_SetupActivationOverlay(f)
    OmniBar_HideActivationGlow(f)


    f.pendingHide = false

    table.insert(self.icons, f)
end

local function SpellBelongsToSpec(spellID, specID)
    if not addon.Cooldowns[spellID].specID then return true end


    if not specID or specID == 0 then
        return true
    end


    for i = 1, #addon.Cooldowns[spellID].specID do
        if addon.Cooldowns[spellID].specID[i] == specID then return true end
    end

    return false
end
local SPECIFIC_SPELL_ID = 32727
function HasSpecificBuff()
    local i = 1
    while true do
        local name, icon, count, debuffType, duration, expirationTime, source,
        isStealable, nameplateShowPersonal, spellId = UnitBuff("player", i)

        if not name then break end

        if spellId == SPECIFIC_SPELL_ID then
            return true
        end
        i = i + 1
    end

    return false
end

function OmniBar:UpdateBarsWithArenaSpecs()
    if not self.arenaSpecsInitialized then return end


    for _, bar in ipairs(self.bars) do
        if not bar.disabled and bar.settings.showUnused then
            if bar.inArena and bar.settings.trackUnit == "ENEMY" then
                local cooldownStates = {}
                for i, icon in ipairs(bar.active) do
                    if icon.spellID and icon:IsVisible() then
                        local remainingTime = icon.cooldown and icon.cooldown.finish and
                            (icon.cooldown.finish - GetTime()) or 0

                        local key = tostring(icon.spellID) .. "-" .. tostring(icon.sourceGUID)
                        cooldownStates[key] = {
                            charges = icon.charges,
                            remainingTime = remainingTime > 0 and remainingTime or 0,
                            sourceGUID = icon.sourceGUID,
                            sourceName = icon.sourceName,
                            spellID = icon.spellID
                        }
                    end
                end


                bar.arenaSpecMap = bar.arenaSpecMap or {}


                for i = 1, MAX_ARENA_SIZE do
                    if self.arenaSpecs[i] and self.arenaSpecs[i].specID then
                        bar.arenaSpecMap[i] = self.arenaSpecs[i].specID


                        local hasIconsForUnit = false
                        for _, icon in ipairs(bar.active) do
                            if icon.sourceGUID == i then
                                hasIconsForUnit = true
                                break
                            end
                        end


                        if not hasIconsForUnit then
                            OmniBar_AddArenaIcons(bar, i, self.arenaSpecs[i].specID, self.arenaSpecs[i].class)
                        end
                    end
                end


                if next(cooldownStates) ~= nil then
                    for i, icon in ipairs(bar.active) do
                        local key = tostring(icon.spellID) .. "-" .. tostring(icon.sourceGUID)
                        local state = cooldownStates[key]

                        if state and state.remainingTime > 0 then
                            icon.cooldown:Show()
                            OmniBar_StartCooldown(bar, icon, GetTime())
                            icon.cooldown.finish = GetTime() + state.remainingTime


                            if state.charges ~= nil then
                                icon.charges = state.charges
                                icon.Count:SetText(state.charges > 0 and state.charges or "")
                            end
                        end
                    end
                end


                OmniBar_Position(bar)
            end
        end
    end


    OmniBar.arenaInitialized = true
end

function OmniBar:OnResetSpellCast(event, name, spellID)
    for _, bar in ipairs(self.bars) do
        if not bar.disabled and bar.inArena and bar.settings.showUnused then
            local restoredAny = false


            for i = 1, MAX_ARENA_SIZE do
                local specID = GetArenaOpponentSpec(i)
                if specID and specID > 0 then
                    local _, _, _, _, _, class = GetSpecializationInfoByID(specID)
                    if class and (bar.settings.trackUnit == "ENEMY" or bar.settings.trackUnit == "arena" .. i) then
                        local hasIconsForUnit = false
                        for _, icon in ipairs(bar.active) do
                            if icon.sourceGUID == i and icon:IsVisible() then
                                hasIconsForUnit = true
                                break
                            end
                        end


                        if not hasIconsForUnit then
                            OmniBar_AddArenaIcons(bar, i, specID, class)
                            restoredAny = true
                        end
                    end
                end
            end


            if restoredAny then
                OmniBar_Position(bar)
            end
        end
    end
end

function VerifyArenaIcons(self)
    if not self.settings.showUnused or self.disabled then return end


    if not self.inArena then return end


    local hasSpecs = false
    for i = 1, MAX_ARENA_SIZE do
        local specID = GetArenaOpponentSpec(i)
        if specID and specID > 0 then
            hasSpecs = true
            break
        end
    end

    if not hasSpecs then return end


    local visibleIconsByUnit = {}
    for _, icon in ipairs(self.active) do
        if icon:IsVisible() and type(icon.sourceGUID) == "number" then
            visibleIconsByUnit[icon.sourceGUID] = (visibleIconsByUnit[icon.sourceGUID] or 0) + 1
        end
    end


    for i = 1, MAX_ARENA_SIZE do
        local specID = GetArenaOpponentSpec(i)
        if specID and specID > 0 and (not visibleIconsByUnit[i] or visibleIconsByUnit[i] == 0) then
            local _, _, _, _, _, class = GetSpecializationInfoByID(specID)
            if class and (self.settings.trackUnit == "ENEMY" or self.settings.trackUnit == "arena" .. i) then
                OmniBar_AddArenaIcons(self, i, specID, class)
            end
        end
    end


    OmniBar_Position(self)
end

function OmniBar:AddSpecificSpellsByClass(bar, class, sourceGUID, specID)
    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(bar, spellID) and spell.class == "GENERAL" then
            OmniBar_AddIcon(bar, {
                spellID = spellID,
                sourceGUID = sourceGUID,
                specID = specID,
                class = "GENERAL"
            })
        end
    end


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(bar, spellID) and spell.class == class then
            local belongsToSpec = true
            if spell.specID and specID and specID > 0 then
                belongsToSpec = false
                for i = 1, #spell.specID do
                    if spell.specID[i] == specID then
                        belongsToSpec = true
                        break
                    end
                end
            end

            if belongsToSpec then
                OmniBar_AddIcon(bar, {
                    spellID = spellID,
                    sourceGUID = sourceGUID,
                    specID = specID,
                    class = class
                })
            end
        end
    end
end

function OmniBar_AddIconsByClass(self, class, sourceGUID, specID)
    local addedSpells = {}

    if self.inArena then
        for spellID, spell in pairs(addon.Cooldowns) do
            if OmniBar_IsSpellEnabled(self, spellID) and spell.class == "GENERAL" and not addedSpells[spellID] then
                local icon = OmniBar_ArenaAddIcon(self, { spellID = spellID, sourceGUID = sourceGUID, specID = specID })
                if icon then addedSpells[spellID] = true end
            end
        end

        for spellID, spell in pairs(addon.Cooldowns) do
            if OmniBar_IsSpellEnabled(self, spellID) and spell.class == class and not addedSpells[spellID] then
                local icon = OmniBar_ArenaAddIcon(self, { spellID = spellID, sourceGUID = sourceGUID, specID = specID })
                if icon then addedSpells[spellID] = true end
            end
        end

        return
    end


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(self, spellID) and
            (spell.class == "GENERAL" or
                (spell.class == class and SpellBelongsToSpec(spellID, specID)))
        then
            OmniBar_AddIcon(self, { spellID = spellID, sourceGUID = sourceGUID, specID = specID })
        end
    end
end

local function IconIsUnit(iconGUID, guid)
    if (not guid) then return end
    if type(iconGUID) == "number" then
        return UnitGUID("arena" .. iconGUID) == guid
    end
    return iconGUID == guid
end
function OmniBar:SetupFlashAnimation()
    self.flashFrame = CreateFrame("Frame", nil, UIParent)
    self.flashFrame:SetFrameStrata("TOOLTIP")


    local texture = self.flashFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    texture:SetTexture([[Interface\Cooldown\star4]])
    texture:SetAlpha(0)
    texture:SetAllPoints(self.flashFrame)
    texture:SetBlendMode("ADD")


    local animation = texture:CreateAnimationGroup()
    animation:SetScript("OnFinished", function()
        self.isFlashing = false
        self.flashFrame:Hide()
    end)


    local alpha = animation:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(0)
    alpha:SetOrder(1)


    local scale1 = animation:CreateAnimation("Scale")
    scale1:SetScale(1.5, 1.5)
    scale1:SetDuration(0)
    scale1:SetOrder(1)


    local scale2 = animation:CreateAnimation("Scale")
    scale2:SetScale(0, 0)
    scale2:SetDuration(0.3)
    scale2:SetOrder(2)


    local rotation = animation:CreateAnimation("Rotation")
    rotation:SetDegrees(90)
    rotation:SetDuration(0.3)
    rotation:SetOrder(2)


    self.flashTexture = texture
    self.flashAnimation = animation
    self.isFlashing = false
end

local function OmniBar_StartAnimation(self, icon)
    if (not self.settings.glow) then return end
    icon.flashAnim:Play()
    icon.newitemglowAnim:Play()
end

local function OmniBar_StopAnimation(self, icon)
    if icon.flashAnim:IsPlaying() then icon.flashAnim:Stop() end
    if icon.newitemglowAnim:IsPlaying() then icon.newitemglowAnim:Stop() end
end

function IsIconUsed(icon)
    if not icon.cooldown or not icon:IsVisible() then return false end


    if icon.charges ~= nil then
        return icon.charges == 0
    end


    return icon.cooldown:GetCooldownTimes() > 0
end

function OmniBar_UpdateBorder(self, icon)
    local border
    local guid = icon.sourceGUID
    local name = icon.sourceName


    if guid or name then
        if self.settings.highlightFocus and
            self.settings.trackUnit == "ENEMY" and
            (IconIsUnit(guid, UnitGUID("focus")) or name == GetUnitName("focus", true)) and
            UnitIsPlayer("focus")
        then
            icon.FocusTexture:SetAlpha(1)
            border = true
        else
            icon.FocusTexture:SetAlpha(0)
        end


        if self.settings.highlightTarget and
            self.settings.trackUnit == "ENEMY" and
            (IconIsUnit(guid, UnitGUID("target")) or name == GetUnitName("target", true)) and
            UnitIsPlayer("target")
        then
            icon.FocusTexture:SetAlpha(0)
            icon.TargetTexture:SetAlpha(1)
            border = true
        else
            icon.TargetTexture:SetAlpha(0)
        end
    else
        local _, class = UnitClass("focus")
        if self.settings.highlightFocus and
            self.settings.trackUnit == "ENEMY" and
            class and (class == icon.class or icon.class == "GENERAL") and
            UnitIsPlayer("focus")
        then
            icon.FocusTexture:SetAlpha(1)
            border = true
        else
            icon.FocusTexture:SetAlpha(0)
        end


        _, class = UnitClass("target")
        if self.settings.highlightTarget and
            self.settings.trackUnit == "ENEMY" and
            class and (class == icon.class or icon.class == "GENERAL") and
            UnitIsPlayer("target")
        then
            icon.FocusTexture:SetAlpha(0)
            icon.TargetTexture:SetAlpha(1)
            border = true
        else
            icon.TargetTexture:SetAlpha(0)
        end
    end


    local isUsed = IsIconUsed(icon)


    if self.settings.desaturateUsed then
        icon.icon:SetDesaturated(isUsed)
    else
        icon.icon:SetDesaturated(false)
    end
    icon.cooldown:SetReverse(self.settings.reverseCooldown)
    if isUsed then
        icon:SetAlpha(self.settings.usedAlpha or 1)
        local activeSwipeAlpha = math.min((self.settings.swipeAlpha or 0.65) + 0.3, 1.0)
        icon.cooldown:SetSwipeColor(0, 0, 0, activeSwipeAlpha)
    else
        icon:SetAlpha(self.settings.unusedAlpha or 1)
        icon.cooldown:SetSwipeColor(0, 0, 0, self.settings.swipeAlpha or 0.65)
    end
end

function OmniBar_UpdateAllBorders(self)
    for i = 1, #self.active do
        OmniBar_UpdateBorder(self, self.active[i])
    end
end

function OmniBar_UpdateCooldownSort(self)
    if self.settings.sortMethod == "cooldown" and #self.active > 0 then
        self.forceResort = true
        OmniBar_Position(self)
    end
end

function OmniBar_SortIcons(self)
    local sortMethod = self.settings.sortMethod or "player"


    if sortMethod == "none" then
        if not self.initializedOrder then
            self.initializedOrder = {}
            for i, icon in ipairs(self.active) do
                self.initializedOrder[icon] = i
            end
        end


        table.sort(self.active, function(a, b)
            local orderA = self.initializedOrder[a] or 999
            local orderB = self.initializedOrder[b] or 999
            return orderA < orderB
        end)
        return
    end


    self.initializedOrder = nil

    local isStableSortMethod = (sortMethod == "player")
    local isArena = IsInInstance() and select(1, GetInstanceInfo()) == "arena"

    if InCombatLockdown() and isStableSortMethod and isArena and self.frozenOrder then
        table.sort(self.active, function(a, b)
            local orderA = self.frozenOrder[a] or 999
            local orderB = self.frozenOrder[b] or 999
            return orderA < orderB
        end)
        return
    end


    table.sort(self.active, function(a, b)
        if sortMethod == "player" then
            if isArena then
                if type(a.sourceGUID) == "number" and type(b.sourceGUID) == "number" then
                    return a.sourceGUID < b.sourceGUID
                elseif type(a.sourceGUID) == "number" then
                    return true
                elseif type(b.sourceGUID) == "number" then
                    return false
                end
            end

            local aClass, bClass = a.class or 0, b.class or 0
            if aClass ~= bClass then
                return CLASS_ORDER[aClass] < CLASS_ORDER[bClass]
            end

            local x, y = a.ownerName or a.sourceName or "", b.ownerName or b.sourceName or ""
            if x ~= y then return x < y end

            return a.spellID < b.spellID
        elseif sortMethod == "cooldown" then
            local aIsUsed = IsIconUsed(a)
            local bIsUsed = IsIconUsed(b)


            if aIsUsed ~= bIsUsed then
                return bIsUsed
            end


            if aIsUsed and bIsUsed then
                local aRemaining = a.cooldown and a.cooldown.finish and (a.cooldown.finish - GetTime()) or 0
                local bRemaining = b.cooldown and b.cooldown.finish and (b.cooldown.finish - GetTime()) or 0
                if aRemaining ~= bRemaining then
                    return aRemaining < bRemaining
                end
            end


            if not aIsUsed and not bIsUsed then
                local aDuration = a.duration or 0
                local bDuration = b.duration or 0
                if aDuration ~= bDuration then
                    return aDuration > bDuration
                end
            end


            local x, y = a.ownerName or a.sourceName or "", b.ownerName or b.sourceName or ""
            if x ~= y then return x < y end
            return a.spellID < b.spellID
        else
            if isArena then
                if type(a.sourceGUID) == "number" and type(b.sourceGUID) == "number" then
                    return a.sourceGUID < b.sourceGUID
                elseif type(a.sourceGUID) == "number" then
                    return true
                elseif type(b.sourceGUID) == "number" then
                    return false
                end
            end

            local aClass, bClass = a.class or 0, b.class or 0
            if aClass ~= bClass then
                return CLASS_ORDER[aClass] < CLASS_ORDER[bClass]
            end

            local x, y = a.ownerName or a.sourceName or "", b.ownerName or b.sourceName or ""
            if x ~= y then return x < y end

            return a.spellID < b.spellID
        end
    end)

    if not InCombatLockdown() and isStableSortMethod and isArena then
        self.frozenOrder = self.frozenOrder or {}
        wipe(self.frozenOrder)

        for i, icon in ipairs(self.active) do
            self.frozenOrder[icon] = i
        end
    end
end

function OmniBar_SetZone(self, refresh)
    local disabled = self.disabled
    local _, zone = IsInInstance()


    local wasInArena = self.inArena
    self.inArena = (zone == "arena")
    ARENA_STATE.inArena = self.inArena


    if self.inArena and not wasInArena then
        wipe(self.active)
        wipe(self.detected)
        self.arenaSpecMap = {}
        ARENA_STATE.inPrep = true
    end


    self.zone = zone
    self.rated = IsRatedBattleground and IsRatedBattleground()
    self.disabled = (zone == "arena" and (not self.settings.arena)) or
        (self.rated and (not self.settings.ratedBattleground)) or
        (zone == "pvp" and (not self.settings.battleground) and (not self.rated)) or
        (zone == "scenario" and (not self.settings.scenario)) or
        (zone ~= "arena" and zone ~= "pvp" and zone ~= "scenario" and (not self.settings.world))

    self.adaptive = OmniBar_IsAdaptive(self)


    if refresh or disabled ~= self.disabled then
        OmniBar_LoadPosition(self)
        OmniBar_ResetIcons(self)
        OmniBar_UpdateIcons(self)
        OmniBar_ShowAnchor(self)


        if zone == "arena" and (not self.disabled) and self.settings.showUnused then
            OmniBar:UpdateArenaOpponents()
        end
    end
end

local UNITNAME_SUMMON_TITLES = {
    UNITNAME_SUMMON_TITLE1,
    UNITNAME_SUMMON_TITLE2,
    UNITNAME_SUMMON_TITLE3,
}
local tooltip = CreateFrame("GameTooltip", "OmniBarPetTooltip", nil, "GameTooltipTemplate")
local tooltipText = OmniBarPetTooltipTextLeft2
local function UnitOwnerName(guid)
    if (not guid) then return end
    for i = 1, 3 do
        _G["UNITNAME_SUMMON_TITLE" .. i] = "OmniBar %s"
    end
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink("unit:" .. guid)
    local name = tooltipText:GetText()
    for i = 1, 3 do
        _G["UNITNAME_SUMMON_TITLE" .. i] = UNITNAME_SUMMON_TITLES[i]
    end
    if (not name) then return end
    local owner = name:match("OmniBar (.+)")
    if owner then return owner end
end

local function IsSourceHostile(sourceFlags)
    local band = bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE)
    if UnitIsPossessed("player") and band == 0 then return true end
    return band == COMBATLOG_OBJECT_REACTION_HOSTILE
end

function OmniBar:GetCooldownDuration(cooldown, specID)
    if (not cooldown.duration) then return end

    if type(cooldown.duration) == "table" then
        if specID and cooldown.duration[specID] then
            return cooldown.duration[specID]
        else
            return cooldown.duration.default
        end
    else
        return cooldown.duration
    end
end

function OmniBar:AddSpellCast(event, sourceGUID, sourceName, sourceFlags, spellID, serverTime, customDuration)
    local isLocal = (not serverTime)
    serverTime = serverTime or GetServerTime()

    if spellID == 195457 then
        local castingUnit
        for unit in pairs({ player = true, target = true, focus = true }) do
            if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                castingUnit = unit
                break
            end
        end


        if not castingUnit and IsInGroup() then
            local prefix = IsInRaid() and "raid" or "party"
            local count = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers() - 1
            for i = 1, count do
                local unit = prefix .. i
                if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                    castingUnit = unit
                    break
                end
            end
        end


        if not castingUnit then
            for i = 1, 5 do
                local unit = "arena" .. i
                if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                    castingUnit = unit
                    break
                end
            end
        end


        if castingUnit and self:HasBuff(castingUnit, "Death's Arrival") then
            return
        end
    end
    if (not customDuration) then
        for i = 1, #addon.Shared do
            local shared = addon.Shared[i]
            if (shared.triggers and tContains(shared.triggers, spellID)) or tContains(shared.spells, spellID) then
                for i = 1, #shared.spells do
                    if spellID ~= shared.spells[i] then
                        local amount = shared.amount

                        if type(amount) == "table" then amount = shared.amount.default end
                        if addon.Cooldowns[shared.spells[i]] and (not addon.Cooldowns[shared.spells[i]].parent) then
                            self:AddSpellCast(
                                event,
                                sourceGUID,
                                sourceName,
                                sourceFlags,
                                shared.spells[i],
                                nil,
                                amount
                            )
                        end
                    end
                end
            end
        end
    end

    if (not addon.Resets[spellID]) and (not addon.Cooldowns[spellID]) then return end


    sourceName = sourceName == COMBATLOG_FILTER_STRING_UNKNOWN_UNITS and nil or sourceName


    local ownerName = UnitOwnerName(sourceGUID)
    local name = ownerName or sourceName

    if (not name) then return end


    if addon.Resets[spellID] and self.spellCasts[name] and event == "SPELL_CAST_SUCCESS" then
        for i = 1, #addon.Resets[spellID] do
            local reset = addon.Resets[spellID][i]
            if type(reset) == "table" and reset.amount then
                if self.spellCasts[name][reset.spellID] then
                    self.spellCasts[name][reset.spellID].duration = self.spellCasts[name][reset.spellID].duration -
                        reset.amount
                    if self.spellCasts[name][reset.spellID].duration < 1 then
                        self.spellCasts[name][reset.spellID] = nil
                    end
                end
            else
                if type(reset) == "table" then reset = reset.spellID end
                self.spellCasts[name][reset] = nil
            end
        end
        self:SendMessage("OmniBar_ResetSpellCast", name, spellID)



        for _, bar in ipairs(self.bars) do
            if not bar.disabled and bar.inArena and bar.settings.showUnused then
                VerifyArenaIcons(bar)
            end
        end
    end
    if (not addon.Cooldowns[spellID]) then return end

    local now = GetTime()


    local targetSpecID


    -- Check info first
    if info and info.specID then
        targetSpecID = info.specID
    end

    -- If still no spec, check name
    if not targetSpecID and name and self.specs[name] then
        targetSpecID = self.specs[name]
    end

    -- If still no spec, check arena index
    if not targetSpecID and type(sourceGUID) == "number" and self.arenaSpecMap and self.arenaSpecMap[sourceGUID] then
        targetSpecID = self.arenaSpecMap[sourceGUID]
    end

    -- If still no spec, check GUID map
    if not targetSpecID and sourceGUID and self.arenaGUIDMap and self.arenaGUIDMap[sourceGUID] then
        targetSpecID = self.arenaGUIDMap[sourceGUID]
    end



    local charges = addon.Cooldowns[spellID].charges

    local duration = customDuration or self:GetCooldownDuration(addon.Cooldowns[spellID], targetSpecID)


    spellID = addon.Cooldowns[spellID].parent or spellID


    if self.spellCasts[name] and
        self.spellCasts[name][spellID] and
        (customDuration or self.spellCasts[name][spellID].serverTime == serverTime)
    then
        return
    end


    if (not ownerName) and bit_band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then return end


    if (not charges) then
        charges = addon.Cooldowns[spellID].charges
    end


    if (not duration) then
        duration = self:GetCooldownDuration(addon.Cooldowns[spellID], targetSpecID)
    end


    self.spellCasts[name] = self.spellCasts[name] or {}
    self.spellCasts[name][spellID] = {
        charges = charges,
        duration = duration,
        event = event,
        expires = now + duration,
        ownerName = ownerName,
        serverTime = serverTime,
        sourceFlags = sourceFlags,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        spellID = spellID,
        spellName = GetSpellName(spellID),
        timestamp = now,
        specID = targetSpecID,

    }

    self:SendMessage("OmniBar_SpellCast", name, spellID)

    -- Add support for showAfterCast feature
    for _, bar in ipairs(self.bars) do
        if bar.settings.showAfterCast and not bar.disabled and bar.settings.showUnused then
            -- Create a copy of the spell cast info we just stored
            local info = {}
            for k, v in pairs(self.spellCasts[name][spellID]) do
                info[k] = v
            end

            -- Check if this bar should track this unit
            if OmniBar_IsUnitEnabled(bar, info) then
                -- Track by spellID only, but check for duplicates before adding
                if not bar.castHistory[spellID] then
                    bar.castHistory[spellID] = true

                    -- Check if we already have this exact icon
                    local alreadyExists = false
                    for _, icon in ipairs(bar.active) do
                        if icon.spellID == spellID and icon:IsVisible() then
                            -- Check if it's the same source
                            if (sourceGUID and icon.sourceGUID == sourceGUID) or
                                (name and icon.sourceName == name) then
                                alreadyExists = true
                                break
                            end
                        end
                    end

                    if not alreadyExists then
                        OmniBar_AddIcon(bar, info)
                        OmniBar_Position(bar)
                    end
                else
                    -- Spell already cast before, but check if we need to add for a different source
                    if bar.settings.multiple then
                        local needsNewIcon = true
                        for _, icon in ipairs(bar.active) do
                            if icon.spellID == spellID and icon:IsVisible() then
                                if (sourceGUID and icon.sourceGUID == sourceGUID) or
                                    (name and icon.sourceName == name) then
                                    needsNewIcon = false
                                    break
                                end
                            end
                        end

                        if needsNewIcon then
                            OmniBar_AddIcon(bar, info)
                            OmniBar_Position(bar)
                        end
                    end
                end
            end
        end
    end
end

function OmniBar:AlertGroup(...)
    if (not IsInGroup()) or GetNumGroupMembers() > 5 then return end
    local event, sourceGUID, sourceName, sourceFlags, spellID, serverTime = ...
    self:SendCommMessage("OmniBarSpell", self:Serialize(...), GetDefaultCommChannel(), nil, "ALERT")
end

-- function OmniBar:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
--     if self:IsEmpoweredSpell(unit) then
--         return
--     end



--     if not addon.Cooldowns[spellID] and not addon.CooldownReduction[spellID] then return end

--     local sourceFlags = 0

--     if UnitReaction("player", unit) < 4 then
--         sourceFlags = sourceFlags + COMBATLOG_OBJECT_REACTION_HOSTILE
--     end

--     if UnitIsPlayer(unit) then
--         sourceFlags = sourceFlags + COMBATLOG_OBJECT_TYPE_PLAYER
--     end


--     if addon.Cooldowns[spellID] then
--         self:AddSpellCast(event, UnitGUID(unit), GetUnitName(unit, true), sourceFlags, spellID)
--     end


--     self:ProcessCooldownReduction(spellID, UnitGUID(unit), GetUnitName(unit, true), event, castGUID)
-- end

function OmniBar:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
    -- Check if this is an empowered spell
    local isEmpoweredSpell = EMPOWERED_SPELLS[spellID]

    if isEmpoweredSpell then
        -- Check if unit has Tip the Scales buff
        local hasTipTheScales = self:HasBuff(unit, "Tip the Scales")

        if hasTipTheScales then
            -- Process as instant empowered spell - don't return early
            -- The spell will be handled by the normal logic below
        else
            -- Normal empowered spell - return early to wait for EMPOWER_STOP
            if self:IsEmpoweredSpell(unit) then
                return
            end
        end
    else
        -- Non-empowered spell - check for regular empowering state
        if self:IsEmpoweredSpell(unit) then
            return
        end
    end

    if not addon.Cooldowns[spellID] and not addon.CooldownReduction[spellID] then return end

    local sourceFlags = 0

    if UnitReaction("player", unit) < 4 then
        sourceFlags = sourceFlags + COMBATLOG_OBJECT_REACTION_HOSTILE
    end

    if UnitIsPlayer(unit) then
        sourceFlags = sourceFlags + COMBATLOG_OBJECT_TYPE_PLAYER
    end

    -- Add the spell cast for cooldown tracking
    if addon.Cooldowns[spellID] then
        self:AddSpellCast(event, UnitGUID(unit), GetUnitName(unit, true), sourceFlags, spellID)
    end

    -- Process cooldown reduction
    self:ProcessCooldownReduction(spellID, UnitGUID(unit), GetUnitName(unit, true), event, castGUID)
end

function OmniBar:UNIT_SPELLCAST_EMPOWER_STOP(event, unit, _, spellID, successful)
    -- Only process if the cast was successful (arg5 = true)
    if not successful then return end

    if not addon.Cooldowns[spellID] and not addon.CooldownReduction[spellID] then return end

    local sourceFlags = 0

    if UnitReaction("player", unit) < 4 then
        sourceFlags = sourceFlags + COMBATLOG_OBJECT_REACTION_HOSTILE
    end

    if UnitIsPlayer(unit) then
        sourceFlags = sourceFlags + COMBATLOG_OBJECT_TYPE_PLAYER
    end

    -- Add the spell cast for cooldown tracking
    if addon.Cooldowns[spellID] then
        self:AddSpellCast(event, UnitGUID(unit), GetUnitName(unit, true), sourceFlags, spellID)
    end

    -- Process cooldown reduction
    self:ProcessCooldownReduction(spellID, UnitGUID(unit), GetUnitName(unit, true), event, castGUID)
end

function OmniBar:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical =
        CombatLogGetCurrentEventInfo()
    local procIDs = {
        [1719] = true,
        [107574] = true,
        [12472] = true,
        [216331] = true,
        [31884] = true,
        [10060] = true,
        [200183] = true,
        [363916] = true
    }

    local CHANNELED_SPELLS_CAST_ONLY = {
        [382445] = true,
    }

    -- Guardian Spirit logic
    local GUARDIAN_SPIRIT_ID = 47788
    local GUARDIAN_SPIRIT_HEAL_ID = 48153

    local foundProc = false
    if (subevent == "SPELL_AURA_APPLIED") then
        for k, v in pairs(procIDs) do
            if spellID == k then
                foundProc = true
                return
            end
        end
        if foundProc then
            return
        end

        if spellID == GUARDIAN_SPIRIT_ID then
            self.guardianSpiritCasts[destGUID] = {
                sourceGUID = sourceGUID,
                sourceName = sourceName,
                sourceFlags = sourceFlags,
                timestamp = GetTime(),
                healed = false,

                expiryTimer = C_Timer.NewTimer(12, function()
                    local castInfo = self.guardianSpiritCasts[destGUID]
                    if castInfo and not castInfo.healed then
                        self:ReduceCooldown(castInfo.sourceGUID, 109, GUARDIAN_SPIRIT_ID)
                    end

                    self.guardianSpiritCasts[destGUID] = nil
                end)
            }
        end
    end

    if subevent == "SPELL_HEAL" and spellID == GUARDIAN_SPIRIT_HEAL_ID then
        if self.guardianSpiritCasts[destGUID] then
            self.guardianSpiritCasts[destGUID].healed = true
        end
    end

    -- Basic spell cast processing
    if (subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_INTERRUPT") then
        if spellID == 0 and SPELL_ID_BY_NAME then spellID = SPELL_ID_BY_NAME[spellName] end
        self:AddSpellCast(subevent, sourceGUID, sourceName, sourceFlags, spellID)
    end

    -- NEW: Handle fire spell damage for Combustion reduction
    -- Handle fire spell damage for Combustion reduction
    if subevent == "SPELL_DAMAGE" then
        local FIRE_SPELLS = {
            [133] = true,    -- Fireball
            [11366] = true,  -- Pyroblast
            [108853] = true, -- Fire Blast
            [2948] = true,   -- Scorch
            [257542] = true  -- Phoenix Flames
        }

        if FIRE_SPELLS[spellID] then
            self:ProcessAllCombustionReduction(spellID, sourceGUID, sourceName, critical)
        end
    end

    -- Channeled spells logic
    if CHANNELED_SPELLS[spellID] then
        if subevent == "SPELL_CAST_SUCCESS" then
            self.activeChannels[sourceGUID] = {
                spellID = spellID,
                sourceName = sourceName,
                sourceFlags = sourceFlags,
                timestamp = timestamp
            }
        elseif subevent == "SPELL_CAST_FAILED" or subevent == "SPELL_AURA_REMOVED" then
            self.activeChannels[sourceGUID] = nil
        elseif subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "SPELL_PERIODIC_HEAL" or
            subevent == "SPELL_DAMAGE" or subevent:match("^SPELL_") then
            local channelInfo = self.activeChannels[sourceGUID]

            if channelInfo and channelInfo.spellID == spellID and not CHANNELED_SPELLS_CAST_ONLY[spellID] then
                self:ProcessCooldownReduction(spellID, sourceGUID, sourceName, "SPELL_CHANNEL_TICK")
            end
        end
    end

    -- Cooldown reduction processing
    if subevent == "SPELL_INTERRUPT" or
        subevent == "SPELL_CAST_SUCCESS" or
        (subevent == "SPELL_DAMAGE" and not CHANNELED_SPELLS_CAST_ONLY[spellID]) or
        subevent == "SPELL_AURA_APPLIED" then
        self:ProcessCooldownReduction(spellID, sourceGUID, sourceName, subevent)
    end

    if (subevent == "SWING_DAMAGE" or subevent == "RANGE_DAMAGE" or
            (subevent == "SPELL_DAMAGE" and spellSchool == 1)) then
        -- Throttle to once every 5 seconds per player
        local currentTime = GetTime()
        self.impishInstinctsThrottle = self.impishInstinctsThrottle or {}
        local lastReduction = self.impishInstinctsThrottle[destGUID]

        if not lastReduction or (currentTime - lastReduction) >= 5 then
            self.impishInstinctsThrottle[destGUID] = currentTime
            self:ReduceCooldown(destGUID, 3, 48020)
        end
    end
end

function OmniBar:ProcessCooldownReduction(spellID, sourceGUID, sourceName, eventType, castGUID)
    if not addon.CooldownReduction[spellID] then return end

    local currentTime = GetTime()

    -- Create a unique event key based on available identifiers
    local eventKey
    if castGUID then
        -- If we have a castGUID, it's unique per cast
        eventKey = castGUID .. "_" .. spellID
    else
        -- For combat log events without castGUID, use the combination of identifiers
        eventKey = sourceGUID .. "_" .. spellID .. "_" .. eventType
    end

    -- Initialize tracking if needed
    self.recentCDREvents = self.recentCDREvents or {}

    -- Different duplicate prevention for channeled vs normal spells
    -- if CHANNELED_SPELLS[spellID] then
    --     -- For channeled spells, use time-based duplicate prevention
    --     if self.recentCDREvents[eventKey] and (currentTime - self.recentCDREvents[eventKey]) < 0.01 then
    --         return
    --     end
    --     -- Store timestamp for channeled spells
    --     self.recentCDREvents[eventKey] = currentTime
    -- else
    --     -- For non-channeled spells, use event-based duplicate prevention
    --     if self.recentCDREvents[eventKey] then
    --         return
    --     end
    --     -- Store boolean for non-channeled spells
    --     self.recentCDREvents[eventKey] = true
    -- end

    -- -- Clean up old entries periodically to prevent memory bloat
    -- if (currentTime - (self.lastCDRCleanup or 0)) > 10 then
    --     self.lastCDRCleanup = currentTime
    --     -- For mixed tracking (timestamps and booleans)
    --     for key, value in pairs(self.recentCDREvents) do
    --         if type(value) == "number" then
    --             -- It's a timestamp from a channeled spell
    --             if (currentTime - value) > 1 then
    --                 self.recentCDREvents[key] = nil
    --             end
    --         end
    --         -- Boolean values (non-channeled) are kept until full wipe
    --     end

    --     -- Do a full wipe every 60 seconds for non-channeled entries
    --     if (currentTime - (self.lastFullCDRWipe or 0)) > 60 then
    --         self.lastFullCDRWipe = currentTime
    --         wipe(self.recentCDREvents)
    --     end
    -- end


    local duplicateWindow = CHANNELED_SPELLS[spellID] and 0.01 or 0.1
    if self.recentCDREvents[eventKey] and (currentTime - self.recentCDREvents[eventKey]) < duplicateWindow then
        return
    end
    -- Store timestamp for all spells
    self.recentCDREvents[eventKey] = currentTime

    if (currentTime - (self.lastCDRCleanup or 0)) > 10 then
        self.lastCDRCleanup = currentTime
        for key, timestamp in pairs(self.recentCDREvents) do
            if (currentTime - timestamp) > 2 then
                self.recentCDREvents[key] = nil
            end
        end
    end


    -- Find the casting unit
    local castingUnit
    for unit in pairs({ player = true, target = true, focus = true }) do
        if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
            castingUnit = unit
            break
        end
    end

    if not castingUnit then
        for i = 1, 5 do
            local unit = "arena" .. i
            if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                castingUnit = unit
                break
            end
        end
    end

    if not castingUnit and IsInGroup() then
        local prefix = IsInRaid() and "raid" or "party"
        local count = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers() - 1
        for i = 1, count do
            local unit = prefix .. i
            if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                castingUnit = unit
                break
            end
        end
    end


    -- Process the cooldown reduction
    for _, bar in ipairs(self.bars) do
        local isEnemyTracking = (bar.settings.trackUnit == "ENEMY")

        for _, icon in ipairs(bar.active) do
            if addon.CooldownReduction[spellID] and addon.CooldownReduction[spellID][icon.spellID] then
                local reductionInfo = addon.CooldownReduction[spellID][icon.spellID]
                local reduction, requiredEvent

                if type(reductionInfo) == "number" then
                    reduction = reductionInfo
                elseif type(reductionInfo) == "table" then
                    reduction = reductionInfo.amount
                    requiredEvent = reductionInfo.event
                else
                    break
                end

                if requiredEvent and requiredEvent ~= eventType and requiredEvent ~= "ANY" then
                    -- Skip if event type doesn't match
                else
                    local samePlayer = false

                    if isEnemyTracking then
                        if sourceGUID and icon.sourceGUID then
                            samePlayer = (sourceGUID == icon.sourceGUID)

                            if not samePlayer and type(icon.sourceGUID) == "number" then
                                local arenaUnit = "arena" .. icon.sourceGUID
                                if UnitExists(arenaUnit) and UnitGUID(arenaUnit) == sourceGUID then
                                    samePlayer = true
                                end
                            end
                        end

                        if not samePlayer and sourceName and icon.sourceName then
                            samePlayer = (sourceName == icon.sourceName)
                        end
                    else
                        if sourceGUID and icon.sourceGUID then
                            samePlayer = (sourceGUID == icon.sourceGUID)
                        elseif sourceName and icon.sourceName then
                            samePlayer = (sourceName == icon.sourceName)
                        end
                    end
                    if samePlayer then
                        local applyReduction = true

                        if castingUnit then
                            if reductionInfo.buffName then
                                if reductionInfo.buffName == "True Bearing" then
                                    local hasTrueBearing = self:HasBuff(castingUnit, "True Bearing")
                                    if hasTrueBearing then
                                        reduction = reduction + 3
                                    end
                                else
                                    applyReduction = self:HasBuff(castingUnit, reductionInfo.buffName)
                                end
                            elseif reductionInfo.buffCheck then
                                local hasApotheosis = self:HasBuff(castingUnit, "Apotheosis")
                                if hasApotheosis then
                                    reduction = reduction * 3
                                end
                            end

                            if spellID == 342247 then
                                local hasBuff = false
                                AuraUtil.ForEachAura(castingUnit, "HELPFUL", nil,
                                    function(_, _, _, _, _, _, _, _, _, foundID)
                                        if foundID == 342246 then
                                            hasBuff = true
                                            return
                                        end
                                    end)
                                if hasBuff then
                                    applyReduction = false
                                end
                            end
                        else
                            if not isEnemyTracking and (reductionInfo.buffName or reductionInfo.buffCheck) then
                                applyReduction = false
                            end
                        end

                        if applyReduction then
                            local start, duration = icon.cooldown:GetCooldownTimes()
                            if start > 0 and duration > 0 then
                                start = start / 1000
                                duration = duration / 1000

                                local currentTime = GetTime()
                                local endTime = start + duration
                                local newEndTime = endTime - reduction

                                local maxCharges = addon.Cooldowns[icon.spellID] and
                                    addon.Cooldowns[icon.spellID].charges
                                if maxCharges and icon.charges ~= nil and icon.charges < maxCharges and newEndTime <= currentTime then
                                    local wasZero = (icon.charges == 0)
                                    icon.charges = icon.charges + 1
                                    icon.Count:SetText(icon.charges > 0 and icon.charges or "")
                                    OmniBar_UpdateBorder(bar, icon)

                                    if bar.settings.hideChargedCooldownText and wasZero and icon.charges > 0 then
                                        icon.cooldown:SetCooldown(0, 0)

                                        if bar.settings.hideChargedCooldownText then -- Add this check
                                            icon.cooldown:SetHideCountdownNumbers(true)
                                            icon.cooldown.noCooldownCount = true
                                        end
                                        local excessReduction = currentTime - newEndTime
                                        local adjustedStart = currentTime - excessReduction
                                        icon.cooldown:SetCooldown(adjustedStart, duration)

                                        icon.cooldown.start = adjustedStart
                                        if icon.cooldown.finish then
                                            icon.cooldown.finish = adjustedStart + duration
                                        end
                                    elseif icon.charges < maxCharges then
                                        local excessReduction = currentTime - newEndTime
                                        local adjustedStart = currentTime - excessReduction

                                        icon.cooldown:SetCooldown(adjustedStart, duration)

                                        icon.cooldown.start = adjustedStart
                                        if icon.cooldown.finish then
                                            icon.cooldown.finish = adjustedStart + duration
                                        end
                                    else
                                        icon.cooldown:SetCooldown(0, 0)
                                        if icon.cooldown.finish then
                                            icon.cooldown.finish = 0
                                        end

                                        if bar.settings.showUnused and bar.settings.readyGlow ~= false then
                                            OmniBar_ShowActivationGlow(icon)
                                            C_Timer.After(1, function()
                                                if icon and icon.spellActivationAlert then
                                                    OmniBar_HideActivationGlow(icon)
                                                end
                                            end)
                                        end
                                    end
                                else
                                    newEndTime = math.max(currentTime, newEndTime)
                                    local newRemainingTime = newEndTime - currentTime
                                    local newStartTime = currentTime - (duration - newRemainingTime)

                                    icon.cooldown:SetCooldown(newStartTime, duration)

                                    icon.cooldown.start = newStartTime
                                    if icon.cooldown.finish then
                                        icon.cooldown.finish = newEndTime
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function OmniBar:ProcessAllCombustionReduction(spellID, sourceGUID, sourceName, isCritical)
    local COMBUSTION_ID = 190319
    local PHOENIX_FLAMES_ID = 257542

    -- Special duplicate prevention for Phoenix Flames (it can fire multiple events)
    if spellID == PHOENIX_FLAMES_ID then
        local currentTime = GetTime()
        local eventKey = sourceGUID .. "_" .. PHOENIX_FLAMES_ID .. "_" .. math.floor(currentTime * 10) -- 100ms precision

        self.recentPhoenixEvents = self.recentPhoenixEvents or {}

        if self.recentPhoenixEvents[eventKey] then
            return -- Skip duplicate Phoenix Flames event
        end
        self.recentPhoenixEvents[eventKey] = currentTime

        -- Clean up old Phoenix events
        if not self.lastPhoenixCleanup or (currentTime - self.lastPhoenixCleanup) > 2 then
            self.lastPhoenixCleanup = currentTime
            for key, timestamp in pairs(self.recentPhoenixEvents) do
                if (currentTime - timestamp) > 0.2 then -- Keep events for 200ms
                    self.recentPhoenixEvents[key] = nil
                end
            end
        end
    end

    -- Find the casting unit
    local castingUnit
    for unit in pairs({ player = true, target = true, focus = true }) do
        if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
            castingUnit = unit
            break
        end
    end

    if not castingUnit then
        for i = 1, 5 do
            local unit = "arena" .. i
            if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                castingUnit = unit
                break
            end
        end
    end

    if not castingUnit and IsInGroup() then
        local prefix = IsInRaid() and "raid" or "party"
        local count = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers() - 1
        for i = 1, count do
            local unit = prefix .. i
            if UnitExists(unit) and UnitGUID(unit) == sourceGUID then
                castingUnit = unit
                break
            end
        end
    end

    if not castingUnit then return end

    -- Check if Combustion is active
    local hasCombustion = self:HasBuff(castingUnit, "Combustion")

    -- Simple logic for reduction amount
    local reductionAmount = 0

    if isCritical and hasCombustion then
        reductionAmount = 2.25 -- Crit + Combustion
    elseif isCritical then
        reductionAmount = 1    -- Crit only
    elseif hasCombustion then
        reductionAmount = 1.25 -- Combustion only
    else
        return                 -- No reduction (non-crit, no Combustion)
    end

    -- Apply the reduction to Combustion icons
    for _, bar in ipairs(self.bars) do
        if not bar.disabled then
            for _, icon in ipairs(bar.active) do
                if icon.spellID == COMBUSTION_ID then
                    -- Check if this icon belongs to the same player
                    local samePlayer = false

                    if sourceGUID and icon.sourceGUID then
                        samePlayer = (sourceGUID == icon.sourceGUID)

                        -- Handle arena units
                        if not samePlayer and type(icon.sourceGUID) == "number" then
                            local arenaUnit = "arena" .. icon.sourceGUID
                            if UnitExists(arenaUnit) and UnitGUID(arenaUnit) == sourceGUID then
                                samePlayer = true
                            end
                        end
                    elseif sourceName and icon.sourceName then
                        samePlayer = (sourceName == icon.sourceName)
                    end

                    if samePlayer then
                        local start, duration = icon.cooldown:GetCooldownTimes()
                        if start > 0 and duration > 0 then
                            start = start / 1000
                            duration = duration / 1000

                            local currentTime = GetTime()
                            local endTime = start + duration
                            local newEndTime = math.max(currentTime, endTime - reductionAmount)

                            local newRemainingTime = newEndTime - currentTime
                            local newStartTime = currentTime - (duration - newRemainingTime)

                            icon.cooldown:SetCooldown(newStartTime, duration)
                            icon.cooldown.start = newStartTime
                            icon.cooldown.finish = newEndTime
                        end
                    end
                end
            end
        end
    end
end

function OmniBar:UNIT_POWER_UPDATE(event, unit, powerType)
    if powerType ~= "RAGE" then return end
    local _, class = UnitClass(unit)
    if class ~= "WARRIOR" then return end


    local specMultiplier = 1
    local unitGUID = UnitGUID(unit)


    if self.inArena then
        local unitSpec = nil


        if unitGUID and self.warriorSpecMap[unitGUID] then
            unitSpec = self.warriorSpecMap[unitGUID]
        end


        if not unitSpec and self.warriorSpecMap[unit] then
            unitSpec = self.warriorSpecMap[unit]
        end


        if unitSpec == 72 then
            specMultiplier = 2
        end
    end

    local currentRage = UnitPower(unit, Enum.PowerType.Rage)
    local previousRage = self.lastRage[unit] or currentRage
    local rageSpent = previousRage - currentRage

    if rageSpent > 0 and UnitAffectingCombat(unit) then
        local cdr = rageSpent / 20
        cdr = cdr * specMultiplier

        self:ReduceCooldown(unitGUID, cdr, 1719)
        self:ReduceCooldown(unitGUID, cdr, 167105)
        self:ReduceCooldown(unitGUID, cdr, 262161)
        self:ReduceCooldown(unitGUID, cdr, 446035)
    end

    self.lastRage[unit] = currentRage
end

function OmniBar:ReduceCooldown(casterGUID, seconds, targetSpellID)
    self.processedIcons = self.processedIcons or {}
    local castTime = GetTime()
    local castKey = casterGUID .. "-" .. targetSpellID .. "-" .. castTime

    if self.processedIcons[castKey] then return end
    self.processedIcons[castKey] = true


    if not self.lastCleanup or (castTime - self.lastCleanup > 60) then
        self.lastCleanup = castTime
        for k, v in pairs(self.processedIcons) do
            local timestamp = k:match(".*-.*-(.*)$")
            if timestamp and (castTime - tonumber(timestamp) > 10) then
                self.processedIcons[k] = nil
            end
        end
    end

    for _, bar in ipairs(self.bars) do
        for _, icon in ipairs(bar.active) do
            if icon and icon.cooldown and icon.sourceGUID and icon.sourceGUID == casterGUID then
                if icon.spellID == targetSpellID then
                    local now = GetTime()
                    local start, duration = icon.cooldown:GetCooldownTimes()
                    start = start / 1000
                    duration = duration / 1000
                    local elapsed = now - start
                    local newDuration = math.max(duration - seconds, 0)
                    local newStart = now - elapsed
                    local currentDuration = duration - elapsed

                    if seconds > currentDuration then
                        local charges = icon.charges
                        if charges and charges > 1 then
                            charges = charges - 1
                            icon.charges = charges
                            icon.Count:SetText(charges)
                            newStart = now - (seconds - currentDuration)
                            newDuration = icon.duration
                        end
                    end

                    icon.cooldown:SetCooldown(newStart, newDuration)


                    icon.cooldown.finish = newStart + newDuration






                    local spellCastTable = self.spellCasts[icon.sourceName]
                    if spellCastTable and spellCastTable[icon.spellID] then
                        spellCastTable[icon.spellID].duration = newDuration
                        spellCastTable[icon.spellID].expires = newStart + newDuration
                    end
                end
            end
        end
    end
end

function OmniBar_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...
        local _, instanceType = IsInInstance()

        -- Skip processing if reloading in arena
        if isReloadingUi and instanceType == "arena" then
            return
        end

        self.inArena = (instanceType == "arena")
        ARENA_STATE.inArena = self.inArena
        OmniBar_SetZone(self, true)
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        local _, instanceType = IsInInstance()
        self.inArena = (instanceType == "arena")
        ARENA_STATE.inArena = self.inArena

        OmniBar_SetZone(self, true)
    elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then


    elseif event == "ARENA_OPPONENT_UPDATE" then



    elseif event == "PVP_MATCH_ACTIVE" then
        if self.zone == "arena" then
            self.inArena = true
            ARENA_STATE.inArena = true
            ARENA_STATE.inPrep = false

            if self.settings.showUnused then
                OmniBar:UpdateArenaOpponents()
            end
        end
    elseif event == "UPDATE_BATTLEFIELD_STATUS" or
        event == "UPDATE_BATTLEFIELD_SCORE" or
        event == "PLAYER_TARGET_CHANGED" or
        event == "PLAYER_FOCUS_CHANGED" or
        event == "PLAYER_REGEN_DISABLED" or
        event == "GROUP_ROSTER_UPDATE" then

    end
end

function OmniBar_AddArenaIcons(self, arenaIndex, specID, class)
    if not class or not specID then return end


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(self, spellID) and spell.class == "GENERAL" then
            OmniBar_AddIcon(self, { spellID = spellID, sourceGUID = arenaIndex, specID = specID })
        end
    end


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(self, spellID) and
            spell.class == class and
            not spell.specID
        then
            OmniBar_AddIcon(self, { spellID = spellID, sourceGUID = arenaIndex, specID = specID })
        end
    end


    for spellID, spell in pairs(addon.Cooldowns) do
        if OmniBar_IsSpellEnabled(self, spellID) and
            spell.class == class and
            spell.specID
        then
            for i = 1, #spell.specID do
                if spell.specID[i] == specID then
                    OmniBar_AddIcon(self, { spellID = spellID, sourceGUID = arenaIndex, specID = specID })
                    break
                end
            end
        end
    end
end

function OmniBar_EnsureArenaIconsInitialized(self)
    if not self.inArena or not self.settings.showUnused then return end


    local hasVisibleIcons = false
    for _, icon in ipairs(self.active) do
        if icon:IsVisible() then
            hasVisibleIcons = true
            break
        end
    end


    if not hasVisibleIcons then
        OmniBar:UpdateArenaOpponents()
    end
end

function OmniBar_LoadSettings(self)
    for k, v in pairs(DEFAULTS) do
        if self.settings[k] == nil then
            self.settings[k] = v
        end
    end
    self.container:SetScale(self.settings.size / BASE_ICON_SIZE)

    OmniBar_LoadPosition(self)
    OmniBar_ResetIcons(self)
    OmniBar_UpdateIcons(self)
    OmniBar_Center(self)
end

function OmniBar_SavePosition(self, set)
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    local frameStrata = self:GetFrameStrata()
    relativeTo = relativeTo and relativeTo:GetName() or "UIParent"
    if set then
        if set.point then point = set.point end
        if set.relativeTo then relativeTo = set.relativeTo end
        if set.relativePoint then relativePoint = set.relativePoint end
        if set.xOfs then xOfs = set.xOfs end
        if set.yOfs then yOfs = set.yOfs end
        if set.frameStrata then frameStrata = set.frameStrata end
    end

    if (not self.settings.position) then
        self.settings.position = {}
    end
    self.settings.position.point = point
    self.settings.position.relativeTo = relativeTo
    self.settings.position.relativePoint = relativePoint
    self.settings.position.xOfs = xOfs
    self.settings.position.yOfs = yOfs
    self.settings.position.frameStrata = frameStrata
end

function OmniBar_ResetPosition(self)
    self.settings.position.relativeTo = "UIParent"
    self.settings.position.relativePoint = "CENTER"
    self.settings.position.xOfs = 0
    self.settings.position.yOfs = 0
    OmniBar_LoadPosition(self)
end

function OmniBar:IsValidSpec(specID)
    if not specID or specID == 0 then return false end
    local _, name = GetSpecializationInfoByID(specID)
    return name ~= nil
end

function OmniBar_LoadPosition(self)
    self:ClearAllPoints()
    if self.settings.position then
        local point = self.settings.position.point or "CENTER"
        self.anchor:ClearAllPoints()
        self.anchor:SetPoint(point, self, point, 0, 0)
        local relativeTo = self.settings.position.relativeTo or "UIParent"
        if (not _G[relativeTo]) then
            OmniBar_ResetPosition(self)
            return
        end
        local relativePoint = self.settings.position.relativePoint or "CENTER"
        local xOfs = self.settings.position.xOfs or 0
        local yOfs = self.settings.position.yOfs or 0
        self:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        if (not self.settings.position.frameStrata) then self.settings.position.frameStrata = "MEDIUM" end
        self:SetFrameStrata(self.settings.position.frameStrata)
    else
        self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        OmniBar_SavePosition(self)
    end
end

function OmniBar_IsSpellEnabled(self, spellID)
    if (not spellID) then return end

    if (not self.settings.spells) then return addon.Cooldowns[spellID].default end

    return self.settings.spells[spellID]
end

function OmniBar:GetSpellTexture(spellID)
    spellID = tonumber(spellID)
    return (addon.Cooldowns[spellID] and addon.Cooldowns[spellID].icon) or GetSpellTexture(spellID)
end

function OmniBar_SpecUpdated(self, event, name)
    if self.disabled then return end
    if self.settings.trackUnit == "GROUP" or UnitIsUnit(self.settings.trackUnit, name) then
        OmniBar_Refresh(self)
    end
end

function OmniBar:GetSpecs()
    if (not GetSpecializationInfo) then return end
    if (not self.specs[PLAYER_NAME]) then
        self.specs[PLAYER_NAME] = GetSpecializationInfo(GetSpecialization())
        self:SendMessage("OmniBar_SpecUpdated", PLAYER_NAME)
    end
    if self.lastInspect and GetTime() - self.lastInspect < 3 then
        return
    end
    for i = 1, GetNumGroupMembers() do
        local name, _, _, _, _, class = GetRaidRosterInfo(i)
        if name and (not self.specs[name]) and (not UnitIsUnit("player", name)) and CanInspect(name) then
            self.inspectUnit = name
            self.lastInspect = GetTime()
            self:RegisterEvent("INSPECT_READY")
            NotifyInspect(name)
            return
        end
    end
end

function OmniBar:INSPECT_READY(event, guid)
    if (not self.inspectUnit) then return end
    local unit = self.inspectUnit
    self.inspectUnit = nil
    self:UnregisterEvent("INSPECT_READY")
    if (UnitGUID(unit) ~= guid) then
        ClearInspectPlayer()
        self:GetSpecs()
        return
    end
    self.specs[unit] = GetInspectSpecialization(unit)
    self:SendMessage("OmniBar_SpecUpdated", unit)
    ClearInspectPlayer()
    self:GetSpecs()
end

function OmniBar_IsUnitEnabled(self, info)
    if (not info.timestamp) then return true end
    if info.test then return true end

    local guid = info.sourceGUID
    if guid == nil then return end

    local name = info.ownerName or info.sourceName

    local isHostile = IsSourceHostile(info.sourceFlags)

    if self.settings.trackUnit == "ENEMY" and isHostile then
        return true
    end

    local isPlayer = UnitIsUnit("player", name)

    if self.settings.trackUnit == "PLAYER" and isPlayer then
        return true
    end

    if self.settings.trackUnit == "TARGET" and (UnitGUID("target") == guid or GetUnitName("target", true) == name) then
        return true
    end

    if self.settings.trackUnit == "FOCUS" and (UnitGUID("focus") == guid or GetUnitName("focus", true) == name) then
        return true
    end

    if self.settings.trackUnit == "GROUP" and (not isPlayer) and (UnitInParty(name) or UnitInRaid(name)) then
        return true
    end

    for i = 1, MAX_ARENA_SIZE do
        local unit = "arena" .. i
        if (i == guid or UnitGUID(unit) == guid) and self.settings.trackUnit == unit:lower() then
            return true
        end
    end

    for i = 1, 4 do
        local unit = "party" .. i
        if (i == guid or UnitGUID(unit) == guid) and self.settings.trackUnit == unit:lower() then
            return true
        end
    end
end

function OmniBar_Center(self)
    local parentWidth = UIParent:GetWidth()
    local clamp = self.settings.center and (1 - parentWidth) / 2 or 0
    self:SetClampRectInsets(clamp, -clamp, 0, 0)
    clamp = self.settings.center and (self.anchor:GetWidth() - parentWidth) / 2 or 0
    self.anchor:SetClampRectInsets(clamp, -clamp, 0, 0)
end

function OmniBar_CooldownFinish(self, force)
    local icon = self:GetParent()
    if icon.cooldown and icon.cooldown:GetCooldownTimes() > 0 and (not force) then return end
    local bar = icon:GetParent():GetParent()

    -- Restore the original swipe alpha when cooldown finishes (with safety check)
    if bar and bar.settings then
        icon.cooldown:SetSwipeColor(0, 0, 0, bar.settings.swipeAlpha or 0.65)
    end

    local maxCharges = addon.Cooldowns[icon.spellID] and addon.Cooldowns[icon.spellID].charges
    if maxCharges and icon.charges ~= nil then
        if icon.charges < maxCharges then
            local wasZero = (icon.charges == 0)

            icon.charges = icon.charges + 1
            icon.Count:SetText(icon.charges)

            local bar = icon:GetParent():GetParent()
            if bar.settings.hideChargedCooldownText then -- Add this check
                if icon.charges > 0 then
                    icon.cooldown:SetHideCountdownNumbers(true)
                    icon.cooldown.noCooldownCount = true
                else
                    icon.cooldown:SetHideCountdownNumbers(not bar.settings.cooldownCount and true or false)
                    icon.cooldown.noCooldownCount = (not bar.settings.cooldownCount)
                end
            end

            if wasZero and bar.settings.readyGlow ~= false then
                icon.pendingHide = false

                OmniBar_ShowActivationGlow(icon)
                C_Timer.After(1, function()
                    if icon and not icon.pendingHide then
                        OmniBar_HideActivationGlow(icon)
                    end
                end)
            end

            if icon.charges < maxCharges then
                OmniBar_StartCooldown(icon:GetParent():GetParent(), icon, GetTime())
                OmniBar_UpdateBorder(bar, icon)
                return
            end
        end
    end

    local bar = icon:GetParent():GetParent()
    OmniBar_StopAnimation(self, icon)


    icon.pendingHide = false


    if bar.settings.readyGlow ~= false then
        OmniBar_ShowActivationGlow(icon)


        if not bar.settings.showUnused then
            icon.pendingHide = true

            C_Timer.After(1, function()
                if icon and icon.pendingHide then
                    OmniBar_HideActivationGlow(icon)
                    icon:Hide()
                    icon.pendingHide = false
                    OmniBar_Position(bar)
                end
            end)
        else
            C_Timer.After(1, function()
                if icon and not icon.pendingHide then
                    OmniBar_HideActivationGlow(icon)
                end
            end)
        end
    else
        if not bar.settings.showUnused then
            icon:Hide()
        end
    end

    if bar.frozenOrder and bar.frozenOrder[icon] then
        local currentOrder = bar.frozenOrder[icon]
        bar.frozenOrder[icon] = nil

        C_Timer.After(0.1, function()
            if bar.frozenOrder then
                bar.frozenOrder[icon] = currentOrder
            end
        end)
    end


    if bar.settings.showUnused then
        OmniBar_UpdateBorder(bar, icon)
    end

    if bar.settings.sortMethod == "cooldown" and bar.settings.showUnused then
        OmniBar_UpdateCooldownSort(bar)
    end

    bar:StopMovingOrSizing()


    if bar.settings.showUnused or bar.settings.readyGlow == false then
        OmniBar_Position(bar)
    end
end

function OmniBar_ReplaySpellCasts(self)
    if self.disabled then return end

    local now = GetTime()

    for name, _ in pairs(self.spellCasts) do
        for k, v in pairs(self.spellCasts[name]) do
            if now >= v.expires then
                self.spellCasts[name][k] = nil
            else
                OmniBar_AddIcon(self, self.spellCasts[name][k])
            end
        end
    end
end

local function OmniBar_UnitClassAndSpec(self)
    local unit = self.settings.trackUnit
    if unit == "ENEMY" or unit == "GROUP" then return end
    local _, class = UnitClass(unit)
    local specID = self.specs[GetUnitName(unit, true)]
    return class, specID
end


function OmniBar_ResetIcons(self)
    for i = 1, self.numIcons do
        if self.icons[i].MasqueGroup then
            self.icons[i].MasqueGroup = nil
        end
        self.icons[i].TargetTexture:SetAlpha(0)
        self.icons[i].FocusTexture:SetAlpha(0)
        self.icons[i].flash:SetAlpha(0)
        self.icons[i].NewItemTexture:SetAlpha(0)
        self.icons[i].cooldown:SetCooldown(0, 0)
        self.icons[i].cooldown:Hide()


        OmniBar_HideActivationGlow(self.icons[i])


        self.icons[i].pendingHide = false

        self.icons[i]:Hide()
    end
    wipe(self.active)
    if not self.settings.showAfterCast then
        wipe(self.castHistory)
    end
    if self.disabled then return end

    if self.settings.showUnused then
        if self.inArena then
            return
        end

        if self.settings.trackUnit == "ENEMY" then
            if (not self.adaptive) then
                for spellID, _ in pairs(addon.Cooldowns) do
                    if OmniBar_IsSpellEnabled(self, spellID) then
                        OmniBar_AddIcon(self, { spellID = spellID })
                    end
                end
            end
        elseif self.settings.trackUnit == "GROUP" then
            for i = 1, GetNumGroupMembers() do
                local name, _, _, _, _, class = GetRaidRosterInfo(i)
                local guid = UnitGUID(name)
                if class and (not UnitIsUnit("player", name)) then
                    OmniBar_AddIconsByClass(self, class, UnitGUID(name), self.specs[name])
                end
            end
        else
            local class, specID = OmniBar_UnitClassAndSpec(self)
            if class and UnitIsPlayer(self.settings.trackUnit) then
                OmniBar_AddIconsByClass(self, class, nil, specID)
            end
        end
    end

    OmniBar_Position(self)
end

function OmniBar:SetupCooldownUpdates()
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:Hide()
    self.updateElapsed = 0

    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self.updateElapsed = self.updateElapsed + elapsed
        if self.updateElapsed >= 0.5 then
            self.updateElapsed = 0


            local needsUpdates = false

            for _, bar in ipairs(self.bars) do
                if not bar.disabled and bar.settings.sortMethod == "cooldown" and
                    bar.settings.showUnused and #bar.active > 0 then
                    local hasActiveCooldowns = false
                    for _, icon in ipairs(bar.active) do
                        if icon.cooldown and icon.cooldown:GetCooldownTimes() > 0 then
                            hasActiveCooldowns = true
                            break
                        end
                    end


                    if hasActiveCooldowns then
                        OmniBar_UpdateCooldownSort(bar)
                        needsUpdates = true
                    end
                end
            end


            if not needsUpdates then
                self.updateFrame:Hide()
            end
        end
    end)
end

function OmniBar:StartCooldownUpdates()
    self.updateElapsed = 0
    self.updateFrame:Show()
end

function OmniBar_StartCooldown(self, icon, start)
    icon.cooldown:SetCooldown(start, icon.duration)
    icon.cooldown.finish = start + icon.duration

    --   local activeSwipeAlpha = math.min((self.settings.swipeAlpha or 0.65) + 0.6, 1.0)
    -- icon.cooldown:SetSwipeColor(0, 0, 0, activeSwipeAlpha)


    icon.cooldown:SetScript("OnUpdate", nil)

    OmniBar_UpdateBorder(self, icon)

    if self.settings.sortMethod == "cooldown" and self.settings.showUnused then
        _G["OmniBar"]:StartCooldownUpdates()
    end
end

function OmniBar_AddIcon(self, info)
    if (not OmniBar_IsUnitEnabled(self, info)) then return end
    if (not OmniBar_IsSpellEnabled(self, info.spellID)) then return end
    if self.settings.showUnused and self.settings.showAfterCast and not info.test then
        if not self.castHistory[info.spellID] then
            return
        end
    end
    local icon, duplicate

    for i = 1, #self.active do
        if self.active[i].spellID == info.spellID then
            duplicate = true

            if (not self.active[i].sourceGUID) then
                duplicate = nil
                icon = self.active[i]
                break
            end

            if info.sourceGUID and IconIsUnit(self.active[i].sourceGUID, info.sourceGUID) then
                duplicate = nil
                icon = self.active[i]
                break
            end
        end
    end

    if (not icon) then
        if #self.active >= self.settings.maxIcons then return end
        if (not self.settings.multiple) and duplicate then return end
        for i = 1, #self.icons do
            if (not self.icons[i]:IsVisible()) then
                icon = self.icons[i]
                icon.specID = nil

                icon.charges = nil
                icon.pendingHide = false


                OmniBar_HideActivationGlow(icon)

                break
            end
        end
    end

    if (not icon) then return end

    icon.class = addon.Cooldowns[info.spellID].class
    icon.sourceGUID = info.sourceGUID
    icon.sourceName = info.ownerName or info.sourceName
    icon.specID = info.specID and info.specID or self.specs[icon.sourceName]
    icon.icon:SetTexture(addon.Cooldowns[info.spellID].icon)
    icon.spellID = info.spellID
    icon.timestamp = info.test and GetTime() or info.timestamp
    icon.duration = info.test and math.random(5, 30) or
        OmniBar:GetCooldownDuration(addon.Cooldowns[info.spellID], icon.specID)
    icon.added = GetTime()

    local isArena = IsInInstance() and select(1, GetInstanceInfo()) == "arena"
    local isStableSortMethod = self.settings.sortMethod == "player" or self.settings.sortMethod == "spec"

    if self.frozenOrder and InCombatLockdown() and isArena and isStableSortMethod then
        local maxOrder = 0
        for _, order in pairs(self.frozenOrder) do
            maxOrder = math.max(maxOrder, order)
        end
        self.frozenOrder[icon] = maxOrder + 1
    end

    local maxCharges = addon.Cooldowns[info.spellID].charges or 1
    if info.charges then
        if icon:IsVisible() and icon.charges then
            if icon.charges > 0 then
                icon.charges = icon.charges - 1
                icon.Count:SetText(icon.charges)
                OmniBar_StartAnimation(self, icon)
                OmniBar_UpdateBorder(self, icon)

                -- Update text visibility immediately after charge change
                if self.settings.hideChargedCooldownText then -- Add this check
                    if icon.charges > 0 then
                        icon.cooldown:SetHideCountdownNumbers(true)
                        icon.cooldown.noCooldownCount = true
                    else
                        icon.cooldown:SetHideCountdownNumbers(not self.settings.cooldownCount and true or false)
                        icon.cooldown.noCooldownCount = (not self.settings.cooldownCount)

                        -- Force cooldown refresh when showing text to fix font
                        if icon.cooldown.finish and icon.cooldown.finish > GetTime() then
                            local remaining = icon.cooldown.finish - GetTime()
                            local start = GetTime() - (icon.duration - remaining)
                            icon.cooldown:SetCooldown(start, icon.duration)
                        end
                    end
                end

                if not icon.cooldown.finish or icon.cooldown.finish - GetTime() <= 1 then
                    OmniBar_StartCooldown(self, icon, GetTime())
                end
                return icon
            end
        else
            icon.charges = maxCharges - 1
            icon.Count:SetText(icon.charges)
            -- Hide text for new charges > 0
            if self.settings.hideChargedCooldownText and icon.charges > 0 then -- Add this check
                icon.cooldown:SetHideCountdownNumbers(true)
                icon.cooldown.noCooldownCount = true
            end
        end
    else
        icon.charges = nil
        icon.Count:SetText(nil)
        if self.settings.hideChargedCooldownText then
            icon.cooldown:SetHideCountdownNumbers(not self.settings.cooldownCount and true or false)
            icon.cooldown.noCooldownCount = (not self.settings.cooldownCount)
        end
    end

    if self.settings.names then
        local name = info.test and "Name" or icon.sourceName
        icon.Name:SetText(name)
    end

    if Masque then
        icon.MasqueGroup = Masque:Group("OmniBar", info.spellName)
        icon.MasqueGroup:AddButton(icon, {
            FloatingBG = false,
            Icon = icon.icon,
            Cooldown = icon.cooldown,
            Flash = false,
            Pushed = false,
            Normal = icon:GetNormalTexture(),
            Disabled = false,
            Checked = false,
            Border = _G[icon:GetName() .. "Border"],
            AutoCastable = false,
            Highlight = false,
            Hotkey = false,
            Count = false,
            Name = false,
            Duration = false,
            AutoCast = false,
        })
    end

    icon:Show()

    if (icon.timestamp) then
        OmniBar_StartCooldown(self, icon, icon.timestamp)
        if (GetTime() == icon.timestamp) then OmniBar_StartAnimation(self, icon) end
    end

    self.forceResort = true
    if self.settings.sortMethod == "none" and not self.initializedOrder then
        self.initializedOrder = self.initializedOrder or {}
        self.initializedOrder[icon] = #self.active
    end


    if icon.timestamp and icon.timestamp < GetTime() then
        OmniBar_HideActivationGlow(icon)
    end

    return icon
end

function OmniBar_UpdateIcons(self)
    for i = 1, self.numIcons do
        if self.settings.hideChargedCooldownText then -- Add this check
            if not self.icons[i].charges or self.icons[i].charges == 0 then
                self.icons[i].cooldown:SetHideCountdownNumbers(not self.settings.cooldownCount and true or false)
                self.icons[i].cooldown.noCooldownCount = (not self.settings.cooldownCount)
            else
                self.icons[i].cooldown:SetHideCountdownNumbers(true)
                self.icons[i].cooldown.noCooldownCount = true
            end
        else
            -- Default behavior
            self.icons[i].cooldown:SetHideCountdownNumbers(not self.settings.cooldownCount and true or false)
            self.icons[i].cooldown.noCooldownCount = (not self.settings.cooldownCount)
        end
        --        self.icons[i].cooldown:SetSwipeColor(0, 0, 0, self.settings.swipeAlpha or 0.65)
        local start, duration = self.icons[i].cooldown:GetCooldownTimes()
        if start == 0 or duration == 0 then
            self.icons[i].cooldown:SetSwipeColor(0, 0, 0, self.settings.swipeAlpha or 0.65)
        end

        if self.settings.desaturateUsed then
            local isUsed = IsIconUsed(self.icons[i])
            self.icons[i].icon:SetDesaturated(isUsed)
        else
            self.icons[i].icon:SetDesaturated(false)
        end


        local borderStyle = self.settings.borderStyle or "pixel"

        if borderStyle == "original" then
            if self.settings.border then
                self.icons[i].icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
            else
                self.icons[i].icon:SetTexCoord(0.07, 0.9, 0.07, 0.9)
            end

            if self.icons[i].borderTop then
                self.icons[i].borderTop:Hide()
                self.icons[i].borderBottom:Hide()
                self.icons[i].borderLeft:Hide()
                self.icons[i].borderRight:Hide()
            end
        else
            OmniBar_SetPixelBorder(self.icons[i], self.settings.border, 1, 0, 0, 0)
        end

        OmniBar_UpdateBorder(self, self.icons[i])

        if self.icons[i].MasqueGroup then
            self.icons[i].MasqueGroup:ReSkin()
        end
    end
end

function OmniBar_Test(self)
    if (not self) then return end
    self.disabled = nil
    OmniBar_ResetIcons(self)
    if self.settings.spells then
        for k, v in pairs(self.settings.spells) do
            OmniBar_AddIcon(self, { spellID = k, test = true })
        end
    else
        for k, v in pairs(addon.Cooldowns) do
            if v.default then
                OmniBar_AddIcon(self, { spellID = k, test = true })
            end
        end
    end
end

function OmniBar_Position(self)
    local numActive = #self.active
    if numActive == 0 then
        OmniBar_ShowAnchor(self)
        return
    end

    if self.settings.sortMethod or self.forceResort then
        OmniBar_SortIcons(self)
        self.forceResort = nil
    elseif self.settings.showUnused then
        table.sort(self.active, function(a, b)
            local x, y = a.ownerName or a.sourceName or "", b.ownerName or b.sourceName or ""
            local aClass, bClass = a.class or 0, b.class or 0
            if aClass == bClass then
                if self.settings.trackUnit ~= "ENEMY" and self.settings.trackUnit ~= "GROUP" then
                    return a.spellID < b.spellID
                end
                if x < y then return true end
                if x == y then return a.spellID < b.spellID end
            end
            return CLASS_ORDER[aClass] < CLASS_ORDER[bClass]
        end)
    else
        table.sort(self.active,
            function(a, b) return a.added == b.added and a.spellID < b.spellID or a.added < b.added end)
    end

    local count, rows = 0, 1
    local grow = self.settings.growUpward and 1 or -1
    local padding = self.settings.padding and self.settings.padding or 0
    for i = 1, numActive do
        if self.settings.locked then
            self.active[i]:EnableMouse(false)
        else
            self.active[i]:EnableMouse(true)
        end
        self.active[i]:ClearAllPoints()
        local columns = self.settings.columns and self.settings.columns > 0 and self.settings.columns < numActive and
            self.settings.columns or numActive
        if i > 1 then
            count = count + 1
            if count >= columns then
                if self.settings.align == "CENTER" then
                    self.active[i]:SetPoint("CENTER", self.anchor, "CENTER",
                        (-BASE_ICON_SIZE - padding) * (columns - 1) /
                        2, (BASE_ICON_SIZE + padding) * rows * grow)
                else
                    self.active[i]:SetPoint(self.settings.align, self.anchor, self.settings.align, 0,
                        (BASE_ICON_SIZE + padding) * rows * grow)
                end

                count = 0
                rows = rows + 1
            else
                if self.settings.align == "RIGHT" then
                    self.active[i]:SetPoint("TOPRIGHT", self.active[i - 1], "TOPLEFT", -1 * padding, 0)
                else
                    self.active[i]:SetPoint("TOPLEFT", self.active[i - 1], "TOPRIGHT", padding, 0)
                end
            end
        else
            if self.settings.align == "CENTER" then
                self.active[i]:SetPoint("CENTER", self.anchor, "CENTER", (-BASE_ICON_SIZE - padding) * (columns - 1) / 2,
                    0)
            else
                self.active[i]:SetPoint(self.settings.align, self.anchor, self.settings.align, 0, 0)
            end
        end
    end
    OmniBar_ShowAnchor(self)
end

function OmniBar:Test()
    for key, _ in pairs(self.db.profile.bars) do
        OmniBar_Test(_G[key])
    end
end

function OmniBar:IsSpecValid(specID)
    if not specID or specID == 0 then return false end

    local _, name = GetSpecializationInfoByID(specID)
    return name ~= nil
end

function OmniBar_SetPixelBorder(icon, show, edgeSize, r, g, b)
    if not show then
        icon.borderTop:Hide()
        icon.borderBottom:Hide()
        icon.borderLeft:Hide()
        icon.borderRight:Hide()
        icon.icon:SetTexCoord(0, 1, 0, 1)
        return
    end

    edgeSize = edgeSize or 1
    r = r or 0
    g = g or 0
    b = b or 0

    icon.borderTop:ClearAllPoints()
    icon.borderTop:SetPoint("TOPLEFT", icon, "TOPLEFT")
    icon.borderTop:SetPoint("BOTTOMRIGHT", icon, "TOPRIGHT", 0, -edgeSize)
    icon.borderTop:SetColorTexture(r, g, b)
    icon.borderTop:Show()

    icon.borderBottom:ClearAllPoints()
    icon.borderBottom:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT")
    icon.borderBottom:SetPoint("TOPRIGHT", icon, "BOTTOMRIGHT", 0, edgeSize)
    icon.borderBottom:SetColorTexture(r, g, b)
    icon.borderBottom:Show()

    icon.borderRight:ClearAllPoints()
    icon.borderRight:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 0, -edgeSize)
    icon.borderRight:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", -edgeSize, edgeSize)
    icon.borderRight:SetColorTexture(r, g, b)
    icon.borderRight:Show()

    icon.borderLeft:ClearAllPoints()
    icon.borderLeft:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, -edgeSize)
    icon.borderLeft:SetPoint("BOTTOMRIGHT", icon, "BOTTOMLEFT", edgeSize, edgeSize)
    icon.borderLeft:SetColorTexture(r, g, b)
    icon.borderLeft:Show()

    icon.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

function OmniBar:IsEmpoweredSpell(unit)
    if GetUnitEmpowerHoldAtMaxTime(unit) then
        return true
    end

    return false
end

-- function OmniBar:UNIT_AURA(event, unit, updateInfo)
--     if not unit then return end

--     -- Only track player, party, raid, and arena units
--     local isTrackedUnit = false
--     if UnitIsUnit(unit, "player") then
--         isTrackedUnit = true
--     elseif unit:match("^party%d+$") or unit:match("^raid%d+$") or unit:match("^arena%d+$") then
--         isTrackedUnit = true
--     end

--     if not isTrackedUnit then return end

--     local unitGUID = UnitGUID(unit)
--     if not unitGUID then return end

--     -- Check for our specific buffs using AuraUtil if available
--     local hasTemporalBurst = false
--     local hasFlowState = false
--     local temporalBurstTimeLeft = 0

--     -- Try using AuraUtil.FindAuraBySpellID if it exists
--     if AuraUtil and AuraUtil.FindAuraBySpellID then
--         local temporalBurstData = AuraUtil.FindAuraBySpellID(431698, unit, "HELPFUL")
--         if temporalBurstData then
--             hasTemporalBurst = true
--             temporalBurstTimeLeft = temporalBurstData.expirationTime - GetTime()
--         end

--         local flowStateData = AuraUtil.FindAuraBySpellID(390148, unit, "HELPFUL")
--         if flowStateData then
--             hasFlowState = true
--         end
--     else
--         -- -- Fallback to UnitBuff iteration
--         -- for i = 1, 40 do
--         --     local name, icon, count, debuffType, duration, expirationTime, source,
--         --     isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i)

--         --     if not name then break end

--         --     if spellId == 431698 then -- Temporal Burst
--         --         hasTemporalBurst = true
--         --         temporalBurstTimeLeft = expirationTime - GetTime()
--         --     elseif spellId == 390148 then -- Flow State
--         --         hasFlowState = true
--         --     end
--         -- end
--     end

--     -- Rest of the function remains the same...
--     local wasActive = self.evokerRateBuffs[unitGUID] ~= nil

--     if hasTemporalBurst or hasFlowState then
--         self.evokerRateBuffs[unitGUID] = {
--             hasTemporalBurst = hasTemporalBurst,
--             hasFlowState = hasFlowState,
--             temporalBurstTimeLeft = temporalBurstTimeLeft,
--             lastUpdate = GetTime()
--         }

--         if not wasActive and not self.evokerUpdateFrame:IsShown() then
--             self.lastEvokerUpdate = GetTime()
--             self.evokerUpdateFrame:Show()
--         end
--     else
--         self.evokerRateBuffs[unitGUID] = nil

--         if wasActive and not next(self.evokerRateBuffs) then
--             self.evokerUpdateFrame:Hide()
--         end
--     end
-- end

function OmniBar:UNIT_AURA(event, unit, updateInfo)
    if not unit then return end

    local isTrackedUnit = false
    if UnitIsUnit(unit, "player") then
        isTrackedUnit = true
    elseif unit:match("^party%d+$") or unit:match("^raid%d+$") or unit:match("^arena%d+$") then
        isTrackedUnit = true
    end

    if not isTrackedUnit then return end

    local unitGUID = UnitGUID(unit)
    if not unitGUID then return end

    local hasTemporalBurst = false
    local hasFlowState = false
    local currentTime = GetTime()

    -- Initialize evokerRateBuffs if needed
    if not self.evokerRateBuffs then
        self.evokerRateBuffs = {}
    end

    -- Check for buffs by name
    local temporalBurstData = AuraUtil.FindAuraByName("Temporal Burst", unit, "HELPFUL")
    if temporalBurstData then
        hasTemporalBurst = true
    end

    local flowStateData = AuraUtil.FindAuraByName("Flow State", unit, "HELPFUL")
    if flowStateData then
        hasFlowState = true
    end

    local hasBlessingOfAutumn = false
    local blessingOfAutumnData = AuraUtil.FindAuraByName("Blessing of Autumn", unit, "HELPFUL")
    if blessingOfAutumnData then
        hasBlessingOfAutumn = true
    end

    local wasActive = self.evokerRateBuffs[unitGUID] ~= nil

    if hasTemporalBurst or hasFlowState or hasBlessingOfAutumn then
        -- Initialize buff tracking
        if not self.evokerRateBuffs[unitGUID] then
            self.evokerRateBuffs[unitGUID] = {}
        end

        local buffInfo = self.evokerRateBuffs[unitGUID]

        -- Set Flow State
        buffInfo.hasFlowState = hasFlowState
        buffInfo.hasBlessingOfAutumn = hasBlessingOfAutumn

        -- Set Temporal Burst with initial timestamp
        if hasTemporalBurst then
            if not buffInfo.hasTemporalBurst then
                -- New Temporal Burst detected
                buffInfo.hasTemporalBurst = true
                buffInfo.temporalBurstStartTime = currentTime
                buffInfo.temporalBurstInitialDuration = 30
            end
        else
            if buffInfo.hasTemporalBurst then
            end
            buffInfo.hasTemporalBurst = false
        end

        buffInfo.lastUpdate = currentTime

        if not wasActive and not self.evokerUpdateFrame:IsShown() then
            self.lastEvokerUpdate = GetTime()
            self.evokerUpdateFrame:Show()
        end
    else
        self.evokerRateBuffs[unitGUID] = nil

        if wasActive and not next(self.evokerRateBuffs) then
            self.evokerUpdateFrame:Hide()
        end
    end
end

function OmniBar:ProcessEvokerRateReduction(deltaTime)
    local hasActiveBuffs = false
    local currentTime = GetTime()

    for unitGUID, buffInfo in pairs(self.evokerRateBuffs) do
        hasActiveBuffs = true
        local reductionRate = 1.0

        -- Flow State: flat 10%
        if buffInfo.hasFlowState then
            reductionRate = reductionRate * 1.1
        end

        if buffInfo.hasBlessingOfAutumn then
            reductionRate = reductionRate * 1.3 -- 30% increase
        end

        -- Temporal Burst: calculate remaining time manually
        if buffInfo.hasTemporalBurst and buffInfo.temporalBurstStartTime then
            local elapsedTime = currentTime - buffInfo.temporalBurstStartTime
            local remainingTime = buffInfo.temporalBurstInitialDuration - elapsedTime

            if remainingTime > 0 then
                -- Clamp to 1-30 second range for rate calculation
                local scaledTime = math.min(30, math.max(1, remainingTime))
                local temporalBurstMultiplier = 1 + (scaledTime / 100)
                reductionRate = reductionRate * temporalBurstMultiplier

                -- Debug output every second
                if math.floor(currentTime) ~= math.floor(self.lastDebugTime or 0) then
                    self.lastDebugTime = currentTime
                end
            else
                -- Temporal Burst expired
                buffInfo.hasTemporalBurst = false
                buffInfo.temporalBurstStartTime = nil
            end
        end

        -- Clean up if no buffs remain
        if not buffInfo.hasTemporalBurst and not buffInfo.hasFlowState and not buffInfo.hasBlessingOfAutumn then
            self.evokerRateBuffs[unitGUID] = nil
        else
            -- Apply the reduction
            self:ApplyEvokerRateReduction(unitGUID, deltaTime, reductionRate)
        end
    end

    -- Clean up and stop frame if no active buffs
    if not next(self.evokerRateBuffs) then
        self.evokerUpdateFrame:Hide()
    end
end

function OmniBar:GetUnitFromGUID(targetGUID)
    -- Check player first
    if UnitGUID("player") == targetGUID then
        return "player"
    end

    -- Check party/raid
    local prefix = IsInRaid() and "raid" or "party"
    local count = IsInRaid() and GetNumGroupMembers() or GetNumGroupMembers() - 1
    for i = 1, count do
        local unit = prefix .. i
        if UnitExists(unit) and UnitGUID(unit) == targetGUID then
            return unit
        end
    end

    -- Check arena
    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) and UnitGUID(unit) == targetGUID then
            return unit
        end
    end

    return nil
end

function OmniBar:ApplyEvokerRateReduction(unitGUID, deltaTime, reductionRate)
    local reductionAmount = deltaTime * (reductionRate - 1.0)

    for _, bar in ipairs(self.bars) do
        if not bar.disabled then
            for _, icon in ipairs(bar.active) do
                if icon and icon.cooldown then
                    -- Check if this icon belongs to the unit with the buff
                    local iconMatches = false
                    if icon.sourceGUID == unitGUID then
                        iconMatches = true
                    elseif type(icon.sourceGUID) == "number" then
                        local arenaUnit = "arena" .. icon.sourceGUID
                        if UnitExists(arenaUnit) and UnitGUID(arenaUnit) == unitGUID then
                            iconMatches = true
                        end
                    elseif icon.sourceName then
                        for unit in pairs({ player = true, target = true, focus = true }) do
                            if UnitExists(unit) and UnitGUID(unit) == unitGUID and
                                GetUnitName(unit, true) == icon.sourceName then
                                iconMatches = true
                                break
                            end
                        end
                    end

                    if iconMatches then
                        local start, duration = icon.cooldown:GetCooldownTimes()
                        if start > 0 and duration > 0 then
                            start = start / 1000
                            duration = duration / 1000

                            local currentTime = GetTime()
                            local endTime = start + duration
                            local newEndTime = endTime - reductionAmount

                            -- Handle charges and normal cooldowns
                            local maxCharges = addon.Cooldowns[icon.spellID] and addon.Cooldowns[icon.spellID].charges
                            if maxCharges and icon.charges ~= nil and icon.charges < maxCharges and newEndTime <= currentTime then
                                local wasZero = (icon.charges == 0)
                                icon.charges = icon.charges + 1
                                icon.Count:SetText(icon.charges > 0 and icon.charges or "")
                                OmniBar_UpdateBorder(bar, icon)

                                if icon.charges < maxCharges then
                                    local excessReduction = currentTime - newEndTime
                                    local adjustedStart = currentTime - excessReduction
                                    icon.cooldown:SetCooldown(adjustedStart, duration)
                                    icon.cooldown.start = adjustedStart
                                    icon.cooldown.finish = adjustedStart + duration
                                else
                                    icon.cooldown:SetCooldown(0, 0)
                                    icon.cooldown.finish = 0

                                    if bar.settings.showUnused and bar.settings.readyGlow ~= false then
                                        OmniBar_ShowActivationGlow(icon)
                                        C_Timer.After(1, function()
                                            if icon then
                                                OmniBar_HideActivationGlow(icon)
                                            end
                                        end)
                                    end
                                end
                            else
                                newEndTime = math.max(currentTime, newEndTime)
                                local newRemainingTime = newEndTime - currentTime
                                local newStartTime = currentTime - (duration - newRemainingTime)

                                icon.cooldown:SetCooldown(newStartTime, duration)
                                icon.cooldown.start = newStartTime
                                icon.cooldown.finish = newEndTime
                            end
                        end
                    end
                end
            end
        end
    end
end

function OmniBar_AllOnCooldown(barKey, spellIDs)
    local bar = _G[barKey]
    if not bar or not bar.active then return false end

    for _, spellID in ipairs(spellIDs) do
        for _, icon in ipairs(bar.active) do
            if icon:IsVisible() and icon.spellID == spellID then
                -- Check if spell is ready (off cooldown)
                local start, duration = icon.cooldown:GetCooldownTimes()
                local isReady = (start == 0 or duration == 0)

                -- Handle charges
                if icon.charges ~= nil then
                    isReady = (icon.charges > 0)
                end

                if isReady then
                    return false -- Found a ready spell, so not all on cooldown
                end
                break
            end
        end
    end

    return true -- All spells are on cooldown
end

SLASH_OmniBar1 = "/ob"
SLASH_OmniBar2 = "/omnibar"
SlashCmdList.OmniBar = function()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addonName)
    else
        InterfaceOptionsFrame_OpenToCategory(addonName)
        InterfaceOptionsFrame_OpenToCategory(addonName)
    end
end
