local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLSClient", true)
local AceGUI = LibStub("AceGUI-3.0")

-- get information from CheeseSLS

function CheeseSLSClient:OnCommReceived(prefix, message, distribution, sender)
	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	-- don't react to own messages
-- for now: DO. I may want to roll on items as well! maybe make this configurable?
--	if sender == UnitName("player") then
--		return 0
--	end

	local success, deserialized = CheeseSLSClient:Deserialize(message);


	-- every thing else get handled if (if not disabled)
	if not success then
		CheeseSLSClient:Debug("ERROR: " .. distribution .. " message from " .. sender .. ": cannot be deserialized")
		return
	end

	-- start of bidding
	if deserialized["command"] == "BIDDING_START" then

		local itemLink = deserialized["itemLink"]
		local _, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", itemLink)
		local acceptRolls = (deserialized["acceptrolls"])
		local acceptWhisper = false

		if (deserialized["acceptwhisper"]) then acceptWhisper = sender end

		if CheeseSLSClient.db.profile.notificationHandling[tonumber(itemId)] ~= "IGNORE" then
			CheeseSLSClient.bidFrame = CheeseSLSClient:createBidFrame(itemLink, acceptRolls, acceptWhisper)
			if CheeseSLSClient.bidFrame then CheeseSLSClient.bidFrame:Show() end
		end

		if CheeseSLSClient.db.profile.notificationHandling[tonumber(itemId)] == "ALERT" then
			-- ready check sound (see https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/SharedXML/SoundKitConstants.lua)
			PlaySound(8960, "master")
			UIFrameFlash(UIParent, 0.1, 0.1, 1, true, 0, 0)
		end

	end

	-- somebody rolled? Then show roll icon
	if (deserialized["command"] == "GOT_ROLL") and (CheeseSLSClient.bidFrameIconRoll) then
		CheeseSLSClient.bidFrameIconRoll:SetDisabled(false)
	end

	-- somebody bid fix? Then show fix icon
	if (deserialized["command"] == "GOT_FIX") and (CheeseSLSClient.bidFrameIconFix) then
		CheeseSLSClient.bidFrameIconFix:SetDisabled(false)
	end

	-- somebody bid full? Then show full icon
	if (deserialized["command"] == "GOT_FULL") and (CheeseSLSClient.bidFrameIconFull) then
		CheeseSLSClient.bidFrameIconFull:SetDisabled(false)
	end

	-- end of bidding
	if deserialized["command"] == "BIDDING_STOP" then
		if CheeseSLSClient.bidFrame then CheeseSLSClient.bidFrame:Hide() end
	end

end
