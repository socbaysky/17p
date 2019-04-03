local tbAct = Activity:GetClass("NewYearQAAct")
tbAct.tbTimerTrigger = 
{
	[1] = {szType = "Day", Time = string.format("%d:00", tbAct.nCreateSysQuestion) , Trigger = "OnWorldNotify" },
}
tbAct.tbTrigger = { Init = { }, Start = { {"StartTimerTrigger", 1} }, End = { }, OnWorldNotify = {}}
tbAct.nDataCountIn1Table = 25 --一个表可以存多少个玩家数据，非配置项，请勿修改
tbAct.nRightPos = 1
tbAct.nWrongPos = tbAct.nRightPos + 1

function tbAct:OnTrigger(szTrigger)
	self:CheckSetting()
	if szTrigger == "Init" then
		local _, nEndTime = self:GetOpenTimeInfo()
		local tbMail = {Title = self.szMailTitle, From = "系统", LevelLimit = self.nRequireLv, nRecyleTime = nEndTime - GetTime(), nLogReazon = Env.LogWay_NewYearQAAct, Text = self.szMailContent}
		tbMail.tbAttach = {{"Item", self.nActEnterItem, 1, nEndTime}}
		Mail:SendGlobalSystemMail(tbMail)
	elseif szTrigger == "Start" then
		self.tbPlayerDataSaveKey = {}
		Activity.ActPlayerExtData:Create(self.szKeyName, self.nDataCountIn1Table)
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin")
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLevelUp", "OnLevelUp")
		Activity:RegisterPlayerEvent(self, "Act_NewYearQA_ClientCall", "OnClientCall")
		self:LoadSetting()
		local tbPlayer = KPlayer.GetAllPlayer()
		for _, pPlayer in pairs(tbPlayer) do
			self:OnLogin(pPlayer)
		end
	elseif szTrigger == "End" then
		self:SendAward()
		Activity.ActPlayerExtData:Clear(self.szKeyName)
	elseif szTrigger == "OnWorldNotify" then
		self:OnWorldNotify()
	end
end

function tbAct:CheckSetting()
	if self.bChecked then
		return
	end
	self.bChecked = true

	local tbSetting = self.tbDiffKeySetting[self.szKeyName]
	if not tbSetting then
		return
	end
	for szKey, value in pairs(tbSetting) do
		self[szKey] = value
	end
end

function tbAct:OnWorldNotify()
	local tbPlayer = KPlayer.GetAllPlayer()
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel >= self.nRequireLv then
			self:CheckAnswerData(pPlayer.dwID, true)
			local tbData = self:GetPlayerData(pPlayer.dwID)
			if #tbData.tbAnswerInfo.tbTodayQuestion <= 0 then
				pPlayer.CallClientScript("Activity.NewYearQAAct:OnCreateNotify")
			end
		end
	end
end

function tbAct:OnLogin(pPlayer)
	self:CheckAskData(pPlayer.dwID)
	self:CheckAnswerData(pPlayer.dwID, true)
	local tbData = self:GetPlayerData(pPlayer.dwID)
	local nStartTime = self:GetOpenTimeInfo()
	pPlayer.CallClientScript("Activity.NewYearQAAct:SyncData", nStartTime, tbData)
end

function tbAct:OnLevelUp(pPlayer, nNewLevel)
	if nNewLevel == self.nRequireLv then
		local _, nEndTime = self:GetOpenTimeInfo()
		local tbMail = {Title = self.szMailTitle, From = "系统", To = pPlayer.dwID, nRecyleTime = nEndTime - GetTime(), nLogReazon = Env.LogWay_NewYearQAAct, Text = self.szMailContent}
		tbMail.tbAttach = {{"Item", self.nActEnterItem, 1, nEndTime}}
		Mail:SendSystemMail(tbMail)
		Log("NewYearQAAct OnLevelUp:", pPlayer.dwID, nNewLevel)
	end
end

function tbAct:LoadSetting()
	local tbFile = Lib:LoadTabFile(self.szQuestionFile, {})
	self.nQACount = #tbFile
	tbFile = Lib:LoadTabFile(self.szDQuestionFile, {nRight = 1})
	self.tbDefaultQA = {}
	for _, tbInfo in ipairs(tbFile) do
		table.insert(self.tbDefaultQA, tbInfo.nRight)
	end
end

function tbAct:GetRound()
	local nStartTime = self:GetOpenTimeInfo()
	local nStartDay  = Lib:GetLocalDay(nStartTime - self.nNewDayTime)
	local nLocalDay  = Lib:GetLocalDay(GetTime() - self.nNewDayTime)
	local nCurRound  = math.floor((nLocalDay - nStartDay) / self.nDayInRound) + 1
	return nCurRound
end

function tbAct:RandomQuestion()
	local tbQuestion = {}
	local tbAll = {}
	for i = 1, self.nQACount do
		table.insert(tbAll, i)
	end
	for i = 1, self.nQuestionNum do
		local nTitle = table.remove(tbAll, MathRandom(#tbAll))
		table.insert(tbQuestion, nTitle)
	end
	return tbQuestion
end

function tbAct:CheckAskData(nPlayerId)
	local tbData = self:GetPlayerData(nPlayerId)
	local nCurRound = self:GetRound()
	if tbData.tbAskInfo.nRound ~= nCurRound then
		tbData.tbAskInfo.nRound     = nCurRound
		tbData.tbAskInfo.bConfirm   = false
		tbData.tbAskInfo.bCostGold  = false
		tbData.tbAskInfo.tbQuestion = {}
		local tbRandom = self:RandomQuestion()
		for _, nTitleId in pairs(tbRandom) do
			table.insert(tbData.tbAskInfo.tbQuestion, {nTitle = nTitleId})
		end
		self:AddModifyFlag(nPlayerId)
		Log("NewYearQAAct CheckAskData", nPlayerId, nCurRound)
	end
end

function tbAct:IsPlayerSetQuestion(nPlayerId, nCurRound)
	local tbData = self:GetPlayerData(nPlayerId)
	if not tbData.tbAskInfo then
		return
	end
	if tbData.tbAskInfo.nRound ~= nCurRound then
		return
	end
	return tbData.tbAskInfo.bConfirm
end

function tbAct:RandomTodayQuestion(nPlayerId, tbAnswerInfo)
	if #tbAnswerInfo.tbTodayQuestion > 0 then
		return
	end
	local nCurRound = self:GetRound()
	local nHour = Lib:GetLocalDayHour()
	local tbList, nTotal = KFriendShip.GetFriendList(nPlayerId)
	nTotal = nTotal or 0
	if nTotal < self.nDayQuestionCount and
			(nHour < self.nCreateSysQuestion) and
			(nHour >= (self.nNewDayTime/3600)) then
		return
	end
	local tbFriendList = {}
	for nFriendId, nImity in pairs(tbList) do
		if self:IsPlayerSetQuestion(nFriendId, nCurRound) then
			table.insert(tbFriendList, {nFriendId, nImity})
		end
	end
	if (#tbFriendList >= self.nDayQuestionCount) or
			(nHour >= self.nCreateSysQuestion) or
			(nHour < (self.nNewDayTime/3600)) then
		local fnInst = function (nPlayerId)
			local tbData = self:GetPlayerData(nPlayerId)
			local nQId   = MathRandom(self.nQuestionNum)
			local tbQ    = tbData.tbAskInfo.tbQuestion[nQId]
			table.insert(tbAnswerInfo.tbTodayQuestion, {nPlayerId = nPlayerId, nTitle = tbQ.nTitle, nAnswer = tbQ.nAskId, bCostGold = tbData.tbAskInfo.bCostGold})
		end
		if #tbFriendList <= self.nDayQuestionCount then
			for _, tbInfo in ipairs(tbFriendList) do
				fnInst(tbInfo[1])
			end
		else
			table.sort(tbFriendList, function (a, b)
				return a[2] > b[2]
			end)
			local nCount = 0
			local tbInsertIndx = {}
			for i, tbInfo in ipairs(tbFriendList) do
				local nRan = MathRandom(1000000)
				if tbInfo[2] >= nRan then
					fnInst(tbInfo[1])
					tbInsertIndx[i] = true
					nCount = nCount + 1
				end
			end
			if nCount < self.nDayQuestionCount then
				for i, tbInfo in ipairs(tbFriendList) do
					if not tbInsertIndx[i] then
						fnInst(tbInfo[1])
						nCount = nCount + 1
						if nCount >= self.nDayQuestionCount then
							break
						end
					end
				end
			end
		end
		if #tbAnswerInfo.tbTodayQuestion < self.nDayQuestionCount then
			local tbIdx = {}
			for i = 1, #self.tbDefaultQA do
				table.insert(tbIdx, i)
			end
			for i = #tbAnswerInfo.tbTodayQuestion + 1, self.nDayQuestionCount do
				local nQId = table.remove(tbIdx, MathRandom(#tbIdx))
				table.insert(tbAnswerInfo.tbTodayQuestion, {nPlayerId = -1, nTitle = nQId, nAnswer = self.tbDefaultQA[nQId]})
			end
		end
		Log("NewYearQAAct RandomTodayQuestion", nPlayerId)
		return true
	end
end

function tbAct:CheckAnswerData(nPlayerId, bNoRefreshQuestion, bReset)
	local tbData = self:GetPlayerData(nPlayerId)
	local bNotToday = tbData.tbAnswerInfo.nDataDay ~= Lib:GetLocalDay(GetTime() - self.nNewDayTime)
	if bNotToday or bReset then
		if bNotToday then
			tbData.tbAnswerInfo.nDayRefreshTimes = 0
			tbData.tbAnswerInfo.nDataDay = Lib:GetLocalDay(GetTime() - self.nNewDayTime)
		elseif bReset then
			tbData.tbAnswerInfo.nDayRefreshTimes = tbData.tbAnswerInfo.nDayRefreshTimes or 0
			tbData.tbAnswerInfo.nDayRefreshTimes = tbData.tbAnswerInfo.nDayRefreshTimes + 1
		end 
		tbData.tbAnswerInfo.nAnswerNum = 0
		tbData.tbAnswerInfo.nMoneyRight = 0
		tbData.tbAnswerInfo.nNormalRight = 0
		tbData.tbAnswerInfo.tbAnswerFriend = tbData.tbAnswerInfo.tbAnswerFriend or {}
		tbData.tbAnswerInfo.tbTodayQuestion = {}
		Log("NewYearQAAct CheckAnswerData", nPlayerId, tbData.tbAnswerInfo.nDayRefreshTimes)
	end
	if not bNoRefreshQuestion then
		self:RandomTodayQuestion(nPlayerId, tbData.tbAnswerInfo)
	end
	self:AddModifyFlag(nPlayerId)
end

function tbAct:TryBeginQuestion(pPlayer)
	self:CheckAskData(pPlayer.dwID)
	local tbData = self:GetPlayerData(pPlayer.dwID)
	if not tbData.tbAskInfo.bConfirm then
		pPlayer.CallClientScript("Activity.NewYearQAAct:BeginQuestion", tbData.tbAskInfo)
	end
end

function tbAct:TrySetQuestion(pPlayer, nRound, tbQuestion, bCostGold)
	if bCostGold and pPlayer.GetMoney("Gold") < self.nSetQuestionGold then
		pPlayer.CenterMsg(string.format("元宝不足 %s", self.nSetQuestionGold))
		return
	end

	if bCostGold then
		local fnCostCallback = function (nPlayerId, bSuccess)
			if not bSuccess then
				return false, "支付失败"
			end
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if not pPlayer then
				return false, "玩家离线"
			end
			return self:_SetQuestionSuccess(pPlayer, nRound, tbQuestion, bCostGold)
		end

		-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
		local bRet = pPlayer.CostGold(self.nSetQuestionGold, Env.LogWay_NewYearQAAct, nil, fnCostCallback)
		if not bRet then
			pPlayer.CenterMsg("支付失败，请重试")
		end
	else
		local bRet, szMsg = self:_SetQuestionSuccess(pPlayer, nRound, tbQuestion, bCostGold)
		if not bRet then
			pPlayer.CenterMsg(szMsg)
		end
	end
end

function tbAct:CheckSetQuestion(pPlayer, nRound, tbAnswerInfo)
	self:CheckAskData(pPlayer.dwID)
	local tbData = self:GetPlayerData(pPlayer.dwID)
	local nCurRound = self:GetRound()
	if nCurRound ~= nRound then
		pPlayer.CallClientScript("Activity.NewYearQAAct:BeginQuestion", tbData.tbAskInfo)
		return false, "题目过期，已重新随机"
	end
	if tbData.tbAskInfo.bConfirm then
		return false, "大侠本轮已经出过题了"
	end
	if not tbAnswerInfo or #tbAnswerInfo ~= self.nQuestionNum then
		return false, "答案数量不足"
	end
	for _, nAnswerId in ipairs(tbAnswerInfo)  do
		if nAnswerId <= 0 or nAnswerId > self.nAnswerCount then
			return false, "答案不存在"
		end
	end
	return true, "", tbData
end

function tbAct:_SetQuestionSuccess(pPlayer, nRound, tbQuestion, bCostGold)
	local bRet, szMsg, tbData = self:CheckSetQuestion(pPlayer, nRound, tbQuestion)
	if not bRet then
		return false, szMsg
	end

	for nQIdx, tbInfo in ipairs(tbData.tbAskInfo.tbQuestion) do
		tbInfo.nAskId = tbQuestion[nQIdx]
	end
	tbData.tbAskInfo.nRound = nRound
	tbData.tbAskInfo.bConfirm = true
	tbData.tbAskInfo.bCostGold = bCostGold
	self:AddModifyFlag(pPlayer.dwID)
	pPlayer.CallClientScript("Activity.NewYearQAAct:SetQuestionSuccess", tbData.tbAskInfo)
	Log("NewYearQAAct _SetQuestionSuccess", pPlayer.dwID, nRound, tostring(bCostGold))
	return true
end

function tbAct:TryBeginAnswer(pPlayer)
	self:CheckAnswerData(pPlayer.dwID)
	local tbData = self:GetPlayerData(pPlayer.dwID)
	if tbData.tbAnswerInfo.nAnswerNum >= self.nDayQuestionCount then
		return
	end
	if #tbData.tbAnswerInfo.tbTodayQuestion < self.nDayQuestionCount then
		return
	end
	pPlayer.CallClientScript("Activity.NewYearQAAct:BeginAnswer", tbData.tbAnswerInfo)
end

function tbAct:FreeRefreshQuestion(pPlayer)
	local tbData = self:GetPlayerData(pPlayer.dwID)
	if tbData.tbAnswerInfo.nDayRefreshTimes and tbData.tbAnswerInfo.nDayRefreshTimes >= self.nDayRefreshTimes then
		pPlayer.CenterMsg(string.format("每天只能刷新%d次", self.nDayRefreshTimes))
		return true
	end
	if tbData.tbAnswerInfo.nDataDay ~= Lib:GetLocalDay(GetTime() - self.nNewDayTime) then
		self:CheckAnswerData(pPlayer.dwID)
		tbData = self:GetPlayerData(pPlayer.dwID)
		pPlayer.CallClientScript("Activity.NewYearQAAct:BeginAnswer", tbData.tbAnswerInfo)
		pPlayer.CenterMsg("每天免费的题目已刷新")
		Log("NewYearQAAct FreeRefreshQuestion", pPlayer.dwID)
		return true
	end
end

function tbAct:TryRefreshQuestion(pPlayer)
	if self:FreeRefreshQuestion(pPlayer) then
		return
	end

	if pPlayer.GetMoney("Gold") < self.nRefreshQuestionGold then
		pPlayer.CenterMsg(string.format("元宝不足 %s", self.nRefreshQuestionGold))
		return
	end

	local fnCostCallback = function (nPlayerId, bSuccess)
		if not bSuccess then
			return false, "支付失败"
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if not pPlayer then
			return false, "玩家离线"
		end

		if self:FreeRefreshQuestion(pPlayer) then
			return false, "题目已自行刷新"
		end

		self:CheckAnswerData(pPlayer.dwID, nil, true)
		local tbData = self:GetPlayerData(pPlayer.dwID)
		pPlayer.CallClientScript("Activity.NewYearQAAct:BeginAnswer", tbData.tbAnswerInfo)
		pPlayer.CenterMsg("刷新成功")
		return true
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(self.nRefreshQuestionGold, Env.LogWay_NewYearQAAct, nil, fnCostCallback)
	if not bRet then
		pPlayer.CenterMsg("支付失败，请重试")
	end
end

function tbAct:GetPlayerName(nPlayerId)
	local szPlayerName = "神秘人"
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer then
		szPlayerName = pPlayer.szName
	else
		local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
		if tbRoleStayInfo then
			szPlayerName = tbRoleStayInfo.szName
		end
	end
	return szPlayerName
end

function tbAct:TryAnswer(pPlayer, nQIdx, nAnswer)
	if not nQIdx or nQIdx <= 0 or nQIdx > self.nDayQuestionCount or not nAnswer then
		return
	end

	self:CheckAnswerData(pPlayer.dwID)
	local tbData = self:GetPlayerData(pPlayer.dwID)
	if #tbData.tbAnswerInfo.tbTodayQuestion < self.nDayQuestionCount then
		return
	end
	local tbQInfo = tbData.tbAnswerInfo.tbTodayQuestion[nQIdx]
	if not tbQInfo or tbQInfo.nChooseAnswer then
		return
	end

	local nFriendId = tbQInfo.nPlayerId
	local bRight = tbQInfo.nAnswer == nAnswer
	if nFriendId > 0 then
		local nPos = (bRight) and self.nRightPos or self.nWrongPos
		tbData.tbAnswerInfo.tbAnswerFriend[nFriendId] = tbData.tbAnswerInfo.tbAnswerFriend[nFriendId] or {}
		tbData.tbAnswerInfo.tbAnswerFriend[nFriendId][nPos] = tbData.tbAnswerInfo.tbAnswerFriend[nFriendId][nPos] or 0
		tbData.tbAnswerInfo.tbAnswerFriend[nFriendId][nPos] = tbData.tbAnswerInfo.tbAnswerFriend[nFriendId][nPos]  + 1
	end
	tbQInfo.nChooseAnswer = nAnswer
	tbData.tbAnswerInfo.nAnswerNum = tbData.tbAnswerInfo.nAnswerNum + 1
	pPlayer.CenterMsg(bRight and "回答正确" or "回答错误")
	if bRight and FriendShip:IsFriend(pPlayer.dwID, nFriendId) then
		local nImity = tbQInfo.bCostGold and self.nMoneyRightImity or self.nNormalRightImity
		FriendShip:AddImitity(pPlayer.dwID, nFriendId, nImity, Env.LogWay_NewYearQAAct)
	end
	if tbQInfo.bCostGold then
		if bRight then
			local bRet = self:CheckAwardTimes(nFriendId)
			if bRet then
				local szPlayerName = pPlayer.szName
				if self.bWolrdNotify then
					local szFriendName = self:GetPlayerName(nFriendId)
					KPlayer.SendWorldNotify(1, 999, string.format("[eebb01]%s[-]答对了[eebb01]%s[-]的一条高级问题，两人的关系还真是亲密无间呢！", szPlayerName, szFriendName), 1, 1)
				else
					local pFriend = KPlayer.GetPlayerObjById(nFriendId)
					if pFriend then
						pFriend.CenterMsg(string.format("[eebb01]%s[-]答对了你的高级问题，你俩的关系真是亲密无间", szPlayerName))
					end
				end
				local tbMail =
				{
					To = nFriendId,
					Title = self.szMailTitle,
					Text = string.format("[eebb01]%s[-]答对了您的问题，大侠成功获得1000贡献", szPlayerName),
					tbAttach = self.tbMoneyQuestionAward,
					nLogReazon = Env.LogWay_NewYearQAAct,
				}
				Mail:SendSystemMail(tbMail)
			end
		end
		tbData.tbAnswerInfo.nMoneyRight = tbData.tbAnswerInfo.nMoneyRight + 1
	else
		tbData.tbAnswerInfo.nNormalRight = tbData.tbAnswerInfo.nNormalRight + 1
	end
	local nAnswerNum = tbData.tbAnswerInfo.nAnswerNum
	if nAnswerNum == self.nDayQuestionCount then
		self:SendDayAward(pPlayer, tbData.tbAnswerInfo.nMoneyRight, tbData.tbAnswerInfo.nNormalRight)
	end
	self:AddModifyFlag(pPlayer.dwID)
	pPlayer.CallClientScript("Activity.NewYearQAAct:OnAnswer", nQIdx, nAnswer)
	Log("NewYearQAAct Answer:", pPlayer.dwID, nAnswerNum)
end

function tbAct:CheckAwardTimes(nPlayerId)
	local tbFriendData = self:GetPlayerData(nPlayerId)
	if tbFriendData.tbTodayAwardData then
		if tbFriendData.tbTodayAwardData.nDataDay ~= Lib:GetLocalDay(GetTime() - self.nNewDayTime) then
			tbFriendData.tbTodayAwardData.nDataDay = Lib:GetLocalDay(GetTime() - self.nNewDayTime)
			tbFriendData.tbTodayAwardData.nRightNum = 1
			self:AddModifyFlag(nPlayerId)
			Log("NewYearQAAct Reset AwardTimes", nPlayerId)
			return true
		elseif tbFriendData.tbTodayAwardData.nRightNum < self.nBeAnswerAwardTimes then
			tbFriendData.tbTodayAwardData.nRightNum = tbFriendData.tbTodayAwardData.nRightNum + 1
			self:AddModifyFlag(nPlayerId)
			Log("NewYearQAAct Add AwardTimes", nPlayerId)
			return true
		end
	else
		tbFriendData.tbTodayAwardData = {nDataDay = Lib:GetLocalDay(GetTime() - self.nNewDayTime), nRightNum = 1}
		self:AddModifyFlag(nPlayerId)
		return true
	end
end

function tbAct:SendDayAward(pPlayer, nMoneyRight, nNormalRight)
	local tbAward = {}
	if nMoneyRight > 0 then
		table.insert(tbAward, {"Item", self.nMoneyAward, nMoneyRight})
	end

	if nNormalRight > 0 then
		table.insert(tbAward, {"Item", self.nNormalAward, nNormalRight})
	end
	pPlayer.SendAward(tbAward, false, true, Env.LogWay_NewYearQAAct)
	pPlayer.CallClientScript("Ui:OpenWindow", "NewYearQARedbagPanel")
end

--[[
{
	tbAskInfo    = { nRound = 1, bConfirm = false, bCostGold = false, tbQuestion = {{nTitle = 1, nAskId = 1}, {nTitle = 1, nAskId = 1}, {nTitle = 1, nAskId = 1}} }
	tbAnswerInfo = { nDataDay = Lib:GetLocalDay(), nRightNum = 0, nAnswerNum = 0, nNormalRight = 0, nMoneyRight = 0, nDayRefreshTimes = 0, tbTodayQuestion = {{nPlayerId = -1, nTitle = 1, nAnswer = 1}}, tbAnswerFriend = {[1] = {1, 1}} }
}
]]
function tbAct:GetPlayerData(nPlayerId)
	local tbData, szSaveKey = Activity.ActPlayerExtData:GetData(self.szKeyName, nPlayerId)
	if not tbData then
		tbData = {tbAskInfo = {}, tbAnswerInfo = {}}
		szSaveKey = Activity.ActPlayerExtData:SaveData(self.szKeyName, nPlayerId, tbData)
	end
	self.tbPlayerDataSaveKey[nPlayerId] = szSaveKey
	return tbData
end

function tbAct:AddModifyFlag(nPlayerId)
	local szSaveKey = self.tbPlayerDataSaveKey[nPlayerId]
	if szSaveKey then
		ScriptData:AddModifyFlag(szSaveKey)
	end
end

function tbAct:GetAllAnswerInfo()
	local tbPlayInfo = {}
	local fn = function (nPlayerId, tbPlayData)
		if tbPlayData and tbPlayData.tbAnswerInfo then
			local tbAnswerFriend = tbPlayData.tbAnswerInfo.tbAnswerFriend
			if tbAnswerFriend then
				for nBeAnswerPlayer, tb in pairs(tbAnswerFriend) do
					tbPlayInfo[nBeAnswerPlayer] = tbPlayInfo[nBeAnswerPlayer] or { [self.nRightPos] = {nNum = 0, tbPlayer = {}}, [self.nWrongPos] = {nNum = 0, tbPlayer = {}} }
					for nPos = self.nRightPos, self.nWrongPos do
						local nCount = tb[nPos] or 0
						if nCount > 0 and nCount >= self.tbPlayerTitle[nPos][3] and
							( nPos == self.nRightPos or (nPos == self.nWrongPos and (not tb[self.nRightPos] or tb[self.nRightPos] == 0)) ) then
							if nCount == tbPlayInfo[nBeAnswerPlayer][nPos].nNum then
								table.insert(tbPlayInfo[nBeAnswerPlayer][nPos].tbPlayer, nPlayerId)
							elseif nCount > tbPlayInfo[nBeAnswerPlayer][nPos].nNum then
								tbPlayInfo[nBeAnswerPlayer][nPos].nNum = nCount
								tbPlayInfo[nBeAnswerPlayer][nPos].tbPlayer = {nPlayerId}
							end
						end
					end
				end 
			end
		end
	end
	Activity.ActPlayerExtData:TraversalAllPlayer(self.szKeyName, fn)

	local tbChoose = {}
	for nPlayer, tbInfo in pairs(tbPlayInfo) do
		for nPos = self.nRightPos, self.nWrongPos do
			if #tbInfo[nPos].tbPlayer > 0 then
				for _, nPlayerId in pairs(tbInfo[nPos].tbPlayer) do
					tbChoose[nPlayerId] = tbChoose[nPlayerId] or {}
					local tbCurFriendInfo = tbChoose[nPlayerId][nPos]
					local nImity = FriendShip:GetImity(nPlayer, nPlayerId)
					if nImity and (not tbCurFriendInfo or tbCurFriendInfo.nImity < nImity) then
						tbChoose[nPlayerId][nPos] = tbChoose[nPlayerId][nPos] or {}
						tbChoose[nPlayerId][nPos].nCurFriend = nPlayer
						tbChoose[nPlayerId][nPos].nImity     = nImity
					end
				end
			end
		end
	end
	return tbChoose
end 

function tbAct:SendAward()
	local tbPlayInfo = self:GetAllAnswerInfo()
	local nTimeout = self.nTitleValidTime
	for nPlayerId, tbInfo in pairs(tbPlayInfo) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		for nPos = self.nRightPos, self.nWrongPos do
			local nFriendId = tbInfo[nPos] and tbInfo[nPos].nCurFriend
			if nFriendId then
				local szPlayerName = self:GetPlayerName(nFriendId)
				local szText = string.format(self.tbPlayerTitle[nPos][2], szPlayerName)
				local nTitleId = self.tbPlayerTitle[nPos][1]
				if pPlayer then
					PlayerTitle:AddTitle(pPlayer, nTitleId, nTimeout, szText)
				else
					local szCmd = [[
						local nTimeout = %d
						if GetTime() < nTimeout then
							PlayerTitle:AddTitle(me, %d, nTimeout - GetTime(), '%s')
						end
					]]
					szCmd = string.format(szCmd, nTimeout + GetTime(), nTitleId, szText)
					KPlayer.AddDelayCmd(nPlayerId, szCmd, string.format("NewYearQAAct Send Title Award %d nTitleId %d", nPlayerId, nTitleId))
				end
				Log("NewYearQAAct SendTitle:", nPlayerId, nTitleId, szPlayerName)
			end
		end
	end
end

local tbSafeCall = {
	["TryBeginQuestion"] = true,
	["TrySetQuestion"] = true,
	["TryBeginAnswer"] = true,
	["TryRefreshQuestion"] = true,
	["TryAnswer"] = true,
}
function tbAct:OnClientCall(pPlayer, szFunc, ...)
	if not tbSafeCall[szFunc] then
		return
	end
	if pPlayer.nLevel < self.nRequireLv then
		pPlayer.CenterMsg("等级不足，无法参加该活动")
		return
	end
	self[szFunc](self, pPlayer, ...)
end

--[[
待优化：
1.现有数据结构太大，一个表存到30人就不够了
2.出题没缓存，每次申请都需要重新检测
]]