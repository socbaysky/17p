--[[
-- 挑战武林盟主
Boss._tbPlayerData = {
	[nPlayerId] = {
		nScore =
	}
}

-- 数据对于到_PalyerData时的值, 作用在于用于排序
Boss._tbPlayerRankData = {
	[1] = ...;
	[2] = ...;
	}

Boss._tbKinData = {

}
]]

Boss.tbStateInfo = Boss.tbStateInfo or {};

function Boss:StateStart(szStateType, nStart)
	if not Boss.tbStateInfo[szStateType] then
		Boss.tbStateInfo[szStateType] = {
			nCount = 0;
			nTotal = 0;
			nPeak  = 0;
			nStart = 0;
		};
	end

	Boss.tbStateInfo[szStateType].nStart = nStart or GetRDTSC();
end

function Boss:StateEnd(szStateType, nEnd)
	local tbInfo = Boss.tbStateInfo[szStateType];
	local nCost = (nEnd or GetRDTSC()) - tbInfo.nStart;
	if nCost < 0 then
		return;
	end

	tbInfo.nCount = tbInfo.nCount + 1;
	tbInfo.nTotal = tbInfo.nTotal + nCost;
	if nCost > tbInfo.nPeak then
		tbInfo.nPeak = nCost;
	end
end

function Boss:LogState()
	Log("=========Boss:LogState============");
	Lib:Tree(Boss.tbStateInfo);
	Log("==================================");
	Boss.tbStateInfo = {};
end

function Boss:InitData()
	self._tbPlayerData = {};
	self._tbPlayerRankData = {};
	self._tbRobMap = {};
	self._tbKinData = {};
	self._tbKinRankData = {};
	self.bStart = false;
	self._tbBossData = nil;
	self.bPrepareFinish = nil;
	self.bSortKinRank = nil;
	self.bSortPlayerRank = nil;
end

function Boss:ClearRankShow()
	local tbRankData = Boss:GetBossRankData();
	tbRankData.tbPlayerRank = {};
	tbRankData.nPlayerRankVersion = 0;
	tbRankData.tbKinRank = {};
	tbRankData.nKinRankVersion = 0;
end

-- function Boss:GetBossHpAdjustRate()
-- 	local tbScriptData = ScriptData:GetValue("Boss");
-- 	return tbScriptData.nBossHpAdjustRate or 1;
-- end

-- function Boss:SetBossAdjustRate(nRate)
-- 	local tbScriptData = ScriptData:GetValue("Boss");
-- 	tbScriptData.nBossHpAdjustRate = nRate;

-- 	ScriptData:SaveAtOnce("Boss", tbScriptData);
-- end

function Boss:GetBossRankData()
	local tbScriptData = ScriptData:GetValue("Boss");
	if not tbScriptData.tbRankData then
		tbScriptData.tbRankData = {};
	end
	return tbScriptData.tbRankData;
end

function Boss:MarkRobTable(nRober, nRobed)
	assert(self._tbRobMap);
	self._tbRobMap[nRobed] = self._tbRobMap[nRobed] or {};
	self._tbRobMap[nRobed][nRober] = true;
end

function Boss:GetRobers(nPlayerId)
	assert(self._tbRobMap);
	return self._tbRobMap[nPlayerId];
end

function Boss:GetBossData()
	return self._tbBossData;
end

-- 获取列表中列的值
local function GetItemValueFromSetting(nIth, tbItems)
	for i, v in ipairs(tbItems) do
		if nIth <= (v.Rank or v.Day) then
			return v;
		end
	end
end

function Boss:GetCurBossData()
	local tbCurBossData = Boss.Def.tbBossSetting[1];
	for _, tbItem in ipairs(Boss.Def.tbBossSetting) do
		if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
			break;
		end
		tbCurBossData = tbItem;
	end

	local tbBossInfo = {};
	tbBossInfo.Hp = tbCurBossData.Data.Hp;

	local tbNpcIds = tbCurBossData.Data.NpcIds;
	tbBossInfo.NpcId = tbNpcIds[MathRandom(1, #tbNpcIds)];

	return tbBossInfo;
end

function Boss:StartBossFight(nRound)
	Log("Boss:StartBossFight");

	self:InitData();
	self:ClearRankShow();

	local tbCurBossData = self:GetCurBossData();
	assert(tbCurBossData, "武林盟主 找不到设置");
	Log("Boss CurBossNpcInfo", tbCurBossData.NpcId, tbCurBossData.Hp);

	-- local nHpRate = Boss:GetBossHpAdjustRate();
	self._tbBossData = {
		nMaxHp = tbCurBossData.Hp;		--math.min(tbCurBossData.Hp * nHpRate, Boss.Def.nBossHpMaxValue);
		nCurHp = tbCurBossData.Hp;
		nNpcId = tbCurBossData.NpcId;
		nEndTime = GetTime() + Boss.Def.nTimeDuration;
		nStartTime = GetTime();
	}

	KPlayer.SendWorldNotify(Boss.Def.nPlayerEnterLevel - 1, 1000,
		"各位少侠！挑战武林盟主已经准时开启！通过「活动」前去挑战获得荣耀吧！",
		ChatMgr.ChannelType.Public, 1);

	local tbMsgData = {
		szType = "Boss";
		nTimeOut = GetTime() + Boss.Def.nTimeDuration;
	};

	KPlayer.BoardcastScript(Boss.Def.nPlayerEnterLevel, "Ui:SynNotifyMsg", tbMsgData);

	self.nRound = nRound; -- 标识中午场1 还是 晚上场2
	self.bStart = true;

	self.nSortRankTimer = Timer:Register(Env.GAME_FPS * Boss.Def.nSortRankWaitingTime, self.SortRankActive, self);

	-- 5秒 check 一次活动end，直接起一个定时器在结束会受追帧影响
	self.nCheckTimer = Timer:Register(Env.GAME_FPS * Boss.Def.nCheckEndTime, self.CheckState, self);
	Calendar:OnActivityBegin("Boss");
end

function Boss:CheckState()
	local tbBossData = self:GetBossData()
	local nCurTime = GetTime();
	if not tbBossData or not self.nCheckTimer then
		return false;
	end
	tbBossData.nCurHp = math.max(tbBossData.nMaxHp * (tbBossData.nEndTime - nCurTime) / (tbBossData.nEndTime - tbBossData.nStartTime), 0);
	if nCurTime > tbBossData.nEndTime then
		if not self.bPrepareFinish then
			Boss:NotifyFinishBoss();
			self.nCheckTimer = nil;
		end
		return false;
	end
	return true;
end

function Boss:SortRankActive()
	if not Boss:IsOpen() then
		self.nSortRankTimer = nil;
		return false;
	end

	if self.bSortPlayerRank then
		self.bSortPlayerRank = nil;
		Boss:StateStart("SortPlayerRank");
		Boss:SortPlayerRank();
		Boss:StateEnd("SortPlayerRank");
	end

	if self.bSortKinRank then
		self.bSortKinRank = nil;
		Boss:StateStart("SortKinRank");
		Boss:SortKinRank();
		Boss:StateEnd("SortKinRank");
	end
	return true;
end

function Boss:IsOpen()
	return self.bStart and not self.bPrepareFinish;
end

function Boss:NotifyFinishBoss()
	if not self.bStart or self.bPrepareFinish then
		return;
	end
	self.bPrepareFinish = true;
	Log("Boss:NotifyFinishBoss");

	for nPlayerId, _ in pairs(self._tbPlayerData) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("Boss:NotifyFinish");
		end
	end

	AsyncBattle:AllBattleExecute("BossFightBattle", "CloseBossBattle");
	AsyncBattle:AllBattleExecute("BossRobBattle", "CloseBossBattle");

	Timer:Register(Env.GAME_FPS * Boss.Def.nFinishWaitTime, self.FinishBoss, self);
end

function Boss:FinishBoss(pPlayer)
	if not self.bStart then
		return;
	end

	Log("Boss:FinishBoss");

	Calendar:OnActivityEnd("Boss");
	self.bStart = false;
	self.bPrepareFinish = nil;

	--考虑到参加活动时家族可能变更, 重新清算参与人数
	for nRank, tbKinData in ipairs(self._tbKinRankData) do
		tbKinData.nJoinMember = 0;
	end

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		local pRole = KPlayer.GetPlayerObjById(tbPlayerData.nPlayerId) or KPlayer.GetRoleStayInfo(tbPlayerData.nPlayerId);
		if pRole and pRole.dwKinId == tbPlayerData.nKinId and tbPlayerData.nKinId ~= 0 then
			local kinMemberData = Kin:GetMemberData(tbPlayerData.nPlayerId);
			if kinMemberData and not kinMemberData:IsRetire() then
				local tbKinData = Boss:GetKinData(pRole.dwKinId);
				if tbKinData then
					tbKinData.nJoinMember = tbKinData.nJoinMember + 1;
					tbKinData.tbFighter[tbPlayerData.nPlayerId] = true;
				end
			end
		end
	end

	-- 家族发奖
	Boss:SortKinRank();
	local tbKinTop1 = self._tbKinRankData[1];
	if tbKinTop1 then
		local szMsgFormat = "本轮挑战武林盟主, [FFFF0E]「%s」[-]帮派以%d分获得帮派总积分第一！";
		local szMsg = string.format(szMsgFormat, tbKinTop1.szName, tbKinTop1.nScore);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);
	end

	local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam()
	for nRank, tbKinData in ipairs(self._tbKinRankData) do
		Boss:SendKinReward(tbKinData, nRank);
		TLog("KinActFlow", szGameAppid, nPlat, nServerIdentity, Env.LogWay_Boss, tbKinData.nKinId, tbKinData.nJoinMember, tbKinData.nScore);
	end

	-- 个人发奖
	Boss:SortPlayerRank();
	local tbPlayerTop1 = self._tbPlayerRankData[1];
	if tbPlayerTop1 then
		local szMsgFormat = "[FFFF0E]「%s」[-]武功卓绝，非但与武林盟主交手不落下风，更力克群雄，夺得%d分，争得榜首!";
		local szMsg = string.format(szMsgFormat, tbPlayerTop1.szName, tbPlayerTop1.nScore);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);
	end

	-- 前十名玩家 家族名
	for nPlayerRank = 1, 10 do
		local tbPlayerData = self._tbPlayerRankData[nPlayerRank];
		if not tbPlayerData then
			break;
		end

		local kinData = Kin:GetKinById(tbPlayerData.nKinId);
		tbPlayerData.szKinName = kinData and kinData.szName;
	end

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		Boss:SendPlayerReward(tbPlayerData.nPlayerId, tbPlayerData.nScore, nRank);
	end

	-- 计算下回boss的血
	--local tbBossData = Boss:GetBossData();
	--local nCostTime = GetTime() - tbBossData.nStartTime;
	--local nOrgBossHpRate = Boss:GetBossHpAdjustRate();
	--if nCostTime < 60 * 10 then -- 10分钟内结束, 则下场血量增加10%
	--	Boss:SetBossAdjustRate(nOrgBossHpRate * 1.1);
	--elseif nCostTime > 60 * 20 then -- 超过20分钟结束, 则下场血量减少10%
	--	Boss:SetBossAdjustRate(nOrgBossHpRate * 0.9);
	--end

	Boss:LogState();
	self:InitData();
end

function Boss:SendPlayerReward(nPlayerId, nScore, nRank)
	-- 成就
	local player = KPlayer.GetPlayerObjById(nPlayerId);

	local nKinHonorBoss = 0;
	local kinMemberData = Kin:GetMemberData(nPlayerId);
	local bossKinData = Boss:GetKinData(kinMemberData and kinMemberData.nKinId or 0);
	if bossKinData then
		nKinHonorBoss = GetItemValueFromSetting(bossKinData.nRank, Boss.Def.tbKinBoxRankScore).Honor;
		if bossKinData.nJoinMember >= Boss.Def.nBossKinMemberN then
			nKinHonorBoss = math.max(nKinHonorBoss, Boss.Def.nBossKinMemberNMinScore);
		end

		if player and bossKinData.nRank == 1 then
			Achievement:AddCount(player, "BossNumberOne_1");
		end
	end

	local nPlayerHonorBoss = GetItemValueFromSetting(nRank, Boss.Def.tbPlayerBoxRankScore).Honor;
	if nScore >= Boss.Def.nBossPlayerScoreN then
		nPlayerHonorBoss = math.max(nPlayerHonorBoss, Boss.Def.nBossPlayerScoreNMinScore);
	end

	local nKinRewardAdditionRate = kinMemberData and kinMemberData:GetRewardAdditionRate() or 0;
	local nFinalHonorBoss = (nKinHonorBoss + nPlayerHonorBoss) * (1 + nKinRewardAdditionRate);

	if player then
		local tbMyKin = bossKinData;
		local tbMyRank = {nScore = nScore, nRank = nRank};
		local tbTop10Player = Boss:GetTop10Player();
		local tbTop10Kin = Boss:GetTop10Kin();

		player.CallClientScript("Boss:SyncFinalResult", tbMyRank, tbMyKin, tbTop10Player, tbTop10Kin);
	end

	local szMsgFormat = "尊敬的玩家：\n\n    本次挑战武林盟主，您获得了[FFFE0D]第%d名[-]，您%s本次挑战共获得[FFFE0D]%d[-]贡献%s，请注意查收哦。\n\n小提示：帮派参与人数越多奖励越丰厚哦！";
	local szKinInfo = "";
	if bossKinData and bossKinData.nRank then
		szKinInfo = string.format("所在的帮派排名第[FFFE0D]%d[-]名，", bossKinData.nRank);
	end

	local tbMailRewards = {{ Boss.Def.szAwardMoneyType, nFinalHonorBoss}};
	if not bossKinData then
		local tbNoKinReward = Boss:GetNoKinReward(nPlayerId);
		for _, tbReward in ipairs(tbNoKinReward) do
			table.insert(tbMailRewards, tbReward);
		end
	end
	local _, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(player, "Boss", tbMailRewards)
	local tbGiftBoxMail = {
		To = nPlayerId;
		Title = "挑战武林盟主奖励";
		Text = string.format(szMsgFormat, nRank, szKinInfo, nFinalHonorBoss, szMsg and string.format(szMsg, nFinalHonorBoss) or "");
		From = "「武林盟主」独孤剑";
		tbAttach = tbFinalAward;
		nLogReazon = Env.LogWay_Boss;
		tbParams = {
			nRank = nRank,
		};
	};

	Mail:SendSystemMail(tbGiftBoxMail);
end

function Boss:GetNoKinReward(nPlayerId)
	local tbRewards = {};
	local tbBossData = Boss:GetBossData();
	local tbAuctionRewards = Boss:GetAuctionRewards();
	for _, tbItemsData in ipairs(tbAuctionRewards) do
		if not tbItemsData.nBossId or tbBossData.nNpcId == tbItemsData.nBossId then
			local nValue = Boss.Def.nNoKinRewardScore * tbItemsData.nRate / #tbItemsData.Items;
			for _, nItemId in ipairs(tbItemsData.Items) do
				if nItemId ~= Boss.Def.nNoKinIgnoreItemId then
					local nItemValue = KItem.GetItemBaseProp(nItemId).nValue;
					local nItemCount = math.floor(nValue / nItemValue + MathRandom());
					if nItemCount > 0 then
						table.insert(tbRewards, {"item", nItemId, nItemCount});
						Log("NoKinRewardItem:", nPlayerId, nItemId, nItemCount);
					end
				end
			end
		end
	end
	return tbRewards;
end

function Boss:GetKinAuctionItems(nRank, nBossId, nJoinMember, tbRankScore, tbAuctionRewards)
	local tbAuctionItems = {};
	local nRewardScore = GetItemValueFromSetting(nRank, tbRankScore).Score;
	local nAuctionScale = Boss:GetAuctionRewardScale();
	local nTotalKinValue = nRewardScore * nJoinMember * nAuctionScale;

	for _, tbItemsData in ipairs(tbAuctionRewards) do
		if not tbItemsData.nBossId or nBossId == tbItemsData.nBossId then
			local nValue = nTotalKinValue * tbItemsData.nRate / #tbItemsData.Items;
			for _, nItemId in ipairs(tbItemsData.Items) do
				local nItemValue = KItem.GetItemBaseProp(nItemId).nValue;
				local nItemCount = math.floor(nValue / nItemValue + MathRandom());
				if nItemCount > 0 then
					table.insert(tbAuctionItems, {nItemId, nItemCount});
				end
			end
		end
	end
	return tbAuctionItems;
end

function Boss:SendKinReward(tbKinData, nRank)
	local tbBossData = Boss:GetBossData();
	local tbAuctionRewards = Boss:GetAuctionRewards();
	local tbKinRankScore = Boss:GetCurTimeKinRewardRankScore();
	local tbAuctionItems = Boss:GetKinAuctionItems(nRank, tbBossData.nNpcId, tbKinData.nJoinMember, tbKinRankScore, tbAuctionRewards);

	Log(tbKinData.nKinId, tbKinData.nJoinMember, nRank, "BOSS活动进入拍卖的物品:")
	Lib:LogTB(tbAuctionItems);

	Kin:AddAuction(tbKinData.nKinId, "Boss", tbKinData.tbFighter, tbAuctionItems);

	Boss:ZCRecordKinScore4ZFight(tbKinData.nKinId, nRank);
	-- 家族威望奖励
	local nPrestige = GetItemValueFromSetting(nRank, Boss.Def.KinPrestigeRward).Prestige;
	local kinData = Kin:GetKinById(tbKinData.nKinId);
	nPrestige = nPrestige + tbKinData.nJoinMember; -- 所有家族获得参与人数*1的基准威望值
	kinData:AddPrestige(nPrestige, Env.LogWay_Boss);

	-- 记录家族排名信息
	kinData:SetCacheFlag("BossRank" .. (self.nRound or ""), nRank);

	local szMsg = string.format("你的帮派在本轮挑战武林盟主当中, 获得第[FFFF0E]%d[-]名, 获得威望[FFFF0E]%d[-]", nRank, nPrestige);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, tbKinData.nKinId);
end

function Boss:MarkSortPlayer()
	self.bSortPlayerRank = true;
end

function Boss:SortPlayerRank()
	table.sort(self._tbPlayerRankData, function (a, b)
		if a.nScore == b.nScore then
			return a.nTime < b.nTime;
		else
			return a.nScore > b.nScore;
		end
	end);

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		tbPlayerData.nRank = nRank;
	end
	Boss:Refresh10Player(self._tbPlayerRankData);
end

function Boss:PlayerJoin(pPlayer)
	if not self._tbPlayerData[pPlayer.dwID] then
		local tbPlayerData = {
			nKinId              = pPlayer.dwKinId;
			nPlayerId           = pPlayer.dwID;
			szName              = pPlayer.szName;
			nPortrait           = pPlayer.nPortrait;
			nScore              = 0;
			nTime               = GetTime();
			nNextFightTime      = 0;
			nNextRobTime        = 0;
			nProtectRobTime     = 0;
			nProtectRobFullTime = 0; -- 抢夺全保护时间，被抢期间有效
			nLevel              = pPlayer.nLevel;
			nHonorLevel         = pPlayer.nHonorLevel;
			nFaction            = pPlayer.nFaction;
			nRank               = 9999;
			tbPartner           = {};
		}

		self._tbPlayerData[pPlayer.dwID] = tbPlayerData;
		table.insert(self._tbPlayerRankData, tbPlayerData);

		if pPlayer.dwKinId ~= 0 then
			local tbKinRankData = Boss:GetKinData(pPlayer.dwKinId);
			if tbKinRankData then
				tbPlayerData.szKinName = tbKinRankData.szName;
				tbKinRankData.nJoinMember = tbKinRankData.nJoinMember + 1;
			end
		end

		EverydayTarget:AddCount(pPlayer, "Boss");

		AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinBossFight, 1, 0, 1)
		return tbPlayerData;
	end
end

function Boss:GetPlayerData(nPlayerId)
	return self._tbPlayerData[nPlayerId]
end

function Boss:ClearPlayerData(nPlayerId)
	self._tbPlayerData[nPlayerId] = nil;

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		if tbPlayerData.nPlayerId == nPlayerId then
			table.remove(self._tbPlayerRankData, nRank);
			break;
		end
	end

	Boss:MarkSortPlayer();
	Log("Boss:ClearPlayerData", nPlayerId);
end

function Boss:KinJoin(nKinId)
	if not self._tbKinData[nKinId] and nKinId ~= 0 then
		local kinData = Kin:GetKinById(nKinId);
		if not kinData then
			return;
		end

		local nLeaderId = kinData:GetLeaderId();
		local leader = Kin:GetMemberData(nLeaderId);
		if not leader then
			leader = Kin:GetMemberData(kinData.nMasterId);
		end
		local tbKinData = {
			nKinId       = nKinId;
			szName       = kinData.szName;
			szMasterName = leader and leader:GetName() or "暂无";
			nScore       = 0;
			bCanJoin     = kinData:Available2Join();
			nJoinMember  = 0;
			nRank        = 999;
			tbFighter    = {};
		};

		self._tbKinData[nKinId] = tbKinData;
		table.insert(self._tbKinRankData, tbKinData);

		return tbKinData;
	end
end

function Boss:GetKinData(nKinId)
	if not self._tbKinData[nKinId] then
		Boss:KinJoin(nKinId);
	end
	return self._tbKinData[nKinId];
end

function Boss:DealKinScore(nKinId, nScore)
	assert(nKinId and nScore);
	if nScore == 0 or nKinId == 0 then
		return;
	end

	local tbKinData = Boss:GetKinData(nKinId);
	if tbKinData then
		tbKinData.nScore = tbKinData.nScore + nScore;
		Boss:MarkSortKin();
	end
end

function Boss:MarkSortKin()
	self.bSortKinRank = true;
end

function Boss:SortKinRank()
	table.sort(self._tbKinRankData, function (a, b)
		return a.nScore > b.nScore;
	end)

	for nRank, tbKinData in ipairs(self._tbKinRankData) do
		tbKinData.nRank = nRank;
	end

	Boss:RefreshTop10Kin(self._tbKinRankData);
end

function Boss:GetPartnerInfo(nPlayerId, nCount)
	nCount = nCount or 2; -- 抢夺列表默认取两个
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
	local tbPartners = {};
	for i = 1, Partner.MAX_PARTNER_POS_COUNT do
		local nPartnerId, nLevel = pAsyncData.GetPartnerInfo(i);
		if nPartnerId and nPartnerId ~= 0 then
			table.insert(tbPartners, {nPartnerId, nLevel});
			if #tbPartners >= nCount then
				break;
			end
		end
	end
	return tbPartners;
end

function Boss:CheckJoinLevel(player)
	return player.nLevel >= Boss.Def.nPlayerEnterLevel;
end

function Boss:FightBoss()
	if not Boss:CheckJoinLevel(me) then
		return false, string.format("%d级才可参加该活动", Boss.Def.nPlayerEnterLevel);
	end

	if not Boss:IsOpen() then
		return false, "本轮挑战已结束";
	end

    if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
        return false, "目前状态不允许切换地图";
    end

	if not Boss:CanJoinBoss(me) then
		return false, "目前状态无法挑战武林盟主，请先前往[FFFE0D]野外安全区[-]再尝试";
	end

	local pPlayerNpc = me.GetNpc();
	pPlayerNpc.RestoreAction() 			-- 先解除跳舞状态
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前状态不能参加";
	end

	local tbPlayerData = Boss:GetPlayerData(me.dwID);
	if not tbPlayerData then
		Boss:PlayerJoin(me);
		tbPlayerData = Boss:GetPlayerData(me.dwID);
	end

	local nCurTime = GetTime();
	if nCurTime < tbPlayerData.nNextFightTime then
		return false, "挑战冷却时间未到."
	end

	tbPlayerData.tbPartner = Boss:GetPartnerInfo(me.dwID);
	tbPlayerData.nNextFightTime = nCurTime + Boss.Def.nBossFightCd;
	tbPlayerData.nKinId = me.dwKinId;

	local nBattleKey = nCurTime;
	local tbBossData = Boss:GetBossData();
	local tbFightParam = {
		nMaxHp = tbBossData.nMaxHp,
		nCurHp = tbBossData.nCurHp,
		nNpcId = tbBossData.nNpcId,
	};

	if Boss.bServerFight or tbPlayerData.bServerFight then
		if not AsyncBattle:CreateAsyncBattle(me, Boss.Def.nBossFightMap, {2202, 1978}, "BossFightBattle", tbFightParam, nBattleKey, {nCurTime}, true) then
			Log("Error!! Enter BossFightBattle Map Failed!")
			return;
		end
	else
		AsyncBattle:CreateClientAsyncBattle(me, Boss.Def.nBossFightMap, {2202, 1978}, "BossFight_Client", tbFightParam, nBattleKey, {nCurTime})
	end


	LogD(Env.LOGD_ActivityPlay, me.szAccount, me.dwID, me.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_BOSS, me.GetFightPower());

	Achievement:AddCount(me, "BossChallenge_1");
end

function Boss:CalculateBossFightScore(nDamage, tbBossData)
	local nScore = nDamage / 100;
	local nLeftHpRate = tbBossData.nCurHp / tbBossData.nMaxHp;
	local nScoreRate = Boss:GetBossHpStageInfo(nLeftHpRate);
	return math.max(1, math.floor(nScore * nScoreRate)), nScore; -- 至少抢一分
end

function Boss:OnBossFightBattleResult(pPlayer, nResult, tbBattleObj, nFightBeginTime)
	if not self.bStart or not tbBattleObj.nDamage then
		pPlayer.CenterMsg("BOSS已被他人强行杀死, 本次得分无效");
		return;
	end

	local bClientFight = (tbBattleObj.szClassType ~= "BossFightBattle");
	if Boss.bServerFight and bClientFight then
		Log("Error!!!Boss:OnBossFightBattleResult while ServerFight Bug szClassType ~= BossFightBattle");
		return;
	end

	local tbPlayerData = Boss:GetPlayerData(pPlayer.dwID);
	if not tbPlayerData then
		return;
	end

	Boss:StateStart("OnBossFightBattleResult");

	local nCurTime = GetTime();
	local tbBossData = Boss:GetBossData();
	local nFightScore, nOrgScore = Boss:CalculateBossFightScore(tbBattleObj.nDamage, tbBossData);
	local nLimitScore = Boss:GetLimitBossFightScore(pPlayer);

	--当玩家盟主打分超过其战力对应分数上限时
	--将此上限和0.9*上限之间随机一个值作为其实际分数
	if nOrgScore > nLimitScore and bClientFight then
		--tbPlayerData.nNextFightTime = nCurTime - 30;
		tbPlayerData.bServerFight = true;
		--pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
		--pPlayer.MsgBox("由于系统检测到分数异常, 故判定此次挑战无效. 还请再次对盟主进行挑战");
		Log("BossFightResult OverScore", pPlayer.dwID, pPlayer.szName, nLimitScore, nOrgScore);
		local nLimitDmg = math.floor(MathRandom(0.9*nLimitScore, nLimitScore)) * 100;
		nFightScore, nOrgScore = Boss:CalculateBossFightScore(nLimitDmg, tbBossData);
		--return;
	else
		tbPlayerData.bServerFight = nil;
	end

	if not bClientFight then
		Boss:UpdateServerBossFightScore(pPlayer, nOrgScore);
	end

	if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then                                       -- 功能冻结
		nFightScore = 0
		local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuLinMengZhu)
		local szTime = Lib:GetTimeStr3(nEndTime)
		pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁时间%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuLinMengZhu), szTime or ""), {{"确定"}, {"取消"}})
	end

	tbPlayerData.nScore = tbPlayerData.nScore + nFightScore;

	local nKinScore = Kin:GetReducedValue(pPlayer.dwID, nFightScore)
	Boss:DealKinScore(pPlayer.dwKinId, nKinScore);
	Boss:MarkSortPlayer();

	pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	pPlayer.CallClientScript("Boss:OnMyMsg", string.format("本次挑战盟主获得[FFFF0E]%d[-]点积分", math.floor(nFightScore)));

	if pPlayer.dwKinId ~= 0 then
		local szBroadcastMsg = string.format("「%s」挑战盟主获得[FFFF0E]%d[-]点积分", pPlayer.szName, math.floor(nFightScore));
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, pPlayer.dwKinId);
	end

	local bBossDie = (nResult == 1);
	local tbFightResult = {
		bBossDie = bBossDie and not self.bPrepareFinish;
		nScore = nFightScore;
	};
	pPlayer.CallClientScript("Boss:OnFightBossResult", tbFightResult);

	pPlayer.TLogRoundFlow(Env.LogWay_Boss, Env.LogWay_BossFight, nFightScore or 0, GetTime() - nFightBeginTime,
		nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, tbPlayerData.nRank or 0, 0);
	--LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_BOSS, pPlayer.GetFightPower());

	Boss:StateEnd("OnBossFightBattleResult");
	return true;
end

AsyncBattle:ResgiterBattleType("BossFightBattle", Boss, Boss.OnBossFightBattleResult, nil, Boss.Def.nBossFightMap);
AsyncBattle:ResgiterBattleType("BossFight_Client", Boss, Boss.OnBossFightBattleResult, nil, Boss.Def.nBossFightMap)

function Boss:RobPlayer(nTargetPlayerId)
	if not Boss:CheckJoinLevel(me) then
		return false, string.format("%d级才可参加该活动", Boss.Def.nPlayerEnterLevel);
	end

	if not Boss:IsOpen() then
		return false, "本轮武林盟主挑战已结束";
	end

	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
	    return false, "目前状态不允许切换地图";
	end

	if not Boss:CanJoinBoss(me) then
		return false, "目前状态无法抢夺，请先前往[FFFE0D]野外安全区[-]再尝试";
	end

	if FriendShip:IsFriend(me.dwID, nTargetPlayerId) then
		return false, "这位侠客是您的好友，请不要背後捅刀子哦！";
	end

	local targetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId) or KPlayer.GetRoleStayInfo(nTargetPlayerId);
	local tbTargetPlayerData = Boss:GetPlayerData(nTargetPlayerId);
	-- 更新..
	if targetPlayer.dwKinId ~= tbTargetPlayerData.nKinId then
		tbTargetPlayerData.nKinId = targetPlayer.dwKinId;
	end
	if targetPlayer.nHonorLevel ~= tbTargetPlayerData.nHonorLevel then
		tbTargetPlayerData.nHonorLevel = targetPlayer.nHonorLevel;
	end

	if me.dwKinId == tbTargetPlayerData.nKinId and me.dwKinId ~= 0 then
		return false, "这位侠客是您的帮派成员，请不要破坏帮派关系哦！";
	end

	-- 头衔高于自身2级的玩家不可抢分
	if tbTargetPlayerData.nHonorLevel > me.nHonorLevel + 2 then
		return false, "此人头衔太高，隐隐传来一股威压，请提升头衔後再尝试！";
	end

	local nCurTime = GetTime();
	if nCurTime < tbTargetPlayerData.nProtectRobTime then
		return false, "该侠士正与其他侠士交手，请稍後再尝试挑战";
	end

	if nCurTime < tbTargetPlayerData.nProtectRobFullTime then
		local nProtectBack = Boss.Def.nProtectRobCd + Boss.Def.nExtraProtectRobCd - Boss.Def.nRobBattleTime;
		tbTargetPlayerData.nProtectRobTime = tbTargetPlayerData.nProtectRobFullTime - nProtectBack;
		return false, "该侠士正与其他侠士交手，请稍後再尝试挑战";
	end

	if not me.SyncOtherPlayerAsyncData(nTargetPlayerId) then
		return false, "同步战斗资料出错";
	end

	local pPlayerNpc = me.GetNpc();
	pPlayerNpc.RestoreAction() 			-- 先解除跳舞状态
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前状态不能参加";
	end

	local tbPlayerData = Boss:GetPlayerData(me.dwID);
	if not tbPlayerData then
		Boss:PlayerJoin(me);
		tbPlayerData = Boss:GetPlayerData(me.dwID);
		tbPlayerData.tbPartner = Boss:GetPartnerInfo(me.dwID);
	end

	if nCurTime < tbPlayerData.nNextRobTime then
		return false, "抢夺冷却时间未到";
	end

	local nBattleKey = nCurTime;
	if not AsyncBattle:CreateAsyncBattle(me, Boss.Def.nRobFightMap, {2190, 1939}, "BossRobBattle", nTargetPlayerId, nBattleKey, {nTargetPlayerId, nCurTime}, true) then
		Log("Error!! Enter BossRobBattle Map Failed!")
		return;
	end

	tbTargetPlayerData.nProtectRobTime = nCurTime + Boss.Def.nProtectRobCd;
	tbTargetPlayerData.nProtectRobFullTime = nCurTime + Boss.Def.nProtectRobCd + Boss.Def.nExtraProtectRobCd;
	Achievement:AddCount(me, "BossRob_1");

	tbPlayerData.nNextRobTime = nCurTime + Boss.Def.nRobCd;
	tbPlayerData.nKinId = me.dwKinId;

	LogD(Env.LOGD_ActivityPlay, me.szAccount, me.dwID, me.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_BOSS_ROB, me.GetFightPower());
	return true;
end

function Boss:OnRobBattleResult(pPlayer, nResult, tbBattleObj, nTargetPlayerId, nFightBeginTime)
	Boss:StateStart("OnRobBattleResult");

	if not Boss:IsOpen() then
		pPlayer.CenterMsg("此轮武林盟主挑战已结束, 本次抢夺得分无效");
		return;
	end

	--LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_BOSS_ROB, pPlayer.GetFightPower());

	local tbTargetPlayerData = Boss:GetPlayerData(nTargetPlayerId);
	assert(tbTargetPlayerData);

	local nRobScore = Boss:CalculateRobScore(tbTargetPlayerData.nScore, tbBattleObj.nEnemyBeated, tbBattleObj.bEnemyMainBeated);
	local tbPlayerData = Boss:GetPlayerData(pPlayer.dwID);
	if not tbPlayerData then
		Boss:PlayerJoin(pPlayer);
		tbPlayerData = Boss:GetPlayerData(pPlayer.dwID);
	end

	if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then                                       -- 功能冻结,自己抢不到分，对方也不扣分
		nRobScore = 0

		local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuLinMengZhu)
        local szTime = Lib:GetTimeStr3(nEndTime)
        pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁时间%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuLinMengZhu), szTime or ""), {{"确定"}, {"取消"}})
	end

	if nResult == 1 then
		tbTargetPlayerData.nProtectRobTime = math.max(tbTargetPlayerData.nProtectRobFullTime, tbTargetPlayerData.nProtectRobTime);
	end
	tbTargetPlayerData.nProtectRobFullTime = 0;

	tbPlayerData.nScore = tbPlayerData.nScore + nRobScore;
	tbTargetPlayerData.nScore = tbTargetPlayerData.nScore - nRobScore;

	local pTargetPlayer = KPlayer.GetRoleStayInfo(nTargetPlayerId);
	if nRobScore > 0 then
		FriendShip:AddHate(pTargetPlayer, pPlayer, Boss.Def.nRobHate);
		FriendShip:AddHate(pPlayer, pTargetPlayer, -0.8 * Boss.Def.nRobHate);
		RecordStone:AddRecordCount(pPlayer, "Master", 1);
	end

	Boss:MarkSortPlayer();

	pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	local szMyMsg = string.format("成功抢夺到[FFFF0E]%d[-]点积分", nRobScore);
	if nRobScore == 0 then
		szMyMsg = "你尝试抢夺积分, 可惜并无所获..";
	end
	pPlayer.CallClientScript("Boss:OnMyMsg", szMyMsg);

	pTargetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerId);
	if pTargetPlayer then
		tbTargetPlayerData.nKinId = pTargetPlayer.dwKinId;
		pTargetPlayer.CallClientScript("Boss:OnSyncMyData", tbTargetPlayerData);
		if nRobScore == 0 then
			pTargetPlayer.CallClientScript("Boss:OnMyMsg", string.format("[FFFF0E]「%s」[-]尝试抢夺您的积分, 可惜他技不如人，抢夺失败了", pPlayer.szName));
		else
			pTargetPlayer.CallClientScript("Boss:OnMyMsg", string.format("被[FFFF0E]「%s」[-]夺走了%d点积分", pPlayer.szName, nRobScore));
		end
	end


	local szBroadcastMsg = string.format("[FFFF0E]「%s」[-]成功夺走[FFFF0E]「%s」[-]%d点积分", pPlayer.szName, tbTargetPlayerData.szName, nRobScore);
	if nRobScore == 0 then
		szBroadcastMsg = string.format("[FFFF0E]「%s」[-]尝试对[FFFF0E]「%s」[-]进行抢夺, 可惜技不如人", pPlayer.szName, tbTargetPlayerData.szName);
	end
	if pPlayer.dwKinId ~= 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, pPlayer.dwKinId);
	end
	if tbTargetPlayerData.nKinId and tbTargetPlayerData.nKinId ~= 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, tbTargetPlayerData.nKinId);
	end

	Boss:MarkRobTable(pPlayer.dwID, nTargetPlayerId);
	Boss:DealKinScore(pPlayer.dwKinId, nRobScore);
	Boss:DealKinScore(tbTargetPlayerData.nKinId, -nRobScore);

	local tbEnemyPartners = Boss:GetPartnerInfo(nTargetPlayerId, Partner.MAX_PARTNER_POS_COUNT);

	-- 结算界面
	local tbResult = {
		bSuccess = (nResult == 1);
		nRobScore = nRobScore;
		tbEnemyPartners = tbEnemyPartners;
		tbEnemyData = tbTargetPlayerData;
		tbBeated = tbBattleObj.tbBeatedNpc;
		bMainBeated = tbBattleObj.bEnemyMainBeated;
	};

	pPlayer.CallClientScript("Boss:OnRobResult", tbResult);

	pPlayer.TLogRoundFlow(Env.LogWay_Boss, Env.LogWay_BossRob, nRobScore or 0, GetTime() - nFightBeginTime,
		nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, tbPlayerData.nRank or 0, 0);

	Boss:StateEnd("OnRobBattleResult");
end

function Boss:CalculateRobScore(nEnemyScore, nBeated, bMainBeated)
	local nResultScore = 0;
	local nMinBaseRate = Boss.Def.nRobScoreBaseRateMin;
	local nMaxBaseRate = Boss.Def.nRobScoreBaseRateMax;
	local nBaseScore = MathRandom(nMinBaseRate, nMaxBaseRate) * nEnemyScore / 100;
	local nMainCount = 0;
	if bMainBeated then
		nMainCount = 1;
		nResultScore = nBaseScore * 0.6;
	end

	nResultScore = nResultScore + (nBeated - nMainCount) * 0.1 * nBaseScore;

	return math.floor(nResultScore);
end

AsyncBattle:ResgiterBattleType("BossRobBattle", Boss, Boss.OnRobBattleResult, nil, Boss.Def.nRobFightMap);

function Boss:Refresh10Player(tbPlayers)
	local tbRankData = Boss:GetBossRankData();
	if not tbRankData.tbPlayerRank then
		tbRankData.tbPlayerRank = {};
		tbRankData.nPlayerRankVersion = 0;
	end

	tbRankData.nPlayerRankVersion = tbRankData.nPlayerRankVersion + 1;
	tbRankData.tbPlayerRank = {};
	for nRank, tbPlayerData in ipairs(tbPlayers) do
		if nRank > 20 then
			break;
		end
		tbRankData.tbPlayerRank[nRank] = tbPlayerData;
	end
end

function Boss:GetTop10Player(nVersion)
	local tbRankData = Boss:GetBossRankData();

	if nVersion ~= tbRankData.nPlayerRankVersion then
		return tbRankData.tbPlayerRank, tbRankData.nPlayerRankVersion;
	end
end

function Boss:RefreshTop10Kin(tbKins)
	local tbRankData = Boss:GetBossRankData();
	if not tbRankData.tbKinRank then
		tbRankData.tbKinRank = {};
		tbRankData.nKinRankVersion = 0;
	end

	tbRankData.nKinRankVersion = tbRankData.nKinRankVersion + 1;
	for nRank, tbKinData in ipairs(tbKins) do
		if nRank > 10 then
			break;
		end
		tbRankData.tbKinRank[nRank] = tbKinData;
	end
end

function Boss:GetTop10Kin(nVersion)
	local tbRankData = Boss:GetBossRankData();
	if nVersion ~= tbRankData.nKinRankVersion then
		return tbRankData.tbKinRank, tbRankData.nKinRankVersion;
	end
end

function Boss:SyncBossInfo(nEndTime, nMyRank)
	local tbBossData = Boss:GetBossData() or {};
	if tbBossData.nEndTime ~= nEndTime and Boss:IsOpen() then
		me.CallClientScript("Boss:OnSyncBossData", tbBossData);
	end

	local tbPlayerData = Boss:IsOpen() and Boss:GetPlayerData(me.dwID);
	if tbPlayerData and tbPlayerData.nRank ~= nMyRank then
		me.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	end

	if tbBossData.nEndTime == nEndTime then
		return true;
	end

	me.CallClientScript("Boss:OnSyncBossTime", tbBossData.nStartTime or 0, tbBossData.nEndTime or 0);
	return true;
end

function Boss:SyncRobList()
	if not Boss:IsOpen() then
		return false, "挑战未开启";
	end

	Boss:StateStart("SyncRobListCount", 0);

	local tbRobList = {};
	local nTopSelectCount = 20;

	for nRank, tbPlayerData in ipairs(self._tbPlayerRankData) do
		if nRank > nTopSelectCount then
			break;
		end

		table.insert(tbRobList, tbPlayerData);
	end

	local tbRobers = Boss:GetRobers(me.dwID) or {};
	for nPlayerId, _ in pairs(tbRobers) do
		local tbPlayerData = Boss:GetPlayerData(nPlayerId);
		if tbPlayerData.nRank > nTopSelectCount then
			table.insert(tbRobList, tbPlayerData);
		end
	end

	local myData = Boss:GetPlayerData(me.dwID) or {};
	local nMyRank = myData.nRank;
	if nMyRank then
		local nUpSelectCount = 5;
		local nBeforeCount = 0;
		local nCurRank = nMyRank;
		while nBeforeCount <= nUpSelectCount and nCurRank > nTopSelectCount do
			local tbPlayerData = self._tbPlayerRankData[nCurRank];
			if tbPlayerData and
				not FriendShip:IsFriend(me.dwID, tbPlayerData.nPlayerId)
				and (tbPlayerData.nKinId ~= me.dwKinId or me.dwKinId == 0 or me.dwID == tbPlayerData.nPlayerId)
				and not tbRobers[tbPlayerData.nPlayerId]
				then
				nBeforeCount = nBeforeCount + 1;
				table.insert(tbRobList, tbPlayerData);
			end

			nCurRank = nCurRank - 1;
		end
	end

	me.CallClientScript("Boss:OnSyncRobList", tbRobList);
	Boss:StateEnd("SyncRobListCount", #tbRobList);
	return true;
end

function Boss:SyncKinRank(nVersion)
	local tbRank, nVersion = Boss:GetTop10Kin(nVersion);
	if tbRank then
		local tbMyKin = Boss:IsOpen() and Boss:GetPlayerData(me.dwID) and Boss:GetKinData(me.dwKinId);
		me.CallClientScript("Boss:OnSyncKinRank", tbRank, nVersion, tbMyKin);
	end
	return true;
end

function Boss:SyncPlayerRank(nVersion)
	local tbRank, nVersion = Boss:GetTop10Player(nVersion);
	if tbRank then
		me.CallClientScript("Boss:OnSyncPlayerRank", tbRank, nVersion);
	end
	return true;
end

local tbBossInterface = {
	FightBoss = true;
	RobPlayer = true;
	SyncPlayerRank = true;
	SyncKinRank = true;
	SyncRobList = true;
	SyncBossInfo = true;
}

function Boss:ClientRequest(szRequestType, ...)
	if Boss:ZCIsCrossOpen() then
		if Boss:ZCIsJoinCross(me) then
			Boss:ZCSyncBossInfo();
			return;
		end
	end

	if tbBossInterface[szRequestType] then
		Boss:StateStart(szRequestType);
		local bSuccess, szInfo = Boss[szRequestType](Boss, ...);
		Boss:StateEnd(szRequestType);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG Boss Request:", szRequestType, ...);
	end
end

function Boss:ResetPlayerData(nPlayerId)
	if Boss.bStart then
		local tbPlayerData = Boss:GetPlayerData(nPlayerId);
		if not tbPlayerData then
			return
		end
		tbPlayerData.nScore = 0												-- 将武林盟主个人积分重置为0
		--Boss:MarkSortPlayer();											-- 更新玩家排名
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);	-- 同步玩家自身信息
			local tbRank, nVersion = Boss:GetTop10Player();
			if tbRank then
				pPlayer.CallClientScript("Boss:OnSyncPlayerRank", tbRank, nVersion);		-- 同步玩家排名
			end
		end
	end
end

-- ===================================================IDIP用到=================================================================
function Boss:PlayerDmgInfo(dwID)
    local nMyRank = 0
    local nMyScore = 0
    local nKinRank = 0
    local nKinScore = 0
    local tbPlayerData = Boss:GetPlayerData(dwID);
    if not tbPlayerData then
        return nMyScore,nMyRank,nKinScore,nKinRank
    else
        nMyRank = tbPlayerData.nRank
        nMyScore = tbPlayerData.nScore
        local pPlayer = KPlayer.GetPlayerObjById(dwID) or KPlayer.GetRoleStayInfo(dwID);
        local nMyKinId = pPlayer.dwKinId
        if nMyKinId > 0 then
            local tbKinData = Boss:GetKinData(nMyKinId)
            if tbKinData then
                nKinRank = tbKinData.nRank
                nKinScore = tbKinData.nScore
            end
        end
    end
    return nMyScore,nMyRank,nKinScore,nKinRank
end


--------------------------------------------------------------------------------
-----------------------跨服盟主相关---------------------------------------------
--------------------------------------------------------------------------------

function Boss:ZCGetSaveData(szKey)
	local tbScriptData = ScriptData:GetValue("Boss");
	if not tbScriptData[szKey] then
		tbScriptData[szKey] = {};
	end
	return tbScriptData[szKey];
end

function Boss:ZCSetSaveData(szKey, data)
	local tbScriptData = ScriptData:GetValue("Boss");
	tbScriptData[szKey] = data;
	ScriptData:AddModifyFlag("Boss");
end

function Boss:ZCTimeFramOpen()
	return GetTimeFrameState(Boss.ZDef.szTimeFrame) == 1;
end

function Boss:ZCGetBossData()
	return Boss:ZCGetCacheData("ZBossData");
end

function Boss:ZCIsCrossOpen()
	return self.bZoneBossOpen and not self.bZPreFinish;
end

function Boss:ZCRecordKinScore4ZFight(nKinId, nRank)
	local nScore = Boss.ZDef.tbRankScore4Cross[nRank];
	if not nScore then
		return;
	end

	if self.nZoneBossOpenDay == Lib:GetLocalDay() then
		return;
	end

	if not Boss:ZCTimeFramOpen() then
		return;
	end

	local tbRankScore = Boss:ZCGetSaveData("RankScore4Cross");
	tbRankScore[nKinId] = tbRankScore[nKinId] or 0;
	tbRankScore[nKinId] = tbRankScore[nKinId] + nScore;
	Log("ZCRecordKinScore4ZFight", nKinId, tbRankScore[nKinId], nScore);
end

function Boss:ZCCalculateCrossKins()
	local tbJoinKinInfo = Boss:ZCGetCurrentCrossKinInfo();
	local nCurWeek = Lib:GetLocalWeek();
	-- 参加的跨服的家族当周不变
	if nCurWeek == tbJoinKinInfo.nWeek then
		return;
	end
	tbJoinKinInfo.nWeek = nCurWeek;

	local tbRankScore = Boss:ZCGetSaveData("RankScore4Cross");
	local tbSort = {};
	for nKinId, nScore in pairs(tbRankScore) do
		table.insert(tbSort, {nKinId, nScore});
	end

	table.sort(tbSort, function (a, b)
		return a[2] > b[2];
	end);

	tbJoinKinInfo.tbJoinKins = {};
	for i = 1, Boss.ZDef.nJoinKinCountPerWorld do
		if not tbSort[i] then
			break;
		end

		local nKinId, nScore = unpack(tbSort[i]);
		tbJoinKinInfo.tbJoinKins[nKinId] = nScore;
		Log("ZCCalculateCrossKins", nKinId, i, nScore);
	end
	Boss:ZCSetSaveData("ZJoinKin", tbJoinKinInfo);
	Boss:ZCSetSaveData("RankScore4Cross", {});
end

function Boss:ZCGetCurrentCrossKinInfo()
	return Boss:ZCGetSaveData("ZJoinKin");
end

function Boss:ZCSendKinNotifyMail()
	Boss:ZCCalculateCrossKins();

	local tbJoinKinInfo = Boss:ZCGetCurrentCrossKinInfo();
	local tbKins = tbJoinKinInfo.tbJoinKins or {};

	local szMailFormat = [[    恭喜侠士，您所在的帮派[ffff00]%s[-]于普通武林盟主中表现优异，出类拔萃！现已获得跨服武林盟主的参与资格。此次跨服武林盟主的开启时间为[ffff00]%s中午12:30/晚上19:30（共两场）[-]，请您务必准时参加，携手帮派兄弟冲击桂冠，夺取更加丰厚的奖励！]];
	local szTime = Lib:GetTimeStr(GetTime()+12*3600); -- 以中午为12点前为当日计算
	local tbKinNames = {};
	for nKinId, _ in pairs(tbKins) do
		local tbKinData = Kin:GetKinById(nKinId);
		if tbKinData then
			Mail:SendKinMail({
				Title = "跨服盟主资格通知",
				KinId = nKinId,
				Text = string.format(szMailFormat, tbKinData.szName, szTime),
				From = "独孤剑",
			});

			table.insert(tbKinNames, string.format("[ffff00]%s[-]", tbKinData.szName));

			local szMsg = "恭喜本帮派于普通武林盟主中表现优异，出类拔萃！现已获得跨服武林盟主的参与资格，可喜可贺！#49";
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
		end
	end

	if next(tbKinNames) then
		local szMsg = "恭喜帮派%s于普通武林盟主中表现优异，出类拔萃！现已获得跨服武林盟主的参与资格，可喜可贺！";
		KPlayer.SendWorldNotify(1, 1000,string.format(szMsg, table.concat(tbKinNames, ",")),ChatMgr.ChannelType.Public, 1);
	end
end

function Boss:ZCIsJoinCross(pPlayer)
	local tbZKinsInfo = Boss:ZCGetCacheData("ZJoinKinData");
	return tbZKinsInfo[pPlayer.dwKinId] ~= nil;
end

function Boss:ZCGetKinInfo(nKinId)
	local tbZKinsInfo = Boss:ZCGetCacheData("ZJoinKinData");
	return tbZKinsInfo[nKinId];
end

function Boss:ZCKinJoin(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		return;
	end

	local nLeaderId = kinData:GetLeaderId();
	local leader = Kin:GetMemberData(nLeaderId);
	if not leader then
		leader = Kin:GetMemberData(kinData.nMasterId);
	end
	local tbKinData = {
		nKinId       = nKinId;
		szName       = kinData.szName;
		szMasterName = leader and leader:GetName() or "暂无";
		nScore       = 0;
		nJoinMember  = 0;
		nRank        = Boss.ZDef.nDefaultRank;
		tbFighter    = {};
		nServerId    = GetServerIdentity();
	}

	local tbZKinsInfo = Boss:ZCGetCacheData("ZJoinKinData");
	tbZKinsInfo[nKinId] = tbKinData;
	Boss:ZCCallZone("ZSReportKinData", tbKinData);
	return tbKinData;
end

function Boss:ZCStart(tbBossData)
	Boss:ZCCalculateCrossKins();
	Boss:ZCClearData();

	local tbJoinKinInfo = Boss:ZCGetCurrentCrossKinInfo();
	local tbZBossData = Boss:ZCGetBossData();
	tbZBossData.szType = "CrossBoss";
	tbZBossData.nStartTime = tbBossData.nStartTime;
	tbZBossData.nEndTime = tbBossData.nEndTime;
	tbZBossData.nMaxHp = tbBossData.nMaxHp;
	tbZBossData.nCurHp = tbBossData.nCurHp;
	tbZBossData.nNpcId = tbBossData.nNpcId;
	tbZBossData.tbKins = tbJoinKinInfo.tbJoinKins;

	for nKinId, _ in pairs(tbJoinKinInfo.tbJoinKins or {}) do
		Boss:ZCKinJoin(nKinId);
	end

	self.nZCheckStateActive = Timer:Register(Env.GAME_FPS, Boss.ZCCheckStateActive, Boss);
	self.bZoneBossOpen = true;
	self.nZoneBossOpenDay = Lib:GetLocalDay();
end

function Boss:ZCCheckStateActive()
	if not self.bZoneBossOpen or not self.nZCheckStateActive then
		self.nZCheckStateActive = nil;
		return false;
	end

	local nCurTime = GetTime();
	local tbBossData = Boss:ZCGetBossData();
	tbBossData.nCurHp = math.max(tbBossData.nMaxHp * (tbBossData.nEndTime - nCurTime) / (tbBossData.nEndTime - tbBossData.nStartTime), 0);

	if nCurTime > tbBossData.nEndTime then
		Boss:ZCNotifyFinishBoss();
		self.nZCheckStateActive = nil;
		return false;
	end
	return true;
end

function Boss:ZCNotifyFinishBoss()
	if not Boss:ZCIsCrossOpen() then
		return;
	end

	self.bZPreFinish = true;
	Log("Boss:ZCNotifyFinishBoss");

	local tbPlayersData = Boss:ZCGetCacheData("ZPlayersData");
	for nPlayerId, _ in pairs(tbPlayersData) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("Boss:NotifyFinish");
		end
	end

	AsyncBattle:AllBattleExecute("CrossBossFightBattle", "CloseBossBattle");
	AsyncBattle:AllBattleExecute("CrossBossRobBattle", "CloseBossBattle");
end

function Boss:ZCFinish()
	Log("Boss:ZCFinish");

	-- 统计发送家族相关奖励
	local tbKinsInfo = Boss:ZCGetCacheData("ZJoinKinData");
	local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam()
	for nKinId, tbKinData in pairs(tbKinsInfo) do
		Boss:ZCSendKinReward(tbKinData);
		TLog("KinActFlow", szGameAppid, nPlat, nServerIdentity, Env.LogWay_Boss, nKinId, tbKinData.nJoinMember, tbKinData.nScore);
	end

	local tbPlayersData = Boss:ZCGetCacheData("ZPlayersData");
	for nPlayerId, tbPlayerData in pairs(tbPlayersData) do
		Boss:ZCSendPlayerReward(tbPlayerData);
	end

	Boss:ZCClearData();
end

function Boss:ZCSendPlayerReward(tbPlayerData)
	local tbKinData = Boss:ZCGetKinInfo(tbPlayerData.nKinId);
	local pPlayer = KPlayer.GetPlayerObjById(tbPlayerData.nPlayerId);
	local kinMemberData = Kin:GetMemberData(tbPlayerData.nPlayerId) or {};

	if not tbKinData or kinMemberData.nKinId ~= tbPlayerData.nKinId then
		Log("ZCSendPlayerReward no kin member anymore", tbPlayerData.nPlayerId, tbPlayerData.szName, kinMemberData.nKinId, tbPlayerData.nKinId);
		return;
	end

	local nKinHonorBoss = GetItemValueFromSetting(tbKinData.nRank, Boss.ZDef.tbKinBoxRankScore).Honor;
	if tbKinData.nJoinMember >= Boss.Def.nBossKinMemberN then
		nKinHonorBoss = math.max(nKinHonorBoss, Boss.Def.nBossKinMemberNMinScore);
	end

	if pPlayer and tbKinData.nRank == 1 then
		Achievement:AddCount(pPlayer, "BossNumberOne_1");
	end

	if tbPlayerData.nRank == 1 then
		local szMsgFormat = "恭喜来自[FFFF0E]「%s」[-]帮派的[FFFF0E]%s[-]，于跨服武林盟主活动中个人排名[FFFF0E]第一[-]，傲视武林，唯我独尊！";
		KPlayer.SendWorldNotify(1, 1000,string.format(szMsgFormat, tbKinData.szName, tbPlayerData.szName),ChatMgr.ChannelType.Public, 1);

		szMsgFormat = "恭喜本帮派成员[FFFF0E]%s[-]于跨服武林盟主活动中个人排名[FFFF0E]第一[-]，傲视武林，独步天下！#49";
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(szMsgFormat, tbPlayerData.szName), tbKinData.nKinId);
	end

	local nPlayerHonorBoss = GetItemValueFromSetting(tbPlayerData.nRank, Boss.ZDef.tbPlayerBoxRankScore).Honor;
	if tbPlayerData.nScore >= Boss.Def.nBossPlayerScoreN then
		nPlayerHonorBoss = math.max(nPlayerHonorBoss, Boss.Def.nBossPlayerScoreNMinScore);
	end

	local kinMemberData = Kin:GetMemberData(tbPlayerData.nPlayerId);
	local nKinRewardAdditionRate = kinMemberData and kinMemberData:GetRewardAdditionRate() or 0;
	local nFinalHonorBoss = (nKinHonorBoss + nPlayerHonorBoss) * (1 + nKinRewardAdditionRate);

	if pPlayer then
		local tbMyKin = tbKinData;
		local tbMyRank = tbPlayerData;
		local tbKinTopInfo = Boss:ZCGetCacheData("ZKinRank");
		local tbPlayerTopRank = Boss:ZCGetCacheData("ZPlayerRank");
		pPlayer.CallClientScript("Boss:SyncFinalResult", tbMyRank, tbMyKin, tbPlayerTopRank.tbPlayerRank, tbKinTopInfo.tbKinRank);
	end

	local szMsgFormat = "尊敬的玩家：\n\n    本次挑战武林盟主，您获得了[FFFE0D]第%d名[-]，您%s本次挑战共获得[FFFE0D]%d[-]贡献%s，请注意查收哦。\n\n小提示：帮派参与人数越多奖励越丰厚哦！";
	local szKinInfo = string.format("所在的帮派排名第[FFFE0D]%d[-]名，", tbKinData.nRank);

	local tbMailRewards = {{ Boss.Def.szAwardMoneyType, nFinalHonorBoss}};
	local _, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(pPlayer, "Boss", tbMailRewards)

	local tbTitleAward = Boss:GetCrossPlayerRankTitleAward(tbPlayerData.nRank);
	if tbTitleAward then
		table.insert(tbFinalAward, tbTitleAward);
	end

	local tbGiftBoxMail = {
		To = tbPlayerData.nPlayerId;
		Title = "跨服武林盟主奖励";
		Text = string.format(szMsgFormat, tbPlayerData.nRank, szKinInfo, nFinalHonorBoss, szMsg and string.format(szMsg, nFinalHonorBoss) or "");
		From = "「武林盟主」独孤剑";
		tbAttach = tbFinalAward;
		nLogReazon = Env.LogWay_Boss;
		tbParams = {
			nRank = tbPlayerData.nRank,
		};
	};

	Mail:SendSystemMail(tbGiftBoxMail);
end

function Boss:ZCSendKinReward(tbKinData)
	local nRank = tbKinData.nRank;

	if nRank == 1 then
		local szMsgFormat = "恭喜本服内帮派[FFFF0E]「%s」[-]于跨服武林盟主活动中荣获[FFFF0E]第一名[-]，独占鳌头！帮派实力令人惊叹！";
		KPlayer.SendWorldNotify(1, 1000,string.format(szMsgFormat, tbKinData.szName),ChatMgr.ChannelType.Public, 1);

		local szMsg = "恭喜本帮派于跨服武林盟主活动中荣获[FFFF0E]第一名[-]，独占鳌头！望诸位侠士继续努力，再创辉煌！#49";
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, tbKinData.nKinId);
	end

	local nJoinMember = 0;
	local tbFighter = {};
	local nKinId = tbKinData.nKinId;
	for nPlayerId, _ in pairs(tbKinData.tbFighter) do
		local kinMemberData = Kin:GetMemberData(nPlayerId);
		if kinMemberData and kinMemberData.nKinId == nKinId and not kinMemberData:IsRetire() then
			nJoinMember = nJoinMember + 1;
			tbFighter[nPlayerId] = true;
		end
	end
	tbKinData.nJoinMember = nJoinMember;

	local tbBossData = Boss:ZCGetBossData();
	local tbAuctionRewards = Boss:GetCrossAuctionRewards();
	local tbAuctionItems = Boss:GetKinAuctionItems(nRank, tbBossData.nNpcId, nJoinMember, Boss.ZDef.KinRwardRankScore, tbAuctionRewards);


	Log("ZCSendKinReward", nKinId, nJoinMember, nRank);
	Lib:LogTB(tbAuctionItems);

	Kin:AddAuction(nKinId, "CrossBoss", tbFighter, tbAuctionItems);

	local nPrestige = GetItemValueFromSetting(nRank, Boss.Def.KinPrestigeRward).Prestige;
	local kinData = Kin:GetKinById(nKinId);
	nPrestige = nPrestige + nJoinMember; -- 所有家族获得参与人数*1的基准威望值
	kinData:AddPrestige(nPrestige, Env.LogWay_Boss);

	-- 记录家族排名信息
	kinData:SetCacheFlag("BossRank" .. (self.nRound or ""), nRank);

	local szMsg = string.format("你的帮派在本轮跨服武林盟主当中, 获得第[FFFF0E]%d[-]名, 获得威望[FFFF0E]%d[-]", nRank, nPrestige);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
end

function Boss:ZCGetRobTargetInfo(nTargetPlayerId)
	local tbTargetsInfo = Boss:ZCGetCacheData("ZRobTarget");
	return tbTargetsInfo[nTargetPlayerId];
end

function Boss:ZCGetCacheData(szKey)
	if not self._tbZCCacheData[szKey] then
		self._tbZCCacheData[szKey] = {};
	end
	return self._tbZCCacheData[szKey];
end

function Boss:ZCClearData()
	self.bZPreFinish = nil;
	self.bZoneBossOpen = nil;
	self._tbZCCacheData = {};
	KPlayer.ClearBossFightAsyncData();
end

function Boss:ZCCheckFightState(pPlayer)
	if not Boss:CheckJoinLevel(pPlayer) then
		return false, string.format("%d级才可参加该活动", Boss.Def.nPlayerEnterLevel);
	end

	if not Boss:ZCIsCrossOpen() then
		return false, "本轮挑战已结束";
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		return false, "目前状态不允许切换地图";
	end

	if not Boss:CanJoinBoss(pPlayer) then
		return false, "目前状态无法挑战武林盟主，请先前往[FFFE0D]野外安全区[-]再尝试";
	end

	local pPlayerNpc = pPlayer.GetNpc();
	pPlayerNpc.RestoreAction() 			-- 先解除跳舞状态
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前状态不能参加";
	end

	local nCurTime = GetTime();
	local tbBossData = Boss:ZCGetBossData();
	if nCurTime < tbBossData.nStartTime then
		return false, "活动尚未开启，请稍後";
	end

	return true;
end

function Boss:ZCGetPlayerData(nPlayerId)
	local tbPlayersData = Boss:ZCGetCacheData("ZPlayersData");
	return tbPlayersData[nPlayerId];
end

function Boss:ZCPlayerJoin(pPlayer)
	local tbPlayersData = Boss:ZCGetCacheData("ZPlayersData");
	local nPlayerId = pPlayer.dwID;
	if tbPlayersData[nPlayerId] then
		Log("ZCPlayerJoin Error, Player Already Exist", nPlayerId);
		return false;
	end

	tbPlayersData[nPlayerId] = {
		nKinId              = pPlayer.dwKinId;
		nPlayerId           = nPlayerId;
		szName              = pPlayer.szName;
		nPortrait           = pPlayer.nPortrait;
		nScore              = 0;
		nTime               = GetTime();
		nNextFightTime      = 0;
		nNextRobTime        = 0;
		nProtectRobTime     = 0;
		nProtectRobFullTime = 0; -- 抢夺全保护时间，被抢期间有效
		nLevel              = pPlayer.nLevel;
		nHonorLevel         = pPlayer.nHonorLevel;
		nFaction            = pPlayer.nFaction;
		nRank               = Boss.ZDef.nDefaultRank;
		tbPartner           = {};
		nServerId           = GetServerIdentity();
	};

	local tbKinInfo = Boss:ZCGetKinInfo(pPlayer.dwKinId);
	if not tbKinInfo then
		Log("ZCPlayerJoin Error, Kin not found", nPlayerId, pPlayer.dwKinId);
		return false;
	end

	tbKinInfo.nJoinMember = tbKinInfo.nJoinMember + 1;
	tbKinInfo.tbFighter[nPlayerId] = true;

	EverydayTarget:AddCount(pPlayer, "Boss");
	Boss:ZCCallZone("ZSReportPlayerData", tbPlayersData[nPlayerId]);
	Boss:ZCCallZone("ZSReportKinDataByKey", pPlayer.dwKinId, {nJoinMember = tbKinInfo.nJoinMember});


	local tbLocalPlayerData = Boss:GetPlayerData(nPlayerId);
	if tbLocalPlayerData then
		Log("ClearPlayerData for ZBoss Join", nPlayerId, tbLocalPlayerData.nScore, tbLocalPlayerData.nRank);
		Boss:ClearPlayerData(nPlayerId);
	end
end

function Boss:ZCFightBoss()
	local bRet, szMsg = Boss:ZCCheckFightState(me);
	if not bRet then
		return false, szMsg;
	end

	local tbPlayerData = Boss:ZCGetPlayerData(me.dwID);
	if not tbPlayerData then
		Boss:ZCPlayerJoin(me);
		tbPlayerData = Boss:ZCGetPlayerData(me.dwID);
	end

	local nCurTime = GetTime();
	if nCurTime < tbPlayerData.nNextFightTime then
		return false, "挑战冷却时间未到";
	end

	tbPlayerData.tbPartner = Boss:GetPartnerInfo(me.dwID, Partner.MAX_PARTNER_POS_COUNT);
	tbPlayerData.nNextFightTime = nCurTime + Boss.Def.nBossFightCd;

	if tbPlayerData.nKinId ~= me.dwKinId then
		tbPlayerData.nKinId = me.dwKinId;
		Boss:ZCCallZone("ZSReportPlayerDataByKey", me.dwID, {nKinId = tbPlayerData.nKinId});
	end

	Boss:ZCCallZone("ZSReportPlayerDataByKey", me.dwID, {tbPartner = tbPlayerData.tbPartner, szAsyncData = me.GetBattleAsyncData()});

	local nBattleKey = nCurTime;
	local tbBossData = Boss:ZCGetBossData();
	local tbFightParam = {
		nMaxHp = tbBossData.nMaxHp,
		nCurHp = tbBossData.nCurHp,
		nNpcId = tbBossData.nNpcId,
	};

	if Boss.bServerFight or tbPlayerData.bServerFight then
		if not AsyncBattle:CreateAsyncBattle(me, Boss.Def.nBossFightMap, {2202, 1978}, "CrossBossFightBattle", tbFightParam, nBattleKey, {nCurTime}, true) then
			Log("Error!! Enter CrossBossFightBattle Map Failed!")
			return;
		end
	else
		AsyncBattle:CreateClientAsyncBattle(me, Boss.Def.nBossFightMap, {2202, 1978}, "CrossBossFight_Client", tbFightParam, nBattleKey, {nCurTime})
	end

	LogD(Env.LOGD_ActivityPlay, me.szAccount, me.dwID, me.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_ZBOSS, me.GetFightPower());
	Achievement:AddCount(me, "BossChallenge_1");
	return true;
end

function Boss:ZCOnFightBattleResult(pPlayer, nResult, tbBattleObj, nFightBeginTime)
	if not self.bZoneBossOpen or not tbBattleObj.nDamage then
		pPlayer.CenterMsg("BOSS已被他人强行杀死, 本次得分无效");
		return;
	end

	local bClientFight = (tbBattleObj.szClassType ~= "CrossBossFightBattle");
	if Boss.bServerFight and bClientFight then
		Log("Error!!!Boss:ZCOnFightBattleResult BattleType Error");
		return;
	end

	local tbPlayerData = Boss:ZCGetPlayerData(pPlayer.dwID);
	if not tbPlayerData then
		Log("Error ZCOnFightBattleResult Player data not found");
		return;
	end

	local nCurTime = GetTime();
	local tbBossData = Boss:ZCGetBossData();
	local nFightScore, nOrgScore = Boss:CalculateBossFightScore(tbBattleObj.nDamage, tbBossData);
	local nLimitScore = Boss:GetLimitBossFightScore(pPlayer);

	--当玩家盟主打分超过其战力对应分数上限时
	--将此上限和0.9*上限之间随机一个值作为其实际分数
	if nOrgScore > nLimitScore and bClientFight then
		--tbPlayerData.nNextFightTime = nCurTime - 30;
		tbPlayerData.bServerFight = true;
		--pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
		--pPlayer.MsgBox("由于系统检测到分数异常, 故判定此次挑战无效. 还请再次对盟主进行挑战");
		Log("BossFightResult OverScore", pPlayer.dwID, pPlayer.szName, nLimitScore, nOrgScore);
		local nLimitDmg = math.floor(MathRandom(0.9*nLimitScore, nLimitScore)) * 100;
		nFightScore, nOrgScore = Boss:CalculateBossFightScore(nLimitDmg, tbBossData);
		--return;
	else
		tbPlayerData.bServerFight = nil;
	end

	if not bClientFight then
		Boss:UpdateServerBossFightScore(pPlayer, nOrgScore);
	end

	if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then                                       -- 功能冻结
		nFightScore = 0
		local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuLinMengZhu)
		local szTime = Lib:GetTimeStr3(nEndTime)
		pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁时间%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuLinMengZhu), szTime or ""), {{"确定"}, {"取消"}})
	end

	-- tbPlayerData.nScore = tbPlayerData.nScore + nFightScore;
	local nKinScore = Kin:GetReducedValue(pPlayer.dwID, nFightScore)
	Boss:ZCCallZone("ZSReportBossFightScore", tbPlayerData.nPlayerId, nFightScore, tbPlayerData.nKinId, nKinScore);

	-- pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	pPlayer.CallClientScript("Boss:OnMyMsg", string.format("本次挑战盟主获得[FFFF0E]%d[-]点积分", math.floor(nFightScore)));

	local szBroadcastMsg = string.format("「%s」挑战盟主获得[FFFF0E]%d[-]点积分", pPlayer.szName, math.floor(nFightScore));
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szBroadcastMsg, pPlayer.dwKinId);

	local bBossDie = (nResult == 1);
	local tbFightResult = {
		bBossDie = bBossDie;
		nScore = nFightScore;
	};
	pPlayer.CallClientScript("Boss:OnFightBossResult", tbFightResult);

	pPlayer.TLogRoundFlow(Env.LogWay_Boss, Env.LogWay_CrossBossFight, nFightScore or 0, nCurTime - nFightBeginTime,
		nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, tbPlayerData.nRank or 0, 0);
end

AsyncBattle:ResgiterBattleType("CrossBossFightBattle", Boss, Boss.ZCOnFightBattleResult, nil, Boss.Def.nBossFightMap);
AsyncBattle:ResgiterBattleType("CrossBossFight_Client", Boss, Boss.ZCOnFightBattleResult, nil, Boss.Def.nBossFightMap)

-- /? 
-- local tbTargetInfo = {
-- 	szAsyncData = me.GetBattleAsyncData(),
-- 	szName = me.szName,
-- 	nPortrait = me.nPortrait,
-- };
-- Boss:ZCRobTarget(me.dwID, me.dwID, tbTargetInfo)


function Boss:ZCRobTarget(nPlayerId, nTargetPlayerId, tbTargetInfo)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local bRet, szMsg = Boss:ZCCheckFightState(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local tbTargetsInfo = Boss:ZCGetCacheData("ZRobTarget");
	tbTargetsInfo[nTargetPlayerId] = tbTargetInfo;
	KPlayer.UpdateBossFightAsyncData(nTargetPlayerId, tbTargetInfo.szAsyncData);

	local nCurTime = GetTime();
	local nBattleKey = nCurTime;
	if not AsyncBattle:CreateAsyncBattle(pPlayer, Boss.Def.nRobFightMap, {2190, 1939}, "CrossBossRobBattle", nTargetPlayerId, nBattleKey, {nTargetPlayerId, nCurTime}, true) then
		Log("Error!! Enter CrossBossRobBattle Map Failed!")
		return;
	end

	tbTargetInfo.nProtectRobTime = nCurTime + Boss.Def.nProtectRobCd;
	tbTargetInfo.nProtectRobFullTime = nCurTime + Boss.Def.nProtectRobCd + Boss.Def.nExtraProtectRobCd;
	Boss:ZCCallZone("ZSReportRobProtectInfo", nTargetPlayerId, tbTargetInfo.nProtectRobTime, tbTargetInfo.nProtectRobFullTime);

	local tbPlayerData = Boss:ZCGetPlayerData(nPlayerId);
	tbPlayerData.nNextRobTime = nCurTime + Boss.Def.nRobCd;
	tbPlayerData.nKinId = pPlayer.dwKinId;
	tbPlayerData.tbPartner = Boss:GetPartnerInfo(pPlayer.dwID, Partner.MAX_PARTNER_POS_COUNT);
	Boss:ZCCallZone("ZSReportPlayerDataByKey", nPlayerId, {
		nNextRobTime = tbPlayerData.nNextRobTime,
		nKinId       = tbPlayerData.nKinId,
		tbPartner    = tbPlayerData.tbPartner,
		szAsyncData  = pPlayer.GetBattleAsyncData()
	});

	Achievement:AddCount(pPlayer, "BossRob_1");
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_ZBOSS_ROB, pPlayer.GetFightPower());
end

function Boss:ZCOnRobResult(pPlayer, nResult, tbBattleObj, nTargetPlayerId, nFightBeginTime)
	-- print("ZCOnRobResult", pPlayer, nResult, tbBattleObj, nTargetPlayerId, nFightBeginTime)

	if not Boss:ZCIsCrossOpen() then
		pPlayer.CenterMsg("此轮武林盟主挑战已结束, 本次抢夺得分无效");
		return;
	end

	local tbTargetData = Boss:ZCGetRobTargetInfo(nTargetPlayerId);
	local tbPlayerData = Boss:ZCGetPlayerData(pPlayer.dwID);

	local nRobScore = Boss:CalculateRobScore(tbTargetData.nScore, tbBattleObj.nEnemyBeated, tbBattleObj.bEnemyMainBeated);
	if Forbid:IsBanning(pPlayer,Forbid.BanType.WuLinMengZhu) then                                       -- 功能冻结,自己抢不到分，对方也不扣分
		nRobScore = 0

		local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuLinMengZhu)
		local szTime = Lib:GetTimeStr3(nEndTime)
		pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁时间%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuLinMengZhu), szTime or ""), {{"确定"}, {"取消"}})
	end

	if nResult == 1 then
		tbTargetData.nProtectRobTime = math.max(tbTargetData.nProtectRobFullTime, tbTargetData.nProtectRobTime);
	end
	tbTargetData.nProtectRobFullTime = 0;

	Boss:ZCCallZone("ZSReportRobScore", pPlayer.dwID, nTargetPlayerId, nRobScore);
	Boss:ZCCallZone("ZSReportRobProtectInfo", nTargetPlayerId, tbTargetData.nProtectRobTime, tbTargetData.nProtectRobFullTime);

	local tbTargetShowInfo = {
		szName      = tbTargetData.szName;
		nPlayerId   = tbTargetData.nPlayerId;
		nPortrait   = tbTargetData.nPortrait;
		nFaction    = tbTargetData.nFaction;
		nHonorLevel = tbTargetData.nHonorLevel;
		nLevel      = tbTargetData.nLevel;
	};

	local tbResult = {
		bSuccess = (nResult == 1);
		nRobScore = nRobScore;
		tbEnemyPartners = tbTargetData.tbPartner;
		tbEnemyData = tbTargetShowInfo;
		tbBeated = tbBattleObj.tbBeatedNpc;
		bMainBeated = tbBattleObj.bEnemyMainBeated;
	};

	pPlayer.CallClientScript("Boss:OnRobResult", tbResult);
	pPlayer.TLogRoundFlow(Env.LogWay_Boss, Env.LogWay_CrossBossRob, nRobScore or 0, GetTime() - nFightBeginTime,
		nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, tbPlayerData.nRank or 0, 0);
end

AsyncBattle:ResgiterBattleType("CrossBossRobBattle", Boss, Boss.ZCOnRobResult, nil, Boss.Def.nRobFightMap);

function Boss:ZCCallZone(szType, ...)
	-- print("Boss:ZSOnClientCall", szType, ...)
	CallZoneServerScript("Boss:ZSOnClientCall", szType, ...);
end

function Boss:ZCGetMaxFrame()
	if not Boss:ZCTimeFramOpen() then
		return;
	end
	
	local szMaxFrame = "";
	for _, tbItem in ipairs(Boss.Def.tbBossSetting) do
		if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
			break;
		end
		szMaxFrame = tbItem.TimeFrame;
	end

	Boss:ZCCallZone("ZSReportTimeFrame", szMaxFrame);
	Log("ZCGetMaxFrame", szMaxFrame);
end

function Boss:ZCOnSyncKinRank(tbKinRank)
	local tbKinTopInfo = Boss:ZCGetCacheData("ZKinRank");
	tbKinTopInfo.nVersion = tbKinTopInfo.nVersion or 0;
	tbKinTopInfo.nVersion = tbKinTopInfo.nVersion + 1;
	tbKinTopInfo.tbKinRank = tbKinRank;
end

function Boss:ZCOnSyncPlayerRank(tbPlayerRank)
	local tbPlayerTopRank = Boss:ZCGetCacheData("ZPlayerRank");
	tbPlayerTopRank.nVersion = tbPlayerTopRank.nVersion or 0;
	tbPlayerTopRank.nVersion = tbPlayerTopRank.nVersion + 1;
	tbPlayerTopRank.tbPlayerRank = tbPlayerRank;
end

function Boss:ZCOnSyncPlayersInfo(tbPlayersInfo)
	for _, tbSyncData in ipairs(tbPlayersInfo) do
		local tbPlayerData = Boss:ZCGetPlayerData(tbSyncData.nPlayerId);
		if tbPlayerData then
			tbPlayerData.nScore = tbSyncData.nScore;
			tbPlayerData.nRank = tbSyncData.nRank;
		end
	end
end

function Boss:ZCOnSyncKinsInfo(tbKinsInfo)
	for _, tbSyncData in ipairs(tbKinsInfo) do
		local tbKinInfo = Boss:ZCGetKinInfo(tbSyncData.nKinId);
		if tbKinInfo then
			tbKinInfo.nScore = tbSyncData.nScore;
			tbKinInfo.nRank = tbSyncData.nRank;
		end
	end
end

function Boss:ZCOnPlayerCall(nPlayerId, szFunc, ...)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	pPlayer.CallClientScript(szFunc, ...);
end

function Boss:ZCOnPlayerCenterMsg(nPlayerId, szMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	pPlayer.CenterMsg(szMsg);
end

function Boss:ZCOnBossKinMsg(nKinId, szMsg)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Boss, szMsg, nKinId);
end

function Boss:ZCOnSyncPlayerInfoByKey(nPlayerId, tbData)
	local tbPlayerData = Boss:ZCGetPlayerData(nPlayerId);
	if not tbPlayerData then
		Log("ZCOnSyncPlayerInfoByKey Error", nPlayerId);
		return;
	end

	for szKey, v in pairs(tbData) do
		tbPlayerData[szKey] = v;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	end
end

local tbOnZoneCallType = {
	ZCStart                 = true;
	ZCGetMaxFrame           = true;
	ZCOnSyncKinRank         = true;
	ZCOnSyncPlayerRank      = true;
	ZCOnSyncPlayersInfo     = true;
	ZCOnSyncKinsInfo        = true;
	ZCOnPlayerCall          = true;
	ZCOnSyncPlayerInfoByKey = true;
	ZCOnPlayerCenterMsg     = true;
	ZCOnBossKinMsg          = true;
	ZCRobTarget             = true;
	ZCNotifyFinishBoss      = true;
	ZCFinish                = true;
}

function Boss:ZCOnZoneCall(szType, ...)
	-- print("ZCOnZoneCall", szType, ...);
	if not tbOnZoneCallType[szType] then
		Log("ZCOnZoneCall Error type:", szType);
		return;
	end

	Boss:StateStart(szType);
	Boss[szType](Boss, ...);
	Boss:StateEnd(szType);
end

function Boss:ZCSyncBossInfo(nEndTime, nMyRank, nScore)
	if not nEndTime and Boss:ZCIsCrossOpen() then
		local tbZBossData = Boss:ZCGetBossData();
		me.CallClientScript("Boss:OnSyncBossData", tbZBossData);
	end

	local tbPlayerData = Boss:ZCIsCrossOpen() and Boss:ZCGetPlayerData(me.dwID);
	if tbPlayerData and (tbPlayerData.nRank ~= nMyRank or tbPlayerData.nScore ~= nScore) then
		me.CallClientScript("Boss:OnSyncMyData", tbPlayerData);
	end

	return true;
end

function Boss:ZCSyncKinRank()
	local tbKinTopInfo = Boss:ZCGetCacheData("ZKinRank");
	local tbMyKin = Boss:ZCGetKinInfo(me.dwKinId);
	me.CallClientScript("Boss:OnSyncKinRank", tbKinTopInfo.tbKinRank, tbKinTopInfo.nVersion, tbMyKin);
	return true;
end

function Boss:ZCSyncPlayerRank()
	local tbPlayerTopRank = Boss:ZCGetCacheData("ZPlayerRank");
	me.CallClientScript("Boss:OnSyncPlayerRank", tbPlayerTopRank.tbPlayerRank, tbPlayerTopRank.nVersion);
	return true;
end

function Boss:ZCSyncRobList()
	if not Boss:ZCIsCrossOpen() then
		return false, "挑战未开启";
	end

	Boss:ZCCallZone("ZSAskRobList", me.dwID);
	return true;
end

function Boss:ZCRobPlayer(nTargetUid, nTargetPlayerId, nTargetServerId)
	local bRet, szInfo = Boss:ZCCheckFightState(me);
	if not bRet then
		return false, szInfo;
	end

	local bSameServer = (nTargetServerId == GetServerIdentity());
	if bSameServer and FriendShip:IsFriend(me.dwID, nTargetPlayerId) then
		return false, "这位侠客是您的好友，请不要背後捅刀子哦！";
	end

	local tbTargetData = bSameServer and Boss:ZCGetPlayerData(nTargetPlayerId);
	if tbTargetData and tbTargetData.nKinId == me.dwKinId then
		return false, "这位侠客是您的帮派成员，请不要破坏帮派关系哦！";
	end

	local tbPlayerData = Boss:ZCGetPlayerData(me.dwID);
	if not tbPlayerData then
		Boss:ZCPlayerJoin(me);
		tbPlayerData = Boss:ZCGetPlayerData(me.dwID);
	end

	local nCurTime = GetTime();
	if nCurTime < tbPlayerData.nNextRobTime then
		return false, "抢夺冷却时间未到";
	end

	Boss:ZCCallZone("ZSRobPlayer", me.dwID, nTargetUid);
	return true;
end

local tbZCClientRequstType = {
	ZCSyncBossInfo = true;
	ZCSyncKinRank = true;
	ZCSyncPlayerRank = true;
	ZCSyncRobList = true;
	ZCFightBoss = true;
	ZCRobPlayer = true;
};

function Boss:ZCClientRequest(szType, ...)
	-- print("ZCClientRequest", szType, ...)
	if not Boss:ZCIsJoinCross(me) then
		Boss:SyncBossInfo();
		return;
	end

	if tbZCClientRequstType[szType] then
		Boss:StateStart(szType);
		local bSuccess, szInfo = Boss[szType](Boss, ...);
		Boss:StateEnd(szType);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG Boss ZCClientRequest:", szType, ...);
	end
end


-- /? 
-- Timer:Register(Env.GAME_FPS * 15, function ( ... )
-- 	Boss:StartBossFight();
-- end)

-- Boss:ZCGetCurrentCrossKinInfo().nWeek = nil;
-- Boss:ZCRecordKinScore4ZFight(me.dwKinId, 1);
-- Boss:ZCCallZone("ZSPreStart")