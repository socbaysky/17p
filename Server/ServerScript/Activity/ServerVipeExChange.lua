
local tbAct = Activity:GetClass("ServerVipeExChange");

tbAct.tbTimerTrigger =
{
}
tbAct.tbTrigger = {
	Init 	= { },
	Start 	= { },
	End 	= { },
}

tbAct.SAVE_GROUP = 102
tbAct.SAVE_KEY_ServerSend = 1; --ServerSend 的 key


function tbAct:OnTrigger(szTrigger)

	if szTrigger == "Start" then
		self:LoadSetting();
		-- Activity:RegisterNpcDialog(self, 97,  {Text = "bug补偿", Callback = self.OnNpcDialog, Param = {self}})
	elseif szTrigger == "Init" then
		self:LoadSetting();
		self:SendAllMails();
	end
end

function tbAct:SendAllMails()
	for dwRoldId, nCount in pairs(self.tbLimitServerSend) do
		Mail:SendSystemMail({
			To = dwRoldId;
			Title = "剑侠V礼包BUG补偿";
			Text = string.format("尊敬的玩家，由於之前VIP礼包中的4级魂石BUG，导致你获得一些错误的4级魂石。我们深表歉意。\n现提供兑换功能，可以使用任意一个4级的中级魂石（如中级魂石·少年杨影枫等），兑换一个随机4级的初级魂石。\n根据你之前VIP礼包获得情况，你有%d次兑换机会，可以兑换%d个4级的初级魂石。\n请前往襄阳城的 [url=npc:NPC月眉儿, 97, 10] 处兑换", nCount, nCount);
		 })
	end
end

function tbAct:LoadSetting()
	if self.tbLimitServerSend then
		return
	end
	local tbLimitServerSend = {}
	local _, _, nServerIdentity = GetWorldConfifParam()
	local file  = LoadTabFile("Setting/Exchange/LimitServerSend.tab", "ddd", nil, {"ServerId", "RoleId", "Count"});
	for i,v in ipairs(file) do
		if v.ServerId == nServerIdentity then
			tbLimitServerSend[v.RoleId] = v.Count
		end
	end
	self.tbLimitServerSend = tbLimitServerSend
end


function tbAct:OnNpcDialog()
	local nTotalCount = self.tbLimitServerSend[me.dwID]
	if not nTotalCount then
		me.CenterMsg("当前没有bug补偿")
		return
	end

	local nUseCount = me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend)
	Dialog:Show(
	{
	    Text    = string.format("为了补偿之前的BUG，你现在还有 %d/%d 次兑换随机4级初级魂石的机会。可使用4级中级魂石兑换", (nTotalCount - nUseCount), nTotalCount) ,
	    OptList = {
	        { Text = "兑换4级初级魂石", Callback = self.AskExchangeItem, Param = {self} },
	    },
	}, me, him)
end

function tbAct:AskExchangeItem()
	if not self:Can_ServerVipeExChange(me) then
		return
	end
	Exchange:AskItem(me, "ServerVipeExChange", self.ExchangeItem, self)
end

function tbAct:Can_ServerVipeExChange(pPlayer, nAddCount)
	local nTotalCount = self.tbLimitServerSend[pPlayer.dwID]
	if not nTotalCount then
		return
	end
	nAddCount = nAddCount or 1
	local nUseCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend)
	if nUseCount + nAddCount > nTotalCount then
		if nUseCount == nTotalCount then
			pPlayer.CenterMsg("兑换次数已经用完")
		else
			pPlayer.CenterMsg(string.format("兑换次数不足%d次", nAddCount) )
		end
		return
	end

	return true
end

function tbAct:ExchangeItem(tbItems) --有me 的
	for dwTemplateId, nCount in pairs(tbItems) do
		if me.GetItemCountInAllPos(dwTemplateId) < nCount then
			return
		end
	end

	local tbSetting = Exchange.tbExchangeSetting["ServerVipeExChange"];
	local tbExchangeIndex =  Exchange:DefaultCheck(tbItems, tbSetting)
	if not tbExchangeIndex then
		return
	end

	if not self:Can_ServerVipeExChange(me, #tbExchangeIndex) then
		return
	end
	local tbAllExchange = tbSetting.tbAllExchange
	me.SetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend, me.GetUserValue(self.SAVE_GROUP, self.SAVE_KEY_ServerSend) + #tbExchangeIndex)
	for _,nIdex in ipairs(tbExchangeIndex) do
		local tbSet = tbAllExchange[nIdex]
		for nItemId,nCount in pairs(tbSet.tbAllItem) do
			if  me.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_ExchangeSeverSend) ~= nCount then
				Log(debug.traceback(), me.dwID)
				return
			end
		end

		me.SendAward(tbSet.tbAllAward, nil,nil, Env.LogWay_ExchangeSeverSend)
	end
	me.CenterMsg("兑换成功")
end