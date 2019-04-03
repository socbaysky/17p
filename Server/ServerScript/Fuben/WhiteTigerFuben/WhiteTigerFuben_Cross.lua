if not MODULE_ZONESERVER then
    return
end

Fuben.WhiteTigerFuben = Fuben.WhiteTigerFuben or {};
local WhiteTigerFuben = Fuben.WhiteTigerFuben;

function WhiteTigerFuben:OnWSBeginFight()
    self.tbWS = self.tbWS or {}
    self.tbWS[Server.nCurConnectIdx] = true
    Log("WhiteTigerFuben OnWSBeginFight:", Server.nCurConnectIdx)
end

--nServerIdx：在gateway中的服务器序号，有可能重复
function WhiteTigerFuben:SyncKillBossKinId(nKinId, szKinName, nServerId, nServerIdx)
    self.tbServerInfo[nServerId] = {nConnectIdx = Server.nCurConnectIdx, nKinId = nKinId, nServerIdx = nServerIdx, szKinName = szKinName}
    Log("WhiteTigerFuben SyncKillBossKinId", nKinId, Server.nCurConnectIdx, nServerIdx)
end

--scheduletask
function WhiteTigerFuben:BeginCrossFight()
    self.nLastWS = 0
    for nWsIdx, _ in pairs(self.tbWS or {}) do
        self.nLastWS = self.nLastWS + 1
    end
    if self.nLastWS <= 0 then
        Log("WhiteTigerFuben BeginCrossFight Fail Not WsBegin")
        return
    end

    self.tbWSMap = {}
    self:CreateFightMap(self.nLastWS)
    self:BoardcastMapId()
    self.tbWS = {}
    self.tbServerInfo = {}
    self.tbZoneClientTeam = {}
    Log("WhiteTigerFuben BeginCrossFight", self.nLastWS)
end

function WhiteTigerFuben:CreateFightMap(nWSCount)    
    local nCreateNum = math.floor(nWSCount/self.FIT_KIN_IN_MAP)
    --这些情况下地图数量不足
    if nWSCount == 1 or nWSCount == 2 or nWSCount == 5 then
        nCreateNum = nCreateNum + 1
    end
    local tbMapInfo = {}
    for i = 1, nCreateNum do
        local nMapId = CreateMap(self.CROSS_MAP_TID)
        table.insert(tbMapInfo, {nMapId = nMapId, nWSNum = 0})
    end

    for nWsIdx, _ in pairs(self.tbWS or {}) do
        local nMapId, nRoomIdx = self:DistributionMap(tbMapInfo, nWSCount)
        if nMapId then
            self.tbWSMap[nWsIdx] = {nMapId = nMapId, nRoomIdx = nRoomIdx}
            Log("WhiteTigerFuben CreateFightMap", nWsIdx, nWSCount, nMapId, nRoomIdx)
            nWSCount = nWSCount - 1
        end
    end
end

function WhiteTigerFuben:DistributionMap(tbMapInfo, nLastWS)
    --先按照每个地图三个服务器分配，当分配不下来时按照每个地图四个服务器分配
    for nMax = self.FIT_KIN_IN_MAP, self.FIT_KIN_IN_MAP + 1 do
        for _, tbInfo in ipairs(tbMapInfo) do
            if tbInfo.nWSNum < nMax then
                tbInfo.nWSNum = tbInfo.nWSNum + 1
                return tbInfo.nMapId, tbInfo.nWSNum
            end
        end
    end
    Log("WhiteTigerFuben DistributionMap Err", nLastWS)
end

function WhiteTigerFuben:BoardcastMapId()
    for nWsIdx, tbInfo in pairs(self.tbWSMap) do
        CallZoneClientScript(nWsIdx, "Fuben.WhiteTigerFuben:OnCrossMapCreated", tbInfo.nMapId, tbInfo.nRoomIdx)
        Log("WhiteTigerFuben BoardcastMapId", nWsIdx, tbInfo.nMapId, tbInfo.nRoomIdx)
    end
end

function WhiteTigerFuben:GetKinIdByMap(nMapId, nRoomIdx)
    for nServerId, tb in pairs(self.tbServerInfo) do
        local tbInfo = self.tbWSMap[tb.nConnectIdx] or {}
        if tbInfo.nMapId == nMapId and tbInfo.nRoomIdx == nRoomIdx then
            return nServerId, tb.nKinId
        end
    end
end

function WhiteTigerFuben:GetWsByKinId(pPlayer)
    if not self.tbServerInfo[pPlayer.nZoneServerId] then
        return
    end
    return self.tbServerInfo[pPlayer.nZoneServerId].nConnectIdx
end

function WhiteTigerFuben:JoinZoneClientTeam(nServerId, nOldPlayerId, nTeamId)
    self.tbZoneClientTeam = self.tbZoneClientTeam or {}
    self.tbZoneClientTeam[nServerId] = self.tbZoneClientTeam[nServerId] or {}
    local nPlayerId = KPlayer.ForceGetZonePlayerIdByOrgId(nOldPlayerId, nServerId)
    if self.tbZoneClientTeam[nServerId][nTeamId] then
        local teamData = TeamMgr:GetTeamById(self.tbZoneClientTeam[nServerId][nTeamId])
        if teamData then
            teamData:AddMember(nPlayerId)
        else
            Log("WhiteTigerFuben:JoinZoneClientTeam Team Not Found", nServerId, nOldPlayerId, nTeamId)
        end
    else
        local bRet, _, _, teamData = TeamMgr:Create(nPlayerId, nPlayerId)
        if bRet and teamData then
            self.tbZoneClientTeam[nServerId][nTeamId] = teamData.nTeamID
        else
            Log("WhiteTigerFuben:JoinZoneClientTeam Team Create Fail", nServerId, nOldPlayerId, nTeamId)
        end
    end
end

function WhiteTigerFuben:SendCrossAward(nMapId, tbKinValue, tbKinJoinPlayer, nKillKinId)
    for nKinId, nValue in pairs(tbKinValue) do
        local nServerId, nOrgKillKinId = KPlayer.GetOrgKinIdByZoneId(nKinId)
        local tbInfo = self.tbServerInfo[nServerId]
        if tbInfo then
            local tbJoin = tbKinJoinPlayer[nKinId] or {}
            CallZoneClientScript(tbInfo.nConnectIdx, "Fuben.WhiteTigerFuben:BeginSendCrossAward", nOrgKillKinId, tbJoin, nValue)
        end
    end

    self:SendFightResult(nMapId, nKillKinId)
    Log("WhiteTigerFuben SendCrossAward", nKillKinId or "-")
end

function WhiteTigerFuben:SendFightResult(nMapId, nKillKinId)
    if not nKillKinId then
        Log("WhiteTigerFuben SendFightResult Err Not KillInfo")
        return
    end

    local tbHostileKin = {}
    local nServerKillId, nOrgKillKinId = KPlayer.GetOrgKinIdByZoneId(nKillKinId)
    local tbKillInfo = self.tbServerInfo[nServerKillId]
    for i = 1, 4 do
        local nOrgServerId, nOrgKinId = self:GetKinIdByMap(nMapId, i)
        if nOrgServerId and nOrgKinId and nServerKillId ~= nOrgServerId then
            local tbInfo = self.tbServerInfo[nOrgServerId]
            if tbInfo then
                table.insert(tbHostileKin, {nOrgServerId, tbInfo.szKinName})
                if tbKillInfo then
                    CallZoneClientScript(tbInfo.nConnectIdx, "Fuben.WhiteTigerFuben:OnBeDefeatInCross", {nServerKillId, tbKillInfo.szKinName}, nOrgKinId)
                end
            end
        end
    end

    if tbKillInfo then
        CallZoneClientScript(tbKillInfo.nConnectIdx, "Fuben.WhiteTigerFuben:OnKillCrossBoss", tbKillInfo.nKinId, tbHostileKin)
    end
end

--scheduletask
function WhiteTigerFuben:StopCrossFight()
    local fnLeaveMap = function (pPlayer)
        local nWs = self:GetWsByKinId(pPlayer)
        if nWs then
            CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnLeaveCross", pPlayer.dwOrgPlayerId)
        end    
        pPlayer.ZoneLogout()
    end
    for nWsIdx, tbInfo in pairs(self.tbWSMap or {}) do
        local tbInst = Fuben.tbFubenInstance[tbInfo.nMapId]
        if tbInst then
            tbInst:Close()
            tbInst:AllPlayerInMapExcute(fnLeaveMap)
        end
    end
    self.tbWSMap = {}
    self.tbZoneClientTeam = {}
    Log("WhiteTigerFuben StopCrossFight")
end