
Require("CommonScript/ChangeFaction/ChangeFactionDef.lua");

ChangeFaction.tbAllApplyPlayer = ChangeFaction.tbAllApplyPlayer or {};
ChangeFaction.tbAllPlayerInfo = ChangeFaction.tbAllPlayerInfo or {};

local tbDef = ChangeFaction.tbDef;
local tbMap = Map:GetClass(tbDef.nMapTID);

function tbMap:OnCreate(nMapId)
    ChangeFaction:OnCreate(nMapId);
end

function tbMap:OnDestroy(nMapId)
    ChangeFaction:OnDestroy(nMapId);
end

function tbMap:OnEnter(nMapId)
    ChangeFaction:OnEnter(nMapId);
end

function tbMap:OnLeave(nMapId)
    ChangeFaction:OnLeave(nMapId);
end


function ChangeFaction:CheckApplyEnterMap(pPlayer)
    local nLing = pPlayer.GetItemCountInAllPos(tbDef.nChangeFactionLing);
    if nLing <= 0 then
        local szName = KItem.GetItemShowInfo(tbDef.nChangeFactionLing);
        return false, string.format("身上不足%s", szName);
    end

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "不在安全区，不能进入";
    end

    if pPlayer.nMapTemplateId == tbDef.nMapTID then
        return false, "已经在地图！";
    end

    if tbDef.nMinChangeLevel > pPlayer.nLevel then
        return false, string.format("等级不足%s级", tbDef.nMinChangeLevel);
    end

    local nLastTime = pPlayer.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD);
    local nRetTime = nLastTime - GetTime();
    if nRetTime > 0 then
        return false, string.format("%s後才可以使用", Lib:TimeDesc2(nRetTime));
    end

    return true, "";
end

function ChangeFaction:ApplyEnterMap(pPlayer)
    local bRet, szMsg = self:CheckApplyEnterMap(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local nTime = GetTime() + ChangeFaction:GetUseFactionCD();
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveUseCD, nTime);
    local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbDef.nChangeFactionLing, 1, Env.LogWay_ChangeFaction);
    if nConsumeCount <= 0 then
        Log("Error ChangeFaction OnEnter", pPlayer.dwID, nConsumeCount);
        return;
    end

    pPlayer.SetEntryPoint();
    pPlayer.SwitchMap(tbDef.nMapTID, tbDef.tbEnterPos[1], tbDef.tbEnterPos[2]);
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveEnterFaction, pPlayer.nFaction);
    pPlayer.SetUserValue(tbDef.nSaveGroup, tbDef.nSaveEnterSex, pPlayer.nSex);
    pPlayer.CallClientScript("Ui:CloseWindow", "ItemBox");
    Log("ChangeFaction ApplyEnterMap", pPlayer.dwID);
end

function ChangeFaction:CheckPlayerChangeFaction(pPlayer, nChangeFaction, nSex)
    if not Faction.tbFactionInfo[nChangeFaction] then
        return false, "没有开放当前的门派";
    end

    if pPlayer.nMapTemplateId ~= tbDef.nMapTID then
        return false, "当前地图不能转门派";
    end

    if nSex ~= Player.SEX_MALE and nSex ~= Player.SEX_FEMALE then
        return false, "请选择性别";
    end

    if pPlayer.nFaction == nChangeFaction and pPlayer.nSex == nSex then
        return false, "请选择不同的门派或性别";
    end

    local tbPlayerInit = KPlayer.GetPlayerInitInfo(nChangeFaction, nSex);
    if not tbPlayerInit then
        return false, "没有的门派或性别";
    end

    return true, "";
end

function ChangeFaction:PlayerChangeFaction(pPlayer, nChangeFaction, nSex)
    local bRet, szMsg = self:CheckPlayerChangeFaction(pPlayer, nChangeFaction, nSex);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local nOrgFaction = pPlayer.nFaction;
    local nOrgSex = pPlayer.nSex;
    if pPlayer.nFaction ~= nChangeFaction then
        local nRet = pPlayer.ChangeFaction(nChangeFaction);
        if nRet ~= 1 then
            Log("Error PlayerChangeFaction", pPlayer.dwID, nChangeFaction, pPlayer.nFaction);
            return;
        end

        if pPlayer.nSex ~= nSex then
            pPlayer.ChangeSex(nSex);
        end
        
        pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, 0);
        local nPortrait = PlayerPortrait:GetDefaultId(pPlayer.nFaction, pPlayer.nSex)
        pPlayer.SetPortrait(nPortrait)

        local szKey = string.format("FightPower_%s", nOrgFaction);
        local pRank = KRank.GetRankBoard(szKey)
        if pRank then
            local tbRankInfo = pRank.GetRankInfoByID(pPlayer.dwID);
            if tbRankInfo then
                pRank.RemoveByID(pPlayer.dwID);
            end
        end

        FightPower:ChangeFightPower("Skill", pPlayer);
        local tbBook = Item:GetClass("SkillBook");
        --tbBook:UnuseAllSkillBook(pPlayer);
        tbBook:ChangeFactionBook(pPlayer, nOrgFaction, nChangeFaction);

        self:ClearFactionChannel(pPlayer, nOrgFaction);
    else
        pPlayer.ChangeSex(nSex);
        local nPortrait = PlayerPortrait:GetDefaultId(pPlayer.nFaction, pPlayer.nSex)
        pPlayer.SetPortrait(nPortrait)
    end

    --因为换性别也会导致武器附魔特效大小变化，所以无论换门派还是性别都刷新一下
    local nLightID = pPlayer.GetUserValue(OpenLight.nSaveGroupID, OpenLight.nSaveLightID);
    if nLightID > 0 then
        OpenLight:ServerUpdateOpenLight(pPlayer);
    end

    KPlayer.UpdateAsyncData(pPlayer.dwID);
    pPlayer.SavePlayer();

    pPlayer.TLog("ChangeFactionFlow", pPlayer.nLevel, nOrgFaction, pPlayer.nFaction, nOrgSex, nSex);
    Log("ChangeFaction PlayerChangeFaction", pPlayer.dwID, nOrgFaction, pPlayer.nFaction, nChangeFaction, nSex);
end

function ChangeFaction:OnCreate(nMapId)
    Log("ChangeFaction OnCreate", nMapId);
end

function ChangeFaction:OnDestroy(nMapId)
    Log("ChangeFaction OnDestroy", nMapId);
end

function ChangeFaction:OnEnter(nMapId)
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    tbPlayerInfo = tbPlayerInfo or {};
    tbPlayerInfo.nEnterTime = GetTime();
    tbPlayerInfo.nOrgFaction = me.nFaction;
    tbPlayerInfo.nOrgSex = me.nSex;

    if tbPlayerInfo.nOnDeathRegID then
        PlayerEvent:UnRegister(me, "OnDeath", tbPlayerInfo.nOnDeathRegID);
        tbPlayerInfo.nOnDeathRegID = nil;
    end

    tbPlayerInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);

    self.tbAllPlayerInfo[me.dwID] = tbPlayerInfo;

    local nCurMapId, nPosX, nPosY = me.GetWorldPos();
    me.SetTempRevivePos(nCurMapId, nPosX, nPosY);  --设置临时复活点
    me.bForbidChangePk = 1;
    me.nInBattleState = 1; --战场模式
    me.SetPkMode(Player.MODE_PEACE);
    me.CallClientScript("AutoFight:ChangeHand");
    Log("ChangeFaction OnEnter", nMapId, me.dwID, me.nFaction);
end

function ChangeFaction:OnPlayerDeath()
    me.Revive(1);
end

function ChangeFaction:GetPlayerInfo(nPlayerID)
    return self.tbAllPlayerInfo[nPlayerID];
end

function ChangeFaction:OnLeave(nMapId)
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    if not tbPlayerInfo then
        Log("Error ChangeFaction OnLeave", nMapId, me.dwID);
        return;
    end


    self:ClearFactionData(me, tbPlayerInfo.nOrgFaction, tbPlayerInfo.nOrgSex);

    if tbPlayerInfo.nOnDeathRegID then
        PlayerEvent:UnRegister(me, "OnDeath", tbPlayerInfo.nOnDeathRegID);
        tbPlayerInfo.nOnDeathRegID = nil;
    end

    me.ClearTempRevivePos();
    local tbLogData =
    {
        Result = Env.LogRound_SUCCESS;
        nMatchTime = GetTime() - tbPlayerInfo.nEnterTime;
    };
    me.ActionLog(Env.LogType_Activity, Env.LogWay_ChangeFaction, tbLogData);
    self.tbAllPlayerInfo[me.dwID] = nil;

    me.bForbidChangePk = 0;
    me.nInBattleState = 0; --战场模式
    Log("ChangeFaction OnLeave", nMapId, me.dwID, me.nFaction);
end

function ChangeFaction:ClearFactionChannel(pPlayer, nOrgFaction)
    local tbOrgChat = Faction.tbChatChannel[nOrgFaction];
    if tbOrgChat then
        KChat.DelPlayerFromDynamicChannel(tbOrgChat, pPlayer.dwID);
    end

    local tbCurChat = Faction.tbChatChannel[pPlayer.nFaction];
    if pPlayer.nLevel >= 20 and tbCurChat then
        KChat.AddPlayerToDynamicChannel(tbCurChat, pPlayer.dwID);
    end
end

function ChangeFaction:ClearFactionBattleTile(pPlayer, nOrgFaction, nOrgSex, tbTitleList)
    local nTitleID = tbTitleList[nOrgFaction];
    if nTitleID then
        local tbTitle = PlayerTitle:GetPlayerTitleByID(pPlayer, nTitleID);
        if tbTitle then
            pPlayer.DeleteTitle(nTitleID, true);

            local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);
            if tbTitleTemp then
                pPlayer.Msg(string.format("由於转为新门派，原称号「%s」无法使用，称号消失", tbTitleTemp.Name));
            end
        end
    end
end

function ChangeFaction:ClearFactionData(pPlayer, nOrgFaction, nOrgSex)
    if pPlayer.nFaction == nOrgFaction and nOrgSex == pPlayer.nSex  then
        return;
    end

    ChatMgr:SetNamePrefixByName(pPlayer, "FactionMonkey", 0);

    self:ClearFactionBattleTile(pPlayer, nOrgFaction, nOrgSex, FactionBattle.CHAMPION_TITLE)
    self:ClearFactionBattleTile(pPlayer, nOrgFaction, nOrgSex, FactionBattle.CHAMPION_MONTH_TITLE)
    self:ClearFactionBattleTile(pPlayer, nOrgFaction, nOrgSex, FactionBattle.CHAMPION_SEASON_TITLE)

    local tbTitleID = FactionBattle.MONKEY_TITLE_ID[nOrgFaction];
    local nTitleID = tbTitleID and tbTitleID[nOrgSex]
    if nTitleID then
        local tbTitle = PlayerTitle:GetPlayerTitleByID(pPlayer, nTitleID);
        if tbTitle then
            pPlayer.DeleteTitle(nTitleID, true);

            local tbTitleTemp = PlayerTitle:GetTitleTemplate(nTitleID);
            if tbTitleTemp then
                pPlayer.Msg(string.format("由於转为新门派，原称号「%s」无法使用，称号消失", tbTitleTemp.Name));
            end    
        end
    end

    if FactionBattle.FactionMonkey then
        Lib:CallBack({FactionBattle.FactionMonkey.DelCandidate, FactionBattle.FactionMonkey, nOrgFaction, pPlayer.dwID});
        Log("ChangeFaction ClearFactionData FactionMonkey", pPlayer.dwID, nOrgFaction);
    end

    
    
    Log("ChangeFaction ClearFactionData", pPlayer.dwID, nOrgFaction, nOrgSex);
end
