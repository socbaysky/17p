-- 所有开启的活动的信息
BiWuZhaoQin.tbActData = BiWuZhaoQin.tbActData or {}

function BiWuZhaoQin:StartS(nTargetId, nKinId, bNpcType)
    if nKinId > 0 and not Kin:GetKinById(nKinId) then
        Log("BiWuZhaoQin fnStart no kin ", nTargetId, nKinId)
        return
    end
    local nServerId = GetServerIdentity();
    local szTimeFrame = Lib:GetMaxTimeFrame(BiWuZhaoQin.tbAvatar)
    CallZoneServerScript("BiWuZhaoQin:Start", nTargetId, nKinId, szTimeFrame, bNpcType, nServerId);
    Log("BiWuZhaoQin fnStart ", nServerId, nTargetId, nKinId, szTimeFrame, bNpcType and "true" or "false");
end
function BiWuZhaoQin:OnSynData(nTargetId,tbFightInfo)
    BiWuZhaoQin.tbActData[nTargetId] = tbFightInfo
end

function BiWuZhaoQin:GetActData(nTargetId)
    return BiWuZhaoQin.tbActData[nTargetId]
end

function BiWuZhaoQin:ClearActData(nTargetId)
    if BiWuZhaoQin.tbActData[nTargetId] then
        BiWuZhaoQin.tbActData[nTargetId] = nil
        Log("BiWuZhaoQin fnClearActDataS ok",nTargetId)
    end
end

-- 招亲结束回调
function BiWuZhaoQin:OnCompleteZhaoQinS(nPreMapId, nTargetId, nWinerId, nType, tbAllPlayer, tbFinalLostPlayer)
    local tbActData = self:GetActData(nTargetId);
    local bNpcType = tbActData and tbActData.bNpcType;
    if bNpcType then
        -- 这里说明是Npc的招亲
        Activity:OnGlobalEvent("Act_OnCompleteZhaoQinS", tbAllPlayer, nWinerId, nTargetId);
    end

    local pWiner = KPlayer.GetPlayerObjById(nWinerId)
    if not pWiner then
        self:OnEndZhaoQinS(nPreMapId, nTargetId, nType, tbAllPlayer, tbFinalLostPlayer, nWinerId)
        local tbMail = {
                To = nWinerId;
                Title = "比武招亲";
                From = "系统";
                Text = "由於比武招亲比赛开始时您不线上，错失了冠军！";
                nLogReazon = Env.LogWay_BiWuZhaoQin;
            };

       Mail:SendSystemMail(tbMail);
       Log("BiWuZhaoQin fnOnCompleteZhaoQinS offline ",nPreMapId,nTargetId,nWinerId,nType)
       return
    end

    self:SendPlayerJoinAward(tbAllPlayer, tbFinalLostPlayer, nTargetId, nType, nWinerId)

    if not bNpcType then
        Item:GetClass("LoveToken"):AddLoveToken(pWiner, nTargetId, BiWuZhaoQin.nItemTID, nType);
    end

    self:ClearActData(nTargetId)
    local pTargetInfo = KPlayer.GetPlayerObjById(nTargetId) or KPlayer.GetRoleStayInfo(nTargetId)
    if pTargetInfo and not bNpcType then

        local szName = pTargetInfo.szName or "-"

        local tbMail = {
                    To = nWinerId;
                    Title = "比武招亲冠军";
                    From = "系统";
                    Text = string.format("大侠，恭喜您获得了侠士[FFFE0D]%s[-]的比武招亲冠军，结成情缘的道具[FFFE0D][url=openwnd:定情信物, ItemTips,'Item',nil,%d][-]已发送到背包中，请尽快使用与其结成情缘吧！",szName,BiWuZhaoQin.nItemTID);
                    nLogReazon = Env.LogWay_BiWuZhaoQin;
                };
        Mail:SendSystemMail(tbMail);

        tbMail = {
                    To = nTargetId;
                    Title = "比武招亲";
                    From = "系统";
                    Text = string.format("您的比武招亲比赛结束了，侠士[FFFE0D]%s[-]成为了优胜者，请尽快与其联系结成情缘！",pWiner.szName);
                    nLogReazon = Env.LogWay_BiWuZhaoQin;
                };
        Mail:SendSystemMail(tbMail);
    end


    Log("BiWuZhaoQin fnOnCompleteZhaoQinS ",nPreMapId,nTargetId,nWinerId, bNpcType and "true" or "false");
end

function BiWuZhaoQin:SendPlayerJoinAward(tbAllPlayer, tbFinalLostPlayer, nTargetId, nType, nWinerId)
    Log("BiWuZhaoQin fnSendPlayerJoinAward Start ", nTargetId, nType)
    if not tbAllPlayer or not next(tbAllPlayer) then
        Log("BiWuZhaoQin fnSendPlayerJoinAward no player ", nTargetId, nType)
        return
    end
    local tbFinalLostPlayer = tbFinalLostPlayer or {}
    local tbJoinPlayer = {}
    for nRound,tbPlayer in pairs(tbAllPlayer) do
        for dwID,_ in pairs(tbPlayer) do
            tbJoinPlayer[dwID] = (tbJoinPlayer[dwID] or 0) + 1
        end
    end
    for dwID,nCount in pairs(tbJoinPlayer) do
        local nBaseExpCount = tbFinalLostPlayer[dwID] and nCount - 1 or nCount
        -- 除掉冠军最后一份数据
        if nWinerId and nWinerId == dwID then
            nBaseExpCount = nBaseExpCount - 1
        end
        if nBaseExpCount > 0 then
            local tbMail = {
                To = dwID;
                Title = "比武招亲";
                From = "系统";
                Text = "这是你参加比武招亲获得的经验奖励，请查收！";
                tbAttach = {{"BasicExp", nBaseExpCount * BiWuZhaoQin.nBaseExpCount}};
                nLogReazon = Env.LogWay_BiWuZhaoQin;
            };
            Mail:SendSystemMail(tbMail);
            Log("BiWuZhaoQin fnSendPlayerJoinAward ok ", dwID, nCount, nBaseExpCount, nTargetId, nType)
        else
            Log("BiWuZhaoQin fnSendPlayerJoinAward Zero ", dwID, nCount, nBaseExpCount, nTargetId, nType)
        end
    end
end

-- 开始招亲回调
function BiWuZhaoQin:OnStartZhaoQinS(nPreMapId, nTargetId, nType, nKinId, bNpcType)
    local szMsg = ""
    local pTargetInfo = KPlayer.GetPlayerObjById(nTargetId) or KPlayer.GetRoleStayInfo(nTargetId)
    if pTargetInfo then
        local szName = pTargetInfo and pTargetInfo.szName or "-"
        if nType == BiWuZhaoQin.TYPE_KIN then
            if nKinId and nKinId ~= 0 then
                szMsg = string.format("帮派成员[FFFE0D]%s[-]的比武招亲开始报名了，时间[FFFE0D]5分钟[-]，请大家尽快找[FFFE0D]襄阳燕若雪[-]报名参加！", szName)
                ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
                local fnMsg = function(self, pPlayer, szMsg)
                    pPlayer.Msg(szMsg)
                end
                BiWuZhaoQin:ForeachKinPlayer(fnMsg, nKinId, szMsg)
            else
               Log("BiWuZhaoQin OnStartZhaoQin no kin id", nPreMapId, nTargetId, nType);
            end
        elseif nType == BiWuZhaoQin.TYPE_GLOBAL then
            szMsg = string.format("侠士[FFFE0D]%s[-]的比武招亲开始报名了，时间[FFFE0D]5分钟[-]，请大家尽快找[FFFE0D]襄阳燕若雪[-]报名参加！", szName)
            KPlayer.SendWorldNotify(1,1000, szMsg, ChatMgr.ChannelType.Public, 1);
        end
    end

    if bNpcType then
        Activity:OnGlobalEvent("Act_OnStartZhaoQinS", nPreMapId, nTargetId);
    end

    Log("BiWuZhaoQin fnOnStartZhaoQinS ", nPreMapId, nTargetId, nType, bNpcType and "true" or "false");
end

-- 招亲无人参加或者所有参赛者失去资格回调
function BiWuZhaoQin:OnEndZhaoQinS(nPreMapId, nTargetId, nType, tbAllPlayer, tbFinalLostPlayer, nWinerId)
    self:SendPlayerJoinAward(tbAllPlayer, tbFinalLostPlayer, nTargetId, nType, nWinerId)

    local tbActData = self:GetActData(nTargetId);
    local bNpcType = tbActData and tbActData.bNpcType;
    if bNpcType then
        Activity:OnGlobalEvent("Act_OnEndZhaoQinS", tbAllPlayer, nPreMapId, nTargetId);
    end

    self:ClearActData(nTargetId)

    local pTargetInfo = KPlayer.GetPlayerObjById(nTargetId) or KPlayer.GetRoleStayInfo(nTargetId)
    if pTargetInfo then
        local tbMail = {
                    To = nTargetId;
                    Title = "比武招亲";
                    From = "系统";
                    Text = "很遗憾地通知您，由於您的比武招亲比赛无人参加，招亲失败了！";
                    nLogReazon = Env.LogWay_BiWuZhaoQin;
                };
        Mail:SendSystemMail(tbMail);
    end

	Log("BiWuZhaoQin fnOnEndZhaoQinS ",nPreMapId,nTargetId,nType, bNpcType and "true" or "false");
end

function BiWuZhaoQin:OnStartFinalS(nTargetId)
     local tbActData = self:GetActData(nTargetId)
     if not tbActData then
        Log("BiWuZhaoQin fnOnStartFinalS no tbActData",nTargetId)
        return
    end
    local szMsg = ""
    tbActData.nProcess = BiWuZhaoQin.Process_Final
    local pTargetInfo = KPlayer.GetPlayerObjById(nTargetId) or KPlayer.GetRoleStayInfo(nTargetId)
    if pTargetInfo then
        if tbActData.nType == BiWuZhaoQin.TYPE_KIN then
            local nKinId = tbActData.nKinId
            if nKinId and nKinId ~= 0 then
                szMsg = string.format("帮派成员[FFFE0D]%s[-]的比武招亲决赛即将开始，大家可找[FFFE0D]襄阳燕若雪[-]进入场地观战！",pTargetInfo.szName or "-")
                ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
            end
        elseif tbActData.nType == BiWuZhaoQin.TYPE_GLOBAL then
            szMsg = string.format("侠士[FFFE0D]%s[-]的比武招亲决赛即将开始，大家可找[FFFE0D]襄阳燕若雪[-]进入场地观战！",pTargetInfo.szName or "-")
            KPlayer.SendWorldNotify(1,1000, szMsg, ChatMgr.ChannelType.Public, 1);
        end
    end

    local tbActData = self:GetActData(nTargetId);
    local bNpcType = tbActData and tbActData.bNpcType;
    if bNpcType then
        Activity:OnGlobalEvent("Act_OnStartFinalS", nPreMapId, nTargetId);
    end
end

function BiWuZhaoQin:CheckCanEnter(dwID, nTargetId, bNoJoin)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return false;
    end
    local tbActData = self:GetActData(nTargetId)
    if not tbActData or not tbActData.nPreMapId then
        return false, "活动未开启！", pPlayer;
    end

    if not bNoJoin and tbActData.nKinId > 0 and tbActData.nKinId ~= pPlayer.dwKinId then
        return false, "必须与招亲玩家在同一帮派才能参与", pPlayer;
    end

    if not bNoJoin and dwID == tbActData.nTargetId then
        return false, "招亲的人只能以观战形式进入", pPlayer;
    end

    if not bNoJoin and pPlayer.nLevel < BiWuZhaoQin.nJoinLevel then
        return false, string.format("需要等级达到%d级！",BiWuZhaoQin.nJoinLevel), pPlayer;
    end

    if not bNoJoin and (not tbActData.nProcess or tbActData.nProcess ~=  BiWuZhaoQin.Process_Pre) and not self:HadJoin(dwID,tbActData.nTargetId) then
        return false, "报名阶段已经结束，请以观战形式进入", pPlayer;
    end

    if not bNoJoin and tbActData.nJoin >= BiWuZhaoQin.nMaxJoin then
        return false, "参加人数已满，请以观战形式进入", pPlayer;
    end
    return true, "", pPlayer, tbActData;
end

-- 玩家进入的接口
function BiWuZhaoQin:Enter(dwID, nTargetId, bNoJoin)
    local bRet, szMsg, pPlayer, tbActData = self:CheckCanEnter(dwID, nTargetId, bNoJoin);
    if not bRet then
        if pPlayer then
            pPlayer.CenterMsg(szMsg, true);
        end
        return false;
    end

    CallZoneServerScript("BiWuZhaoQin:OnTryEnterPreMap", dwID, tbActData.nPreMapId, bNoJoin);
    if not pPlayer.SwitchZoneMap(tbActData.nPreMapId, 0, 0) then
        pPlayer.CenterMsg("该招亲比赛地图现在已无法进入", true)
        return false;
    end

    Log("BiWuZhaoQin fnEnterS ", dwID, nTargetId, tbActData.nKinId, bNoJoin and 1 or 0)
    return true;
end

function BiWuZhaoQin:ForeachKinPlayer(fnFunc,nKinId,...)
    local tbMember = Kin:GetKinMembers(nKinId)
    for dwID,_ in pairs(tbMember) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            Lib:CallBack({fnFunc, self, pPlayer,...});
        end
    end
end

-- 玩家参加后离开判断是否参加过
function BiWuZhaoQin:HadJoin(dwID,nTargetId)
    local tbActData = self:GetActData(nTargetId)
    if tbActData and tbActData.tbPlayer then
        return tbActData.tbPlayer[dwID]
    end
end

function BiWuZhaoQin:OnSynJoinS(nTargetId,nJoin)
    local tbActData = self:GetActData(nTargetId)
    if not tbActData then
        Log("BiWuZhaoQin fnOnSynJoinS ",nTargetId,nJoin)
        return
    end
    tbActData.nJoin = nJoin
end

function BiWuZhaoQin:OnFirstFightS(tbFightInfo)
     local tbActData = self:GetActData(tbFightInfo.nTargetId)
     if not tbActData then
        Log("BiWuZhaoQin fnOnFirstFightS no tbActData",tbFightInfo.nTargetId)
        return
    end
    tbActData.nProcess = tbFightInfo.nProcess
    tbActData.tbPlayer = tbFightInfo.tbPlayer[tbFightInfo.nRound]
end

function BiWuZhaoQin:GetAllLoverInfo()
    local tbData = ScriptData:GetValue("BiWuZhaoQin");
    if not tbData.tbAllLoverInfo then
        tbData.tbAllLoverInfo = {};
        ScriptData:AddModifyFlag("BiWuZhaoQin");
    end

    return tbData.tbAllLoverInfo;
end

function BiWuZhaoQin:GetLover(nPlayerId)
    local tbAllLoverInfo = self:GetAllLoverInfo();
    return tbAllLoverInfo[nPlayerId];
end

function BiWuZhaoQin:CheckIsLover(nPlayerId, nOtherId)
    local nLoverId = self:GetLover(nPlayerId) or 0;
    return nLoverId == nOtherId;
end

function BiWuZhaoQin:AddLover(pPlayer, pOther)
    if not pPlayer or not pOther then
        Log("[BiWuZhaoQin] AddLover Fail !!", pPlayer and "true" or "nil", pOther and "true" or "nil");
        return;
    end

    local tbAllLoverInfo = self:GetAllLoverInfo();
    if tbAllLoverInfo[pPlayer.dwID] or tbAllLoverInfo[pOther.dwID] then
        Log("[BiWuZhaoQin] AddLover Fail !! Lover has exist !!", pPlayer.dwID, tbAllLoverInfo[pPlayer.dwID] or "nil", pOther.dwID, tbAllLoverInfo[pOther.dwID] or "nil");
        return;
    end

    pPlayer.CallClientScript("BiWuZhaoQin:OnSyncLoverInfo", pOther.dwID);
    pOther.CallClientScript("BiWuZhaoQin:OnSyncLoverInfo", pPlayer.dwID);

    FriendShip:ForceAddFriend(pPlayer, pOther);
    tbAllLoverInfo[pPlayer.dwID] = pOther.dwID;
    tbAllLoverInfo[pOther.dwID] = pPlayer.dwID;

    ScriptData:AddModifyFlag("BiWuZhaoQin");
    ScriptData:CheckAndSave();
end

function BiWuZhaoQin:RemoveLover(pPlayer)
    if not pPlayer then
        return false;
    end

    local tbAllLoverInfo = self:GetAllLoverInfo();
    local nOtherId = tbAllLoverInfo[pPlayer.dwID];
    if not nOtherId then
        return;
    end

    pPlayer.CallClientScript("BiWuZhaoQin:OnSyncLoverInfo");
    tbAllLoverInfo[pPlayer.dwID] = nil;
    ScriptData:AddModifyFlag("BiWuZhaoQin");
    ScriptData:CheckAndSave();
    return nOtherId;
end

function BiWuZhaoQin:OnLogin(pPlayer)
    local nLoverId = self:GetLover(pPlayer.dwID);
    if not nLoverId then
        return;
    end

    local nMyId = self:GetLover(nLoverId);
    if not nMyId or nMyId ~= pPlayer.dwID then
        -- 说明对方已经解除关系
        -- 移除数据，解除关系
        BiWuZhaoQin:RemoveLover(pPlayer);
        pPlayer.DeleteTitle(BiWuZhaoQin.nTitleId);
        return;
    end

    pPlayer.CallClientScript("BiWuZhaoQin:OnSyncLoverInfo", nLoverId);
    local pLover = KPlayer.GetPlayerObjById(nLoverId);
    if pLover then
        pLover.Msg(string.format("您的情缘「%s」上线了", pPlayer.szName));
    end
end