
local tbAct = Activity:GetClass("DomainBattleAct");

tbAct.tbTimerTrigger = 
{ 
	[1] = {szType = "Day", Time = "4:02" , Trigger = "SendNews"},					--第一次攻城战是4：02
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { {"StartTimerTrigger", 1}, }, 
	End 	= { }, 
	SendNews= { };
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:SendNews();
	elseif szTrigger == "SendNews" then
		self:SendNews();
	end
end

function tbAct:SendNews()
	local nVersion = DomainBattle:GetBattleVersion()
	if not nVersion or nVersion == 0 then
		return
	end
	local _, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("DomainBattleAct", nEndTime, {[[
[FFFE0D]攻城战狂欢活动[-]

    各位大侠，本周将开启攻城战狂欢活动，参与攻城战将获得更多奖励，请踊跃参加。
[FFFE0D]活动时间：7月12日——7月16日[-]
[FFFE0D]活动一：[-]帮派攻城器械打折
    在活动期间，战争坊出售的攻城器械价格将变为[FFFE0D]八折[-]。
[FFFE0D]活动二：[-]个人奖励增加
    在活动期间，参加攻城战後，个人获得奖励[FFFE0D]增加50%[-]，会获得更多的攻城宝箱。
	]]} )	

end
