--[[
	titleFrame.lua
		A title frame widget
--]]


local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')

local TitleFrame = Bagnon.Classy:New('Button')
TitleFrame:Hide()
Bagnon.TitleFrame = TitleFrame


--[[ Constructor ]]--

function TitleFrame:New(frameID, parent)
	local b = self:Bind(CreateFrame('Button', nil, parent))
	b:SetToplevel(true)

	b:SetNormalFontObject('GameFontNormalLeft')
	b:SetHighlightFontObject('GameFontHighlightLeft')
	b:RegisterForClicks('anyUp')

	local slotCountFrame = CreateFrame('Frame', nil, b)
	slotCountFrame:SetAllPoints(b)
	slotCountFrame:SetFrameLevel(b:GetFrameLevel() + 1)
	local slotCount = slotCountFrame:CreateFontString(nil, 'OVERLAY')
	slotCount:SetFont(GameFontNormalSmall:GetFont())
	slotCount:SetPoint('RIGHT', b, 'RIGHT', 0, 0)
	slotCount:SetJustifyH('RIGHT')
	slotCount:SetTextColor(1, 1, 1)
	b.slotCount = slotCount

	b:SetScript('OnShow', b.OnShow)
	b:SetScript('OnHide', b.OnHide)
	b:SetScript('OnEvent', b.OnEvent)
	b:SetScript('OnMouseDown', b.OnMouseDown)
	b:SetScript('OnMouseUp', b.OnMouseUp)
	b:SetScript('OnDoubleClick', b.OnDoubleClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetScript('OnClick', b.OnClick)

	b:SetFrameID(frameID)
	b:UpdateEvents()

	return b
end


--[[ Messages ]]--

function TitleFrame:PLAYER_UPDATE(msg, frameID, player)
	if frameID == self:GetFrameID() then
		self:UpdateText()
		self:UpdateSlotCount()
	end
end

function TitleFrame:SLOT_COUNT_UPDATE()
	self:UpdateSlotCount()
end


--[[ Frame Events ]]--

function TitleFrame:OnEvent(event, ...)
	if event == 'BAG_UPDATE' then
		self:UpdateSlotCount()
	end
end

function TitleFrame:OnShow()
	self:UpdateText()
	self:UpdateSlotCount()
	self:UpdateEvents()
end

function TitleFrame:OnHide()
	self:StopMovingFrame()
	self:UnregisterAllEvents()
end

function TitleFrame:OnMouseDown()
	if self:IsFrameMovable() or IsAltKeyDown() then
		self:StartMovingFrame()
	end
end

function TitleFrame:OnMouseUp()
	self:StopMovingFrame()
end

function TitleFrame:OnDoubleClick()
	self:ToggleSearchFrame()
end

function TitleFrame:OnClick(button)
	if button == 'RightButton' then
		if LoadAddOn('Bagnon_Config') then
			Bagnon.FrameOptions:ShowFrame(self:GetFrameID())
		end
	end
end

function TitleFrame:OnEnter()
	if self:GetRight() > (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end
	self:UpdateTooltip()
end

function TitleFrame:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function TitleFrame:UpdateText()
	self:SetFormattedText(self:GetTitleText(), self:GetPlayer())
	self:GetFontString():SetAllPoints(self)
end

function TitleFrame:UpdateSlotCount()
	if not Bagnon.Settings or not Bagnon.Settings:IsShowingSlotCount() then
		self.slotCount:SetText('')
		return
	end

	local settings = self:GetSettings()
	if not settings then
		self.slotCount:SetText('')
		return
	end

	local player = settings:GetPlayerFilter()
	local totalSlots, usedSlots = 0, 0

	for _, bag in settings:GetVisibleBagSlots() do
		local size = Bagnon.BagSlotInfo:GetSize(player, bag)
		totalSlots = totalSlots + size
		if not Bagnon.BagSlotInfo:IsCached(player, bag) then
			for slot = 1, size do
				if GetContainerItemLink(bag, slot) then
					usedSlots = usedSlots + 1
				end
			end
		end
	end

	local freeSlots = totalSlots - usedSlots
	self.slotCount:SetFormattedText('%d/%d', freeSlots, totalSlots)
end

function TitleFrame:UpdateTooltip()
	GameTooltip:SetText(L.TipDoubleClickSearch)
	GameTooltip:Show()
end

function TitleFrame:UpdateEvents()
	self:UnregisterAllMessages()
	self:UnregisterAllEvents()

	if self:IsVisible() then
		self:RegisterMessage('PLAYER_UPDATE')
		self:RegisterMessage('SLOT_COUNT_UPDATE')
		if not Bagnon.PlayerInfo:IsCached(self:GetPlayer()) then
			self:RegisterEvent('BAG_UPDATE')
		end
	end
end

function TitleFrame:StartMovingFrame()
	self:SendMessage('FRAME_MOVE_START', self:GetFrameID())
end

function TitleFrame:StopMovingFrame()
	self:SendMessage('FRAME_MOVE_STOP', self:GetFrameID())
end


--[[ Properties ]]--

function TitleFrame:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateText()
	end
end

function TitleFrame:GetFrameID()
	return self.frameID
end

--yeah, still hardcoded
function TitleFrame:GetTitleText()
	if self:GetFrameID() == 'bank' then
		return L.TitleBank
	end

	if self:GetFrameID() == 'keys' then
		return L.TitleKeys
	end
	
	if self:GetFrameID() == 'guildbank' then
		return [[%s's Guild Bank]]
	end

	return L.TitleBags
end


--[[ Frame Settings ]]--

function TitleFrame:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end

function TitleFrame:GetPlayer()
	return self:GetSettings():GetPlayerFilter()
end

function TitleFrame:IsFrameMovable()
	return self:GetSettings():IsMovable()
end

function TitleFrame:ToggleSearchFrame()
	self:GetSettings():ToggleTextSearch()
end