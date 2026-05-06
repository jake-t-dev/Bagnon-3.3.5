--[[
	player.lua
		Generic methods for accessing player information
--]]


--[[ Player Info ]]--

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local PlayerInfo = {}
Bagnon.PlayerInfo = PlayerInfo

local CURRENT_PLAYER = UnitName('player')

-- Update current player name on login/character swap
local playerInfoFrame = CreateFrame('Frame')
playerInfoFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
playerInfoFrame:SetScript('OnEvent', function()
	CURRENT_PLAYER = UnitName('player')
end)

function PlayerInfo:IsCached(player)
	return player ~= CURRENT_PLAYER
end

function PlayerInfo:GetMoney(player)
	local money = 0
	if self:IsCached(player) then
		if BagnonDB then
			money = BagnonDB:GetMoney(player)
		end
	else
		money = GetMoney()
	end
	return money
end

function PlayerInfo:AtBank()
	return Bagnon.BagEvents:AtBank()
end