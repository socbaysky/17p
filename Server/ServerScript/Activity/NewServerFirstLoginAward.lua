--新年登录领奖
local tbAct = Activity:GetClass("NewServerFirstLoginAward")
tbAct.tbTimerTrigger = 
{    
}

tbAct.tbTrigger  =
{
    Init  = {},
    Start = {},
    End   = {},
}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerFirstLogin", "OnFirstLogin")
    end
end


function tbAct:OnFirstLogin(pPlayer)
    Mail:SendSystemMail({
        To = pPlayer.dwID;
        Title = "《忘忧镇》互动礼包";
        Text = "少侠，多日未见可曾安好？在此谢过少侠那日忘忧镇中相助，为表谢意，今日我与丽颖为侠士特备薄礼一份，还请笑纳。";
        tbAttach = { { "item", 2180, 1 }, {"item", 2181, 1} };
        From = "杨大侠";
        })
end

