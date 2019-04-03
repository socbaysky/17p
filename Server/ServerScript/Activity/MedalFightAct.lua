local tbAct = Activity:GetClass("MedalFightAct")
tbAct.tbTimerTrigger = {
    [1] = {szType = "Day", Time = "18:59" , Trigger = "SendWorldNotify" },
    [2] = {szType = "Day", Time = "18:59" , Trigger = "SendNotify" },

    [3] = {szType = "Day", Time = "19:00" , Trigger = "OpenAct" },
    [4] = {szType = "Day", Time = "19:30" , Trigger = "CloseAct" },

    [5] = {szType = "Day", Time = "19:03" , Trigger = "NewMatch" },
    [6] = {szType = "Day", Time = "19:06" , Trigger = "NewMatch" },
    [7] = {szType = "Day", Time = "19:09" , Trigger = "NewMatch" },
    [8] = {szType = "Day", Time = "19:12" , Trigger = "NewMatch" },
    [9] = {szType = "Day", Time = "19:15" , Trigger = "NewMatch" },
    [10] = {szType = "Day", Time = "19:18" , Trigger = "NewMatch" },
    [11] = {szType = "Day", Time = "19:21" , Trigger = "NewMatch" },
    [12] = {szType = "Day", Time = "19:24" , Trigger = "NewMatch" },
    [13] = {szType = "Day", Time = "19:27" , Trigger = "NewMatch" },
}
tbAct.tbTrigger = {
	Init={},
	Start={
        {"StartTimerTrigger", 1},
        {"StartTimerTrigger", 2},
        {"StartTimerTrigger", 3},
        {"StartTimerTrigger", 4},

        {"StartTimerTrigger", 5},
        {"StartTimerTrigger", 6},
        {"StartTimerTrigger", 7},
        {"StartTimerTrigger", 8},
        {"StartTimerTrigger", 9},
        {"StartTimerTrigger", 10},
        {"StartTimerTrigger", 11},
        {"StartTimerTrigger", 12},
        {"StartTimerTrigger", 13},
    },
	End={},
    SendWorldNotify = { {"WorldMsg", "各位少侠，奖章争夺战即将开始，大家可通过查看“最新消息”了解活动内容！", 20} },
    SendNotify = {},
    OpenAct = {},
    CloseAct = {},
    NewMatch = {},
}

function tbAct:OnTrigger(szTrigger)
    Log("MedalFightAct:OnTrigger", szTrigger)
    if szTrigger=="Init" then
        RankBoard:ClearRank(self.szMainKey)
    elseif szTrigger=="Start" then
        Activity:RegisterPlayerEvent(self, "Act_EverydayTargetGainAward", "OnEverydayTargetGainAward")
        Activity:RegisterPlayerEvent(self, "Act_MedalFightReq", "OnClientReq")
        Activity:RegisterPlayerEvent(self, "Act_LeaveMap", "OnLeaveMap")
        Activity:RegisterPlayerEvent(self, "Act_Logout", "OnLogout")
    elseif szTrigger=="End" then
        self:SendRankReward()
    elseif szTrigger=="NewMatch" then
        self:OnNewMatch()
    elseif szTrigger=="OpenAct" then
        self:OnOpenAct()
    elseif szTrigger=="CloseAct" then
        self:OnCloseAct()
    elseif szTrigger=="SendNotify" then
        self:SendNotify()
	end
end

function tbAct:GetRankAward(nRank, nScore)
    local tbAward = {}
    for _, tbInfo in ipairs(self.tbRankAward) do
        if nRank <= tbInfo[1] then
            table.insert(tbAward, tbInfo[2])
            break
        end
    end
    if not next(tbAward) and nScore>=self.nBaseRewardScoreMin then
        table.insert(tbAward, self.tbBaseReward)
    end
    return tbAward
end

function tbAct:SendRankReward()
    RankBoard:Rank(self.szMainKey)

    local tbRankPlayer = RankBoard:GetRankBoardWithLength(self.szMainKey, 99999, 1)
    local tbMail = {Title = "奖章争夺战", From = "系统", nLogReazon = Env.LogWay_MedalFightAct}
    local nSendNum = 0
    for nRank, tbRankInfo in ipairs(tbRankPlayer or {}) do
        local tbAward = self:GetRankAward(nRank, tonumber(tbRankInfo.szValue))
        if not tbAward or not next(tbAward) then
            break
        end
        local szMailText = string.format(self.szMailText, nRank)
        tbMail.Text = szMailText
        tbMail.To = tbRankInfo.dwUnitID
        tbMail.tbAttach = tbAward
        Mail:SendSystemMail(tbMail)
        nSendNum = nRank
        Log("MedalFightAct:SendRankReward, to player", tbRankInfo.dwUnitID, nRank, tbRankInfo.szValue)
    end
    Log("MedalFightAct:SendRankReward", nSendNum)
end

function tbAct:SendNotify()
    local tbMsgData = {
        szType = "MedalFightAct";
        nTimeOut = GetTime() + 5*60;
    };
    Kin:TraverseKin(function(tbKinData)
        tbKinData:TraverseMembers(function (memberData)
            local player = KPlayer.GetPlayerObjById(memberData.nMemberId);
            if player then
                player.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
            end
            return true;
        end) 
    end)
end

function tbAct:GetSortedJoinPlayers()
    local tbPlayers = {}
    for nPlayerId in pairs(self.tbJoinPlayers or {}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer and self:CanJoin(pPlayer) then
            table.insert(tbPlayers, pPlayer)
        else
            self.tbJoinPlayers[nPlayerId] = nil
        end
    end

    local tbRet = {}
    local fn = Lib:GetRandomSelect(#tbPlayers)
    for i=1, #tbPlayers do
        table.insert(tbRet, tbPlayers[fn()])
    end
    return tbRet
end

function tbAct:DealWithTimeoutMatches()
    if not next(self.tbMatchMap or {}) then
        self.tbMatchMap = {}
        return
    end

    for nMatchId in pairs(self.tbMatchMap) do
        self:DoMatchOver(nMatchId)
    end

    self.tbMatchMap = {}
end

function tbAct:DoMatchOver(nMatchId)
    local tb = self.tbMatchMap[nMatchId]
    if not tb then
        return
    end
    local nPlayerId1, nPlayerId2 = 0, 0
    local nScore1, nScore2 = 0, 0
    local tbWinPlayerIds = {}
    local tbLosePlayerIds = {}
    local tbDrawPlayerIds = {}
    for nPlayerId, tbStatus in pairs(tb.tbPlayers) do
        if nPlayerId1<=0 then
            nPlayerId1, nScore1 = nPlayerId, tbStatus.nScore
        else
            nPlayerId2, nScore2 = nPlayerId, tbStatus.nScore
        end
    end
    if nScore1>nScore2 then
        table.insert(tbWinPlayerIds, nPlayerId1)
        table.insert(tbLosePlayerIds, nPlayerId2)
    elseif nScore1<nScore2 then
        table.insert(tbWinPlayerIds, nPlayerId2)
        table.insert(tbLosePlayerIds, nPlayerId1)
    else
        table.insert(tbDrawPlayerIds, nPlayerId1)
        table.insert(tbDrawPlayerIds, nPlayerId2)
    end
    local _, nEndTime = self:GetOpenTimeInfo()
    for _, nPlayerId in ipairs(tbWinPlayerIds) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer then
            self:AddScore(pPlayer, 1)
            pPlayer.SendAward({{"Item", self.nMedalItemId, 1, nEndTime}}, nil, true, Env.LogWay_MedalFightAct)
            pPlayer.SendAward(self.tbWinAward, nil, true, Env.LogWay_MedalFightAct)
            pPlayer.CallClientScript("Activity.MedalFightAct:OnMatchOver", 1)
            self:AddJoinCount(pPlayer, true)
        end
    end
    for _, nPlayerId in ipairs(tbLosePlayerIds) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer then
            self:AddScore(pPlayer, -1)
            pPlayer.ConsumeItemInBag(self.nMedalItemId, 1, Env.LogWay_MedalFightAct)
            pPlayer.SendAward(self.tbLoseAward, nil, true, Env.LogWay_MedalFightAct)
            pPlayer.CallClientScript("Activity.MedalFightAct:OnMatchOver", -1)
            self:AddJoinCount(pPlayer, false)
        end
    end
    for _, nPlayerId in ipairs(tbDrawPlayerIds) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer then
            pPlayer.SendAward(self.tbWinAward, nil, true, Env.LogWay_MedalFightAct)
            pPlayer.CallClientScript("Activity.MedalFightAct:OnMatchOver", 0)
            self:AddJoinCount(pPlayer, true)
        end
    end
end

function tbAct:OnNewMatch()
    self:DealWithTimeoutMatches()

    local tbSorted = self:GetSortedJoinPlayers()
    for i=1, #tbSorted, 2 do
        local p1 = tbSorted[i]
        local p2 = tbSorted[i+1]
        if not p2 then
            Log("MedalFightAct:OnNewMatch, single", p1.dwID)
            break
        end
        self.tbMatchMap[i] = {
            nId = i,
            nCurRound = 1,
            nRoundDeadline = GetTime()+self.nRoundTime+self.nRoundPrepareTime,
            tbQuestions = self:RandomQuestionIds(3),
            tbPlayers = {
                [p1.dwID] = {
                    nScore = 0,
                },
                [p2.dwID] = {
                    nScore = 0,
                },
            },
        }

        local tbPlayer1 = self:GetPlayerMatchInfo(p1)
        local tbPlayer2 = self:GetPlayerMatchInfo(p2)
        local nNow = GetTime()
        p1.CallClientScript("Activity.MedalFightAct:OnNewMatch", self.tbMatchMap[i], tbPlayer2, tbPlayer1, nNow)
        p2.CallClientScript("Activity.MedalFightAct:OnNewMatch", self.tbMatchMap[i], tbPlayer1, tbPlayer2, nNow)

        self.tbJoinPlayers[p1.dwID] = nil
        self.tbJoinPlayers[p2.dwID] = nil
    end
end

function tbAct:GetPlayerMatchInfo(pPlayer)
    local nPlayerId = pPlayer.dwID
    local tbRet = {}
    tbRet.nPlayerId = nPlayerId
    tbRet.szName = pPlayer.szName
    tbRet.nPortrait = pPlayer.nPortrait
    tbRet.nHonorLevel = pPlayer.nHonorLevel

    tbRet.nWinRate = self:GetWinRate(pPlayer)
    tbRet.nMedal = self:GetScore(pPlayer)
    return tbRet
end

function tbAct:OnLogout(pPlayer)
    self:OnReq_Quit(pPlayer)
end

function tbAct:OnLeaveMap(pPlayer, nMapTemplateId, nMapId)
    self:OnReq_Quit(pPlayer)
end

tbAct.tbValidReqs = {
    Join = true,
    Quit = true,
    UpdateStatus = true,
    Answer = true,
    AnswerTimeout = true,
}
function tbAct:OnClientReq(pPlayer, szType, ...)
    if not self.tbValidReqs[szType] then
        return
    end

    local fn = self["OnReq_"..szType]
    if not fn then
        return
    end

    local bOk, szErr = fn(self, pPlayer, ...)
    if not bOk then
        if szErr and szErr~="" then
            pPlayer.CenterMsg(szErr)
            return
        end
    end
end

function tbAct:OnReq_AnswerTimeout(pPlayer, nMatchId)
    local tbMatch = (self.tbMatchMap or {})[nMatchId]
    if not tbMatch then
        return
    end

    if tbMatch.nRoundDeadline>GetTime() then
        return
    end

    if tbMatch.nCurRound>=3 then
        self:MatchOver(nMatchId)
    else
        self:NextRound(nMatchId)
    end
end

function tbAct:OnReq_Answer(pPlayer, nMatchId, nAnswerId)
    local tbMatch = (self.tbMatchMap or {})[nMatchId]
    if not tbMatch then
        return
    end

    local nPlayerId = pPlayer.dwID
    local tbPlayerInfo = tbMatch.tbPlayers[nPlayerId]
    if not tbPlayerInfo or tbPlayerInfo.bRoundOver then
        return
    end

    local nNow = GetTime()
    if tbMatch.nRoundDeadline<nNow then
        return false, "时间已耗尽"
    end

    local nQuestionId = tbMatch.tbQuestions[tbMatch.nCurRound]
    if not self:IsAnswerRight(nQuestionId, nAnswerId) then
        tbPlayerInfo.nScore = (tbPlayerInfo.nScore or 0)+self.nWrongScore
    else
        local nUse = self.nRoundTime-(tbMatch.nRoundDeadline-nNow)
        local nPercent = nUse/self.nRoundTime
        for _, tb in ipairs(self.nRoundTimeScore) do
            if nPercent<=tb[1] then
                tbPlayerInfo.nScore = (tbPlayerInfo.nScore or 0)+tb[2]
                break
            end
        end
    end
    tbPlayerInfo.bRoundOver = true
    self:SyncAnswered(tbMatch, nPlayerId)

    if self:CheckRoundOver(tbMatch) then
        if tbMatch.nCurRound>=3 then
            self:MatchOver(nMatchId)
        else
            self:NextRound(nMatchId)
        end
    end
end

function tbAct:SyncAnswered(tbMatch, nPlayerId)
    local nScore = tbMatch.tbPlayers[nPlayerId].nScore
    for nPid in pairs(tbMatch.tbPlayers) do
        local pPlayer = KPlayer.GetPlayerObjById(nPid)
        if pPlayer then
            pPlayer.CallClientScript("Activity.MedalFightAct:OnSyncAnswered", nPlayerId, nScore)
        end
    end
end

function tbAct:NextRound(nMatchId)
    local tbMatch = (self.tbMatchMap or {})[nMatchId]
    if not tbMatch then
        return
    end

    tbMatch.nCurRound = tbMatch.nCurRound+1
    tbMatch.nRoundDeadline = GetTime()+self.nRoundTime+self.nRoundPrepareTime
    for nPlayerId, tbPlayer in pairs(tbMatch.tbPlayers) do
        tbPlayer.bRoundOver = false

        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer and Kin:IsInKinMap(pPlayer) then
            pPlayer.CallClientScript("Activity.MedalFightAct:OnNextRound", tbMatch.nCurRound, tbMatch.nRoundDeadline, GetTime())
        end
    end
end

function tbAct:MatchOver(nMatchId)
    self:DoMatchOver(nMatchId)
    self.tbMatchMap[nMatchId] = nil
end

function tbAct:CheckRoundOver(tbMatch)
    for nPlayerId, tb in pairs(tbMatch.tbPlayers) do
        if not tb.bRoundOver then
            return false
        end
    end
    return true
end

function tbAct:CanJoin(pPlayer)
    local bOk, szErr = self:CheckPlayer(pPlayer)
    if not bOk then
        return false, szErr
    end
    if not Kin:IsInKinMap(pPlayer) then
        return false, "请到帮派属地中参加"
    end
    local nScore = self:GetScore(pPlayer)
    if nScore<=0 then
        return false, "大侠已经没有奖章了！"
    end
    if not self:CheckJoinCount(pPlayer) then
        return false, "大侠今日参加比赛次数已经达到上限了！"
    end
    return true
end

function tbAct:OnReq_Join(pPlayer)
    if not self.bOpen then
        return false, "比赛时间未到，请到19:00-19:30期间再来！"
    end
    local bOk, szErr = self:CanJoin(pPlayer)
    if not bOk then
        return false, szErr
    end

    local nPlayerId = pPlayer.dwID
    self.tbJoinPlayers[nPlayerId] = true

    self:OnReq_UpdateStatus(pPlayer)
end

function tbAct:OnReq_Quit(pPlayer)
    if not self.bOpen then
        return false, "比赛时间未到，请到19:00-19:30期间再来！"
    end
    local nPlayerId = pPlayer.dwID
    self.tbJoinPlayers[nPlayerId] = nil

    self:OnReq_UpdateStatus(pPlayer)
end

function tbAct:OnReq_UpdateStatus(pPlayer)
    if not self.bOpen then
        return false
    end
    local nPlayerId = pPlayer.dwID
    local tbData = {
        bJoin = not not self.tbJoinPlayers[nPlayerId],
        nEndTime = self.nEndTime,
    }
    pPlayer.CallClientScript("Activity.MedalFightAct:OnUpdateStatus", tbData, GetTime())
end

function tbAct:OnEverydayTargetGainAward(pPlayer, nAwardIdx)
    if not self:CheckPlayer(pPlayer) then
        return
    end
    local nCount = self.tbActiveAward[nAwardIdx]
    if not nCount or nCount<=0 then
        return
    end
    local _, nEndTime = self:GetOpenTimeInfo()
    local tbAward = {{"item", self.nMedalItemId, nCount}}
    tbAward = self:FormatAward(tbAward, nEndTime)
    pPlayer.SendAward(tbAward, true, nil, Env.LogWay_MedalFightAct);
    self:AddScore(pPlayer, nCount)
end

function tbAct:FormatAward(tbAward, nEndTime)
    if not MODULE_GAMESERVER or not Activity:__IsActInProcessByType("MedalFightAct") or not nEndTime then
        return tbAward
    end
    local tbFormatAward = Lib:CopyTB(tbAward or {})
    for _, v in ipairs(tbFormatAward) do
        if v[1] == "item" or v[1] == "Item" then
            v[4] = nEndTime
        end
    end
    return tbFormatAward
end

function tbAct:OnOpenAct()
    self.bOpen = true
    Kin:GatherSetEnable(false)
    self.nEndTime = GetTime()+self.nActDuration
    self.tbJoinPlayers = {}
    Log("MedalFightAct:OnOpenAct")
end

function tbAct:OnCloseAct()
    self:DealWithTimeoutMatches()
    self.bOpen = false
    Kin:GatherSetEnable(true)
    self.tbJoinPlayers = nil
    RankBoard:Rank(self.szMainKey)
	Log("MedalFightAct:OnCloseAct")
end