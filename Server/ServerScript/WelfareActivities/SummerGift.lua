function SummerGift:OnLogin(pPlayer)
    self:CheckPlayerData(pPlayer)
end

function SummerGift:OnPerDayUpdate()
    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbAllPlayer) do
        if pPlayer then
            self:CheckPlayerData(pPlayer)
            pPlayer.CallClientScript("SummerGift:CheckRedPoint")
        end
    end
end

function SummerGift:OnJoinAct(pPlayer, szAct, nTimes)
    local nCurDay = self:GetCurDayIndex()
    if nCurDay <= 0 or nCurDay > self.nActAltDay then
        return
    end

    local nActPos, nJoinTimes, tbTodayAct = self:GetActPos(szAct)
    if not nActPos then
        return
    end

    self:CheckPlayerData(pPlayer)
    local nSavePos = self.BEGIN_FLAG + nActPos - 1
    local nCurTimes = pPlayer.GetUserValue(self.GROUP, nSavePos)
    if nCurTimes >= nJoinTimes then
        return
    end

    nTimes = nTimes or 1
    nCurTimes = nCurTimes + nTimes
    pPlayer.SetUserValue(self.GROUP, nSavePos, nCurTimes)
    pPlayer.CallClientScript("SummerGift:OnJoinAct")
    if nCurTimes >= nJoinTimes then
        for i, tbInfo in ipairs(tbTodayAct) do
            local nNeed = tbInfo[2]
            local nTimes = pPlayer.GetUserValue(self.GROUP, self.BEGIN_FLAG + i - 1)
            if nTimes < nNeed then
                return
            end
        end
        local nCompleteFlag = pPlayer.GetUserValue(self.GROUP, self.COMPLETE_FLAG)
        nCompleteFlag = KLib.SetBit(nCompleteFlag, nCurDay, 1)
        pPlayer.SetUserValue(self.GROUP, self.COMPLETE_FLAG, nCompleteFlag)
        if self.tbDayAward[nCurDay] then
            local tbAward = {}
            table.insert(tbAward, self.tbDayAward[nCurDay])
            Mail:SendSystemMail({
                To = pPlayer.dwID,
                Title = "盛夏之周每日奖励",
                Text = "    恭喜侠士达到盛夏之周的每日活动要求，应允之物我已托付邮差捎去，可千万莫要忘记领走。还望侠士继续保持，不仅奖励丰厚，累积天数达到要求，更有一份额外的好处。",
                From = "",
                tbAttach = tbAward,
            })
        end
        Log("SummerGift Complete", pPlayer.dwID, szAct, nJoinTimes, type(self.tbDayAward[nCurDay]))
        for i = 1, 3 do
            self:TryGainGift(pPlayer, i)
        end
    end
end

function SummerGift:CheckPlayerData(pPlayer)
    local nDataDay   = pPlayer.GetUserValue(self.GROUP, self.DATA_DAY)
    local nBeginTime = Lib:ParseDateTime(self.szBeginDay)
    local nBeginDay  = Lib:GetLocalDay(nBeginTime)
    local nToday     = Lib:GetLocalDay(GetTime() - 4*60*60)
    if nDataDay < nToday then
        pPlayer.SetUserValue(self.GROUP, self.DATA_DAY, nToday)
        for i = self.BEGIN_FLAG, self.END_FLAG do
            pPlayer.SetUserValue(self.GROUP, i, 0)
        end
        if nDataDay < nBeginDay then
            pPlayer.SetUserValue(self.GROUP, self.COMPLETE_FLAG, 0)
            pPlayer.SetUserValue(self.GROUP, self.AWARD_FLAG, 0)
        end
    end
end

function SummerGift:TryGainGift(pPlayer, nIdx)
    self:CheckPlayerData(pPlayer)

    local bRet, szMsg = self:CheckCanGainGift(pPlayer, nIdx)
    if not bRet then
        return
    end

    local nGainFlag = pPlayer.GetUserValue(self.GROUP, self.AWARD_FLAG)
    nGainFlag = KLib.SetBit(nGainFlag, nIdx, 1)
    pPlayer.SetUserValue(self.GROUP, self.AWARD_FLAG, nGainFlag)

    local tbInfo = self.tbAward[nIdx]
    Mail:SendSystemMail({
                To = pPlayer.dwID,
                Title = "盛夏之周累积奖励",
                Text = "    恭喜侠士达到盛夏之周的累积活动要求，应允之物我已托付邮差捎去，可千万莫要忘记领走。还望侠士继续保持，报酬自然是会越来越丰厚。武林之未来，还得指望诸位侠士同心协力。",
                From = "",
                tbAttach = tbInfo[2],
            })
    Log("SummerGift GainGift", pPlayer.dwID, nGainFlag, nIdx)
end