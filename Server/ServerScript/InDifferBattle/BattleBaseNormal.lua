if not MODULE_ZONESERVER then
	return
end
Require("ServerScript/InDifferBattle/BattleBase.lua")

local tbBattleBase = InDifferBattle:CreateClass("BattleBaseNormal", "BattleBase")
local tbDefine = InDifferBattle.tbDefine


local tbSkillBook = Item:GetClass("SkillBook");

function tbBattleBase:SublClassInit(nMapId, tbTeamIds)
	local nMaxRoomNum, tbSettingGroup = InDifferBattle:GetSettingTypeField(self.szBattleType, "nMaxRoomNum") 
	local tbRoomIndex = tbSettingGroup.tbRoomIndex
	self.tbGateCloseNpcId = {};--房间关闭时需要操作提示的npc列表
	for nRoomIndex=1,nMaxRoomNum do
		self.tbGateCloseNpcId[nRoomIndex] = {}
	end
	for nRoomIndex=1,nMaxRoomNum do
		  --因为用时是 nTarRoomIndex和下面的不一样
		local nRow, nCol = unpack(tbRoomIndex[nRoomIndex])
		for szPosName, tbRowCol in pairs(tbDefine.tbGateDirectionModify) do
			local nRowModi, nColModi = unpack(tbRowCol)
			local nTarRoomIndex = InDifferBattle:GetRoomIndexByRowCol(self.szBattleType, nRow + nRowModi, nCol + nColModi)
			if nTarRoomIndex then
				local pNpc = self:AddMapNpcByPosName(tbDefine.nGateNpcId, 1, 0, nRoomIndex, szPosName)
				if pNpc then
					pNpc.SetName(string.format("前往%d号区域", nTarRoomIndex))
					table.insert(self.tbGateCloseNpcId[nTarRoomIndex], pNpc.nId)	
				end
			end
		end
	end

	
end

function tbBattleBase:ChangePlayerFaction(pPlayer, nFaction)
	if not Player:ChangePlayer2Avatar(pPlayer, nFaction, tbDefine.nPlayerLevel, tbDefine.szAvatarEquipKey, tbDefine.szAvatarEquipKey, tbDefine.nDefaultStrengthLevel) then
		return
	end
	pPlayer.nFightMode = 1;
	pPlayer.GetNpc().RemoveFightSkill(1013) --禁止打坐操作
	
	pPlayer.AddSkillState(tbDefine.nInitAddBuffId, tbDefine.nInitAddBuffLevel, 0, Env.GAME_FPS * tbDefine.nInitAddBuffTime, 1)

	self:ChangeFightPower(pPlayer) --加了头衔有血量
	local pNpc = pPlayer.GetNpc()
	pNpc.SetCurLife(pNpc.nMaxLife)
	self.tbCurFactionChange[pPlayer.dwID] = nFaction
	return true				
end

function tbBattleBase:OnKillPlayerAndGetAward(pKiller, pDeather)
	--坐骑，秘籍， 是取身上的 ,坐骑升阶 和强化, 秘籍升阶段 是使用时记录的
	local dwKillerTeamId = pKiller.dwTeamID
	local tbDeathPlayerInfo = self.tbPlayerInfos[pDeather.dwID]
	local tbRandItems = tbDeathPlayerInfo.tbUsedItems
	local pItems = pDeather.GetItemListInBag();
	for _, pItem in ipairs(pItems) do
		for i=1,pItem.nCount do
			table.insert(tbRandItems, pItem.dwTemplateId)
		end
	end
	local pHorse = pDeather.GetEquipByPos(Item.EQUIPPOS_HORSE);
	if pHorse then
		table.insert(tbRandItems, tbDefine.tbHorseUpgrade[1])
	end

    for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
    	local pEquip = pDeather.GetEquipByPos(nIndex + Item.EQUIPPOS_SKILL_BOOK - 1);
    	if pEquip then
    		local dwLowestItemId = tbSkillBook:GetLowestBookId(pEquip.dwTemplateId)
    		table.insert(tbRandItems, dwLowestItemId)
    	end
    end

    local tbTakeAwrdList = {};
    --爆钱
    local nHasMoney = pDeather.GetMoney(tbDefine.szMonoeyType)
    local nRandMin, nRandMax, nMinNum = unpack(tbDefine.tbKillGetMoneyRand)
    local nRandPersent = MathRandom(nRandMin, nRandMax)
    local nGetMoney = math.max(nMinNum, math.floor( nRandPersent / 100 * nHasMoney) )
    table.insert(tbTakeAwrdList, {tbDefine.szMonoeyType, nGetMoney})
    --掉道具
    if #tbRandItems == 1 then
    	if MathRandom() <= 0.5 then
    		table.insert(tbTakeAwrdList, {"item", tbRandItems[1], 1})
    	end
    elseif #tbRandItems > 1 then
    	local nRandNum = MathRandom(unpack(tbDefine.tbKillGetItemNumRand))
    	nRandNum = #tbRandItems * nRandNum / 100 
    	local nFloor = nRandNum -  math.floor(nRandNum) --小数部分单独随机决定向上还是向下取整
    	if MathRandom() <= nFloor then
    		nRandNum = math.ceil(nRandNum)
    	else
    		nRandNum = math.floor(nRandNum)
    	end
    	for i = 1, nRandNum do
    		if #tbRandItems == 1 then
    			table.insert(tbTakeAwrdList, {"item", tbRandItems[1], 1})
    			break;
    		else
    			local nIndex = MathRandom(#tbRandItems)	
    			local nItemId = table.remove(tbRandItems, nIndex)
    			table.insert(tbTakeAwrdList, {"item", nItemId, 1})
    		end
    	end
    end

    for _, v in ipairs(tbTakeAwrdList) do
    	--如果是门派秘籍则转换下类型
    	local nBookType = tbSkillBook:GetBookType(v[2]) 
    	if nBookType and v[1] == "item" then
    		self:SendAwardToTeamTurns(dwKillerTeamId, {{"SkillBook", nBookType } })
    	else
    		self:SendAwardToTeamTurns(dwKillerTeamId, {v})	
    	end
    end

    local nRobAwardNum = #tbTakeAwrdList
    --水晶数量比较多，就单独算平均分了
    local nCostStoneNum = tbDeathPlayerInfo.nCostStoneNum
    if nCostStoneNum > 0 then
    	--算上钱和道具，SendAwardToTeamTurns至少掉了2次，直接用里面的列表平分就好
    	local nRandNum = MathRandom(unpack(tbDefine.tbKillGetItemNumRand))
    	local tbTurnsGetAwardMembers = self.tbTeamServerInfo[dwKillerTeamId].tbTurnsGetAwardMembers
    	local nPerGetNum =  math.floor(nCostStoneNum * nRandNum / 100 / #tbTurnsGetAwardMembers + 0.5) 
    	if nPerGetNum > 0 then
    		for _,dwRoleId in ipairs(tbTurnsGetAwardMembers) do
	    		local pPlayer = self:GetPlayerObjById(dwRoleId)
	    		if pPlayer and pPlayer.nFightMode ~= 2 then
	    			self:SendAward(pPlayer, {{ "item", tbDefine.nEnhanceItemId, nPerGetNum}});
	    		end
	    	end
	    	nRobAwardNum = nRobAwardNum + nPerGetNum * #tbTurnsGetAwardMembers
    	end
    end

    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」击败了「神秘人」，抢夺了%d个宝物已均分给队伍成员", pKiller.szName, nRobAwardNum), dwKillerTeamId)
    tbDeathPlayerInfo.tbUsedItems = {};
	tbDeathPlayerInfo.nCostStoneNum = 0;
end

function tbBattleBase:SetForceSyncNpcs()
	--先添加上所有放技能的npc，不然开宝箱这种开出来就加npc放技能的不能立马同步
	local fnFunction = function (pPlayer, nRoomIndex)
		self:ForceSynRoomNpcToPlayer(pPlayer, nRoomIndex)
	end
	local nTempCastSKillNpcId = InDifferBattle:GetSettingTypeField(self.szBattleType, "nTempCastSKillNpcId")
	for nRoomIndex=1,25 do
		local x, y = unpack(tbDefine.tbCastSkillNpcPos[nRoomIndex]) 
		local pNpc = self:AddMapNpc(nTempCastSKillNpcId, 80, nRoomIndex, x, y, 0)
		if pNpc then
			self.tbForceSynNpcSet[nRoomIndex] = pNpc.nId;	
			self:ForEachAlivePlayerInRoom(nRoomIndex, fnFunction)
		end
	end
end

function tbBattleBase:ResetTime()
	self.bRestTime = true
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	local nAddScore = self.tbSettingGroup.tbStateGetScore[self.nSchedulePos].nSurviveScore
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			 --加存活分
			local tbScoreInfo = self.tbTeamReportInfo[pPlayer.dwTeamID][pPlayer.dwID]
			tbScoreInfo.nScore = tbScoreInfo.nScore + nAddScore
			--不然可以打小怪
			pPlayer.AddSkillState(tbDefine.nSafeStateSkillBuffId, 1, 0, 15000)
		end
	end
end

function tbBattleBase:ReStartFight()
	self.bRestTime = nil;
	self:CloseRoom(); --关闭预关闭的房间
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			pPlayer.RemoveSkillState(tbDefine.nSafeStateSkillBuffId)
			if self.nSchedulePos == 7 then
				local nBuffId, nLevel, nTime = unpack(tbDefine.tbLastSkillBuff)
		         pPlayer.AddSkillState(nBuffId, nLevel, 0, nTime)
		         pPlayer.bTempForbitMount = true;
		         pPlayer.DoChangeActionMode(Npc.NpcActionModeType.act_mode_none);
		         pPlayer.CenterMsg("本阶段禁止骑马", true)
			end
		end
	end
	if self.nSchedulePos == 7 then
		local nRoomIndex = 1;
		for _,nNpcId in ipairs(self.tbMapNpcGroup[nRoomIndex]) do
			self:DeleteNpc(nNpcId)
		end
		self.tbMapNpcGroup[nRoomIndex] = {};
		for _, nTimer in ipairs(self.tbTimerGroup[nRoomIndex]) do
			Timer:Close(nTimer)
		end
		self.tbTimerGroup[nRoomIndex] = {};
	end
end

function tbBattleBase:CloseRoom()
	local tbReadyCloseRoomIndex = self.tbReadyCloseRoomIndex
	for k,v in pairs(tbReadyCloseRoomIndex) do
		self:_CloseRoom(k)		
	end

	self:PlayerOnCloseRoom(tbReadyCloseRoomIndex)
	
	--同步关闭的房间信息
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomOpenInfo", self.tbCanUseRoomIndex)	

	self.tbReadyCloseRoomIndex = nil;
end

function tbBattleBase:ShopBuy(pPlayer, nNpcId, nTemplateId, nBuyCount)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		pPlayer.CenterMsg("神秘商人已经离开")
		return
	end

	local tbCurSellWares = pNpc.tbCurSellWares
	if not tbCurSellWares then
		pPlayer.CenterMsg("无效的npc")
		return
	end

	local nOriBookId = InDifferBattle:GetRandSkillBookOriId(nTemplateId)
	if nOriBookId then
		nTemplateId = nOriBookId;
	end

	local nLeftItemNum = tbCurSellWares[nTemplateId]
	if not nLeftItemNum or nLeftItemNum < nBuyCount then
		pPlayer.CenterMsg("该商品库存不足")
		return
	end

	if pPlayer.GetNpc().GetDistance(nNpcId) >= tbDefine.nCanBuyDistance then
		pPlayer.CenterMsg("您距离神秘商人太远了")
		return
	end

	local nCost, szMonoeyType = InDifferBattle:GetBuySumPrice(nTemplateId, nBuyCount)
	if not pPlayer.CostMoney(szMonoeyType, nCost, Env.LogWay_InDifferBattle) then
		return
	end

	tbCurSellWares[nTemplateId] = nLeftItemNum - nBuyCount
	self:SendAward(pPlayer, { { "item", nTemplateId, nBuyCount } }, true)
	pPlayer.CallClientScript("InDifferBattle:OnBuyShopWareSuc", tbCurSellWares, nNpcId)
end

function tbBattleBase:SellItem(pPlayer, nItemId, nCount)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		print("Unexsit Item "..nItemId)
		return;
	end
	local dwTemplateId = pItem.dwTemplateId;
	local nPrice, szMonoeyType = InDifferBattle:GetSellSumPrice(dwTemplateId, nCount)
	if not nPrice then
		return
	end
	if pPlayer.ConsumeItem(pItem, nCount, Env.LogWay_InDifferBattle) ~= nCount then
		Log("ERROR Shop:Sell comsumeItem failed ", pPlayer.dwID, dwTemplateId, nCount);
		return
	end
	self:SendAward(pPlayer, { { szMonoeyType, nPrice} } )
end

function tbBattleBase:BookUpgrade(pPlayer, nEquipId, nCostItemId, nEquipPos)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	local pCostItem = pPlayer.GetItemInBag(nCostItemId)
	if not pCostItem then
		return
	end
	local pEquip = pPlayer.GetItemInBag(nEquipId)

	if not pEquip then
		return
	end
	
	local nOlddwTemplateId = pEquip.dwTemplateId
	local tbBookInfo = tbSkillBook:GetBookInfo(nOlddwTemplateId);
	if not tbBookInfo then
		return
	end
	if tbBookInfo.Type >= tbDefine.nMaxSkillBookType then
		return
	end

	if tbBookInfo.UpgradeItem <= 0 then
		return
	end

	local tbUsedItems = self.tbPlayerInfos[pPlayer.dwID].tbUsedItems
	local dwCostItemId = pCostItem.dwTemplateId

	if pPlayer.ConsumeItem(pCostItem, 1, Env.LogWay_InDifferBattle) ~= 1 then
		return
	end
	table.insert(tbUsedItems, dwCostItemId)

	pEquip.Delete(Env.LogWay_InDifferBattle, 0);

	local pNewEquip = self:AddItemToPlayer(pPlayer, tbBookInfo.UpgradeItem, 1)
	if not pNewEquip then
		return
	end
	pPlayer.UseEquip(pNewEquip.dwId, nEquipPos)
	self:ChangeFightPower(pPlayer, "Skill");
	self:ChangeFightPower(pPlayer, "Equip");
	pPlayer.CallClientScript("InDifferBattle:OnLevelUpItemSuc", "BookUpgrade", nOlddwTemplateId, pNewEquip.dwTemplateId)
end


function tbBattleBase:OnTeamKillNormalNpc(dwTeamID, pNpc)
	local tbBattleNpcDropSetting = tbDefine.tbBattleNpcDropSetting[self.nSchedulePos]
	if tbBattleNpcDropSetting then
		local tbAward = tbBattleNpcDropSetting[MathRandom(#tbBattleNpcDropSetting)] 
		if tbAward then
			self:SendAwardToTeamTurns(dwTeamID, {tbAward})			
		end
	end
end

--重载
function tbBattleBase:BeforeSwithToRoom(pPlayer, nRoomIndex, bNotCheck)
	if not self.tbCanUseRoomIndex[nRoomIndex] then
		pPlayer.CenterMsg(nRoomIndex .. "号入口已坍塌")
		return
	end

	-- 如果自己已经死亡，服务端就只限制了不能进入没有已存活队友的房间
	if  not bNotCheck and pPlayer.nFightMode == 2 then --TODO 
		local dwTeamID = pPlayer.dwTeamID
		local dwRoleId = pPlayer.dwID
		local tbTeamRoomInfo = self.tbTeamRoomInfo[dwTeamID]
		local bCan = false;
		for dwID, _nRoomIndex in pairs(tbTeamRoomInfo) do
			if dwID ~= dwRoleId and  _nRoomIndex == nRoomIndex then
				bCan = true;
				break
			end
		end
		if not bCan then
			pPlayer.CenterMsg("您当前状态无法传入目的地区域")
			return
		end
	end
	return true
end

function tbBattleBase:PlayerOnCloseRoom(tbReadyCloseRoomIndex)
	local tbNowCanUseRooms = {}
	for k,v in pairs(self.tbCanUseRoomIndex) do
		table.insert(tbNowCanUseRooms, k)
	end
	for dwTeamID,v in pairs(self.tbTeamRoomInfo) do
		local tbDeathPlayers = {};
		local pAlivePlayer;
		for dwRoleId,nRoomIndex in pairs(v) do
			if tbReadyCloseRoomIndex[nRoomIndex] then
				--随机传送到未关闭的房间 --如果是已经死的玩家则先不传，后面则传到活的玩家边上即可
				local pPlayer = self:GetPlayerObjById(dwRoleId)
				if pPlayer then
					--造成伤害 不能死
					if pPlayer.nFightMode ~= 2 then
						local pNpc = pPlayer.GetNpc()
						pNpc.SetCurLife(pNpc.nCurLife * tbDefine.nCloseRoomPunishPersent )
						local nRandRoom = tbNowCanUseRooms[MathRandom(#tbNowCanUseRooms)] 
						local szPosName = "center"
						if #tbNowCanUseRooms == 1 then
							szPosName = tbDefine.tbLastSwitchRandPosSet[MathRandom(#tbDefine.tbLastSwitchRandPosSet)]
						end

						local x,y = unpack(self.tbRooomPosSet[nRandRoom][szPosName])
						self:SwitchToRoom(pPlayer, x,y, nRandRoom, true)
						pPlayer.CenterMsg("幻境异变，被神秘力量席卷至此！", true)
						pAlivePlayer = pPlayer;
					else
						table.insert(tbDeathPlayers, pPlayer)
					end
				end
			end
		end
		if #tbDeathPlayers == 1 and tbDeathPlayers[1].dwFollowAliveId then
			pAlivePlayer = self:GetPlayerObjById(tbDeathPlayers[1].dwFollowAliveId)
		end
		if pAlivePlayer then  --三个都死在房间等传出去也是可能的
			local nHimRoomIndex = v[pAlivePlayer.dwID]
			local _,x,y = pAlivePlayer.GetWorldPos()
			for _, pPlayer in ipairs(tbDeathPlayers) do 
				self:SwitchToRoom(pPlayer, x,y, nHimRoomIndex, true)
				Dialog:SendBlackBoardMsg(pPlayer, "幻境异变，被神秘力量席卷至此！");	
			end		
		end
	end
end

function tbBattleBase:ReadyCloseRoom( szRoomGroup, szRandomGroup )
	--准备关闭但不是真正关闭
	local tbRoomIndex1; 
	if szRandomGroup then
		local tbGroup = InDifferBattle:GetSettingTypeField(self.szBattleType, szRandomGroup) 
		-- InDifferBattle.tbRoomSetting[szRandomGroup]
		tbRoomIndex1 = tbGroup[MathRandom(#tbGroup)]
	else
		tbRoomIndex1 = InDifferBattle:GetSettingTypeField(self.szBattleType, szRoomGroup) 
	end
		
	self.tbReadyCloseRoomIndex = {}

	for i, nRoomIndex in ipairs(tbRoomIndex1) do
		self.tbReadyCloseRoomIndex[nRoomIndex] = 1;
	end
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomReadyCloseInfo", self.tbReadyCloseRoomIndex)	
end

