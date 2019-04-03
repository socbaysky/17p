
local tbActivity = Activity:GetClass(InDifferBattle.tbBattleTypeSetting.ActJueDi.szActName);

tbActivity.tbTimerTrigger = 
{
    {szType = "Day", Time = "13:26" , Trigger = "StartMatchSignUp" },
	{szType = "Day", Time = "16:00" , Trigger = "CloseMatchSignUp" },

    -- {szType = "Day", Time = "13:55" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "13:15" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "14:30" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "14:45" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "15:15" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "15:30" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "15:45" , Trigger = "UpdateRank" },
    -- {szType = "Day", Time = "16:25" , Trigger = "UpdateRank" }, --取最后场打完的时间
}

tbActivity.tbTrigger = 
{
	Init = 
	{
	},
    Start = 
    {
    },
    End = 
    {
    },
    StartMatchSignUp =
    {
    },
    CloseMatchSignUp =
    {
    },
    UpdateRank = {};
}

for i,v in ipairs(tbActivity.tbTimerTrigger) do
    table.insert(tbActivity.tbTrigger.Start, {"StartTimerTrigger", i})
end

function tbActivity:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        InDifferBattle.tbAct:OnActInit(self)
    elseif szTrigger == "Start" then
        local nStartTime, nEndTime = self:GetOpenTimeInfo()

        local szContenrt = string.format(InDifferBattle.tbBattleTypeSetting.ActJueDi.szNewInfomation, Lib:TimeDesc17(nStartTime), Lib:TimeDesc17(nEndTime))
        NewInformation:AddInfomation(InDifferBattle.tbBattleTypeSetting.ActJueDi.szActName, nEndTime, { szContenrt }, {szTitle = "绝地试炼", nReqLevel = 1} )    

        InDifferBattle.tbAct:OnActStart(self)
        
        self:RegisterDataInPlayer(nEndTime)
        
    elseif szTrigger == "StartMatchSignUp" then
        InDifferBattle.tbAct:StartMatchSignUp();
    elseif szTrigger == "CloseMatchSignUp" then
        InDifferBattle.tbAct:CloseMatchSignUp();        
    elseif szTrigger == "UpdateRank" then
        InDifferBattle.tbAct:UpdateRank();        
    elseif szTrigger == "End" then
        InDifferBattle.tbAct:EndAct();
    end
end

function tbActivity:GetCustomInfo( pPlayer )
    if not pPlayer then
        return
    end
    return self:GetDataFromPlayer(pPlayer.dwID) 
end

