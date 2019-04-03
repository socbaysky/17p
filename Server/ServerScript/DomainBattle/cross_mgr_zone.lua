Require("ServerScript/DomainBattle/cross_mgr.lua");

DomainBattle.tbCross = DomainBattle.tbCross or {};
local tbCross = DomainBattle.tbCross
local tbCrossDef = DomainBattle.tbCrossDef

function tbCross:GetCampCfg(nMapTemplateId)
	return self.tbCampCfg[nMapTemplateId] or {}
end

function tbCross:GetDynObsCfg(nMapTemplateId)
	return self.tbDynObsCfg[nMapTemplateId] or {}
end

function tbCross:GetTrapCfg(nMapTemplateId)
	return self.tbTrapCfg[nMapTemplateId] or {}
end

function tbCross:GetNpcCfg(nMapTemplateId)
	return self.tbNpcCfg[nMapTemplateId] or {}
end

function tbCross:InitMapCallBack()
	local fnOnCreate = function (tbMap, nMapId)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnMapCreate(tbMap.nMapTemplateId, nMapId);
		else
			Log("[Error]", "DomainBattleCross", "create map but not found tbInst", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnDestory = function (tbMap, nMapId)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnMapDestory();
		else
			Log("[Error]", "DomainBattleCross", "destory map but not found tbInst", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnMapLogin = function (tbMap, nMapId)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnMapLogin();
		else
			Log("[Error]", "DomainBattleCross", "login map but not found tbInst", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnEnter = function (tbMap, nMapId)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnMapEnter();
		else
			Log("[Error]", "DomainBattleCross", "enter map but not found tbInst", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnLeave = function (tbMap, nMapId)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnMapLeave();
		else
			Log("[Error]", "DomainBattleCross", "leave map but not found tbInst", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnPlayerTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnPlayerTrap(szTrapName);
		else
			Log("[Error]", "DomainBattleCross", "player trap but not found tbInst", tbMap.nMapTemplateId, nMapId, szTrapName)
		end
	end

	local fnOnNpcTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = self.tbInstList[nMapId];
		if tbInst then
			tbInst:OnNpcTrap(szTrapName);
		else
			Log("[Error]", "DomainBattleCross", "npc trap but not found tbInst", tbMap.nMapTemplateId, nMapId, szTrapName)
		end
	end

	for nMapTemplateId, _ in pairs(tbCrossDef.tbMapTemplateId2Info) do
		local tbMapClass = Map:GetClass(nMapTemplateId)
		tbMapClass.OnCreate = fnOnCreate;
		tbMapClass.OnDestroy = fnOnDestory;
		tbMapClass.OnEnter = fnOnEnter;
		tbMapClass.OnLeave = fnOnLeave;
		tbMapClass.OnNpcTrap = fnOnNpcTrap;
		tbMapClass.OnPlayerTrap = fnOnPlayerTrap;
		tbMapClass.OnLogin = fnOnMapLogin;
	end
end

function tbCross:OnRecvLocalData(tbData)
	local nServerId = Server:GetServerId(Server.nCurConnectIdx)
	Log("[Info]", "DomainBattleCross", "OnRecvLocalData", tostring(Server.nCurConnectIdx), tostring(nServerId))
	if self.nMaxNpcLevel < tbData.nMaxNpcLevel then
		self.nMaxNpcLevel = tbData.nMaxNpcLevel
	end

	if self.nSiegeBuffLevel < tbData.nSiegeBuffLevel then
		self.nSiegeBuffLevel = tbData.nSiegeBuffLevel
	end

	for nKinId, tbKinInfo in pairs( tbData.tbKinList ) do
		local nZoneKinId = KPlayer.ForceGetZoneKinIdByOrgId(nKinId, nServerId);
		tbKinInfo.nOrgKinId = tbKinInfo.nKinId
		tbKinInfo.nKinId = nZoneKinId
		tbKinInfo.nServerId = nServerId
		tbKinInfo.szName = tbKinInfo.szName
		tbKinInfo.szFullName = string.format("［%s］%s", Sdk:GetServerDesc(tbKinInfo.nServerId), tbKinInfo.szName)
		tbKinInfo.nPkCampIndex = self.nPkCampIndex
		tbKinInfo.tbUsedSupply = {}
		tbKinInfo.nSupplyDataVersion = 0
		self.nPkCampIndex =  self.nPkCampIndex + 1
		self.tbKinList[nZoneKinId] = tbKinInfo
		local tbCanUseSupplyPlayer = {}
		for nOrgPlayerId, _ in pairs( tbKinInfo.tbCanUseSupplyPlayer ) do
			tbCanUseSupplyPlayer[KPlayer.ForceGetZonePlayerIdByOrgId(nOrgPlayerId, nServerId)] = true
		end

		tbKinInfo.tbCanUseSupplyPlayer = tbCanUseSupplyPlayer
	end
	for nPlayerId, nKinId in pairs( tbData.tbAidList ) do
		local nZoneKinId = KPlayer.ForceGetZoneKinIdByOrgId(nKinId, nServerId);
		local nZonePlayerId = KPlayer.ForceGetZonePlayerIdByOrgId(nPlayerId, nServerId);
		self.tbAidList[nZonePlayerId] = nZoneKinId
		self.tbKinAidPlayer[nZoneKinId] = self.tbKinAidPlayer[nZoneKinId] or {}
		self.tbKinAidPlayer[nZoneKinId][nZonePlayerId] = true
	end

	Lib:Tree(tbData)
end

function tbCross:_PopMatchKins(tbOuterAssign)
	local tbAKin = tbOuterAssign[1]
	if not tbAKin then
		return
	end

	local tbBTempKin = tbOuterAssign[2]
	local tbBKin = nil
	local nBKinIndex = nil
	for i=2,#tbOuterAssign do
		local tbTempKin = tbOuterAssign[i]
		if tbTempKin.nServerId ~= tbAKin.nServerId then
			tbBKin = tbTempKin
			nBKinIndex = i
			break;
		end
	end

	if not tbBKin then
		--如果没有不同服的，只能取同服的
		tbBKin = tbBTempKin
		nBKinIndex = 2
	end

	if nBKinIndex then
		table.remove(tbOuterAssign, nBKinIndex)
	end

	table.remove(tbOuterAssign, 1)

	return tbAKin, tbBKin
end

function tbCross:GetOuterAssign()
	local nKinCount = Lib:CountTB(self.tbKinList)
	local nOuterCount = math.ceil(nKinCount/2); --2个家族一张外城地图
	local tbOuterAssign = {}
	local tbRetList = {}
	for _, tbKinInfo in pairs( self.tbKinList ) do
		table.insert(tbOuterAssign, tbKinInfo)
	end

	table.sort(tbOuterAssign, function (a, b)
		if a.nDomainType == b.nDomainType then
			if a.nRank == b.nRank then
				return a.nScore > b.nScore
			end

			return a.nRank < b.nRank
		end

		return a.nDomainType < b.nDomainType
	end)

	while #tbOuterAssign > 0 do
		local tbAKin, tbBKin = self:_PopMatchKins(tbOuterAssign)
		table.insert(tbRetList, {tbAKin and tbAKin.nKinId, tbBKin and tbBKin.nKinId})
	end

	if #tbRetList ~= nOuterCount then
		Log("[Error]", "DomainBattleCross", "OuterAssign Wrong Map Count")
		Lib:Tree(self.tbKinList)
		Lib:Tree(tbRetList)
	end

	return tbRetList
end

function tbCross:_CreateMapRequest(nMapType, ...)
	local tbMapClass =
	{
		[tbCrossDef.tbMapType.Outer] = DomainBattle.tbCrossOuter,
		[tbCrossDef.tbMapType.Inner] = DomainBattle.tbCrossInner,
		[tbCrossDef.tbMapType.King] = DomainBattle.tbCrossKing,
	}

	local arg = {...};
	local tbMapInfo = Lib:CopyTB(tbCrossDef.tbMapInfoList[nMapType])
	local nMapId = CreateMap(tbMapInfo.nTemplateId);
	local tbInst = Lib:NewClass(tbMapClass[nMapType], nMapId, tbMapInfo, unpack(arg))
	self.tbInstList[nMapId] = tbInst
	self.tbType2Inst[nMapType] = self.tbType2Inst[nMapType] or {};
	self.tbType2Inst[nMapType][nMapId] = tbInst

	Log("[Info]", "DomainBattleCross", "_CreateMapRequest", nMapType, nMapId)
end

function tbCross:CreateBattleMap()
	--[[if not self:CheckCrossDay() then
		return
	end]]

	local nKinCount = Lib:CountTB(self.tbKinList)
	if nKinCount <= 0 then
		return
	end

	Log("[Info]", "DomainBattleCross", "CreateBattleMap")

	self.tbType2Inst = {}
	self.tbInstList = {}
	self.tbPlayerList = {}

	local tbOuterAssign = self:GetOuterAssign()

	local nMapIndex = 1
	for _, tbKinPair in ipairs( tbOuterAssign ) do
		self:_CreateMapRequest(tbCrossDef.tbMapType.Outer, nMapIndex, tbKinPair)
		nMapIndex = nMapIndex + 1
	end

	nMapIndex = 1
	for i=1, #tbOuterAssign, 2 do
		local tbInnerKinList = {}
		Lib:MergeTable(tbInnerKinList, tbOuterAssign[i] or {})
		Lib:MergeTable(tbInnerKinList, tbOuterAssign[i + 1] or {})
		self:_CreateMapRequest(tbCrossDef.tbMapType.Inner, nMapIndex, tbInnerKinList)

		nMapIndex = nMapIndex + 1
	end

	self:_CreateMapRequest(tbCrossDef.tbMapType.King)
end

function tbCross:GetKingInst()
	local tbTypeList = self.tbType2Inst[tbCrossDef.tbMapType.King];
	if not tbTypeList or Lib:IsEmptyTB(tbTypeList) then
		Log("[Error]", "DomainBattleCross", "GetKingInst Failed No tbTypeList")
		return
	end

	local tbKingInst = nil
	for _, tbInst in pairs( tbTypeList ) do
		tbKingInst = tbInst
	end

	return tbKingInst
end

function tbCross:CallZoneClientScriptByKinId(nKinId, szFun, ...)
	local tbKinInfo = self.tbKinList[nKinId]
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "CallZoneClientScriptByKinId Failed Not Found Kin Info", nKinId, szFun)
		return
	end
	self:CallZoneClientScriptByServerId(tbKinInfo.nServerId, szFun, unpack({...}))
end

function tbCross:CallZoneClientScriptByServerId(nServerId, szFun, ...)
	local nServerConIdx = Server:GetConnectIdx(nServerId)
	if not nServerConIdx then
		Log("[Error]", "DomainBattleCross", "CallZoneClientScriptByServerId Failed Not Found Server Connection", nServerId, szFun)
		return
	end
	CallZoneClientScript(nServerConIdx, szFun, unpack({...}));
end

function tbCross:Start()
	--[[if not self:CheckCrossDay() then
		return
	end]]
	local nKinCount = Lib:CountTB(self.tbKinList)
	if nKinCount <= 0 then
		return
	end

	self.nCurStateIndex = 0;
	self:NextState();
end

function tbCross:NextState()
	local tbCurStateInfo = tbCrossDef.tbStateCfg[self.nCurStateIndex]
	if tbCurStateInfo then
		local szEndFun = tbCurStateInfo.szOnEndFun;
		if szEndFun and szEndFun ~= "" and self[szEndFun] then
			Lib:CallBack({ self[szEndFun], self})
		end
	end

	self.nMainTimer = nil;

	self.nCurStateIndex = self.nCurStateIndex + 1;
	local tbNextStateInfo = tbCrossDef.tbStateCfg[self.nCurStateIndex]
	if not tbNextStateInfo then
		return
	end

	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextStateInfo.nTime, self.NextState, self )
	self:SyncAllPlayerStateChange();
	local szStartFun = tbNextStateInfo.szOnStartFun;
	if szStartFun and szStartFun ~= "" and self[szStartFun] then
		Lib:CallBack({ self[szStartFun], self})
	end
end

function tbCross:GetStateLeftTime()
	if not self.nMainTimer then
		return 0
	end

	return math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS)
end

function tbCross:GetTotalLeftTime()
	if not self.nMainTimer or not self.nCurStateIndex then
		return 0
	end

	local nTotalTime = self:GetStateLeftTime()
	local nIndex = self.nCurStateIndex + 1
	while (tbCrossDef.tbStateCfg[nIndex]) do
		nTotalTime = nTotalTime + tbCrossDef.tbStateCfg[nIndex].nTime
		nIndex = nIndex + 1
	end

	return nTotalTime
end

function tbCross:SortRank()
	self:SortKinRank()
	self:SortPlayerRank()
	return true
end

function tbCross:ClearCrossBattleData()
	self.nKingCampAssignCounter = 1;
	self.tbKinRank = {}
	self.tbPlayerRank = {}

	self.tbOccupySyncInfo = {} --{[nMapId]={[szNpcName]=szKinName,},}
	self.tbTopKinSyncInfo = {} --{[nRank]={nRank=, nScore=, szName=, szMasterName=}}
	self.nTopKinSyncVersion = 0
	self.tbTopPlayerSyncInfo = {}
	self.nTopPlayerSyncVersion = 0

	self.tbKinList = {}

	self.tbAidList = {}
	self.tbKinAidPlayer = {}
end

function tbCross:StartPrepare()
	for nKinId, tbKinInfo in pairs( self.tbKinList ) do
		tbKinInfo.nScore = 0;
		tbKinInfo.nRank = 0;
		tbKinInfo.nLastScoreChange = 0;
		table.insert(self.tbKinRank, tbKinInfo)
		ChatMgr:CreateKinChatRoom(nKinId)
	end

	if self.nSortTimer then
		Timer:Close(self.nSortTimer)
		self.nSortTimer = nil
	end

	self.nSortTimer = Timer:Register(Env.GAME_FPS * 10, self.SortRank, self )
end

function tbCross:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
	if not self.nMainTimer or not self.nCurStateIndex then
		return false
	end

	local tbKinInfo = self:GetKinInfo(dwKinId);

	if not tbKinInfo then
		return false
	end

	local fnAddKinPlayerChatRoom = function (nMapId)
		if not nMapId then
			return
		end
		local tbPlayers = KPlayer.GetMapPlayer(nMapId)
		for _,pPlayer in ipairs(tbPlayers) do
			local nPlayerId = pPlayer.dwID
			local tbPlayerInfo = self:GetPlayerInfo(nPlayerId);
			if tbPlayerInfo and tbPlayerInfo.nKinId == dwKinId then
				local nPrivilege = ChatMgr.RoomPrivilege.emAudience;
				if tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] then
					nPrivilege = ChatMgr.RoomPrivilege.emSpeaker;
				end
				Kin:JoinChatRoom(pPlayer, nPrivilege);
			end
		end
	end

	for _, tbInst in pairs( self.tbInstList ) do
		fnAddKinPlayerChatRoom(tbInst.nMapId);
	end

	return true;
end

function tbCross:StartBattle()
	for _, tbInst in pairs( self.tbInstList ) do
		if tbInst.OnStartBattle then
				tbInst:OnStartBattle()
		end
	end
end

function tbCross:StartInnerCity()
	for _, tbInst in pairs( self.tbInstList ) do
		if tbInst.OnInnerCityStart then
				tbInst:OnInnerCityStart()
		end
	end
end

function tbCross:EndInnerCity()
	for _, tbInst in pairs( self.tbInstList ) do
		if tbInst.OnInnerCityEnd then
				tbInst:OnInnerCityEnd()
		end
	end
end

function tbCross:StartAward()
	Log("[Info]", "DomainBattleCross", "StartAward")

	if self.nSortTimer then
		Timer:Close(self.nSortTimer)
		self.nSortTimer = nil
	end

	self:SortRank()

	for _, tbInst in pairs( self.tbInstList ) do
		tbInst:OnStartAward()
	end

	--通知local 不能进入
	CallZoneClientScript(-1, "DomainBattle.tbCross:ClearAssignOuterCamp");

	CallZoneClientScript(-1, "Calendar:OnActivityEnd", "CrossDomainBattle");

	--结束时弹出战报界面
	for _, tbInst in pairs( self.tbInstList ) do
		KPlayer.MapBoardcastScript(tbInst.nMapId, "Ui:OpenWindow", "TerritoryCrossBattlefieldPanel");
	end

	local tbKinRankList = {}
	local tbFirstKin = nil
	for nRank, tbKinInfo in ipairs( self.tbKinRank ) do
		local tbRankInfo =
		{
			nServerId = tbKinInfo.nServerId,
			nKinId = tbKinInfo.nOrgKinId,
			nRank = nRank,
		}

		if nRank == 1 then
			tbRankInfo.szKinFullName = tbKinInfo.szFullName
			tbRankInfo.szKinName = tbKinInfo.szName
			tbRankInfo.nLeaderId = tbKinInfo.nLeaderId
			tbRankInfo.szLeaderName = tbKinInfo.szLeaderName
			tbRankInfo.nLeaderHonorLevel = tbKinInfo.nLeaderHonorLevel
			tbRankInfo.nLeaderFaction = tbKinInfo.nLeaderFaction
			tbRankInfo.nLeaderSex = tbKinInfo.nLeaderSex
			tbRankInfo.nLeaderResId = tbKinInfo.nLeaderResId
			tbRankInfo.tbLeaderPartRes = tbKinInfo.tbLeaderPartRes
			tbFirstKin = tbRankInfo;
		end

		tbKinRankList[tbKinInfo.nKinId] = tbRankInfo
	end

	CallZoneClientScript(-1, "DomainBattle.tbCross:NotifyFirstKin", tbFirstKin);

	for nRank, tbPlayerInfo in ipairs( self.tbPlayerRank ) do
		local tbKinRankInfo = tbKinRankList[tbPlayerInfo.nKinId]
		if tbKinRankInfo then
			tbKinRankInfo.tbPlayerList = tbKinRankInfo.tbPlayerList or {}
			table.insert(tbKinRankInfo.tbPlayerList, {nPlayerId=tbPlayerInfo.nOrgPlayerId, nRank=nRank, bAid = tbPlayerInfo.bAid})
		else
			Log("[Error]", "DomainBattleCross", "StartAward Not Found Player Kin Rank Info")
			Lib:Tree(tbPlayerInfo)
		end
	end

	Lib:Tree(tbKinRankList)

	for _, tbKinRankInfo in pairs( tbKinRankList ) do
		self:CallZoneClientScriptByServerId(tbKinRankInfo.nServerId, "DomainBattle.tbCross:OnLocalAward", tbKinRankInfo)
	end
end

function tbCross:EndBattle()
	Log("[Info]", "DomainBattleCross", "EndBattle")

	CallZoneClientScript(-1, "DomainBattle.tbCross:OnLocalEnd");

	for dwKinId, _ in pairs( self.tbKinList ) do
		ChatMgr:CloseKinChatRoom(dwKinId)
	end

	for _, tbInst in pairs( self.tbInstList ) do
		tbInst:OnBattleEnd()
	end

	--清除内存数据
	self:ClearCrossBattleData();
end

function tbCross:GetPlayerInfo(nPlayerId)
	return self.tbPlayerList[nPlayerId]
end

function tbCross:GetKinInfo(nKinId)
	return self.tbKinList[nKinId]
end

function tbCross:OnPlayerJoin(pPlayer)
	local nPlayerId = pPlayer.dwID
	local nAidKinId = self.tbAidList[nPlayerId]
	local nKinId = (nAidKinId and nAidKinId) or pPlayer.dwKinId
	local tbKinInfo = self:GetKinInfo(nKinId)
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "OnPlayerJoin Failed Not Found Kin Info", nPlayerId, nKinId)
		return
	end
	local tbPlayerInfo = self.tbPlayerList[nPlayerId]
	if not tbPlayerInfo then
		tbPlayerInfo = {
					nServerId = tbKinInfo.nServerId,
					nKinId = nKinId,
					nOrgKinId = tbKinInfo.nOrgKinId,
					nPlayerId = nPlayerId,
					nOrgPlayerId = pPlayer.dwOrgPlayerId,
					szName = pPlayer.szName,
					nScore = 0,
					nRank = 0,
					nKinRank = 0, --家族中的排名
					nLastScoreChange = 0,
					nKillCount = 0,
					nKillCombo = 0,
					bAid = self:IsAidPlayer(nPlayerId),
				}
		self.tbPlayerList[nPlayerId] = tbPlayerInfo

		table.insert(self.tbPlayerRank, tbPlayerInfo)
	end

	return tbPlayerInfo;
end

function tbCross:IsAidPlayer(nPlayerId)
	return self.tbAidList[nPlayerId] ~= nil
end

function tbCross:GetPlayerPkCamp(nPlayerId)
	local tbPlayerInfo = self.tbPlayerList[nPlayerId];
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "GetPlayerPkCamp Failed Not Found Player Info", nPlayerId)
		return 0
	end

	local tbKinInfo = self.tbKinList[tbPlayerInfo.nKinId];
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "GetPlayerPkCamp Failed Not Found Kin Info", nPlayerId, tbPlayerInfo.nKinId)
		Lib:Tree(tbPlayerInfo)
		return 0
	end

	return tbKinInfo.nPkCampIndex
end

function tbCross:OnNpcDeath(pNpc, pKillNpc)
	local nMapId = pNpc.nMapId
	local tbInst = self.tbInstList[nMapId]
	if not tbInst then
		Log("[Error]", "DomainBattleCross", "OnNpcDeath Failed Not Found Map Inst Info", pNpc.nId, nMapId)
		return
	end

	if not tbInst.OnNpcDeath then
		Log("[Error]", "DomainBattleCross", "OnNpcDeath Failed Not Found Inst OnNpcDeath Func", pNpc.nId, nMapId)
		Lib:Tree(tbInst)
		return
	end

	tbInst:OnNpcDeath(pNpc, pKillNpc);
end

function tbCross:OnWallDeath(pNpc, pKillNpc)
	local nMapId = pNpc.nMapId
	local tbInst = self.tbInstList[nMapId]
	if not tbInst then
		Log("[Error]", "DomainBattleCross", "OnWallDeath Failed Not Found Map Inst Info", pNpc.nId, nMapId)
		return
	end

	if not tbInst.OnWallDeath then
		Log("[Error]", "DomainBattleCross", "OnWallDeath Failed Not Found Inst OnWallDeath Func", pNpc.nId, nMapId)
		Lib:Tree(tbInst)
		return
	end

	tbInst:OnWallDeath(pNpc, pKillNpc);
end

function tbCross:AddKinScore(nKinId, nScore)
	local tbKinInfo = self.tbKinList[nKinId];
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "AddKinScore Failed Not Found Kin Info", nKinId, nScore)
		return
	end

	tbKinInfo.nScore = tbKinInfo.nScore + nScore
	tbKinInfo.nLastScoreChange = GetTime()
end

function tbCross:AddPlayerScore(nPlayerId, nScore)
	local tbPlayerInfo = self.tbPlayerList[nPlayerId];
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "AddPlayerScore Failed Not Found Player Info", nPlayerId, nScore)
		return false
	end

	tbPlayerInfo.nScore = tbPlayerInfo.nScore + nScore
	tbPlayerInfo.nLastScoreChange = GetTime()
	return true
end

function tbCross:AddKinPlayerScore(nKinId, nScore, szMsg)
	local nNow = GetTime()
	local function _AddScore(pPlayer, tbPlayerInfo)
		tbPlayerInfo.nScore = tbPlayerInfo.nScore + nScore
		tbPlayerInfo.nLastScoreChange = nNow
		if szMsg then
			pPlayer.CenterMsg(szMsg)
		end
	end

	self:ForEachKinPlayer(nKinId, _AddScore)
end

function tbCross:ForEachKinPlayer(nKinId, fnFunction)
	for nPlayerId, tbPlayerInfo in pairs( self.tbPlayerList ) do
		if tbPlayerInfo.nKinId == nKinId then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pPlayer then
				fnFunction(pPlayer, tbPlayerInfo)
			end
		end
	end
end

function tbCross:SortKinRank()
	self.nTopKinSyncVersion = self.nTopKinSyncVersion + 1
	self.tbTopKinSyncInfo = {}

	table.sort(self.tbKinRank, function (a, b)
		if a.nScore == b.nScore then
			return a.nLastScoreChange < b.nLastScoreChange
		end

		return a.nScore > b.nScore
	end)

	for nRank, tbKinInfo in ipairs( self.tbKinRank ) do
		tbKinInfo.nRank = nRank
		if nRank <= tbCrossDef.nMaxSyncTopKin then
			self.tbTopKinSyncInfo[nRank] =
			{
				nRank = nRank,
				nScore = tbKinInfo.nScore,
				nKinId = tbKinInfo.nKinId,
				szName = tbKinInfo.szFullName,
				szMasterName = tbKinInfo.szMasterName,
			}
		end
	end
end

function tbCross:SortPlayerRank()
	for _, tbKinTopPlayerInfo in pairs( self.tbTopPlayerSyncInfo ) do
		tbKinTopPlayerInfo.nVersion = tbKinTopPlayerInfo.nVersion or 0
		tbKinTopPlayerInfo.nVersion = tbKinTopPlayerInfo.nVersion + 1
		tbKinTopPlayerInfo.tbList = {}
	end

	table.sort(self.tbPlayerRank, function (a, b)
		if a.nScore == b.nScore then
			return a.nLastScoreChange < b.nLastScoreChange
		end

		return a.nScore > b.nScore
	end)

	for nRank, tbPlayerInfo in ipairs( self.tbPlayerRank ) do
		self.tbTopPlayerSyncInfo[tbPlayerInfo.nKinId] = self.tbTopPlayerSyncInfo[tbPlayerInfo.nKinId] or {}
		local tbKinTopPlayerInfo = self.tbTopPlayerSyncInfo[tbPlayerInfo.nKinId]
		tbKinTopPlayerInfo.nVersion = tbKinTopPlayerInfo.nVersion or 0
		tbKinTopPlayerInfo.tbList = tbKinTopPlayerInfo.tbList or {}
		tbPlayerInfo.nRank = nRank
		tbPlayerInfo.nKinRank = #tbKinTopPlayerInfo.tbList + 1
		if tbPlayerInfo.nKinRank <= tbCrossDef.nMaxSyncTopPlayer then
			table.insert(tbKinTopPlayerInfo.tbList,
				{
					nRank = tbPlayerInfo.nKinRank,
					nScore = tbPlayerInfo.nScore,
					nPlayerId = tbPlayerInfo.nPlayerId,
					szName = tbPlayerInfo.szName,
					nKillCount = tbPlayerInfo.nKillCount,
					bAid = tbPlayerInfo.bAid,
				});
		end
	end
end

function tbCross:GetKinSortedDmgInfo(tbDamageList)
	local tbSortedList = {};
	local tbKinDmgMap = {};

	--合并家族伤害列表
	for _, tbDmgInfo in ipairs(tbDamageList) do
		local nCaptainId = -1;
		local tbTeam = nil;
		if tbDmgInfo.nTeamId > 0 then
			tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId);
		end
		if tbTeam then
			nCaptainId = tbTeam:GetCaptainId();
		elseif tbDmgInfo.nAttackRoleId > 0 then
			nCaptainId = tbDmgInfo.nAttackRoleId;
		end

		if nCaptainId > 0 then
			local tbPlayerInfo  = self:GetPlayerInfo(nCaptainId)
			if tbPlayerInfo then
				local nKinId = tbPlayerInfo.nKinId
				if not tbKinDmgMap[nKinId] then
					tbKinDmgMap[nKinId] =
					{
						nKinId = nKinId,
						nOrgKinId = tbPlayerInfo.nOrgKinId,
						nDmg = 0,
					}
				end

				local tbInfo = tbKinDmgMap[nKinId]
				tbInfo.nDmg = tbInfo.nDmg + tbDmgInfo.nTotalDamage
			end
		end
	end

	for _, tbKinInfo in pairs( tbKinDmgMap ) do
		table.insert(tbSortedList,tbKinInfo)
	end

	local function fnDamageCmp(a, b)
		return a.nDmg > b.nDmg;
	end

	table.sort(tbSortedList, fnDamageCmp);

	return tbSortedList;
end
