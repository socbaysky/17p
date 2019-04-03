Require("CommonScript/DomainBattle/define.lua");
Require("CommonScript/DomainBattle/cross_common.lua");
Require("ServerScript/DomainBattle/cross_base.lua");
Require("ServerScript/DomainBattle/cross_mgr.lua");

DomainBattle.tbCrossOuter = DomainBattle.tbCrossOuter or Lib:NewClass(DomainBattle.tbCrossBase)

local tbCrossDef = DomainBattle.tbCrossDef
local tbCrossBase = DomainBattle.tbCrossBase
local tbCrossOuter = DomainBattle.tbCrossOuter
local tbCross = DomainBattle.tbCross

tbCrossOuter.tbTrapFun = Lib:CopyTB(tbCrossBase.tbTrapFun or {})
tbCrossOuter.tbOnSpawnNpcFun = Lib:CopyTB(tbCrossBase.tbOnSpawnNpcFun or {})
tbCrossOuter.tbOnNpcDeathFun = Lib:CopyTB(tbCrossBase.tbOnNpcDeathFun or {})

function  tbCrossOuter:init(nMapId, _, nIndex, tbKinList)
	self.tbTransferRight = {}
	self.nTransferRightVersion = 0
	if not nIndex then
		return
	end

	self.nIndex = nIndex
	self.tbKinList = {unpack(tbKinList)}
	self.tbKinCamp = {}
	for nCampIndex, nKinId in ipairs( self.tbKinList ) do
		local tbKinInfo = tbCross:GetKinInfo(nKinId)
		self.tbKinCamp[nKinId] = nCampIndex
		tbKinInfo.nOuterMapId = nMapId
		Lib:Tree(tbKinInfo)
	end
	Log("[Info]", "DomainBattleCross", "tbCrossOuter:init")
end

function tbCrossOuter:OnMapCreate(nMapTemplateId, nMapId)
	tbCrossBase.OnMapCreate(self, nMapTemplateId, nMapId);
	for nIndex, nKinId in ipairs( self.tbKinList ) do
		local tbKinInfo = tbCross:GetKinInfo(nKinId)
		tbCross:OnAssignOuterCamp(nKinId, nMapTemplateId, nMapId, nIndex)
		tbCross:CallZoneClientScriptByKinId(nKinId, "DomainBattle.tbCross:OnAssignOuterCamp", tbKinInfo.nOrgKinId, nMapTemplateId, nMapId, nIndex);
	end
end

function tbCrossOuter:OnStartBattle()
	if tbCrossBase.OnStartBattle then
		tbCrossBase.OnStartBattle(self)
	end

	local tbEnableTrap =
	{
		["ToKing"] = true,
	}
	self:SetTrapEnableByTypeList(tbEnableTrap, true)

	--启动计时器通知内城阶段
	self.nInnerNotifyTimer = Timer:Register((tbCross:GetStateLeftTime() - 30) * Env.GAME_FPS, self.OnInnerNotify, self)

	--传送门出现特效
	self.nInnerEffectTimer = Timer:Register((tbCross:GetStateLeftTime() - 2) * Env.GAME_FPS, self.OnInnerEffect, self)
end

function tbCrossOuter:OnInnerNotify()
	self.nInnerNotifyTimer = nil
	local nLeftTime = tbCross:GetStateLeftTime()
	local szMsg = string.format("龙柱异变，伴随着地动山摇，似是有一密道逐渐形成（%d秒後）", nLeftTime)
	local function _InnerNotifyMsg(pPlayer)
		pPlayer.SendBlackBoardMsg(szMsg)
	end

	self:ForEachInMap(_InnerNotifyMsg)

	if nLeftTime <= 10 then
		return
	end

	self.nInnerNotifyTimer = Timer:Register(10 * Env.GAME_FPS, self.OnInnerNotify, self)
end

function tbCrossOuter:OnInnerEffect()
	self.nInnerEffectTimer = nil

	for _, tbNpcInfo in pairs( self.tbNpcList ) do
		if tbNpcInfo.szNpcClass == "cross_domain_pillar" and tbNpcInfo.nNpcId then
			local pNpc = KNpc.GetById(tbNpcInfo.nNpcId);
			if pNpc then
				local _, nNpcX, nNpcY = pNpc.GetWorldPos()
				pNpc.CastSkill(4904, 1, nNpcX, nNpcY)
			end
		end
	end
end

function tbCrossOuter:OnOccupy(tbNpcInfo, nOwnerKinId)
	tbCrossBase.OnOccupy(self, tbNpcInfo, nOwnerKinId);
	if tbNpcInfo.szNpcClass == "cross_domain_pillar" and
		self:GetOccupyCount(nOwnerKinId, tbNpcInfo.szNpcClass) >= 2 then

		self:AddTransferRight(nOwnerKinId)
	end
end

function tbCrossOuter:AddTransferRight(nKinId)
	--至少有60秒的传送时间
	self.tbTransferRight[nKinId] = GetTime() + 60

	local tbKinInfo = tbCross:GetKinInfo(nKinId)

	local szMsg = "成功占领两根龙柱，临安王城密道已对本帮派开放，请火速前往[FFFE0D]（限制进入40人）[-]"
	tbCross:CallZoneClientScriptByKinId(nKinId, "ChatMgr:SendSystemMsg", ChatMgr.SystemMsgType.Kin,
		szMsg, tbKinInfo.nOrgKinId);

	local function _RightMsg(pPlayer, tbPlayerInfo)
		pPlayer.SendBlackBoardMsg(szMsg)
	end

	tbCross:ForEachKinPlayer(nKinId, _RightMsg)
end

function tbCrossOuter:IsCanTranferToKing(nKinId)
	if self:GetOccupyCount(nKinId, "cross_domain_pillar") >= 2 then
		return true
	end

	local nRightTime = self.tbTransferRight[nKinId] or 0
	return nRightTime >= GetTime()
end

function tbCrossOuter:OnInnerCityStart()
	if tbCrossBase.OnInnerCityStart then
		tbCrossBase.OnInnerCityStart(self)
	end
	self:DelAllPillar()
	self:ClearOccupyCount()
	self:SetTrapEnableByType("ToKing", false)
	self:SetTrapEnableByType("ToInner", true)

	self:UpdateMiniMapInfo("ZY_Longzhu_Z", "内城密道")
	self:UpdateMiniMapInfo("ZY_Longzhu_B", "内城密道")
	self:UpdateMiniMapInfo("ZY_Longzhu_N", "内城密道")

	local szMsg = string.format("龙柱位置出现了通往临安内城的密道，请火速前往")
	local function _InnerNotifyMsg(pPlayer)
		pPlayer.SendBlackBoardMsg(szMsg)
		self:SyncKingTransferRightInfoReq(pPlayer)
	end

	self:ForEachInMap(_InnerNotifyMsg)
end

function tbCrossOuter:OnInnerCityEnd()
	if tbCrossBase.OnInnerCityEnd then
		tbCrossBase.OnInnerCityEnd(self)
	end
	self:SetTrapEnableByType("ToKing", true)
	self:SetTrapEnableByType("ToInner", false)
	self:SpawnAllPillar()

	self:UpdateMiniMapInfo("ZY_Longzhu_Z", "中龙柱")
	self:UpdateMiniMapInfo("ZY_Longzhu_B", "北龙柱")
	self:UpdateMiniMapInfo("ZY_Longzhu_N", "南龙柱")

	local function _NotifyMsg(pPlayer)
		pPlayer.SendBlackBoardMsg("龙柱已重新出现，当前均为无人占领")
	end

	self:ForEachInMap(_NotifyMsg)
end

function tbCrossOuter:GetKinCamp(nKinId)
	return self.tbKinCamp[nKinId]
end

function tbCrossOuter:SyncKingTransferRightInfoReq(pPlayer)
	local tbList = {}
	for _, nKinId in pairs( self.tbKinList ) do
		if self:IsCanTranferToKing(nKinId) then
			local tbKinInfo = tbCross:GetKinInfo(nKinId)
			if tbKinInfo then
				table.insert(tbList, {nKinId, tbKinInfo.szFullName})
			end
		end
	end

	pPlayer.CallClientScript("DomainBattle.tbCross:SyncKingTransferRightInfo", tbList)
end

function tbCrossOuter:TransferToKinCamp(nKinId, pPlayer)
	local nCampIndex = self:GetKinCamp(nKinId)
	if not nCampIndex then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter:TransferToKinCamp Failed Not Found Kin Camp Index", nKinId)
		return
	end

	local nPosX, nPosY = tbCross:GetCampPos(self.nMapTemplateId, nCampIndex)
	if not nPosX then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter:TransferToKinCamp Failed Not Found Camp Pos", nCampIndex, nKinId, pPlayer.dwID)
		return
	end

	pPlayer.SwitchMap(self.nMapId, nPosX, nPosY)
end

function tbCrossOuter:OnStartAward()
	tbCrossBase.OnStartAward(self)

	if self.nInnerNotifyTimer then
		Timer:Close(self.nInnerNotifyTimer)
		self.nInnerNotifyTimer = nil
	end

	if self.nInnerEffectTimer then
		Timer:Close(self.nInnerEffectTimer)
		self.nInnerEffectTimer = nil
	end
end

function tbCrossOuter.tbTrapFun:ToPeace(pPlayer, tbTrapInfo)
	local tbPlayerInfo = tbCross:GetPlayerInfo(pPlayer.dwID)
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToPeace Failed No Player Info", pPlayer.dwID, pPlayer.szName, pPlayer.nFightMode)
		Lib:Tree(tbTrapInfo)
		return
	end

	local nCampIndex = self.tbKinCamp[tbPlayerInfo.nKinId]

	if not nCampIndex then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToPeace Failed No Kin Camp Index", pPlayer.dwID, pPlayer.szName, pPlayer.nFightMode)
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbTrapInfo)
		return
	end

	if nCampIndex ~= tbTrapInfo.nIndex then
		return
	end

	self:TrapToPeace(pPlayer, tbTrapInfo)
end

function tbCrossOuter.tbTrapFun:ToKing(pPlayer, tbTrapInfo)
	if not tbTrapInfo.bEnable then
		return
	end

	local nPlayerId =pPlayer.dwID
	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToKing Failed Not Found PlayerInfo", nPlayerId)
		Lib:Tree(tbTrapInfo)
		return
	end

	if not self:IsCanTranferToKing(tbPlayerInfo.nKinId) then
		pPlayer.SendBlackBoardMsg("本帮派未获得临安王城进入资格")
		return
	end

	local tbKingInst = tbCross:GetKingInst()

	if not tbKingInst then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToKing Failed Not Found King Inst", nPlayerId)
		Lib:Tree(tbTrapInfo)
		Lib:Tree(tbPlayerInfo)
		return
	end

	tbKingInst:TransferToKinCamp(tbPlayerInfo.nKinId, pPlayer);
end

function tbCrossOuter.tbTrapFun:ToInner(pPlayer, tbTrapInfo)
	if not tbTrapInfo.bEnable then
		return
	end

	local nPlayerId =pPlayer.dwID
	local tbPlayerInfo = tbCross:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToInner Failed Not Found PlayerInfo", nPlayerId)
		Lib:Tree(tbTrapInfo)
		return
	end

	local tbKinInfo = tbCross:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToInner Failed Not Found KinInfo")
		Lib:Tree(tbTrapInfo)
		Lib:Tree(tbPlayerInfo)
		return
	end

	local nInnerMapId = tbKinInfo.nInnerMapId
	if not nInnerMapId then
		Log("[Error]", "DomainBattleCross", "tbCrossOuter.tbTrapFun:ToInner Failed No nInnerMapId")
		Lib:Tree(tbTrapInfo)
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbKinInfo)
		return
	end

	local tbInnerInst = tbCross.tbInstList[nInnerMapId]
	tbInnerInst:TransferToKinCamp(tbPlayerInfo.nKinId, pPlayer);
end
