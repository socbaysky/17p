-- 所有玩家已经选好的门派，[dwID] = nFaction
QunYingHuiCross.tbPlayerFaction = QunYingHuiCross.tbPlayerFaction or {}

function QunYingHuiCross:OnPreMapReady(nPreMapId)
	self.nPreMapId = nPreMapId
	Calendar:OnActivityBegin("QunYingHui");
	KPlayer.SendWorldNotify(0, 999, QunYingHuiCross.szStartWorldNotify, 0, 1);
	self:Log("fnOnPreMapReady ", nPreMapId)
end

function QunYingHuiCross:OnActEnd()
	self.nPreMapId = nil
	self:Log("OnActEnd ")
end

function QunYingHuiCross:Join(pPlayer, pAssist)
	local tbPlayer = {pPlayer, pAssist}
	local nServerIdx = GetServerListIndex()
	local nServerId = GetServerIdentity();
	local nType = #tbPlayer == 1 and QunYingHuiCross.TYPE_SINGLE or QunYingHuiCross.TYPE_TEAM
	local szKinName 
	local kinData = Kin:GetKinById(pPlayer.dwKinId)
	szKinName = kinData and kinData.szName
	local nPlayerUniqId = QunYingHuiCross:CombineUniqId(nServerId, pPlayer.dwID)
	CallZoneServerScript("QunYingHuiCross.tbQunYingHuiZ:SynPreMapLogic", "UpdatePlayer", nil ,{szName = pPlayer.szName, nType = nType, nServerIdx = nServerIdx, szKinName = szKinName, nServerId = nServerId}, nPlayerUniqId);
	local nAssistUniqId
	if pAssist then
		local szAssistKinName 
		local assistKinData = Kin:GetKinById(pAssist.dwKinId)
		szAssistKinName = assistKinData and assistKinData.szName
		nAssistUniqId = QunYingHuiCross:CombineUniqId(nServerId, pAssist.dwID)
		CallZoneServerScript("QunYingHuiCross.tbQunYingHuiZ:SynPreMapLogic", "UpdatePlayer", nil ,{szName = pAssist.szName, nType = nType, nServerIdx = nServerIdx, szKinName = szAssistKinName, nServerId = nServerId}, nAssistUniqId);
	end
	if #tbPlayer == 2 then
		local dwTeamID = pPlayer.dwTeamID
		local tbMemberIds = {}
		for i,v in ipairs(tbPlayer) do
			local nMemberUniqId = QunYingHuiCross:CombineUniqId(nServerId, v.dwID)
			table.insert(tbMemberIds, nMemberUniqId)
		end
		CallZoneServerScript("QunYingHuiCross.tbQunYingHuiZ:SynPreMapLogic", "OnSyncTeamInfo", nPlayerUniqId, tbMemberIds);
		--组队信息， 拆队
		for _, nPlayerId in pairs(tbMemberIds) do
			TeamMgr:QuiteTeam(dwTeamID, nPlayerId)
		end
	end
	local nPosX, nPosY = Map:GetDefaultPos(QunYingHuiCross.nPreMapTID);
	for _, pP in ipairs(tbPlayer) do
		if not pP.SwitchZoneMap(self.nPreMapId, nPosX, nPosY) then
			pP.CenterMsg("暂时无法进入准备场地")
			self:Log("fnJoin fail", self.nPreMapId, pP.szName, pP.dwID)
		else
			-- 没选过门派代表没参加过
			if not self.tbPlayerFaction[pP.dwID] then
				EverydayTarget:AddCount(pP, "QunYingHui");
			end
		end
	end
	self:Log("fnJoin ok", nPlayerUniqId, nAssistUniqId or -1, nType, nServerId, nServerIdx, self.nPreMapId, pPlayer.szName, pPlayer.dwID, pAssist and pAssist.dwID, pAssist and pAssist.szName, pAssist and pAssist.dwTeamID)
end

function QunYingHuiCross:ConfirmChooseFaction(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if pPlayer then
		local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
		local pAssist;
		if tbTeam then
			local tbMember = tbTeam:GetMembers()
			if Lib:CountTB(tbMember) ~= 2 then
				pPlayer.CenterMsg("双人队伍或单人才能参加", true)
				return 
			end
			for _, nPlayerID in pairs(tbMember) do
				local pMember = KPlayer.GetPlayerObjById(nPlayerID);
				if not pMember then
					pPlayer.CenterMsg("对方不线上，无法参加！", true)
					return
				end
				if nPlayerID ~= pPlayer.dwID then
					pAssist = pMember;
				end
			end
			if not pAssist then
				pPlayer.CenterMsg("无法找到您的队友", true)
				return
			end
			local nCaptainId = tbTeam:GetCaptainId()
			local pCaptain = KPlayer.GetPlayerObjById(nCaptainId)
			if not pCaptain then
				pPlayer.CenterMsg("队长不线上", true)
				return
			end
			if not self:IsRequestChooseFactionWilling(pPlayer) then
				pPlayer.CenterMsg("请求已经失效", true)
				return 
			end
			self:ConfirmChooseFactionWilling(pPlayer)
			if self:IsChooseFactionWilling(pPlayer) and self:IsChooseFactionWilling(pAssist) then
				self:TryJoin(pCaptain, true)
			else
				pPlayer.CenterMsg("等待对方确认", true)
			end
		end
	end
end

-- 已选门派直接进入
function QunYingHuiCross:PreJoin(pPlayer, pMember)
	local nPlayerFaction = self.tbPlayerFaction[pPlayer.dwID]
	if not pMember and nPlayerFaction then
		self:Join(pPlayer)
	else
		local nMemberFaction = self.tbPlayerFaction[pMember.dwID]
		if nPlayerFaction and nMemberFaction then
			self:Join(pPlayer, pMember)
		end
	end
end

function QunYingHuiCross:TryJoin(pPlayer, bConfirm)
	local bRet, szMsg, pMember = self:CheckJoin(pPlayer, bConfirm)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return 
	end
	if self.tbPlayerFaction[pPlayer.dwID] then
		self:PreJoin(pPlayer, pMember)
		return
	end
	if not pMember then
		local fnSure = function (dwID)
			local pSure = KPlayer.GetPlayerObjById(dwID)
			if not pSure then
				return
			end
			local bRet, szMsg, pTeammate = self:CheckJoin(pSure)
			if not bRet then
				pSure.CenterMsg(szMsg, true)
				return 
			end
			if self.tbPlayerFaction[pSure.dwID] then
				self:PreJoin(pSure)
				return
			end
			if pTeammate then
				self:TryJoin(pSure)
				return
			end
			self:Join(pSure)
		end
		pPlayer.MsgBox("是否确认报名参加本场群英会？", {{"确定", fnSure, pPlayer.dwID}, {"拒绝"}})
	else
		local bPlayerWilling = self:IsChooseFactionWilling(pPlayer)
		local bMemberWilling = self:IsChooseFactionWilling(pMember)
		local nMemberId = pMember.dwID
		local nPlayerId = pPlayer.dwID
		if not bPlayerWilling and not bMemberWilling and not bConfirm then
			local fnAgree = function (nOtherId, nMeId)
				local pOther = KPlayer.GetPlayerObjById(nOtherId, nMeId)
				if pOther then
					local pMe = KPlayer.GetPlayerObjById(nMeId)
					if not self:IsRequestChooseFactionWilling(pOther) then
						if pMe then
							pMe.CenterMsg("请求已经失效", true)
						end
						return 
					end
					self:ConfirmChooseFaction(nMeId)
					pOther.CenterMsg("对方已同意")
				end
			end
			local fnRefuse = function (nOtherId, nMeId)
				local pOther = KPlayer.GetPlayerObjById(nOtherId)
				if pOther then
					local pMe = KPlayer.GetPlayerObjById(nMeId)
					if not self:IsRequestChooseFactionWilling(pOther) then
						if pMe then
							pMe.CenterMsg("请求已经失效", true)
						end
						return 
					end
					if pMe then
						self:ClearRequestFactionData(pMe)
					end
					self:ClearRequestFactionData(pOther)
					pOther.CenterMsg("对方还没准备好")
					GameSetting:SetGlobalObj(pOther)
					Dialog:OnMsgBoxSelect(1, true, true)
					GameSetting:RestoreGlobalObj()
					pOther.CallClientScript("Ui:CloseWindow", "MessageBox")
				end
			end
			local fnOverTime = function ()
				if me then
					local tbPlayerId = {nMemberId, nPlayerId}
					for _, dwID in ipairs(tbPlayerId) do
						local pP = KPlayer.GetPlayerObjById(dwID)
						if pP then
							self:ClearRequestFactionData(pP)
						end
					end
					me.CenterMsg("请求超时", true)
					me.CallClientScript("Ui:CloseWindow", "MessageBox")
				end
			end
			self:RequestChooseFactionWilling(pPlayer)
			self:RequestChooseFactionWilling(pMember)
			local szTip = string.format("是否确认与[FFFE0D]「%s」[-]共同组队，报名参加本场群英会？", pPlayer.szName)
			pMember.MsgBox(szTip .."\n（%d秒後自动拒绝）", {{"同意", fnAgree, pPlayer.dwID, pMember.dwID}, {"拒绝", fnRefuse, pPlayer.dwID, pMember.dwID}}, nil, Wedding.nRequestJumpWelcomeTime, fnOverTime)
			szTip = string.format("是否确认与[FFFE0D]「%s」[-]共同组队，报名参加本场群英会？", pMember.szName)
			pPlayer.MsgBox(szTip .."\n（%d秒後自动拒绝）", {{"同意", fnAgree, pMember.dwID, pPlayer.dwID}, {"拒绝", fnRefuse, pMember.dwID, pPlayer.dwID}}, nil, Wedding.nRequestJumpWelcomeTime, fnOverTime)
		elseif bPlayerWilling and bMemberWilling then
			self:Join(pPlayer, pMember)
		else
			self:ClearRequestFactionData(pPlayer)
			self:ClearRequestFactionData(pMember)
			pPlayer.CenterMsg("请稍後再试", true)
		end 
	end
end

function QunYingHuiCross:CheckJoin(pPlayer, bConfirm)
	if not self.nPreMapId then
		return false, "准备场还没开放"
	end
	local bRet, szMsg = self:CheckCommonJoin(pPlayer)
	if not bRet then
		return false, szMsg
	end
	local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	local pAssist;
	if tbTeam then
		if tbTeam:GetCaptainId() ~= pPlayer.dwID then
			return false, "只有队长可以进行此操作"
		end
		local tbMember = tbTeam:GetMembers()
		if Lib:CountTB(tbMember) ~= 2 then
			return false, "双人队伍或单人才能参加"
		end
		for _, nPlayerID in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(nPlayerID);
			if not pMember then
				return false, "对方不线上，无法参加！"
			end
			if nPlayerID ~= pPlayer.dwID then
				pAssist = pMember;
			end
		end
		if not pAssist then
			return false, "无法找到您的队友"
		end
		bRet, szMsg = self:CheckCommonJoin(pAssist)
		if not bRet then
			return false, szMsg
		end
		if not bConfirm and (self:IsRequestChooseFactionWilling(pPlayer) or self:IsRequestChooseFactionWilling(pAssist)) then
			return false, "请先完成当前操作"
		end
		local nMapId1, nX1, nY1 = pPlayer.GetWorldPos()
	    local nMapId2, nX2, nY2 = pAssist.GetWorldPos()
	    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
	    if fDists > (self.MIN_DISTANCE * self.MIN_DISTANCE) or nMapId1 ~= nMapId2 then
	        return false, "队友不在附近"
	    end
	    local nCaptainFaction = QunYingHuiCross.tbPlayerFaction[pPlayer.dwID]
	    local nMemberFaction = QunYingHuiCross.tbPlayerFaction[pAssist.dwID]
	    if nCaptainFaction and not nMemberFaction then
	    	return false, string.format("队员「%s」尚未报名，无法同时入场", pAssist.szName)
	    end
	    if not nCaptainFaction and nMemberFaction then
	    	return false, string.format("队员「%s」已经报名，无法同时入场", pAssist.szName)
	    end
	    if nCaptainFaction and nMemberFaction and nMemberFaction == nCaptainFaction then
	    	return false, "所选门派相同的侠士不可组队参加"
	    end
	end
	return true, nil, pAssist
end

function QunYingHuiCross:ClearRequestFactionData(pPlayer)
	self:ClearRequestChooseFactionWilling(pPlayer)
	self:ClearChooseFactionWilling(pPlayer)
end

function QunYingHuiCross:ClearRequestChooseFactionWilling(pPlayer)
	pPlayer.tbRequestChooseFactionWilling = pPlayer.tbRequestChooseFactionWilling or {}
	pPlayer.tbRequestChooseFactionWilling[pPlayer.dwTeamID] = nil
end

function QunYingHuiCross:GetRequestChooseFactionWilling(pPlayer)
	pPlayer.tbRequestChooseFactionWilling = pPlayer.tbRequestChooseFactionWilling or {}
	return pPlayer.tbRequestChooseFactionWilling[pPlayer.dwTeamID]
end

function QunYingHuiCross:RequestChooseFactionWilling(pPlayer)
	pPlayer.tbRequestChooseFactionWilling = pPlayer.tbRequestChooseFactionWilling or {}
	pPlayer.tbRequestChooseFactionWilling[pPlayer.dwTeamID] = GetTime()
end

-- 是否处于有效的请求时间内
function QunYingHuiCross:IsRequestChooseFactionWilling(pPlayer)
	local nRequestTime = self:GetRequestChooseFactionWilling(pPlayer)
	if nRequestTime and GetTime() - nRequestTime < QunYingHuiCross.nRequestChooseFactionTime then
		return true
	end
end

function QunYingHuiCross:ClearChooseFactionWilling(pPlayer)
	pPlayer.tbChooseFactionWilling = pPlayer.tbChooseFactionWilling or {}
	pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID] = pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID] or {}
	pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID][pPlayer.dwID] = nil
end

function QunYingHuiCross:GetChooseFactionWillingTime(pPlayer)
	pPlayer.tbChooseFactionWilling = pPlayer.tbChooseFactionWilling or {}
	pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID] = pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID] or {}
	return pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID][pPlayer.dwID]
end

function QunYingHuiCross:ConfirmChooseFactionWilling(pPlayer)
	pPlayer.tbChooseFactionWilling = pPlayer.tbChooseFactionWilling or {}
	pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID] = pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID] or {}
	pPlayer.tbChooseFactionWilling[pPlayer.dwTeamID][pPlayer.dwID] = GetTime()
end

-- 玩家是否已经确认并且确认在有效的时间内
function QunYingHuiCross:IsChooseFactionWilling(pPlayer)
	local nConfirmTime = self:GetChooseFactionWillingTime(pPlayer)
	local nRequestTime = self:GetRequestChooseFactionWilling(pPlayer)
	if nConfirmTime and nRequestTime and nConfirmTime - nRequestTime < QunYingHuiCross.nRequestChooseFactionTime then
		return true
	end 
end

-- zone server 回调	
function QunYingHuiCross:OnZoneCallBack(szFun, ...)
	if self[szFun] then
		if self:CheckOpen() then
			self[szFun](self, ...)
		else
			self:Log("fnOnClientCall no open", szFun)
		end
	else
		self:Log("fnOnClientCall fail", szFun)
	end
end

function QunYingHuiCross:OnPreStart()
	local szTimeFrame = Lib:GetMaxTimeFrame(QunYingHuiCross.tbAvatar)
	local nMaxLevel = GetMaxLevel() or 0
	CallZoneServerScript("QunYingHuiCross.tbQunYingHuiZ:PreStartFinish", szTimeFrame, nMaxLevel);
	self:Log("fnOnPreStart", szTimeFrame, nMaxLevel)
end

function QunYingHuiCross:OnStart()
	QunYingHuiCross.tbPlayerFaction = {}
    self:Log("fnOnStart");
end

-- 前n名家族公告
function QunYingHuiCross:OnRankKinMsg(dwID, nRank)
	local pStayInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
	if pStayInfo and pStayInfo.dwKinId > 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(QunYingHuiCross.szRankKinMsg, pStayInfo.szName, nRank), pStayInfo.dwKinId)
	end
end

-- 排名公告
function QunYingHuiCross:OnRankNotify(nRank, tbData)
	for _, v in ipairs(QunYingHuiCross.tbRankNotify) do
		if nRank == v.nRank then
			local szMsg = v.szMsg
			local szName = tbData.szName or ""
			KPlayer.SendWorldNotify(1, 999, string.format(szMsg, szName), 1, 1)
		end
	end
end

-- 选完门派回调
function QunYingHuiCross:OnChooseFactionFinish(dwID, nFaction)
	self.tbPlayerFaction[dwID] = nFaction
end

-- 连胜公告
function QunYingHuiCross:OnContinueWinTip(dwID, nContinueWin)
	local pStayInfo = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID)
	local tbMsg = QunYingHuiCross.tbContinueWinTip[nContinueWin]
	if tbMsg then
		for szMsgKey, szMsg in pairs(tbMsg) do
			if szMsgKey == "szKinMsg" and pStayInfo.dwKinId > 0 then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(szMsg, pStayInfo.szName), pStayInfo.dwKinId)
			end
		end
	end
end

-- 最新消息
function QunYingHuiCross:OnSendNewInfomation(tbNewInfoData)
	local nNowTime = GetTime()
	NewInformation:AddInfomation("QYHCROSS" .. nNowTime, nNowTime + QunYingHuiCross.nNewInfoValidTime, { Type1 = "QYHCROSS",Type2 = QunYingHuiCross.TYPE_NORMAL, tbList = tbNewInfoData }, {szTitle = "跨服群英会", nReqLevel = 10, szUiName = "StarTower"});
end

-- 最终奖励
function QunYingHuiCross:OnSendEndAward(tbServerPlayer)
	tbServerPlayer= tbServerPlayer or {}
	for _, tbPlayerAward in ipairs(tbServerPlayer) do
		local dwID = tbPlayerAward.dwID or 0
		local nRank = tbPlayerAward.nRank or 0
		local nWinCount = tbPlayerAward.nWinCount or 0
		local nLostCount = tbPlayerAward.nLostCount or 0
		local nFightCount = nWinCount + nLostCount
		local tbAllAward = tbPlayerAward.tbAllAward or {}
		local tbHandAward = tbPlayerAward.tbHandAward or {}
		local pStayInfo = KPlayer.GetRoleStayInfo(dwID)
		if pStayInfo then
			Lib:CallBack({Calendar.OnCompleteAct, Calendar, dwID, "QunYingHui", nWinCount})   
			tbAllAward = next(tbAllAward) and QunYingHuiCross:FormatReward(tbAllAward) or nil
			tbAllAward = tbAllAward and KPlayer:MgrAward(nil, tbAllAward)
			local szContent = ""
			if tbAllAward then
				szContent = szContent .. "尊敬的侠士：\n      您在本场群英会中"
				if nWinCount > 0 then
					szContent = szContent .. string.format("共胜利了[ff8f06]%d场[-]，获得[FFFE0D]%s[-]；", nWinCount, QunYingHuiCross:GetAwardDes(nWinCount, QunYingHuiCross.tbFightWinAward))
				end
				if nLostCount > 0 then
					szContent = szContent .. string.format("共失败了[ff8f06]%d场[-]，获得[FFFE0D]%s[-]。", nLostCount, QunYingHuiCross:GetAwardDes(nLostCount, QunYingHuiCross.tbFightLostAward))
				end
				szContent = szContent .. "上述奖励已合并派发如下，请查收。"
				if nRank <= 200 then
					szContent = szContent .. string.format("\n      与此同时，您在群英会最终结算排行中荣获[ff8f06]第%d名[-]，对应的排名奖励[ff578c]【群英会黄金宝箱】[-]也在此一并发放，请注意查收。望少侠再接再厉，再度征战群英会，勇夺桂冠！", nRank)
				else
					szContent = szContent .. string.format("\n      与此同时，您在本场群英会中憾未上榜，对应的奖励[FFFE0D]真气*500[-]也在此一并发放，请注意查收。望少侠再接再厉，再度征战群英会，勇夺桂冠！")
				end
			else
				szContent = "      抱歉少侠，您未在本场群英会中获得任何奖励，望继续努力，再创佳绩。"
			end
			local tbMail = {
							To = dwID;
							Title = "群英会结算奖励";
							From = "系统";
							Text = szContent;
							tbAttach = tbAllAward;
							nLogReazon = Env.LogWay_QYHCross;
						};
			Mail:SendSystemMail(tbMail);
			tbHandAward = next(tbHandAward) and QunYingHuiCross:FormatReward(tbHandAward) or nil
			tbHandAward = tbHandAward and KPlayer:MgrAward(nil, tbHandAward)
			if tbHandAward then
				local tbMail = {
							To = dwID;
							Title = "群英会奖励派发信件";
							From = "系统";
							Text = string.format("      恭喜侠士在本场群英会中英勇无敌，成功获得%s，具体奖励如下[FFFE0D]（少侠手动领取过的并未计入）[-]，请查收！", QunYingHuiCross:GetFightDes(nWinCount, nFightCount));
							tbAttach = tbHandAward;
							nLogReazon = Env.LogWay_QYHCross;
						};
				Mail:SendSystemMail(tbMail);
			end
			local nRedBagEventType = QunYingHuiCross.tbRankRedBag[nRank]
			if nRedBagEventType then
				-- 家族红包
				Kin:RedBagOnEvent(dwID, nRedBagEventType, nRank)
				self:Log("fnOnSendAward 1 rank ", dwID, nRank)
			end
		else
			self:Log("fnOnSendAward No pStayInfo", dwID, nRank, nWinCount, nLostCount, nFightCount, next(tbAllAward) and "true" or "false", next(tbHandAward) and "true" or "false")
		end
	end
	Calendar:OnActivityEnd("QunYingHui");
	self:Log("fnOnSendAward ok", #tbServerPlayer)
end

-- n胜奖励
function QunYingHuiCross:OnSendWinAward(dwID, nWin, tbAward)
	local tbMail = {
					To = dwID;
					Title = "群英会首胜奖励";
					From = "系统";
					Text = string.format("      恭喜侠士在群英会中大显身手，成功取得[FFFE0D]%d场胜利[-]，获得如下奖励，请查收！", nWin);
					tbAttach = tbAward;
					nLogReazon = Env.LogWay_QYHCrossWinAward;
				};
	Mail:SendSystemMail(tbMail);
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if pPlayer then
		pPlayer.CenterMsg("奖励信件已经发到邮箱", true)
	end
	self:Log("fnOnSendWinAward", dwID, nWin)
end

-- n战奖励
function QunYingHuiCross:OnSendJoinAward(dwID, nJoin, tbAward)
	local tbMail = {
					To = dwID;
					Title = "群英会十战奖励";
					From = "系统";
					Text = string.format("      恭喜侠士在群英会中能伐善战，成功完成[FFFE0D]%d场对战[-]，获得如下奖励，请查收！", nJoin);
					tbAttach = tbAward;
					nLogReazon = Env.LogWay_QYHCrossJoinAward;
				};
	Mail:SendSystemMail(tbMail);
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if pPlayer then
		pPlayer.CenterMsg("奖励已通过信件发放", true)
	end
	self:Log("fnOnSendJoinAward", dwID, nJoin)
end

function QunYingHuiCross:OnClientCall(szFun, ...)
	if self[szFun] then
		self[szFun](self, ...)
	else
		self:Log("fnOnClientCall fail", szFun)
	end
end

function QunYingHuiCross:Log(szLog, ...)
	Log("QYHCrossS ", szLog, ...)
end

function QunYingHuiCross:TLogRoundFlow(dwID, nMapTemplateId, nCostTime, nResult, nTeammate)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if pPlayer then
		pPlayer.TLogRoundFlow(Env.LogWay_QYHCross, nMapTemplateId, 0, nCostTime, nResult, nTeammate, 0);
	else
		self:Log("fnTLogRoundFlow player offline", dwID, nMapTemplateId, nCostTime, nResult, nTeammate)
	end
end

function QunYingHuiCross:OnFirstFight(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if pPlayer then
		EverydayTarget:AddCount(pPlayer, "QunYingHui");
	else
		self:Log("fnOnFirstFight Player Offline", dwID)
	end
end

function QunYingHuiCross:OnWinFight(dwID, nWin)
	local szAchievement = self.tbAchievement[nWin];
    if szAchievement then
    	local pStayInfo = KPlayer.GetRoleStayInfo(dwID or 0)
    	if pStayInfo then
    		Achievement:AddCount(dwID, szAchievement, 1);
    	else
    		self:Log("fnOnFirstFight No Player", dwID, nWin)
    	end
        
    end
end

