
function TeamBattle:CheckStartLeague()
	self.nExtType = self:GetCurrentLeagueType();
	if not self.nExtType or self.nExtType == self.TYPE_NORMAL then
		return;
	end

	self:PreStartTeamBattle(TeamBattle.nPreMapTime, false, self.nExtType);
end

function TeamBattle:GetCurrentLeagueType()
	local nLeagueType = self.TYPE_NORMAL;
	local nTimeNow = GetTime();
	local nTodayZeroTime = Lib:GetTodayZeroHour();
	local nEndType = self.bNotOpenYear and self.TYPE_QUARTERLY or self.TYPE_YEAR
	for nType = self.TYPE_MONTHLY, nEndType do
		local nOpenTime = self:GetNextOpenTime(nType, nTodayZeroTime);
		if nOpenTime and math.abs(nOpenTime - nTimeNow) <= 900 then
			nLeagueType = nType;
			break;
		end
	end

	return nLeagueType;
end

function TeamBattle:OnSyncLeaguePreMap(nType, nPreMapId, bIsLoadOK)
	-- 联赛类型以zoneserver的为准
	self.nExtType = nType;
	self.nLeaguePreMapId = nPreMapId;
	self.bLeaguePreMapLoadOK = bIsLoadOK;
end

function TeamBattle:OnSyncPreTime(bIsPreTime)
	self.bLeagueIsPreTime = bIsPreTime;
end

function TeamBattle:OnSyncFinish(nType)
	Log(string.format("[TeamBattle] OnSyncFinish nType = %s", nType));

	if TeamBattle.tbLeagueCloseNotify[nType] then
		KPlayer.SendWorldNotify(1, 999, TeamBattle.tbLeagueCloseNotify[nType], ChatMgr.SystemMsgType.System, 0);
	end

	if not self.tbCacheInfo or not self.tbCacheInfo.tbPlayerInfo or #self.tbCacheInfo.tbPlayerInfo <= 0 then
		return;
	end

	local tbMaxFloorInfo = {};
	for _, tbInfo in pairs(self.tbCacheInfo.tbPlayerInfo) do
		tbMaxFloorInfo[tbInfo[3]] = true;
	end

	local tbAllPlayer = {};
	local nMaxFloor, nSecondFloor = nil, nil;
	for i = TeamBattle.nMaxFloor_Cross, TeamBattle.nMaxFloor_Cross - 1, -1 do
		if tbMaxFloorInfo[i] then
			if nMaxFloor == nil or nSecondFloor == nil then
				nMaxFloor = nMaxFloor or i;
				nSecondFloor = nMaxFloor ~= i and i or nil;
			end

			if i == nMaxFloor or i == nSecondFloor then
				for _, tbInfo in pairs(self.tbCacheInfo.tbPlayerInfo) do
					if tbInfo[3] == i then
						table.insert(tbAllPlayer, tbInfo);
					end
				end
			end
		end
	end

	if #tbAllPlayer <= 0 then
		return;
	end

	table.sort(tbAllPlayer, function (a, b)
		if a[3] ~= b[3] then
			return a[3] > b[3];
		end

		if a[2] ~= b[2] then
			return a[2] > b[2];
		end

		if a[4] ~= b[4] then
			return a[4] > b[4];
		end

		if a[1] ~= b[1] then
			return a[1] > b[1];
		end
	end)

	local tbShowInfo = {};
	for _, tbInfo in pairs(tbAllPlayer) do
		local tbRoleStayInfo = KPlayer.GetRoleStayInfo(tbInfo[1]);

		local szKinName = "";
		local tbKin = Kin:GetKinById(tbRoleStayInfo.dwKinId);
		if tbKin then
			szKinName = tbKin.szName;
		end

		table.insert(tbShowInfo, {szName = tbRoleStayInfo.szName,
									nLevel = tbRoleStayInfo.nLevel,
									nFaction = tbRoleStayInfo.nFaction,
									nHonorLevel = tbRoleStayInfo.nHonorLevel,
									szKinName = szKinName,
									nFightPower = tbInfo[4]});
	end


	NewInformation:AddInfomation("TeamBattle" .. GetTime(), GetTime() + 7 * 3600 * 24, {Type1 = "TeamBattle",Type2 = nType, tbList = tbShowInfo } , {szTitle = "通天塔系列赛", nReqLevel = 10, szUiName = "StarTower"});
end

function TeamBattle:SendQuarterlyTick(nPlayerId, nFloor)
	if nFloor < 7 then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("[TeamBattle] SendQuarterlyTick ERR ?? pPlayer is nil !! ", nPlayerId, nFloor);
		return;
	end


	local nNextOpenTime = TeamBattle:GetNextOpenTime(TeamBattle.TYPE_QUARTERLY);
	local nNextOpenSeason = Lib:GetLocalSeason(nNextOpenTime);
	local nCurInfo = pPlayer.GetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_QUARTERLY_INFO);
	if nCurInfo ~= nNextOpenSeason then
		pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_QUARTERLY_INFO_OLD, nCurInfo);
		pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_QUARTERLY_INFO, nNextOpenSeason);

		local szTimeInfo = Lib:GetTimeStr4(nNextOpenTime);
		local tbQuarterlyMail = {
			To = pPlayer.dwID,
			Title = "季度通天塔资格通知",
			Text = string.format("      恭喜您在本场通天塔竞技中成绩优异，登上%s层，现已获得季度通天塔参赛资格。季度通天塔开启时间为[FFFE0D]%s[-]，期待您的参与！更高的荣誉等着您！", nFloor, szTimeInfo),
			From = "通天塔",
			tbAttach = {{"AddTimeTitle", TeamBattle.nQuarterlyAddTitle, nNextOpenTime}},
			nLogReazon = Env.LogWay_TeamBattle,
		}
		Mail:SendSystemMail(tbQuarterlyMail);

		local szFriendMsg = string.format("恭喜侠士「%s」在月度通天塔竞技中英勇无敌，一口气登上%s层，成功获得季度通天塔参赛资格！#49", pPlayer.szName, nFloor);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szFriendMsg, pPlayer.dwID);
		if pPlayer.dwKinId > 0 then
			local szKinMsg = string.format("恭喜本帮派成员「%s」在月度通天塔竞技中英勇无敌，一口气登上%s层，现已获得季度通天塔参赛资格！#49", pPlayer.szName, nFloor);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId);
		end
	end
end

function TeamBattle:SendYearTick(nPlayerId, nFloor)
	if nFloor < 7 then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("[TeamBattle] SendYearTick ERR ?? pPlayer is nil !! ", nPlayerId, nFloor);
		return;
	end

	local nNextOpenTime = TeamBattle:GetNextOpenTime(TeamBattle.TYPE_YEAR);
	local nNextOpenYear = Lib:GetLocalYear(nNextOpenTime);
	local nCurInfo = pPlayer.GetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_YEAR_INFO);
	if nCurInfo ~= nNextOpenYear - 1 then
		pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_YEAR_INFO_OLD, nCurInfo);
		pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_YEAR_INFO, nNextOpenYear - 1);

		local szTimeInfo = Lib:GetTimeStr4(nNextOpenTime);
		local tbYearMail = {
			To = pPlayer.dwID,
			Title = "年度通天塔资格通知",
			Text = string.format("      恭喜您在本场通天塔竞技中成绩优异，登上%s层，现已获得年度通天塔参赛资格。年度通天塔开启时间为[FFFE0D]%s[-]，期待您的参与！更高的荣誉等着您！", nFloor, szTimeInfo),
			From = "通天塔",
			tbAttach = {{"AddTimeTitle", TeamBattle.nYearAddTitle, nNextOpenTime}},
			nLogReazon = Env.LogWay_TeamBattle,
		}
		Mail:SendSystemMail(tbYearMail);

		local szFriendMsg = string.format("恭喜侠士「%s」在季度通天塔竞技中英勇无敌，一口气登上%s层，成功获得年度通天塔参赛资格！#49", pPlayer.szName, nFloor);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szFriendMsg, pPlayer.dwID);
		if pPlayer.dwKinId > 0 then
			local szKinMsg = string.format("恭喜本帮派成员「%s」在季度通天塔竞技中英勇无敌，一口气登上%s层，现已获得年度通天塔参赛资格！#49", pPlayer.szName, nFloor);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId);
		end
	end
end

function TeamBattle:SendYearResult(nPlayerId, nFloor)
	if nFloor < 8 then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		Log("[TeamBattle] SendYearTick ERR ?? pPlayer is nil !! ", nPlayerId, nFloor);
		return;
	end

	local szFriendMsg = string.format("恭喜侠士「%s」在年度通天塔竞技中英勇无敌，一口气登上%s层！#49", pPlayer.szName, nFloor);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szFriendMsg, pPlayer.dwID);
	-- if pPlayer.dwKinId > 0 then
	-- 	local szKinMsg = string.format("恭喜本家族成员「%s」在季度通天塔竞技中英勇无敌，一口气登上%s层，现已获得年度通天塔参赛资格！#49", pPlayer.szName, nFloor);
	-- 	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId);
	-- end
end

function TeamBattle:OnSyncLeagueResult(tbPlayerInfo, nType)
	Log(string.format("[TeamBattle] OnSyncLeagueResult nType = %s", nType));

	self.tbCacheInfo = self.tbCacheInfo or {};
	self.tbCacheInfo.nMaxTeamId = self.tbCacheInfo.nMaxTeamId or 1;

	self.tbCacheInfo.tbPlayerInfo = self.tbCacheInfo.tbPlayerInfo or {};
	for nFloor, tbInfo in pairs(tbPlayerInfo) do
		self.tbCacheInfo.nMaxTeamId = self.tbCacheInfo.nMaxTeamId + 1;
		for nIdx, nPlayerId in ipairs(tbInfo) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			for i = 1, nIdx - 1 do
				if FriendShip:IsFriend(nPlayerId, tbInfo[i]) then
					FriendShip:AddImitity(nPlayerId, tbInfo[i], TeamBattle.nLeagueAddImity, Env.LogWay_TeamBattle);
				end
			end

			local tbAward = (TeamBattle.tbLeagueAward[nType] or {})[nFloor];
			if tbAward then
				local tbMail = {
					To = nPlayerId,
					Title = TeamBattle.tbAwardMailInfo[nType][1],
					Text = string.format(TeamBattle.tbAwardMailInfo[nType][2], nFloor);
					From = "通天塔",
					tbAttach = tbAward,
					nLogReazon = Env.LogWay_TeamBattle,
				};
				Mail:SendSystemMail(tbMail);

				local nFightPower = 0;
				if pPlayer then
					nFightPower = pPlayer.GetFightPower();
				end
				table.insert(self.tbCacheInfo.tbPlayerInfo, {nPlayerId, self.tbCacheInfo.nMaxTeamId, nFloor, nFightPower});
				Log("[TeamBattle] OnSyncLeagueResult SendAward", nPlayerId, nFloor, nType);
			else
				Log("[TeamBattle] OnSyncLeagueResult ERR ?? tbAward is nil !!", nPlayerId, nFloor, nType);
			end

			if pPlayer and nFloor >= TeamBattle.nMaxFloor_Cross then
				if pPlayer and pPlayer.dwKinId > 0 then
					ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(TeamBattle.tbLeagueTopKinNotify[nType], pPlayer.szName), pPlayer.dwKinId);
				end

				KPlayer.SendWorldNotify(1, 999, string.format(TeamBattle.tbLeagueTopWorldNotify[nType], pPlayer.szName), 1, 1);
			end

			if nType == self.TYPE_MONTHLY then
				TeamBattle:SendQuarterlyTick(nPlayerId, nFloor);
			end

			if nType == self.TYPE_QUARTERLY and not TeamBattle.bNotOpenYear then
				TeamBattle:SendYearTick(nPlayerId, nFloor);
			end

			if nType == self.TYPE_YEAR and not TeamBattle.bNotOpenYear then
				TeamBattle:SendYearResult(nPlayerId, nFloor);
			end

			local tbRedBagEvents = {
				[self.TYPE_MONTHLY] = Kin.tbRedBagEvents.tower_floor_monthly,
				[self.TYPE_QUARTERLY] = Kin.tbRedBagEvents.tower_floor_quarterly,
				[self.TYPE_YEAR] = Kin.tbRedBagEvents.tower_floor_year,
			}
			if nFloor == 8 and tbRedBagEvents[nType] then
				Kin:RedBagOnEvent(nPlayerId, tbRedBagEvents[nType], nFloor);
			end

			if pPlayer then
				EverydayTarget:AddCount(pPlayer, "TeamBattle", 1);
			end

			Calendar:OnCompleteAct(nPlayerId, "TeamBattle", nFloor);
		end
	end
end


function TeamBattle:CheckTips()
	local nTimeNow = GetTime();
	local nLocalDay = Lib:GetLocalDay();
	if not self.tbTipCheckInfo or self.tbTipCheckInfo.nCheckDay ~= nLocalDay then
		self.tbTipCheckInfo = {};
		self.tbTipCheckInfo.nCheckDay = nLocalDay;
		self.tbTipCheckInfo.tbTipInfo = {};
		self.tbTipCheckInfo.bNeedCheck = false;

		for nType in pairs(TeamBattle.tbLeagueTipMailInfo) do
			local nOpenTime = TeamBattle:GetNextOpenTime(nType);
			if nOpenTime and nOpenTime > nTimeNow and nOpenTime - nTimeNow < TeamBattle.nPreTipTime + 86400 then
				self.tbTipCheckInfo.tbTipInfo[nType] = nOpenTime;
				self.tbTipCheckInfo.bNeedCheck = true;
			end
		end
	end

	return self.tbTipCheckInfo.bNeedCheck, self.tbTipCheckInfo.tbTipInfo, nTimeNow;
end

function TeamBattle:SendLeagueTip(pPlayer)
	local bNeedCheck, tbTipInfo, nTimeNow = self:CheckTips();
	if not bNeedCheck then
		return;
	end

	for nType, nOpenTime in pairs(tbTipInfo) do
		local nLastTime = nOpenTime - nTimeNow;
		if nLastTime > 0 and nLastTime < TeamBattle.nPreTipTime then
			if TeamBattle:CheckTicket(pPlayer, nType) then
				local nSaveIdx = TeamBattle.tbTipSaveValue[nType];
				local nLastSendTime = pPlayer.GetUserValue(TeamBattle.SAVE_GROUP, nSaveIdx);
				local nLastSendDay = Lib:GetLocalDay(nLastSendTime);
				local nToday = Lib:GetLocalDay(nTimeNow);
				local nOpenDay = Lib:GetLocalDay(nOpenTime);
				if nTimeNow - nLastSendTime > TeamBattle.nPreTipTime or (nToday == nOpenDay and nLastSendDay ~= nOpenDay) then
					pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, nSaveIdx, nTimeNow);

					local szTimeInfo = Lib:GetTimeStr4(nOpenTime);
					local tbTipMail = {
						To = pPlayer.dwID,
						Title = TeamBattle.tbLeagueTipMailInfo[nType][1],
						Text = string.format(TeamBattle.tbLeagueTipMailInfo[nType][2], szTimeInfo),
						From = "通天塔",
					};
					Mail:SendSystemMail(tbTipMail);
				end
			end
		end
	end
end

function TeamBattle:OnPlayerLogin_League()
	TeamBattle:SendLeagueTip(me);
end


function TeamBattle:SendSpaceAward(nPlayerId, nType)
	if not TeamBattle.tbSpaceTipsMailInfo[nType] then
		return;
	end

	local tbMailInfo = TeamBattle.tbSpaceTipsMailInfo[nType];
	local tbAward = (TeamBattle.tbLeagueAward[nType] or {})[6];

	local tbMail = {
		To = nPlayerId,
		Title = tbMailInfo[1],
		Text = tbMailInfo[2],
		From = "通天塔",
		tbAttach = tbAward,
		nLogReazon = Env.LogWay_TeamBattle,
	};
	Mail:SendSystemMail(tbMail);
end

function TeamBattle:SendStartFailAward(nPlayerId, nType)
	if not TeamBattle.tbStartFailMailInfo[nType] then
		return;
	end

	local tbMailInfo = TeamBattle.tbStartFailMailInfo[nType];
	local tbAward = (TeamBattle.tbLeagueAward[nType] or {})[8];

	local tbMail = {
		To = nPlayerId,
		Title = tbMailInfo[1],
		Text = tbMailInfo[2],
		From = "通天塔",
		tbAttach = tbAward,
		nLogReazon = Env.LogWay_TeamBattle,
	};
	Mail:SendSystemMail(tbMail);
end