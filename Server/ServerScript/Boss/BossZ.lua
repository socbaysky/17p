if not MODULE_ZONESERVER then
	return
end

function Boss:ZSGetPlayerUid(nPlayerId, nServerId)
	if not nServerId then
		nServerId = Server:GetServerId(Server.nCurConnectIdx);
	end

	local tbPlayerUidInfo = Boss:ZSGetCacheData("PlayerUid");
	if not tbPlayerUidInfo[nServerId] then
		tbPlayerUidInfo[nServerId] = {};
	end

	if not tbPlayerUidInfo[nServerId][nPlayerId] then
		tbPlayerUidInfo.nNextPlayerUid = tbPlayerUidInfo.nNextPlayerUid or 0;
		tbPlayerUidInfo.nNextPlayerUid = tbPlayerUidInfo.nNextPlayerUid + 1;
		tbPlayerUidInfo[nServerId][nPlayerId] = tbPlayerUidInfo.nNextPlayerUid;
	end

	return tbPlayerUidInfo[nServerId][nPlayerId];
end

function Boss:ZSGetKinUid(nKinId, nServerId)
	if not nServerId then
		nServerId = Server:GetServerId(Server.nCurConnectIdx);
	end

	local tbKinUidInfo = Boss:ZSGetCacheData("KinUid");
	if not tbKinUidInfo[nServerId] then
		tbKinUidInfo[nServerId] = {};
	end

	if not tbKinUidInfo[nServerId][nKinId] then
		tbKinUidInfo.nNextKinUid = tbKinUidInfo.nNextKinUid or 0;
		tbKinUidInfo.nNextKinUid = tbKinUidInfo.nNextKinUid + 1;
		tbKinUidInfo[nServerId][nKinId] = tbKinUidInfo.nNextKinUid;
	end

	return tbKinUidInfo[nServerId][nKinId];
end


function Boss:ZSGetCurBossData(szTimeFrame)
	local tbCurBossData = Boss.Def.tbBossSetting[1];
	for _, tbItem in ipairs(Boss.Def.tbBossSetting) do
		if tbItem.TimeFrame == szTimeFrame then
			tbCurBossData = tbItem;
			break;
		end
	end

	local tbBossInfo = {};
	tbBossInfo.Hp = tbCurBossData.Data.Hp;

	local tbNpcIds = tbCurBossData.Data.NpcIds;
	tbBossInfo.NpcId = tbNpcIds[MathRandom(1, #tbNpcIds)];

	return tbBossInfo;
end

function Boss:ZSPreStart()
	Log("Boss:ZSPreStart");

	Boss:ZSClearData();
	Boss:ZSCallAllClient("ZCGetMaxFrame");
	Timer:Register(Env.GAME_FPS * 5, self.ZSStart, self);

	local nCurTime = GetTime();
	local tbBossData = Boss:ZSGetCacheData("BossData");
	tbBossData.nStartTime = nCurTime + Boss.ZDef.nPreStartTime;
	tbBossData.nEndTime   = tbBossData.nStartTime + Boss.Def.nTimeDuration;
end

function Boss:ZSStart()
	local tbBossData = Boss:ZSGetCacheData("BossData");
	Log("Boss:ZSStart", tbBossData.szCurTimeFrame);

	local tbCurBossData = Boss:ZSGetCurBossData(tbBossData.szCurTimeFrame);
	tbBossData.nMaxHp     = tbCurBossData.Hp;
	tbBossData.nCurHp     = tbCurBossData.Hp;
	tbBossData.nNpcId     = tbCurBossData.NpcId;

	Boss:ZSCallAllClient("ZCStart", tbBossData);

	self.nSortRankTimer = Timer:Register(Env.GAME_FPS * Boss.Def.nSortRankWaitingTime, self.ZSSortActive, self);
	self.nStateCheckTimer = Timer:Register(Env.GAME_FPS, self.ZSCheckStateActive, self);
	self.bZBossOpen = true;
end

function Boss:ZSCheckStateActive()
	if not self.bZBossOpen then
		self.nStateCheckTimer = nil;
		return false;
	end

	local tbBossData = Boss:ZSGetCacheData("BossData");
	local nCurTime = GetTime();
	if nCurTime > tbBossData.nEndTime then
		self.nStateCheckTimer = nil;
		Boss:ZSPreFinish();
		return false;
	end
	return true;
end

function Boss:ZSPreFinish()
	if not self.bZBossOpen then
		return;
	end
	self.bZBossOpen = nil;
	Boss:ZSCallAllClient("ZCNotifyFinishBoss");
	Timer:Register(Env.GAME_FPS * Boss.Def.nFinishWaitTime, self.ZSFinish, self);
end

function Boss:ZSFinish()
	Log("Boss:ZSFinish");
	Boss:ZSSortPlayerRank();
	Boss:ZSSortKinRank();
	Boss:ZSCallAllClient("ZCFinish");
	Boss:ZSLogRank();
	Boss:ZSClearData();
end

function Boss:ZSLogRank()
	local tbKinRank = Boss:ZSGetCacheData("KinRank");
	local tbPlayerRank = Boss:ZSGetCacheData("PlayerRank");
	
	for nRank, tbKinData in ipairs(tbKinRank) do
		Log("BossKinRank", nRank, tbKinData.nServerId, tbKinData.szName, tbKinData.nKinId);
	end

	for nRank, tbPlayerData in ipairs(tbPlayerRank) do
		Log("BossPlayerRank", nRank, tbPlayerData.nServerId, tbPlayerData.szName, tbPlayerData.nPlayerId, tbPlayerData.nKinId);
	end
end

function Boss:ZSSortActive()
	if not self.bZBossOpen then
		self.nSortRankTimer = nil;
		return false;
	end

	if self.bZSortRank then
		Boss:ZSSortPlayerRank();
		Boss:ZSSortKinRank();
		self.bZSortRank = nil;
	end

	return true;
end

function Boss:ZSSortKinRank()
	local tbKinRank = Boss:ZSGetCacheData("KinRank");
	table.sort( tbKinRank, function (a, b)
		if a.nScore == b.nScore then
			return a.nJoinMember > b.nJoinMember;
		end
		return a.nScore > b.nScore;
	end);

	local tbSyncKinInfo = {};
	local tbKinTop = Boss:ZSGetCacheData("KinTopRank");
	for nRank, tbKinData in ipairs(tbKinRank) do
		tbKinData.nRank = nRank;

		if not tbSyncKinInfo[tbKinData.nConnectIdx] then
			tbSyncKinInfo[tbKinData.nConnectIdx] = {};
		end
		table.insert(tbSyncKinInfo[tbKinData.nConnectIdx], {
				nRank = nRank;
				nKinId = tbKinData.nKinId;
				nScore = tbKinData.nScore;
			})

		if nRank <= Boss.ZDef.nKinShowRankCount and tbKinData.nScore > 0 then
			tbKinTop[nRank] = tbKinData;
		end
	end

	Boss:ZSCallAllClient("ZCOnSyncKinRank", tbKinTop);

	for nConnectIdx, tbSyncData in pairs(tbSyncKinInfo) do
		-- 分片，每次最多同步300个
		local tbSlice = Lib:SplitArrayByCount(tbSyncData, 300);
		for _, tbData in ipairs(tbSlice) do
			Boss:ZSCallClient(nConnectIdx, "ZCOnSyncKinsInfo", tbData);
		end
	end
end

function Boss:ZSSortPlayerRank()
	local tbPlayerRank = Boss:ZSGetCacheData("PlayerRank");
	table.sort( tbPlayerRank, function (a, b)
		if a.nScore == b.nScore then
			return a.nTime < b.nTime;
		else
			return a.nScore > b.nScore;
		end
	end);

	local tbSyncPlayerInfo = {};
	local tbPlayerTop = Boss:ZSGetCacheData("PlayerTOpRank");
	for nRank, tbPlayerData in ipairs(tbPlayerRank) do
		tbPlayerData.nRank = nRank;

		if not tbSyncPlayerInfo[tbPlayerData.nConnectIdx] then
			tbSyncPlayerInfo[tbPlayerData.nConnectIdx] = {};
		end

		table.insert(tbSyncPlayerInfo[tbPlayerData.nConnectIdx], {
				nPlayerId = tbPlayerData.nPlayerId;
				nScore = tbPlayerData.nScore;
				nRank = nRank;
			});

		if nRank <= Boss.ZDef.nPlayerShowRankCount and tbPlayerData.nScore > 0 then
			local nKinUid   = Boss:ZSGetKinUid(tbPlayerData.nKinId, tbPlayerData.nServerId);
			local tbKinData = Boss:ZSGetKinData(nKinUid);
			tbPlayerTop[nRank] = {
				szName = tbPlayerData.szName;
				nScore = tbPlayerData.nScore;
				szKinName = tbKinData and tbKinData.szName;
				nHonorLevel = tbPlayerData.nHonorLevel;
				nFaction = tbPlayerData.nFaction;
				nServerId = tbPlayerData.nServerId;
			};
		end
	end
	Boss:ZSCallAllClient("ZCOnSyncPlayerRank", tbPlayerTop);

	for nConnectIdx, tbSyncData in pairs(tbSyncPlayerInfo) do
		-- 分片，每次最多同步300个
		local tbSlice = Lib:SplitArrayByCount(tbSyncData, 300);
		for _, tbData in ipairs(tbSlice) do
			Boss:ZSCallClient(nConnectIdx, "ZCOnSyncPlayersInfo", tbData);
		end
	end
end

-- Boss:ZSPreStart()

function Boss:ZSGetCacheData(szKey)
	if not self._tbZSCacheData[szKey] then
		self._tbZSCacheData[szKey] = {};
	end
	return self._tbZSCacheData[szKey];
end

function Boss:ZSClearData()
	self._tbZSCacheData = {};
end

function Boss:ZSReportTimeFrame(szTimeFrame)
	local tbBossData = Boss:ZSGetCacheData("BossData");

	if not tbBossData.szCurTimeFrame then
		tbBossData.szCurTimeFrame = szTimeFrame;
	else
		local nFrameOpenTime = CalcTimeFrameOpenTime(szTimeFrame);
		local nOrgFrameOpenTime = CalcTimeFrameOpenTime(tbBossData.szCurTimeFrame);
		if nFrameOpenTime < nOrgFrameOpenTime then
			tbBossData.szCurTimeFrame = szTimeFrame;
		end
	end

	Log("ZSReportTimeFrame", szTimeFrame, tbBossData.szCurTimeFrame, Server.nCurConnectIdx);
end

function Boss:ZSReportKinData(tbKinData)
	local tbKinMap = Boss:ZSGetCacheData("KinMap");
	local tbKinRank = Boss:ZSGetCacheData("KinRank");

	local nKinUid = Boss:ZSGetKinUid(tbKinData.nKinId);

	if tbKinMap[nKinUid] then
		Log("ZSReportKinData Repeated kinId", tbKinData.nKinId, Server.nCurConnectIdx, tbKinMap[tbKinData.nKinId].nConnectIdx);
		return;
	end

	tbKinData.nKinUid     = nKinUid;
	tbKinData.nConnectIdx = Server.nCurConnectIdx;
	tbKinMap[nKinUid]     = tbKinData;
	table.insert(tbKinRank, tbKinData);
end

function Boss:ZSReportPlayerData(tbPlayerData)
	local tbPlayerMap = Boss:ZSGetCacheData("PlayerMap");
	local tbPlayerRank = Boss:ZSGetCacheData("PlayerRank");

	local nPlayerUid = Boss:ZSGetPlayerUid(tbPlayerData.nPlayerId);

	if tbPlayerMap[nPlayerUid] then
		Log("ZSReportPlayerData Repeated PlayerId", tbPlayerData.nPlayerId, Server.nCurConnectIdx, tbPlayerMap[tbPlayerData.nPlayerId].nConnectIdx);
		return;
	end

	tbPlayerData.nPlayerUid = nPlayerUid;
	tbPlayerData.nConnectIdx = Server.nCurConnectIdx;
	tbPlayerMap[nPlayerUid] = tbPlayerData;
	table.insert(tbPlayerRank, tbPlayerData);

	self.bZSortRank = true;
end

function Boss:ZSGetPlayerData(nPlayerUid)
	return Boss:ZSGetCacheData("PlayerMap")[nPlayerUid];
end

function Boss:ZSGetKinData(nKinUid)
	return Boss:ZSGetCacheData("KinMap")[nKinUid];
end

function Boss:ZSReportKinDataByKey(nKinId, tbData)
	local nKinUid = Boss:ZSGetKinUid(nKinId);
	local tbKinData = Boss:ZSGetKinData(nKinUid);
	if not tbKinData then
		Log("ZSReportKinData Error, Kin data not found", nKinId);
		return;
	end

	for szKey, data in pairs(tbData) do
		tbKinData[szKey] = data;
	end
end

function Boss:ZSReportPlayerDataByKey(nPlayerId, tbData)
	local nPlayerUid = Boss:ZSGetPlayerUid(nPlayerId);
	local tbPlayerData = Boss:ZSGetPlayerData(nPlayerUid);
	if not tbPlayerData then
		Log("ZSReportPlayerDataByKey Error, player data not found", nPlayerId);
		return;
	end

	for szKey, data in pairs(tbData) do
		tbPlayerData[szKey] = data;
	end
end

function Boss:ZSReportBossFightScore(nPlayerId, nScore, nKinId, nKinScore)
	local nPlayerUid = Boss:ZSGetPlayerUid(nPlayerId);
	local tbPlayerData = Boss:ZSGetPlayerData(nPlayerUid);
	tbPlayerData.nScore = tbPlayerData.nScore + nScore;

	local nKinUid = Boss:ZSGetKinUid(nKinId);
	local tbKinData = Boss:ZSGetKinData(nKinUid);
	tbKinData.nScore = tbKinData.nScore + nKinScore;

	self.bZSortRank = true;

	Boss:ZSCallClient(Server.nCurConnectIdx, "ZCOnSyncPlayerInfoByKey", nPlayerId, {nScore = tbPlayerData.nScore});
end

function Boss:ZSReportRobScore(nPlayerId, nTargetUid, nRobScore)
	local nPlayerUid      = Boss:ZSGetPlayerUid(nPlayerId);
	local tbPlayerData    = Boss:ZSGetPlayerData(nPlayerUid);
	local tbTargetData    = Boss:ZSGetPlayerData(nTargetUid);
	
	local nKinUid         = Boss:ZSGetKinUid(tbPlayerData.nKinId, tbPlayerData.nServerId);
	local nTargetKinUid   = Boss:ZSGetKinUid(tbTargetData.nKinId, tbTargetData.nServerId);
	local tbPlayerKinData = Boss:ZSGetKinData(nKinUid);
	local tbTargetKinData = Boss:ZSGetKinData(nTargetKinUid);

	tbPlayerData.nScore    = tbPlayerData.nScore + nRobScore;
	tbPlayerKinData.nScore = tbPlayerKinData.nScore + nRobScore;
	tbTargetData.nScore    = tbTargetData.nScore - nRobScore;
	tbTargetKinData.nScore = tbTargetKinData.nScore - nRobScore;

	Boss:ZSCallClient(tbPlayerData.nConnectIdx, "ZCOnSyncPlayerInfoByKey", nPlayerId, {nScore = tbPlayerData.nScore});
	Boss:ZSCallClient(tbTargetData.nConnectIdx, "ZCOnSyncPlayerInfoByKey", tbTargetData.nPlayerId, {nScore = tbTargetData.nScore});

	local szMyServer = Sdk:GetServerDesc(tbPlayerData.nServerId);
	local szTargetServer = Sdk:GetServerDesc(tbTargetData.nServerId);
	local szMyMsg = string.format("成功抢夺到[FFFF0E]%d[-]点积分", nRobScore);
	local szTargetMsg = string.format("被[FFFF0E]%s「%s」[-]夺走了%d点积分", szMyServer, tbPlayerData.szName, nRobScore);
	if nRobScore == 0 then
		szMyMsg = "你尝试抢夺积分, 可惜并无所获..";
		szTargetMsg = string.format("[FFFF0E]%s「%s」[-]尝试抢夺您的积分, 可惜他技不如人，抢夺失败了", szMyServer, tbPlayerData.szName);
	end
	Boss:ZSCallClient(tbPlayerData.nConnectIdx, "ZCOnPlayerCall", nPlayerId, "Boss:OnMyMsg", szMyMsg);
	Boss:ZSCallClient(tbTargetData.nConnectIdx, "ZCOnPlayerCall", tbTargetData.nPlayerId, "Boss:OnMyMsg", szTargetMsg);

	local szBroadcastMsg = string.format("[FFFF0E]%s「%s」[-]成功夺走[FFFF0E]%s「%s」[-]%d点积分", szMyServer, tbPlayerData.szName, szTargetServer, tbTargetData.szName, nRobScore);
	if nRobScore == 0 then
		szBroadcastMsg = string.format("[FFFF0E]%s「%s」[-]尝试对[FFFF0E]%s「%s」[-]进行抢夺, 可惜技不如人", szMyServer, tbPlayerData.szName, szTargetServer, tbTargetData.szName);
	end
	Boss:ZSCallClient(tbPlayerData.nConnectIdx, "ZCOnBossKinMsg", tbPlayerData.nKinId, szBroadcastMsg);
	Boss:ZSCallClient(tbTargetData.nConnectIdx, "ZCOnBossKinMsg", tbTargetData.nKinId, szBroadcastMsg);

	Boss:ZSMarkRobTable(nPlayerUid, nTargetUid);
	self.bZSortRank = true;
end

function Boss:ZSReportRobProtectInfo(nPlayerUid, nProtectRobTime, nProtectRobFullTime)
	local tbPlayerData = Boss:ZSGetPlayerData(nPlayerUid);
	tbPlayerData.nProtectRobTime = math.max(nProtectRobTime, tbPlayerData.nProtectRobTime);
	tbPlayerData.nProtectRobFullTime = nProtectRobFullTime;
end

function Boss:ZSMarkRobTable(nPlayerUid, nTargetUid)
	local tbRobersMap = Boss:ZSGetCacheData("RobersMap");
	if not tbRobersMap[nTargetUid] then
		tbRobersMap[nTargetUid] = {};
	end

	tbRobersMap[nTargetUid][nPlayerUid] = true;
end

function Boss:ZSGetRobers(nPlayerUid)
	local tbRobersMap = Boss:ZSGetCacheData("RobersMap");
	return tbRobersMap[nPlayerUid];
end

local function ZSGetPlayerShowData(tbPlayerData, nRank)
	return {
			nRank           = nRank or tbPlayerData.nRank;
			nPlayerId       = tbPlayerData.nPlayerId;
			nKinId          = tbPlayerData.nKinId;
			nScore          = tbPlayerData.nScore;
			nProtectRobTime = tbPlayerData.nProtectRobTime;
			nHonorLevel     = tbPlayerData.nHonorLevel;
			szName          = tbPlayerData.szName;
			nServerId       = tbPlayerData.nServerId;
			nPortrait       = tbPlayerData.nPortrait;
			nFaction        = tbPlayerData.nFaction;
			tbPartner       = tbPlayerData.tbPartner;
			nLevel          = tbPlayerData.nLevel;
			nPlayerUid      = tbPlayerData.nPlayerUid;
		};
end

function Boss:ZSAskRobList(nPlayerId)
	local nPlayerUid = Boss:ZSGetPlayerUid(nPlayerId);
	local tbRobList = {};
	local nTopSelect = Boss.ZDef.nRobListTopSelect;

	local tbPlayerRank = Boss:ZSGetCacheData("PlayerRank");
	for nRank, tbPlayerData in ipairs(tbPlayerRank) do
		if nRank > nTopSelect then
			break;
		end

		table.insert(tbRobList, ZSGetPlayerShowData(tbPlayerData, nRank));
	end

	local tbRobers = Boss:ZSGetRobers(nPlayerUid) or {};
	for nRobId, _ in pairs(tbRobers) do
		local tbPlayerData = Boss:ZSGetPlayerData(nRobId);
		if tbPlayerData.nRank > nTopSelect and tbPlayerData.nRank ~= Boss.ZDef.nDefaultRank then
			table.insert(tbRobList, ZSGetPlayerShowData(tbPlayerData));
		end
	end

	local myData = Boss:ZSGetPlayerData(nPlayerUid) or {};
	local nMyRank = myData.nRank;
	if nMyRank and nMyRank ~= Boss.ZDef.nDefaultRank then
		local nUpSelectCount = 5;
		local nBeforeCount = 0;
		local nCurRank = nMyRank;

		while nBeforeCount < nUpSelectCount and nCurRank > nTopSelect do
			local tbPlayerData = tbPlayerRank[nCurRank];
			if tbPlayerData and not tbRobers[tbPlayerData.nPlayerUid] then
				nBeforeCount = nBeforeCount + 1;
				table.insert(tbRobList, ZSGetPlayerShowData(tbPlayerData));
			end

			nCurRank = nCurRank - 1;
		end
	end

	Boss:ZSCallClient(Server.nCurConnectIdx, "ZCOnPlayerCall", nPlayerId, "Boss:OnSyncRobList", tbRobList);
end

function Boss:ZSCheckRobState(tbPlayerData, tbTargetData)
	if not tbTargetData then
		return false, "抢夺对象不存在";
	end

	local nCurTime = GetTime();
	if nCurTime < tbPlayerData.nNextRobTime then
		return false, "抢夺冷却时间未到.";
	end

	if tbTargetData.nHonorLevel > tbPlayerData.nHonorLevel + Boss.ZDef.nRobMaxHigherHonorLevel then
		return false, "此人头衔太高，隐隐传来一股威压，请提升头衔後再尝试！";
	end

	if nCurTime < tbTargetData.nProtectRobTime then
		return false, "该侠士正与其他侠士交手，请稍後再尝试挑战";
	end

	if nCurTime < tbTargetData.nProtectRobFullTime then
		local nProtectBack = Boss.Def.nProtectRobCd + Boss.Def.nExtraProtectRobCd - Boss.Def.nRobBattleTime;
		tbTargetData.nProtectRobTime = tbTargetData.nProtectRobFullTime - nProtectBack;
		return false, "该侠士正与其他侠士交手，请稍後再尝试挑战";
	end

	if not tbTargetData.szAsyncData then
		return false, "该侠士数据异常，请稍後再试";
	end

	return true;
end

function Boss:ZSRobPlayer(nPlayerId, nTargetUid)
	local nPlayerUid = Boss:ZSGetPlayerUid(nPlayerId);
	local tbPlayerData = Boss:ZSGetPlayerData(nPlayerUid);
	local tbTargetData = Boss:ZSGetPlayerData(nTargetUid);

	local bRet, szMsg = Boss:ZSCheckRobState(tbPlayerData, tbTargetData);
	if not bRet then
		Boss:ZSCallClient(Server.nCurConnectIdx, "ZCOnPlayerCenterMsg", nPlayerId, szMsg);
		return;
	end

	local nProtectTime = 2;
	local nCurTime = GetTime();
	tbPlayerData.nNextRobTime = nCurTime + nProtectTime; -- 防止ws还没处理时多次调用
	tbTargetData.nProtectRobTime = nCurTime + nProtectTime;
	Boss:ZSCallClient(Server.nCurConnectIdx, "ZCRobTarget", nPlayerId, nTargetUid, tbTargetData);
end

function Boss:ZSCallClient(nIdx, szType, ...)
	return CallZoneClientScript(nIdx, "Boss:ZCOnZoneCall", szType, ...);
end

function Boss:ZSCallAllClient(szType, ...)
	-- Log("Boss:ZSCallAllClient", szType, ...)
	return CallZoneClientScript(-1, "Boss:ZCOnZoneCall", szType, ...);
end

local tbOnWorldClientCall = {
	ZSReportTimeFrame       = true;
	ZSReportKinData         = true;
--	ZSPreStart              = true;
	ZSReportPlayerData      = true;
	ZSReportKinDataByKey    = true;
	ZSReportPlayerDataByKey = true;
	ZSReportBossFightScore  = true;
	ZSAskRobList            = true;
	ZSRobPlayer             = true;
	ZSReportRobScore        = true;
	ZSReportRobProtectInfo  = true;
}

function Boss:ZSOnClientCall(szType, ...)
	-- Log("Boss:ZSOnClientCall", szType, ...);
	if not tbOnWorldClientCall[szType] then
		Log("ZSOnClientCall Error", szType, ...);
		return;
	end

	Boss[szType](Boss, ...);
end