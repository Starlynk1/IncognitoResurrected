---------------------------------------------------------------------
-- Incognito2 native options panel (Ace3 optional, not required)
---------------------------------------------------------------------
local _, ns = ...
local I2 = ns.Incognito2
local L = I2.L

local widgets = {}

local function Profile()
    return I2:GetProfile()
end

local function CreateCheck(parent, template)
    local ok, cb = pcall(CreateFrame, "CheckButton", nil, parent, template)
    if ok and cb then return cb end
    return CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
end

local function SetCheckLabel(cb, text)
    local label = cb.Text or cb.text or _G[cb:GetName() and (cb:GetName() .. "Text") or ""]
    if label and label.SetText then
        label:SetText(text)
    end
end

local function AddCheckbox(parent, key, label, desc, onChanged)
    local cb = CreateCheck(parent, "UICheckButtonTemplate")
    SetCheckLabel(cb, label)
    cb.tooltipText = desc
    cb:SetScript("OnEnter", function(self)
        if self.tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    cb:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    cb:SetScript("OnClick", function(self)
        I2:SetFlag(key, self:GetChecked() and 1 or 0)
        if onChanged then onChanged(I2:GetFlag(key)) end
        I2:NotifyOptionsChanged()
    end)
    widgets[#widgets + 1] = function()
        cb:SetChecked(I2:GetFlag(key))
    end
    return cb
end

local function AddEditBox(parent, key, width)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetAutoFocus(false)
    box:SetSize(width or 180, 20)
    box:SetScript("OnEnterPressed", function(self)
        local profile = Profile()
        if profile then
            profile[key] = self:GetText() or ""
            I2:NotifyOptionsChanged()
        end
        self:ClearFocus()
    end)
    box:SetScript("OnEditFocusLost", function(self)
        local profile = Profile()
        if profile then
            profile[key] = self:GetText() or ""
            I2:RebuildSendCache()
        end
    end)
    widgets[#widgets + 1] = function()
        local profile = Profile()
        if profile and not box:HasFocus() then
            box:SetText(profile[key] or "")
        end
    end
    return box
end

local function AddLabel(parent, text, font)
    local fs = parent:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
    fs:SetText(text)
    fs:SetJustifyH("LEFT")
    return fs
end

local function AddNote(parent, text, width)
    local fs = AddLabel(parent, "|cFFFFA500" .. text .. "|r",
                        "GameFontHighlightSmall")
    fs:SetWidth(width or 500)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    return fs
end

local function AddTooltip(frame, title, desc)
    if not desc or desc == "" then return end
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title or "", nil, nil, nil, nil, true)
        if desc and desc ~= title then
            GameTooltip:AddLine(desc, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function SetWidgetEnabled(widget, enabled)
    if not widget then return end
    if widget.Button or (widget.Left and widget.Middle and widget.Right) then
        if enabled then
            pcall(UIDropDownMenu_EnableDropDown, widget)
        else
            pcall(UIDropDownMenu_DisableDropDown, widget)
        end
        return
    end
    if widget.SetEnabled then
        widget:SetEnabled(enabled)
    elseif enabled then
        if widget.Enable then widget:Enable() end
    else
        if widget.Disable then widget:Disable() end
    end
end

local function AddCycleButton(parent, key, items)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(180, 22)
    local function SelectedLabel()
        local profile = Profile()
        local value = profile and profile[key]
        for i = 1, #items do
            if items[i].value == value then
                return items[i].label
            end
        end
        return items[1] and items[1].label or ""
    end
    btn:SetScript("OnClick", function()
        local profile = Profile()
        if not profile then return end
        local idx = 1
        for i = 1, #items do
            if items[i].value == profile[key] then
                idx = i
                break
            end
        end
        idx = (idx % #items) + 1
        profile[key] = items[idx].value
        btn:SetText(items[idx].label)
        I2:NotifyOptionsChanged()
    end)
    widgets[#widgets + 1] = function()
        btn:SetText(SelectedLabel())
    end
    btn:SetText(SelectedLabel())
    return btn
end

local function AddDropdown(parent, name, key, items)
    local ok, drop = pcall(CreateFrame, "Frame", name, parent,
                           "UIDropDownMenuTemplate")
    if not ok or not drop or type(UIDropDownMenu_SetWidth) ~= "function" then
        return AddCycleButton(parent, key, items)
    end
    pcall(UIDropDownMenu_SetWidth, drop, 160)
    local function SelectedLabel()
        local profile = Profile()
        local value = profile and profile[key]
        for i = 1, #items do
            if items[i].value == value then
                return items[i].label
            end
        end
        return items[1] and items[1].label or ""
    end
    local initOk = pcall(UIDropDownMenu_Initialize, drop, function()
        for i = 1, #items do
            local item = items[i]
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.label
            info.checked = Profile()[key] == item.value
            info.func = function()
                Profile()[key] = item.value
                UIDropDownMenu_SetText(drop, item.label)
                I2:NotifyOptionsChanged()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    if not initOk then
        drop:Hide()
        return AddCycleButton(parent, key, items)
    end
    widgets[#widgets + 1] = function()
        pcall(UIDropDownMenu_SetText, drop, SelectedLabel())
    end
    return drop
end

function I2:RefreshOptionsPanel()
    for i = 1, #widgets do
        widgets[i]()
    end
end

function I2:CreateOptionsPanel()
    if self.optionsPanel then return end

    local panel = CreateFrame("Frame")
    panel.name = self.embedded and "Incognito2 Beta" or "Incognito2"
    self.optionsPanel = panel

    local scroll = CreateFrame("ScrollFrame", "Incognito2OptionsScroll", panel,
                               "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -8)
    scroll:SetPoint("BOTTOMRIGHT", -30, 8)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(560, 920)
    scroll:SetScrollChild(content)

    local LEFT = 16
    local COL = 168
    local DROP_COL = 260
    local y = -8

    local function Next(dy)
        y = y - dy
    end

    local function Put(frame, x, dy)
        frame:SetPoint("TOPLEFT", content, "TOPLEFT", x or LEFT, y)
        if dy then Next(dy) end
        return frame
    end

    local function Section(title)
        Next(10)
        local header = AddLabel(content, title, "GameFontNormal")
        Put(header, LEFT, 16)
        local line = content:CreateTexture(nil, "ARTWORK")
        line:SetColorTexture(1, 0.82, 0, 0.35)
        line:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT, y + 4)
        line:SetSize(520, 1)
        Next(10)
        return header
    end

    local title = AddLabel(content, panel.name, "GameFontNormalLarge")
    Put(title, LEFT, 22)

    local status = AddLabel(content, "", "GameFontHighlightSmall")
    status:SetWidth(520)
    status:SetWordWrap(true)
    Put(status, LEFT, 28)
    widgets[#widgets + 1] = function()
        if I2:ShouldActivate() and I2:IsActive() then
            status:SetText("|cff00ff00" .. L.engineActive .. "|r")
        elseif I2.embedded then
            status:SetText("|cffffcc00" .. L.engineIdle .. "|r")
        else
            status:SetText("|cff00ff00" .. L.engineActive .. "|r")
        end
    end

    local globalCb = CreateCheck(content, "UICheckButtonTemplate")
    SetCheckLabel(globalCb, L.useGlobalProfile)
    AddTooltip(globalCb, L.useGlobalProfile, L.useGlobalProfile_desc)
    globalCb:SetScript("OnClick", function(self)
        I2:SetUseGlobalProfile(self:GetChecked() and 1 or 0)
    end)
    Put(globalCb, LEFT - 4, 26)
    widgets[#widgets + 1] = function()
        globalCb:SetChecked(I2:IsUsingGlobalProfile())
    end

    local profileLabel = AddNote(content, "", 520)
    Put(profileLabel, LEFT, 22)
    widgets[#widgets + 1] = function()
        profileLabel:SetText("|cFFFFA500" .. L.activeProfile ..
                                 I2:GetActiveProfileName() .. "|r")
    end

    ---------------------------------------------------------------------
    -- General Settings
    ---------------------------------------------------------------------
    Section(L.generalSettings)

    local nameLabel = AddLabel(content, L.name)
    Put(nameLabel, LEFT, 16)

    local nameBox = AddEditBox(content, "name", 220)
    AddTooltip(nameBox, L.name, L.name_desc)
    Put(nameBox, LEFT + 6)
    local enableCb = AddCheckbox(content, "enable", L.enable, L.enable_desc)
    enableCb:SetPoint("LEFT", nameBox, "RIGHT", 24, 0)
    Next(30)

    Put(AddCheckbox(content, "colorizePrefix", L.colorizePrefix,
                    L.colorizePrefix_desc), LEFT - 4, 26)

    local hideCb = AddCheckbox(content, "hideOnMatchingCharName",
                               L.hideOnMatchingCharName,
                               L.hideOnMatchingCharName_desc)
    Put(hideCb, LEFT - 4, 28)

    local partialLabel = AddLabel(content, L.partialMatchMode)
    Put(partialLabel, LEFT)
    local bracketLabel = AddLabel(content, L.bracketStyle)
    bracketLabel:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT + DROP_COL, y)
    Next(16)

    local partial = AddDropdown(content, "Incognito2PartialDropDown",
                                "partialMatchMode", {
        {value = "disabled", label = L.partialMatchMode_disabled},
        {value = "start", label = L.partialMatchMode_start},
        {value = "anywhere", label = L.partialMatchMode_anywhere},
        {value = "end", label = L.partialMatchMode_end}
    })
    Put(partial, LEFT - 16)
    local bracket = AddDropdown(content, "Incognito2BracketDropDown",
                                "bracketStyle", {
        {value = "paren", label = "(round)"},
        {value = "square", label = "[square]"},
        {value = "curly", label = "{curly}"},
        {value = "angle", label = "<angle>"}
    })
    bracket:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT + DROP_COL - 16, y)
    Next(40)

    widgets[#widgets + 1] = function()
        SetWidgetEnabled(partial, I2:GetFlag("hideOnMatchingCharName"))
    end

    Put(AddNote(content, L.specialCharsInfo, 520), LEFT, 28)

    ---------------------------------------------------------------------
    -- Options
    ---------------------------------------------------------------------
    Section(L.optionsSection)

    Put(AddCheckbox(content, "guild", L.guild, L.guild_desc), LEFT - 4, 26)
    Put(AddNote(content, L.guildinfo, 520), LEFT, 28)

    local partyCb = AddCheckbox(content, "party", L.party, L.party_desc)
    local dungeonCb = AddCheckbox(content, "dungeon", L.dungeon, L.dungeon_desc)
    local raidCb = AddCheckbox(content, "raid", L.raid, L.raid_desc)
    partyCb:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT - 4, y)
    dungeonCb:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT - 4 + COL, y)
    raidCb:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT - 4 + COL * 2, y)
    Next(26)

    local bgCb = AddCheckbox(content, "battleground", L.battleground,
                             L.battleground_desc)
    bgCb:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT - 4, y)
    local arenaCb
    if I2:HasArenas() then
        arenaCb = AddCheckbox(content, "arena", L.arena, L.arena_desc)
        arenaCb:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT - 4 + COL, y)
    end
    Next(26)

    local instanceNote = AddNote(content, L.instanceTogglesDisabled, 520)
    Put(instanceNote, LEFT, 36)
    widgets[#widgets + 1] = function()
        local modern = I2:IsModernRetail()
        SetWidgetEnabled(dungeonCb, not modern)
        SetWidgetEnabled(raidCb, not modern)
        SetWidgetEnabled(bgCb, not modern)
        SetWidgetEnabled(arenaCb, not modern)
        instanceNote:SetShown(modern)
    end

    Put(AddCheckbox(content, "world_chat", L.world_chat, L.world_chat_desc),
        LEFT - 4, 26)
    Put(AddNote(content, L.world_chat_info_desc, 520), LEFT, 28)

    local channelLabel = AddLabel(content, L.channel)
    Put(channelLabel, LEFT, 16)
    local channelBox = AddEditBox(content, "channel", 280)
    AddTooltip(channelBox, L.channel, L.channel_desc)
    Put(channelBox, LEFT + 6, 26)
    Put(AddNote(content, L.channel_info_text, 520), LEFT, 28)

    if I2:IsRetailAPI() then
        Put(AddCheckbox(content, "community", L.community, L.community_desc),
            LEFT - 4, 26)
        Put(AddNote(content, L.community_info_text, 520), LEFT, 28)
    end

    Put(AddCheckbox(content, "debug", L.debug, L.debug_desc), LEFT - 4, 26)

    content:SetHeight(math.max(640, -y + 24))

    panel:SetScript("OnShow", function()
        I2:RefreshOptionsPanel()
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel,
                                   panel.name)
        if ok and category then
            pcall(Settings.RegisterAddOnCategory, category)
            self.settingsCategory = category
            if category.GetID then
                self.settingsCategoryID = category:GetID()
            else
                self.settingsCategoryID = category.ID or panel.name
            end
        end
    elseif InterfaceOptions_AddCategory then
        pcall(InterfaceOptions_AddCategory, panel)
    end
end

function I2:OpenOptions()
    if self.settingsCategoryID and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(self.settingsCategoryID)
        return
    end
    if self.settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(self.settingsCategory)
        return
    end
    if self.optionsPanel and InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        return
    end
    self:Print("Open Interface Options and look for " ..
                   (self.optionsPanel and self.optionsPanel.name or "Incognito2"))
end
