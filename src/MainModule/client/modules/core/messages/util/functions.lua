-- Author: @Jumpathy
-- Name: functions.lua
-- Descriptions: Function serving for messages

return function(environment)
	local players = game:GetService("Players")

	local rich = environment.richText
	local systemPrefixColor = environment.config.UI.Colors.SystemPrefixColor

	local localPlayer = players.LocalPlayer

	local functions = {}

	functions.getTags = function(data)
		local tagsList = data.tags or {}
		if(data.isWhisper) then
			data.tags = {}
			tagsList = data.tags
			local sender = data.player
			local from = players:GetPlayerByUserId(sender==localPlayer and data.to_user or data.to_user)
			local opposite = players:GetPlayerByUserId(data.ids[1]==localPlayer.UserId and data.ids[2] or data.ids[1])
			if(from ~= nil) then
				local prefix = environment.localization:getMessagePrefix(sender == localPlayer and "To" or "From")
				table.insert(tagsList,1,{
					text = ("%s %s"):format(prefix,opposite:GetAttribute("DisplayName")),
					color = systemPrefixColor
				})
			end
		elseif(data.isTeam) then
			table.insert(tagsList,1,{
				text = environment.localization:getMessagePrefix("Team"),
				color = systemPrefixColor
			})
		end
		local tags = ""
		for _,tag in pairs(tagsList) do
			local tag = rich:colorize(("[TEXTHERE]"):format(tag.text),tag.color):gsub("TEXTHERE",rich:markdown(tag.text))
			tags = tags .. tag .. " "
		end
		return tags
	end

	function functions:getUserThumbnail(userId)
		return("rbxthumb://type=AvatarHeadShot&id=%s&w=150&h=150"):format(userId)
	end

	function functions.createCollector(object,onEnd)
		local collector = {signals = {}}

		function collector:add(signal)
			if (collector) then
				table.insert(collector.signals,signal)
			end
		end

		local changed;
		changed = object.Changed:Connect(function()
			if(object:GetFullName() == object.Name) then
				changed:Disconnect()
				for _,signal in pairs(collector.signals) do
					signal:Disconnect()
				end
				collector.signals = nil
				collector = nil
				pcall(onEnd or function() end)
			end
		end)

		return collector
	end

	function functions:initReply(data)
		environment:setChannel(environment:generateReplyCode(data.id),true)
	end

	function functions:initWhisper(player)
		if(player and environment.config.Messages.Private.WhispersEnabled) then
			environment:whisper(player)
		end
	end

	return functions
end