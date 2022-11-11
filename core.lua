local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLSClient", true)

CheeseSLSClient.commPrefix = "CheeseSLS-1.0-"
CheeseSLSClient.commVersion = 20221103

local defaults = {
	profile = {
		enabled = true,
		debugging = false,
	}
}

CheeseSLSClient.optionsTable = {
	type = "group",
	args = {
		enabled = {
			name = "Enabled",
			desc = "Enabled",
			type = "toggle",
			set = function(info,val)
				CheeseSLSClient.db.profile.enabled = val
			end,
			get = function(info) return CheeseSLSClient.db.profile.enabled end,
		},
		debugging = {
			name = "Debug",
			desc = "Debug",
			type = "toggle",
			set = function(info,val)
				CheeseSLSClient.db.profile.debugging = val
			end,
			get = function(info) return CheeseSLSClient.db.profile.debugging end,
		},
	} -- args
}

function CheeseSLSClient:OnInitialize()
	-- Code that you want to run when the addon is first loaded goes here.
	self.db = LibStub("AceDB-3.0"):New("CheeseSLSClientDB", defaults)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("CheeseSLSClient", self.optionsTable)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CheeseSLSClient", "CheeseSLSClient")

	if not CheeseSLSClient.db.profile.alertlist then CheeseSLSClient.db.profile.alertlist = {} end
	if not CheeseSLSClient.db.profile.ignorelist then CheeseSLSClient.db.profile.ignorelist = {} end
end

function CheeseSLSClient:OnEnable()
	-- Called when the addon is enabled
	self:RegisterChatCommand("cslsclient", "ChatCommand")
	self:RegisterChatCommand("slsclient", "ChatCommand");

	self:RegisterComm(CheeseSLSClient.commPrefix, "OnCommReceived")
end

function CheeseSLSClient:OnDisable()
	-- Called when the addon is disabled
end

local function strlt(s)
	return strlower(strtrim(s))
end

function CheeseSLSClient:ChatCommand(inc)
	if strlt(inc) == "debug" then
		CheeseSLSClient.db.profile.debugging = not CheeseSLSClient.db.profile.debugging
		if CheeseSLSClient.db.profile.debugging then
			CheeseSLSClient:Print("CheeseSLSClient DEBUGGING " .. L["is enabled."])
		else
			CheeseSLSClient:Print("CheeseSLSClient DEBUGGING " .. L["is disabled."])
		end

	elseif strlt(inc:sub(0,4)) == "test" then
		local itemLink = "\124cffff8000\124Hitem:199914::::::::80:::::\124h[Glowing Pebble]\124h\124r"

		if #inc > 4 then
			itemLink = inc:sub(5)
		end

		CheeseSLSClient.bidFrame = CheeseSLSClient:createBidFrame(itemLink, true, false)
		if CheeseSLSClient.bidFrame then CheeseSLSClient.bidFrame:Show() end

	else

		if strlt(inc) == "" then
			CheeseSLSClient.db.profile.enabled = not CheeseSLSClient.db.profile.enabled
		end

		if (strlt(inc) == "enable") or (strlt(inc) == "enabled") or (strlt(inc) == "on") then
			CheeseSLSClient.db.profile.enabled = true
		end

		if (strlt(inc) == "disable") or (strlt(inc) == "disabled") or (strlt(inc) == "off") then
			CheeseSLSClient.db.profile.enabled = false
		end

		if CheeseSLSClient.db.profile.enabled then
			CheeseSLSClient:Print("CheeseSLSClient " .. L["is enabled."])
		else
			CheeseSLSClient:Print("CheeseSLSClient " .. L["is disabled."])
		end

	end

end


function CheeseSLSClient:Debug(t)
	if (CheeseSLSClient.db.profile.debugging) then
		CheeseSLSClient:Print("CheeseSLSClient DEBUG: " .. t)
	end
end

