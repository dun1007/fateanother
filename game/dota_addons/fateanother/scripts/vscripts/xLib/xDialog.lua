if xDialog == nil then xDialog = class({}) end

--[[
xDialog:ShowDialog({
			"#dialogSentence1",
			"#dialogSentence1",
			"#dialogSentence1",
			"#dialogSentence1"
		},{
			allowSkip = true;
			npcName = "miku",
			hideActionPanel = true;
		})

]]
function xDialog:ShowDialog(dialogStringTable, dialogOptions)
	xDialog:ShowDialogForPlayer(-1, dialogStringTable, dialogOptions)
end


--[[
* "xgui_show_rpg_dialog"
			 * {
			 * 		"playerID"		"short"
			 * 		"npcName"		"string"
			 * 		"dialogContent"	"string"
			 * 		"dialogID"		"short"
			 * 		"allowEndDialogAnySentence"	"bool"
			 * }
]]
function xDialog:ShowDialogForPlayer(playerID, dialogStringTable, dialogOptions)

	local dialogID = self:GetUniqueDialogID()
	local npcName = dialogOptions.npcName
	local dialogContent = ""
	local hideActionPanel = dialogOptions.hideActionPanel
	local allowEndDialogAnySentence = dialogOptions.allowSkip
	local callback = dialogOptions.endDialogCallback
	local dialogStrinIndex = 0
	
	for _,dialogString in pairs(dialogStringTable) do
		dialogStrinIndex = dialogStrinIndex + 1
		dialogContent = dialogContent..dialogString
		if dialogStrinIndex < #dialogStringTable then
			dialogContent = dialogContent.."|"
		end
	end

	Convars:RegisterCommand("xgui_player_end_rpg_dialog"..dialogID, function(_, playerID)
		print("a player end rpg dialog")
		if callback then
			callback(playerID)
		end
	end, "a player end dialog", 0)

	FireGameEvent("xgui_show_rpg_dialog",{
		playerID = playerID,
		npcName = npcName,
		dialogContent = dialogContent,
		dialogID = dialogID,
		allowEndDialogAnySentence = allowEndDialogAnySentence
	})
end

function xDialog:GetUniqueDialogID()
	if self.__dialogID == nil then
		self.__dialogID = 0
	end
	self.__dialogID = self.__dialogID + 1
	return self.__dialogID
end