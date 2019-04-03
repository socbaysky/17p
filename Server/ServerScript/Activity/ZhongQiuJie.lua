local tbAct = Activity:GetClass("ZhongQiuJie")
tbAct.tbTimerTrigger = {
    [1] = {szType = "Day", Time = "23:58" , Trigger = "CheckSendRankRewards"},
}
tbAct.tbTrigger = { 
    Init = {},
    Start = { {"StartTimerTrigger", 1}, },
    CheckSendRankRewards = {},
    End = {},
}

tbAct.szMailText = "您在[FFFE0D]中秋祭月榜[-]中位列第[FFFE0D]%d[-]名，附件为奖励，请查收！"
tbAct.tbRankAward = {
    {1, { {"Item", 6446, 1}, }},
    {10, { {"Item", 6447, 1}, }},
    {50, { {"Item", 6448, 1}, }},
}
tbAct.nBaseRewardScoreMin = 800 --x分以上的玩家有基础奖励
tbAct.tbBaseReward = {"Item", 6465, 1} --基础奖励

tbAct.nKinGatherExpAddScore = 1    --每次获得烤火经验时加的积分
tbAct.nKinGatherExtraDrinkAddExp = 2    --额外喝酒增加经验百分比
tbAct.nKinGatherExtraDrinkCost = 20 --额外喝酒花费元宝数
tbAct.nKinGatherExtraDrinkMaxCount = 20 --额外喝酒最多人数
tbAct.nKinGatherExtraDrinkScore = 50    --额外喝酒获得积分

tbAct.nReceiveMoonCakeScore = 60   --收到别人赠送月饼增加积分

tbAct.nAnswer10Score = 100  --完成当天10次答题获得积分奖励
tbAct.nAnswerRightScore = 10    --答对得分
tbAct.nAnswerWrongScore = 5     --答错得分
tbAct.tbAnswerTimeScore = { --答题耗时得分
    {5, 5}, --{x秒内, 答对附加得分，答错不给}
}
tbAct.nAnswerAllRightRewardRate = 4000  --全部答对获得礼盒概率（分母10000）

tbAct.nMoonCakeBoxId = 6442 --精美月饼礼盒id
tbAct.nOpenMoonCakeBoxScore = 20    --打开精美月饼礼盒获得积分
tbAct.nMaxMoonCakeBoxScoreTime = 6  --打开礼盒最多获得积分次数

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:ClearRankBoard()
        self:SendStartMail()
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_ZhognQiuJieAnswerCallBack", "OnAnswerCallBack")
        Activity:RegisterGlobalEvent(self, "Act_KinGatherAddExp", "OnKinGatherAddExp")
        Activity:RegisterGlobalEvent(self, "Act_KinGatherDrink", "OnKinGatherDrink")
        Activity:RegisterGlobalEvent(self, "Act_KinGatherDrunk", "OnKinGatherDrunk")
        Activity:RegisterPlayerEvent(self, "Act_KinGather_Open", "OnKinGatherOpen")
        Activity:RegisterPlayerEvent(self, "Act_KinGather_Close", "OnKinGatherClose")
        Activity:RegisterPlayerEvent(self, "Act_SendGift", "OnSendGift")
        Activity:RegisterPlayerEvent(self, "Act_UseMoonCakeBox", "OnUseMoonCakeBox")
        Activity:RegisterNpcDialog(self, 99, {Text = "中秋答题", Callback = self.TryQuestion, Param = {self}})
        DaTi:SetQuestionNum("ZhongQiuJie", self.MAX_QUESTION)
        self:ChangeGatherDrinkData()
    elseif szTrigger == "End" then
        self:RestoreGatherDrinkData()
    elseif szTrigger=="CheckSendRankRewards" then
        self:CheckSendRankRewards()
    end
    Log("ZhongQiuJie OnTrigger:", szTrigger)
end

function tbAct:ChangeGatherDrinkData()
    self.nOldMaxExtraExpBuff = Kin.GatherDef.MaxExtraExpBuff
    Kin.GatherDef.MaxExtraExpBuff = Kin.GatherDef.MaxExtraExpBuff+self.nKinGatherExtraDrinkAddExp*self.nKinGatherExtraDrinkMaxCount
end

function tbAct:RestoreGatherDrinkData()
    Kin.GatherDef.MaxExtraExpBuff = self.nOldMaxExtraExpBuff
end

function tbAct:OnUseMoonCakeBox(pPlayer)
    if self:GetMoonCakeBoxScoreTime(pPlayer)>=self.nMaxMoonCakeBoxScoreTime then
        pPlayer.Msg("抱歉少侠，精美月饼礼盒获取祭月值已达上限。", 1)
        return
    end
    self:AddScore(pPlayer, self.nOpenMoonCakeBoxScore, "精美月饼礼盒")
    self:AddMoonCakeBoxScoreTime(pPlayer, 1)
end

function tbAct:OnSendGift(pPlayer, pAcceptPlayer, nGiftType)
    if nGiftType~=Gift.GiftType.MoonCake then
        return
    end

    self:AddScore(pAcceptPlayer, self.nReceiveMoonCakeScore, "获赠晴云秋月")
end

function tbAct:SendStartMail()
    Mail:SendGlobalSystemMail({
        Title = "中秋祭月活动",
        Text = "遥寄相思中秋梦，千里故人何处逢。象徵着团圆美满的中秋佳节再次到来，现推出一系列中秋节特别活动，更有丰厚诱人的奖励等着诸位少侠！[FFFE0D][url=openwnd:点此了解详情, NewInformationPanel, '___Activity___ZhongQiuJie'][-]",
        From = "系统",
        tbAttach = {
            {"item", self.nMoonCakeBoxId, 1, GetTime()+3*24*3600},
        },
        LevelLimit = self.nJoinLevel,
    })
    Log("ZhongQiuJie:SendStartMail")
end

function tbAct:TryQuestion()
    local bRet, szMsg = self:CheckCanAnswer(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    me.MsgBox("答题过程不可中断，是否确认开始答题？", {{"确认", self.ConfirmBeginAnswer, self}, {"取消"}})
end

function tbAct:GetRankAward(nRank, nScore)
    local tbAward = nil
    for _, tbInfo in ipairs(self.tbRankAward) do
        if nRank <= tbInfo[1] then
            tbAward = tbInfo[2]
            break
        end
    end

    if nScore>=self.nBaseRewardScoreMin then
        tbAward = tbAward or {}
        table.insert(tbAward, self.tbBaseReward)
    end
    return tbAward
end

function tbAct:CheckSendRankRewards()
    local nNow = GetTime()
    local _, nEndTime = self:GetOpenTimeInfo()
    if nEndTime<nNow or nEndTime-nNow>=3600 then
        return
    end

    self:BalanceRankBoard()
end

--结算排行榜
function tbAct:BalanceRankBoard()
    RankBoard:Rank(self.szMainKey)

    local tbRankPlayer = RankBoard:GetRankBoardWithLength(self.szMainKey, 99999, 1)
    local tbMail = {Title = "中秋祭月榜奖励", From = "", nLogReazon = Env.LogWay_ZhongQiuJie}
    local nSendNum = 0
    for nRank, tbRankInfo in ipairs(tbRankPlayer or {}) do
        local tbAward = self:GetRankAward(nRank, tonumber(tbRankInfo.szValue))
        if not tbAward or not next(tbAward) then
            break
        end
        local szMailText = string.format(self.szMailText, nRank)
        tbMail.Text = szMailText
        tbMail.To = tbRankInfo.dwUnitID
        tbMail.tbAttach = tbAward
        Mail:SendSystemMail(tbMail)
        nSendNum = nRank
    end
    Log("ZhongQiuJie BalanceRankBoard", nSendNum)
end

function tbAct:ClearRankBoard()
    RankBoard:ClearRank(self.szMainKey)
end

function tbAct:CommonCheck(pPlayer)
    if pPlayer.nLevel<self.nJoinLevel then
        return false, "等级不足，无法参加"
    end
    
    local nCurTime = Lib:GetTodaySec()
    if nCurTime >= self.CLEARING_TIME or nCurTime < self.REFRESH_TIME then
        return false, "不在答题时间内"
    end

    return true
end

function tbAct:CheckCanAnswer(pPlayer)
    local bRet, szMsg = self:CommonCheck(pPlayer)
    if not bRet then
        return bRet, szMsg
    end

    self:RefreshData(pPlayer)
    local nLastBeginTime = pPlayer.GetUserValue(self.nSaveGroup, self.BEGIN_TIME)
    local nCompleteNum = pPlayer.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM)
    if nLastBeginTime > 0 and GetTime() - nLastBeginTime > self.TIME_OUT then
        local nTotalTime = pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME) + self.TIME_OUT
        nCompleteNum = nCompleteNum + 1
        pPlayer.SetUserValue(self.nSaveGroup, self.COMPLETE_NUM, nCompleteNum)
        pPlayer.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.TOTAL_TIME, nTotalTime)

        local tbAward = {}
        table.insert(tbAward, self.tbQuestionAward_Wrong)
        pPlayer.SendAward(tbAward, nil, true, Env.LogWay_ZhongQiuJie)
        self:AddScore(pPlayer, self.nAnswerWrongScore, "回答错误")
    end
    if nCompleteNum >= self.MAX_QUESTION then
        return false, "今天的答题已完成"
    end

    return true
end

function tbAct:ConfirmBeginAnswer()
    local bRet, szMsg = self:CheckCanAnswer(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    local nBeginTime = me.GetUserValue(self.nSaveGroup, self.BEGIN_TIME)
    if nBeginTime == 0 then
        me.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, GetTime())
    end
    local nEndTime = (nBeginTime == 0 and GetTime() or nBeginTime) + self.TIME_OUT
    DaTi:TryBeginQuestion(me, self.szMainKey, me.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM) + 1, nEndTime)
end

function tbAct:RefreshData(pPlayer)
    local nLastSaveTime = pPlayer.GetUserValue(self.nSaveGroup, self.DATA_TIME)
    if Lib:IsDiffDay(self.REFRESH_TIME, nLastSaveTime) then
        pPlayer.SetUserValue(self.nSaveGroup, self.DATA_TIME, GetTime())
        pPlayer.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.COMPLETE_NUM, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.TOTAL_TIME, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.RIGHT_NUM, 0)
        DaTi:Refresh(pPlayer.dwID, self.szMainKey)
        return true
    end
end

function tbAct:_Drink(pPlayer)
    if pPlayer.dwKinId == 0 then
        return false, "无帮派";
    end

    if self:HasDrunk(pPlayer) then
        return false, "你已经请大家喝过酒了！"
    end

    local memberData = Kin:GetMemberData(pPlayer.dwID);
    if not memberData then
        return false, "你不是此帮派成员"
    end
    if memberData:IsRetire() then
        return false, "退隐成员不参加该活动";
    end

    local kinData = Kin:GetKinById(pPlayer.dwKinId);
    local nKinMapId = kinData:GetMapId();

    if pPlayer.nMapId ~= nKinMapId then
        return false, "请到帮派属地参与烤火活动";
    end

    local tbGatherData = kinData:GetGatherData();
    if not next(tbGatherData) then
        return false, "烤火活动已结束";
    end

    local nPrice = self.nKinGatherExtraDrinkCost
    local nGold = pPlayer.GetMoney("Gold");
    if nGold < nPrice then
        return false, "你没钱.. 快到储值介面储值吧";
    end

    local pFireNpc = KNpc.GetById(tbGatherData.nFireNpcId);
    if not pFireNpc then
        return false, "篝火哪里去了...";
    end

    local nCurFireAddExp = pFireNpc.tbTmp.nExtraKinAddRate or 0;
    local nMaxExtraExpBuff = Kin.GatherDef.MaxExtraExpBuff
    if nCurFireAddExp + pFireNpc.tbTmp.nQuotiety >= nMaxExtraExpBuff then
        Kin.Gather:UpdateGatherData(pPlayer.dwKinId, { [Kin.GatherDef.Quotiety] = nMaxExtraExpBuff })
        return false, "已达到最大喝酒上限";
    end

    -- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
    pPlayer.CostGold(nPrice, Env.LogWay_ZhongQiuJie, nil, function (nPlayerId, bSuccess, szBillNo, kinData)
        if not bSuccess then
            return false;
        end

        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
        if not pPlayer then
            return false, "喝酒支付过程中您下线了";
        end

        local tbGatherData = kinData:GetGatherData();
        if not next(tbGatherData) then
            return false, "帮派聚集活动结束了";
        end

        local pFireNpc = KNpc.GetById(tbGatherData.nFireNpcId);
        if not pFireNpc then
            return false, "篝火不见了";
        end

        local nCurFireAddExp = pFireNpc.tbTmp.nExtraKinAddRate or 0;
        if nCurFireAddExp + pFireNpc.tbTmp.nQuotiety >= nMaxExtraExpBuff then
            Kin.Gather:UpdateGatherData(pPlayer.dwKinId, { [Kin.GatherDef.Quotiety] = nMaxExtraExpBuff })
            return false, "已达到最大喝酒上限";
        end

        pFireNpc.tbTmp.nQuotiety = pFireNpc.tbTmp.nQuotiety + self.nKinGatherExtraDrinkAddExp;
        tbGatherData.nQuotiety   = pFireNpc.tbTmp.nQuotiety
        Kin.Gather:UpdateGatherData(pPlayer.dwKinId, { [Kin.GatherDef.Quotiety] = math.min(pFireNpc.tbTmp.nQuotiety + nCurFireAddExp, nMaxExtraExpBuff) })

        self:SetDrunk(pPlayer)

        local szMsg = string.format("「%s」请大夥喝桂花酒，篝火经验加成增加了%d%%！", pPlayer.szName, self.nKinGatherExtraDrinkAddExp);
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, kinData.nKinId);
        self:AddScore(pPlayer, self.nKinGatherExtraDrinkScore, "请客喝桂花酒")
        pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinGatherDrink, tbGatherData.nQuotiety, 0)
        Log("ZhongQiuJie:_Drink", pPlayer.dwID, pPlayer.dwKinId, nPrice)
        return true;
    end, kinData);
    return true;
end

function tbAct:OnKinGatherOpen(pPlayer)
    self.tbDrinkCache = {}
end

function tbAct:OnKinGatherClose(pPlayer)
    self.tbDrinkCache = {}
end

function tbAct:SetDrunk(pPlayer)
    local nKinId = pPlayer.dwKinId or 0
    self.tbDrinkCache = self.tbDrinkCache or {}
    self.tbDrinkCache[nKinId] = self.tbDrinkCache[nKinId] or {}
    self.tbDrinkCache[nKinId][pPlayer.dwID] = true
end

function tbAct:HasDrunk(pPlayer)
    local nKinId = pPlayer.dwKinId or 0
    return self.tbDrinkCache and self.tbDrinkCache[nKinId] and self.tbDrinkCache[nKinId][pPlayer.dwID]
end

function tbAct:OnKinGatherDrunk(pPlayer)
    if self:HasDrunk(pPlayer) then
        pPlayer.CenterMsg("你已经请大家喝过酒了！")
        return
    end
    self:ShowDrinkMsgbox(pPlayer)
end

function tbAct:OnKinGatherDrink(pPlayer)
    if pPlayer.nLevel<self.nJoinLevel or self:HasDrunk(pPlayer) then
        return
    end
    self:ShowDrinkMsgbox(pPlayer)
end

function tbAct:ShowDrinkMsgbox(pPlayer)
    local function fConfirm()
        local bOk, szErr = self:_Drink(pPlayer)
        if not bOk and szErr then
            pPlayer.CenterMsg(szErr)
        end
    end

    local szMsg = string.format("是否花费 [FFFE0D]%d元宝[-] 请帮派全体成员在中秋节喝一壶桂花酒？\n（额外增加烤火经验%d%%%%，您将获得%d祭月值）", 
        self.nKinGatherExtraDrinkCost, self.nKinGatherExtraDrinkAddExp, self.nKinGatherExtraDrinkScore)
    pPlayer.MsgBox(szMsg, {{"同意", fConfirm}, {"拒绝"}})
end

function tbAct:OnKinGatherAddExp(pPlayer)
    self:AddScore(pPlayer, self.nKinGatherExpAddScore, "参与帮派烤火")
end

function tbAct:OnAnswerCallBack(pPlayer, nQuestionId, bRight, bTimeOut)
    local bRet, szMsg = self:CommonCheck(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        pPlayer.CallClientScript("DaTi:CloseUi")
        return
    end

    if self:RefreshData(pPlayer) then
        pPlayer.CenterMsg("这轮答题已结束，请重新开始")
        pPlayer.CallClientScript("DaTi:CloseUi")
        return
    end

    local nBeginTime = pPlayer.GetUserValue(self.nSaveGroup, self.BEGIN_TIME)
    if nBeginTime == 0 then
        Log("ZhongQiuJie OnAnswerCallBack Err", pPlayer.dwID)
        return
    end
    local nCompleteNum = pPlayer.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM)
    nCompleteNum = nCompleteNum + 1
    if nCompleteNum > self.MAX_QUESTION then
        pPlayer.CenterMsg("今日答题已结束")
        pPlayer.CallClientScript("DaTi:CloseUi")
        return
    end

    local nTime = math.min(GetTime() - nBeginTime, self.TIME_OUT)
    pPlayer.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, 0)
    pPlayer.SetUserValue(self.nSaveGroup, self.TOTAL_TIME, pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME) + nTime)
    pPlayer.SetUserValue(self.nSaveGroup, self.COMPLETE_NUM, nCompleteNum)
    if bTimeOut then
        pPlayer.CenterMsg("回答已超时")
    else
        local szReason = "回答错误"
        local nTotalScore = bRight and self.nAnswerRightScore or self.nAnswerWrongScore
        if bRight then
            pPlayer.SetUserValue(self.nSaveGroup, self.RIGHT_NUM, pPlayer.GetUserValue(self.nSaveGroup, self.RIGHT_NUM) + 1)

            szReason = "回答正确"
            for _, tb in ipairs(self.tbAnswerTimeScore) do
                local nSec, nScore = unpack(tb)
                if nTime<=nSec then
                    nTotalScore = nTotalScore+nScore
                    szReason = "快速回答正确"
                    break
                end
            end
        end
        self:AddScore(pPlayer, nTotalScore, szReason)
    end
    local tbAward = {}
    table.insert(tbAward, bRight and self.tbQuestionAward_Right or self.tbQuestionAward_Wrong)
    pPlayer.SendAward(tbAward, nil, true, Env.LogWay_ZhongQiuJie)
    if nCompleteNum >= self.MAX_QUESTION then
        pPlayer.CenterMsg("今日答题已结束")

        if self:GetRightNum(pPlayer)>=self.MAX_QUESTION then
            if MathRandom(10000)<=self.nAnswerAllRightRewardRate then
                pPlayer.SendAward({{"item", self.nMoonCakeBoxId, 1}}, nil, true, Env.LogWay_ZhongQiuJie)
            end
        end
        
        self:AddScore(pPlayer, self.nAnswer10Score, "完成每日灯谜")
        pPlayer.CallClientScript("DaTi:CloseUi")
        return
    end

    self:ConfirmBeginAnswer()
end