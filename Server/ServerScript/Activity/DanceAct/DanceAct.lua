
local tbActivity = Activity:GetClass("DanceAct");

tbActivity.tbTimerTrigger = 
{
	[1] = {szType = "Day", Time = "12:45" , Trigger = "StartMatch" },
    [2] = {szType = "Day", Time = "15:00" , Trigger = "StartMatch" },
    [3] = {szType = "Day", Time = "20:00" , Trigger = "StartMatch" },
}

tbActivity.tbTrigger = 
{
	Init = 
	{
	},
    Start = 
    {
        {"StartTimerTrigger", 1}, 
        {"StartTimerTrigger", 2},
        {"StartTimerTrigger", 3},
    },
    End = 
    {
    },
    StartMatch =
    {
    },
    
}

function tbActivity:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        Activity.DanceMatch:OnActInit(self)
    elseif szTrigger == "Start" then
        Activity.DanceMatch:OnActStart(self)
        local _, nEndTime = self:GetOpenTimeInfo()
        self:RegisterDataInPlayer(nEndTime)
        
    elseif szTrigger == "StartMatch" then
        Activity.DanceMatch:StartMatchSignUp();
    elseif szTrigger == "End" then
        Activity.DanceMatch:EndAct();
    end
end

function tbActivity:GetCustomInfo( pPlayer )
    if not pPlayer then
        return
    end
    return self:GetDataFromPlayer(pPlayer.dwID) 
end

