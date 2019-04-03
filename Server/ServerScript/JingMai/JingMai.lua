-- 为所有经脉检测升级
function JingMai:TryDoJingMaiLevelUp(pPlayer, nJingMaiId)
	local nNowTime = GetTime()
	local tbXueWeiLearnedInfo, _, tbJingMaiLevelInfo = self:GetLearnedXueWeiInfo(pPlayer, nil, true);
	local tbLevelAttrib = self:GetXueWeiLevelAttrib(tbXueWeiLearnedInfo)
	local tbJingMaiLevelData = tbJingMaiLevelInfo[nJingMaiId] or {}
	local nNowLevelIndex = tbJingMaiLevelData.nLevelIndex or 0
	local nRequestTime = tbJingMaiLevelData.nRequestLevelTime or 0
	if nRequestTime ~= 0 and nNowTime >= nRequestTime + self.nJingMaiLevelUpTime then
		local nNextLevelIndex = nNowLevelIndex + 1
		if tbLevelAttrib[nJingMaiId] and tbLevelAttrib[nJingMaiId][nNextLevelIndex] then
			JingMai:SetJingMaiLevelData(pPlayer, nJingMaiId, nNowLevelIndex + 1, 0)
			self:UpdatePlayerAttrib(pPlayer);
			pPlayer.CenterMsg(string.format("%s成功升级到第%s重", JingMai:GetJingMaiLevelName(nJingMaiId), nNextLevelIndex), true)
			pPlayer.CallClientScript("JingMai:OnJingMaiLevelUp", nJingMaiId)
			Log("[JingMai] fnTryDoJingMaiLevelUp ok", pPlayer.dwID, pPlayer.szName, nJingMaiId, nNextLevelIndex, Lib:TimeDesc9(nRequestTime))
		else
			Log("[JingMai] fnTryDoJingMaiLevelUp err", pPlayer.dwID, pPlayer.szName, nJingMaiId, nNowLevelIndex, nRequestTime)
		end
	else
		pPlayer.CenterMsg("时间未到", true)
	end
end

-- 请求升级
function JingMai:RequestJingMaiLevelUp(pPlayer, nJingMaiId)
	local bRet, szMsg, nNowLevelIndex, tbCost, szLevelName = self:CheckJingMaiLevelUp(pPlayer, nJingMaiId)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	if tbCost then
		for _, tbInfo in ipairs(tbCost) do
			local nType = Player.AwardType[tbInfo[1]];
			if nType == Player.award_type_item then
				local nCount = pPlayer.ConsumeItemInBag(tbInfo[2], tbInfo[3], Env.LogWay_JingMaiLevelUp);
				if nCount < tbInfo[3] then
					pPlayer.CenterMsg("扣除道具失败！", true);
					Log("[JingMai] fnRequestJingMaiLevelUp ConsumeItemInBag Fail !!!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel, tbInfo[2], tbInfo[3], nCount);
					return;
				end
			elseif nType == Player.award_type_money then
				local bResult = pPlayer.CostMoney(tbInfo[1], tbInfo[2], Env.LogWay_JingMaiLevelUp);
				if not bResult then
					pPlayer.CenterMsg("扣除货币失败！", true);
					Log("[JingMai] fnRequestJingMaiLevelUp CostMoney Fail !!!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel, tbInfo[1], tbInfo[2]);
					return;
				end
			end
		end
	end
	local nNowTime = GetTime()
	JingMai:SetJingMaiLevelData(pPlayer, nJingMaiId, nil, nNowTime)
	pPlayer.CenterMsg(string.format("%s将在%s运转完毕", szLevelName or "经脉", Lib:TimeDesc9(nNowTime + self.nJingMaiLevelUpTime)), true)
	pPlayer.CallClientScript("JingMai:OnRequestJingMaiLevelUp", nJingMaiId)
	Log("[JingMai] fnRequestJingMaiLevelUp ok", pPlayer.dwID, pPlayer.szName, nJingMaiId, nNowLevelIndex)
end

function JingMai:OnLogin(pPlayer)
	pPlayer.CallClientScript("JingMai:OnSyncOpenInfo", self.tbOpenInfo);
	-- 先检查升级再更新属性
	--Lib:CallBack({self.TryDoJingMaiLevelUp, self, pPlayer})
	self:UpdatePlayerAttrib(pPlayer);
end

function JingMai:OnClientCall(szFun, ...)
	if self[szFun] then
		self[szFun](self, ...)
	else
		Log("[JingMai] fnOnClientCall fail", szFun)
	end
end