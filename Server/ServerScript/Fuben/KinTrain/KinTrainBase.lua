local tbFuben = Fuben:CreateFubenClass("KinTrainBase")
function tbFuben:OnPreCreate(dwKinId, bDefend)
    self.tbMaterialGroup = {}
    self.tbPushMatInfo   = {} --实时更新物资信息的玩家列表
    self.tbEnterTime     = {} --玩家进入时间，在准备时间内进进出出会重置进入时间
    self.bTrainHadBegin  = false
    self.bOpenSuccess    = false
    self.dwKinId         = dwKinId
    self.tbJoinPlayer    = {}
    self.tbHadAddFlag    = {}
    self.bDefend         = bDefend
    self.Def             = bDefend and Fuben.KinTrainMgr.DefendFubenDef or Fuben.KinTrainMgr.FubenDef
end

function tbFuben:OnLogin()
    self:OnJoin(me)
end

function tbFuben:OnJoin(pPlayer)
    local bShowLeave = not self.bTrainHadBegin or self.bClose == 1
    local nEndTime   = Fuben.KinTrainMgr:GetEndTime() or 0
    pPlayer.CallClientScript("Fuben.KinTrainMgr:OnEntryMap", bShowLeave, nEndTime)

    if self.bClose ~= 1 and self.tbCacheProgressInfo then
        pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
    end

    self.tbEnterTime[pPlayer.dwID] = self.tbEnterTime[pPlayer.dwID] or GetTime()
    Kin:JoinChatRoom(pPlayer)

    if not self.tbJoinPlayer[pPlayer.dwID] and pPlayer.nHonorLevel > 2 and pPlayer.nLevel > Fuben.KinTrainMgr.AUCTION_LEVEL then
        self.tbJoinPlayer[pPlayer.dwID] = true
    end

    if self.bTrainHadBegin then
        self:OnJoinActiviy(pPlayer)
    end
    pPlayer.nCanLeaveMapId = self.nMapId
    Log("KinTrainBase Join:", pPlayer.dwID, pPlayer.nLevel, pPlayer.nHonorLevel, tostring(self.tbJoinPlayer[pPlayer.dwID]))
end

function tbFuben:OnLeaveMap(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")

    if self.bTrainHadBegin then
        local nMatchTime = self.tbEnterTime[pPlayer.dwID] or 0
        nMatchTime = GetTime() - nMatchTime
        local nResult = (self.bClose == 1 and self.bOpenSuccess) and Env.LogRound_SUCCESS or Env.LogRound_FAIL
        pPlayer.TLogRoundFlow(Env.LogWay_KinTrain, self.nMapId, 0, nMatchTime, nResult, 0, 0)
        pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinTrain, self.nMapId, nResult)
    end

    ChatMgr:LeaveKinChatRoom(pPlayer);
end

function tbFuben:OnJoinActiviy(pPlayer)
    if not pPlayer or self.tbHadAddFlag[pPlayer.dwID] then
        return
    end

    self.tbHadAddFlag[pPlayer.dwID] = 1
    EverydayTarget:AddCount(pPlayer, "KinFuben", 1)
    Achievement:AddCount(pPlayer, "KinFuben_1", 1)
    TeacherStudent:TargetAddCount(pPlayer, "KinPractice", 1)
    TeacherStudent:CustomTargetAddCount(pPlayer, "KinPractice", 1)
    Log("KinTrainBase OnJoinActiviy", pPlayer.dwID)
end

function tbFuben:BeginTrain()
    self.bTrainHadBegin = true
    local tbPlayer, nPlayerNum = KPlayer.GetMapPlayer(self.nMapId)
    if nPlayerNum < Fuben.KinTrainMgr.OPEN_MEMBER_NUM then
        self:Close()
        KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinTrainMgr:OnFubenStartFail")
        return
    end

    self.nNpcIdx = nil
    for nIdx, nNum in ipairs(self.Def.tbPlayerNumForNpIdx) do
        if nPlayerNum <= nNum then
            self.nNpcIdx = nIdx
            break
        end
    end
    self.nNpcIdx = self.nNpcIdx or (#self.Def.tbPlayerNumForNpIdx + 1)

    self.nAddPrestige = self.Def.tbPrestige[1][2]
    for _, tbInfo in ipairs(self.Def.tbPrestige) do
        if nPlayerNum <= tbInfo[1] then
            self.nAddPrestige = tbInfo[2]
            break
        end
    end

    for _, pPlayer in pairs(tbPlayer) do
        self:OnJoinActiviy(pPlayer)
    end
    Log("Kin BeginTrain:", self.dwKinId, self.nMapId, self.nNpcIdx, nPlayerNum)

    local nEndTime = Fuben.KinTrainMgr:GetEndTime() or 0
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinTrainMgr:OnTrainBegin", false, nEndTime)
    self:UnLock(100)
    self.bOpenSuccess = true
end

function tbFuben:GetNumber(value)
    if type(value) == "number" then
        return value;
    end

    self.tbSetting.NUM = self.tbSetting.NUM or {};
    if not self.tbSetting.NUM[value] then
        assert(false, "KinTrainBase:GetNumber(value) ERR ?? self.tbSetting.NUM[value] is nil !! " .. self.tbSetting.szFubenClass .. "  " .. value);
        return 0;
    end

    if type(self.tbSetting.NUM[value]) == "number" then
        return self.tbSetting.NUM[value];
    end

    if not self.tbSetting.NUM[value][self.nNpcIdx] then
        assert(false, string.format("KinTrainBase:GetNumber(value) ERR ?? szFubenClass %s, value %s, nFubenLevel %s", self.tbSetting.szFubenClass, value, self.nNpcIdx));
        return 0;
    end

    return self.tbSetting.NUM[value][self.nNpcIdx];
end

function tbFuben:OnPlayerDeath()
    me.Revive(1)
    me.SetPosition(unpack(self.tbRevivePos))
end

function tbFuben:DropAward(pNpc, tbAwardInfo)
    local nRate   = tbAwardInfo[2]
    local nRandom = MathRandom(100)
    if nRandom > nRate then
        return
    end

    local _, nPosX, nPosY = pNpc.GetWorldPos()
    local nBasicExp = (tbAwardInfo[3] or 0) * (tbAwardInfo[1][3] or 0)

    local fnDrop = function (pPlayer)
        if nBasicExp > 0 then
            local nExp = pPlayer.GetBaseAwardExp() * nBasicExp
            pPlayer.AddExperience(nExp, Env.LogWay_KinTrainNpcAward)
        end
        pPlayer.DropAward(nPosX, nPosY, nil, {tbAwardInfo[1]}, Env.LogWay_KinTrainNpcAward, nil, true)
    end
    self:AllPlayerExcute(fnDrop)
end

function tbFuben:OnKillNpc(pNpc)
    local tbAwardInfo = self.Def.tbDropAward[pNpc.nTemplateId]
    if tbAwardInfo then
        self:DropAward(pNpc, tbAwardInfo)
    end

    if self.nMaterialBoss and pNpc.nId == self.nMaterialBoss then
        self:OnMatBossDeath()
        return
    end

    local nTemplateId = pNpc.nTemplateId
    local nType = self:GetMaterialType(nTemplateId)
    if not nType then
        return
    end

    local tbNpcInfo = self.Def.tbMaterialNpc[nTemplateId]
    self.tbCollection[nType] = self.tbCollection[nType] + tbNpcInfo.nDropNum
    if self.tbCreateNpcNum[nType] < tbNpcInfo.nCreateNum then
        Timer:Register(Env.GAME_FPS*10, self.AddMeterialNpc, self, nTemplateId, 1)
    end
    self.tbMaterialGroup[pNpc.nId] = nil
    self:UpdateMatPanel()
end

function tbFuben:BeginMaterial()
    if self.bClose == 1 then
        return
    end
    for nTemplateId, _ in pairs(self.Def.tbMaterialNpc) do
        self:AddMeterialNpc(nTemplateId, 10)
    end

    local nLevel = self:GetAverageLevel()
    local pCarNpc = KNpc.Add(self.Def.CAR_TEMPLATE, nLevel, -1, self.nMapId, unpack(self.Def.tbMaterialCarPos)) --物资车
    if pCarNpc then
        self.nCarId = pCarNpc.nId
    else
        Log("KinTrainBase CreateCarError", self.nMapId)
    end
end

function tbFuben:GetMaterialType(nTemplateId)
    local tbNpcInfo = self.Def.tbMaterialNpc[nTemplateId] or {}
    return tbNpcInfo.nType
end

function tbFuben:ShowMeterialInfo(pPlayer)
    self.tbPushMatInfo[pPlayer.dwID] = true
    pPlayer.CallClientScript("Fuben.KinTrainMgr:ShowMeterialInfo", unpack(self.tbCollection))
end

function tbFuben:OnCancelMatUpdate(pPlayer)
    self.tbPushMatInfo[pPlayer.dwID] = false
end

function tbFuben:UpdateMatPanel()    
    for dwID, bNeedUpdate in pairs(self.tbPushMatInfo) do
        if bNeedUpdate then
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer then
                pPlayer.CallClientScript("Fuben.KinTrainMgr:ShowMeterialInfo", unpack(self.tbCollection))
            end
        end
    end
end

function tbFuben:TryDepart(pPlayer)
    local bRet, szMsg = self:CheckDepart(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local nBossTemplateId = self:CalBossTemplateId()
    local nLevel = self:GetAverageLevel()
    local pBoss = KNpc.Add(nBossTemplateId, nLevel, -1, self.nMapId, unpack(self.Def.tbBossPos)) --boss
    if not pBoss then
        Log("KinTrainBase Depart Error", self.nMapId)
        return
    end
    
    self.nMaterialBoss = pBoss.nId
    self.nMaterialBossTID = nBossTemplateId
    self:DeleteMaterialNpc()

    local szBossMsg = string.format("召唤出了%s", pBoss.szName)
    local fnMsg = function (pPlayer)
        pPlayer.CenterMsg(szBossMsg)
    end
    self:AllPlayerExcute(fnMsg)
    Log("KinTrainBase Boss Create", nBossTemplateId)
    if self.OnDepart then
        self:OnDepart()
    end
end

function tbFuben:CheckDepart(pPlayer)
    if self.nMaterialBoss then
        return false, "已发车"
    end

    if self.bClose == 1 then
        return false, "帮派试炼已结束"
    end
    
    if pPlayer.dwKinId == 0 then
        return false, "没有帮派，发车失败"
    end

    local tbMemberList = Kin:GetKinMembers(pPlayer.dwKinId)
    if tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_ViceMaster and tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_Master then
        return false, "只有堂主或副堂主才能发车"
    end

    for nType, nKillCount in pairs(self.tbCollection) do
        if nKillCount < (self.Def.tbMaterialInfo[nType] * 0.6) then
            local szMatName = self.bDefend and "军资" or "物资"
            return false, string.format("%s不足，无法发车", szMatName)
        end
    end

    return true
end

function tbFuben:CalBossTemplateId()
    local nScore = 0
    for nType, nKillCount in pairs(self.tbCollection) do
        local nCol = nKillCount
        local nStan = self.Def.tbMaterialInfo[nType]
        if nCol < 0.6*nStan or nCol > 1.3*nStan then
            nScore = nScore + 5
        elseif (nCol >= 0.6*nStan and nCol < 0.8*nStan) or (nCol > 1.1*nStan and nCol <= 1.3*nStan) then
            nScore = nScore + 3
        elseif (nCol >= 0.8*nStan and nCol < nStan) or (nCol > nStan and nCol <= 1.1*nStan) then
            nScore = nScore + 1
        end
    end

    local tbBossTID = self.Def.tbBossTemplateId
    for _, tbInfo in ipairs(tbBossTID) do
        if nScore >= tbInfo[1] then
            return tbInfo[2]
        end
    end

    Log("KinTrainBase CalcBossId Error", self.nMapId)
    return tbBossTID[1][2]
end

function tbFuben:DeleteMaterialNpc()
    if self.nCarId then
        local pCarNpc = KNpc.GetById(self.nCarId)
        if pCarNpc then
            pCarNpc.Delete()
        end
    end

    for nNpcId, _ in pairs(self.tbMaterialGroup) do
        local pNpc = KNpc.GetById(nNpcId)
        if pNpc then
            pNpc.Delete()
        end
    end
    self.tbMaterialGroup = {}
    if self.OnDeleteMaterialNpc then
        self:OnDeleteMaterialNpc()
    end
end

function tbFuben:SendAuctionAward()
    local nJoinNum = 0
    local szPlayerList = ""
    for nPlayerId, _ in pairs(self.tbJoinPlayer or {}) do
        nJoinNum = nJoinNum + 1
        szPlayerList = string.format("%s|%d", szPlayerList, nPlayerId or 0)
    end
    local tbAward = Fuben.KinTrainMgr:GetAward(nJoinNum)
    if tbAward and next(tbAward) then
        Kin:AddAuction(self.dwKinId, "KinTrain", self.tbJoinPlayer, tbAward)
    end
    Log("KinTrainBase SendAuctionAward", self.dwKinId, nJoinNum, tbAward and #tbAward or "Err", szPlayerList)
end

function tbFuben:OnTimeOut()
    if self.nMaterialBoss then
        local pNpc = KNpc.GetById(self.nMaterialBoss)
        if pNpc then
            pNpc.Delete()
        end
    end
    self:DeleteMaterialNpc()
    if self.bClose == 1 then
        return
    end

    self:Close()
    Log("KinTrainBase TimeOut", self.nMapId)
end

function tbFuben:OnMatBossDeath()
    if self.bClose == 1 then
        return
    end

    local kinData = Kin:GetKinById(self.dwKinId)
    kinData:AddPrestige(self.nAddPrestige, Env.LogWay_KinTrainCommon)

    self:SendAuctionAward()
    self:Close()
    Log("KinTrainBase Boss Death", self.nMapId)
end

function tbFuben:OnClose()
    Timer:Register(Env.GAME_FPS*60*3, self.KickoutPlayer, self)
    KPlayer.MapBoardcastScript(self.nMapId, "Fuben.KinTrainMgr:OnFubenOver", "帮派试炼已结束，请离开")
end

function tbFuben:KickoutPlayer()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.GotoEntryPoint()
    end
    Log("KintainBase KickoutPlayer", self.nMapId)
end

function tbFuben:MemberJoinKinChatRoom()
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in ipairs(tbPlayer) do
         Kin:JoinChatRoom(pPlayer)
    end
end