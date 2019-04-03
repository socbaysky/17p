local tbAct = Activity:GetClass("DefendAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterNpcDialog(self, 99,  {Text = "五一江湖展身手", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        self:SynSwitch()
    elseif szTrigger == "End" then
        self:SynSwitch(true) 
    end
    Log("DefendAct OnTrigger:", szTrigger)
end

function tbAct:OnNpcDialog()
    local fnJoin = function(nPlayerId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId or 0)
        if not pPlayer then
            return
        end
        DefendFuben:TryCreateFuben(pPlayer)
    end
    me.MsgBox("你们确定要参加 五一江湖展身手 活动吗?\n（每日有且仅有一次参与机会，一旦进入就将消耗次数）",
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
        pPlayer.CallClientScript("DefendFuben:SynSwitch", nEndTime)
    end
end

function tbAct:OnPlayerLogin()
    local nStartTime, nEndTime = self:GetOpenTimeInfo()
    me.CallClientScript("DefendFuben:SynSwitch", nEndTime)
end
