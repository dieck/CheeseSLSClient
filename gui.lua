local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLSClient", true)
local AceGUI = LibStub("AceGUI-3.0")

function CheeseSLSClient:createBidFrame(itemLink, acceptRolls, acceptWhispers)
	-- called without link? bail out
	if not itemLink then return end

	-- secret Drungk-Everlook mode ;)
	local isDrungk = (UnitName("player") == "Drungk" and GetRealmName() == "Everlook")

	local _, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", itemLink)
	if (not itemId) or (tostring(itemId) ~= tostring(tonumber(itemId))) then return end -- obviously something wrong with the link
	local _, _, _, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(itemId)

	local f = AceGUI:Create("Window")
	f:SetTitle(L["SLS bid started"])
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(350)
	local windowheight = 165
	if isDrungk then windowheight = windowheight + 75 end
	f:SetHeight(windowheight)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	f:SetUserData("itemLink", itemLink)

	-- close on escape
	local frameName = "CheeseSLSClientBidFrameFrame"
	_G[frameName] = f.frame
	tinsert(UISpecialFrames, frameName)

	local lbIcon = AceGUI:Create("Icon")
	self.bidFrameLbIcon = lbIcon
	lbIcon:SetRelativeWidth(0.25)
	lbIcon:SetImage(itemTexture)
	lbIcon:SetImageSize(35,35)
	lbIcon:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(widget.parent:GetUserData("itemLink"))
		GameTooltip:Show()
	end)
	lbIcon:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide()
	end)
	-- if pawn is installed, open compare if you click on the icon
	if (PawnCommand) then
		lbIcon:SetCallback("OnClick", function(widget)
			PawnCommand("compare " .. widget.parent:GetUserData("itemLink"))
		end)
	end
	f:AddChild(lbIcon)

	if (not itemTexture) then
		-- see if it turns up later (code needs to be AFTER bidFrameLbIcon exists ;))
		self.waitForItemInfoReceived = itemId
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	end

	local lbPrio = AceGUI:Create("InteractiveLabel")
	lbPrio:SetText(itemLink)
	lbPrio:SetRelativeWidth(0.75)
	lbPrio:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(widget.parent:GetUserData("itemLink"))
		GameTooltip:Show()
	end)
	lbPrio:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide()
	end)
	f:AddChild(lbPrio)

	self.db.profile.biddingRoll = false
	self.db.profile.biddingFix = false
	self.db.profile.biddingFull = false

	local grpRoll = AceGUI:Create("SimpleGroup")
	grpRoll:SetRelativeWidth(0.33)

		local btnRoll = AceGUI:Create("Button")
		f.bidFrameBtnRoll = btnRoll
		btnRoll:SetText(L["/roll"])
		btnRoll:SetRelativeWidth(1)
		btnRoll:SetCallback("OnClick", function(widget)
			-- can only use Roll if i haven't rolled, and have not bid fix or full
			if (not CheeseSLSClient.db.profile.biddingRoll)
			and (not CheeseSLSClient.db.profile.biddingFix)
			and (not CheeseSLSClient.db.profile.biddingFull) then
				RandomRoll(1, 100)
			end
			CheeseSLSClient.db.profile.biddingRoll = true
			widget.parent.bidFrameBtnRoll:SetDisabled(true)
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
		self.bidFrameIconRoll = lbIconRoll

	f:AddChild(grpRoll)


	local grpFix = AceGUI:Create("SimpleGroup")
	grpFix:SetRelativeWidth(0.33)

		local btnFix = AceGUI:Create("Button")
		f.bidFrameBtnFix = btnFix
		btnFix:SetText(L["fix bid"])
		btnFix:SetRelativeWidth(1)
		btnFix:SetCallback("OnClick", function(widget)
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
			widget.parent.bidFrameBtnRoll:SetDisabled(true)
			widget.parent.bidFrameBtnFix:SetDisabled(true)
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
		self.bidFrameIconFix = lbIconFix

	f:AddChild(grpFix)


	local grpFull = AceGUI:Create("SimpleGroup")
	grpFull:SetRelativeWidth(0.33)

		local btnFull = AceGUI:Create("Button")
		f.bidFrameBtnFull = btnFull
		btnFull:SetText(L["full bid"])
		btnFull:SetRelativeWidth(1)
		btnFull:SetCallback("OnClick", function(widget)
			-- can only use Full if i have not bid full (roll or fix would be ok)
			if (not CheeseSLSClient.db.profile.biddingFull) then
				if acceptWhispers then
					SendChatMessage("+", "WHISPER", nil, acceptWhispers)
				else
					SendChatMessage("+", "RAID")
				end
			end
			CheeseSLSClient.db.profile.biddingFull = true
			widget.parent.bidFrameBtnRoll:SetDisabled(true)
			widget.parent.bidFrameBtnFix:SetDisabled(true)
			widget.parent.bidFrameBtnFull:SetDisabled(true)
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
		self.bidFrameIconFull = lbIconFull

	f:AddChild(grpFull)

	if isDrungk then
		local btnDrungk = AceGUI:Create("Button")
		btnDrungk:SetText("DRUNGK PASST")
		btnDrungk:SetRelativeWidth(1)
		btnDrungk:SetHeight(75)
		btnDrungk:SetCallback("OnClick",function(widget) widget.parent:Hide() end)
		f:AddChild(btnDrungk)
	end

	return f
end

-- asynch handling of cached item infos
function CheeseSLSClient:GET_ITEM_INFO_RECEIVED(event, itemID, success)

	-- wait for the item we are waiting for (others might come in through other requests)
	if tonumber(itemID) ~= tonumber(self.waitForItemInfoReceived) then return end

	-- see if item texture is now available
	local _, _, _, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(tonumber(itemID))

	-- if not, keep waiting, might turn up later
	if not itemTexture then return end

	-- ok, we found it!
	-- stop looking
	self.waitForItemInfoReceived = nil
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")

	-- set as icon
	if self.bidFrameLbIcon then self.bidFrameLbIcon:SetImage(itemTexture) end
end
