
local tbAct = Activity:GetClass("RechargeAllDayCardAct");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}

tbAct.SAVE_GROUP = 121;
tbAct.KEY_TAKE_DAY = 1;


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self.tbAward = Lib:GetAwardFromString(self.tbParam[1])
		self:SendNews()
		Activity:RegisterPlayerEvent(self, "Act_DailyGift", "OnAct_DailyGift");
	end
end

function tbAct:SendNews()
	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	local tbTime1 = os.date("*t", nStartTime)
	local tbTime2 = os.date("*t", nEndTime)

	local szAwadDesc =  table.concat( Lib:GetAwardDesCount2(self.tbAward), "、")

	NewInformation:AddInfomation("RechargeResetDou", nEndTime, {
		string.format([[
            活动时间：[c8ff00]%d年%d月%d日4点-%d月%d日4点[-]
            活动说明：活动时间内购买[c8ff00]白银/黄金/钻石三个[-]超值礼包後，还将获得[c8ff00]%s[-]的额外奖励，还等什麽，快去购买吧！
            奖励将会通过邮件发放，请注意查收。

        ]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day, szAwadDesc)},
         {szTitle = "每日礼包加码送", nReqLevel = 1})
end



function tbAct:OnAct_DailyGift(pPlayer)
	local nToday = Lib:GetLocalDay(GetTime() - 3600 * 4)
	local nTakedyDay = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TAKE_DAY)
	if nTakedyDay == nToday then
		return
	end
	for nGroupIndex, tbBuyInfo in ipairs(Recharge.tbSettingGroup.DayGift) do
		local nBuyDay = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey)
		if nBuyDay ~= nToday then
			return
		end
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TAKE_DAY, nToday)


	Mail:SendSystemMail({
		To = pPlayer.dwID,
		Title = "活动奖励",
		Text = "      尊敬的侠士！恭喜您在每日礼包加码送活动中达成要求，获得活动奖励",
		tbAttach = self.tbAward,
		nLogReazon = Env.LogWay_RechargeAllDayCardAct,
	});

end

