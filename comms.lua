local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLSClient", true)
local AceGUI = LibStub("AceGUI-3.0")

-- get information from CheeseSLS

function CheeseSLSClient:OnCommReceived(prefix, message, distribution, sender)
	-- addon disabled? don't do anything
	if not self.db.profile.enabled then
	  return
	end

	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)

	-- don't react to own messages
-- for now: DO. I may want to roll on items as well! maybe make this configurable?
--	if sender == UnitName("player") then
--		return 0
--	end

	local success, deserialized = self:Deserialize(message);


	-- every thing else get handled if (if not disabled)
	if not success then
		self:Debug("ERROR: " .. distribution .. " message from " .. sender .. ": cannot be deserialized")
		return
	end

	-- start of bidding
	if deserialized["command"] == "BIDDING_START" then

		local itemLink = deserialized["itemLink"]
		local _, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", itemLink)
		local acceptRolls = (deserialized["acceptrolls"])
		local acceptWhisper = false

		if (deserialized["acceptwhisper"]) then acceptWhisper = sender end

		if not self.db.profile.ignorelist[tonumber(itemId)] then
			self.bidFrame = self:createBidFrame(itemLink, acceptRolls, acceptWhisper)
			if self.bidFrame then self.bidFrame:Show() end
		end

		if self.db.profile.alertlist[tonumber(itemId)] then
			-- ready check sound (see https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/SharedXML/SoundKitConstants.lua)
			PlaySound(8960, "master")
			UIFrameFlash(UIParent, 0.1, 0.1, 1, true, 0, 0)
		end

	end

	-- somebody rolled? Then show roll icon
	if (deserialized["command"] == "GOT_ROLL") and (self.bidFrameIconRoll) then
		self.bidFrameIconRoll:SetDisabled(false)
	end

	-- somebody bid fix? Then show fix icon
	if (deserialized["command"] == "GOT_FIX") and (self.bidFrameIconFix) then
		self.bidFrameIconFix:SetDisabled(false)
	end

	-- somebody bid full? Then show full icon
	if (deserialized["command"] == "GOT_FULL") and (self.bidFrameIconFull) then
		self.bidFrameIconFull:SetDisabled(false)
	end

	-- end of bidding
	if deserialized["command"] == "BIDDING_STOP" then
		if self.bidFrame then self.bidFrame:Hide() end
	end

end
