
local tbAct = Activity:GetClass("VipAwardBoxExchange");

tbAct.tbTimerTrigger =
{
}
tbAct.tbTrigger = {
	Init 	= { },
	Start 	= { },
	End 	= { },
}

tbAct.tbVipLevelCount  = {
	[14] = 4;
	[15] = 6;
	[16] = 6;
}

tbAct.SAVE_GROUP = 102
tbAct.SAVE_KEY_Count = 2;

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		if not self.nRegisterLogin then
			self.nRegisterLogin = PlayerEvent:RegisterGlobal("OnLogin",  self.OnLogin, self);
		end

		Activity:RegisterNpcDialog(self, 97,  {Text = "Bug补偿", Callback = self.OnNpcDialog, Param = {self}})

	elseif szTrigger == "End" then
		if self.nRegisterLogin then
			PlayerEvent:UnRegisterGlobal("OnLogin", self.nRegisterLogin)
			self.nRegisterLogin = nil;
		end
	end
end

function tbAct:OnNpcDialog()
	local nHasCout = me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count)
	if nHasCout <= 0 then
		me.CenterMsg("当前没有bug补偿")
		return
	end

	Dialog:Show(
	{
	    Text    = string.format("你现在还有 %d 次兑换4级魂石任选箱的机会。可使用4级初级魂石兑换", nHasCout) ,
	    OptList = {
	        { Text = "兑换4级魂石任选箱", Callback = self.AskExchangeItem, Param = {self} },
	    },
	}, me, him)
end

function tbAct:CanChange(pPlayer, nUseCount)
	local nHasCout = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count)
	if nHasCout <= 0 then
		pPlayer.CenterMsg("当前没有兑换次数")
		return
	end

	if nUseCount then
		if nUseCount > nHasCout then
			pPlayer.CenterMsg(string.format("兑换次数不足%d次", nUseCount))
			return
		end
	end

	return true
end

function tbAct:AskExchangeItem()
	if not self:CanChange(me) then
		return
	end
	Exchange:AskItem(me, "VipAwardBoxExchange", self.ExchangeItem, self)
end

function tbAct:ExchangeItem(tbItems)
	for dwTemplateId, nCount in pairs(tbItems) do
		if me.GetItemCountInAllPos(dwTemplateId) < nCount then
			return
		end
	end

	local tbSetting = Exchange.tbExchangeSetting["VipAwardBoxExchange"];
	local tbExchangeIndex =  Exchange:DefaultCheck(tbItems, tbSetting)
	if not tbExchangeIndex then
		return
	end

	local nHasCout = me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count)
	if not self:CanChange(me, #tbExchangeIndex) then
		return
	end


	local tbAllExchange = tbSetting.tbAllExchange
	local tbGetItems = {}
	for i,nIdex in ipairs(tbExchangeIndex) do
		local tbSet = tbAllExchange[nIdex]
		for nItemId,nCount in pairs(tbSet.tbAllItem) do
			if  me.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_VipAwardBoxExchange) ~= nCount then
				Log(debug.traceback(), me.dwID)
				return
			end
		end
		Lib:MergeTable(tbGetItems, tbSet.tbAllAward)
	end

	me.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count, nHasCout - #tbExchangeIndex)
	me.SendAward(tbGetItems, nil,nil, Env.LogWay_VipAwardBoxExchange)

	me.CenterMsg("兑换成功")
end

function tbAct:OnLogin()
	if me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count) > 0 then
		return
	end

	local nVipLevel = me.GetVipLevel()
	if nVipLevel < 14 then
		return;
	end

	local nBuyedVal = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_VIP_AWARD)
	local nCount = 0
	local _, nEndTime = self:GetOpenTimeInfo()
	for nNeedVipLevel, nSaveKey in pairs(Recharge.tbVipAwardTakeTimeKey) do
		local nBuydeBit = KLib.GetBit(nBuyedVal, nNeedVipLevel + 1)
		if nBuydeBit == 1 and me.GetUserValue(Recharge.SAVE_GROUP, nSaveKey) == 0 then
			nCount = nCount + self.tbVipLevelCount[nNeedVipLevel]
			me.SetUserValue(Recharge.SAVE_GROUP, nSaveKey, nEndTime)
		end
	end
	if nCount > 0 then
		me.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_Count, nCount)
		Log("VipAwardBoxExchange AddCount ", me.dwID, nCount, me.GetVipLevel())
		Mail:SendSystemMail({
			To = me.dwID;
			Title = "剑侠V礼包补偿";
			Text = string.format("尊敬的玩家，由於原VIP礼包中的4级随机魂石，调整为4级魂石任选箱。为弥补您的损失，现提供兑换功能，可以使用任意一个4级的初级魂石，兑换一个4级魂石任选箱。\n根据你之前VIP礼包获得情况，你有%d次兑换机会\n请前往襄阳城的 [00ff00][url=npc:NPC月眉儿, 97, 10][-] 处兑换", nCount);
		 })

	end
end