---------------------------------------------------------------------
-- Incognito Resurrected chat
-- Cheap hot path for Midnight / Forever secret values.
--
-- Secret rule: never compare, match, index, or take the length of a
-- value until I2.Usable(value) is true. Pass secrets through unchanged.
--
-- Retail / Forever / MoP: change the editbox text only. Never replace
-- C_ChatInfo.SendChatMessage.
-- Classic Era: wrap the global send functions.
---------------------------------------------------------------------
local _, ns = ...
local I2 = ns.IncognitoResurrected

local state = {
    send = nil,
    club = nil,
    wrappedSend = false,
    wrappedClub = false,
    editBoxes = false
}

-- AddOnRestrictionType from RestrictedActionsConstantsDocumentation:
-- 0 Combat (do not skip prefix — combat lockdown is not chat lockdown)
-- 1 Encounter, 2 ChallengeMode, 3 PvPMatch, 4 Map, 5 Chat
local CHAT_RESTRICT_TYPES = {1, 2, 3, 4, 5}
local classHex = {}

---------------------------------------------------------------------
function I2:IsAddonRestricted()
    local flavor = self.flavor
    if not flavor or not flavor.skipWhenRestricted then return false end
    if self._restricted ~= nil then return self._restricted end

    if type(C_ChatInfo) == "table" and
        type(C_ChatInfo.InChatMessagingLockdown) == "function" then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and locked then
            self._restricted = true
            return true
        end
    end

    local restricted = false
    if flavor.hasRestrictedActions then
        local isActive = C_RestrictedActions.IsAddOnRestrictionActive
        if type(isActive) == "function" then
            for i = 1, #CHAT_RESTRICT_TYPES do
                local ok, active = pcall(isActive, CHAT_RESTRICT_TYPES[i])
                if ok and active then
                    restricted = true
                    break
                end
            end
        else
            for i = 1, #CHAT_RESTRICT_TYPES do
                local ok, value =
                    pcall(C_RestrictedActions.GetAddOnRestrictionState,
                          CHAT_RESTRICT_TYPES[i])
                -- AddOnRestrictionState.Active == 2
                if ok and value == 2 then
                    restricted = true
                    break
                end
            end
        end
    else
        local instanceType = self:GetInstanceTypeSafe()
        restricted = instanceType == "pvp" or instanceType == "arena"
    end
    self._restricted = restricted
    return restricted
end

function I2:ProcessOutgoingText(text, chatType, target)
    return self:AttachPrefix(text, chatType, target)
end

---------------------------------------------------------------------
local function OriginalSend(msg, chatType, language, target)
    local fn = state.send
    if fn then return fn(msg, chatType, language, target) end
    if I2.flavor and I2.flavor.hasCChatInfo then
        return C_ChatInfo.SendChatMessage(msg, chatType, language, target)
    end
    return SendChatMessage(msg, chatType, language, target)
end

local function OriginalClub(clubID, streamID, msg)
    local fn = state.club
    if fn then return fn(clubID, streamID, msg) end
    if I2.flavor and I2.flavor.hasCClub then
        return C_Club.SendMessage(clubID, streamID, msg)
    end
end

function I2:CallOriginalSendChatMessage(msg, chatType, language, target)
    return OriginalSend(msg, chatType, language, target)
end

function I2:CallOriginalClubSendMessage(clubID, streamID, msg)
    return OriginalClub(clubID, streamID, msg)
end

local WrappedClub

local function WrappedSend(msg, chatType, language, target)
    if not I2._prefixEnabled then
        return OriginalSend(msg, chatType, language, target)
    end
    -- Secret or non-string messages are forwarded untouched.
    if not I2.Usable(msg) then
        return OriginalSend(msg, chatType, language, target)
    end
    local cache = I2:GetSendCache()
    if cache.community and chatType == "CHANNEL" and I2.flavor and
        I2.flavor.hasCClub then
        local clubId, streamId = I2:CommunityIdsFromTarget(target)
        if clubId and streamId then
            return WrappedClub(clubId, streamId, msg)
        end
    end
    return OriginalSend(I2:AttachPrefix(msg, chatType, target), chatType,
                        language, target)
end

WrappedClub = function(clubID, streamID, msg)
    if not I2._prefixEnabled or not I2.Usable(msg) then
        return OriginalClub(clubID, streamID, msg)
    end
    local cache = I2:GetSendCache()
    if cache.enable and cache.community and not cache.hide and cache.name ~= "" and
        not I2:HasLeadingIgnoreSymbol(msg) then
        local ok, info = pcall(C_Club.GetClubInfo, clubID)
        local clubType = ok and info and info.clubType
        local kinds = Enum and Enum.ClubType
        if clubType and kinds and
            (clubType == kinds.BattleNet or clubType == kinds.Character) and
            not I2:TextAlreadyPrefixed(msg) then
            msg = cache.prefix .. msg
        end
    end
    return OriginalClub(clubID, streamID, msg)
end

local function WrapSend()
    if state.wrappedSend then return end
    if I2.flavor.hasCChatInfo then
        state.send = C_ChatInfo.SendChatMessage
        C_ChatInfo.SendChatMessage = WrappedSend
    else
        state.send = SendChatMessage
        SendChatMessage = WrappedSend
    end
    state.wrappedSend = true
end

local function UnwrapSend()
    if not state.wrappedSend then return end
    if I2.flavor.hasCChatInfo then
        C_ChatInfo.SendChatMessage = state.send
    else
        SendChatMessage = state.send
    end
    state.wrappedSend = false
end

local function WrapClub()
    if state.wrappedClub or not I2.flavor.hasCClub then return end
    state.club = C_Club.SendMessage
    C_Club.SendMessage = WrappedClub
    state.wrappedClub = true
end

local function UnwrapClub()
    if not state.wrappedClub then return end
    C_Club.SendMessage = state.club
    state.wrappedClub = false
end

---------------------------------------------------------------------
local function ReadChatType(editBox)
    local ok, value = pcall(editBox.GetAttribute, editBox, "chatType")
    if ok and I2.Usable(value) then return value end
    if editBox.GetChatType then
        ok, value = pcall(editBox.GetChatType, editBox)
        if ok and I2.Usable(value) then return value end
    end
    if I2.Usable(editBox.chatType) then return editBox.chatType end
    return nil
end

local function ReadChannelTarget(editBox)
    if editBox.GetChannelTarget then
        local ok, value = pcall(editBox.GetChannelTarget, editBox)
        if ok then return value end
    end
    return editBox.channelTarget
end

-- Official Retail/Forever injection point (ChatFrameEditBoxMixin:OnPreSendText):
-- ParseText has already run; GetText has not. Addons are told to edit here.
-- GetText is a secret on Retail 12.1+. Do not compare or match it; concat is allowed.
local function PrefixFromEditBox(box)
    if not box or not I2._prefixEnabled or I2:IsAddonRestricted() then return end
    if box._incognito2Prefixed then return end
    local ok, text = pcall(box.GetText, box)
    if not ok or text == nil then return end
    local chatType = ReadChatType(box)
    if not chatType then return end
    local nextText, changed = I2:AttachPrefix(text, chatType,
                                             ReadChannelTarget(box))
    if not changed then return end
    box._incognito2IgnoreText = true
    if pcall(box.SetText, box, nextText) then
        box._incognito2Prefixed = true
    end
    box._incognito2IgnoreText = nil
end

local function HookMixinMethod(mixinName, methodName, hook)
    local mixin = _G[mixinName]
    if type(mixin) == "table" and type(mixin[methodName]) == "function" then
        hooksecurefunc(mixin, methodName, hook)
        return true
    end
    return false
end

local function WatchEditBox(editBox)
    if not editBox or editBox._incognito2Watch then return end
    editBox:HookScript("OnTextChanged", function(box)
        if not box._incognito2IgnoreText then
            box._incognito2Prefixed = nil
        end
    end)
    -- Enter fallback when ChatFrame.OnEditBoxPreSendText does not fire.
    -- Dedupe via _incognito2Prefixed if the official callback also runs.
    editBox:HookScript("OnKeyDown", function(box, key)
        if not I2._prefixEnabled then return end
        if key == "ENTER" or key == "NUMPADENTER" then
            PrefixFromEditBox(box)
            return
        end
        if key ~= "UP" and key ~= "DOWN" then return end
        if I2:IsAddonRestricted() then return end
        if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
            return
        end
        C_Timer.After(0, function()
            local ok, text = pcall(box.GetText, box)
            if not ok or not I2.Usable(text) then return end
            local stripped = I2:StripOwnPrefix(text)
            if stripped ~= text then
                pcall(box.SetText, box, stripped)
            end
        end)
    end)
    editBox._incognito2Watch = true
end

local function ForEachChatEditBox(visitor)
    local last = 20
    if type(NUM_CHAT_WINDOWS) == "number" and NUM_CHAT_WINDOWS > last then
        last = NUM_CHAT_WINDOWS
    end
    for i = 1, last do
        visitor(_G["ChatFrame" .. i .. "EditBox"])
    end
    local defaultBox = DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox
    if defaultBox then visitor(defaultBox) end
end

local function WatchAllEditBoxes()
    ForEachChatEditBox(WatchEditBox)
end

function I2:InstallChatHooks()
    if self.flavor.useEditBoxHook then
        if not state.preSend then
            if EventRegistry and EventRegistry.RegisterCallback then
                -- Owner is required on some clients; Function callbacks get (owner, ...).
                pcall(EventRegistry.RegisterCallback, EventRegistry,
                      "ChatFrame.OnEditBoxPreSendText", function(ownerOrBox, box)
                    PrefixFromEditBox(box or ownerOrBox)
                end, I2)
            end
            if type(hooksecurefunc) == "function" then
                HookMixinMethod("ChatFrameEditBoxMixin", "OnPreSendText",
                                PrefixFromEditBox)
            end
            state.preSend = true
        end
        if not state.editBoxes then
            WatchAllEditBoxes()
            if type(hooksecurefunc) == "function" and
                type(FCF_OpenTemporaryWindow) == "function" then
                hooksecurefunc("FCF_OpenTemporaryWindow", WatchAllEditBoxes)
            end
            state.editBoxes = true
        end
        self._prefixEnabled = true
        return
    end
    WrapSend()
    WrapClub()
    self._prefixEnabled = true
end

function I2:RemoveChatHooks()
    self._prefixEnabled = false
    if self.flavor.useTableSwap then
        UnwrapSend()
        UnwrapClub()
    end
end

---------------------------------------------------------------------
local CLOSING = {["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">"}

local function SplitPrefixedMessage(msg)
    local lead, open, name, close, gap, afterColon =
        msg:match("^(%s*)([%(%[%{%<])([^%(%[%{%<%]%}%>]+)([%)%]%}%>])(%s*):(%s*)")
    if not open or CLOSING[open] ~= close then return nil end
    return lead, open, name, close, gap, afterColon,
           msg:sub(#lead + #name + #gap + #afterColon + 4)
end

local function GuidFromFilter(...)
    local n = select("#", ...)
    if n >= 10 then
        local value = select(10, ...)
        if I2.Usable(value) and value:sub(1, 7) == "Player-" then
            return value
        end
    end
    for i = n, 1, -1 do
        local value = select(i, ...)
        if I2.Usable(value) and value:sub(1, 7) == "Player-" then
            return value
        end
    end
end

local function ClassFileFrom(author, ...)
    local guid = GuidFromFilter(...)
    if guid and GetPlayerInfoByGUID then
        local ok, _, classFile = pcall(GetPlayerInfoByGUID, guid)
        if ok and I2.Usable(classFile) then return classFile end
    end
    if not author or not UnitClass then return nil end
    local unit = author
    if Ambiguate then
        local ok, short = pcall(Ambiguate, author, "none")
        if ok and I2.Usable(short) then unit = short end
    end
    local ok, _, classFile = pcall(UnitClass, unit)
    if ok and I2.Usable(classFile) then return classFile end
    return nil
end

local function ClassHex(classFile)
    local hex = classHex[classFile]
    if hex then return hex end
    local colors = (type(CUSTOM_CLASS_COLORS) == "table" and CUSTOM_CLASS_COLORS) or
                       RAID_CLASS_COLORS
    local color = colors and colors[classFile]
    if not color then return nil end
    hex = string.format("|cff%02x%02x%02x", math.floor((color.r or 1) * 255 + 0.5),
                        math.floor((color.g or 1) * 255 + 0.5),
                        math.floor((color.b or 1) * 255 + 0.5))
    classHex[classFile] = hex
    return hex
end

function I2:ChatPrefixColorFilter(_, _, msg, author, ...)
    local cache = self:GetSendCache()
    if not cache.enable or not cache.colorize then return false end
    -- Incoming chat can be secret during lockdown. Leave those lines alone.
    if not self.Usable(msg) or not self.Usable(author) then return false end
    local lead, open, name, close, gap, afterColon, rest = SplitPrefixedMessage(msg)
    if not open then return false end
    local hex = ClassHex(ClassFileFrom(author, ...))
    if not hex then return false end
    return false, string.format("%s%s%s%s|r%s%s:%s%s", lead, open, hex, name,
                                close, gap, afterColon, rest), author, ...
end

local FILTER_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING", "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_CHANNEL", "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM"
}

function I2:RegisterChatFilters()
    if self._filtersRegistered then return end
    if not self._ChatFilterFunc then
        self._ChatFilterFunc = function(...)
            return I2:ChatPrefixColorFilter(...)
        end
    end
    for i = 1, #FILTER_EVENTS do
        ChatFrame_AddMessageEventFilter(FILTER_EVENTS[i], self._ChatFilterFunc)
    end
    self._filtersRegistered = true
end

function I2:UnregisterChatFilters()
    if not self._filtersRegistered then return end
    for i = 1, #FILTER_EVENTS do
        ChatFrame_RemoveMessageEventFilter(FILTER_EVENTS[i], self._ChatFilterFunc)
    end
    self._filtersRegistered = false
end
