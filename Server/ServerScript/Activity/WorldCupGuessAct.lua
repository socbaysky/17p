local tbAct = Activity:GetClass("WorldCupGuessAct")
tbAct.tbTimerTrigger = {
	[1] = {szType = "Day", Time = "9:00" , Trigger = "SendWorldNotify" },
	[2] = {szType = "Day", Time = "12:00" , Trigger = "SendWorldNotify" },
	[3] = {szType = "Day", Time = "19:00" , Trigger = "SendWorldNotify" },
}
tbAct.tbTrigger = {
	Init={},
	Start={
		{"StartTimerTrigger", 1},
		{"StartTimerTrigger", 2},
		{"StartTimerTrigger", 3},
	},
	End={},
	SendWorldNotify = { {"WorldMsg", "各位少侠，大力神杯竞猜活动开始了，大家可通过查看“最新消息”了解活动内容！", 20} },
	OpenAct = {},
	CloseAct = {},
}

function tbAct:OnTrigger(szTrigger)
	Log("WorldCupGuessAct:OnTrigger", szTrigger)
	if szTrigger=="Init" then
		ScriptData:SaveAtOnce("WorldCupGuessAct", {})
	elseif szTrigger=="Start" then
		Activity:RegisterPlayerEvent(self, "Act_WorldCupReq", "OnClientReq")
	elseif szTrigger=="End" then
	end
end

tbAct.tbValidReqs = {
	UpdateData = true,
	Guess = true,
}
function tbAct:OnClientReq(pPlayer, szType, ...)
	if not self.tbValidReqs[szType] then
		return
	end

	local fn = self["OnReq_"..szType]
	if not fn then
		return
	end

	local bOk, szErr = self:CheckPlayer(pPlayer)
	if not bOk then
		if szErr and szErr~="" then
			pPlayer.CenterMsg(szErr)
		end
		return
	end

	local bOk, szErr = fn(self, pPlayer, ...)
	if not bOk then
		if szErr and szErr~="" then
			pPlayer.CenterMsg(szErr)
		end
		return
	end
end

function tbAct:OnReq_UpdateData(pPlayer)
	local tbScriptData = ScriptData:GetValue("WorldCupGuessAct")
	local tbSaveData = tbScriptData[pPlayer.dwID] or {{}, {}}

	local tbData = Lib:CopyTB(tbSaveData)
	tbData[3] = {}
	if tbScriptData.nRewarded1 and tbScriptData.nRewarded1 > 0 then
		tbData[3][1] = tbData[1][1] == self.tbTop1[1]
	end
	if tbScriptData.nRewarded4 and tbScriptData.nRewarded4 > 0 then
		for i=1, 4 do
			tbData[3][1+i] = Lib:IsInArray(self.tbTop4, tbData[1][1+i])
		end
	end
	pPlayer.CallClientScript("Activity.WorldCupGuessAct:OnUpdateData", tbData)
	return true
end

--[nPlayerId] = {{nTemplate1, ...}, {nTimeIdx1, ...}}
function tbAct:OnReq_Guess(pPlayer, nIdx, nTemplateId)
	if nIdx<1 or nIdx>5 then
		Log("[x] WorldCupGuessAct:OnReq_Guess", pPlayer.dwID, nIdx, nTemplateId)
		return false
	end

	local tbData = ScriptData:GetValue("WorldCupGuessAct")
	local tbSaveData = tbData[pPlayer.dwID] or {{}, {}}
	if tbSaveData[1][nIdx] then
		return false, "此位置已经竞猜过了"
	end
	
	if nIdx > 1 then
		for i=2, 5 do
			if tbSaveData[1][i]==nTemplateId then
				return false, "此队伍已经竞猜过，请勿重复竞猜！"
			end
		end
	end

	local tbTimeCfg = nIdx > 1 and self.tbTop4Cfg or self.tbTop1Cfg
	local nTimeIdx = self:GetTimeIdx(tbTimeCfg)
	if nTimeIdx <= 0 then
		return false, "当前阶段不可竞猜"
	end

	local nCost = self.tbGuessCost[nIdx]
	if not nCost then
		Log("[x] WorldCupGuessAct:OnReq_Guess, no cost cfg", pPlayer.dwID, nIdx, nTemplate1)
		return false
	end
	local nHave = pPlayer.GetMoney("Gold") or 0
	if nHave < nCost then
		return false, "元宝不足"
	end
	pPlayer.CostGold(nCost, Env.LogWay_WorldCupAct, nil, function(nPlayerId, bSuccess)
		if not bSuccess then
            return false, "扣除元宝失败"
        end

        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "扣除元宝过程中你掉线了"
        end

		tbSaveData[1][nIdx] = nTemplateId
		tbSaveData[2][nIdx] = nTimeIdx

		tbData[pPlayer.dwID] = tbSaveData

		pPlayer.CenterMsg("竞猜成功")
		self:OnReq_UpdateData(pPlayer)

		return true
	end)
	return true
end

--在指令中调用，必须给出对应的胜出列表(self.tbTop1, self.tbTop4)
function tbAct:SendRewards(nTop)
	if not nTop or (nTop ~= 1 and nTop ~= 4) then
		Log("[x] WorldCupGuessAct:SendRewards", nTop)
		return
	end

	local tbTopList = nTop==1 and self.tbTop1 or self.tbTop4
	if not next(tbTopList or {}) then
		Log("[x] WorldCupGuessAct:SendRewards, empty toplist", nTop)
		return
	end

	local tbTimeCfg = nTop==1 and self.tbTop1Cfg or self.tbTop4Cfg
	if GetTime() <= tbTimeCfg[#tbTimeCfg][2] then
		Log("[x] WorldCupGuessAct:SendRewards, not finish", nTop)
		return
	end

	local tbData = ScriptData:GetValue("WorldCupGuessAct")
	local szKey = "nRewarded"..nTop
	if tbData[szKey] then
		Log("[x] WorldCupGuessAct:SendRewards, sent before", nTop)
		return
	end

	local tbTopMap = {}
	for _, nWinTemplateId in ipairs(tbTopList) do
		tbTopMap[nWinTemplateId] = true
	end

	local szGuessName = nTop==1 and "冠军" or "四强"
	local tbIdxs = nTop==1 and {1} or {2, 3, 4, 5}
	local tbMail = {Title = "大力神杯竞猜", From = "系统", nLogReazon = Env.LogWay_WorldCupAct}
	for nPlayerId, tb in pairs(tbData) do
		if type(nPlayerId) == "number" then
			local nTotalTimes = 0
			local tbRight = {}
			for _, nIdx in ipairs(tbIdxs) do
				local nGuessTemplateId = tb[1][nIdx]
				if tbTopMap[nGuessTemplateId] then
					local nGuessTimeIdx = tb[2][nIdx]
					local tbCfg = tbTimeCfg[nGuessTimeIdx]
					local nTimes = tbCfg[3]
					nTotalTimes = nTotalTimes + nTimes
					table.insert(tbRight, {"item", nGuessTemplateId, nTimes})
					Log("WorldCupGuessAct:SendRewards, step", nTop, nPlayerId, nGuessTemplateId, nGuessTimeIdx, nTimes)
				end
			end
			if nTotalTimes > 0 then
				local tbAttach = {}
				local tbBaseReward = nTop == 1 and self.tbBaseReward1 or self.tbBaseReward4
				for i=1, nTotalTimes do
					for _, tb in ipairs(tbBaseReward) do
						table.insert(tbAttach, tb)
					end
				end
				tbAttach = KPlayer:MgrAward(nil, tbAttach)
				tbRight = self:FormatAward(tbRight)
				for _, tb in ipairs(tbRight) do
					table.insert(tbAttach, tb)
				end

				local tbDetails = {}
				for _, tb in ipairs(tbRight) do
					local _, nTemplateId, nTimes = unpack(tb)
					local szName = self.tbTeamCfg[nTemplateId][1]
					table.insert(tbDetails, string.format("%s（%d倍奖励）", szName, nTimes))
				end

				local szMailText = string.format("您在[FFFE0D]大力神杯%s竞猜[-]中猜中[FFFE0D]%d[-]个，包括%s，附件为奖励，请查收！", szGuessName, #tbRight, table.concat(tbDetails, "、"))
				tbMail.Text = szMailText
				tbMail.To = nPlayerId
				tbMail.tbAttach = tbAttach
				Mail:SendSystemMail(tbMail)
				Log("WorldCupGuessAct:SendRewards", nTop, nPlayerId, #tbRight, nTotalTimes)
			end
		end
	end

	tbData[szKey] = GetTime()
	ScriptData:SaveAtOnce("WorldCupGuessAct", tbData)
end

function tbAct:FormatAward(tbAward)
	if not MODULE_GAMESERVER or not Activity:__IsActInProcessByType("WorldCupGuessAct") then
		return tbAward
	end
	local tbFormatAward = Lib:CopyTB(tbAward or {})
	if not self.nMedalExpire then
		local _, nEndTime = self:GetOpenTimeInfo()
		self.nMedalExpire = nEndTime
	end
	for _, v in ipairs(tbFormatAward) do
		if v[1] == "item" or v[1] == "Item" then
			v[4] = self.nMedalExpire
		end
	end
	return tbFormatAward
end

function tbAct:GetUiData()
	if not self.tbUiData then
		local tbData = {}
		tbData.nShowLevel = 20
		tbData.szTitle = "大力神杯竞猜"
		tbData.nBottomAnchor = 0

		local nStartTime, nEndTime = self:GetOpenTimeInfo()
		local tbTime1 = os.date("*t", nStartTime)
		local tbTime2 = os.date("*t", nEndTime)
		tbData.szContent = string.format([[活动时间：[c8ff00]%s年%s月%s日%d点-%s年%s月%s日%s点[-]
大力神杯竞猜活动开始了！
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime1.hour, tbTime2.year, tbTime2.month, tbTime2.day, tbTime2.hour)
		tbData.tbSubInfo = {}
		table.insert(tbData.tbSubInfo, {szType = "Item2", szInfo = [[[FFFE0D]快乐竞猜 奖励拿来[-]
活动期间大侠可以通过[FFFE0D]最新消息[-]页面以及[e6d012][url=openwnd:2018世界盃徽章收集册, ItemTips, "Item", nil, 8216][-]中前往竞猜介面，在规定的截止时间前参与本届世界盃[FFFE0D]冠军[-]以及[FFFE0D]四强[-]的竞猜（竞猜冠军球队需要消耗[FFFE0D]300元宝[-]，竞猜每个四强球队均需要消耗[FFFE0D]100元宝[-]），竞猜成功後的奖励如下：
成功竞猜1个四强球队奖励：[FFFE0D]1个对应四强球队徽章[-]、[FFFE0D]5000贡献[-]
成功竞猜1个冠军球队奖励：[FFFE0D]1个对应冠军球队徽章[-]、[FFFE0D]15000贡献[-]
[ff578c]注[-]：四强竞猜截止时间为[ff578c]2018年07月06日21:59:59[-]，冠军竞猜截止时间为[ff578c]2018年07月15日22:59:59[-]。
[FFFE0D]提前竞猜 奖励翻倍[-]
大侠参与竞猜对的时间越早，最终竞猜成功获得的奖励越丰厚！竞猜时间与最终奖励倍数的关系如下：
[ff578c]竞猜四强[-]：
2018-06-29 04:00:00~2018-06-30 21:59:59         2倍
2018-06-30 22:00:00~2018-07-06 21:59:59         1倍
[ff578c]竞猜冠军[-]：
2018-06-29 04:00:00~2018-06-30 21:59:59         5倍
2018-06-30 22:00:00~2018-07-06 21:59:59         3倍
2018-07-06 22:00:00~2018-07-11 01:59:59         2倍
2018-07-11 02:00:00~2018-07-15 22:59:59         1倍
[ff578c]贴心提示[-]：提前竞猜虽然奖励丰厚，但是准确率也会更低哦！
[FFFE0D]公布结果 奖励发放[-]
四强的结果将於[ff578c]2018年7月9日[-]公布，冠军的结果将於[ff578c]2018年7月16日[-]公布，奖励将在公布结果当日以信件的方式发放给各位竞猜成功的大侠。
[ff578c]贴心提示[-]：大侠记得及时收集信件中发放的徽章，不然徽章活动结束就过期了！
]]})
		tbData.szBtnText = "前往竞猜"
		tbData.szBtnTrap = "[url=openwnd:前往竞猜, WorldCupGuessPanel]"

		self.tbUiData = tbData
	end
	return self.tbUiData
end