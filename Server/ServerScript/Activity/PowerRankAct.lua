local tbAct = Activity:GetClass("PowerRankAct")
tbAct.tbTrigger = { 
	Init = { }, 
	End = { }, 
}
function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		local _, nEndTime = Activity:__GetActTimeInfo(self.szKeyName)
		NewInformation:AddInfomation("PowerRankActivity", nEndTime, {})
	elseif szTrigger == "End" then
		RankActivity.PowerRankActivity:StartPowerRank()
	end
end