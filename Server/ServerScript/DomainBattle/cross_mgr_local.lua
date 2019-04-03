Require("ServerScript/DomainBattle/cross_mgr.lua");

DomainBattle.tbCross = DomainBattle.tbCross or {};
local tbCross = DomainBattle.tbCross
local tbCrossDef = DomainBattle.tbCrossDef
local tbDefine = DomainBattle.define

function tbCross:GetCrossOpenTime(bNext)
	--[[local nNow = GetTime();
	local nNextTime = Lib:GetTimeByWeekInMonth(nNow, -1, tbCrossDef.nOpenWeekDay, 21, 0, 0);
	if bNext or (nNow > nNextTime and Lib:GetLocalDay(nNextTime) ~= Lib:GetLocalDay(nNow)) then
		--这个月的开启时间已经过了取下个月
		local tbTime = os.date("*t", nNextTime);
		tbTime.month = tbTime.month + 1;
		if tbTime.month > 12 then
			tbTime.month = 1;
			tbTime.year = tbTime.year + 1;
		end

		nNow = os.time(tbTime);
		nNextTime = Lib:GetTimeByWeekInMonth(nNow, -1, tbCrossDef.nOpenWeekDay, 21, 0, 0);
	end

	return nNextTime]]

	local nServerId = GetServerIdentity()
	local nZoneServerId = 1
	if Server.tbZoneGroup and Server.tbZoneGroup[nServerId] then
		nZoneServerId = Server.tbZoneGroup[nServerId]["CrossDomain"] or 1
	end

	if nZoneServerId <= 1 then
		--只有配了跨服战区才会开启
		return 0
	end

	local nLastOpenDay = self.tbLocalData.nLastOpenDay or 0

	local nLocalDay = Lib:GetLocalDay()
	local nOldLastOpenDay = nLastOpenDay
	if nOldLastOpenDay <= 0 then
		nLastOpenDay = nLocalDay
	end

	local nLastOpenTime = Lib:GetTimeByLocalDay(nLastOpenDay)
	local tbLastOpenTime = os.date("*t", nLastOpenTime);
	local nLastOpenWeekDay = tbLastOpenTime.wday - 1;
	if nLastOpenWeekDay ~= 0 then
		--如果不是周日,调整到周日
		nLastOpenTime = nLastOpenTime + (7-nLastOpenWeekDay)*24*60*60;
	end

	local nOpenTime = nLastOpenTime
	local nNow = Lib:GetLocalDayTime()

	if nOldLastOpenDay > 0 and ((nLastOpenDay ~= nLocalDay or nLastOpenWeekDay ~= 0) or  nNow >= Lib:ParseTodayTime("21:40") ) then
		--每隔2周开一次
		nOpenTime = nOpenTime + 14*24*60*60;
		if Lib:GetTimeByLocalDay(nLocalDay) > nOpenTime then
			--被跳过了
			self.tbLocalData.nLastOpenDay = Lib:GetLocalDay(nOpenTime - 7*24*60*60 + 21*60*60)
			return self:GetCrossOpenTime(bNext);
		end
	end

	if bNext then
		--每隔2周开一次
		nOpenTime = nOpenTime + 14*24*60*60;
	end

	return nOpenTime + 21*60*60;
end

function tbCross:LoadLocalData()
	self.tbLocalData = ScriptData:GetValue("DomainBattleCross");
	self.tbLocalData.tbScore = self.tbLocalData.tbScore or {};
	self.tbLocalData.tbAidList = self.tbLocalData.tbAidList or {};
	self.tbLocalData.tbKinList = self.tbLocalData.tbKinList or {};
	self.tbLocalData.tbFirstKinLeader = self.tbLocalData.tbFirstKinLeader or {}
	self.tbScore = self.tbLocalData.tbScore;
	self.tbKinList = self.tbLocalData.tbKinList;
	self.tbAidList = self.tbLocalData.tbAidList;
	self.tbFirstKinLeader = self.tbLocalData.tbFirstKinLeader;

	for nPlayerId, nKinId in pairs( self.tbAidList ) do
		self.tbKinAidPlayer[nKinId] = self.tbKinAidPlayer[nKinId] or {}
		self.tbKinAidPlayer[nKinId][nPlayerId] = true
	end

	self:ClearAssignOuterCamp();
	self:UpdateStatue();
end

function tbCross:GetMaxNpcLevel()
	--local取出NPC等级，传给zone，zone选择最大的
	local szLvlFrame = Lib:GetMaxTimeFrame(tbCrossDef.tbNpcTimeFrameLevel);
	return tbCrossDef.tbNpcTimeFrameLevel[szLvlFrame] or 105
end

function tbCross:GetSiegeBuffLevel()
	--local取出等级，传给zone，zone选择最大的
	local szLvlFrame = Lib:GetMaxTimeFrame(tbCrossDef.tbSiegeBuffLevel);
	return tbCrossDef.tbSiegeBuffLevel[szLvlFrame] or 1
end

function tbCross:IsLocalCanAddScore()
	if GetTimeFrameState(tbCrossDef.szOpenFrame) == 1 then
		return true
	end

	--本月开启跨服攻城战，则记录积分
	local nOpenTime = CalcTimeFrameOpenTime(tbCrossDef.szOpenFrame);
	local nOpenMonth = Lib:GetLocalMonth(nOpenTime);
	local nCurMonth = Lib:GetLocalMonth();

	return nOpenMonth == nCurMonth
end

function tbCross:AddLocalScore(nDomainType, nKinId)
	if not self:IsLocalCanAddScore() then
		return
	end

	self.tbScore[nKinId] = self.tbScore[nKinId] or 0;

	local nScore = tbCrossDef.tbQualifiedScore[nDomainType];
	if not nScore then
		Log("[Error]", "DomainBattleCross", "AddQualifiedScore not found domain score", nDomainType, nKinId)
		return
	end

	self.tbScore[nKinId] = self.tbScore[nKinId] + nScore;

	ScriptData:AddModifyFlag("DomainBattleCross")

	Log("[Info]", "DomainBattleCross", "AddLocalScore", nKinId, nDomainType, nScore)
end

function tbCross:CheckGenCrossList()
	local nRefDay = Lib:GetLocalDay(CalcTimeFrameOpenTime(tbCrossDef.szOpenFrame)) - Lib:GetLocalDay()
	if GetTimeFrameState(tbCrossDef.szOpenFrame) ~= 1 and nRefDay > 1 then
		--如果明天就开时间轴那也生成名单
		return false
	end

	--检查是否跨服攻城战前最后一场本服战斗，目前本服跨服定在周二，周六
	--所以判断是否同一周并且为周六即可,如果要修改本服的时间需要改这里
	if Lib:GetLocalWeekDay() ~= 6 then
		return false
	end

	if Activity:__IsActInProcessByType("WuLinDaHuiAct") then
		return false
	end

	local nOpenTime = self:GetCrossOpenTime();

	return Lib:GetLocalWeek(nOpenTime) ==  Lib:GetLocalWeek()
end

function tbCross:OnLocalBattleEnd()
	if not self:CheckGenCrossList() then
		return
	end

	Log("[Info]", "DomainBattleCross", "OnLocalBattleEnd")
	self.tbLocalData.tbKinList = self:GetQualifiedKinList();
	Lib:Tree(self.tbLocalData.tbKinList)
	self.tbKinList = self.tbLocalData.tbKinList;

	ScriptData:AddModifyFlag("DomainBattleCross")

	self:SendAttendKinMail();

	local szContent = [[    恭喜！帮派[FFFE0D]%s%s[-]于攻城战中表现优异，出类拔萃！现已获得[FFFE0D]跨服攻城战[-]的参战资格。此次跨服攻城战的开启时间为[FFFE0D]%s 晚上21:00[-]，还请各参战帮派提前做好准备，携手帮派弟兄攻城掠地，与来自其他伺服器的帮派共同争夺主城「临安城」。\n\n    未获得参战资格的玩家可报名助战本服的参战帮派，报名时间[FFFE0D]%s 10:00 ~ 20:50[-]。\n\n    [00FF00][url=openwnd:了解活动规则, GeneralHelpPanel, "CrossDomainHelp"][-] ]]
	local szCityKin = ""
	local szScoreKin = "";
	for nKinId, tbKinInfo in pairs( self.tbKinList ) do
		local tbKinData = Kin:GetKinById(nKinId);
		if tbKinData then
			if tbKinInfo.nDomainType == tbDefine.tbDomainType.nCity then
				szCityKin = string.format("%s（占领襄阳）", tbKinData.szName)
			else
				szScoreKin = string.format("%s、%s（%d积分）", szScoreKin, tbKinData.szName, tbKinInfo.nScore)
			end
		end
	end
	local szTime = Lib:GetTimeStr(self:GetCrossOpenTime());

	NewInformation:AddInfomation("DomainBattleCrossAid", self:GetCrossOpenTime(),
					 {string.format(szContent, szCityKin, szScoreKin, szTime, szTime)},
					 {szTitle = "跨服攻城战预告", szBtnName="报名助战", szBtnTrap="[url=openwnd:test, TerritoryAssistPanel]"})
end

function tbCross:GetQualifiedKinList()
	local tbSortList = {}
	for nKinId, nScore in pairs( self.tbScore ) do
		local tbKin = Kin:GetKinById(nKinId);
		if tbKin then
			table.insert(tbSortList, {nKinId = nKinId, nScore = nScore, tbKin = tbKin});
		end
	end

	table.sort(tbSortList, function (a, b)
		if a.nScore == b.nScore then
			return a.tbKin:GetPrestige() > b.tbKin:GetPrestige()
		end

		return a.nScore > b.nScore
	end)

	local tbList = {};
	local tbMapOwner = DomainBattle:GetDomainMapOwner()
	local tbKinOwner = DomainBattle:GetDomainOwnerMap()
	local nCityMapTemplateId = DomainBattle.tbMapSetting.nMapTemplateId;
	local nCityKinId = tbMapOwner[nCityMapTemplateId] or 0;
	local tbCityKin = Kin:GetKinById(nCityKinId);
	local nCount = 0;
	if tbCityKin then
		tbList[nCityKinId] = {nKinId = nCityKinId, nScore = self.tbScore[nCityKinId] or 0, nRank = 0,
					 nDomainType = DomainBattle:GetMapLevel(tbKinOwner[nCityKinId]) or 999};
		nCount = nCount + 1;
	end

	for nRank, tbKinInfo in ipairs( tbSortList ) do
		if tbKinInfo.nKinId == nCityKinId then
			tbKinInfo.nRank = nRank
		else
			tbList[tbKinInfo.nKinId] = {nKinId = tbKinInfo.nKinId, nScore = tbKinInfo.nScore, nRank = nRank,
						nDomainType = DomainBattle:GetMapLevel(tbKinOwner[tbKinInfo.nKinId]) or 999};
			nCount = nCount + 1;
		end
		if nCount >= tbCrossDef.nKinCount then
			break;
		end
	end

	return tbList
end

function tbCross:SendAttendKinMail()
	if GetTimeFrameState(tbCrossDef.szOpenFrame) ~= 1 then
		return
	end

	local szContent = [[    恭喜侠士，您所在的帮派[FFFE0D]%s[-]于攻城战中表现优异，出类拔萃！现已获得[FFFE0D]跨服攻城战[-]的参战资格。此次跨服攻城战的开启时间为[FFFE0D]%s 晚上21:00[-]，请侠士务必准时参与，携手帮派弟兄攻城掠地，进军主城「临安城」。]];

	local szTime = Lib:GetTimeStr(self:GetCrossOpenTime());
	--local tbKinNames = {};
	for nKinId, _ in pairs(self.tbKinList) do
		local tbKinData = Kin:GetKinById(nKinId);
		if tbKinData then
			Mail:SendKinMail({
				Title = "跨服攻城战资格通知",
				KinId = nKinId,
				Text = string.format(szContent, tbKinData.szName, szTime),
				From = "帮派总管",
			});

			--table.insert(tbKinNames, string.format("[ffff00]%s[-]", tbKinData.szName));

			--local szMsg = "恭喜本家族于攻城战中表现优异，出类拔萃！现已获得[FFFE0D]跨服攻城战[-]的参与资格，可喜可贺！#49";
			--ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
		end
	end

	--[[if next(tbKinNames) then
		local szMsg = "恭喜家族%s于攻城战中表现优异，出类拔萃！现已获得[FFFE0D]跨服攻城战[-]的参与资格，可喜可贺！";
		KPlayer.SendWorldNotify(1, 1000,string.format(szMsg, table.concat(tbKinNames, ",")),ChatMgr.ChannelType.Public, 1);
	end]]
end

function tbCross:ClearLocalData()
	Log("[Info]", "DomainBattleCross", "ClearLocalData")
	self.tbLocalData = ScriptData:GetValue("DomainBattleCross");
	self.tbLocalData.tbScore = {};
	self.tbLocalData.tbAidList = {};
	self.tbLocalData.tbKinList = {};
	self.tbScore = self.tbLocalData.tbScore;
	self.tbKinList = self.tbLocalData.tbKinList;
	self.tbAidList = self.tbLocalData.tbAidList;
	self.tbKinAidPlayer = {}
	ScriptData:AddModifyFlag("DomainBattleCross")

	self.tbAidListSyncInfo = {}
end

function tbCross:CheckAidSignUp()
	if GetTimeFrameState(tbCrossDef.szOpenFrame) ~= 1 then
		return
	end

	local nOpenTime = self:GetCrossOpenTime();
	local nNow = GetTime();
	local nCurLocalTime = Lib:GetLocalDayTime()

	if Lib:GetLocalDay(nOpenTime) == Lib:GetLocalDay() and
		nOpenTime > nNow and
		nCurLocalTime >= Lib:ParseTodayTime(tbCrossDef.tbAidSignUpTime[1]) and
		nCurLocalTime < Lib:ParseTodayTime(tbCrossDef.tbAidSignUpTime[2]) then

		self:OnStartAidSignUp()
	end
end

function tbCross:OnStartAidSignUp()
	self.bAidSignUp = true
	KPlayer.BoardcastScript(1, "DomainBattle.tbCross:SyncAidSignUpState", self.bAidSignUp);
	self:OnAidSignUpMsg()
	Log("[Info]", "DomainBattleCross", "OnStartAidSignUp")
end

function tbCross:OnAidSignUpMsg()
	if not self:CheckCrossDay() then
		return
	end
	KPlayer.SendWorldNotify(self:GetAidMinHonorLevel(), 1000,
				"跨服攻城战【助战】已经开始接受报名，请未拥有参战资格的侠士火速前往【最新消息】报名助战。",
				ChatMgr.ChannelType.Public, 1);
end

function tbCross:OnLogin(pPlayer)
	self:SyncAidSignUpState(pPlayer)

	local nOpenTime = self:GetCrossOpenTime()
	if nOpenTime > 0 then
		pPlayer.CallClientScript("DomainBattle.tbCross:SyncOpenTime",nOpenTime)
	end
end

function tbCross:GetPlayerAidKinId(nPlayerId)
	return self.tbAidList[nPlayerId]
end

function tbCross:UpdateBriefInfo(bForce)
	local nNow = GetTime()
	if  not self.tbAidListSyncInfo.nLastBriefUpdateTime or bForce or
		(nNow - self.tbAidListSyncInfo.nLastBriefUpdateTime) > 60 then

		self.tbAidListSyncInfo.nVersion = (self.tbAidListSyncInfo.nVersion or 0) + 1

		self.tbAidListSyncInfo.tbAidBriefList = {}

		for nKinId, _ in pairs( self.tbKinList ) do
			local tbKinData = Kin:GetKinById(nKinId);
			if tbKinData then
				local nMasterId = tbKinData:GetMasterId();
				local pMaster = KPlayer.GetRoleStayInfo(nMasterId)
				self.tbAidListSyncInfo.tbAidBriefList[nKinId] =
					{
						nKinId = nKinId,
						szKinName = tbKinData.szName,
						szMasterName = (pMaster and pMaster.szName) or "",
						nMasterHonorLvl = (pMaster and pMaster.nHonorLevel) or 0,
						nAidCount = Lib:CountTB(self.tbKinAidPlayer[nKinId] or {})
					}
			end
		end

		self.tbAidListSyncInfo.nLastBriefUpdateTime = nNow;
		return true
	end

	return false
end

function tbCross:UpdateBriefKinAidInfo(nKinId)
	if  not self:UpdateBriefInfo() and self.tbAidListSyncInfo.tbAidBriefList[nKinId] then
		self.tbAidListSyncInfo.tbAidBriefList[nKinId].nAidCount = Lib:CountTB(self.tbKinAidPlayer[nKinId] or {})
		self.tbAidListSyncInfo.nVersion = (self.tbAidListSyncInfo.nVersion or 0) + 1
	end
end

function tbCross:OnSyncAidBriefInfo(pPlayer, nVersion)
	self:UpdateBriefInfo()
	if nVersion ~= self.tbAidListSyncInfo.nVersion then
		pPlayer.CallClientScript("DomainBattle.tbCross:SyncAidBriefInfo",
			self.tbAidListSyncInfo.nVersion, self.tbAidListSyncInfo.tbAidBriefList,
			self:GetPlayerAidKinId(pPlayer.dwID))
	end
end

function tbCross:UpdateSyncAidInfo(nKinId, bForce)
	self.tbAidListSyncInfo.tbAidList = self.tbAidListSyncInfo.tbAidList or {}

	local nNow = GetTime()
	local tbAidInfo = self.tbAidListSyncInfo.tbAidList[nKinId];

	if  not tbAidInfo or bForce or (nNow - tbAidInfo.nLastUpdateTime) > 60 then
		tbAidInfo = tbAidInfo or {}
		tbAidInfo.nVersion = (tbAidInfo.nVersion or 0) + 1

		tbAidInfo.tbList = {}

		for nPlayerId, _ in pairs( self.tbKinAidPlayer[nKinId] or {}) do
			local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
			local tbKinData = Kin:GetKinById((pStayInfo and pStayInfo.dwKinId) or 0);
			tbAidInfo.tbList[nPlayerId] =
			{
				szName = (pStayInfo and pStayInfo.szName) or "",
				nFaction = (pStayInfo and pStayInfo.nFaction) or 0,
				nLevel = (pStayInfo and pStayInfo.nLevel) or 0,
				nHonorLevel = (pStayInfo and pStayInfo.nHonorLevel) or 0,
				nPortrait = (pStayInfo and pStayInfo.nPortrait) or 0,
				szKinName = (tbKinData and tbKinData.szName) or "",
			}
		end

		tbAidInfo.nLastUpdateTime = nNow;
		self.tbAidListSyncInfo.tbAidList[nKinId] = tbAidInfo
		return true
	end

	return false
end

function tbCross:AddSyncAidInfo(nKinId, nPlayerId)
	if  not self:UpdateSyncAidInfo(nKinId) and self.tbAidListSyncInfo.tbAidList[nKinId] then
		local pStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
			local tbAidInfo = self.tbAidListSyncInfo.tbAidList[nKinId];
			local tbKinData = Kin:GetKinById((pStayInfo and pStayInfo.dwKinId) or 0);
			tbAidInfo.tbList[nPlayerId] =
			{
				szName = (pStayInfo and pStayInfo.szName) or "",
				nFaction = (pStayInfo and pStayInfo.nFaction) or 0,
				nLevel = (pStayInfo and pStayInfo.nLevel) or 0,
				nHonorLevel = (pStayInfo and pStayInfo.nHonorLevel) or 0,
				nPortrait = (pStayInfo and pStayInfo.nPortrait) or 0,
				szKinName = (tbKinData and tbKinData.szName) or "",
			}

			tbAidInfo.nVersion = (tbAidInfo.nVersion or 0) + 1
	end
end

function tbCross:OnSyncAidList(pPlayer, nVersion)
	local nKinId = pPlayer.dwKinId
	if not self.tbKinList[nKinId] then
		return
	end

	self:UpdateSyncAidInfo(nKinId)

	if not self.tbAidListSyncInfo.tbAidList[nKinId] then
		return
	end

	local tbAidInfo = self.tbAidListSyncInfo.tbAidList[nKinId];

	if nVersion ~= tbAidInfo.nVersion then
		pPlayer.CallClientScript("DomainBattle.tbCross:SyncAidList",
			tbAidInfo.nVersion, tbAidInfo.tbList)
	end
end

function tbCross:OnAidRequest(pPlayer, nKinId)
	if not self.bAidSignUp then
		return
	end

	local nMyKinId = pPlayer.dwKinId
	if nMyKinId <= 0 then
		return
	end

	if nKinId == nMyKinId then
		return
	end

	if not self.tbKinList[nKinId] then
		return
	end

	local nMinHonorLevel = self:GetAidMinHonorLevel()

	if pPlayer.nHonorLevel < nMinHonorLevel then
		return
	end

	if Lib:CountTB(self.tbKinAidPlayer[nKinId] or {}) >= tbCrossDef.nAidCount then
		self:OnSyncAidBriefInfo(pPlayer)
		return
	end

	self:AddAidPlayer(pPlayer.dwID, nKinId)
	self:OnSyncAidBriefInfo(pPlayer)
	pPlayer.CenterMsg("助战成功")
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin,
				string.format(XT("侠士「%s」已报名成为本帮派跨服攻城战的助战。"), pPlayer.szName),
				nKinId);
end

function tbCross:AddAidPlayer(nPlayerId, nKinId)
	self.tbKinAidPlayer[nKinId] = self.tbKinAidPlayer[nKinId] or {}
	self.tbKinAidPlayer[nKinId][nPlayerId] = true
	self.tbAidList[nPlayerId] = nKinId
	self:AddSyncAidInfo(nKinId, nPlayerId)
	self:UpdateBriefKinAidInfo(nKinId)

	ScriptData:AddModifyFlag("DomainBattleCross")

	Log("[Info]", "DomainBattleCross", "AddAidPlayer", nPlayerId, nKinId)
end

function tbCross:OnJoinKin(nPlayerId, nKinId)
	local nAidKinId = self.tbAidList[nPlayerId]
	if nAidKinId and self.tbKinList[nKinId] then
		self:RemoveAidPlayer(nPlayerId)
	end
end

function tbCross:RemoveAidPlayer(nPlayerId)
	local nAidKinId = self.tbAidList[nPlayerId]
	if not nAidKinId then
		Log("[Error]", "DomainBattleCross", "RemoveAidPlayer Failed No Aid Kin", nPlayerId)
		return
	end

	self.tbKinAidPlayer[nAidKinId] = self.tbKinAidPlayer[nAidKinId] or {}
	self.tbKinAidPlayer[nAidKinId][nPlayerId] = nil
	self.tbAidList[nPlayerId] = nil
	self:UpdateSyncAidInfo(nAidKinId, true)
	self:UpdateBriefInfo(true)

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.CenterMsg("你失去了跨服攻城战的助战资格")
	end

	Log("[Info]", "DomainBattleCross", "RemoveAidPlayer", nPlayerId, nAidKinId)
end

function tbCross:SendLocalData()
	local tbData = {}
	self.nMaxNpcLevel = self:GetMaxNpcLevel()
	self.nSiegeBuffLevel = self:GetSiegeBuffLevel()
	tbData.nMaxNpcLevel = self.nMaxNpcLevel
	tbData.nSiegeBuffLevel = self.nSiegeBuffLevel
	tbData.tbKinList = {}
	tbData.tbAidList = self.tbAidList
	for nKinId, tbKinInfo in pairs( self.tbKinList ) do
		local tbKinData = Kin:GetKinById(nKinId);
		if tbKinData then
			--如果没有领袖奖励发给族长
			local nMasterId = tbKinData:GetMasterId()
			local pMasterData = Kin:GetMemberData(nMasterId);
			local szMasterName =  (pMasterData and pMasterData:GetName()) or "暂无";
			local nLeaderId = tbKinData:GetLeaderId()
			local pLeaderData = Kin:GetMemberData(nLeaderId);
			nLeaderId = (pLeaderData and nLeaderId) or nMasterId;
			local nLeaderResId, tbLeaderPartRes = Player:GetFeatureInfo(nLeaderId)
			local pLeaderRoleStay = KPlayer.GetRoleStayInfo(nLeaderId)

			tbData.tbKinList[nKinId] =
			{
				nKinId = nKinId,
				szName = tbKinData.szName,
				nMasterId = tbKinData:GetMasterId(),
				szMasterName = szMasterName,
				nLeaderId = nLeaderId,
				szLeaderName = pLeaderRoleStay.szName,
				nLeaderHonorLevel = pLeaderRoleStay.nHonorLevel,
				nLeaderFaction = pLeaderRoleStay.nFaction,
				nLeaderResId = nLeaderResId,
				nLeaderSex = pLeaderRoleStay.nSex,
				tbLeaderPartRes = tbLeaderPartRes,
				nScore = tbKinInfo.nScore,
				nRank = tbKinInfo.nRank,
				nDomainType = tbKinInfo.nDomainType,
				tbCanUseSupplyPlayer = tbKinData:GetCareerList(tbDefine.tbCanUseItemCareer),
				tbBattleSupply = tbKinData:GetBattleApplys(),
			}
		end
	end
	CallZoneServerScript("DomainBattle.tbCross:OnRecvLocalData", tbData);

	Log("[Info]", "DomainBattleCross", "SendLocalData")
	Lib:Tree(tbData)
end

function tbCross:OnLocalUseSupply(nKinId, nItemId)
	local tbKin = Kin:GetKinById(nKinId)
	if not tbKin then
		Log("[Error]", "DomainBattleCross", "OnLocalUseSupply Failed Not Found Kin", nKinId)
		return
	end

	local bRet, _ = tbKin:UseBattleApplys(nItemId)
	if not bRet then
		Log("[Error]", "DomainBattleCross", "OnLocalUseSupply Use Failed", nKinId, nItemId)
	end
end

function tbCross:EnterRequest(pPlayer)
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		pPlayer.CenterMsg("目前状态不允许切换地图")
		return
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight"  then
		pPlayer.CenterMsg("当前地图无法参加！")
		return
	end

	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
		pPlayer.CenterMsg("请回到安全区域後参加！")
		return
	end

	if not pPlayer.nState == Player.emPLAYER_STATE_ALONE then
		pPlayer.CenterMsg("目前状态不允许切换地图")
		return
	end


	local nPlayerId = pPlayer.dwID
	local nKinId = pPlayer.dwKinId
	local nJoinKinId = (self.tbKinList[nKinId] and nKinId) or self.tbAidList[nPlayerId]

	if not nJoinKinId then
		pPlayer.CenterMsg("尚未获得参加资格")
		return
	end

	if pPlayer.nLevel < tbCrossDef.nMinLevel then
		pPlayer.CenterMsg(string.format("等级未满%d级，不可参加跨服攻城战", tbCrossDef.nMinLevel))
		return
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		pPlayer.CenterMsg("目前状态不允许切换地图")
		return
	end

	local tbKinInfo = self.tbKinList[nJoinKinId]
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "EnterRequest Failed Not Found Kin Info", nPlayerId, nKinId, nJoinKinId)
		pPlayer.CenterMsg("暂时无法参加跨服攻城战，请联系客服协助")
		return
	end

	if not tbKinInfo.tbOuterCampInfo then
		pPlayer.CenterMsg("跨服攻城战尚未开启，请稍候再试")
		return
	end

	local nX, nY = self:GetCampPos(tbKinInfo.tbOuterCampInfo.nMapTemplateId, tbKinInfo.tbOuterCampInfo.nIndex)

	if not nX or not nY then
		Log("[Error]", "DomainBattleCross", "EnterRequest Failed Not Found Outer Camp Pos",
			nPlayerId, nKinId, nJoinKinId, tbKinInfo.tbOuterCampInfo.nIndex)
		pPlayer.CenterMsg("暂时无法参加跨服攻城战，请联系客服协助")
		return
	end

	pPlayer.CallClientScript("Ui:CloseWindow", "KinDetailPanel")

	pPlayer.SetEntryPoint();
	pPlayer.SwitchZoneMap(tbKinInfo.tbOuterCampInfo.nMapId, nX, nY);
end

function tbCross:SyncAidSignUpState(pPlayer)
	if self.bAidSignUp then
		pPlayer.CallClientScript("DomainBattle.tbCross:SyncAidSignUpState", self.bAidSignUp)
	end
end

function tbCross:OnPrepareNotice()
	if not self:CheckCrossDay() then
		return
	end

	self.bAidSignUp = false;

	KPlayer.BoardcastScript(1, "DomainBattle.tbCross:SyncAidSignUpState", self.bAidSignUp);

	KPlayer.SendWorldNotify(1, 1000,
				"跨服攻城战将于10分钟後开始，请参战帮派提前做好入场准备。",
				ChatMgr.ChannelType.Public, 1);

	self:SendLocalData()
end

function tbCross:OnAssignOuterCamp(nKinId, nMapTemplateId, nMapId, nIndex)
	local tbKinInfo = self.tbKinList[nKinId]
	if not tbKinInfo then
		Log("[Error]", "DomainBattleCross", "OnAssignOuterCamp Failed Not Found Kin Info", nKinId, nMapTemplateId, nMapId, nIndex)
		return
	end

	tbKinInfo.tbOuterCampInfo = {nMapTemplateId = nMapTemplateId, nMapId = nMapId, nIndex = nIndex}

	Log("[Info]", "DomainBattleCross", "OnAssignOuterCamp", nKinId, nMapTemplateId, nMapId, nIndex)
end

function tbCross:ClearAssignOuterCamp()
	for _, tbKinInfo in pairs( self.tbKinList ) do
		tbKinInfo.tbOuterCampInfo = nil
	end

	Log("[Info]", "DomainBattleCross", "ClearAssignOuterCamp")
end

function tbCross:OnLocalStart()
	if not self:CheckCrossDay() then
		return
	end

	self.tbCrossKinAwardList = {}

	Calendar:OnActivityBegin("CrossDomainBattle")
	local tbMsgData =
	{
		szType = "DomainCrossStart";
		nTimeOut = GetTime() + 35*60;
	};

	KPlayer.BoardcastScript(tbCrossDef.nMinLevel, "Ui:SynNotifyMsg", tbMsgData);


	KPlayer.SendWorldNotify(1, 1000,
				"跨服攻城战已经开始，请所有参加帮派尽快进入战场，为夺取帮派领地而战！",
				ChatMgr.ChannelType.Public, 1);
end

function tbCross:GetRankAwardList(nTotal, tbAwardCfg)
	local tbRankAward = {}
	local nLastRankEnd = 0;
	for _, tbCfg in ipairs(tbAwardCfg) do
		local nRankEnd = tbCfg.nRankEnd
		if  nRankEnd > 3 then
			nRankEnd = math.max(math.floor(nTotal * nRankEnd/100), nLastRankEnd + 1)
		end
		table.insert(tbRankAward, {nRankEnd = nRankEnd, tbAward = tbCfg.tbAward})
		if nRankEnd >= nTotal then
			break;
		end
		nLastRankEnd = nRankEnd
	end
	return tbRankAward
end

function tbCross:GetRankAward(nRank, tbRankAward)
	for _, tbRankInfo in ipairs( tbRankAward ) do
		if nRank <= tbRankInfo.nRankEnd then
			return tbRankInfo.tbAward
		end
	end
end

function tbCross:CombineLocalData(tbData)
	Log("[Info]", "DomainBattleCross", "CombineLocalData")
	Log("Old Data")
	Lib:Tree(self.tbLocalData)
	local tbScore = tbData.tbScore or {}

	for nKinId, nScore in pairs( tbScore ) do
		self.tbScore[nKinId] = nScore
	end

	ScriptData:AddModifyFlag("DomainBattleCross")

	Log("New Data")
	Lib:Tree(self.tbLocalData)
end

function tbCross:NotifyFirstKin(tbFirstKin)
	self.tbFirstKinLeader =
	{
		nServerId = tbFirstKin.nServerId,
		szKinFullName = tbFirstKin.szKinFullName or "",
		szKinName = tbFirstKin.szKinName or "",
		nLeaderId = tbFirstKin.nLeaderId,
		szLeaderName = tbFirstKin.szLeaderName or "",
		nLeaderHonorLevel = tbFirstKin.nLeaderHonorLevel or 0,
		nLeaderFaction = tbFirstKin.nLeaderFaction or 0,
		nLeaderSex = tbFirstKin.nLeaderSex,
		nLeaderResId = tbFirstKin.nLeaderResId or 0 ,
		tbLeaderPartRes = tbFirstKin.tbLeaderPartRes or {},
	}

	self.tbLocalData.tbFirstKinLeader = self.tbFirstKinLeader

	ScriptData:AddModifyFlag("DomainBattleCross")

	local nNextOpenTime = self:GetCrossOpenTime(true)

	local nServerId = GetServerIdentity();
	if tbFirstKin.nServerId == nServerId then
		--发城主奖励
		Mail:SendSystemMail(
		{
			To = tbFirstKin.nLeaderId,
			Title = "恭喜阁下成为临安城主",
			Text = "      在阁下英明神武的领导下，您的帮派同仇敌忾浴血奋战，终於夺下临安城获得无上荣耀，您也成为了临安城的新主人，特赠与阁下贺礼聊表心意。",
			tbAttach = {{"AddTimeTitle", 6001, nNextOpenTime},{"Item", 7383, 1, nNextOpenTime}},
			From = "独孤剑",
			nLogReazon = Env.LogWay_DomainBattleMaster,
		})
	end

	self:UpdateStatue();

	local tbSetting =
	{
		szTitle = "临安城主",
		szUiName = "NewInfo_TerritoryChampionship",
	}
	NewInformation:AddInfomation("CrossDomainOwner", nNextOpenTime, self.tbFirstKinLeader, tbSetting)

	KPlayer.SendWorldNotify(1, 1000,
				string.format("跨服攻城战已经结束，恭喜来自%s的<%s>帮派占据了「临安城」！",
					Sdk:GetServerDesc(tbFirstKin.nServerId),
					tbFirstKin.szKinName),
				ChatMgr.ChannelType.Public, 1);
end

function tbCross:OnLocalAward(tbKinRankInfo)
	Log("[Info]", "DomainBattleCross", "OnLocalAward")
	Lib:Tree(tbKinRankInfo)

	local nServerId = GetServerIdentity();
	if tbKinRankInfo.nServerId ~= nServerId then
		return
	end

	self.tbCrossKinAwardList = self.tbCrossKinAwardList or {}
	self.tbCrossKinAwardList[tbKinRankInfo.nRank] = tbKinRankInfo
	local szAwardFrame = Lib:GetMaxTimeFrame(tbCrossDef.tbKinAward)
	local tbKinTimeFrameAward = tbCrossDef.tbKinAward[szAwardFrame]
	if not tbKinTimeFrameAward then
		Log("[Error]", "DomainBattleCross", "No Kin TimeFrame Award", szAwardFrame)
		return
	end

	local kinData = Kin:GetKinById(tbKinRankInfo.nKinId);
	if kinData then
		local nAwardValue = tbCrossDef.tbKinRankAward[tbKinRankInfo.nRank]
		if nAwardValue then
			local tbAward = {}
			for _, tbAwardInfo in pairs( tbKinTimeFrameAward ) do
				local nItemAwardValue = nAwardValue*tbAwardInfo.nFactor;
				local szGuaranteeKey = string.format("CrossDomain_%s", tostring(tbAwardInfo.nId));
				local nCount = 0;
				if tbAwardInfo.Guarantee == 1 then
					nCount = RandomAward:GetKinGuaranteeAwardCount(tbKinRankInfo.nKinId, nItemAwardValue, tbAwardInfo.nValue, szGuaranteeKey);
				else
					nCount = RandomAward:GetKinAwardCount(tbKinRankInfo.nKinId, nItemAwardValue, tbAwardInfo.nValue, szGuaranteeKey);
				end

				if nCount > 0 then
					table.insert(tbAward, {tbAwardInfo.nId, nCount, tbAwardInfo.SilverBoard == 1, false, tbAwardInfo.SilverBoard == 1})
				end
			end

			local tbPlayerSet = {}
			for _, tbPlayerInfo in pairs( tbKinRankInfo.tbPlayerList or {} ) do
				if not tbPlayerInfo.bAid then
					tbPlayerSet[tbPlayerInfo.nPlayerId] = true
				end
			end
			local nTotalCount = #(tbKinRankInfo.tbPlayerList or {})
			local tbRankAward = self:GetRankAwardList(nTotalCount, tbCrossDef.tbPlayerAward)
			for nKinPlayerRank, tbPlayerInfo in ipairs( tbKinRankInfo.tbPlayerList or {} ) do
				local tbPlayerAward = self:GetRankAward(nKinPlayerRank, tbRankAward)
				if tbPlayerAward then
					Mail:SendSystemMail(
					{
						To = tbPlayerInfo.nPlayerId,
						Title = "跨服攻城战奖励",
						Text = string.format("    跨服攻城战已结束，你的征战积分在%s帮派中排名[FFFE0D]第%d名[-]，奖励请领取附件。", 
							(tbPlayerInfo.bAid and "所助战的") or "",nKinPlayerRank),
						tbAttach = tbPlayerAward,
						nLogReazon = Env.LogWay_DomainBattle,
					})
				else
					Log("[Error]", "DomainBattleCross", "OnLocalAward Player Failed No Award",
						tbPlayerInfo.nPlayerId, tbPlayerInfo.nRank, nKinPlayerRank, nTotalCount)
					Lib:Tree(tbRankAward)
				end
			end

			if nTotalCount > 0 then
				Kin:AddAuction(tbKinRankInfo.nKinId, "DomainBattleCross", tbPlayerSet, tbAward);
			else
				Log("[Info]", "DomainBattleCross", "OnLocalAward Kin No Player Attend Award",
					tbKinRankInfo.nRank, tbKinRankInfo.nKinId)
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin,
						"由於无人参加跨服攻城战，本帮派没有获得任何奖励！",
						tbKinRankInfo.nKinId);
			end
		else
			Log("[Error]", "DomainBattleCross", "OnLocalAward Kin Failed No Award",
				tbKinRankInfo.nRank, tbKinRankInfo.nKinId)
		end
	end
end

function tbCross:OnLocalEnd()
	Log("[Info]", "DomainBattleCross", "OnLocalEnd")
	self.tbLocalData.nLastOpenDay = Lib:GetLocalDay()
	ScriptData:AddModifyFlag("DomainBattleCross")
	self.tbKinFireTimers = {};
	local nServerId = GetServerIdentity();

	for _, tbRankInfo in pairs(self.tbCrossKinAwardList or {}) do
		if tbRankInfo.nServerId == nServerId then
			local kinData = Kin:GetKinById(tbRankInfo.nKinId);
			if kinData then
				--创建各自的家族篝火
				kinData:CallWithMap(function ()
					local nMapId = kinData:GetMapId();
					self.tbKinFireTimers[tbRankInfo.nKinId] = Timer:Register(Env.GAME_FPS * tbDefine.nFireNpcTime, function ()
						self.tbKinFireTimers[tbRankInfo.nKinId]  = nil;
						KPlayer.MapBoardcastScript(nMapId, "Dialog:SendBlackBoardMsg", nil, "跨服攻城战聚集总结活动结束")
					end)

					SetMapSurvivalTime(nMapId, GetTime() + tbDefine.nFireNpcTime);
					local pFireNpc = KNpc.Add(tbDefine.FireNpcTemplateId, 1, 0, nMapId, Kin.GatherDef.FireNpcPosX, Kin.GatherDef.FireNpcPosY);
					if pFireNpc then
						pFireNpc.tbTmp.nKey = tbRankInfo.nKinId;
					end
				end);
			end
		end
	end

	self:ClearLocalData()
end

function tbCross:OnReConnectZoneClient(pPlayer)
	local dwKinId = pPlayer.dwKinId
	if self.tbKinFireTimers and  self.tbKinFireTimers[dwKinId] then
		local kinData = Kin:GetKinById(dwKinId);
		if kinData then
			kinData:GoMap(pPlayer.dwID);
		end
	end
end

function tbCross:OnEnterKinMap(pPlayer)
	local dwKinId = pPlayer.dwKinId
	if self.tbKinFireTimers and  self.tbKinFireTimers[dwKinId] then
		pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeftInfo", "DomainBattleFire",
				{nil, math.floor(Timer:GetRestTime(self.tbKinFireTimers[dwKinId]) / Env.GAME_FPS)})

		pPlayer.SendBlackBoardMsg("跨服攻城战慰劳篝火已点燃，大家休整一下吧！")
	end
end

function tbCross:AddPlayerHonorBox(pPlayer, nLogReazon, nLogReazon2, szType, nGetHonor)
	local nPlayerId = pPlayer.dwID
	local pAsync = KPlayer.GetAsyncData(nPlayerId);
	if not pAsync then
		Log("[Error]", "DomainBattleCross", "AddPlayerHonorBox Failed No Player Async Data", nPlayerId, nLogReazon, nLogReazon2, szType, nCount)
		return
	end

	local nCurHonor = pAsync.GetCrossDomainHonor();
	local nLeftHonor = nCurHonor + nGetHonor;
	local nCanChangeNum = math.floor(nLeftHonor / tbCrossDef.nHonor2Box)
	if nCanChangeNum > 0 then
		local nCostHonor = nCanChangeNum * tbCrossDef.nHonor2Box
		nLeftHonor = nLeftHonor - nCostHonor
		pPlayer.SendAward({{"item", tbCrossDef.nAwardBoxId, nCanChangeNum }}, true, true, nLogReazon, nLogReazon2)
	end

	pAsync.SetCrossDomainHonor(nLeftHonor);
end

function tbCross:UpdateStatue()
	if self.nStatueNpcId and self.nStatueNpcId > 0 then
		local pOldNpc = KNpc.GetById(self.nStatueNpcId)
		if pOldNpc then
			pOldNpc.Delete();
		end

		self.nStatueNpcId = nil
	end

	if not self.tbFirstKinLeader or  not self.tbFirstKinLeader.nLeaderId then
		KPlayer.BoardcastScript(1, "DomainBattle.tbCross:SyncCityMiniMapStatue", false);
		return
	end

	local tbStatueId = tbDefine.tbMasterStatueId[self.tbFirstKinLeader.nLeaderFaction]
	if not tbStatueId then
		Log("[Error]", "DomainBattleCross", "UpdateStatue Failed No Statue Id")
		Lib:Tree(self.tbFirstKinLeader)
		Lib:Tree(tbDefine.tbMasterStatueId)
		return
	end

	local nStatueId = tbStatueId[self.tbFirstKinLeader.nLeaderSex]
	if not nStatueId then
		Log("[Error]", "DomainBattleCross", "UpdateStatue Failed No Statue Id")
		Lib:Tree(self.tbFirstKinLeader)
		Lib:Tree(tbDefine.tbMasterStatueId)
		return
	end

	local nMapId, nX, nY, nDir = unpack(tbCrossDef.tbStatuePos)
	local pNpc = KNpc.Add(nStatueId, 1, 0, nMapId, nX, nY, 0, nDir)
	if not pNpc then
		Log("[Error]", "DomainBattleCross", "UpdateStatue Failed Add Npc Failed", nStatueId)
		Lib:Tree(self.tbFirstKinLeader)
		return
	end

	pNpc.SetName(string.format("［%s］%s", Sdk:GetServerDesc(self.tbFirstKinLeader.nServerId), self.tbFirstKinLeader.szLeaderName))

	pNpc.SetTitleID(6001);

	pNpc.bCross = true;
	pNpc.nCrossServerId = self.tbFirstKinLeader.nServerId
	pNpc.nCrossLeaderId = self.tbFirstKinLeader.nLeaderId

	self.nStatueNpcId = pNpc.nId;

	KPlayer.BoardcastScript(1, "DomainBattle.tbCross:SyncCityMiniMapStatue", true);
end

function tbCross:CityMiniMapStatueReq(pPlayer)
	pPlayer.CallClientScript("DomainBattle.tbCross:SyncCityMiniMapStatue", self.tbFirstKinLeader and self.tbFirstKinLeader.nLeaderId)
end

function tbCross:OnLocalKillPlayer(nPlayerId)
	Achievement:AddCount(nPlayerId, "DomainBattle_1", 1)
	RecordStone:AddRecordCount(nPlayerId, "Domain", 1)
end
