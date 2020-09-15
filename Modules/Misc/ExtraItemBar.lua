local W, F, E, L = unpack(select(2, ...))
local EB = W:NewModule("ExtraItemsBar", "AceEvent-3.0", "AceHook-3.0")
local S = W:GetModule("Skins")

local _G = _G
local unpack = unpack
local strmatch = strmatch
local tinsert = tinsert
local wipe = wipe
local tonumber = tonumber
local InCombatLockdown = InCombatLockdown
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local CreateFrame = CreateFrame
local GetInventoryItemID = GetInventoryItemID
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local GameTooltip = _G.GameTooltip
local IsUsableItem = IsUsableItem
local GetItemIcon = GetItemIcon
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo

-- https://shadowlands.wowhead.com/potions/name:Potion/min-req-level:40#0+2+3+18
-- Wowhead 抓取后正则替换: ^"([0-9]{6})".* 到 [$1] = true

-- 药水 需求人物等级 40 级
local potions = {
    [5512] = true, -- 治療石
    [176443] = true, -- 消逝狂亂藥水
    [118915] = true, -- 打鬥者的無底德拉諾力量藥水
    [118911] = true, -- 打鬥者的德拉諾智力藥水
    [118913] = true, -- 打鬥者的無底德拉諾敏捷藥水
    [118914] = true, -- 打鬥者的無底德拉諾智力藥水
    [116925] = true, -- 舊式的自由行動藥水
    [118910] = true, -- 打鬥者的德拉諾敏捷藥水
    [118912] = true, -- 打鬥者的德拉諾力量藥水
    [114124] = true, -- 幽靈藥水
    [115531] = true, -- 迴旋艾斯蘭藥水
    [127845] = true, -- 不屈藥水
    [142117] = true, -- 持久之力藥水
    [127844] = true, -- 遠古戰役藥水
    [127834] = true, -- 上古治療藥水
    [127835] = true, -- 上古法力藥水
    [127843] = true, -- 致命恩典藥水
    [127846] = true, -- 脈流藥水
    [127836] = true, -- 上古活力藥水
    [136569] = true, -- 陳年的生命藥水
    [144396] = true, -- 悍勇治療藥水
    [144397] = true, -- 悍勇護甲藥水
    [144398] = true, -- 悍勇怒氣藥水
    [152615] = true, -- 暗星治療藥水
    [142326] = true, -- 打鬥者持久之力藥水
    [142325] = true, -- 打鬥者上古治療藥水
    [152619] = true, -- 暗星法力藥水
    [169451] = true, -- 深淵治療藥水
    [169299] = true, -- 無盡狂怒藥水
    [152497] = true, -- 輕足藥水
    [168498] = true, -- 精良智力戰鬥藥水
    [152495] = true, -- 濱海法力藥水
    [168500] = true, -- 精良力量戰鬥藥水
    [168489] = true, -- 精良敏捷戰鬥藥水
    [152494] = true, -- 濱海治療藥水
    [168506] = true, -- 凝神決心藥水
    [152561] = true, -- 回復藥水
    [168529] = true, -- 地緣強化藥水
    [163222] = true, -- 智力戰鬥藥水
    [163223] = true, -- 敏捷戰鬥藥水
    [152550] = true, -- 海霧藥水
    [152503] = true, -- 隱身藥水
    [152557] = true, -- 鋼膚藥水
    [163224] = true, -- 力量戰鬥藥水
    [152560] = true, -- 澎湃鮮血藥水
    [169300] = true, -- 野性癒合藥水
    [168501] = true, -- 精良鋼膚藥水
    [168499] = true, -- 精良耐力戰鬥藥水
    [163225] = true, -- 耐力戰鬥藥水
    [152559] = true, -- 死亡湧升藥水
    [163082] = true, -- 濱海回春藥水
    [168502] = true, -- 重組藥水
    [167917] = true, -- 鬥陣濱海治療藥水
    [167920] = true, -- 鬥陣智力戰鬥藥水
    [167918] = true, -- 鬥陣力量戰鬥藥水
    [167919] = true, -- 鬥陣敏捷戰鬥藥水
    [184090] = true, -- 導靈者之速藥水
    [180771] = true, -- 不尋常力量藥水
    [171267] = true, -- 鬼靈治療藥水
    [171270] = true, -- 鬼靈敏捷藥水
    [171351] = true, -- 死亡凝視藥水
    [171273] = true, -- 鬼靈智力藥水
    [171352] = true, -- 強力驅邪藥水
    [171350] = true, -- 神性覺醒藥水
    [171349] = true, -- 魅影之火藥水
    [171266] = true, -- 魂隱藥水
    [171272] = true, -- 鬼靈清晰藥水
    [171268] = true, -- 鬼靈法力藥水
    [176811] = true, -- 靈魄獻祭藥水
    [171271] = true, -- 堅實暗影藥水
    [171274] = true, -- 鬼靈耐力藥水
    [171269] = true, -- 鬼靈活力藥水
    [171275] = true, -- 鬼靈力量藥水
    [171264] = true, -- 靈視藥水
    [171263] = true, -- 靈魂純淨藥水
    [171370] = true, -- 幽魂迅捷藥水
    [183823] = true, -- 暢行無阻藥水
    [180317] = true, -- 靈性治療藥水
    [180318] = true -- 靈性法力藥水
}

-- 药剂 需求人物等级 40 级
local flasks = {
    [168652] = true, -- 強效無盡深淵精煉藥劑
    [168654] = true, -- 強效暗流精煉藥劑
    [168651] = true, -- 強效洪流精煉藥劑
    [168655] = true, -- 強效神秘精煉藥劑
    [152639] = true, -- 無盡深淵精煉藥劑
    [168653] = true, -- 強效遼闊地平線精煉藥劑
    [152638] = true, -- 洪流精煉藥劑
    [152641] = true, -- 暗流精煉藥劑
    [127848] = true, -- 七魔精煉藥劑
    [127849] = true, -- 無盡軍士精煉藥劑
    [127850] = true, -- 萬道傷痕精煉藥劑
    [127847] = true, -- 低語契約精煉藥劑
    [152640] = true, -- 遼闊地平線精煉藥劑
    [127858] = true, -- 靈魂精煉藥劑
    [162518] = true, -- 神秘精煉藥劑
    [171276] = true, -- 鬼靈威力精煉藥劑
    [171278] = true -- 鬼靈耐力精煉藥
}

-- 战旗
local banners = {
    [63359] = true, -- 合作旌旗
    [64400] = true, -- 合作旌旗
    [64398] = true, -- 團結軍旗
    [64401] = true, -- 團結軍旗
    [64399] = true, -- 協調戰旗
    [64402] = true, -- 協調戰旗
    [18606] = true, -- 聯盟戰旗
    [18607] = true -- 部落戰旗
}

-- 实用工具
local utilities = {
    [153023] = true, -- 光鑄增強符文
    [109076] = true, -- 哥布林滑翔工具組
    [49040] = true, -- 吉福斯
    [132514] = true -- 自動鐵錘
}

-- 更新任务物品列表
local questItemList = {}
local function UpdateQuestItemList()
    wipe(questItemList)
    for questLogIndex = 1, C_QuestLog_GetNumQuestLogEntries() do
        local link = GetQuestLogSpecialItemInfo(questLogIndex)
        if link then
            local itemID = tonumber(strmatch(link, "|Hitem:(%d+):"))
            local data = {
                questLogIndex = questLogIndex,
                itemID = itemID
            }
            tinsert(questItemList, data)
        end
    end
end

-- 更新装备物品列表
local equipmentList = {}
local function UpdateEquipmentList()
    wipe(equipmentList)
    for slotID = 1, 18 do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID and IsUsableItem(itemID) then
            tinsert(equipmentList, slotID)
        end
    end
end

function EB:CreateButton(name, barDB)
    local button = CreateFrame("Button", name, E.UIParent, "SecureActionButtonTemplate, BackdropTemplate")
    button:Size(barDB.buttonWidth, barDB.buttonHeight)
    button:SetTemplate("Default")
    button:SetClampedToScreen(true)
    button:SetAttribute("type", "item")
    button:EnableMouse(false)
    button:RegisterForClicks("AnyUp")

    local tex = button:CreateTexture(nil, "OVERLAY", nil)
    tex:Point("TOPLEFT", button, "TOPLEFT", 1, -1)
    tex:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    tex:SetTexCoord(unpack(E.TexCoords))

    local count = button:CreateFontString(nil, "OVERLAY")
    count:SetTextColor(1, 1, 1, 1)
    count:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0.5, 0)
    count:SetJustifyH("CENTER")
    F.SetFontWithDB(count, barDB.countFont)

    local bind = button:CreateFontString(nil, "OVERLAY")
    bind:SetTextColor(0.6, 0.6, 0.6)
    bind:Point("BOTTOM", button, "BOTTOM", 0, -5)
    bind:SetJustifyH("CENTER")
    F.SetFontWithDB(bind, barDB.bindFont)

    local cooldown = CreateFrame("Cooldown", name .. "Cooldown", button, "CooldownFrameTemplate")
    E:RegisterCooldown(cooldown)

    button.tex = tex
    button.count = count
    button.bind = bind
    button.cooldown = cooldown

    button:StyleButton()

    if E.private.WT.skins.enable and E.private.WT.skins.windtools then
        S:CreateShadow(button)
    end

    return button
end

function EB:SetUpButton(button, questItemData, slotID)
    button.itemName = nil
    button.itemID = nil
    button.spellName = nil
    button.slotID = nil
    button.countText = nil

    if questItemData then
        button.itemID = questItemData.itemID
        button.itemName = GetItemInfo(questItemData.itemID)
        button.countText = GetItemCount(questItemData.itemID, nil, true)
        button.tex:SetTexture(GetItemIcon(questItemData.itemID))
        button.questLogIndex = questItemData.questLogIndex

        button:SetBackdropBorderColor(0, 0, 0)
    elseif slotID then
        local itemID = GetInventoryItemID("player", slotID)
        local name, _, rarity = GetItemInfo(itemID)

        button.slotID = slotID
        button.itemName = GetItemInfo(itemID)
        button.tex:SetTexture(GetItemIcon(itemID))

        if rarity and rarity > 1 then
            local r, g, b = GetItemQualityColor(rarity)
            button:SetBackdropBorderColor(r, g, b)
        end
    end

    -- 更新堆叠数
    if button.countText and button.countText > 1 then
        button.count:SetText(countText)
    else
        button.count:SetText()
    end

    -- 更新 OnUpdate 函数
    local OnUpdateFunction

    if button.itemID then
        OnUpdateFunction = function(self)
            local start, duration, enable
            if self.questLogIndex and self.questLogIndex > 0 then
                start, duration, enable = GetQuestLogSpecialItemCooldown(self.questLogIndex)
            else
                start, duration, enable = GetItemCooldown(self.itemID)
            end
            CooldownFrame_Set(self.cooldown, start, duration, enable)
            if (duration and duration > 0 and enable and enable == 0) then
                self.tex:SetVertexColor(0.4, 0.4, 0.4)
            elseif IsItemInRange(self.itemID, "target") == false then
                self.tex:SetVertexColor(1, 0, 0)
            else
                self.tex:SetVertexColor(1, 1, 1)
            end
        end
    elseif button.slotID then
        OnUpdateFunction = function(self)
            local start, duration, enable = GetInventoryItemCooldown("player", self.slotID)
            CooldownFrame_Set(self.cooldown, start, duration, enable)
        end
    end

    button:SetScript("OnUpdate", OnUpdateFunction)

    -- 浮动提示
    button:SetScript(
        "OnEnter",
        function(self)
            if InCombatLockdown() then
                return
            end

            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, -2)
            GameTooltip:ClearLines()

            if self.slotID then
                GameTooltip:SetInventoryItem("player", self.slotID)
            else
                GameTooltip:SetItemByID(self.itemID)
            end

            GameTooltip:Show()
        end
    )

    button:SetScript(
        "OnLeave",
        function(self)
            GameTooltip:Hide()
        end
    )

    -- 更新按钮功能
    if not InCombatLockdown() then
        button:EnableMouse(true)
        button:Show()
        if button.slotID then
            button:SetAttribute("type", "macro")
            button:SetAttribute("macrotext", "/use " .. button.slotID)
        elseif button.itemName then
            button:SetAttribute("type", "item")
            button:SetAttribute("item", button.itemName)
        end
    else
        button:RegisterEvent("PLAYER_REGEN_ENABLED")
        button:SetScript(
            "OnEvent",
            function(self, event)
                if event == "PLAYER_REGEN_ENABLED" then
                    self:EnableMouse(true)
                    if self.slotID then
                        self:SetAttribute("type", "macro")
                        self:SetAttribute("macrotext", "/use " .. self.slotID)
                    elseif self.itemName then
                        self:SetAttribute("type", "item")
                        self:SetAttribute("item", self.itemName)
                    end
                    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    button:Show()
                end
            end
        )
    end
end

function EB:CreateBar(id)
    if not self.db or not self.db["bar" .. id] then
        return
    end

    local barDB = self.db["bar" .. id]

    -- 建立条移动锚点
    local anchor = CreateFrame("Frame", "WTExtraItemsBar" .. id .. "Anchor", E.UIParent)
    anchor:SetClampedToScreen(true)
    anchor:Point("BOTTOMLEFT", _G.RightChatPanel or _G.LeftChatPanel, "TOPLEFT", 0, (id - 1) * 45)
    anchor:Size(200, 40)
    E:CreateMover(
        anchor,
        "WTExtraItemsBar" .. id .. "Mover",
        L["Extra Items Bar"] .. " " .. id,
        nil,
        nil,
        nil,
        "ALL,WINDTOOLS",
        function()
            return EB.db.enable and barDB.enable
        end
    )

    -- 建立条
    local bar = CreateFrame("Frame", "WTExtraItemsBar" .. id, E.UIParent, "SecureHandlerStateTemplate")
    bar.id = id
    bar:ClearAllPoints()
    bar:SetParent(anchor)
    bar:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    bar:Size(200, 40)
    bar:CreateBackdrop("Transparent")
    bar:SetFrameStrata("LOW")

    -- 建立按钮
    bar.buttons = {}
    for i = 1, 12 do
        bar.buttons[i] = self:CreateButton(bar:GetName() .. "Button" .. i, barDB)
        bar.buttons[i]:SetParent(bar)
        if i == 1 then
            bar.buttons[i]:Point("LEFT", bar, "LEFT", 5, 0)
        else
            bar.buttons[i]:Point("LEFT", bar.buttons[i - 1], "RIGHT", 5, 0)
        end
    end

    self.bars[id] = bar
end

function EB:UpdateButtonSize(button, barDB)
    button:Size(barDB.buttonWidth, barDB.buttonHeight)
    local left, right, top, bottom = unpack(E.TexCoords)

    if barDB.buttonWidth > barDB.buttonHeight then
        local offset = (bottom - top) * (1 - barDB.buttonHeight / barDB.buttonWidth) / 2
        top = top + offset
        bottom = bottom - offset
    elseif barDB.buttonWidth < barDB.buttonHeight then
        local offset = (right - left) * (1 - barDB.buttonWidth / barDB.buttonHeight) / 2
        left = left + offset
        right = right - offset
    end

    button.tex:SetTexCoord(left, right, top, bottom)
end

function EB:UpdateBar(id)
    if not self.db or not self.db["bar" .. id] then
        return
    end

    local bar = self.bars[id]
    local barDB = self.db["bar" .. id]

    if not self.db.enable or not barDB.enable then
        bar:Hide()
        return
    end

    local buttonID = 1

    for _, module in ipairs {strsplit("[, ]", barDB.include)} do
        if module == "QUEST" then -- 更新任务物品
            for _, data in pairs(questItemList) do
                self:SetUpButton(bar.buttons[buttonID], data)
                self:UpdateButtonSize(bar.buttons[buttonID], barDB)
                buttonID = buttonID + 1
            end
        elseif module == "POTION" then -- 更新药水
            for potionID in pairs(potions) do
                local count = GetItemCount(potionID)
                if count and count > 0 and not self.db.blackList[potionID] then
                    self:SetUpButton(bar.buttons[buttonID], {itemID = potionID})
                    self:UpdateButtonSize(bar.buttons[buttonID], barDB)
                    buttonID = buttonID + 1
                end
            end
        elseif module == "FLASK" then -- 更新药剂
            for flaskID in pairs(flasks) do
                local count = GetItemCount(flaskID)
                if count and count > 0 and not self.db.blackList[flaskID] then
                    self:SetUpButton(bar.buttons[buttonID], {itemID = flaskID})
                    self:UpdateButtonSize(bar.buttons[buttonID], barDB)
                    buttonID = buttonID + 1
                end
            end
        elseif module == "BANNER" then -- 更新战旗
            for bannerID in pairs(banners) do
                local count = GetItemCount(bannerID)
                if count and count > 0 and not self.db.blackList[bannerID] then
                    self:SetUpButton(bar.buttons[buttonID], {itemID = bannerID})
                    bar.buttons[buttonID]:Size(barDB.buttonWidth, barDB.buttonHeight)
                    buttonID = buttonID + 1
                end
            end
        elseif module == "UTILITY" then -- 更新实用工具
            for utilityID in pairs(utilities) do
                local count = GetItemCount(utilityID)
                if count and count > 0 and not self.db.blackList[utilityID] then
                    self:SetUpButton(bar.buttons[buttonID], {itemID = utilityID})
                    self:UpdateButtonSize(bar.buttons[buttonID], barDB)
                    buttonID = buttonID + 1
                end
            end
        elseif module == "EQUIP" then -- 更新装备物品
            for _, slotID in pairs(equipmentList) do
                self:SetUpButton(bar.buttons[buttonID], nil, slotID)
                self:UpdateButtonSize(bar.buttons[buttonID], barDB)
                buttonID = buttonID + 1
            end
        end
        if buttonID > 12 then
            return
        end
    end

    -- 隐藏其余按钮
    if buttonID == 1 then
        bar:Hide()
        return
    end

    if buttonID <= 12 then
        for hideButtonID = buttonID, 12 do
            bar.buttons[hideButtonID]:Hide()
        end
    end

    -- 计算新的条大小
    local numRows = ceil((buttonID - 1) / barDB.buttonsPerRow)
    local numCols = buttonID > barDB.buttonsPerRow and barDB.buttonsPerRow or (buttonID - 1)
    local newBarWidth = 2 * barDB.backdropSpacing + numCols * barDB.buttonWidth + (numCols - 1) * barDB.spacing
    local newBarHeight = 2 * barDB.backdropSpacing + numRows * barDB.buttonHeight + (numRows - 1) * barDB.spacing
    bar:Size(newBarWidth, newBarHeight)
    bar:GetParent():Size(newBarWidth, newBarHeight)

    -- 重新定位图标
    for i = 1, buttonID - 1 do
        local anchor = barDB.anchor
        local button = bar.buttons[i]

        button:ClearAllPoints()

        if i == 1 then
            if anchor == "TOPLEFT" then
                button:Point("TOPRIGHT", bar, "TOPRIGHT", -barDB.backdropSpacing, -barDB.backdropSpacing)
            elseif anchor == "TOPRIGHT" then
                button:Point("TOPLEFT", bar, "TOPLEFT", barDB.backdropSpacing, -barDB.backdropSpacing)
            elseif anchor == "BOTTOMLEFT" then
                button:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -barDB.backdropSpacing, barDB.backdropSpacing)
            elseif anchor == "BOTTOMRIGHT" then
                button:Point("BOTTOMLEFT", bar, "BOTTOMLEFT", barDB.backdropSpacing, barDB.backdropSpacing)
            end
        elseif i <= barDB.buttonsPerRow then
            local nearest = bar.buttons[i - 1]
            if anchor == "TOPLEFT" or anchor == "BOTTOMLEFT" then
                button:Point("RIGHT", nearest, "LEFT", barDB.spacing, 0)
            else
                button:Point("LEFT", nearest, "RIGHT", -barDB.spacing, 0)
            end
        else
            local nearest = bar.buttons[i - barDB.buttonsPerRow]
            if anchor == "TOPLEFT" or anchor == "TOPRIGHT" then
                button:Point("TOP", nearest, "BOTTOM", 0, -barDB.spacing)
            else
                button:Point("BOTTOM", nearest, "TOP", 0, barDB.spacing)
            end
        end
    end

    bar:Show()

    -- 切换阴影
    if E.private.WT.skins.enable and E.private.WT.skins.windtools then
        if barDB.backdrop then
            bar.backdrop:Show()
            for i = 1, 12 do
                if bar.buttons[i].shadow then
                    bar.buttons[i].shadow:Hide()
                end
            end
        else
            bar.backdrop:Hide()
            for i = 1, 12 do
                if bar.buttons[i].shadow then
                    bar.buttons[i].shadow:Show()
                end
            end
        end
    end
end

function EB:UpdateBars()
    for i = 1, 3 do
        self:UpdateBar(i)
    end
end

function EB:UpdateQuestItem()
    UpdateQuestItemList()
    self:UpdateBars()
end

function EB:UpdateEquipment()
    UpdateEquipmentList()
    self:UpdateBars()
end

function EB:CreateAll()
    self.bars = {}

    for i = 1, 3 do
        self:CreateBar(i)
        if E.private.WT.skins.enable and E.private.WT.skins.windtools then
            S:CreateShadow(self.bars[i].backdrop)
        end
    end
end

function EB:Initialize()
    self.db = E.db.WT.misc.extraItemsBar
    if not self.db or not self.db.enable or self.Initialized then
        return
    end

    self:CreateAll()
    UpdateQuestItemList()
    UpdateEquipmentList()
    self:UpdateBars()

    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateEquipment")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "UpdateBars")
    self:RegisterEvent("ZONE_CHANGED", "UpdateBars")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateBars")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED", "UpdateQuestItem")
    self:RegisterEvent("QUEST_LOG_UPDATE", "UpdateQuestItem")
    self:RegisterEvent("QUEST_ACCEPTED", "UpdateQuestItem")
    self:RegisterEvent("QUEST_TURNED_IN", "UpdateQuestItem")
    self:RegisterEvent("UPDATE_BINDINGS", "UpdateBind")

    self.Initialized = true
end

function EB:ProfileUpdate()
    self:Initialize()

    if self.db.enable then
        UpdateQuestItemList()
        UpdateEquipmentList()
    elseif self.Initialized then
        self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
        self:UnregisterEvent("ZONE_CHANGED")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("QUEST_WATCH_LIST_CHANGED")
        self:UnregisterEvent("QUEST_LOG_UPDATE")
        self:UnregisterEvent("QUEST_ACCEPTED")
        self:UnregisterEvent("QUEST_TURNED_IN")
        self:UnregisterEvent("UPDATE_BINDINGS")
    end

    self:UpdateBars()
end

W:RegisterModule(EB:GetName())
