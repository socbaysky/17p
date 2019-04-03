if not MODULE_ZONESERVER then

function ZhenFa:SyncPlayerData(pPlayer)
    local tbData = {}
    for _, tbInfo in ipairs(self.tbJueYao) do
        local tbTmp = {}
        for nSaveIdx = tbInfo.nStrengthLv, tbInfo.nAttribIdx do
            table.insert(tbTmp, pPlayer.GetUserValue(self.GROUP, nSaveIdx))
        end
        table.insert(tbData, tbTmp)
    end
    CallZoneServerScript("ZhenFa:OnSyncPlayerData", pPlayer.dwID, tbData)
end

function ZhenFa:OnReConnectZoneClient(pPlayer)
    pPlayer.CallClientScript("ZhenFa:RefreshExternAttrib")
end

function ZhenFa:OnRecieveRequest(tbRequest)
    local tbRelation = {}
    for _, tbInfo in ipairs(tbRequest or {}) do
        local nPlayer1, nPlayer2 = unpack(tbInfo)
        local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1)
        local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2)
        if pPlayer1 and pPlayer2 then
            local tbPlayerRelation = {}
            for nPos = 1, self.JUEYAO_TYPE_LEN do
                if self:IsRelationSame(pPlayer1, pPlayer2, nPos) then
                    table.insert(tbPlayerRelation, nPos)
                end
            end
            if next(tbPlayerRelation) then
                self:AddRelation2List(Server.nCurZoneId, nPlayer1, nPlayer2, tbPlayerRelation)
            end
        end
    end
end

ZhenFa.tbRelationCache = ZhenFa.tbRelationCache or {}
function ZhenFa:AddRelation2List(nZoneId, nPlayer1, nPlayer2, tbPlayerRelation)
    table.insert(self.tbRelationCache, {nZoneId, nPlayer1, nPlayer2, tbPlayerRelation})
end

ZhenFa.PROCESS_COUNT_PER_FPS = 20
function ZhenFa:Activate()
    if not next(self.tbRelationCache) then
        return
    end

    local tbRequest = {}
    for nIdx = 1, self.PROCESS_COUNT_PER_FPS do
        local tbInfo = table.remove(self.tbRelationCache, 1)
        if not tbInfo then
            break
        end
        local nZoneId = tbInfo[1]
        tbRequest[nZoneId] = tbRequest[nZoneId] or {}
        table.insert(tbRequest[nZoneId], {unpack(tbInfo, 2, 4)})
    end

    if not next(tbRequest) then
        return
    end

    for nZoneId, tbRequestInfo in pairs(tbRequest) do
        CallSubZoneServerScript(nZoneId, "ZhenFa:OnRecieveRelation", tbRequestInfo)
    end
end

return
end

ZhenFa.tbRelationCache = ZhenFa.tbRelationCache or {}
function ZhenFa:IsRelationSameZ(pPlayer1, pPlayer2, nPos)
    --无差别时跟任何人都没关系
    if pPlayer1.bAvatarInZone or pPlayer2.bAvatarInZone then
        return
    end
    if pPlayer1.nZoneServerId ~= pPlayer2.nZoneServerId then
        return
    end

    local tbInfo = self.tbJueYao[nPos]
    if not tbInfo then
        return
    end

    local nPlayer1 = pPlayer1.dwID
    local nPlayer2 = pPlayer2.dwID
    self.tbRelationCache[nPlayer1] = self.tbRelationCache[nPlayer1] or {}
    self.tbRelationCache[nPlayer2] = self.tbRelationCache[nPlayer2] or {}
    local tbRelationInfo = self.tbRelationCache[nPlayer1][nPlayer2] or self.tbRelationCache[nPlayer2][nPlayer1]
    if not tbRelationInfo then
        tbRelationInfo = {bInWaiting = true}
        self.tbRelationCache[nPlayer1][nPlayer2] = tbRelationInfo
        self.tbRelationCache[nPlayer2][nPlayer1] = tbRelationInfo
        self:AddRequest2List(pPlayer1.nZoneServerId, pPlayer1.dwOrgPlayerId, pPlayer2.dwOrgPlayerId)
        return
    end
    if tbRelationInfo.bInWaiting then
        return
    end

    return tbRelationInfo.tbRelation and tbRelationInfo.tbRelation[nPos]
end

ZhenFa.tbRequestCache = ZhenFa.tbRequestCache or {tbHadAskPlayer = {}, tbRequest = {}}
function ZhenFa:AddRequest2List(nZoneServerId, nPlayer1, nPlayer2)
    if self.tbRequestCache.tbHadAskPlayer[nPlayer1] or self.tbRequestCache.tbHadAskPlayer[nPlayer2] then
        return
    end

    self.tbRequestCache.tbHadAskPlayer[nPlayer1] = true
    self.tbRequestCache.tbHadAskPlayer[nPlayer2] = true
    table.insert(self.tbRequestCache.tbRequest, {nZoneServerId, nPlayer1, nPlayer2})
end

ZhenFa.PROCESS_COUNT_PER_FPS = 20
function ZhenFa:Activate()
    if not next(self.tbRequestCache.tbRequest) then
        return
    end

    local tbRequest = {}
    for nIdx = 1, self.PROCESS_COUNT_PER_FPS do
        local tbInfo = table.remove(self.tbRequestCache.tbRequest, 1)
        tbInfo = tbInfo or {}
        local nZoneServerId = tbInfo[1]
        local nPlayer1 = tbInfo[2]
        local nPlayer2 = tbInfo[3]
        if nZoneServerId and nPlayer1 and nPlayer2 then
            tbRequest[nZoneServerId] = tbRequest[nZoneServerId] or {}
            self.tbRequestCache.tbHadAskPlayer[nPlayer1] = nil
            self.tbRequestCache.tbHadAskPlayer[nPlayer2] = nil
            table.insert(tbRequest[nZoneServerId], {nPlayer1, nPlayer2})
        end
    end

    if not next(tbRequest) then
        return
    end

    for nZoneServerId, tbRequestInfo in pairs(tbRequest) do
        local nConnectIdx = Server:GetConnectIdx(nZoneServerId)
        CallZoneClientScript(nConnectIdx, "ZhenFa:OnRecieveRequest", tbRequestInfo)
    end
end

--[[
tbRelationInfo = {
    {nPlayer1, nPlayer2, {1, 3, 5}--关系ID},
}
]]
function ZhenFa:OnRecieveRelation(tbRelationInfo)
    local nServerId = Server:GetServerId(Server.nCurConnectIdx)
    for _, tbInfo in ipairs(tbRelationInfo) do
        local nPlayer1 = tbInfo[1]
        nPlayer1 = KPlayer.ForceGetZonePlayerIdByOrgId(nPlayer1, nServerId)
        local nPlayer2 = tbInfo[2]
        nPlayer2 = KPlayer.ForceGetZonePlayerIdByOrgId(nPlayer2, nServerId)
        local tbPlayerRelation = {}
        for _, nPos in ipairs(tbInfo[3]) do
            tbPlayerRelation[nPos] = true
        end
        local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1)
        if pPlayer1 then
            self.tbRelationCache[nPlayer1] = self.tbRelationCache[nPlayer1] or {}
            self.tbRelationCache[nPlayer1][nPlayer2] = {bInWaiting = false, tbRelation = tbPlayerRelation}
        end

        local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2)
        if pPlayer2 then
            self.tbRelationCache[nPlayer2] = self.tbRelationCache[nPlayer1] or {}
            self.tbRelationCache[nPlayer1][nPlayer2] = {bInWaiting = false, tbRelation = tbPlayerRelation}
        end
        if (pPlayer1 and pPlayer2) and (pPlayer1.dwTeamID > 0 and pPlayer1.dwTeamID == pPlayer2.dwTeamID) and (pPlayer1.nMapId == pPlayer2.nMapId) then
            local tbPlayer = {pPlayer1, pPlayer2}
            for _, pPlayer in ipairs(tbPlayer) do
                for nPos = 1, self.JUEYAO_TYPE_LEN do
                    local _, nCurLevel = self:GetPlayerEquipIdx(pPlayer, nPos)
                    nCurLevel = nCurLevel or 0
                    self:ResetExternAttrib(pPlayer, nPos, nCurLevel + 1)
                end
            end
        end
    end
end

function ZhenFa:OnSyncPlayerData(nPlayer, tbData)
    local nServerId = Server:GetServerId(Server.nCurConnectIdx)
    nPlayer = KPlayer.ForceGetZonePlayerIdByOrgId(nPlayer, nServerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayer)
    if not pPlayer then
        return
    end
    for _, tbInfo in ipairs(self.tbJueYao) do
        local tbTmp = tbData[_]
        for nSaveIdx = tbInfo.nStrengthLv, tbInfo.nCurLevel do
            local nData = table.remove(tbTmp, 1)
            pPlayer.SetUserValue(self.GROUP, nSaveIdx, nData or 0)
        end
    end
    pPlayer.CallClientScript("ZhenFa:RefreshExternAttrib")

    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if not teamData then
        return
    end

    local tbAllMember = teamData:GetMembers()
    self:__AddLevel2Team(pPlayer, tbAllMember)
end