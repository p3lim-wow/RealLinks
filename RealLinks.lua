local queuedMessages = {}

local split = string.split
local gmatch = string.gmatch
local gsub = string.gsub

local function GetLinkColor(data)
	local type, arg1, arg2 = split(':', data)
	if(type == 'item') then
		local _, _, quality = GetItemInfo(arg1)
		if(quality) then
			local _, _, _, color = GetItemQualityColor(quality)
			return '|c' .. color
		else
			return nil, true
		end
	elseif(type == 'quest') then
		local color = GetQuestDifficultyColor(arg2)
		return format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
	elseif(type == 'spell') then
		return '|cff71d5ff'
	elseif(type == 'achievement') then
		return '|cffffff00'
	elseif(type == 'trade' or type == 'enchant') then
		return '|cffffd000'
	elseif(type == 'instancelock') then
		return '|cffff8000'
	elseif(type == 'glyph' or type == 'journal') then
		return '|cff66bbff'
	elseif(type == 'talent') then
		return '|cff4e96f7'
	elseif(type == 'levelup') then
		return '|cffFF4E00'
	end
end

local function MessageFilter(self, event, message, ...)
	for link, data in gmatch(message, '(|H(.-)|h.-|h)') do
		local color, queue = GetLinkColor(data)
		if(queue) then
			table.insert(queuedMessages, {self, event, message, ...})
			return true
		if(color) then
			local matchLink = '|H' .. data .. '|h.-|h'
			message = gsub(message, matchLink, color .. link .. '|r', 1)
		end
	end

	return false, message, ...
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('GET_ITEM_INFO_RECEIVED')
Handler:SetScript('OnEvent', function()
	if(#queuedMessages > 0) then
		for index, data in next, queuedMessages do
			ChatFrame_MessageEventHandler(unpack(data))
			queuedMessages[index] = nil
		end
	end
end)

ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER', MessageFilter)
ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER_INFORM', MessageFilter)
