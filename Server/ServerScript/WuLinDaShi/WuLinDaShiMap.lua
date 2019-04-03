--每阶段对应的天数
WuLinDaShi.SECTION_DAY = {5, 5}
WuLinDaShi.SECTION1_ID = 1 --第一阶段ID
WuLinDaShi.SECTION2_ID = 2 --第二阶段ID
WuLinDaShi.tbNpcInfo = {
    --[NpcId] = {[阶段ID] = {阶段信息，nOriginalHp：原始血量，根据阶段时间，每天减少一份}}
    [2788] = {[WuLinDaShi.SECTION1_ID] = {nOriginalHp = 100}},  ---城门
    [2789] = {[WuLinDaShi.SECTION1_ID] = {}},                   ---龙柱
    [2790] = {[WuLinDaShi.SECTION1_ID] = {}},                   ---龙柱
    [2791] = {[WuLinDaShi.SECTION1_ID] = {}},                   ---金兵
    [2792] = {[WuLinDaShi.SECTION1_ID] = {}},                   ---宋兵
    [2820] = {[WuLinDaShi.SECTION1_ID] = {}},                   ---百夫长
    [2818] = {[WuLinDaShi.SECTION1_ID] = {}},                   ---宋军副将

    [2798] = {[WuLinDaShi.SECTION2_ID] = {nOriginalHp = 100}},  ---龙柱
    [2797] = {[WuLinDaShi.SECTION2_ID] = {nOriginalHp = 100}},  ---龙柱
    [2793] = {[WuLinDaShi.SECTION2_ID] = {}},                   ---工匠
    [2794] = {[WuLinDaShi.SECTION2_ID] = {}},                   ---木材
    [2795] = {[WuLinDaShi.SECTION2_ID] = {}},                   ---宋兵
    [2796] = {[WuLinDaShi.SECTION2_ID] = {}},                   ---金兵
    [2817] = {[WuLinDaShi.SECTION2_ID] = {}},                   ---百夫长
    [2819] = {[WuLinDaShi.SECTION2_ID] = {}},                   ---宋军副将
}
WuLinDaShi.tbObstacle = {
    [WuLinDaShi.SECTION2_ID] = true,
}
WuLinDaShi.MAP_ID   = 6101
WuLinDaShi.OPEN_TF  = "OpenLevel79"
WuLinDaShi.DAYEND   = 3 --每天打烊的时间
WuLinDaShi.DAYBEGIN = 4 --每天开始的时间

local fnGetCycleDay = function (tb)
    local nCycDay = 0
    for _, nDay in pairs(tb) do
        nCycDay = nCycDay + nDay
    end
    return nCycDay
end
function WuLinDaShi:GetMapCurInfo()
    if GetTimeFrameState(self.OPEN_TF) ~= 1 then
        return
    end

    self.tbTmpMapInfo = self.tbTmpMapInfo or {}
    if self.tbTmpMapInfo.nRefreshDay == Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600) then
        return unpack(self.tbTmpMapInfo.tbMapInfo)
    end
    self.tbTmpMapInfo.nRefreshDay = Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600)

    local tbInfo    = ScriptData:GetValue("WuLinDaShiMapInfo")
    local nStartDay = tbInfo.nStartDay or 0
    local nCurDay   = Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600) - nStartDay + 1
    local nOpenDay  = 0
    for nSection, nDay in ipairs(tbInfo.tbSectionDay or {}) do
        if nCurDay <= (nOpenDay + nDay) then
            self.tbTmpMapInfo.tbMapInfo = {nSection, nCurDay - nOpenDay, nDay, tbInfo.tbSectionDay}
            return unpack(self.tbTmpMapInfo.tbMapInfo)
        end
        nOpenDay = nOpenDay + nDay
    end
    tbInfo.nStartTime   = GetTime()
    tbInfo.nStartDay    = Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600)
    tbInfo.nEndDay      = tbInfo.nStartDay + fnGetCycleDay(self.SECTION_DAY) - 1
    tbInfo.tbSectionDay = self.SECTION_DAY
    ScriptData:SaveAtOnce("WuLinDaShiMapInfo", tbInfo)
    Log("WuLinDaShi Map Reset")
    self.tbTmpMapInfo.tbMapInfo = {self.SECTION1_ID, 1, tbInfo.tbSectionDay[self.SECTION1_ID], tbInfo.tbSectionDay}
    return unpack(self.tbTmpMapInfo.tbMapInfo)
end

function WuLinDaShi:OnStartUp()
    self.nActivityId = TeamMgr:RegisterActivity("WuLinDaShiFuben", "WuLinDaShiFuben", "龙潭虎穴",
        {"WuLinDaShi:QTCanShow"},
        {"WuLinDaShi:QTCanJoin"},
        {"WuLinDaShi:QTCheckEnter"},
        {"WuLinDaShi:QTEnterFuben"}, self.MIN_PLAYER_COUNT)
    Timer:Register(Env.GAME_FPS * 10, self.RefreshNpcHp, self)
end

function WuLinDaShi:RefreshNpcHp()
    local nSection, nSectionDay, nSectionMaxDay = self:GetMapCurInfo()
    if not nSection or not GetMapInfoById(self.MAP_ID) then
        self.nRefreshTimer = nil
        return
    end

    local tbNpc = KNpc.GetMapNpc(self.MAP_ID, false)
    if #tbNpc == 0 then
        self.nRefreshTimer = nil
        return
    end
    for _, pNpc in ipairs(tbNpc) do
        local nTID   = pNpc.nTemplateId
        local tbInfo = self.tbNpcInfo[nTID]
        if tbInfo then
            local tbSecInfo = tbInfo[nSection]
            if tbSecInfo then
                pNpc.SetHideNpc(0)
                local nOriginalHp = tbSecInfo.nOriginalHp
                if nOriginalHp then
                    local nDayHp   = nOriginalHp / nSectionMaxDay
                    local nTodayHp = nOriginalHp - (nSectionDay - 1) * nDayHp
                    local nHour    = Lib:GetLocalDayHour() - self.DAYBEGIN
                    nHour = nHour < 0 and (nHour + 24) or nHour
                    local nCurHp   = nTodayHp - (nHour/24)*nDayHp
                    nCurHp = math.ceil(pNpc.nMaxLife * nCurHp / 100)
                    pNpc.SetCurLife(nCurHp)
                end
            else
                pNpc.SetHideNpc(1)
            end
        end
    end
    return true
end

--每天三点打烊
function WuLinDaShi:PutUpTheShutters()
    local nSection, nSectionDay, nSectionMaxDay = self:GetMapCurInfo()
    if not nSection then
        return
    end
    local tbPlayer = KPlayer.GetMapPlayer(self.MAP_ID)
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.GotoEntryPoint()
    end
end

function WuLinDaShi:CheckEnter(pPlayer)
    if not self:GetMapCurInfo() then
        return false, "不在活动时间内"
    end

    local nHour = Lib:GetLocalDayHour()
    if nHour >= self.DAYEND and nHour < self.DAYBEGIN then
        return false, "金军暂缓攻城，少侠先暂时休息一下吧！"
    end

    if not self:GetCycleTask(pPlayer) then
        return false, "少侠身上没有任务！"
    end

    return true
end

function WuLinDaShi:RefreshObstacle()
    local nSection = self:GetMapCurInfo()
    if not nSection then
        return
    end
    local bRefreshNpcHp
    if not self.nRefreshTimer then
        self.nRefreshTimer = Timer:Register(Env.GAME_FPS*60*60, self.RefreshNpcHp, self)
        bRefreshNpcHp = true
    end
    if self.nLastRefreshSection ~= nSection then
        self.bDynamicObstacleOpen = self.tbObstacle[nSection]
        if self.bDynamicObstacleOpen then
            OpenDynamicObstacle(self.MAP_ID, "gate_n")
            OpenDynamicObstacle(self.MAP_ID, "gate_s")
        else
            CloseDynamicObstacle(self.MAP_ID, "gate_n")
            CloseDynamicObstacle(self.MAP_ID, "gate_s")
        end
        self.nLastRefreshSection = nSection
        bRefreshNpcHp = true
    end
    if bRefreshNpcHp then
        self:RefreshNpcHp()
    end
end

function WuLinDaShi:CheckTaskBaseData(pPlayer, nTranche, bSetIsNil)
    if not self:GetMapCurInfo() then
        return
    end
    local tbTaskInfo = self.tbCycleTask[nTranche]
    if not tbTaskInfo then
        return
    end
    local tbInfo = ScriptData:GetValue("WuLinDaShiMapInfo")
    if not next(tbInfo) then
        return
    end
    local nStartDay = pPlayer.GetUserValue(tbTaskInfo.nPlayerSaveGroup, tbTaskInfo.nVersionBegin)
    if nStartDay > 0 then
        local nEndDay = pPlayer.GetUserValue(tbTaskInfo.nPlayerSaveGroup, tbTaskInfo.nVersionEnd)
        if tbInfo.nStartDay == nStartDay and tbInfo.nEndDay == nEndDay then
            return 0
        end

        if nStartDay <= tbInfo.nStartDay and nEndDay > tbInfo.nStartDay  then
            pPlayer.SetUserValue(tbTaskInfo.nPlayerSaveGroup, tbTaskInfo.nVersionBegin, tbInfo.nStartDay)
            pPlayer.SetUserValue(tbTaskInfo.nPlayerSaveGroup, tbTaskInfo.nVersionEnd, tbInfo.nEndDay)
            Log("WuLinDaShi CheckTaskBaseData Reset, Reason Is CombineServer", pPlayer.dwID, nStartDay, nEndDay, tbInfo.nStartDay, tbInfo.nEndDay)
            return 0
        end
        return
    end
    if bSetIsNil then
        pPlayer.SetUserValue(tbTaskInfo.nPlayerSaveGroup, tbTaskInfo.nVersionBegin, tbInfo.nStartDay)
        pPlayer.SetUserValue(tbTaskInfo.nPlayerSaveGroup, tbTaskInfo.nVersionEnd, tbInfo.nEndDay)
        Log("WuLinDaShi SetPlayerTranche Base Data", pPlayer.dwID, tbInfo.nStartDay, tbInfo.nEndDay)
    end
    return 1
end

local fnGetTodayEndTime = function ()
    local nDayTime = Lib:GetLocalDayTime()
    local nEndTime = GetTime() + (WuLinDaShi.DAYBEGIN*3600 - nDayTime)
    if nDayTime > WuLinDaShi.DAYBEGIN*3600 then
        nEndTime = nEndTime + 24*3600
    end
    return nEndTime
end
function WuLinDaShi:OnFinishTask(nTaskId)
    local nTranche = self.tbStartTaskId[nTaskId]
    if nTranche then
        local nRet = self:CheckTaskBaseData(me, nTranche, true)
        if nRet ~= 1 then
            Log("WuLinDaShi OnFinishTask StartTask Had Data or Not Open", nTaskId, nRet)
            return
        end
        self:__AcceptTask(me, nTranche)
        return
    end
    nTranche = self.tbDayTask[nTaskId]
    if nTranche then
        local nRet = self:CheckTaskBaseData(me, nTranche)
        if nRet ~= 0 then
            Log("WuLinDaShi OnFinishTask StartTask No Data or Not Open", nTaskId, nRet)
            return
        end
        self:__AcceptTask(me, nTranche)
        return
    end
    nTranche = self.tbDayCompleteTaskId[nTaskId]
    if nTranche then
        local tbTrancheInfo = self.tbCycleTask[nTranche]
        if tbTrancheInfo and tbTrancheInfo.nDayTask4Show then
            local nEndTime = fnGetTodayEndTime()
            Task:ForceAcceptTask(me, tbTrancheInfo.nDayTask4Show)
            Task:SetValidTime2Task(me, tbTrancheInfo.nDayTask4Show, nEndTime)
        end
        return
    end
end

function WuLinDaShi:OnLogin(pPlayer)
    if GetTimeFrameState(self.OPEN_TF) ~= 1 then
        return
    end
    self:FixLinAnTask(pPlayer)
    self:CheckTodayTask(pPlayer)
    local nSection, nSectionDay, nSectionMaxDay, tbSectionDay = self:GetMapCurInfo()
    if nSection then
        pPlayer.CallClientScript("WuLinDaShi:OnSyncSectionInfo", nSection, nSectionDay, nSectionMaxDay, tbSectionDay)
    end
    pPlayer.CallClientScript("WuLinDaShi:OnSyncActivityId", self.nActivityId)
end

--外网有些玩家还没到时间轴就接了临安之秋的任务，这里对这种玩家进行处理
function WuLinDaShi:FixLinAnTask(pPlayer)
    local nLinAnTranche = 1
    local tbTrancheInfo = self.tbCycleTask[nLinAnTranche]
    if not tbTrancheInfo then
        return
    end

    if pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nVersionBegin) > 0 then
        return
    end

    if Task:GetTaskFlag(pPlayer, tbTrancheInfo.nStartTaskId) ~= 1 then
        return
    end

    local _, nSectionDay = self:GetMapCurInfo()
    if not nSectionDay or nSectionDay > 3 then
        return
    end

    self:OnFinishTask(tbTrancheInfo.nStartTaskId)
end

function WuLinDaShi:OnNewDayBegin()
    if GetTimeFrameState(self.OPEN_TF) ~= 1 then
        return
    end
    local nSection, nSectionDay, nSectionMaxDay, tbSectionDay = self:GetMapCurInfo()
    if not nSection then
        return
    end
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayer) do
        Task:CheckTaskValidTime(pPlayer)
        self:CheckTodayTask(pPlayer)
        pPlayer.CallClientScript("WuLinDaShi:OnSyncSectionInfo", nSection, nSectionDay, nSectionMaxDay, tbSectionDay)
    end
end

function WuLinDaShi:CheckTodayTask(pPlayer)
    for nTranche, tbTrancheInfo in ipairs(self.tbCycleTask) do
        local nRet = self:CheckTaskBaseData(pPlayer, nTranche)
        if nRet == 0 and pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nDataDay) ~= Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600) then
            self:__AcceptTask(pPlayer, nTranche)
        end
    end
end

function WuLinDaShi:__AcceptTask(pPlayer, nTranche)
    local tbTrancheInfo = self.tbCycleTask[nTranche]
    local nSection = self:GetMapCurInfo()
    if not tbTrancheInfo or not nSection then
        Log("WuLinDaShi __AcceptTask Big Err", pPlayer.dwID, nTranche, nSection)
        return
    end

    if pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nDataDay) ~= Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600) then
        pPlayer.SetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nDataDay, Lib:GetLocalDay(GetTime() - self.DAYBEGIN*3600))
        pPlayer.SetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nAcceptCount, 0)
        local tbRanTask = Lib:CopyTB1(tbTrancheInfo.tbSectionTask[nSection].tbRandomTask)
        Lib:SmashTable(tbRanTask)
        for nTaskIdx = 1, tbTrancheInfo.nDayTaskCount do
            pPlayer.SetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nDayTaskBeginKey + nTaskIdx - 1, tbRanTask[nTaskIdx])
        end
    end

    local nHadAccept = pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nAcceptCount)
    if nHadAccept > tbTrancheInfo.nDayTaskCount then
        return
    end

    pPlayer.SetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nAcceptCount, nHadAccept + 1)
    if nHadAccept == tbTrancheInfo.nDayTaskCount then
        if pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nDataDay) == pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, tbTrancheInfo.nVersionEnd) then
            Task:ForceAcceptTask(pPlayer, tbTrancheInfo.nAllCompleteTaskId)
            Log("WuLinDaShi Accept AllComplete Task", pPlayer.dwID)
        else
            local nSection = self:GetMapCurInfo()
            local nEndTime = fnGetTodayEndTime()
            local nTaskId = tbTrancheInfo.tbSectionTask[nSection].nDayCompleteTaskId
            Task:ForceAcceptTask(pPlayer, nTaskId)
            Task:SetValidTime2Task(pPlayer, nTaskId, nEndTime)
        end
        return
    end

    local nSaveKey = tbTrancheInfo.nDayTaskBeginKey + nHadAccept
    local nTaskId = pPlayer.GetUserValue(tbTrancheInfo.nPlayerSaveGroup, nSaveKey)
    if nTaskId == 0 then
        local nSection = self:GetMapCurInfo()
        local tbRanTask = tbTrancheInfo.tbSectionTask[nSection].tbRandomTask
        nTaskId = tbRanTask[MathRandom(#tbRanTask)]
        Log("WuLinDaShi __AcceptTask Task Init Err, TaskCount Not Same", pPlayer.dwID, nHadAccept)
    end
    Task:ForceAcceptTask(pPlayer, nTaskId)
    local nEndTime = fnGetTodayEndTime()
    Task:SetValidTime2Task(pPlayer, nTaskId, nEndTime)
end


------------------------------------------------Fuben------------------------------------------------
--客户端显示可见情况
function WuLinDaShi:QTCanShow()
    return true
end

function WuLinDaShi:QTCanJoin()
    return self:CheckPlayerCanEnterFuben(me)
end

function WuLinDaShi:CheckPlayerCanEnterFuben(pPlayer)
    if pPlayer.nLevel < self.FUBEN_MIN_LEVEL then
        return false, string.format("等级不足%d，无法参加", self.FUBEN_MIN_LEVEL)
    end

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前状态不允许参加"
    end

    local bRet, szMsg = pPlayer.CheckNeedArrangeBag()
    if bRet then
        return false, szMsg
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
        return false, "所在地图不允许进入副本"
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "不在安全区，不允许进入副本"
    end

    return true
end

function WuLinDaShi:QTCheckEnter()
    return self:CheckCanCreateFuben(me)
end

function WuLinDaShi:CheckCanCreateFuben(pPlayer)
    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if not tbMember or #tbMember <= 0 then
        tbMember = { pPlayer.dwID }
    end

    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if teamData and teamData.nCaptainID ~= pPlayer.dwID then
        return false, "只有队长才可以开启副本！"
    end

    if #tbMember < self.MIN_PLAYER_COUNT then
        return false, string.format("队伍人数不足 %d，无法开启副本！", self.MIN_PLAYER_COUNT), tbMember
    end

    if #tbMember > self.MAX_PLAYER_COUNT then
        return false, string.format("队伍人数超过 %d，无法开启副本！", self.MAX_PLAYER_COUNT), tbMember
    end

    for _, nPlayerId in pairs(tbMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "未知队伍成员，无法开启副本！", tbMember
        end

        local bRet, szMsg = self:CheckPlayerCanEnterFuben(pPlayer)
        if not bRet then
            return false, "「" .. pPlayer.szName .. "」" .. szMsg, tbMember
        end
    end

    return true, "", tbMember
end

local function fnAllMember(tbMember, fnSc, ...)
    for _, nPlayerId in pairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId)
        if pMember then
            fnSc(pMember, ...)
        end
    end
end

local function fnMsg(pPlayer, szMsg)
    pPlayer.CenterMsg(szMsg)
end

function WuLinDaShi:QTEnterFuben()
    self:CreateFuben(me.dwID)
end

function WuLinDaShi:CreateFuben(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return
    end

    if not self:CheckFubenTask(pPlayer) then
        pPlayer.CenterMsg("没有对应任务")
        return
    end

    local bRet, szMsg, tbMember = self:CheckCanCreateFuben(pPlayer)
    if not bRet then
        fnAllMember(tbMember, fnMsg, szMsg)
        return
    end

    local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint()
            pPlayer.SwitchMap(nMapId, 0, 0)
        end
        fnAllMember(tbMember, fnSucess, nMapId)
    end

    local function fnFailedCallback()
        fnAllMember(tbMember, fnMsg, "创建副本失败，请稍後尝试！")
    end

    Fuben:ApplyFuben(pPlayer.dwID, self.FUBEN_TASK_MAP, fnSuccessCallback, fnFailedCallback)
    return true
end

WuLinDaShi.tbSafeCall = {
    TrySetTarget = true,
    TryEnterFuben = true,
    RequestSectionInfo = true,
}
function WuLinDaShi:OnClientCall(szFunc, ...)
    if not self.tbSafeCall[szFunc] then
        return
    end
    self[szFunc](self, ...)
end

function WuLinDaShi:TrySetTarget()
    if not self.nActivityId then
        me.CenterMsg("没找到活动")
        return
    end
    local teamData = TeamMgr:GetTeamById(me.dwTeamID)
    if not teamData then
        local bRet, szMsg = TeamMgr:CreateOnePersonTeam(self.nActivityId)
        if not bRet then
            me.CenterMsg(szMsg or "")
            return
        end
        me.CallClientScript("Ui:OpenWindow", "TeamPanel", "TeamActivity")
    else
        if teamData:IsCaptain(me.dwID) then
            local bRet, szMsg = self:QTCanJoin()
            if not bRet then
                me.CenterMsg(szMsg)
                return
            end
            teamData:ChangeTargetActivity(self.nActivityId)
            me.CallClientScript("WuLinDaShi:NotifyTargetChanged")
        else
            me.CenterMsg("不是队长，无法进行操作")
        end
    end
end

function WuLinDaShi:TryEnterFuben()
    local teamData = TeamMgr:GetTeamById(me.dwTeamID)
    if not teamData then
        me.CenterMsg("没有队伍")
        return
    end
    if not teamData:IsCaptain(me.dwID) then
        me.CenterMsg("不是队长，无法进行操作")
        return
    end

    local bRet, szMsg = self:QTCanJoin()
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    TeamMgr:QuickTeamUpSetting(self.nActivityId)
    me.CallClientScript("TeamMgr:EnterActivity")
end

function WuLinDaShi:RequestSectionInfo()
    local nSection, nSectionDay, nSectionMaxDay, tbSectionDay = self:GetMapCurInfo()
    if nSection then
        me.CallClientScript("WuLinDaShi:OnSyncSectionInfo", nSection, nSectionDay, nSectionMaxDay, tbSectionDay)
    end
end

local tbMap = Map:GetClass(WuLinDaShi.MAP_ID)
tbMap.tbTrapInfo = {
    chuansong1 = {11692, 10664},
    chuansong2 = {9239, 7009},
    chuansong3 = {12967, 10473},
    chuansong4 = {13008, 4949},
}
tbMap.tbTrapMsg =
{
    tips1 = "此战关乎大宋存亡，城门不得擅开，少侠可由旁边密道进城！",
    tips2 = "此战关乎大宋存亡，城门不得擅开，少侠可由旁边密道出城！",
}
function tbMap:OnPlayerTrap(nMapID, szTrapName)
    if nMapID ~= WuLinDaShi.MAP_ID then
        return
    end
    if not WuLinDaShi:GetMapCurInfo() then
        return
    end
    if WuLinDaShi.bDynamicObstacleOpen then
        return
    end
    if self.tbTrapMsg[szTrapName] then
        me.CenterMsg(self.tbTrapMsg[szTrapName])
    end
    local tbPos = self.tbTrapInfo[szTrapName]
    if not tbPos then
        return
    end
    me.SetPosition(unpack(tbPos))
end

function tbMap:OnEnter()
    local nHour = Lib:GetLocalDayHour()
    if (not WuLinDaShi:GetMapCurInfo()) or (nHour >= WuLinDaShi.DAYEND and nHour < WuLinDaShi.DAYBEGIN) then
        me.GotoEntryPoint()
        return
    end
    WuLinDaShi:RefreshObstacle()
end

function WuLinDaShi:IsMyMap(nMapTID)
    return nMapTID == self.MAP_ID
end