
local tbAct = Activity:GetClass("HonorLevelRank");

tbAct.tbTimerTrigger = 
{
};

tbAct.tbTrigger = 
{
    Init = {},
    Start = {},
    End = {},
};

tbAct.tbHonorLevelType =
{
    [1] = 
    {
        nHonorLevel = 6; --头衔的等级
        tbAllRankAward = 
        {
            {nMinRank = 1, nMaxRank = 1, tbAward = {{"item", 6015, 1}, {"item", 1126, 1}} };
            {nMinRank = 2, nMaxRank = 10, tbAward = {{"item", 6017, 1}, {"item", 1616, 1}} };
        };
        tbMailInfo =
        {
            szTitle = "潜龙头衔冲榜奖励";
            szContent =
[[恭喜少侠！在“潜龙头衔冲榜”活动中表现优异，现已获得第[FFFE0D]%s[-]名的奖励，请查收。
望少侠继续努力，早日名震江湖！
]];
        };
        tbUpdateNewInformation =
        {
            szTitle = "潜龙头衔冲榜";
            szContent =
[[  活动时间：[c8ff00]%s年%s月%s日0点-%s年%s月%s日%s点[-]
    诸位侠士：
    如今江湖风起云涌，各路豪侠共聚于此。现推出“潜龙头衔冲榜”活动，对优先达到[aa62fc]潜龙头衔[-]的杰出豪侠给予丰厚奖励。
    其中第一名将给予[ff578c] [url=openwnd:称号·第一潜龙, ItemTips, "Item", nil, 6015] [-]、[ff8f06] [url=openwnd:五阶稀有武器, ItemTips,  "Item", nil, 1126, me.nFaction] [-]的丰厚奖励；
    第二到十名将给予[aa62fc] [url=openwnd:称号·十大潜龙, ItemTips, "Item", nil, 6017] [-]、[aa62fc] [url=openwnd:五阶传承武器, ItemTips,  "Item", nil, 1616, me.nFaction] [-]的丰厚奖励。
    望大家积极参加，勇夺殊荣！
    以下为当前冲榜名单:
%s
]];
        };

    };

    [2] = 
    {
        nHonorLevel = 8; --头衔的等级
        tbAllRankAward = 
        {
            {nMinRank = 1, nMaxRank = 1, tbAward = {{"item", 6016, 1}, {"item", 4282, 1}} };
            {nMinRank = 2, nMaxRank = 10, tbAward = {{"item", 6018, 1}, {"item", 4289, 1}} };
        };
        tbMailInfo =
        {
            szTitle = "倚天头衔冲榜奖励";
            szContent =
[[恭喜少侠！在“倚天头衔冲榜”活动中表现优异，现已获得第[FFFE0D]%s[-]名的奖励，请查收。
望少侠继续努力，早日名震江湖！
]];
        };
        tbUpdateNewInformation =
        {
            szTitle = "倚天头衔冲榜";
            szContent =
[[  活动时间：[c8ff00]%s年%s月%s日0点-%s年%s月%s日%s点[-]
    诸位侠士：
    如今江湖纷争不断，各路豪侠的进步更是一日千里。现推出“倚天头衔冲榜”活动，对优先达到[ff578c]倚天头衔[-]的杰出豪侠给予丰厚奖励。
    其中第一名将给予[ff578c] [url=openwnd:称号·第一倚天, ItemTips, "Item", nil, 6016] [-]、[ff8f06] [url=openwnd:【稀有】太虚之灵, ItemTips,  "Item", nil, 4282] [-]的丰厚奖励；
    第二到十名将给予[aa62fc] [url=openwnd:称号·十大倚天, ItemTips, "Item", nil, 6018] [-]、[aa62fc] [url=openwnd:【传承】太虚之灵, ItemTips,  "Item", nil, 4289] [-]的丰厚奖励。
    望大家积极参加，勇夺殊荣！
    以下为当前冲榜名单:
%s
]];
        };
    };
}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:UpdateNewInformation();
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_HonorLevel", "OnHonorLevel");
    end

    local nType = self:GetHonorLevelType();
    Log("HonorLevelRank OnTrigger:", szTrigger, nType or "-");
end

function tbAct:GetHonorLevelType()
    if not self.tbParam then
        return;
    end

    if not self.tbParam[1] then
        return;
    end

    local nType = tonumber(self.tbParam[1]);
    return nType;
end

function tbAct:GetRankAward(tbTypeInfo, nRank)
    for _, tbInfo in pairs(tbTypeInfo.tbAllRankAward) do
        if tbInfo.nMinRank <= nRank and nRank <= tbInfo.nMaxRank then
            return tbInfo;
        end    
    end
end

function tbAct:CheckPlayerHonorLevel(pPlayer, nHonorLevel)
    local nType = self:GetHonorLevelType();
    if not nType then
        return false;
    end

    local tbHonorLevelInfo = Player.tbHonorLevel:GetHonorLevelInfo(nHonorLevel);
    if not tbHonorLevelInfo then
        return false;
    end    

    local tbTypeInfo = tbAct.tbHonorLevelType[nType];
    if not tbTypeInfo then
        return false;
    end

    if tbTypeInfo.nHonorLevel ~= nHonorLevel then
        return false;
    end

    local tbSaveData = self:GetSaveHonorLevel(nType);
    if tbSaveData.tbPlayer[pPlayer.dwID] then
        return false;
    end

    local nCurRank = tbSaveData.nRank + 1;
    local tbRankAward = self:GetRankAward(tbTypeInfo, nCurRank);
    if not tbRankAward then
        return false;
    end

    return true, tbRankAward, nCurRank, nType;    
end

function tbAct:OnHonorLevel(pPlayer, nHonorLevel)
    local bRet, tbRankAward, nRank, nType = self:CheckPlayerHonorLevel(pPlayer, nHonorLevel);
    if not bRet then
        return;
    end

    local tbTypeInfo = tbAct.tbHonorLevelType[nType];
    local tbSaveData = self:GetSaveHonorLevel(nType);
    tbSaveData.tbPlayer[pPlayer.dwID] = nRank;
    tbSaveData.nRank = nRank;

    local szKey = self:GetSaveKey(nType);
    ScriptData:AddModifyFlag(szKey);

    local tbMail =
    {
        To = pPlayer.dwID,
        Title = tbTypeInfo.tbMailInfo.szTitle,
        Text = string.format(tbTypeInfo.tbMailInfo.szContent, nRank);
        nLogReazon = Env.LogWay_ActHonorLevelRank;
        tbAttach = tbRankAward.tbAward,
    }

    Mail:SendSystemMail(tbMail);
    self:UpdateNewInformation();
    Log("HonorLevelRank OnHonorLevel", pPlayer.dwID, nHonorLevel, nType, nRank);
end

function tbAct:GetSaveKey(nType)
    local szKey = string.format("ActHonorLevelRank:%s", nType);
    return szKey;
end

function tbAct:GetSaveHonorLevel(nType)
    local szKey = self:GetSaveKey(nType);
    ScriptData:AddDef(szKey);
    local tbSaveHonor = ScriptData:GetValue(szKey);
    if not tbSaveHonor.nRank then
        tbSaveHonor.nRank = 0;
        tbSaveHonor.tbPlayer = {};
    end

    return tbSaveHonor;
end

function tbAct:UpdateNewInformation()
    local nType = self:GetHonorLevelType();
    if not nType then
        return;
    end

    local tbTypeInfo = tbAct.tbHonorLevelType[nType];
    if not tbTypeInfo then
        return;
    end

    local szPlayerRank = "";
    local tbSaveData = self:GetSaveHonorLevel(nType);
    local tbAllShowInfo = {};
    for nPlayerID, nRank in pairs(tbSaveData.tbPlayer) do
        local pRole = KPlayer.GetRoleStayInfo(nPlayerID)
        local szName = "-";
        if pRole then
            szName = pRole.szName;
        end

        local tbPlayerInfo = {nPlayerID = nPlayerID, szName = szName, nRank = nRank};
        tbAllShowInfo[nRank] = tbPlayerInfo;
    end
    
    for nI = 1, 10 do
        local szExt = "  ";
        if nI == 10 then
            szExt = "";
        end

        local tbInfo = tbAllShowInfo[nI];
        if tbInfo then
            szPlayerRank = szPlayerRank .. string.format("    第[FFFE0D]%s[-]名：%s[FFFE0D][url=viewrole:%s,%s][-]\n", tbInfo.nRank, szExt, tbInfo.szName, tbInfo.nPlayerID);
        else
            szPlayerRank = szPlayerRank .. string.format("    第[FFFE0D]%s[-]名：%s虚位以待\n", nI, szExt);    
        end    
    end

    local nStartTime, nEndTime = self:GetOpenTimeInfo();
    local tbTime1 = os.date("*t", nStartTime)
    local tbTime2 = os.date("*t", nEndTime);
    local szContent = string.format(tbTypeInfo.tbUpdateNewInformation.szContent, tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.year, tbTime2.month, tbTime2.day, tbTime2.hour, szPlayerRank);
    NewInformation:AddInfomation("ActHonorLevelRank_NewInfo", nEndTime, {szContent}, {szTitle = tbTypeInfo.tbUpdateNewInformation.szTitle, nReqLevel = 1});
end