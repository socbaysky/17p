
local tbAct = Activity:GetClass("DomainBattleAct2");

tbAct.tbTimerTrigger = 
{ 
	[1] = {szType = "Day", Time = "19:10" , Trigger = "AddAcution"},				
	[2] = {szType = "Day", Time = "4:02" , Trigger = "SendNews"},					--第一次攻城战是4：02
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { {"StartTimerTrigger", 1}, {"StartTimerTrigger", 2},}, 
	End 	= { }, 
	AddAcution = {};
	SendNews = {};
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:SendNews();
	elseif szTrigger == "AddAcution" then

		self:AddAcution()
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
	NewInformation:AddInfomation("DomainBattleAct2", nEndTime, {[[
\t\t[FFFE0D]攻城战狂欢活动二[-]
\t\t\t[FFFE0D]活动时间：7月17日——7月23日[-]
\t\t\t各位侠士，活动期间，西域行商开始出现在各大领地贩卖各种珍贵物品。
\t\t\t每天[FFFE0D]19：10[-]，帮派拍卖行会出现“[FFFE0D]领地行商[-]”拍卖，参加了[FFFE0D]上一次攻城战[-]的帮派成员可以获得拍卖分红。
]]} )
end

function tbAct:AddAcution()
	DomainBattle:AddOnwenrAcutionAward()
end
