Require("CommonScript/DomainBattle/define.lua");
Require("CommonScript/DomainBattle/cross_common.lua");
Require("ServerScript/DomainBattle/cross_mgr.lua");

DomainBattle.tbCrossBase = DomainBattle.tbCrossBase or {};
local tbCrossDef = DomainBattle.tbCrossDef
local tbDefine = DomainBattle.define
local tbCrossBase = DomainBattle.tbCrossBase
local tbCross = DomainBattle.tbCross
tbCrossBase.tbTrapFun = tbCrossBase.tbTrapFun or {}
tbCrossBase.tbOnSpawnNpcFun = tbCrossBase.tbOnSpawnNpcFun or {}
tbCrossBase.tbOnNpcDeathFun = tbCrossBase.tbOnNpcDeathFun or {}

function tbCrossBase:init(nMapId, tbMapInfo)
	if not nMapId then
		return
	end
	self.nMapId = nMapId
	self.szName = tbMapInfo.szName or ""
	self.nMapTemplateId = tbMapInfo.nTemplateId
	self.tbMapInfo = tbMapInfo
	self.tbDyncObsList = Lib:CopyTB(tbCross:GetDynObsCfg(self.nMapTemplateId));
	self.tbTrapList= Lib:CopyTB(tbCross:GetTrapCfg(self.nMapTemplateId));
	self.tbNpcList = Lib:CopyTB(tbCross:GetNpcCfg(self.nMapTemplateId));
	self.tbOccupyList = {} --{[nKinId]={[szNpcClass] = nCount}}
	self.tbBloodSyncNpcList = {}
	self.tbMiniMapInfo = {}
	self.nMiniMapVersion = 0

	Log("[Info]", "DomainBattleCross", "tbCrossBase:init", self.nMapId, self.nMapTemplateId, self.szName)
end

function tbCrossBase:OnMapCreate(nMapTemplateId, nMapId)
	self.bMapCreated = true;
	SetMapSurvivalTime(nMapId, GetTime()+tbCrossDef.nMapExsitTime)
	self:SpawnAllDynObs();
	self:SpawnAllPillar();
	Log("[Info]", "DomainBattleCross", "tbCrossBase:OnMapCreate", nMapTemplateId, nMapId)
end

function tbCrossBase:OnMapDestory(nMapTemplateId, nMapId)
	self.bMapCreated = false;
	Log("[Info]", "DomainBattleCross", "tbCrossBase:OnMapDestory", nMapTemplateId, nMapId)
end

function tbCrossBase:OnMapLogin()
	Log("tbCrossBase:OnMapLogin")
	local nPlayerId = me.dwID
	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossBase:OnMapLogin Not Found Player Info",
			self.nMapId, self.nMapTemplateId, self.szName, nPlayerId, me.szName)
		return
	end

	local tbKinInfo = tbCross:GetKinInfo(tbPlayerInfo.nKinId)

	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossBase:OnMapLogin Not Found Kin Info",
			self.nMapId, self.nMapTemplateId, self.szName, nPlayerId, me.szName)
		Lib:Tree(tbPlayerInfo);
		return
	end

	local nNow = GetTime()

	me.CallClientScript("DomainBattle.tbCross:OnEnterMap",
		DomainBattle.tbCross.nCurStateIndex, GetTime() + tbCross:GetStateLeftTime(), nNow + tbCross:GetTotalLeftTime(),
		self.tbBloodSyncNpcList, tbKinInfo.nKinId, tbKinInfo.szFullName)
end

function tbCrossBase:OnMapEnter()
	self:OnPlayerJoin(me)
end

function tbCrossBase:OnMapLeave()
	self:OnPlayerLeave(me)
end

function tbCrossBase:OnPlayerTrap(szTrapName)
	local tbTrapInfoList = self.tbTrapList[szTrapName]
	if not tbTrapInfoList then
		return
	end
	local _, tbDefault = next(tbTrapInfoList);

	if not tbDefault then
		return
	end

	local fnTrap = self.tbTrapFun[tbDefault.szTrapType]

	if fnTrap then
		fnTrap(self, me, tbDefault)
	end
end

function tbCrossBase:OnNpcTrap(szTrapName)
end

function tbCrossBase:OnPlayerJoin(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = tbCross:OnPlayerJoin(pPlayer)
	local tbKinInfo = tbCross:GetKinInfo(tbPlayerInfo.nKinId)

	if tbPlayerInfo.nDeathId then
		PlayerEvent:UnRegister(pPlayer, "OnDeath", tbPlayerInfo.nDeathId);
		tbPlayerInfo.nDeathId = nil
	end

	tbPlayerInfo.nDeathId = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);
	tbPlayerInfo.tbSkillState = tbPlayerInfo.tbSkillState or {};

	pPlayer.nFightMode = 0
	pPlayer.bForbidChangePk = 1;
	pPlayer.nInBattleState = 1;
	pPlayer.SetPkMode(Player.MODE_CUSTOM, tbCross:GetPlayerPkCamp(nPlayerId));

	local _, nPosX, nPosY = pPlayer.GetWorldPos();
	pPlayer.SetTempRevivePos(self.nMapId, nPosX, nPosY);

	pPlayer.dwKinId = tbPlayerInfo.nKinId

	local function _SetKinTitle()
		if tbPlayerInfo.bAid then
			local pTmpPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pTmpPlayer then
				pTmpPlayer.dwKinId = tbPlayerInfo.nKinId
				pTmpPlayer.SetKinTitle(string.format("%s·助战", tbKinInfo.szFullName))
				Kin:JoinChatRoom(pTmpPlayer);
			end
		end
	end

	local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_HORSE);
	if not pEquip then
		pPlayer.ResetAsyncExtEquip(Item.EQUIPPOS_HORSE);
	end

	Timer:Register(1, _SetKinTitle)

	local nPrivilege = ChatMgr.RoomPrivilege.emAudience;
	if tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] then
		nPrivilege = ChatMgr.RoomPrivilege.emSpeaker;
	end
	if not tbPlayerInfo.bAid then
		Kin:JoinChatRoom(pPlayer, nPrivilege);
	end

	local nNow = GetTime()

	pPlayer.CallClientScript("DomainBattle.tbCross:OnEnterMap",
		DomainBattle.tbCross.nCurStateIndex, GetTime() + tbCross:GetStateLeftTime(), nNow + tbCross:GetTotalLeftTime(),
		self.tbBloodSyncNpcList, tbKinInfo.nKinId, tbKinInfo.szFullName)
end

function tbCrossBase:OnPlayerLeave(pPlayer)
	local nPlayerId = pPlayer.dwID
	pPlayer.szComboSkillFun = nil;
	pPlayer.bOpenComboSkill = false;
	pPlayer.bForbidChangePk = 0;
	pPlayer.nInBattleState = 0;
	pPlayer.SetPkMode(Player.MODE_PEACE);
	pPlayer.ClearTempRevivePos();

	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "OnPlayerLeave Failed Not Found Player Info", nPlayerId)
		return 0
	end
	if tbPlayerInfo then
		if tbPlayerInfo.nDeathId then
			PlayerEvent:UnRegister(pPlayer, "OnDeath", tbPlayerInfo.nDeathId);
			tbPlayerInfo.nDeathId = nil;
		end

		for nSkillId, _ in pairs(tbPlayerInfo.tbSkillState) do
			pPlayer.RemoveSkillState(nSkillId);
		end
		tbPlayerInfo.tbSkillState = {};
	end

	ChatMgr:LeaveKinChatRoom(pPlayer);
end

function tbCrossBase:OnStartBattle()
	local tbEnableTrap =
	{
		["ToFight"] = true,
		["ToPeace"] = true,
	}
	self:SetTrapEnableByTypeList(tbEnableTrap, true)
end

function tbCrossBase:SpawnNpc(tbNpcInfo, nDelay, ...)
	local fnAddNpc = function (tbArg)
		if tbNpcInfo.nNpcId then
			local pNpc = KNpc.GetById(tbNpcInfo.nNpcId);
			if pNpc then
				Log("[Error]", "DomainBattleCross", "SpawnNpc Failed Already Exsit",
					tbNpcInfo.nNpcTemplate, tbCross.nMaxNpcLevel, self.nMapId, tbNpcInfo.nX, tbNpcInfo.nY)
				return
			else
				tbNpcInfo.nNpcId = nil
			end
		end

		local pNpc = KNpc.Add(tbNpcInfo.nNpcTemplate, tbCross.nMaxNpcLevel, 0, self.nMapId, tbNpcInfo.nX, tbNpcInfo.nY, 0, tbNpcInfo.nDir or 0)
		if pNpc then
			pNpc.SetName(tbNpcInfo.szNpcName)
			tbNpcInfo.nNpcId = pNpc.nId
			pNpc.tbNpcInfo = tbNpcInfo
			local fnOnSpawn = self.tbOnSpawnNpcFun[tbNpcInfo.szNpcClass]
			if fnOnSpawn then
				fnOnSpawn(self, tbNpcInfo, pNpc, unpack(tbArg))
			end
		else
			Log("[Error]", "DomainBattleCross", "SpawnAllNpc Add Npc Failed", tbNpcInfo.nNpcTemplate, tbCross.nMaxNpcLevel, self.nMapId, tbNpcInfo.nX, tbNpcInfo.nY)
		end
	end

	if nDelay and nDelay > 0 then
		Timer:Register(nDelay * Env.GAME_FPS, fnAddNpc, {...})
	else
		fnAddNpc({...})
	end
end

function tbCrossBase:DelNpc(tbNpcInfo)
	if tbNpcInfo.nNpcId then
		local pNpc = KNpc.GetById(tbNpcInfo.nNpcId);
		if pNpc then
			pNpc.Delete();
		end
		self.tbBloodSyncNpcList[tbNpcInfo.nNpcId] = nil
		tbNpcInfo.nNpcId = nil
	end

	if tbNpcInfo.szNpcClass == "cross_domain_pillar" then
		self:StopPillarTimer(tbNpcInfo);
	end
end

function tbCrossBase:SpawnAllPillar(nDelay)
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_pillar" then
			self:SpawnNpc(tbNpcInfo, nDelay)
		end
	end
end

function tbCrossBase:DelAllPillar()
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_pillar" then
			self:DelNpc(tbNpcInfo)
			tbNpcInfo.nOwnerKinId = -1;
			self:UpdateMiniMapInfo(tbNpcInfo.szMiniMapSyncKey, "")
		end
	end
	self:SyncBloodNpc()
end

function tbCrossBase:SpawnAllDynObs()
	for _, tbObsInfo in pairs( self.tbDyncObsList ) do
		local pNpc = KNpc.Add(tbObsInfo.nNpcTemplate, tbCross.nMaxNpcLevel, 0, self.nMapId, tbObsInfo.nX, tbObsInfo.nY, 0, tbObsInfo.nDir or 0)
		if pNpc then
			pNpc.SetPkMode(Player.MODE_CUSTOM, 0);
			pNpc.SetName(tbObsInfo.szName)
			tbObsInfo.nNpcId = pNpc.nId
			self.tbBloodSyncNpcList[tbObsInfo.nNpcId] = true
			CloseDynamicObstacle(self.nMapId, tbObsInfo.szType);
		else
			Log("[Error]", "DomainBattleCross", "SpawnDynObs Add Npc Failed", tbObsInfo.nNpcTemplate, tbCross.nMaxNpcLevel, self.nMapId, tbObsInfo.nX, tbObsInfo.nY)
		end

		self:UpdateMiniMapInfo(tbObsInfo.szMiniMapSyncKey, "")
	end
end

function tbCrossBase:DelDyncObs( tbObsInfo )
	local pNpc = KNpc.GetById(tbObsInfo.nNpcId or 0)
	if pNpc then
		pNpc.Delete();
	end
	OpenDynamicObstacle(self.nMapId, tbObsInfo.szType);
	tbObsInfo.nNpcId = nil
	self:UpdateMiniMapInfo(tbObsInfo.szMiniMapSyncKey, "（击破）")
end

function tbCrossBase:DelDyncObsByNpcId( nNpcId )
	for _, tbObsInfo in pairs( self.tbDyncObsList ) do
		if tbObsInfo.nNpcId == nNpcId then
			self:DelDyncObs( tbObsInfo )
		end
	end
end

function tbCrossBase:DelDyncObsByType( szType )
	for _, tbObsInfo in pairs( self.tbDyncObsList ) do
		if tbObsInfo.szType == szType then
			self:DelDyncObs(tbObsInfo)
		end
	end
end

function tbCrossBase:EnableTrap(tbTrapInfo)
	if tbTrapInfo.bEnable then
		return
	end

	local pNpc = KNpc.Add(73, 1, 0, self.nMapId, tbTrapInfo.nX, tbTrapInfo.nY);
	if not pNpc then
		Log("[Error]", "DomainBattleCross", "EnableTrap Failed Add Npc")
		Lib:Tree(tbTrapInfo)
		return
	end

	pNpc.SetName(tbTrapInfo.szTrapNpcName or "");
	tbTrapInfo.nNpcId = pNpc.nId
	tbTrapInfo.bEnable = true
	local tbPlayers = KNpc.GetAroundPlayerList(tbTrapInfo.nNpcId, 500) or {}
	for _, pPlayer in pairs(tbPlayers) do
		local pPlayerNpc = pPlayer.GetNpc();
		if pPlayerNpc then
			pPlayerNpc.CheckTrap();
		end
	end
end

function tbCrossBase:DisableTrap(tbTrapInfo)
	if not tbTrapInfo.bEnable then
		return
	end

	local pNpc = KNpc.GetById(tbTrapInfo.nNpcId)
	if pNpc then
		pNpc.Delete()
		tbTrapInfo.nNpcId = nil
	end

	tbTrapInfo.bEnable = false
end

function tbCrossBase:SetAllTrapEnable(bEnable)
	for _, tbTrapInfoList in pairs( self.tbTrapList ) do
		for _, tbTrapInfo in pairs( tbTrapInfoList ) do
			if bEnable then
				self:EnableTrap(tbTrapInfo)
			else
				self:DisableTrap(tbTrapInfo)
			end
		end
	end
end

function tbCrossBase:SetTrapEnableByTypeList(tbType, bEnable)
	for _, tbTrapInfoList in pairs( self.tbTrapList ) do
		for _, tbTrapInfo in pairs( tbTrapInfoList ) do
			if tbType[tbTrapInfo.szTrapType] then
				if bEnable then
					self:EnableTrap(tbTrapInfo)
				else
					self:DisableTrap(tbTrapInfo)
				end
			end
		end
	end
end

function tbCrossBase:SetTrapEnableByType(szType, bEnable)
	for _, tbTrapInfoList in pairs( self.tbTrapList ) do
		for _, tbTrapInfo in pairs( tbTrapInfoList ) do
			if tbTrapInfo.szTrapType == szType then
				if bEnable then
					self:EnableTrap(tbTrapInfo)
				else
					self:DisableTrap(tbTrapInfo)
				end
			end
		end
	end
end

function tbCrossBase:SetTrapEnableByName(szTrapName, bEnable)
	local tbTrapInfoList = self.tbTrapList[szTrapName]
	if not tbTrapInfoList then
		return
	end

	for _, tbTrapInfo in pairs( tbTrapInfoList ) do
		if bEnable then
			self:EnableTrap(tbTrapInfo)
		else
			self:DisableTrap(tbTrapInfo)
		end
	end
end

function tbCrossBase:UpdateMiniMapInfo(szSyncKey, szValue)
	if szSyncKey and szSyncKey ~= "" then
		self.tbMiniMapInfo[szSyncKey] = szValue;
		self.nMiniMapVersion = self.nMiniMapVersion + 1
	end
end

function tbCrossBase:OnPillarAddScore(tbNpcInfo)
	tbCross:AddKinScore(tbNpcInfo.nOwnerKinId, 20);
	return true
end

function tbCrossBase:StopPillarTimer(tbNpcInfo)
	if tbNpcInfo.nAddScoreTimer then
		Timer:Close(tbNpcInfo.nAddScoreTimer)
		tbNpcInfo.nAddScoreTimer = nil
	end
end

function tbCrossBase:OnNpcDeath(pNpc, pKillNpc)
	local nNpcId = pNpc.nId
	local tbNpcInfo = pNpc.tbNpcInfo
	if not tbNpcInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossBase:OnNpcDeath Failed Not Found NpcInfo", nNpcId)
		return
	end

	tbNpcInfo.nNpcId = nil

	local fnOnDeath = self.tbOnNpcDeathFun[tbNpcInfo.szNpcClass]
	if fnOnDeath then
		fnOnDeath(self, tbNpcInfo, pNpc, pKillNpc)
	end
end

function tbCrossBase:OnWallDeath(pNpc, pKillNpc)
	local nNpcId = pNpc.nId
	self:DelDyncObsByNpcId(nNpcId)

	local szMsg = string.format("%s已被摧毁！", pNpc.szName)
	local function _WallDeathMsg(pPlayer)
		pPlayer.SendBlackBoardMsg(szMsg)
	end

	self:ForEachInMap(_WallDeathMsg)
end

function tbCrossBase:OnPlayerDeath(pKillerNpc)
	me.Revive(0)
	me.nFightMode = 0
	local pMeNpc = me.GetNpc();
	if pMeNpc then
		pMeNpc.ClearAllSkillCD();
	end
	local tbPlayerInfo = tbCross:GetPlayerInfo(me.dwID)
	if tbPlayerInfo then
		tbPlayerInfo.nKillCombo = 0;
	end

	me.CallClientScript("DomainBattle:ShowComboKillCount", 0)

	if pKillerNpc then
		local pKillerPlayer = pKillerNpc.GetPlayer()
		if pKillerPlayer then
			self:OnKillPlayer(pKillerPlayer)
		end
	end
end

function tbCrossBase:OnKillPlayer(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if tbPlayerInfo then
		tbPlayerInfo.nKillCombo = tbPlayerInfo.nKillCombo + 1;
		tbPlayerInfo.nKillCount = tbPlayerInfo.nKillCount + 1;

		if tbPlayerInfo.nKillCombo % 10 == 0 then
			tbCross:CallZoneClientScriptByKinId(tbPlayerInfo.nKinId, "ChatMgr:SendSystemMsg", ChatMgr.SystemMsgType.Kin,
					string.format("「%s」在跨服攻城战中，连斩%s人！", pPlayer.szName, tbPlayerInfo.nKillCombo), tbPlayerInfo.nOrgKinId);
		end

		pPlayer.CallClientScript("DomainBattle:ShowComboKillCount", tbPlayerInfo.nKillCombo)

		tbCross:AddPlayerScore(nPlayerId, 50)

		CallZoneClientScript(pPlayer.nZoneIndex, "DomainBattle.tbCross:OnLocalKillPlayer", tbPlayerInfo.nOrgPlayerId)
	end
end

function tbCrossBase:ClearOccupyCount()
	self.tbOccupyList = {}
end

function tbCrossBase:_OnOccupyCountChange(tbNpcInfo, nOwnerKinId, nCount)
	self.tbOccupyList[nOwnerKinId] = self.tbOccupyList[nOwnerKinId] or {}
	local tbOldOccupyInfo = self.tbOccupyList[nOwnerKinId]
	local nOccupyCount = tbOldOccupyInfo[tbNpcInfo.szNpcClass] or 0;
	nOccupyCount = nOccupyCount + nCount
	if nOccupyCount < 0 then
		nOccupyCount = 0
	end
	tbOldOccupyInfo[tbNpcInfo.szNpcClass] = nOccupyCount
end

function tbCrossBase:OnOccupy(tbNpcInfo, nOwnerKinId)
	if tbNpcInfo.nOwnerKinId and tbNpcInfo.nOwnerKinId > 0 then
		self:_OnOccupyCountChange(tbNpcInfo, tbNpcInfo.nOwnerKinId, -1)
	end

	self:_OnOccupyCountChange(tbNpcInfo, nOwnerKinId, 1)
end

function tbCrossBase:OnAfterOccupy(tbNpcInfo, nOwnerKinId)

end

function tbCrossBase:GetOccupyCount( nKinId, szNpcClass )
	if not self.tbOccupyList[nKinId] then
		return 0
	end

	return self.tbOccupyList[nKinId][szNpcClass] or 0
end

function tbCrossBase:IsAllPillarOccupied()
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_pillar" then
			if not tbNpcInfo.nOwnerKinId or tbNpcInfo.nOwnerKinId <= 0 then
				return false
			end
		end
	end

	return true
end

function tbCrossBase:ForEachInMap(fnFunction)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbPlayer) do
		fnFunction(pPlayer);
	end
end

function tbCrossBase:UseSupply(pPlayer, nItemId)
	local tbItemUseInfo = tbCrossDef.tbBattleApplyIds[nItemId]
	if not tbItemUseInfo then
		return
	end

	local bRet, szMsg =  self[tbItemUseInfo[1]](self, pPlayer, unpack(tbItemUseInfo, 2))
	if szMsg then
		pPlayer.CenterMsg(szMsg, true)
	end

	return bRet
end

function tbCrossBase:UseItemCallDialogNpc(pPlayer, nNpcId, nDir, szItemName)
	local pPlayerNpc = pPlayer.GetNpc()
	if not pPlayerNpc then
		return
	end

	local tbPlayerInfo = tbCross:GetPlayerInfo(pPlayer.dwID)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = tbCross:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local tbNpcList = KNpc.GetAroundNpcList(pPlayerNpc, tbDefine.nCallNpcMinDistance);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.szClass == "corss_domain_change" then
			return false, "附近已有同类型"
		end
	end

	if pPlayer.nFightMode ~= 0 then
		return false, "请在营地中使用"
	end

	local nMapId, nX, nY = pPlayer.GetWorldPos()
	local pNpc = KNpc.Add(nNpcId, tbCross.nMaxNpcLevel, 0, nMapId, nX, nY, 0, nDir)
	if pNpc then
		pNpc.dwKinId = tbKinInfo.nKinId
		pNpc.SetTitle(tbKinInfo.szFullName)
		return true,  string.format("使用成功，身边出现了一个「%s」，请点击选择变身。", szItemName)
	end
end

function tbCrossBase:UseItemCallAttackNpc(pPlayer, nNpcId, nDir, szNpcName, nKillScore)
	local tbPlayerInfo = tbCross:GetPlayerInfo(pPlayer.dwID)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = tbCross:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	if pPlayer.nFightMode ~= 1 then
		return false, "请在战斗区域使用"
	end

	local nMapId, nX, nY = pPlayer.GetWorldPos()
	local pNpc = KNpc.Add(nNpcId, tbCross.nMaxNpcLevel, 0, nMapId, nX, nY, 0, nDir)
	if pNpc then
		pNpc.dwKinId = tbKinInfo.nKinId
		pNpc.nKillScore = nKillScore
		pNpc.SetTitle(tbKinInfo.szFullName)
		pNpc.SetPkMode(Player.MODE_CUSTOM, tbKinInfo.nPkCampIndex);
		return true, string.format("使用成功，身边出现了一个「%s」！", szNpcName)
	end
end

function tbCrossBase:ChangeToSiegeCar(pPlayer, nNpcId, nChangeSkillId, szText, nDuraSeconds)
	local tbPlayerInfo = tbCross:GetPlayerInfo(pPlayer.dwID)
	if not tbPlayerInfo then
		return
	end

	if pPlayer.GetNpc().nShapeShiftNpcTID ~= 0 then
		pPlayer.CenterMsg("您目前已经变身")
		return
	end

	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	if pPlayer.nFightMode ~= 0 then
		pPlayer.CenterMsg("请在营地使用")
		return
	end

	if nChangeSkillId then
		for nSkillId, _ in pairs(tbPlayerInfo.tbSkillState) do
			pPlayer.RemoveSkillState(nSkillId);
		end
		pPlayer.AddSkillState(nChangeSkillId, tbCross.nMaxNpcLevel,  0 , nDuraSeconds * Env.GAME_FPS)
		pPlayer.CenterMsg(string.format("成功变身为「%s」", szText))
		tbPlayerInfo.tbSkillState[nChangeSkillId] = 1;
	end

	pNpc.Delete();
end

function tbCrossBase:SyncBloodNpc()
	if IsLoadFinishMap(self.nMapId) then
		KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "BloodPanel", self.tbBloodSyncNpcList)
	end
end

function tbCrossBase:MiniMapInfoReq(pPlayer, nVersion)
	if nVersion == self.nMiniMapVersion then
		return
	end

	pPlayer.CallClientScript("DomainBattle.tbCross:OnSynMiniMapInfo", self.nMiniMapVersion, self.tbMiniMapInfo)
end

function tbCrossBase:OnStartAward()
	--关闭龙柱加分Timer
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.nAddScoreTimer then
			Timer:Close(tbNpcInfo.nAddScoreTimer)
			tbNpcInfo.nAddScoreTimer = nil
		end
	end

	self:SetAllTrapEnable(false)

	self.bStopBattle = true

	--将所有人的PK模式设置成和平
	local function _PkPeace(pPlayer)
		pPlayer.nFightMode = 0
		pPlayer.SetPkMode(Player.MODE_PEACE);
	end

	self:ForEachInMap(_PkPeace)
end

function tbCrossBase:OnBattleEnd()
	Timer:Register(Env.GAME_FPS, self.ZoneLogoutMapPlayer, self);
end

function tbCrossBase:ZoneLogoutMapPlayer()
	--分批传送玩家回本服
	local nCount = 0
	local function _ZoneLogout(pPlayer)
		if nCount < 30 then
			pPlayer.CallClientScript("Ui:CloseWindow", "TerritoryCrossBattlefieldPanel")
			ChatMgr:LeaveKinChatRoom(pPlayer);
			pPlayer.ZoneLogout()
		end
		nCount = nCount + 1;
	end

	self:ForEachInMap(_ZoneLogout)

	if nCount > 0 then
		Timer:Register(Env.GAME_FPS, self.ZoneLogoutMapPlayer, self);
	end
end

function tbCrossBase:CheckCanLeave(pPlayer)
	return true
end

function tbCrossBase:TrapToFight(pPlayer, tbTrapInfo)
	if not tbTrapInfo.bEnable then
		return
	end

	if #tbTrapInfo.tbToPos <=0 then
		Log("[Error]", "DomainBattleCross", "tbTrapFun:ToFight Failed No Tran Pos", pPlayer.dwID, pPlayer.szName)
		Lib:Tree(tbTrapInfo)
		return
	end

	if pPlayer.nFightMode ~= 0 then
		Log("[Error]", "DomainBattleCross", "tbTrapFun:ToFight Failed Wrong Fight Mode", pPlayer.dwID, pPlayer.szName, pPlayer.nFightMode)
		Lib:Tree(tbTrapInfo)
		return
	end

	local tbToPos = tbTrapInfo.tbToPos[MathRandom(#tbTrapInfo.tbToPos)]

	pPlayer.SetPosition(tbToPos.nX, tbToPos.nY)
	pPlayer.nFightMode = 1
	pPlayer.AddSkillState(1517, 1,  0 , 5 * Env.GAME_FPS)
end

function tbCrossBase:TrapToPeace(pPlayer, tbTrapInfo)
	if not tbTrapInfo.bEnable then
		return
	end

	if #tbTrapInfo.tbToPos <=0 then
		Log("[Error]", "DomainBattleCross", "tbTrapFun:ToPeace Failed No Tran Pos", pPlayer.dwID, pPlayer.szName)
		Lib:Tree(tbTrapInfo)
		return
	end

	if pPlayer.nFightMode ~= 1 then
		Log("[Error]", "DomainBattleCross", "tbTrapFun:ToPeace Failed Wrong Fight Mode", pPlayer.dwID, pPlayer.szName, pPlayer.nFightMode)
		Lib:Tree(tbTrapInfo)
		return
	end

	local tbToPos = tbTrapInfo.tbToPos[MathRandom(#tbTrapInfo.tbToPos)]

	pPlayer.SetPosition(tbToPos.nX, tbToPos.nY)
	pPlayer.nFightMode = 0
end

function tbCrossBase.tbTrapFun:ToFight(pPlayer, tbTrapInfo)
	self:TrapToFight(pPlayer, tbTrapInfo)
end

function tbCrossBase.tbTrapFun:ToPeace(pPlayer, tbTrapInfo)
	self:TrapToPeace(pPlayer, tbTrapInfo)
end

function tbCrossBase.tbOnSpawnNpcFun:cross_domain_pillar(tbNpcInfo, pNpc, nKinId)
	nKinId = nKinId or -1
	tbNpcInfo.nOwnerKinId = nKinId
	local tbKinInfo = tbCross:GetKinInfo(nKinId or -1)
	local szNpcTitle = string.format("%s", (tbKinInfo and tbKinInfo.szFullName) or "无人占据")
	local szNpcName = pNpc.szName
	pNpc.SetPkMode(Player.MODE_CUSTOM, (tbKinInfo and tbKinInfo.nPkCampIndex) or 0);
	pNpc.SetTitle(szNpcTitle)

	pNpc.AddSkillState(tbDefine.tbDoorBuff[1], tbCross.nSiegeBuffLevel,  0 , 3600 * Env.GAME_FPS)
	pNpc.AddFightSkill(tbDefine.tbFlagBuff[1], tbCross.nSiegeBuffLevel)
	pNpc.AddSkillState(tbCrossDef.nPillarInvincibleBuffId, 1,  0 , tbCrossDef.nPillarInvincibleTime * Env.GAME_FPS)

	for _,tbWarningInfo in ipairs(tbCrossDef.tbPillarWarningHp) do
		Npc:RegisterNpcHpPercent(pNpc, tbWarningInfo.nPercent, function ()
			if tbNpcInfo.nNpcId == pNpc.nId and tbNpcInfo.nOwnerKinId and tbNpcInfo.nOwnerKinId > 0 then
				local tbOwnerKinInfo = tbCross:GetKinInfo(tbNpcInfo.nOwnerKinId)
				tbCross:CallZoneClientScriptByKinId(tbNpcInfo.nOwnerKinId, "ChatMgr:SendSystemMsg", ChatMgr.SystemMsgType.Kin,
						string.format("本帮派的%s——%s%s！", self.szName, szNpcName, tbWarningInfo.szMsg or ""), tbOwnerKinInfo.nOrgKinId);
			end
		end)
	end

	self.tbBloodSyncNpcList[pNpc.nId] = true

	local tbOwnerKinInfo
	if nKinId > 0 then
		tbNpcInfo.nAddScoreTimer = Timer:Register(tbCrossDef.nPillarAddScoreInterval * Env.GAME_FPS, self.OnPillarAddScore, self, tbNpcInfo)

		tbOwnerKinInfo = tbCross:GetKinInfo(nKinId)

		self:UpdateMiniMapInfo(tbNpcInfo.szMiniMapSyncKey, szNpcTitle)
	else
		self:UpdateMiniMapInfo(tbNpcInfo.szMiniMapSyncKey, "")
	end
	tbCross:OnUpdateOccupySyncInfo(self.nMapId, tbNpcInfo, tbOwnerKinInfo)
	self:SyncBloodNpc()
end

function tbCrossBase.tbOnNpcDeathFun:cross_domain_pillar(tbNpcInfo, pNpc, pKillerNpc)
	self:StopPillarTimer(tbNpcInfo)
	self.tbBloodSyncNpcList[pNpc.nId] = nil
	if self.bStopBattle then
		return
	end

	local szNpcName = pNpc.szName
	local tbDamage = pNpc.GetDamageInfo() or {};
	local tbSortedKinList = tbCross:GetKinSortedDmgInfo(tbDamage)
	local nOwnerKinId = nil;
	local nOrgOwnerKinId = nil;
	local nKillerPlayerId = pKillerNpc and pKillerNpc.dwPlayerID;
	local tbKillerPlayerInfo = tbCross:GetPlayerInfo(nKillerPlayerId or 0)
	if tbKillerPlayerInfo then
		nOwnerKinId = tbKillerPlayerInfo.nKinId
		nOrgOwnerKinId = tbKillerPlayerInfo.nOrgKinId
	end

	if #tbSortedKinList > 0 then
		nOwnerKinId = tbSortedKinList[1].nKinId
		nOrgOwnerKinId = tbSortedKinList[1].nOrgKinId
	end

	if nOwnerKinId then
		self:OnOccupy(tbNpcInfo, nOwnerKinId)
		tbCross:AddKinPlayerScore(nOwnerKinId, 200, string.format("帮派成功摧毁%s获得了%d积分！", szNpcName, 200))

		tbCross:CallZoneClientScriptByKinId(nOwnerKinId, "ChatMgr:SendSystemMsg", ChatMgr.SystemMsgType.Kin,
					string.format("本帮派成功占据了%s——%s！", self.szName, szNpcName), nOrgOwnerKinId);
	end

	if tbNpcInfo.nOwnerKinId and tbNpcInfo.nOwnerKinId > 0 then
		local tbOldOwnerKin = tbCross:GetKinInfo(tbNpcInfo.nOwnerKinId)
		tbCross:CallZoneClientScriptByKinId(tbNpcInfo.nOwnerKinId, "ChatMgr:SendSystemMsg", ChatMgr.SystemMsgType.Kin,
					string.format("本帮派的%s——%s已被摧毁！", self.szName, szNpcName), tbOldOwnerKin.nOrgKinId);
	end

	self:SpawnNpc(tbNpcInfo, 0, nOwnerKinId)

	self:SyncBloodNpc()

	self:OnAfterOccupy(tbNpcInfo, nOwnerKinId)
end

