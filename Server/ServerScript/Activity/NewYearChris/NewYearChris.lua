-- 元旦&圣诞活动
local tbAct = Activity:GetClass("NewYearChris")

tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

tbAct.nWishGiftLastUpdate = 1
tbAct.nWishGiftHousePlantHelp = 2
tbAct.nWishGiftElite = 3
tbAct.nWishGiftBoss = 4
tbAct.nGiftBoxGainCount = 5

tbAct.nSockTotal = 8	--总获得圣诞袜数
tbAct.nWishGiftTotalIdentify = 9	--总鉴定数
tbAct.nWishGiftScore = 10

tbAct.JOIN_LEVEL = 20	--参与等级
tbAct.tbWishItemIdentify = {	--许愿符鉴定
	{7348, 9000},	--物品id，概率
	{7349, 1000},
}

tbAct.tbWishItemScores = {	--不同等级许愿符对应积分,留言次数
	[7348] = {1, 0, 500},	--物品id，{积分, 留言次数, 银两}
	[7349] = {5, 1, 2000},
}

tbAct.nUnidentWishItemId = 7346	--未鉴定许愿符
tbAct.nLockedWishItemTempId = 7347	--封印的许愿符

tbAct.nRateBase = 10000	--以下渠道获得许愿符的概率分母

tbAct.nWishGiftGainPlantHelp = 3000	--家园植物协助（普通）
tbAct.nWishGiftGainPlantHelpCost = 7000	--家园协助（花费元宝）
tbAct.nWishGiftGainElite = 200	--击杀精英
tbAct.nWishGiftGainBoss = 5000	--首次攻击野外首领

tbAct.nEverydayActivityGainMin = 4	--每日活跃获得许愿符最低档次

--每日获得许愿符上限
tbAct.nWishGiftGainPlantHelpMax = 5	--家园植物协助
tbAct.nWishGiftGainEliteMax = 5	--击杀精英
tbAct.nWishGiftGainBossMax = 5	--野外首领

tbAct.nWishGiftDailyIdentifyLimit = 15	--许愿符每日鉴定上限
tbAct.nGiftBoxGainLimit = 100	--每日获得赠品·佳节礼盒上限

tbAct.nWishNpcTempId = 2825	--许愿少女id
tbAct.nWishNpcDir = 32
tbAct.nWishNpcMapId = 15	--许愿少女map id
tbAct.tbWishNpcPos = {8487, 16593}

tbAct.nWishTreeNpcTempId = 2826	--许愿树id
tbAct.nWishTreeNpcDir = 32
tbAct.nWishTreeNpcMapId = 15
tbAct.tbWishTreeNpcPos = {8485, 16956}

tbAct.nFestivalGiftBoxId = 7350	--赠品·佳节礼盒id
tbAct.nFestivalBoxId = 7351	--佳节礼盒id
tbAct.tbSnowmanGainGiftBoxRates = {	--元旦雪人获得礼盒概率
	[1] = 10000,	--等级，概率
	[2] = 10000,
	[3] = 10000,
	[4] = 10000,
	[5] = 10000,
	[6] = 10000,
	[7] = 10000,
	[8] = 10000,
	[9] = 10000,
	[10] = 10000,
}

tbAct.nSendGiftRewardCoin = 1000	--赠送礼盒获得银两
tbAct.nSendGiftRewardExpMinutes = 30	--赠送礼盒获得经验分钟数

tbAct.nSendGiftPerGainSock = 2	--每获得x件圣诞袜送一个礼盒
tbAct.nSendGiftPerWishScore = 10	--每获得x许愿分，送一个礼盒

tbAct.szMailText = "您在[FFFE0D]许愿排行榜[-]中位列第[FFFE0D]%d[-]名，附件为奖励，请查收！"
tbAct.tbRankAward = {
    {1, {"Item", 7352, 1}},
    {10, {"Item", 7353, 1}},
    {30, {"Item", 7354, 1}},
    {100, {"Item", 7355, 1}},
    {200, {"Item", 7356, 1}},
    {300, {"Item", 7357, 1}},
    {500, {"Item", 7358, 1}},
    {1000, {"Item", 7359, 1}},
    {10000, {"Item", 7360, 1}},
}

tbAct.nMaxWishList = 50	--最多保留的许愿数
tbAct.nWishTextMaxLen = 30	--愿望最长字数

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		self:InitAct()
	elseif szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnAddEverydayAward")
		Activity:RegisterPlayerEvent(self, "Act_House_PlantHelpCure", "OnHousePlantHelpCure")
		Activity:RegisterPlayerEvent(self, "Act_JoinFieldBoss", "OnJoinFieldBoss")
		Activity:RegisterPlayerEvent(self, "Act_CallTeamGouhuoNpc", "OnCallTeamGouhuoNpc")
		Activity:RegisterPlayerEvent(self, "Act_NYSnowmanGetGiftBox", "OnNYSnowmanGetGiftBox")
		Activity:RegisterPlayerEvent(self, "Act_ChristmasGetGift", "OnChristmasGetGift")
		Activity:RegisterPlayerEvent(self, "Act_MakeWish", "OnMakeWish")
		Activity:RegisterPlayerEvent(self, "Act_DialogNewYearChrisNpc", "OnDlgNewYearChrisNpc")
		Activity:RegisterPlayerEvent(self, "Act_NewYearChrisReq", "OnNewYearChrisReq")
		Activity:RegisterPlayerEvent(self, "Act_SendMailGiftSuccess", "OnSendMainGiftSuccess")

		self:OnStartAct()
	elseif szTrigger == "End" then
		self:OnEndAct()
	end
	Log("NewYearChris OnTrigger:", szTrigger)
end

function tbAct:ClearData()
	ScriptData:SaveAtOnce("NewYearChrisWishes", {})
end

function tbAct:InitAct()
	self:ClearData()
    RankBoard:ClearRank("NewYearChris")
end

function tbAct:OnStartAct()
	self:CreateWishNpc()
	self:CreateWishTreeNpc()
end

function tbAct:OnEndAct()
	self:SendRankBoardRewards()
	self:RemoveWishNpc()
	self:RemoveWishTreeNpc()
	self:ClearData()
end

function tbAct:CheckLevel(pPlayer)
	return pPlayer.nLevel>=self.JOIN_LEVEL
end

function tbAct:SendUnidentWishItem(pPlayer, nCount)
	nCount = nCount or 1
	pPlayer.SendAward({{"item", self.nUnidentWishItemId, nCount, self:GetWishItemExpireTime()}}, true, true, Env.LogWay_NewYearChris)

	Dialog:SendBlackBoardMsg(pPlayer, "恭喜你获得了未鉴定的许愿符！")
	local nTeamId = pPlayer.dwTeamID
	if nTeamId and nTeamId>0 then
		local szMsg = string.format("队伍成员%s获得了未鉴定的许愿符！", pPlayer.szName)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, nTeamId)
	end
	Log("NewYearChris:SendUnidentWishItem", pPlayer.dwID, nCount)
end

function tbAct:OnAddEverydayAward(pPlayer, nIdx)
    if not self:CheckLevel(pPlayer) then
        return
    end

    if nIdx<self.nEverydayActivityGainMin then
    	return
    end
    self:SendUnidentWishItem(pPlayer, 1)
    Log("NewYearChris:OnAddEverydayAward", pPlayer.dwID, nIdx)
end

function tbAct:CheckWishGiftRate(nRateMax)
	return MathRandom(self.nRateBase)<=nRateMax
end

function tbAct:CheckWishGiftLimit(pPlayer, nKey, nLimit)
	local nNow = GetTime()
	local nLastUpdate = pPlayer.GetUserValue(self.nWishGiftSaveGrp, self.nWishGiftLastUpdate)
	if Lib:IsDiffDay(4*3600, nNow, nLastUpdate) then
		pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishGiftLastUpdate, nNow)
		pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishGiftHousePlantHelp, 0)
		pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishGiftElite, 0)
		pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishGiftBoss, 0)
		pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nGiftBoxGainCount, 0)
	end

	local nCur = pPlayer.GetUserValue(self.nWishGiftSaveGrp, nKey)
	return nCur<nLimit
end

function tbAct:WishGiftCommonCheck(pPlayer, nRateMax, nKey, nLimit)
	return self:CheckWishGiftRate(nRateMax) and self:CheckWishGiftLimit(pPlayer, nKey, nLimit)
end

function tbAct:AddWishGiftGain(pPlayer, nKey, nAdd)
	local nCur = pPlayer.GetUserValue(self.nWishGiftSaveGrp, nKey)
	pPlayer.SetUserValue(self.nWishGiftSaveGrp, nKey, nCur+nAdd)
end

function tbAct:OnHousePlantHelpCure(pPlayer, nOwnerId, bCost)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local nKey = self.nWishGiftHousePlantHelp

	if not self:WishGiftCommonCheck(pPlayer, bCost and self.nWishGiftGainPlantHelpCost or self.nWishGiftGainPlantHelp, nKey, self.nWishGiftGainPlantHelpMax) then
		return
	end
	self:AddWishGiftGain(pPlayer, nKey, 1)

	self:SendUnidentWishItem(pPlayer, 1)
	Log("NewYearChris:OnHousePlantHelpCure", pPlayer.dwID, nOwnerId, nRand)
end

function tbAct:OnJoinFieldBoss(pPlayer)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local nKey = self.nWishGiftBoss
	if not self:WishGiftCommonCheck(pPlayer, self.nWishGiftGainBoss, nKey, self.nWishGiftGainBossMax) then
		return
	end
	self:AddWishGiftGain(pPlayer, nKey, 1)

	self:SendUnidentWishItem(pPlayer, 1)
	Log("NewYearChris:OnJoinFieldBoss", pPlayer.dwID, nRand)
end

function tbAct:OnCallTeamGouhuoNpc(pPlayer)
	if not self:CheckLevel(pPlayer) then
		return
	end
	
	if not self:CheckWishGiftRate(self.nWishGiftGainElite) then
		return
	end

	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
	if not next(tbMember) then
		tbMember = {pPlayer.dwID}
	end

	local nKey = self.nWishGiftElite
	for _, nId in ipairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(nId)
		if pPlayer and self:CheckWishGiftLimit(pPlayer, nKey, self.nWishGiftGainEliteMax) then
			self:AddWishGiftGain(pPlayer, nKey, 1)
			self:SendUnidentWishItem(pPlayer, 1)
			Log("NewYearChris:OnCallTeamGouhuoNpc", nId)	
		end
	end
end

function tbAct:SendFestivalGiftBox(pPlayer, nCount)
	local nKey = self.nGiftBoxGainCount
	if not self:CheckWishGiftLimit(pPlayer, nKey, self.nGiftBoxGainLimit) then
		return false
	end
	nCount = nCount or 1
	local nCur = pPlayer.GetUserValue(self.nWishGiftSaveGrp, nKey)
	pPlayer.SetUserValue(self.nWishGiftSaveGrp, nKey, nCur+nCount)

	local _, nEndTime = Activity:__GetActTimeInfo(self.szKeyName)
	pPlayer.SendAward({{"item", self.nFestivalGiftBoxId, nCount, nEndTime}}, true, true, Env.LogWay_NewYearChris)
	return true
end

function tbAct:OnNYSnowmanGetGiftBox(pPlayer, nSnowmanLv)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local nRate = self.tbSnowmanGainGiftBoxRates[nSnowmanLv]
	if not nRate then
		Log("[x] NewYearChris:OnNYSnowmanGetGiftBox, no rate", pPlayer.dwID, nSnowmanLv, nRate)
		return
	end

	if MathRandom(self.nRateBase)>nRate then
		return
	end

	local bGiven = self:SendFestivalGiftBox(pPlayer, 1)
	Log("NewYearChris:OnNYSnowmanGetGiftBox", pPlayer.dwID, nSnowmanLv, tostring(bGiven))
end

function tbAct:OnChristmasGetGift(pPlayer, nGain)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local nCur = pPlayer.GetUserValue(self.nWishGiftSaveGrp, self.nSockTotal)
	local nTotal = nCur+nGain
	pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nSockTotal, nTotal)

	for i=nCur+1, nTotal do
		if i%self.nSendGiftPerGainSock==0 then
			local bGiven = self:SendFestivalGiftBox(pPlayer, 1)
			Log("NewYearChris:OnChristmasGetGift", pPlayer.dwID, i, nGain, nCur, nTotal, tostring(bGiven))
		end
	end
end

function tbAct:OnMakeWish(pPlayer, nAdd)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local nTotalScore = self:GetScore(pPlayer)
	for i=nTotalScore-nAdd+1, nTotalScore do
		if i%self.nSendGiftPerWishScore==0 then
			local bGiven = self:SendFestivalGiftBox(pPlayer, 1)
			Log("NewYearChris:OnMakeWish", pPlayer.dwID, nAdd, nTotalScore, tostring(bGiven))
		end
	end
end

function tbAct:GetWishItemExpireTime()
	local nNow = GetTime()
	local tbData = os.date("*t", nNow)
	if tbData.hour<4 then
		tbData.hour = 4
		tbData.min = 0
		tbData.sec = 0
	else
		nNow = nNow+24*3600
		tbData = os.date("*t", nNow)
		tbData.hour = 4
		tbData.min = 0
		tbData.sec = 0
	end
	return os.time(tbData)
end

function tbAct:GetWishGiftMaxIdentifyCount()
	local nNow = GetTime()
	local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szKeyName)
	if nNow<nStartTime or nNow>nEndTime then
		return 0
	end
	local nDiffDays = Lib:GetDiffDays(4*3600, nNow, nStartTime)
	return math.max(nDiffDays+1, 1)*self.nWishGiftDailyIdentifyLimit
end

function tbAct:IdentifyWishItem(pPlayer, nItemId)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local nCur = pPlayer.GetUserValue(self.nWishGiftSaveGrp, self.nWishGiftTotalIdentify)
	if nCur>=self:GetWishGiftMaxIdentifyCount() then
		pPlayer.CenterMsg("您今天已经不能鉴定了！")
		return
	end

	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem or pPlayer.ConsumeItem(pItem, 1, Env.LogWay_NewYearChris)~=1 then
		Log("[x] NewYearChris:IdentifyWishItem, no item", pPlayer.dwID, nItemId)
		return
	end

	if not self.nWishItemIdentifyTotal or self.nWishItemIdentifyTotal<=0 then
		self.nWishItemIdentifyTotal = 0
		for _, tb in ipairs(self.tbWishItemIdentify) do
			self.nWishItemIdentifyTotal = self.nWishItemIdentifyTotal+tb[2]
		end
	end
	local nRand = MathRandom(self.nWishItemIdentifyTotal)
	local nIdentifiedId = 0
	for _, tb in ipairs(self.tbWishItemIdentify) do
		if nRand<=tb[2] then
			nIdentifiedId = tb[1]
			break
		end
		nRand = nRand-tb[2]
	end

	if nIdentifiedId<=0 then
		Log("[x] NewYearChris:IdentifyWishItem, id err", pPlayer.dwID, nIdentifiedId)
		return
	end

	pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishGiftTotalIdentify, nCur+1)

	pPlayer.SendAward({{"item", nIdentifiedId, 1, self:GetWishItemExpireTime()}}, true, true, Env.LogWay_NewYearChris)
	pPlayer.CenterMsg("鉴定成功")
end

function tbAct:LockWishItem(pPlayer, nItemId)
	if not self:CheckLevel(pPlayer) then
		return
	end

	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem or pPlayer.ConsumeItem(pItem, 1, Env.LogWay_NewYearChris)~=1 then
		Log("[x] NewYearChris:LockWishItem, no item", pPlayer.dwID, nItemId)
		return
	end

	pPlayer.SendAward({{"item", self.nLockedWishItemTempId, 1}}, true, true, Env.LogWay_NewYearChris)
	pPlayer.CenterMsg("封印成功")
end

function tbAct:CanWish(pPlayer)
	if not self:CheckLevel(pPlayer) then
		return false, string.format("等级未达到%d级", self.JOIN_LEVEL)
	end

	local tbItems = pPlayer.FindItemInBag("WishItem")
	if not tbItems or not next(tbItems) then
		return false, "没有许愿符"
	end

	return true
end

function tbAct:OnDlgNewYearChrisNpc(pPlayer, pNpc)
	local fnDetail = function (dwID)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if not pPlayer then return end
		pPlayer.CallClientScript("Ui:OpenWindow", "NewInformationPanel", "ShuangJieTongQing")
	end

	local fnOpenRankboard = function(dwID)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if not pPlayer then return end
		pPlayer.CallClientScript("Ui:OpenWindow", "RankBoardPanel", "NewYearChris")
	end

	local fnOpenWishPanel = function(dwID)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if not pPlayer then return end
		pPlayer.CallClientScript("Ui:OpenWindow", "ChristmasWishPanel")
	end

	local tbOptList = {
		{Text = "许愿", Callback = fnOpenWishPanel, Param = {pPlayer.dwID}},
		{Text = "排行榜", Callback = fnOpenRankboard, Param = {pPlayer.dwID}},
		{Text = "了解详情", Callback = fnDetail, Param = {pPlayer.dwID}}
	}

    Dialog:Show({
        Text    = "许个愿吧！",
        OptList = tbOptList,
    }, pPlayer, pNpc)
end

function tbAct:MakeWish(pPlayer)
	local nPlayerId = pPlayer.dwID
	local bOk, szErr = self:CanWish(pPlayer)
	if not bOk then
		pPlayer.CenterMsg(szErr)
		return
	end

	local tbItems = pPlayer.FindItemInBag("WishItem")
	local nCount = 0
	for _, pItem in ipairs(tbItems) do
		nCount = nCount + pItem.nCount
	end
	pPlayer.MsgBox(string.format("你当前拥有各种许愿符共计%d张，将全部用来许愿？", nCount), {
		{"确定", function(nPlayerId)
			self:DoMakeWish(nPlayerId)
		end, nPlayerId}, 
		{"取消"}
	})
end

function tbAct:DoMakeWish(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return
	end

	local bOk, szErr = self:CanWish(pPlayer)
	if not bOk then
		pPlayer.CenterMsg(szErr)
		return
	end

	local tbItems = pPlayer.FindItemInBag("WishItem")
	local nScore = 0
	local nCoin = 0
	local nTotalWishCount = 0
	local nTotalAdvanceWishItem = 0

	for _, pItem in ipairs(tbItems) do
		local tbSetting = self.tbWishItemScores[pItem.dwTemplateId]
		local nItemScore, nWishTimes, nItemCoin = unpack(tbSetting)
		local nCount = pItem.nCount
		if pPlayer.ConsumeItem(pItem, nCount, Env.LogWay_NewYearChris)~=nCount then
			Log("[x] NewYearChris:DoMakeWish, consume failed", nPlayerId, pItem.dwTemplateId)
			pPlayer.Msg("消耗许愿符失败", 1)
			return
		end
		nScore = nScore + nItemScore*nCount
		nCoin = nCoin + nItemCoin*nCount
		if nWishTimes>0 then
			nTotalWishCount = nTotalWishCount + nWishTimes*nCount
			nTotalAdvanceWishItem = nTotalAdvanceWishItem + nCount
		end
	end

	self:AddScore(pPlayer, nScore)
	pPlayer.SendAward({{"Coin", nCoin}}, true, nil, Env.LogWay_NewYearChris)
	if nTotalWishCount>0 then
		self:AddWishesLeft(pPlayer, nTotalWishCount)
		pPlayer.CenterMsg(string.format("消耗%d张稀有许愿符，获得%d次祈福次数", nTotalAdvanceWishItem, nTotalWishCount), true)
	end
	Dialog:SendBlackBoardMsg(pPlayer, string.format("大侠成功许愿，本次许愿获得%d积分，离自己的梦想又近了一步！", nScore))

	Activity:OnPlayerEvent(pPlayer, "Act_MakeWish", nScore)
end

function tbAct:GetWishesLeft(pPlayer)
	return pPlayer.GetUserValue(self.nWishGiftSaveGrp, self.nWishesLeft) or 0
end

function tbAct:AddWishesLeft(pPlayer, nAdd)
	if not nAdd or nAdd==0 then
		return false
	end
	if not self:CheckLevel(pPlayer) then
		return false
	end
	local nLeft = self:GetWishesLeft(pPlayer)+nAdd
	if nLeft<0 then
		return false
	end
	pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishesLeft, nLeft)
	return true
end

function tbAct:GetScore(pPlayer)
	return pPlayer.GetUserValue(self.nWishGiftSaveGrp, self.nWishGiftScore) or 0
end

function tbAct:AddScore(pPlayer, nAdd)
	if not self:CheckLevel(pPlayer) then
        return
    end
	local nScore = self:GetScore(pPlayer)+nAdd
	pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishGiftScore, nScore)
    RankBoard:UpdateRankVal("NewYearChris", pPlayer.dwID, nScore)
    Log("NewYearChris:AddScore", pPlayer.dwID, nAdd, nScore)
end

function tbAct:CreateWishTreeNpc()
	self:RemoveWishTreeNpc()
	local pNpc = KNpc.Add(self.nWishTreeNpcTempId, 1, 0, self.nWishTreeNpcMapId, 
		self.tbWishTreeNpcPos[1], self.tbWishTreeNpcPos[2], 0, self.nWishTreeNpcDir)
	if not pNpc then
		Log("[x] NewYearChris:CreateWishTreeNpc failed")
		return
	end
	self.nWishTreeNpcId = pNpc.nId
end

function tbAct:CreateWishNpc()
	self:RemoveWishNpc()
	local pNpc = KNpc.Add(self.nWishNpcTempId, 1, 0, self.nWishNpcMapId, self.tbWishNpcPos[1], self.tbWishNpcPos[2], 0, self.nWishNpcDir)
	if not pNpc then
		Log("[x] NewYearChris:CreateWishNpc failed")
		return
	end
	self.nWishNpcId = pNpc.nId
end

function tbAct:RemoveWishTreeNpc()
	if not self.nWishTreeNpcId then
		return
	end

	local pNpc =  KNpc.GetById(self.nWishTreeNpcId)
	if pNpc then
		pNpc.Delete()
	end
	self.nWishTreeNpcId = nil
end

function tbAct:RemoveWishNpc()
	if not self.nWishNpcId then
		return
	end

	local pNpc =  KNpc.GetById(self.nWishNpcId)
	if pNpc then
		pNpc.Delete()
	end
	self.nWishNpcId = nil
end

function tbAct:GetRankAward(nRank, nScore)
    local tbAward = {}
    for _, tbInfo in ipairs(self.tbRankAward) do
        if nRank <= tbInfo[1] then
            table.insert(tbAward, tbInfo[2])
            break
        end
    end
    return tbAward
end

function tbAct:SendRankBoardRewards()
    RankBoard:Rank("NewYearChris")

    local tbRankPlayer = RankBoard:GetRankBoardWithLength("NewYearChris", 99999, 1)
    local tbMail = {Title = "许愿排行榜奖励", From = "系统", nLogReazon = Env.LogWay_NewYearChris}
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

        Log("NewYearChris:SendRankBoardRewards:", nRank, tbRankInfo.dwUnitID)
    end
    Log("NewYearChris:SendRankBoardRewards", nSendNum)
end

function tbAct:UpdateWishList(pPlayer, nVersion)
	local tbData = ScriptData:GetValue("NewYearChrisWishes")
	if not tbData.nVersion or nVersion==tbData.nVersion then
		return
	end

	local tbList = {nVersion = tbData.nVersion}
	for _, tbWish in ipairs(tbData) do
		local nPid = tbWish[1]
		local pPlayer = KPlayer.GetRoleStayInfo(nPid)
		if pPlayer then
			table.insert(tbList, {
				pPlayer.szName,	--name
				pPlayer.nFaction,	--career
				pPlayer.nPortrait,	--portrait
				pPlayer.nLevel,	--level
				tbWish[2],	--text
			})
		end
	end
	pPlayer.CallClientScript("Activity.NewYearChris:OnUpdateWishList", tbList)
end

function tbAct:AddWishText(pPlayer, szText)
	if not szText or szText=="" then
		pPlayer.CenterMsg("愿望不能为空")
		return false
	end

	if Lib:Utf8Len(szText)>self.nWishTextMaxLen then
		pPlayer.CenterMsg(string.format("愿望最长%d字", self.nWishTextMaxLen))
		return false
	end

	local nLeft = self:GetWishesLeft(pPlayer)
	if nLeft<=0 then
		pPlayer.CenterMsg("剩余祈福次数不足")
		return false
	end

	local szKey = "NewYearChrisWishes"
	local tbData = ScriptData:GetValue(szKey)
	tbData.nVersion = (tbData.nVersion or 0)+1
	table.insert(tbData, 1, {pPlayer.dwID, szText})
	while #tbData>self.nMaxWishList do
		table.remove(tbData)
	end
	ScriptData:AddModifyFlag(szKey)
	ScriptData:CheckAndSave()
	pPlayer.CenterMsg("许愿成功")

	self:UpdateWishList(pPlayer, -1)

	pPlayer.SetUserValue(self.nWishGiftSaveGrp, self.nWishesLeft, math.max(nLeft-1, 0))
end

local tbAvaliableReqs = {
	IdentifyWishItem = true,
	LockWishItem = true,
	UpdateWishList = true,
	AddWishText = true,
	MakeWish = true,
}

function tbAct:OnNewYearChrisReq(pPlayer, szReqType, ...)
	if not tbAvaliableReqs[szReqType] then
		Log("[!] NewYearChris:OnNewYearChrisReq", pPlayer.dwID, szReqType, ...)
		return
	end

	local fn = tbAct[szReqType]
	if not fn then
		Log("[x] NewYearChris:OnNewYearChrisReq", pPlayer.dwID, szReqType, ...)
		return
	end

	fn(self, pPlayer, ...)
end

function tbAct:OnSendMainGiftSuccess(pPlayer, szType, nCount)
	if szType~="FestivalGiftBox" then
		return
	end

	if not nCount or nCount<1 then
		Log("[x] NewYearChris:OnSendMainGiftSuccess nCount", pPlayer.dwID, szType, tostring(nCount))
		return
	end

	pPlayer.SendAward({{"Coin", self.nSendGiftRewardCoin*nCount}}, true, nil, Env.LogWay_NewYearChris)
	local nAddExp = self.nSendGiftRewardExpMinutes*nCount
	pPlayer.SendAward({{"BasicExp", nAddExp}}, true, false, Env.LogWay_NewYearChris)
	Log("NewYearChris:OnSendMainGiftSuccess", pPlayer.dwID, szType, nAddExp, self.nSendGiftRewardCoin*nCount, nCount)
end