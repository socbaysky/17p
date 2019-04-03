Require("CommonScript/EnvDef.lua");
Require("CommonScript/Npc/NpcDefine.lua");
Require("CommonScript/Item/XiuLian.lua");
Require("ServerScript/Common/Env.lua");
Require("CommonScript/Item/Class/XinDeBook.lua");

local tbXiuLianDef = XiuLian.tbDef;
local tbXinDe = Item:GetClass("XinDeBook");
local tbOfflineNotifyMsg = {}

Player.emPLAYER_STATE_NONE = 0;
Player.emPLAYER_STATE_LOADING = 1;
Player.emPLAYER_STATE_NORMAL = 2;
Player.emPLAYER_STATE_ALONE = 3;
Player.emPLAYER_STATE_OFFLINE = 4;
Player.emPLAYER_STATE_ZONE = 5;

Player.tbAccountRoleQueryList = Player.tbAccountRoleQueryList or {};
Player.tbRoleInfoQueryList = Player.tbRoleInfoQueryList or {};
Player.tbAccountRoleMatchList = Player.tbAccountRoleMatchList or {};
Player.nAccountRoleQuerySeq = Player.nAccountRoleQuerySeq or 0;
Player.nRoleInfoQuerySeq = Player.nRoleInfoQuerySeq or 0;
Player.nAccountRoleMatchSeq = Player.nAccountRoleMatchSeq or 0;

Player.tbExcerciseRequest = Player.tbExcerciseRequest or {};

function Player:LoadServerData()
	self.tbExpRuleData = {};

	local tbFileData = Lib:LoadTabFile("Setting/Player/ExpRule.tab", {});
	for _, tbInfo in pairs(tbFileData) do
		local nPlayerLevel = tonumber(tbInfo["0"]);
		self.tbExpRuleData[nPlayerLevel] = {};
		local tbLevelData = self.tbExpRuleData[nPlayerLevel];
		for nNpcLevel = 1, Npc.MAX_NPC_LEVEL do
			local szPercent = tbInfo[tostring(nNpcLevel)]
			if not Lib:IsEmptyStr(szPercent) then
				tbLevelData[nNpcLevel] = tonumber(szPercent);
			end
		end
	end
end

Player:LoadServerData();

function Player:GetExpRule(nPlayerLevel, nTarLevel)
	local tbLevelData = self.tbExpRuleData[nPlayerLevel];
	if not tbLevelData then
		return 0;
	end

	return tbLevelData[nTarLevel] or 0;
end

function Player:CalcPlayerExpByLevel(nExp, nSelfLevel, nTarLevel)
	local nPercent = self:GetExpRule(nSelfLevel, nTarLevel);
	local nGetExp = nExp * nPercent / 100;

	if nGetExp <= 0 then
		nGetExp = 1;
	end

	return nGetExp;
end

function Player:AddXiuLianExp(pPlayer, nExp, nTarLevel,bIsField)
	if not nTarLevel then
		nTarLevel = pPlayer.nLevel;
	end

	local nTarExp = Player:CalcPlayerExpByLevel(nExp, pPlayer.nLevel, nTarLevel)
	local nExpAddP = 0;
	local nCalcTarExp = XiuLian:CalcXiuLianExpAddP(pPlayer, nTarExp);

	local pPlayerNpc = pPlayer.GetNpc();
	if bIsField then
		nExpAddP = nExpAddP + pPlayerNpc.nEnhanceExpP;
	end
	local nGetTarExp = nCalcTarExp * (100 + nExpAddP) / 100;
	nGetTarExp = math.floor(nGetTarExp);
	if nGetTarExp > 0 then
		pPlayer.AddExperience(nGetTarExp, Env.LogWay_XiuLian);
	end
	--Log("Player AddXiuLianExp", pPlayer.dwID, nGetTarExp, nExpAddP, pPlayer.nLevel, nTarLevel);
end

function Player:SendNotifyMsg(dwRoleId, tbData)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if pPlayer and pPlayer.nState == 2 then
		pPlayer.CallClientScript("Ui:SynNotifyMsg", tbData)
	else
		tbOfflineNotifyMsg[dwRoleId] = tbOfflineNotifyMsg[dwRoleId] or {}
		table.insert(tbOfflineNotifyMsg[dwRoleId], tbData)
	end
end

function Player:NotifyMsgOnLogin(pPlayer)
	local tbDatas = tbOfflineNotifyMsg[pPlayer.dwID]
	if tbDatas then
		for i,tbData in ipairs(tbDatas) do
			pPlayer.CallClientScript("Ui:SynNotifyMsg", tbData)
		end
		tbOfflineNotifyMsg[pPlayer.dwID] = nil;
	end
end

Player.tbFieldComboKillFun =
{
	["FieldBoss"] = function (pPlayer, nFieldComboSkill)
		if pPlayer.dwKinId <= 0 then
			return;
		end

		if not BossLeader.tbComboSkillCount[nFieldComboSkill] then
			return;
		end

		local  szExtMsg = "";
		if MODULE_ZONESERVER then
			szExtMsg = "【跨服】";
		end

		local szShowMsg = string.format("「%s」在挑战名将时，连斩%s人！", pPlayer.szName, nFieldComboSkill);
		Lib:CallZ2SOrLocalScript(pPlayer.nZoneIndex, "BossLeader:SendCrossKinMsg", szExtMsg..szShowMsg, pPlayer.dwOrgKinId);
	end,

	["ImperialTomb"] = function (pPlayer, nFieldComboSkill)
		if pPlayer.dwKinId <= 0 then
			return;
		end

		if not BossLeader.tbComboSkillCount[nFieldComboSkill] then
			return;
		end

		local szShowMsg = string.format("「%s」在秦始皇陵中大展身手，连斩%s人！", pPlayer.szName, nFieldComboSkill);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pPlayer.dwKinId);
	end,

	["FemaleImperialTomb"] = function (pPlayer, nFieldComboSkill)
		if pPlayer.dwKinId <= 0 then
			return;
		end

		if not BossLeader.tbComboSkillCount[nFieldComboSkill] then
			return;
		end

		local szShowMsg = string.format("「%s」在女帝疑塚中大展身手，连斩%s人！", pPlayer.szName, nFieldComboSkill);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pPlayer.dwKinId);
	end,
}

function Player:AddFieldComboKill(pPlayer)
	local pNpc = pPlayer.GetNpc();
	if not pNpc then
		return;
	end

	local nMapTemplateId = pNpc.nMapTemplateId;
	if not pPlayer.bOpenComboSkill and not Map:IsFieldFightMap(nMapTemplateId) then
		return;
	end

	pPlayer.nFieldComboSkill = pPlayer.nFieldComboSkill or 0;
	pPlayer.nFieldComboSkill = pPlayer.nFieldComboSkill + 1;

	if pPlayer.szComboSkillFun and Player.tbFieldComboKillFun[pPlayer.szComboSkillFun] then
		local FunComboSkill = Player.tbFieldComboKillFun[pPlayer.szComboSkillFun];
		FunComboSkill(pPlayer, pPlayer.nFieldComboSkill);
	end

	pPlayer.CallClientScript("Ui:ShowComboKillCount", pPlayer.nFieldComboSkill);
end

function Player:ClearFieldComboKill(pPlayer)
	pPlayer.nFieldComboSkill = nil;
end

function Player:OnDelayCmd( szCmd, szComment )
	loadstring(szCmd)();
end

function Player:OnDelayCmdEnd(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.OnEvent("OnDelayCmdEnd");
	end
end

function Player:GetQuerySaveData(pPlayer)
	local tbTitleData = PlayerTitle:GetPlayerTitleData(pPlayer)
	local nActivateTitle = tbTitleData.nActivateTitle or 0;
	local tbAllTitleIds = {}
	for k,v in pairs(tbTitleData.tbAllTitle) do
		table.insert(tbAllTitleIds, k)
	end
	local szTittleIds = table.concat(tbAllTitleIds, ",");

	local tbFightPowerData = pPlayer.GetScriptTable("FightPower");

	return pPlayer.GetMoney("Gold") - pPlayer.GetMoneyDebt("Gold"),
		pPlayer.GetMoney("Coin"),
		pPlayer.GetMoney("Jade"),
		pPlayer.GetMoney("Contrib"),
		pPlayer.GetVipLevel(),
		Recharge:GetTotoalRecharge(pPlayer),
		tbTitleData.nActivateTitle,
		szTittleIds,
		pPlayer.GetMoney("Biography"),
		pPlayer.GetMoney("Honor"),
		pPlayer.GetMoney("SkillPoint"),
		pPlayer.GetFightPower(),
		RankBattle:GetBestRank(pPlayer),
		tbFightPowerData.nStoneFightPower or 0,
		tbFightPowerData.nSkillFightPower or 0,
		tbFightPowerData.nEquipFightPower or 0,
		tbFightPowerData.nLevelFightPower or 0,
		tbFightPowerData.nStrengthenFightPower or 0,
		tbFightPowerData.nHonorFightPower or 0,
		tbFightPowerData.nPartnerFightPower or 0,
		pPlayer.GetMoney("Energy"),
		pPlayer.GetMoney("SilverBoard"),
		tbFightPowerData.nHouseFightPower or 0,
		pPlayer.GetMoney("ZhenQi"),
		pPlayer.GetMoney("SkillExp");
end

function Player:GetPlayerLoginTLogInfo(pPlayer)
	local nCarrer = Kin:GetPlayerCareer(pPlayer.dwID)
	local tbHouse = House:GetHouse(pPlayer.dwID)
	local nHouseLevel, nComfortValue, nMagicBowlLevel = 0,0,0;
	if tbHouse then
		nHouseLevel = tbHouse.nLevel
		nComfortValue = tbHouse.nComfortValue 
		if tbHouse.tbMagicBowl and tbHouse.tbMagicBowl.nLevel then
			nMagicBowlLevel = tbHouse.tbMagicBowl.nLevel 	
		end
	end 
	local nTotalCharm = Item.tbChangeColor:GetCacheCharm(pPlayer)
	return nCarrer, (pPlayer.nInsetExIdx or 0), (pPlayer.nEnhExIdx or 0), nHouseLevel, nComfortValue, nTotalCharm, nMagicBowlLevel
end

function Player:SendServerIdentity(pPlayer)
	local nServerIndentity = Sdk:GetServerId();
	pPlayer.CallClientScript("Player:SendServerIdentity", nServerIndentity);
end

function Player:DoAccountRoleListRequest(szAccount, nPlatId, fnCallBack, callObj, ...)
	self.nAccountRoleQuerySeq = self.nAccountRoleQuerySeq + 1;
	local nSeq = self.nAccountRoleQuerySeq;
	self.tbAccountRoleQueryList[nSeq] =
	{
		fnCallBack = fnCallBack,
		callObj = callObj,
		param = {...},
	}

	KPlayer.RequestAccountRoleList(szAccount, nPlatId, nSeq)
end

function Player:DoPlayerQueryInfoRequest(dwPlayerId, fnCallBack, callObj, ...)
	self.nRoleInfoQuerySeq = self.nRoleInfoQuerySeq + 1;
	local nSeq = self.nRoleInfoQuerySeq;
	self.tbRoleInfoQueryList[nSeq] =
	{
		fnCallBack = fnCallBack,
		callObj = callObj,
		param = {...},
	}

	KPlayer.RequestRoleQueryInfo(dwPlayerId, nSeq)
end

function Player:DoAccountRoleMatchRequest(szAccount, dwPlayerId, fnCallBack, callObj, ...)
	self.nAccountRoleMatchSeq = self.nAccountRoleMatchSeq + 1;
	local nSeq = self.nAccountRoleMatchSeq;
	self.tbAccountRoleMatchList[nSeq] =
	{
		fnCallBack = fnCallBack,
		callObj = callObj,
		param = {...},
	}
	dwPlayerId = tonumber(dwPlayerId) or -1
	KPlayer.QueryAccountRoleMatch(szAccount, dwPlayerId, nSeq)
end

function Player:OnAccountRoleListResult(nSeq, szAccount, tbRoleList)
	local callBackInfo = self.tbAccountRoleQueryList[nSeq]
	if callBackInfo and callBackInfo.fnCallBack then
		local function fnExc()
			if callBackInfo.callObj then
				  callBackInfo.fnCallBack(callBackInfo.callObj, szAccount, tbRoleList, unpack(callBackInfo.param))
			else
					callBackInfo.fnCallBack(szAccount, tbRoleList, unpack(callBackInfo.param))
			end
		end
		xpcall(fnExc, Lib.ShowStack);
	end
	self.tbAccountRoleQueryList[nSeq] = nil
end

function Player:OnLoadPlayerQueryInfo(nSeq, tbQueryInfo)
	local callBackInfo = self.tbRoleInfoQueryList[nSeq]
	if callBackInfo and callBackInfo.fnCallBack then
		local function fnExc()
			if callBackInfo.callObj then
				  callBackInfo.fnCallBack(callBackInfo.callObj, tbQueryInfo, unpack(callBackInfo.param))
			else
					callBackInfo.fnCallBack(tbQueryInfo, unpack(callBackInfo.param))
			end
		end
		xpcall(fnExc, Lib.ShowStack);
	end
	self.tbRoleInfoQueryList[nSeq] = nil
end

function Player:OnAccountRoleMatchResult(nSeq, szAccount, dwPlayerId, nIsMatch)
	local callBackInfo = self.tbAccountRoleMatchList[nSeq]
	if callBackInfo and callBackInfo.fnCallBack then
		local function fnExc()
			if callBackInfo.callObj then
				callBackInfo.fnCallBack(callBackInfo.callObj, szAccount, dwPlayerId, nIsMatch, unpack(callBackInfo.param))
			else
				callBackInfo.fnCallBack(szAccount, dwPlayerId, nIsMatch, unpack(callBackInfo.param))
			end
		end
		xpcall(fnExc, Lib.ShowStack);
	end
	self.tbAccountRoleMatchList[nSeq] = nil
end

function Player:UpdateNormalValue(pPlayer, pASynPlayer)
	pASynPlayer.SetCoin(pPlayer.GetMoney("Coin"));
end

function Player:GetPlayerCoin(pPlayer, pASynPlayer)
	if pPlayer then
		return pPlayer.GetMoney("Coin")
	end
	if pASynPlayer then
		return pASynPlayer.GetCoin() + pASynPlayer.GetCoinAdd()
	end
	Log(debug.traceback())
	return 0;
end


---------------定义Log统一数据类型-------------------
-----玩家自身可以获得不需要添加 无法获取的变量可以不填写 按照不同的活动Log规则填写  不足再补充------
-- local tbLog =
-- {
--	 Result = Env.LogRound_SUCCESS;  --结果 Env.LogRound_FAIL = 0 失败   Env.LogRound_SUCCESS = 1 成功
--	 nMatchTime = 1; --消耗的时间
--	 nRank = 1; --活动排名
--	 nScore = 1; --活动的分数
--	 MoneyType = "Gold"; -- 暂时可选 获得的货币的类型
--	 nMoney = 1; --暂时可选 获得的货币
--	 SubActivityType = ; --二级活动标识 根据活动来填写
-- };

---Log的行为
Player.tbFunActionLog =
{
	--竞技类型活动
	[Env.LogType_Athletics] = function (pPlayer, ActivityType, tbLog)
		pPlayer.TLogRoundFlow( ActivityType, pPlayer.nMapTemplateId, tbLog.nScore or 0, tbLog.nMatchTime or 0, tbLog.Result or Env.LogRound_SUCCESS, tbLog.nRank or 0, tbLog.nMoney or 0);
	end;

	--普通活动类型
	[Env.LogType_Activity] = function (pPlayer, ActivityType, tbLog)
		pPlayer.TLogRoundFlow( ActivityType, pPlayer.nMapTemplateId, tbLog.nScore or 0, tbLog.nMatchTime or 0, tbLog.Result or Env.LogRound_SUCCESS, tbLog.nRank or 0, tbLog.nMoney or 0);
	end;

	--通关活动类型
	[Env.LogType_Carnet] = function (pPlayer, ActivityType, tbLog)
		pPlayer.TLogRoundFlow( ActivityType, pPlayer.nMapTemplateId, tbLog.nScore or 0, tbLog.nMatchTime or 0, tbLog.Result or Env.LogRound_SUCCESS, tbLog.nRank or 0, tbLog.nMoney or 0);
	end;

	--异步竞技类型活动
	[Env.LogType_AsynAthletics] = function (pPlayer, ActivityType, tbLog)
		local nSubActivityType = pPlayer.nMapTemplateId;
		if type(tbLog.SubActivityType) == "number" then
			nSubActivityType = tbLog.SubActivityType;
		end

		pPlayer.TLogRoundFlow( ActivityType, nSubActivityType, tbLog.nScore or 0, tbLog.nMatchTime or 0, tbLog.Result or Env.LogRound_SUCCESS, tbLog.nRank or 0, tbLog.nMoney or 0);
	end;
};

function Player:ActionLog(pPlayer, szLogType, ActivityType, tbLog)
	local fnActionLog = Player.tbFunActionLog[szLogType];
	if not fnActionLog then
		return;
	end

	fnActionLog(pPlayer, ActivityType, tbLog);
end

function Player:OnLogin(pPlayer)
	local pNpc = pPlayer.GetNpc();
	if not pNpc then
		return;
	end
	local nPkMode = pNpc.GetPkMode();
	local nExcerciseId = pNpc.nExcerciseId;
	if nPkMode == self.MODE_EXCERCISE and nExcerciseId > 0 then
		pPlayer.CallClientScript("Player:OnPkExcerciseState", self.PK_EXCERCISE_GO, nExcerciseId);
	end

	--TODO Delete ivan
	--不换包前提下突破客户端150级等级限制的临时处理
	local nCurLevel = pPlayer.nLevel
	if nCurLevel > 150 then
		pPlayer.CallClientScript("Player:TmpLevelChange", 150, nCurLevel);
	end
end

function Player:CheckFocusSelfAllPet(pPlayer)
	local bRet = Map:IsFocusAllPet(pPlayer.nMapTemplateId);
	if not bRet then
		return false, "当前地图不可以操作";
	end

	local nTime = pPlayer.nFocusAllPetTime or 0;
	local nCurTime = GetTime() - nTime;
	if nCurTime < Player.nFocusPetTime then
		return false;
	end

	return true;
end

function Player:FocusSelfAllPet(pPlayer)
	local bRet, szMsg = self:CheckFocusSelfAllPet(pPlayer);
	if not bRet then
		if szMsg then
			pPlayer.CenterMsg(szMsg, true);
		end

		return;
	end

	local nRet = pPlayer.HaulBackPartnerPos();
	if nRet == 1 then
		pPlayer.nFocusAllPetTime = GetTime();
		pPlayer.CallClientScript("Player:UpdateAllPetTime");
	end
	Log("Player FocusSelfAllPet", pPlayer.dwID);
end


function Player:CheckExcercise(pNpc1, pNpc2)
	local tbMapSetting = Map:GetMapSetting(pNpc1.nMapTemplateId)
	if tbMapSetting.Excercise ~= 1 then
		return false, "目前地图禁止切磋";
	end

	local nDistance = pNpc1.GetDistance(pNpc2.nId);
	if nDistance < 0 or nDistance > self.PK_EXCERCISE_DISTANCE then
		return false, "双方距离太远，无法进行切磋";
	end

	local nPkMode1 = pNpc1.GetPkMode();
	local nPkMode2 = pNpc2.GetPkMode();
	if nPkMode1 == Player.MODE_EXCERCISE or nPkMode2 == Player.MODE_EXCERCISE then
		return false, string.format("%s正在进行切磋，无法同时与多人切磋。", nPkMode1 == Player.MODE_EXCERCISE and pNpc1.szName or pNpc2.szName)
	end
	if nPkMode1 ~= Player.MODE_PEACE or nPkMode2 ~= Player.MODE_PEACE then
		return false, "切磋双方的PK模式必须都是和平模式";
	end
	if pNpc1.nFightMode ~= 1 or pNpc2.nFightMode ~= 1 then
		return false, "切磋双方不能处於安全区内";
	end

	return true;
end

function Player:RequestExcercise(pRequestor, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return
	end

	local nRet, szMsg = self:CheckExcercise(pRequestor.GetNpc(), pPlayer.GetNpc())
	if not nRet then
		pRequestor.CenterMsg(szMsg);
		return;
	end

	self.tbExcerciseRequest[pRequestor.dwID] =
	{
		nReceivePlayer = nPlayerId,
	}
	pRequestor.CenterMsg(string.format("您向「%s」发起了切磋请求", pPlayer.szName));
	pPlayer.CallClientScript("Player:OnPkExcerciseRequest", pRequestor.szName, pRequestor.dwID);
end

function Player:OnExcerciseRespond(pPlayerAnswer, nRequestPlayerId, bResult)
	if not self.tbExcerciseRequest[nRequestPlayerId] then
		pPlayerAnswer.CenterMsg("切磋请求已过期");
		return;
	end

	if self.tbExcerciseRequest[nRequestPlayerId].nReceivePlayer ~= pPlayerAnswer.dwID then
		pPlayerAnswer.CenterMsg("切磋请求已过期");
		return;
	end

	self.tbExcerciseRequest[nRequestPlayerId] = nil;

	local pRequestor = KPlayer.GetPlayerObjById(nRequestPlayerId)
	if not pRequestor then
		return
	end

	if not bResult then
		pRequestor.CenterMsg(string.format("「%s」拒绝了您的切磋请求", pPlayerAnswer.szName))
		return
	end

	local bRet, szMsg = self:CheckExcercise(pRequestor.GetNpc(), pPlayerAnswer.GetNpc())
	if not bRet then
		if szMsg then
			pPlayerAnswer.CenterMsg(szMsg);
			pRequestor.CenterMsg(szMsg);
		end
		return;
	end

	pPlayerAnswer.CallClientScript("Player:OnPkExcerciseState", self.PK_EXCERCISE_READY);
	pRequestor.CallClientScript("Player:OnPkExcerciseState", self.PK_EXCERCISE_READY);

	Timer:Register(4 * Env.GAME_FPS, self.StartExcercise, self, nRequestPlayerId, pPlayerAnswer.dwID)
end

function Player:StartExcercise(nRequestPlayerId, nAnswerPlayerId)
	local pRequestor = KPlayer.GetPlayerObjById(nRequestPlayerId);
	local pAnswer = KPlayer.GetPlayerObjById(nAnswerPlayerId);
	if not pRequestor or not pAnswer then
		return
	end
	local pNpc1 = pRequestor.GetNpc();
	local pNpc2 = pAnswer.GetNpc();

	local bRet, szMsg = self:CheckExcercise(pNpc1, pNpc2)
	if not bRet then
		if szMsg then
			pRequestor.CenterMsg(szMsg);
			pAnswer.CenterMsg(szMsg);
		end
		return;
	end
	pNpc1.nExcerciseId = pNpc2.nId;
	pNpc1.SetPkMode(self.MODE_EXCERCISE)
	pNpc2.nExcerciseId = pNpc1.nId;
	pNpc2.SetPkMode(self.MODE_EXCERCISE)


	pRequestor.CallClientScript("Player:OnPkExcerciseState", self.PK_EXCERCISE_GO, pNpc1.nExcerciseId);
	pAnswer.CallClientScript("Player:OnPkExcerciseState", self.PK_EXCERCISE_GO, pNpc2.nExcerciseId);

	Achievement:AddCount(pRequestor, "PkExcercise_1", 1)
	Achievement:AddCount(pAnswer, "PkExcercise_1", 1)
end

function Player:ChangePKMode(pPlayer, nMode)
	local bRet = 0;
	if pPlayer.bForbidChangePk == 1 then
		local nForce = Map:GetForcePkMode(pPlayer.nMapTemplateId);
		if nForce > 0 then
			pPlayer.CenterMsg("在对战地图无法手动切换模式", true);
		end

		pPlayer.CallClientScript("Player:ChangePkResult", 0, 0)
		return
	end
	if Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
		pPlayer.CallClientScript("Player:ChangePkResult", 0, 0)
		return;
	end

	if nMode == Player.MODE_KILLER and PKValue:CheckMaxValue(pPlayer) then
		pPlayer.CenterMsg("恶名值过高，无法开启屠杀模式！");
		pPlayer.CallClientScript("Player:ChangePkResult", 0, 0)
		return;
	end

	if pPlayer.nForbidPkMode and pPlayer.nForbidPkMode == nMode then
		pPlayer.CallClientScript("Player:ChangePkResult", 0, 0)
		return;
	end

	local nCurMode = pPlayer.nPkMode
	local nCurTime = GetTime()
	if nCurMode == Player.MODE_KILLER and
			nCurMode ~= nMode and
			nCurTime - pPlayer.GetLastAttTime() < 3 then
		pPlayer.CenterMsg("正在战斗中，暂时无法切换模式");
		pPlayer.CallClientScript("Player:ChangePkResult", 0, 0)
		return;
	end

	if nCurMode ~= nMode then
		if (nMode == Player.MODE_PEACE) then
			if pPlayer.nPeaceCD and pPlayer.nPeaceCD > nCurTime then
				pPlayer.CallClientScript("Player:ChangePkResult", 0, pPlayer.nPeaceCD)
				return
			end
			pPlayer.SetPkMode(nMode, 0)
			bRet = 1;
		elseif nMode == Player.MODE_PK or nMode == Player.MODE_KILLER or nMode == Player.MODE_CAMP then
			if nCurMode == Player.MODE_PEACE then
				pPlayer.nPeaceCD = nCurTime + Player.CHANGE_PEACE_CD;
			end
			pPlayer.SetPkMode(nMode, 0)
			bRet = 1;
		end

		pPlayer.CallClientScript("Player:ChangePkResult", bRet, pPlayer.nPeaceCD or 0)
	end
end

function Player:OnExcerciseResult(nWinner, nLoser)
	local pWinner = KNpc.GetById(nWinner)
	local pLoser = KNpc.GetById(nLoser)

	pWinner.AddSkillState(self.EXCERCISE_WIN_BUFF, 1, 0, 5 * Env.GAME_FPS)
	pLoser.AddSkillState(self.EXCERCISE_LOSE_BUFF, 1, 0, 5 * Env.GAME_FPS)

--	local pWinnerPlayer = pWinner.GetPlayer();
--	local pLoserPlayer = pLoser.GetPlayer();
--	if pWinnerPlayer then
--		pWinnerPlayer.CenterMsg("您在切磋中胜利了！")
--	end
--	if pLoserPlayer then
--		pLoserPlayer.CenterMsg("您在切磋中失败了！");
--	end

	self:NpcQuitExcercise(nWinner)
	self:NpcQuitExcercise(nLoser)
end

local tbQuiteResultDesc =
{
	["NpcW::SetPkMode"] = "「%s」PK状态改变了，切磋结束",
	["SetPkMode"] = "「%s」PK状态改变了，切磋结束",
	["XPlayerServer::DelayLogout"] = "「%s」网路连接中断，切磋结束",
	["DelayLogout"] = "「%s」网路连接中断，切磋结束",
	["NpcW::ChangeSubWorld"] = "「%s」离开目前地图，切磋结束",
	["ChangeSubWorld"] = "「%s」离开目前地图，切磋结束",
	["NpcW::SetFightMode"] = "「%s」回到安全区，切磋结束",
	["SetFightMode"] = "「%s」回到安全区，切磋结束",
	["Player::SetAlone"] = "「%s」离开目前地图，切磋结束",
	["SetAlone"] = "「%s」离开目前地图，切磋结束",
}

function Player:QuitExcerciseState(nNpcId, nTargetNpcId, szResult)
	local pNpc = KNpc.GetById(nNpcId)
	if szResult and tbQuiteResultDesc[szResult] then
		szResult = string.format(tbQuiteResultDesc[szResult], pNpc.szName)
	else
	end
	self:NpcQuitExcercise(nNpcId, szResult)
	self:NpcQuitExcercise(nTargetNpcId, szResult)
end

function Player:NpcQuitExcercise(nNpcId, szResult)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return;
	end

	pNpc.nExcerciseId = 0;	-- 必须先清Id再设模式，否则会死循环
	if pNpc.GetPkMode() == self.MODE_EXCERCISE then
		pNpc.SetPkMode(self.MODE_PEACE)
	end

	local pPlayer = pNpc.GetPlayer()
	if pPlayer then
		pPlayer.CallClientScript("Player:OnPkExcerciseState", self.PK_EXCERCISE_END, szResult);
	end
end

function Player:GetOfflineDays(nPlayerId)
	local pInfo = KPlayer.GetRoleStayInfo(nPlayerId)
	if pInfo and pInfo.nLastOnlineTime then
		local nOfflineTime = GetTime()-pInfo.nLastOnlineTime
		return Lib:SecondsToDays(nOfflineTime), nOfflineTime
	end
	return math.huge, math.huge
end

function Player:AddMoneyDebt(nPlayerId, szType, nPoint, nLogReazon, nLogReazon2, bNeedCheck)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.AddMoneyDebt(szType, nPoint, nLogReazon, nLogReazon2)
		if bNeedCheck then
			pPlayer.CheckMoneyDebt(szType)
		end
	else
		local szCmd = string.format("me.AddMoneyDebt('%s',%d,%d,%d);me.CheckMoneyDebt('%s')",szType, nPoint, nLogReazon or Env.LogWay_Money_Debt_Add, nLogReazon2 or 0, szType);
		KPlayer.AddDelayCmd(nPlayerId,
			szCmd,
			string.format("%s|%s|%d|%d|%d", 'AddMoneyDebt', szType, nPoint, nLogReazon or Env.LogWay_Money_Debt_Add, nLogReazon2 or 0))
	end
end

function Player:CheckAllMoneyDebt(pPlayer)
	for szType,_ in pairs(Shop.tbMoney) do
		pPlayer.CheckMoneyDebt(szType);
	end
end

function Player:OnPlayerAddExp(pPlayer, nExp, nTrueExp)
	tbXinDe:OnPlayerAddExp(pPlayer, nExp, nTrueExp)
end

function Player:OnFetchRechargeResult(szAccount, nRoleId, nGold, nResult)
	self.tbRechargeBack = self.tbRechargeBack or {};
	self.tbRechargeBack[szAccount] = nGold;
	if nRoleId == 0 then
		-- 查询结果
		local pPlayer = KPlayer.GetAccountOnlinePlayer(szAccount)
		if pPlayer then
			Player:SyncRechargeBackNewsInfo(pPlayer)
		end
	else
		-- 领取结果
		if nGold > 0 and nResult == 1 then
			self.tbRechargeBack[szAccount] = 0;
			local tbMailInfo =
			{
				To = nRoleId,
				Title = "封测储值返还",
				Text = "感谢您在《剑侠情缘》封测期间里进行储值，附件为对应的储值元宝返还，请注意查收",
				tbAttach 	= {{"Gold", nGold}},
				nLogReazon = Env.LogWay_RechargeSumAct,
			}
			Mail:SendSystemMail(tbMailInfo)
			Log("FetchRechargeResult", szAccount, nRoleId, nGold, nResult)
		end
		local pPlayer = KPlayer.GetPlayerObjById(nRoleId)
		if pPlayer then
			pPlayer.CenterMsg(nResult == 1 and "领取成功，请查看邮件" or "领取失败")
			pPlayer.CallClientScript("Activity:CloseNewInfomation", "RechargeBack");
		end
	end
end

function Player:OnRechargeBackNewsInfoCallback(bConfirm)
	local szAccount = me.szAccount
	if not self.tbRechargeBack or not self.tbRechargeBack[szAccount] then
		return;
	end
	if not bConfirm then
		me.MsgBox("只能由一个角色领取储值返还，是否领取？", {{"确认", self.OnRechargeBackNewsInfoCallback, self, true}, {"取消"}})
		return
	end
	Log("OnRechargeBackNewsInfoCallback", szAccount, me.dwID, self.tbRechargeBack[szAccount])
	me.FetchRechargeBack()
end

function Player:SyncRechargeBackNewsInfo(pPlayer)
	local szAccount = pPlayer.szAccount
	if not self.tbRechargeBack or not self.tbRechargeBack[szAccount] then
		return;
	end
	local nGold = self.tbRechargeBack[szAccount]
	if nGold > 0 then
		local tbNewsData =
		{
			szTitle = "封测储值返还";
			szContent = string.format("    封测期间参与储值的玩家可以获得对应的储值返还，低於於1000元部分按150%%返还，高於1000元部分按100%%返还，返还不计入VIP经验。\n\n    [FFFE0D]注意：每个帐号的返还只能由一个角色领取一次，请谨慎选择！[-]\n\n    根据您的储值记录，[FFFE0D]您可以获得%d元宝[-]", nGold);
			szBtnText = "领取返还";
			szBtnType = "ServerCmd";
			szBtnTrap = "RechargeBack";
		}
		NewInformation:RegisterButtonCallBack("RechargeBack", {Player.OnRechargeBackNewsInfoCallback, Player})
		pPlayer.CallClientScript("Activity:OnSyncActivityInfo", {{ tbUiData = tbNewsData, szKeyName = "RechargeBack", szType = "", nEndTime = GetTime() + 24*3600*15, nStartTime = 0}});
	else
		pPlayer.CallClientScript("Activity:CloseNewInfomation", "RechargeBack");
	end
end

function Player:CheckMoneyDebtBuff(pPlayer)
	if version_vn then
		return
	end

	local pNpc = pPlayer.GetNpc();
	if not pNpc then
		return
	end

	local nBuffLevel = self:GetDebtAttrDebuffLevel(pPlayer)

	if nBuffLevel and nBuffLevel > 0 then
		pNpc.AddSkillState(Shop.MONEY_DEBT_ATTR_DEBUFF, nBuffLevel, 3, 2000000000, 1, 1);
	else
		pNpc.RemoveSkillState(Shop.MONEY_DEBT_ATTR_DEBUFF)
	end

	pPlayer.OnEvent("CheckMoneyDebt");
end

function Player:CheckMoneyDebtStartTime(pPlayer)
	if version_vn then
		return
	end

	local nStartTime = pPlayer.GetUserValue(Shop.MONEY_DEBT_GROUP, Shop.MONEY_DEBT_START_TIME);
	local nBuffLevel = 0;
	local pNpc = pPlayer.GetNpc();

	--之前的debuff 会影响战斗里的计算，先移除后再进行判断添加新的debuff
	local function afterRemoveDebuff(nPlayerId)
		local pCurPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pCurPlayer then
			return
		end

		if pCurPlayer.nState == Player.emPLAYER_STATE_ZONE then --跨服是可能改战力的，回本服时回重新检查
			return
		end

		local pNpc = pCurPlayer.GetNpc();

		Player:CheckMoneyDebtBuff(pCurPlayer)

		local nBuffLevel = Player:GetDebtFightPowerDebuffLevel(pCurPlayer)

		if nBuffLevel > 0 and pNpc then
			pNpc.AddSkillState(Shop.MONEY_DEBT_FIGHT_DEBUFF, nBuffLevel, 3, 2000000000, 1, 1);
		end

		RankBoard:UpdateRankVal("FightPower", pCurPlayer)
		FightPower:ResetFightPower(pCurPlayer)
	end

	if self:GetDebtAttrDebuffLevel(pPlayer) >= Player.DEBT_FIGHT_POWER_NEED_LEVEL then
		if nStartTime <= 0 then
			pPlayer.SetUserValue(Shop.MONEY_DEBT_GROUP, Shop.MONEY_DEBT_START_TIME, GetTime());
		end
	else
		pPlayer.SetUserValue(Shop.MONEY_DEBT_GROUP, Shop.MONEY_DEBT_START_TIME, 0);
	end

	if pNpc then
		--先把影响战斗力衰减的debuff都移除掉，在计时器回调中再判断加回来
		pNpc.RemoveSkillState(Shop.MONEY_DEBT_ATTR_DEBUFF)
		pNpc.RemoveSkillState(Shop.MONEY_DEBT_FIGHT_DEBUFF)
	end

	RankBoard:UpdateRankVal("FightPower", pPlayer)
	FightPower:ResetFightPower(pPlayer)

	Timer:Register(8, afterRemoveDebuff, pPlayer.dwID)
end

function Player:OnGatewayKickAccount(pPlayer, szReason)
	if pPlayer and szReason ~= "" then
		if szReason == "ParentForbid" then
			szReason = XT("您的帐号已被家长设定为暂时无法登录游戏。如有疑问，请拨打服务热线0755-86013799进行谘询。共筑绿色健康游戏环境，感谢您的理解与支持。")
		end
		pPlayer.CallClientScript("Ui:OnShowKickMsg", szReason);
	end
end

function Player:AddGoldDebtFromList()
	local tbList = LoadTabFile("PlayerGoldDebtList.tab", "dd", nil, {"PlayerId", "Count"}, 1, 1) or {};
	local nCount = 0;
	for _,tbInfo in pairs(tbList) do
		local pStayInfo = KPlayer.GetRoleStayInfo(tbInfo.PlayerId);
		if pStayInfo then
			Player:AddMoneyDebt(tbInfo.PlayerId,"Gold", math.abs(tbInfo.Count), Env.LogWay_Money_Debt_Add, 0, true)

			nCount = nCount + 1
		end
	end

	return nCount
end

function Player:MarketStallLimitFromList()
	local tbList = LoadTabFile("MarketStallLimitList.tab", "ddss", nil, {"PlayerId", "Type", "Value", "EndTime"}, 1, 1) or {};
	local nCount = 0;
	for _,tbInfo in pairs(tbList) do
		local pStayInfo = KPlayer.GetRoleStayInfo(tbInfo.PlayerId);

		if pStayInfo then
			MarketStall:SetPlayerLimit(tbInfo.PlayerId, tbInfo.Type, tonumber(tbInfo.Value) or 0.1, Lib:ParseDateTime(tbInfo.EndTime))

			nCount = nCount + 1
		end
	end

	return nCount
end

function Player:PeekPlayer(pPeeker, dwRoleId)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		pPeeker.CenterMsg("对方未在线");
		return
	end

	local CanPeekMap =
	{
		city = 1,
		kin = 1,
	}
	local szMapClass = Map:GetClassDesc(pPeeker.nMapTemplateId)
	if not CanPeekMap[szMapClass] then
		pPeeker.CenterMsg("您所在的地图不允许进行远端观战！");
		return;
	end
	if Map:IsForbidPeeking(pPlayer.nMapTemplateId) then
		pPeeker.CenterMsg("对方所在地图不允许被观战");
		return
	end
	if Wedding:IsPlayerTouring(dwRoleId) then
		pPeeker.CenterMsg("对方当前正在进行花轿游城无法进行远端观战");
		return
	end
	if not Env:CheckSystemSwitch(pPeeker, Env.SW_ChuangGong) then
		pPeeker.CenterMsg("您当前状态无法进行远端观战");
		return
	end
	if pPeeker.PeekPlayer(dwRoleId) == 0 then
		pPeeker.CenterMsg("对方当前状态无法进行远端观战");
		return
	end
end

function Player:OnPlayerNpcAiFlying(pNpc, pFollowingNpc)
	if Map:IsFieldFightMap(pNpc.nMapTemplateId) then
		if pNpc.dwPlayerID ~= 0 and pFollowingNpc.dwPlayerID ~= 0 then
			pNpc.nFightMode = pFollowingNpc.nFightMode;
		end
	end
end


function Player:AddRewardValueDebt(nPlayerId, nPoint, nLogReazon, nLogReazon2)
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
	if not pAsyncData then
		Log(debug.traceback())
		return;
	end

	if nPoint <= 0 then
		Log(debug.traceback())
		return;
	end

	local nOrgPoint = pAsyncData.GetRewardValueDebt();
	local nSetPoint = nOrgPoint + nPoint
	pAsyncData.SetRewardValueDebt(nSetPoint)

	nLogReazon2 = nLogReazon2 or 0;
	if not nLogReazon or nLogReazon == 0 then
		Log(debug.traceback())
	end

	TLog("RewardDebtFlow", nPlayerId, nSetPoint, nPoint, nLogReazon, nLogReazon2, 0)

	return true;
end

function Player:CostRewardValueDebt(nPlayerId, nPoint, nLogReazon, nLogReazon2)
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
	if not pAsyncData then
		Log(debug.traceback())
		return;
	end

	if nPoint <= 0 then
		Log(debug.traceback())
		return;
	end
	local nOrgPoint = pAsyncData.GetRewardValueDebt();

	local nSetPoint = nOrgPoint - nPoint
	pAsyncData.SetRewardValueDebt(nSetPoint)

	nLogReazon2 = nLogReazon2 or 0;

	if not nLogReazon or nLogReazon == 0 then
		Log(debug.traceback())
	end

	TLog("RewardDebtFlow", nPlayerId, nSetPoint, nPoint, nLogReazon, nLogReazon2, 1)

	return true;
end

function Player:AddRewardValueDebtFromList()
	local tbList = LoadTabFile("PlayerRewardDebtList.tab", "dd", nil, {"PlayerId", "Count"}, 1, 1) or {};
	local nCount = 0;
	for _,tbInfo in pairs(tbList) do
		local pStayInfo = KPlayer.GetRoleStayInfo(tbInfo.PlayerId);
		if pStayInfo then
			if Player:AddRewardValueDebt(tbInfo.PlayerId, math.abs(tbInfo.Count), Env.LogWay_GM, 0) then
				nCount = nCount + 1
			end
		end
	end

	return nCount
end

Player.tbTempRoleStayOtherInfo = Player.tbTempRoleStayOtherInfo or {};
function Player:OnAddTempRoleStayInfo(nRoleServerId, dwRoleId, nTitleId, szTitleName, szKinName)
	Log("Player:OnAddTempRoleStayInfo", nRoleServerId, dwRoleId, nTitleId, szTitleName, szKinName)
	Player.tbTempRoleStayOtherInfo[string.format("%d_%d", nRoleServerId, dwRoleId)] = {nTitleId, szTitleName, szKinName};
end

function Player:GetOtherTempRoleStayInfo(nRoleServerId, dwRoleId)
	return Player.tbTempRoleStayOtherInfo[string.format("%d_%d", nRoleServerId, dwRoleId)]
end

--优先是取跨服信息，再是本服的
function Player:GetRoleStayInfo(dwRoleId, bWithViewInfo, nServerId)
	local tbRole;
	if nServerId then
		tbRole = KPlayer.GetTempRoleStayInfo(nServerId, dwRoleId)
		if tbRole then
			if bWithViewInfo then
				local tbOtherViewInfo = self:GetOtherTempRoleStayInfo(nServerId, dwRoleId)
				if tbOtherViewInfo then
					local nTitleId, szTitleName, szKinName = unpack(tbOtherViewInfo)
					tbRole.szKinName = szKinName
					tbRole.tbTitleInfo = {nTitleId, szTitleName}
				end
			end
		end
	end
	if not tbRole then
		tbRole = KPlayer.GetRoleStayInfo(dwRoleId)
		if tbRole then
			if bWithViewInfo then
			if tbRole.dwKinId ~= 0 then
				local tbKin = Kin:GetKinById(tbRole.dwKinId)
					if tbKin then
						tbRole.szKinName = tbKin.szName
					end
				end
				tbRole.tbTitleInfo = PlayerTitle:GetTitleInfoByRoleId(dwRoleId)
			end
		end
	end
	return tbRole
end

function Player:GetAsyncData(nPlayerID, nServerId)
	local pAsyncData;
	if nServerId  then
		pAsyncData = KPlayer.GetTempAsyncData(nServerId, nPlayerID)
	end
	if not pAsyncData then
		pAsyncData = KPlayer.GetAsyncData(nPlayerID)
	end
	return pAsyncData
end

function Player:PlayEffectWithDistance(pPlayer, nDis, ...)
	local pNpc = pPlayer.GetNpc()
	if not pNpc then
		return
	end

	local tbPlayer = KNpc.GetAroundPlayerList(pNpc.nId, nDis or 1000) or {};
	for _, pP in pairs(tbPlayer) do
		pP.CallClientScript("Ui:PlayEffect", ...)
	end
end

--获取玩家形象信息 return nNpcResId, tbPartsRes
function Player:GetFeatureInfo(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		--玩家在线
		local pNpc = pPlayer.GetNpc();
		if pNpc then
			 return pNpc.GetFeature();
		end
	end

	local nNpcResId = 0
	local tbPartsRes = {}

	local pRoleStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
	if not pRoleStayInfo then
		return nNpcResId, tbPartsRes
	end

	nNpcResId , tbPartsRes = KPlayer.GetNpcResId(pRoleStayInfo.nFaction, pRoleStayInfo.nSex);
	local tbEquipInfo = KPlayer.GetInfoFromAsyncData(nPlayerId);
	if tbEquipInfo then
		local tbWeapon = tbEquipInfo[Item.EQUIPPOS_WEAPON]
		local tbArmor = tbEquipInfo[Item.EQUIPPOS_BODY]
		local tbHead = tbEquipInfo[Item.EQUIPPOS_HEAD]
		local tbHorse = tbEquipInfo[Item.EQUIPPOS_HORSE]

		local tbWaiWeapon = tbEquipInfo[Item.EQUIPPOS_WAI_WEAPON]
		local tbWaiArmor = tbEquipInfo[Item.EQUIPPOS_WAIYI]
		local tbWaiHead = tbEquipInfo[Item.EQUIPPOS_WAI_HEAD]
		local tbWaiBack = tbEquipInfo[Item.EQUIPPOS_WAI_BACK]
		local tbWaiHorse = tbEquipInfo[Item.EQUIPPOS_WAI_HORSE]

		tbPartsRes[Npc.NpcResPartsDef.npc_part_body] = (tbWaiArmor and tbWaiArmor.nShowResId > 0 and tbWaiArmor.nShowResId) or
									(tbArmor and tbArmor.nShowResId > 0 and tbArmor.nShowResId) or tbPartsRes[Npc.NpcResPartsDef.npc_part_body];

		tbPartsRes[Npc.NpcResPartsDef.npc_part_weapon] = (tbWaiWeapon and tbWaiWeapon.nShowResId > 0 and tbWaiWeapon.nShowResId) or
									(tbWeapon and tbWeapon.nShowResId > 0 and tbWeapon.nShowResId) or tbPartsRes[Npc.NpcResPartsDef.npc_part_weapon];

		tbPartsRes[Npc.NpcResPartsDef.npc_part_head] = (tbWaiHead and tbWaiHead.nShowResId > 0 and tbWaiHead.nShowResId) or
									(tbHead and tbHead.nShowResId > 0 and tbHead.nShowResId) or tbPartsRes[Npc.NpcResPartsDef.npc_part_head];

		tbPartsRes[Npc.NpcResPartsDef.npc_part_horse] = (tbWaiHorse and tbWaiHorse.nShowResId > 0 and tbWaiHorse.nShowResId) or
									(tbHorse and tbHorse.nShowResId > 0 and tbHorse.nShowResId) or tbPartsRes[Npc.NpcResPartsDef.npc_part_horse];

		tbPartsRes[Npc.NpcResPartsDef.npc_part_back] = (tbWaiBack and tbWaiBack.nShowResId > 0 and tbWaiBack.nShowResId) or
									tbPartsRes[Npc.NpcResPartsDef.npc_part_back];
	end

	return nNpcResId , tbPartsRes;
end

function Player:OnZCTLogRoundFlow(dwID, nBattleType, nBattleID, nScore, nRoundTime, nResult, nRank, nGold )
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		Log("Player:OnZCTLogRoundFlow Error", dwID, nBattleType, nBattleID, nScore, nRoundTime, nResult, nRank, nGold )
		return
	end
	pPlayer.TLogRoundFlow(nBattleType, nBattleID, nScore, nRoundTime, nResult, nRank, nGold)
end

Player.tbMoneyTypeAddP =
{
    ["Coin"] =
    {
        tbLogType =
        {
        	[Env.LogWay_MoneyTreeShake] = 1; -- 摇钱树
        	[Env.LogWay_EverydayTargetAward] = 1; --每日目标
        	[Env.LogWay_DungeonMgrKill] = 1; --随机地宫
        	[Env.LogWay_FindDungeonAward] = 1; --随机地宫
        	[Env.LogWay_DungeonFubenOpenGateAward] = 1; --随机地宫
        	[Env.LogWay_DungLeaderOnAttack] = 1; --随机地宫
        	[Env.LogWay_DungLeaderDeath] = 1; --随机地宫
        	[Env.LogWay_XiuLian] = 1; -- 野外修炼
        	[Env.LogWay_FinishCommerceTask] = 1;--商会任务

        };
        fnAddP = function (pPlayer, nValue, nLogType)
            local tbType = Player.tbMoneyTypeAddP["Coin"];
            if not tbType or not nLogType then
                return 0;
            end

            if not tbType.tbLogType[nLogType] then
                return 0;
            end

            local pNpc = pPlayer.GetNpc();
            if not pNpc then
                return 0;
            end

            local nAdP = pNpc.nAddCoinP;
            local nPoint = math.floor(nValue * (nAdP + 100) / 100);
            if nPoint ~= nValue then
            	pPlayer.CenterMsg(string.format("额外获得银两 * %s", nPoint - nValue), true);
            end

            return nAdP;
        end;
    };

    ["Contrib"] =
    {
        tbLogType =
        {
        	[Env.LogWay_KinDonate] = 1; -- 家族捐献
        	[Env.LogWay_RankBattleAward_Rank] = 1; -- 武神殿
        	[Env.LogWay_PunishTask] = 1; --惩恶任务
        	[Env.LogWay_GatherAnswer] = 1; --家族烤火答题
        	[Env.LogWay_GatherAnswerRight] = 1; --家族烤火答题
        	[Env.LogWay_Boss] = 1; --武林盟主

        };
        fnAddP = function (pPlayer, nValue, nLogType)
            local tbType = Player.tbMoneyTypeAddP["Contrib"];
            if not tbType or not nLogType then
                return 0;
            end

            if not tbType.tbLogType[nLogType] then
                return 0;
            end

            local pNpc = pPlayer.GetNpc();
            if not pNpc then
                return 0;
            end

            local nAdP = pNpc.nAddContribP;
            local nPoint = math.floor(nValue * (nAdP + 100) / 100);
            if nPoint ~= nValue then
            	pPlayer.CenterMsg(string.format("额外获得贡献 * %s", nPoint - nValue), true);
            end

            return nAdP;
        end;
    };
}
