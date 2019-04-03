local tbFuben = Fuben:CreateFubenClass("KinSecretFuben")

local tbBossGrps = {"BOSS1", "BOSS2", "BOSS3A", "BOSS3B"}

function tbFuben:OnPreCreate(dwKinId, nIdx)
    self.bBegan  = false
    self.bOpenSuccess    = false
    self.dwKinId         = dwKinId
    self.nIdx = nIdx
    self.nPassed = 0    --通关数
    self.tbDeathInfo = {}
    self.nDeathCount = 0    --玩家死亡次数
    self.tbRoomPlayerIds = {}
    self.bReward = false
    self.tbTrapOpened = {}
end

function tbFuben:OnLogin()
    self:OnJoin(me)
end

function tbFuben:SyncJoinCount(nDelta)
    local _, nPlayerNum = KPlayer.GetMapPlayer(self.nMapId)
    nPlayerNum = nPlayerNum+nDelta
    if nPlayerNum<=0 then
        return
    end
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinSecretMgr:OnSyncFubenJoinCount", nPlayerNum)
end

function tbFuben:SyncDeathCount()
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinSecretMgr:OnSyncFubenDeathCount", self.nDeathCount)
end

function tbFuben:OnJoin(pPlayer)
    if not self.bBegan and GetTime()>(Fuben.KinSecretMgr.nStartTime+Fuben.KinSecretMgr.Def.nPrepareTime) then
        self:BeginSecret()
    end

    local nPlayerId = pPlayer.dwID
    local bShowLeave = not self.bBegan or self.bClose == 1
    local nEndTime   = Fuben.KinSecretMgr:GetEndTime() or 0
    pPlayer.CallClientScript("Fuben.KinSecretMgr:OnEntryMap", bShowLeave, nEndTime)

    if self.bClose ~= 1 and self.tbCacheProgressInfo then
        pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
    end

    Kin:JoinChatRoom(pPlayer)

    if self.bBegan then
        self:OnJoinActiviy(pPlayer)
    end
    pPlayer.nCanLeaveMapId = self.nMapId
    if not pPlayer.nRoom or pPlayer.nRoom<=0 then
        pPlayer.nFightMode = 0
    end
    if pPlayer.nOnLeaveKinRegID and pPlayer.nOnLeaveKinRegID>0 then
        PlayerEvent:UnRegister(pPlayer, "OnLeaveKin", pPlayer.nOnLeaveKinRegID)
    end
    pPlayer.nOnLeaveKinRegID = PlayerEvent:Register(pPlayer, "OnLeaveKin", self.OnPlayerLeaveKin, self)

    self:SyncJoinCount(0)
    Log("KinSecretFuben:OnJoin", self.dwKinId, self.nIdx, nPlayerId, pPlayer.nLevel)
end

function tbFuben:OnPlayerLeaveKin()
    Fuben.KinSecretMgr.tbHadAddFlag[me.dwID] = nil
    me.GotoEntryPoint()
    Log("KinSecretFuben:OnPlayerLeaveKin", self.dwKinId, self.nIdx, me.dwID)
end

function tbFuben:OnLeaveMap(pPlayer)
    if pPlayer.nOnLeaveKinRegID and pPlayer.nOnLeaveKinRegID>0 then
        PlayerEvent:UnRegister(pPlayer, "OnLeaveKin", pPlayer.nOnLeaveKinRegID)
    end
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
    ChatMgr:LeaveKinChatRoom(pPlayer);
    self:LeaveRoom(pPlayer, pPlayer.nRoom)
    self:SyncJoinCount(-1)
end

function tbFuben:OnJoinActiviy(pPlayer)
    if not pPlayer or Fuben.KinSecretMgr.tbHadAddFlag[pPlayer.dwID] then
        return
    end

    local nPlayerId = pPlayer.dwID
    Fuben.KinSecretMgr.tbHadAddFlag[nPlayerId] = 1
    EverydayTarget:AddCount(pPlayer, "KinSecretFuben", 1)
    Log("KinSecretFuben:OnJoinActiviy", self.dwKinId, self.nIdx, nPlayerId)
end

function tbFuben:BeginSecret()
    self.bBegan = true
    local tbPlayer, nPlayerNum = KPlayer.GetMapPlayer(self.nMapId)
    if nPlayerNum < Fuben.KinSecretMgr.Def.nJoinMin then
        self:Close()
        KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinSecretMgr:OnFubenStartFail")
        return
    end

    for _, pPlayer in pairs(tbPlayer) do
        self:OnJoinActiviy(pPlayer)
    end

    local nEndTime = Fuben.KinSecretMgr:GetEndTime() or 0
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinSecretMgr:OnTrainBegin", false, nEndTime)
    self:UnLock(100)
    self.bOpenSuccess = true
    Log("KinSecretFuben:BeginSecret", self.dwKinId, self.nIdx, self.nMapId, nPlayerNum)
end

function tbFuben:OnPlayerDeath()
    me.bAoeAvoidActive = nil
    me.nFightMode = 2
    self.tbDeathInfo[me.dwID] = (self.tbDeathInfo[me.dwID] or 0) + 1;
    local nReviveTime = math.min(self.tbDeathInfo[me.dwID]*Fuben.KinSecretMgr.Def.nReviveAddTime, Fuben.KinSecretMgr.Def.nReviveMaxTime)
    Timer:Register(nReviveTime * Env.GAME_FPS, self.DoRevive, self, me.dwID);
    me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", "您将在 %d 秒後复活", nReviveTime)

    me.Revive(1);
    me.RestoreAll();
    me.AddSkillState(Fuben.KinSecretMgr.Def.nDeathSkillId, 1, 0, 10000);
    if self.tbSetting.tbTempRevivePoint then
        me.SetPosition(unpack(self.tbSetting.tbTempRevivePoint))
    end

    local nRoom = me.nRoom
    local bReset = false
    if nRoom then
        bReset = self:LeaveRoom(me, me.nRoom)
    end

    if not bReset then
        self.nDeathCount = math.min(self.nDeathCount+1, Fuben.KinSecretMgr.Def.nPlayerDieBossAddBuffMaxLvl)
        self:SyncDeathCount()
        if self.nDeathCount<Fuben.KinSecretMgr.Def.nPlayerDieBossAddBuffMaxLvl then
            for _, szBoss in ipairs(tbBossGrps) do
                if self.tbNpcGroup[szBoss] then
                    self:NpcRemoveBuff(szBoss, Fuben.KinSecretMgr.Def.nPlayerDieBossAddBuffId)
                    self:NpcAddBuff(szBoss, Fuben.KinSecretMgr.Def.nPlayerDieBossAddBuffId, self.nDeathCount, 99999)
                end
            end
            self:SendCenterMsg(string.format("%s死亡，boss变的更强了", me.szName))
        end
    end
    Log("KinSecretFuben:OnPlayerDeath", self.dwKinId, me.dwID, self.nIdx, nRoom, self.nPassed)
end

function tbFuben:CheckResetRoom(nRoom)
    if nRoom~=(self.nPassed+1) then
        return false
    end
    if next(self.tbRoomPlayerIds[nRoom] or {}) then
        return false
    end

    self.nDeathCount = 0
    self:SyncDeathCount()
    self.bBoss3BDeath = nil
    for _, szBoss in ipairs(tbBossGrps) do
        if self.tbNpcGroup[szBoss] then
            self:DelNpc(szBoss)
        end
    end
    if self.tbNpcGroup[Fuben.KinSecretMgr.Def.szPick2DeathDropNpcGrp] then
        self:DelNpc(Fuben.KinSecretMgr.Def.szPick2DeathDropNpcGrp)
    end
    local tbBosses = Fuben.KinSecretMgr.Def.tbRoomBosses[nRoom]
    if not tbBosses then
        Log("[x] KinSecretFuben:CheckResetRoom, no boss cfg", self.dwKinId, self.nIdx, nRoom)
        return false
    end
    for _, tbBoss in ipairs(tbBosses) do
        local nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime = unpack(tbBoss)
        self:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime)
    end

    self:SendBlackBoardMsg("全军覆没，当前关卡被重置")
    Log("KinSecretFuben:CheckResetRoom", self.dwKinId, self.nIdx, self.nPassed, nRoom)
    return true
end

function tbFuben:ManualKick(nTarget)
    local pTarget = KPlayer.GetPlayerObjById(nTarget or 0)
    if not pTarget or pTarget.nMapId~=self.nMapId then
        return false
    end

    pTarget.Msg(string.format("管理已申请将你踢回准备场，%d秒後生效", Fuben.KinSecretMgr.Def.nKickWaitTime))
    Timer:Register(Env.GAME_FPS*Fuben.KinSecretMgr.Def.nKickWaitTime, function()
        local pTarget = KPlayer.GetPlayerObjById(nTarget)
        if not pTarget then
            return
        end
        self:LeaveRoom(pTarget, pTarget.nRoom)
        pTarget.bAoeAvoidActive = nil
        pTarget.SetPosition(unpack(self.tbSetting.tbTempRevivePoint))
        pTarget.nFightMode = 0
    end)
    return true
end

function tbFuben:DoRevive(nPlayerId)
    if self.bClose == 1 then
        return;
    end

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer or pPlayer.nMapId~=self.nMapId then
        return;
    end
    pPlayer.RemoveSkillState(Fuben.KinSecretMgr.Def.nDeathSkillId);

    if pPlayer.nFightMode ~= 2 then
        return;
    end

    pPlayer.nFightMode = 0;
end

function tbFuben:OnTimeOut()
    if self.bClose == 1 then
        return
    end

    self:UnLock(2000)
    self:Close()

    Log("KinSecretFuben:OnTimeOut", self.dwKinId, self.nIdx, self.nMapId)
end

function tbFuben:OnClose()
    Timer:Register(Env.GAME_FPS*60*10, self.KickoutPlayer, self)
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinSecretMgr:OnFubenOver", "帮派秘境已结束，请离开")
end

function tbFuben:OnSendReward()
    if self.bReward then return end
    self.bReward = true

    if self.nPassed<=0 then
        Log("KinSecretFuben:OnSendReward, no reward", self.dwKinId, self.nIdx, self.nPassed)
        return
    end
    
    local nBoxCount = 0
    for i=1, self.nPassed do
        nBoxCount = nBoxCount+Fuben.KinSecretMgr.Def.tbLevelRewardBoxCount[i]
    end
    local tbMail = {
        To = nil,
        Title = "帮派秘境",
        Text = "大侠与同帮派袍泽浴血奋战，在秘境中力战历代武林盟主不落下风，实乃当代武林翘楚。以下是大侠此战中获得的奖励，请查收！",
        From = "帮派总管",
        tbAttach = {{"item", Fuben.KinSecretMgr.Def.nLevelRewardBoxId, nBoxCount}},
        nLogReazon = Env.LogWay_KinSecretFuben,
    }
    local tbPlayers = KPlayer.GetMapPlayer(self.nMapId)
    local tbAutionPlayers = {}
    for _, pPlayer in ipairs(tbPlayers) do
        local nPlayerId = pPlayer.dwID
        local bSend = Fuben.KinSecretMgr.tbRewardedPlayers[nPlayerId]
        if not bSend then
            tbMail.To = nPlayerId
            Mail:SendSystemMail(tbMail)
            Fuben.KinSecretMgr.tbRewardedPlayers[nPlayerId] = true

            tbAutionPlayers[nPlayerId] = true
        end
        Log("KinSecretFuben:SendReward to player", self.dwKinId, self.nIdx, self.nPassed, nPlayerId, tostring(not not bSend))
    end
    Log("KinSecretFuben:SendReward", self.dwKinId, self.nIdx, self.nPassed, nBoxCount)

    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("%s字型大小秘境成功完成挑战，获得奖励已加入拍卖库，请等待20:55拍卖开始", Fuben.KinSecretMgr.Def.tbRoomNames[self.nIdx]), self.dwKinId)
    Fuben.KinSecretMgr:SetKinResult(self.dwKinId, self.nIdx, tbAutionPlayers, self.nPassed)
end

function tbFuben:KickoutPlayer()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.GotoEntryPoint()
    end
end

function tbFuben:SendCenterMsg(szMsg)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.CenterMsg(szMsg)
    end
end

function tbFuben:SendBlackBoardMsg(szMsg)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
        Dialog:SendBlackBoardMsg(pPlayer, szMsg)
    end
end

function tbFuben:MemberJoinKinChatRoom()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
         Kin:JoinChatRoom(pPlayer)
    end
end

function tbFuben:OnPickAOE(szNpcGroup)
    local tbRoomPlayers = self.tbRoomPlayerIds[1] or {}
    if not next(tbRoomPlayers) then
        return
    end

    local tbIds = {}
    for nPlayerId in pairs(tbRoomPlayers) do
        table.insert(tbIds, nPlayerId)
    end

    local nIdx = MathRandom(#tbIds)
    local nPlayerId = tbIds[nIdx]
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return
    end

    self:NpcBubbleTalk(szNpcGroup, string.format("[FFFE0D]%s[-]，你已被我注入天煞真气了！", pPlayer.szName), 10, 0, 1)
    Dialog:SendBlackBoardMsg(pPlayer, string.format("[FFFE0D]%s[-]，请速速离开人群！", pPlayer.szName))

    local nSkillId, nLevel = unpack(Fuben.KinSecretMgr.Def.tbAoeSkillCfg)
    self:CastSkill("BOSS1", nSkillId, nLevel, -1, pPlayer.GetNpc().nId)

    local function _AddAoeAvoidBuff()
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer or pPlayer.nMapId~=self.nMapId then
            return
        end

        local nBuffId, nBuffLvl, nBuffTime = unpack(Fuben.KinSecretMgr.Def.tbAoeAvoidBuff)
        pPlayer.AddSkillState(nBuffId, nBuffLvl, 0, nBuffTime*Env.GAME_FPS)
    end
    if Fuben.KinSecretMgr.Def.nAoeAvoidBuffDelayAdd<=0 then
        _AddAoeAvoidBuff()
    else
        Timer:Register(Env.GAME_FPS*Fuben.KinSecretMgr.Def.nAoeAvoidBuffDelayAdd, _AddAoeAvoidBuff)
    end
end

function tbFuben:OnPick2(szNpcGroup, bMustSeparate)
    local tbRoomPlayers = self.tbRoomPlayerIds[3] or {}
    local nCount = Lib:CountTB(tbRoomPlayers)
    if nCount<2 then
        return
    end
    local tbIds = {}
    for nPlayerId in pairs(tbRoomPlayers) do
        table.insert(tbIds, nPlayerId)
    end

    local nPlayer1 = tbIds[MathRandom(nCount)]
    local nPlayer2 = nil
    while true do
        local nIdx = MathRandom(nCount)
        if tbIds[nIdx]~=nPlayer1 then
            nPlayer2 = tbIds[nIdx]
            break
        end
    end

    local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1)
    local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2)
    if not pPlayer1 or not pPlayer2 then
        return
    end

    local tbPlayerBuff = Fuben.KinSecretMgr.Def.tbBoss3PlayerBuffB
    local szBuffName, szDir = "异极真气", "靠近"
    if bMustSeparate then
        szBuffName, szDir = "同极真气", "远离"
        tbPlayerBuff = Fuben.KinSecretMgr.Def.tbBoss3PlayerBuffA
    end

    local nPlayerBuffId, nPlayerBuffTime = unpack(tbPlayerBuff)
    pPlayer1.AddSkillState(nPlayerBuffId, 1, 0, nPlayerBuffTime*Env.GAME_FPS)
    pPlayer2.AddSkillState(nPlayerBuffId, 1, 0, nPlayerBuffTime*Env.GAME_FPS)

    self:NpcBubbleTalk(szNpcGroup, string.format("[FFFE0D]%s、%s[-]，你二人已被我注入%s了！", pPlayer1.szName, pPlayer2.szName, szBuffName), 10, 0, 1)
    Dialog:SendBlackBoardMsg(pPlayer1, string.format("[FFFE0D]%s、%s[-]，请速速[FFFE0D]%s[-]对方！", pPlayer1.szName, pPlayer2.szName, szDir))
    Dialog:SendBlackBoardMsg(pPlayer2, string.format("[FFFE0D]%s、%s[-]，请速速[FFFE0D]%s[-]对方！", pPlayer2.szName, pPlayer1.szName, szDir))

    local function _Check()
        local tbRoomPlayers = self.tbRoomPlayerIds[3] or {}
        if not tbRoomPlayers[nPlayer1] or not tbRoomPlayers[nPlayer2] then
            return
        end

        local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1)
        local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2)
        if not pPlayer1 or not pPlayer2 or pPlayer1.nMapId~=self.nMapId or pPlayer2.nMapId~=self.nMapId then
            return
        end

        local nDistance = pPlayer1.GetNpc().GetDistance(pPlayer2.GetNpc().nId)
        local bFail = nDistance>Fuben.KinSecretMgr.Def.nPick2DistanceB
        if bMustSeparate then
            bFail = nDistance<Fuben.KinSecretMgr.Def.nPick2DistanceA
        end
        if not bFail then
            return
        end

        local pPlayers = {pPlayer1, pPlayer2}
        for _, pPlayer in ipairs(pPlayers) do
            local nMapId, x, y = pPlayer.GetWorldPos()
            local pNpc = KNpc.Add(Fuben.KinSecretMgr.Def.nPick2DeathDropNpcId, 1, -1, nMapId, x, y)
            if pNpc then
                self:AddNpcInGroup(pNpc, Fuben.KinSecretMgr.Def.szPick2DeathDropNpcGrp)
            end
            pPlayer.GetNpc().DoDeath()
        end
    end
    if Fuben.KinSecretMgr.Def.nPick2DelayCheck<=0 then
        _Check()
    else
        Timer:Register(Env.GAME_FPS*Fuben.KinSecretMgr.Def.nPick2DelayCheck, _Check)
    end
end

function tbFuben:OnPassLevel(nLevel)
    self.nPassed = nLevel
    self.nDeathCount = 0
    self:SyncDeathCount()
end

function tbFuben:OnOpenTrap(szTrapName)
    self.tbTrapOpened = self.tbTrapOpened or {}
    self.tbTrapOpened[szTrapName] = true
end

function tbFuben:OnSetNpcTitle(szNpcGroup, szNpcTitle)
    if not self.tbNpcGroup[szNpcGroup] then
        Log("[x] KinSecretFuben:OnSetNpcTitle nogrp", self.dwKinId, szNpcGroup)
        return
    end

    for _, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
        local pNpc = KNpc.GetById(nNpcId)
        if pNpc then
            pNpc.SetTitle(szNpcTitle)
        end
    end
end

function tbFuben:GetTrapRoom(szTrapName)
    local tbTrap2Room = {
        trap1 = 1,
        trap2 = 2,
        trap3 = 3,
    }
    return tbTrap2Room[szTrapName]
end

function tbFuben:EnterRoom(pPlayer, nRoom)
    if not nRoom or nRoom>(self.nPassed+1) or pPlayer.nRoom==nRoom then
        return
    end

    self:LeaveRoom(pPlayer, pPlayer.nRoom)

    self.tbRoomPlayerIds[nRoom] = self.tbRoomPlayerIds[nRoom] or {}
    self.tbRoomPlayerIds[nRoom][pPlayer.dwID] = true
    pPlayer.nRoom = nRoom
    pPlayer.nFightMode = 1
end

function tbFuben:LeaveRoom(pPlayer, nRoom)
    if not nRoom then
        return false
    end

    self.tbRoomPlayerIds[nRoom] = self.tbRoomPlayerIds[nRoom] or {}
    self.tbRoomPlayerIds[nRoom][pPlayer.dwID] = nil
    pPlayer.nRoom = nil

    return self:CheckResetRoom(nRoom)
end

local tbPlayerSeries = {"jin", "mu", "shui", "huo", "tu"}

function tbFuben:OnPlayerTrap(szTrapName)
    if not self.bBegan or me.nFightMode==2 then
        return
    end
    Fuben.tbBase.OnPlayerTrap(self, szTrapName)
    if self.tbTrapOpened[szTrapName] then
        local nRoom = self:GetTrapRoom(szTrapName)
        self:EnterRoom(me, nRoom)
    end

    self:CheckBoss2Trap(me, szTrapName)
end

function tbFuben:CheckBoss2Trap(pPlayer, szTrapName)
    if self.nPassed~=1 then
        return
    end

    local szIn = Fuben.KinSecretMgr.Def.tbTrapIn[szTrapName]
    if szIn then
        local tbPlayerInfo = KPlayer.GetPlayerInitInfo(pPlayer.nFaction, pPlayer.nSex)
        if szIn==tbPlayerSeries[tbPlayerInfo.nSeries] then
            pPlayer.bAoeAvoidActive = true
        end
        return
    end
    local szOut = Fuben.KinSecretMgr.Def.tbTrapOut[szTrapName]
    if szOut then
        pPlayer.bAoeAvoidActive = nil
        return
    end
end

local tbNpc = Npc:GetClass("KinSecretNpc2")
function tbFuben:OnNpcTrap(szTrapName)
    Fuben.tbBase.OnNpcTrap(self, szTrapName)
    tbNpc:OnTrap(him, szTrapName)
end

function tbFuben:OnBoss2Aoe()
    local nBuffId, nTime = unpack(Fuben.KinSecretMgr.Def.tbBoss2PlayerAoeBuff)
    local tbPlayers = self.tbRoomPlayerIds[2] or {}
    for nPlayerId in pairs(tbPlayers) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer and pPlayer.bAoeAvoidActive then
            self:OnUseSkillState(nBuffId)
            pPlayer.AddSkillState(nBuffId, 1, 0, nTime * Env.GAME_FPS)
        end
    end
end

function tbFuben:OnBoss3ADeath()
    if not self.bBoss3BDeath then
        local tbBoss = Fuben.KinSecretMgr.Def.tbRoomBosses[3][1]
        local nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime = unpack(tbBoss)
        self:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime)
        self:SendBlackBoardMsg("糟了，张琳心使独孤剑重生了")
        return
    end
    self:UnLock(1000)
end

function tbFuben:OnBoss3BDeath()
    self.bBoss3BDeath = true
    local nBuffId, nLevel = unpack(Fuben.KinSecretMgr.Def.nBoss3ACrazyBuff)
    self:NpcAddBuff("BOSS3A", nBuffId, nLevel, 99999)
    self:SendBlackBoardMsg("不好，独孤剑因为张琳心被击杀变得狂暴异常！")
end

function tbFuben:OnOpenRewardBox(pPlayer, pNpc)
    if not pNpc then
        return;
    end

    self:SendBlackBoardMsg(string.format("[FFFE0D]%s[-]打开了宝箱，快去查看自己的礼物吧！", pPlayer.szName))

    Fuben:NpcUnLock(pNpc);
    pNpc.Delete();
end