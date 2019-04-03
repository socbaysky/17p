local KinNest = Kin.KinNest;
local tbLabaZhouItem = Item:GetClass("LabaZhou");
local tbAct = Activity:GetClass("LabaAct")
tbAct.tbTimerTrigger = { 
	{szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify"},  
}
tbAct.tbTrigger = { 
	Init = { }, 
	Start = { }, 
	End = { }, 
	SendWorldNotify = { {"WorldMsg", "腊八节活动正在进行中，详情可参见[eebb01]最新消息[-]相关页面"} },
}
--[[
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbSaveData.tbMaterial = {[nId] = nCount}   		-- 拥有材料
	tbSaveData.tbCommitMaterial = {[nId] = nCount}  -- 已经提交的材料
	tbSaveData.nComposeCount = 0 					-- 已经合成的次数
	tbSaveData.nComposeUpdateTime = nNowTime 		-- 合成次数更新时间
	tbSaveData.nExchangeCount = 0 					-- 已经交换的次数
	tbSaveData.nExchangeUpdateTime = nNowTime		-- 交换次数更新时间
	tbSaveData.nAssistCount = 0 					-- 协助次数
	tbSaveData.nAssistUpdateTime = nNowTime 		-- 协助时间
	tbSaveData.nCommitCount = 0 					-- 提交腊八粥次数
]]
function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_EverydayTargetGainAward", "OnEverydayTargetGainAward")
        Activity:RegisterPlayerEvent(self, "Act_UseLabaMaterial", "OnUseLabaMaterial")
        Activity:RegisterPlayerEvent(self, "Act_OnLabaActClientCall", "OnLabaActClientCall")
        Activity:RegisterPlayerEvent(self, "Act_GetMaterial", "OnGetMaterial")
        Activity:RegisterPlayerEvent(self, "Act_DailyGift", "OnBuyDailyGift")
        Activity:RegisterNpcDialog(self, 91, {Text = "腊八节", Callback = self.OnShowDetail, Param = {self}})
        local _, nEndTime = self:GetOpenTimeInfo()
        -- 注册申请存库数据块,活动结束自动清掉
        self:RegisterDataInPlayer(nEndTime)
        KinNest:OnLabaActStart(nEndTime)
    elseif szTrigger == "End" then
    	KinNest:OnLabaActEnd()
    end
    Log("[LabaAct] OnTrigger:", szTrigger)
end

function tbAct:OnShowDetail()
	local tbDlg = {
		{ Text = "赠送腊八粥", Callback = self.OnGetLabaAward, Param = {self} };
		{ Text = "交换食材", Callback = self.OnExchangeMaterial, Param = {self} };
		{ Text = "了解详情", Callback = self.DoShowDetail, Param = {self} };
	};
	Dialog:Show(
		{
		    Text    = "国难当头，众位侠士一起为国尽力，居功至伟！",
		    OptList = tbDlg,
		}, me, him);
end

function tbAct:DoShowDetail()
	me.CallClientScript("Activity.LabaAct:OnDetail")
end

function tbAct:OnExchangeMaterial()
	me.CallClientScript("Ui:OpenWindow", "LabaFestivalExchangePanel")
end

function tbAct:OnGetLabaAward()
	local bRet, szMsg, nHave = self:CheckGetLabaAward(me)
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	local fnAgree = function (dwID)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if not pPlayer then
            return
		end
		local bRet, szMsg, nHave = self:CheckGetLabaAward(pPlayer)
		if not bRet then
			pPlayer.CenterMsg(szMsg, true)
			return
		end
		local nConsume = pPlayer.ConsumeItemInAllPos(self.nLabaZhouItemId, nHave, Env.LogWay_LabaAct);
		if nConsume ~= nHave then
			pPlayer.CenterMsg("提交失败,请稍後再试", true)
			return 
		end
		local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
		local nBeginCommitCount = tbSaveData.nCommitCount or 0
		tbSaveData.nCommitCount = nBeginCommitCount + nConsume
		local tbCommitAward = self:FormatCommitAward(nConsume)
		pPlayer.SendAward(tbCommitAward, true, nil, Env.LogWay_LabaAct);
		self:TrySendCountAward(pPlayer, nBeginCommitCount, nBeginCommitCount + nConsume)
		Log("[LabaAct] fnOnGetLabaAward", pPlayer.dwID, pPlayer.szName, nHave)
	end
	me.MsgBox(string.format("是否提交%d份腊八粥", nHave), {{"同意", fnAgree, me.dwID}, {"拒绝"}})
end

-- 1,3,6元礼包nGroupIndex分别对应1,2,3 nBuyCount购买数量
function tbAct:OnBuyDailyGift(pPlayer, nGroupIndex, nBuyCount)
	if not self:CheckPlayer(pPlayer) then
		return
	end
	local tbFormatAward = {}
	if self.tbDailyGiftAward[nGroupIndex] then
		local _, nEndTime = self:GetOpenTimeInfo()
		tbFormatAward = self:FormatAward(self.tbDailyGiftAward[nGroupIndex], nEndTime)
		tbFormatAward = self:FormatCommitAward(nBuyCount, tbFormatAward)
	end
	if next(tbFormatAward) then
		pPlayer.SendAward(tbFormatAward, true, nil, Env.LogWay_LabaAct);
		Log("[LabaAct] fnOnBuyDailyGift", pPlayer.dwID, pPlayer.szName, nGroupIndex, nBuyCount)
	end
end

function tbAct:OnGetMaterial(pPlayer, nId, nCount)
	if (nCount or 0) < 1 then
		pPlayer.CenterMsg("未知数量", true)
		return 
	end
	if not self.tbMaterial[nId] then
		pPlayer.CenterMsg("未知材料", true)
		return 
	end
	local bRet, szMsg = self:CheckPlayer(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbSaveData.tbMaterial = tbSaveData.tbMaterial or {}
	tbSaveData.tbMaterial[nId] = (tbSaveData.tbMaterial[nId] or 0) + 1
	self:SaveDataToPlayer(pPlayer, tbSaveData)
	self:SynMaterialData(pPlayer)
	self:SendMenu(pPlayer)
	local szName = self.tbMaterial[nId].szName or "食材"
	pPlayer.CenterMsg(string.format("恭喜你获得了[FFFE0D]%s[-]，可以打开腊八粥食谱查看！", szName), true)
end

function tbAct:SendMenu(pPlayer)
	local nHave = pPlayer.GetItemCountInAllPos(self.nLabaMenuItemId)
	if nHave < 1 then
		local _, nEndTime = self:GetOpenTimeInfo()
		pPlayer.SendAward({{"item", self.nLabaMenuItemId, 1, nEndTime}}, true, nil, Env.LogWay_LabaAct);
	end
end

function tbAct:CheckGetLabaAward(pPlayer)
	local nHave = pPlayer.GetItemCountInAllPos(self.nLabaZhouItemId)
	if nHave <= 0 then
		return false, "请先搜集腊八粥再来"
	end
	return true, nil, nHave
end

function tbAct:TrySendCountAward(pPlayer, nBeginCount, nEndCount)
	for i = nBeginCount, nEndCount do
		local tbAward = self.tbCommitCountAward[i]
		if tbAward then
			pPlayer.SendAward(tbAward, true, nil, Env.LogWay_LabaAct);
			Log("[LabaAct] fnTrySendCountAward", pPlayer.dwID, pPlayer.szName, i, nBeginCount, nEndCount)
		end
	end
end

function tbAct:OnLabaActClientCall(pPlayer, szCall, ...)
	if self[szCall] then
		self[szCall](self, pPlayer, ...)
	else
		Log("[LabaAct] client call fail", pPlayer.dwID, pPlayer.szName, szCall)
	end
end

function tbAct:OnEverydayTargetGainAward(pPlayer, nAwardIdx)
	if not self:CheckPlayer(pPlayer) then
		return
	end
	local tbAward = self.tbActiveAward[nAwardIdx]
	if not tbAward then
		return
	end
	local _, nEndTime = self:GetOpenTimeInfo()
	tbAward = self:FormatAward(tbAward, nEndTime)
	pPlayer.SendAward(tbAward, true, nil, Env.LogWay_LabaAct);
end

function tbAct:OnUseLabaMaterial(pPlayer, pItem)
	local bRet, szMsg = self:CheckPlayer(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	local fnSelect = Lib:GetRandomSelect(#self.tbMaterial)
	local nSelect = fnSelect()
	if pPlayer.ConsumeItem(pItem, 1, Env.LogWay_LabaAct) ~= 1 then
		pPlayer.CenterMsg("扣除道具失败", true)
		return
	end
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbSaveData.tbMaterial = tbSaveData.tbMaterial or {}
	tbSaveData.tbMaterial[nSelect] = (tbSaveData.tbMaterial[nSelect] or 0) + 1
	self:SaveDataToPlayer(pPlayer, tbSaveData)
	local szName = self.tbMaterial[nSelect].szName or "食材"
	pPlayer.CenterMsg(string.format("恭喜你获得了[FFFE0D]%s[-]，可以打开腊八粥食谱查看！", szName), true)
end

function tbAct:GetComposeCount(pPlayer)
	local nNowTime = GetTime()
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	if Lib:IsDiffDay(self.nComposeReset, (tbSaveData.nComposeUpdateTime or 0), nNowTime) then
		tbSaveData.nComposeCount = 0
		tbSaveData.nComposeUpdateTime = nNowTime
		self:SaveDataToPlayer(pPlayer, tbSaveData)
	end
	return tbSaveData.nComposeCount or 0, tbSaveData.nComposeUpdateTime or 0
end

function tbAct:CheckCommon(pPlayer)
	local nCount = self:GetComposeCount(pPlayer)
	if nCount >= self.nMaxComposeCount then
		return false, string.format("一天只允许得到%s份腊八粥。", self.nMaxComposeCount)
	end
	return true
end

function tbAct:CommitMaterial(pPlayer, nId)
	local bRet, szMsg = self:CheckCommon(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	local tbMaterialInfo = self.tbMaterial[nId]
	if not tbMaterialInfo then
		pPlayer.CenterMsg("未知材料", true)
		return
	end
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbSaveData.tbMaterial = tbSaveData.tbMaterial or {}
	if (tbSaveData.tbMaterial[nId] or 0) < self.nCommitPer then
		pPlayer.CenterMsg("材料不足", true)
		return
	end
	tbSaveData.tbCommitMaterial = tbSaveData.tbCommitMaterial or {}
	if (tbSaveData.tbCommitMaterial[nId] or 0) >= self.nCommitPer then
		pPlayer.CenterMsg("已经提交过该材料", true)
		return
	end
	tbSaveData.tbMaterial[nId] = tbSaveData.tbMaterial[nId] - 1
	tbSaveData.tbCommitMaterial[nId] = (tbSaveData.tbCommitMaterial[nId] or 0) + self.nCommitPer
	self:SaveDataToPlayer(pPlayer, tbSaveData)
	pPlayer.CenterMsg("提交成功", true)
	self:TryCompose(pPlayer)
	self:SynMaterialData(pPlayer)
	Log("[LabaAct] fnCommitMaterial ", pPlayer.dwID, pPlayer.szName, nId)
end

function tbAct:TryCompose(pPlayer)
	local bRet, szMsg = self:CheckCommon(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbSaveData.tbCommitMaterial = tbSaveData.tbCommitMaterial or {}
	for nId in ipairs(self.tbMaterial) do
		if (tbSaveData.tbCommitMaterial[nId] or 0) < self.nComposeNeed then
			return
		end
	end
	local tbName = {}
	for szName, nAssistTime in pairs(tbSaveData.tbAssistName or {}) do
		table.insert(tbName, {szName = szName, nTime = nAssistTime})
	end
	if #tbName > 1 then
		table.sort(tbName, function (a, b) return a.nTime < b.nTime end)
	end
	local tbAssistName = {}
	for _, v in ipairs(tbName) do
		table.insert(tbAssistName, ("[FFFE0D]" ..v.szName .."[-]"))
	end
	local szNameStr = next(tbAssistName) and table.concat(tbAssistName, ",") or ""
	local _, nEndTime = self:GetOpenTimeInfo()
	local pItem = pPlayer.AddItem(self.nLabaZhouItemId, 1, nEndTime, Env.LogWay_LabaAct)
	if not pItem then
		Log("[LabaAct] fnTryCompose AddItem fail", pPlayer.dwID, pPlayer.szName)
		return
	end
	for nId in ipairs(self.tbMaterial) do
		tbSaveData.tbCommitMaterial[nId] = nil
	end
	tbSaveData.nComposeCount = (tbSaveData.nComposeCount or 0) + 1
	tbSaveData.tbAssistName = nil
	self:SaveDataToPlayer(pPlayer, tbSaveData)
	pItem.SetStrValue(tbLabaZhouItem.nAssistId, szNameStr)
	pPlayer.CenterMsg("成功合成腊八粥", true)
	Log("[LabaAct] fnTryCompose ", pPlayer.dwID, pPlayer.szName, tbSaveData.nComposeCount)
end

function tbAct:UpdateCount(pPlayer)
	self:GetAssistCount(pPlayer)
	self:GetExchangeCount(pPlayer)
	self:GetComposeCount(pPlayer)
end

function tbAct:SynMaterialData(pPlayer, nPlayerId)
	self:UpdateCount(pPlayer)
	local tbSaveData = self:GetDataFromPlayer(nPlayerId or pPlayer.dwID) or {}
	pPlayer.CallClientScript("Activity.LabaAct:OnSynMaterialData", tbSaveData)
end

function tbAct:GetExchangeCount(pPlayer)
	local nNowTime = GetTime()
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	if Lib:IsDiffDay(self.nExchangeReset, (tbSaveData.nExchangeUpdateTime or 0), nNowTime) then
		tbSaveData.nExchangeCount = 0
		tbSaveData.nExchangeUpdateTime = nNowTime
		self:SaveDataToPlayer(pPlayer, tbSaveData)
	end
	return tbSaveData.nExchangeCount or 0
end

function tbAct:CheckExchange(pPlayer, nId, nExchangeId)
	if not self.tbMaterial[nId] or not self.tbMaterial[nExchangeId] then
		return false, "未知材料"
	end
	if nId == nExchangeId then
		return false, "不能交换相同的材料"
	end
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbSaveData.tbMaterial = tbSaveData.tbMaterial or {}
	if (tbSaveData.tbMaterial[nId] or 0) < 1 then
		return false, "数量不足"
	end
	local nCount = self:GetExchangeCount(pPlayer)
	if nCount >= self.nMaxExchangeCount then
		return false, string.format("每天只能交换%s次", self.nMaxExchangeCount)
	end
	return true
end

function tbAct:ExchangeMaterial(pPlayer, nId, nExchangeId)
	local bRet, szMsg = self:CheckExchange(pPlayer, nId, nExchangeId)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return 
	end
	local nHave = pPlayer.GetMoney("Gold") or 0
	if nHave < self.nExchangeCost then
		pPlayer.CenterMsg("元宝不足", true)
		return 
	end
	local fnChange = function (pPlayer, nId, nExchangeId)
		local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
        tbSaveData.tbMaterial = tbSaveData.tbMaterial or {}
        tbSaveData.tbMaterial[nId] = tbSaveData.tbMaterial[nId] - 1
        tbSaveData.tbMaterial[nExchangeId] = (tbSaveData.tbMaterial[nExchangeId] or 0) + 1
        tbSaveData.nExchangeCount = (tbSaveData.nExchangeCount or 0) + 1
        self:SaveDataToPlayer(pPlayer, tbSaveData)
        self:SynMaterialData(pPlayer)
        pPlayer.CenterMsg(string.format("交换成功,恭喜获得%s", self.tbMaterial[nExchangeId].szName))
        Log("[LabaAct] fnExchangeMaterial ", pPlayer.dwID, pPlayer.szName, nId, nExchangeId)
	end
	pPlayer.CostGold(self.nExchangeCost, Env.LogWay_LabaAct, nil, function (nPlayerId, bSuccess, szBillNo, nId, nExchangeId)
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
            if not pPlayer then
                return false, "离线了"
            end
            if not bSuccess then
            	pPlayer.CenterMsg("储值失败", true)
                return false, "储值失败"
            end
            local bRet, szMsg = self:CheckExchange(pPlayer, nId, nExchangeId)
            if not bRet then
            	pPlayer.CenterMsg(szMsg, true)
                return false, szMsg
            end
            fnChange(pPlayer, nId, nExchangeId)
            return true
	end, nId, nExchangeId);
end

function tbAct:CheckAssist(pPlayer, nAssistId, nId)
	local tbMaterialInfo = self.tbMaterial[nId]
	if not tbMaterialInfo then
		return false, "未知材料"
	end
	local pAssist = KPlayer.GetPlayerObjById(nAssistId)
	if not pAssist then
        return false, "对方未在线"
	end
	if nAssistId == pPlayer.dwID then
        return false, "不能协助自己"
	end
	if not FriendShip:IsFriend(pPlayer.dwID, nAssistId) then
		return false, "对方不是你的好友"
	end
	local nAssistCount = self:GetAssistCount(pPlayer)
	if nAssistCount >= self.nMaxAssistCount then
		return false, string.format("每天只能协助%d次", self.nMaxAssistCount)
	end
	local tbPlayer = {pPlayer, pAssist}
	for _, v in ipairs(tbPlayer) do
		if v.nLevel < self.nJoinLevel then
			return false, string.format("「%s」参与等级不足", v.szName)
		end
	end
	local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nAssistId) or 0
	if nImityLevel < self.nAssistImityLevel then
		return false, string.format("您与「%s」亲密度不够%s级", pAssist.szName, self.nAssistImityLevel)
	end

	local tbPlayerSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	local tbPlayerMaterial = tbPlayerSaveData.tbMaterial or {}
	if (tbPlayerMaterial[nId] or 0) < 1 then
		return false, "您的材料不足"
	end
	if not self:IsLackMaterial(pAssist, nId) then
		return false, string.format("「%s」已经拥有该材料", pAssist.szName)
	end
	local nAssistComposeCount = self:GetComposeCount(pAssist)
	if nAssistComposeCount >= self.nMaxComposeCount then
		return false, "对方合成次数已经用完，不能协助"
	end
	return true, nil, pAssist, tbMaterialInfo.szName or ""
end

function tbAct:GetAssistCount(pPlayer)
	local nNowTime = GetTime()
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	if Lib:IsDiffDay(self.nAssistReset, (tbSaveData.nAssistUpdateTime or 0), nNowTime) then
		tbSaveData.nAssistCount = 0
		tbSaveData.nAssistUpdateTime = nNowTime
		self:SaveDataToPlayer(pPlayer, tbSaveData)
	end
	return tbSaveData.nAssistCount or 0
end

-- nAssistId被协助的人
function tbAct:Assist(pPlayer, nAssistId, nId, nShowId, nShowComposeCount)
	local bRet, szMsg, pAssist, szMaterialName = self:CheckAssist(pPlayer, nAssistId, nId)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	local tbPlayerSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	tbPlayerSaveData.tbMaterial = tbPlayerSaveData.tbMaterial or {}
	tbPlayerSaveData.tbMaterial[nId] = math.max(0, (tbPlayerSaveData.tbMaterial[nId] or 0) - 1)
	tbPlayerSaveData.nAssistCount = (tbPlayerSaveData.nAssistCount or 0) + 1

	local tbAssistSaveData = self:GetDataFromPlayer(nAssistId) or {}
	tbAssistSaveData.tbCommitMaterial = tbAssistSaveData.tbCommitMaterial or {}
	tbAssistSaveData.tbCommitMaterial[nId] = (tbAssistSaveData.tbCommitMaterial[nId] or 0) + 1
	tbAssistSaveData.tbAssistName = tbAssistSaveData.tbAssistName or {}
	if not tbAssistSaveData.tbAssistName[pPlayer.szName] then
		tbAssistSaveData.tbAssistName[pPlayer.szName] = GetTime()
	end
	self:SaveDataToPlayer(pPlayer, tbPlayerSaveData)
	self:SaveDataToPlayer(pAssist, tbAssistSaveData)
	pPlayer.SendAward(self.tbAssistAward, nil, true, Env.LogWay_LabaAct);
	local szTip = string.format("您的好友「%s」协助您提交了腊八粥必需食材%s，真是情深义重！", pPlayer.szName, szMaterialName)
	local tbMail = {
		To = nAssistId;
		Title = "腊八节";
		From = "系统";
		Text = szTip;
		nLogReazon = Env.LogWay_LabaAct;
	};
	Mail:SendSystemMail(tbMail);
	pAssist.CenterMsg(szTip, true) 
	pPlayer.CenterMsg("协助成功", true)
	self:TryCompose(pAssist)
	self:SynMaterialData(pPlayer)
	self:SynMaterialData(pAssist)
	self:SynAssistData(pPlayer, nAssistId, nShowId, nShowComposeCount)
	Log("[LabaAct] fnExchangeMaterial ", pPlayer.dwID, pPlayer.szName, nAssistId, nId, nShowId, nShowComposeCount)
end

function tbAct:IsLackMaterial(pPlayer, nId)
	local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
	local tbMaterial = tbSaveData.tbMaterial or {}
	local tbCommitMaterial = tbSaveData.tbCommitMaterial or {}
	local tbMaterialId = nId and {[nId] = true} or self.tbMaterial
	for nMaterialId in pairs(tbMaterialId) do
		-- 身上已经没有材料并且没有提交过材料
		if ((tbMaterial[nMaterialId] or 0) + (tbCommitMaterial[nMaterialId] or 0)) < self.nComposeNeed then
			return true
		end
	end
end

-- 同步玩家单个缺乏的材料或者所有缺乏的材料
function tbAct:SynAssistData(pPlayer, dwID, nId, nComposeCount)
	local pStayInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
	if not pStayInfo then
		return
	end
	local tbData = {}
	tbData[dwID] = tbData[dwID] or {}
	tbData[dwID].dwID = dwID
	tbData[dwID].szName = pStayInfo.szName
	tbData[dwID].tbLack = {}
	local fnGetData = function (pPlayer, dwID, nId, nComposeCount)
		local pAssist = KPlayer.GetPlayerObjById(dwID or 0)
		local tbMaterialInfo = self.tbMaterial[nId]
		if tbMaterialInfo and pAssist and self:IsLackMaterial(pAssist, nId) and (FriendShip:IsFriend(pPlayer.dwID, dwID) or pPlayer.dwID == dwID) then
			local nCount, nUpdateTime = self:GetComposeCount(pAssist)
			-- 每天可合成多次，保证求助的轮次, 用nComposeCount + nUpdateTime来唯一标识当天第n次的求助
			if not nComposeCount or (nCount + nUpdateTime) == nComposeCount then
				local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
				local tbMaterial = tbSaveData.tbMaterial or {}
				local nHave = tbMaterial[nId] or 0
				 return {nId = nId, nHave = nHave}
			end
		end
	end
	if nId then
		local tbGetData = fnGetData(pPlayer, dwID, nId, nComposeCount)
		if tbGetData then
			table.insert(tbData[dwID].tbLack, tbGetData)
		end
	else
		for nMaterialId in ipairs(self.tbMaterial) do
			local tbGetData = fnGetData(pPlayer, dwID, nMaterialId)
			if tbGetData then
				table.insert(tbData[dwID].tbLack, tbGetData)
			end
		end
	end
	pPlayer.CallClientScript("Activity.LabaAct:OnSynAssistData", tbData, dwID, nId, nComposeCount)
end

-- 同步好友需要协助的标识
function tbAct:SynAssistFriend(pPlayer)
	local tbLackFriend = {}
	local tbAllFriends = KFriendShip.GetFriendList(pPlayer.dwID) or {};
	for nFriendId in pairs(tbAllFriends) do
		local pFriend = KPlayer.GetPlayerObjById(nFriendId)
		if pFriend then
			local nCount = self:GetComposeCount(pFriend)
			tbLackFriend[nFriendId] = (self:IsLackMaterial(pFriend) and nCount < self.nMaxComposeCount)
		end
	end
	pPlayer.CallClientScript("Activity.LabaAct:OnSynNeedAssistFriend", tbLackFriend)
end

function tbAct:AskAssist(pPlayer, nId)
	if not self.tbMaterial[nId] then
		pPlayer.CenterMsg("未知材料", true)
		return 
	end
	if not self:IsLackMaterial(pPlayer, nId) then
		pPlayer.CenterMsg("您暂时不需要求助该种材料", true)
		return
	end
	local nComposeCount, nUpdateTime = self:GetComposeCount(pPlayer)
	if nComposeCount >= self.nMaxComposeCount then
		pPlayer.CenterMsg("您暂时不需要求助该种材料", true)
		return 
	end
	local szMsg = string.format("<求助腊八节材料:%s>", self.tbMaterial[nId].szName or "-")
	local tbLinkData = {nLinkType = ChatMgr.LinkType.OpenLabaActAssist, dwID = pPlayer.dwID, nId = nId, nComposeCount = nComposeCount + nUpdateTime}
	ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Friend, pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nPortrait, pPlayer.nSex, pPlayer.nLevel, szMsg, tbLinkData)
	pPlayer.CenterMsg("已经将求助资讯发到好友频道")
end