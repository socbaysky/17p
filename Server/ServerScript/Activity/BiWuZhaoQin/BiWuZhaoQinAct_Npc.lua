
local tbAct = Activity:GetClass("NpcBiWuZhaoQin");

tbAct.nZhaoQinCost = 688;		-- 参与招亲消耗元宝
tbAct.nItemTimeout = 90 * 24 * 3600;
tbAct.nMinLevel = 60;

tbAct.tbTypeInfo = {

		--	活动类型	招亲开启NpcId	冠军奖励道具		参与奖			冠军额外奖励
			[1] = 		{2326, 				4789,			4810,			4811};
			[2] = 		{2279, 				4790,			4812,			4813};
}

-- 按照时间轴不同的最低等级限制
tbAct.tbMinLevel = {
	{"OpenLevel69",  60},
	{"OpenLevel89",  70},
	{"OpenLevel99",  80},
	{"OpenLevel109", 90},
	{"OpenLevel119", 100},
}

tbAct.tbTimerTrigger = {}

tbAct.tbTrigger =
{
	Init = {},
	Start = {},
	End = {},
};

tbAct.nMaxIndex = tbAct.nMaxIndex or 0;
tbAct.bFinish = tbAct.bFinish or false;

function tbAct:OnTrigger(szTrigger, nType)
	nType = tonumber(nType or "");
	if szTrigger == "Init" then
		if tbAct.nMaxIndex <= 0 then
			local _, _, nSubServerId = GetServerIdentity();
			tbAct.nMaxIndex = nSubServerId*2^5;
		end

		tbAct.nMaxIndex = tbAct.nMaxIndex + 1;
		for _, tbInfo in pairs(tbAct.tbMinLevel) do
			if GetTimeFrameState(tbInfo[1]) == 1 then
				tbAct.nMinLevel = math.max(tbAct.nMinLevel, tbInfo[2]);
			end
		end

		BiWuZhaoQin:StartS(tbAct.nMaxIndex, 0, true);
		tbAct.tbAllPlayer = {};
		tbAct.bFinish = false;

		Log("[NpcBiWuZhaoQin] Init ", tbAct.nMaxIndex);
	elseif szTrigger == "Start" then
		if not self.tbTypeInfo[nType] then
			Log("[NpcBiWuZhaoQin] ERROR !! self.tbTypeInfo[nType] is nil !!!", type(nType), nType);
			return;
		end

		self.nEntryNpc = self.tbTypeInfo[nType][1];
		self.nNormalAward = self.tbTypeInfo[nType][3];
		self.nWinnerAward = self.tbTypeInfo[nType][4];

		local szName = KNpc.GetNameByTemplateId(self.nEntryNpc);
		KPlayer.SendWorldNotify(0, 999, string.format("[FFFE0D]%s[-]的比武招亲开始报名了，时间[FFFE0D]5分钟[-]，请大家尽快找[FFFE0D]%s[-]报名参加！", szName, szName), 1, 1);

		Activity:RegisterNpcDialog(self, self.nEntryNpc, {Text = "我要参与招亲", Callback = function ()
			if tbAct.bFinish then
				me.CenterMsg("活动已结束！");
				return;
			else
				me.CallClientScript("Ui:OpenWindow", "NpcBiWuZhaoQinUi", self.nEntryNpc);
			end
		end, Param = {}})

		self.nAwardItemId = self.tbTypeInfo[nType][2];
		Activity:RegisterGlobalEvent(self, "Act_OnCompleteZhaoQinS", "OnCompleteZhaoQinS");
		Activity:RegisterGlobalEvent(self, "Act_OnStartFinalS", "OnStartFinalS");
		Activity:RegisterGlobalEvent(self, "Act_OnEndZhaoQinS", "OnEndZhaoQinS");
		Activity:RegisterGlobalEvent(self, "Act_Act_OnStartZhaoQinS", "OnStartZhaoQinS");
		Activity:RegisterPlayerEvent(self, "Act_NpcBiWuZhaoQinClientCall", "OnBiWuZhaoQinClientCall");

		Log("[NpcBiWuZhaoQin] Start ", tbAct.nMaxIndex, nType);
	elseif szTrigger == "End" then
		self.nEntryNpc = nil;
		tbAct.tbAllPlayer = {};
	end
end

function tbAct:OnBiWuZhaoQinClientCall(pPlayer, szCmd, ...)
	if szCmd == "Enter" then
		self:GoToFight(pPlayer);
	elseif szCmd == "Match" then
		self:GoToMatch(pPlayer);
	end
end

function tbAct:SendNormalAward()
	local nWinerId = self.nWinerId or 0;
	for nPlayerId in pairs(tbAct.tbAllPlayer or {}) do
		if nPlayerId ~= nWinerId then
			local szName = KNpc.GetNameByTemplateId(self.nEntryNpc);
			local tbMail = {
					To = nPlayerId;
					Title = "比武招亲奖励";
					From = "系统";
					Text = string.format("侠士成功参与[FFFE0D]%s[-]的比武招亲！这是小小心意，还望侠士笑纳！", szName);
					tbAttach = {{"item", self.nNormalAward, 1}};
					nLogReazon = Env.LogWay_NpcBiWuZhaoQin;
				};
			Mail:SendSystemMail(tbMail);
		end
	end
end

function tbAct:OnCompleteZhaoQinS(tbAllPlayer, nWinerId, nTargetId)
	self.nWinerId = nWinerId;
	self:SendNormalAward();

	tbAct.bFinish = true;
	local pPlayer = KPlayer.GetPlayerObjById(nWinerId);
	if not pPlayer then
		return;
	end

	local tbAward = {
		{"item", self.nAwardItemId, 1, GetTime() + self.nItemTimeout},

	};
	pPlayer.SendAward(tbAward, false, true, Env.LogWay_NpcBiWuZhaoQin);

	local szItemName = KItem.GetItemShowInfo(self.nAwardItemId, pPlayer.nFaction, pPlayer.nSex);
	local szName = KNpc.GetNameByTemplateId(self.nEntryNpc);
	local tbMail = {
			To = nWinerId;
			Title = "比武招亲优胜";
			From = "系统";
			Text = string.format("大侠，恭喜您赢得了[FFFE0D]%s[-]的比武招亲冠军，除附件奖励外，特殊奖励[FFFE0D][url=openwnd:%s, ItemTips,'Item',nil,%d][-]已经发放至侠士背包，可以前往家园，通过使用道具将其邀请至家园中小憩一段时日，可不要错过这个单独相处的机会哦！", szName, szItemName, self.nAwardItemId);
			tbAttach = {{"item", self.nWinnerAward, 1}};
			nLogReazon = Env.LogWay_NpcBiWuZhaoQin;
		};
	Mail:SendSystemMail(tbMail);

	local szMsg = string.format("「%s」参加%s的比武招亲披荆斩棘，过关斩将，获得最终优胜！赢得%s的青睐！小心翼翼地接过%s放在手中的[FFFE0D]<%s>[-]！实是羡煞旁人！", pPlayer.szName, szName, szName, szName, szItemName);
	KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = self.nAwardItemId, nFaction = pPlayer.nFaction, nSex = pPlayer.nSex});
	if pPlayer.dwKinId > 0 then
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = self.nAwardItemId, nFaction = pPlayer.nFaction, nSex = pPlayer.nSex});
	end

	Log("[NpcBiWuZhaoQin] Finish !!", nWinerId, nTargetId);
end

function tbAct:OnStartFinalS()
	local szName = KNpc.GetNameByTemplateId(self.nEntryNpc)
	local szMsg = string.format("[FFFE0D]%s[-]的比武招亲决赛阶段即将开始，侠士可找[FFFE0D]%s[-]进入场地观战！", szName, szName);
	KPlayer.SendWorldNotify(1,1000, szMsg, ChatMgr.ChannelType.Public, 1);
end

function tbAct:OnEndZhaoQinS(tbAllPlayer, nPreMapId, nTargetId)
	tbAct.bFinish = true;
	local szName = KNpc.GetNameByTemplateId(self.nEntryNpc)
	local szMsg = string.format("由於无人参加，[FFFE0D]%s[-]的比武招亲失败了", szName);
	KPlayer.SendWorldNotify(1,1000, szMsg, ChatMgr.ChannelType.Public, 1);

	self:SendNormalAward();
	Log("[NpcBiWuZhaoQin] End !! ", nTargetId);
end

function tbAct:OnStartZhaoQinS()
	local szName = KNpc.GetNameByTemplateId(self.nEntryNpc)
	local szMsg = string.format("[FFFE0D]%s[-]的比武招亲开始报名了，时间[FFFE0D]5分钟[-]，请大家尽快找[FFFE0D]%s[-]报名参加！", szName, szName)
	KPlayer.SendWorldNotify(1,1000, szMsg, ChatMgr.ChannelType.Public, 1, 1);
end

function tbAct:CheckZhaoQinCommon(pPlayer, nIdx, bNotCheckLevel)
	if tbAct.bFinish then
		return false, "招亲已经结束了！";
	end

	if not bNotCheckLevel and pPlayer.nLevel < tbAct.nMinLevel then
		return false, string.format("等级不足%s,无法参加！", tbAct.nMinLevel);
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] then
		return false, "当前地图不可参与，请前往[FFFE0D]襄阳城[-]或[FFFE0D]忘忧岛[-]再尝试";
	end

	local tbActData = BiWuZhaoQin:GetActData(tbAct.nMaxIndex);
	if not tbActData or not tbActData.nPreMapId then
		return false, "本场招亲比赛还没开启！";
	end

	if nIdx and nIdx ~= tbAct.nMaxIndex then
		return false, "指定场次已经结束了！";
	end

	return true;
end

function tbAct:CheckCanGoToFight(pPlayer, nIdx, bNotCheckMoney)
	local bRet, szMsg = self:CheckZhaoQinCommon(pPlayer, nIdx);
	if not bRet then
		return bRet, szMsg;
	end

	bRet, szMsg = BiWuZhaoQin:CheckCanEnter(pPlayer.dwID, nIdx);
	if not bRet then
		return bRet, szMsg;
	end

	if not bNotCheckMoney and pPlayer.GetMoney("Gold") < self.nZhaoQinCost then
		return false, string.format("元宝不足 %s, 无法报名！", self.nZhaoQinCost);
	end

	return true;
end

function tbAct:CheckCanGoToMatch(pPlayer, nIdx)
	local bRet, szMsg = self:CheckZhaoQinCommon(pPlayer, nIdx, true);
	if not bRet then
		return bRet, szMsg;
	end

	bRet, szMsg = BiWuZhaoQin:CheckCanEnter(pPlayer.dwID, nIdx, true);
	if not bRet then
		return bRet, szMsg;
	end

	return true;
end

function tbAct:TryZhaoQin_CoseMoney(nPlayerId, bSuccess, szBillNo, nIdx)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "尊敬的侠士，您在报名过程中掉线！请重新尝试！";
	end

	if not bSuccess then
		return false, "支付失败请稍後再试！";
	end

	local bRet, szMsg = self:CheckCanGoToFight(pPlayer, nIdx, true);
	if not bRet then
		return false, szMsg;
	end

	bRet = BiWuZhaoQin:Enter(pPlayer.dwID, nIdx);
	if not bRet then
		return false, "比武招亲地图的人数已达上限，请稍候再试！";
	end

	tbAct.tbAllPlayer = tbAct.tbAllPlayer or {};
	tbAct.tbAllPlayer[pPlayer.dwID] = true;
	Log("[NpcBiWuZhaoQin] Goto Fight ", pPlayer.szName, pPlayer.szAccount, pPlayer.dwID, nIdx);
	return true;
end

function tbAct:GoToFight(pPlayer)
	local bCanJoin, szMsg = tbAct:CheckCanGoToFight(pPlayer, tbAct.nMaxIndex, tbAct.tbAllPlayer[pPlayer.dwID] and true or false);
	if not bCanJoin then
		pPlayer.CenterMsg(szMsg, true);
		return;
	end

	if tbAct.tbAllPlayer[pPlayer.dwID] then
		local bRet = BiWuZhaoQin:Enter(pPlayer.dwID, tbAct.nMaxIndex);
		if not bRet then
			pPlayer.CenterMsg("比武招亲地图的人数已达上限，请稍候再试！");
		end
		return;
	end

	local function fnCostCallback(nPlayerId, bSuccess, szBillNo, nIdx)
		return tbAct:TryZhaoQin_CoseMoney(nPlayerId, bSuccess, szBillNo, nIdx);
	end

	local bRet = pPlayer.CostGold(tbAct.nZhaoQinCost, Env.LogWay_NpcBiWuZhaoQin, nil, fnCostCallback, tbAct.nMaxIndex);
	if not bRet then
		pPlayer.CenterMsg("支付失败请稍後再试！");
		return;
	end
end

function tbAct:GoToMatch(pPlayer)
	local bRet, szMsg = tbAct:CheckCanGoToMatch(pPlayer, tbAct.nMaxIndex);
	if not bRet then
		pPlayer.CenterMsg(szMsg, true);
		return;
	end

	local bRet = BiWuZhaoQin:Enter(pPlayer.dwID, tbAct.nMaxIndex, true);
	if not bRet then
		pPlayer.CenterMsg("目标地图人数已满！", true);
	end
	Log("[NpcBiWuZhaoQin] Goto Match ", pPlayer.szName, pPlayer.szAccount, pPlayer.dwID, tbAct.nMaxIndex);
end
