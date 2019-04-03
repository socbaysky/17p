local tbAct     = Activity:GetClass("ContinualRechargeAct")
tbAct.tbTimerTrigger = 
{ 
    [1] = {szType = "Day", Time = "0:00" , Trigger = "RefreshOnlinePlayerData"},
}
tbAct.tbTrigger = {Init = {}, Start = {{"StartTimerTrigger", 1}}, End = {}, RefreshOnlinePlayerData = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        self:LoadAward()
        self.nRechargeGold = tonumber(self.tbParam[2])
        Activity:RegisterPlayerEvent(self, "OnRecharge", "OnRecharge")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "CheckPlayerData")
        self:RefreshOnlinePlayerData()
    elseif szTrigger == "RefreshOnlinePlayerData" then
        self:RefreshOnlinePlayerData()
    end
end

function tbAct:LoadAward()
    local tbFile = Lib:LoadTabFile(self.tbParam[1], {nParam = 1})
    self.tbEverydayAward = {}
    self.tbSpecialAward = {}
    for _, tbInfo in ipairs(tbFile) do
        if tbInfo.szType == "everyday" then
            self.tbEverydayAward[tbInfo.nParam] = Lib:GetAwardFromString(tbInfo.szAward)
        elseif tbInfo.szType == "specialday" then
            local tbAward = Lib:GetAwardFromString(tbInfo.szAward)
            self.tbSpecialAward[tbInfo.nParam] = {nContinualDay = tbInfo.nParam, tbAward = tbAward}
        end
    end
end

function tbAct:OnRecharge(pPlayer, nGoldRMB, nCardRMB, nChargeGold)
    self:CheckPlayerData(pPlayer)
    local nTodayRecharge = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE)
    nTodayRecharge = nTodayRecharge + nChargeGold
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE, nTodayRecharge)
    if nTodayRecharge < self.nRechargeGold then
        return
    end

    if Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_FLAG) > 0 then
        return
    end

    local nContinual = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DAYS) + 1
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DAYS, nContinual)
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_FLAG, 1)
    local tbAward = self:GetCurDayAward()
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_ContinualRechargeAct)
    if self.tbSpecialAward[nContinual] then
        pPlayer.SendAward(self.tbSpecialAward[nContinual].tbAward, true, false, Env.LogWay_ContinualRechargeAct)
    end
end

function tbAct:RefreshOnlinePlayerData()
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        self:CheckPlayerData(pPlayer)
    end
end

function tbAct:CheckPlayerData(pPlayer)
    local nStartTime   = self:GetOpenTimeInfo()
    local bNotThisSess = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_SESSION_TIME) ~= nStartTime
    local nDataDay     = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DATA_DAY)
    local nRecharge    = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE)
    local nLocalDay    = Lib:GetLocalDay()
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DATA_DAY, nLocalDay)
    if nLocalDay - nDataDay >= 1 or bNotThisSess then
        Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_FLAG, 0)
        Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE, 0)
        if bNotThisSess then
            Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_SESSION_TIME, nStartTime)
            Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DAYS, 0)
        end
    end
end

function tbAct:GetCurDayAward()
    local nLocalDay = Lib:GetLocalDay()
    local nBeginDay = Lib:GetLocalDay(Activity:GetActBeginTime(self.szKeyName))
    return self.tbEverydayAward[nLocalDay - nBeginDay + 1] or self.tbEverydayAward[1]
end

function tbAct:GetUiData()
    if not self.tbUiData then
        local tbData = {}
        tbData.nShowLevel = 1
        tbData.szTitle = "连续储值活动"
        tbData.nBottomAnchor = 0

        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local tbTime1 = os.date("*t", nStartTime)
        local tbTime2 = os.date("*t", nEndTime)
        tbData.szContent = string.format([[活动时间：[c8ff00]%d年%d月%d日0点-%d月%d日24点[-]
活动内容：
  每日[FFFF00]储值达到指定额度（[c8ff00]有且仅有储值额度直接兑换的元宝计算入内，系统赠送的元宝不计入累计储值金额[-]）[-]，均将获得一份奖励，每日仅限获得一次，[FFFF00]凌晨0点[-]结算，连续储值[FFFF00]3天/7天[-]将获得一份额外奖励，活动期间若中途某一天未储值，累计天数也将为您保留。
        ]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day)

        tbData.szBtnText = "前去储值"
        tbData.szBtnTrap = "[url=openwnd:test, CommonShop, 'Recharge', 'Recharge']";

        tbData.tbSubInfo = {}
        local tbDesc = self:GetAwardDesc(self.tbEverydayAward[1])
        table.insert(tbData.tbSubInfo, {szType = "Item3", szSub = "ContinualRecharge_Day", nParam = self.nRechargeGold, tbItemList = self.tbEverydayAward[1], tbItemName = tbDesc, tbBgSprite = {"BtnListFifthSpecial", "NewBTn"}})

        for _, tbInfo in pairs(self.tbSpecialAward) do
            local tbDesc = self:GetAwardDesc(tbInfo.tbAward)
            table.insert(tbData.tbSubInfo, {szType = "Item3", szSub = "ContinualRecharge", nParam = tbInfo.nContinualDay, tbItemList = tbInfo.tbAward, tbItemName = tbDesc})
        end
        self.tbUiData = tbData
    end
    return self.tbUiData
end

function tbAct:GetAwardDesc(tbAward)
    local tbDesc = {}
    for _, tbInfo in ipairs(tbAward) do
        local nAwardType = Player.AwardType[tbInfo[1]]
        if nAwardType == Player.award_type_item then
            local szName = KItem.GetItemShowInfo(tbInfo[2])
            table.insert(tbDesc, szName)
        elseif nAwardType == Player.award_type_money then
            local szName = Shop:GetMoneyName(tbInfo[1])
            table.insert(tbDesc, szName)
        else
            table.insert(tbDesc, "其他奖励")
        end
    end
    return tbDesc
end