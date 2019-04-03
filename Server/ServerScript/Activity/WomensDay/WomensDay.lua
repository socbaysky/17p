Require("CommonScript/EnvDef.lua")
local tbAct = Activity:GetClass("WomensDay")

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }

tbAct.GROUP            = 68
tbAct.VERSION          = 21
tbAct.JOINACT_TIME     = 22
tbAct.tbDayAct         = { --nTimes：活动对应的需参加次数，nSaveKey：不可修改
    [Env.LogWay_AdventureFuben] = {nTimes = 2, nSaveKey = 23},
    [Env.LogWay_PunishTask]     = {nTimes = 5, nSaveKey = 24},
    [Env.LogWay_TeamFuben]      = {nTimes = 2, nSaveKey = 25},
    [Env.LogWay_RandomFuben]    = {nTimes = 2, nSaveKey = 26},
}
tbAct.GIFT_DATA_TIME   = 27
tbAct.SENDGIFT_TIMES   = 28
tbAct.HAVE_AWARD_TIMES = 9 --每天有多少次送礼能够获得奖励

tbAct.JOIN_LEVEL       = 20
tbAct.tbJoinActAward   = {{"Contrib", 999}} --参加活动的队伍中有女性时的奖励

tbAct.tbGiftAward      = {{"Item", 3914, 1}} --送礼时拿到的奖励
tbAct.szGiftMsg        = "[FFFE0D]%s[-]微一抱拳，拿出准备已久的99朵玫瑰，带着笑意对[FFFE0D]%s[-]说道：节日快乐！女侠！英姿飒爽的女侠一反常态，那一抹羞涩的笑意，当可倾城！"
tbAct.nImitityMul      = 9

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        local bOpen
        if self.tbParam[1] == "1" or self.tbParam[1] == "true" then
            Activity:RegisterGlobalEvent(self, "Act_OnJoinTeamActivity", "OnJoinAct")
            Activity:RegisterGlobalEvent(self, "Act_OnAddImitity", "OnAddImitity")
            bOpen = true
        end
        if self.tbParam[2] == "1" or self.tbParam[2] == "true" then
            Gift:OnWomensDayOpen(self)
            bOpen = true
        end
        if not bOpen then
            Log("WomensDay Start Err, No Activity Start")
        end
    elseif szTrigger == "End" then
        Gift:OnWomensDayClose()
    end
end

function tbAct:OnJoinAct(tbMember, nAct)
    local bHaveGirl = false
    local tbTeamMember = {}
    for _, nPlayerId in pairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId)
        if pMember then
            bHaveGirl = bHaveGirl or (pMember.nSex == Gift.Sex.Girl)
            table.insert(tbTeamMember, pMember)
        end
    end
    if not bHaveGirl then
        return
    end

    local tbJoinMember = {}
    local nLen = #tbTeamMember
    for i = 1, nLen do
        local pMember = tbTeamMember[i]
        for j = i + 1, nLen do
            local pFriend = tbTeamMember[j]
            if FriendShip:IsFriend(pMember.dwID, pFriend.dwID) and (pMember.nSex ~= Gift.Sex.Boy or pFriend.nSex ~= Gift.Sex.Boy) then
                tbJoinMember[pMember.dwID] = true
                tbJoinMember[pFriend.dwID] = true
            end
        end
    end

    for nPlayerId, _ in pairs(tbJoinMember) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId)
        if pMember and pMember.nLevel >= self.JOIN_LEVEL then
            self:SendCompleteAward(pMember, nAct)
        end
    end
end

function tbAct:SendCompleteAward(pMember, nAct)
    local tbActInfo = self.tbDayAct[nAct]
    if not tbActInfo then
        return
    end
    local bReset = self:CheckPlayerData(pMember)
    if not bReset and Lib:IsDiffDay(4*3600, pMember.GetUserValue(self.GROUP, self.JOINACT_TIME)) then
        for _, tbInfo in pairs(self.tbDayAct) do
            pMember.SetUserValue(self.GROUP, tbInfo.nSaveKey, 0)
        end
    end
    pMember.SetUserValue(self.GROUP, self.JOINACT_TIME, GetTime())
    local nJoinTimes = pMember.GetUserValue(self.GROUP, tbActInfo.nSaveKey) + 1
    if nJoinTimes > tbActInfo.nTimes then
        return
    end
    pMember.SetUserValue(self.GROUP, tbActInfo.nSaveKey, nJoinTimes)
    Log("WomensDay SendCompleteAward AddJoinTimes", nJoinTimes, pMember.dwID)
    if nJoinTimes ~= tbActInfo.nTimes then
        return
    end
    for _, tbInfo in pairs(self.tbDayAct) do
        if pMember.GetUserValue(self.GROUP, tbInfo.nSaveKey) < tbInfo.nTimes then
            return
        end
    end
    local szMsg = "    侠士已完成组队秘境、凌绝峰、山贼秘窟、惩恶任务四项任务全部次数，成功达成女侠闯天关活动的要求，请领取奖励！"
    local tbMail = {Title = "女侠闯天关奖励", tbAttach = self.tbJoinActAward, Text = szMsg, nLogReazon = Env.LogWay_WomensDay, To = pMember.dwID}
    Mail:SendSystemMail(tbMail)
    Log("WomensDay SendCompleteAward AddCompleteDays", pMember.dwID, nAct)
end

function tbAct:OnAddImitity(pRole1, pRole2, nImitity, nLog)
    if not self.tbDayAct[nLog] then
        return
    end

    if pRole1.nSex == Gift.Sex.Boy and pRole2.nSex == Gift.Sex.Boy then
        return
    end

    if pRole1.nLevel < self.JOIN_LEVEL or pRole2.nLevel < self.JOIN_LEVEL then
        return
    end

    nImitity = nImitity * self.nImitityMul
    local nRole1 = pRole1.dwID
    local nRole2 = pRole2.dwID
    Timer:Register(5, function ()
        FriendShip:AddImitity(nRole1, nRole2, nImitity, Env.LogWay_WomensDay)
        Log("WomensDay OnAddImitity", nRole1, nRole2, nImitity, nLog)
    end)
end

function tbAct:OnSendGift(pPlayer, pAcc, _, nItemTID, nCount)
    if nItemTID ~= Gift.nRoseBoxId or pPlayer.nLevel < self.JOIN_LEVEL then
        return
    end

    local bReset = self:CheckPlayerData(pPlayer)
    if bReset or Lib:GetLocalDay(pPlayer.GetUserValue(self.GROUP, self.GIFT_DATA_TIME)) ~= Lib:GetLocalDay() then
        pPlayer.SetUserValue(self.GROUP, self.GIFT_DATA_TIME, GetTime())
        pPlayer.SetUserValue(self.GROUP, self.SENDGIFT_TIMES, 0)
    end
    local nHadSend = pPlayer.GetUserValue(self.GROUP, self.SENDGIFT_TIMES)
    if nHadSend >= self.HAVE_AWARD_TIMES then
        return
    end
    local nAwardCount = (nHadSend + nCount) > self.HAVE_AWARD_TIMES and (self.HAVE_AWARD_TIMES - nHadSend) or nCount
    pPlayer.SetUserValue(self.GROUP, self.SENDGIFT_TIMES, nHadSend + nAwardCount)
    local tbAward = {}
    for _, tbInfo in ipairs(self.tbGiftAward) do
        local tbTemp = {unpack(tbInfo)}
        local nParLen = #tbTemp
        tbTemp[nParLen] = tbTemp[nParLen] * nAwardCount        
        table.insert(tbAward, tbTemp)
    end
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_WomensDay)
    local szGiftMsg = string.format(self.szGiftMsg, pPlayer.szName, pAcc.szName)
    Log("WomensDay OnSendGift", pPlayer.dwID, pAcc.dwID, nSaveKey, nAwardCount, nCount)
    return szGiftMsg
end

function tbAct:CheckPlayerData(pPlayer)
    local nVersion = self:GetOpenTimeInfo()
    if pPlayer.GetUserValue(self.GROUP, self.VERSION) == nVersion then
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.VERSION, nVersion)
    for i = self.VERSION + 1, self.SENDGIFT_TIMES do
        pPlayer.SetUserValue(self.GROUP, i, 0)
    end
    Log("WomensDay ResetData", pPlayer.dwID)
    return true
end