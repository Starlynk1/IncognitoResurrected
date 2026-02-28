---------------------------------------------------------------------
-- ChatCompat.lua  (v6)
-- Abstraction layer for Retail / Classic Chat APIs
--
-- Retail: EditBox pre-hook approach — hooks chat editbox OnKeyDown to
-- modify outgoing text before Enter triggers the secure send path.
-- Never replaces C_ChatInfo.SendChatMessage, preventing taint.
--
-- Classic: Manual table-swap hooks (no taint issues in Classic).
-- 
-- Note: This Library has been modified from the original place I had
-- found it. Name2Chat was the first place I saw its use, not sure if
-- is the original author. But credits to them for the original work.
---------------------------------------------------------------------
local MAJOR, MINOR = "ChatCompat", 6
local ChatCompat = LibStub:NewLibrary(MAJOR, MINOR)
if not ChatCompat then return end

---------------------------------------------------------------------
-- State Initialization
---------------------------------------------------------------------
ChatCompat._hooks = ChatCompat._hooks or {}
-- Reset editbox hooks on version upgrade so new hook code is installed
ChatCompat._hooks.editBoxesHooked = false

-- Modern Retail (TWW 11.x / Midnight 12.x+) has taint restrictions;
-- MoP Classic (5.x) uses EditBox hooks too but has no taint issue.
local function isModernRetail()
    local _, _, _, tocVersion = GetBuildInfo()
    return tocVersion and tocVersion >= 110000
end

-- Returns true if addon restrictions are active (encounter, M+, PvP, restricted map).
-- Uses C_RestrictedActions when available or falls back to GetInstanceInfo.
local function IsAddonRestricted()
    if type(C_RestrictedActions) == "table" and
       type(C_RestrictedActions.GetAddOnRestrictionState) == "function" then
        for _, restrictType in ipairs({1, 2, 3, 4}) do -- Encounter, ChallengeMode, PvPMatch, Map
            if C_RestrictedActions.GetAddOnRestrictionState(restrictType) ~= 0 then
                return true
            end
        end
        return false
    end
    if type(GetInstanceInfo) == "function" then
        local _, instanceType = GetInstanceInfo()
        return instanceType == "pvp" or instanceType == "arena"
    end
    return false
end

---------------------------------------------------------------------
-- API Detection
---------------------------------------------------------------------
local function detectApi()
    local hasCChatInfo = type(C_ChatInfo) == "table" and
                             type(C_ChatInfo.SendChatMessage) == "function"
    local hasCClub = type(C_Club) == "table" and type(C_Club.SendMessage) ==
                         "function"
    local supportsInstanceChat =
        ChatTypeInfo and ChatTypeInfo["INSTANCE_CHAT"] ~= nil

    return {
        useCChatInfo = hasCChatInfo,
        useCClub = hasCClub,
        supportsInstanceChat = supportsInstanceChat
    }
end

ChatCompat.api = detectApi()

---------------------------------------------------------------------
-- Hook SendChatMessage  (manual table swap — no AceHook, no taint)
-- Preserves the original across unhook/re-hook cycles.
---------------------------------------------------------------------
function ChatCompat:HookSendChatMessage(addon)
    if self._hooks.sendChatHooked then return end

    -- Capture the true original only once
    if not self._hooks.sendChatOriginal then
        if self.api.useCChatInfo then
            self._hooks.sendChatOriginal = C_ChatInfo.SendChatMessage
        else
            self._hooks.sendChatOriginal = SendChatMessage
        end
    end

    if self.api.useCChatInfo then
        C_ChatInfo.SendChatMessage = function(msg, chatType, language, target)
            return addon:SendChatMessage(msg, chatType, language, target)
        end
    else
        SendChatMessage = function(msg, chatType, language, target)
            return addon:SendChatMessage(msg, chatType, language, target)
        end
    end
    self._hooks.sendChatHooked = true
end

---------------------------------------------------------------------
-- Unhook SendChatMessage  (deterministic restore of original)
---------------------------------------------------------------------
function ChatCompat:UnhookSendChatMessage()
    if not self._hooks.sendChatHooked then return end

    if self.api.useCChatInfo then
        C_ChatInfo.SendChatMessage = self._hooks.sendChatOriginal
    else
        SendChatMessage = self._hooks.sendChatOriginal
    end
    self._hooks.sendChatHooked = false
    -- NOTE: sendChatOriginal is kept for re-hooking later
end

---------------------------------------------------------------------
-- Hook C_Club.SendMessage  (Retail communities)
---------------------------------------------------------------------
function ChatCompat:HookClubSendMessage(addon)
    if not self.api.useCClub then return end
    if self._hooks.clubSendHooked then return end

    if not self._hooks.clubSendOriginal then
        self._hooks.clubSendOriginal = C_Club.SendMessage
    end

    C_Club.SendMessage = function(clubID, streamID, msg)
        return addon:SendMessage(clubID, streamID, msg)
    end
    self._hooks.clubSendHooked = true
end

---------------------------------------------------------------------
-- Unhook C_Club.SendMessage
---------------------------------------------------------------------
function ChatCompat:UnhookClubSendMessage()
    if not self._hooks.clubSendHooked then return end

    C_Club.SendMessage = self._hooks.clubSendOriginal
    self._hooks.clubSendHooked = false
end

---------------------------------------------------------------------
-- Retail: EditBox OnKeyDown pre-hook approach
--
-- OnKeyDown fires BEFORE OnEnterPressed in WoW's event chain:
--   1. OnKeyDown original handler → 2. OnKeyDown HookScript (us) →
--   3. OnEnterPressed original handler (sends & clears text)
--
-- So our HookScript fires while text & chatType are still available.
-- We modify the text via SetText() and OnEnterPressed then sends it.
--
-- hooksecurefunc/HookScript don't spread taint, so the secure send
-- path (C_ChatInfo.SendChatMessage) runs in a clean context.
---------------------------------------------------------------------
function ChatCompat:HookChatEditBoxes(addon)
    if self._hooks.editBoxesHooked then return end

    local function hookSingleEditBox(editBox)
        if not editBox or editBox._chatCompatHooked then return end

        editBox:HookScript("OnKeyDown", function(eb, key)
            if key ~= "ENTER" and key ~= "NUMPADENTER" then return end
            if not addon._prefixEnabled then return end

            local text = eb:GetText()
            if not text or text == "" then return end

            -- Midnight stores chatType as a frame attribute, not a field
            local chatType = eb:GetAttribute("chatType") or
                                 (eb.GetChatType and eb:GetChatType()) or
                                 eb.chatType

            -- Channel target via method (Midnight) or field (Classic)
            local target = (eb.GetChannelTarget and eb:GetChannelTarget()) or
                               eb.channelTarget
            if not chatType then return end

            -- Skip prefix injection when addon restrictions are active (encounter, M+, PvP, etc.)
            if IsAddonRestricted() then return end

            local newText = addon:ProcessOutgoingText(text, chatType, target)
            if newText and newText ~= text then eb:SetText(newText) end
        end)

        -- Strip prefix when the user browses sent-message history (Up/Down).
        editBox:HookScript("OnKeyDown", function(eb, key)
            if key ~= "UP" and key ~= "DOWN" then return end
            if not addon._prefixEnabled then return end

            -- Skip prefix injection when addon restrictions are active (encounter, M+, PvP, etc.)
            if IsAddonRestricted() then return end

            local text = eb:GetText()
            if not text or text == "" then return end
            local prefix = addon:GetNamePrefix()
            if text:sub(1, #prefix) == prefix then
                eb:SetText(text:sub(#prefix + 1))
            end
        end)

        editBox._chatCompatHooked = true
    end

    -- Hook all existing chat editboxes
    local numFrames = NUM_CHAT_WINDOWS or 10
    for i = 1, numFrames do
        local eb = _G["ChatFrame" .. i .. "EditBox"]
        hookSingleEditBox(eb)
        if eb then
            addon:Safe_Print("[ChatCompat] Hooked ChatFrame" .. i ..
                                 "EditBox OnKeyDown")
        end
    end

    -- Catch new temporary windows
    if type(FCF_OpenTemporaryWindow) == "function" then
        hooksecurefunc("FCF_OpenTemporaryWindow", function()
            for i = 1, (NUM_CHAT_WINDOWS or 10) do
                hookSingleEditBox(_G["ChatFrame" .. i .. "EditBox"])
            end
        end)
    end

    self._hooks.editBoxesHooked = true
    addon._prefixEnabled = true
    addon:Safe_Print(
        "[ChatCompat] OnKeyDown hooks installed, prefixEnabled=true")
end

---------------------------------------------------------------------
-- Call original SendChatMessage  (Classic table-swap path only)
---------------------------------------------------------------------
function ChatCompat:CallOriginalSendChatMessage(msg, chatType, language, target)
    local original = self._hooks.sendChatOriginal
    if type(original) == "function" then
        return original(msg, chatType, language, target)
    end
    -- Fallback: hooks were never set up
    if self.api.useCChatInfo then
        return C_ChatInfo.SendChatMessage(msg, chatType, language, target)
    else
        return SendChatMessage(msg, chatType, language, target)
    end
end

---------------------------------------------------------------------
-- Call original C_Club.SendMessage
---------------------------------------------------------------------
function ChatCompat:CallOriginalClubSendMessage(clubID, streamID, msg)
    local original = self._hooks.clubSendOriginal
    if type(original) == "function" then
        return original(clubID, streamID, msg)
    end
    if self.api.useCClub then
        return C_Club.SendMessage(clubID, streamID, msg)
    end
end

---------------------------------------------------------------------
-- Check if chat messaging is locked (Retail instance lockdown)
---------------------------------------------------------------------
function ChatCompat:IsChatLocked()
    if not self.api.useCChatInfo then return false end
    if type(C_ChatInfo) == "table" and type(C_ChatInfo.InChatMessagingLockdown) ==
        "function" then
        local ok, result = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and result then return true end
    end
    return false
end

---------------------------------------------------------------------
-- Hook state queries
---------------------------------------------------------------------
function ChatCompat:IsSendChatHooked() return
    self._hooks.sendChatHooked or false end

function ChatCompat:IsClubSendHooked() return
    self._hooks.clubSendHooked or false end

---------------------------------------------------------------------
-- Bulk hook / unhook helpers
---------------------------------------------------------------------
function ChatCompat:HookAll(addon)
    self:HookSendChatMessage(addon)
    self:HookClubSendMessage(addon)
end

function ChatCompat:UnhookAll()
    self:UnhookSendChatMessage()
    self:UnhookClubSendMessage()
end

---------------------------------------------------------------------
-- API info (debug)
---------------------------------------------------------------------
function ChatCompat:GetApiInfo()
    return {
        useCChatInfo = self.api.useCChatInfo,
        useCClub = self.api.useCClub,
        supportsInstanceChat = self.api.supportsInstanceChat,
        sendChatHooked = self:IsSendChatHooked(),
        clubSendHooked = self:IsClubSendHooked()
    }
end

return ChatCompat
