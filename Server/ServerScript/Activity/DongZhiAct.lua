--打开庆典宝箱额外奖励
local tbDAct = Activity:GetClass("DongZhiAct")

tbDAct.tbTimerTrigger = { }
tbDAct.tbTrigger = { Init = { }, Start = { }, End = { }, }
tbDAct.tbAward = { {"Item", 3524, 1} }

function tbDAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnOpenGatherBox", "OnOpenBox")
        local _, nEndTime = self:GetOpenTimeInfo()
        self:RegisterDataInPlayer(nEndTime)
    end
end

function tbDAct:OnOpenBox(pPlayer)
    local nBadLuckTimes = self:GetDataFromPlayer(pPlayer.dwID)
    nBadLuckTimes = nBadLuckTimes or 0
    if MathRandom(1000000) <= 300000 or nBadLuckTimes >= 7 then
        nBadLuckTimes = 0
        pPlayer.SendAward(self.tbAward, true, true, Env.LogWay_DongzhiAct)
    else
        nBadLuckTimes = nBadLuckTimes + 1
    end
    self:SaveDataToPlayer(pPlayer, nBadLuckTimes)
end


--完成商会任务额外奖励
local tbAct = Activity:GetClass("CommerceTaskAct")

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }
tbAct.tbAward = { {"Item", 3525, 1, 86400}, {"Item", 7319, 1, 259200} }

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnCommitItem", "OnCommitItem")
        CommerceTask:RegisterActAward(self.GetAward, self)
    elseif szTrigger == "End" then
        CommerceTask:UnRegisterActAward()
    end
end

function tbAct:GetAward()
    local tbAward = {}
    for _, tbInfo in ipairs(self.tbAward) do
        local tbCopy = {unpack(tbInfo)}
        if tbCopy[4] then
            tbCopy[4] = tbCopy[4] + GetTime()
        end
        table.insert(tbAward, tbCopy)
    end
    return tbAward
end

function tbAct:OnCommitItem(player)
    local tbAward = self:GetAward()
    local pPlayer = player
    if type(pPlayer) == "number" then
        pPlayer = KPlayer.GetPlayerObjById(player)
        if not pPlayer then
            return
        end
    end
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_CommerceTaskAct)
end