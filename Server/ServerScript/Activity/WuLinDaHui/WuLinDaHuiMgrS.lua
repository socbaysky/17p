if MODULE_ZONESERVER then
	return
end

WuLinDaHui.tbFightTeamNotSave = WuLinDaHui.tbFightTeamNotSave or {}; --战队不保存数据
WuLinDaHui.tbNotSaveData = WuLinDaHui.tbNotSaveData or {}; --一些不存盘的临时数据
WuLinDaHui.tbFinalsGameNotSave = WuLinDaHui.tbFinalsGameNotSave or {}; --决赛不保存数据
WuLinDaHui.tbZoneNotSaveData = WuLinDaHui.tbZoneNotSaveData or {}; --跨服过来的数据

local tbDef = WuLinDaHui.tbDef

function WuLinDaHui:LoadSetting()
    self.tbAllGameFormatAward = {};
    local  tbFileData = Lib:LoadTabFile("Setting/WuLinDaHui/GameFormatAward.tab", {GameFormat = 1, MinRank = 1, MaxRank = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        tbInfo.tbAllAward = {};
        if not Lib:IsEmptyStr(tbInfo["AllAward"]) then
            tbInfo.tbAllAward = Lib:GetAwardFromString(tbInfo["AllAward"]);
        end

        if not Lib:IsEmptyStr(tbInfo["RedBagKey"]) then
            tbInfo.tbRedBagKeys = Lib:SplitStr(tbInfo["RedBagKey"], ";")
        end

        self.tbAllGameFormatAward[tbInfo.GameFormat] = self.tbAllGameFormatAward[tbInfo.GameFormat] or {};
        table.insert(self.tbAllGameFormatAward[tbInfo.GameFormat], tbInfo);
    end
end

WuLinDaHui:LoadSetting();

function WuLinDaHui:OnServerStartup()
    --必须在活动后
    if WuLinDaHui:IsBaoMingAndMainActTime() then
        self:UpdateFightTeamNameNotSaveData() 
        self:UpdateAllPlayerGuessingVersion()
    end
    if Activity:__IsActInProcessByType(self.szActNameMain) and not self.nServerStartupTimer then
        self.nServerStartupTimer = Timer:Register(Env.GAME_FPS * 60, self.TimerCheckSendZoneData, self)
    end
end

local nRunCount = 0
function WuLinDaHui:TimerCheckSendZoneData()
    nRunCount = nRunCount + 1;
    self:TrySendDataToZoneServer()
    if nRunCount >= 20 then
        self.nServerStartupTimer = nil
        return
    else
        return true
    end
end

function WuLinDaHui:InitAtNewBaoMing()
    self.tbFightTeamNotSave = {};
    self.tbNotSaveData = {};
    self.tbFinalsGameNotSave = {};
    self.tbZoneNotSaveData = {};
    self.tbAllPlayerFightTeamID = {};

    self:CheckGiveTicket()

    --清除之前先取上次的报名时间
    
    local tbSaveData = ScriptData:GetValue("WuLinDaHuiData"); 
    local nLastStartBaoMingTime = (tbSaveData.nStartBaoMingTime or 0) + 1;  
    ScriptData:SaveValue("WuLinDaHuiData", {}) --直接清除所有之前记录的吧
	local tbSaveData = ScriptData:GetValue("WuLinDaHuiData"); 
	tbSaveData.nMatchDay = 0; --比赛的第几天
	tbSaveData.nCheckOpenDay = 0;
    for nGameType,v in ipairs(self.tbGameFormat) do
        tbSaveData["tbFinalsFightTeam" .. nGameType] = {};
        tbSaveData["tbNeedSynRoleInfoIds" .. nGameType] = nil;
    end
    tbSaveData.nGuessingVer = 1;
	local nNow = GetTime();
	--上次的报名时间，获取前50的大于该时间才是有资格的, 因为第一次wldh打时是设的一样的时间，而且没有0， 所以做了+1
    tbSaveData.nLastStartBaoMingTime = nLastStartBaoMingTime;
	tbSaveData.nStartBaoMingTime = nNow; 
end

function WuLinDaHui:CheckGiveTicket()
    --对于没有开过华山论剑的直接根据排行榜给门票资格
    local pRank = KRank.GetRankBoard(HuaShanLunJian.tbDef.szRankBoard)
    if pRank and pRank.GetRankInfoByPos(0) then
        return 
    end
    self:SetRankPlayersTicket()
end

function WuLinDaHui:EndAct()
    local tbSaveData = self:GetSaveData()
    for nGameType,v in ipairs(self.tbGameFormat) do
        tbSaveData["tbNeedSynRoleInfoIds" .. nGameType] = nil;
    end
end

function WuLinDaHui:SetPlayersTicket()
    local pRank = KRank.GetRankBoard(HuaShanLunJian.tbDef.szRankBoard)
    local nNow = GetTime()
    for nRank = 1, tbDef.nHSLJTicketRankPos do
         local tbInfo = pRank.GetRankInfoByPos(nRank - 1);
         if not tbInfo then
             break;
         end      
         local tbFightTeam = HuaShanLunJian:GetFightTeamByID(tbInfo.dwUnitID);
         if tbFightTeam then
            local tbAllPlayer = tbFightTeam:GetAllPlayerID();            
            for nPlayerID, _ in pairs(tbAllPlayer) do
                local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
                if pPlayer then
                    self:SetPlayersTicketOne(pPlayer, nNow)
                else
                    local szCmd = string.format("WuLinDaHui:OnDelaySetPlayerTicket('%s')", nNow) 
                    KPlayer.AddDelayCmd(nPlayerID, szCmd, string.format("%s|%s", "WuLinDaHuiDelayUserValue", nNow));
                end
                Log("WuLinDaHui:SetRankPlayersTicket Top", nPlayerID, pPlayer and "online" or "offline", nNow, nRank)                
            end
         end
    end
    Log("WuLinDaHui:SetPlayersTicket")
end

function WuLinDaHui:SetRankPlayersTicket()
    local pRank = KRank.GetRankBoard("FightPower")
    pRank.Rank()

    local nTiceketTime = GetTime() - 3600 * 24;
    for i=1,tbDef.nAutoTicketFightPowerRank do
        local tbInfo = pRank.GetRankInfoByPos(i - 1);
        if not tbInfo then
            break;
        end
        local dwRoleId = tbInfo.dwUnitID
        local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
        if pPlayer then
            self:SetPlayersTicketOne(pPlayer, nTiceketTime, true)
        else
            local szCmd = string.format("WuLinDaHui:OnDelaySetPlayerTicketByRank('%s')", nTiceketTime) 
            KPlayer.AddDelayCmd(dwRoleId, szCmd, string.format("%s|%s", "OnDelaySetPlayerTicketByRank", nTiceketTime));
        end
        Log("WuLinDaHui:ByRankSetRankPlayersTicket Top", dwRoleId, pPlayer and "online" or "offline", i, nTiceketTime)                
    end
end

function WuLinDaHui:SetPlayersTicketOne( pPlayer, nVal, bRank)
    local nOldVal = pPlayer.GetUserValue(tbDef.SAVE_GROUP,  tbDef.SAVE_KEY_TicketTime)
    pPlayer.SetUserValue(tbDef.SAVE_GROUP,  tbDef.SAVE_KEY_TicketTime, nVal)
    local bNotifyMail = false
    if nOldVal == 0 then
        bNotifyMail = true
    else
        local tbSaveData = WuLinDaHui:GetSaveData() --设置时是还没有开始报名的，所以这里是直接取报名时间
        if nOldVal <= tbSaveData.nStartBaoMingTime then
            bNotifyMail = true;
        end
    end
    if bNotifyMail then
        local szMailContent = bRank and tbDef.szMailTextGetTicketByRank or tbDef.szMailTextGetTicket
        Mail:SendSystemMail({
            Title = "武林大会参赛资格";
            Text = szMailContent;
            To = pPlayer.dwID;
        })
    end

    Log("WuLinDaHui:SetPlayersTicketOne", pPlayer.dwID, nVal, nOldVal, tostring(bRank))
end

function WuLinDaHui:OnDelaySetPlayerTicket(nVal)
    self:SetPlayersTicketOne(me, tonumber(nVal))
end

function WuLinDaHui:OnDelaySetPlayerTicketByRank(nVal)
    self:SetPlayersTicketOne(me, tonumber(nVal), true)
end

function WuLinDaHui:IsBaoMingTime()
    local bRet = Activity:__IsActInProcessByType(self.szActNameBaoMing)
    if not bRet then
        return false, "不在报名时间范围内"
    end
	return true;
end

function WuLinDaHui:CheckRequest()
    local nToday = Lib:GetLocalDay()
    local tbSaveData = self:GetSaveData()

    if tbSaveData.nCheckOpenDay ~= nToday then
        tbSaveData.nCheckOpenDay = nToday;
        tbSaveData.nMatchDay = (tbSaveData.nMatchDay or 0) + 1;

    end
    local tbScheInfo = self.tbScheduleDay[tbSaveData.nMatchDay]
    if not tbScheInfo then
        Log("Error!  WuLinDaHui:CheckOpenMatch not such a day", tbSaveData.nMatchDay)
        return
    end
    if tbScheInfo.nGameType ~= tbSaveData.nLastGameType then
        tbSaveData.nOpenTimes = 0;
        tbSaveData.nLastGameType = tbScheInfo.nGameType
    end

    return tbScheInfo
end

function WuLinDaHui:CheckOpenMatch()
   local tbScheInfo = self:CheckRequest();
   if not tbScheInfo then
        return
   end
   --因为决赛和初赛的时间不一样，但是每天都会执行到 所以分开函数处理
   if tbScheInfo.bFinal then
        return
   end

	self:OpenMatch(tbScheInfo.nGameType, tbScheInfo.bFinal);
end

function WuLinDaHui:CheckOpenMatchFinal()
   local tbScheInfo = self:CheckRequest();
   if not tbScheInfo then
        return
   end
   --因为决赛和初赛的时间不一样，所以分开函数处理
   if not tbScheInfo.bFinal then
        return
   end

    self:OpenMatch(tbScheInfo.nGameType, tbScheInfo.bFinal);
end

function WuLinDaHui:CheckCloseMatch()
   self:TryCloseMatch() 
end

function WuLinDaHui:CheckCloseMatchFinal()
    self:TryCloseMatch(true) 
end

function WuLinDaHui:TryCloseMatch(bFinal)
    if not self.tbNotSaveData.nCurGameType then
        Log("WuLinDaHui:CheckCloseMatch Not has Mathch")
        return
    end

    if bFinal and not self.tbNotSaveData.bCurIsFinal then
        Log("WuLinDaHui:TryCloseMatch not the finla")
        return
    end
    if not bFinal and self.tbNotSaveData.bCurIsFinal then
        Log("WuLinDaHui:TryCloseMatch not the Normal")
        return
    end

    if self.tbNotSaveData.bCurIsFinal then
        local tbSaveData = self:GetSaveData()
        local nWinTeamId = tbSaveData["WinnerTeamId" .. self.tbNotSaveData.nCurGameType]
        if not nWinTeamId then
            local tbGameFormat = self.tbGameFormat[self.tbNotSaveData.nCurGameType]
            KPlayer.SendWorldNotify(1, 999, string.format("【武林大会】[eebb01]%s[-]并没有产生冠军[eebb01]", tbGameFormat.szName), 1, 1);
        end
    end
        
    self:ClearMathInfo();

    Calendar:OnActivityEnd("WuLinDaHui"); 
    Log("WuLinDaHui CloseMatch");
end

function WuLinDaHui:CheckNotifyGameStart()
    local tbSaveData = self:GetSaveData()
    local nToday = Lib:GetLocalDay()
    local nMatchDay = tbSaveData.nMatchDay or 0
    if nToday ~= tbSaveData.nCheckOpenDay then
        nMatchDay = nMatchDay + 1;
    end
    local tbScheInfo = self.tbScheduleDay[nMatchDay]
    local tbGameFormat = self.tbGameFormat[tbScheInfo.nGameType]
    local szMsg;
    if  tbScheInfo.bFinal then
        local nNow = GetTime()
        local tbTime = os.date("*t", nNow);
        local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalStartMatchTime, "(%d+):(%d+)");
        local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0}); 
        if math.abs(nSecBegin - nNow) > 3600 then
            return
        end

        szMsg = string.format(tbDef.tbFinalsGame.szBeforeNotifyMsg, tbGameFormat.szName)
    else
        szMsg = string.format(tbDef.tbPrepareGame.szBeforeNotifyMsg, tbGameFormat.szName)
    end
    KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
end

function WuLinDaHui:ClearMathInfo()
	self.tbNotSaveData = {};
    -- tbZoneData不能直接清了，不然先收到 nZoneMapid 再开启本服活动的就会被清掉, 通过收到的时间戳确认有效性
end

function WuLinDaHui:GetCurServerTeamIdByZoneTeamId(nZoneTeamId, nCurGameType)
    local tbZoneTeam = self:GetFightTeamByID(nZoneTeamId)
    if not tbZoneTeam then
        return
    end
    local tbPlayers = tbZoneTeam:GetAllPlayerID()
    local nPlayerId = next(tbPlayers)
    if not nPlayerId then
        return
    end
    local pRole = KPlayer.GetRoleStayInfo(nPlayerId)
    if not pRole then
        return
    end
    local nServerId = GetServerIdentity()
    local nMyServerTeamId = WuLinDaHui:GetPlayerFightTeamIdByRoleId(nPlayerId, nCurGameType, nServerId)
    if not nMyServerTeamId or nMyServerTeamId == 0 then
        return
    end
    return nMyServerTeamId
end

function WuLinDaHui:OpenMatch(nGameType, bFinal)
    Log("WuLinDaHui:OpenMatch", nGameType, bFinal)
	self:ClearMathInfo();

    local tbSaveData = self:GetSaveData()
    tbSaveData.nOpenTimes = (tbSaveData.nOpenTimes or 0) + 1;

	local tbNotSaveData = self.tbNotSaveData
	tbNotSaveData.nCurGameType = nGameType;
	tbNotSaveData.bCurIsFinal = bFinal;
    --跨服上还是先执行开因为要清数据，然后再 传送战队数据过去
	CallZoneServerScript("WuLinDaHui:OpenMatchZ", nGameType, bFinal);

    if bFinal then
        self:UpdateAndSendFinalTeams(nGameType)
    else
       if tbSaveData.nOpenTimes > 1 then --将前20名的数据发过去，这样如果前20名不打也会在最终排名里
            local nServerId = GetServerIdentity()
            local szServerName = GetServerName()
            local nSaveGameType = #self.tbGameFormat + nGameType
            local tbData = WuLinDaHui:CheckUpdateFightTeamNameZoneData(nSaveGameType)
            for i,v in ipairs(tbData) do
                local nMyServerTeamId = self:GetCurServerTeamIdByZoneTeamId(v.nFightTeamID, nGameType)
                if nMyServerTeamId then
                    local tbMySeverFightTeam = self:GetFightTeamByID(nMyServerTeamId)
                    if tbMySeverFightTeam then
                        CallZoneServerScript("WuLinDaHui:SendFightTeamDataFromZC", tbMySeverFightTeam.tbSaveData, nMyServerTeamId, nServerId, szServerName)            
                    end
                end
            end
        end
    end
end

function WuLinDaHui:GetSaveData()
    local tbSaveData = ScriptData:GetValue("WuLinDaHuiData");
    if not tbSaveData.nFightTeamVer1 then
        --还有存跨服过来的队伍，在接受跨服传过来的战队数据时添加 另外一份的 nGameType
        for nGameType,v in pairs(self.tbGameFormat) do
            tbSaveData["nFightTeamVer" .. nGameType] = 1;
        end
        tbSaveData.nGuessingVer = 1;
    end
    tbSaveData.nStartBaoMingTime  = tbSaveData.nStartBaoMingTime or 0;

    return tbSaveData;
end

function WuLinDaHui:GetFightTeamClientInfo(tbFightTeam)
    local tbFightTeamInfo = {};
    if tbFightTeam then --返回空用于同步退出战队情况
        local nFightTeamID = tbFightTeam:GetID();
        local nGameType = WuLinDaHui:GetGameTypeByTeamId(nFightTeamID)
        tbFightTeamInfo.nGameType = nGameType
        tbFightTeamInfo.szName = tbFightTeam:GetName();
        tbFightTeamInfo.nJoinCount = tbFightTeam:GetJoinCount();
        tbFightTeamInfo.nWinCount = tbFightTeam:GetWinCount();
        tbFightTeamInfo.nPlayerTime = tbFightTeam:GetPlayTime();
        tbFightTeamInfo.nJiFen = tbFightTeam:GetJiFen();
        --没去跨服打时获得是本服
        local nServerId = GetServerIdentity()
        tbFightTeamInfo.nServerId = nServerId
        tbFightTeamInfo.szServerName = GetServerName()
        tbFightTeamInfo.nRank = tbFightTeam:GetRank()

        --但是主界面上的看到的是可以看成员列表，不过那个走的另外的
        tbFightTeamInfo.nFightTeamID = nFightTeamID
        local tbAllPlayerID = tbFightTeam:GetAllPlayerID()

        local nPlayerID = next(tbAllPlayerID)
        if self:IsFinalPlayer(nGameType, nPlayerID, nServerId) then
            tbFightTeamInfo.nFinals = nGameType;    
        end

        --只有三人决斗赛的需要队员信息吧
        if WuLinDaHui.tbGameFormat[nGameType].szPKClass == "PlayDuel" then
            tbFightTeamInfo.tbAllPlayer = {};
            for nPlayerID, nTeamNum in pairs(tbAllPlayerID) do
                local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
                if tbStayInfo then
                    local tbInfo = {};
                    tbInfo.szName = tbStayInfo.szName;
                    tbInfo.nNum = nTeamNum;
                    tbFightTeamInfo.tbAllPlayer[nPlayerID] = tbInfo; 
                end 
            end         
        end
    end
    return tbFightTeamInfo    
end

function WuLinDaHui:RequestFightTeamInfo(pPlayer, nGameType)
	local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    local tbFightTeamInfo = self:GetFightTeamClientInfo(tbFightTeam)
    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHFightTeamInfo" .. nGameType, tbFightTeamInfo);
end

--玩家参与活动
function WuLinDaHui:ApplyPlayGame(pPlayer)
	local tbNotSaveData = self.tbNotSaveData
    if not tbNotSaveData.nCurGameType then
    	pPlayer.CenterMsg("未开启活动", true);    
    	return
    end

    if not tbNotSaveData.bCurIsFinal then
    	self:EnterPrepareGame(pPlayer);
        return;
    end

    --todo 决赛是可以观众进入的，区分限制观众的进入人数
    self:PlayerEnterFinalsMap(pPlayer);
end

--清除从ZOne下来的数据，如果接受数据和开启不是同一个 rankKey则清除
function WuLinDaHui:GetZoneData(nZoneOpenTime)
	if nZoneOpenTime and self.nZoneOpenTime ~= nZoneOpenTime then
		self.tbZoneData = {};
		self.nZoneOpenTime = nZoneOpenTime
	end
	return self.tbZoneData or {};
end

function WuLinDaHui:OnPreMapCreate(nMapId, nZoneOpenTime, nCurGameType)
    if not Activity:__IsActInProcessByType(self.szActNameMain) then
        return
    end
	local tbZoneData = self:GetZoneData(nZoneOpenTime)
	tbZoneData.nZoneMapId = nMapId 
    --本地的tbNotSaveData不用是因为本地触发请求开启时有可能晚于跨服
    self.tbNotSaveData.nCurGameType = nCurGameType;
    self.tbNotSaveData.bCurIsFinal = nil;
    

	--通知本服武林大会开了
    local tbMsgData =
    {
        szType = "WuLinDaHui";
        nGameType = nCurGameType;
        nTimeOut = GetTime() + 1800;
    };
    local tbSaveData = self:GetSaveData()
    local tbAllPlayer = KPlayer.GetAllPlayer()
    for i,pPlayer in ipairs(tbAllPlayer) do
        if WuLinDaHui:GetPlayerFightTeam(pPlayer, nCurGameType) ~= 0 then
            pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData)
        end
    end
    -- KPlayer.BoardcastScript(tbDef.nMinPlayerLevel, "Ui:SynNotifyMsg", tbMsgData);
    Calendar:OnActivityBegin("WuLinDaHui");
    Log("WuLinDaHui StartPrepareGame", nMapId, nZoneOpenTime);
end

function WuLinDaHui:UpdateFinalRoleIds(nGameType, bForeUpdate)
    local tbSaveData = self:GetSaveData()
    local tbFinalsFightTeam = tbSaveData["tbFinalsFightTeam" .. nGameType]    
    if not tbFinalsFightTeam then
        return
    end
    self.tbFinalRoleIds = self.tbFinalRoleIds or {};
     
    if bForeUpdate or not self.tbFinalRoleIds[nGameType] then
        local tbRoles = {}
        for nFightTeamID,v in pairs(tbFinalsFightTeam) do
            local tbFightTeam = self:GetFightTeamByID(nFightTeamID)
            if tbFightTeam then
                local nServerId = tbFightTeam:GetServerIdx()
                tbRoles[nServerId] = tbRoles[nServerId] or {};
                local tbPlayers = tbFightTeam:GetAllPlayerID()
                for nPlayerId, v in pairs(tbPlayers) do
                    tbRoles[nServerId][nPlayerId] = 1;
                end
            end
        end 
        self.tbFinalRoleIds[nGameType] = tbRoles;    
    end
    return self.tbFinalRoleIds[nGameType]
end

function WuLinDaHui:IsFinalPlayer(nGameType, dwRoleId, nServerId)
    local tbFinalRoleIds = self:UpdateFinalRoleIds(nGameType)
    if not tbFinalRoleIds then
        return
    end
    local tbRoleIds = tbFinalRoleIds[nServerId]
    if not tbRoleIds then
        return
    end

    return tbRoleIds[dwRoleId]
end

function WuLinDaHui:OnFinalMapCreate(nMapId, nZoneOpenTime, nCurGameType)
    if not Activity:__IsActInProcessByType(self.szActNameMain) then
        return
    end
    local tbZoneData = self:GetZoneData(nZoneOpenTime)
    tbZoneData.nZoneMapId = nMapId 

    self.tbNotSaveData.nCurGameType = nCurGameType
    self.tbNotSaveData.bCurIsFinal = true;
    local tbMsgData =
    {
        szType = "WuLinDaHui";
        nGameType = nCurGameType;
        bFinal = true;
        nTimeOut = GetTime() + 1800;
    };

    local tbAllRoles = WuLinDaHui:UpdateFinalRoleIds(nCurGameType, true)
    local nServerId = GetServerIdentity()
    local tbRoles = tbAllRoles[nServerId]
    if not tbRoles then
        Log("WuLinDaHui No FinalRoleIn this Server", nServerId)
        return
    end
    for nPlayerId,v in pairs(tbRoles) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if pPlayer then
            pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData)
        end
    end
    -- KPlayer.BoardcastScript(tbDef.nMinPlayerLevel, "Ui:SynNotifyMsg", tbMsgData);
    Calendar:OnActivityBegin("WuLinDaHui");
    Log("WuLinDaHui StartFinalGame", nMapId, nZoneOpenTime);
end

function WuLinDaHui:TrueEndGame()
    local tbZoneData = self:GetZoneData()
    tbZoneData.nZoneMapId = nil;
    Calendar:OnActivityEnd("WuLinDaHui");
    Log("WuLinDaHui:TrueEndGame");
end

function WuLinDaHui:CheckEnterPrepareGame(pPlayer, bNotCheckMap, bOnePlayer, bNotTeamCount)
	local tbZoneData = self:GetZoneData()
	if not tbZoneData.nZoneMapId then
		return false, "比赛尚未开启！";
	end

	local nGameType = self.tbNotSaveData.nCurGameType
	if not nGameType then
		return false, "当前未开启比赛"
	end

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, string.format("当前是%s，你还没有对应战队", WuLinDaHui.tbGameFormat[nGameType].szName);
    end

    local bRet = tbFightTeam:HavePlayerID(pPlayer.dwID);
    if not bRet then
        return false, "战队不存在你的资讯，请跟客服人员联系！";
    end 

    local nJoinCount = tbFightTeam:GetJoinCount();
    if nJoinCount >= tbDef.nPreMatchJoinCount and not bNotTeamCount then
        return false, "您的战队已没有剩余比赛次数";
    end

    local tbZoneData = self:GetZoneData()
    local nEnterPreMapID = tbZoneData.nZoneMapId;
    if not nEnterPreMapID then
    	return false, "准备场地图还未创建"
    end

    bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet and not bNotCheckMap then
        return false, "非安全区不能进入";
    end   

    local nTeamId = pPlayer.dwTeamID;

    if nTeamId > 0 and not bOnePlayer then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local nCaptainId = tbTeam:GetCaptainId();
        if nCaptainId ~= pPlayer.dwID then
            return false, "您不是队长";
        end
        local nFightTeamID = tbFightTeam:GetID()

        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if not pMember then
                return false, "有玩家不线上！"
            end

            local nMemberTeamID = self:GetPlayerFightTeam(pMember, nGameType);
            if nMemberTeamID ~= nFightTeamID then
                return false, string.format("%s不是同一个战队", pMember.szName);
            end

            bRet = tbFightTeam:HavePlayerID(pMember.dwID);
            if not bRet then
                return false, string.format("战队不存在%s的资讯，请跟客服人员联系！!", pMember.szName);
            end  

            bRet = Map:CheckEnterOtherMap(pMember);
            if not bRet and not bNotCheckMap then
                return false, string.format("「%s」非安全区不能进入", pMember.szName);
            end    
        end        
    end

    return true, "", nEnterPreMapID, tbFightTeam;
end

function WuLinDaHui:EnterPrepareGame(pPlayer, bNotCheckMap, bOnePlayer, bNotTeamCount)
    local bRet, szMsg, nEnterPreMapID, tbFightTeam = self:CheckEnterPrepareGame(pPlayer, bNotCheckMap, bOnePlayer, bNotTeamCount);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

	--发送战队数据到跨服上    
    local nServerIndex = GetServerIdentity()
    local szServerName = GetServerName()
    CallZoneServerScript("WuLinDaHui:SendFightTeamDataFromZC", tbFightTeam.tbSaveData, tbFightTeam:GetID(), nServerIndex, szServerName)

    local tbAllPos   = HuaShanLunJian:GetMapAllPosByTID(self.tbDef.tbPrepareGame.nPrepareMapTID);
    local nTotalCount = #tbAllPos;
    local nRandIndex = MathRandom(nTotalCount);
    local tbEnterPos = tbAllPos[nRandIndex];

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 and not bOnePlayer then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            pMember.SetEntryPoint();
            pMember.CenterMsg("比赛即将开始，请阁下耐心等等！", true)
            pMember.SwitchZoneMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY)
            TeamMgr:QuiteTeam(nTeamId, nPlayerID)
            Log("WuLinDaHui EnterPrepareGame", pMember.dwID);
        end
    else
        if not bNotCheckMap then
            pPlayer.SetEntryPoint();
        end
        pPlayer.CenterMsg("比赛即将开始，请阁下耐心等等！", true)
        pPlayer.SwitchZoneMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
        Log("WuLinDaHui EnterPrepareGame", pPlayer.dwID);
    end  
end

function WuLinDaHui:OnZCRequestFightTeamShowInfo(dwID, nFightTeamID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    self:RequestFightTeamShowInfo(pPlayer, nFightTeamID)
end

function WuLinDaHui:OnZCRequestFightTeam(dwID, nGameType)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    WuLinDaHui:RequestFightTeamInfo(pPlayer, nGameType);
end

function WuLinDaHui:OnZCChangeFightTeamPlayerNum(dwID, tbPlayerNum, nGameType)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    self:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType)
end

function WuLinDaHui:RequestFightTeamShowInfo(pPlayer, nFightTeamID)
    local tbShowInfo = self:GetFightTeamShowInfo(nFightTeamID);
    if not tbShowInfo then
        return
    end
    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHFightTeam:"..nFightTeamID, tbShowInfo);
end

function WuLinDaHui:GetFightTeamShowInfo(nFightTeamID)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    local tbShowInfo = {}
    tbShowInfo.szName = tbFightTeam:GetName();
    tbShowInfo.tbAllPlayer = {};
    tbShowInfo.szServerName = tbFightTeam:GetServerName();

    local tbAllPlayerID = tbFightTeam:GetAllPlayerID()
    local nServerId = tbFightTeam:GetServerIdx()
    tbShowInfo.nServerId = nServerId;
    for nPlayerID, _ in pairs(tbAllPlayerID) do
        local tbStayInfo = Player:GetRoleStayInfo(nPlayerID, nil, nServerId);
        if tbStayInfo then
            local tbInfo = {};
            tbInfo.szName = tbStayInfo.szName;
            tbInfo.nFaction = tbStayInfo.nFaction;
            tbInfo.nLevel = tbStayInfo.nLevel;
            tbInfo.nPortrait = tbStayInfo.nPortrait;
            tbInfo.nHonorLevel = tbStayInfo.nHonorLevel;
            tbInfo.nFightPower = 0;

            local pAsyncData = Player:GetAsyncData(nPlayerID, nServerId)
            if pAsyncData then
                tbInfo.nFightPower = pAsyncData.GetFightPower();
            end

            tbShowInfo.tbAllPlayer[nPlayerID] = tbInfo; 
        end
    end

    return tbShowInfo;
end

--用 5，6，7， 8 ，gameType对应到跨服上过来的战队， 但是战队id就也不对了，应该没所谓吧, 所以id就直接按排名顺序吧
function WuLinDaHui:SynTopRankPreMatchTeams( tbSaveRankData, nCurGameType)
    --获取数据时一次时间抽，刷新排名战队信息列表时也记录一时间戳, 获取最终下发给玩家看的信息列表
    local nMaxGameType = #self.tbGameFormat
    local nSaveZoneGameType = nMaxGameType + nCurGameType
    assert(not self.tbGameFormat[nSaveZoneGameType], nCurGameType)

    local tbSaveData = self:GetSaveData() --清空存盘记录
    local nNow = GetTime();
    if tbSaveData["nZoneSynTeamDataTime" .. nSaveZoneGameType] == nNow then
        --同一时间戳的无法覆盖，因为对应存盘数据不会清掉，数据会叠加
        Log("WuLinDaHui:SynTopRankPreMatchTeams SameTime", nNow, nCurGameType)
        return
    end
    tbSaveData["nZoneSynTeamDataTime" .. nSaveZoneGameType]  = nNow
    tbSaveData["nFightTeamVer" .. nSaveZoneGameType] = 1;

    --对应的id列表也不用存盘的，因为从存盘数据里都能取出来，同个类型的按类型排序就好了
    for i,v in ipairs(tbSaveRankData) do
        local tbTeamSave = self:GetCanFightTeamSava(nSaveZoneGameType);
        tbTeamSave.nCount = tbTeamSave.nCount + 1;
        local nServerIndex = v[HuaShanLunJian.tbDef.nTeamTypeServerIdx]
        --nCurGameType用的新的所以跨服传回来的和本服已有的战队还是会重复存的
        local nFightTeamID  = nServerIndex * tbDef.nServerIdxInTeamId + nSaveZoneGameType * tbDef.nGameTypeInTeamId + tbTeamSave.nCount * tbDef.nMaxFightTeamVer  + tbTeamSave.nVer;    
        v[ HuaShanLunJian.tbDef.nTeamTypeRank ] = i;
        tbTeamSave.tbAllTeam[nFightTeamID] = v; --战队名这里就不用管了
    end
    --如果是决赛也没必要立即更新， 更新nPlan就就好了

    -- local tbCachedData, nUpdateTime = self:UpdateFightTeamZoneData(nSaveZoneGameType)
    -- local nWinTeamId = tbSaveData["WinnerTeamId" .. nCurGameType] 
    -- KPlayer.BoardcastScript(tbDef.nMinPlayerLevel, "Player:ServerSyncData", "WLDHTopPreFightTeamList".. nCurGameType, tbCachedData, nUpdateTime, nWinTeamId);

    Log("WuLinDaHui:SynTopRankPreMatchTeams", nCurGameType, tbSaveData["nZoneSynTeamDataTime" .. nSaveZoneGameType], #tbSaveRankData)
end

function WuLinDaHui:UpdateFinalTeams(nCurGameType)
    local nMaxGameType = #self.tbGameFormat
    local nSaveZoneGameType = nMaxGameType + nCurGameType
    local tbCachedData = self:UpdateFightTeamZoneData(nSaveZoneGameType)

    local nFrontRank = tbDef.tbFinalsGame.nFrontRank
    local tbSaveData = self:GetSaveData()

    local tbFinalsFightTeam = {};
    --由于跨服没有存
    nFrontRank = math.min(#tbCachedData, nFrontRank) --少于16个时也知道是同步完了
    for i,v in ipairs(tbCachedData) do
        local nFightTeamID = v.nFightTeamID
        local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
        --现在也类似华山的存在 scriptdata里吧，后期检查下大小 TODO 
        tbFinalsFightTeam[nFightTeamID] = { nRank = i, nPlan = 16}; -- 这里 nRank 应是和 teamdata 里的rank一样的，后面可以去掉
        if i >= nFrontRank then
            break;
        end
    end
    tbSaveData["tbFinalsFightTeam" .. nCurGameType] = tbFinalsFightTeam
    WuLinDaHui:UpdateFinalRoleIds(nCurGameType, true)
    return tbFinalsFightTeam
end

function WuLinDaHui:UpdateAndSendFinalTeams(nCurGameType)
    local tbSaveData = self:GetSaveData()
    local tbFinalsFightTeam = tbSaveData["tbFinalsFightTeam" .. nCurGameType];
    if not tbFinalsFightTeam then
        tbFinalsFightTeam = self:UpdateFinalTeams(nCurGameType)
        tbSaveData["tbFinalsFightTeam" .. nCurGameType] = tbFinalsFightTeam
    end
    local tbTeamIds = {};
    for k,v in pairs(tbFinalsFightTeam) do
        table.insert(tbTeamIds, k)
    end
    for i,nFightTeamID in ipairs(tbTeamIds) do
        local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
        local tbFinalsFightTeamInfo = tbFinalsFightTeam[nFightTeamID]
        CallZoneServerScript("WuLinDaHui:SendFightTeamDataFromZC", tbFightTeam.tbSaveData, tbFightTeam:GetID(), tbFightTeam:GetServerIdx(), tbFightTeam:GetServerName(), tbFinalsFightTeamInfo.nRank, i == #tbTeamIds)        
    end
end

function WuLinDaHui:OnZCRequestTopPreFightTeamList(dwID, nGameType, nClientSynTime)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    self:RequestTopPreFightTeamList(pPlayer, nGameType, nClientSynTime)
end

function WuLinDaHui:RequestTopPreFightTeamList(pPlayer, nGameType, nClientSynTime)
    local bRet = Activity:__IsActInProcessByType(self.szActNameMain)
    if not bRet then
        pPlayer.CenterMsg("武林大会还未正式打响")        
        return
    end
    assert(self.tbGameFormat[nGameType], nGameType)
    local nSaveGameType = #self.tbGameFormat + nGameType
    local tbData, nZoneSynTeamDataTime = self:CheckUpdateFightTeamNameZoneData(nSaveGameType)
    if not tbData or not nZoneSynTeamDataTime then
        pPlayer.CenterMsg("当前无对应排名资料")
        return
    end
    if nClientSynTime == nZoneSynTeamDataTime then
        return
    end
    local tbSaveData = self:GetSaveData()
    local nWinTeamId = tbSaveData["WinnerTeamId" .. nGameType] 

    pPlayer.CallClientScript("Player:ServerSyncData", "WLDHTopPreFightTeamList".. nGameType, tbData, nZoneSynTeamDataTime, nWinTeamId);
end

function WuLinDaHui:SynCurAllTeamRanks(tbRankTeamIds, bPreEnd, nCurGameType, bTransFinalRank)
    local nServerIdx = GetServerIdentity()
    for i,v in ipairs(tbRankTeamIds) do
        local nFightTeamID = v[1]
        local nTeamVerIdx = math.floor(nFightTeamID / tbDef.nServerIdxInTeamId)
        if nTeamVerIdx == nServerIdx then
            local tbTeam = self:GetFightTeamByID(nFightTeamID)
            if tbTeam then
                tbTeam:SetRank(i);
            end    
            if bTransFinalRank and nCurGameType then
                local nMyServerTeamId = self:GetCurServerTeamIdByZoneTeamId(nFightTeamID, nCurGameType)
                if nMyServerTeamId then
                    local tbMySeverFightTeam = self:GetFightTeamByID(nMyServerTeamId)
                    if tbMySeverFightTeam then
                        tbMySeverFightTeam:SetRank(i)
                        Log("WuLinDaHui:SynCurAllTeamRanks Final", nMyServerTeamId, nFightTeamID)
                    end
                end
            end
        end
    end
    if bPreEnd and nCurGameType then
        local tbSaveData = self:GetSaveData()
        if tbSaveData.nOpenTimes == WuLinDaHui.tbDef.nOpenPreMatchRound then
            local tbGameFormat = self.tbGameFormat[nCurGameType]
            KPlayer.SendWorldNotify(1, 999, string.format("【武林大会】[eebb01]%s初赛[-]结束了，16强战队已产生，可打开武林大会比赛介面查询！", tbGameFormat.szName), 1, 1);
            -- 预选赛结束时，所有决赛战队需要自己是否有资格
            self:UpdateFinalTeams(nCurGameType);
            local tbFinalRoleIds = self:UpdateFinalRoleIds(nCurGameType)
            local nServerId = GetServerIdentity()
            local tbRoleIds = tbFinalRoleIds[nServerId]
            if tbRoleIds then
                for nPlayerId,v in pairs(tbFinalRoleIds) do
                    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)    
                    if pPlayer then
                        self:RequestFightTeamInfo(pPlayer, nCurGameType)
                    end
                end    
            end
        end
    end
end

function WuLinDaHui:SynNeedSyncRoleIds( tbNeedSynRoleInfoIds, nGameType)
    local tbSaveData = self:GetSaveData()
    if tbSaveData.nOpenTimes ~= WuLinDaHui.tbDef.nOpenPreMatchRound then
        Log("WuLinDaHui:SynNeedSyncRoleIds=== not second Sync ", nGameType)
        return
    end
    Log("WuLinDaHui:SynNeedSyncRoleIds===", tbNeedSynRoleInfoIds, nGameType)

    local tbGameFormat = self.tbGameFormat[nGameType]
    local tbSaveData = self:GetSaveData();
    local nCurServerId = GetServerIdentity()
    for i,v in ipairs(tbNeedSynRoleInfoIds) do
        local dwRoleId, nServerId = unpack(v)
        if nServerId == nCurServerId then
            local pAsync = KPlayer.GetAsyncData(dwRoleId)
            if pAsync then
                SendTempRoleStayInfo(dwRoleId);

                local nFightTeamID = self:GetPlayerFightTeamIdByRoleId(dwRoleId, nGameType, nServerId)
                local tbFightTeam = self:GetFightTeamByID(nFightTeamID)
                if tbFightTeam then
                    local tbMail16th = {
                        Title = "武林大会决赛晋级";
                        Text = string.format("  恭喜阁下所在的战队[FFFE0D]「%s」[-]晋级了武林大会[FFFE0D]「%s」[-]决赛阶段！", tbFightTeam:GetName(), tbGameFormat.szName) ;
                        To = dwRoleId;
                    }
                    Mail:SendSystemMail(tbMail16th)    
                end
                local pRole = KPlayer.GetRoleStayInfo(dwRoleId)
                if pRole.dwKinId ~= 0 then
                    local szShowMsg = string.format(WuLinDaHui.tbDef.szEnterFinalQualifyMsgKin, pRole.szName, tbGameFormat.szName);
                    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pRole.dwKinId);
                end
                ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, string.format(WuLinDaHui.tbDef.szEnterFinalQualifyMsgFriend, pRole.szName, tbGameFormat.szName), dwRoleId);    
            end
        end        
    end
    tbSaveData["tbNeedSynRoleInfoIds" .. nGameType] = tbNeedSynRoleInfoIds --要看外观的16强选手，但是有四种，别被替换了
end

function WuLinDaHui:CallBackFromZoneServerGetData()
    --说明已经连通
    if self.bSendTempRoleStayInfo then
        return
    end
    local nTarZoneId = Server:GetZoneGroupServerId("WLDH")
    if not nTarZoneId then
        return
    end
    Log("WuLinDaHui:CallBackFromZoneServerGetData")
    local tbSaveData = self:GetSaveData();
    local tbRequestRoleIds = {};
    self.tbSendZoneServerRoleData = self.tbSendZoneServerRoleData or {};
    local nCurServerId = GetServerIdentity()
    for nGameType, _ in ipairs(self.tbGameFormat) do
        local tbNeedSyncZoneRoleIds = tbSaveData["tbNeedSynRoleInfoIds" .. nGameType]    
        if tbNeedSyncZoneRoleIds then
            for i,v in ipairs(tbNeedSyncZoneRoleIds) do
                local dwRoleId, nServerId = unpack(v)
                if nServerId == nCurServerId then
                    if not  self.tbSendZoneServerRoleData[dwRoleId] then
                        local pAsync = KPlayer.GetAsyncData(dwRoleId)
                        if pAsync then
                            if SendTempRoleStayInfo(dwRoleId, nTarZoneId) then
                                self.tbSendZoneServerRoleData[dwRoleId] = 1;
                                Log("SendTempRoleStayInfo Success", dwRoleId, nTarZoneId)
                            end
                        else
                            Log(debug.traceback(), dwRoleId, nServerId)
                        end    
                    end
                else
                    local tbTmpRole = KPlayer.GetTempRoleStayInfo(nServerId, dwRoleId)
                    if not tbTmpRole then
                        table.insert(tbRequestRoleIds, v)       
                    end
                end
            end        
        end
    end

    if #tbRequestRoleIds == 0 then
        self.bSendTempRoleStayInfo = true
    else
        --本地不存在的其他服数据， 使用主动请求zonerserver的形式，如果主动请求时没有，那么应该是那些有的服还没连上跨区服，不然连上的时候是先把自己的数据发到跨服上的
        CallSubZoneServerScript(nTarZoneId, "WuLinDaHui:RequestSynRoleInfo", tbRequestRoleIds)
    end
end

function WuLinDaHui:TrySendDataToZoneServer()
    --只处理当前战区是对应武林大会的 和第一次启动服务器时会发送玩家异步数据
    if self.bSendTempRoleStayInfo then
        return
    end
    local nTarZoneId = Server:GetZoneGroupServerId("WLDH")
    if not nTarZoneId then
        return
    end
    CallSubZoneServerScript(nTarZoneId, "WuLinDaHui:CallFromZoneClinetGetData")
end

--跨服上重载
function WuLinDaHui:GetFinalsFightTeamByID(nFightTeamID)  --nFightTeamID 这个都是对应到的跨服队伍id
    local nSaveGameType = self:GetGameTypeByTeamId(nFightTeamID)
    local nGameType = nSaveGameType - #self.tbGameFormat
    if not self.tbGameFormat[nGameType] then
        return
    end
    local tbSaveData = self:GetSaveData()
    local tbFinalsFightTeam = tbSaveData["tbFinalsFightTeam" .. nGameType]
    if not tbFinalsFightTeam then
        return
    end
    return tbFinalsFightTeam[nFightTeamID]
end

function WuLinDaHui:SetFinalsFightTeamPlan(nFightTeamID, nPlan)
    local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
    if not tbFinalsInfo then
        return
    end
    tbFinalsInfo.nPlan = nPlan;
    local nSaveGameType = self:GetGameTypeByTeamId(nFightTeamID)
    WuLinDaHui:UpdateFightTeamZoneData(nSaveGameType) --这样玩家看就直接更新了

    Log("WuLinDaHui SetFinalsFightTeamPlan", nFightTeamID, nPlan);
end

function WuLinDaHui:SynFinalMapGuestCount(nPlayerEnterCount)
    local tbZoneData = self:GetZoneData()
    tbZoneData.nPlayerEnterCount = nPlayerEnterCount
end

function WuLinDaHui:CheckPlayerEnterFinalsMap(pPlayer)
    local tbZoneData = self:GetZoneData()
    local nMainID = tbZoneData.nZoneMapId;
    if not nMainID then
        return false, "地图尚未开启";
    end

    local tbFinalsDef = tbDef.tbFinalsGame
    if pPlayer.nLevel < tbFinalsDef.nAudienceMinLevel then
        return false, string.format("等级不足%s无法参加", tbFinalsDef.nAudienceMinLevel);
    end    

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全区不能进入";
    end   
    local nGameType = self.tbNotSaveData.nCurGameType
    if not nGameType then
        return false, "当前未开启比赛"
    end
    local tbSaveData = self:GetSaveData()
    if tbSaveData["WinnerTeamId" .. nGameType] then
        return false, "比赛已结束"
    end    

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer, nGameType);
    local nTeamId = pPlayer.dwTeamID;
    local nAddPlayerCount = 1;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local nCaptainId = tbTeam:GetCaptainId();
        if nCaptainId ~= pPlayer.dwID then
            return false, "您不是队长";
        end

        local tbMember = tbTeam:GetMembers();
        nAddPlayerCount = 0;
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if not pMember then
                return false, "有玩家不线上！"
            end

            local nMemberTeamID = self:GetPlayerFightTeam(pMember, nGameType);
            if nMemberTeamID ~= nFightTeamID then
                return false, string.format("%s不是同一个战队", pMember.szName);
            end

            bRet = Map:CheckEnterOtherMap(pMember);
            if not bRet then
                return false, string.format("「%s」非安全区不能进入", pMember.szName);
            end

            nAddPlayerCount = nAddPlayerCount + 1;    
        end        
    end
    local nServerId = GetServerIdentity()
    local bIsFinal = self:IsFinalPlayer(nGameType, pPlayer.dwID, nServerId)
    local nPlayerCount = tbZoneData.nPlayerEnterCount or 0;
    if nPlayerCount + nAddPlayerCount > tbFinalsDef.nEnterPlayerCount then
        if not bIsFinal then
            return false, "进入的人数已满";
        end 
    end

    return true, "", nMainID, bIsFinal;        
end

function WuLinDaHui:SendViewItemInfoToZ(pPlayer)
    local tbItems = {};
    local tbPos = {Item.EQUIPPOS_WEAPON, Item.EQUIPPOS_BODY, Item.EQUIPPOS_HEAD, Item.EQUIPPOS_WAIYI, Item.EQUIPPOS_WAI_WEAPON, Item.EQUIPPOS_WAI_HEAD }
    for _, nEquipPos in ipairs(tbPos) do
        local pEquip = pPlayer.GetEquipByPos(nEquipPos) --跨服上没有 playerItems ，
        if pEquip then
            tbItems[nEquipPos] = pEquip.dwTemplateId
        end    
    end
    if next(tbItems) then
        CallZoneServerScript("WuLinDaHui:CachePlayerViewItemInfo", pPlayer.dwID, tbItems);
    end
end

function WuLinDaHui:PlayerEnterFinalsMap(pPlayer)
    local bRet, szMsg, nEnterPreMapID, bIsFinal = self:CheckPlayerEnterFinalsMap(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbAllPos   = HuaShanLunJian:GetMapAllPosByTID(tbDef.tbFinalsGame.nFinalsMapTID);
    local nTotalCount = #tbAllPos;
    local nRandIndex = MathRandom(nTotalCount);
    local tbEnterPos = tbAllPos[nRandIndex];

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if bIsFinal then
                self:SendViewItemInfoToZ(pMember)
            end
            pMember.SetEntryPoint();
            pMember.SwitchZoneMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
            TeamMgr:QuiteTeam(nTeamId, nPlayerID)
            Log("HuaShanLunJian PlayerEnterFinalsMap", pMember.dwID);
        end
    else
        if bIsFinal then
            self:SendViewItemInfoToZ(pPlayer)
        end
        pPlayer.SetEntryPoint();
        pPlayer.SwitchZoneMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
        Log("WuLinDaHui PlayerEnterFinalsMap", pPlayer.dwID);
    end      
end

function WuLinDaHui:SendWorldMsg(szMsg)
    if not WuLinDaHui:IsBaoMingAndMainActTime() then
        return
    end
    if Lib:IsEmptyStr(szMsg) then
        return;
    end

    KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
end

function WuLinDaHui:SendPlayerMsg(dwRoleId, tbInfo)
    local nCurGameType = self.tbNotSaveData.nCurGameType
    if not nCurGameType then
        Log("Error!!!!!!! WuLinDaHui:SendPlayerMsg")
        return
    end
    local tbGameFormat = self.tbGameFormat[nCurGameType]

    local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
    if not pPlayer then
        return
    end

    if tbInfo.szMsg then
        pPlayer.CenterMsg(tbInfo.szMsg, true);
    end

    if tbInfo.szKinMsg then
        if pPlayer.dwKinId ~= 0 then
            local szShowMsg = string.format(tbInfo.szKinMsg, pPlayer.szName, tbGameFormat.szName);
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pPlayer.dwKinId);
        end
    end

    if tbInfo.szFriend then
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, string.format(tbInfo.szFriend, pPlayer.szName, tbGameFormat.szName), pPlayer.dwID);    
    end    
end

function WuLinDaHui:SetChampionTeamId(nGameType, nFightTeamID, tbPlayerViewInfo)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID)
    if not tbFightTeam then
        Log(debug.traceback(), nFightTeamID)
        return
    end

    local tbSaveData = self:GetSaveData()
    tbSaveData["WinnerTeamId" .. nGameType] = nFightTeamID;
    Log("WuLinDaHui:SetChampionTeamId", nGameType, nFightTeamID)
    
    local tbCurNewsData = NewInformation:GetInformation("WLDHChampionship") ; --合并已发的没过期的最新消息
    local tbActData = tbCurNewsData and tbCurNewsData.tbData or {};
    
    

    tbActData[nGameType] = { szTeamName = tbFightTeam:GetName(), szServerName = tbFightTeam:GetServerName(), tbPlayerViewInfo = tbPlayerViewInfo };
    NewInformation:AddInfomation("WLDHChampionship", GetTime() + self.tbDef.nNewsInformationTimeLast, tbActData )    

    local nSaveGameType = #self.tbGameFormat + nGameType
    local tbData, nZoneSynTeamDataTime = self:CheckUpdateFightTeamNameZoneData(nSaveGameType)
    if not tbData or not nZoneSynTeamDataTime then
        Log("Error!!!!!!! WuLinDaHui:SetChampionTeamId", nGameType, nFightTeamID)
        return
    end
    KPlayer.BoardcastScript(tbDef.nMinPlayerLevel, "Player:ServerSyncData", "WLDHTopPreFightTeamList".. nGameType, tbData, nZoneSynTeamDataTime, nFightTeamID);
end

function WuLinDaHui:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType)
    local bRet, szMsg, tbFightTeam = self:CheckChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbCurPlayerNum = {};
    for nPlayerID, nNum in pairs(tbPlayerNum) do
        local bRet1 = tbFightTeam:HavePlayerID(nPlayerID);
        if bRet1 then
            tbFightTeam:ChangePlayerNum(nPlayerID, nNum);
            tbCurPlayerNum[nNum] = nPlayerID;
            Log("WuLinDaHui ChangeFightTeamPlayerNum", tbFightTeam:GetID(), nPlayerID, nNum);
        end    
    end

    local szChangeMsg = "";
    local nChangeCount = Lib:CountTB(tbCurPlayerNum);
    for nI = 1, nChangeCount do
        local nPlayerID = tbCurPlayerNum[nI];
        if nPlayerID then
            local tbPlayerInfo = self:GetPlayerInfoByID(nPlayerID);
            if tbPlayerInfo then
                if Lib:IsEmptyStr(szChangeMsg) then
                    szChangeMsg = string.format("%s号位为「%s」", nI, tbPlayerInfo.szName);
                else    
                    szChangeMsg = szChangeMsg..string.format("，%s号位为「%s」", nI, tbPlayerInfo.szName);
                end
            end    
        end    
    end    
    
    szChangeMsg = "武林大会战队编号变更：" ..szChangeMsg;
    pPlayer.CenterMsg("改变阵容成功！", true);

    local tbAllPlayerID = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayerID) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            pPlayer.Msg(szChangeMsg);
        end    
    end

    self:RequestFightTeamInfo(pPlayer, nGameType);
    Log("WuLinDaHui ChangeFightTeamPlayerNum Player", pPlayer.dwID, tbFightTeam:GetID());
end  

function WuLinDaHui:GameFormatFightTeamAward(nGameType)
    for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
        local bRet = self:HaveFightTeamSavaData(nGameType, nVer);
        if not bRet then
            break;
        else
            local tbSaveData = self:GetFightTeamSavaData(nGameType, nVer)
            for nFightTeamID, _ in pairs(tbSaveData.tbAllTeam) do
                local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
                local nRank = tbFightTeam:GetRank()
                self:SendGameFormatTeamAward(nFightTeamID, nRank, nGameType); 
            end   
        end    
    end      

    Log("HSLJ GameFormatFightTeamAward");
end

function WuLinDaHui:GetGameFormatAwardInfo(nGameFormat, nRank)
    local tbGameFormat = self.tbAllGameFormatAward[nGameFormat];
    if not tbGameFormat then
        return;
    end

    for nI, tbInfo in ipairs(tbGameFormat) do
        if tbInfo.MinRank <= nRank and nRank <= tbInfo.MaxRank then
            return tbInfo;
        end
    end
end

function WuLinDaHui:CheckSendGameFormatTeamAward(nFightTeamID, nRank, nGameType)
    if not nRank then
        return false, "Not Rank";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "Not FightTeam";
    end

    local tbAwardInfo = self:GetGameFormatAwardInfo(nGameType, nRank);
    if not tbAwardInfo then
        return false, "Not AwardInfo";
    end

    return true, "", tbFightTeam, tbAwardInfo;
end

function WuLinDaHui:SendGameFormatTeamAward(nFightTeamID, nRank, nGameType)
    local bRet, szMsg, tbFightTeam, tbAwardInfo = self:CheckSendGameFormatTeamAward(nFightTeamID, nRank, nGameType);
    if not bRet then
        Log("HSLJ SendGameFormatTeamAward", nFightTeamID, nRank, szMsg);
        return;
    end

    local tbGetAllAward = tbAwardInfo.tbAllAward
    local tbAllAward = {};
    for _, tbAward in pairs(tbGetAllAward) do
        local tbAddAward = {};
        if tbAward[1] == "AddTimeTitle" then
            local nTime = GetTime() + tbAward[3];
            tbAddAward = {"AddTimeTitle", tbAward[2], nTime};
        else
            tbAddAward = tbAward;
        end

        table.insert(tbAllAward, tbAddAward);
    end

    local tbRedBagKeys = tbAwardInfo.tbRedBagKeys
    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        local tbMail =
        {
            To = nPlayerID,
            Title = "武林大会",
            Text = tbAwardInfo.MailConent;
            nLogReazon = Env.LogWay_WuLinDaHui;
            tbAttach = tbAllAward,
        }

        Mail:SendSystemMail(tbMail);
        if tbRedBagKeys then
            for _,szRedKey in ipairs(tbRedBagKeys) do
                local nRedKey = Kin.tbRedBagEvents[szRedKey]
                if not nRedKey then
                    Log(debug.traceback() , "szRedKey" .. szRedKey .. nPlayerID)
                else
                    Kin:RedBagOnEvent(nPlayerID, nRedKey)
                end
            end
        end

        Log("WLDH SendGameFormatTeamAward FightTeam", nFightTeamID, nPlayerID, nRank);
    end
end

function WuLinDaHui:SendFinalAward(nGameType)
    local tbSaveData = self:GetSaveData()
    if not tbSaveData["WinnerTeamId" .. nGameType] then
        return
    end
    if tbSaveData["Award" .. nGameType] then
        return
    end
    tbSaveData["Award" .. nGameType] = 1;

    WuLinDaHui:FinalsFightTeamAward(nGameType);
    
    Log("WLDH Finals Map OnSendAward", nState);
end

function WuLinDaHui:SendGuessingAwardByVersion(nVersion, nChampionId, szChampionName, nGameType)
    local tbGuessing = self:GetGuessingSavaData(nVersion);
    if not tbGuessing then
        return;
    end

    self.tbFetchGuessingAward = self.tbFetchGuessingAward or {};
    local tbAward = tbDef.tbChampionGuessing.tbWinAward
    local tbGameFormat = self.tbGameFormat[nGameType]
    local szMailCoent = string.format(tbDef.tbChampionGuessing.szAwardMail, tbGameFormat.szName, szChampionName);
    for nPlayerID, tbSaveInfo in pairs(tbGuessing.tbAllPlayer) do
        if tbSaveInfo[nGameType] == nChampionId then
            if not self.tbFetchGuessingAward[nPlayerID] then
                self.tbFetchGuessingAward[nPlayerID] = 1;
                local tbAward = tbAward;
                
                local tbMail =
                {
                    To = nPlayerID,
                    Title = "武林大会",
                    Text = szMailCoent;
                    nLogReazon = Env.LogWay_HSLJGuessing;
                    tbAttach = tbAward,
                }
                Mail:SendSystemMail(tbMail);

                Log("WLDH SendGuessingAwardByVersion Player", nPlayerID,  nChampionId);
            else
                Log("Erro WLDH SendGuessingAwardByVersion Player", nPlayerID,  nChampionId);
            end
        end
    end
    Log("WLDH SendGuessingAwardByVersion", nVersion, nChampionId, nGameType);
end

function WuLinDaHui:ChampionGuessingAward(nGameType)
    local tbSaveData = self:GetSaveData();
    local nChampionId = tbSaveData["WinnerTeamId" .. nGameType]
    if not nChampionId or nChampionId <= 0 then
        Log("Error WLDH ChampionGuessingAward nChampionId", nChampionId);
        return;
    end

    local tbChampionFightTeam = self:GetFightTeamByID(nChampionId);
    if not tbChampionFightTeam then
        Log("Error WLDH ChampionGuessingAward GetFightTeamByID", nChampionId);
        return;
    end

    self.tbFetchGuessingAward = {};

    local szChampionName = tbChampionFightTeam:GetName();
    for nV = 1, tbDef.nMaxGuessingVer - 1 do
        local bRet = self:HaveGuessingSavaData(nV);
        if bRet then
            self:SendGuessingAwardByVersion(nV, nChampionId, szChampionName, nGameType);
        else
            break;
        end
    end
    Log("WLDH ChampionGuessingAward", nChampionId, nGameType);
end


function WuLinDaHui:FinalsFightTeamAward(nGameType)
    self:GameFormatFightTeamAward(nGameType);
    self:ChampionGuessingAward(nGameType);
end


WuLinDaHui.tbC2SRequest = {
	["CreateFightTeam"] = function (pPlayer, szTeamName, nWLDHType)
		WuLinDaHui:PlayerCreateFightTeam(pPlayer.dwID, szTeamName, nWLDHType);       
	end;

    ["RequestFightTeam"] = function (pPlayer, nGameType)
        WuLinDaHui:RequestFightTeamInfo(pPlayer, nGameType);
    end;

    ["RequestFightTeamAll"] = function (pPlayer)
        for nGameType,v in pairs(WuLinDaHui.tbGameFormat) do
            WuLinDaHui:RequestFightTeamInfo(pPlayer, nGameType);
        end
        WuLinDaHui:SyncGuessingData(pPlayer)
    end;

    ["JoinFightTeam"] = function (pPlayer, nGameType)
    	WuLinDaHui:PlayerJoinFightTeam(pPlayer.dwID, nGameType);
    end;

    ["QuitFightTeam"] = function (pPlayer, nGameType)
    	WuLinDaHui:PlayerQuitFightTeam(pPlayer.dwID, nGameType)
    end;

    ["DeleteFightTeam"] = function (pPlayer, nGameType)
        WuLinDaHui:DeleteFightTeam(pPlayer.dwID, nGameType)
    end;

    ["ApplyPlayGame"] = function (pPlayer)
        WuLinDaHui:ApplyPlayGame(pPlayer);
    end;

    ["RequestFightTeamShow"] = function (pPlayer, nFightTeamID)
        if type(nFightTeamID) ~= "number" then
            return;
        end

        WuLinDaHui:RequestFightTeamShowInfo(pPlayer, nFightTeamID)
    end;

    ["RequestTopPreFightTeamList"] = function (pPlayer, nGameType, nSynTimeVersion)
        WuLinDaHui:RequestTopPreFightTeamList(pPlayer, nGameType, nSynTimeVersion)
    end;

    ["ChangeTeamNum"] = function (pPlayer, tbPlayerNum, nGameType)
        WuLinDaHui:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum, nGameType)
    end;

    ["ChampionGuessing"] = function (pPlayer, nFightTeamID, nGameType)
        if type(nFightTeamID) ~= "number" or type(nGameType) ~= "number" then
            return;
        end

        WuLinDaHui:PlayerChampionGuessing(pPlayer, nFightTeamID, nGameType)
    end;
    ["GetWLDHStartBaoMingTime"] = function (pPlayer)
    	local tbSaveData = WuLinDaHui:GetSaveData()
    	pPlayer.CallClientScript("Player:ServerSyncData", "nWLDHStartBaoMingTime", tbSaveData.nStartBaoMingTime);
    end;

};