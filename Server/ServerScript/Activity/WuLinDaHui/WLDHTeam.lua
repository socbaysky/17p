local tbDef = WuLinDaHui.tbDef;
local tbHSLJDef = HuaShanLunJian.tbDef;

WuLinDaHui.tbAllPlayerFightTeamID = WuLinDaHui.tbAllPlayerFightTeamID or {}; --[GameType][nServerId][dwRoleId]

WuLinDaHui.__tbBaseFightTeam = WuLinDaHui.__tbBaseFightTeam  or {};
local tbBaseFightTeam = WuLinDaHui.__tbBaseFightTeam;

function tbBaseFightTeam:SetSaveData(tbSaveData, nID)
    self.tbSaveData = tbSaveData;
    self.nID = nID;
    local nGameType = WuLinDaHui:GetGameTypeByTeamId(nID)
    --一个坑是因为本服上存的跨服决赛战队id是新生成的，战队id对应的game type 是4+nType的。为了存盘需要,
    local tbAllPlayer = self:GetAllPlayerID();
    local bAddToPlayerTeamKey = true;
    if not WuLinDaHui.tbGameFormat[nGameType] then
        nGameType = nGameType - #WuLinDaHui.tbGameFormat
        --本服上的跨服战队数据 ，非本服的战队不加入到 PlayerFightTeamId 防止替换本服的
        if not MODULE_ZONESERVER then
            bAddToPlayerTeamKey = false --非本服的跨服战队不在本服获得 playerFightTeam
        end
    end
    if bAddToPlayerTeamKey then
        WuLinDaHui.tbAllPlayerFightTeamID[nGameType] = WuLinDaHui.tbAllPlayerFightTeamID[nGameType] or {};
        local nServerId = self:GetServerIdx()
        local tbKeys1 = WuLinDaHui.tbAllPlayerFightTeamID[nGameType]
        tbKeys1[nServerId] = tbKeys1[nServerId] or {}
        for nPlayerID, _ in pairs(tbAllPlayer) do
            tbKeys1[nServerId][nPlayerID] = nID;     
        end    
    end
    
end

function tbBaseFightTeam:GetID()
    return self.nID;
end

function tbBaseFightTeam:GetName()
    return self.tbSaveData[tbHSLJDef.nTeamTypeName];
end

function tbBaseFightTeam:GetAllPlayerID()
    local tbAllPlayer = self.tbSaveData[tbHSLJDef.nTeamTypePlayer] or {};
    return tbAllPlayer;
end

function tbBaseFightTeam:GetPlayerNum(nPlayerID)
    local tbAllPlayer = self:GetAllPlayerID();
    local nNum = tbAllPlayer[nPlayerID] or 0;
    return nNum;
end

function tbBaseFightTeam:FindPlayerIDByNum(nFindNum)
    local tbAllPlayer = self:GetAllPlayerID();
    for nPlayerID, nNum in pairs(tbAllPlayer) do
        if nNum == nFindNum then
            return nPlayerID;
        end    
    end    
end 

function tbBaseFightTeam:AddPlayerID(nPlayerID)
    self.tbSaveData[tbHSLJDef.nTeamTypePlayer] = self.tbSaveData[tbHSLJDef.nTeamTypePlayer] or {};
    self.tbSaveData[tbHSLJDef.nTeamTypePlayer][nPlayerID] = 0;

    local nFightTeamID = self:GetID();
    local nGameType = WuLinDaHui:GetGameTypeByTeamId(nFightTeamID)
    local nServerId = self:GetServerIdx()
    --TODO 战队数据武林大会开新的时候要一起清掉一遍 本服和跨服上都要清
    WuLinDaHui.tbAllPlayerFightTeamID[nGameType][nServerId][nPlayerID] = nFightTeamID; 

    self:ResetPlayerNum();
end

function tbBaseFightTeam:ResetPlayerNum()
    local nCount = self:GetPlayerCount();
    if nCount <= 0 then
        return;
    end

    local tbAllPlayer = self:GetAllPlayerID();
    local tbSortID = {};
    for nPlayerID, _ in pairs(tbAllPlayer) do
        table.insert(tbSortID, nPlayerID);
    end

    table.sort(tbSortID, function (a, b)
        return a < b;
    end); 

    for nNum, nPlayerID in pairs(tbSortID) do
        local bRet = self:HavePlayerID(nPlayerID);
        if bRet then
            self:ChangePlayerNum(nPlayerID, nNum);
        end      
    end   
end

function tbBaseFightTeam:ChangePlayerNum(nPlayerID, nNum)
    local bRet = self:HavePlayerID(nPlayerID);
    if not bRet then
        return;
    end

    self.tbSaveData[tbHSLJDef.nTeamTypePlayer][nPlayerID] = nNum;    
end

function tbBaseFightTeam:GetPlayerCount()
    local tbAllPlayerID = self:GetAllPlayerID();
    local nCount = Lib:CountTB(tbAllPlayerID);
    return nCount;
end

function tbBaseFightTeam:HavePlayerID(nPlayerID)
    local tbAllPlayer = self:GetAllPlayerID();
    if not tbAllPlayer[nPlayerID] then
        return false;
    end

    return true;
end

function tbBaseFightTeam:RemovePlayer(nPlayerID)
    local bRet = self:HavePlayerID(nPlayerID);
    if not bRet then
        return;
    end

    self.tbSaveData[tbHSLJDef.nTeamTypePlayer][nPlayerID] = nil;

    local nFightTeamID = self:GetID();
    local nGameType = WuLinDaHui:GetGameTypeByTeamId(nFightTeamID)

    local tbAllData1 = WuLinDaHui.tbAllPlayerFightTeamID[nGameType]
    local nServerId = self:GetServerIdx()
    local tbAllData = tbAllData1 and tbAllData1[nServerId]
    if tbAllData then
        local nPlayerTeamID = tbAllData[nPlayerID];
        if nPlayerTeamID and nPlayerTeamID == nFightTeamID then
            tbAllData[nPlayerID] = nil;
        end    
    end

    self:ResetPlayerNum();      
end

--积分 * 100 * 100 + 胜利场数 * 100 + 总共场数
function tbBaseFightTeam:GetValue()
    local nValue = self.tbSaveData[tbHSLJDef.nTeamTypeValue] or 0;
    return nValue;
end

function tbBaseFightTeam:UpdateValue(nJiFen, nWinCount, nJoinCount)
    local nValue = nJiFen * 100 * 100 + nWinCount * 100 + nJoinCount;
    self.tbSaveData[tbHSLJDef.nTeamTypeValue] = nValue;
end

function tbBaseFightTeam:GetJoinCount()
    local nValue = self:GetValue();
    local nJoinCount = nValue % 100;
    return nJoinCount;
end

function tbBaseFightTeam:GetWinCount()
    local nValue = self:GetValue();
    local nWinCount = math.floor(nValue / 100) % 100;
    return nWinCount;
end

function tbBaseFightTeam:GetJiFen()
    local nValue = self:GetValue();
    local nJiFen = math.floor(nValue / 100 / 100);
    return nJiFen;
end

function tbBaseFightTeam:GetPlayTime()
    local nTime = self.tbSaveData[tbHSLJDef.nTeamTypeTime] or 0;
    return nTime;
end

function tbBaseFightTeam:GetServerIdx()
    local nServerIdx = self.tbSaveData[tbHSLJDef.nTeamTypeServerIdx];
    if not nServerIdx then
        nServerIdx = math.floor(self:GetID() / tbDef.nServerIdxInTeamId) 
    end
    return nServerIdx
end

function tbBaseFightTeam:GetServerName()
    return self.tbSaveData[tbHSLJDef.nTeamTypeServerName] or GetServerName();
end

function tbBaseFightTeam:SetRank( nRank )
    self.tbSaveData[tbHSLJDef.nTeamTypeRank]  = nRank
end

function tbBaseFightTeam:GetRank()
    return self.tbSaveData[tbHSLJDef.nTeamTypeRank] or 0;
end

function tbBaseFightTeam:AddPlayTime(nTime)
    local nTotatTime = self:GetPlayTime();
    self.tbSaveData[tbHSLJDef.nTeamTypeTime] = nTotatTime + nTime;
end

function tbBaseFightTeam:AddWinCount()
    local nJiFen     = self:GetJiFen();
    local nJoinCount = self:GetJoinCount();
    local nWinCount  = self:GetWinCount();
    nWinCount = nWinCount + 1;
    self:UpdateValue(nJiFen, nWinCount, nJoinCount);
end

function tbBaseFightTeam:AddJoinCount()
    local nJiFen     = self:GetJiFen();
    local nJoinCount = self:GetJoinCount();
    local nWinCount  = self:GetWinCount();
    nJoinCount = nJoinCount + 1;
    self:UpdateValue(nJiFen, nWinCount, nJoinCount);
    self:AddPerDayCount();
    if MODULE_ZONESERVER then
        local nFightTeamID = self:GetID()
        local nConnectIdx = WuLinDaHui:GetFightTeamConnIdx(nFightTeamID)
        CallZoneClientScript(nConnectIdx, "WuLinDaHui:OnZCAddJoinCount", nFightTeamID)
    end
end

function WuLinDaHui:OnZCAddJoinCount(nFightTeamID)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID)
    if not tbFightTeam then
        return
    end
    tbFightTeam:AddJoinCount();
end

function tbBaseFightTeam:GetPerDayCount()
    local nPlayTime = self.tbSaveData[tbHSLJDef.nTeamTypePlayDay] or 0;
    local nCurDay = Lib:GetLocalDay();
    local nPlayCount = self.tbSaveData[tbHSLJDef.nTeamTypePerCount] or 0;
    if nPlayTime == nCurDay then
        return nPlayCount;
    end

    self.tbSaveData[tbHSLJDef.nTeamTypePerCount] = 0;
    self.tbSaveData[tbHSLJDef.nTeamTypePlayDay] = nCurDay;
    return 0;    
end

function tbBaseFightTeam:AddPerDayCount()
    local nPerCount = self:GetPerDayCount();
    self.tbSaveData[tbHSLJDef.nTeamTypePerCount] = nPerCount + 1;
end

function tbBaseFightTeam:AddJiFen(nAdd)
    if nAdd <= 0 then
        return;
    end    

    local nJiFen     = self:GetJiFen();
    local nJoinCount = self:GetJoinCount();
    local nWinCount  = self:GetWinCount();
    nJiFen = nJiFen + nAdd;
    self:UpdateValue(nJiFen, nWinCount, nJoinCount);
end

function tbBaseFightTeam:GetRankValue()
    local nJiFen = self:GetJiFen();
    local nWinCount = self:GetWinCount();
    local nTime = self:GetPlayTime();
    local nValue = nJiFen * 100 + nWinCount;
    local nRankTime = tbHSLJDef.nPrePlayTotalTime - nTime;
    if nRankTime <= 0 then
        nRankTime = 0;
    end
    return nValue * tbHSLJDef.nPrePlayTotalTime + nRankTime;
end

function tbBaseFightTeam:AnalyzeRankValue(nValue)
    local nRankTime = nValue % tbHSLJDef.nPrePlayTotalTime;
    local nTime = tbHSLJDef.nPrePlayTotalTime - nRankTime;
    local nJiFen = math.floor(nValue / tbHSLJDef.nPrePlayTotalTime / 100);
    local nWinCount = math.floor(nValue / tbHSLJDef.nPrePlayTotalTime) % 100;
    return nJiFen, nWinCount, nTime;
end



-----------================================

function WuLinDaHui:CheckPlayerFightTeamPeriod(pPlayer)
    if tbDef.nMinPlayerLevel > pPlayer.nLevel then
        return false, string.format("等级不足%d级", tbDef.nMinPlayerLevel);
    end
    local tbSaveData = WuLinDaHui:GetSaveData()
    local nLastStartBaoMingTime = tbSaveData.nLastStartBaoMingTime;
    if pPlayer.GetUserValue(tbDef.SAVE_GROUP, tbDef.SAVE_KEY_TicketTime) <= nLastStartBaoMingTime then
        return false, "不具有参与武林大会的资格！"
    end

    local bRet, szMsg = self:IsBaoMingTime()
    return bRet, szMsg;
end

function WuLinDaHui:GetFightTeamSavaDataKey(nGameType, nVersion)
    local szKey = string.format("WLDHFightTeam%d:%s",nGameType,nVersion);
    return szKey;
end

function WuLinDaHui:GetFightTeamSavaData(nGameType, nVersion)
    local tbSaveData = self:GetSaveData()
    local nVersionStartTime = tbSaveData.nStartBaoMingTime; --普通本服的创建是从报名开始的
    if not self.tbGameFormat[nGameType] then
        nVersionStartTime = tbSaveData["nZoneSynTeamDataTime" .. nGameType];
        assert(nGameType <= (#self.tbGameFormat) * 2)
    end

    if nVersion <= 0 or nVersion >= tbDef.nMaxFightTeamVer then
        Log("Error WuLinDaHui GetFightTeamSavaData", nVersion);
        return;
    end
    assert(nVersionStartTime and nVersionStartTime > 0 )
    
    local szKey = self:GetFightTeamSavaDataKey(nGameType, nVersion);
    ScriptData:AddDef(szKey);
    local tbTeam = ScriptData:GetValue(szKey);
    if tbTeam.nVersionStartTime and tbTeam.nVersionStartTime == nVersionStartTime then
        return tbTeam;
    end

    tbTeam.nVersionStartTime = nVersionStartTime;
    tbTeam.nCount     = 0;
    tbTeam.nVer       = nVersion;
    tbTeam.tbAllTeam  = {};
    return tbTeam;
end


function WuLinDaHui:HaveFightTeamSavaData(nGameType, nVersion)
    local szKey = self:GetFightTeamSavaDataKey(nGameType, nVersion);
    ScriptData:AddDef(szKey);
    local tbTeam = ScriptData:GetValue(szKey);
    if not tbTeam or not tbTeam.nVersionStartTime then
        return false;
    end

    return true;    
end

function WuLinDaHui:GetFightTeamNotSaveData()
    self.tbFightTeamNotSave.tbAllFightTeamName = self.tbFightTeamNotSave.tbAllFightTeamName or {};
    self.tbFightTeamNotSave.tbAllFightTeamInst = self.tbFightTeamNotSave.tbAllFightTeamInst or {};
    -- self:UpdateFightTeamNameNotSaveData(); --启动时加载了
    return self.tbFightTeamNotSave;
end

function WuLinDaHui:GetFightTeamVerData(nFightTeamID)
    local nGameType =  self:GetGameTypeByTeamId(nFightTeamID)
    local nVersion = nFightTeamID % tbDef.nMaxFightTeamVer;
    local tbSaveData = self:GetFightTeamSavaData(nGameType, nVersion);
    return tbSaveData;
end

function WuLinDaHui:GetFightTeamSavaByID(nFightTeamID)
    local tbSaveData = self:GetFightTeamVerData(nFightTeamID);
    if not tbSaveData then
        return;
    end    

    return tbSaveData.tbAllTeam[nFightTeamID];
end

function WuLinDaHui:GetFightTeamByID(nFightTeamID)
    if nFightTeamID == 0 then
        return
    end
    local tbSaveData = self:GetFightTeamSavaByID(nFightTeamID);
    if not tbSaveData then
        return;
    end

    local tbNotSave = self:GetFightTeamNotSaveData();
    local tbInst = tbNotSave.tbAllFightTeamInst[nFightTeamID];
    if not tbInst then
        tbInst = Lib:NewClass(WuLinDaHui.__tbBaseFightTeam);
        tbNotSave.tbAllFightTeamInst[nFightTeamID] = tbInst;
    end

    tbInst:SetSaveData(tbSaveData, nFightTeamID);

    return tbInst;
end

function WuLinDaHui:GetPlayerFightTeam(pPlayer, nGameType)
    self.tbAllPlayerFightTeamID[nGameType] = self.tbAllPlayerFightTeamID[nGameType] or {};
    local tbData1 = self.tbAllPlayerFightTeamID[nGameType][pPlayer.nZoneServerId]
    if tbData1 then
        return  tbData1[pPlayer.dwOrgPlayerId] or 0
    end
    return 0
end

function WuLinDaHui:GetPlayerFightTeamIdByRoleId(dwRoleId, nGameType, nServerId)
    self.tbAllPlayerFightTeamID[nGameType] = self.tbAllPlayerFightTeamID[nGameType] or {};
    self.tbAllPlayerFightTeamID[nGameType][nServerId] = self.tbAllPlayerFightTeamID[nGameType][nServerId] or {};
    return self.tbAllPlayerFightTeamID[nGameType][nServerId][dwRoleId] or 0;
end

function WuLinDaHui:RemoveFightTeam(nFightTeamID)
    local tbSaveData = self:GetFightTeamVerData(nFightTeamID);
    local tbAllFightTeam = tbSaveData.tbAllTeam;
    if not tbAllFightTeam then
        return;
    end    

    local tbFightTeamData = tbAllFightTeam[nFightTeamID];
    if not tbFightTeamData then
        return;
    end

    local tbNotSave = self:GetFightTeamNotSaveData();
    local tbInst = self:GetFightTeamByID(nFightTeamID);
    local szName = tbInst:GetName();

    tbNotSave.tbAllFightTeamName[szName] = nil;
    tbNotSave.tbAllFightTeamInst[nFightTeamID] = nil;
    tbAllFightTeam[nFightTeamID] = nil;

    Log("WuLinDaHui RemoveFightTeam ", nFightTeamID);
    return;
end

function WuLinDaHui:UpdateFightTeamNameNotSaveData()
    if self.tbFightTeamNotSave.bLoadData then
        return;
    end

    self.tbFightTeamNotSave.tbAllFightTeamName = {};
    self.tbFightTeamNotSave.bLoadData = true;

    for nGameType, _ in pairs(self.tbGameFormat) do
        for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
            local bRet = self:HaveFightTeamSavaData(nGameType, nVer);
            if not bRet then
                break;
            end    
            local tbSaveData = self:GetFightTeamSavaData(nGameType, nVer)
            for nFightTeamID, _ in pairs(tbSaveData.tbAllTeam) do
                local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
                local szName = tbFightTeam:GetName();
                self.tbFightTeamNotSave.tbAllFightTeamName[szName] = nFightTeamID;
            end    
        end      
    end
end

function WuLinDaHui:UpdateFightTeamZoneData(nSaveGameType)
    local tbCachedData = {}
    for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
        local bRet = self:HaveFightTeamSavaData(nSaveGameType, nVer);
        if not bRet then
            break;
        end    
        local tbSaveData = self:GetFightTeamSavaData(nSaveGameType, nVer)
        for nFightTeamID, _ in pairs(tbSaveData.tbAllTeam) do
            local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
            local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID)
            local tbTeamInfo = {
                nFightTeamID = nFightTeamID;
                szName = tbFightTeam:GetName();
                nWinCount = tbFightTeam:GetWinCount();
                nPlayerTime = tbFightTeam:GetPlayTime();
                nJiFen = tbFightTeam:GetJiFen();
                nRankValue = tbFightTeam:GetRankValue();
                nServerIdx = tbFightTeam:GetServerIdx();
                szServerName = tbFightTeam:GetServerName();
                nRank = tbFightTeam:GetRank(); --传过来时已经设上，所以统一是用的跨服的了
            }
            if tbFinalsInfo then
                tbTeamInfo.nPlan = tbFinalsInfo.nPlan
            end
            table.insert(tbCachedData, tbTeamInfo)
        end    
    end      
    table.sort( tbCachedData, function (a, b)
        return a.nRank < b.nRank
    end )

    local tbZoneNotSaveData = self.tbZoneNotSaveData
    tbZoneNotSaveData.tbCachedTopPreFightTeamList = tbZoneNotSaveData.tbCachedTopPreFightTeamList or {}
    tbZoneNotSaveData.tbCachedTopPreFightTeamList[nSaveGameType] = tbCachedData
    tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime = tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime or {}
    local nNow = GetTime()
    tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime[nSaveGameType] = nNow
    return tbCachedData, nNow
end

function WuLinDaHui:CheckUpdateFightTeamNameZoneData(nSaveGameType)
    --跨服的是需求查看信息，要缓存起来
    local tbSaveData = self:GetSaveData() --清空存盘记录
    local nZoneSynTeamDataTime = tbSaveData["nZoneSynTeamDataTime" .. nSaveGameType]
    if not nZoneSynTeamDataTime or nZoneSynTeamDataTime < tbSaveData.nStartBaoMingTime then
        Log("WuLinDaHui:CheckUpdateFightTeamNameZoneData not CurData")
        return
    end

    local tbZoneNotSaveData = self.tbZoneNotSaveData
    tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime = tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime or {}
    local nRefreshTime = tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime[nSaveGameType]
    if nRefreshTime and nRefreshTime >= nZoneSynTeamDataTime then --因为还有上面主动 UpdateFightTeamZoneData  的地方
        return tbZoneNotSaveData.tbCachedTopPreFightTeamList[nSaveGameType], nRefreshTime
    end
    local tbCachedData = self:UpdateFightTeamZoneData(nSaveGameType)
    tbZoneNotSaveData.tbRefreshTopPreFightTeamListTime[nSaveGameType] = nZoneSynTeamDataTime
    return tbCachedData, nZoneSynTeamDataTime
end

function WuLinDaHui:GetFightTeamIDByName(szTeamName)
    local tbNotSave = self:GetFightTeamNotSaveData();
    local tbAllFightTeamName = tbNotSave.tbAllFightTeamName;
    if not tbAllFightTeamName then
        return;
    end

    return tbAllFightTeamName[szTeamName];
end

function WuLinDaHui:CheckJoinTeamMember(nPlayerID, nGameType)
    local pMember = KPlayer.GetPlayerObjById(nPlayerID);
    if not pMember then
        local tbPlayerInfo = self:GetPlayerInfoByID(nPlayerID);
        return false, string.format("「%s」不线上", tbPlayerInfo.szName);
    end

    if tbDef.nMinPlayerLevel > pMember.nLevel then
        return false, string.format("「%s」的等级不足%d", pMember.szName, tbDef.nMinPlayerLevel);
    end

    local tbSaveData = WuLinDaHui:GetSaveData()
    local nLastStartBaoMingTime = tbSaveData.nLastStartBaoMingTime;
    if pMember.GetUserValue(tbDef.SAVE_GROUP, tbDef.SAVE_KEY_TicketTime) <= nLastStartBaoMingTime then
        return false, string.format("「%s」不具有参与武林大会的资格", pMember.szName);
    end

    local nMemberTeamID = self:GetPlayerFightTeam(pMember, nGameType);
    if nMemberTeamID > 0 then
        return false, string.format("「%s」已经拥有战队", pMember.szName);
    end

    local bRet = Map:CheckEnterOtherMap(pMember);
    if not bRet then
        return false, string.format("「%s」处於非安全区无法进行战队相关操作", pMember.szName);
    end

    if self:GetPlayerTeamNum(pMember) >= tbDef.nMaxJoinTeamNum then
        return false, string.format("「%s」已参与%d支队伍", pMember.szName, tbDef.nMaxJoinTeamNum)
    end

    return true, "";
end



function WuLinDaHui:CreateFightTeam(szTeamName, tbPlayers, nGameType)
    local nHaveTeamID = self:GetFightTeamIDByName(szTeamName);
    if nHaveTeamID then
        Log("Error WuLinDaHui CreateFightTeam", szTeamName);
        return 0;
    end

    local tbTeamSave = self:GetCanFightTeamSava(nGameType);
    tbTeamSave.nCount = tbTeamSave.nCount + 1;
    
    local nServerIdx = GetServerIdentity()
    local nFightTeamID  = nServerIdx * tbDef.nServerIdxInTeamId + nGameType * tbDef.nGameTypeInTeamId + tbTeamSave.nCount * tbDef.nMaxFightTeamVer  + tbTeamSave.nVer;
    local tbTeamSaveOne = 
    {
        [tbHSLJDef.nTeamTypeName] = szTeamName;
        [tbHSLJDef.nTeamTypePlayer] = {};
        [tbHSLJDef.nTeamTypeValue] = 0;
        [tbHSLJDef.nTeamTypeTime] = 0;
    }; 

    tbTeamSave.tbAllTeam[nFightTeamID] = tbTeamSaveOne;

    local tbNotSave = self:GetFightTeamNotSaveData();
    tbNotSave.tbAllFightTeamName[szTeamName] = nFightTeamID;

    self:AddFightTeamMembers(nFightTeamID, tbPlayers);
    Log("WuLinDaHui CreateFightTeam", szTeamName, nFightTeamID);
    return nFightTeamID;
end

function WuLinDaHui:AddFightTeamMembers(nFightTeamID, tbPlayers)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        Log("Error WuLinDaHui AddFightTeamMembers", nFightTeamID);
        return;
    end    
    local nGameType = self:GetGameTypeByTeamId(nFightTeamID)
    for _, nPlayerID in pairs(tbPlayers) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        local nMemberTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
        if nMemberTeamID > 0 then
            local tbMemberTeam = self:GetFightTeamByID(nMemberTeamID);
            if tbMemberTeam then
                tbMemberTeam:RemovePlayer(pPlayer.dwOrgPlayerId);
            end 

            Log("Error WuLinDaHui AddFightTeamMembers Have nFightTeamID", nFightTeamID, nMemberTeamID, nPlayerID);    
        end
        
        tbFightTeam:AddPlayerID(nPlayerID);
        Log("WuLinDaHui AddFightTeamMembers", nFightTeamID, szTeamName, nPlayerID);
    end
end

function WuLinDaHui:PlayerCreateFightTeam(nRequestPlayerID, szTeamName, nGameType, bForce)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error WuLinDaHui PlayerCreateFightTeam Not Player", nRequestPlayerID, szTeamName);
        return;
    end
    local bRet, szMsg = self:CheckPlayerCreateFightTeam(pPlayer, szTeamName, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end
    local tbPlayers = {};
    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            tbPlayers[nPlayerID] = nPlayerID;
        end   
    else
        tbPlayers[pPlayer.dwOrgPlayerId] = pPlayer.dwOrgPlayerId;
    end
    if not bForce then
        local szMsg = string.format("你要创建战队：[FFFE0D]%s[-]吗？", szTeamName);

        for _, nPlayerID in pairs(tbPlayers) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            szMsg = szMsg .. string.format("\n%s %s级%s", pMember.szName, pMember.nLevel, Faction:GetName(pMember.nFaction));
        end

        pPlayer.MsgBox(szMsg, {{"确认", self.PlayerCreateFightTeam, self, pPlayer.dwOrgPlayerId, szTeamName, nGameType, true}, {"取消"}});
        return;
    end 

    local nFightTeamID = self:CreateFightTeam(szTeamName, tbPlayers, nGameType);

    for _, nPlayerID in pairs(tbPlayers) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        pMember.CenterMsg(string.format("创建%s战队成功！", szTeamName), true);
        self:RequestFightTeamInfo(pMember, nGameType); 
    end

    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHCreateFightTeam");

    Log("WuLinDaHui PlayerCreateFightTeam", szTeamName, pPlayer.dwOrgPlayerId, nFightTeamID);  
end

function WuLinDaHui:CheckPlayerCreateFightTeam(pPlayer, szTeamName, nGameType)
    local bRet, szMsg = self:CheckPlayerFightTeamPeriod(pPlayer);
    if not bRet then
        return false, szMsg;
    end    

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
    if nFightTeamID > 0 then
        return false, "已经创建战队";
    end

    if Lib:IsEmptyStr(szTeamName) then
        return false, "请输入名字";
    end    

    local nFindTeamID = self:GetFightTeamIDByName(szTeamName);
    if nFindTeamID then
        return false, "战队的名称已经存在！";
    end

    local bRet1, szMsg1 = HuaShanLunJian:CheckFightTeamName(szTeamName);
    if not bRet1 then
        return false, szMsg1;
    end

    bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全区不能操作";
    end

    local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType];
    if not tbGameFormat then
        return false, "无效的比赛模式"
    end

    if self:GetPlayerTeamNum(pPlayer) >= tbDef.nMaxJoinTeamNum then
        return false, string.format("最多参与%d支队伍", tbDef.nMaxJoinTeamNum)
    end

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local nCaptainId = tbTeam:GetCaptainId();
        if nCaptainId ~= pPlayer.dwOrgPlayerId then
            return false, "您不是队长";
        end

        local tbMember     = tbTeam:GetMembers();
        local nCountMember = Lib:CountTB(tbMember);
        if nCountMember > tbGameFormat.nFightTeamCount then
            return false, string.format("最多%s个人参加", tbGameFormat.nFightTeamCount);
        end

        for _, nPlayerID in pairs(tbMember) do
            local bRet2, szMsg2 = self:CheckJoinTeamMember(nPlayerID, nGameType);
            if not bRet2 then
                return false, szMsg2;
            end    
        end        
    end

    local tbCanSava = self:GetCanFightTeamSava(nGameType);
    if not tbCanSava then
        return false, "创建战队已满！！";
    end   

    return true, "";
end

function WuLinDaHui:GetCanFightTeamSava(nGameType)
    local tbSaveData = self:GetSaveData();
    local szFightTeamVer = "nFightTeamVer" .. nGameType
    for nV = tbSaveData[szFightTeamVer], tbDef.nMaxFightTeamVer - 1 do
        local tbTeam = self:GetFightTeamSavaData(nGameType, nV);
        if not tbTeam then
            return;
        end

        if tbTeam.nCount < tbDef.nMaxFightTeamCount then
            tbSaveData[szFightTeamVer] = nV;
            return tbTeam;
        end    
    end
end

function WuLinDaHui:CheckJoinFightTeam(pPlayer, nGameType)
    local bRet, szMsg = self:CheckPlayerFightTeamPeriod(pPlayer);
    if not bRet then
        return false, szMsg;
    end

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
    if nFightTeamID <= 0 then
        return false, "未拥有战队";
    end

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId <= 0 then 
        return false, "尚未组队";
    end

    local tbTeam = TeamMgr:GetTeamById(nTeamId)
    local nCaptainId = tbTeam:GetCaptainId();
    if nCaptainId ~= pPlayer.dwOrgPlayerId then
        return false, "您不是队长";
    end

    local tbMember = tbTeam:GetMembers();
    local nCountMember = Lib:CountTB(tbMember);
    if nCountMember ~= tbHSLJDef.nFightTeamJoinMemebr then
        return false, "请两人单独组队";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    local nCurTeamCount = tbFightTeam:GetPlayerCount();
    local nTotalCount = nCurTeamCount + nCountMember - 1;

    local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType] ;
    if not tbGameFormat then
        return false, "无效的比赛模式"
    end
    if nTotalCount > tbGameFormat.nFightTeamCount then
        return false, string.format("本模式的战队最多允许%s名队员", tbGameFormat.nFightTeamCount);
    end

    bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全区不能操作";
    end 

    local nJoinPlayerID = nil;
    for _, nPlayerID in pairs(tbMember) do
        if nPlayerID ~= pPlayer.dwOrgPlayerId then
            local bRet1, szMsg1 = self:CheckJoinTeamMember(nPlayerID,nGameType);
            if not bRet1 then
                return false, szMsg1;
            end

            nJoinPlayerID = nPlayerID;
        end     
    end

    if not nJoinPlayerID then
        return false, "没有成员加入";
    end    

    return true, "", nJoinPlayerID;
end

function WuLinDaHui:OnRefuseJoinFightTeam(nRequestPlayerID, nMemberID)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        return;
    end
    local pMember = KPlayer.GetPlayerObjById(nMemberID);
    if not pMember then
        return;
    end
    pPlayer.CenterMsg(string.format("「%s」拒绝了加入您的战队", pMember.szName))
end

function WuLinDaHui:PlayerJoinFightTeam(nRequestPlayerID, nGameType, bConfirm, bForce)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error WuLinDaHui PlayerJoinFightTeam Not Player", nRequestPlayerID);
        return;
    end

    local bRet, szMsg, nJoinPlayerID = self:CheckJoinFightTeam(pPlayer, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    local pJoinMember = KPlayer.GetPlayerObjById(nJoinPlayerID);
    local tbGameFormat = self.tbGameFormat[nGameType]
    if not bConfirm then
        local szMsg = string.format("你确定将「%s」组入的你的[FFFE0D]%s[-]战队%s吗？", pJoinMember.szName, tbGameFormat.szName, tbFightTeam:GetName());
        pPlayer.MsgBox(szMsg, {{"确认", self.PlayerJoinFightTeam, self, nRequestPlayerID, nGameType, true}, {"取消"}});
        return;
    end    

    if not bForce then
        local szMsg = string.format("%s邀请你加入[FFFE0D]%s[-]「%s」战队\n成员：", pPlayer.szName, tbGameFormat.szName, tbFightTeam:GetName());
        local szMsgMember = nil;
        local tbCurPlayers = tbFightTeam:GetAllPlayerID();
        for nPlayerID, _ in pairs(tbCurPlayers) do
            local tbPlayerInfo = self:GetPlayerInfoByID(nPlayerID);
            if not szMsgMember then
                szMsgMember = string.format("「%s」 %s级%s", tbPlayerInfo.szName, tbPlayerInfo.nLevel, Faction:GetName(tbPlayerInfo.nFaction));
            else
               szMsgMember = szMsgMember .. string.format(",「%s」 %s级%s", tbPlayerInfo.szName, tbPlayerInfo.nLevel, Faction:GetName(tbPlayerInfo.nFaction)); 
            end    
        end

        szMsg = szMsg .. szMsgMember;
        szMsg = szMsg .. "\n是否同意加入该战队！";
        pJoinMember.MsgBox(szMsg, {{"同意", self.PlayerJoinFightTeam, self, nRequestPlayerID, nGameType, true, true}, {"婉拒", self.OnRefuseJoinFightTeam, self, nRequestPlayerID, pJoinMember.dwOrgPlayerId }});
        pPlayer.CenterMsg(string.format("正在邀请%s加入战队！", pJoinMember.szName), true);
        return;
    end

    local tbPlayers = {};
    tbPlayers[nJoinPlayerID] = nJoinPlayerID;
    self:AddFightTeamMembers(nFightTeamID, tbPlayers);
    pPlayer.CenterMsg(string.format("成功邀请「%s」加入战队！", pJoinMember.szName), true);
    pJoinMember.CenterMsg(string.format("您成功加入了%s战队！", tbFightTeam:GetName()), true);

    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHJoinFightTeam");

    self:RequestFightTeamInfo(pPlayer, nGameType);
    self:RequestFightTeamShowInfo(pPlayer, nFightTeamID);
    self:RequestFightTeamInfo(pJoinMember, nGameType);

    local tbOnLinePlayers = tbFightTeam:GetAllPlayerID();
    for nOnLinePlayerID, _ in pairs(tbOnLinePlayers) do
        if nOnLinePlayerID ~= pPlayer.dwOrgPlayerId and nOnLinePlayerID ~= nJoinPlayerID then
            local pOnLinePlayer = KPlayer.GetPlayerObjById(nOnLinePlayerID);
            if pOnLinePlayer then
                self:RequestFightTeamInfo(pOnLinePlayer, nGameType);
                pOnLinePlayer.CallClientScript("WuLinDaHui:OnChangeTeamInfo", nGameType);
                pOnLinePlayer.Msg(string.format("「%s」加入了您的武林大会[FFFE0D]%s[-]战队！", pJoinMember.szName, tbGameFormat.szName));
            end    
        end
    end

    Log("WuLinDaHui PlayerJoinFightTeam", nRequestPlayerID, nFightTeamID);    
end

function WuLinDaHui:CheckPlayerQuitFightTeam(pPlayer, nGameType)
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
    if nFightTeamID <= 0 then
        return false, "您没有战队，何来退出？";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "系统出错，战队不存在，请联系客服人员！";
    end    

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全区不能操作";
    end

    bRet = tbFightTeam:HavePlayerID(pPlayer.dwOrgPlayerId);
    if not bRet then
        return false, "系统出错，你不存在战队，请联系客服人员！";
    end

    local nJoinCount = tbFightTeam:GetJoinCount();
    if nJoinCount > 0 then
        return false, "您所在战队已有比赛成绩，不能退出。"
    end    
    local bRet, szMsg = self:IsBaoMingTime()
    if not bRet then
        return bRet, szMsg
    end

    return true, "", nFightTeamID;
end

function WuLinDaHui:PlayerQuitFightTeam(nRequestPlayerID, nGameType, bConfirm)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error WuLinDaHui PlayerQuitFightTeam", nRequestPlayerID);
        return;
    end

    local tbGameFormat = self.tbGameFormat[nGameType];
    if not tbGameFormat then
        Log("Error WuLinDaHui  PlayerQuitFightTeam mode", nGameType)
        return
    end

    local bRet, szMsg, nFightTeamID = self:CheckPlayerQuitFightTeam(pPlayer, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not bConfirm then
        local szMsg = string.format("您确定退出战队%s吗？", tbFightTeam:GetName());
        pPlayer.MsgBox(szMsg, {{"确认", self.PlayerQuitFightTeam, self, nRequestPlayerID, nGameType, true}, {"取消"}});
        return;
    end    

    tbFightTeam:RemovePlayer(pPlayer.dwOrgPlayerId);
    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    pPlayer.CenterMsg(string.format("您退出了%s战队！", tbFightTeam:GetName()), true);
    local nPlayerCount = tbFightTeam:GetPlayerCount();
    if nPlayerCount > 0 then
        local szContent = string.format("大侠，很遗憾的通知你，武林大会%s模式战队成员%s离开了大家。请尽快找到新的侠士来一起战斗吧！", tbGameFormat.szName, pPlayer.szName);
        for nPlayerID, _ in pairs(tbAllPlayer) do
            local tbMail = 
            {
                To = nPlayerID,
                Text = szContent;
            }
            Mail:SendSystemMail(tbMail);
        end    
    else
        self:RemoveFightTeam(nFightTeamID);
        pPlayer.CenterMsg("您所在的战队已经解散了！", true);
    end

    
    self:RequestFightTeamInfo(pPlayer, nGameType); --YI
    pPlayer.CallClientScript("WuLinDaHui:OnChangeTeamInfo", nGameType);
    for nOnLinePlayerID, _ in pairs(tbAllPlayer) do
        local pOnLinePlayer = KPlayer.GetPlayerObjById(nOnLinePlayerID);
        if pOnLinePlayer then
            self:RequestFightTeamInfo(pOnLinePlayer, nGameType);
            pOnLinePlayer.CallClientScript("WuLinDaHui:OnChangeTeamInfo", nGameType);
        end    
    end

    Log("WuLinDaHui PlayerQuitFightTeam", pPlayer.dwOrgPlayerId, nFightTeamID);
end

function WuLinDaHui:GetPlayerTeamNum(pPlayer)
    local nSelfCurTeamNum = 0;
    for nGameType, v in pairs(self.tbGameFormat) do
        local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType)
        if nFightTeamID > 0 then
            nSelfCurTeamNum = nSelfCurTeamNum + 1;
        end
    end
    return nSelfCurTeamNum
end


function WuLinDaHui:DeleteFightTeam(nRequestPlayerID, nGameType, bConfirm)
    local pPlayer = KPlayer.GetPlayerObjById(nRequestPlayerID);
    if not pPlayer then
        Log("Error WuLinDaHui PlayerQuitFightTeam", nRequestPlayerID);
        return;
    end

    local tbGameFormat = self.tbGameFormat[nGameType];
    if not tbGameFormat then
        Log("Error WuLinDaHui  PlayerQuitFightTeam mode", nGameType)
        return
    end

    local bRet, szMsg, nFightTeamID = self:CheckPlayerQuitFightTeam(pPlayer, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not bConfirm then
        local szMsg = string.format("取消报名将[FFFE0D]解散“%s”战队[-]，阁下需要与队友重新组队报名比赛，确定取消吗？",  tbGameFormat.szName );
        pPlayer.MsgBox(szMsg, {{"确认", self.DeleteFightTeam, self, nRequestPlayerID, nGameType, true}, {"取消"}});
        return;
    end    

    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    local tbRemovePlayerIds = {};

    for nPlayerID, _ in pairs(tbAllPlayer) do
        tbFightTeam:RemovePlayer(nPlayerID); --会修改掉tbAllPlayer
        table.insert(tbRemovePlayerIds, nPlayerID)
    end    
    self:RemoveFightTeam(nFightTeamID);
    pPlayer.CenterMsg(string.format("阁下取消了“%s”的报名，“%s”战队已解散！", tbGameFormat.szName, tbGameFormat.szName), true)
    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHQuitFightTeam");
    local tbMail = 
    {
        Title = "武林大会报名取消";
        Text = string.format("大侠，战队成员[FFFE0D]「%s」[-]取消了参加武林大会[FFFE0D]「%s」[-]的报名！\n阁下若要继续参与比赛，请再次与具有武林大会参与资格的侠士组队并报名", pPlayer.szName, tbGameFormat.szName);
    }
    for _, nPlayerID in ipairs(tbRemovePlayerIds) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID)
        if pMember then
            self:RequestFightTeamInfo(pMember, nGameType); 
        end
        tbMail.To = nPlayerID
        Mail:SendSystemMail(tbMail);
    end    
    Log("WuLinDaHui DeleteFightTeam", pPlayer.dwOrgPlayerId, nFightTeamID);
end

function WuLinDaHui:GetPlayerInfoByID(nPlayerID)
    local tbInfo = {};
    tbInfo.szName   = "-";
    tbInfo.nFaction = 1;

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            tbInfo.szName = tbStayInfo.szName;
            tbInfo.nFaction = tbStayInfo.nFaction;
            tbInfo.nLevel = tbStayInfo.nLevel;
        end
    else
        tbInfo.szName = pPlayer.szName;
        tbInfo.nFaction = pPlayer.nFaction;
        tbInfo.nLevel = pPlayer.nLevel;
    end

    return tbInfo;
end

function WuLinDaHui:AddFightTeamJiFen(nFightTeamID, bWin, nJiFen, nPlayTime)
   local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
   if not tbFightTeam then
        return;
   end

   if bWin then
        tbFightTeam:AddWinCount();
   end

   if nJiFen > 0 then
       tbFightTeam:AddJiFen(nJiFen);
   end

   tbFightTeam:AddPlayTime(nPlayTime);
      ---实时同步积分数据
    if not MODULE_ZONESERVER then
        local tbFightTeamInfo = self:GetFightTeamClientInfo(tbFightTeam)
        local tbAllPlayer = tbFightTeam:GetAllPlayerID();
        local nGameType = tbFightTeamInfo.nGameType
        for nPlayerId, v in pairs(tbAllPlayer) do
           local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
           if pPlayer then
                pPlayer.CallClientScript("Player:ServerSyncData", "WLDHFightTeamInfo" .. nGameType, tbFightTeamInfo);        
           end
       end
   end

   Log("WuLinDaHui AddFightTeamJiFen", tbFightTeam:GetName(), nFightTeamID, nJiFen, nPlayTime, tostring(bWin));
end

function WuLinDaHui:CheckChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType)
    if type(tbPlayerNum) ~= "table" then
        return false, "操作的资料错误";
    end
        
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
    if nFightTeamID <= 0 then
        return false, "您没有战队不能操作";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "系统出错，战队不存在，请联系客服人员！";
    end    

    local tbGameFormat = self.tbGameFormat[nGameType]
    if not tbGameFormat then
        return false, "Error"
    end
    if tbGameFormat.szPKClass ~= "PlayDuel" then
        return false, "非决斗赛不能操作";
    end 

    local nChangeCount = Lib:CountTB(tbPlayerNum);    
    local nTotalCount = tbFightTeam:GetPlayerCount();
    if nChangeCount ~= nTotalCount then
        return false, "请选择更换的阵容";
    end

    local tbHaveNum = {};
    for nPlayerID, nNum in pairs(tbPlayerNum) do
        if not nPlayerID then
            return false, "操作的阵容资料错误!!";
        end    

        local bRet = tbFightTeam:HavePlayerID(nPlayerID);
        if not bRet then
            return false, "有玩家不在当前的战队";
        end

        if nNum <= 0 or nNum > nTotalCount then
            return false, "操作的阵容资料错误";
        end

        if tbHaveNum[nNum] then
            return false, "操作的阵容资料错误!";
        end    

        tbHaveNum[nNum] = 1;    
    end

    return true, "", tbFightTeam;    
end