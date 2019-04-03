Require("ServerScript/QunYingHuiCross/QYHCrossZ.lua")
local tbQunYingHuiZ = QunYingHuiCross.tbQunYingHuiZ
local tbPreMapLogic = tbQunYingHuiZ.tbPreMapLogic

function tbPreMapLogic:OnCreate(nMapId, szTimeFrame)
	self.nMapId = nMapId
    self.szTimeFrame = szTimeFrame
    self.tbOldTeamInfo = {}
    self.tbOldTeamMembers = {}
    self.tbPlayer = {}                                 -- 所有玩家信息[dwID] = {}
    self.tbFightMapPlayer = {}                         -- [nMapId] = tbPlayer
    self.tbFightMapLogic = {}                          -- [nMapId] = tbFightLogic
    self.tbRank = {}                                   -- 排行榜
    self.tbSynRank = {}                                -- 同步客户端最多只会同步前QunYingHuiCross.nShowRankNum
    self.tbPlayer2Rank = {}                            -- 玩家对应排名
    self.tbPlayerData = {}                             -- 玩家先行信息
    self.tbPlayerStandByFaction = {}                   -- 玩家可选的门派(以玩家id或者队伍id为key)，主要用来同一玩家或者同一队伍已经随好门派就不再随了,[dwID/nTeamId] = tbFaction
    self.tbChosedFaction = {}                          -- 各门派已选的数量,[nFaction] = nCount
    self.tbAllChooseFactionTimer = {}                  -- [dwID] = nTimerID 选门派倒计时，跟着玩家走,组队玩家各记录一份，ID相同
    self.tbPlayerRequestRank = {}                      -- 玩家请求排行数据[dwID] = GetTime()
    self.tbZonePlayerRef = {}                          -- 跨服玩家ID映射
    self.nActiveCount = 0                              -- 定时器计数
    self.nWarnCount = 0                                -- 未匹配状态提示计数
    self.bPlayerDataChange = nil                       -- 玩家数据改变(新玩家进入或者玩家刚打完)
    self.nStartMatch = QunYingHuiCross.MATCH_NONE      -- 匹配状态
    self:CloseActiveTimer()
    self:CloseSynRankTimer()
    self.nActiveTimerId = Timer:Register(Env.GAME_FPS, self.OnActive, self)
    self.nSynRankTimerId = Timer:Register(1, self.OnSynRank, self)
    self:ExecuteSchedule()
    self.fnEnterPos = Lib:GetRandomSelect(#QunYingHuiCross.tbPreMapEnterPos)
    -- -1 广播
    CallZoneClientScript(-1, "QunYingHuiCross:OnZoneCallBack", "OnPreMapReady", nMapId)
    self:Log("fnOnCreateLogic")
end

function tbPreMapLogic:OnSynRank()
    local nSyn = 0
    for dwID in pairs(self.tbPlayerRequestRank or {}) do
        if nSyn >= 50 then
            break
        end
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            self:SynRankData(pPlayer)
        end
        self.tbPlayerRequestRank[dwID] = nil 
        nSyn = nSyn + 1
    end
    return true
end

function tbPreMapLogic:GetEnterPos()
    return QunYingHuiCross.tbPreMapEnterPos[self.fnEnterPos()]
end

function tbPreMapLogic:ExecuteSchedule()
    self.nMainTimer = nil;
    self.nSchedulePos = (self.nSchedulePos or 0) + 1
    local tbCurSchedule = QunYingHuiCross.PRE_STATE_TRANS[self.nSchedulePos]
    if not tbCurSchedule then
        return
    end
    self:Log("fnExecuteSchedule", self.nSchedulePos, tbCurSchedule.nSeconds or 0, tbCurSchedule.nType or "nil")
    self.nStateInfo = tbCurSchedule.nType;
    self[tbCurSchedule.szFunc](self)
    if tbCurSchedule.nSeconds < 0 then
        return
    end
    if not QunYingHuiCross.PRE_STATE_TRANS[self.nSchedulePos + 1] then --后面没有timer 就断了
        self.nMainTimer = nil
        return;
    end
    self.nMainTimer = Timer:Register(Env.GAME_FPS * tbCurSchedule.nSeconds, self.ExecuteSchedule, self)
    self:ForeachMapPlayer(self.UpdatePlayerUi)
end

function tbPreMapLogic:WaitMatch()
    self:ForeachMapPlayer(self.UpdatePlayerUi)
end

function tbPreMapLogic:StartMatch()
    self:OnStartMatch()
    self:ForeachMapPlayer(self.UpdatePlayerUi)
end

function tbPreMapLogic:StopMatch()
    self:OnStopMatch()
    self:ForeachMapPlayer(self.UpdatePlayerUi)
end

function tbPreMapLogic:EndAct()
    self:OnEnd()
    local fnSynData = function (self, pPlayer)
        local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
        self:DoRequestMatchData(pPlayer, {tbGetWinAwardFlag = tbPlayerInfo.tbGetWinAwardFlag, tbGetJoinAwardFlag = tbPlayerInfo.tbGetJoinAwardFlag})
        self:UpdatePlayerUi(pPlayer)
    end
    self:ForeachMapPlayer(fnSynData)
end

function tbPreMapLogic:KickOutPlayer()
    local fnKickOut = function (self, pPlayer)
        pPlayer.ZoneLogout();
    end
    self:ForeachMapPlayer(fnKickOut)

    for nMapId in pairs(self.tbFightMapLogic) do
        local tbPlayer = KPlayer.GetMapPlayer(nMapId) or {}
        for _, pPlayer in ipairs(tbPlayer) do
            pPlayer.ZoneLogout();
        end
    end
    self:CloseSynRankTimer()
end

function tbPreMapLogic:ForeachMapPlayer(fnFunc, ...)
    local tbMapPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbMapPlayer or {}) do
        Lib:CallBack({fnFunc, self, pPlayer, ...});
    end
end


function tbPreMapLogic:OnActive()
    self.nActiveCount = self.nActiveCount + 1
    if self.nStartMatch == QunYingHuiCross.MATCH_OPEN then
        if  self.nActiveCount % QunYingHuiCross.nMatchTime == 0 then
            Lib:CallBack({self.MatchTeammate, self});
            Lib:CallBack({self.MatchFightTeam, self});
        end
        self.nWarnCount = self.nWarnCount + 1
        if self.nWarnCount % QunYingHuiCross.nNotMatchWarnTime == 0 then
            self.nWarnCount = 0
            Lib:CallBack({self.WarnTip, self});
        end
    end
    if self.nActiveCount % QunYingHuiCross.nRankRefreshTime == 0 then
        self:TryRefreshRank()
    end
    return true
end

function tbPreMapLogic:TryEnterMatchState(pPlayer, bCheck)
    if self.nStartMatch == QunYingHuiCross.MATCH_OPEN then
        pPlayer.CallClientScript("Ui:OpenWindow", "QYHMatchingPanel")
        if bCheck then
            self:DoJoinMatch(pPlayer)
        else
            self:EnterMatchState(pPlayer)
        end
    end
end

function tbPreMapLogic:OnStartMatch()
    self.nStartMatch = QunYingHuiCross.MATCH_OPEN
    local fnStartMatch = function (self, pPlayer)
        local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
         if tbPlayerInfo.nFaction > 0 and tbPlayerInfo.nType ~= QunYingHuiCross.TYPE_NONE then
            self:TryEnterMatchState(pPlayer)
        end
    end
    self:ForeachMapPlayer(fnStartMatch)
    self:Log("fnOnStartMatch")
end

function tbPreMapLogic:OnStopMatch()
    self.nStartMatch = QunYingHuiCross.MATCH_CLOSE
    local fnStopMatch = function (self, pPlayer)
        self:DoCancelMatch(pPlayer.dwID)
        self:DoRequestMatchData(pPlayer, {nState = QunYingHuiCross.STATE_NONE})
        pPlayer.CallClientScript("Ui:OpenWindow", "SystemNotice", QunYingHuiCross.szStopMatchNotice)
        pPlayer.Msg(QunYingHuiCross.szStopMatchNotice)
    end
    self:ForeachMapPlayer(fnStopMatch)
end

function tbPreMapLogic:OnEnd()
    local nNowTime = GetTime()
    CallZoneClientScript(-1, "QunYingHuiCross:OnZoneCallBack", "OnActEnd")
    self.nStartMatch = QunYingHuiCross.MATCH_END
    self:CloseActiveTimer()
    self:DoRefreshRank(true)
    local tbServerPlayer = {}
    local tbNewInfoData = {}
    -- 每50个数据发送一次
    local nSynCountPerTime = 50
    for nUniqId, v in pairs(self.tbPlayer) do
        local tbAllAward = {}
        local tbHandAward = {}
        local nWinCount = v.nWinCount
        local nFightCount = v.nFightCount
        local nLostCount = nFightCount - nWinCount
        local tbGetWinAwardFlag = v.tbGetWinAwardFlag
        local tbGetJoinAwardFlag = v.tbGetJoinAwardFlag
        local nServerId = v.nServerId
        local nConnectIdx = self:GetConnectIdx(v)
        if nConnectIdx then
            tbServerPlayer[nConnectIdx] = tbServerPlayer[nConnectIdx] or {}
            if nWinCount > 0 then
                Lib:MergeTable(tbAllAward, QunYingHuiCross:GetTimesAward(QunYingHuiCross.tbFightWinAward, nWinCount))
            end
            if nLostCount > 0 then
                Lib:MergeTable(tbAllAward, QunYingHuiCross:GetTimesAward(QunYingHuiCross.tbFightLostAward, nLostCount))
            end
            local nRank = self.tbPlayer2Rank[nUniqId]
            if nRank then
                local tbRankAward = QunYingHuiCross:RankReward(nRank)
                -- 有排名奖励就给排名奖励没有就给安慰奖
                if next(tbRankAward) then
                    Lib:MergeTable(tbAllAward, tbRankAward)
                else
                    Lib:MergeTable(tbAllAward, QunYingHuiCross.tbJoinAVAward)
                end
            end
            -- n胜奖励
            for nId, j in ipairs(QunYingHuiCross.tbWinAward) do
                if not tbGetWinAwardFlag[nId] and nWinCount >= j.nCount then
                    Lib:MergeTable(tbHandAward, j.tbAward)
                    tbGetWinAwardFlag[nId] = nNowTime
                end
            end
            -- n战奖励
            for nId, k in ipairs(QunYingHuiCross.tbJoinAward) do
                if not tbGetJoinAwardFlag[nId] and nFightCount >= k.nCount then
                    Lib:MergeTable(tbHandAward, k.tbAward)
                    tbGetJoinAwardFlag[nId] = nNowTime
                end
            end
            local nOrgPlayerId =  QunYingHuiCross:RestoreUniqId(nUniqId)
            table.insert(tbServerPlayer[nConnectIdx], {dwID = nOrgPlayerId, nRank = nRank, nWinCount = nWinCount, nLostCount = nLostCount, tbAllAward = tbAllAward, tbHandAward = tbHandAward})
            if #tbServerPlayer[nConnectIdx] >= nSynCountPerTime then
                CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnSendEndAward", tbServerPlayer[nConnectIdx])
                tbServerPlayer[nConnectIdx] = {}
            end
        else
            self:Log("fnOnEnd no ConnectIdx", nServerId, nUniqId, nWinCount, nFightCount, nLostCount)
        end
    end

    -- 发送剩余玩家奖励
    for nConnectIdx, tbServerPlayer in pairs(tbServerPlayer) do
        if next(tbServerPlayer) then
            CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnSendEndAward", tbServerPlayer)
        end
    end

    -- 第n名世界公告
    for _, v in ipairs(QunYingHuiCross.tbRankNotify) do
        local tbPlayerRank = self.tbRank[v.nRank]
        if tbPlayerRank then
            local nUniqId = tbPlayerRank.nUniqId or 0
            local szName = self:GetPlayer(nil, nUniqId).szName
            if not Lib:IsEmptyStr(szName) then
                local tbData = {szName = szName}
                CallZoneClientScript(-1, "QunYingHuiCross:OnZoneCallBack", "OnRankNotify", v.nRank, tbData)
            else
                self:Log("RankNotify no StayInfo", nUniqId)
            end
        end
    end

    -- 前n名家族公告
    for nRank = 1, QunYingHuiCross.nRankKinMsg do
        local tbPlayerRank = self.tbRank[nRank]
        if tbPlayerRank then
            local tbPlayerInfo = self:GetPlayer(nil, tbPlayerRank.nUniqId)
            local nConnectIdx = self:GetConnectIdx(tbPlayerInfo)
            if nConnectIdx then
                local nOrgPlayerId =  QunYingHuiCross:RestoreUniqId(tbPlayerRank.nUniqId)
                CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnRankKinMsg", nOrgPlayerId, nRank)
            else
                self:Log("RankKinMsg no nConnectIdx", tbPlayerRank.nUniqId)
            end
        end
    end
    -- 最新消息
    for nRank = 1, QunYingHuiCross.nNewInfoShowRank do
        local tbPlayerRank = self.tbRank[nRank]
        if tbPlayerRank then
            local nUniqId = tbPlayerRank.nUniqId or 0
            local szName = self:GetPlayer(nil, nUniqId).szName
            local nZonePlayerId =  self:GetZonePlayerId(nUniqId)
            if not Lib:IsEmptyStr(szName) then
                local nFightPower = 0
                -- 待确定
                local pAsync = KPlayer.GetAsyncData(nZonePlayerId)
                if pAsync then
                    nFightPower = pAsync.GetFightPower()
                end
                local tbPlayerInfo = self:GetPlayer(nZonePlayerId)
                local nWinCount = tbPlayerInfo.nWinCount or 0
                local nFightCount = tbPlayerInfo.nFightCount or 0
                local nFightTime = tbPlayerInfo.nFightTime or 0
                local szKinName = tbPlayerInfo.szKinName or "-"
                -- 等级显示胜率， 战力显示战斗时长
                local szWinRate = string.format("%s/%s(%s)", nWinCount, nFightCount, string.format("%.2f%%", (nFightCount == 0 and 0 or (nWinCount / nFightCount * 100))))
                local szFightTime = Lib:TimeDesc3(nFightTime)
                local nOrgPlayerId =  QunYingHuiCross:RestoreUniqId(nUniqId)
                table.insert(tbNewInfoData, {dwID = nOrgPlayerId, nFaction = tbPlayerInfo.nFaction, szName = szName, nLevel = szWinRate, nFightPower = szFightTime, szKinName = szKinName})
            end
        end
    end
    CallZoneClientScript(-1, "QunYingHuiCross:OnZoneCallBack", "OnSendNewInfomation", tbNewInfoData)
    self:Log("fnOnEnd")
end

function tbPreMapLogic:TryRefreshRank()
    if not self.bPlayerDataChange then
        return 
    end
    self:DoRefreshRank()
end

function tbPreMapLogic:DoRefreshRank(bAll)
    local tbAllPlayer = {}
    for nUniqId,v in pairs(self.tbPlayer) do
        -- 选完门派才能进排名
        if v.nFaction > 0 then
            table.insert(tbAllPlayer, {nUniqId = nUniqId; nWinCount = v.nWinCount; nWinRate = v.nWinRate, nFightCount = v.nFightCount, nFightTime = v.nFightTime, nGetRateTime = v.nGetRateTime, nFirstEnterTime = v.nFirstEnterTime})
        end
    end
    local fnSort = function (a,b)
        if a.nWinCount == b.nWinCount then
            if a.nWinRate == b.nWinRate then
                if a.nFightTime == b.nFightTime then
                    if a.nGetRateTime == b.nGetRateTime then
                        local pPlayer1 = KPlayer.GetPlayerObjById(self:GetZonePlayerId(a.nUniqId))
                        local pPlayer2 = KPlayer.GetPlayerObjById(self:GetZonePlayerId(b.nUniqId))
                        if pPlayer1 and pPlayer2 and pPlayer1.dwTeamID > 0 and pPlayer2.dwTeamID > 0 and pPlayer1.dwTeamID == pPlayer2.dwTeamID then
                            local tbTeam = TeamMgr:GetTeamById(pPlayer1.dwTeamID)
                            if tbTeam then
                                local nCaptainId = tbTeam:GetCaptainId();
                                if pPlayer1.dwID == nCaptainId then
                                    return true
                                end
                            end
                        end
                        return a.nFirstEnterTime < b.nFirstEnterTime
                    end
                    return a.nGetRateTime < b.nGetRateTime
                end
                return a.nFightTime < b.nFightTime
            end
            return a.nWinRate > b.nWinRate
        end
        return a.nWinCount > b.nWinCount
    end
    table.sort(tbAllPlayer, fnSort)
    local nMaxRankShow = bAll and #tbAllPlayer or QunYingHuiCross.nShowRankNum
    for nRank = 1, nMaxRankShow do
        if tbAllPlayer[nRank] then
            self.tbRank[nRank] = tbAllPlayer[nRank]
            self.tbPlayer2Rank[tbAllPlayer[nRank].nUniqId] = nRank
            if nRank <= QunYingHuiCross.nShowRankNum then
                self.tbSynRank[nRank] = tbAllPlayer[nRank]
            end
        end
    end
end

function tbPreMapLogic:GetSynRankData(nZonePlayerId)
    local nUniqId = self:GetUniqID(nZonePlayerId)
   return self.tbSynRank, self.tbPlayer2Rank[nUniqId]
end

function tbPreMapLogic:WarnTip()
    local nNowTime = GetTime()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId) or {};
    local fnOk = function (dwID)
        local pP = KPlayer.GetPlayerObjById(dwID)
        if not pP then
           return
        end
        if self.nStartMatch ~= QunYingHuiCross.MATCH_OPEN then
            pP.CenterMsg("匹配阶段已结束", true)
            return
        end
        self:TryEnterMatchState(pP, true)
    end
    for _, pPlayer in ipairs(tbPlayer) do
        local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
        if tbPlayerInfo and tbPlayerInfo.nState ~= QunYingHuiCross.STATE_MATCHING 
            and tbPlayerInfo.nCancelMatchTime ~= 0 and (nNowTime - tbPlayerInfo.nCancelMatchTime) >= QunYingHuiCross.nNotMatchWarnTime 
            and not self:CheckMaxFight(pPlayer.dwID) then
            local _, nMin = Lib:TransferSecond2NormalTime(QunYingHuiCross.nNotMatchWarnTime)
            pPlayer.MsgBox(string.format("尊敬的侠士，您已%d分钟未进行对战匹配，这将影响您的[FFFE0D]最终排名[-]和[FFFE0D]奖励获取[-]，是否立即开启匹配？", nMin), {{"确定", fnOk, pPlayer.dwID}, {"取消"}})
        end
    end
end

-- 匹配队友
function tbPreMapLogic:MatchTeammate()
   local tbFactionWaitMatchTeammate = {}
   local tbPlayer = KPlayer.GetMapPlayer(self.nMapId) or {};
   self:DismissUnNormalTeam(tbPlayer)
   self:DismissMaxFightTeam(tbPlayer)
   for _, pPlayer in ipairs(tbPlayer) do
        local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
        if tbPlayerInfo and tbPlayerInfo.nState == QunYingHuiCross.STATE_MATCHING 
            and pPlayer.dwTeamID <= 0 and tbPlayerInfo.nFaction > 0 and tbPlayerInfo.nFightCount < QunYingHuiCross.nMaxFight then
            tbFactionWaitMatchTeammate[tbPlayerInfo.nFaction] = tbFactionWaitMatchTeammate[tbPlayerInfo.nFaction] or {}
            table.insert(tbFactionWaitMatchTeammate[tbPlayerInfo.nFaction], {dwID = pPlayer.dwID, nMatchTime = tbPlayerInfo.nMatchTime})
        end
   end
   -- 越早匹配越优先
   local fnSortByMatchTime = function (a, b)
        return a.nMatchTime < b.nMatchTime
   end
   -- 每个门派单独排序
   for nFaction, v in pairs(tbFactionWaitMatchTeammate) do
       if #v >= 2 then
          table.sort(v, fnSortByMatchTime)
       end
   end
   -- 每个排好序的门派玩家索引越靠前越优先
   local tbWaitMatchPlayer = {}
   for nFaction, tbFactionPlayer in pairs(tbFactionWaitMatchTeammate) do
        for i,v in ipairs(tbFactionPlayer) do
            v.nPriority = i
            table.insert(tbWaitMatchPlayer, v)
        end
   end
   -- 索引越小越优先
   local fnSortByPriority = function (a, b)
        return a.nPriority < b.nPriority
    end
    table.sort(tbWaitMatchPlayer, fnSortByPriority)
    local nStep = 0
    for i = 1, math.floor(#tbWaitMatchPlayer / 2) do
        if tbWaitMatchPlayer[i + nStep] and tbWaitMatchPlayer[i + nStep + 1] then
            self:CreateTempTeam({tbWaitMatchPlayer[i + nStep], tbWaitMatchPlayer[i + nStep +1]})
        end
        nStep = nStep + 1
    end
end

-- 将队伍中有一个人达到最大场数的队伍解散
function tbPreMapLogic:DismissMaxFightTeam(tbPlayer)
    for _, pPlayer in ipairs(tbPlayer) do
       self:DoDismissMaxFightTeam(pPlayer)
    end
end

-- 将队伍人数异常的队伍解散
function tbPreMapLogic:DismissUnNormalTeam(tbPlayer)
    for _, pPlayer in ipairs(tbPlayer) do
        local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
        if tbTeam then
            local tbMember = tbTeam:GetMembers()
            local nTeamCount = Lib:CountTB(tbMember);
             if nTeamCount ~= QunYingHuiCross.nFightPlayerNum then
                self:DoDismissTeam(pPlayer, string.format("由於您的队伍中的人数异常，已经自动解散队伍"), QunYingHuiCross.STATE_NONE)
            end
        end
    end
end

function tbPreMapLogic:CheckMaxFight(nPlayerId)
    local tbPlayerInfo = self:GetPlayer(nPlayerId)
    if tbPlayerInfo.nFightCount >= QunYingHuiCross.nMaxFight then
        return true
    end
    return false
end

function tbPreMapLogic:DoDismissMaxFightTeam(pPlayer)
    local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
    if tbTeam then
        if self:CheckMaxFight(pPlayer.dwID) then
            self:DoDismissTeam(pPlayer, string.format("由於队伍中的%s战斗场数达到%s场，已经自动解散队伍", pPlayer.szName, QunYingHuiCross.nMaxFight), QunYingHuiCross.STATE_NONE)
            return true
        end
    end
end

-- 匹配队伍
function tbPreMapLogic:MatchFightTeam()
    local tbSinglePlayer = {}               -- 单人类型组成队伍的玩家
    local tbTeamPlayer = {}                 -- 组队类型组成队伍的玩家
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId) or {};
    self:DismissMaxFightTeam(tbPlayer)
    for _, pPlayer in ipairs(tbPlayer) do
        local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
        if tbPlayerInfo and tbPlayerInfo.nState == QunYingHuiCross.STATE_MATCHING and pPlayer.dwTeamID > 0 
            and tbPlayerInfo.nFaction > 0  and tbPlayerInfo.nFightCount < QunYingHuiCross.nMaxFight then
            if tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE then
                tbSinglePlayer[pPlayer.dwTeamID] = tbSinglePlayer[pPlayer.dwTeamID] or {}
                table.insert(tbSinglePlayer[pPlayer.dwTeamID], {dwID = pPlayer.dwID, nWinRate = tbPlayerInfo.nWinRate, nFightTime = tbPlayerInfo.nFightTime, tbNearFight = tbPlayerInfo.tbNearFight})
            elseif tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM then
                tbTeamPlayer[pPlayer.dwTeamID] = tbTeamPlayer[pPlayer.dwTeamID] or {}
                table.insert(tbTeamPlayer[pPlayer.dwTeamID], {dwID = pPlayer.dwID, nWinRate = tbPlayerInfo.nWinRate, nFightTime = tbPlayerInfo.nFightTime, tbNearFight = tbPlayerInfo.tbNearFight})
            end
        end
    end
    -- 整理队伍信息
    local fnArrange = function (tbPlayer)
        local tbArrangePlayer = {}
        for nTeamId, tbPlayer in pairs(tbPlayer) do
            if #tbPlayer ~= QunYingHuiCross.nFightPlayerNum then
                self:DismissTeam(tbPlayer)
            else
                local nWinRate = 0                          -- 队伍胜率为队员胜率的一半
                local nFightTime = 0                        -- 队伍战斗时长为队员战斗时间之和
                local tbNearFight = {}                      -- 双方战斗过的玩家
                local tbPlayerId = {}
                for _, v in ipairs(tbPlayer) do
                    nWinRate = nWinRate + v.nWinRate / 2
                    nFightTime = nFightTime + v.nFightTime
                    table.insert(tbPlayerId, v.dwID)
                    for _, tbFightPlayer in pairs(v.tbNearFight) do
                        for _, dwID in ipairs(tbFightPlayer) do
                            tbNearFight[dwID] = true
                        end
                    end
                end
                table.insert(tbArrangePlayer, {nWinRate = nWinRate, nFightTime = nFightTime, tbNearFight = tbNearFight, tbPlayerId = tbPlayerId})
            end
        end
        return tbArrangePlayer
    end
    -- 排序队列
    local tbSingleQueue = fnArrange(tbSinglePlayer)
    local tbTeamQueue = fnArrange(tbTeamPlayer)
    local fnSort = function (a, b)
        if a.nWinRate == b.nWinRate then
            return a.nFightTime > b.nFightTime
        end
        return a.nWinRate > b.nWinRate
    end
    table.sort(tbSingleQueue, fnSort)
    table.sort(tbTeamQueue, fnSort)
    -- 执行匹配
    local fnAssist = function (tbPlayer)
        local nBreakCount = 0
        local tbAssistPlayer = {}
        while true do
            nBreakCount = nBreakCount + 1
            local nEnd = #tbPlayer
            if nEnd <= 1 or nBreakCount > 10000 then
                break
            end
            local nFind = 2
            local nMatch = 1
            local tbMatchPlayer = tbPlayer[nMatch]
            for i = nFind, nEnd do
                local tbFindPlayer = tbPlayer[i]
                local bHadFight
                local tbMatchNearFight = tbMatchPlayer.tbNearFight
                local tbFindNearFight = tbFindPlayer.tbNearFight
                local tbFindPlayerId = tbFindPlayer.tbPlayerId
                local tbMatchPlayerId = tbMatchPlayer.tbPlayerId
                -- 近两轮打过的先忽略，直到最后一个队伍默认匹配
                for _, dwID in ipairs(tbFindPlayerId) do
                    local nUniqId = self:GetUniqID(dwID)
                    if tbMatchNearFight[nUniqId] then
                        bHadFight = true
                        break
                    end
                end
                for _, dwID in ipairs(tbMatchPlayerId) do
                    local nUniqId = self:GetUniqID(dwID)
                    if tbFindNearFight[nUniqId] then
                        bHadFight = true
                        break
                    end
                end
                if i == nEnd or not bHadFight then
                    table.insert(tbAssistPlayer, {tbMatchPlayer, tbFindPlayer})
                    -- 先移除位于尾部的数据再移除头数据
                    table.remove(tbPlayer, i)
                    table.remove(tbPlayer, nMatch)
                    break
                end
            end
        end
        return tbAssistPlayer
    end
    local tbSingleAssistPlayer = fnAssist(tbSingleQueue)
    local tbTeamAssistPlayer = fnAssist(tbTeamQueue)
    -- 如果两个队列各剩下一个队伍，默认匹配
    if next(tbSingleQueue) and next(tbTeamQueue) then
        table.insert(tbTeamAssistPlayer, {tbSingleQueue[1], tbTeamQueue[1]})
    end
    -- local tbRemainPlayer = next(tbSingleQueue) and tbSingleQueue[1] or (next(tbTeamQueue) and tbTeamQueue[1])
    -- if tbRemainPlayer then
    --     self:OnPlayerMatchNoTeam(tbRemainPlayer)
    -- end
    -- 最终队列{ {{tbPlayerId = tbPlayerId, ...}, tbTeam2}, {tbTeam3, tbTeam4} }
    local tbQueue = Lib:MergeTable(tbSingleAssistPlayer, tbTeamAssistPlayer)
    Lib:CallBack({self.OnPlayerMatchTeam, self, tbQueue})
    if not QunYingHuiCross.nWaitFightTime or QunYingHuiCross.nWaitFightTime == 0 then
        self:AssistFight(tbQueue)
    else
        Timer:Register(Env.GAME_FPS * QunYingHuiCross.nWaitFightTime, self.AssistFight, self, tbQueue)
    end
    self:Log("fnMatchFightTeam ", #tbQueue)
end

-- function tbPreMapLogic:OnPlayerMatchNoTeam(tbPlayer)
--     local tbPlayerId = (tbPlayer or {}).tbPlayerId or {}
--     for _, dwID in ipairs(tbPlayerId) do
--         local pPlayer = KPlayer.GetPlayerObjById(dwID)
--         if pPlayer then
--             pPlayer.CenterMsg("请耐心等待，正在努力为您匹配...", true)
--         end
--     end
-- end

function tbPreMapLogic:OnPlayerMatchTeam(tbQueue)
    local nNowTime = GetTime()
    for _, tbFightPlayer in ipairs(tbQueue or {}) do
        for nCamp, v in ipairs(tbFightPlayer) do
            local tbPlayerId = v.tbPlayerId or {}
            for _, dwID in ipairs(tbPlayerId) do
                local tbPlayerInfo = self:GetPlayer(dwID)
                tbPlayerInfo.nMatchFightTime = nNowTime
                local pPlayer = KPlayer.GetPlayerObjById(dwID)
                if pPlayer then
                    pPlayer.CenterMsg("已匹配到对手，准备进入对战……", true)
                end
            end
        end
    end
end

function tbPreMapLogic:AssistFight(tbQueue)
    for _, tbFightPlayer in ipairs(tbQueue or {}) do
        self:JoinInFight(tbFightPlayer)
    end
end

-- 开始创建地图战斗
function tbPreMapLogic:JoinInFight(tbFightPlayer)
    local nFightMapId = CreateMap(QunYingHuiCross.nFightMapTID)
    self.tbFightMapPlayer[nFightMapId] = tbFightPlayer
end

function tbPreMapLogic:CreateFight(nFightMapId)
    local tbFightPlayer = self.tbFightMapPlayer[nFightMapId]
    if not tbFightPlayer then
        self:Log("fnCreateFight fail", nFightMapId)
        return 
    end
    local tbPlayer = {}
    local tbCampPlayer = {}
    local tbTeamId = {}
    for nCamp, v in ipairs(tbFightPlayer) do
        local tbPlayerId = v.tbPlayerId or {}
        for _, dwID in ipairs(tbPlayerId) do
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer and pPlayer.dwTeamID > 0 and pPlayer.nMapId == self.nMapId then
                table.insert(tbPlayer, pPlayer)
                tbCampPlayer[dwID] = nCamp
                tbTeamId[pPlayer.dwTeamID] = nCamp
            end
        end
    end
    if #tbPlayer ~= 4 or Lib:CountTB(tbTeamId) ~= 2 then
        for _, pPlayer in pairs(tbPlayer) do
            pPlayer.CenterMsg("检测到有玩家资料异常，即将为您重新匹配", true)
        end
        return
    end
    local tbFightLogic = self:CreateFightLogic(nFightMapId)
    tbFightLogic.tbCampPlayer = tbCampPlayer
    if tbFightLogic.OnCreate then
        tbFightLogic:OnCreate()
    end
    for _, pPlayer in pairs(tbPlayer) do
        pPlayer.SwitchMap(nFightMapId, 0, 0)
    end
end

function tbPreMapLogic:CreateFightLogic(nFightMapId)
    local tbFightLogic = Lib:NewClass(QunYingHuiCross.QYHCrossFight)
    tbFightLogic.nMapId = nFightMapId
    tbFightLogic.nPreMapId = self.nMapId
    tbFightLogic.szTimeFrame = self.szTimeFrame
    self.tbFightMapLogic[nFightMapId] = tbFightLogic
    return tbFightLogic
end

function tbPreMapLogic:CloseFightLogic(nFightMapId)
    local tbFightLogic = self.tbFightMapLogic[nFightMapId]
    if not tbFightLogic then
        return
    end
    if tbFightLogic.OnClose then
        tbFightLogic:OnClose()
    end
    self.tbFightMapLogic[nFightMapId] = nil
    self.tbFightMapPlayer[nFightMapId] = nil
    self:Log("fnCloseFightLogic ", nFightMapId)
end

-- 将玩家状态设置为单人并解散其队伍 tbPlayer结构{{dwID = 123}, {dwID = 123}}
function tbPreMapLogic:DismissTeam(tbPlayer)
    for _, v in pairs(tbPlayer) do
        local tbPlayerInfo = self:GetPlayer(v.dwID)
        if tbPlayerInfo then
            tbPlayerInfo.nType = QunYingHuiCross.TYPE_SINGLE
            local pPlayer = KPlayer.GetPlayerObjById(v.dwID)
            if pPlayer then
                self:DoDismissTeam(pPlayer)
            end
        end
    end
end

function tbPreMapLogic:DoKeepTeam(pPlayer)
    local tbFightLogic = self.tbFightMapLogic[pPlayer.nMapId]
    if not tbFightLogic then
        return
    end
    tbFightLogic:TryKeepTeam(pPlayer)
end

-- 将该玩家所在队伍所有队员解散
function tbPreMapLogic:DoDismissTeam(pPlayer, szMsg, nState)
    local dwTeamID = pPlayer.dwTeamID or 0
    local tbTeam = TeamMgr:GetTeamById(dwTeamID);
    if tbTeam then
        local tbMember = tbTeam:GetMembers() or {}
        for _, nPlayerID in pairs(tbMember) do
            TeamMgr:QuiteTeam(dwTeamID, nPlayerID)
            local tbPlayerInfo = self:GetPlayer(nPlayerID)
            tbPlayerInfo.nType = QunYingHuiCross.TYPE_SINGLE
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
            if szMsg then
                if pPlayer then
                    pPlayer.CenterMsg(szMsg, true)
                end
            end
            if nState then
                tbPlayerInfo.nState = nState
                if pPlayer then
                    self:DoRequestMatchData(pPlayer, {nState = nState,nType = tbPlayerInfo.nType})
                end
            end
        end
    end
end

-- 匹配到队友时创建临时队伍
function tbPreMapLogic:CreateTempTeam(tbPlayer)
    local nPlayerId1 = tbPlayer[1].dwID or 0
    local nPlayerId2 = tbPlayer[2].dwID or 0
    local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
    local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2)
    if pPlayer1 and pPlayer2 then
        local bRet = TeamMgr:Create(nPlayerId1, nPlayerId2, true);
        if not bRet then
            self:Log("fnCreateTempTeam fail", nPlayerId1, nPlayerId2)
            return
        end
        pPlayer1.CenterMsg(string.format("已找到队友[FFFE0D]「%s」[-]，正在匹配对手……", pPlayer2.szName), true)
        pPlayer2.CenterMsg(string.format("已找到队友[FFFE0D]「%s」[-]，正在匹配对手……", pPlayer1.szName), true)
    else
        self:Log("fnCreateTempTeam Player Offline", nPlayerId1, nPlayerId2, pPlayer1 and 1 or 0, pPlayer2 and 1 or 0)
    end
end

function tbPreMapLogic:UpdatePlayerUi(pPlayer, bForceShowLeave)
    local nRestTime = 0;
    if self.nMainTimer then
        nRestTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS);
    end
    nRestTime = math.max(nRestTime, 0)
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID) 
    pPlayer.CallClientScript("QunYingHuiCross:OnUpdatePlayerUi", {self.nStateInfo, nRestTime, tbPlayerInfo.nWinCount, tbPlayerInfo.nFightCount} )
    self:UpdateLeaveUi(pPlayer, bForceShowLeave)
end

function tbPreMapLogic:CheckOpenLeaveUi(pPlayer)
    local nNowTime = GetTime()
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    local bShow = true
    if tbPlayerInfo.nFaction <= 0 or self:IsChoosingFaction(pPlayer) then
        bShow = false
    end
    return bShow
end

function tbPreMapLogic:UpdateLeaveUi(pPlayer, bForceShowLeave)
    local bShow = bForceShowLeave or self:CheckOpenLeaveUi(pPlayer)
    pPlayer.CallClientScript("QunYingHuiCross:OnUpdateLeaveUi", bShow)
end

function tbPreMapLogic:OnClose()
    self:CloseActiveTimer()
    self:CloseSynRankTimer()
    self:Log("fnOnCloseLogic")
end

function tbPreMapLogic:IsChoosingFaction(pPlayer)
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    return GetTime() - tbPlayerInfo.nStartChooseFactionTime < QunYingHuiCross.nChooseFactionTime
end

function tbPreMapLogic:OnLogin(pPlayer)
    local nMyUniqId = QunYingHuiCross:CombineUniqId(pPlayer.nZoneServerId, pPlayer.dwOrgPlayerId)
    self:UpdateZonePlayerRef(pPlayer.dwID, {nOrgPlayerId = pPlayer.dwOrgPlayerId, nServerId = pPlayer.nZoneServerId, nUniqId = nMyUniqId}) 
    self:UpdatePlayerUi(pPlayer)
    local bChoosingFaction = self:IsChoosingFaction(pPlayer)
    pPlayer.CallClientScript("QunYingHuiCross:OnPreMapLogin", bChoosingFaction)
end

function tbPreMapLogic:CloseActiveTimer()
    if self.nActiveTimerId then
        Timer:Close(self.nActiveTimerId)
        self.nActiveTimerId = nil
    end
end

function tbPreMapLogic:CloseSynRankTimer()
    if self.nSynRankTimerId then
        Timer:Close(self.nSynRankTimerId)
        self.nSynRankTimerId = nil
    end
end

function tbPreMapLogic:Log(szLog, ...)
    Log(string.format("tbQunYingHuiZ PreMapLogic %s", szLog or ""), ...);
end

function tbPreMapLogic:PlayerAvatar(dwID, nFaction)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    local tbAvatarInfo = QunYingHuiCross.tbAvatar[self.szTimeFrame] or QunYingHuiCross.tbDefaultAvatar
    if not Player:ChangePlayer2Avatar(pPlayer, nFaction, tbAvatarInfo.nLevel, tbAvatarInfo.szEquipKey, tbAvatarInfo.szInsetKey, tbAvatarInfo.nStrengthLevel, tbAvatarInfo.tbBookType) then
        self:Log("fnPlayerAvatar fail", dwID, nFaction)
        pPlayer.CenterMsg("转换无差别角色失败", true)
        pPlayer.ZoneLogout();
    else
        pPlayer.bPlayerAvatar = true
        local nPortrait = PlayerPortrait:GetDefaultId(nFaction, pPlayer.nSex)
        pPlayer.SetPortrait(nPortrait);
        self:Log("fnPlayerAvatar", pPlayer.dwID, pPlayer.szName, nFaction)
    end
end

function tbPreMapLogic:RegisterChooseFactionTimer(tbPlayerId, tbFaction)
    local nTimerID = Timer:Register(Env.GAME_FPS * QunYingHuiCross.nChooseFactionTime,
            function (self, tbPlayerId, tbFaction)
                local tbChooseFaction = {}
                for nFaction in pairs(tbFaction or {}) do
                    for _, dwID in ipairs(tbPlayerId or {}) do
                        local tbPlayerInfo = self:GetPlayer(dwID)
                        if tbPlayerInfo.nFaction ~= nFaction then
                            table.insert(tbChooseFaction, nFaction)
                        end
                    end
                end
                for _, dwID in ipairs(tbPlayerId or {}) do
                    self.tbAllChooseFactionTimer[dwID] = nil
                    local tbPlayerInfo = self:GetPlayer(dwID)
                    if tbPlayerInfo.nFaction <= 0 then
                        local fnSelect = Lib:GetRandomSelect(#tbChooseFaction)
                        local nFaction = tbPlayerInfo.nChangeFaction ~= 0 and tbPlayerInfo.nChangeFaction or tbChooseFaction[fnSelect()]
                        if nFaction then
                            self:RecordFaction(dwID, nFaction)
                            self:PlayerAvatar(dwID, nFaction)
                            Log("Execute fnRegisterChooseFactionTimer", dwID, nFaction, tbPlayerInfo.nChangeFaction)
                        end
                    end
                    local pPlayer = KPlayer.GetPlayerObjById(dwID)
                    if pPlayer then
                        pPlayer.CallClientScript("QunYingHuiCross:OnFinishChooseFaction")
                        self:UpdatePlayerUi(pPlayer, true)
                        self:TryEnterMatchState(pPlayer)
                    end
                end
            end, self, tbPlayerId, tbFaction);
    for _, dwID in ipairs(tbPlayerId) do
        self.tbAllChooseFactionTimer[dwID] = nTimerID
    end
end

function tbPreMapLogic:OnEnter()
    local nMyUniqId = QunYingHuiCross:CombineUniqId(me.nZoneServerId, me.dwOrgPlayerId)
    self:UpdateZonePlayerRef(me.dwID, {nOrgPlayerId = me.dwOrgPlayerId, nServerId = me.nZoneServerId, nUniqId = nMyUniqId}) 
    -- 跨服进来，重新组队
    local bCreateTeam
    local tbPlayerInfo = self:GetPlayer(nil, nMyUniqId)
    tbPlayerInfo.nZonePlayerId = me.dwID
    local nOldCaptainUniqId = self.tbOldTeamInfo[nMyUniqId]
    local nOldCaptainId
    if nOldCaptainUniqId then
        nOldCaptainId = QunYingHuiCross:RestoreUniqId(nOldCaptainUniqId)
        local tbMemeber = self.tbOldTeamMembers[nOldCaptainUniqId]
        for i, nUniqId in ipairs(tbMemeber) do
            local nOrgPlayerId = QunYingHuiCross:RestoreUniqId(nUniqId)
            -- 第一个进来的玩家不做操作，第二个玩家创建队伍并确认队长
            if nOrgPlayerId ~= me.dwOrgPlayerId then
                local tbMemberInfo = self:GetPlayer(nil, nUniqId)
                local pPlayer = KPlayer.GetPlayerObjById(tbMemberInfo.nZonePlayerId);
                if pPlayer then
                    if pPlayer.dwTeamID <= 0 then
                        local nCaptainId = me.dwOrgPlayerId == nOldCaptainId and me.dwID or pPlayer.dwID
                        local nMemberId = me.dwOrgPlayerId == nOldCaptainId and pPlayer.dwID or me.dwID
                        local bRet = TeamMgr:Create(nCaptainId, nMemberId, true);
                        if bRet then
                            bCreateTeam = true
                        else
                            self:Log("fnOnEnterLogic Create Team fail", nCaptainId, nMemberId)
                        end
                        self.tbOldTeamMembers[nOldCaptainUniqId] = nil
                        self.tbOldTeamInfo[nMyUniqId] = nil
                        self.tbOldTeamInfo[nUniqId] = nil
                    end
                    break;
                end
            end
        end
    end
    local nNowTime = GetTime()
    if tbPlayerInfo.nFirstEnterTime ~= 0 then
        tbPlayerInfo.nFirstEnterTime = nNowTime
    end
    -- 放在OnChooseFaction之前为了现在在选门派界面下面
    self:UpdatePlayerUi(me)
    if tbPlayerInfo.nFaction <= 0 then
        if tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE then
            local tbFaction = self:GetChooseFaction(me.dwID)
            self.tbPlayerStandByFaction[me.dwID] = tbFaction
            me.CallClientScript("QunYingHuiCross:OnChooseFaction", tbFaction, QunYingHuiCross.TYPE_SINGLE, QunYingHuiCross.nChooseFactionTime, tbPlayerInfo.szKinName)
            self:RegisterChooseFactionTimer({me.dwID}, tbFaction)
            self:UpdatePlayer(me.dwID, {nStartChooseFactionTime = nNowTime})
        elseif tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM then
            if bCreateTeam then
                local tbFaction = self:GetChooseFaction(me.dwTeamID)
                self.tbPlayerStandByFaction[me.dwTeamID] = tbFaction
                local fnExe = function(self, pPlayer, tbFaction)
                    pPlayer.CallClientScript("QunYingHuiCross:OnChooseFaction", tbFaction, QunYingHuiCross.TYPE_TEAM, QunYingHuiCross.nChooseFactionTime, tbPlayerInfo.szKinName)
                end
                local tbPlayerId = self:ForeachTeam(me.dwTeamID, fnExe, tbFaction)
                self:RegisterChooseFactionTimer(tbPlayerId, tbFaction)
                for _, dwID in ipairs(tbPlayerId) do
                    self:UpdatePlayer(dwID, {nStartChooseFactionTime = nNowTime})
                end
            end
        end
    else
        -- 变身会清空uservalue，没有变身才变身
        if not me.bPlayerAvatar then
            Timer:Register(1, self.PlayerAvatar, self, me.dwID, tbPlayerInfo.nFaction);
        end
        self:DoRequestMatchData(me)
    end
    me.SetPosition(unpack(self:GetEnterPos()))
    self:MatchTip(me)
    self:Log("fnOnEnterLogic", tbPlayerInfo.nZonePlayerId, me.dwOrgPlayerId, me.nZoneServerId, me.dwTeamID or -1, nOldCaptainId or -1, 
        tbPlayerInfo.nServerId, tbPlayerInfo.nType, tbPlayerInfo.nFaction, bCreateTeam and 1 or 0, tbPlayerInfo.nFightCount, tbPlayerInfo.nWinCount)
end
    
function tbPreMapLogic:MatchTip(pPlayer)
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    local bMax = self:CheckMaxFight(pPlayer.dwID)
    if tbPlayerInfo.nState == QunYingHuiCross.STATE_MATCHING and self.nStartMatch == QunYingHuiCross.MATCH_OPEN and not bMax then
        pPlayer.CenterMsg(QunYingHuiCross.szStartMatchTip, true)
    end
end

function tbPreMapLogic:RecordFaction(dwID, nFaction)
    local tbPlayerInfo = self:GetPlayer(dwID)
    tbPlayerInfo.nFaction = nFaction
    self.tbChosedFaction[nFaction] = (self.tbChosedFaction[nFaction] or 0) + 1
    local nConnectIdx = self:GetConnectIdx(tbPlayerInfo)
    local _, dwOrgPlayerId = KPlayer.GetOrgPlayerIdByZoneId(dwID)
    CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnChooseFactionFinish", dwOrgPlayerId, nFaction)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if pPlayer then
        self:UpdatePlayerUi(pPlayer)
    end
    self:Log("RecordFaction", dwID, dwOrgPlayerId, nFaction, self.tbChosedFaction[nFaction], nConnectIdx)
end

function tbPreMapLogic:DoChooseFactionChange(pPlayer, nFaction)
    local bRet, szMsg = QunYingHuiCross:CheckFaction(nFaction)
    if not bRet then
        pPlayer.CenterMsg(szMsg, true)
        return
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nFaction > 0 then
        return
    end
    local tbData = {}
    tbData[nFaction] = pPlayer.szName
    local tbPlayer = {pPlayer}
    if tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE then
        local tbFaction = self.tbPlayerStandByFaction[pPlayer.dwID]
        if not tbFaction or not tbFaction[nFaction] then
            pPlayer.CenterMsg("未知门派数据", true)
            return
        end
    elseif tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM then
        local nTeamId = pPlayer.dwTeamID
        local tbFaction = self.tbPlayerStandByFaction[nTeamId]
        if not tbFaction or not tbFaction[nFaction] then
            pPlayer.CenterMsg("未知门派数据", true)
            return
        end
        local tbTeam = TeamMgr:GetTeamById(nTeamId);
        if tbTeam then
           local tbMember = tbTeam:GetMembers()
           for _, nMemberId in pairs(tbMember) do
                if nMemberId ~= pPlayer.dwID then
                   local pMember = KPlayer.GetPlayerObjById(nMemberId)
                   local tbMemberInfo = self:GetPlayer(nMemberId)
                   if pMember then
                      if tbMemberInfo.nChangeFaction == nFaction then
                         pPlayer.CenterMsg("该门派已经被对方选择", true)
                         return
                      end 
                      table.insert(tbPlayer, pMember)
                      if tbMemberInfo.nChangeFaction > 0 then
                         tbData[tbMemberInfo.nChangeFaction] = pMember.szName
                      end
                   end
                end
           end
        end
    end
    tbPlayerInfo.nChangeFaction = nFaction
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.CallClientScript("QunYingHuiCross:OnChooseFactionChange", tbData)
    end
end

function tbPreMapLogic:OnFinishChoose(tbPlayerId)
    local nTimerID
    for _, dwID in ipairs(tbPlayerId) do
        local tbPlayerInfo = self:GetPlayer(dwID)
        tbPlayerInfo.nStartChooseFactionTime = tbPlayerInfo.nStartChooseFactionTime - QunYingHuiCross.nChooseFactionTime
        nTimerID = self.tbAllChooseFactionTimer[dwID]
        self.tbAllChooseFactionTimer[dwID] = nil
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            pPlayer.CallClientScript("QunYingHuiCross:OnFinishChooseFaction")
            self:UpdatePlayerUi(pPlayer)
        end
    end
    if nTimerID then
        Timer:Close(nTimerID)
        self:Log("fnOnFinishChoose", nTimerID)
    end
end

function tbPreMapLogic:DoChooseFaction(pPlayer, nFaction)
    local bRet, szMsg = QunYingHuiCross:CheckFaction(nFaction)
    if not bRet then
        pPlayer.CenterMsg(szMsg, true)
        return
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nFaction > 0 then
        pPlayer.CenterMsg("您已经选择过门派了", true)
        return 
    end
    -- 没有找到队伍直接转单人
    local fnTurn = function(pTurner, nFaction)
        local tbTurnerInfo = self:GetPlayer(pTurner.dwID)
        tbTurnerInfo.nType = QunYingHuiCross.TYPE_SINGLE
        self:RecordFaction(pTurner.dwID, nFaction)
        self:PlayerAvatar(pTurner.dwID, nFaction)
        self:OnFinishChoose({pTurner.dwID})
        pTurner.CenterMsg("检测到您的队友掉线，已转为单人参赛", true)
    end
    -- 做出选门派
    local fnChoose = function(pChooser, nFaction)
        local tbChooserInfo = self:GetPlayer(pChooser.dwID)
        self:RecordFaction(pChooser.dwID, nFaction)
        self:PlayerAvatar(pChooser.dwID, nFaction)
    end
    if tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE then
        local tbFaction = self.tbPlayerStandByFaction[pPlayer.dwID]
        if not tbFaction then
            pPlayer.CenterMsg("未知门派数据", true)
            return
        end
        if not tbFaction[nFaction] then
            pPlayer.CenterMsg("不能选择此门派", true)
            return
        end
        fnChoose(pPlayer, nFaction)
        self:OnFinishChoose({pPlayer.dwID})
    elseif tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM then
        local nTeamId = pPlayer.dwTeamID
        local tbFaction = self.tbPlayerStandByFaction[nTeamId]
        if not tbFaction then
            pPlayer.CenterMsg("未知门派数据", true)
            return
        end
        if not tbFaction[nFaction] then
            pPlayer.CenterMsg("不能选择此门派", true)
            return
        end
        local tbTeam = TeamMgr:GetTeamById(nTeamId);
        if not tbTeam then
            fnTurn(pPlayer, nFaction)
            return 
        end
        local tbMember = tbTeam:GetMembers()
        local nMemberCount = Lib:CountTB(tbMember)
        local pAssist

        if nMemberCount == 1 then
            fnTurn(pPlayer, nFaction)
        elseif nMemberCount == 2 then
            for _, nPlayerID in pairs(tbMember) do
                local pMember = KPlayer.GetPlayerObjById(nPlayerID);
                if not pMember then
                    fnTurn(pPlayer, nFaction)
                    return
                end
                if nPlayerID ~= pPlayer.dwID then
                    pAssist = pMember;
                end
            end
            if not pAssist then
                fnTurn(pPlayer, nFaction)
                return
            end
            local tbAssistInfo = self:GetPlayer(pAssist.dwID)
            if tbAssistInfo.nFaction > 0 then
                if tbAssistInfo.nFaction == nFaction then
                    pPlayer.CenterMsg(string.format("您的队友[FFFE0D]「%s」[-]已经选择了该门派", pAssist.szName), true)
                    return
                end
                fnChoose(pPlayer, nFaction)
                self:OnFinishChoose({pPlayer.dwID, pAssist.dwID})
            else
                fnChoose(pPlayer, nFaction)
                pPlayer.CenterMsg("等待对方选择", true)
            end
        else
            pPlayer.CenterMsg("队伍成员异常", true)
            return
        end
       
    else
        pPlayer.CenterMsg("未知对战类型", true)
    end
end

function tbPreMapLogic:ForeachTeam(nTeamId, fnFunc, ...)
    local tbPlayerId = {}
    local tbTeam = TeamMgr:GetTeamById(nTeamId);
    if tbTeam then
        local tbMember = tbTeam:GetMembers()
        for _, nPlayerId in pairs(tbMember) do
            table.insert(tbPlayerId, nPlayerId)
            local pMember = KPlayer.GetPlayerObjById(nPlayerId)
            if pMember then
                Lib:CallBack({fnFunc, self, pMember, ...});
            end
        end
    end
    return tbPlayerId
end

function tbPreMapLogic:GetChooseFaction(nId)
    if self.tbPlayerStandByFaction[nId] then
        return self.tbPlayerStandByFaction[nId]
    end
    return self:RandomChooseFaction()
end

function tbPreMapLogic:RandomChooseFaction()
    local tbFaction = {}
    local tbTempFaction = {}
    local nForbidFaction = self:GetForbidFaction() or -1
    for nFaction = 1, Faction.MAX_FACTION_COUNT do
        if nForbidFaction ~= nFaction then
            table.insert(tbTempFaction, nFaction)
        end
    end
    local fnSelect = Lib:GetRandomSelect(#tbTempFaction)
    for i = 1, QunYingHuiCross.nChooseFaction do
        local nFaction = tbTempFaction[fnSelect()]
        tbFaction[nFaction] = true
    end
    return tbFaction
end

-- 最大选择数量的门派大于其他门派总和时，除去
function tbPreMapLogic:GetForbidFaction()
    local nForbidFaction, nMaxFaction, nMaxFactionCount, nAllFactionCount = nil, nil, 0, 0
    for nFaction, nCount in pairs(self.tbChosedFaction) do
        if nCount > nMaxFactionCount then
            nMaxFaction = nFaction
            nMaxFactionCount = nCount
        end
        nAllFactionCount = nAllFactionCount + nCount
    end
    if nMaxFactionCount > (nAllFactionCount - nMaxFactionCount) then
        nForbidFaction = nMaxFaction
    end
    return nForbidFaction
end

function tbPreMapLogic:CheckMatchCommon(pPlayer)
    if pPlayer.nMapId ~= self.nMapId then
        return false, "请返回活动地图再进行匹配"
    end
    if self.nStartMatch ~= QunYingHuiCross.MATCH_OPEN then
        local szTip = "请等待活动开启再进行匹配"
        if self.nStartMatch == QunYingHuiCross.MATCH_CLOSE then
            szTip = "活动已结束，请耐心等待结算"
        elseif self.nStartMatch == QunYingHuiCross.MATCH_END then
            szTip = "活动已结束并完成结算，请离开活动地图"
        end
        return false, szTip
    end
    local bRet, szMsg = self:CheckLeave(pPlayer)
    if not bRet then
        return false, szMsg
    end
    return true
end

function tbPreMapLogic:DoJoinMatch(pPlayer)
    local bRet, szMsg = self:CheckMatchCommon(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg, true)
        return
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nFaction <= 0 then
        pPlayer.CenterMsg("少侠还没有选择门派，请重新进入活动地图", true)
        return
    end
    if tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM and pPlayer.dwTeamID <= 0 then
        tbPlayerInfo.nType = QunYingHuiCross.TYPE_SINGLE
        pPlayer.CenterMsg("匹配失败", true)
	    self:Log("fnDoJoinMatch fail", pPlayer.dwID, pPlayer.szName)
        return
    end
    if tbPlayerInfo.nState == QunYingHuiCross.STATE_MATCHING then
         pPlayer.CenterMsg("已在匹配伫列", true)
        return
    end
    if tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE and tbPlayerInfo.nFightCount >= QunYingHuiCross.nMaxFight then
        pPlayer.CenterMsg(string.format("已经打满%s场不能参加匹配", QunYingHuiCross.nMaxFight), true)
        return 
    end
    local tbPlayer = {pPlayer}
    local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
    local pAssist;
    if tbTeam then
        local tbMember = tbTeam:GetMembers()
        if Lib:CountTB(tbMember) ~= 2 then
            self:DoDismissTeam(pPlayer)
            pPlayer.CenterMsg("队伍资料不正常，已为您解散队伍", true)
            return 
        end
        if tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM then
            if tbTeam:GetCaptainId() ~= pPlayer.dwID then
                pPlayer.CenterMsg("只有队长才能操作", true)
                return 
            end
        end
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if not pMember then
                pPlayer.CenterMsg("对方不线上，无法参加！", true)
                return
            end
            if nPlayerID ~= pPlayer.dwID then
                pAssist = pMember;
            end
        end
        if not pAssist then
            pPlayer.CenterMsg("找不到您的队友", true)
            return
        end
        table.insert(tbPlayer, pAssist)
        for _, pP in ipairs(tbPlayer) do
            if self:DoDismissMaxFightTeam(pP) then
                return 
            end
        end
    end
    for _, pP in ipairs(tbPlayer) do
        self:EnterMatchState(pP)
        pP.CenterMsg(QunYingHuiCross.szStartMatchTip, true)
    end
end

function tbPreMapLogic:EnterMatchState(pPlayer)
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    tbPlayerInfo.nState = QunYingHuiCross.STATE_MATCHING
    tbPlayerInfo.nMatchTime = GetTime()
    self:DoRequestMatchData(pPlayer, {nState = QunYingHuiCross.STATE_MATCHING})
end

function tbPreMapLogic:DoCancelMatch(dwID)
    local tbPlayerInfo = self:GetPlayer(dwID)
    tbPlayerInfo.nState = QunYingHuiCross.STATE_NONE
    tbPlayerInfo.nCancelMatchTime = GetTime()
end

function tbPreMapLogic:TryDoQuiteMatch(pPlayer)
    local szTip 
    if pPlayer.dwTeamID > 0 then
        local pTeammate = self:GetTeammate(pPlayer)
        local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
        if tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE then
            szTip = string.format("大侠当前为组队状态，取消匹配後将与[FFFE0D]「%s」[-]解除组队，是否继续？", pTeammate and pTeammate.szName or "")
        end
        if szTip then
            pPlayer.MsgBox(szTip, {{"确认", self.DoQuiteMatch, self, pPlayer.dwID}, {"取消"}})
        end
    end
    if not szTip then
        self:DoQuiteMatch(pPlayer.dwID)
    end
end

function tbPreMapLogic:DoQuiteMatch(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
       return
    end
    local bRet, szMsg = self:CheckMatchCommon(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg, true)
        return
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nState ~= QunYingHuiCross.STATE_MATCHING then
        pPlayer.CenterMsg("当前不是匹配状态", true)
        return
    end
    local bSingleTeam = (tbPlayerInfo.nType == QunYingHuiCross.TYPE_SINGLE and pPlayer.dwTeamID > 0) and true or false
    local nNowTime = GetTime()
    local tbPlayerId = {pPlayer.dwID}
    local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
    if tbTeam then
        if tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM and tbTeam:GetCaptainId() ~= pPlayer.dwID then
            pPlayer.CenterMsg("只有队长才能操作", true)
            return
        end
        local tbMember = tbTeam:GetMembers()
        for _, nPlayerID in pairs(tbMember) do
            if nPlayerID ~= pPlayer.dwID then
                table.insert(tbPlayerId, nPlayerID)
            end
        end

    end
    for _, dwID in ipairs(tbPlayerId) do
        self:DoCancelMatch(dwID)
        local pMember = KPlayer.GetPlayerObjById(dwID)
        if pMember then
            local szTip = (pMember.dwID ~= pPlayer.dwID and bSingleTeam) and string.format("[FFFE0D]「%s」[-]已退出匹配，队伍已解散，请重新匹配", pPlayer.szName) or QunYingHuiCross.szQuiteMatchTip
            pMember.CenterMsg(szTip, true)
            self:DoRequestMatchData(pMember, {nState = QunYingHuiCross.STATE_NONE})
        end
    end
    
    if bSingleTeam then
        self:DoDismissTeam(pPlayer)
    end
end

function tbPreMapLogic:GetTeammate(pPlayer)
    local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
    if tbTeam then
        local tbMember = tbTeam:GetMembers()
        for _, nPlayerID in pairs(tbMember) do
            if pPlayer.dwID ~= nPlayerID then
                local pMember = KPlayer.GetPlayerObjById(nPlayerID)
                if pMember then
                    return pMember
                end
            end
        end
    end
end

function tbPreMapLogic:CheckLeave(pPlayer)
    local nNowTime = GetTime()
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    -- 已匹配到n + 10秒之内不能离开
    if tbPlayerInfo.nMatchFightTime + (QunYingHuiCross.nWaitFightTime or 0) + 10 > nNowTime then
        return false, "已匹配到对手不允许操作"
    end
    if pPlayer.nMapTemplateId ~= QunYingHuiCross.nPreMapTID then
        return false, "不能通该方式操作"
    end
    return true
end

function tbPreMapLogic:DoLeaveMap(pPlayer)
    local fnLeave = function (self, dwID)
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if not pPlayer then
           return
        end
        local bRet, szMsg = self:CheckLeave(pPlayer)
        if not bRet then
            pPlayer.CenterMsg(szMsg, true)
            return
        end
        local tbPlayerInfo = self:GetPlayer(dwID)
        if tbPlayerInfo.nState == QunYingHuiCross.STATE_FIGHT then
            pPlayer.CenterMsg("战斗中玩家不允许离开", true)
            return 
        end
        if tbPlayerInfo.nState == QunYingHuiCross.STATE_MATCHING then
            pPlayer.CenterMsg(QunYingHuiCross.szQuiteMatchTip, true)
        end
        self:DoCancelMatch(dwID)
        local nTeamId = pPlayer.dwTeamID
        local tbTeam = TeamMgr:GetTeamById(nTeamId);
        if tbTeam then
            local tbMember = tbTeam:GetMembers()
            for _, nPlayerID in pairs(tbMember) do
                if dwID ~= nPlayerID then
                    local tbMemberInfo = self:GetPlayer(nPlayerID)
                    local nMemberState = tbMemberInfo.nState
                    self:DoCancelMatch(nPlayerID)
                    local pMember = KPlayer.GetPlayerObjById(nPlayerID)
                    if pMember then
                        if nMemberState == QunYingHuiCross.STATE_MATCHING then
                            pMember.CenterMsg(string.format("[FFFE0D]「%s」[-]已离开群英会场地，匹配已中断", pPlayer.szName), true)
                        else
                            pMember.CenterMsg(string.format("[FFFE0D]「%s」[-]已离开群英会场地，队伍已解散", pPlayer.szName), true)
                        end
                        self:DoRequestMatchData(pMember)
                    end
                end
            end
            self:DoDismissTeam(pPlayer)
        end
        pPlayer.ZoneLogout();
        self:Log("fnOnLeave", dwID, pPlayer.szName, nTeamId)
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nState == QunYingHuiCross.STATE_FIGHT then
        pPlayer.CenterMsg("战斗中玩家不允许离开", true)
        return 
    end
    local bRet, szMsg = self:CheckLeave(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg, true)
        return
    end
    local szLeave = "大侠是否确认离开群英会场地？"
    local bMatching = tbPlayerInfo.nState == QunYingHuiCross.STATE_MATCHING and true or false
    if bMatching then
        szLeave = "大侠当前正在匹配，是否停止匹配并离开场地？"
    end
    if pPlayer.dwTeamID > 0 then
        local szAssistName
        local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
        if tbTeam then
            local tbMember = tbTeam:GetMembers()
            for _, nPlayerID in pairs(tbMember) do
                if pPlayer.dwID ~= nPlayerID then
                    szAssistName = self:GetPlayer(nPlayerID).szName
                end
            end
        end
        if tbPlayerInfo.nType == QunYingHuiCross.TYPE_TEAM then
            szLeave = string.format("大侠当前为组队状态，离开场地後将与[FFFE0D]「%s」[-]解除组队状态（返场後无法恢复），是否继续？", szAssistName or "队友")
            if bMatching then
                szLeave = string.format("大侠当前正在匹配，是否停止匹配并离开场地？同时将与[FFFE0D]「%s」[-]解除组队状态", szAssistName or "队友")
            end
        end
    end
    pPlayer.MsgBox(szLeave, {{"确认", fnLeave, self, pPlayer.dwID}, {"拒绝"}})
end

function tbPreMapLogic:GetMatchTime()
    local nMatchTime = 0
    if self.nStateInfo == QunYingHuiCross.PRE_STATE_STARTMATCH and self.nMainTimer then
        nMatchTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS);
    end
    return nMatchTime
end

function tbPreMapLogic:DoRequestMatchTime(pPlayer)
    self:DoRequestMatchData(pPlayer, {nMatchTime = self:GetMatchTime()})
end

function tbPreMapLogic:DoRequestMatchData(pPlayer, tbMatchData)
    local tbData = tbMatchData or {}
    if not tbMatchData then
        local tbMyPlayerInfo = self:GetPlayer(pPlayer.dwID)
        tbData.nFightTime = tbMyPlayerInfo.nFightTime
        tbData.nWinCount = tbMyPlayerInfo.nWinCount
        tbData.nFightCount = tbMyPlayerInfo.nFightCount
        tbData.nState = tbMyPlayerInfo.nState
        tbData.nWinRate = tbMyPlayerInfo.nWinRate
        tbData.nServerIdx = tbMyPlayerInfo.nServerIdx
        tbData.nFaction = tbMyPlayerInfo.nFaction
        tbData.tbGetWinAwardFlag = tbMyPlayerInfo.tbGetWinAwardFlag
        tbData.tbGetJoinAwardFlag = tbMyPlayerInfo.tbGetJoinAwardFlag
        tbData.nProcess = self.nStartMatch
        tbData.szKinName = tbMyPlayerInfo.szKinName
        tbData.nType =  tbMyPlayerInfo.nType
        tbData.nMatchTime = self:GetMatchTime()
        local tbRank, nMyRank = self:GetSynRankData(pPlayer.dwID)
        tbData.nRank = nMyRank
        self.tbPlayerRequestRank[pPlayer.dwID] = GetTime()
    end
    pPlayer.CallClientScript("QunYingHuiCross:OnSynMatchData", tbData)
end

function tbPreMapLogic:SynRankData(pPlayer)
    local tbData = {}
    local tbRank, nMyRank = self:GetSynRankData(pPlayer.dwID)
    tbData.nRank = nMyRank
    local tbRankInfo = {}
    for nRank, v in ipairs(tbRank or {}) do
        local tbInfo = {}
        local tbPlayerInfo = self:GetPlayer(nil, v.nUniqId)
        tbInfo.nRank = nRank
        tbInfo.szName = tbPlayerInfo.szName
        tbInfo.nWinRate = tbPlayerInfo.nWinRate
        tbInfo.nFightTime = tbPlayerInfo.nFightTime
        tbInfo.nWinCount = tbPlayerInfo.nWinCount
        tbInfo.nFightCount = tbPlayerInfo.nFightCount
        tbInfo.nServerIdx = tbPlayerInfo.nServerIdx
        tbInfo.nFaction = tbPlayerInfo.nFaction
        tbInfo.szKinName = tbPlayerInfo.szKinName
        tbRankInfo[nRank] = tbInfo
    end
    tbData.tbRank = tbRankInfo
    pPlayer.CallClientScript("QunYingHuiCross:OnSynMatchData", tbData)
end

function tbPreMapLogic:OnLeave(pPlayer)
   self:Log("fnOnLeave", pPlayer.dwID, pPlayer.szName, pPlayer.dwTeamID)
end

function tbPreMapLogic:OnSyncTeamInfo(dwCaptainID, tbMember)
    for i, nPlayerId in ipairs(tbMember) do
        self.tbOldTeamInfo[nPlayerId] = dwCaptainID;
    end
    self.tbOldTeamMembers[dwCaptainID] = tbMember
end

function tbPreMapLogic:UpdatePlayer(nZonePlayerId, tbValue, nUniqId)
    local tbPlayerInfo = self:GetPlayer(nZonePlayerId, nUniqId)
    for k, v in pairs(tbValue or {}) do
        if v == "nil" then
            tbPlayerInfo[k] = nil
        else
            tbPlayerInfo[k] = v
        end
    end
end

function tbPreMapLogic:GetPlayer(nZonePlayerId, nId)
    local nUniqId = nId and nId or self:GetUniqID(nZonePlayerId)
    if not self.tbPlayer[nUniqId] then
        self.tbPlayer[nUniqId] = 
        {
            nType = QunYingHuiCross.TYPE_NONE;      -- 进入类型（单人/组队）
            nState = QunYingHuiCross.STATE_NONE;    -- 状态
            nFaction = 0;                           -- 玩家门派
            nChangeFaction = 0;                     -- 想要选的门派
            nMatchTime = 0;                         -- 进入匹配状态的时间
            nWinRate = 0;                           -- 胜率
            nGetRateTime = 0;                       -- 到达排行的时间（排行排序用到）
            nFightTime = 0;                         -- 战斗总时长
            tbNearFight = {};                       -- 近两场打过的玩家{{dwID1,dwID2},{dwID1,dwID2}}
            nCancelMatchTime = 0;                   -- 取消匹配的时间
            nWinCount = 0;                          -- 胜场数
            nFightCount = 0;                        -- 打了几场
            tbGetWinAwardFlag = {};                 -- n胜奖励是否已经领取，未领取结束的时候强制发放
            tbGetJoinAwardFlag = {};                -- n场奖励是否已经领取，未领取结束的时候强制发放
            nServerIdx = nil;                       -- 几服(显示用)
            nServerId = nil;                        -- 服务器id（唯一，合成id用）
            nContinueWin = 0;                       -- 连胜
            nStartChooseFactionTime = 0;            -- 开始选门派时间
            nFirstEnterTime = 0;                    -- 首次进入地图的时间
            szKinName = nil;                        -- 家族名
            nMatchFightTime = 0;                    -- 匹配到战斗的时间
            tbContinueWinNotify = {};               -- 已经公告过的连胜次数{[5] = nNowTime}
            nZonePlayerId = 0;                      -- 玩家在跨服上的ID
            szName = "";                            -- 玩家名字
        }
        self.bPlayerDataChange = true
    end
    return self.tbPlayer[nUniqId]
end

function tbPreMapLogic:GetZonePlayerId(nUniqId)
    return self:GetPlayer(nil, nUniqId).nZonePlayerId
end

function tbPreMapLogic:GetUniqID(nZonePlayerId)
    return self:GetZonePlayerRef(nZonePlayerId).nUniqId
end

function tbPreMapLogic:GetZonePlayerRef(nZonePlayerId)
    -- nZonePlayerId可能会变（每次玩家重新登录id重新生成）
    if not self.tbZonePlayerRef[nZonePlayerId] then
        self.tbZonePlayerRef[nZonePlayerId] = 
        {
            nOrgPlayerId = 0;                           -- 原服玩家id
            nServerId    = 0;                           -- 原服服务器id
            nUniqId      = 0;                           -- 生成的唯一id
        }
    end
    return self.tbZonePlayerRef[nZonePlayerId]
end

function tbPreMapLogic:UpdateZonePlayerRef(nZonePlayerId, tbValue)
     local tbInfo = self:GetZonePlayerRef(nZonePlayerId)
    for k, v in pairs(tbValue or {}) do
        if v == "nil" then
            tbInfo[k] = nil
        else
            tbInfo[k] = v
        end
    end
end

function tbPreMapLogic:DoGetWinAward(pPlayer, nWin)
    local tbAward, nId = QunYingHuiCross:GetWinAward(nWin)
    if not tbAward then
        pPlayer.CenterMsg("没有相关的奖励", true)
        return
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nWinCount < nWin then
        pPlayer.CenterMsg(string.format("请先取得%d场胜利", nWin), true)
        return
    end
    if self.nStartMatch == QunYingHuiCross.MATCH_END then
        pPlayer.CenterMsg("奖励已通过信件发放", true)
        return
    end
    local tbRecord = tbPlayerInfo.tbGetWinAwardFlag
    if tbRecord[nId] then
        pPlayer.CenterMsg("您已经领过奖励了", true)
        return
    end
    tbRecord[nId] = GetTime()
    local nConnectIdx = self:GetConnectIdx(tbPlayerInfo)
    CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnSendWinAward", pPlayer.dwOrgPlayerId, nWin, tbAward)
    self:DoRequestMatchData(pPlayer, {tbGetWinAwardFlag = tbRecord})
end

function tbPreMapLogic:DoGetJoinAward(pPlayer, nJoin)
    local tbAward, nId = QunYingHuiCross:GetJoinAward(nJoin)
    if not tbAward then
        pPlayer.CenterMsg("没有相关的奖励", true)
        return
    end
    local tbPlayerInfo = self:GetPlayer(pPlayer.dwID)
    if tbPlayerInfo.nFightCount < nJoin then
        pPlayer.CenterMsg(string.format("请先完成%d场对战", nJoin), true)
        return
    end
    if self.nStartMatch == QunYingHuiCross.MATCH_END then
        pPlayer.CenterMsg("奖励已通过信件发放", true)
        return
    end
    local tbRecord = tbPlayerInfo.tbGetJoinAwardFlag
    if tbRecord[nId] then
        pPlayer.CenterMsg("您已经领过奖励了", true)
        return
    end
    tbRecord[nId] = GetTime()
    local nConnectIdx = self:GetConnectIdx(tbPlayerInfo)
    CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnSendJoinAward", pPlayer.dwOrgPlayerId, nJoin, tbAward)
    self:DoRequestMatchData(pPlayer, {tbGetJoinAwardFlag = tbRecord})
end

function tbPreMapLogic:GetConnectIdx(tbPlayerInfo)
    local nServerId = tbPlayerInfo.nServerId
    local nConnectIdx = Server:GetConnectIdx(nServerId)
    if not nConnectIdx then
        self:Log("fnGetConnectIdx nil", tbPlayerInfo.nZonePlayerId, tbPlayerInfo.szName, nServerId, tbPlayerInfo.nType)
        Log(debug.traceback())
    end
    return nConnectIdx
end

-- >>>>>>>>>>>>>>>>>>>> 准备场
local tbPreMap = Map:GetClass(QunYingHuiCross.nPreMapTID);
function tbPreMap:OnCreate(nMapId)
    tbQunYingHuiZ:CreatePreMapLogic(nMapId)
    Log("tbQunYingHuiZ PreMap fnOnCreate", nMapId);
end

function tbPreMap:OnDestroy(nMapId)
    tbQunYingHuiZ:ClosePreMapLogic(nMapId)
    Log("tbQunYingHuiZ PreMap fnOnDestroy", nMapId);
end

function tbPreMap:OnEnter(nMapId)
    me.nInBattleState = 1
    -- Lib:CallBack({tbQunYingHuiZ.UpdateNormalKinName,tbQunYingHuiZ,me});
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end
    tbPrLogic:OnEnter();
    -- me.CallClientScript("AutoFight:StopFollowTeammate");
    
end

function tbPreMap:OnLeave(nMapId)
    me.nInBattleState = 0
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end
    tbPrLogic:OnLeave(me);
end

function tbPreMap:OnLogin(nMapId)
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnLogin(me);
end

-- >>>>>>>>>>>>>>>>>>>> 战斗场
local tbFightMap = Map:GetClass(QunYingHuiCross.nFightMapTID);

function tbFightMap:OnCreate(nMapId)
    local tbZoneInfo = tbQunYingHuiZ:GetZoneInfo()
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(tbZoneInfo.nPreMapId);
    if tbPrLogic then
        tbPrLogic:CreateFight(nMapId)
    end
    if QunYingHuiCross.nPkDmgRate then
        SetMapPKDmgRate(nMapId, QunYingHuiCross.nPkDmgRate);
    end
    Log("QunYingHuiCross FightMap fnOnCreate", nMapId, tbPrLogic and 1 or 0, QunYingHuiCross.nPkDmgRate);
end

function tbFightMap:OnDestroy(nMapId)
    local tbZoneInfo = tbQunYingHuiZ:GetZoneInfo()
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(tbZoneInfo.nPreMapId);
    if tbPrLogic then
        tbPrLogic:CloseFightLogic(nMapId)
    end
    Log("QunYingHuiCross FightMap fnOnDestroy", nMapId);
end

function tbFightMap:OnEnter(nMapId)
    local tbZoneInfo = tbQunYingHuiZ:GetZoneInfo()
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(tbZoneInfo.nPreMapId);
    if tbPrLogic then
        local tbFightLogic = tbPrLogic.tbFightMapLogic[nMapId]
        if tbFightLogic and tbFightLogic.OnEnter then
            tbFightLogic:OnEnter(me)
        end
    end
end

function tbFightMap:OnLeave(nMapId)
     local tbZoneInfo = tbQunYingHuiZ:GetZoneInfo()
    local tbPrLogic = tbQunYingHuiZ:GetPreMapLogic(tbZoneInfo.nPreMapId);
    if tbPrLogic then
        local tbFightLogic = tbPrLogic.tbFightMapLogic[nMapId]
        if tbFightLogic and tbFightLogic.OnLeave then
            tbFightLogic:OnLeave(me)
        end
    end
end