
local tbActivity = Activity:GetClass("ZhouNianQing2");

tbActivity.tbTimerTrigger = 
{
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
}

function tbActivity:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        
    elseif szTrigger == "Start" then
        Timer:Register(1, function ()
            KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
        end)
    elseif szTrigger == "End" then
        Timer:Register(1, function ()
            KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
        end)
    end
end
