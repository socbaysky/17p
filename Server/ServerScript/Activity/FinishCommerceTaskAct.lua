local tbActivity = Activity:GetClass("FinishCommerceTaskAct")
tbActivity.tbTrigger = 
{
	Init = {}, Start = {}, End = {},
}
tbActivity.tbAward = {{"Item", 8396, 1}}

function tbActivity:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_FinishCommerceTask", "OnFinishTask")
    end
end

function tbActivity:OnFinishTask(pPlayer, nLogway)
	pPlayer.SendAward(self.tbAward, false, true, nLogway)
end