QunYingHuiCross.QYHCrossFight = QunYingHuiCross.QYHCrossFight or {}
local QYHCrossFight = QunYingHuiCross.QYHCrossFight

function QYHCrossFight:OnCreate()
	self.tbPlayer = {}
	self.tbCamp = {}
	self.tbDeathCamp = {}
	self.tbPlayerKill = {} 																		-- 玩家的连斩数
	self.tbDismissTeam = {}
	self.tbAllNpc = {}
	self.tbDmgInfo = {{nTotalDmg = 0, nKillCount = 0}, {nTotalDmg = 0, nKillCount = 0}} 		-- 阵营的输出和杀敌数
	self.nStartTime = GetTime();
	self.nUpdateDmgTime = nil
	self:InitNpcSelect()
	local szLog = self:GetLogPlayer()
	if self.nMapId and QunYingHuiCross.nPkDmgRate then
		SetMapPKDmgRate(self.nMapId, QunYingHuiCross.nPkDmgRate)
	end
	self:Log("fnOnCreate", szLog)
end

function QYHCrossFight:InitNpcSelect()
	local nNpcCount = #QunYingHuiCross.NPC_SETTING
	if nNpcCount > 0 then
		self.fnNpcSelect = Lib:GetRandomSelect(nNpcCount)
	end
end

function QYHCrossFight:GetLogPlayer()
	local szLog = ""
	for dwID, nCamp in pairs(self.tbCampPlayer) do
		local szTeamId = ""
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			szTeamId = pPlayer.dwTeamID
		end
		szLog = szLog .."Id:" ..dwID .."Camp:" ..nCamp .."TeamID:" ..szTeamId
	end
	return szLog
end	

function QYHCrossFight:OnClose()
	self.bStart = nil
	self:CloseAllTimer()
	self:Log("fnOnClose")
end

function QYHCrossFight:OnEnter(pPlayer)
	local nCamp = self.tbCampPlayer[pPlayer.dwID]
	if not nCamp then
		self:Log("fnOnEnter no camp!!!", pPlayer.dwID, pPlayer.szName, pPlayer.dwTeamID)
 		return
	end
	if not self.tbPlayer[pPlayer.dwID] then
		self:RegisterEvent(pPlayer)
	end
	self.tbPlayer[pPlayer.dwID] = nCamp
	self.tbCamp[nCamp] = self.tbCamp[nCamp] or {}
	table.insert(self.tbCamp[nCamp], pPlayer.dwID)
	ActionMode:DoForceNoneActMode(pPlayer)
	self:SetPreState(pPlayer)
	self:UpdatePlayerUi(pPlayer)
	-- 所有玩家都已经进入地图
	if Lib:CountTB(self.tbPlayer) == 2 * QunYingHuiCross.nFightPlayerNum then
		self:UpdateMatchState(QunYingHuiCross.STATE_FIGHT)
		self:SetStartPos()
		self.bStart = true
		self:ExecuteSchedule()
		self:InitDismissData()
	end
	pPlayer.CallClientScript("QunYingHuiCross:OnEnterFight")
	--self:Log("fnOnEnter", pPlayer.dwID, pPlayer.szName, pPlayer.dwTeamID, nCamp)
end

function QYHCrossFight:InitDismissData()
	local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
	if not tbPrLogic then
		self:Log("fnInitDismissData")
		return
	end
	for nCamp, tbPlayerId in pairs(self.tbCamp) do
		for i, nPlayerId in ipairs(tbPlayerId) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pPlayer then
				local tbPlayerData = tbPrLogic:GetPlayer(pPlayer.dwID)
				if tbPlayerData.nType == QunYingHuiCross.TYPE_SINGLE then
					local nTeammateId = self:GetTeammateId(nCamp, nPlayerId)
					local tbContinuePlayer = pPlayer.tbQYHContinuePlayer or {}
					local nTeamId = tbContinuePlayer[nTeammateId] or -1
					if nTeamId ~= pPlayer.dwTeamID then
						-- 默认解散
						self.tbDismissTeam[nPlayerId] = true
					end
				end
			end
		end
	end
end

function QYHCrossFight:GetTeammateId(nCamp, nPlayerId)
	local nTeammateId = 0
	local tbPlayerId = self.tbCamp[nCamp] or {}
	for _, dwID in pairs(tbPlayerId) do
		if nPlayerId ~= dwID then
			nTeammateId = dwID
			break
		end
	end
	return nTeammateId
end

function QYHCrossFight:UpdateMatchState(nState)
	local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
	if not tbPrLogic then
		self:Log("fnUpdateMatchState")
		return
	end
	for dwID in pairs(self.tbPlayer) do
		local tbPlayerInfo = tbPrLogic:GetPlayer(dwID)
		if tbPlayerInfo.nState ~= nState then
			tbPlayerInfo.nState = nState
			if nState == QunYingHuiCross.STATE_MATCHING then
				local bMax = tbPrLogic:CheckMaxFight(dwID)
				if bMax then
					tbPrLogic:DoCancelMatch(dwID)
				end
			end
		end
	end
end

function QYHCrossFight:ExecuteSchedule()
	self.nMainTimer = nil;
	self.nSchedulePos = (self.nSchedulePos or 0) + 1
	local tbCurSchedule = QunYingHuiCross.STATE_TRANS[self.nSchedulePos]
	if not tbCurSchedule then
		return
	end
	--self:Log("fnExecuteSchedule", self.nSchedulePos, tbCurSchedule.nSeconds or 0, tbCurSchedule.szDesc or "nil")
	self.szStateInfo = tbCurSchedule.szDesc;
	self[tbCurSchedule.szFunc](self)
	if tbCurSchedule.nSeconds < 0 then
		return
	end
	if not QunYingHuiCross.STATE_TRANS[self.nSchedulePos + 1] then --后面没有timer 就断了
		return;
	end
	local function fnSyncFightState(self, pPlayer)
	    self:SyncPlayerLeftInfo(pPlayer);
	    pPlayer.CallClientScript("QunYingHuiCross:SyncFightState", tbCurSchedule.nSeconds);
	end
	self:ForeachPlayer(fnSyncFightState)
	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbCurSchedule.nSeconds, self.ExecuteSchedule, self)
end

function QYHCrossFight:ExecuteNpcSchedule()
	self.nNpcTimer = nil;
	self.nNpcSchedulePos = (self.nNpcSchedulePos or 0) + 1
	local tbCurSchedule = QunYingHuiCross.NPC_TRANS[self.nNpcSchedulePos]
	if not tbCurSchedule then
		return
	end
	--self:Log("fnExecuteNpcSchedule", self.nNpcSchedulePos, tbCurSchedule.nSeconds or 0)
	self[tbCurSchedule.szFunc](self, tbCurSchedule.tbParam)
	if tbCurSchedule.nSeconds < 0 then
		return
	end
	if not QunYingHuiCross.NPC_TRANS[self.nNpcSchedulePos + 1] then --后面没有timer 就断了
		return;
	end
	self.nNpcTimer = Timer:Register(Env.GAME_FPS * tbCurSchedule.nSeconds, self.ExecuteNpcSchedule, self)
end

function QYHCrossFight:RandomNpc(tbParam)
	local nCount = (tbParam or {}).nCount
	if not nCount or nCount < 1 then
		self:Log("fnRandomNpc valid count", nCount)
		return
	end
	if not self.fnNpcSelect then
		self:Log("fnRandomNpc valid fnNpcSelect")
		return
	end
	for i = 1, nCount do
		local nSelect = self.fnNpcSelect()
		local tbNpcInfo = QunYingHuiCross.NPC_SETTING[nSelect]
		if tbNpcInfo then
			local nPosX = tbNpcInfo.tbPos[1]
			local nPosY = tbNpcInfo.tbPos[2]
			local pNpc = KNpc.Add(tbNpcInfo.nNpcTId, tbNpcInfo.nNpcLevel or 1, -1, self.nMapId, nPosX, nPosY, 0);
			if pNpc then
				if tbNpcInfo.nSkillId then
					pNpc.CastSkill(tbNpcInfo.nSkillId, 1, nPosX, nPosY);
				end
				self.tbAllNpc = self.tbAllNpc or {}
				table.insert(self.tbAllNpc, pNpc.nId)
				self:Log("fnRandomNpc ok", nSelect, tbNpcInfo.nNpcTId, pNpc.nId, nCount, nPosX, nPosY, tbNpcInfo.nSkillId or "nil")
			else
				self:Log("fnRandomNpc no npc", tbNpcInfo.nNpcTId, nPosX, nPosY, nCount) 
			end
		else
			self:Log("fnRandomNpc valid tbNpcInfo", nSelect)
		end
	end
end

function QYHCrossFight:ClearNpc()
	for _, nNpcId in ipairs(self.tbAllNpc) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			pNpc.Delete()
		end
	end
end

function QYHCrossFight:SyncPlayerLeftInfo(pPlayer)
	local tbDmgInfo = {
		szStateInfo = self.szStateInfo or "--",
		[1] = {nTotalDmg = self.tbDmgInfo[1].nTotalDmg, nKillCount = self.tbDmgInfo[1].nKillCount},
		[2] = {nTotalDmg = self.tbDmgInfo[2].nTotalDmg, nKillCount = self.tbDmgInfo[2].nKillCount},
	};
	pPlayer.CallClientScript("QunYingHuiCross:SyncPlayerLeftInfo", self.tbPlayer[pPlayer.dwID], tbDmgInfo);
end

function QYHCrossFight:PlayerReady()

end

function QYHCrossFight:PlayerAvatar()
	-- local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
	-- if not tbPrLogic then
	-- 	self:Log("fnPlayerAvatar")
	-- 	return
	-- end
	-- for dwID, nCamp in pairs(self.tbPlayer) do
	-- 	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	-- 	if pPlayer then
	-- 		local tbPlayerData = tbPrLogic:GetPlayer(dwID)
	-- 		if tbPlayerData.nFaction ~= 0 then
	-- 			local tbAvatarInfo = QunYingHuiCross.tbAvatar[self.szTimeFrame] or QunYingHuiCross.tbDefaultAvatar
	-- 			Player:ChangePlayer2Avatar(pPlayer, tbPlayerData.nFaction, tbAvatarInfo.nLevel, tbAvatarInfo.szEquipKey, tbAvatarInfo.szInsetKey, tbAvatarInfo.nStrengthLevel)
	-- 		end
	-- 	end
	-- end
end

function QYHCrossFight:SetPlayerDmgCounter(pPlayer, bStart)
	local pPlayerNpc = pPlayer.GetNpc();
	if bStart then
		pPlayerNpc.StartDamageCounter();
	else
		pPlayerNpc.StopDamageCounter();
	end
end

function QYHCrossFight:StartFight()
	local function fnStartFight(self, pPlayer)
		self:SetPlayerDmgCounter(pPlayer, true)
		local nCamp = self.tbPlayer[pPlayer.dwID]
		if nCamp then
			pPlayer.nFightMode = 1;
			pPlayer.SetPkMode(3, nCamp);
		else
			self:Log("fnStartFight no camp", pPlayer.dwID, pPlayer.szName)
		end
	end
	if not self.nUpdateDmgTime then
		self.nUpdateDmgTime = Timer:Register(Env.GAME_FPS * 2, self.UpdateAllPlayerDmg, self);
	end

	self:ForeachPlayer(fnStartFight)
	self:ExecuteNpcSchedule()
end

function QYHCrossFight:ClcResult()
	if not self.bStart then
		self:Log("fnClcResult no start")
		return
	end
	self.bClcResult = true
	self:CloseAllTimer()
	self:ClearNpc()
	local nCostTime = GetTime() - self.nStartTime;
	self.szStateInfo = "比赛结束";
	self.bStart = false
	self:UpdateAllPlayerDmg();
	local nWinCamp = 1;
	if self.tbDmgInfo[2].nKillCount > self.tbDmgInfo[1].nKillCount or
		(self.tbDmgInfo[2].nKillCount == self.tbDmgInfo[1].nKillCount and self.tbDmgInfo[2].nTotalDmg >= self.tbDmgInfo[1].nTotalDmg) then

		nWinCamp = 2;
	end
	self:UpdatePlayerData(nWinCamp, nCostTime)
	local function fnResult(self, pPlayer)
		local nCamp = self.tbPlayer[pPlayer.dwID]
		if not nCamp then
			return 
		end
		self:ClearState(pPlayer)
		local nResult = nCamp == nWinCamp and Env.LogRound_SUCCESS or Env.LogRound_FAIL;
		self:TLog(pPlayer, nCostTime, nResult)
		-- if nCamp == nWinCamp then
		-- 	local szMsg = "恭喜您赢得了比赛"
		-- 	pPlayer.Msg(szMsg)
		-- 	Dialog:SendBlackBoardMsg(pPlayer, szMsg)
		-- elseif pPlayer.dwID == nLostPlayerId then
		-- 	local szMsg = "您输了，再接再厉！"
		-- 	pPlayer.Msg(szMsg)
		-- 	Dialog:SendBlackBoardMsg(pPlayer, szMsg)
		-- end
	end
	self:ForeachPlayer(fnResult)
	
	local fnLeave = function (self)
		self:ClearFight()
	end
	self.nDelayLeaveTimer = Timer:Register(Env.GAME_FPS * QunYingHuiCross.nDealyLeaveTime, fnLeave, self)
	self.szStateInfo = "即将离开"
	self:ForeachPlayer(self.UpdatePlayerUi);

	self:ShowTeamInfo(nWinCamp)
	--local szLog = self:GetLogPlayer()
	self:Log("fnClcResult", nWinCamp, nCostTime)
end

function QYHCrossFight:TLog(pPlayer, nCostTime, nResult)
	local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
	if not tbPrLogic then
		self:Log("fnTLog", pPlayer.dwID, pPlayer.szName, nCostTime, nResult)
		return
	end
	local tbPlayerData = tbPrLogic:GetPlayer(pPlayer.dwID)
	local nConnectIdx = tbPrLogic:GetConnectIdx(tbPlayerData)
	if nConnectIdx then
		local nTeammate = self:GetTeammate(pPlayer) or 0
		CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "TLogRoundFlow", pPlayer.dwOrgPlayerId, pPlayer.nMapTemplateId, nCostTime, nResult, nTeammate)
	end
end

function QYHCrossFight:GetTeammate(pPlayer)
	local nCamp = self.tbPlayer[pPlayer.dwID] or -1
	local tbCampPlayer = self.tbCamp[nCamp] or {}
	local nTeammate = 0
	for _, dwID in ipairs(tbCampPlayer) do
		if dwID ~= pPlayer.dwID then
			nTeammate = dwID
		end
	end
	return nTeammate
end

function QYHCrossFight:TryKeepTeam(pPlayer)
	if pPlayer.nMapId ~= self.nMapId then
		return
	end
	if not self.bClcResult then
		return
	end
	if not self.tbDismissTeam[pPlayer.dwID] then
		pPlayer.CenterMsg("已经完成组队邀请", true)
		return
	end
	local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if not tbTeam then
		pPlayer.CenterMsg("请先组成两人队伍", true)
		return
	end
	local bMeRequest = self:CheckRequestingKeepTeam(pPlayer)
	if bMeRequest then
		pPlayer.CenterMsg("请等待处理完成", true)
		return
	end
	local tbMember = tbTeam:GetMembers()
	local nMemberCount = Lib:CountTB(tbMember)
	if nMemberCount ~= QunYingHuiCross.nFightPlayerNum then
		pPlayer.CenterMsg(string.format("请先组成%d人队伍", QunYingHuiCross.nFightPlayerNum), true)
		return
	end
	local pAssist 
	for _, nPlayerID in pairs(tbMember) do
		local pMember = KPlayer.GetPlayerObjById(nPlayerID);
		if not pMember then
			pPlayer.CenterMsg("对方未在线", true)
			return
		end
		if nPlayerID ~= pPlayer.dwID then
			pAssist = pMember;
		end
	end
	if not pAssist then
		pPlayer.CenterMsg("找不到你的队友", true)
		return
	end
	local bAssistRequest = self:CheckRequestingKeepTeam(pAssist)
	local nRequestId = pPlayer.dwID
	local nResponseId = pAssist.dwID
	-- 同意对方的请求
	if bAssistRequest then
		self:ContinueFight(pPlayer, nResponseId)
		self:ContinueFight(pAssist, nRequestId)
		pPlayer.CenterMsg("同意成功", true)
		pAssist.CenterMsg(string.format("「%s」同意了你的组队邀请，即将进行下一场匹配", pPlayer.szName), true)
		self:Log("fnTryKeepTeam ", pPlayer.dwID, pPlayer.szName, pPlayer.dwTeamID, pAssist.dwID, pAssist.szName, pAssist.dwTeamID)
	else
		local fnAgree = function (self, dwID)
		    local pPlayer = KPlayer.GetPlayerObjById(dwID)
		    if not pPlayer then
               return
		    end
			self:TryKeepTeam(pPlayer)
		end
		local fnRefuse = function (self, nRefuseId, nRequestpPlayerId)
			local pRefuser = KPlayer.GetPlayerObjById(nRefuseId)
			if pRefuser.nMapId ~= self.nMapId then
				return
			end
			local pRequester = KPlayer.GetPlayerObjById(nRequestpPlayerId)
			if pRequester then
				pRequester.CenterMsg(string.format("抱歉，「%s」拒绝了你的组队邀请", pRefuser and pRefuser.szName or ""), true)
				self:ClearRequestKeepTeam(pRequester)
				if pRefuser then
					self:ClearRequestKeepTeam(pRefuser)
				end
			end
		end
		local fnOverTime = function()
			if me then
				if me.nMapId ~= self.nMapId then
					return 
				end
				me.CenterMsg("已自动拒绝", true)
				me.CallClientScript("Ui:CloseWindow", "MessageBox")
				local pRequester = KPlayer.GetPlayerObjById(nRequestId or 0)
				if pRequester then
					pRequester.CenterMsg(string.format("抱歉，「%s」拒绝了你的组队邀请", me.szName), true)
				end 
			end
		end
		pAssist.MsgBox(string.format("[FFFE0D]「%s」[-]邀请你继续组队共同战斗，是否同意？", pPlayer.szName)  .."\n（%d秒後自动拒绝）", {{"同意", fnAgree, self, nResponseId}, {"取消", fnRefuse, self, nResponseId, nRequestId}}, nil, QunYingHuiCross.nKeepTeamWaitTime, fnOverTime)
		self:RequestKeepTeam(pPlayer)
		pPlayer.CenterMsg(string.format("已向「%s」发出组队邀请", pAssist.szName), true)
	end
end

function QYHCrossFight:RequestKeepTeam(pPlayer)
	pPlayer.nRequestKeepTeamTime = GetTime()
end

function QYHCrossFight:ClearRequestKeepTeam(pPlayer)
	pPlayer.nRequestKeepTeamTime = nil
end


function QYHCrossFight:CheckRequestingKeepTeam(pPlayer)
	if pPlayer.nRequestKeepTeamTime and GetTime() < pPlayer.nRequestKeepTeamTime + QunYingHuiCross.nKeepTeamWaitTime then
		return true
	end
end

function QYHCrossFight:ContinueFight(pPlayer, nTeammateId)
	self.tbDismissTeam[pPlayer.dwID] = nil
	pPlayer.tbQYHContinuePlayer = pPlayer.tbQYHContinuePlayer or {}
	pPlayer.tbQYHContinuePlayer[nTeammateId] = pPlayer.dwTeamID
end

function QYHCrossFight:UpdatePlayerData(nWinCamp, nCostTime)
	local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
	if not tbPrLogic then
		self:Log("fnUpdatePlayerData", nWinCamp)
		return
	end
	local nNowTime = GetTime()
	tbPrLogic.bPlayerDataChange = true
	for dwID, nCamp in pairs(self.tbPlayer) do
		local tbPlayerData = tbPrLogic:GetPlayer(dwID)
		local nConnectIdx = tbPrLogic:GetConnectIdx(tbPlayerData)
		local nOrgPlayerId =  QunYingHuiCross:RestoreUniqId(tbPrLogic:GetUniqID(dwID))
		tbPlayerData.nFightCount = tbPlayerData.nFightCount + 1
		if tbPlayerData.nFightCount == 1 and nConnectIdx then
			CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnFirstFight", nOrgPlayerId)
		end
		if nCamp == nWinCamp then
			tbPlayerData.nWinCount = tbPlayerData.nWinCount + 1
			tbPlayerData.nContinueWin = tbPlayerData.nContinueWin + 1
			if QunYingHuiCross.tbAchievement[tbPlayerData.nWinCount] then
				CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnWinFight", nOrgPlayerId, tbPlayerData.nWinCount)
			end
		else
			tbPlayerData.nContinueWin = 0
		end
		tbPlayerData.nWinRate = tbPlayerData.nWinCount / tbPlayerData.nFightCount
		tbPlayerData.nGetRateTime = nNowTime
		tbPlayerData.nFightTime = tbPlayerData.nFightTime + nCostTime
		local nOtherCampId = 3 - nCamp;
		local tbOtherPlayerId = self.tbCamp[nOtherCampId]
		if tbOtherPlayerId and (QunYingHuiCross.nNearFightCount or 0) > 0 then
			if #tbPlayerData.tbNearFight >= QunYingHuiCross.nNearFightCount then
				table.remove(tbPlayerData.tbNearFight, 1)
			end
			local tbPlayerUniqId = {}
			for _, dwID in ipairs(tbOtherPlayerId) do
				table.insert(tbPlayerUniqId, tbPrLogic:GetUniqID(dwID))
			end
			table.insert(tbPlayerData.tbNearFight, tbPlayerUniqId)
		end
		-- 连胜公告
		if QunYingHuiCross.tbContinueWinTip[tbPlayerData.nContinueWin] and not tbPlayerData.tbContinueWinNotify[tbPlayerData.nContinueWin] then
			if nConnectIdx then
				tbPlayerData.tbContinueWinNotify[tbPlayerData.nContinueWin] = nNowTime
				CallZoneClientScript(nConnectIdx, "QunYingHuiCross:OnZoneCallBack", "OnContinueWinTip", nOrgPlayerId, tbPlayerData.nContinueWin)
			else
				self:Log("ContinueWinTip ConnectIdx nil", dwID, tbPlayerData.nContinueWin)
			end
			
		end
	end

end

function QYHCrossFight:ShowTeamInfo(nWinCamp)
	self.tbCurCampInfo = {};
	
	local function fnGetPlayerInfo(self, pPlayer)
		local nCamp = self.tbPlayer[pPlayer.dwID];
		if not nCamp then
			return 
		end
		self.tbCurCampInfo[nCamp] = self.tbCurCampInfo[nCamp] or {};

		local nDamage, nKillCount, nFightPower = 0, 0, 0
		if nWinCamp then
			if self.tbDmgInfo[nCamp] then
				if self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] then
					nDamage = self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID].nDamage;
				end
				if self.tbDmgInfo[nCamp].tbPlayerKillCount then
					nKillCount = self.tbDmgInfo[nCamp].tbPlayerKillCount[pPlayer.dwID] or 0;
				end
			end
			nFightPower = pPlayer.GetFightPower()
		else
			local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
			if tbPrLogic then
				local tbPlayerData = tbPrLogic:GetPlayer(pPlayer.dwID)
				local nWinCount = tbPlayerData.nWinCount or 0
				local nFightCount = tbPlayerData.nFightCount or 0
				nFightPower = string.format("%s/%s([FFFE0D]%s[-])", nWinCount, nFightCount, string.format("%.2f%%", (nFightCount == 0 and 0 or (nWinCount / nFightCount * 100))))
			end
		end
		local nPortrait = PlayerPortrait:GetDefaultId(pPlayer.nFaction, pPlayer.nSex)
		table.insert(self.tbCurCampInfo[nCamp], {
			szName		= pPlayer.szName,
			nPortrait	= nPortrait,
			nLevel		= pPlayer.nLevel,
			nHonorLevel	= pPlayer.nHonorLevel,
			nFaction	= pPlayer.nFaction,
			nFightPower	= nFightPower,
			nDamage = nDamage,
			nKillCount = nKillCount,
		});
	end
	self:ForeachPlayer(fnGetPlayerInfo)

	local function fnShowInfo(self,pPlayer)
		local nCamp = self.tbPlayer[pPlayer.dwID];
		if not nCamp then
			return 
		end
		local bCanContinue = self.tbDismissTeam[pPlayer.dwID]
		if nWinCamp then
			pPlayer.CallClientScript("QunYingHuiCross:OnShowTeamInfo", nCamp, self.tbCurCampInfo, nWinCamp, QunYingHuiCross.nTeamInfoStayTime, bCanContinue);
		else
			pPlayer.CallClientScript("QunYingHuiCross:OnShowTeamInfo", nCamp, self.tbCurCampInfo);
		end
		
	end
	self:ForeachPlayer(fnShowInfo)
end

function QYHCrossFight:UpdatePlayerDmg(pPlayer)
	local nCamp = self.tbPlayer[pPlayer.dwID];
	if not nCamp then
		return;
	end

	self.tbDmgInfo[nCamp].tbPlayerDmg = self.tbDmgInfo[nCamp].tbPlayerDmg or {};
	self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] = self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] or {nDamage = 0};

	local tbLastCounter = self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID];
	local tbCounter = pPlayer.GetNpc().GetDamageCounter();
	self.tbDmgInfo[nCamp].tbPlayerDmg[pPlayer.dwID] = tbCounter;
	self.tbDmgInfo[nCamp].nTotalDmg = self.tbDmgInfo[nCamp].nTotalDmg - tbLastCounter.nDamage + tbCounter.nDamage;
end

function QYHCrossFight:UpdateAllPlayerDmg()
	self:ForeachPlayer(self.UpdatePlayerDmg);
	self:ForeachPlayer(self.SyncPlayerLeftInfo);
	return self.bStart;
end

function QYHCrossFight:StartCountDown()
	local function fnStartCountDown(self, pPlayer)
		pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
	end
	self:ForeachPlayer(fnStartCountDown)
end

function QYHCrossFight:ForeachPlayer(fnFunc,...)
	for dwID,_ in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer and pPlayer.nMapId == self.nMapId then
			Lib:CallBack({fnFunc, self, pPlayer, ...});
		end
	end
end

function QYHCrossFight:ClearFight()
	-- 不建议手动离开，建议延迟一起离开，因为离开会更新为匹配状态
	-- 如果手动离开，同一队伍只有一个人为匹配状态，在匹配检测的时候会解散该队伍
	local tbMapPlayer = KPlayer.GetMapPlayer(self.nMapId) or {}
	for _, pPlayer in ipairs(tbMapPlayer) do
		pPlayer.SwitchMap(self.nPreMapId, 0, 0)
	end
end

-- 设置准备状态
function QYHCrossFight:SetPreState(pPlayer)
	pPlayer.nInBattleState = 1
	pPlayer.SetPkMode(0);
	pPlayer.nFightMode = 0;
end

-- 设置玩家开始位置
function QYHCrossFight:SetStartPos()
	for nCamp, tbPlayerId in pairs(self.tbCamp) do
		local tbCampPos = QunYingHuiCross.tbFightStartPos[nCamp]
		if tbCampPos and #tbCampPos > 0 then
			local fnSelect = Lib:GetRandomSelect(#tbCampPos)
			for _, dwID in ipairs(tbPlayerId) do
				local pPlayer = KPlayer.GetPlayerObjById(dwID)
				if pPlayer then
					local tbPosInfo = tbCampPos[fnSelect()]
					local tbPos = tbPosInfo[1]
					local nDir = tbPosInfo[2]
					if tbPos then
						pPlayer.SetPosition(unpack(tbPos))
					end
					if nDir then
						local pNpc = pPlayer.GetNpc();
						if pNpc then
							pNpc.SetDir(nDir);
						end
					end
				end
			end
		end
	end
end

function QYHCrossFight:OnPlayerDeath(pKiller)
	if not self.bStart then
		self:Log("fnOnPlayerDeath no start", me.dwID, me.szName)
		return
	end
	local nCamp = self.tbPlayer[me.dwID]
	if not nCamp then
		self:Log("fnOnPlayerDeath no camp", me.dwID, me.szName)
		return
	end
	-- 阵营死了几个人
	self.tbDeathCamp[nCamp] = (self.tbDeathCamp[nCamp] or 0) + 1
	local nKillCamp = nCamp == 1 and 2 or 1;
	local nKillID,nKillName
	if pKiller then
		local pKillPlayer = pKiller.GetPlayer();
		if pKillPlayer then
			self.tbDmgInfo[nKillCamp].tbPlayerKillCount = self.tbDmgInfo[nKillCamp].tbPlayerKillCount or {};
			self.tbDmgInfo[nKillCamp].tbPlayerKillCount[pKillPlayer.dwID] = (self.tbDmgInfo[nKillCamp].tbPlayerKillCount[pKillPlayer.dwID] or 0) + 1;
			
			self.tbPlayerKill[pKillPlayer.dwID] = (self.tbPlayerKill[pKillPlayer.dwID] or 0) + 1
			
			nKillID = pKillPlayer.dwID
			nKillName = pKillPlayer.szName
		end
	end
	self.tbPlayerKill[me.dwID] = 0 				-- 待定
	self.tbDmgInfo[nKillCamp].nKillCount = self.tbDmgInfo[nKillCamp].nKillCount + 1;
	self:OnDeathState(me)
	self:Log("fnOnPlayerDeath", me.dwID, me.szName, nKillID or -1, nKillName or "nil", nCamp, nKillCamp)
	if self.tbDeathCamp[nCamp] >= QunYingHuiCross.nFightPlayerNum then
		self:ClcResult();
	end
end

function QYHCrossFight:OnDeathState(pPlayer)
	pPlayer.Revive(1);
	pPlayer.SetPkMode(0);
	pPlayer.RestoreAll();
	pPlayer.nFightMode = 2;
	pPlayer.AddSkillState(QunYingHuiCross.nDeathSkillState, 1, 0, 10000);
end

function QYHCrossFight:UpdatePlayerUi(pPlayer)
	local nCamp = self.tbPlayer[pPlayer.dwID]
	if not nCamp then
		self:Log("fnUpdatePlayerUi no camp", pPlayer.dwID, pPlayer.dwTeamID, pPlayer.szName)
		return
	end	
	local nRestTime = 0;
	if self.bStart then 		-- 战斗中
		if self.nMainTimer then
			nRestTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS);
		end
		pPlayer.CallClientScript("QunYingHuiCross:OnFightingState", nRestTime)
		self:SyncPlayerLeftInfo(pPlayer);
	else
		if self.nDelayLeaveTimer then
			nRestTime = math.floor(Timer:GetRestTime(self.nDelayLeaveTimer) / Env.GAME_FPS);
		end
		pPlayer.CallClientScript("QunYingHuiCross:OnFightingState", nRestTime)
		self:SyncPlayerLeftInfo(pPlayer);
	end
end

function QYHCrossFight:OnLeave(pPlayer)
	pPlayer.nInBattleState = 0
	self:ClearState(pPlayer)
	self:UnRegisterEvent(pPlayer)
	self:TryDismissTeam(pPlayer)
	self:ClearRequestKeepTeam(pPlayer)
	pPlayer.CallClientScript("QunYingHuiCross:OnLeaveFight")
	--self:Log("fnOnLeave", pPlayer.dwID, pPlayer.szName, pPlayer.dwTeamID)
end

function QYHCrossFight:TryDismissTeam(pPlayer)
	local tbPrLogic = QunYingHuiCross.tbQunYingHuiZ:GetPreMapLogic(self.nPreMapId) 
	if tbPrLogic then
		-- 单人不组队的解散
		if self.tbDismissTeam[pPlayer.dwID] then
			tbPrLogic:DoDismissTeam(pPlayer)
		end
		-- 达到最大场次的解散
		tbPrLogic:DoDismissMaxFightTeam(pPlayer)
		-- 如果准备场还处于可匹配阶段，默认开启匹配，否则不开启
		if tbPrLogic.nStartMatch ~= QunYingHuiCross.MATCH_OPEN then
			self:UpdateMatchState(QunYingHuiCross.STATE_NONE)
		else
			self:UpdateMatchState(QunYingHuiCross.STATE_MATCHING)
		end
	end
end

function QYHCrossFight:ClearState(pPlayer)
	pPlayer.Revive(1);
	pPlayer.SetPkMode(0);
	pPlayer.RestoreAll();
	pPlayer.nFightMode = 0;
	pPlayer.RemoveSkillState(QunYingHuiCross.nDeathSkillState);
	self:SetPlayerDmgCounter(pPlayer, false)
end

function QYHCrossFight:CloseAllTimer()
	self:CloseMainSchedule()
	self:CloseDmgSchedule()
	self:CloseNpcSchedule()
end

function QYHCrossFight:CloseMainSchedule()
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
end

function QYHCrossFight:CloseDmgSchedule()
	if self.nUpdateDmgTime then
		Timer:Close(self.nUpdateDmgTime)
		self.nUpdateDmgTime = nil
	end
end

function QYHCrossFight:CloseNpcSchedule()
	if self.nNpcTimer then
		Timer:Close(self.nNpcTimer)
		self.nNpcTimer = nil
	end
end

function QYHCrossFight:OnPlayerLogin(bReconnect)
	if me.nMapId ~= self.nMapId then
		return
	end
	local nWait = bReconnect and Env.GAME_FPS or (Env.GAME_FPS * 3)
	Timer:Register(nWait, function (self, nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer or not pPlayer.nMapId ~= self.nMapId then
			return;
		end
		self:UpdatePlayerUi(pPlayer);
	end, self, me.dwID);
end

function QYHCrossFight:OnPlayerLogout()
	local nCamp = self.tbPlayer[me.dwID]
	if not nCamp then
		self:Log("fnOnPlayerLogout no camp", me.dwID, me.szName)
		return
	end
	-- 阵营死了几个人(下线相当于死亡)
	local nKillCamp = nCamp == 1 and 2 or 1;
	self.tbDmgInfo[nKillCamp] = self.tbDmgInfo[nKillCamp] or {}
	self.tbDmgInfo[nKillCamp].nKillCount = (self.tbDmgInfo[nKillCamp].nKillCount or 0) + 1;
	self.tbDeathCamp[nCamp] = (self.tbDeathCamp[nCamp] or 0) + 1
	if self.tbDeathCamp[nCamp] >= QunYingHuiCross.nFightPlayerNum then
		self:ClcResult();
	end
	self:Log("fnOnPlayerLogout", me.dwID, me.szName, me.dwTeamID, me.dwOrgPlayerId, nCamp)
end

function QYHCrossFight:UnRegisterEvent(pPlayer)
	self.tbRegisterInfo = self.tbRegisterInfo or {};
	if self.tbRegisterInfo[pPlayer.dwID] then
		if self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID then
			PlayerEvent:UnRegister(pPlayer, "OnDeath", self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID);
		end
		if self.tbRegisterInfo[pPlayer.dwID].nOnLoginRegID then
			PlayerEvent:UnRegister(pPlayer, "OnLogin", self.tbRegisterInfo[pPlayer.dwID].nOnLoginRegID);
		end
		if self.tbRegisterInfo[pPlayer.dwID].nOnLogoutRegID then
			PlayerEvent:UnRegister(pPlayer, "OnLogout", self.tbRegisterInfo[pPlayer.dwID].nOnLogoutRegID);
		end
		if self.tbRegisterInfo[pPlayer.dwID].nOnReConnectRegID then
			PlayerEvent:UnRegister(pPlayer, "OnReConnect", self.tbRegisterInfo[pPlayer.dwID].nOnReConnectRegID);
		end
	end
	self.tbRegisterInfo[pPlayer.dwID] = nil;
end

function QYHCrossFight:RegisterEvent(pPlayer)
	self.tbRegisterInfo = self.tbRegisterInfo or {};
	self.tbRegisterInfo[pPlayer.dwID] = {};
	self.tbRegisterInfo[pPlayer.dwID].nOnDeathRegID = PlayerEvent:Register(pPlayer, "OnDeath", function(pKiller) self:OnPlayerDeath(pKiller); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnLoginRegID = PlayerEvent:Register(pPlayer, "OnLogin", function() self:OnPlayerLogin(); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnLogoutRegID = PlayerEvent:Register(pPlayer, "OnLogout", function() self:OnPlayerLogout(); end);
	self.tbRegisterInfo[pPlayer.dwID].nOnReConnectRegID = PlayerEvent:Register(pPlayer, "OnReConnect", function() self:OnPlayerLogin(1); end);
end

function QYHCrossFight:Log(szLog, ...)
	Log("QYHCrossFight ", szLog, self.nMapId, self.nPreMapId, self.szTimeFrame, ...)
end