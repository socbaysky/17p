FactionBattle.tbBaseFaction =  FactionBattle.tbBaseFaction or {};	-- 	各门派的门派战基类
local tbBaseFaction = FactionBattle.tbBaseFaction;

local tbBeforeRemind =
{
}

function tbBaseFaction:Init(nMapId, nFaction)
	self.nMapId = nMapId;
	self.nFreePKMapId = nil
	self.nFaction = nFaction
	self.tbEliminationPlayer = {}
	self.nPlayerCount = 0;
	self.tbPlayer = {};
	self.tbSort = {};				-- 即时排序信息表
	self.tbArea = {};
	self.tbAreaFightPower = {};	--第一轮晋级赛场地划分战斗力界限
	self.tbReadySignup = {};	--晋级赛比赛当中加入的，等待下一轮开始时报名
	self.bAwarded = false;
	self.tbCachedWatchList = {};	--等待观战的玩家列表
	--创建聊天频道
	--self.nChatChannelId = KChat.CreateDynamicChannel("门派竞技","#108")

	self:AddGouhuoNpc();

	--设置pk伤害系数
	local nDmgRate = FactionBattle.PK_DMG_RATE[nFaction]
	if nDmgRate then
		SetMapPKDmgRate(nMapId, nDmgRate);
	end
end

function tbBaseFaction:SetClientState(pPlayer)
	self:NotifyClientEnter(pPlayer);

	-- 强制退队
	if pPlayer.dwTeamID ~= 0 then
		TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
	end

	-- 禁止改变PK状态
	--pPlayer.nInBattleState = 1;
	pPlayer.bForbidChangePk = 1;
	pPlayer.SetPkMode(0)

	if self.nState == FactionBattle.ELIMINATION and
		self.tbPlayer[pPlayer.dwID] and
		self.tbPlayer[pPlayer.dwID].nArea > 0 and
		 self.tbArea[self.tbPlayer[pPlayer.dwID].nArea] then

		 self.tbArea[self.tbPlayer[pPlayer.dwID].nArea]:ReLogin(me);
	end

	 if  (self.nState == FactionBattle.READY_ELIMINATION or
		self.nState == FactionBattle.ELIMINATION or
		self.nState == FactionBattle.ELIMINATION_REST)
		and self:IsIn16th(me.dwID) then

		self:Add16thForceSync(me.dwID)
	 end

	self:SyncLeftInfo(pPlayer)
	self:Sync16thInfo(pPlayer);		-- 同步界面数据
end

function tbBaseFaction:OnMapEnter()
	local szMsg = "";
	if self.nState == FactionBattle.SIGN_UP then
		if self.nPlayerCount >= FactionBattle.MAX_ATTEND_PLAYER then
			szMsg = string.format(XT("报名人数已达到%d人上限，不能再报名了"), FactionBattle.MAX_ATTEND_PLAYER);
		elseif me.nLevel < FactionBattle.MIN_LEVEL then
			szMsg = XT("你等级不足")..FactionBattle.MIN_LEVEL..XT("级，不能参加门派竞技比赛。")
		elseif not self.tbPlayer[me.dwID] then
			self:JoinGame(me);
		end
	elseif self.nState == FactionBattle.FREE_PK or self.nState == FactionBattle.FREE_PK_REST then
		--晋级赛的时候还可以继续报名，将在下一轮的时候加入战斗
		if self.nPlayerCount < FactionBattle.MAX_ATTEND_PLAYER and 
			not self.tbPlayer[me.dwID] and not self.tbReadySignup[me.dwID]  then
			self.tbReadySignup[me.dwID] = true;
			szMsg = XT("你已自动报名，请稍作等待！");
		end
	elseif self.nState > FactionBattle.FREE_PK_REST then
		if not self.tbPlayer[me.dwID] then
			szMsg = XT("门派竞技已经开始了，报名已经截止");
		end
	else
		return 0;
	end

	self:SetClientState(me)

	--KChat.AddPlayerToDynamicChannel(self.nChatChannelId,me.dwID);

	if szMsg ~= "" then
		Dialog:SendBlackBoardMsg(me, szMsg);
	end

	if MODULE_ZONESERVER then
		me.CenterMsg(string.format("你已进入跨服门派竞技%s场地", FactionBattle:GetCrossTypeName()))
	end
end

function tbBaseFaction:OnMapLogin()
	me.CallClientScript("FactionBattle:OnEnter");
	self:SetClientState(me)
end

function tbBaseFaction:OnMapLeave()
	me.nInBattleState = 0;
	me.bForbidChangePk = 0;
	me.SetPkMode(0)
	if self.nState == FactionBattle.SIGN_UP and self.tbPlayer[me.dwID] then
		self.tbPlayer[me.dwID] = nil
		self.nPlayerCount = self.nPlayerCount - 1;
		self:SyncLeftInfo()
	elseif self.nState == FactionBattle.ELIMINATION then
		self:LeaveGame(me)
	end
	--KChat.DelPlayerFromDynamicChannel(self.nChatChannelId,me.dwID);
	self:RemoveCacheWatchPlayer(me.dwID)
end

function tbBaseFaction:NotifyClientEnter(pPlayer)

	if pPlayer.nLastLeaveMap ~= FactionBattle.PREPARE_MAP_TAMPLATE_ID and
	pPlayer.nLastLeaveMap ~= FactionBattle.FREEPK_MAP_TAMPLATE_ID  then

		pPlayer.CallClientScript("FactionBattle:OnEnter");
	end
end

function tbBaseFaction:JoinGame(pPlayer)
	local nPlayerId = pPlayer.dwID
	if not self.tbPlayer[nPlayerId] then
		self.tbPlayer[nPlayerId] = {nScore = 0, nArea = 0, nPlayerId = nPlayerId, nSort = 0, nFreePKCombo = 0};
		if MODULE_ZONESERVER then
			--跨服比赛记录原服信息
			self.tbPlayer[nPlayerId].nZoneServerId = pPlayer.nZoneServerId;
			self.tbPlayer[nPlayerId].dwOrgPlayerId = pPlayer.dwOrgPlayerId;
			self.tbPlayer[nPlayerId].dwOrgKinId = pPlayer.dwOrgKinId;
		end
		self.nPlayerCount = self.nPlayerCount + 1;
		self:SyncLeftInfo()
		if not MODULE_ZONESERVER then
			Achievement:AddCount(pPlayer, "FactionBattle_1", 1)
		else
			FactionBattle:CallZoneClientScriptByServerId(self.tbPlayer[nPlayerId].nZoneServerId, "Achievement:AddCount", self.tbPlayer[nPlayerId].dwOrgPlayerId, "FactionBattle_1", 1)
		end
	end
	self.tbPlayer[nPlayerId].nArea = 0;

end

function tbBaseFaction:LeaveGame(pPlayer)
	if self.tbPlayer[pPlayer.dwID] then
		if self.tbPlayer[pPlayer.dwID].nArea > 0 and self.tbArea[self.tbPlayer[pPlayer.dwID].nArea] then
			self.tbArea[self.tbPlayer[pPlayer.dwID].nArea]:KickOut(pPlayer);
		end
		self.tbPlayer[pPlayer.dwID].nArea = -1;
		-- 禁止改变PK状态
	end
end

function tbBaseFaction:OnPlayerJoinArea(nPlayerId, nArea)
	if self.tbPlayer[nPlayerId] then
		self.tbPlayer[nPlayerId].nArea = nArea
	end
end

function tbBaseFaction:OnPlayerLeaveArea(nPlayerId)
	if self.tbPlayer[nPlayerId] then
		self.tbPlayer[nPlayerId].nArea = 0
	end
end

function tbBaseFaction:KickOut(pPlayer)
	if MODULE_ZONESERVER then
		pPlayer.ZoneLogout();
	else
		pPlayer.GotoEntryPoint();
	end
end

function tbBaseFaction:ForEachInMap(fnFunction)
	local tbPlayer,count = KPlayer.GetMapPlayer(self.nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		fnFunction(pPlayer)
	end
	if self.nFreePKMapId then
		tbPlayer,count = KPlayer.GetMapPlayer(self.nFreePKMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			fnFunction(pPlayer)
		end
	end
end

function tbBaseFaction:ForEach(fnFunction)
	for nPlayerId, _ in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			fnFunction(pPlayer)
		end
	end
end

function tbBaseFaction:Start()
	self:TimerStart();
end

function tbBaseFaction:Close()
	local tbPlayer,count = KPlayer.GetMapPlayer(self.nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		GameSetting:SetGlobalObj(pPlayer, him, it);
		self:OnMapLeave(self.nMapId);
		GameSetting:RestoreGlobalObj();
	end
	if self.nFreePKMapId then
		tbPlayer,count = KPlayer.GetMapPlayer(self.nFreePKMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			GameSetting:SetGlobalObj(pPlayer, him, it);
			self:OnMapLeave(self.nMapId);
			GameSetting:RestoreGlobalObj();
		end
	end

	for i, tbArea in pairs(self.tbArea) do
		tbArea:Close();
	end

	if self.nTimerId and self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
	end
	local fnFunction = function (pPlayer)
		self:KickOut(pPlayer)
	end
	self:ForEachInMap(fnFunction);

	--KChat.DelDynamicChannel(self.nChatChannelId);

	self:ExcuteAwardChampion(true)

	FactionBattle:ShutDown(self.nMapId, self.nFaction);
end

function tbBaseFaction:TimerStart()
	local nRet;
	self.nTimerId = 0;
	self.nStateJour = self.nStateJour or 0

	self:ClearUnqualifiedPlayer();

	if FactionBattle.STATE_TRANS[self.nStateJour] then
		local szFunction = FactionBattle.STATE_TRANS[self.nStateJour][4]
		local fncExcute = self[szFunction];
		if fncExcute then
			nRet = fncExcute(self);
			if nRet and nRet == 0 then
				self:Close();	-- 关闭活动
				return 0;
			end
		end
	end

	-- 状态转换
	self.nStateJour = self.nStateJour + 1;
	self.nState = FactionBattle.STATE_TRANS[self.nStateJour][1];

	if self.nState == FactionBattle.NOTHING or self.nState >= FactionBattle.END then	-- 未必开启或者已经结束
		self:Close();	-- 关闭活动
		return 0;
	end
	-- 下一阶段定时
	local tbSetting = FactionBattle.STATE_TRANS[self.nStateJour];
	if not tbSetting then
		return 0;
	end
	self.nTimerId = Timer:Register(
		tbSetting[3] * Env.GAME_FPS,
		self.TimerStart,
		self
	);	-- 开启新的定时

	local szNextFunction = tbSetting[4]
	if tbBeforeRemind[szNextFunction] and (tbSetting[3] - FactionBattle.BEFORE_REMIND_TIME) * Env.GAME_FPS > 0 then
		self.nTixingTimer = Timer:Register((tbSetting[3] - FactionBattle.BEFORE_REMIND_TIME) * Env.GAME_FPS, tbBeforeRemind[szNextFunction], self);	-- 开启新的定时
	end

	self:SyncLeftInfo()
	return 0
end

function tbBaseFaction:GetCurStateTime()
	return Timer:GetRestTime(self.nTimerId)
end

function tbBaseFaction:GetNextStateTime()
	local nNextState = self.nStateJour + 1;
	if not FactionBattle.STATE_TRANS[nNextState] then
		return 0;
	end

	return FactionBattle.STATE_TRANS[nNextState][3];
end

function tbBaseFaction:GetNextStateName()
	local nNextState = self.nStateJour + 1;
	if not FactionBattle.STATE_TRANS[nNextState] then
		return "";
	end

	return FactionBattle.STATE_TRANS[nNextState][2];
end

function tbBaseFaction:SyncLeftInfo(pPlayer, nState)
	nState = nState or self.nState

	local fnFunction = function (pPlayer)
		if nState == FactionBattle.SIGN_UP then
			pPlayer.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattlePrepare", {self.nPlayerCount, self:GetCurStateTime()/Env.GAME_FPS});
		elseif nState == FactionBattle.FREE_PK or nState == FactionBattle.ELIMINATION then
			if self.tbPlayer[pPlayer.dwID] and self.tbPlayer[pPlayer.dwID].nArea > 0 and self.tbArea[self.tbPlayer[pPlayer.dwID].nArea] then
				self.tbArea[self.tbPlayer[pPlayer.dwID].nArea]:SyncLeftInfo(pPlayer);
			else
				pPlayer.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleOut", {FactionBattle.STATE_TRANS[self.nStateJour][2], self:GetCurStateTime()/Env.GAME_FPS});
			end
		elseif nState == FactionBattle.CHAMPION_AWARD then
			pPlayer.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleOut", {FactionBattle.STATE_TRANS[self.nStateJour][2], self:GetCurStateTime()/Env.GAME_FPS});
		elseif nState == FactionBattle.END_AWARD then
			pPlayer.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleEnd", {});
		else
			pPlayer.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleRest", {FactionBattle.STATE_TRANS[self.nStateJour][2], self:GetCurStateTime()/Env.GAME_FPS});
		end
	end

	if not pPlayer then
		self:ForEachInMap(fnFunction);
	else
		fnFunction(pPlayer)
	end
end

function tbBaseFaction:BoardMsgToMapPlayer(szMsg)
	local fnFunction = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:ForEachInMap(fnFunction);
end

function tbBaseFaction:BoardCenterMsgToMapPlayer(szMsg)
	local fnFunction = function (pPlayer)
		pPlayer.CenterMsg(szMsg)
	end
	self:ForEachInMap(fnFunction);
end

function tbBaseFaction:SysMsgToMapPlayer(szMsg)
	local fnFunction = function (pPlayer)
		pPlayer.Msg(szMsg)
	end
	self:ForEachInMap(fnFunction);
end

-- 开始自由PK
function tbBaseFaction:_StartFreedomPK(nOpenCount)
	-- 排序分组
	local tbResult = {}
	local fnSort = function (tbA, tbB)
		if nOpenCount > 1 then
			return tbA.nScore > tbB.nScore
		else
			return tbA.nPow > tbB.nPow
		end
	end

	if #self.tbSort == 0 then
		for nPlayerId, tbInfo in pairs(self.tbPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				tbInfo.nPow = pPlayer.GetFightPower();
			else
				tbInfo.nPow = 0;
			end

			table.insert(self.tbSort, tbInfo);
		end
		table.sort(self.tbSort, fnSort);
		for i, tbInfo in ipairs(self.tbSort) do
			tbInfo.nSort = i;
		end
	end

	for i, tbInfo in ipairs(self.tbSort) do
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId);
		if pPlayer and (pPlayer.nMapTemplateId == FactionBattle.PREPARE_MAP_TAMPLATE_ID or
				pPlayer.nMapTemplateId == FactionBattle.FREEPK_MAP_TAMPLATE_ID)then		-- 筛选掉不在本地图的玩家
			table.insert(tbResult, {pPlayer = pPlayer, nPow = tbInfo.nPow});
		end
	end
	local nTotal = #tbResult;	-- 最终人数以筛选后的结果为准
	if nTotal < FactionBattle.MIN_ATTEND_PLAYER and nOpenCount <= 1 then
		Log("FactionBattle", "Start Failed Faction " , self.nFaction, " Attend Player", nTotal)
		--未开启成功给在场的发16强奖励和箱子奖励
		local nBoxAwardId = FactionBattle:GetBoxAwardId()
		local tbSync16th = {}
		local tbSyncBox = {}
		for _,tbInfo in pairs(tbResult) do
			if tbInfo.pPlayer then
				local nPlayerId = tbInfo.pPlayer.dwID
				local tbRankInfo = {nPlayerId=nPlayerId, nWinCount=0}
				if MODULE_ZONESERVER then
					tbRankInfo.dwOrgPlayerId = tbInfo.pPlayer.dwOrgPlayerId;
					tbRankInfo.nZoneServerId = tbInfo.pPlayer.nZoneServerId;
				end
				table.insert(tbSync16th, tbRankInfo)
				tbSyncBox[nPlayerId] = FactionBattle.BOX_MAX_GET
				if not MODULE_ZONESERVER then
					FactionBattle:OnAttend(tbInfo.pPlayer);
					self:Send16thAward(nPlayerId, 0, XT("由於本次少侠所在的门派竞技，因为人数不足没有顺利开启，特给予以下奖励，以资鼓励！"))
					Calendar:OnCompleteAct(nPlayerId, "FactionBattle", 16, nTotal)

					--本服前8强获得进入月度赛资格
					FactionBattle:OnLocal8th(nPlayerId);

					if nBoxAwardId then
						for i=1,FactionBattle.BOX_MAX_GET do
							local nRet, szMsg, tbAward = Item:GetClass("RandomItem"):RandomItemAward(tbInfo.pPlayer, nBoxAwardId, "FactionBattleBox");
							if nRet == 1 then
								FactionBattle:AddBoxAwardRecord(nPlayerId);
								tbInfo.pPlayer.SendAward(tbAward, true, false, Env.LogWay_FactionBattleBox);
							end
						end
					end
				end

				tbInfo.pPlayer.Msg(XT("本次门派竞技由於参与人数不足，没有开启，特给予少侠8个门派竞技宝箱，以资鼓励！"))
			end
		end
		if MODULE_ZONESERVER then
			CallZoneClientScript(-1, "FactionBattle:OnCrossAward16th", tbSync16th, nTotal);
		end
		return 0;
	elseif nTotal <= 16 and nOpenCount <= 1 then
		--满足最小参与人数，但又小于等于16人的，直接开启16强比赛
		for _,tbInfo in pairs(tbResult) do
			if tbInfo.pPlayer then
				FactionBattle:OnAttend(tbInfo.pPlayer);
			end
		end

		self:BoardCenterMsgToMapPlayer(XT("由於参与人数不足，直接进入16强比赛！"));
		self:EndFreedomPKDelay();
		self.nStateJour = 6; --把当前阶段强制设置成第3轮淘汰赛结束
		return 1;
	end

	-- 计算场地
	local nAreaCount = 1
	for i, nPlayerMax in ipairs(FactionBattle.OPEN_AREA) do
		nAreaCount = i
		if nTotal <= nPlayerMax then
			break;
		end
	end

	nAreaCount = math.min(nAreaCount, #FactionBattle.FREE_PK_SCORE)
	self.tbArea = {}
	for i = 1, nAreaCount do
		local tbFreedomPkGame = Lib:NewClass(FactionBattle.tbFreedomPK);
		tbFreedomPkGame:Init(i, self.nFreePKMapId, (FactionBattle.FREE_PK_SCORE[i] or {})[nOpenCount] or 1, FactionBattle.tbFreedomPkPoint[i], self, nOpenCount)
		table.insert(self.tbArea, tbFreedomPkGame);
	end

	local nArea = 1;
	local nFightPower = 0; --用来保存场地战斗力划分的下限
	for i, tbInfo in ipairs(tbResult) do
		if i > nArea * nTotal / nAreaCount then
			if nOpenCount == 1 then
				--晋级赛第一轮记录战斗力划分界限
				self.tbAreaFightPower[nArea] = nFightPower;
			end
			nArea = nArea + 1
		end
		nFightPower = tbInfo.nPow;
		self.tbArea[nArea]:Join(tbInfo.pPlayer);
	end

	if nOpenCount > 1 then
		for nPlayerId,_ in pairs(self.tbReadySignup) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer and pPlayer.nFaction == self.nFaction and (pPlayer.nMapTemplateId == FactionBattle.PREPARE_MAP_TAMPLATE_ID or
					pPlayer.nMapTemplateId == FactionBattle.FREEPK_MAP_TAMPLATE_ID) then

				self:JoinGame(pPlayer);
				local tbInfo = self.tbPlayer[nPlayerId];

				table.insert(self.tbSort, tbInfo);

				tbInfo.nSort = #self.tbSort;

				local nSelectArea = nil
				for nArea,nFightPower in ipairs(self.tbAreaFightPower) do
					if pPlayer.GetFightPower() >= nFightPower then
						nSelectArea = nArea;
						break;
					end
				end
				nSelectArea = nSelectArea or nAreaCount;
				self.tbArea[nSelectArea]:Join(pPlayer);
				--Dialog:SendBlackBoardMsg(pPlayer, szMsg)
			end
		end
	end

	self.tbReadySignup = {};

	for i, tbArea in ipairs(self.tbArea) do
		tbArea:Start()
	end

	self:BoardMsgToMapPlayer(string.format(XT("晋级赛第%s阶段开战！"), nOpenCount));

	return 1;
end

function tbBaseFaction:CloseFreedomPK(bKickOut)
	for i, tbArea in ipairs(self.tbArea) do
		tbArea:Close(bKickOut);
	end
end

function tbBaseFaction:StartFreedomPK()
	self.nOpenCount = (self.nOpenCount or 0) + 1;
	local nRet = self:_StartFreedomPK(self.nOpenCount)

	if nRet == 0 then
		self:BoardMsgToMapPlayer(string.format(XT("本门派竞技参与人数少於%d人，无法开启"), FactionBattle.MIN_ATTEND_PLAYER))
	end
	return nRet;
end

function tbBaseFaction:ReturnAllPlayerPoint()
	local fnFunction = function (pPlayer)
		self:Return2EnterPoint(pPlayer)
	end
	self:ForEach(fnFunction);
end

function tbBaseFaction:RecordPlayerPoint(pPlayer)
	if not pPlayer or not FactionBattle:IsInValidMap(pPlayer) then
		return;
	end
	local nPlayerId = pPlayer.dwID;
	if not self.tbPlayer[nPlayerId].tbTransPos then
		local _, nX, nY = pPlayer.GetWorldPos();
		self.tbPlayer[nPlayerId].tbTransPos = {self.nMapId, nX, nY}
	else
		self.tbPlayer[nPlayerId].tbTransPos = {self.nMapId, unpack(FactionBattle:GetRandomEnterPos())};
	end
end

function tbBaseFaction:Return2EnterPoint(pPlayer)
	if not pPlayer or not FactionBattle:IsInValidMap(pPlayer) then
		return;
	end
	local nPlayerId = pPlayer.dwID;
	if not self.tbPlayer or not self.tbPlayer[nPlayerId] or not self.tbPlayer[nPlayerId].tbTransPos then
		pPlayer.SwitchMap(self.nMapId, unpack(FactionBattle:GetRandomEnterPos()))
		return;
	end
	pPlayer.SwitchMap(unpack(self.tbPlayer[nPlayerId].tbTransPos))
	self.tbPlayer[nPlayerId].tbTransPos = nil;
end

function tbBaseFaction:AddPlayerScore(nPlayerId, nAddSore)
	if not self.tbPlayer[nPlayerId] then
		return;
	end
	self.tbPlayer[nPlayerId].nScore = (self.tbPlayer[nPlayerId].nScore or 0) + nAddSore;

	local nSort = self.tbPlayer[nPlayerId].nSort;
	local tbTmpId = {nPlayerId};
	-- 实时排序
	while nSort > 1 and self.tbSort[nSort].nScore > self.tbSort[nSort - 1].nScore do
		table.insert(tbTmpId, self.tbSort[nSort - 1].nPlayerId);
		self.tbSort[nSort - 1], self.tbSort[nSort] = self.tbSort[nSort], self.tbSort[nSort - 1];
		self.tbSort[nSort - 1].nSort = nSort - 1;
		self.tbSort[nSort].nSort = nSort;
		nSort = nSort - 1;
	end
	for i, nId in ipairs(tbTmpId) do
		local pPlayer = KPlayer.GetPlayerObjById(nId)
		if pPlayer and self.tbPlayer[nId].nArea > 0 and self.tbArea[self.tbPlayer[nId].nArea] then
			self.tbArea[self.tbPlayer[nId].nArea]:SyncLeftInfo(pPlayer);
		end
	end
end

function tbBaseFaction:GetPlayerScore(nPlayerId)
	if not self.tbPlayer[nPlayerId] then
		return 0;
	end
	return self.tbPlayer[nPlayerId].nScore;
end

function tbBaseFaction:GetPlayerSort(nPlayerId)
	if not self.tbPlayer[nPlayerId] then
		return 0;
	end
	return self.tbPlayer[nPlayerId].nSort;
end

function tbBaseFaction:EndFreedomPK()
	self:CloseFreedomPK(true);
	Timer:Register(5*Env.GAME_FPS, self.EndFreedomPKDelay, self);
end

function tbBaseFaction:EndFreedomPKDelay()
	local tbResult = {};
	local nCount = #self.tbSort
	local nResultCount = 0
	local nLastIdx = 1

	for i, tbInfo in ipairs(self.tbSort) do
		local pPlayerStay = KPlayer.GetRoleStayInfo(tbInfo.nPlayerId);
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId);
		if nResultCount < 16 then
			table.insert(tbResult, {pPlayerStay = pPlayerStay, nPlayerId = tbInfo.nPlayerId, nZoneServerId = tbInfo.nZoneServerId , dwOrgPlayerId = tbInfo.dwOrgPlayerId});
			if not MODULE_ZONESERVER then
				Achievement:AddCount(tbInfo.nPlayerId, "FactionBattle_2", 1)
			else
				FactionBattle:CallZoneClientScriptByServerId(tbInfo.nZoneServerId, "Achievement:AddCount", tbInfo.dwOrgPlayerId, "FactionBattle_2", 1)
			end
			if pPlayer then
				pPlayer.CallClientScript("Ui:OpenWindow", "FactionBattleRankEffect", XT("16强赛"));
			end
			nResultCount = #tbResult;
		end
	end

	self.tb16thPlayer = {}
	for i = 1, 8 do
		local tbInfo1 = tbResult[FactionBattle.ELIMI_VS_TABLE[i][1]] or {}
		local tbInfo2 = tbResult[FactionBattle.ELIMI_VS_TABLE[i][2]] or {}
		local tbPlayer1 = tbInfo1.pPlayerStay or {}
		local tbPlayer2 = tbInfo2.pPlayerStay or {}
		self.tb16thPlayer[2 * i - 1] =
			{
				nPlayerId = tbInfo1.nPlayerId or 0, szName = tbPlayer1.szName or XT(""), nFaction = tbPlayer1.nFaction,
				nFace = tbPlayer1.nPortrait, nWinCount = 0, nZoneServerId = tbInfo1.nZoneServerId, dwOrgPlayerId = tbInfo1.dwOrgPlayerId,
			}
		self.tb16thPlayer[2 * i] =
			{
				nPlayerId = tbInfo2.nPlayerId or 0, szName = tbPlayer2.szName or XT(""), nFaction = tbPlayer2.nFaction,
				nFace = tbPlayer2.nPortrait, nWinCount = 0, nZoneServerId = tbInfo2.nZoneServerId, dwOrgPlayerId = tbInfo2.dwOrgPlayerId,
			}
		self.tbEliminationPlayer[2 * i - 1] = { nPlayerId = tbInfo1.nPlayerId or 0, tbInfo = self.tb16thPlayer[2 * i - 1]};
		self.tbEliminationPlayer[2 * i] = { nPlayerId = tbInfo2.nPlayerId or 0, tbInfo = self.tb16thPlayer[2 * i]};
	end

	--把16强之间互相加入强制同步列表
	for i = 1, 16 do
		local tbPlayerInfo = self.tb16thPlayer[i]
		if tbPlayerInfo and tbPlayerInfo.nPlayerId then
			self:Add16thForceSync(tbPlayerInfo.nPlayerId)
		end
	end

	self:SyncLeftInfo();
	self:SyncAllPlayer16thInfo()

	--self:AddGouhuoNpc();

	local fnOpen16Info = function (pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "FactionBattlePanel")
	end

	self:ForEachInMap(fnOpen16Info);

	self:BoardMsgToMapPlayer(XT("16强产生，详情可查看对阵表"));
end

function tbBaseFaction:Add16thForceSync(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = (pPlayer and pPlayer.GetNpc())
	if pNpc then
		for j = 1, 16 do
			local tbInfo = self.tb16thPlayer[j]
			if tbInfo and tbInfo.nPlayerId then
				pNpc.AddToForceSyncSet(tbInfo.nPlayerId);
			end
		end
	end
end

function tbBaseFaction:StartElimination()
	self.tbArea = {};
	self.tbWinner = {};
	for i = 1, math.ceil(#self.tbEliminationPlayer / 2) do
		local nPlayerId1 = self.tbEliminationPlayer[2 * i - 1].nPlayerId
		local nPlayerId2 = self.tbEliminationPlayer[2 * i].nPlayerId
		local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
		local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2)
		if pPlayer1 and pPlayer2 and pPlayer1.nMapId == self.nMapId and pPlayer2.nMapId == self.nMapId then
			self.tbArea[i] = Lib:NewClass(FactionBattle.tbElimination);
			self.tbArea[i]:Init(i, FactionBattle:GetElimFixPoint(i), self)
			self.tbArea[i]:Join(pPlayer1);
			self.tbArea[i]:Join(pPlayer2);
			self.tbArea[i]:Start()
			self:BeginWatchForCached(i, nPlayerId1, nPlayerId2)
		elseif pPlayer1 and pPlayer1.nMapId == self.nMapId then
			self:SetEliminationWinner(i, self.tbEliminationPlayer[2 * i - 1].nPlayerId, self.tbEliminationPlayer[2 * i].nPlayerId)
			pPlayer1.CenterMsg(XT("对手缺阵，你直接获胜晋级！"))
		elseif pPlayer2 and pPlayer2.nMapId == self.nMapId then
			self:SetEliminationWinner(i, self.tbEliminationPlayer[2 * i].nPlayerId, self.tbEliminationPlayer[2 * i - 1].nPlayerId)
			pPlayer2.CenterMsg(XT("对手缺阵，你直接获胜晋级！"))
		else
			self:SetEliminationWinner(i, 0, 0)
		end
	end
	Timer:Register(1, self.OnElimanationEarlyClose, self, 0);
	--self:DeleteGouhuoNpc();

	self:BoardMsgToMapPlayer(string.format(XT("门派竞技%s开始！"), FactionBattle.STATE_TRANS[self.nStateJour][2]));
end

function tbBaseFaction:SetEliminationWinner(nArea, nWinnerId, nLoserId)
	self.tbWinner[nArea] = nWinnerId
	local nWinCount = 0;
	for _, tbPlayerInfo in ipairs(self.tbEliminationPlayer) do
		if tbPlayerInfo.nPlayerId == nWinnerId and tbPlayerInfo.nPlayerId ~= 0 then
			tbPlayerInfo.tbInfo.nWinCount = tbPlayerInfo.tbInfo.nWinCount + 1
			nWinCount = tbPlayerInfo.tbInfo.nWinCount;
			local _, nMapPlayerCount = KPlayer.GetMapPlayer(self.nMapId)
			local nCount = nMapPlayerCount * (FactionBattle.ELIMINATION_AWARD[nWinCount] or 0)
			FactionBattle:AddBoxNpcInPoint(nArea, self.nMapId, nCount);
			break;
		end
	end
	local pWinner = KPlayer.GetPlayerObjById(nWinnerId)
	local pLoser = KPlayer.GetPlayerObjById(nLoserId)
	if pWinner then
		if not MODULE_ZONESERVER then
			FactionBattle:SendEliminationWinnerNotify(pWinner, nWinCount);
		else
			FactionBattle:CallZoneClientScriptByServerId(self.tbPlayer[nWinnerId].nZoneServerId, "FactionBattle:OnCrossEliminationWinner", self.tbPlayer[nWinnerId].dwOrgPlayerId, nWinCount)
		end
		pWinner.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleOut", {FactionBattle.STATE_TRANS[self.nStateJour][2], self:GetCurStateTime()/Env.GAME_FPS});
	end

	if pLoser then
		pLoser.CallClientScript("FactionBattle:OnSyncLeftInfo", "FactionBattleOut", {FactionBattle.STATE_TRANS[self.nStateJour][2], self:GetCurStateTime()/Env.GAME_FPS});
	end

	self:SyncAllPlayer16thInfo()

	self:PlayerTLog(nWinnerId, Env.LogRound_SUCCESS)
	self:PlayerTLog(nLoserId, Env.LogRound_FAIL)
end

function tbBaseFaction:PlayerTLog(nPlayerId, nWinner, nTime)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);

	if not pPlayer then
		return
	end

	pPlayer.TLogRoundFlow(Env.LogWay_FactionBattle,
		 pPlayer.nMapTemplateId,
		 pPlayer.nFaction,
		 nTime,
		 nWinner ,
		 0,
		 0);
end

function tbBaseFaction:Sync16thInfo(pPlayer)		-- 同步界面数据
	if pPlayer and self.tb16thPlayer then
		pPlayer.CallClientScript("FactionBattle:OnSync16thInfo", self.tb16thPlayer);
	end
	return 1;
end

function tbBaseFaction:SyncAllPlayer16thInfo()
	local fnFunction = function (pPlayer)
		self:Sync16thInfo(pPlayer);
	end
	self:ForEachInMap(fnFunction)
end

function tbBaseFaction:OnElimanationEarlyClose(nAreaId)
	if self.tbArea[nAreaId] then
		self.tbArea[nAreaId] = nil;
	end
	local nCount = 0;
	for _, _ in pairs(self.tbArea) do
		nCount = nCount + 1;
	end
	-- 全部都提前结束了，提前下个环节
	if nCount == 0 and self.nState == FactionBattle.ELIMINATION then
		Timer:Close(self.nTimerId);
		self:TimerStart();
	end
end

function tbBaseFaction:CloseElimination()
	for i, tbArea in pairs(self.tbArea) do
		tbArea:Close();
	end
	self.tbArea = {}
	local tbTemp = {}
	for i, nPlayerId in ipairs(self.tbWinner) do
		for j, tbInfo in ipairs(self.tbEliminationPlayer) do
			if tbInfo.nPlayerId ~= 0 and tbInfo.nPlayerId == nPlayerId then
				tbTemp[i] = tbInfo;
			end
		end
		if not tbTemp[i] then
			tbTemp[i] = {nPlayerId = 0};
		end
	end

	self.tbEliminationPlayer = tbTemp;

	local szNextStateName = self:GetNextStateName();
	local szAchievement = FactionBattle.STATE_ACHIEVEMENT[szNextStateName];

	for _, tbInfo in pairs(self.tbEliminationPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId);
		if szAchievement and tbInfo.nPlayerId > 0 then
			if not MODULE_ZONESERVER then
				Achievement:AddCount(tbInfo.nPlayerId, szAchievement, 1)
			else
				FactionBattle:CallZoneClientScriptByServerId(tbInfo.tbInfo.nZoneServerId, "Achievement:AddCount", tbInfo.tbInfo.dwOrgPlayerId, szAchievement, 1)
			end
		end
		if pPlayer then
			pPlayer.CallClientScript("Ui:OpenWindow", "FactionBattleRankEffect", szNextStateName);
		end
	end

	--self:AddGouhuoNpc();

	self:BoardMsgToMapPlayer(string.format(XT("%s选手产生，详情可查看对阵表"), self:GetNextStateName()));
end

function tbBaseFaction:EndElimination()
	for i, tbArea in pairs(self.tbArea) do
		tbArea:Close();
	end
	self.tbArea = {}
	if self.tbWinner[1] and self.tbWinner[1] > 0 then
		self:AwardChampionStart(self.tbWinner[1])
	end
end

-- 冠军授予功能启动
function tbBaseFaction:AwardChampionStart(nWinnerId)
	local pFlagNpc = KNpc.Add(FactionBattle.FLAG_TEMPLATE_ID, 1, 0, self.nMapId, unpack(FactionBattle.FLAG_POS));
	pFlagNpc.tbFactionBattle = {}
	pFlagNpc.tbFactionBattle.nWinnerId = nWinnerId;
	pFlagNpc.tbFactionBattle.tbGame = self;	-- 记录活动对象，

	self.nWinnerId = nWinnerId

	self:SyncAllPlayer16thInfo()

	local pPlayer = KPlayer.GetPlayerObjById(nWinnerId)
	if MODULE_ZONESERVER then
		local tbPlayerInfo = self.tbPlayer[nWinnerId];
		CallZoneClientScript(-1, "FactionBattle:OnCrossAwardChampionStart", tbPlayerInfo.dwOrgPlayerId, tbPlayerInfo.nZoneServerId, pPlayer and pPlayer.szName,  self.nFaction,
					 pPlayer and pPlayer.nLevel, pPlayer and pPlayer.nPortrait, pPlayer and pPlayer.nHonorLevel, pPlayer and pPlayer.GetFightPower());
	end

	if pPlayer  then
		pPlayer.CallClientScript("Ui:OpenWindow", "FactionBattleRankEffect", XT("冠军"));
		if pPlayer.nMapId == self.nMapId then
			pPlayer.SetPosition(unpack(FactionBattle.AWARD_POS));
		end

		if not MODULE_ZONESERVER then
			pPlayer.AddTitle(FactionBattle.CHAMPION_TITLE[self.nFaction], FactionBattle.CHAMPION_TITLE_TIMEOUT, true)

			KPlayer.SendWorldNotify(0, 1000,
					string.format(XT("恭喜「%s」获得%s门派竞技新人王", pPlayer.szName, Faction:GetName(self.nFaction))),
					ChatMgr.ChannelType.Public, 1);

			Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.newbie_king)
			Sdk:SendTXLuckyBagMail(pPlayer, "FactionNew");
			RecordStone:AddRecordCount(pPlayer, "FactionBattle", 1)
		end
		pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_FactionBattle_NewbieKing);
	end

	if not MODULE_ZONESERVER then
		FactionBattle:OnWinner(self.nFaction, nWinnerId);

		Achievement:AddCount(nWinnerId, "FactionBattleNew_1", 1)
	end
end

function tbBaseFaction:OnPlayerTrap(szClassName)
	if szClassName == "trap_out" then
		if self.nWinnerId == me.dwID and self.bAwarded then
			me.SetPosition(unpack(FactionBattle.FALG_TICK_BACK))
		end
	elseif szClassName == "trap_watch_out" then
		self:OnWatchTrapOut(me)
	elseif FactionBattle.WATCH_TRAP[szClassName] then
		local nAreaId = FactionBattle.WATCH_TRAP[szClassName];
		self:OnWatchTrapIn(me, nAreaId)
	end
end

function tbBaseFaction:AddCacheWatch(nAreaId, nId)
	self.tbCachedWatchList[nAreaId] = self.tbCachedWatchList[nAreaId] or {}
	self.tbCachedWatchList[nAreaId][nId] = true
end

function tbBaseFaction:RemoveCacheWatch(nAreaId, nId)
	local tbList = self.tbCachedWatchList[nAreaId]
	if not tbList then return end

	tbList[nId] = nil
end

function tbBaseFaction:RemoveCacheWatchPlayer(nPlayerId)
	for _, tbList in pairs(self.tbCachedWatchList) do
		tbList[nPlayerId] = nil
	end
end

function tbBaseFaction:BeginWatchForCached(nAreaId, nExclude1, nExclude2)
	local tbArea = self.tbArea[nAreaId]
	if not tbArea or not tbArea.SyncWatchInfo then
		return
	end
	local tbList = self.tbCachedWatchList[nAreaId]
	if not tbList then return end

	for nId in pairs(tbList) do
		if nId~=nExclude1 and nId~=nExclude2 and self.tbPlayer[nId] and self.tbPlayer[nId].nArea==0 then
			local pPlayer = KPlayer.GetPlayerObjById(nId)
			if pPlayer then
				tbArea:SyncWatchInfo(pPlayer)
			end
		end
	end
end

function tbBaseFaction:OnWatchTrapIn(pPlayer, nAreaId)
	local tbArea = self.tbArea[nAreaId]
	if tbArea and tbArea.SyncWatchInfo and self.nState == FactionBattle.ELIMINATION then
		tbArea:SyncWatchInfo(pPlayer)
	elseif self.nState==FactionBattle.READY_ELIMINATION or self.nState==FactionBattle.ELIMINATION_REST then
		self:AddCacheWatch(nAreaId, pPlayer.dwID)
	end
end

function tbBaseFaction:OnWatchTrapOut()
	me.CallClientScript("FactionBattle:OnWatchTrapOut")
	if self.nState == FactionBattle.ELIMINATION then
		for nAreaId,tbArea in pairs(self.tbArea) do
			tbArea:StopSyncWatch(me);
			self:RemoveCacheWatch(nAreaId, me.dwID)
		end
	elseif self.nState==FactionBattle.READY_ELIMINATION or self.nState==FactionBattle.ELIMINATION_REST then
		for nAreaId in pairs(self.tbArea) do
			self:RemoveCacheWatch(nAreaId, me.dwID)
		end
	end
end

function tbBaseFaction:TestMail()

	local tbMail = {
		Title = FactionBattle.FINAL_AWARD_MAIL_TITLE,
		From = XT("系统"),
		nLogReazon = Env.LogWay_FactionBattle,
	};

	--给16强发奖
	for nWinCount=1,4 do
			tbMail.To = me.dwID;

			local nAwardIdx,szDesc = FactionBattle:Get16thAwardTypeByWinCount(nWinCount);
			tbMail.tbAttach = {};

			local tbFixAward = FactionBattle.FINAL_AWARD_16TH_FIX[nAwardIdx]
			if HuaShanLunJian:IsPlayGamePeriod() then
				--华山论剑开启后给不同奖励
				tbFixAward = FactionBattle.FINAL_AWARD_16TH_FIX_HIGH[nAwardIdx]
			end

			local nGetHonor, nCurHonor, nBoxCount, nLeftHonor = FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, tbFixAward);
			FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, FactionBattle.FINAL_AWARD_16TH_RATE_BY_FACTION[nAwardIdx]);

			tbMail.Text = string.format(FactionBattle.FINAL_AWARD_MAIL_CONTENT, szDesc--[[, nGetHonor, nCurHonor, nBoxCount, nLeftHonor]]);

			Mail:SendSystemMail(tbMail)
	end

	--给参与奖
	for nAwardIdx=20,100, 20 do
			tbMail.To = me.dwID;

			tbMail.tbAttach = {};

			local tbFixAward = FactionBattle.FINAL_AWARD_ALL_FIX[nAwardIdx]
			if HuaShanLunJian:IsPlayGamePeriod() then
				--华山论剑开启后给不同奖励
				tbFixAward = FactionBattle.FINAL_AWARD_ALL_FIX_HIGH[nAwardIdx]
			end

			local nGetHonor, nCurHonor, nBoxCount, nLeftHonor = FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, tbFixAward);
			FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, FactionBattle.FINAL_AWARD_ALL_RATE_BY_FACTION[nAwardIdx]);

			tbMail.Text = string.format(FactionBattle.FINAL_AWARD_MAIL_CONTENT, "参与奖"--[[, nGetHonor, nCurHonor, nBoxCount, nLeftHonor]]);

			Mail:SendSystemMail(tbMail)
	end
end

-- 触发冠军授予
function tbBaseFaction:ExcuteAwardChampion(bClose)
	if self.bAwarded then
		return
	end

	self.bAwarded = true;

	local _, nMapPlayerCount = KPlayer.GetMapPlayer(self.nMapId)
	local nCount = nMapPlayerCount * (FactionBattle.ELIMINATION_AWARD[0] or 0)
	FactionBattle:AddBoxNpcInPoint(9, self.nMapId, nCount);

	local tbMail = {
		Title = FactionBattle.FINAL_AWARD_MAIL_TITLE,
		From = XT("系统"),
		nLogReazon = Env.LogWay_FactionBattle,
	};

	local nTotal  = #self.tbSort;
	--给16强发奖
	if self.tb16thPlayer then
		for _,tbInfo in pairs(self.tb16thPlayer) do
			if tbInfo.nPlayerId > 0 then
				local nRank, _ = FactionBattle:Get16thAwardTypeByWinCount(tbInfo.nWinCount)
				if not MODULE_ZONESERVER then
					self:Send16thAward(tbInfo.nPlayerId, tbInfo.nWinCount)
					Calendar:OnCompleteAct(tbInfo.nPlayerId, "FactionBattle", nRank, nTotal)
				end
				if nRank <= 8 then
					if MODULE_ZONESERVER then
						if FactionBattle:IsMonthBattleOpen() then
							FactionBattle:CallZoneClientScriptByServerId(tbInfo.nZoneServerId, "FactionBattle:OnMonthly8th", tbInfo.dwOrgPlayerId);
						elseif FactionBattle:IsSeasonBattleOpen() then
							FactionBattle:CallZoneClientScriptByServerId(tbInfo.nZoneServerId, "FactionBattle:OnSeason8th", tbInfo.dwOrgPlayerId);
						end
					else
						--本服前8强获得进入月度赛资格
						FactionBattle:OnLocal8th(tbInfo.nPlayerId);
					end
				end
			end
		end

		if MODULE_ZONESERVER then
			CallZoneClientScript(-1, "FactionBattle:OnCrossAward16th", self.tb16thPlayer, nTotal);
		end
		Lib:Tree(self.tb16thPlayer)
	end


	--给参与奖
	local nTotalWithout16th = nTotal - 16;
	local tbSyncSortList = {};

	if nTotalWithout16th > 0 then
		for nRank=1,nTotalWithout16th do
			local nPlayerId = self.tbSort[nRank+16].nPlayerId;
			if  nPlayerId > 0 then
				tbSyncSortList[nRank+16] = {nZoneServerId = self.tbPlayer[nPlayerId].nZoneServerId, dwOrgPlayerId = self.tbPlayer[nPlayerId].dwOrgPlayerId}
				if not MODULE_ZONESERVER then
					tbMail.To = nPlayerId;

					local nAwardIdx = FactionBattle:GetAwardTypeByRank(nTotalWithout16th, nRank);
					tbMail.tbAttach = {};

					local tbFixAward = FactionBattle.FINAL_AWARD_ALL_FIX[nAwardIdx]
					if HuaShanLunJian:IsPlayGamePeriod() then
						--华山论剑开启后给不同奖励
						tbFixAward = FactionBattle.FINAL_AWARD_ALL_FIX_HIGH[nAwardIdx]
					end

					local nGetHonor, nCurHonor, nBoxCount, nLeftHonor = FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, tbFixAward);
					FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, FactionBattle.FINAL_AWARD_ALL_RATE_BY_FACTION[nAwardIdx]);

					tbMail.Text = string.format(FactionBattle.FINAL_AWARD_MAIL_CONTENT, "参与奖"--[[, nGetHonor, nCurHonor, nBoxCount, nLeftHonor]]);

					Mail:SendSystemMail(tbMail)

					Calendar:OnCompleteAct(nPlayerId, "FactionBattle", nRank+16, nTotal)
				end
			end
		end
	end

	--跨服比赛
	if MODULE_ZONESERVER then
		if Lib:CountTB(tbSyncSortList) > 0 then
			CallZoneClientScript(-1, "FactionBattle:OnCrossAwardWithout16th", tbSyncSortList, nTotal);
		end
		Lib:Tree(tbSyncSortList)
	end

	if not bClose then
		Timer:Close(self.nTimerId);
		self:TimerStart();
	end
end

function tbBaseFaction:EndChampionAward()
	self:BoardMsgToMapPlayer(XT("本届门派竞技圆满结束"))
	self:SysMsgToMapPlayer(XT("本届门派竞技圆满结束"))
	self:SyncLeftInfo(nil,FactionBattle.END_AWARD)
end

function tbBaseFaction:EndBattle()
end

function tbBaseFaction:OnFreePKMapCreate(nMapId)
	self.nFreePKMapId = nMapId

	--设置pk伤害系数
	local nDmgRate = FactionBattle.PK_DMG_RATE[self.nFaction]
	if nDmgRate then
		SetMapPKDmgRate(nMapId, nDmgRate);
	end
end

function tbBaseFaction:OnFreePKMapDestroy(nMapId)
end

function tbBaseFaction:OnEnterFreePKMap(nMapId)
	if self.tbPlayer[me.dwID] then
		local nAreaId = self.tbPlayer[me.dwID].nArea

		if nAreaId > 0 and self.tbArea[nAreaId] and self.tbArea[nAreaId].OnEnterMap then
			self.tbArea[nAreaId]:OnEnterMap();
		end
	end
end

function tbBaseFaction:OnLoginFreePKMap()
	if self.tbPlayer[me.dwID] then
		local nAreaId = self.tbPlayer[me.dwID].nArea

		if nAreaId > 0 and self.tbArea[nAreaId] and self.tbArea[nAreaId].OnEnterMap then
			self.tbArea[nAreaId]:OnLoginMap();
		end
	end
end

function tbBaseFaction:OnLeaveFreePKMap(nMapId)
	if self.tbPlayer[me.dwID] then
		local nAreaId = self.tbPlayer[me.dwID].nArea

		if nAreaId > 0 and self.tbArea[nAreaId] and self.tbArea[nAreaId].OnLeaveMap then
			self.tbArea[nAreaId]:OnLeaveMap();
		else
			self:OnMapLeave(nMapId);
		end
	end
end

function tbBaseFaction:DeleteGouhuoNpc()
	if self.nGouhuoNpcId then
		local pNpc = KNpc.GetById(self.nGouhuoNpcId);

		if pNpc then
			local tbTmp = pNpc.tbTmp;
			if tbTmp and tbTmp.nTimerId then
				Timer:Close(tbTmp.nTimerId);
				tbTmp.nTimerId = nil;
			end
			pNpc.Delete();
		end
		self.nGouhuoNpcId = nil
	end
end

function tbBaseFaction:AddGouhuoNpc()
	if MODULE_ZONESERVER then
		--跨服不开篝火
		return
	end

	self:DeleteGouhuoNpc()

	local pNpc = KNpc.Add(FactionBattle.GOUHUO_NPC_ID , 1, 0, self.nMapId, unpack(FactionBattle.GOUHUO_POS));

	if pNpc then
		self.nGouhuoNpcId = pNpc.nId
	end
end

function tbBaseFaction:StopWatchElimination(nPlayerId)
	if not nPlayerId or nPlayerId <= 0 then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)

	if not pPlayer then
		return
	end

	local pNpc = pPlayer.GetNpc()

	if not pNpc then
		return
	end

	pNpc.ClearForceSyncSet();

	local fnStopWatch = function (pPlayer)
		pPlayer.CallClientScript("FactionBattle:EndWatch", pNpc.nId);
	end

	self:ForEachInMap(fnStopWatch);
end

function  tbBaseFaction:AddFreePKCombo(nPlayerId)
	local tbPlayerInfo = self.tbPlayer[nPlayerId]

	if not tbPlayerInfo then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)

	if not pPlayer then
		return
	end

	tbPlayerInfo.nFreePKCombo = (tbPlayerInfo.nFreePKCombo or 0) + 1;
	pPlayer.CallClientScript("Ui:ShowComboKillCount", tbPlayerInfo.nFreePKCombo);
end

function tbBaseFaction:IsIn16th(nPlayerId)
	if not self.tb16thPlayer then
		return false
	end

	for i = 1, 16 do
		local tbPlayerInfo = self.tb16thPlayer[i]
		if tbPlayerInfo and tbPlayerInfo.nPlayerId == nPlayerId then
			return true
		end
	end

	return false
end

function tbBaseFaction:Send16thAward(nPlayerId, nWinCount, szContent)
	local tbMail = {
		Title = FactionBattle.FINAL_AWARD_MAIL_TITLE,
		From = XT("系统"),
		To = nPlayerId,
		nLogReazon = Env.LogWay_FactionBattle,
		tbAttach = {},
	};

	local nAwardIdx,szDesc = FactionBattle:Get16thAwardTypeByWinCount(nWinCount);

	local tbFixAward = FactionBattle.FINAL_AWARD_16TH_FIX[nAwardIdx]
	if HuaShanLunJian:IsPlayGamePeriod() then
		--华山论剑开启后给不同奖励
		tbFixAward = FactionBattle.FINAL_AWARD_16TH_FIX_HIGH[nAwardIdx]
	end

	local nGetHonor, nCurHonor, nBoxCount, nLeftHonor = FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, tbFixAward);
	FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, FactionBattle.FINAL_AWARD_16TH_RATE_BY_FACTION[nAwardIdx]);

	tbMail.Text = szContent or string.format(FactionBattle.FINAL_AWARD_MAIL_CONTENT, szDesc--[[, nGetHonor, nCurHonor, nBoxCount, nLeftHonor]]);

	Mail:SendSystemMail(tbMail)
end

function tbBaseFaction:ClearUnqualifiedPlayer()
	for nPlayerId, _ in pairs(self.tbPlayer) do
		local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
		if pStayInfo and pStayInfo.nFaction ~= self.nFaction then
			self.tbPlayer[nPlayerId] = nil
			self.nPlayerCount = self.nPlayerCount - 1;
		end
	end

	for nRank=#self.tbSort,1,-1 do
		local tbPlayerInfo = self.tbSort[nRank]
		local pStayInfo = KPlayer.GetRoleStayInfo(tbPlayerInfo.nPlayerId)
		if pStayInfo and pStayInfo.nFaction ~= self.nFaction then
			table.remove(self.tbSort, nRank)
		end
	end

	for _, tbPlayerInfo in ipairs(self.tbEliminationPlayer) do
		if tbPlayerInfo.nPlayerId ~= 0 then
			local pStayInfo = KPlayer.GetRoleStayInfo(tbPlayerInfo.nPlayerId)
			if pStayInfo and pStayInfo.nFaction ~= self.nFaction then
				tbPlayerInfo.nPlayerId = 0
			end
		end
	end

	if self.tb16thPlayer then
		for _,tbPlayerInfo in pairs(self.tb16thPlayer) do
			if tbPlayerInfo.nPlayerId ~= 0 then
				local pStayInfo = KPlayer.GetRoleStayInfo(tbPlayerInfo.nPlayerId)
				if pStayInfo and pStayInfo.nFaction ~= self.nFaction then
					tbPlayerInfo.nPlayerId = 0
					tbPlayerInfo.szName = ""
				end
			end
		end
	end
end