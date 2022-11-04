local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLSClient", true)
local AceGUI = LibStub("AceGUI-3.0")

function CheeseSLSClient:createBidFrame(itemLink, acceptRolls, acceptWhispers)
	-- called without link? bail out
	if not itemLink then return end

	local d, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", itemLink)

	local _, _, _, _, _, _, _, _, _, itemTexture, _ =
	GetItemInfo(itemId)

	local f = AceGUI:Create("Window")
	f:SetTitle("SLS bid started")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(350)
	f:SetHeight(165)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- close on escape
	local frameName = "CheeseSLSClient.bidFrameFrame"
	_G[frameName] = f.frame
	tinsert(UISpecialFrames, frameName)


	local lbIcon = AceGUI:Create("Icon")
	lbIcon:SetRelativeWidth(0.25)
	lbIcon:SetImage(itemTexture)
	lbIcon:SetImageSize(35,35)
	lbIcon:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end)
	lbIcon:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide()
	end)
	f:AddChild(lbIcon)

	local lbPrio = AceGUI:Create("InteractiveLabel")
	lbPrio:SetText(itemLink)
	lbPrio:SetRelativeWidth(0.75)
	f:AddChild(lbPrio)

	CheeseSLSClient.db.profile.biddingRoll = false
	CheeseSLSClient.db.profile.biddingFix = false
	CheeseSLSClient.db.profile.biddingFull = false

	local grpRoll = AceGUI:Create("SimpleGroup")
	grpRoll:SetRelativeWidth(0.33)

		local btnRoll = AceGUI:Create("Button")
		CheeseSLSClient.bidFrameBtnRoll = btnRoll
		btnRoll:SetText("/roll")
		btnRoll:SetRelativeWidth(1)
		btnRoll:SetCallback("OnClick", function()
			-- can only use Roll if i haven't rolled, and have not bid fix or full
			if (not CheeseSLSClient.db.profile.biddingRoll)
			and (not CheeseSLSClient.db.profile.biddingFix)
			and (not CheeseSLSClient.db.profile.biddingFull) then
				RandomRoll(1, 100)
			end
			CheeseSLSClient.db.profile.biddingRoll = true
			CheeseSLSClient.bidFrameBtnRoll:SetDisabled(true)
		end)
		if (not acceptRolls) then btnRoll:SetDisabled(true) end
		grpRoll:AddChild(btnRoll)

		local lbIconRoll = AceGUI:Create("Icon")
		lbIconRoll["SetDisabled"] = function(self, disabled)
			self.disabled = disabled
			if disabled then
					self.frame:Disable()
					self.label:SetTextColor(0, 0, 0)
					self.image:SetVertexColor(0, 0, 0, 0)
			else
					self.frame:Enable()
					self.label:SetTextColor(1, 1, 1)
					self.image:SetVertexColor(1, 1, 1, 1)
			end
		end
		lbIconRoll:SetRelativeWidth(1)
		lbIconRoll:SetImage(237285)
		lbIconRoll:SetImageSize(35,35)
		lbIconRoll:SetDisabled(true)
		grpRoll:AddChild(lbIconRoll)
		CheeseSLSClient.bidFrameIconRoll = lbIconRoll

	f:AddChild(grpRoll)


	local grpFix = AceGUI:Create("SimpleGroup")
	grpFix:SetRelativeWidth(0.33)

		local btnFix = AceGUI:Create("Button")
		CheeseSLSClient.bidFrameBtnFix = btnFix
		btnFix:SetText("fix bid")
		btnFix:SetRelativeWidth(1)
		btnFix:SetCallback("OnClick", function()
			-- can only use Fix if i have not bid fix or full (roll would be ok)
			if (not CheeseSLSClient.db.profile.biddingFix)
			and (not CheeseSLSClient.db.profile.biddingFull) then
				if acceptWhispers then
					SendChatMessage("f", "WHISPER", nil, acceptWhispers)
				else
					SendChatMessage("f", "RAID")
				end
			end
			CheeseSLSClient.db.profile.biddingFix = true
			CheeseSLSClient.bidFrameBtnRoll:SetDisabled(true)
			CheeseSLSClient.bidFrameBtnFix:SetDisabled(true)
		end)
		grpFix:AddChild(btnFix)

		local lbIconFix = AceGUI:Create("Icon")
		lbIconFix["SetDisabled"] = function(self, disabled)
			self.disabled = disabled
			if disabled then
					self.frame:Disable()
					self.label:SetTextColor(0, 0, 0)
					self.image:SetVertexColor(0, 0, 0, 0)
			else
					self.frame:Enable()
					self.label:SetTextColor(1, 1, 1)
					self.image:SetVertexColor(1, 1, 1, 1)
			end
		end
		lbIconFix:SetRelativeWidth(1)
		lbIconFix:SetImage(133786)
		lbIconFix:SetImageSize(35,35)
		lbIconFix:SetDisabled(true)
		grpFix:AddChild(lbIconFix)
		CheeseSLSClient.bidFrameIconFix = lbIconFix

	f:AddChild(grpFix)


	local grpFull = AceGUI:Create("SimpleGroup")
	grpFull:SetRelativeWidth(0.33)

		local btnFull = AceGUI:Create("Button")
		CheeseSLSClient.bidFrameBtnFull = btnFull
		btnFull:SetText("full bid")
		btnFull:SetRelativeWidth(1)
		btnFull:SetCallback("OnClick", function()
			-- can only use Full if i have not bid full (roll or fix would be ok)
			if (not CheeseSLSClient.db.profile.biddingFull) then
				if acceptWhispers then
					SendChatMessage("+", "WHISPER", nil, acceptWhispers)
				else
					SendChatMessage("+", "RAID")
				end
			end
			CheeseSLSClient.db.profile.biddingFull = true
			CheeseSLSClient.bidFrameBtnRoll:SetDisabled(true)
			CheeseSLSClient.bidFrameBtnFix:SetDisabled(true)
			CheeseSLSClient.bidFrameBtnFull:SetDisabled(true)
		end)
		grpFull:AddChild(btnFull)

		local lbIconFull = AceGUI:Create("Icon")
		lbIconFull["SetDisabled"] = function(self, disabled)
			self.disabled = disabled
			if disabled then
					self.frame:Disable()
					self.label:SetTextColor(0, 0, 0)
					self.image:SetVertexColor(0, 0, 0, 0)
			else
					self.frame:Enable()
					self.label:SetTextColor(1, 1, 1)
					self.image:SetVertexColor(1, 1, 1, 1)
			end
		end
		lbIconFull:SetRelativeWidth(1)
		lbIconFull:SetImage(133785)
		lbIconFull:SetImageSize(35,35)
		lbIconFull:SetDisabled(true)
		grpFull:AddChild(lbIconFull)
		CheeseSLSClient.bidFrameIconFull = lbIconFull

	f:AddChild(grpFull)

	return f
end

