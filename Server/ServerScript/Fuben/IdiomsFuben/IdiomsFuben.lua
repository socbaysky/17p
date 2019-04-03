
local function fnAllMember(tbMember, fnSc, ...)
    for _, nPlayerId in pairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId);
        if pMember then
            fnSc(pMember, ...);
        end
    end
end

local function fnMsg(pPlayer, szMsg)
    pPlayer.CenterMsg(szMsg);
end

function IdiomFuben:CheckCanEnter(pTarget)
    local tbTeamMember = TeamMgr:GetMembers(pTarget.dwTeamID)

    local bInProcess = Activity:__IsActInProcessByType("IdiomsAct")
    if not bInProcess then
        return false,"活动未开放",tbTeamMember
    end

    if pTarget.dwTeamID == 0 then
        return false, "请组成两人队伍再来",tbTeamMember
    end
  
    if #tbTeamMember ~= IdiomFuben.JOIN_MEMBER_COUNT then
        return false, string.format("队伍人数必须为%d人",IdiomFuben.JOIN_MEMBER_COUNT),tbTeamMember
    end

    local tbTeam = TeamMgr:GetTeamById(pTarget.dwTeamID)
    local nCaptainId = tbTeam:GetCaptainId();
    if nCaptainId ~= pTarget.dwID then
    	return false,"队长才有许可权报名",tbTeamMember
    end

    local bRet,szMsg = self:CheckDistance(pTarget)
    if not bRet then
        return false,szMsg
    end

    table.sort(tbTeamMember, function (a, b)
        return a == pTarget.dwID and b ~= pTarget.dwID
    end)

    local tbSecOK = {}
    for nIdx, nPlayerId in ipairs(tbTeamMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "没找到玩家",tbTeamMember
        end

        if pPlayer.nLevel < IdiomFuben.JOIN_LEVEL then
            return false, string.format("「%s」不足%d级",pPlayer.szName, IdiomFuben.JOIN_LEVEL),tbTeamMember
        end

        tbSecOK[nIdx] = pPlayer.nSex;
        if DegreeCtrl:GetDegree(pPlayer, "Idioms") <= 0 then
            return false,string.format("「%s」次数不足",pPlayer.szName),tbTeamMember
        end
    end
    if tbSecOK[1] == tbSecOK[2] then
        return false, "必须异性组队",tbTeamMember
    end

    return true,nil,tbTeamMember
end

function IdiomFuben:CheckDistance(pPlayer)
    local tbTeamMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    local pPlayer1 = KPlayer.GetPlayerObjById(tbTeamMember[1])
    local pPlayer2 = KPlayer.GetPlayerObjById(tbTeamMember[2])
    local nMapId1, nX1, nY1 = pPlayer1.GetWorldPos()
    local nMapId2, nX2, nY2 = pPlayer2.GetWorldPos()

    local szName = ""
    if pPlayer1.dwID == me.dwID then
        szName = pPlayer2.szName
    elseif pPlayer2.dwID == me.dwID then
         szName = pPlayer1.szName
    end

    if nMapId1 ~= nMapId2 then
        return false, string.format("队友%s不在本地图",szName)
    end

    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    if fDists > (self.MIN_DISTANCE * self.MIN_DISTANCE) then
        return false, string.format("队友%s不在附近",szName)
    end

    return true
end


function IdiomFuben:TryCreateFuben(pPlayer)

    local bRet, szMsg,tbMember = self:CheckCanEnter(pPlayer);
    if not bRet then
        if not tbMember or not next(tbMember) then
            pPlayer.CenterMsg(szMsg)
        else
            fnAllMember(tbMember, fnMsg, szMsg);
        end
       ChatMgr:SendTeamOrSysMsg(pPlayer, szMsg)
       return;
    end

    local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint();
            pPlayer.SwitchMap(nMapId, 0, 0);
        end
        fnAllMember(tbMember, fnSucess, nMapId);
    end

    local function fnFailedCallback()
        fnAllMember(tbMember, fnMsg, "创建副本失败，请稍後尝试！");
    end

    Fuben:ApplyFuben(pPlayer.dwID, IdiomFuben.nFubenMapTemplateId, fnSuccessCallback, fnFailedCallback);

    return true;
end