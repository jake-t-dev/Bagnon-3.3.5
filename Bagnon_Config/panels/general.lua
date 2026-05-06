--[[
	General.lua
		General Bagnon settings
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Config')

--a hack panel, this is designed to force open to the general options panel when clicked
local BagnonOptions = Bagnon.OptionsPanel:New('Bagnon', nil, 'Bagnon')
BagnonOptions:SetScript('OnShow', function(self)
	InterfaceOptionsFrame_OpenToCategory(Bagnon.GeneralOptions)
	self:Hide()
end)

local GeneralOptions = Bagnon.OptionsPanel:New('BagnonOptions_General', 'Bagnon', L.GeneralSettings, L.GeneralSettingsTitle)
Bagnon.GeneralOptions = GeneralOptions

local SPACING = 6


--[[
	Startup
--]]

function GeneralOptions:Load()
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:AddWidgets()
	self:UpdateMessages()
end

--[[
	Frame Events
--]]

function GeneralOptions:OnShow()
	self:UpdateMessages()
end

function GeneralOptions:OnHide()
	self:UpdateMessages()
end


--[[
	Messages
--]]

function GeneralOptions:UpdateMessages()
	if not self:IsVisible() then
		self:UnregisterAllMessages()
		return
	end

	self:RegisterMessage('SHOW_EMPTY_ITEM_SLOT_TEXTURE_UPDATE')
	self:RegisterMessage('LOCK_FRAME_POSITIONS_UPDATE')
	self:RegisterMessage('ENABLE_FRAME_UPDATE')
	self:RegisterMessage('BLIZZARD_BAG_PASSTHROUGH_UPDATE')
end

function GeneralOptions:SHOW_EMPTY_ITEM_SLOT_TEXTURE_UPDATE(msg, enable)
	self:GetEmptyItemSlotTextureCheckbox():UpdateChecked()
end

function GeneralOptions:LOCK_FRAME_POSITIONS_UPDATE(msg, enable)
	self:GetLockFramePositionsCheckbox():UpdateChecked()
end

function GeneralOptions:ENABLE_FRAME_UPDATE(msg, frameID, enable)
	self:GetEnableFrameCheckbox(frameID):UpdateChecked()
end

function GeneralOptions:BLIZZARD_BAG_PASSTHROUGH_UPDATE(msg, enable)
	self:GetBlizzardBagPassThroughCheckbox():UpdateChecked()
end



--[[
	Widgets
--]]

function GeneralOptions:AddWidgets()
	local scrollChild = self:GetScrollChild()

	local enableInventory = self:CreateEnableFrameCheckbox('inventory')
	enableInventory:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 14, -12)
	
	local enableBank = self:CreateEnableFrameCheckbox('bank')
	enableBank:SetPoint('TOPLEFT', enableInventory, 'BOTTOMLEFT', 0, -SPACING)
	
	local enableKeyring = self:CreateEnableFrameCheckbox('keys')
	enableKeyring:SetPoint('TOPLEFT', enableBank, 'BOTTOMLEFT', 0, -SPACING)
	
	local lockFramePositions = self:CreateLockFramePositionsCheckbox()
	lockFramePositions:SetPoint('TOPLEFT', enableKeyring, 'BOTTOMLEFT', 0, -SPACING)
	
	local showEmptyItemSlotTextures = self:CreateEmptyItemSlotTextureCheckbox()
	showEmptyItemSlotTextures:SetPoint('TOPLEFT', lockFramePositions, 'BOTTOMLEFT', 0, -SPACING)
	
	local enableBlizzardBagPassThrough = self:CreateBlizzardBagPassThroughCheckbox()
	enableBlizzardBagPassThrough:SetPoint('TOPLEFT', showEmptyItemSlotTextures, 'BOTTOMLEFT', 0, -SPACING)

	local showSlotCount = self:CreateShowSlotCountCheckbox()
	showSlotCount:SetPoint('TOPLEFT', enableBlizzardBagPassThrough, 'BOTTOMLEFT', 0, -SPACING)

	local showItemLevel = self:CreateShowItemLevelCheckbox()
	showItemLevel:SetPoint('TOPLEFT', showSlotCount, 'BOTTOMLEFT', 0, -SPACING)

	local showNewItemGlow = self:CreateShowNewItemGlowCheckbox()
	showNewItemGlow:SetPoint('TOPLEFT', showItemLevel, 'BOTTOMLEFT', 0, -SPACING)

	local sortIgnoreSlotsSlider = self:CreateSortIgnoreSlotsSlider()
	sortIgnoreSlotsSlider:SetPoint('TOPLEFT', showNewItemGlow, 'BOTTOMLEFT', 0, -16)
	sortIgnoreSlotsSlider:SetWidth(240)

	local sortIgnoreSlotsAtBottom = self:CreateSortIgnoreSlotsAtBottomCheckbox()
	sortIgnoreSlotsAtBottom:SetPoint('TOPLEFT', sortIgnoreSlotsSlider, 'BOTTOMLEFT', 0, -16)

	local sortOrderDropdown = self:CreateSortOrderDropdown()
	sortOrderDropdown:SetPoint('TOPLEFT', sortIgnoreSlotsAtBottom, 'BOTTOMLEFT', -16, -16)

	local reverseSort = self:CreateReverseSortCheckbox()
	reverseSort:SetPoint('TOPLEFT', sortOrderDropdown, 'BOTTOMLEFT', 16, -SPACING)

	-- Set scroll child height to fit all content
	scrollChild:SetHeight(560)
end

function GeneralOptions:UpdateWidgets()
	if not self:IsVisible() then
		return
	end

	self:GetEnableFrameCheckbox('inventory'):UpdateChecked()
	self:GetEnableFrameCheckbox('bank'):UpdateChecked()
	self:GetEnableFrameCheckbox('keyring'):UpdateChecked()

	self:GetEmptyItemSlotTextureCheckbox():UpdateChecked()
	self:GetHighlightItemsByQualityCheckbox():UpdateChecked()
	self:GetHighlightQuestItemsCheckbox():UpdateChecked()
	self:GetColorItemSlotsCheckbox():UpdateChecked()
	self:GetBlizzardBagPassThroughCheckbox():UpdateChecked()
end


--[[ Checkboxes ]]--

function GeneralOptions:CreateEnableFrameCheckbox(frameID)
	local button = Bagnon.OptionsCheckButton:New(L['EnableFrame_' .. frameID], self:GetScrollChild())
	button.frameID = frameID

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetEnableFrame(self.frameID, enable)
		GeneralOptions:DisplayRequiresRestartPopup()
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:WillFrameBeEnabled(self.frameID)
	end

	self['enableFrame_' .. frameID .. '_Checkbox'] = button
	return button
end

function GeneralOptions:GetEnableFrameCheckbox(frameID)
	return self['enableFrame_' .. frameID .. '_Checkbox']
end

function GeneralOptions:DisplayRequiresRestartPopup()
	self:CreateRequiresRestartDialog()
	StaticPopup_Show('BAGNON_CONFIRM_REQUIRES_RESTART')
end

function GeneralOptions:CreateRequiresRestartDialog()
	if not StaticPopupDialogs['BAGNON_CONFIRM_REQUIRES_RESTART'] then
		StaticPopupDialogs['BAGNON_CONFIRM_REQUIRES_RESTART'] = {
			text = L.SettingRequiresRestart,
			button1 = OKAY,
			timeout = 0, exclusive = 1, hideOnEscape = 1
		}
	end
end

--show empty item slot textures
function GeneralOptions:CreateEmptyItemSlotTextureCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ShowEmptyItemSlotBackground, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetShowEmptyItemSlotTexture(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:ShowingEmptyItemSlotTextures()
	end

	self.showEmptyItemsTextureCheckbox = button
	return button
end

function GeneralOptions:GetEmptyItemSlotTextureCheckbox()
	return self.showEmptyItemsTextureCheckbox
end


--lock frame positions
function GeneralOptions:CreateLockFramePositionsCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.LockFramePositions, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetLockFramePositions(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:AreFramePositionsLocked()
	end

	self.lockFramePositionsCheckbox = button
	return button
end

function GeneralOptions:GetLockFramePositionsCheckbox()
	return self.lockFramePositionsCheckbox
end


--blizzard bag passthrough
function GeneralOptions:CreateBlizzardBagPassThroughCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.EnableBlizzardBagPassThrough, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetEnableBlizzardBagPassThrough(enable)
		GeneralOptions:DisplayRequiresRestartPopup()
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:WillBlizzardBagPassThroughBeEnabled()
	end

	self.blizzardBagPassThroughCheckbox = button
	return button
end

function GeneralOptions:GetBlizzardBagPassThroughCheckbox()
	return self.blizzardBagPassThroughCheckbox
end 


--sort ignore slots slider
function GeneralOptions:CreateSortIgnoreSlotsSlider()
	local slider = Bagnon.OptionsSlider:New(L.SortIgnoreSlots, self:GetScrollChild(), 0, 20, 1)

	slider.SetSavedValue = function(self, value)
		Bagnon.Settings:SetSortIgnoreSlotsCount(value)
	end

	slider.GetSavedValue = function(self)
		return Bagnon.Settings:GetSortIgnoreSlotsCount()
	end

	self.sortIgnoreSlotsSlider = slider
	return slider
end

function GeneralOptions:GetSortIgnoreSlotsSlider()
	return self.sortIgnoreSlotsSlider
end


--sort ignore slots at bottom checkbox
function GeneralOptions:CreateSortIgnoreSlotsAtBottomCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.SortIgnoreSlotsAtBottom, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetSortIgnoreSlotsAtBottom(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:IsSortIgnoreSlotsAtBottom()
	end

	self.sortIgnoreSlotsAtBottomCheckbox = button
	return button
end

function GeneralOptions:GetSortIgnoreSlotsAtBottomCheckbox()
	return self.sortIgnoreSlotsAtBottomCheckbox
end


--show slot count checkbox
function GeneralOptions:CreateShowSlotCountCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ShowSlotCount, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetShowSlotCount(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:IsShowingSlotCount()
	end

	self.showSlotCountCheckbox = button
	return button
end

function GeneralOptions:GetShowSlotCountCheckbox()
	return self.showSlotCountCheckbox
end


--show item level checkbox
function GeneralOptions:CreateShowItemLevelCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ShowItemLevel, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetShowItemLevel(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:IsShowingItemLevel()
	end

	self.showItemLevelCheckbox = button
	return button
end

function GeneralOptions:GetShowItemLevelCheckbox()
	return self.showItemLevelCheckbox
end


--show new item glow checkbox
function GeneralOptions:CreateShowNewItemGlowCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ShowNewItemGlow, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetShowNewItemGlow(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:IsShowingNewItemGlow()
	end

	self.showNewItemGlowCheckbox = button
	return button
end

function GeneralOptions:GetShowNewItemGlowCheckbox()
	return self.showNewItemGlowCheckbox
end


--sort order dropdown
function GeneralOptions:CreateSortOrderDropdown()
	local dropdown = Bagnon.OptionsDropdown:New(L.SortOrder, self:GetScrollChild(), 120)

	dropdown.Initialize = function(self)
		self:AddItem(L.SortOrder_default, 'default')
		self:AddItem(L.SortOrder_quality, 'quality')
		self:AddItem(L.SortOrder_name, 'name')
		self:AddItem(L.SortOrder_level, 'level')
	end

	dropdown.SetSavedValue = function(self, value)
		Bagnon.Settings:SetSortOrder(value)
	end

	dropdown.GetSavedValue = function(self)
		return Bagnon.Settings:GetSortOrder()
	end

	self.sortOrderDropdown = dropdown
	return dropdown
end

function GeneralOptions:GetSortOrderDropdown()
	return self.sortOrderDropdown
end


--reverse sort checkbox
function GeneralOptions:CreateReverseSortCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ReverseSort, self:GetScrollChild())

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetReverseSort(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:IsReverseSorting()
	end

	self.reverseSortCheckbox = button
	return button
end

function GeneralOptions:GetReverseSortCheckbox()
	return self.reverseSortCheckbox
end


--[[ Load the thing ]]--

GeneralOptions:Load()