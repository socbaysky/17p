Require("CommonScript/DomainBattle/define.lua");
Require("CommonScript/DomainBattle/cross_common.lua");
Require("ServerScript/DomainBattle/cross_base.lua");

DomainBattle.tbCrossWithThrone = DomainBattle.tbCrossWithThrone or Lib:NewClass(DomainBattle.tbCrossBase)

local tbCrossDef = DomainBattle.tbCrossDef
local tbCrossBase = DomainBattle.tbCrossBase
local tbCrossWithThrone = DomainBattle.tbCrossWithThrone
local tbCross = DomainBattle.tbCross

tbCrossWithThrone.tbTrapFun = Lib:CopyTB(tbCrossBase.tbTrapFun or {})
tbCrossWithThrone.tbOnSpawnNpcFun = Lib:CopyTB(tbCrossBase.tbOnSpawnNpcFun or {})
tbCrossWithThrone.tbOnNpcDeathFun = Lib:CopyTB(tbCrossBase.tbOnNpcDeathFun or {})

function  tbCrossWithThrone:init()
	Log("[Info]", "DomainBattleCross", "tbCrossWithThrone:init")
end

function tbCrossWithThrone:OnMapCreate(nMapTemplateId, nMapId)
	tbCrossBase.OnMapCreate(self, nMapTemplateId, nMapId)
	self:SpawnThrone();
	Log("[Info]", "DomainBattleCross", "tbCrossWithThrone:OnMapCreate", nMapTemplateId, nMapId)
end


function tbCrossWithThrone:OnMapLeave()
	tbCrossBase.OnMapLeave(self)

	local nPlayerId = me.dwID
	if nPlayerId == self.nOccupyThronePlayerId then
		self:ClearThroneFight()
	end

end

function tbCrossWithThrone:OnBattleEnd()
	tbCrossBase.OnBattleEnd(self)
	self:ClearThroneFight();
end

function tbCrossWithThrone:ClearThroneFight()
	if not self.nOccupyThronePlayerId then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(self.nOccupyThronePlayerId);
	local pPlayerNpc
	if pPlayer then
		pPlayer.SetPkMode(Player.MODE_CUSTOM, tbCross:GetPlayerPkCamp(self.nOccupyThronePlayerId));
		pPlayer.RemoveSkillState(3549);
		pPlayerNpc = pPlayer.GetNpc()
	end
	if pPlayerNpc then
		pPlayerNpc.RestoreAction()
	end

	local pThrone = self:GetThroneFightNpc()
	if pThrone then
		local nHideNpcId = pThrone.nHideNpcId
		pThrone.nHideNpcId = nil
		self.tbBloodSyncNpcList[pThrone.nId] = nil

		pThrone.Delete();

		if nHideNpcId then
			local pHideNpc = KNpc.GetById(nHideNpcId);
			if pHideNpc then
				pHideNpc.Delete()
			end
		end

		self:SpawnThrone();
	end

	if self.nOccupyThroneTimer then
		Timer:Close(self.nOccupyThroneTimer)
	end

	self.nOccupyThroneTimer = nil
	self.nOccupyThronePlayerId = nil
	self.nOccupyThroneKinId = nil

	self:SyncBloodNpc()
end

function tbCrossWithThrone:SpawnThrone(nDelay)
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_throne" then
			self:SpawnNpc(tbNpcInfo, nDelay)
		end
	end
end

function tbCrossWithThrone:SpawnThroneFight(nDelay, nKinId, nPlayerId)
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_throne_fight" then
			self:SpawnNpc(tbNpcInfo, nDelay, nKinId, nPlayerId)
		end
	end
end

function tbCrossWithThrone:GetThroneNpc()
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_throne" then
			return tbNpcInfo.nNpcId and KNpc.GetById(tbNpcInfo.nNpcId), tbNpcInfo
		end
	end
end

function tbCrossWithThrone:GetThroneFightNpc()
	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_throne_fight" then
			return tbNpcInfo.nNpcId and KNpc.GetById(tbNpcInfo.nNpcId), tbNpcInfo
		end
	end
end

function tbCrossWithThrone:IsCanOccupyThrone()
	return true
end

function tbCrossWithThrone:OccupyThroneReq(pPlayer)
	if self.nOccupyThronePlayerId or not self:IsCanOccupyThrone() then
		pPlayer.SendBlackBoardMsg("临安王城内龙柱均被占据後，开启王座争夺")
		return
	end

	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = tbCross:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local pPlayerNpc = pPlayer.GetNpc();

	if not pPlayerNpc or pPlayerNpc.nShapeShiftNpcTID ~= 0 then
		pPlayer.CenterMsg("处於变身状态时不能操作")
		return
	end

	local pThroneNpc, tbNpcInfo = self:GetThroneNpc()

	if not pThroneNpc then
		Log("[Error]", "DomainBattleCross", "tbCrossWithThrone.OccupyThroneReq Failed Not Found ThroneNpc", nPlayerId)
		return
	end

	tbNpcInfo.nNpcId = nil
	local nHideNpcId = pThroneNpc.nHideNpcId
	pThroneNpc.nHideNpcId = nil

	pThroneNpc.Delete();

	if nHideNpcId then
		local pHideNpc = KNpc.GetById(nHideNpcId);
		if pHideNpc then
			pHideNpc.Delete()
		end
	end

	self.nOccupyThronePlayerId = nPlayerId
	self.nOccupyThroneKinId = tbKinInfo.nKinId

	self.nOccupyThroneTimer = Timer:Register(tbCrossDef.nPillarAddScoreInterval * Env.GAME_FPS, self.OnThroneAddScore, self)

	self:SpawnThroneFight(0, self.nOccupyThroneKinId, self.nOccupyThronePlayerId)

	tbCross:AddPlayerScore(nPlayerId, 600);
end

function tbCrossWithThrone:OnThroneAddScore()
	tbCross:AddPlayerScore(self.nOccupyThronePlayerId, 50);
	return true
end

function tbCrossWithThrone:_ThroneSpawnFix(pNpc)
	--处理王座碰撞问题
	local nMapId, nX, nY = pNpc.GetWorldPos();
	local pHideAttachNpc = KNpc.Add(2853, 1, 0, nMapId, nX - 100, nY - 100, 0, 0);
	local nHideNpcId = pHideAttachNpc.nId
	local tbPlayers = KNpc.GetAroundPlayerList(nHideNpcId, 500) or {}
	for _, pPlayer in pairs(tbPlayers) do
		pPlayer.SyncNpc(nHideNpcId)
	end

	pNpc.nHideNpcId = nHideNpcId
	pNpc.InitLinkAttach(Npc.AttachType.npc_attach_npc_pos, 0, 0, 0);
	pNpc.SetLinkAttachEvent(0, 0);
	pNpc.SetLinkAttachParam(1, nHideNpcId);
	pNpc.SetLinkAttachParam(2, 100);
	pNpc.SetLinkAttachParam(3, 100);
	pNpc.SetLinkAttachParam(4, 0);
	pNpc.SetLinkAttachParam(5, 0);
	pNpc.SetLinkAttachParam(6, 0);
	pNpc.EndLinkAttach();
end

function tbCrossWithThrone:OnStartAward()
	tbCrossBase.OnStartAward(self)
	--关闭王座加分Timer
	if self.nOccupyThroneTimer then
		Timer:Close(self.nOccupyThroneTimer)
		self.nOccupyThroneTimer = nil
	end
end

function tbCrossWithThrone:CheckCanLeave(pPlayer)
	if self.nOccupyThronePlayerId == pPlayer.dwID then
		pPlayer.SendBlackBoardMsg("当前状态不能离开")
		return false
	end
	return true;
end

function tbCrossWithThrone.tbOnSpawnNpcFun:cross_domain_throne(tbNpcInfo, pNpc)
	self:_ThroneSpawnFix(pNpc)
	tbCross:OnUpdateOccupySyncInfo(self.nMapId, tbNpcInfo, nil)
	self:UpdateMiniMapInfo(tbNpcInfo.szMiniMapSyncKey, "")
end

function tbCrossWithThrone.tbOnSpawnNpcFun:cross_domain_throne_fight(tbNpcInfo, pNpc, nKinId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	local pPlayerNpc = pPlayer.GetNpc()
	if not pPlayer or not pPlayerNpc then
		Log("[Error]", "DomainBattleCross", "spawn cross_domain_throne_fight Failed No Player", nKinId, nPlayerId)
		pNpc.Delete();
		self:SpawnThrone()
		return
	end

	nKinId = nKinId or -1
	tbNpcInfo.nOwnerKinId = nKinId
	local tbKinInfo = tbCross:GetKinInfo(nKinId or -1)
	local szNpcTitle = string.format("%s", (tbKinInfo and tbKinInfo.szFullName) or "无人占据")

	pNpc.SetPkMode(Player.MODE_CUSTOM, (tbKinInfo and tbKinInfo.nPkCampIndex) or 0);
	pNpc.SetTitle(szNpcTitle)
	local szNpcName = pNpc.szName
	pNpc.SetName(string.format("「%s」占领的%s", pPlayer.szName, szNpcName))

	self.tbBloodSyncNpcList[pNpc.nId] = true

	self:_ThroneSpawnFix(pNpc)

	local _, nX, nY = pNpc.GetWorldPos();

	ActionMode:DoChangeActionMode(pPlayer, Npc.NpcActionModeType.act_mode_none)
	pPlayer.SetPosition(nX - 35, nY - 5);
	pPlayerNpc.SetDir(48)
	pPlayerNpc.DoCommonAct(39, 10015);
	pPlayer.SetPkMode(Player.MODE_PEACE);

	--隐藏玩家名字和血量
	pPlayer.AddSkillState(3549, 1,  0 , 10000000)
	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if tbPlayerInfo then
		tbPlayerInfo.tbSkillState[3549] = 1;
	end

	tbCross:OnUpdateOccupySyncInfo(self.nMapId, tbNpcInfo, tbKinInfo)

	self:SyncBloodNpc()

	self:UpdateMiniMapInfo(tbNpcInfo.szMiniMapSyncKey, szNpcTitle)

	if nKinId > 0 then
		tbCross:CallZoneClientScriptByKinId(nKinId, "ChatMgr:SendSystemMsg", ChatMgr.SystemMsgType.Kin,
						string.format("帮派成员「%s」成功占据了%s——%s！", pPlayer.szName, self.szName, szNpcName), tbKinInfo.nOrgKinId);
	end
end

function tbCrossWithThrone.tbOnNpcDeathFun:cross_domain_throne_fight(tbNpcInfo, pNpc, pKillerNpc)
	if self.bStopBattle then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(self.nOccupyThronePlayerId);
	if pPlayer then
		pPlayer.RemoveSkillState(3549);
		local pPlayerNpc = pPlayer.GetNpc()
		if pPlayerNpc then
			pPlayerNpc.DoDeath(pKillerNpc.nId)
		end
	end

	self:ClearThroneFight();

	self:SpawnThrone();
end
