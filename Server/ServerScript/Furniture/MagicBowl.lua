Furniture.MagicBowl = Furniture.MagicBowl or {}
local MagicBowl = Furniture.MagicBowl

local tbValidReqs = {
	Upgrade = true,
	InscriptionStartStage = true,
	InscriptionHarvest = true,
	Pray = true,
	ConfirmPrayResult = true,
	TransferBuff = true,
	UpdateData = true,
	Refinement = true,
}

function MagicBowl:OnReq(pPlayer, szReqType, ...)
	if not tbValidReqs[szReqType] then
		Log("[x] MagicBowl:OnReq", pPlayer.dwID, szReqType)
		return
	end

	local fn = self[szReqType]
	if not fn then
		Log("[x] MagicBowl:OnReq, no impl", pPlayer.dwID, szReqType)
		return
	end

	local bOk, szErr = fn(self, pPlayer, ...)
	if not bOk and szErr and szErr~="" then
		pPlayer.CenterMsg(szErr)
		return
	end
end

function MagicBowl:GetData(nPlayerId)
	if MODULE_ZONESERVER then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer and pPlayer.tbTmpMagicBowlData then
			return pPlayer.tbTmpMagicBowlData
		end
		return false, "没有聚宝盆"
	end

	local tbHouse = House:GetHouse(nPlayerId)
	if not tbHouse then
		return false, "没有家园"
	end

	local tbMagicBowl = tbHouse.tbMagicBowl
	if not next(tbMagicBowl or {}) then
		return false, "没有聚宝盆"
	end
	return tbMagicBowl
end

function MagicBowl:GetFightPower(nPlayerId)
	local tbData = self:GetData(nPlayerId)
	if not tbData then
		return 0
	end

	local nRet = 0
	for _, nSaveData in ipairs(tbData.tbAttrs) do
		nRet = nRet+self:GetAttrFightPower(nSaveData)
	end
	return nRet
end

function MagicBowl:UpdateData(pPlayer, nOwner, nVersion)
	if not nOwner or nOwner<=0 then
		Log("[x] MagicBowl:UpdateData", pPlayer.dwID, tostring(nOwner), nVersion)
		return false
	end
	local tbMagicBowl, szErr = self:GetData(nOwner)
	if not tbMagicBowl then
		return false
	end

	if tbMagicBowl.nVersion==nVersion then
		return true
	end

	pPlayer.CallClientScript("House:OnSyncMagicBowl", nOwner, tbMagicBowl)
	return true
end

function MagicBowl:Upgrade(pPlayer, nFurnitureId, tbMaterials)
	local nPlayerId = pPlayer.dwID
	local tbMagicBowl, szErr = self:GetData(nPlayerId)
	if not tbMagicBowl then
		return false, szErr
	end

	local nCurLvl = tbMagicBowl.nLevel
	local tbNextLvl = self:GetLevelSetting(nCurLvl+1)
	if not tbNextLvl then
		return false, "已达最大等级"
	end

	local nComfortLvl = House:GetHouseComfortLevel(nPlayerId) or 0
	if nComfortLvl<tbNextLvl.nComfortLvl then
		return false, "舒适度等级不足"
	end

	if tbNextLvl.szOpenFrame~="" and GetTimeFrameState(tbNextLvl.szOpenFrame)~=1 then
		return false, "此等级尚未开启"
	end

	local nStage = tbMagicBowl.tbInscription.nStage
	if nStage~=0 then
		return false, "正在铸造铭文，无法升级"
	end

	local nLastCachedValue = tbMagicBowl.nCachedValue or 0
	local bOk, szErr, nCachedValue = self:ConsumeMaterials(pPlayer, tbMaterials, nLastCachedValue, tbNextLvl.nCostValue)
	if not bOk then
		return false, szErr
	end

	tbMagicBowl.nLevel = nCurLvl+1
	tbMagicBowl.nCachedValue = nCachedValue
	self:IncVersion(nPlayerId, tbMagicBowl)

	local nNewFurnitureId = 0
	local bOk, tbFurniture = Furniture:RemoveMapFurniture(nPlayerId, nFurnitureId)
	if not bOk then
		Log("[x] MagicBowl:Upgrade, rm failed", nPlayerId, nCurLvl, tbFurniture)
	else
		local bOk, szErr = Furniture:AddMapFurniture(pPlayer, tbNextLvl.nItemId, tbFurniture.nX, tbFurniture.nY, tbFurniture.nRotation or 0)
		if not bOk then
			Furniture:Add(pPlayer, tbNextLvl.nItemId)	
			Log("[x] MagicBowl:Upgrade, add furniture failed", nPlayerId, nCurLvl, tbNextLvl.nItemId, tbFurniture.nX, tbFurniture.nY, tbFurniture.nRotation, szErr)
		else
			nNewFurnitureId = szErr
		end
	end
	
	House:Save(nPlayerId)

	self:UpdateData(pPlayer, nPlayerId, 0)

	pPlayer.CallClientScript("House:OnMagicBowlUpgrade", nCurLvl, tbMagicBowl.nLevel, nNewFurnitureId)

	Log("MagicBowl:Upgrade", nPlayerId, nFurnitureId, nCurLvl, nNewFurnitureId, nLastCachedValue, nCachedValue)
	return true
end

function MagicBowl:IncVersion(nPlayerId, tbMagicBowl)
	tbMagicBowl.nVersion = ((tbMagicBowl.nVersion or 1)+1) % 1000000
	House:MarkDirty(nPlayerId)
end

function MagicBowl:InscriptionStartStage(pPlayer, tbMaterials)
	local nPlayerId = pPlayer.dwID
	local tbMagicBowl, szErr = self:GetData(nPlayerId)
	if not tbMagicBowl then
		return false, szErr
	end

	local nStage = tbMagicBowl.tbInscription.nStage
	local nDeadline = tbMagicBowl.tbInscription.nDeadline
	if nStage<=0 then
		nStage, nDeadline = 1, 0
	end
	local szState = self:GetInscriptionState(tbMagicBowl.nLevel, nStage, nDeadline)
	if szState~="rest" then
		return false, "当前状态无法开启阶段铸造"
	end

	local tbSetting = self:GetInscriptionMakeSetting(tbMagicBowl.nLevel)
	if not tbSetting then
		Log("[x] MagicBowl:InscriptionStartStage, no setting", nPlayerId, tbMagicBowl.nLevel)
		return false
	end

	local nRealStage = nStage
	if nDeadline>0 then
		nRealStage = nStage+1
	end
	local nCostValue = tbSetting["nValue"..nRealStage]
	local nTime = tbSetting["nTime"..nRealStage]
	if not nCostValue or not nTime then
		Log("[x] MagicBowl:InscriptionStartStage, overflow", nPlayerId, tbMagicBowl.nLevel, nStage, nDeadline, nRealStage, nCostValue, nTime)
		return false
	end

	local nLastCachedValue = tbMagicBowl.tbInscription.nCachedValue or 0
	local bOk, szErr, nCachedValue = self:ConsumeMaterials(pPlayer, tbMaterials, nLastCachedValue, nCostValue)
	if not bOk then
		return false, szErr
	end

	tbMagicBowl.tbInscription.nStage = nRealStage
	tbMagicBowl.tbInscription.nDeadline = GetTime()+nTime
	tbMagicBowl.tbInscription.nCachedValue = nCachedValue
	self:IncVersion(nPlayerId, tbMagicBowl)
	self:UpdateData(pPlayer, nPlayerId, 0)

	self:CheckHarvest(nPlayerId)

	Log("MagicBowl:InscriptionStartStage", nPlayerId, tbMagicBowl.nLevel, nStage, nDeadline, nRealStage, nCostValue, nTime, nLastCachedValue, nCachedValue)

	return true
end

function MagicBowl:ConsumeMaterials(pPlayer, tbMaterials, nCachedValue, nNeedValue)
	local nPlayerId = pPlayer.dwID
	local bOk, szErr, nTotalValue = self:CheckMaterials(tbMaterials, nCachedValue, nNeedValue)
	if not bOk then
		return false, szErr
	end

	for nItemId, nCount in pairs(tbMaterials) do
		local pItem = KItem.GetItemObj(nItemId)
		if not pItem then
			Log("[x] MagicBowl:ConsumeMaterials, item nil", nPlayerId, nItemId, nCount)
			return false, "指定消耗的材料不存在"
		end
		local nConsumeCount = pPlayer.ConsumeItem(pItem, nCount, Env.LogWay_MagicBowl)
		if nConsumeCount~=nCount then
			Log("[x] MagicBowl:ConsumeMaterials, consume fail", nPlayerId, pItem.dwTemplateId, nCount, nConsumeCount)
			return false, "消耗物品失败"
		end
		Log("MagicBowl:ConsumeMaterials, consume", nPlayerId, nCachedValue, pItem.dwTemplateId, nCount)
	end
	return true, "", nTotalValue-nNeedValue
end

function MagicBowl:InscriptionHarvest(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbMagicBowl, szErr = self:GetData(nPlayerId)
	if not tbMagicBowl then
		return false, szErr
	end

	local nStage = tbMagicBowl.tbInscription.nStage
	local nDeadline = tbMagicBowl.tbInscription.nDeadline
	local szState = self:GetInscriptionState(tbMagicBowl.nLevel, nStage, nDeadline)
	if szState~="finished" then
		return false, "当前状态无法进行收获"
	end

	local tbSetting = self:GetInscriptionMakeSetting(tbMagicBowl.nLevel)
	if not tbSetting then
		Log("[x] MagicBowl:InscriptionHarvest, no setting", nPlayerId, tbMagicBowl.nLevel)
		return false
	end
	if not tbSetting.nItemId or tbSetting.nItemId<=0 then
		Log("[x] MagicBowl:InscriptionHarvest, cfg err", nPlayerId, tbMagicBowl.nLevel, tostring(tbSetting.nItemId))
		return false
	end

	pPlayer.SendAward({{"item", tbSetting.nItemId, 1}}, false, true, Env.LogWay_MagicBowl)

	tbMagicBowl.tbInscription.nStage = 0
	tbMagicBowl.tbInscription.nDeadline = 0
	self:IncVersion(nPlayerId, tbMagicBowl)
	self:UpdateData(pPlayer, nPlayerId, 0)
	Log("MagicBowl:InscriptionHarvest", nPlayerId, tbMagicBowl.nLevel, tbSetting.nItemId)

	return true
end

function MagicBowl:Pray(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbMagicBowl, szErr = self:GetData(nPlayerId)
	if not tbMagicBowl then
		return false, szErr
	end

	if #tbMagicBowl.tbAttrs<=0 then
		return false, "请使用铭文为聚宝盆洗练属性後再进行祈福吧"
	end

	local nNow = GetTime()
	local bNewDay = Lib:IsDiffDay(self.Def.nNewDayTime, nNow, tbMagicBowl.tbPray.nLastUpdate)
	local nNextTimes = (bNewDay and 0 or tbMagicBowl.tbPray.nTimes)+1
	local nNextCost = self:GetPrayCost(nNextTimes)
	if nNextCost>0 then
		local szMoneyName = Shop:GetMoneyName(self.Def.szPrayCostType)
		if pPlayer.GetMoney(self.Def.szPrayCostType)<nNextCost then
			return false, string.format("%s不足", szMoneyName)
		end
		
		if not pPlayer.CostMoney(self.Def.szPrayCostType, nNextCost, Env.LogWay_MagicBowl) then
			return false, string.format("扣除%s失败", szMoneyName)
		end

		local szMsg = string.format("消耗%s：%d（家园聚宝盆祈福）", szMoneyName, nNextCost)
		pPlayer.Msg(szMsg)
		pPlayer.CenterMsg(szMsg)

		Log("MagicBowl:Pray, cost", nPlayerId, nNextTimes, self.Def.szPrayCostType, nNextCost)
		return self:_DoPray(pPlayer)
	else
		return self:_DoPray(pPlayer)
	end
end

function MagicBowl:_DoPray(pPlayer)
	local nPlayerId = pPlayer.dwID
	local tbMagicBowl, szErr = self:GetData(nPlayerId)
	if not tbMagicBowl then
		return false, szErr
	end

	if #tbMagicBowl.tbAttrs<=0 then
		return false, "请使用铭文为聚宝盆洗练属性後再进行祈福吧"
	end

	local nNow = GetTime()
	local bNewDay = Lib:IsDiffDay(self.Def.nNewDayTime, nNow, tbMagicBowl.tbPray.nLastUpdate)
	if bNewDay then
		tbMagicBowl.tbPray.nTimes = 0
	end

	self:CheckPrayExpire(nPlayerId, tbMagicBowl)

	tbMagicBowl.tbPray.nTimes = tbMagicBowl.tbPray.nTimes+1
	tbMagicBowl.tbPray.nLastUpdate = GetTime()

	self.tbPrayResults = self.tbPrayResults or {}

	local tbIdxs = {}
	for _ in ipairs(tbMagicBowl.tbAttrs) do
		table.insert(tbIdxs, MathRandom(#self.Def.tbPrayPercentDesc))
	end
	self.tbPrayResults[nPlayerId] = tbIdxs
	pPlayer.CallClientScript("Ui:OpenWindow", "MagicBowlPrayResultPanel", tbIdxs)
	self:IncVersion(nPlayerId, tbMagicBowl)

	Log("MagicBowl:_DoPray", nPlayerId, tbMagicBowl.tbPray.nTimes)
	return true
end

function MagicBowl:ConfirmPrayResult(pPlayer, bChooseNew)
	self.tbPrayResults = self.tbPrayResults or {}

	local nPlayerId = pPlayer.dwID
	if not bChooseNew then
		self.tbPrayResults[nPlayerId] = nil
		self:UpdateData(pPlayer, nPlayerId, 0)
		Log("MagicBowl:ConfirmPrayResult, no", nPlayerId)
		return
	end

	local tbMagicBowl, szErr = self:GetData(nPlayerId)
	if not tbMagicBowl then
		return false, szErr
	end

	local tbIdx = self.tbPrayResults[nPlayerId]
	if not tbIdx then
		Log("[x] MagicBowl:ConfirmPrayResult", nPlayerId, tostring(bChooseNew))
		return false
	end
	self.tbPrayResults[nPlayerId] = nil

	tbMagicBowl.tbPray.tbIdxs = tbIdx
	tbMagicBowl.tbPray.nLastPray = GetTime()
	self:IncVersion(nPlayerId, tbMagicBowl)

	self:UpdateData(pPlayer, nPlayerId, 0)
	self:UpdateAttrs(pPlayer)

	Log("MagicBowl:ConfirmPrayResult, yes", nPlayerId)
	return true
end

function MagicBowl:ApplyAttrib(pPlayer, nSaveData, nPrayIdx)
	local szType, tbMa = self:GetPrayValue(nSaveData, nPrayIdx)
	self:RecordOldAttr(pPlayer, szType, tbMa)
	pPlayer.GetNpc().ChangeAttribValue(szType, tbMa[1], tbMa[2], tbMa[3])
	pPlayer.CallClientScript("House:MagicBowlApplyAttrib", szType, tbMa)
end

function MagicBowl:IsPrayValid(tbData)
	local nLastPray = tbData.tbPray.nLastPray or 0
	return (GetTime()-nLastPray)<=self.Def.nPrayDuration
end

function MagicBowl:CheckPrayExpire(nPlayerId, tbData)
	if tbData.tbPray.nLastPray and tbData.tbPray.nLastPray<0 then
		return
	end

	if self:IsPrayValid(tbData) then
		return
	end

	tbData.tbPray.nLastPray = -1
	local nMin, nMax = unpack(self.Def.tbPrayDefaultIdxs)
	for i in ipairs(tbData.tbAttrs) do
		tbData.tbPray.tbIdxs[i] = MathRandom(nMin, nMax)
	end
	self:IncVersion(nPlayerId, tbData)
	Log("MagicBowl:CheckPrayExpire", nPlayerId, tbData.tbPray.nLastUpdate)
end

function MagicBowl:UpdateAttrs(pPlayer, bDontRmClientOldAttrs)
	local nPlayerId = pPlayer.dwID
	local tbData = self:GetData(nPlayerId)
	if not tbData then
		return
	end

	self:RemoveOldAttrs(pPlayer)
	if not bDontRmClientOldAttrs then
		pPlayer.CallClientScript("Furniture.MagicBowl:RemoveOldAttrs")
	end

	self:CheckPrayExpire(nPlayerId, tbData)
	local nMin, nMax = unpack(self.Def.tbPrayDefaultIdxs)
	for i, nSaveData in ipairs(tbData.tbAttrs) do
		if not tbData.tbPray.tbIdxs[i] then
			tbData.tbPray.tbIdxs[i] = MathRandom(nMin, nMax)
			self:IncVersion(nPlayerId, tbData)
		end
		self:ApplyAttrib(pPlayer, nSaveData, tbData.tbPray.tbIdxs[i])
	end
end

function MagicBowl:UpdateOnlinePlayersBuff()
	local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayer) do
		self:UpdateAttrs(pPlayer)
    end
end

function MagicBowl:Refinement(pPlayer, nItemId, nSrcPos, nTargetPos)
	local nPlayerId = pPlayer.dwID
	local tbData = self:GetData(nPlayerId)
	if not tbData then
		pPlayer.CallClientScript("House:MagicBowlOnRefinementResult", false, "没有聚宝盆")
		return false, "没有聚宝盆"
	end
	
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		pPlayer.CallClientScript("House:MagicBowlOnRefinementResult", false, "铭文不存在")
		return false, "铭文不存在"
	end

	local tbItemAttrs = Item.tbRefinement:GetRandomAttrib(pItem)
	local tbItemAttr = tbItemAttrs[nSrcPos]
	if not tbItemAttr then
		Log("[x] MagicBowl:Refinement, invalid src pos", nPlayerId, nItemId, nSrcPos, nTargetPos)
		pPlayer.CallClientScript("House:MagicBowlOnRefinementResult", false, "洗练失败")
		return false
	end

	local nOldTargetPos = nTargetPos
	nTargetPos = nTargetPos>0 and nTargetPos or (#tbData.tbAttrs+1)
	local nMaxCount = self:GetMaxAttrCount(nPlayerId)
	if nTargetPos>nMaxCount then
		Log("[x] MagicBowl:Refinement, overflow", nPlayerId, nItemId, nSrcPos, nOldTargetPos, nTargetPos, nMaxCount)
		pPlayer.CallClientScript("House:MagicBowlOnRefinementResult", false, "洗练失败")
		return false
	end

	for i, nSaveData in ipairs(tbData.tbAttrs) do
		local nAttribId, nLevel = Item.tbRefinement:SaveDataToAttrib(nSaveData)
		if nAttribId==tbItemAttr.nAttribId and i~=nTargetPos then
			return false, "已存在相同属性"
		end
	end

	if not pPlayer.CostMoney("Coin", Item.tbRefinement:GetRefineCost(tbItemAttr.nSaveData, pItem.nItemType), Env.LogWay_Refinement) then
		return false, "银两不足"
	end

	Item.tbRefinement:ReduceRandomAttrib(pItem, tbItemAttr.szAttrib)
	tbData.tbAttrs[nTargetPos] = tbItemAttr.nSaveData

	self:IncVersion(nPlayerId, tbData)
	self:UpdateAttrs(pPlayer)
	self:UpdateData(pPlayer, nPlayerId, 0)

	FightPower:ChangeFightPower("MagicBowl", pPlayer)
	
	pPlayer.CallClientScript("House:MagicBowlOnRefinementResult", true, "")
	return true
end

function MagicBowl:NotifyState(dwOwnerId)
	local tbMagicBowl = self:GetData(dwOwnerId)
	if not tbMagicBowl then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwOwnerId);
	if not pPlayer then
		return;
	end

	local nStage = tbMagicBowl.tbInscription.nStage
	local nDeadline = tbMagicBowl.tbInscription.nDeadline
	local szState = self:GetInscriptionState(tbMagicBowl.nLevel, nStage, nDeadline)
	if szState~="finished" then
		return
	end

	self:UpdateData(pPlayer, dwOwnerId, 0)
	pPlayer.CallClientScript("Ui:SynNotifyMsg", { szType = "InscriptionHarvest", nTimeOut = GetTime() + 3600 });
end

function MagicBowl:OnLogin(pPlayer)
	self:UpdateAttrs(pPlayer)
	self:NotifyState(pPlayer.dwID)
	self:CheckHarvest(pPlayer.dwID)
end

function MagicBowl:CheckHarvest(dwOwnerId)
	local tbMagicBowl = self:GetData(dwOwnerId)
	if not tbMagicBowl then
		return;
	end

	local nStage = tbMagicBowl.tbInscription.nStage
	local nDeadline = tbMagicBowl.tbInscription.nDeadline
	local szState, bLastStage = self:GetInscriptionState(tbMagicBowl.nLevel, nStage, nDeadline)
	if szState~="running" or not bLastStage then
		return
	end

	local nTime = nDeadline-GetTime()+2;
	if nTime <= 0 then
		return;
	end

	self.tbTimers = self.tbTimers or {}
	if self.tbTimers[dwOwnerId] and self.tbTimers[dwOwnerId]>0 then
		Timer:Close(self.tbTimers[dwOwnerId])
	end
	self.tbTimers[dwOwnerId] = Timer:Register(Env.GAME_FPS * nTime, self.OnHarvestTimer, self, dwOwnerId);
end

function MagicBowl:OnHarvestTimer(nPlayerId)
	self.tbTimers = self.tbTimers or {}
	self.tbTimers[nPlayerId] = nil
	self:NotifyState(nPlayerId)
end

local nNextCheckTime = 0
function MagicBowl:Activate()
	local nNow = GetTime()
	if nNow<nNextCheckTime then
		return
	end
	nNextCheckTime = nNow+self.Def.nCheckPrayExpireDelta

	self:UpdateOnlinePlayersBuff()
end

function MagicBowl:SyncPlayerData(pPlayer)
    local tbData = self:GetData(pPlayer.dwID)
    if not tbData then
    	return
    end
    CallZoneServerScript("Furniture.MagicBowl:OnSyncPlayerData", pPlayer.dwID, tbData)
end
function MagicBowl:OnSyncPlayerData(nPlayerId, tbData)
	local nServerId = Server:GetServerId(Server.nCurConnectIdx)
    nPlayerId = KPlayer.ForceGetZonePlayerIdByOrgId(nPlayerId, nServerId)
    
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return
	end
	pPlayer.tbTmpMagicBowlData = tbData
	self:UpdateAttrs(pPlayer, true)
end
