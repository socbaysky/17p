local DanceMatch = Activity.DanceMatch;
local tbSetting = DanceMatch.tbSetting

DanceMatch.tbMapInst = DanceMatch.tbMapInst or {} --放的是实际实例
DanceMatch.tbInGamePlayers = DanceMatch.tbInGamePlayers or {};

function DanceMatch:OnActInit( tbActInst )
    RankBoard:ClearRank(tbSetting.szRankboardKey)
end

function DanceMatch:OnActStart( tbActInst )
    self.tbActInst = tbActInst
    self:SetupMapCallback()
end

function DanceMatch:EndAct()
    self.tbActInst = nil
    local pRank = KRank.GetRankBoard(tbSetting.szRankboardKey)
    pRank.Rank()

    local nFrom = 1
    local szTitle = tbSetting.szActName .. "排名奖励"
    for i,v in ipairs(tbSetting.tbFinnalAwardSetting) do
        for nPos = nFrom, v.nRankEnd do
            local tbInfo = pRank.GetRankInfoByPos(nPos - 1);
            if tbInfo then
                Mail:SendSystemMail({
                    To = tbInfo.dwUnitID,
                    Title = szTitle,
                    Text = string.format(tbSetting.szFianalMailContent, tbInfo.szValue, nPos),
                    tbAttach = v.tbAward,
                    nLogReazon = Env.LogWay_DanceAct;
                });
            else
                break;
            end
        end
        nFrom = v.nRankEnd + 1
    end
end


function DanceMatch:StartMatchSignUp()
    self:StopSignUp() 
    CreateMap(tbSetting.READY_MAP_ID);
end

function DanceMatch:StopSignUp()
    if self.nReadyMapId then
        local tbPlayers = KPlayer.GetMapPlayer(self.nReadyMapId)
        for i,pPlayer in ipairs(tbPlayers) do
            pPlayer.GotoEntryPoint()
        end
        self.nReadyMapId = nil
        Calendar:OnActivityEnd(tbSetting.szCalendarKey)
    end
    if self.nTimerBeginMatch then
        Timer:Close(self.nTimerBeginMatch)
        self.nTimerBeginMatch = nil;
    end
    if self.nActiveTimerReady then
        Timer:Close(self.nActiveTimerReady)
        self.nActiveTimerReady = nil;
    end
end

function DanceMatch:BeginMatch()
    local tbPlayers = KPlayer.GetMapPlayer(self.nReadyMapId) 
    local tbSortPlayers = {};
    for i,v in ipairs(tbPlayers) do
        table.insert(tbSortPlayers, {dwID = v.dwID, dwKinId = v.dwKinId })
    end
    table.sort( tbSortPlayers, function (a, b)
        return a.dwKinId < b.dwKinId --优先排有家族的最后面的
    end )
    local nCreateMapNum = math.ceil(#tbSortPlayers / self.tbSetting.nMatchPlayerNum)
    local nPerMapPlayerNum = math.floor(#tbSortPlayers / nCreateMapNum) 
    --前面的都按顺序给，后面多的就按顺序放到分配里
    local tbMapIds = {};
    for i=1,nCreateMapNum do
        local nMapId = CreateMap(self.tbSetting.FIGHT_MAP_ID);
        table.insert(tbMapIds, nMapId)
        self.tbInGamePlayers[nMapId] = {}; 
        for j=1,nPerMapPlayerNum do
            local v = table.remove(tbSortPlayers)
            table.insert(self.tbInGamePlayers[nMapId], v.dwID)
        end
    end
    for i,v in ipairs(tbSortPlayers) do
        local nMapIndex = i % nCreateMapNum + 1;
        local nMapId = tbMapIds[nMapIndex]
        table.insert(self.tbInGamePlayers[nMapId], v.dwID)
    end
end

function DanceMatch:UpdateReadyMapInfo()
    if self.bChangePlayerNum then
        self.bChangePlayerNum = nil;
        local nTime = math.floor(Timer:GetRestTime(self.nTimerBeginMatch) / Env.GAME_FPS);
        local szNumInfo = string.format("%d / %d", self.nTotalPlayerNum, self.tbSetting.nMatchPlayerNum)
        KPlayer.MapBoardcastScript(self.nReadyMapId , "Ui:DoLeftInfoUpdate", {nTime, szNumInfo})
    end
    return true
end

function DanceMatch:UpdateReadyMapLeftInfo(pPlayer)
    local nTime = math.floor(Timer:GetRestTime(self.nTimerBeginMatch) / Env.GAME_FPS);
    pPlayer.CallClientScript("Battle:EnterReadyMap", "DanceMatch", {nTime, string.format("%d / %d", self.nTotalPlayerNum, self.tbSetting.nMatchPlayerNum)})
end

function DanceMatch:OnLoginReadyMap()
    self:UpdateReadyMapLeftInfo(me)
end

function DanceMatch:OnReadyMapCreate(nMapId)
    self.nTimerBeginMatch = Timer:Register(Env.GAME_FPS * tbSetting.SIGNUP_TIME, function ()
        DanceMatch:BeginMatch()
        DanceMatch:StopSignUp()
    end);

    self.nActiveTimerReady =  Timer:Register(Env.GAME_FPS * 3, self.UpdateReadyMapInfo, self)

    self.nReadyMapId = nMapId
    self.nTotalPlayerNum = 0;
    KPlayer.SendWorldNotify(tbSetting.nMinLevel, 999, tbSetting.MsgNotifySignUp, 1, 1)
    local tbMsgData = {
        szType = "StartDanceMatch";
        nTimeOut = GetTime() + tbSetting.SIGNUP_TIME;
    };

    KPlayer.BoardcastScript(tbSetting.nMinLevel, "Ui:SynNotifyMsg", tbMsgData);
    Calendar:OnActivityBegin(tbSetting.szCalendarKey)
    KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
end

function DanceMatch:PlayerSignUp(pPlayer)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        pPlayer.CenterMsg("目前状态不允许切换地图")
        return
    end
    if not self.nReadyMapId then
        pPlayer.CenterMsg("现在没有舞林大会")
        return
    end
    local tbActInst = self.tbActInst
    if not tbActInst then
        return
    end
    if pPlayer.nLevel < self.tbSetting.nMinLevel then
        pPlayer.CenterMsg(string.format("需要%d级才能参加", self.tbSetting.nMinLevel))
        return
    end
    local tbActData = tbActInst:GetDataFromPlayer(pPlayer.dwID)
    if tbActData and tbActData.nLastPlayDay == Lib:GetLocalDay() and tbActData.nToDayCount >= self.tbSetting.nEveryDayPlayerTimes then
        pPlayer.CenterMsg(string.format("一天只能参与%d次", self.tbSetting.nEveryDayPlayerTimes) )
        return
    end
    if tbActData and tbActData.nTotalPlayerCount and tbActData.nTotalPlayerCount >= self.tbSetting.nTotalPlayTimes then
        pPlayer.CenterMsg(string.format("最多参与%d次", self.tbSetting.nTotalPlayTimes))
        return
    end
    
    pPlayer.SetEntryPoint()
    local READY_MAP_POS = self.tbSetting.READY_MAP_POS
    pPlayer.SwitchMap(self.nReadyMapId, unpack(READY_MAP_POS[MathRandom(#READY_MAP_POS)]) )
end

function DanceMatch:OnEnterReadyMap(  )
    me.nCanLeaveMapId = self.nReadyMapId
    self.nTotalPlayerNum = self.nTotalPlayerNum + 1;
    self.bChangePlayerNum = true
    self:UpdateReadyMapLeftInfo(me)
end

function DanceMatch:OnLeaveReadyMap()
    self.nTotalPlayerNum = self.nTotalPlayerNum - 1;
    self.bChangePlayerNum = true
end

function DanceMatch:OnBattleMapCreate(nMapId)
    local tbInst = Lib:NewClass(DanceMatch.DanceMapLogic)
    self.tbMapInst[nMapId] = tbInst
    local tbPlayerIds = self.tbInGamePlayers[nMapId]
    tbInst:Init(nMapId, tbPlayerIds);

    local nToDay = Lib:GetLocalDay()
    local tbActInst = self.tbActInst
    for i, dwRoleId in ipairs(tbPlayerIds) do
        local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
        if pPlayer then
            if pPlayer.dwTeamID ~= 0 then
                TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
            end
            pPlayer.SwitchMap(nMapId, 0, 0)
            local tbActData = tbActInst:GetDataFromPlayer(pPlayer.dwID) or {}
            if tbActData.nLastPlayDay == nToDay then
                tbActData.nToDayCount = tbActData.nToDayCount + 1
            else
                tbActData.nLastPlayDay = nToDay
                tbActData.nToDayCount = 1
            end
            tbActData.nTotalPlayerCount = (tbActData.nTotalPlayerCount or 0) + 1;
            tbActInst:SaveDataToPlayer(pPlayer, tbActData)            
            pPlayer.CallClientScript("Activity:OnSyncActivityCustomInfo", self.tbActInst.szKeyName, tbActData)
        end
    end

    tbInst:Start();
end

function DanceMatch:OnBattleMapDestory(nMapId)
    self.tbInGamePlayers[nMapId] = nil;
    if self.tbMapInst[nMapId] then
        self.tbMapInst[nMapId]:OnMapDestroy();
        self.tbMapInst[nMapId] = nil;
    end
end

local tbInferFace = {
    PlayerSignUp = 1;
    CommitDanceCMD = 1;

}

function DanceMatch:CommitDanceCMD(pPlayer, szDanceCmd)
    local tbInst = self.tbMapInst[pPlayer.nMapId]
    if not tbInst then
        return
    end
    tbInst:CommitDanceCMD(pPlayer, szDanceCmd)
end

function DanceMatch:DanceActRequest(pPlayer, szFunc, ...)
    if not tbInferFace[szFunc] then
        return
    end
    self[szFunc](self, pPlayer, ...)
end

function DanceMatch:SetupMapCallback()
    local fnOnCreate = function (tbMap, nMapId)
        self:OnReadyMapCreate(nMapId)
    end

    local fnOnEnter = function (tbMap, nMapId)
        self:OnEnterReadyMap(nMapId)
    end

    local fnOnLeave = function (tbMap, nMapId)
        self:OnLeaveReadyMap(nMapId)
    end

    local fnOnMapLogin = function (tbMap, nMapId)
        self:OnLoginReadyMap(nMapId)
    end

    local tbMapClass = Map:GetClass(tbSetting.READY_MAP_ID)
    assert(tbMapClass.OnCreate == fnOnCreate or tbMapClass.OnCreate == Map.tbMapBase.OnCreate)
    tbMapClass.OnCreate = fnOnCreate;
    tbMapClass.OnEnter = fnOnEnter;
    tbMapClass.OnLeave = fnOnLeave;
    tbMapClass.OnLogin = fnOnMapLogin;

    local fnOnCreate = function (tbMap, nMapId)
        self:OnBattleMapCreate(nMapId)
    end

    local fnOnDestory = function (tbMap, nMapId)
        self:OnBattleMapDestory(nMapId)
    end

    local fnOnEnter = function (tbMap, nMapId)
        local tbInst = self.tbMapInst[nMapId]
        if tbInst then
            tbInst:OnEnter()
        end
    end

    local fnOnLeave = function (tbMap, nMapId)
        local tbInst = self.tbMapInst[nMapId]
        if tbInst then
            tbInst:OnLeave()
        end
    end

    local fnOnMapLogin = function (tbMap, nMapId)
        local tbInst = self.tbMapInst[nMapId]
        if tbInst then
            tbInst:OnLogin()
        end
    end

    local tbMapClass = Map:GetClass(tbSetting.FIGHT_MAP_ID)
    assert(tbMapClass.OnCreate == fnOnCreate or tbMapClass.OnCreate == Map.tbMapBase.OnCreate)
    tbMapClass.OnCreate = fnOnCreate;
    tbMapClass.OnEnter = fnOnEnter;
    tbMapClass.OnLeave = fnOnLeave;
    tbMapClass.OnLogin = fnOnMapLogin;
end