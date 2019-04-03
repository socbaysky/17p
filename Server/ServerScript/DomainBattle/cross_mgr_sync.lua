Require("ServerScript/DomainBattle/cross_mgr.lua");

DomainBattle.tbCross = DomainBattle.tbCross or {};
local tbCross = DomainBattle.tbCross
local tbCrossDef = DomainBattle.tbCrossDef
local tbDefine = DomainBattle.define

function tbCross:SyncKingTransferRightInfoReq(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local tbOuterInst = self.tbInstList[tbKinInfo.nOuterMapId]
	if not tbOuterInst then
		Log("[Error]", "DomainBattleCross", "SyncOuterOccupyInfoReq Failed Not Found Kin Outer Map")
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbKinInfo)
		return
	end

	tbOuterInst:SyncKingTransferRightInfoReq(pPlayer)
end

function tbCross:SyncKingTransferCountInfoReq(pPlayer, nVersion)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local tbKingInst = self:GetKingInst()
	if not tbKingInst then
		Log("[Error]", "DomainBattleCross", "SyncKingOccupyInfoReq Failed Not Found King Map")
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbKinInfo)
		return
	end

	tbKingInst:SyncKingTransferCountInfoReq(pPlayer, nVersion)
end

function tbCross:SyncOuterOccupyInfoReq(pPlayer, nVersion)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local tbOccupyInfo = self.tbOccupySyncInfo[tbKinInfo.nOuterMapId] or {}

	if nVersion == tbOccupyInfo.nVersion then
		return
	end

	self:SyncOuterOccupyInfo(pPlayer, tbKinInfo.nOuterMapId)
end

function tbCross:SyncOuterOccupyInfo(pPlayer, nMapId)
	local tbOccupyInfo = self.tbOccupySyncInfo[nMapId] or {}
	pPlayer.CallClientScript("DomainBattle.tbCross:SyncOuterOccupyInfo", tbOccupyInfo.nVersion, tbOccupyInfo.tbList)
end

function tbCross:SyncKingOccupyInfoReq(pPlayer, nVersion)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local tbKingInst = self:GetKingInst()
	if not tbKingInst then
		Log("[Error]", "DomainBattleCross", "SyncKingOccupyInfoReq Failed Not Found King Map")
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbKinInfo)
		return
	end

	local tbOccupyInfo = self.tbOccupySyncInfo[tbKingInst.nMapId] or {}

	if nVersion == tbOccupyInfo.nVersion then
		return
	end

	self:SyncKingOccupyInfo(pPlayer, tbKingInst.nMapId)
end

function tbCross:SyncKingOccupyInfo(pPlayer, nMapId)
	local tbOccupyInfo = self.tbOccupySyncInfo[nMapId] or {}
	pPlayer.CallClientScript("DomainBattle.tbCross:SyncKingOccupyInfo", tbOccupyInfo.nVersion, tbOccupyInfo.tbList)
end

function tbCross:SyncTopKinInfoReq(pPlayer, nVersion)
	if nVersion == self.nTopKinSyncVersion then
		return
	end

	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	pPlayer.CallClientScript("DomainBattle.tbCross:SyncTopKinInfo", self.tbTopKinSyncInfo, self.nTopKinSyncVersion);
end

function tbCross:SyncSelfInfoReq(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)
	if not tbKinInfo then
		return
	end

	local tbSelfKinInfo
	if tbKinInfo.nRank > tbCrossDef.nMaxSyncTopKin then
		tbSelfKinInfo = {
					nRank = tbKinInfo.nRank,
					nScore = tbKinInfo.nScore,
					nKinId = tbKinInfo.nKinId,
					szName = tbKinInfo.szFullName,
					szMasterName = tbKinInfo.szMasterName,
				}
	end
	local tbSelfInfo
	if tbPlayerInfo.nKinRank > tbCrossDef.nMaxSyncTopPlayer then
		tbSelfInfo = {
				nRank = tbPlayerInfo.nKinRank,
				nScore = tbPlayerInfo.nScore,
				nPlayerId = tbPlayerInfo.nPlayerId,
				szName = tbPlayerInfo.szName,
				nKillCount = tbPlayerInfo.nKillCount,
				bAid = tbPlayerInfo.bAid,
			}
	end

	pPlayer.CallClientScript("DomainBattle.tbCross:SyncSelfInfo",
				tbPlayerInfo.bAid, tbSelfInfo, tbSelfKinInfo);
end

function tbCross:SyncTopPlayerInfoReq(pPlayer, nVersion)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinTopPlayerInfo = self.tbTopPlayerSyncInfo[tbPlayerInfo.nKinId];
	if not tbKinTopPlayerInfo then
		Log("[Error]", "DomainBattleCross", "SyncTopPlayerInfoReq Not Found KinTopPlayerInfo")
		Lib:Tree(tbPlayerInfo)
		return
	end

	if nVersion == tbKinTopPlayerInfo.nVersion then
		return
	end


	pPlayer.CallClientScript("DomainBattle.tbCross:SyncTopPlayerInfo", tbKinTopPlayerInfo.tbList, tbKinTopPlayerInfo.nVersion);
end

function tbCross:SyncAllPlayerStateChange()
	local nStateEndTime = GetTime() + self:GetStateLeftTime();
	for nMapId, _ in pairs( self.tbInstList ) do
		KPlayer.MapBoardcastScript(nMapId, "DomainBattle.tbCross:OnSyncStateChange",
				self.nCurStateIndex, nStateEndTime)
	end
end

function tbCross:OnUpdateOccupySyncInfo(nMapId, tbNpcInfo, tbKinInfo)
	self.tbOccupySyncInfo[nMapId] = self.tbOccupySyncInfo[nMapId] or {nVersion=0, tbList={}}
	self.tbOccupySyncInfo[nMapId].nVersion = self.tbOccupySyncInfo[nMapId].nVersion + 1
	local szOwner = "无"
	if tbKinInfo then
		szOwner = tbKinInfo.szFullName
	end
	self.tbOccupySyncInfo[nMapId].tbList[tbNpcInfo.szNpcName] = szOwner
end

function tbCross:ChangeToSiegeCar(pPlayer, nNpcId, nChangeSkillId, szText, nDuraSeconds)
	local tbInst = self.tbInstList[pPlayer.nMapId]
	if tbInst then
		tbInst:ChangeToSiegeCar(pPlayer, nNpcId, nChangeSkillId, szText, nDuraSeconds)
	end
end

function tbCross:LeaveRequest(pPlayer)
	local tbInst = self.tbInstList[pPlayer.nMapId]
	if not tbInst then
		return
	end

	if not tbInst:CheckCanLeave(pPlayer) then
		return
	end

	local function _Leave(nPlayerId)
		local pTmpPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pTmpPlayer then
			ChatMgr:LeaveKinChatRoom(pTmpPlayer);
			pTmpPlayer.ZoneLogout();
		end
	end

	if pPlayer.nFightMode  == 1 then
		GeneralProcess:StartProcess(pPlayer, 5 * Env.GAME_FPS, "传送中...", _Leave, pPlayer.dwID);
		return
	end

	_Leave(pPlayer.dwID)
end

function tbCross:MiniMapInfoReq(pPlayer, nVersion)
	local tbInst = self.tbInstList[pPlayer.nMapId]
	if not tbInst then
		return
	end

	tbInst:MiniMapInfoReq(pPlayer, nVersion)
end

function tbCross:SyncSupplyReq(pPlayer, nVersion)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)

	if not tbKinInfo then
		return
	end

	if tbKinInfo.nSupplyDataVersion == nVersion then
		return
	end

	pPlayer.CallClientScript("DomainBattle.tbCross:OnSyncSupplyInfo", tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] == true,
				tbKinInfo.tbBattleSupply, tbKinInfo.nSupplyDataVersion);
end

function tbCross:UseSupplysReq(pPlayer, nItemId)
	if not nItemId then
		return
	end

	if not self.nMainTimer or self.nCurStateIndex > 4 then
		--开始结算后不能使用
		return
	end

	local nMapId = pPlayer.nMapId
	local tbInst = self.tbInstList[nMapId]
	if not tbInst then
		return
	end

	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)

	if not tbKinInfo then
		return
	end

	if not tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] then
		return
	end

	local nLeftCount = tbKinInfo.tbBattleSupply[nItemId] or 0
	if nLeftCount <= 0 then
		return
	end

	tbKinInfo.tbUsedSupply[nItemId] = tbKinInfo.tbUsedSupply[nItemId] or 0
	local nLimitNum = tbDefine.tbBattleApplyLimit[nItemId]

	if nLimitNum and tbKinInfo.tbUsedSupply[nItemId] >= nLimitNum then
		pPlayer.CenterMsg(string.format("该道具使用次数已达本场上限%d次", nLimitNum), true)
		return
	end

	local bRet = tbInst:UseSupply(pPlayer, nItemId)
	if bRet then
		tbKinInfo.tbUsedSupply[nItemId] = tbKinInfo.tbUsedSupply[nItemId] + 1
		tbKinInfo.tbBattleSupply[nItemId] = tbKinInfo.tbBattleSupply[nItemId] - 1
		tbKinInfo.nSupplyDataVersion = tbKinInfo.nSupplyDataVersion + 1
		self:CallZoneClientScriptByKinId(tbPlayerInfo.nKinId, "DomainBattle.tbCross:OnLocalUseSupply", tbPlayerInfo.nOrgKinId, nItemId)
		self:SyncKinSupplyInfo(tbPlayerInfo.nKinId)
	end
end

function tbCross:SyncKinSupplyInfo(nKinId)
	local tbKinInfo = self:GetKinInfo(nKinId)

	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "SyncKinSupplyInfo Failed Not Found Kin Info", nKinId)
		return
	end

	for nPlayerId, _ in pairs( tbKinInfo.tbCanUseSupplyPlayer ) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			pPlayer.CallClientScript("DomainBattle.tbCross:OnSyncSupplyInfo", true, tbKinInfo.tbBattleSupply, tbKinInfo.nSupplyDataVersion);
		end
	end
end

function tbCross:ChangeKingCampReq(pPlayer, nCampIndex)
	if not nCampIndex then
		return
	end

	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)

	if not tbKinInfo then
		return
	end

	if not tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] then
		return
	end

	local tbKingInst = self:GetKingInst()
	if not tbKingInst then
		Log("[Error]", "DomainBattleCross", "ChangeKingCampReq Failed Not Found King Map")
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbKinInfo)
		return
	end

	local bRet, szMsg = tbKingInst:ChangeKinCamp(nPlayerId, nCampIndex)
	if bRet then
		pPlayer.CallClientScript("DomainBattle.tbCross:OnSyncKingCampInfo", nCampIndex, tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] == true);
	elseif szMsg then
		pPlayer.CenterMsg(szMsg);
	end
end

function tbCross:KingCampInfoReq(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbPlayerInfo = self:GetPlayerInfo(nPlayerId)
	if not tbPlayerInfo then
		return
	end

	local tbKinInfo = self:GetKinInfo(tbPlayerInfo.nKinId)

	if not tbKinInfo then
		return
	end

	local tbKingInst = self:GetKingInst()
	if not tbKingInst then
		Log("[Error]", "DomainBattleCross", "KingCampInfoReq Failed Not Found King Map")
		Lib:Tree(tbPlayerInfo)
		Lib:Tree(tbKinInfo)
		return
	end

	local nCampIndex = tbKingInst:GetKinCamp(tbKinInfo.nKinId)

	pPlayer.CallClientScript("DomainBattle.tbCross:OnSyncKingCampInfo", nCampIndex, tbKinInfo.tbCanUseSupplyPlayer[nPlayerId] == true);
end
