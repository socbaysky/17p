local tbAct = Activity:GetClass("MonsterNianAct")
tbAct.tbTimerTrigger = {
    [1] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify" },
    [2] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify" },
    [3] = {szType = "Day", Time = "20:00" , Trigger = "SendWorldNotify" },
}
tbAct.tbTrigger = {
	Init={},
	Start={
        {"StartTimerTrigger", 1},
        {"StartTimerTrigger", 2},
        {"StartTimerTrigger", 3},
    },
	End={},
    OpenAct = {},
    CloseAct = {},
    SendWorldNotify = { {"WorldMsg", "各位少侠，新年活动开始了，大家可通过查询“最新消息”了解活动内容！", 20} },
}
tbAct.nGroup = 128
tbAct.nDataDay = 1
tbAct.nTimes = 2

function tbAct:OnTrigger(szTrigger)
    Log("MonsterNianAct:OnTrigger", szTrigger)
    if szTrigger=="Start" then
        Activity:RegisterGlobalEvent(self, "Act_KinGather_Open", "OnOpenAct")
        Activity:RegisterGlobalEvent(self, "Act_KinGather_Close", "OnCloseAct")
        Activity:RegisterGlobalEvent(self, "Act_OnKinMemberQuit", "OnKinMemberQuit")

        Activity:RegisterPlayerEvent(self, "Act_TryOpenMonsterBox", "TryOpenMonsterBox")
        Activity:RegisterPlayerEvent(self, "Act_UseFirework", "OnUseFirework")
	end
end

function tbAct:OnUseFirework(pPlayer)
    Kin.MonsterNian:AddScore(pPlayer, Kin.MonsterNianDef.nUseFireworkScore)
end

function tbAct:OnKinMemberQuit(nKinId, nMemberId)
    Kin.MonsterNian:RemoveScore(nKinId, nMemberId)
end

function tbAct:OnOpenAct()
    Kin.MonsterNian:OnActOpen()
	Activity:RegisterGlobalEvent(self, "Act_OnKinMapCreate", "OnKinMapCreate")
    self:CreateKinMapNpc()
    Log("MonsterNianAct:OnOpenAct")
end

function tbAct:OnCloseAct()
    Kin.MonsterNian:OnActClose()
	Log("MonsterNianAct:OnloseAct")
end

function tbAct:CreateNpc(nMapId)
    if not nMapId then
        return
    end
    local nKinId = Kin:GetKinIdByMapId(nMapId)
    if not nKinId then
        Log("[x] MonsterNianAct:CreateNpc, kin nil", tostring(nMapId))
        return
    end
    if not Kin.MonsterNian:IsEnabled(nKinId) then
        Log("MonsterNianAct:CreateNpc, inactive", tostring(nKinId))
        return
    end

    local bOk, szErr = Kin.MonsterNian:Open(nKinId)
    if not bOk then
        Log("[x] MonsterNianAct:CreateNpc", nKinId, tostring(szErr))
    end

    local tbPlayer = KPlayer.GetMapPlayer(nMapId)
    for _, pPlayer in ipairs(tbPlayer or {}) do
        Kin.MonsterNian:OnEnterKinMap(pPlayer)
    end
end

function tbAct:CreateKinMapNpc()
    Kin:TraverseKin(function(tbKinData)
        if not tbKinData:IsMapOpen() then
            return
        end

        self:CreateNpc(tbKinData:GetMapId())
    end)
    Log("MonsterNianAct:CreateKinMapNpc")
end

function tbAct:OnKinMapCreate(nMapId)
    self:CreateNpc(nMapId)
    Log("MonsterNianAct:OnKinMapCreate", nMapId)
end

function tbAct:CheckCanOpen(pPlayer, pNpc)
    local bRet, szMsg = pPlayer.CheckNeedArrangeBag()
    if bRet then
        return false, szMsg
    end

    local nDataDay = pPlayer.GetUserValue(self.nGroup, self.nDataDay)
    local nOpenTimes = pPlayer.GetUserValue(self.nGroup, self.nTimes)
    if Lib:GetLocalDay() ~= nDataDay then
        pPlayer.SetUserValue(self.nGroup, self.nDataDay, nDataDay)
        pPlayer.SetUserValue(self.nGroup, self.nTimes, 0)
        return true
    end

    return nOpenTimes<Kin.MonsterNianDef.nMaxHpRewardsPerDay, string.format("每天只能打开%d个%s", Kin.MonsterNianDef.nMaxHpRewardsPerDay, pNpc.szName)
end

function tbAct:TryOpenMonsterBox(pPlayer, pBox)
    local bRet, szMsg = self:CheckCanOpen(pPlayer, pBox)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end
    GeneralProcess:StartProcess(pPlayer, Env.GAME_FPS, "开启中", self.EndProcess, self, pPlayer.dwID, pBox.nId)
end

function tbAct:EndProcess(dwID, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local pNpc    = KNpc.GetById(nNpcId)
    if not pPlayer then
        return
    end

    if not pNpc or pNpc.IsDelayDelete() then
        pPlayer:CenterMsg("已被其他人抢先打开啦")
        return
    end
    
    local bRet, szMsg = self:CheckCanOpen(pPlayer, pNpc)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    pNpc.Delete()

    local nRandomItemId = tonumber(pNpc.szScriptParam)
    if not nRandomItemId then
        Log("[x] MonsterNian, GatherBox Award Error")
        return
    end

    local nDataDay = pPlayer.SetUserValue(self.nGroup, self.nDataDay, Lib:GetLocalDay())
    local nOpenTimes = pPlayer.GetUserValue(self.nGroup, self.nTimes)
    pPlayer.SetUserValue(self.nGroup, self.nTimes, nOpenTimes + 1)
    pPlayer.SendAward({{"Item", nRandomItemId, 1}}, false, true, Env.LogWay_MonsterNianAct)
    Log("MonsterNianAct:EndProcess", dwID, nRandomItemId, nDataDay, nOpenTimes)
end
