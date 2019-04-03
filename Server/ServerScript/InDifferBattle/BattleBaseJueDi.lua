if not MODULE_ZONESERVER then
	return
end
Require("ServerScript/InDifferBattle/BattleBase.lua")

local tbBattleBase = InDifferBattle:CreateClass("BattleBaseJueDi", "BattleBase")
local tbDefine = InDifferBattle.tbDefine
local tbSkillBook = Item:GetClass("SkillBook");

function tbBattleBase:SublClassInit(nMapId, tbTeamIds)
	-- 重载
	self.tbAllMapGrid = {}; --有npc 或者是障碍的设1;
	self.GRID_SIZE = self.tbSettingGroup.GRID_SIZE;
	self.nCurPosionGasLevel = 0; --现在的毒气等级
end

function tbBattleBase:SublClassOnEnter(pPlayer)
	--初始变身 放到FrameActive 里去变了
	self.tbPlayerInfos[pPlayer.dwID].nNowItemBagNpcId = self.tbSettingGroup.nDefautItemBagNpcId
end

function tbBattleBase:SublClassCloseBattle()
	self.tbCurFactionSel = nil;
	self.tbAllMapGrid = nil;
end

--只是放采集物的npc做这种操作
function tbBattleBase:GetCanUsePos(x,y)
	local nGridX = math.floor(x / self.GRID_SIZE);
	local nGridY = math.floor(y / self.GRID_SIZE);
	self.tbAllMapGrid[nGridX] = self.tbAllMapGrid[nGridX] or {};
	if not self.tbAllMapGrid[nGridX][nGridY] then
		self.tbAllMapGrid[nGridX][nGridY] = 1;
		return self.GRID_SIZE * nGridX, self.GRID_SIZE * nGridY
	end

	--这里没考虑当前点与目标点直接有障碍且是无法到达的那种情况todo
	for i=1,6 do --先最多六层吧，13*13个已经很多了
		local tbXs = InDifferBattle:GetAroundGridX(i)
		local tbYs = InDifferBattle:GetAroundGridY(i)
		for nIndex, _X in ipairs(tbXs) do
			local _Y = tbYs[nIndex]
			local nTarX = nGridX + _X
			local nTarY = nGridY + _Y
			self.tbAllMapGrid[nTarX] = self.tbAllMapGrid[nTarX] or {};
			if not self.tbAllMapGrid[nTarX][nTarY] then
				local nRealX = self.GRID_SIZE * nTarX
				local nRealY = self.GRID_SIZE * nTarY
				local bCanUse = CheckBarrier(self.nMapId, nRealX, nRealY);
				if bCanUse == 1 then
					self.tbAllMapGrid[nTarX][nTarY] = 1;
					return nRealX, nRealY
				end
			end
		end
	end
	return x,y
end

function tbBattleBase:ReleasePos(x,y)
	local nGridX = math.floor(x / self.GRID_SIZE);
	local nGridY = math.floor(y / self.GRID_SIZE);
	if not self.tbAllMapGrid then
		return
	end
	local tbY = self.tbAllMapGrid[nGridX]
	if not tbY then
		return
	end
	tbY[nGridY] = nil;
end

--这里只是初始的无差别门派变身
function tbBattleBase:ChangePlayerFaction(pPlayer, nFaction)
	local tbSettingGroup = self.tbSettingGroup
	if not Player:ChangePlayer2Avatar(pPlayer, nFaction, tbSettingGroup.nPlayerLevel, tbSettingGroup.szAvatarEquipKey, tbSettingGroup.szAvatarEquipKey, tbSettingGroup.nDefaultStrengthLevel) then
		return		
	end
	pPlayer.GetNpc().RemoveFightSkill(1013) --禁止打坐操作
	pPlayer.AddSkillState(tbSettingGroup.nInitAddBuffId, tbSettingGroup.nInitAddBuffLevel, 0, Env.GAME_FPS * tbSettingGroup.nInitAddBuffTime, 1)

	self:ChangeFightPower(pPlayer) --加了头衔有血量
	local pNpc = pPlayer.GetNpc()
	pNpc.SetCurLife(pNpc.nMaxLife)
	self.tbCurFactionChange[pPlayer.dwID] = nFaction
end

function tbBattleBase:DelaySetPlayerLife( dwRoleId, nPercent)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		return
	end
	if pPlayer.nFightMode == 2 then
		return
	end
	local pNpc = pPlayer.GetNpc()
	pNpc.SetCurLife(math.ceil(pNpc.nMaxLife * nPercent))
end

function tbBattleBase:ChangePlayerFactionFight(pPlayer, nFaction)
	local nOldFaction = pPlayer.nFaction
	if nOldFaction == nFaction then
		pPlayer.CenterMsg("门派相同")
		return
	end
	local pNpc = pPlayer.GetNpc()
	local nOldCurLife = pNpc.nCurLife;
	local nOldMaxLife = pNpc.nMaxLife

	if not pPlayer.ChangeFaction(nFaction) then
		Log(debug.traceback())
		return
	end
	pPlayer.GetNpc().RemoveFightSkill(1013) --禁止打坐操作
	--看下是否有唯一的性别
	local nNeedSex = Player:Faction2Sex(nFaction, pPlayer.nSex)
	if nNeedSex ~= pPlayer.nSex then
		pPlayer.ChangeSex(nNeedSex);
	end
	local nPortrait = PlayerPortrait:GetDefaultId(pPlayer.nFaction, pPlayer.nSex)
    pPlayer.SetPortrait(nPortrait)
    tbSkillBook:ChangeFactionBook(pPlayer, nOldFaction, nFaction);
    Player:AvatarUpdateSkillLevel(pPlayer)

	-- 丢出已有门派的采集物品
	local _,x,y = pPlayer.GetWorldPos()
	local nRoomIndex = self.tbTeamRoomInfo[pPlayer.dwTeamID][pPlayer.dwID]
	local pNpcFaction = self:AddMapNpc(self.tbSettingGroup.nChangeFactionNpcId, 1, nRoomIndex, x, y)
	pNpcFaction.nChangeToFactionId = nOldFaction
	pNpcFaction.SetName( string.format("%s门派之力", Faction:GetName(nOldFaction)) )
	--队伍里的变化

	local nLightID = pPlayer.GetUserValue(OpenLight.nSaveGroupID, OpenLight.nSaveLightID);
    if nLightID > 0 then
        OpenLight:ServerUpdateOpenLight(pPlayer);
    end
    Timer:Register(2, self.DelaySetPlayerLife, self, pPlayer.dwID, nOldCurLife / nOldMaxLife) --移除之前被动buff是下一帧才实际生效

    pNpc.SetAllFactionSkillCD(self.tbSettingGroup.nChangeFactionSkillCD);
    pPlayer.CallClientScript("InDifferBattle:CheckAfterChangeFaction")
	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if teamData then
		local tbMenbers = TeamMgr:GetMembers(teamData.nTeamID)
		for i,v in ipairs(tbMenbers) do
			local pPlayer = self:GetPlayerObjById(v)
			if pPlayer then
				pPlayer.CallClientScript("TeamMgr:OnSynNewTeam", teamData.nTeamID, teamData.nCaptainID, teamData:GetLuaTeamMemberData(pPlayer.dwID), true);	
			end
		end
	end
	return true
end

--重载
function tbBattleBase:AddMapNpc(nTemplateId, nLevel, nRoomIndex, x, y, nDir, nReviveTime, nLiveTime)
	x, y = self:GetCanUsePos(x, y)
	local pNpc = KNpc.Add(nTemplateId, nLevel, -1, self.nMapId, x, y, 0, nDir) 
	if pNpc then
		pNpc.nReviveTime = nReviveTime
		if tbDefine.tbAutoDeleteWhenStateChangeNpc[nTemplateId] then
			table.insert(self.tbAutoDeleteNpcs, pNpc.nId)
		end
		if nLiveTime then
			Timer:Register(Env.GAME_FPS * nLiveTime, self.DeleteNpc, self, pNpc.nId) 
		end
		return pNpc
	end
end

function tbBattleBase:GetRoomRandPos( nRoomIndex )
	local tbRoomRegion = self.tbSettingGroup.tbRoomRegion[nRoomIndex]
	local tbUseIndex = {1,2,3,4}
	table.remove(tbUseIndex, MathRandom(4))
	local x1,y1 = unpack(tbRoomRegion[tbUseIndex[1]])
	local x2,y2 = unpack(tbRoomRegion[tbUseIndex[2]])
	local x3,y3 = unpack(tbRoomRegion[tbUseIndex[3]])
	local a1 = x2 == x1 and 0 or (y2- y1) / (x2 - x1)
	local b1 = y1 - a1*x1
	local nRandX1 = x1 < x2 and  ( x1 + MathRandom(0, x2 - x1)  ) or ( x2 + MathRandom(0, x1 - x2) )
	local nRandY1 = a1* nRandX1 + b1
	
	local a2 = x3 == nRandX1 and 0 or (y3 - nRandY1) / (x3 - nRandX1)
	local b2 = y3 - a2*x3
	local nRandX2 = nRandX1 < x3  and ( nRandX1 + MathRandom(0, math.floor(x3 - nRandX1)) )  or ( x3 + MathRandom(0, math.floor( nRandX1 - x3)) )
	local nRandY2 = a2* nRandX2 + b2
	return nRandX2, nRandY2
end

--副本接口
-- 1.指定房间组合，刷新数量，每个房间的刷新个数范围，存活时间（不填就不消失），出怪和出采集物资源使用不同的点集合名字
function tbBattleBase:AddRandRoomRandNpc(nNpcGroup, nLevel, nRoomGroup, nRoomNum, tbRandNpcNum, nLiveTime)
	local tbNpcGroup = self.tbSettingGroup.tbAddRandNpcGroup[nNpcGroup]
	local tbAddRooms = {}
	local tbCopyRooms = { unpack(self.tbSettingGroup.tbAddRandRoomGroup[nRoomGroup]) }

	local x = 1
	while true do
		local nRandRoomIndex;
		local nLeftCount = #tbCopyRooms
		if nLeftCount == 1 then
			nRandRoomIndex = table.remove(tbCopyRooms) 
		elseif nLeftCount == 0 then
				break;
		else
			nRandRoomIndex = table.remove(tbCopyRooms, MathRandom(nLeftCount))
		end
		if self.tbCanUseRoomIndex[nRandRoomIndex] then
			table.insert(tbAddRooms, nRandRoomIndex)
			if #tbAddRooms >=nRoomNum then
				break;
			end
		end
	end

	for i, nRoomIndex in ipairs(tbAddRooms) do
		local nAddNpcCount = MathRandom(unpack(tbRandNpcNum))
		--先按顺序吧，不影响，
		local tbPosSet = self.tbRooomPosSet[nRoomIndex]
		for j=1,nAddNpcCount do
			local nTemplateId = tbNpcGroup[MathRandom(1, #tbNpcGroup)]
			local x,y = self:GetRoomRandPos(nRoomIndex)
			local pNpc = self:AddMapNpc(nTemplateId, nLevel, nRoomIndex, x, y)
			if pNpc and nLiveTime then
				Timer:Register(Env.GAME_FPS * nLiveTime, self.DeleteNpc, self, pNpc.nId) 
			end
		end
	end
end

function tbBattleBase:CastPosionGasBuffToRoomPlayer(nRoomIndex)
	local nForceSyncNpcId = self.tbForceSynNpcSet[1] 
	local pNpc = KNpc.GetById(nForceSyncNpcId)
	if pNpc then
		local fnFunction = function (pPlayer, nRoomIndex)
			pNpc.CastSkill(self.tbSettingGroup.nPosionGasSkillStateId, self.nCurPosionGasLevel, -1, pPlayer.GetNpc().nId)
		end
		self:ForEachAlivePlayerInRoom(nRoomIndex, fnFunction)
	end
end

function tbBattleBase:CastPosionGasBuffToPlayer(pPlayer)
	local nForceSyncNpcId = self.tbForceSynNpcSet[1] 
	local pNpc = KNpc.GetById(nForceSyncNpcId)
	if pNpc then
		pNpc.CastSkill(self.tbSettingGroup.nPosionGasSkillStateId, self.nCurPosionGasLevel, -1, pPlayer.GetNpc().nId)
	end
end

--重载
function tbBattleBase:_CloseRoom(nRoomIndex)
	self:CastPosionGasBuffToRoomPlayer(nRoomIndex)
	for _, nTimer in ipairs(self.tbTimerGroup[nRoomIndex]) do
		Timer:Close(nTimer)
	end
	self.tbTimerGroup[nRoomIndex] = {};
	-- self.tbForceSynNpcSet[nRoomIndex] = nil; --关闭的房间也有技能放的可能
	self.tbCanUseRoomIndex[nRoomIndex] = nil;
	self.tbNpcDmgInfo[nRoomIndex] = nil;
end


--重载
function tbBattleBase:ChangeFightPower(pPlayer, szType)
	if szType then
		FightPower:ChangeFightPower(szType, pPlayer);
	else
		FightPower:ResetFightPower(pPlayer); --是有buff减少战力的，更新下
	end
	local nFightPower = pPlayer.GetNpc().GetFightPower();
	local nTitleId;
	local tbFightPowerToTitle = self.tbSettingGroup.tbFightPowerToTitle
	for i,v in ipairs(tbFightPowerToTitle) do
		if nFightPower > v.nMinFightPower then
			nTitleId = v.nTitleId
		else
			break;
		end
	end
	local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
	local nOldTitleId = tbInfo.nTitleId
	--如果是初始avatar变身，对应的称号还是会清掉的
	if nTitleId ~= nOldTitleId then
		if nOldTitleId then
			pPlayer.DeleteTitle(nOldTitleId, true)
		end
		if nTitleId then
			pPlayer.AddTitle(nTitleId, self.tbSettingGroup.nTotalGameFightTime , true, false, true)
		end
		tbInfo.nTitleId = nTitleId
	end
end

function tbBattleBase:MarkDangerouRoomIndex(widthFrom, heightFrom, widthTo, heightTo, widthTar)
	local nRandX = MathRandom( widthFrom, widthTo - widthTar + 1 )
	local nRandY = MathRandom( heightFrom, heightTo - widthTar + 1 )

	self.tbReadyCloseRoomIndex = {}
	local tbSafeRoom = {};

	for nCol=nRandX,nRandX + widthTar - 1 do
		for nRow=nRandY,nRandY + widthTar - 1 do
			local nRoomIndex = InDifferBattle:GetRoomIndexByRowCol(self.szBattleType, nRow, nCol)
			tbSafeRoom[nRoomIndex] = 1;
		end
	end
	--所有的可用房间不是下个安全的就是将要 关闭的
	for k,v in pairs(self.tbCanUseRoomIndex) do
		if not tbSafeRoom[k] then
			self.tbReadyCloseRoomIndex[k] = 1;
		end
	end

	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomReadyCloseInfo", self.tbReadyCloseRoomIndex)	
end

function tbBattleBase:MarkDangerouRoomCurByRange(widthTar)
	--先找出x 和 y 的最大最小 --直接从 tbCanUseRoomIndex 里找就行了，那个本身就是连贯的矩形范围
	local widthFrom, heightFrom, widthTo, heightTo = 999, 999, 1, 1
	for nRoomIndex, v in pairs(self.tbCanUseRoomIndex) do
		local nRow, nCol = unpack(v)
		if nCol <  widthFrom then
			widthFrom = nCol
		end
		
		if nCol > widthTo then
			widthTo = nCol
		end
		if nRow <  heightFrom then
			heightFrom = nRow
		end
		if nRow > heightTo then
			heightTo = nRow
		end
	end
	self:MarkDangerouRoomIndex(widthFrom, heightFrom, widthTo, heightTo, widthTar)
end

function tbBattleBase:ChangeDangerousRoom(nGasLevel)
	local tbTimers = self.tbTypeNameTimers.Monster
	local nOldnCurFreshMonsterRooomIndex = self.nCurFreshMonsterRooomIndex
	if tbTimers then
		for i,v in ipairs(tbTimers) do
			Timer:Close(v);
		end
		self.tbTypeNameTimers.Monster = nil;
		self.nCurFreshMonsterRooomIndex = nil;
	end

	self.nCurPosionGasLevel = nGasLevel;

	local tbReadyCloseRoomIndex = self.tbReadyCloseRoomIndex
	for k,v in pairs(tbReadyCloseRoomIndex) do
		self:_CloseRoom(k)		
	end
	if nOldnCurFreshMonsterRooomIndex and self.tbCanUseRoomIndex[nOldnCurFreshMonsterRooomIndex] then
		local fnFunction = function (pPlayer, nRoomIndex)
			pPlayer.RemoveSkillState(self.tbSettingGroup.nPosionGasSkillStateId)
		end
		self:ForEachAlivePlayerInRoom(nOldnCurFreshMonsterRooomIndex, fnFunction)
	end
	
	--同步关闭的房间信息
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomOpenInfo", self.tbCanUseRoomIndex, self.nCurFreshMonsterRooomIndex)	

	self.tbReadyCloseRoomIndex = nil;
end

function tbBattleBase:BeforeSwithToRoom(pPlayer, nRoomIndex, bNotCheck)
	if not self.tbCanUseRoomIndex[nRoomIndex] or nRoomIndex == self.nCurFreshMonsterRooomIndex then
		--毒气buff
		self:CastPosionGasBuffToPlayer(pPlayer)
	else
		pPlayer.RemoveSkillState(self.tbSettingGroup.nPosionGasSkillStateId)
	end
	return true
end

function tbBattleBase:DelayRevivePlayerCustom(pPlayer)
	local nRoomIndex = self.tbTeamRoomInfo[pPlayer.dwTeamID][pPlayer.dwID]
	if not self.tbCanUseRoomIndex[nRoomIndex] or nRoomIndex == self.nCurFreshMonsterRooomIndex then
		self:CastPosionGasBuffToPlayer(pPlayer)
	end
end

function tbBattleBase:TrowNpcNearbyPlayer(pPlayer, nNpcId)
	if not nNpcId then
		return
	end
	local _,x,y = pPlayer.GetWorldPos()
	local nRoomIndex = self.tbTeamRoomInfo[pPlayer.dwTeamID][pPlayer.dwID]
	self:AddMapNpc(nNpcId, 1, nRoomIndex, x, y)				
end



function tbBattleBase:CheckCanGatherEnhance( pPlayer, nTemplateId )
	return  InDifferBattle:CheckCanGatherEnhance(pPlayer, nTemplateId)
	
end

function tbBattleBase:GatherEnhance(pPlayer, nTemplateId)
	local nNextLevel, nOldStrenLevel = self:CheckCanGatherEnhance(pPlayer, nTemplateId)
	if not nNextLevel then
		return
	end
	for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
		pPlayer.SetStrengthen(nEquipPos, nNextLevel) 
		pPlayer.SetUserValue(Strengthen.USER_VALUE_GROUP, nEquipPos + 1, nNextLevel)
	end
	
	Strengthen:UpdateEnhAtrrib(pPlayer);
	self:ChangeFightPower(pPlayer, "Strengthen");

	pPlayer.CallClientScript("InDifferBattle:OnLevelUpItemSuc", "StrengthenAll", nNextLevel)
	local nReplaceNpcId = InDifferBattle:FindEnhanceNpcByLevel(nOldStrenLevel)
	self:TrowNpcNearbyPlayer(pPlayer, nReplaceNpcId)
	return true
end

function tbBattleBase:CheckGatherHorseEquip(pPlayer, nTemplateId)
	return InDifferBattle:CheckGatherHorseEquip(pPlayer, nTemplateId)
end

function tbBattleBase:FindEquipNpcById(dwTemplateId)
	for k,v in pairs(self.tbSettingGroup.tbHorseNpcToEquipId) do
		if v == dwTemplateId then
			return k;
		end
	end
end

--有类似的获取装备的可以通用
function tbBattleBase:GatherHorseEquip(pPlayer, nTemplateId)
	local nEquipId, pCurEquip = self:CheckGatherHorseEquip(pPlayer, nTemplateId)
	if not nEquipId then
		return
	end
	
	local pNewEquiop = pPlayer.AddItem(nEquipId, 1)
	if not pNewEquiop then
		Log(debug.traceback())
		return
	end
	pPlayer.UseEquip(pNewEquiop.dwId, -1);
	self:ChangeFightPower(pPlayer, "Horse");
		
	local nReplaceNpcId;
	if pCurEquip then
		local nReplaceNpcId = self:FindEquipNpcById(pCurEquip.dwTemplateId)
		pCurEquip.Delete(0)
		self:TrowNpcNearbyPlayer(pPlayer, nReplaceNpcId)
	end
	return true
end

function tbBattleBase:CheckGatherSkillBook(pPlayer, nNpcTemplateId)
	return InDifferBattle:CheckGatherSkillBook(pPlayer, nNpcTemplateId)
end

function tbBattleBase:GatherSkillBook( pPlayer, nNpcTemplateId )
	--先获取已有秘籍
	local tbSkillBookNpc = self.tbSettingGroup.tbSkillBookNpc
	local tbBookType = tbSkillBookNpc[nNpcTemplateId]
	local pCurEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_SKILL_BOOK)
	local nOldBookType;
	if pCurEquip then
		nOldBookType = tbSkillBook:GetBookType(pCurEquip.dwTemplateId);		
		for i,v in ipairs(tbBookType) do
			if v == nOldBookType then
				pPlayer.CenterMsg("已有同等级秘笈")
				return
			end
		end
		pCurEquip.Delete(0);
		for nEquipPos = Item.EQUIPPOS_SKILL_BOOK,Item.EQUIPPOS_SKILL_BOOK + 3 do
			local pCurEquip = pPlayer.GetEquipByPos(nEquipPos)
			if pCurEquip then
				pCurEquip.Delete(0);
			end
		end
	end

	Player:SkillBook(pPlayer, tbBookType)
	self:ChangeFightPower(pPlayer, "Equip");
	if nOldBookType then
		local nReplaceNpcId = InDifferBattle:_GetSkillBookGatherNpcByType(nOldBookType)
		self:TrowNpcNearbyPlayer(pPlayer, nReplaceNpcId)
	end

	return true
end

function tbBattleBase:CheckGatherItemBagCount(pPlayer, nNpcTemplateId )
	return InDifferBattle:CheckGatherItemBagCount(pPlayer, nNpcTemplateId, self.tbPlayerInfos[pPlayer.dwID])
end

function tbBattleBase:GatherItemBagCount(pPlayer, nNpcTemplateId)
	local tbInfo, nOldItemBagNpcId = self:CheckGatherItemBagCount(pPlayer, nNpcTemplateId)
	if not tbInfo then
		return
	end

	tbInfo.nNowItemBagNpcId = nNpcTemplateId
	if nOldItemBagNpcId ~= self.tbSettingGroup.nDefautItemBagNpcId then
		self:TrowNpcNearbyPlayer(pPlayer, nOldItemBagNpcId)
	end
	pPlayer.CallClientScript("InDifferBattle:UpDateItemBagCount",tbInfo)
	return true;
end

function tbBattleBase:GetPlayerItemBagCount(pPlayer)
	local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
	return self.tbSettingGroup.tbItemBagLNpcGridCount[tbInfo.nNowItemBagNpcId].nCount
end

function tbBattleBase:CheckGatherItem(pPlayer)
	local nCurCount = pPlayer.GetBagUsedCount();
	local nMaxCount = self:GetPlayerItemBagCount(pPlayer)
	if nCurCount >= nMaxCount then
		me.CenterMsg("背包空间不足")
		return
	end
	return true	
end

function tbBattleBase:FindGatherNpcByItemId(dwTemplateId)
	for nNpcTemplateId, nItemId in pairs(self.tbSettingGroup.tbGatherGetItemNpc) do
		if dwTemplateId == nItemId then
			return nNpcTemplateId;
		end
	end	
end

function tbBattleBase:GatherItem(pPlayer, nNpcTemplateId)
	--	先判断背包空间够不够
	if not self:CheckGatherItem(pPlayer) then
		return
	end

	local nItemId = self.tbSettingGroup.tbGatherGetItemNpc[nNpcTemplateId]
	pPlayer.SendAward({ {"item", nItemId, 1}}, nil,nil, Env.LogWay_InDifferBattle)
	if not pPlayer.bNotifyUseItemTip then
		pPlayer.bNotifyUseItemTip = true
		pPlayer.CenterMsg("按两下行囊道具图示可直接使用！", true)
	end
	return true;
end

function tbBattleBase:ChangePlayerFactionFightByNpc(pPlayer, nNpcTemplateId, nFaction)
	return self:ChangePlayerFactionFight(pPlayer, nFaction)
end

function tbBattleBase:TrowItem(pPlayer, nItemId)
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	local dwTemplateId = pItem.dwTemplateId
	local nFromNpcId;
	for k,v in pairs( self.tbSettingGroup.tbGatherGetItemNpc) do
		if v == dwTemplateId then
			nFromNpcId = k;
		end
	end
	if not nFromNpcId then
		pPlayer.CenterMsg("不可丢弃的道具类型")
		return
	end
	pItem.Delete(0)
	self:TrowNpcNearbyPlayer(pPlayer, nFromNpcId)
end

function tbBattleBase:SelectPlayerDeathDrop(pPlayer, nIndex, nNpcId)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		pPlayer.CenterMsg("宝箱已消失")
		return
	end

	local tbDropNpcs = pNpc.tbDropNpcs
	if not tbDropNpcs then
		pPlayer.CenterMsg("无效的npc")
		return
	end

	local tbSelInfo = tbDropNpcs[nIndex]
	if not tbSelInfo then
		pPlayer.CenterMsg("该掉落物已消失")
		pPlayer.CallClientScript("Ui:OpenWindow", "DreamlandDangerCollectionPanel", tbDropNpcs, nNpcId)
		return
	end

	if pPlayer.GetNpc().GetDistance(nNpcId) >= tbDefine.nCanBuyDistance then
		pPlayer.CenterMsg("您距离宝箱太远了")
		return
	end
	local nTemplateId, nFaction = unpack(tbSelInfo)
	local szFunc = self.tbSettingGroup.tbNpcIdToFunction[nTemplateId]
	if not szFunc then
		pPlayer.CenterMsg("错误的配置")
		return
	end

	local bRet = self[szFunc](self, pPlayer, nTemplateId, nFaction);
	if bRet then
		if not nFaction then
			local szNpcName = KNpc.GetNameByTemplateId(nTemplateId)
			pPlayer.CenterMsg(string.format("你获得了「%s」！", szNpcName), true)
		end
		tbDropNpcs[nIndex] = nil;
		if not next(tbDropNpcs) then
			self:DeleteNpc(nNpcId)
		end
		pPlayer.CallClientScript("Ui:OpenWindow", "DreamlandDangerCollectionPanel", tbDropNpcs, nNpcId)
	end
end

--重载
function tbBattleBase:OnDrapAwardListNpcDeath(pNpc, pKiller)
	local tbNpcInfo = self.tbSingleRoomNpc[pNpc.nTemplateId]
	local szDropAwardList = tbNpcInfo.szDropAwardList
	if not szDropAwardList then
		return
	end
	
	self:AddDropAwardNpcRearBy(pNpc, szDropAwardList[self.nSchedulePos], tbNpcInfo.nDropAwardNum, tbNpcInfo.nDropAwardNum)
end

function tbBattleBase:AddDropAwardNpcRearBy(pNpc, szDropAward, nRandMin, nRandMax)
	local nRoomIndex = pNpc.nRoomIndex
	if not nRoomIndex then
		Log(debug.traceback())
		return
	end
	local tbDropList = self.tbSettingGroup.tbDrapList[szDropAward]
	local nNum = nRandMax == 1 and 1 or MathRandom(nRandMin, nRandMax);
	local _, x, y = pNpc.GetWorldPos()
	for i=1,nNum do
		local nRand = MathRandom()	
		for _,v in ipairs(tbDropList) do
			local _rand, tbAwawrd = unpack(v)
			if nRand <= _rand then
				local szType, nNpcGroup, nCount, nLiveTime = unpack(tbAwawrd)
				if szType ~= "DropNpc" then
					Log(debug.traceback()) --initcheck 现在绝地的都是 DropNpc
				else
					local tbNpcGroup = self.tbSettingGroup.tbAddRandNpcGroup[nNpcGroup]
					for i2=1,nCount do
						local nTemplateId = tbNpcGroup[ MathRandom(1, #tbNpcGroup) ]
						self:AddMapNpc(nTemplateId, 1, nRoomIndex, x, y,nil,nil, nLiveTime)				
					end
				end
				break;
			end
		end
	end
end

function tbBattleBase:OnAddRandNpcNearBy(pPlayer, pNpc, szDropAward, nRandMin, nRandMax)
	self:AddDropAwardNpcRearBy(pNpc, szDropAward, nRandMin, nRandMax)
end

function tbBattleBase:AddRandRoomBuff(szBuffParam, nRoomGroup, nRoomNum, tbRandNpcNum)
	local tbAddRooms = {}
	local tbCopyRooms = { unpack(self.tbSettingGroup.tbAddRandRoomGroup[nRoomGroup]) }
	for i = 1, nRoomNum do
		if #tbCopyRooms == 1 then
			table.insert(tbAddRooms, tbCopyRooms[1])
		else
			local nRoomIndex = table.remove(tbCopyRooms, MathRandom(#tbCopyRooms))
			table.insert(tbAddRooms, nRoomIndex)
		end
	end
	for i, nRoomIndex in ipairs(tbAddRooms) do
		local nAddNpcCount = MathRandom(unpack(tbRandNpcNum))
		--先按顺序吧，不影响，
		local tbPosSet = self.tbRooomPosSet[nRoomIndex]
		for j=1,nAddNpcCount do
			local x,y = self:GetRoomRandPos(nRoomIndex)
			x, y = self:GetCanUsePos(x, y)
			Item.Obj:DropBufferInPosWhithType(Item.Obj.TYPE_CHECK_FIGHT_MODE_RIDE, self.nMapId, x,y, szBuffParam);
		end
	end
end

function tbBattleBase:FreshMonsterNotiy()
	self.nNextFreshMonsterRooomIndex = self:GetRandomSafeRoomIndex()
	if not self.nNextFreshMonsterRooomIndex then
		return
	end
	self:SendMapBlackBoardMsgAndSysMsg(string.format( self.tbSettingGroup.szMonsterRefreshNotiy, self.nNextFreshMonsterRooomIndex))
end

function tbBattleBase:FreshMonsterBorn(nStayTime, nDir)
	--幻兽的单独用一个，不然安全区可能不连续，一些计算会出问题
	local nRoomIndex = self.nNextFreshMonsterRooomIndex
	if not nRoomIndex then
		return
	end

	local x, y = unpack(self.tbRooomPosSet[nRoomIndex]["center"]) 
	local pNpc = self:AddMapNpc(self.tbSettingGroup.nRefreshMonsterNpcId, 1, nRoomIndex, x, y, nDir, nil, nStayTime)
	if not pNpc then
		Log(debug.traceback())
		return
	end
	pNpc.nFightMode = 0;
	local nOldRoomIndex = self.nCurFreshMonsterRooomIndex
	self.nCurFreshMonsterRooomIndex = nRoomIndex
	--对房间内的玩家添加毒
	self:CastPosionGasBuffToRoomPlayer(nRoomIndex)

	if nOldRoomIndex and self.tbCanUseRoomIndex[nOldRoomIndex] then
		local fnFunction = function (pPlayer, nRoomIndex)
			pPlayer.RemoveSkillState(self.tbSettingGroup.nPosionGasSkillStateId)
		end
		self:ForEachAlivePlayerInRoom(nOldRoomIndex, fnFunction)
	end

	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomOpenInfo", self.tbCanUseRoomIndex, self.nCurFreshMonsterRooomIndex)	
end

function tbBattleBase:GetRandomSafeRoomIndex()
	local tbRooms = {}
	for nRoomIndex,v in pairs(self.tbCanUseRoomIndex) do
		table.insert(tbRooms, nRoomIndex)
	end
	if #tbRooms == 1 then 
		return tbRooms[1]
	else
		return tbRooms[ MathRandom(#tbRooms) ]
	end
end

function tbBattleBase:StartFreshMonsterTimer(nPreNotifyTime, nStayTime, nDir)
	-- 切状态 时会将这里的timer关闭，所以及时这里的timer 里有先设 tbCanUseRoomIndex 恢复应该也不会错误回复真正关闭的房间
	self:FreshMonsterNotiy()
	local nRealStayTime = nPreNotifyTime + nStayTime
	Timer:Register(Env.GAME_FPS * nPreNotifyTime, function ()
			self:FreshMonsterBorn(nRealStayTime, nDir)
	end)

	self.tbTypeNameTimers.Monster  = self.tbTypeNameTimers.Monster or {};
	local tbTimers = self.tbTypeNameTimers.Monster

	local nTimerId = Timer:Register(Env.GAME_FPS * (nPreNotifyTime + nStayTime), function ()
			self:FreshMonsterNotiy()
		return true;
	end)
	table.insert(tbTimers, nTimerId)			

	local nTimerId = Timer:Register(Env.GAME_FPS * (nPreNotifyTime + nStayTime + nPreNotifyTime), function ()
			self:FreshMonsterBorn(nRealStayTime, nDir)
		return true;
	end)

	table.insert(tbTimers, nTimerId)			
end

function tbBattleBase:OnCustomPlayerDeath(pDeather)
	--掉落身上的采集物，门派， 强化，秘籍，坐骑 --行囊
	local tbDropNpcs = {}
	local _,x,y = pDeather.GetWorldPos()
	local nRoomIndex = self.tbTeamRoomInfo[pDeather.dwTeamID][pDeather.dwID]
	local tbSettingGroup = self.tbSettingGroup
	table.insert(tbDropNpcs, {tbSettingGroup.nChangeFactionNpcId, pDeather.nFaction })
	--强化
	local tbStrengthen = pDeather.GetStrengthen();
	local nOldStrenLevel = tbStrengthen[1];
	local nReplaceNpcId = InDifferBattle:FindEnhanceNpcByLevel(nOldStrenLevel)
	if nReplaceNpcId then
		table.insert(tbDropNpcs, {nReplaceNpcId})
	end
	--秘籍
	local pCurEquip = pDeather.GetEquipByPos(Item.EQUIPPOS_SKILL_BOOK)
	if pCurEquip then
		local nOldBookType = tbSkillBook:GetBookType(pCurEquip.dwTemplateId);		
		local nReplaceNpcId = InDifferBattle:_GetSkillBookGatherNpcByType(nOldBookType)
		if nReplaceNpcId then
			table.insert(tbDropNpcs, {nReplaceNpcId})	
		end
	end
	--坐骑
	local pCurEquip = pDeather.GetEquipByPos(Item.EQUIPPOS_HORSE)
	if pCurEquip then
		local nReplaceNpcId = self:FindEquipNpcById(pCurEquip.dwTemplateId)
		if nReplaceNpcId then
			table.insert(tbDropNpcs, {nReplaceNpcId})	
		end
	end
	--行囊
	local tbInfo = self.tbPlayerInfos[pDeather.dwID]
	if tbInfo.nNowItemBagNpcId ~= tbSettingGroup.nDefautItemBagNpcId then
		table.insert(tbDropNpcs, {tbInfo.nNowItemBagNpcId})
	end
	--身上的其他道具
	local tbAllItems = pDeather.GetItemListInBag()
	for i,pItem in ipairs(tbAllItems) do
		local nNpcId = self:FindGatherNpcByItemId(pItem.dwTemplateId)
		if nNpcId then
			table.insert(tbDropNpcs, {nNpcId})	
		end
	end
	local pNpc = self:AddMapNpc(tbSettingGroup.nDeathDropNpcId, 1, nRoomIndex, x, y, nil, nil,tbSettingGroup.nDeathDropNpcAliveTime * Env.GAME_FPS )
	pNpc.tbDropNpcs = tbDropNpcs
end

--重载
function tbBattleBase:AddDropBuffByPosName( szParam, nRoomIndex, szPosName )
	local x,y =  unpack(self.tbRooomPosSet[nRoomIndex][szPosName]) 
	Item.Obj:DropBufferInPosWhithType(Item.Obj.TYPE_CHECK_FIGHT_MODE_RIDE, self.nMapId, x,y, szParam);
end


--重载
function tbBattleBase:OnPlayerTrap(szTrapName)
	local nTrapInRoom = self.tbRoomTrapToPos[szTrapName]  
	if nTrapInRoom then
		local nOldRoomIndex = self.tbTeamRoomInfo[me.dwTeamID][me.dwID]
		if nTrapInRoom ~= nOldRoomIndex then
			self:SwitchToRoom(me, nil, nil, nTrapInRoom, false, true)	
		end
	end
end


function tbBattleBase:StartFightMode()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for i, pPlayer in ipairs(tbPlayer) do
		pPlayer.nFightMode = 1;
	end
end

function tbBattleBase:OnTeamKillNormalNpc(dwTeamID, pNpc)
	local tbBattleNpcDropSetting = self.tbSettingGroup.tbBattleNpcDropSetting
	local tbSeting = tbBattleNpcDropSetting[self.nSchedulePos] or tbBattleNpcDropSetting[0]
	if not tbSeting then
		return
	end
	local nRand = MathRandom()
	for i,v in ipairs(tbSeting) do
		local nTarRand,nNpcGroup,nLiveTime = unpack(v)
		if nRand <= nTarRand then
			local _,x,y = pNpc.GetWorldPos()
			local tbNpcGroup = self.tbSettingGroup.tbAddRandNpcGroup[nNpcGroup]
			local nTemplateId = tbNpcGroup[ MathRandom(1, #tbNpcGroup) ]
			self:AddMapNpc(nTemplateId, 1, nil, x, y,nil,nil, nLiveTime)
			return
		end
	end
end

function tbBattleBase:OnCallMapNpc(pPlayer, pNpc, nTemplateId)
	local _,x,y = pPlayer.GetWorldPos()
	self:AddMapNpc(nTemplateId, 1, nil, x, y)
end

function tbBattleBase:OnUseIndifferItem(pPlayer, dwTemplateId)
	local tbItemUseFunc = self.tbSettingGroup.tbItemUseFunc[dwTemplateId]
	for i,v in ipairs(tbItemUseFunc) do
		Lib:CallBack({self[v[1]], self, pPlayer, dwTemplateId, unpack(v, 2)});	
	end
end

function tbBattleBase:ForbitPlayerChangeActionMode()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			pPlayer.bTempForbitMount = true;
			pPlayer.DoChangeActionMode(Npc.NpcActionModeType.act_mode_none);
			pPlayer.CenterMsg("本阶段禁止骑马", true)
		end
	end
end

function tbBattleBase:SetForceSyncNpcs()
	--先添加上所有放技能的npc，不然开宝箱这种开出来就加npc放技能的不能立马同步, 这里实际就只有一个npc
	local x, y = unpack(tbDefine.tbCastSkillNpcPos[1]) 
	local nTempCastSKillNpcId = InDifferBattle:GetSettingTypeField(self.szBattleType, "nTempCastSKillNpcId")
	local pNpc = self:AddMapNpc(nTempCastSKillNpcId, 80, 1, x, y, 0)
	if pNpc then
		for nRoomIndex = 1, self.tbSettingGroup.nMaxRoomNum do
			self.tbForceSynNpcSet[nRoomIndex] = pNpc.nId;		
		end
	end
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for i, pPlayer in ipairs(tbPlayer) do
		self:ForceSynRoomNpcToPlayer(pPlayer, 1)
	end
end

--重载
function tbBattleBase:OnOpenBoxCastSkillCycle(pPlayer, pNpc, nTimeSpace, nSkillId, nSkilLevel, nParam1, nParam2)
	local _,x,y = pNpc.GetWorldPos()
	self:AddNpcAndTimerCastSkill(1, x,y, nTimeSpace, nSkillId, nSkilLevel, nParam1, nParam2)
end

function tbBattleBase:AddLastAlivePlayerScore()
	local tbInfo = self.tbSettingGroup.tbStateGetScore[self.nSchedulePos - 1]
	if not tbInfo then
		return
	end
	local nAddScore = tbInfo.nSurviveScore

	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			local tbScoreInfo = self.tbTeamReportInfo[pPlayer.dwTeamID][pPlayer.dwID]
			tbScoreInfo.nScore = tbScoreInfo.nScore + nAddScore
		end
	end
end

function tbBattleBase:BroatcastStartState(nState)
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:OnBroatcastStartState", nState)	
end

function tbBattleBase:BroatcastSpecialTips(szTxt)
	KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "SpecialTips", szTxt)	
end
