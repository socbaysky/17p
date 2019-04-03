local tbAct = Activity:GetClass("IdiomsAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
    	IdiomFuben:LoadSetting()
        Activity:RegisterNpcDialog(self, 99,  {Text = "成语接龙", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        self:SynSwitch() 
    elseif szTrigger == "End" then
        self:SynSwitch(true) 
    end
    Log("IdiomsAct OnTrigger:", szTrigger)
end

function tbAct:OnNpcDialog()
    local fnJoin = function(nPlayerId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId or 0)
        if not pPlayer then
            return
        end
        IdiomFuben:TryCreateFuben(pPlayer)
    end
    me.MsgBox("你们确定要参加 成语接龙 活动吗?",
                {
                    {"确认参加", fnJoin, me.dwID},
                    {"取消"},
                })
end

-- 同步活动开关
function tbAct:SynSwitch(bClose) 
    local nStartTime, nEndTime
    if not bClose then
        nStartTime, nEndTime = self:GetOpenTimeInfo()
    end
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        pPlayer.CallClientScript("IdiomFuben:SynSwitch",nEndTime)
    end
end

function tbAct:OnPlayerLogin()
    local nStartTime, nEndTime = self:GetOpenTimeInfo()
    me.CallClientScript("IdiomFuben:SynSwitch", nEndTime)
end


