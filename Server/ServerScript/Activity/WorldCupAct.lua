local tbAct = Activity:GetClass("WorldCupAct")
tbAct.tbTimerTrigger = {
    [1] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify" },
    [2] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify" },
    [3] = {szType = "Day", Time = "20:00" , Trigger = "SendWorldNotify" },
}
tbAct.tbTrigger = {
	Init={},
	Start={
        {"StartTimerTrigger", 1},
        {"StartTimerTrigger", 2},
        {"StartTimerTrigger", 3},
    },
	End={},
    SendWorldNotify = { {"WorldMsg", "各位少侠，世界盃活动开始了，大家可通过查看“最新消息”了解活动内容！", 20} },
    OpenAct = {},
    CloseAct = {},
}

function tbAct:OnTrigger(szTrigger)
    Log("WorldCupAct:OnTrigger", szTrigger)
    if szTrigger=="Init" then
        RankBoard:ClearRank(self.szMainKey)
    elseif szTrigger=="Start" then
        local _, nEndTime = self:GetOpenTimeInfo()
        self:RegisterDataInPlayer(nEndTime)

        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin")
        Activity:RegisterPlayerEvent(self, "Act_EverydayTargetGainAward", "OnEverydayTargetGainAward")
        Activity:RegisterPlayerEvent(self, "Act_DailyGift", "OnBuyDailyGift") 
        Activity:RegisterPlayerEvent(self, "Act_WorldCupReq", "OnClientReq")
    elseif szTrigger=="End" then
        self:SendRankReward()
	end
end

function tbAct:GainUnidentified(pPlayer, nCount)
    if not nCount or nCount<=0 then
        return
    end
    local _, nEndTime = self:GetOpenTimeInfo()
    self:GainItem(pPlayer, self.nMedalItemId, nCount, nEndTime)
end

function tbAct:GainItem(pPlayer, nItemId, nCount, nExpire)
    if not nCount or nCount<=0 then
        return
    end
    local tbAward = {{"item", nItemId, nCount}}
    tbAward = self:FormatAward(tbAward, nExpire)
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_WorldCupAct)
    Log("WorldCupAct:GainItem", pPlayer.dwID, nCount)
end

function tbAct:OnLogin(pPlayer)
    self:UpdateRank(pPlayer)
end

function tbAct:GetRankAward(nRank, nScore)
    local tbAward = {}
    if nScore<=0 then
        return tbAward
    end
    for _, tbInfo in ipairs(self.tbRankAward) do
        if nRank <= tbInfo[1] then
            for i=2, #tbInfo do
                table.insert(tbAward, tbInfo[i])
            end
            break
        end
    end
    return tbAward
end

function tbAct:SendRankReward()
    RankBoard:Rank(self.szMainKey)

    local tbRankPlayer = RankBoard:GetRankBoardWithLength(self.szMainKey, 99999, 1)
    local tbMail = {Title = "世界盃", From = "系统", nLogReazon = Env.LogWay_WorldCupAct}
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
        Log("WorldCupAct:SendRankReward, to player", tbRankInfo.dwUnitID, nRank, tbRankInfo.szValue)
    end
    Log("WorldCupAct:SendRankReward", nSendNum)
end

tbAct.tbValidReqs = {
    UpdateData = true,
    CollectMedal = true,
    GainReward = true,
    Transfer = true,
}
function tbAct:OnClientReq(pPlayer, szType, ...)
    if not self.tbValidReqs[szType] then
        return
    end

    local fn = self["OnReq_"..szType]
    if not fn then
        return
    end

    local bOk, szErr = fn(self, pPlayer, ...)
    if not bOk then
        if szErr and szErr~="" then
            pPlayer.CenterMsg(szErr)
            return
        end
    end
end

function tbAct:OnReq_UpdateData(pPlayer)
    local tbData = {}
    local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    tbData.tbItems = tbSaveData.tbItems or {}
    tbData.bGainReward = tbSaveData.bGainReward
    tbData.nPosition = 0
    tbData.nScore = self:GetTotalScore(tbSaveData)

    local pRank = KRank.GetRankBoard(self.szMainKey)
    if pRank then
        local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
        if tbInfo then
            tbData.nPosition = tbInfo.nPosition
            tbData.nScore = tonumber(tbInfo.szValue)
        end
    end
    pPlayer.CallClientScript("Activity.WorldCupAct:OnUpdateData", tbData)
end

function tbAct:OnReq_GainReward(pPlayer)
    local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    if tbSaveData.bGainReward then
        return false, "你已经领过了"
    end

    if Lib:CountTB(tbSaveData.tbItems)<Lib:CountTB(self.tbShowItems) then
        return false, "尚未集齐所有徽章"
    end

    tbSaveData.bGainReward = true
    pPlayer.SendAward(self.tbCollect32Rewards, true, true, Env.LogWay_WorldCupAct)
    self:SaveDataToPlayer(pPlayer, tbSaveData)
    self:OnReq_UpdateData(pPlayer)
    return true
end

function tbAct:OnReq_CollectMedal(pPlayer, nItemId)
    local pItem = KItem.GetItemObj(nItemId)
    if not pItem then
        return false, "道具不存在"
    end
    local szName = pItem.szName
    local nTemplateId = pItem.dwTemplateId
    if pPlayer.ConsumeItem(pItem, 1, Env.LogWay_WorldCupAct)~=1 then
        Log("[x] WorldCupAct:OnReq_CollectMedal", nTemplateId, nItemId)
        return false, "消耗道具失败"
    end

    local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    tbSaveData.tbItems = tbSaveData.tbItems or {}
    tbSaveData.tbItems[nTemplateId] = (tbSaveData.tbItems[nTemplateId] or 0)+1
    self:SaveDataToPlayer(pPlayer, tbSaveData)
    self:UpdateRank(pPlayer)

    if pPlayer.GetItemCountInAllPos(self.nBookId)<=0 then
        local _, nEndTime = self:GetOpenTimeInfo()
        pPlayer.SendAward({{"item", self.nBookId, 1, nEndTime}}, true, true, Env.LogWay_WorldCupAct)
    end
    pPlayer.CenterMsg(string.format("成功收集：%s", szName))

    if not tbSaveData.bGainReward and Lib:CountTB(tbSaveData.tbItems)>=32 then
        local szMsg = "恭喜大侠集齐徽章！快去收集册打开宝箱吧！"
        pPlayer.CenterMsg(szMsg, true)
    end

    self:OnReq_UpdateData(pPlayer)
    Log("WorldCupAct:OnReq_CollectMedal", pPlayer.dwID, nTemplateId, nItemId)
    return true
end

function tbAct:OnReq_Transfer(pPlayer, bNormal, nFromItemId, nToItemId)
    bNormal = not not bNormal

    if not nFromItemId or nFromItemId <= 0 then
        return false, "请选择要转换的徽章"
    end

    if nFromItemId == nToItemId then
        return false, "待转换徽章不得与目标徽章相同！"
    end

    local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {tbItems = {}}
    local nCount = tbSaveData.tbItems[nFromItemId] or 0
    if nCount <= 0 then
        return false, "尚未获得所选徽章"
    end

    if bNormal then
        local nToItemId = 0
        while true do
            local nIdx = MathRandom(#self.tbShowItems)
            nToItemId = self.tbShowItems[nIdx]
            if nToItemId ~= nFromItemId then
                break
            end
        end
        return self:Transfer(pPlayer, bNormal, tbSaveData, nFromItemId, nToItemId)
    end

    if not nToItemId or nToItemId <= 0 then
        return false, "请选择要转换的目标徽章"
    end
    local nCount = tbSaveData.tbItems[nToItemId] or 0
    if nCount <= 0 then
        return false, "尚未获得所选目标徽章"
    end
    return self:Transfer(pPlayer, bNormal, tbSaveData, nFromItemId, nToItemId)
end

function tbAct:Transfer(pPlayer, bNormal, tbSaveData, nFromItemId, nToItemId)
    local nItemId = bNormal and self.nTransferItemNormal or self.nTransferItemAdvance
    if pPlayer.ConsumeItemInBag(nItemId, 1, Env.LogWay_WorldCupAct) ~= 1 then
        Log("[x] tbAct:OnReq_Transfer, ConsumeItemInBag failed", nItemId, pPlayer.dwID)
        return false, "消耗道具失败"
    end

    tbSaveData.tbItems[nFromItemId] = tbSaveData.tbItems[nFromItemId] - 1
    if tbSaveData.tbItems[nFromItemId] <= 0 then
        tbSaveData.tbItems[nFromItemId] = nil
    end
    self:SaveDataToPlayer(pPlayer, tbSaveData)
    self:UpdateRank(pPlayer)
    self:GainItem(pPlayer, nToItemId, 1, self.nTransferExpire)
    local szName = KItem.GetItemShowInfo(nToItemId, pPlayer.nFaction, pPlayer.nSex)
    me.CallClientScript("Ui:CloseWindow", "WorldCupTransferPanel")
    Log("WorldCupAct:Transfer", pPlayer.dwID, tostring(bNormal), nFromItemId, nToItemId)
    return true
end

function tbAct:GetTotalScore(tbSaveData)
    local nTotalScore = 0
    for nItemId, nCount in pairs(tbSaveData.tbItems or {}) do
        local nScore = self.tbScoreCfg[nItemId] or 1
        nTotalScore = nTotalScore+nScore*nCount
    end
    return nTotalScore
end

function tbAct:UpdateRank(pPlayer)
    if not self:CheckPlayer(pPlayer) then
        return
    end
    
    local pRank = KRank.GetRankBoard(self.szMainKey)
    if not pRank then
        return
    end

    local tbSaveData = self:GetDataFromPlayer(pPlayer.dwID) or {}
    local nTotalScore = self:GetTotalScore(tbSaveData)
    if nTotalScore<=0 then
        return
    end
    local tbInfo = pRank.GetRankInfoByID(pPlayer.dwID)
    if tbInfo and nTotalScore==tonumber(tbInfo.szValue) then
        return
    end
    RankBoard:UpdateRankVal(self.szMainKey, pPlayer.dwID, nTotalScore)
end

-- 1,3,6元礼包nGroupIndex分别对应1,2,3 nBuyCount购买数量
function tbAct:OnBuyDailyGift(pPlayer, nGroupIndex, nBuyCount)
    if not self:CheckPlayer(pPlayer) then
        return
    end
    local nCount = self.tbDailyGiftAward[nGroupIndex]
    if not nCount or nCount <= 0 then
        return
    end

    self.tbLastTakeTime = self.tbLastTakeTime or {}
    self.tbLastTakeTime[pPlayer.dwID] = self.tbLastTakeTime[pPlayer.dwID] or {}
    local nLastTime = self.tbLastTakeTime[pPlayer.dwID][nGroupIndex] or 0
    local nNow = GetTime()
    if not Lib:IsDiffDay(4 * 3600, nLastTime, nNow) then
        Log("WorldCupAct:OnBuyDailyGift, repurchase", pPlayer.dwID, nGroupIndex, nBuyCount, nLastTime, nNow)
        return
    end
    self.tbLastTakeTime[pPlayer.dwID][nGroupIndex] = nNow

    self:GainUnidentified(pPlayer, nCount*nBuyCount)
    Log("WorldCupAct:OnBuyDailyGift", pPlayer.dwID, nGroupIndex, nCount, nBuyCount)
end

function tbAct:OnEverydayTargetGainAward(pPlayer, nAwardIdx)
    if not self:CheckPlayer(pPlayer) then
        return
    end
    local nCount = self.tbActiveAward[nAwardIdx]
    if not nCount or nCount<=0 then
        return
    end
    self:GainUnidentified(pPlayer, nCount)
    Log("WorldCupAct:OnEverydayTargetGainAward", pPlayer.dwID, nAwardIdx, nCount)
end

function tbAct:FormatAward(tbAward, nEndTime)
    if not MODULE_GAMESERVER or not Activity:__IsActInProcessByType("WorldCupAct") or not nEndTime then
        return tbAward
    end
    local tbFormatAward = Lib:CopyTB(tbAward or {})
    for _, v in ipairs(tbFormatAward) do
        if v[1] == "item" or v[1] == "Item" then
            v[4] = nEndTime
        end
    end
    return tbFormatAward
end

function tbAct:GetUiData()
    if not self.tbUiData then
        local tbData = {}
        tbData.nShowLevel = 20
        tbData.szTitle = "世界盃活动"
        tbData.nBottomAnchor = 0

        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local tbTime1 = os.date("*t", nStartTime)
        local tbTime2 = os.date("*t", nEndTime)
        tbData.szContent = string.format([[活动时间：[c8ff00]%s年%s月%s日%d点-%s年%s月%s日%s点[-]
2018世界盃开始了！
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime1.hour, tbTime2.year, tbTime2.month, tbTime2.day, tbTime2.hour)
        tbData.tbSubInfo = {}
        table.insert(tbData.tbSubInfo, {szType = "Item2", szInfo = [[[FFFE0D]获取徽章 鉴定收集[-]
活动期间大侠活跃度达到[FFFE0D]60[-]、[FFFE0D]80[-]、[FFFE0D]100[-]，打开对应的[FFFE0D]活跃宝箱[-]，或者领取[FFFE0D]每日礼包[-]都会获得[ff578c][url=openwnd:未鉴定的徽章, ItemTips, "Item", nil, 8217][-]，大侠可以消耗[FFFE0D]60贡献[-]对其鉴定，可以鉴定出本届世界盃32支参赛队伍中随机一支队伍的徽章，使用该徽章可以将其放入[e6d012][url=openwnd:2018世界盃徽章收集册, ItemTips, "Item", nil, 8216][-]中。
[ff578c]注[-]：每天大侠最多从[FFFE0D]每日礼包[-]途径获得[FFFE0D]3[-]个[ff578c][url=openwnd:未鉴定的徽章, ItemTips, "Item", nil, 8217][-]。
[FFFE0D]收集满册 开启宝箱[-]
当大侠收集满收集册中所有不同国家队伍的徽章後，可以打开收集册中的宝箱，获得6个[aa62fc][url=openwnd:紫水晶, ItemTips, "Item", nil, 224][-]！
[FFFE0D]价值排行 排名领奖[-]
大侠收集到的不同徽章起始价值都是[FFFE0D]1[-]，随着世界盃比赛的进行，不同的徽章价值也会随之改变。小组出线价值变为[FFFE0D]2[-]，闯入八强价值变为[FFFE0D]4[-]，跻身四强价值变为[FFFE0D]8[-]，力夺季军价值变为[FFFE0D]12[-]，勇取亚军价值变为[FFFE0D]16[-]，捧起大力神杯价值变为[FFFE0D]32[-]。
最终活动结束时（[ff578c]2018年7月16日23:59[-]）按照大侠们收集到的所有徽章的价值排行发放奖励，奖励如下：
第1名----------------------------------100个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第2至第5名-----------------------------60个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第6至第10名----------------------------40个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第11至第20名---------------------------30个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第21至第50名---------------------------20个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第51至第200名--------------------------10个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
第201至第500名-------------------------5个[ff8f06][url=openwnd:和氏璧, ItemTips, "Item", nil, 2804][-]
此外第1名还会获得[ff8f06][url=openwnd:称号·世界足球先生, ItemTips, "Item", nil, 8274][-]、[e6d012][url=openwnd:<血瞳·啸霜>坐骑时装, ItemTips, "Item", nil, 8254][-]
第2至第5名会获得[ff578c][url=openwnd:称号·懂球帝, ItemTips, "Item", nil, 8275][-]、[e6d012][url=openwnd:<血瞳·荒尘>坐骑时装, ItemTips, "Item", nil, 8255][-]
]]})

        self.tbUiData = tbData
    end
    return self.tbUiData
end