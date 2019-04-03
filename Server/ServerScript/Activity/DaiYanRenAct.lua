local tbAct          = Activity:GetClass("DaiYanRenAct")
tbAct.tbTimerTrigger = {}
tbAct.tbTrigger      = { 
    Init    = { }, 
    Start   = { }, 
    End     = { }, 
    SendNews= { };
}
tbAct.LEVEL = 40
tbAct.IMITITY_LV = 5

tbAct.GROUP   = 73
tbAct.VERSION = 1
tbAct.LOVER   = 2

tbAct.tbNpcTask = {
    [2326] = {nTaskId = 6023, nMapTID = 1618},
    [89]   = {nTaskId = 6027, nMapTID = 1619},
    [99]   = {nTaskId = 6030, nMapTID = 1620},
    [625]  = {nTaskId = 6033, nMapTID = 1621},
    [2279] = {nTaskId = 6036, nMapTID = 1623},
}
tbAct.START_TASK = 6020

function tbAct:OnTrigger(szTrigger)
    local fn = self["On" .. szTrigger]
    if not fn then
        return
    end

    fn(self)
end

function tbAct:OnStart()
    self.tbMap4Task = {}
    for nNpcTID, tbInfo in pairs(self.tbNpcTask) do
        local nTaskId = tbInfo.nTaskId
        local nMapTID = tbInfo.nMapTID
        self.tbMap4Task[nMapTID] = nTaskId
        Activity:RegisterNpcDialog(self, nNpcTID, {Text = "前往线索指向之地", Callback = self.TryEnterFuben, Param = {self, nTaskId, nMapTID}})
    end
    Activity:RegisterNpcDialog(self, 99, {Text = "报名参加心心相印活动", Callback = self.TryApply, Param = {self}})
    Activity:RegisterPlayerEvent(self, "DYRAct_TryAgreeApply", "TryAgreeApply")
    Activity:RegisterPlayerEvent(self, "DYRAct_TryAgreeEnterFuben", "TryAgreeEnterFuben")
    Activity:RegisterPlayerEvent(self, "Act_OnAcceptTask", "OnAcceptTask")
    Activity:RegisterGlobalEvent(self, "DYRAct_TryCompleteFuben", "OnFubenSuccess")
end

function tbAct:OnEnd()
    local tbPlayerList = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayerList) do
        Task:CheckTaskValidTime(pPlayer)
    end
end

function tbAct:OnAcceptTask(pPlayer, nTaskId)
    --第一次开活动时参数还没填，所以这里做个保护
    local nBeginTask = tonumber(self.tbParam[1]) or 6020
    local nEndTask = tonumber(self.tbParam[2]) or 6037
    if not nTaskId or nTaskId < nBeginTask or nTaskId > nEndTask then
        return
    end
    local _, nEndTime = self:GetOpenTimeInfo()
    Task:SetValidTime2Task(pPlayer, nTaskId, nEndTime)
end

function tbAct:CheckTeam(pPlayer)
    if not pPlayer.dwTeamID or pPlayer.dwTeamID == 0 then
        return false, "你还没有队伍"
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, "必须与[FFFE0D]报名时的异性好友结成2人组队[-]"
    end

    local dwMember = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    local pMember = KPlayer.GetPlayerObjById(dwMember)
    if not pMember then
        return false, "没找到队友"
    end

    if pPlayer.nSex == pMember.nSex or not FriendShip:IsFriend(pPlayer.dwID, dwMember) then
        return false, "你与对方并非异性的好友，请确认後在进行尝试哦"
    end

    if FriendShip:GetFriendImityLevel(pPlayer.dwID, pMember.dwID) < self.IMITITY_LV then
        return false, string.format("双方亲密度等级需达到%d级", self.IMITITY_LV)
    end

    local nMapId1 = pPlayer.GetWorldPos()
    local nMapId2 = pMember.GetWorldPos()
    if nMapId1 ~= nMapId2 or pPlayer.GetNpc().GetDistance(pMember.GetNpc().nId) > Npc.DIALOG_DISTANCE * 3 then
        return false, "距离太远了，与你的队伍成员必须在一定范围内哦"
    end

    return true, nil, pMember
end

function tbAct:CheckApply(pPlayer)
    if pPlayer.nLevel < self.LEVEL then
        return false, "你等级不足"
    end
    self:CheckPlayerData(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.LOVER) > 0 then
        return false, "你已报名"
    end

    local bRet, szMsg, pTeammate = self:CheckTeam(pPlayer)
    if not bRet then
        return false, szMsg
    end

    if pTeammate.nLevel < self.LEVEL then
        return false, "队友等级不足"
    end
    self:CheckPlayerData(pTeammate)
    if pTeammate.GetUserValue(self.GROUP, self.LOVER) > 0 then
        return false, "队友已经和他人报名"
    end
    return true, nil, pTeammate
end

function tbAct:CheckPlayerData(pPlayer)
    local nGroup     = self.GROUP
    local nVersion   = self.VERSION
    local nStartTime = self:GetOpenTimeInfo()
    if pPlayer.GetUserValue(nGroup, nVersion) == nStartTime then
        return
    end

    pPlayer.SetUserValue(nGroup, nVersion, nStartTime)
    pPlayer.SetUserValue(nGroup, self.LOVER, 0)
end

function tbAct:TryApply()
    local pPlayer = me
    local bRet, szMsg, pTeammate = self:CheckApply(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    pTeammate.CallClientScript("Activity.DaiYanRen:OnGetInvite", "DYRAct_TryAgreeApply", pPlayer.dwID, pPlayer.szName)
end

function tbAct:TryAgreeApply(pPlayer, dwApply, bAgree)
    if not bAgree then
        local pTeammate = KPlayer.GetPlayerObjById(dwApply)
        if pTeammate then
            pTeammate.CenterMsg("对方拒绝了你的邀请")
        end
        return
    end

    local bRet, szMsg, pTeammate = self:CheckApply(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    if pTeammate.dwID ~= dwApply then
        pPlayer.CenterMsg("邀请已过期")
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.LOVER, dwApply)
    pTeammate.SetUserValue(self.GROUP, self.LOVER, pPlayer.dwID)

    Task:ForceAcceptTask(pPlayer, self.START_TASK)
    Task:ForceAcceptTask(pTeammate, self.START_TASK)
    pPlayer.CallClientScript("Activity:CheckRedPoint")
    pTeammate.CallClientScript("Activity:CheckRedPoint")
    local szMsg = "已成功报名参加活动，请将[FFFE0D]左侧按钮[-]切换至[FFFE0D]任务[-]开始进行活动"
    pPlayer.CenterMsg(szMsg)
    pTeammate.CenterMsg(szMsg)
    Log("DaiYanRenAct MakeTeam:", pPlayer.dwID, pTeammate.dwID)
end

local function fnAllMember(tbMember, fnSc, ...)
    for _, nPlayerId in ipairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId)
        if pMember then
            fnSc(pMember, ...);
        end
    end
end

function tbAct:CheckFuben(pPlayer, nTaskId)
    self:CheckPlayerData(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.LOVER) == 0 then
        return false, "队伍中有人尚未报名"
    end

    local bRet, szMsg, pTeammate = self:CheckTeam(pPlayer)
    if not bRet then
        return bRet, szMsg
    end

    for _, pCheck in ipairs({pPlayer, pTeammate}) do
        local nState = Task:GetTaskState(pCheck, nTaskId)
        if nState ~= Task.STATE_ON_DING then
            return false, "必须两人均进行到任务同一步骤才能够继续进行"
        end
    end

    self:CheckPlayerData(pTeammate)
    if pTeammate.GetUserValue(self.GROUP, self.LOVER) == 0 then
        return false, "队友尚未报名"
    end

    if pPlayer.GetUserValue(self.GROUP, self.LOVER) ~= pTeammate.dwID or 
        pTeammate.GetUserValue(self.GROUP, self.LOVER) ~= pPlayer.dwID then
        return false, "队伍成员并非与你一同报名的异性好友"
    end

    for _, pCheck in ipairs({pPlayer, pTeammate}) do
        if not Env:CheckSystemSwitch(pCheck, Env.SW_SwitchMap) then
            return false, "目前状态不允许切换地图"
        end

        if not Fuben.tbSafeMap[pCheck.nMapTemplateId] and Map:GetClassDesc(pCheck.nMapTemplateId) ~= "fight" then
            return false, "所在地图不允许进入副本！";
        end

        if Map:GetClassDesc(pCheck.nMapTemplateId) == "fight" and pCheck.nFightMode ~= 0 then
            return false, "非安全区不允许进入副本！";
        end
    end
    return true, nil, pTeammate
end

function tbAct:TryEnterFuben(nTaskId, nMapTID)
    local pPlayer = me
    if not nTaskId then
        return
    end

    local bRet, szMsg, pTeammate = self:CheckFuben(pPlayer, nTaskId)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    pTeammate.CallClientScript("Activity.DaiYanRen:OnGetInvite", "DYRAct_TryAgreeEnterFuben", pPlayer.dwID, pPlayer.szName, nTaskId, nMapTID)
end

function tbAct:TryAgreeEnterFuben(pPlayer, dwApply, bAgree, tbParam)
    if not bAgree then
        local pTeammate = KPlayer.GetPlayerObjById(dwApply)
        if pTeammate then
            pTeammate.CenterMsg("对方拒绝了你的邀请")
        end
        return
    end

    local nTaskId, nMapTID = unpack(tbParam)
    local bRet, szMsg, pTeammate = self:CheckFuben(pPlayer, nTaskId)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    if pTeammate.dwID ~= dwApply then
        pPlayer.CenterMsg("邀请已过期")
        return
    end


    local nP1ID, nP2ID = pPlayer.dwID, pTeammate.dwID
    local tbMember = {nP1ID, nP2ID}
    local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint()
            pPlayer.SwitchMap(nMapId, 0, 0)
        end
        fnAllMember(tbMember, fnSucess, nMapId)
    end

    local function fnFailedCallback()
        fnAllMember(tbMember, function (pPlayer)
            pPlayer.CenterMsg("创建副本失败，请稍後尝试！")
        end)
    end

    Fuben:ApplyFuben(nP1ID, nMapTID, fnSuccessCallback, fnFailedCallback, nP1ID, nP2ID, nMapTID)
end

function tbAct:OnFubenSuccess(tbPlayer, nMapTID)
    local dwPlayer1, dwPlayer2 = unpack(tbPlayer or {})
    if not dwPlayer1 or not dwPlayer2 then
        return
    end

    local pPlayer1 = KPlayer.GetPlayerObjById(dwPlayer1)
    local pPlayer2 = KPlayer.GetPlayerObjById(dwPlayer2)
    if not pPlayer1 or not pPlayer2 then
        return
    end

    Task:OnTaskExtInfo(pPlayer1, Task.ExtInfo_DaiYanRenAct)
    Task:OnTaskExtInfo(pPlayer2, Task.ExtInfo_DaiYanRenAct)
    Log("DaiYanRenAct CompleteFuben:", dwPlayer1, dwPlayer2, nMapTID)
end