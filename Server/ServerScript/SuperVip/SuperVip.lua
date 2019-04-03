SuperVip.nCheckInterval = 5*3600
function SuperVip:Check(pPlayer)
    if not version_tx then return end
    
    local nPlayerId = pPlayer.dwID
    self.tbResults = self.tbResults or {}
    if self.tbResults[nPlayerId] then
    	local bSuperVip, nLastUpdate = unpack(self.tbResults[nPlayerId])
    	if (GetTime()-nLastUpdate) < self.nCheckInterval then
   			pPlayer.CallClientScript("PlayerEvent:SetSuperVip", bSuperVip)
    		return
    	end
    end

    AssistClient:UpdateSuperVipInfo(pPlayer)
end

function SuperVip:OnQueryResult(pPlayer, bSuperVip)
	local nPlayerId = pPlayer.dwID
	self.tbResults = self.tbResults or {}
	self.tbResults[nPlayerId] = {bSuperVip, GetTime()}
	pPlayer.CallClientScript("PlayerEvent:SetSuperVip", bSuperVip)
end
