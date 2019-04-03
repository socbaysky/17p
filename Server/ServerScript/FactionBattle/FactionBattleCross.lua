Require("CommonScript/FactionBattle/FactionBattleDef.lua")

function FactionBattle:OnCrossStart()
end

function FactionBattle:OnCrossEnd()
	if MODULE_ZONESERVER then
		CallZoneClientScript(-1, "FactionBattle:OnCrossEnd");
	else
		--跨服信息
		local _, nCrossType = self:GetCrossTypeName();
		local tbCrossMsgData =
		{
			szType = "FactionBattleCrossWinner",
			nTimeOut = GetTime() + FactionBattle.WINNER_NOTIFY_TIME,
			nType = nCrossType,
		};

		if nCrossType then
			local tbPlayer = KPlayer.GetAllPlayer();
			for _, pPlayer in pairs(tbPlayer) do
				if pPlayer.nLevel >= FactionBattle.MIN_LEVEL then
					pPlayer.CallClientScript("Ui:SynNotifyMsg", tbCrossMsgData);
				end
			end

			NewInformation:AddInfomation("FactionBattleCross", GetTime() + 24*60*60, { 0, self.tbCrossWinnerInfo[self.tbBattleData.nCurSession],  nCrossType})
		end
	end
end

function FactionBattle:OnCrossClose()
	if self:IsMonthBattleOpen() then
		for nPlayerId, _ in pairs( self.tbBattleData.tbMonthPlayer ) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript("FactionBattle:SyncJoinMonthBattle", false);
			end
		end
		self.tbBattleData.tbMonthPlayer = {}
		if self.tbMonthPlayerTmp then
			for nPlayerId, _ in pairs( self.tbMonthPlayerTmp ) do
				self.tbBattleData.tbMonthPlayer[nPlayerId] = true
			end
			self.tbMonthPlayerTmp = {}
		end
		self.tbMonthPlayer = self.tbBattleData.tbMonthPlayer
	elseif self:IsSeasonBattleOpen() then
		for nPlayerId, _ in pairs( self.tbBattleData.tbSeasonPlayer ) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript("FactionBattle:SyncJoinSeasonBattle", false);
			end
		end
		self.tbBattleData.tbSeasonPlayer = {}
		self.tbSeasonPlayer = self.tbBattleData.tbSeasonPlayer
	end
end

function FactionBattle:CheckFillMonthlyPlayer()
	if (not self.tbBattleData.nMonthlyCount or self.tbBattleData.nMonthlyCount < 4) and self:IsMonthBattleOpen() then
		--如果第一次开启，没有积累够一个月的本服前8强选手，把门派排行榜前16的玩家选入
		for nFaction = 1, Faction.MAX_FACTION_COUNT do
			local tbRankList = RankBoard:GetRankBoardWithLength(string.format("FightPower_%d", nFaction), 16, 1);
			if tbRankList then
				for _, tbPlayerInfo in pairs( tbRankList ) do
					self:OnLocal8th(tbPlayerInfo.dwUnitID)
				end
			end
		end
		self.tbBattleData.nMonthlyCount = 4
	end
end

function FactionBattle:IsCanJoinMonthBattle(nPlayerId)
	self:CheckFillMonthlyPlayer();
	return self.tbMonthPlayer[nPlayerId] ~= nil
end

function FactionBattle:IsCanJoinSeasonBattle(nPlayerId)
	return self.tbSeasonPlayer[nPlayerId] ~= nil
end

function FactionBattle:OnLocalBattleEnd()
	local nWeek = Lib:GetLocalWeek()
	self.tbBattleData.nMonthlyCount = self.tbBattleData.nMonthlyCount or 0
	if nWeek ~= self.tbBattleData.nWeek then
		self.tbBattleData.nMonthlyCount = self.tbBattleData.nMonthlyCount + 1
		self.tbBattleData.nWeek = nWeek
	end
end

function FactionBattle:OnLocal8th(nPlayerId)
	if GetTimeFrameState(self.CROSS_MONTHLY_FRAME) ~= 1 then
		return false
	end

	if not self.tbMonthPlayer[nPlayerId] then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("FactionBattle:SyncJoinMonthBattle", true);
		end

		local tbMail = {
			To = nPlayerId;
			Title = "门派竞技月度赛资格",
			From = XT("系统"),
			nLogReazon = Env.LogWay_FactionBattle,
			Text = string.format("恭喜你获得门派竞技月度赛资格！\n比赛将在[FFFE0D]%s[-]举行！", Lib:GetTimeStr3(FactionBattle:GetNextMonthlyBattleTime())),
		};

		Mail:SendSystemMail(tbMail)
	end
	if self:IsMonthBattleOpen() then
		--如果当天是月度赛，但是玩家在本服比赛取得了资格，暂时先缓存资格避免资格被清除
		self.tbMonthPlayerTmp = self.tbMonthPlayerTmp or {}
		self.tbMonthPlayerTmp[nPlayerId] = true
	else
		self.tbMonthPlayer[nPlayerId] = true
	end
end

function FactionBattle:OnMonthly8th(nPlayerId)
	if not self.tbSeasonPlayer[nPlayerId] then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("FactionBattle:SyncJoinSeasonBattle", true);
		end

		local tbMail = {
			To = nPlayerId;
			Title = "获得门派竞技季度赛资格",
			From = XT("系统"),
			nLogReazon = Env.LogWay_FactionBattle,
			Text = string.format("恭喜你获得门派竞技季度赛资格！\n比赛将在[FFFE0D]%s[-]举行！", Lib:GetTimeStr3(FactionBattle:GetNextSeasonBattleTime())),
		};

		Mail:SendSystemMail(tbMail)
	end

	self.tbSeasonPlayer[nPlayerId] = true
end

function FactionBattle:OnSeason8th(nPlayerId)

end

function FactionBattle:OnCrossGameInit(nFaction, nMapId)
	self.tbCrossGame[nFaction] = nMapId
end

function FactionBattle:OnCrossGameShutDown(nMapId, nFaction)
	self.tbCrossGame[nFaction] = nil
end

function FactionBattle:OnCrossEliminationWinner(nPlayerId, nWinCount)
	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		Log("[Error]", "FactionBattle", "OnCrossEliminationWinner Not Find Player", nPlayerId, nWinCount)
		return
	end

	FactionBattle:SendEliminationWinnerNotify(pStayInfo, nWinCount, "跨服", self:GetCrossTypeName());
end

function FactionBattle:OnCrossAwardChampionStart(nPlayerId, nZoneServerId, szName,  nFaction, nLevel, nPortrait, nHonorLevel, nFightPower, szKinName)

	FactionBattle:OnCrossWinner(nPlayerId, nZoneServerId, szName, nFaction, nLevel, nPortrait, nHonorLevel, nFightPower, szKinName);

	--下面逻辑冠军所在服才处理
	local nServerId = GetServerIdentity();
	if nServerId ~= nZoneServerId then
		return
	end
	local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
	if not pStayInfo then
		return
	end

	KPlayer.SendWorldNotify(0, 1000,
			string.format(XT("恭喜「%s」获得%s跨服门派竞技%s新人王"),
			pStayInfo.szName, Faction:GetName(pStayInfo.nFaction), self:GetCrossTypeName()),
			ChatMgr.ChannelType.Public, 1);

	Kin:RedBagOnEvent(nPlayerId, Kin.tbRedBagEvents.newbie_king)
	Sdk:SendTXLuckyBagMailByPlayerId(nPlayerId, "FactionNew");

	Achievement:AddCount(nPlayerId, "FactionBattleNew_1", 1)
end

function FactionBattle:OnCrossAward16th(tb16thPlayer, nTotal)
	local tbMail = {
		Title = string.format("跨服%s", FactionBattle.FINAL_AWARD_MAIL_TITLE),
		From = XT("系统"),
		nLogReazon = Env.LogWay_FactionBattle,
		tbAttach = {},
	};

	local nNow = GetTime()
	local nTime = FactionBattle.CHAMPION_TITLE_TIMEOUT

	local tbAwadrList = FactionBattle.FINAL_AWARD_16TH_MONTHLY
	local tbTitle = FactionBattle.CHAMPION_MONTH_TITLE
	if self:IsSeasonBattleOpen() then
		tbAwadrList = FactionBattle.FINAL_AWARD_16TH_SEASON
		tbTitle = FactionBattle.CHAMPION_SEASON_TITLE
		nTime = FactionBattle.SEASON_CHAMPION_TITLE_TIMEOUT
	end

	local nServerId = GetServerIdentity();
	for _,tbInfo in pairs(tb16thPlayer) do
		if tbInfo.dwOrgPlayerId and tbInfo.dwOrgPlayerId > 0 and nServerId == tbInfo.nZoneServerId then
			local pStayInfo = KPlayer.GetRoleStayInfo(tbInfo.dwOrgPlayerId);
			if pStayInfo then
				tbMail.To = tbInfo.dwOrgPlayerId;
				tbMail.tbAttach = {};
				local nRank, _ = FactionBattle:Get16thAwardTypeByWinCount(tbInfo.nWinCount)
				local nAwardIdx,szDesc = FactionBattle:Get16thAwardTypeByWinCount(tbInfo.nWinCount);
				local tbFixAward = tbAwadrList[nAwardIdx]
				FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, tbFixAward);
				if nAwardIdx == 1 then
					--增加称号奖励
					table.insert(tbMail.tbAttach, {"AddTimeTitle", tbTitle[pStayInfo.nFaction], nNow + nTime})
				end
				tbMail.Text = string.format("恭喜你在跨服门派竞技%s中获得%s，获得如下奖励！", self:GetCrossTypeName(),szDesc);
				Mail:SendSystemMail(tbMail)
				Calendar:OnCompleteAct(tbInfo.dwOrgPlayerId, "FactionBattle", nRank, nTotal)
			end
		end
	end
end

function FactionBattle:OnCrossAwardWithout16th(tbSyncSortList, nTotal)
	local tbMail = {
		Title = string.format("跨服%s", FactionBattle.FINAL_AWARD_MAIL_TITLE),
		From = XT("系统"),
		nLogReazon = Env.LogWay_FactionBattle,
		tbAttach = {},
	};

	local nTotalWithout16th = nTotal - 16;

	local tbAwadrList = FactionBattle.FINAL_AWARD_ALL_MONTHLY
	if self:IsSeasonBattleOpen() then
		tbAwadrList = FactionBattle.FINAL_AWARD_ALL_SEASON
	end

	local nServerId = GetServerIdentity();
	for nRank,tbPlayerInfo in pairs(tbSyncSortList) do
		if tbPlayerInfo.dwOrgPlayerId and tbPlayerInfo.dwOrgPlayerId > 0 and tbPlayerInfo.nZoneServerId == nServerId then
			local pStayInfo = KPlayer.GetRoleStayInfo(tbPlayerInfo.dwOrgPlayerId);
			if pStayInfo then
				tbMail.To = tbPlayerInfo.dwOrgPlayerId;
				tbMail.tbAttach = {};
				local nAwardIdx = FactionBattle:GetAwardTypeByRank(nTotalWithout16th, nRank);
				local tbFixAward = tbAwadrList[nAwardIdx]
				FactionBattle:FillMailAttach(tbMail.To, tbMail.tbAttach, tbFixAward);
				tbMail.Text = string.format("恭喜你在跨服门派竞技%s中获得%s，获得如下奖励！", self:GetCrossTypeName(), "参与奖");
				Mail:SendSystemMail(tbMail)
				Calendar:OnCompleteAct(tbPlayerInfo.dwOrgPlayerId, "FactionBattle", nRank+16, nTotal)
			end
		end
	end
end

function FactionBattle:OnCrossBoxAward(tbBoxAwardRecord)
	local tbMail = {
		Title = "跨服门派竞技宝箱奖励",
		From = XT("系统"),
		Text = string.format("在本次跨服%s门派竞技中少侠获得了如下的宝箱奖励", self:GetCrossTypeName()),
		nLogReazon = Env.LogWay_FactionBattle,
		tbAttach = {},
	};

	local _,nItemId = FactionBattle:GetBoxAwardId()
	local nServerId = GetServerIdentity();
	for _, tbCountInfo in pairs(tbBoxAwardRecord) do
		if tbCountInfo.dwOrgPlayerId > 0 and tbCountInfo.nZoneServerId == nServerId then
			local pStayInfo = KPlayer.GetRoleStayInfo(tbCountInfo.dwOrgPlayerId);
			if pStayInfo then
				tbMail.To = tbCountInfo.dwOrgPlayerId;
				tbMail.tbAttach = {{"Item", nItemId, tbCountInfo.nCount}}
				Mail:SendSystemMail(tbMail)
			end
		end
	end
end

function FactionBattle:CallZoneClientScriptByServerId(nServerId, szFun, ...)
	local nServerConIdx = Server:GetConnectIdx(nServerId)
	if not nServerConIdx then
		Log("[Error]", "FactionBattle", "CallZoneClientScriptByServerId Failed Not Found Server Connection", nServerId, szFun)
		return
	end
	CallZoneClientScript(nServerConIdx, szFun, unpack({...}));
end
