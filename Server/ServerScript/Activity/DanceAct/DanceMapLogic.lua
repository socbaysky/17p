local DanceMatch = Activity.DanceMatch;
DanceMatch.DanceMapLogic = DanceMatch.DanceMapLogic or {};
local DanceMapLogic = DanceMatch.DanceMapLogic
local tbSetting = DanceMatch.tbSetting

function DanceMapLogic:Init( nMapId , tbPlayerIds)
    self.nMapId = nMapId
    self.nUsedPosIndex = 0;
    self.nCmdPostIndex = 0;
    self.tbScoreRank = {};--{dwRoleId, nToTalScore }
    self.tbPlayerInfos = {}; -- [dwid] = { nCommitIndex = 0, nToTalScore = 0 }
    self.tbReDacnePlayerIds = {};
    self.tbCheckeDeLay = {};
    self.nEndGamePlayerCount = 0
    
    local tbStandPos = DanceMatch.tbSetting.tbStandPos
    self.tbStandPos = tbStandPos[MathRandom(1, #tbStandPos)] 
    local tbDanceSongList = tbSetting.tbDanceSongList
    self.nPlayerSong = tbDanceSongList[MathRandom(1, #tbDanceSongList)]
    self.STATE_TRANS = tbSetting.STATE_TRANS[self.nPlayerSong]
end

function DanceMapLogic:Start()
    self.nSchedulePos = 0;
    local nTotalTime = 0
    for i,v in ipairs(self.STATE_TRANS) do
        nTotalTime = nTotalTime + v.nSeconds
    end
    self.nGameEndTime = nTotalTime + GetTime()

    self:StartSchedule();
end

function DanceMapLogic:OnEnter()
    me.nCanLeaveMapId = self.nMapId
    local nUsedPosIndex = self.nUsedPosIndex + 1;
    self.nUsedPosIndex = nUsedPosIndex
    local tbPos = self.tbStandPos[nUsedPosIndex]
    local x,y,dir = unpack(tbPos)
    me.SetPosition(x,y)
    me.GetNpc().SetDir(dir)
    self.tbPlayerInfos[me.dwID] = {nCommitIndex = 0, nToTalScore = 0, nCombo = 0}
    me.AddSkillState(tbSetting.nForbitMoveSkillState, 1,0, 1800 * Env.GAME_FPS)
    me.CallClientScript("Activity.DanceMatch:OnEnterDanceMatchMap", self.nMapId)
end

function DanceMapLogic:OnLeave()
    me.CallClientScript("Activity.DanceMatch:OnLeaveMap")
    me.RemoveSkillState(tbSetting.nChangeToDogBuffSkill);
    me.RemoveSkillState(tbSetting.nForbitMoveSkillState);
end

function DanceMapLogic:OnLogin()
   me.CallClientScript("Activity.DanceMatch:OnEnterDanceMatchMap", self.nMapId, self.nPlayerSong)
   me.CallClientScript("Player:ServerSyncData", "DanceActRankData", self.tbScoreRank) --如果是切设备登录时，界面还没有打开，这时传过去的数据不会被处理。TODO
   me.CallClientScript("Activity.DanceMatch:OnSynCurSchePos", self.nPlayerSong, self.nSchedulePos, self.nGameEndTime)
end

function DanceMapLogic:CloseBattle()
    if self.nActiveTimer then
        Timer:Close(self.nActiveTimer)
        self.nActiveTimer = nil
    end
    if self.nMainTimer then
        Timer:Close(self.nMainTimer)
        self.nMainTimer = nil
    end
    if self.nMapId then
        local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
        for _, pPlayer in ipairs(tbPlayer) do
            pPlayer.GotoEntryPoint()
        end 
    end
    self.nMapId = nil; --防止一些npc重生在结束游戏后还在添加
end

function DanceMapLogic:OnMapDestroy()
    self:CloseBattle();
end

function DanceMapLogic:StartSchedule()
    local tbLastSchedule = self.STATE_TRANS[self.nSchedulePos]
    if tbLastSchedule then
        Log("StartSchedule Excute", self.nSchedulePos, tbLastSchedule.szFunc, self.nMapId)
        local tbParam = tbLastSchedule.tbParam or {}
        Lib:CallBack({ self[tbLastSchedule.szFunc], self,  unpack(tbParam) })
    end
    self.nMainTimer = nil; --nMainTimer 这样不为空时说明还有定时器未执行，

    self.nSchedulePos = self.nSchedulePos + 1;
    KPlayer.MapBoardcastScript(self.nMapId, "Activity.DanceMatch:OnSynCurSchePos", self.nPlayerSong, self.nSchedulePos, self.nGameEndTime)  

    local tbNextSchedule = self.STATE_TRANS[self.nSchedulePos];
    if not tbNextSchedule then --后面没有timer 就断了
        return
    end

    self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )
end

function DanceMapLogic:DirGotoSchedule(nPos)
    if self.nMainTimer then
        Timer:Close(self.nMainTimer)
        self.nMainTimer = nil;
    end

    self.nSchedulePos = nPos;
    
    KPlayer.MapBoardcastScript(self.nMapId, "Activity.DanceMatch:OnSynCurSchePos", self.nPlayerSong, self.nSchedulePos, self.nGameEndTime)  

    local tbNextSchedule = self.STATE_TRANS[nPos];
    if not tbNextSchedule then --后面没有timer 就断了
        return
    end
    self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )

end

function DanceMapLogic:ShowReady()
    self.bRankChanged = true
    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "ReadyGo")
end

function DanceMapLogic:DoPlayerDance( pPlayer)
    if ChatMgr.ChatEquipBQ:CheckEquipBQ(pPlayer, 1) then
        local tbFactionSexActionInfo = ChatMgr:GetActionInfoByFactionSex(-1, 1, pPlayer.nFaction, pPlayer.nSex)
        if tbFactionSexActionInfo then
            if tbFactionSexActionInfo.ActionEvent and tbFactionSexActionInfo.ActionEvent ~= 0 then
                pPlayer.GetNpc().DoCommonAct(tbSetting.ActionIDAdvance, tbFactionSexActionInfo.ActionEvent, 1, 0, 1);
                return
            end
        end
    end
    pPlayer.GetNpc().DoCommonAct(tbSetting.ActionIDDance, tbSetting.nActionEventDance, 1, 0, 1);         
end

function DanceMapLogic:StartDanceBattle(nType)
    local tbPlayers = KPlayer.GetMapPlayer(self.nMapId)
    local ActionID = tbSetting.ActionIDDance
    local nActionEvent = tbSetting.nActionEventDance
    for i, pPlayer in ipairs(tbPlayers) do
        self:DoPlayerDance(pPlayer)
    end
    self.nCurType = nType
    self.tbCurActiveSetting = tbSetting.tbCmdSetting[self.nPlayerSong][nType]

    if nType == tbSetting.TYPE_NORMAL then
        self.nActiveCount = 0;
        self:Active()
        self.nActiveTimer = Timer:Register(Env.GAME_FPS, function ()
            self.nActiveCount = self.nActiveCount + 1
            self:Active()
            return true
        end)
        KPlayer.MapBoardcastScript(self.nMapId, "Map:PlaySceneOneSound", self.nPlayerSong)
    end
end

function DanceMapLogic:ShowTips(szTips)
    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "BattleFieldTips", szTips)
end

function DanceMapLogic:GetPlayerObjById(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    if pPlayer.nMapId ~= self.nMapId then
        return
    end
    return pPlayer
end

function DanceMapLogic:Active()
    self:SyncAllInfo()
    local nNow = GetTime()
    if self.nValidTimeTo and self.nValidTimeTo == nNow then
        for dwRoleId,_ in pairs(self.tbCheckeDeLay) do
           local pPlayer = self:GetPlayerObjById(dwRoleId)
           if pPlayer then
                local tbInfo = self.tbPlayerInfos[dwRoleId]
                if not tbInfo.bEndGame then
                    self:OnPlayerError(pPlayer, tbInfo)
                end
           end
        end
        self.tbCheckeDeLay = {};
    end
    local tbCmdSetting = self.tbCurActiveSetting[self.nActiveCount]
    if not tbCmdSetting then
        return
    end
    if next(self.tbReDacnePlayerIds)  then
        for dwRoleId,_ in pairs(self.tbReDacnePlayerIds) do
            local pPlayer = self:GetPlayerObjById(dwRoleId)
            if pPlayer then
                self:DoPlayerDance(pPlayer)
            end
        end
        self.tbReDacnePlayerIds = {};
    end
    local tbCMDList = {};
    local tbCmdStr = tbSetting.tbCmdStr
    for i=1,tbCmdSetting.nCmdLen do
        local str = tbCmdStr[MathRandom( 1, #tbCmdStr)] 
        table.insert(tbCMDList, str)
    end
    self.nCmdPostIndex = self.nCmdPostIndex + 1;
    
    self.nValidTimeFrom = nNow
    self.nValidTimeTo = nNow + tbCmdSetting.nDurTime
    self.nPerfectTimeLimit = nNow + math.floor(tbCmdSetting.nDurTime / 2)
    self.szCurCMDList = table.concat( tbCMDList, "")
    self.tbCheckeDeLay = Lib:CopyTB(self.tbPlayerInfos)
    KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "DanceActCMD", tbCMDList, self.nValidTimeFrom, self.nValidTimeTo)
end

function DanceMapLogic:SyncAllInfo()
    if self.bRankChanged then
        self.bRankChanged = nil;
        self:UpdatePlayerRank()
        KPlayer.MapBoardcastScript(self.nMapId, "Player:ServerSyncData", "DanceActRankData", self.tbScoreRank)
    end
end

function DanceMapLogic:UpdatePlayerRank()
    local tbScoreRank = {}
    for k, v in pairs(self.tbPlayerInfos) do
        table.insert(tbScoreRank, {k, v.nToTalScore})
    end
    table.sort( tbScoreRank, function (a, b)
        return  a[2] > b[2]
    end )
    self.tbScoreRank = tbScoreRank
end

function DanceMapLogic:CommitDanceCMD(pPlayer, szDanceCmd)
    local nNow = GetTime()
    if nNow < self.nValidTimeFrom or nNow > self.nValidTimeTo + 2 then
        pPlayer.CenterMsg("已超时")
        return
    end
    local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
    if not tbInfo then
        Log(debug.traceback(), pPlayer.dwID)
        return
    end
    if tbInfo.bEndGame then
        pPlayer.CenterMsg("您已不再允许比赛了")
        return
    end
    if tbInfo.nCommitIndex >= self.nCmdPostIndex then
        pPlayer.CenterMsg("已提交过该操作")
        return
    end
    tbInfo.nCommitIndex = self.nCmdPostIndex
    self.tbCheckeDeLay[pPlayer.dwID] = nil;


    if szDanceCmd == self.szCurCMDList then
        local nWinAddScore = tbSetting.tbWinAddScore[self.nCurType]
        local bPerfect = false
        if nNow <= self.nPerfectTimeLimit then
            bPerfect = true
            nWinAddScore = nWinAddScore * 2
        end
        tbInfo.nToTalScore = tbInfo.nToTalScore + nWinAddScore;
        self.bRankChanged = true
        tbInfo.nCombo = tbInfo.nCombo + 1;
        local nComboAddScore = tbSetting.tbCommoboAddScore[tbInfo.nCombo]
        if nComboAddScore then
            tbInfo.nToTalScore = tbInfo.nToTalScore + nComboAddScore;
        end
        local tbSynData = {
            nToTalScore = tbInfo.nToTalScore;
            nWinAddScore = nWinAddScore;
            bPerfect = bPerfect;
            nComboAddScore = nComboAddScore;
            nCombo = tbInfo.nCombo;
        }
        pPlayer.CallClientScript("Player:ServerSyncData", "DanceActGetScore", tbSynData )
    else
       self:OnPlayerError(pPlayer, tbInfo) 
    end
end

function DanceMapLogic:OnPlayerError(pPlayer, tbInfo)
    local bEndGame = self.nCurType == tbSetting.TYPE_FINAL
    tbInfo.nCombo = 0
    if bEndGame then
        tbInfo.bEndGame = true
        pPlayer.GetNpc().DoCommonAct(1, 0, 1, 0, 0);         
        pPlayer.AddSkillState(tbSetting.nChangeToDogBuffSkill, 1,0, 1800 * Env.GAME_FPS)
        self.tbReDacnePlayerIds[pPlayer.dwID] = nil    
        self.nEndGamePlayerCount = self.nEndGamePlayerCount + 1;
        if self.nEndGamePlayerCount == self.nUsedPosIndex then
            self:StopGame()
            self:DirGotoSchedule(#self.STATE_TRANS)
        end
    else
        pPlayer.GetNpc().DoCommonAct(tbSetting.ActionIDCry, tbSetting.nActionEventCry, 1, 0, 1);         
        Timer:Register(math.floor(Env.GAME_FPS * tbSetting.nCryTime) , self.PlayerReDance, self, pPlayer.dwID)
        self.tbReDacnePlayerIds[pPlayer.dwID] = 1    
    end
    
    pPlayer.CallClientScript("Activity.DanceMatch:OnDanceFail",  bEndGame)
end

function DanceMapLogic:PlayerReDance(dwRoleId)
    if not self.tbReDacnePlayerIds[dwRoleId] then
        return
    end
    self.tbReDacnePlayerIds[dwRoleId] = nil
    local pPlayer = self:GetPlayerObjById(dwRoleId)
    if not pPlayer then
        return
    end
    self:DoPlayerDance(pPlayer)
end

function DanceMapLogic:GetAward(nRank)
    for i, v in ipairs() do
        if nRank <= v.nRandEnd then
            return v.Award
        end
    end
end

function DanceMapLogic:StopGame()
    if self.nActiveTimer then
        Timer:Close(self.nActiveTimer)
        self.nActiveTimer = nil
    end
    self:UpdatePlayerRank()

    local pRank = KRank.GetRankBoard(tbSetting.szRankboardKey)

    local nFrom = 1
    for i,v in ipairs(tbSetting.tbAwardSetting) do
        local tbAward = v.Award
        for nPos = nFrom, v.nRankEnd do
            local tbScore = self.tbScoreRank[nPos]
            if tbScore then
                local dwRoleId, nCurScore = unpack(tbScore)        
                local nToTalScore = nCurScore
                local tbRankInfo = pRank.GetRankInfoByID(dwRoleId)
                if tbRankInfo then
                    nToTalScore = nToTalScore + tbRankInfo.nLowValue
                end
                pRank.UpdateValueByID(dwRoleId, nToTalScore)

                Mail:SendSystemMail({
                    To = dwRoleId;
                    Title = tbSetting.szActName;
                    Text = string.format(tbSetting.szMailContent, nPos);
                    tbAttach = tbAward; 
                    nLogReazon = Env.LogWay_DanceAct;
                    })

            else
                break;
            end
        end
        nFrom = v.nRankEnd + 1        
    end
    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "QYHLeavePanel", {BtnLeave=true})
end

