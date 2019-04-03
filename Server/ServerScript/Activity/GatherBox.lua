local tbAct = Activity:GetClass("GatherBox")

tbAct.tbTrigger = {
    Init    = { },
    Start   = { },
    End     = { },
}

tbAct.tbRefreshTime = {1.5, 7.5, 9.5}
tbAct.tbCreateBoxCount = {
{10, 1},
{40, 3},
{70, 6},
{100, 9},
{130, 12},
{9999, 20},
}
tbAct.nBoxTemplateId = 1840
tbAct.nGroup = 60
tbAct.nDataDay = 1
tbAct.nTimes = 2
tbAct.nCanOpenTimes = 10
tbAct.tbPos = {
    {4657,3766},
    {4922,5011},
    {5311,3529},
    {5740,3611},
    {4246,4752},
    {4300,4310},
    {4205,3548},
    {5955,4796},
    {6132,4278},
    {6034,3946},
    {4325,5428},
    {4025,5077},
    {5074,5450},
    {5456,5437},
    {5800,5279},
    {3892,4537},
    {3911,4205},
    {4600,4038},
    {4764,4632},
    {5099,4708},
    {5140,3823},
    {3943,3744},
    {4306,3924},
    {5545,3867},
    {5627,4231},
    {4600,5254},
    {4663,5602},
    {5263,5728},
    {4158,5794},
    {3934,5542},
    {5775,5750},
    {3665,3915},
    {3580,4335},
    {3513,4689},
    {3637,3567},
    {4913,3425},
    {6217,3738},
    {6448,4158},
    {5898,4509},
    {5510,4597},
    {5475,4979},
    {4818,5940},
    {6454,4572},
}

function tbAct:OnTrigger(szTrigger)
    local nStartTime, nEndTime = self:GetOpenTimeInfo()
    if Activity:IsBeCloseBySameTypeAct(self.szType, self.szKeyName, nStartTime) then
        return
    end

    if not self.bCheck then
        local bRet = Activity:AddTime2SameTypeAct(self.szType, self.szKeyName)
        if not bRet then
            return
        end
        self.bCheck = true
    end

    if szTrigger == "Start" then
        Activity:RegisterGlobalEvent(self, "Act_KinGather_Open", "OnKinGatherBebin")
        Activity:RegisterGlobalEvent(self, "Act_KinGather_Close", "OnKinGatherStop")
        Activity:RegisterPlayerEvent(self, "Act_TryOpenGatherBox", "TryOpenGatherBox")
        Log("GatherBox Begin", self.szKeyName)
    end
end

function tbAct:OnKinGatherBebin()
    self.tbBoxNpc = self.tbBoxNpc or {}
    self:ClearNpc()
    if self.nCreateBoxTimer then
        Timer:Close(self.nCreateBoxTimer)
    end

    self.nCreateBoxTimer = Timer:Register(Env.GAME_FPS * 60 * self.tbRefreshTime[1], self.OnTime2CreateBox, self, 1)
    Log("GatherBox OnKinGatherBebin")
end

function tbAct:OnTime2CreateBox(nTimeIdx)
    Kin:TraverseKinInDiffTime(1, function (kinData)
        self:CreateBox(kinData.nKinId)
    end);

    nTimeIdx = nTimeIdx + 1
    if not self.tbRefreshTime[nTimeIdx] then
        self.nCreateBoxTimer = nil
        Log("GatherBox DayClose")
        return
    end

    local nTime = self.tbRefreshTime[nTimeIdx] - self.tbRefreshTime[nTimeIdx - 1]
    self.nCreateBoxTimer = Timer:Register(Env.GAME_FPS * 60 * nTime, self.OnTime2CreateBox, self, nTimeIdx)
    Log("GatherBox OnTime2CreateBox")
end

function tbAct:CreateBox(nKinId)
    local kinData = Kin:GetKinById(nKinId)
    if not kinData then
        return
    end
    local nMapId = kinData:GetMapId()
    if not nMapId then
        return
    end

    local tbPlayer, nPlayerCount = KPlayer.GetMapPlayer(nMapId)
    local nCreateNpcCount = nPlayerCount * 3
    for i = 1, nCreateNpcCount do
        local tbPos = self.tbPos[MathRandom(#self.tbPos)]
        local nX, nY = unpack(tbPos)
        local pNpc = KNpc.Add(self.nBoxTemplateId, 1, 0, nMapId, nX, nY)
        table.insert(self.tbBoxNpc, pNpc.nId)
    end

    KPlayer.MapBoardcastScript(nMapId, "Ui:OpenWindow", "GatherBoxAnimation")
    local szMsg = "帮派总管：诸位帮派弟兄，庆典宝箱已经运到，天下武功，唯快不破！诸位弟兄！此刻不动手，更待何时！"
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, kinData.nKinId)
    Log("GatherBox CreateBox", nKinId, nCreateNpcCount)
end

function tbAct:OnKinGatherStop()
    self.tbBoxNpc = self.tbBoxNpc or {}
    Timer:Register(Env.GAME_FPS * 60 * 3, self.ClearNpc, self)
end

function tbAct:ClearNpc()
    if #self.tbBoxNpc == 0 then
        return
    end

    for _, nId in ipairs(self.tbBoxNpc) do
        local pNpc = KNpc.GetById(nId)
        if pNpc then
            pNpc.Delete()
        end
    end
    self.tbBoxNpc = {}
    Log("GatherBox Today Act Close Delete Npc")
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

    return nOpenTimes < self.nCanOpenTimes, string.format("每天只能打开%d个%s", self.nCanOpenTimes, pNpc.szName)
end

function tbAct:TryOpenGatherBox(pPlayer, pBox)
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
        Log("GatherBox Award Error")
        return
    end

    local nDataDay = pPlayer.SetUserValue(self.nGroup, self.nDataDay, Lib:GetLocalDay())
    local nOpenTimes = pPlayer.GetUserValue(self.nGroup, self.nTimes)
    pPlayer.SetUserValue(self.nGroup, self.nTimes, nOpenTimes + 1)
    pPlayer.SendAward({{"Item", nRandomItemId, 1}}, false, true, Env.LogWay_GatherBox)
    Activity:OnPlayerEvent(pPlayer, "Act_OnOpenGatherBox")
end

tbAct.tbNewInfo = {
    GatherBox = function (self)
        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local nStartDay = Lib:GetLocalDay(nStartTime)
        local nEndDay = Lib:GetLocalDay(nEndTime)
        local nMaxLevel = self.tbParam[1]
        local szContent = string.format("[FFFE0D]等级上限开放庆典[-]\n    诸位侠士，如今%d级已然开放，诸位可通过新活动多加磨练，将武艺修炼至登峰造极，早日功成名就。\n    值此欢盛之际，%d天内的帮派烤火都将举行欢庆，届时帮派地图将刷新大量庆典宝箱，烤火答题前刷新一波，答题後刷新两波，拾取者将获得大量奖励，可莫要忘记参与！天下武功，唯快不破！速速去抢夺宝箱吧！\n    另传闻西域行商贾有钱西行归来，将会在拍卖行[FFFE0D]停留3天[-]，[FFFE0D]每天19:05[-]开设专场拍卖。届时将竞拍[FFFE0D]各类稀有珍品[-]，诸位侠士们可不要错过哦！", nMaxLevel, nEndDay - nStartDay)
        return {szTitle = string.format("%d级开放庆典", nMaxLevel), nReqLevel = 10, szContent = szContent}
    end,
    --ServerCelebration = function (self)
    --    local _, nEndTime = self:GetOpenTimeInfo()
    --    local nMonthDay = Lib:GetMonthDay(nEndTime - 1)
    --    local szContent = string.format("[FFFE0D]迎资料片江湖狂欢[-]\n    诸位侠士，如今江湖即将迎来重大变革，武林中诸多家族将开启庆典，共襄盛举。\n    值此欢盛之际，各大家族的家族烤火都将举行欢庆，届时家族地图将刷新大量庆典宝箱，烤火答题前刷新一波，答题后刷新两波，拾取者将获得大量奖励，可莫要忘记参与！天下武功，唯快不破！速速去抢夺宝箱吧！", nMonthDay)
    --    return {szTitle = "迎资料片江湖狂欢", nReqLevel = 10, szContent = szContent}
    --end,
}
function tbAct:GetUiData()
    for szKey, fn in pairs(self.tbNewInfo) do
        if string.find(self.szKeyName, szKey) then
            return fn(self)
        end
    end
end