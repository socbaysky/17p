Fuben.KinSecretMgr = Fuben.KinSecretMgr or {}
local KinSecretMgr = Fuben.KinSecretMgr
KinSecretMgr.bOpened = true

local tbValidReq = {
    OpenKickPanel = true,
    ManualKick = true,
    RefreshJoinCounts = true,
}
function KinSecretMgr:OnClientReq(pPlayer, szType, ...)
    if not self.bOpened then return end

    if not tbValidReq[szType] then
        return
    end

    local fn = self[szType]
    if not fn then
        return
    end
    local bOk, szErr = fn(self, pPlayer, ...)
    if not bOk then
        if szErr and szErr~="" then
            pPlayer.CenterMsg(szErr)
        end
        return
    end
end

function KinSecretMgr:RefreshJoinCounts(pPlayer)
    local dwKinId = pPlayer.dwKinId
    if not self.tbKinMap or not self.tbKinMap[dwKinId] then
        return
    end

    local tbCounts = {}
    for nIdx, nMapId in pairs(self.tbKinMap[dwKinId]) do
        if Fuben.tbFubenInstance[nMapId] then
            local _, nPlayerNum = KPlayer.GetMapPlayer(nMapId)
            tbCounts[nIdx] = nPlayerNum
        end
    end
    pPlayer.CallClientScript("Fuben.KinSecretMgr:OnJoinCountsRefreshed", tbCounts)
end

function KinSecretMgr:OpenKickPanel(pPlayer)
    if not self:CanKick(pPlayer) then
        return false, "你没有许可权"
    end

    local tbFubenInst = Fuben.tbFubenInstance[pPlayer.nMapId]
    if not tbFubenInst then
        return false, "你不在副本中"
    end

    local nRoom = pPlayer.nRoom
    if not nRoom or nRoom<=0 then
        return false, "准备场中无法使用"
    end

    local tbPlayers = {}
    local tbPlayerIds = tbFubenInst.tbRoomPlayerIds[nRoom]
    for nPlayerId in pairs(tbPlayerIds) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer then
            table.insert(tbPlayers, {
                nId = pPlayer.dwID,
                nLvl = pPlayer.nLevel,
                szName = pPlayer.szName,
                nFaction = pPlayer.nFaction,
                nHonorLevel = pPlayer.nHonorLevel,
                nVipLevel = pPlayer.GetVipLevel(),
                nPortrait = pPlayer.nPortrait,
            })
        end
    end
    pPlayer.CallClientScript("Ui:OpenWindow", "KickPlayerPanel", tbPlayers)
end

function KinSecretMgr:ManualKick(pPlayer, nTarget)
    if not self:CanKick(pPlayer) then
        return false, "你没有许可权"
    end

    local tbFubenInst = Fuben.tbFubenInstance[pPlayer.nMapId]
    if not tbFubenInst then
        return false, "你不在副本中"
    end

    if tbFubenInst:ManualKick(nTarget) then
        pPlayer.CenterMsg(string.format("对方将在%d秒後被踢回准备场", self.Def.nKickWaitTime))
        return true
    end
    return true
end

function KinSecretMgr:SetKinResult(nKinId, nIdx, tbJoin, nPassed)
    if nPassed<=0 then
        Log("KinSecretMgr:SetKinResult, pass 0", nKinId, nIdx, nPassed)
        return
    end
    self.tbKinResult[nKinId] = self.tbKinResult[nKinId] or {}
    self.tbKinResult[nKinId][nIdx] = {Lib:CopyTB(tbJoin), nPassed}
    Log("KinSecretMgr:SetKinResult", nKinId, nIdx, nPassed)
end

function KinSecretMgr:GiveAuctionRewards()
    local tbPassedValue = {}
    for i, nValue in ipairs(self.Def.tbLevelValue) do
        tbPassedValue[i] = (tbPassedValue[i-1] or 0)+nValue
    end

    for nKinId, tbResult in pairs(self.tbKinResult or {}) do
        local nTotalValue = 0
        for _, tb in pairs(tbResult) do
            local tbJoin, nPassed = unpack(tb)
            local nPlayerCount = Lib:CountTB(tbJoin)
            nTotalValue = nTotalValue+(tbPassedValue[nPassed]*nPlayerCount)
            Log("KinSecretMgr:GiveAuctionRewards", nKinId, nPassed, nPlayerCount)
        end

        local tbAuctionSettings = {}
        for _, v in ipairs(self.Def.tbAuctionSettings) do
            if GetTimeFrameState(v[1])==1 then
                tbAuctionSettings = v[2]
                break
            end
        end

        local tbItems = RandomAward:GetKinAuctionAward(tbAuctionSettings, nKinId, nTotalValue, "KinSecret")
        if next(tbItems) then
            local tbMembers = {}
            local tbKinData = Kin:GetKinById(nKinId)
            if tbKinData then
                tbKinData:TraverseMembers(function(tbMember)
                    if self.tbHadAddFlag[tbMember.nMemberId] then
                        tbMembers[tbMember.nMemberId] = true
                    end
                    return true
                end)
            end
            Kin:AddAuction(nKinId, "KinSecretFubenAuction", tbMembers, tbItems)
            Log("KinSecretMgr:GiveAuctionRewards result", nKinId, nTotalValue, #tbItems, Lib:CountTB(tbMembers))
        else
            local szMsg = "本次活动由於参与人数过少，没有帮派拍卖奖励！"
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId)
            Log("KinSecretMgr:GiveAuctionRewards, no item", nKinId, nTotalValue)
        end
    end

    self.tbKinResult = nil
end

function KinSecretMgr:Clear()
    self.tbKinMap     = {}
    self.tbWaitPlayer = {}
    self.bInProcess   = true
    self.nStartTime   = GetTime()
    self.tbKinResult = {}
    self.tbRewardedPlayers = {}
    self.tbHadAddFlag = {}
end

function KinSecretMgr:Start()
    if not self.bOpened then return end

    self:Clear()

    local szMsg = "帮派秘境已经开启，各帮派成员可通过活动日历前往秘境地图"
    KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
    self:SendNotifyMsg()

    Timer:Register(Env.GAME_FPS*self.Def.nPrepareTime, self.BeginSecret, self)
    Calendar:OnActivityBegin("KinSecretFuben")
    Log("KinSecretMgr:Start", self.nStartTime)
end

function KinSecretMgr:SendNotifyMsg()
    local tbData = {
        szType = "KinSecretFuben",
        nTimeOut = GetTime()+self.Def.nPrepareTime,
    }
    KPlayer.BoardcastScript(self.Def.nMinLevel, "Ui:SynNotifyMsg", tbData)
end

function KinSecretMgr:Stop()
    if not self.bOpened then return end

    if not self.bInProcess then
        return
    end

    self.bInProcess = false
    for _, tbMapIds in pairs(self.tbKinMap or {}) do
        for _, nMapId in pairs(tbMapIds) do
            local tbFubenInst = Fuben.tbFubenInstance[nMapId]
            if tbFubenInst then
                tbFubenInst:OnTimeOut()
            end
        end
    end

    self:GiveAuctionRewards()
    Calendar:OnActivityEnd("KinSecretFuben")
    self:Clear()
    Log("KinSecretMgr:Stop", GetTime())
end

function KinSecretMgr:BeginSecretByKinIdx(nKinId, nIdx)
    local nMapId = (self.tbKinMap[nKinId] or {})[nIdx] or -1
    local tbFubenInst = Fuben.tbFubenInstance[nMapId]
    if tbFubenInst then
        tbFubenInst:BeginSecret()
    end
    Log("KinSecretMgr:BeginSecretByKinIdx", nKinId, nIdx, nMapId, tostring(not not tbFubenInst))
end

function KinSecretMgr:BeginSecret()
    for nKinId, tbMapIds in pairs(self.tbKinMap) do
        for nIdx in pairs(tbMapIds) do
            self:BeginSecretByKinIdx(nKinId, nIdx)
        end
    end
    Log("KinSecretMgr:BeginSecret", GetTime())
end

function KinSecretMgr:OnFubenCreateSuccess(dwKinId, nIdx, nMapId)
    if not self.bInProcess then
        self.tbWaitPlayer[dwKinId] = nil
        return
    end

    self.tbKinMap[dwKinId] = self.tbKinMap[dwKinId] or {}
    self.tbKinMap[dwKinId][nIdx] = nMapId
    local tbPlayers = (self.tbWaitPlayer[dwKinId] or {})[nIdx] or {}
    for dwID in pairs(tbPlayers) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            self:TryEnterMap(pPlayer, nIdx)
        end
    end
    if self.tbWaitPlayer[dwKinId] then
        self.tbWaitPlayer[dwKinId][nIdx] = nil
    end

    --开启家族实时语音
    if not ChatMgr:IsKinHaveChatRoom(dwKinId) then
        ChatMgr:CreateKinChatRoom(dwKinId)
    end
end

function KinSecretMgr:TryEnterMap(pPlayer, nIdx)
    local nPlayerId = pPlayer.dwID
    local bRet, szMsg = self:CheckEntry(pPlayer, nIdx)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local dwKinId = pPlayer.dwKinId
    self.tbKinMap[dwKinId] = self.tbKinMap[dwKinId] or {}
    local nMapId = self.tbKinMap[dwKinId][nIdx]
    if not nMapId then
        self.tbWaitPlayer[dwKinId] = self.tbWaitPlayer[dwKinId] or {}
        if self.tbWaitPlayer[dwKinId][nIdx] then
            self.tbWaitPlayer[dwKinId][nIdx][nPlayerId] = 1
            return
        end

        self.tbWaitPlayer[dwKinId][nIdx] = {[nPlayerId] = 1}
        Fuben:ApplyFuben(nPlayerId, self.Def.nMapTemplateId, 
            function (nMapId)
                self:OnFubenCreateSuccess(dwKinId, nIdx, nMapId)
            end,
            function ()
                Log("[KinSecretMgr] FubenCreateFail", dwKinId, nIdx)
            end, dwKinId, nIdx)
        Log("KinSecretMgr Try CreateMap", dwKinId, nIdx)
        return
    end

    local tbInst = Fuben.tbFubenInstance[nMapId]
    if not tbInst or tbInst.bClose == 1 then
        pPlayer.CenterMsg("本秘境未成功开启")
        return
    end

    local _, nPlayerNum = KPlayer.GetMapPlayer(nMapId)
    if nPlayerNum>=self.Def.nJoinMax then
        pPlayer.CenterMsg("已达人数上限，无法进入")
        return
    end

    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(nMapId, 0, 0)
end

function KinSecretMgr:CheckEntry(pPlayer, nIdx)
    nIdx = nIdx or 0
    if nIdx<=0 or nIdx>self.Def.nMaxCountPerKin then
        Log("[x] KinSecretMgr:CheckEntry", pPlayer.dwID, nIdx, self.Def.nMaxCountPerKin)
        return false, "此房间尚未开启"
    end
    if not self.bInProcess then
        return false, "活动未开启"
    end

    if pPlayer.nLevel<self.Def.nMinLevel then
        return false, "等级不足"
    end

    if pPlayer.dwKinId == 0 then
        return false, "没有帮派，无法参加活动"
    end

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前状态不允许切换地图"
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
        return false, "所在地图不允许进入副本！";
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "非安全区不允许进入副本！";
    end

    return true
end

function KinSecretMgr:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
    if not self.bInProcess then
        return false
    end

    local tbMapIds = self.tbKinMap[dwKinId] or {}
    if not next(tbMapIds) then
        return false
    end

    for _, nMapId in pairs(tbMapIds) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:MemberJoinKinChatRoom()
        end
    end

    return true;
end

function KinSecretMgr:GetEndTime()
    if not self.bInProcess then
        return
    end

    if GetTime() < (self.nStartTime + self.Def.nPrepareTime) then
        return self.nStartTime + self.Def.nPrepareTime
    else
        return self.nStartTime + self.Def.nTotalTime
    end
end
