local tbAct = Activity:GetClass("QingRenJie")
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }

tbAct.GROUP = 68
tbAct.VERSION = 11
tbAct.INVITE = 12
tbAct.BE_INVITE = 13
tbAct.TICKET_FLAG = 14
tbAct.TITLE_FLAG = 15
tbAct.SIT_FLAG = 16
tbAct.ACCEPT_DAY = 17
tbAct.ACCEPT_TIMES = 18
tbAct.tbMapInfo = {}

----------------------------以下为配置项----------------------------
tbAct.TICKET_TID = 3790      --船票ID
tbAct.GIFT_TID = 3787        --赠送礼物时赠送方得到的了礼物
tbAct.GIFT_TID_ACCEPT = 3791 --赠送礼物是对方得到的了礼物
tbAct.RANDOM_GIFT_TID = 3793 --从礼物开出的道具ID
tbAct.TICKET_RATE = 10000    --max is 1000000
tbAct.LEVEL = 40             --参与等级
tbAct.tbGift = {
    3788,
    3789,
}
tbAct.TITLE_ENDTIME = Lib:ParseDateTime("2018/3/14")
tbAct.BE_SEND_GIFT = 5      --每天接受礼物时只能有5有奖励
tbAct.HEAD_BG = 25          --头像框ID
tbAct.CHOOSE_TITLE_ID = 3792
tbAct.BASIC_EXP = 120
tbAct.IMITITY = 999
tbAct.tbPos = {
    {1450, 1700},
    {350,1700},
}
tbAct.TICKET_PRICE = 999
tbAct.NEED_IMITITY_LV = 1
----------------------------以上为配置项----------------------------

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:SendMail("    有朋自远方来，不亦乐乎？有舟自远方来，不游乐乎？今江湖有异国之邦到访，随之而来的还有妖艳花朵及精致船坊，侠士只需完成[FFFE0D]每日目标活跃度[-]即可获得礼物，有缘人更可获得稀有[FFFE0D]双人船票[-]，与心仪之人一睹小楼听雨舫的风采！若与船票失之交臂，只需前往[FFFE0D]襄阳城[-]寻找[c8ff00][url=npc:小紫烟, 95, 10][-]即可直接购买船票！船队将於数日後离开，不要错过哦！")
    elseif szTrigger == "Start" then 
        Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnGainEverydayAward")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_AgreeInvite", "AgreeInvite")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_TryDazuo", "TryDazuo")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_AgreeInviteDazuo", "AgreeInviteDazuo")
        Activity:RegisterPlayerEvent(self, "Act_QingRenJie_ChooseTitle", "TryChooseTitle")
        Activity:RegisterPlayerEvent(self, "Act_TryUseQingRenJieGift", "OnUseGift")
        Activity:RegisterPlayerEvent(self, "Act_SendGift", "OnSendGift")
        Activity:RegisterPlayerEvent(self, "Act_OnLeaveMap", "OnLeaveMap")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogout", "OnLogout")
        Activity:RegisterNpcDialog(self, 95, {Text = "前去购买船票", Callback = self.BuyTicket, Param = {self}})
        Activity:RegisterNpcDialog(self, 95, {Text = "前往小楼听雨舫", Callback = self.TryInteract, Param = {self}})
        Activity:RegisterNpcDialog(self, 95, {Text = "前去被邀请船舫", Callback = self.TryEnterAlong, Param = {self}})
        self.tbMapInfo = {}
        local tbItem = Item:GetClass("QingRenJieTitleItem")
        self.tbTitle = tbItem.tbTitle
    elseif szTrigger == "End" then
        self:SendMail("    诸位侠士，中原武林果然有趣，各位情深意重，也令我大开眼界，如今船队已然离去，还望诸位保重！来年再会！")
    end
end

function tbAct:SendMail(szContent)
    Mail:SendGlobalSystemMail({
        Title = "泛舟江湖情人结",
        Text = szContent,
        From = "小紫烟",
        LevelLimit = self.LEVEL
        })
end

function tbAct:OnGainEverydayAward(pPlayer)
    if pPlayer.nLevel < self.LEVEL then
        return
    end

    local nSex = pPlayer.nSex
    local _, nEndTime = self:GetOpenTimeInfo()
    pPlayer.SendAward({{"Item", self.tbGift[nSex], 1, nEndTime}}, true, false, Env.LogWay_QingRenJie)
    Log("QingRenJie OnGainEverydayAward", pPlayer.dwID)
end

function tbAct:CheckGainTicket(pPlayer)
    self:CheckPlayerData(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.TICKET_FLAG) <= 0, "活动期间每名侠士只能获得一张船票"
end

function tbAct:BuyTicket(bConfirm)
    local pPlayer = me
    local bRet, szMsg = self:CheckGainTicket(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    if not bConfirm then
        me.MsgBox("每位侠士只能获得一张船票，是否确认花费[FFFE0D]999元宝[-]进行购买？", {{"确认", self.BuyTicket, self, true}, {"取消"}})
        return
    end

    if pPlayer.GetMoney("Gold") < self.TICKET_PRICE then
        pPlayer.CenterMsg("元宝不足！请先储值")
        pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge")
        return
    end
    pPlayer.CostGold(self.TICKET_PRICE, Env.LogWay_QingRenJie, nil, function (nPlayerId, bSuccess)
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
            if not pPlayer then
                return false, "离线了"
            end

            if not bSuccess then
                return false, "储值失败"
            end

            local bRet, szMsg = self:CheckGainTicket(pPlayer)
            if not bRet then
                return false, szMsg
            end

            local _, nEndTime = self:GetOpenTimeInfo()
            pPlayer.SetUserValue(self.GROUP, self.TICKET_FLAG, 1)
            pPlayer.SendAward({{"Item", self.TICKET_TID, 1, nEndTime}}, true, nil, Env.LogWay_QingRenJie)
            Log("QingRenJie BuyTicket Success", pPlayer.dwID)
            return true
    end)
end

function tbAct:OnUseGift(pPlayer, pItem)
    if Item:Consume(pItem, 1) < 1 then
        return
    end

    local _, nEndTime = self:GetOpenTimeInfo()
    local bRet = self:CheckGainTicket(pPlayer)
    if bRet and MathRandom(1000000) <= self.TICKET_RATE then
        pPlayer.SetUserValue(self.GROUP, self.TICKET_FLAG, 1)
        pPlayer.SendAward({{"Item", self.TICKET_TID, 1, nEndTime}}, true, false, Env.LogWay_QingRenJie)
        local szMsg = string.format("侠士「%s」开启回礼礼盒後发现其中的双人船票·泛舟江湖，不日即可携心仪之人同行，同舟共渡，实在令人心生羡慕！", pPlayer.szName)
        KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
        Log("QingRenJie OnUseGift GetTicket", pPlayer.dwID)
    end
    pPlayer.SendAward({{"Item", self.RANDOM_GIFT_TID, 1, nEndTime}}, true, false, Env.LogWay_QingRenJie)
    Log("QingRenJie UseGift", pPlayer.dwID)
end

function tbAct:OnSendGift(pPlayer, pAcceptPlayer, nGiftType)
    if nGiftType ~= Gift.GiftType.Lover then
        return
    end

    local _, nEndTime = self:GetOpenTimeInfo()
    local tbAward = {{"Item", self.GIFT_TID, 1, nEndTime}}
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_QingRenJie)
    if pAcceptPlayer.GetUserValue(self.GROUP, self.ACCEPT_DAY) ~= Lib:GetLocalDay() then
        pAcceptPlayer.SetUserValue(self.GROUP, self.ACCEPT_DAY, Lib:GetLocalDay())
        pAcceptPlayer.SetUserValue(self.GROUP, self.ACCEPT_TIMES, 0)
    end
    local nHadAcc = pAcceptPlayer.GetUserValue(self.GROUP, self.ACCEPT_TIMES)
    if nHadAcc < self.BE_SEND_GIFT then
        pAcceptPlayer.SetUserValue(self.GROUP, self.ACCEPT_TIMES, nHadAcc + 1)
        local tbAward = {{"Item", self.GIFT_TID_ACCEPT, 1, nEndTime}}
        pAcceptPlayer.SendAward(tbAward, true, false, Env.LogWay_QingRenJie)

        local nGiftTID = Gift:GetItemId(nGiftType, pAcceptPlayer.nSex)
        local szItemName = KItem.GetItemShowInfo(nGiftTID)
        local szMsg = string.format("    佳节将至，情缘未远。值此佳节，[FFFE0D]「%s」[-]将准备已久的[FFFE0D]「%s」[-]小心交到你的手中，你接过一看，下面竟然还藏有一个小小的礼盒，快打开看看里面装着什麽吧！", pPlayer.szName, szItemName)
        local tbMail = {Title = "泛舟江湖情人结", Text = szMsg, nLogReazon = Env.LogWay_QingRenJie, To = pAcceptPlayer.dwID}
        Mail:SendSystemMail(tbMail)
        Log("QingRenJie OnBeSendGift", pAcceptPlayer.dwID, nHadAcc)
    end
    Log("QingRenJie OnSendGift", pPlayer.dwID, pAcceptPlayer.dwID)
end

function tbAct:CheckPlayerData(pPlayer)
    local nStartTime = self:GetOpenTimeInfo()
    local nVersion = pPlayer.GetUserValue(self.GROUP, self.VERSION)
    if nVersion ~= nStartTime then
        pPlayer.SetUserValue(self.GROUP, self.VERSION, nStartTime)
        for i = self.VERSION + 1, self.SIT_FLAG do
            pPlayer.SetUserValue(self.GROUP, i, 0)
        end
    end
end

function tbAct:CheckEnterSelfMap(pPlayer)
    self:CheckPlayerData(pPlayer)
    if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
        pPlayer.CenterMsg("目前状态不允许切换地图")
        return
    end
    return pPlayer.GetUserValue(self.GROUP, self.INVITE) > 0
end

function tbAct:CheckInvite(pPlayer, pLover)
    if pPlayer.nLevel < self.LEVEL then
        return false, "等级须大於等於40级方可参与"
    end

    if pPlayer.GetUserValue(self.GROUP, self.INVITE) > 0 then
        return false, "每个侠士只能邀请一次"
    end

    if not pPlayer.dwTeamID or pPlayer.dwTeamID == 0 then
        return false, "你还没有队伍"
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, "必须组成两人队伍"
    end

    if pPlayer.GetItemCountInAllPos(self.TICKET_TID) <= 0 then
        return false, "没有船票泛舟江湖，请先获取船票"
    end

    local dwLover = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    if pLover then
        if pLover.dwID ~= dwLover then
            return false
        end
    else
        pLover = KPlayer.GetPlayerObjById(dwLover)
    end
    if not pLover then
        return false, "没找到队友"
    end

    if pPlayer.nSex == pLover.nSex or not FriendShip:IsFriend(pPlayer.dwID, dwLover) then
        return false, "你与对方并非异性的好友，请确认後在进行尝试哦"
    end

    if pLover.nLevel < self.LEVEL then
        return false, "被邀请的侠士等级不足"
    end

    self:CheckPlayerData(pLover)
    if pLover.GetUserValue(self.GROUP, self.BE_INVITE) > 0 then
        local szMsg = "每名侠士只能接受一次邀请"
        pLover.CenterMsg(szMsg)
        return false, szMsg, pLover
    end

    local nMapId1 = pPlayer.GetWorldPos()
    local nMapId2 = pLover.GetWorldPos()
    if nMapId1 ~= nMapId2 or pPlayer.GetNpc().GetDistance(pLover.GetNpc().nId) > Npc.DIALOG_DISTANCE * 3 then
        return false, "有队员距离小紫烟太远了，请先到小紫烟身边哦", pLover
    end

    if FriendShip:GetFriendImityLevel(pPlayer.dwID, pLover.dwID) < self.NEED_IMITITY_LV then
        return false, string.format("双方亲密度等级需达到%d级", self.NEED_IMITITY_LV), pLover
    end

    for _, pNeedCheck in ipairs({pPlayer, pLover}) do
        if not Fuben.tbSafeMap[pNeedCheck.nMapTemplateId] and Map:GetClassDesc(pNeedCheck.nMapTemplateId) ~= "fight" and
            pNeedCheck.nMapTemplateId ~= self.PREPARE_MAPID and pNeedCheck.nMapTemplateId ~= self.OUTSIDE_MAPID then
            return false, string.format("「%s」所在地图不允许进入副本！", pNeedCheck.szName), pLover
        end

        if Map:GetClassDesc(pNeedCheck.nMapTemplateId) == "fight" and pNeedCheck.nFightMode ~= 0 then
            return false, string.format("「%s」非安全区不允许进入副本！", pNeedCheck.szName), pLover
        end
    end

    return true, nil, pLover
end

function tbAct:TryInteract()
    local pPlayer = me
    if self:CheckEnterSelfMap(pPlayer) then
        local nMapId = self.tbMapInfo[pPlayer.dwID]
        self:EnterMap(pPlayer.dwID, nMapId)
        return
    end

    local bRet, szMsg, pLover = self:CheckInvite(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
            if pLover then
                pLover.CenterMsg(szMsg)
            end
        end
        return
    end

    pLover.CallClientScript("Activity.QingRenJie:OnGetInvite", pPlayer.dwID, pPlayer.szName)
end

function tbAct:AgreeInvite(pBeInvitePlayer, nInvitePlayer, bAgree)
    if not nInvitePlayer then
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(nInvitePlayer)
    if not pPlayer then
        pBeInvitePlayer.CenterMsg("对方未在线")
        return
    end

    if not bAgree then
        pPlayer.CenterMsg("对方拒绝了你的邀请")
        return
    end

    local bRet, szMsg = self:CheckInvite(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
            pBeInvitePlayer.CenterMsg(szMsg)
        end
        return
    end

    local nPlayer1 = pPlayer.dwID
    local nPlayer2 = pBeInvitePlayer.dwID
    local fnSuccessCallback = function (nMapId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayer1)
        local pLover = KPlayer.GetPlayerObjById(nPlayer2)
        if not pPlayer or not pLover then
            return
        end

        pPlayer.ConsumeItemInAllPos(self.TICKET_TID, 1, Env.LogWay_QingRenJie)
        pPlayer.SetUserValue(self.GROUP, self.INVITE, pLover.dwID)
        pLover.SetUserValue(self.GROUP, self.BE_INVITE, pPlayer.dwID)
        self:SwitchMap(pPlayer, nMapId, 0, 0, pPlayer.dwID)
        self:SwitchMap(pLover, nMapId, 0, 0, pPlayer.dwID)
        self.tbMapInfo[pPlayer.dwID] = nMapId
        local szMsg = string.format("%s和%s携手一同登上了小楼听雨舫，泛舟湖上，共赏江湖美景！实在是羡煞旁人！", pPlayer.szName, pLover.szName)
        KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
        Log("QingRenJie Invite Success", pPlayer.dwID, pLover.dwID)
    end

    local fnFailedCallback = function ()
        local pPlayer = KPlayer.GetPlayerObjById(nPlayer1)
        local pLover = KPlayer.GetPlayerObjById(nPlayer2)
        if not pPlayer or not pLover then
            return
        end
        pPlayer.CenterMsg("进入失败，请重试")
        pLover.CenterMsg("进入失败，请重试")
        Log("QingRenJie Invite CreateMap Fail", pPlayer.dwID, pLover.dwID)
    end

    Fuben:ApplyFuben(pPlayer.dwID, self.MAP_TID, fnSuccessCallback, fnFailedCallback)
end

function tbAct:TryEnterAlong()
    local pPlayer = me
    self:CheckPlayerData(pPlayer)
    local nInvitePlayer = pPlayer.GetUserValue(self.GROUP, self.BE_INVITE)
    if nInvitePlayer <= 0 then
        pPlayer.CenterMsg("未被邀请")
        return
    end

    local nMapId = self.tbMapInfo[nInvitePlayer]
    self:EnterMap(pPlayer.dwID, nMapId, nInvitePlayer)
end

function tbAct:EnterMap(dwID, nMapId, nInvitePlayer)
    if not nMapId or not GetMapInfoById(nMapId) then
        local fnSuccessCallback = function (nMapId)
            local nPlayerID = nInvitePlayer or dwID
            self.tbMapInfo[nPlayerID] = nMapId
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if not pPlayer then
                return
            end
            self:SwitchMap(pPlayer, nMapId, 0, 0, nInvitePlayer or dwID)
        end
    
        local fnFailedCallback = function ()
            local pPlayer = KPlayer.GetPlayerObjById(nPlayer1)
            if not pPlayer then
                return
            end
            pPlayer.CenterMsg("进入失败，请重试")
        end
        Fuben:ApplyFuben(dwID, self.MAP_TID, fnSuccessCallback, fnFailedCallback)
    else
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        self:SwitchMap(pPlayer, nMapId, 0, 0, nInvitePlayer or dwID)
    end
end

function tbAct:SwitchMap(pPlayer, nMapId, nX, nY, nApplyID)
    if pPlayer.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:DoChangeActionMode(pPlayer, Npc.NpcActionModeType.act_mode_none)
    end
    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(nMapId, nX or 0, nY or 0)
    pPlayer.CallClientScript("Activity.QingRenJie:OnSetApplyPlayer", nApplyID)
end

function tbAct:CheckCanDazuo(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.SIT_FLAG) > 0 then
        return false, "只能进行一次互动"
    end

    if pPlayer.nMapTemplateId ~= self.MAP_TID then
        return false, "队伍中有成员不在小楼听雨舫地图内"
    end

    if pPlayer.nQingRenDazuo then
        return false, "正在进行互动"
    end

    if not pPlayer.dwTeamID or pPlayer.dwTeamID == 0 then
        return false, "你还没有队伍"
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, "必须与队伍中另一名异性好友处於本地图内"
    end

    local dwLover = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    local pLover = KPlayer.GetPlayerObjById(dwLover)
    if pLover.nMapTemplateId ~= self.MAP_TID then
        return false, "队伍中有成员不在小楼听雨舫地图内"
    end
    
    if pLover.nMapId ~= pPlayer.nMapId then
        return false, "对方不在小楼听雨舫地图内"
    end

    if pLover.nQingRenDazuo then
        return false, "正在观赏美景"
    end
    return true, nil, pLover
end

function tbAct:TryDazuo(pPlayer)
    local bRet, szMsg, pLover = self:CheckCanDazuo(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
        end
        return
    end

    pLover.CallClientScript("Activity.QingRenJie:OnGetDazuoInvite", pPlayer.dwID, pPlayer.szName)
end

function tbAct:AgreeInviteDazuo(pBeInvitePlayer, nInvitePlayer, bAgree)
    if not nInvitePlayer then
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(nInvitePlayer)
    if not pPlayer then
        pBeInvitePlayer.CenterMsg("对方未在线")
        return
    end

    if not bAgree then
        pPlayer.CenterMsg("对方拒绝了你的邀请")
        return
    end

    local bRet, szMsg = self:CheckCanDazuo(pPlayer)
    if not bRet then
        if szMsg then
            pPlayer.CenterMsg(szMsg)
            pBeInvitePlayer.CenterMsg("邀请已过期")
        end
        return
    end

    if ActionInteract:IsInteract(pPlayer) then
        ActionInteract:UnbindLinkInteract(pPlayer)
        pPlayer.CallClientScript("Ui:CloseWindow", "QYHLeavePanel")
    end
    if ActionInteract:IsInteract(pBeInvitePlayer) then
        ActionInteract:UnbindLinkInteract(pBeInvitePlayer)
        pBeInvitePlayer.CallClientScript("Ui:CloseWindow", "QYHLeavePanel")
    end

    Env:SetSystemSwitchOff(pPlayer, Env.SW_All)
    Env:SetSystemSwitchOff(pBeInvitePlayer, Env.SW_All)

    if pPlayer.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:DoChangeActionMode(pPlayer, Npc.NpcActionModeType.act_mode_none)
    end
    if pBeInvitePlayer.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
        ActionMode:DoChangeActionMode(pBeInvitePlayer, Npc.NpcActionModeType.act_mode_none)
    end

    pPlayer.SetPosition(830,1135)
    pBeInvitePlayer.SetPosition(790,1110)
    pPlayer.GetNpc().CastSkill(1083, 1, self.tbPos[1][1], self.tbPos[1][2])
    pBeInvitePlayer.GetNpc().CastSkill(1083, 1, self.tbPos[2][1], self.tbPos[2][2])

    pPlayer.SetUserValue(self.GROUP, self.SIT_FLAG, 1)

    pPlayer.nQingRenDazuo = self.DAZUO_SEC
    pPlayer.CallClientScript("Activity.QingRenJie:OnBeginDazuo")
    ValueItem.ValueDecorate:SetValue(pPlayer, self.HEAD_BG, ChatMgr.ChatDecorate.Valid_Type.FOREVER)
    pPlayer.CenterMsg("恭喜侠士使用船票登上小楼听雨舫，解锁「泛舟江湖情人结」头像框！")
    pBeInvitePlayer.nQingRenDazuo = self.DAZUO_SEC
    pBeInvitePlayer.CallClientScript("Activity.QingRenJie:OnBeginDazuo")
    Timer:Register(Env.GAME_FPS, function ()
        return self:ContinueDazuo(pPlayer.dwID, pBeInvitePlayer.dwID)
    end)
end

function tbAct:ContinueDazuo(nPlayer, nLover)
    for _, nPlayerID in ipairs({nPlayer, nLover}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
        if pPlayer and pPlayer.nQingRenDazuo and pPlayer.nQingRenDazuo >= 1 then
            pPlayer.nQingRenDazuo = pPlayer.nQingRenDazuo - 1
            local bAddExp = pPlayer.nQingRenDazuo%(self.DAZUO_SEC/self.EXP_TIMES) == 0
            if bAddExp or pPlayer.nQingRenDazuo%12 == 0 then
                if bAddExp then
                    pPlayer.SendAward({{"BasicExp", self.BASIC_EXP/self.EXP_TIMES}}, false, false, Env.LogWay_QingRenJie)
                end
                pPlayer.CallClientScript("Activity.QingRenJie:ContinueDazuo", pPlayer.nQingRenDazuo)
            end
        else
            self:RestoreState(nPlayer, nLover)
            return
        end
    end
    return true
end

function tbAct:RestoreState(nPlayer, nLover)
    for _, nPlayerID in ipairs({nPlayer, nLover}) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
        if pPlayer then
            Env:SetSystemSwitchOn(pPlayer, Env.SW_All)
            pPlayer.GetNpc().RestoreAction()
            pPlayer.nQingRenDazuo = nil
            pPlayer.CallClientScript("Activity.QingRenJie:OnDazuoEnd", nPlayer == nPlayerID)
        end
    end
    FriendShip:AddImitity(nPlayer, nLover, self.IMITITY, Env.LogWay_QingRenJie)
end

function tbAct:TryChooseTitle(pPlayer, nTitleId, nItemID)
    if nItemID then
        self:ChooseTitleByItem(pPlayer, nTitleId, nItemID)
        return
    end

    if pPlayer.GetUserValue(self.GROUP, self.SIT_FLAG) <= 0 then
        pPlayer.CenterMsg("尚未观赏美景，无法进行称号选择")
        return
    end

    if pPlayer.GetUserValue(self.GROUP, self.TITLE_FLAG) > 0 then
        pPlayer.CenterMsg("已选称号")
        return
    end

    local nInvite = pPlayer.GetUserValue(self.GROUP, self.INVITE)
    if nInvite <= 0 then
        pPlayer.CenterMsg("未进入船坞")
        return
    end

    if not self.tbTitle[nTitleId] then
        pPlayer.CenterMsg("不能选择该称号")
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.TITLE_FLAG, 1)
    self:SendTitleMail(pPlayer.dwID, nInvite, {{"AddTimeTitle", nTitleId, self.TITLE_ENDTIME}})
    pPlayer.CenterMsg("恭喜侠士获得泛舟江湖情人结限时称号")
    local pLover = KPlayer.GetPlayerObjById(nInvite)
    if pLover then
        pLover.CenterMsg("恭喜侠士获得泛舟江湖情人结限时称号")
    end
    Log("QingRenJie TryChooseTitle", pPlayer.dwID, nInvite)
end

function tbAct:ChooseTitleByItem(pPlayer, nTitleId, nItemID)
    if not self.tbTitle[nTitleId] then
        return
    end

    local pItem = KItem.GetItemObj(nItemID)
    if not pItem then
        return
    end

    if Item:Consume(pItem, 1) < 1 then
        pPlayer.CenterMsg("道具消耗失败，请重试")
        return
    end

    local tbAward = {{"AddTimeTitle", nTitleId, self.TITLE_ENDTIME}}
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_QingRenJie)
end

function tbAct:OnLeaveMap(pPlayer, nMapTID)
    self:SendTitleItem(pPlayer, nMapTID)
end

function tbAct:OnLogout(pPlayer)
    self:SendTitleItem(pPlayer, pPlayer.nMapTemplateId)
end

function tbAct:SendTitleItem(pPlayer, nMapTID)
    if nMapTID ~= self.MAP_TID then
        return
    end

    pPlayer.CallClientScript("Ui:CloseWindow", "QingRenJieInvitePanel")
    if pPlayer.GetUserValue(self.GROUP, self.SIT_FLAG) <= 0 then
        return
    end
    if pPlayer.GetUserValue(self.GROUP, self.TITLE_FLAG) > 0 then
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.TITLE_FLAG, 1)
    local nLover = pPlayer.GetUserValue(self.GROUP, self.INVITE)
    local tbAward = {{"Item", self.CHOOSE_TITLE_ID, 1, self.TITLE_ENDTIME}}
    self:SendTitleMail(pPlayer.dwID, nLover, tbAward)
    Log("QingRenJie SendTitleItem", pPlayer.dwID, nLover)
end

function tbAct:SendTitleMail(dwID1, dwID2, tbAward)
    local tbMail = {Title = "泛舟江湖情人结", From = "小紫烟", nLogReazon = Env.LogWay_QingRenJie}
    tbMail.tbAttach = tbAward
    tbMail.Text = "    恭喜侠士使用船票登上小楼听雨舫，获得「泛舟江湖情人结」限时称号！祝二位情意长存！"
    for _, nPlayerID in ipairs({dwID1, dwID2}) do
        tbMail.To = nPlayerID
        Mail:SendSystemMail(tbMail)
    end
end