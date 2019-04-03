Pet.tbValidReqs = {
	FollowMe = true,
	StopFollowMe = true,
	Feed = true,
	ChangeName = true,
	OpenFeedPanel = true,
	OnFeedConfirm = true,
	Play = true,
}

function Pet:ClientReq(pPlayer, szType, ...)
	if not self.tbValidReqs[szType] then
		Log("[x] Pet:ClientReq, invalid req", pPlayer.dwID, szType, ...)
		return false
	end

	local fn = self[szType]
	if not fn then
		Log("[x] Pet:ClientReq, no func", pPlayer.dwID, szType, ...)
		return false
	end

	return fn(self, pPlayer, ...)
end

function Pet:UpdateFollowStatus(pPet)
	self.tbFollowing = self.tbFollowing or {}
	local nPetId = pPet.nId
	local nFollowId = self.tbFollowing[nPetId]
	if not nFollowId or nFollowId<=0 then
		self.tbFollowing[nPetId] = nil
		return
	end

	local pFollow = KPlayer.GetPlayerObjById(nFollowId)
	if not pFollow or pFollow.nMapId~=pPet.nMapId then
		self.tbFollowing[nPetId] = nil
		return
	end
end

function Pet:SyncFollowStatus(pPet)
	self:UpdateFollowStatus(pPet)
	local nPetId = pPet.nId
	local nFollowId = self.tbFollowing[nPetId] or 0
	local tbPlayer = KPlayer.GetMapPlayer(pPet.nMapId)
	for _, pPlayer in ipairs(tbPlayer or {}) do
		pPlayer.CallClientScript("Pet:OnFollow", nPetId, nFollowId)
	end
end

function Pet:Play(pPlayer, nNpcId)
	local nPlayerId = pPlayer.dwID
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[x] Pet:FollowMe", nPlayerId, nNpcId)
		return false
	end

	self:UpdateFollowStatus(pNpc)
	if self.tbFollowing[nNpcId] and self.tbFollowing[nNpcId]~=nPlayerId then
		return false, "其他玩家正在与它交互"
	end

	local nActionID, nActionEvent = unpack(self.Def.tbPlayActs[pNpc.nTemplateId] or self.Def.tbPlayActs.default)
	pNpc.DoCommonAct(nActionID, nActionEvent, 0, 0)
	Log("Pet:Play", pNpc.nTemplateId, nActionID, nActionEvent)
	return true
end

function Pet:FollowMe(pPlayer, nNpcId)
	local nPlayerId = pPlayer.dwID
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[x] Pet:FollowMe", nPlayerId, nNpcId)
		return false
	end

	self:UpdateFollowStatus(pNpc)
	if self.tbFollowing[nNpcId] and self.tbFollowing[nNpcId]~=nPlayerId then
		return false, "其他玩家正在与它交互"
	end
	self.tbFollowing[nNpcId] = nPlayerId
	self:SyncFollowStatus(pNpc)

	local nPlayerNpcId = pPlayer.GetNpc().nId
	pNpc.SetAi(Pet.Def.FollowAi)
	pNpc.AI_SetFollowNpc(nPlayerNpcId)
	pNpc.SetMasterNpcId(nPlayerNpcId)
	pNpc.AI_SetFollowDistance(Pet.Def.FollowDistance)

	Dialog:SendBlackBoardMsg(pPlayer, "宠物欢快的跟着你跑了起来")

	return true
end

function Pet:ChangeName(pPlayer, nPetTemplateId, szNewName)
	local bOk, szErr = self:CheckNameAvailable(szNewName)
	if not bOk then
		return false, szErr
	end

	local nPlayerId = pPlayer.dwID
	local tbHouse = House:GetHouse(nPlayerId)
	if not tbHouse then
		return false, "没有家园"
	end

	local tbPets = tbHouse.tbPets
	if not tbPets or not tbPets[nPetTemplateId] then
		return false, "没有这个宠物"
	end

	local nGold = pPlayer.GetMoney("Gold")
	local nPrice = Pet.Def.nChangeNamePrice
    if nGold<nPrice then
        return false, "元宝不足"
    end

    pPlayer.CostGold(nPrice, Env.LogWay_Pet, nil, function(nPlayerId, bSuccess)
        if not bSuccess then
            return false
        end

        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "支付过程中您下线了"
        end

        tbPets[nPetTemplateId].szName = szNewName
		House:Save(nPlayerId)

		local tbSpawnedIds = self.tbSpawnedPets[nPlayerId] or {}
		local nNpcId = tbSpawnedIds[nPetTemplateId]
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			pNpc.SetName(szNewName)
			local tbPlayers = KPlayer.GetMapPlayer(pNpc.nMapId) or {}
		    for _, pPlayer in ipairs(tbPlayers) do
				pPlayer.SyncNpc(nNpcId)
		    end
		end

		pPlayer.CallClientScript("Pet:OnChangeName", nPetTemplateId, szNewName)

		Log("Pet:ChangeName", nPlayerId, nPetTemplateId, szNewName)
        return true
    end)
	return true
end

function Pet:Feed(pPlayer, nIdx)
	local nOk, nCurCount = self:CheckFeedCount(pPlayer)
	if not nOk then
		return false, "今日喂食次数已达上限"
	end

	local nPlayerId = pPlayer.dwID
	local tbInfo = self:GetPetInfo(nPlayerId)
	if not tbInfo or not next(tbInfo) then
		return false, "没有宠物"
	end

	local tbCfg = self.Def.FeedCfg[nIdx]
	if not tbCfg then
		Log("[x] Pet:Feed", nPlayerId, nNpcId, nIdx)
		return false
	end

	local nPrice = tbCfg.nPrice
	local nGold = pPlayer.GetMoney("Gold")
    if nGold<nPrice then
        return false, "元宝不足"
    end

    pPlayer.CostGold(nPrice, Env.LogWay_Pet, nil, function(nPlayerId, bSuccess)
        if not bSuccess then
            return false
        end

        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "支付过程中您下线了"
        end

        local nOldBuffId = pPlayer.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffId)

        local pNpc = pPlayer.GetNpc()
        if not pNpc then
        	return false
        end

        local tbState = pNpc.GetSkillState(nOldBuffId)
    	if not tbState or tbState.nEndFrame<=0 then
    		nOldBuffId = 0
	    end

	    local nBuffId, nLevel = unpack(tbCfg.tbBuffs[MathRandom(#tbCfg.tbBuffs)])
	    for i=1, 10 do
	    	if nBuffId~=nOldBuffId then
	    		break
	    	end
		    nBuffId, nLevel = unpack(tbCfg.tbBuffs[MathRandom(#tbCfg.tbBuffs)])
	    end

	    local nNow = GetTime()
		pPlayer.SetUserValue(self.Def.SaveGrp, self.Def.SaveKeyCount, nCurCount+1)
		pPlayer.SetUserValue(self.Def.SaveGrp, self.Def.SaveKeyTime, nNow)

		if not nOldBuffId or nOldBuffId<=0 then
			self:OnFeedResult(pPlayer, nBuffId, nLevel, nIdx, true)
			self:OnFeedConfirm(pPlayer, true, true)
		else
			self:OnFeedResult(pPlayer, nBuffId, nLevel, nIdx)
		end
		pPlayer.CenterMsg("喂食成功")
		Log("Pet:Feed, result", nPlayerId, nNpcId, nIdx, nPrice, nBuffId, nLevel, tbCfg.nDuration)
		return true
    end)
end

function Pet:OnFeedResult(pPlayer, nBuffId, nLevel, nIdx, bJustRecord)
	local nPlayerId = pPlayer.dwID
	self.tbFeedResults = self.tbFeedResults or {}
	self.tbFeedResults[nPlayerId] = {nBuffId, nLevel, nIdx}
	if not bJustRecord then
		pPlayer.CallClientScript("Pet:OnFeedResult", nBuffId, nLevel)
	end
end

function Pet:OnFeedConfirm(pPlayer, bChooseNew)
	self.tbFeedResults = self.tbFeedResults or {}
	local nPlayerId = pPlayer.dwID
	if not self.tbFeedResults[nPlayerId] then
		Log("[x] Pet:OnFeedConfirm", nPlayerId, bChooseNew)
		return false
	end

	local nBuffId, nLevel, nIdx = unpack(self.tbFeedResults[nPlayerId])
	self.tbFeedResults[nPlayerId] = nil
	if not bChooseNew then
		Log("Pet:OnFeedConfirm", nPlayerId, bChooseNew)
		return true
	end

	if not nBuffId or nBuffId<=0 then
		Log("[x] Pet:OnFeedConfirm, invalid buff", nPlayerId, bChooseNew, tostring(nBuffId), nLevel)
		return false
	end

	local nOldBuffId = pPlayer.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffId)
    if nOldBuffId and nOldBuffId>0 then
    	pPlayer.RemoveSkillState(nOldBuffId)
    end

    pPlayer.SetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffId, nBuffId)
    pPlayer.SetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffLvl, nLevel)
	pPlayer.SetUserValue(self.Def.SaveGrp, self.Def.SaveKeyFeedIdx, nIdx)

	local tbCfg = self.Def.FeedCfg[nIdx]
	if not tbCfg then
		Log("[x] Pet:OnFeedConfirm, no cfg", nPlayerId, bChooseNew, nOldBuffId, nBuffId, nLevel, nIdx)
		return false
	end
	pPlayer.AddSkillState(nBuffId, nLevel, 2, GetTime()+tbCfg.nDuration, 1, 1)
	pPlayer.CallClientScript("Pet:OnFeed")

	Log("Pet:OnFeedConfirm", nPlayerId, bChooseNew, nOldBuffId, nBuffId, nLevel)
	return true
end

function Pet:StopFollowMe(pPlayer, nNpcId)
	local nPlayerId = pPlayer.dwID
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[x] Pet:StopFollowMe", nPlayerId, nNpcId)
		return false
	end

	self:UpdateFollowStatus(pNpc)
	if self.tbFollowing[nNpcId]~=nPlayerId then
		return false, "它当前没有跟随你"
	end
	self.tbFollowing[nNpcId] = nil
	self:SyncFollowStatus(pNpc)

	pNpc.SetAi(Pet.Def.NormalAi)
	pNpc.AI_SetFollowNpc(0)
	pNpc.SetMasterNpcId(0)

	Dialog:SendBlackBoardMsg(pPlayer, "宠物很听话的停了下来并不断摇着它的尾巴")

	return true
end

function Pet:OnEnterMap(nMapTemplateId, nMapId)
	if not House:IsInNormalHouse(me) then
		return
	end

	local nOwnerId = House:GetHouseInfoByMapId(nMapId)
	if not nOwnerId then
		return
	end
	self:Spawn(me, nOwnerId)
	self:CallAround(me, nOwnerId, true)
end

function Pet:OnLeaveMap(nMapTemplateId, nMapId)
	self:StopFollowPlayer(me)
end

function Pet:OnLogin(pPlayer, bReconnect)
	if not House:IsInNormalHouse(pPlayer) then
		return
	end

	local nOwnerId = House:GetHouseInfoByMapId(pPlayer.nMapId)
	if not nOwnerId then
		return
	end

	local tbInfo = self:GetPetInfo(nOwnerId)
	if not tbInfo or not next(tbInfo) then
		return
	end

	self.tbSpawnedPets = self.tbSpawnedPets or {}
	local tbPetIds = self.tbSpawnedPets[nOwnerId] or {}
	for nPetId in pairs(tbInfo) do
		local nPetNpcId = tbPetIds[nPetId]
		if nPetNpcId then
			local pNpc = KNpc.GetById(nPetNpcId)
			if pNpc then
				self:SyncFollowStatus(pNpc)
			end
		end
	end
end

function Pet:OnLogout(pPlayer)
	self:StopFollowPlayer(pPlayer)
end

function Pet:StopFollowPlayer(pPlayer)
	local nPlayerId = pPlayer.dwID
	self.tbFollowing = self.tbFollowing or {}
	for nPetId, nPid in pairs(self.tbFollowing) do
		if nPlayerId==nPid then
			self:StopFollowMe(pPlayer, nPetId)
		end
	end
end

function Pet:GetPetInfo(nPlayerId)
	local tbHouse = House:GetHouse(nPlayerId)
	if not tbHouse then
		return nil
	end

	local tbPets = tbHouse.tbPets
	if not tbPets then
		return nil
	end

	local tbRet = {}
	local nNow = GetTime()
	for nPetId, tbPet in pairs(tbPets) do
		if tbPet.nDeadline>0 and tbPet.nDeadline<=nNow then
			self:Delete(nPlayerId, nPetId)
		else
			tbRet[nPetId] = {
				nBornTime = tbPet.nBornTime,
				nDeadline = tbPet.nDeadline,
				szName = tbPet.szName,
			}
		end
	end

	--fix bug temp
	local nDogNpcId = 2874
	local tbDog = tbRet[nDogNpcId]
	if tbDog and tbDog.nDeadline <= 0 and GetTime() <= Lib:ParseDateTime("2018-07-30 0:4:0") then
		tbRet[nDogNpcId] = nil
		self:Delete(nPlayerId, nDogNpcId)
	end

	return tbRet
end

function Pet:Delete(nOwnerId, nPetId)
	self.tbSpawnedPets = self.tbSpawnedPets or {}
	local tbPetIds = self.tbSpawnedPets[nOwnerId] or {}
	local nPetNpcId = tbPetIds[nPetId]
	if nPetNpcId then
		local pNpc = KNpc.GetById(nPetNpcId)
		if pNpc then
			pNpc.Delete()
		end
	end

	local tbHouse = House:GetHouse(nOwnerId)
	if not tbHouse then
		return
	end

	tbHouse.tbPets = tbHouse.tbPets or {}
	tbHouse.tbPets[nPetId] = nil
	House:Save(nOwnerId)
	Log("Pet:Delete", nOwnerId, nPetId)
end

function Pet:SetPetInfo(nPlayerId, nNpcId, nDeadline)
	local tbHouse = House:GetHouse(nPlayerId)
	if not tbHouse then
		return
	end

	local nNow = GetTime()
	tbHouse.tbPets = tbHouse.tbPets or {}
	tbHouse.tbPets[nNpcId] = {
		nBornTime = nNow,
		nDeadline = nDeadline,
	}
	House:Save(nPlayerId)
	Log("Pet:SetPetInfo", nPlayerId, nNpcId, nNow, nDeadline)
end

function Pet:Spawn(pPlayer, nOwnerId)
	local tbInfo = self:GetPetInfo(nOwnerId)
	if not tbInfo or not next(tbInfo) then
		return false
	end

	if not House:IsInPlayerHouse(pPlayer, nOwnerId) then
		return false
	end

	self.tbSpawnedPets = self.tbSpawnedPets or {}
	local tbSpawnedIds = self.tbSpawnedPets[nOwnerId] or {}

	local bSpawned = false
	local nMapId, x, y = pPlayer.GetWorldPos()
	for nPetId, tbPet in pairs(tbInfo) do
		local nSpawnedId = tbSpawnedIds[nPetId] or 0
		local pNpc = KNpc.GetById(nSpawnedId)
		local bShouldSpawn = false
		if not pNpc then
			bShouldSpawn = true
		elseif pNpc.nMapId~=pPlayer.nMapId then
			bShouldSpawn = true
			pNpc.Delete()
			Log("Pet:Spawn, map diff", pPlayer.dwID, nOwnerId, nPetId, pNpc.nMapId, pPlayer.nMapId)
		end

		if bShouldSpawn then
			local pPet = KNpc.Add(nPetId, 1, -1, nMapId, x, y, 0)
			if pPet then
				bSpawned = true
				self.tbSpawnedPets[nOwnerId] = self.tbSpawnedPets[nOwnerId] or {}
				self.tbSpawnedPets[nOwnerId][nPetId] = pPet.nId
				pPet.nOwnerId = nOwnerId
				if tbPet.szName and tbPet.szName~="" then
					pPet.SetName(tbPet.szName)
				end
				Log("Pet:Spawn", pPlayer.dwID, nOwnerId, nPetId, tbPet.nDeadline, nMapId, x, y)
			else
				Log("[x] Pet:Spawn", pPlayer.dwID, nOwnerId, nPetId, tbPet.nDeadline, nMapId, x, y)
			end
		end
	end
	return bSpawned
end

function Pet:CallAround(pPlayer, nOwnerId, bJustIn)
	self.tbSpawnedPets = self.tbSpawnedPets or {}
	local tbSpawnedIds = self.tbSpawnedPets[nOwnerId] or {}
	if not next(tbSpawnedIds) then
		return
	end

	local tbPlayers = KPlayer.GetMapPlayer(pPlayer.nMapId) or {}	
	if #tbPlayers>1 then
		return
	end

	local nMapTemplateId = pPlayer.nMapTemplateId
	local tbPoolAll = bJustIn and Pet.Def.tbBornPos1 or Pet.Def.tbBornPos2
	if not tbPoolAll[nMapTemplateId] then
		Log("[x] Pet:CallAround1", pPlayer.dwID, nMapTemplateId, nOwnerId, tostring(bJustIn))
		return
	end
	local tbPool = Lib:CopyTB(tbPoolAll[nMapTemplateId])
	local tbRandomPos = {}
	local nSelectCount = Lib:CountTB(tbSpawnedIds)
	if nSelectCount>#tbPool then
		Log("[x] Pet:CallAround2", pPlayer.dwID, nOwnerId, tostring(bJustIn), nSelectCount, #tbPool)
		return
	end

	for i=1, nSelectCount do
		local nIdx = MathRandom(#tbPool)
		table.insert(tbRandomPos, tbPool[nIdx])
		table.remove(tbPool, nIdx)
	end

	local i = 1
	for _, nNpcId in pairs(tbSpawnedIds) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			pNpc.SetPosition(unpack(tbRandomPos[i]))
			i = i+1
		end
	end
end

function Pet:OpenFeedPanel(pPlayer, nPetTemplateId)
	local nPlayerId = pPlayer.dwID
	local tbInfo = self:GetPetInfo(nPlayerId)
	if not tbInfo or not next(tbInfo) then
		return false, "没有宠物"
	end

	local tbPets = {}
	for nPetId, tb in pairs(tbInfo) do
		table.insert(tbPets, {
			nPetTemplateId = nPetId,
			szName = tb.szName,
			nDeadline = tb.nDeadline,
			nBornTime = tb.nBornTime,
		})
	end
	table.sort(tbPets, function(tbA, tbB)
		if tbA.nPetTemplateId==nPetTemplateId or tbB.nPetTemplateId==nPetTemplateId then
			return tbA.nPetTemplateId==nPetTemplateId
		end
		return tbA.nPetTemplateId<tbB.nPetTemplateId
	end)

	pPlayer.CallClientScript("Ui:OpenWindow", "PetFeedPanel", tbPets)

	return true
end