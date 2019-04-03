local tbAct = Activity:GetClass("CollectAndRobClue")
local tbItem = Item:GetClass("CollectAndRobClue");

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }


tbAct.tbAllPlayerCollectData = tbAct.tbAllPlayerCollectData or {}; --所有登录过的玩家的碎片数，用于可抢夺，
tbAct.tbAllPlayerRobData = tbAct.tbAllPlayerRobData or {}; --抢夺记录，同步回去后清除
tbAct.tbAllPlayerList = tbAct.tbAllPlayerList or {}; --有数据的 就加入list


-- tbAct.tbAllPlayerRobedCount = tbAct.tbAllPlayerRobedCount or {}; --玩家被抢夺的次数
-- tbAct.nLastRobedRecordDay = tbAct.nLastRobedRecordDay or 0; --上次记录被抢夺次数的天数
--登录时如果内存无，则以玩家身上为准设置，, 内存有抢夺数据的，则对玩家设置后清除掉，  
--每次设置后玩家在线就进行全同步
--[[
	[dwRoleId] = {  [nDebrisId] =  nCount };
	[dwRoleId] = {  [nDebrisId] =  { {nCount, dwRoleId}, 、、、  } }; --因为要记录每个抢夺的人， 这个理应只是下线时非空，因为在线不能抢

]]

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		self:OnActInit()

	elseif szTrigger == "Start" then
		local _, nEndTime = self:GetOpenTimeInfo()
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin");
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLevelUp", "OnPlayerLevelUp");
		Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnAddEverydayAward")
		Activity:RegisterPlayerEvent(self, "Act_ModifyClueCount", "ModifyClueCount")
		Activity:RegisterPlayerEvent(self, "ActClueRequestMyInfo", "RequestMyInfo")
		Activity:RegisterPlayerEvent(self, "ActClueRobhim", "Robhim")
		Activity:RegisterPlayerEvent(self, "ActClueSendHim", "SendHim")
		Activity:RegisterPlayerEvent(self, "ActClueCombieClueDerbis", "CombieClueDerbis")
		Activity:RegisterPlayerEvent(self, "ActClueCombieClueItem", "CombieClueItem")
		Activity:RegisterPlayerEvent(self, "ActClueGetMyItemData", "GetMyItemData")
		Activity:RegisterPlayerEvent(self, "ActClueGetSendList", "GetSendList")
		Activity:RegisterPlayerEvent(self, "Act_OnGetClueRandAward", "OnGetClueRandAward")
		Activity:RegisterPlayerEvent(self, "Act_OnBuyFromNpc", "Act_OnBuyFromNpc")

		self:RegisterDataInPlayer(nEndTime)
		
	elseif szTrigger == "End" then
		
	end
end

function tbAct:OnActInit()
	local tbMailInfo = self:GetActMailInfo()
	Mail:SendGlobalSystemMail(tbMailInfo)
	local _, nEndTime = self:GetOpenTimeInfo()

	NewInformation:AddInfomation("CollectAndRobClue", nEndTime, {self.szNewsText}, {nOperationType = NewInformation.nOperationTypeHuoDong, nShowPriority = 100, szTitle = self.szNewsTitle, nReqLevel = 1} )
end

function tbAct:GetActMailInfo()
	if self.tbMailInfo then
		return self.tbMailInfo
	end
	local _, nEndTime = self:GetOpenTimeInfo()
	local nLastTime = nEndTime - GetTime()
	local nItemEndTime = nEndTime + tbItem.nDelayDelItemTime
	local tbMailInfo = {
            Title = self.szActStartMailTitle,
            Text = self.szActStartMailText,
            tbAttach = {{"item", tbItem.nActStartSendItem, 1, nItemEndTime } },
            nRecyleTime =  nLastTime, --因为是全服邮件的，所以要指定回收时间
            LevelLimit = self.nMinLevel,
        }
    self.tbMailInfo = tbMailInfo
    return tbMailInfo
end

function tbAct:Act_OnBuyFromNpc(pPlayer, pNpc)
	if not pNpc then
		return
	end
	local nRandCount = pNpc.nGetCount
	if not nRandCount then
		Log(debug.traceback())
		return
	end
	local nGetItemId = pNpc.nGetItemId
	if not nGetItemId then
		Log(debug.traceback())
		return
	end
	pNpc.nGetCount = nil;
	local _, nEndTime = self:GetOpenTimeInfo()
	local tbAward = {{ "item",  nGetItemId, nRandCount, nEndTime }}
	pPlayer.SendAward( tbAward, true, nil, Env.LogWay_CollectAndRobClue, pNpc.nTemplateId)
	local szKinMsg = pNpc.szKinMsg
	if szKinMsg then
		local szMsg = string.format(szKinMsg, pPlayer.szName, nRandCount)
		if pPlayer.dwKinId ~= 0 then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId)
		end
		if pNpc.bSysNotify then
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	end
	self:OnGetClueRandAward(pPlayer)
	pNpc.Delete()
end

function tbAct:OnGetClueRandAward(pPlayer)
	local nRand = MathRandom(10000)
	if nRand > tbItem.RandGetSelectItemRate then
		return
	end
	local _, nEndTime = self:GetOpenTimeInfo()
	pPlayer.SendAward({ {"item", tbItem.nRandGetSelectItem, 1, nEndTime} }, true, nil, Env.LogWay_CollectAndRobClue, 1)
end

function tbAct:OnPlayerLogin()
	if me.nLevel < self.nMinLevel then
		return
	end

	--重启后登录将玩家加入内存池子
	if not self.tbAllPlayerCollectData[me.dwID] then
		local tbData = self:GetDataFromPlayer(me.dwID) 
		if tbData and tbData.tbDebrisData then
			self:SetAllCollectRoleData(me.dwID, tbData.tbDebrisData)
		end
	elseif self.tbAllPlayerRobData[me.dwID] then
		for k,v in pairs(self.tbAllPlayerRobData[me.dwID]) do
			for i2,v2 in ipairs(v) do
				self:ModifyClueCount(me, k, v2[1], self.LogWayType_Rob, v2[2] );
			end
		end
		self.tbAllPlayerRobData[me.dwID] = nil;
	end

	me.CallClientScript("Player:ServerSyncData", "ActClueRobMyDebris",  self.tbAllPlayerCollectData[me.dwID])
end

function tbAct:OnPlayerLevelUp(pPlayer)
    if pPlayer.nLevel ~= self.nMinLevel then
        return
    end
    local tbMailInfo = self:GetActMailInfo()
    local tbMail = Lib:CopyTB(tbMailInfo)
    tbMail.To = pPlayer.dwID;
    tbMail.LevelLimit = nil;
    Mail:SendSystemMail(tbMail)
end

function tbAct:OnAddEverydayAward(pPlayer, nIdx)
	if pPlayer.nLevel < self.nMinLevel then
        return
    end
    pPlayer.SendAward( {{"item",self.nEverydayTargetAward, self.tbEverydayTargetAwardCount[nIdx]} } , nil, nil, Env.LogWay_CollectAndRobClue)
end

function tbAct:ModifyClueCount(pPlayer, nItemId, nAddOrReduceCount, nLogReazon, nLogReazon2)
	--不设置分卷的直接获取途径，只能是合成获得
	local tbItems = pPlayer.FindItemInBag(tbItem.nActStartSendItem) 
	if #tbItems ~= 1 then
		Log(debug.traceback(), pPlayer.dwID)
		return
	end
	local pItem = tbItems[1];

	local tbData = self:GetDataFromPlayer(pPlayer.dwID) 
	local bSetSave = false
	if not tbData then
		tbData = {}
		bSetSave = true
	end
	tbData.tbDebrisData = tbData.tbDebrisData or {};
	local tbDebrisData = tbData.tbDebrisData
	local nCurCount = (tbDebrisData[nItemId] or 0) + nAddOrReduceCount
	if nCurCount > 0 then
		tbDebrisData[nItemId] = nCurCount
	else
		tbDebrisData[nItemId] = nil;
	end
	if bSetSave then
		self:SaveDataToPlayer(pPlayer, tbData)
	end
	self:SetAllCollectRoleData(pPlayer.dwID, tbDebrisData)

	--不同的logReason ，取不同后面参数
	if nLogReazon == self.LogWayType_Rob or nLogReazon == self.LogWayType_RobOther 
		or nLogReazon == self.LogWayType_GetSend or nLogReazon == self.LogWayType_Send then
		local pRole = KPlayer.GetRoleStayInfo(nLogReazon2)
		if pRole then
			nLogReazon2 = pRole.szName
		end
	end
	if nLogReazon ~= self.LogWayType_Combine then
		local nOldCount = pItem.GetIntValue(tbItem.IntKeyDebrisCount)
		pItem.SetIntValue(tbItem.IntKeyDebrisCount,  math.max(0 , nOldCount + nAddOrReduceCount))
	end

	pPlayer.CallClientScript("Activity.CollectAndRobClue:OnModifyClueCount", nItemId, nAddOrReduceCount, nLogReazon, nLogReazon2, tbDebrisData)

	Log("ModifyClueCount", pPlayer.dwID, nLogReazon, nLogReazon2, nItemId, nAddOrReduceCount, tbDebrisData[nItemId])	
	return true
end


--非inst 调用，所以不用活动实例后的数据, 玩家必须在线
function tbAct:GetPlayerCurCounInfo(pPlayer)
	return self.tbAllPlayerCollectData[pPlayer.dwID]
end

--所有设置 tbAllPlayerCollectData 的地方需要调这个函数
function tbAct:SetAllCollectRoleData(dwRoleId, tbData)
	if tbData and next(tbData) then
		if not self.tbAllPlayerCollectData[dwRoleId] then
			--加入池子
			table.insert(self.tbAllPlayerList, dwRoleId)
		end
		self.tbAllPlayerCollectData[dwRoleId] = tbData ;
	else
		if self.tbAllPlayerCollectData[dwRoleId] then
			--移除池子
			for i,v in ipairs(self.tbAllPlayerList) do
				if v == dwRoleId then
					table.remove(self.tbAllPlayerList, i)
					break;
				end
			end
		end
		self.tbAllPlayerCollectData[dwRoleId] = nil;
	end
end


function tbAct:GetSendList(pPlayer)
	local nNow = GetTime()
	if pPlayer.nLastRequestSendListTime and pPlayer.nLastRequestSendListTime + 60 >= nNow then
		pPlayer.CenterMsg("请稍後再尝试刷新")
		return
	end
	pPlayer.nLastRequestSendListTime = nNow

	local tbFriendKeyList = KFriendShip.GetFriendList(pPlayer.dwID)
	local tbFriendList = {};
	for k,v in pairs(tbFriendKeyList) do
		table.insert(tbFriendList, {k, v})
	end
	table.sort( tbFriendList, function (a, b)
		return a[2] > b[2]
	end )
	local tbRoleList = {};
	local nChecked = 0
	for i,v in ipairs(tbFriendList) do
		nChecked = i
		local dwRoleId = v[1]
		if self:CheckAddToSendList(dwRoleId, pPlayer) then
			table.insert(tbRoleList, dwRoleId)
			if #tbRoleList == 5 then
				break;
			end
		end
	end
	for i=1,nChecked do
		table.remove(tbFriendList, 1)
	end
	local nLeftCount = #tbFriendList
	if nLeftCount > 1 then
		local nRandCount = math.ceil(nLeftCount / 2)
		for i = 1, nRandCount do
			local nRand = MathRandom(nLeftCount)
			tbFriendList[i],tbFriendList[nRand] = tbFriendList[nRand],tbFriendList[i]
		end	
	end

	local nTotolNeed = 30
	for i,v in ipairs(tbFriendList) do
		local dwRoleId = v[1]
		if self:CheckAddToSendList(dwRoleId, pPlayer) then
			table.insert(tbRoleList, dwRoleId)
			if #tbRoleList == nTotolNeed then
				break;
			end
		end
	end

	table.sort( tbRoleList, function (a, b)
		return tbFriendKeyList[a] > tbFriendKeyList[b] 
	end )

	local tbRoleStayData = {}; --只有陌生人是需要下发角色信息数据的
	if #tbRoleList < nTotolNeed then
		 --取下同家族的
		 local dwKinId = pPlayer.dwKinId
		 if dwKinId ~= 0 then
		 	local tbAllKinMembs = Kin:GetKinMembers(dwKinId)
		 	tbAllKinMembs[pPlayer.dwID] = nil;
		 	for k,v in pairs(tbFriendKeyList) do
		 		tbAllKinMembs[k] = nil
		 	end
		 	local tbOtherKinMembers = {}
		 	for k,v in pairs(tbAllKinMembs) do
		 		table.insert(tbOtherKinMembers, k)
		 	end
		 	if #tbOtherKinMembers > 0 then
		 		for i=1, math.min(5, #tbOtherKinMembers) do
		 			local nRand = MathRandom(#tbOtherKinMembers)
		 			tbOtherKinMembers[i], tbOtherKinMembers[nRand] = tbOtherKinMembers[nRand], tbOtherKinMembers[i]
		 		end
		 		for i,dwRoleId in ipairs(tbOtherKinMembers) do
					if self:CheckAddToSendList(dwRoleId, pPlayer) then
						table.insert(tbRoleList, dwRoleId)
						tbRoleStayData[dwRoleId] = Player:GetRoleStayInfo(dwRoleId, true)
						if #tbRoleList == nTotolNeed then
							break;
						end
					end
		 		end
		 	end
		 end
	end
	pPlayer.CallClientScript("Player:ServerSyncData", "ActClueSendList",  tbRoleList, tbRoleStayData)
end

--非inst 调用，
function tbAct:GetRobList(pPlayer)
	local nNow = GetTime()
	if pPlayer.nLastRequestRobListTime and pPlayer.nLastRequestRobListTime + 60 >= nNow then
		pPlayer.CenterMsg("请稍後再尝试刷新")
		return
	end
	pPlayer.nLastRequestRobListTime = nNow
	local tbEnemyKeyList = KFriendShip.GetEnemyList(pPlayer.dwID)
	local tbEnemyList = {};
	for k,v in pairs(tbEnemyKeyList) do
		table.insert(tbEnemyList, {k ,v})
	end
	table.sort( tbEnemyList, function ( a, b )
		return a[2] > b[2]
	end )

	local tbRoleList = {};
	local nChecked = 0
	for i,v in ipairs(tbEnemyList) do
		nChecked = i
		local dwRoleId = v[1]
		if self:CheckAddToRobList(dwRoleId, pPlayer) then
			table.insert(tbRoleList, dwRoleId)
			if #tbRoleList == 5 then
				break;
			end
		end
	end
	for i=1,nChecked do
		table.remove(tbEnemyList, 1)
	end

	local nLeftCount = #tbEnemyList
	local nRandCount = math.ceil(nLeftCount / 2)
	for i = 1, nRandCount do
		local nRand = MathRandom(nLeftCount)
		tbEnemyList[i],tbEnemyList[nRand] = tbEnemyList[nRand],tbEnemyList[i]
	end

	local nTotolNeed = 30
	for i,v in ipairs(tbEnemyList) do
		local dwRoleId = v[1]
		if self:CheckAddToRobList(dwRoleId, pPlayer) then
			table.insert(tbRoleList, dwRoleId)
			if #tbRoleList == nTotolNeed then
				break;
			end
		end
	end

	table.sort( tbRoleList, function (a, b)
		return tbEnemyKeyList[a] > tbEnemyKeyList[b] 
	end )

	local tbRoleStayData = {}; --只有陌生人是需要下发角色信息数据的
	if #tbRoleList < nTotolNeed then
		local tbAllPlayerList = self.tbAllPlayerList
		local nTotolPlayerCount = #tbAllPlayerList
		if nTotolPlayerCount > 1 then --每次取的时候随五次就好了
			for i=1, math.min(5, nTotolPlayerCount) do
				local nRand = MathRandom(nTotolPlayerCount)
				tbAllPlayerList[i], tbAllPlayerList[nRand] = tbAllPlayerList[nRand], tbAllPlayerList[i] 
			end	
			local tbAllFriends = KFriendShip.GetFriendList(pPlayer.dwID)
			for i,v in ipairs(tbAllPlayerList) do
				if not tbAllFriends[v] and not tbEnemyKeyList[v] then
					if self:CheckAddToRobList(v, pPlayer) then
						table.insert(tbRoleList, v)
						tbRoleStayData[v] = Player:GetRoleStayInfo(v, true)
						if #tbRoleList == nTotolNeed then
							break;
						end
					end
				end
			end
		end
	end

	pPlayer.CallClientScript("Player:ServerSyncData", "ActClueRobList",  tbRoleList, tbRoleStayData)
end

function tbAct:GetCountTB()
	local tbData = ScriptData:GetValue("RobClueCount")
	local nToday = Lib:GetLocalDay(GetTime()  - self.RefreshTime)
	if tbData.nCheckedDay ~= nToday then
		tbData.nCheckedDay = nToday
		tbData.tbCount = {};
	end
	return tbData.tbCount
end


function tbAct:CheckAddToSendList(dwRoleId, pPlayerMe)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		return false, "玩家不线上不可赠送"
	end
	local tbItems = pPlayer.FindItemInBag(tbItem.nActStartSendItem) 
	if #tbItems ~= 1 then
		return false, "玩家没有活动道具"
	end
	local tbData = self:GetDataFromPlayer(dwRoleId) or {}
	local nToday = Lib:GetLocalDay(GetTime()  - self.RefreshTime)
	if tbData.nLastGetDay ~= nToday then
		tbData.nGetSendCount = 0;
		tbData.nLastGetDay = nToday
		self:SaveDataToPlayer(pPlayer, tbData)
	end
	if tbData.nGetSendCount >= tbAct.MAX_GETSEND_COUNT then
		return false, "已达今日被赠送上限"
	end

	return pPlayer
end

function tbAct:CheckAddToRobList(dwRoleId, pPlayerMe, bGetCanRobItems)
	local tbCurInfo = self.tbAllPlayerCollectData[dwRoleId]
	if not tbCurInfo or not next(tbCurInfo) then
		return false, "该玩家已无碎片"
	end
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if pPlayer then
		return false, "玩家线上不可以抢"
	end

	local tbCanRobItemList = {}
	for k,v in pairs(tbCurInfo) do
		local tbRobInfo = self.tbAllPlayerRobData[dwRoleId]
		if tbRobInfo then
			local tbRobItem = tbRobInfo[k]
			if tbRobItem then
				for i2,v2 in ipairs(tbRobItem) do
					v = v + v2[1]
				end
			end
		end
		if v > 0 then
			table.insert(tbCanRobItemList, k)
			if not bGetCanRobItems then
				break;
			end
		end
	end
	if #tbCanRobItemList == 0 then
		return false, "该玩家已无碎片"
	end

	local tbCountRobed = self:GetCountTB()
	local nRobedcount = tbCountRobed[dwRoleId]
	if nRobedcount and  nRobedcount >= self.MAX_ROBED_COUNT then
		return false, "该玩家已达今日被抢夺上限"
	end

	local dwMyKinId = pPlayerMe.dwKinId
	if dwMyKinId ~= 0 then
		local dwKinId = Kin:GetKinIdByMemberId(dwRoleId)	
		if dwKinId == dwMyKinId then
			return false, "同帮派不能抢夺"
		end
	end

	return tbCanRobItemList;
end

function tbAct:SendHim(pPlayer, dwSendRoleId, nDerbisId)
	local pPlayer2, szMsg = self:CheckAddToSendList(dwSendRoleId, pPlayer)
	if not pPlayer2 then
		pPlayer.CallClientScript("Activity.CollectAndRobClue:DelOneRoleTarget", dwSendRoleId, "ActClueSendList", szMsg)
		return
	end

	local dwMyRoleId = pPlayer.dwID
	if not FriendShip:IsFriend(dwMyRoleId, dwSendRoleId) then
		local dwKinId = pPlayer.dwKinId
		if dwKinId == 0 then
			pPlayer.CenterMsg("非好友非同帮派之间不能赠送")	
			return
		elseif dwKinId ~= pPlayer.dwKinId then
			pPlayer.CenterMsg("非好友非同帮派之间不能赠送")	
			return
		end
	end

	--合格的道具id，且自己有的
	local nTarItemId = tbItem:GetDerbisCombieTarId(nDerbisId)
	if not nTarItemId then
		return
	end
	local tbMyData = self:GetDataFromPlayer(dwMyRoleId)
	if not tbMyData then
		return
	end
	local tbDebrisData = tbMyData.tbDebrisData
	if not tbDebrisData or not tbDebrisData[nDerbisId] or tbDebrisData[nDerbisId] < 1 then
		pPlayer.CenterMsg("您没有对应的碎片")
		return
	end

	--赠送次数限制 赠送cd
	local nNow = GetTime()
	local nLastSendTime = tbMyData.nLastSendTime or 0
	if nLastSendTime + self.SEND_CD > nNow then
		pPlayer.CenterMsg("赠送冷却中")
		return
	end
	local nRefreshDay = Lib:GetLocalDay(nNow - self.RefreshTime)
	if Lib:GetLocalDay(nLastSendTime - self.RefreshTime) ~= nRefreshDay then
		tbMyData.nSendCount = 0;
	end
	if tbMyData.nSendCount >= self.MAX_SEND_COUNT then
		pPlayer.CenterMsg("今日已无赠送次数")
		return
	end

	tbMyData.nLastSendTime = nNow
	tbMyData.nSendCount = tbMyData.nSendCount + 1
	self:SaveDataToPlayer(pPlayer, tbMyData)

	local tbHimData = self:GetDataFromPlayer(dwSendRoleId) or {}
	tbHimData.nLastGetDay = nRefreshDay
	tbHimData.nGetSendCount = tbHimData.nGetSendCount + 1; --因为前面肯定有重置的检查，所以这里不判0
	self:SaveDataToPlayer(pPlayer2, tbHimData)

	pPlayer.SendAward( { {"CollectClue", nDerbisId, -1} }, true, nil, tbAct.LogWayType_Send, dwSendRoleId)
	pPlayer2.SendAward( { {"CollectClue", nDerbisId, 1} }, true, nil, tbAct.LogWayType_GetSend, dwMyRoleId)
	self:RequestMyInfo(pPlayer)
	self:RequestMyInfo(pPlayer2)
	pPlayer.CenterMsg(string.format("赠送成功！今日已赠送%d/%d", tbMyData.nSendCount, self.MAX_SEND_COUNT))
end

function tbAct:Robhim(pPlayer, dwRobRoleId)
	local dwMyRoleId = pPlayer.dwID
	if FriendShip:IsFriend(dwMyRoleId, dwRobRoleId) then
		pPlayer.CenterMsg("好友之间不能抢夺")
		return 
	end
	--自己抢夺次数和抢夺cd
	local tbData = self:GetDataFromPlayer(dwMyRoleId) or {};
	local nNow = GetTime()
	if tbData.nLastRobTime then
		if tbData.nLastRobTime + self.ROB_CD > nNow then
			pPlayer.CenterMsg("抢夺冷却中")
			return
		end
		if Lib:GetLocalDay(tbData.nLastRobTime - self.RefreshTime) ~= Lib:GetLocalDay(nNow - self.RefreshTime) then
			tbData.nRobCount = 0;
		end
	end
	if tbData.nRobCount then
		if tbData.nRobCount >= self.MAX_ROB_COUNT then
			pPlayer.CenterMsg("今日已无抢夺次数")
			return
		end
	end

	local tbCanRobItemList, szMsg = self:CheckAddToRobList(dwRobRoleId, pPlayer, true)
	if not tbCanRobItemList then
		pPlayer.CallClientScript("Activity.CollectAndRobClue:DelOneRoleTarget", dwRobRoleId, "ActClueRobList", szMsg)
		return
	end

	tbData.nLastRobTime = nNow
	tbData.nRobCount = (tbData.nRobCount or 0) + 1;
	self:SaveDataToPlayer(pPlayer, tbData)

	local tbCountRobed = self:GetCountTB()
	tbCountRobed[dwRobRoleId] = (tbCountRobed[dwRobRoleId] or 0) + 1;

	--随机一张碎片
	local nRandIdx = MathRandom(#tbCanRobItemList)
	local nItemId = tbCanRobItemList[nRandIdx]

	--离线记录
	local tbAllPlayerRobData = self.tbAllPlayerRobData
	tbAllPlayerRobData[dwRobRoleId] = tbAllPlayerRobData[dwRobRoleId] or {}
	tbAllPlayerRobData[dwRobRoleId][nItemId] = tbAllPlayerRobData[dwRobRoleId][nItemId] or {};
	local tbRobItem = tbAllPlayerRobData[dwRobRoleId][nItemId]
	table.insert(tbRobItem, { -1, dwMyRoleId})

	local pRobedHim = KPlayer.GetRoleStayInfo(dwRobRoleId)
	FriendShip:AddHate(pRobedHim, pPlayer, self.nRobAddHate)

	pPlayer.SendAward( { {"CollectClue", nItemId, 1} }, true, nil, tbAct.LogWayType_RobOther, dwRobRoleId)
	self:RequestMyInfo(pPlayer)
	pPlayer.CenterMsg(string.format("抢夺成功！今日已抢夺%d/%d", tbData.nRobCount, self.MAX_ROB_COUNT))
end

--inst调用，所以用event
function tbAct:RequestMyInfo(pPlayer)
	local tbCountRobed = self:GetCountTB()
	local tbData = self:GetDataFromPlayer(pPlayer.dwID) or {};
	local tbInfo = { nLastRobTime = tbData.nLastRobTime or 0, 
					 nRobCount = tbData.nRobCount or 0, 
					 nCountRobed = tbCountRobed[pPlayer.dwID] or 0,
					 nLastSendTime = tbData.nLastSendTime or 0,
					 nSendCount = tbData.nSendCount or 0;
					 nGetSendCount = tbData.nGetSendCount or 0;
					 nLastGetDay = tbData.nLastGetDay or 0;
				   }

	pPlayer.CallClientScript("Player:ServerSyncData", "ActClueRobMyInfo",  tbInfo)	
end

function tbAct:CombieClueItem(pPlayer)
	local tbItems = pPlayer.FindItemInBag(tbItem.nActStartSendItem) 
	if #tbItems ~= 1 then
		pPlayer.CenterMsg("无活动道具")
		return
	end
	local pItem = tbItems[1];

	local tbData = self:GetDataFromPlayer(pPlayer.dwID)
	if not tbData then
		return
	end
	local tbItemData = tbData.tbItemData
	if not tbItemData then
		return
	end
	if not tbItem:CanCombieDebris(tbItemData) then
		pPlayer.CenterMsg("残卷不足")
		return
	end

	for i,v in ipairs(tbItem.tbAllClueCombine) do
		tbItemData[v] = tbItemData[v] - 1
	end

	local nOldCount = pItem.GetIntValue(tbItem.IntKeyDebrisCount)
	pItem.SetIntValue(tbItem.IntKeyDebrisCount,  math.max(0 , nOldCount - #tbItem.tbAllClueDebris * tbItem.COMBIE_COUNT ))

    local bIsLimit = MarketStall:CheckIsLimitPlayer(pPlayer)
	local nGetItemLast = bIsLimit and tbItem.nLastCombineItemId2 or  tbItem.nLastCombineItemId
	pPlayer.SendAward( {{ "item", nGetItemLast, 1 }}, nil, nil,Env.LogWay_CollectAndRobClue, tbAct.LogWayType_Combine)
	
	local szNotifyMsg = string.format("经过一段时间的不懈探寻，「%s」终於集齐了所有分卷并成功的合成了[ff8f06]【神州大地宝卷】[-]！#49", pPlayer.szName)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szNotifyMsg, pPlayer.dwID);
	if pPlayer.dwKinId ~= 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szNotifyMsg, pPlayer.dwKinId)
	end
	pPlayer.CallClientScript("Player:ServerSyncData", "ActClueRobMyItem", tbItemData)	

end

function tbAct:CombieClueDerbis(pPlayer, nTemplateId)
	local tbData = self:GetDataFromPlayer(pPlayer.dwID)
	if not tbData then
		return
	end
	local tbDebrisData = tbData.tbDebrisData
	if not tbDebrisData then
		return
	end
	local nCurCount = tbDebrisData[nTemplateId]
	if not nCurCount or nCurCount < tbItem.COMBIE_COUNT then
		pPlayer.CenterMsg("个数不足")
		return
	end
	local nTarItemId = tbItem:GetDerbisCombieTarId(nTemplateId)
	if not nTarItemId then
		pPlayer.CenterMsg("无效道具id")
		return
	end

	self:ModifyClueCount(pPlayer, nTemplateId, - tbItem.COMBIE_COUNT, self.LogWayType_Combine, nTarItemId)
	local tbItemData = tbData.tbItemData or {};
	tbItemData[nTarItemId] = (tbItemData[nTarItemId] or 0) + 1;
	tbData.tbItemData = tbItemData
	pPlayer.CenterMsg("合成成功")
	pPlayer.SendAward(self.tbCombieDebrisAward, true , nil,Env.LogWay_CollectAndRobClue, self.LogWayType_Combine)
	pPlayer.CallClientScript("Player:ServerSyncData", "ActClueRobMyItem", tbItemData)	
end

function tbAct:GetMyItemData(pPlayer)
	local tbData = self:GetDataFromPlayer(pPlayer.dwID)
	if not tbData then
		return
	end
	local tbItemData = tbData.tbItemData
	if not tbItemData then
		return
	end
	pPlayer.CallClientScript("Player:ServerSyncData", "ActClueRobMyItem", tbItemData)	

end

tbAct.tbC2SRequest = {
	["RequestMyInfo"] = function (pPlayer)
		Activity:OnPlayerEvent(pPlayer, "ActClueRequestMyInfo")
	end;

	["GetRobList"]  = function (pPlayer)
		tbAct:GetRobList(pPlayer)			
	end;

	["GetSendList"] = function (pPlayer)
		Activity:OnPlayerEvent(pPlayer, "ActClueGetSendList")
	end;

	["Robhim"]  = function (pPlayer, dwRobRoleId)
		Activity:OnPlayerEvent(pPlayer, "ActClueRobhim", dwRobRoleId)
	end;

	["SendHim"] = function (pPlayer, dwRobRoleId, nItemId)
		Activity:OnPlayerEvent(pPlayer, "ActClueSendHim", dwRobRoleId, nItemId)
	end;

	["GetMyItemData"] = function (pPlayer)
		Activity:OnPlayerEvent(pPlayer, "ActClueGetMyItemData")
	end;

	["CombieClueDerbis"] = function (pPlayer, nTemplateId)
		Activity:OnPlayerEvent(pPlayer, "ActClueCombieClueDerbis", nTemplateId)
	end;
	["CombieClueItem"] = function (pPlayer)
		Activity:OnPlayerEvent(pPlayer, "ActClueCombieClueItem")
	end;
};

