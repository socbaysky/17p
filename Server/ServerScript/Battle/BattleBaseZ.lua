Require("ServerScript/Battle/BattleBase.lua")
if not MODULE_ZONESERVER then
	return
end

local tbBase = Battle:GetClass("BattleServerBase", "BattleComBase")

function tbBase:CloseBattle()
	local fnKick = function (pPlayer)
		pPlayer.ZoneLogout()
	end
	self:ForEachInMap(fnKick)

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end
end


