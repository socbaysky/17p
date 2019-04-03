if not MODULE_ZONESERVER then
	return
end

local tbDefine = InDifferBattle.tbDefine;

InDifferBattle.tbMapInst = InDifferBattle.tbMapInst or {} --放的是实际实例
InDifferBattle.tbInGamePlayers = InDifferBattle.tbInGamePlayers or {};
InDifferBattle.tbRoleZoneIndex = InDifferBattle.tbRoleZoneIndex or {}; 


function InDifferBattle:OpenSignUp(szType) --nIndex 是第几个战场图
	szType = szType or "Normal"
	if self.tbReadyMapTypes then
		for nReadyMapId,v in ipairs(self.tbReadyMapTypes) do
			local tbPlayers = KPlayer.GetMapPlayer(nReadyMapId) 	
			for i, pPlayer in ipairs(tbPlayers) do
				pPlayer.ZoneLogout();
			end
		end
	end

	self:StopSignUp();
	self.tbRoleZoneIndex = {} --这个不能结束报名时清掉，不然战场没打完已经停止报名时到发奖时就会没有对应玩家数据
	self.tbCreateMapIngIds = {};

	local tbCreateTypes = { szType };
	local szQulifyType = self:GetCurOpenQualifyType()
	if szQulifyType then
		table.insert(tbCreateTypes, szQulifyType)
	end

	self.tbReadyMapWaitIds = {};

	self.tbReadyMapTypes = {};
	self.tbMapTypesTempSetting = {};
	self.tbTotalPlayerNum = {};

	for _, szType in ipairs(tbCreateTypes) do
		self.tbMapTypesTempSetting[szType] = {};
		local nReadyMapId = CreateMap(tbDefine.nReadyMapTemplateId);		
		self.tbReadyMapTypes[nReadyMapId] = szType
		self.tbTotalPlayerNum[nReadyMapId] = 0;
	end
end

function InDifferBattle:IsSignupIng()
	return self.tbTotalPlayerNum ~= nil
end

function InDifferBattle:StopSignUp()
	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil;
	end
	if self.nActiveTimerReady then
		Timer:Close(self.nActiveTimerReady)
		self.nActiveTimerReady = nil;
	end

	if self.tbReadyMapTypes then
		for nReadyMapId,v in pairs(self.tbReadyMapTypes) do
			KPlayer.MapBoardcastScript(nReadyMapId, "Ui:OpenWindow", "QYHLeftInfo", "InDifferBattleClose")	
			local tbPlayers = KPlayer.GetMapPlayer(nReadyMapId)
			for i,pPlayer in ipairs(tbPlayers) do
				if not self.tbRoleZoneIndex[pPlayer.dwID] then
					pPlayer.CenterMsg("未能匹配进活动，请下一场再来！", true)
				end
			end	
		end
	end
	
	self.tbTotalPlayerNum = nil;
	self.tbOldTeamInfo 	 = nil;
	self.tbOldTeamMembers = nil;
	self.tbRandomFactionGroup = nil;
	self.tbRandomRoomIndex = nil;
	-- self.tbReadyMapTypes = nil; --不能清，需要打完所有比赛时也用到
	self.tbReadyMapWaitIds = nil;
	self.tbMapTypesTempSetting = nil;
	
	CallZoneClientScript(-1, "InDifferBattle:OnServerStopSignUp");
end

function InDifferBattle:UpdateReadyMapInfo()
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	for nReadyMapId,_ in pairs(self.tbReadyMapTypes) do
		local nPlayerNum = self.tbTotalPlayerNum[nReadyMapId]
		local szNumInfo = string.format("%d/%d", nPlayerNum, tbDefine.nMaxTeamRoleNum * tbDefine.nMaxTeamNum)
		KPlayer.MapBoardcastScript(nReadyMapId, "Ui:DoLeftInfoUpdate", {nTime, szNumInfo})
	end
	return true
end

--传入id全部组队
function InDifferBattle:TeamUp(tbRoleIds)
	local dwRoleId1, dwRoleId2 = tbRoleIds[1], tbRoleIds[2]
	local bRet, nRet2,nRet3, teamData = TeamMgr:Create(dwRoleId1, dwRoleId2, true);
	if bRet and teamData then
		for j = 3, #tbRoleIds do
			teamData:AddMember(tbRoleIds[j], true);	
		end
		return teamData
	else
		Log("TeamUp Error bRet, nRet2,nRet3", bRet, nRet2,nRet3, dwRoleId1, dwRoleId2)
	end
end


function InDifferBattle:ActiveOneMap(nReadyMapId)
	self.tbOldTeamInfo = {}; --因为这里已经又做了自动组队操作了，所以之前同步过来的信息应该清掉

	--先对没有组队的进行一个自动组队, 目前只是优先同服同家族的
	local nMaxTeamRoleNum = tbDefine.nMaxTeamRoleNum
	local tbPlayers = KPlayer.GetMapPlayer(nReadyMapId) 
	local tbSortPlayers = {}; --暂时没有队伍的玩家
	local tbHasTeams = {};
	for i, pPlayer in ipairs(tbPlayers) do
		if pPlayer.dwTeamID == 0 then
			table.insert(tbSortPlayers, {dwRoleId = pPlayer.dwID, nSort = (pPlayer.nZoneServerId or 0) * 100000 + pPlayer.dwKinId % 2^20 } )
		else
			if not tbHasTeams[pPlayer.dwTeamID] then
				tbHasTeams[pPlayer.dwTeamID] = { tbRoles = {}, nSort = (pPlayer.nZoneServerId or 0) * 100000 + pPlayer.dwKinId % 2^20 }
			end
			table.insert(tbHasTeams[pPlayer.dwTeamID].tbRoles, pPlayer.dwID)
		end
	end
	local tbHasSortIndex = {} -- [nSort] = {dwTeamID1, dwTeamID2 ...}
	local nCurTotalTeamNum = 0
	for dwTeamID,v in pairs(tbHasTeams) do
		if #v.tbRoles < nMaxTeamRoleNum then
			tbHasSortIndex[v.nSort] = tbHasSortIndex[v.nSort] or {};
			table.insert(tbHasSortIndex[v.nSort], dwTeamID);
		end
		nCurTotalTeamNum = nCurTotalTeamNum + 1;
 	end

 	table.sort( tbSortPlayers, function (a, b)
 		return a.nSort < b.nSort;
 	end )

 	--先是优先将同服同家族的塞到已建立的队伍中去
 	for i = #tbSortPlayers, 1, -1 do
 		local v = tbSortPlayers[i]
 		local tbCurSortTeamIDs = tbHasSortIndex[v.nSort]
 		if tbCurSortTeamIDs then
 			local nCurSortTeamID = tbCurSortTeamIDs[#tbCurSortTeamIDs]
 			table.insert(tbHasTeams[nCurSortTeamID].tbRoles, v.dwRoleId)
 			--组队操作
			local teamData = TeamMgr:GetTeamById(nCurSortTeamID);
			teamData:AddMember(v.dwRoleId, true);
 			table.remove(tbSortPlayers, i)
 			if #tbHasTeams[nCurSortTeamID].tbRoles == nMaxTeamRoleNum then
				table.remove(tbCurSortTeamIDs)	 			
				if not next(tbCurSortTeamIDs) then
					tbHasSortIndex[v.nSort] = nil;
				end
 			end
 		end
 	end
 	--直接将剩余的人塞到已建立的队伍中
 	local bHasRoles = true
 	for nSort, tbTeamIDs in pairs(tbHasSortIndex) do
 		for _, dwTeamID in ipairs(tbTeamIDs) do
 			local tbTeamRoles = tbHasTeams[dwTeamID].tbRoles
	 		for i = #tbTeamRoles + 1, nMaxTeamRoleNum do
	 			local tbRole = table.remove(tbSortPlayers)
	 			if not tbRole then
	 				bHasRoles = false
	 				break;
	 			else
		 			local teamData = TeamMgr:GetTeamById(dwTeamID); 
					teamData:AddMember(tbRole.dwRoleId, true);
					table.insert(tbHasTeams[dwTeamID].tbRoles, tbRole.dwRoleId)
	 			end
	 		end
 		end
 		if not bHasRoles then
 			break;
 		end
 	end

 	--剩余的先同 家族的组队 够3个的才组
 	local nMaxLeftTeam = math.floor(#tbSortPlayers / nMaxTeamRoleNum) 
 	if nMaxLeftTeam > 0 then
 		local tbNewTeamUpRoleIndex = {}; --已经组队的列表
 		local tbSameSortRoles = {};
 		local nLastSort = -1;
 		table.insert(tbSortPlayers, {dwRoleId = 0, nLastSort = -2 }) --为了兼容算法，
 		for i, tbRole in ipairs(tbSortPlayers) do
 			if tbRole.nSort ~= nLastSort then
 				local nCanTeamNum = math.floor(#tbSameSortRoles / nMaxTeamRoleNum)
 				for j = 1, nCanTeamNum do
 					local tbRoleIds = { unpack(tbSameSortRoles, (j - 1) * nMaxTeamRoleNum + 1, (j - 1) * nMaxTeamRoleNum + nMaxTeamRoleNum) };
 					local teamData = self:TeamUp(tbRoleIds) 
 					if teamData then
		 				nCurTotalTeamNum = nCurTotalTeamNum + 1;
		 				tbHasTeams[teamData.nTeamID] = { tbRoles = tbRoleIds }
		 			else
		 				Log(debug.traceback())
		 			end
 				end
				for i3 = i - #tbSameSortRoles , i - #tbSameSortRoles - 1 + nCanTeamNum * nMaxTeamRoleNum  do
 					table.insert(tbNewTeamUpRoleIndex, i3)
 				end

 				tbSameSortRoles = { tbRole.dwRoleId }
 				nLastSort = tbRole.nSort;
 			else
 				table.insert(tbSameSortRoles, tbRole.dwRoleId)
 			end
 		end
 		table.remove(tbSortPlayers) --算法去掉最后多于的

 		--去掉刚组上队的
 		for i = #tbNewTeamUpRoleIndex,1, -1 do
 			table.remove(tbSortPlayers, tbNewTeamUpRoleIndex[i])
 		end
 	end

	--剩余的就直接3个一组进行组队。 边缘的其实是会影响到下个服的，应该还是要类似上面的再做次针对同服的3个一组。
	local nMaxLeftTeam = math.floor(#tbSortPlayers / nMaxTeamRoleNum) 
 	if nMaxLeftTeam > 0 then
 		for i = 1, nMaxLeftTeam do
 			local tbRoleIds = {};
 			for j = 1, nMaxTeamRoleNum do
 				table.insert(tbRoleIds, tbSortPlayers[(i - 1) * nMaxTeamRoleNum + j].dwRoleId)
 			end
 			local teamData = self:TeamUp(tbRoleIds) 
 			if teamData then
 				nCurTotalTeamNum = nCurTotalTeamNum + 1;
 				tbHasTeams[teamData.nTeamID] = { tbRoles = tbRoleIds }
 			else
 				Log(debug.traceback())
 			end
 		end
 	end

 	local szBattleType = self.tbReadyMapTypes[nReadyMapId];
 	local tbBattleTypeSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
 	local nMinTeamNum = self:GetSettingTypeField(szBattleType, "nMinTeamNum")
 	if nCurTotalTeamNum  >= nMinTeamNum then
 		local nMatchNum = math.floor(nCurTotalTeamNum / tbDefine.nMaxTeamNum)
 		local nLeftTeamNum = nCurTotalTeamNum % tbDefine.nMaxTeamNum
 		if nLeftTeamNum > 0 then
 			nMatchNum = nMatchNum + 1;
 		end

 		local tbMapIds = {}

 		local nFightMapTemplateId = self:GetSettingTypeField(szBattleType, "nFightMapTemplateId")
 		for i = 1, nMatchNum do
 			local nMapId = CreateMap(nFightMapTemplateId);
 			self.tbCreateMapIngIds[nMapId] = szBattleType;
 			table.insert(tbMapIds, nMapId)
 			self.tbInGamePlayers[nMapId] = { tbRoles = {}, tbTeams = {} }; 
 		end

 		local tbAllTeams = {}
 		for dwTeamID, v in pairs(tbHasTeams) do
 			table.insert(tbAllTeams, {dwTeamID, v})
 		end
 		local fnInsertToGame = function ( nGameIndex, dwTeamID, v)
 			local nMapId = tbMapIds[nGameIndex]
	        self.tbInGamePlayers[nMapId].tbTeams[dwTeamID] = 1;
	        local tbRoles = self.tbInGamePlayers[nMapId].tbRoles
	        for _, nPlayerId in ipairs(v.tbRoles) do
	        	tbRoles[nPlayerId]	= 1;
	        end
 		end
 		local nAssigedMathch = 0
 		if nLeftTeamNum > 0 and nMatchNum > 1 then
 			--分配2场，其他的场都是最大人数
 			for nIndex=1,nLeftTeamNum + tbDefine.nMaxTeamNum do
 				local tbData = table.remove(tbAllTeams)
 				local dwTeamID, v = unpack(tbData)
 				local nGameIndex = 	nIndex % 2 + 1;
 				fnInsertToGame(nGameIndex, dwTeamID, v)
 			end
 			nAssigedMathch = 2;
 		end
 		
 		for i=1,nMatchNum - nAssigedMathch do
 			local nGameIndex = nAssigedMathch + i
 			for nIndex=1,tbDefine.nMaxTeamNum do
 				local tbData = table.remove(tbAllTeams)
 				if tbData then
 					local dwTeamID, v = unpack(tbData)
 					fnInsertToGame(nGameIndex, dwTeamID, v)	
 				else
 					 break;
 				end
 			end
 		end
 	else
 		if tbBattleTypeSetting.tbNotOpenAwardIndex and tbBattleTypeSetting.szNotOpenMailContent then
 			for _, pPlayer in ipairs(tbPlayers) do
				CallZoneClientScript(pPlayer.nZoneIndex, "InDifferBattle:OnGetNotOpenAward", pPlayer.dwOrgPlayerId, szBattleType); 				
 			end
 		end
 	end
end

--组队匹配
function InDifferBattle:Active()
	for nReadyMapId,v in pairs(self.tbReadyMapTypes) do
		self:ActiveOneMap(nReadyMapId)
	end
end

function InDifferBattle:OnSyncTeamInfo(dwCaptainID, tbMember) --因为各个服的队伍id是自增加有可能重复的
	local nServerId = Server:GetServerId(Server.nCurConnectIdx)
	local nChangedwCaptainID = Server:GetServerRoleCombieId(dwCaptainID, nServerId)
	local tbChangedMemberIds = {};
	for i, nPlayerId in ipairs(tbMember) do
		local nChangePlayerId = Server:GetServerRoleCombieId(nPlayerId, nServerId)
		self.tbOldTeamInfo[nChangePlayerId] = nChangedwCaptainID;
		table.insert(tbChangedMemberIds, nChangePlayerId)
	end
	self.tbOldTeamMembers[nChangedwCaptainID] = tbChangedMemberIds

end


function InDifferBattle:OnAllReadyMapCreate()
	self.tbOldTeamInfo	 = {};
	self.tbOldTeamMembers = {};
	if self:IsOpenActType(self.tbReadyMapTypes) then
		local tbBattleTypeSetting = InDifferBattle.tbBattleTypeSetting.ActJueDi
		self.nActiveTimer =	Timer:Register(Env.GAME_FPS * tbBattleTypeSetting.FIRST_SIGNUP_TIME, function ()
			self:Active()

			self.nActiveTimer = Timer:Register(Env.GAME_FPS * tbBattleTypeSetting.NEXT_SIGNUP_TIME, function ()
				self:Active();
				return true
			end)
		end)
	else
		self.nActiveTimer =	Timer:Register(Env.GAME_FPS * tbDefine.MATCH_SIGNUP_TIME, function ()
			self:Active()
			self.nActiveTimer = nil; --不循环了
			if not next(self.tbCreateMapIngIds) then
				self:StopSignUp()
			end
		end)	
		
	end
	
	self.nActiveTimerReady =  Timer:Register(Env.GAME_FPS * 3, self.UpdateReadyMapInfo, self)
	CallZoneClientScript(-1, "InDifferBattle:OnServerOnReadyMapCreate", self.tbReadyMapTypes);

	local tbRandomFactionGroup = {}
	for i=1,20 do
		local tbRandFaction = {};
		for j = 1,Faction.MAX_FACTION_COUNT do
			table.insert(tbRandFaction, j)
		end
		for j = 1,Faction.MAX_FACTION_COUNT do
			local nRand2 = MathRandom(Faction.MAX_FACTION_COUNT)
			tbRandFaction[j], tbRandFaction[nRand2] = tbRandFaction[nRand2], tbRandFaction[j]
		end
		table.insert(tbRandomFactionGroup, tbRandFaction)
	end
	self.tbRandomFactionGroup = tbRandomFactionGroup
	--队伍随机进房间的顺序，--先打乱房间的顺序，然后按队伍顺序放进房间就好了
	for szBattleType, tbTempSeting in pairs(self.tbMapTypesTempSetting) do
		local tbBattleTypeSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
		local nMaxRoomNum = InDifferBattle:GetSettingTypeField(szBattleType, "nMaxRoomNum")
		local tbRandomRoomIndex = {}
		for i = 1,nMaxRoomNum do
			table.insert(tbRandomRoomIndex, i)
		end
		for i = 1,nMaxRoomNum do
			local nRand2 = MathRandom(1, nMaxRoomNum)
			tbRandomRoomIndex[i], tbRandomRoomIndex[nRand2] = tbRandomRoomIndex[nRand2], tbRandomRoomIndex[i]
		end
		tbTempSeting.tbRandomRoomIndex = tbRandomRoomIndex
	end
end


function InDifferBattle:OnReadyMapCreate(nReadyMapId)
	table.insert(self.tbReadyMapWaitIds, nReadyMapId)
	local nReadyMapNum = 0;
	for k,v in pairs(self.tbReadyMapTypes) do
		nReadyMapNum = nReadyMapNum + 1;
	end
	if #self.tbReadyMapWaitIds == nReadyMapNum then
		self:OnAllReadyMapCreate()
		self.tbReadyMapWaitIds = nil;
	end
end

function InDifferBattle:OnLoginReadyMap()
	if not self.tbTotalPlayerNum then
		local dwRoleId = me.dwID
		Timer:Register(1, function ()
			Log("Delayer KickOut InDifferBattle:OnLoginReadyMap", dwRoleId)
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer then
				pPlayer.ZoneLogout()		
			end
		end)
		return
	end
	self:UpdateReadyMapLeftInfo(me)
end

function InDifferBattle:UpdateReadyMapLeftInfo(pPlayer)
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	local szBattleType = self.tbReadyMapTypes[pPlayer.nMapId]
	local szReadyMapLeftKey = self:GetSettingTypeField(szBattleType, "szReadyMapLeftKey")
	pPlayer.CallClientScript("Battle:EnterReadyMap", szReadyMapLeftKey, {nTime, string.format("%d/%d", self.tbTotalPlayerNum[pPlayer.nMapId], tbDefine.nMaxTeamRoleNum * tbDefine.nMaxTeamNum)})
end

function InDifferBattle:OnEnterReadyMap(nMapId)
	self.tbTotalPlayerNum[nMapId] = self.tbTotalPlayerNum[nMapId] + 1;
	self:UpdateReadyMapLeftInfo(me)

	if not self.nActiveTimer then --之前结束匹配到 地图全部创建完之间的时间内已有组队信息的进来这样还是会自动组上原来队会有可能超3人
		return
	end

	-- 跨服进来，重新组队
	local nMyServerId = me.nZoneServerId
	local dwMyChangeRoleId = Server:GetServerRoleCombieId(me.dwOrgPlayerId, nMyServerId)
	local nOldCaptainId = self.tbOldTeamInfo[dwMyChangeRoleId]
	if nOldCaptainId then
		local tbMemeber = self.tbOldTeamMembers[nOldCaptainId]
		for i,nCombinePlayerId in ipairs(tbMemeber) do
			if nCombinePlayerId ~= dwMyChangeRoleId then
				local nServerId, dwOrgPlayerId = Server:GetServerRoleUnLinkId(nCombinePlayerId)
				local pPlayer = KPlayer.GetPlayerObjById(dwOrgPlayerId, nServerId);
				if pPlayer then
					if pPlayer.dwTeamID <= 0 then
						TeamMgr:Create(me.dwID, pPlayer.dwID, true);
					else
						local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
						local nCurCount = teamData:GetMemberCount()
						--队长出去再组人进来，之前的队员出去再进来，就会是同队长导致可能4人
						if nCurCount >= tbDefine.nMaxTeamRoleNum then 
							return
						end
						teamData:AddMember(me.dwID, true);
					end
					local _, x, y = pPlayer.GetWorldPos()
					me.SetPosition(x, y)
					break;
				end
			end
		end
	end
end

function InDifferBattle:OnLeaveReadyMap(nMapId)
	if not self.tbTotalPlayerNum then
		return
	end
	self.tbTotalPlayerNum[nMapId] = self.tbTotalPlayerNum[nMapId] - 1;
end

function InDifferBattle:OnBattleMapCreate(nMapId)
	local szBattleType = self.tbCreateMapIngIds[nMapId]
	assert(szBattleType)
	local szLogicClassName = self:GetSettingTypeField(szBattleType, "szLogicClassName")
	local tbInst = Lib:NewClass(InDifferBattle:GetClass(szLogicClassName))
	self.tbMapInst[nMapId] = tbInst 
	tbInst:Init(nMapId, self.tbInGamePlayers[nMapId].tbTeams, szBattleType)
	tbInst:Start();
	local tbTeamMemrbName = {};
	for dwRoleId,v in pairs(self.tbInGamePlayers[nMapId].tbRoles) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer then
			tbTeamMemrbName[pPlayer.dwTeamID] = tbTeamMemrbName[pPlayer.dwTeamID] or {};
			table.insert(tbTeamMemrbName[pPlayer.dwTeamID], string.format("「%s」",pPlayer.szName) )
			self.tbRoleZoneIndex[pPlayer.dwID] = pPlayer.nZoneIndex
			CallZoneClientScript(pPlayer.nZoneIndex, "InDifferBattle:OnPlayedBattle", pPlayer.dwOrgPlayerId, szBattleType)
			pPlayer.SwitchMap(nMapId, 0,0);
		end
	end
	for dwTeamID,v in pairs(tbTeamMemrbName) do
		local szAllName = table.concat( v, "、")
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, "本次幻境队伍成员：" .. szAllName, dwTeamID)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, "请从右侧随机的6个门派中选择门派。", dwTeamID)
	end
	self.tbCreateMapIngIds[nMapId] = nil;
	if not next(self.tbCreateMapIngIds) then
		if not self:IsOpenActType(self.tbReadyMapTypes) then
			self:StopSignUp();	
		end

		local szBattleTypeQuality = InDifferBattle:IsOpenQualify(self.tbReadyMapTypes)
		if szBattleTypeQuality then
			local nTotalMatchTime = InDifferBattle:GetTotalGameFightTime(szBattleTypeQuality)
			Timer:Register(Env.GAME_FPS * (nTotalMatchTime + 10), function ()
				CallZoneClientScript(-1, "InDifferBattle:CheckSendQualifyWinnerNews", szBattleTypeQuality)
			end)
		end

	end
end

function InDifferBattle:SendQualifyBattleWinRoleIds(tbWinRoleList)
	local tbServerIdRoleIds = {};
	local tbZoneIndexRoleIds = {};
	for i, v in ipairs(tbWinRoleList) do
		local nServerId, dwOrgPlayerId = KPlayer.GetOrgPlayerIdByZoneId(v)
		local nZoneIndex = Server:GetConnectIdx(nServerId)
		tbZoneIndexRoleIds[nZoneIndex] = tbZoneIndexRoleIds[nZoneIndex] or {};
		table.insert(tbZoneIndexRoleIds[nZoneIndex], dwOrgPlayerId)
	end
	for nZoneIndex, v in pairs(tbZoneIndexRoleIds) do
		CallZoneClientScript(nZoneIndex, "InDifferBattle:OnSynQualifyBattleWinRoleIds", v)
	end
	
end

function InDifferBattle:GetAddImityData(bWin, tbRoleIds, tbTeamReportInfo)
	-- 对 v 里的roleID 进行 22匹配，然后用小的在前面的形式，再对应到2个id的最小的死亡阶段，胜利则为 12，其他无死亡阶段10
	 --期望结果，[roleid1][roleid2] = nImity
	local tbAddImitySetting = tbDefine.tbAddImitySetting
	table.sort( tbRoleIds, function (a, b)
		return a < b;
	end )
	local tbRetData = {}
	for i = 1, #tbRoleIds - 1 do
		local dwRoleId1 = tbRoleIds[i];
		tbRetData[dwRoleId1] = {};
		local nState1 = tbTeamReportInfo[dwRoleId1].nDeathState
		local nScore1 = tbAddImitySetting[nState1] or 0;

		for j = i + 1,#tbRoleIds do
			local dwRoleId2 = tbRoleIds[j];
			local nState2 = tbTeamReportInfo[dwRoleId2].nDeathState
			local nScore2 = tbAddImitySetting[nState2] or 0;		
			tbRetData[dwRoleId1][dwRoleId2] = math.min(nScore1, nScore2)
		end
	end
	return tbRetData;
end

--把下面的合并到一起吧，用到了 zoneIndex
function InDifferBattle:SendTeamAwardZ(dwTeamID, dwWinnerTeam, tbTeamReportInfo, nMatchTime, szBattleType)
	--先加亲密度， 确定有区服在一起的
	local tbZoneIndexRoles = {}; --[nZoneIndex] = {roleId1, roleId2}
	for dwRoleId,v in pairs(tbTeamReportInfo) do
		local nZoneIndex = self.tbRoleZoneIndex[dwRoleId]
		if nZoneIndex then
			tbZoneIndexRoles[nZoneIndex] = tbZoneIndexRoles[nZoneIndex] or {};
			table.insert(tbZoneIndexRoles[nZoneIndex], dwRoleId)
		end
	end
	local bWin = dwTeamID == dwWinnerTeam
	for nZoneIndex,v in pairs(tbZoneIndexRoles) do
		if #v >= 2 then
			local tbRetData = self:GetAddImityData(bWin, v, tbTeamReportInfo)
			local tbRealPassData = {};
			for dwRoleId1,v1 in pairs(tbRetData) do
				local _, dwOrgPlayerId1 = KPlayer.GetOrgPlayerIdByZoneId(dwRoleId1)
				tbRealPassData[dwOrgPlayerId1] = {};
				for dwRoleId2,nImitity in pairs(v1) do
					local _, dwOrgPlayerId2 = KPlayer.GetOrgPlayerIdByZoneId(dwRoleId2)
					tbRealPassData[dwOrgPlayerId1][dwOrgPlayerId2] = nImitity
				end
			end
			CallZoneClientScript(nZoneIndex, "InDifferBattle:AddTeamImity", tbRealPassData)
		end
	end
	local nResult = bWin and  Env.LogRound_SUCCESS or Env.LogRound_FAIL;

	for dwRoleId,v in pairs(tbTeamReportInfo) do
		local nZoneIndex = self.tbRoleZoneIndex[dwRoleId]
		if not nZoneIndex then
			Log(debug.traceback(), dwRoleId)
		else
			self.tbRoleZoneIndex[dwRoleId] = nil; 
			local _, dwOrgPlayerId = KPlayer.GetOrgPlayerIdByZoneId(dwRoleId)
			CallZoneClientScript(nZoneIndex, "InDifferBattle:SendPlayerAwardS", dwOrgPlayerId, nResult, nMatchTime, v.nScore, v.nKillCount, szBattleType, v.nDeathState)		
		end
	end
end

function InDifferBattle:SendTeamAwardZAct(dwTeamID, dwWinnerTeam, tbTeamReportInfo, nMatchTime, szBattleType)
	local bWin = dwTeamID == dwWinnerTeam
	local nResult = bWin and  Env.LogRound_SUCCESS or Env.LogRound_FAIL;
	for dwRoleId,v in pairs(tbTeamReportInfo) do
		local nZoneIndex = self.tbRoleZoneIndex[dwRoleId]
		if not nZoneIndex then
			Log(debug.traceback(), dwRoleId)
		else
			self.tbRoleZoneIndex[dwRoleId] = nil; 
			local _, dwOrgPlayerId = KPlayer.GetOrgPlayerIdByZoneId(dwRoleId)
			CallZoneClientScript(nZoneIndex, "InDifferBattle.tbAct:SendPlayerAwardS", dwOrgPlayerId, nResult, nMatchTime, v.nScore, v.nKillCount, szBattleType, v.nDeathState)		
		end
	end
end

function InDifferBattle:OnBattleMapDestory(nMapId)
	self.tbInGamePlayers[nMapId] = nil;
	if self.tbMapInst[nMapId] then
		self.tbMapInst[nMapId]:OnMapDestroy();
		self.tbMapInst[nMapId] = nil;
	end
end

function InDifferBattle:GiveMoneyTo(pPlayer, dwRoleId2, nMoney)
	local nMapId = pPlayer.nMapId
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end
	local pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId2)
	if not pPlayer2 then
		return
	end
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	if pPlayer2.nFightMode == 2 then
		pPlayer.CenterMsg("对方已阵亡，无法接受赠送")
		return
	end

	if pPlayer2.nMapId ~= nMapId then
		return
	end
	if pPlayer.dwTeamID == 0 or pPlayer.dwTeamID ~= pPlayer2.dwTeamID then
		return
	end
	local nRole1Money = pPlayer.GetMoney(tbDefine.szMonoeyType)
	if nMoney >  nRole1Money or nMoney <= 0 then
		return
	end

	if pPlayer.CostMoney(tbDefine.szMonoeyType, nMoney, Env.LogWay_InDifferBattle) then
		pPlayer2.SendAward({{tbDefine.szMonoeyType, nMoney}}, false, false, Env.LogWay_InDifferBattle)
		pPlayer2.Msg( string.format("获得「%s」赠送的#987%d", pPlayer.szName, nMoney))
		pPlayer.CallClientScript("InDifferBattle:OnGiveMoneySuc")
	end
end

function InDifferBattle:OnNpcDeath(pNpc, pKiller)
	local tbInst = self.tbMapInst[pNpc.nMapId]
	if not tbInst then
		return
	end
	tbInst:OnNpcDeath(pNpc, pKiller)
end

function InDifferBattle:OnUseIndifferItem(pPlayer, dwTemplateId)
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end
	if tbInst.OnUseIndifferItem then
		tbInst:OnUseIndifferItem(pPlayer, dwTemplateId)
	end
end

function InDifferBattle:OnCreateChatRoom(dwTeamID, uRoomHighId, uRoomLowId) 
	local tbMembers = TeamMgr:GetMembers(dwTeamID)
	local nMemberId = tbMembers[1]
	if not nMemberId then
		return
	end
	local pMember = KPlayer.GetPlayerObjById(nMemberId)
	if not pMember then
		return
	end
	local tbInst = self.tbMapInst[pMember.nMapId]
	if tbInst then
		for i,nMemberId in ipairs(tbMembers) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId)
			if pMember then
				ChatMgr:JoinChatRoom(pMember, 1) 
			end
		end
		return true
	end
end

local tbC2zRequestInstFunc = {
	ChooseFaction = 1;
	RequetMapInfo = 1;
	ShopBuy = 1;
	UseItem = 1;
	SellItem = 1;
	EnhanceEquip = 1;
	HorseUpgrade = 1;
	BookUpgrade = 1;
	RequestLeave = 1;
	UseEquip = 1;
	UnuseEquip = 1;
	UpdateNpcDmgInfo = 1;
	RequestTeamScore = 1;
	TrowItem = 1;
	SelectPlayerDeathDrop = 1;
}
function InDifferBattle:RequestInst(pPlayer, szFunc, ... )
	if not tbC2zRequestInstFunc[szFunc] then
		return
	end
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end
	tbInst[szFunc](tbInst, pPlayer, ...)
end

function InDifferBattle:SetupMapCallback()
	local fnOnCreate = function (tbMap, nMapId)
		self:OnBattleMapCreate(nMapId)
	end

	local fnOnDestory = function (tbMap, nMapId)
		self:OnBattleMapDestory(nMapId)
	end

	local fnOnEnter = function (tbMap, nMapId)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnEnter()
		end
	end

	local fnOnLeave = function (tbMap, nMapId)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLeave()
		end
	end

	local fnOnPlayerTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnPlayerTrap(szTrapName)
		end
	end

	local fnOnMapLogin = function (tbMap, nMapId)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLogin()
		end
	end

	local tbFighgtMaps = {tbDefine.nFightMapTemplateId};
	for k,v in pairs(InDifferBattle.tbBattleTypeSetting) do
		if v.nFightMapTemplateId then
			table.insert(tbFighgtMaps, v.nFightMapTemplateId)
		end
	end
	for i,v in ipairs(tbFighgtMaps) do
		local tbMapClass = Map:GetClass(v)
		tbMapClass.OnCreate = fnOnCreate;
		tbMapClass.OnDestroy = fnOnDestory;
		tbMapClass.OnEnter = fnOnEnter;
		tbMapClass.OnLeave = fnOnLeave;
		tbMapClass.OnPlayerTrap = fnOnPlayerTrap;
		tbMapClass.OnLogin = fnOnMapLogin;
	end

	local fnOnReadyMapCreate = function (tbMap, nMapId)
		self:OnReadyMapCreate(nMapId)
	end 

	local fnOnEnterReadyMap = function (tbMap, nMapId)
		self:OnEnterReadyMap(nMapId)
	end 

	local fnOnLeaveReadyMap = function (tbMap, nMapId)
		self:OnLeaveReadyMap(nMapId)
	end 
	local fnOnLoginReadyMap = function (tbMap, nMapId)
		self:OnLoginReadyMap(nMapId)
	end 

	local tbReadyMap = Map:GetClass(tbDefine.nReadyMapTemplateId);	
	tbReadyMap.OnCreate = fnOnReadyMapCreate;
	tbReadyMap.OnEnter = fnOnEnterReadyMap
	tbReadyMap.OnLeave = fnOnLeaveReadyMap
	tbReadyMap.OnLogin = fnOnLoginReadyMap;
end


InDifferBattle:SetupMapCallback()