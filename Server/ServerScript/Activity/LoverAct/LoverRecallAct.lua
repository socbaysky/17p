local tbAct = Activity:GetClass("LoverRecallAct")
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}
function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then

	elseif szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_SendUseMapAward", "OnSendUseMapAward")
		Activity:RegisterPlayerEvent(self, "Act_SendAssistAward", "OnSendAssistAward")
		Activity:RegisterPlayerEvent(self, "Act_ComposeLoverRecallMap", "OnComposeLoverRecallMap")
		Activity:RegisterPlayerEvent(self, "Act_EverydayTargetGainAward", "OnEverydayTargetGainAward")
		Activity:RegisterPlayerEvent(self, "Act_UseLoverRecallMap", "OnUseLoverRecallMap")
		Activity:RegisterPlayerEvent(self, "Act_AssistOk", "OnAssistOk")
		local _, nEndTime = self:GetOpenTimeInfo()
		-- 注册申请存库数据块,活动结束自动清掉
        self:RegisterDataInPlayer(nEndTime)
        self:FormatAward()
        self:InitMapInfo()
	elseif szTrigger == "End" then

	end
	Log("[LoverRecallAct] OnTrigger:", szTrigger)
end

function tbAct:InitMapInfo()
	self.tbAllMap = {}
	for _, v in ipairs(self.tbMapInfo) do
		self.tbAllMap[v.nMapTID] = true
	end
end

function tbAct:FormatAward()
	local _, nEndTime = self:GetOpenTimeInfo()
	for _,tbInfo in pairs(self.tbActiveAward) do
		for _, v in ipairs(tbInfo) do
			if v[1] and (v[1] == "item" or v[1] == "Item") then
				 v[4] = nEndTime
			end
		end
	end
end

local function fnAllMember(tbMember, fnSc, ...)
    for _, nPlayerId in pairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId);
        if pMember then
            fnSc(pMember, ...);
        end
    end
end

function tbAct:OnEverydayTargetGainAward(pPlayer, nAwardIdx)
    local tbAward = self.tbActiveAward[nAwardIdx]
    if not tbAward then
		return 
    end

    if not self:CheckLevel(pPlayer) then
    	return 
    end

   pPlayer.SendAward(tbAward, true, nil, Env.LogWay_LoverRecallAct);
end

function tbAct:OnComposeLoverRecallMap(pPlayer)
	local bRet, szMsg = self:CheckComposeLoverRecallMap(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return
	end

	local nConsume = pPlayer.ConsumeItemInAllPos(self.nClueItemTID, self.nClueCompose, Env.LogWay_LoverRecallAct);
	if nConsume < self.nClueCompose then
		pPlayer.CenterMsg("扣除道具失败", true);
		return
	end

	local _, nEndTime = self:GetOpenTimeInfo()
	local pItem = pPlayer.AddItem(self.nMapItemTID, 1, nEndTime, Env.LogWay_LoverRecallAct);
	if pItem then
		pPlayer.CenterMsg(string.format("恭喜！合成了【%s】", KItem.GetItemShowInfo(self.nMapItemTID, pPlayer.nFaction, pPlayer.nSex) or ""));
	else
		pPlayer.CenterMsg("合成失败,未知错误,请与客服联系!");
		Log("[LoverRecallAct] OnComposeLoverRecallMap fail ", pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel);
	end
	Log("[LoverRecallAct] OnComposeLoverRecallMap ok ", pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel);
end

function tbAct:CheckComposeLoverRecallMap(pPlayer)
    local bRet, szMsg = pPlayer.CheckNeedArrangeBag()
    if bRet then
        return false, szMsg
    end

	local nHave = pPlayer.GetItemCountInAllPos(self.nClueItemTID);
	if nHave < self.nClueCompose then
		return false, string.format("您的线索不够，还需要%d个线索", self.nClueCompose - nHave)
	end

	 if not self:CheckLevel(pPlayer) then
    	return false, string.format("请先提升到%d级", self.nJoinLevel)
    end

	return true
end

-- 使用地图道具
-- function tbAct:OnUseLoverRecallMap(pPlayer, nMapTID)

-- 	local tbOptList = {}
-- 	for nIndex, tbInfo in ipairs(self.tbMapInfo) do
-- 		local tbOpt = {}
-- 		tbOpt.Text = tbInfo.szText
-- 		tbOpt.Callback = self.TryGoLoverRecallMap
-- 		tbOpt.Param = {self, pPlayer.dwID, tbInfo.nMapTID}
-- 		table.insert(tbOptList, tbOpt)
-- 	end

-- 	Dialog:Show(
-- 	{
-- 		Text = "您想了解哪对情缘？",
-- 		OptList = tbOptList,
-- 	}, pPlayer);
-- end

function tbAct:OnUseLoverRecallMap(pPlayer, nMapTID, nItemTID)
    if not pPlayer or not self.tbAllMap[nMapTID] then
        return
    end

	local bRet, szMsg, pAssist = self:CheckGoLoverRecallMap(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return
	end
	
	pAssist.MsgBox(string.format("侠士[FFFE0D]%s[-]想要邀请你前去线索地图的所在地，是否前往？", pPlayer.szName),
			{
				{"确认", function () self:ConfirmUseGoLoverRecallMap(pPlayer.dwID, pAssist.dwID, nMapTID, true, nItemTID) end},
				{"拒绝", function () self:ConfirmUseGoLoverRecallMap(pPlayer.dwID, pAssist.dwID, nMapTID, false, nItemTID) end},
			});
end

function tbAct:CheckGoLoverRecallMap(pUsePlayer, nAssistPlayerId)

	local tbTeam = TeamMgr:GetTeamById(pUsePlayer.dwTeamID);
	if not tbTeam then
		return false, "组成两人队伍才可使用！";
	end

	local tbMember = tbTeam:GetMembers();
	local nTeamCount = Lib:CountTB(tbMember);
	if nTeamCount ~= 2 then
		return false, "组成两人队伍才可使用！";
	end
	local tbSecOK = {}
	local pAssist;
	for nIdx, nPlayerID in pairs(tbMember) do
		local pMember = KPlayer.GetPlayerObjById(nPlayerID);
		if not pMember then
			return false, "对方不线上，无法使用！"
		end
		if not self:CheckLevel(pMember) then
			return false, string.format("%s等级需达到%d级", pMember.szName, self.nJoinLevel)
		end
		if nPlayerID ~= pUsePlayer.dwID then
			pAssist = pMember;
		end
		table.insert(tbSecOK, pMember.nSex)
	end

	if not pAssist then
		return false, "找不到您的队友"
	end

	if tbSecOK[1] == tbSecOK[2] then
        return false, "必须异性组队"
    end

    if not FriendShip:IsFriend(pUsePlayer.dwID, pAssist.dwID) then
    	return false, "你与对方并非好友，请确认後在进行尝试哦"
	end

	-- 当A要B协助，发出请求后退出队伍，与C组队，这时如果B确认会直接将A和C传去地图
	if nAssistPlayerId and nAssistPlayerId ~= pAssist.dwID then
		local pOldAssist = KPlayer.GetPlayerObjById(nAssistPlayerId)
		if pOldAssist then
			pOldAssist.CenterMsg("队伍人员发生变化，请重新再试")
		end
		return false, "队伍人员发生变化，请重新再试"
	end

	if not Map:IsCityMap(pUsePlayer.nMapTemplateId) then
		return false, "只能在城市或新手村才能使用"
	end

	local nImityLevel = FriendShip:GetFriendImityLevel(pUsePlayer.dwID, pAssist.dwID) or 0
	if nImityLevel < self.nUseMapImityLevel then
		return false, string.format("双方亲密度达到%s级才可使用", self.nUseMapImityLevel)
	end

	local nMapId1, nX1, nY1 = pUsePlayer.GetWorldPos()
    local nMapId2, nX2, nY2 = pAssist.GetWorldPos()
    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    if fDists > (self.MIN_DISTANCE * self.MIN_DISTANCE) or nMapId1 ~= nMapId2 then
        return false, "队友不在附近"
    end

    self:CheckAssistData(pAssist)

    local tbAssistSaveData = self:GetDataFromPlayer(pAssist.dwID) or {}
	if tbAssistSaveData.nAssistCount >= self.nMaxAssistCount then
		return false, string.format("队友%s协助次数不足", pAssist.szName)
	end

	return true, "", pAssist, tbMember;
end

function tbAct:ConfirmUseGoLoverRecallMap(nUsePlayerId, nAssistPlayerId, nMapTID, bResult, nItemTID)
	local pUsePlayer = KPlayer.GetPlayerObjById(nUsePlayerId);
	if not pUsePlayer then
		local pOldAssist = KPlayer.GetPlayerObjById(nAssistPlayerId)
		if pOldAssist then
			pOldAssist.CenterMsg("对方已离线")
		end
		return;
	end

	if not bResult then
		pUsePlayer.CenterMsg("对方拒绝了你的邀请");
		return;
	end

	local bRet, szMsg, pAssist, tbMember = self:CheckGoLoverRecallMap(pUsePlayer, nAssistPlayerId);
	if not bRet then
		pUsePlayer.CenterMsg(szMsg); 
		return;
	end

	local nConsume = pUsePlayer.ConsumeItemInAllPos(nItemTID, 1, Env.LogWay_LoverRecallAct);
	if nConsume < 1 then
		pUsePlayer.CenterMsg(string.format("扣除道具%s失败！",KItem.GetItemShowInfo(nItemTID, pUsePlayer.nFaction, pUsePlayer.nSex)));
		 Log("[LoverRecallAct] fnConfirmUseGoLoverRecallMap consume item fail ", pUsePlayer.dwID, pUsePlayer.szName, pAssist.dwID, pAssist.szName, nMapTID, nItemTID)
		return
	end

	local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint();
            pPlayer.SwitchMap(nMapId, 0, 0);
        end
        fnAllMember(tbMember, fnSucess, nMapId);
    end

    local function fnFailedCallback()
    	local function fnMsg(pPlayer, szMsg)
		    pPlayer.CenterMsg(szMsg);
		end
        fnAllMember(tbMember, fnMsg, "创建副本失败，请稍後尝试！");
        Log("[LoverRecallAct] fnConfirmUseGoLoverRecallMap fnFailedCallback ", pUsePlayer.dwID, pUsePlayer.szName, pAssist.dwID, pAssist.szName, nMapTID or -1)
    end

    Fuben:ApplyFuben(nUsePlayerId, nMapTID, fnSuccessCallback, fnFailedCallback, nUsePlayerId, nAssistPlayerId);
    Log("[LoverRecallAct] fnConfirmUseGoLoverRecallMap ok ", pUsePlayer.dwID, pUsePlayer.szName, pAssist.dwID, pAssist.szName, nMapTID)
end

function tbAct:CheckAssistData(pPlayer)
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    tbSaveData.nAssistCount = tbSaveData.nAssistCount or 0
    tbSaveData.nAssistTime = tbSaveData.nAssistTime or 0
    local nNowTime = GetTime()
    if Lib:IsDiffDay(self.nAssistRefreshTime, tbSaveData.nAssistTime, nNowTime) then
		tbSaveData.nAssistCount = 0
		tbSaveData.nAssistTime = nNowTime
	end
	self:SaveDataToPlayer(pPlayer, tbSaveData)
end

function tbAct:OnAssistOk(pPlayer, nUsePlayerId)
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    tbSaveData.nAssistCount = (tbSaveData.nAssistCount or 0) + 1
    self:SaveDataToPlayer(pPlayer, tbSaveData)
    Log("[LoverRecallAct] fnOnAssistOk ok ", pPlayer.dwID, pPlayer.szName, tbSaveData.nAssistCount, nUsePlayerId);
end

function tbAct:OnSendUseMapAward(pPlayer)
	local tbMail = {
		To = pPlayer.dwID;
		Title = "吾爱江湖忆情缘";
		From = "公孙惜花";
		Text = "恭喜侠士参与吾爱江湖忆情缘活动获得奖励";
		tbAttach = self.tbUseMapAward;
		nLogReazon = Env.LogWay_LoverRecallAct;
	};
	Mail:SendSystemMail(tbMail);
	Log("[QingMingAct] fnOnSendUseMapAward ok ", pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel)
end

function tbAct:OnSendAssistAward(pPlayer)
	local tbMail = {
		To = pPlayer.dwID;
		Title = "吾爱江湖忆情缘";
		From = "公孙惜花";
		Text = "恭喜侠士参与吾爱江湖忆情缘活动获得协助奖励";
		tbAttach = self.tbAssistAward;
		nLogReazon = Env.LogWay_LoverRecallAct;
	};
	Mail:SendSystemMail(tbMail);
	Log("[QingMingAct] fnOnSendAssistAward ok ", pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nLevel)
end