local tbBase = Fuben:CreateFubenClass("TeachersDayActFubenBase")
function tbBase:OnPreCreate(nTeacherId, nStudentId)
    self.nTeacherId = nTeacherId
    self.nStudentId = nStudentId
end

function tbBase:OnLogin()
   self:OpenFubenUi(pPlayer) 
end

function tbBase:OnJoin(pPlayer)
   self:OpenFubenUi(pPlayer) 
end

function tbBase:OpenFubenUi(pPlayer)
    if self.tbCacheProgressInfo then
        pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
    end
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben")
end

function tbBase:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, szNpcType)
    self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, szNpcType)
end

function tbBase:OnAddNpc(pNpc, szNpcType) 
    if szNpcType == "OnlyTeacher" then
        local pStudent = KPlayer.GetPlayerObjById(self.nStudentId)
        if pStudent then
            pStudent.SetPkMode(3, 1)
            pNpc.SetPkMode(3, 1)
        end
        local pTeacher = KPlayer.GetPlayerObjById(self.nTeacherId)
        if pTeacher then
            pTeacher.SetPkMode(3, 2)
        end
    elseif szNpcType == "OnlyStudent" then
        local pTeacher = KPlayer.GetPlayerObjById(self.nTeacherId)
        if pTeacher then
            pTeacher.SetPkMode(3, 1)
            pNpc.SetPkMode(3, 1)
        end
        local pStudent = KPlayer.GetPlayerObjById(self.nStudentId)
        if pStudent then
            pStudent.SetPkMode(3, 2)
        end
    elseif szNpcType == "TopBoss" then
        Npc:RegisterNpcHpPercent(pNpc, 1, function ()
            self:OnBossPercentChange()
        end)
    end
end

function tbBase:OnBossPercentChange()
    local nLastDmgPlayerID = him.GetLastDmgMePlayerID()
    if nLastDmgPlayerID == self.nStudentId then
        him.DoDeath()
        return
    end

    him.SetCurLife(0.2*him.nMaxLife)
    Npc:RegisterNpcHpPercent(him, 1, function ()
            self:OnBossPercentChange()
        end)
    local function fnNpcBubbleTalk(pPlayer)
        pPlayer.CallClientScript("Ui:NpcBubbleTalk", him.nId, self.tbSetting.szKillBossTip, self.tbSetting.nKillBossTopDur, 1)
    end
    self:AllPlayerExcute(fnNpcBubbleTalk)
end

function tbBase:OnPlayerDeath()
    me.Revive(0)
end

function tbBase:OnLeaveMap(pPlayer)
    pPlayer.ClearTempRevivePos()
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
    if self.bClose == 1 then
        return
    end
    self:GameLost()
end

function tbBase:GameLost()
    self.nDealyKickOutAllMapPlayerTime = 1
    self:Close()
end

function tbBase:GameWin()
    Activity:OnGlobalEvent("Act_CompleteTeacherFuben", self.nTeacherId, self.nStudentId)
    self.nDealyKickOutAllMapPlayerTime = 5
    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "LingJueFengLayerPanel", "Win")
    self:Close()
end