
local ACT_CLASS = "HouseDefend";
local tbActivity = Activity:GetClass(ACT_CLASS);

tbActivity.tbTimerTrigger = 
{
}

tbActivity.tbTrigger = 
{
	Init = 
	{
	},
    Start = 
    {
    },
    End = 
    {
    },
}

tbActivity.tbDailyAward =
{
    [1] = {{"Item", 5420, 1}},
    [2] = {{"Item", 5420, 1}},
    [3] = {{"Item", 5420, 1}},
    [4] = {{"Item", 5420, 1}},
    [5] = {{"Item", 5421, 1}},
};
tbActivity.tbJoinAward = 
{   
    {"Item", 4818, 1},
};
tbActivity.tbFubenAward =
{
    {"Item", 5430, 1},
};

tbActivity.MIN_LEVEL = 60;
tbActivity.TIME_CLEAR = 4 * 3600;
tbActivity.USERGROUP = 137;
tbActivity.USERKEY_FUBENTIME = 1; 
tbActivity.USERKEY_ACT_TIME = 2;
tbActivity.USERKEY_AWARD_COUNT = 3;
tbActivity.nFubenMapTemplateId = 4007;
tbActivity.MAX_AWARD_COUNT = 10;

tbActivity.tbHouseFuben = tbActivity.tbHouseFuben or {};

function tbActivity:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnGainEverydayAward");
        Activity:RegisterPlayerEvent(self, "Act_HouseDefend_OpenFuben", "OpenFuben");
        Activity:RegisterPlayerEvent(self, "Act_HouseDefend_EnterFuben", "EnterFuben");
        Activity:RegisterPlayerEvent(self, "Act_HouseDefend_FubenFinished", "OnFubenFinished");

        Activity:RegisterGlobalEvent(self, "Act_HouseDefend_FubenClose", "OnFubenClose");

        self:SendNews();
    end
end

function tbActivity:SendNews()
    local _, nEndTime = self:GetOpenTimeInfo();
    NewInformation:AddInfomation("ActHouseDefend", nEndTime, 
        {
        [[活动时间：[FFFE0D]2017年7月13日04：00-2017年7月24日3：59[-]\n\n[FFFE0D]新颖小筑，真情常驻[-]\n    诸位侠士，近日据闻杨大侠少侠与真儿女侠又再携手共闯江湖，只是两人嫉恶如仇，行侠仗义之际未免得罪不少武林恶徒，这些恶党若是光明正大前来挑战，两位侠侣自是不惧，但偏生这些卑鄙之人，恐怕会使用一些下三滥的伎俩。故武林盟特邀请诸位侠士，助杨大侠与赵女侠一臂之力。参与方式如下：\n\n    活动期间，完成[FFFE0D]每日目标[-]即可获得合成材料，每天完成[FFFE0D]20、40、60、80[-]时，均将获得 [aa62fc][url=openwnd:灰暗的兔子灯罩, ItemTips, "Item", nil, 5420][-]，完成[FFFE0D]100点[-]时将获得 [aa62fc][url=openwnd:摇曳的兔子灯芯, ItemTips, "Item", nil, 5421][-]，集齐後有机会获得[ff8f06][url=openwnd:邀请函·杨大侠, ItemTips, "Item", nil, 5423][-] [ff8f06][url=openwnd:邀请函·真儿, ItemTips, "Item", nil, 5424][-]或是一份[FFFE0D]随机奖励[-]。\n\n    若侠士幸运得到邀请函，又拥有家园，可邀杨大侠少侠/真儿女侠来自己的家园做客，已加入帮派的侠士，还可与他们对话开启新颖小筑夺回战，与[FFFE0D]帮派成员[-]一同説明他们夺回家园，规则如下：\n\n1、新颖小筑夺回战开启後，[FFFE0D]开启者[-]将获得一份奖励，所在帮派的成员均可进入挑战，击败最终头目後[FFFE0D]所有地图内的侠士均将获得一份奖励[-]，活动期间，每个侠士最多只能获得[FFFE0D]10次奖励[-]，但仍可前往帮助其他侠士夺回新颖小筑\n2、开启新颖小筑夺回战後将发送帮派公告，[FFFE0D]入口持续1小时後关闭[-]，一定要确定有足够的帮派成员与你一同挑战再开启！\n3、邀请函有效期至次日[FFFE0D]淩晨4点[-]，可千万不要忘记使用喔\n4、杨大侠少侠/真儿女侠也将在次日淩晨4日离开，别忘记及时开启夺回战\n5、侠士开启争夺战後，若更换帮派，新帮派的成员无法协助你进行活动]]
        }, 
        {
            szTitle = "新颖小筑情长驻", 
            nReqLevel = 60
        });
end

function tbActivity:OnGainEverydayAward(pPlayer, nAwardIdx)
    if pPlayer.nLevel < tbActivity.MIN_LEVEL then
        return;
    end

    local tbAward = tbActivity.tbDailyAward[nAwardIdx];
    if not tbAward then
        return;
    end

    local nEndTime = Activity:GetActEndTime(self.szKeyName);
    for _, tbInfo in ipairs(tbAward) do
        if tbInfo[1] == "Item" then
            tbInfo[4] = nEndTime;
        end
    end

    pPlayer.SendAward(tbAward, true, true, Env.LogWay_HouseDefend);

    Log("[HouseDefend] player gain daily award:", pPlayer.dwID, pPlayer.szName, nAwardIdx);
end

function tbActivity:CanOpenFuben(pPlayer)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_HouseDefend) then
        return false, "活动暂时关闭，请稍候再试";
    end

    if not House:IsInOwnHouse(pPlayer) then
        return false, "只能在自己家园开启副本哦";
    end

    if pPlayer.nLevel < tbActivity.MIN_LEVEL then
        return false, string.format("等级不足%d级", tbActivity.MIN_LEVEL);
    end

    local nOpenFubenTime = pPlayer.GetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_FUBENTIME);
    if nOpenFubenTime ~= 0 then
        local nCurDay = Lib:GetLocalDay(GetTime() - tbActivity.TIME_CLEAR);
        local nLastDay = Lib:GetLocalDay(nOpenFubenTime - tbActivity.TIME_CLEAR);
        if nCurDay == nLastDay then
            return false, "你已经开启过副本";
        end
    end

    if pPlayer.dwKinId == 0 then
        return false, "你还没有帮派！先去加入一个帮派吧";
    end

    local dwPlayerId = pPlayer.dwID;
    if tbActivity.tbHouseFuben[dwPlayerId] then
        return false, "你还有副本没完成！";
    end

    return true;
end

function tbActivity:OpenFuben(pPlayer, bConfirm)
    local bRet, szMsg = self:CanOpenFuben(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    if not bConfirm then
        pPlayer.MsgBox("新颖小筑夺回战开启後[FFFE0D]持续1小时[-]，其中贼匪众多，请确保有足够的帮派成员与你一同参与，是否确定开启？", {{"确定", function ()
            self:OpenFuben(me, true);
            end}, {"取消"}});
        return;
    end

    pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_FUBENTIME, GetTime());
    pPlayer.SendAward(tbActivity.tbJoinAward, true, false, Env.LogWay_HouseDefend);

    local dwPlayerId = pPlayer.dwID;
    local dwKinId = pPlayer.dwKinId;
    local fnSuccessCallback = function (nMapId)
        assert(not tbActivity.tbHouseFuben[dwPlayerId], "repeated fuben:" .. dwPlayerId);
        tbActivity.tbHouseFuben[dwPlayerId] = { nMapId = nMapId, dwKinId = dwKinId };

        local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
        if pPlayer then
            pPlayer.CenterMsg("开启新颖小筑夺回战成功！", 1);
        end

        local szMsg = string.format("「%s」开启新颖小筑夺回战啦，夺回後人人有奖，诸位帮派兄弟，快去助他一臂之力！", pPlayer.szName);
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, dwKinId);
    end

    local fnFailedCallback = function ()
        Log("[ERROR][HouseDefend] failed to create fuben: ", dwPlayerId);
    end

    Fuben:ApplyFuben(dwPlayerId, tbActivity.nFubenMapTemplateId, fnSuccessCallback, fnFailedCallback, dwPlayerId);

    Log("[HouseDefend] fuben open: player", dwPlayerId, "kin", dwKinId, "map", nMapId);
end

function tbActivity:OnFubenClose(nMapId, dwOwnerId)
    local tbFuben = tbActivity.tbHouseFuben[dwOwnerId];
    if not tbFuben then
        return;
    end
    
    if tbFuben.nMapId ~= nMapId then
        Log("[ERROR][HouseDefend] unknown fuben: ", nMapId, dwOwnerId);
        return;
    end

    tbActivity.tbHouseFuben[dwOwnerId] = nil;

    Log("[HouseDefend] fuben close: ", nMapId, dwOwnerId);
end

function tbActivity:CanEnterFuben(pPlayer, dwOwnerId)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_HouseDefend) then
        return false, "活动暂时关闭，请稍候再试";
    end

    local tbFuben = tbActivity.tbHouseFuben[dwOwnerId];
    if not tbFuben then
        return false, "还没有开启副本";
    end

    if pPlayer.dwID ~= dwOwnerId and pPlayer.dwKinId ~= tbFuben.dwKinId then
        return false, "你不符合条件进入";
    end

    return true, tbFuben.nMapId;
end

function tbActivity:EnterFuben(pPlayer, dwOwnerId)
    local bRet, result = self:CanEnterFuben(pPlayer, dwOwnerId);
    if not bRet then
        pPlayer.CenterMsg(result);
        return;
    end
    pPlayer.SetEntryPoint();
    pPlayer.SwitchMap(result, 0, 0);
end

function tbActivity:GetAwardCount(pPlayer)
    local nLastActTime = pPlayer.GetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_ACT_TIME);
    local nCurActTime = Activity:GetActBeginTime(self.szKeyName);
    if nLastActTime < nCurActTime then
        pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_ACT_TIME, nCurActTime);
        pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_AWARD_COUNT, 0);
    end
    return pPlayer.GetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_AWARD_COUNT);
end

function tbActivity:OnFubenFinished(pPlayer, nMapId)
    local nCurAwardCount = self:GetAwardCount(pPlayer);
    if nCurAwardCount >= tbActivity.MAX_AWARD_COUNT then
        Npc:SetPlayerNoDropMap(pPlayer, nMapId);
        return;
    end

    pPlayer.SetUserValue(tbActivity.USERGROUP, tbActivity.USERKEY_AWARD_COUNT, nCurAwardCount + 1);
    pPlayer.SendAward(tbActivity.tbFubenAward, true, true, Env.LogWay_HouseDefend);
    
    Log("[HouseDefend] player gain fuben award: ", pPlayer.dwID, pPlayer.szName);
end