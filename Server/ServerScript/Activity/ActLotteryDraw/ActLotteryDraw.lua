
local tbActivity = Activity:GetClass("ActLotteryDraw");

tbActivity.tbTimerTrigger = 
{
	[1] = {szType = "Day", Time = "19:20" , Trigger = "SendWorldMsg1" },
    [2] = {szType = "Day", Time = "19:25" , Trigger = "SendWorldMsg2" },
    [3] = {szType = "Day", Time = "19:30" , Trigger = "LotteryDraw" },
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

    SendWorldMsg1 =
    {
        {"ExcuteTriggle", "SendWorldMsg", 10},
    },

    SendWorldMsg2 =
    {
        {"ExcuteTriggle", "SendWorldMsg", 5},
    },

    LotteryDraw =
    {
        {"ExcuteTriggle", "LotteryDraw"},
    }
}

function tbActivity:ExcuteTriggle(szTrigger, ...)
    if not Lottery:IsOpen() then
        return;
    end

    if szTrigger == "SendWorldMsg" then
        Lottery:SendWorldMsg(...);
    elseif szTrigger == "LotteryDraw" then
        Lottery:Draw();
        Lottery:Close();
    end
end
