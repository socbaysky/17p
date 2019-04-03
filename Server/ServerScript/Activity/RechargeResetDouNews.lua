
local tbAct = Activity:GetClass("RechargeResetDouNews");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:SendNews()
	end
end

function tbAct:SendNews()
	local _, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("RechargeResetDou", nEndTime, {[[。
        [FFFE0D]迎全新资料片，全民狂欢福利[-]
            诸位侠士，全新资料片即将到来，以下为活动预告~

            活动时间：[FFFE0D]2016年9月10日-2016年9月20日[-]
            迎全新资料片，全民狂欢福利！活动期间只要登录游戏的侠士，所有已储值档的[FFFE0D]首次储值双倍元宝奖励[-]将会重新开启。
        ]]}, {szTitle = "全民狂欢", nReqLevel = 1})
end

