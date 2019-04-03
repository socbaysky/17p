Require("ServerScript/Kin/KinData.lua");

local _KinData   = Kin._MetaKinData;
Kin.Gather = Kin.Gather or {};

local Gather = Kin.Gather;

function Kin:GatherSetEnable(bEnabled)
	self.Gather.bDisabled = not bEnabled
end

-- 分帧遍历..
function Kin:PrepareKinGatherActivity()
	Kin:TraverseKinInDiffTime(1, function (kinData)
		Gather:SendNotify(kinData);
	end);
end

function Kin:StartKinGatherActivity()
	Kin:TraverseKinInDiffTime(1, function (kinData)
		Gather:Open(kinData.nKinId);
	end);
	Gather:AutoSendRedBag()
	SupplementAward:OnActivityOpen("KinFire")
	Calendar:OnActivityBegin("KinGather");
	Activity:OnGlobalEvent("Act_KinGather_Open")
end

function Kin:StopKinGatherActivity()
	Kin:TraverseKinInDiffTime(1, function (kinData)
		Gather:Finish(kinData.nKinId);
	end);
	Calendar:OnActivityEnd("KinGather");
	Activity:OnGlobalEvent("Act_KinGather_Close")
end

function Gather:Open(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	local tbGatherData = kinData:GetGatherData();

	tbGatherData.tbDrinkMember = {}; -- 请喝酒人数
	tbGatherData.tbQuizIndex = Kin:GetGatherQuizIndex();
	tbGatherData.tbQuestions = {};
	tbGatherData.nCurQuestionIdx = 1;
	tbGatherData.bQuestion = true;
	tbGatherData.bDiceOpen = nil;
	tbGatherData.nQuotiety = 100;
	tbGatherData.nOpenTime = GetTime()

	Timer:Register(Env.GAME_FPS * Kin.GatherDef.FirstQuestionTime, Gather.KinQuestionActive, Gather, nKinId);

	Activity:OnGlobalEvent("Act_OnKinGatherJoin", nKinId)

	local szMsg = "<请大夥喝酒>帮派总管：老夫这有一批上等好酒，喝酒後全体成员可以获得篝火经验加成。";
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, kinData.nKinId, { nLinkType = ChatMgr.LinkType.KinDrink });

	kinData:CallWithMap(function ()
		local nMapId = kinData:GetMapId();
		SetMapSurvivalTime(nMapId, GetTime() + Kin.GatherDef.ActivityTime);
		local pFireNpc = KNpc.Add(Kin.GatherDef.FireNpcTemplateId, 1, 0, nMapId, Kin.GatherDef.FireNpcPosX, Kin.GatherDef.FireNpcPosY);
		pFireNpc.tbTmp.nKey = nKinId;
		pFireNpc.tbTmp.bKinGather = true;
		tbGatherData.nFireNpcId = pFireNpc.nId;
		self:OpenKinMemberFireUi(nKinId)
	end);

	--开启实时语音
	if ChatMgr:IsKinHaveChatRoom(nKinId) then
		self:MemberJoinKinChatRoom(nKinId)
	else
		ChatMgr:CreateKinChatRoom(nKinId)
	end

	self:TraverseInKinMap(nKinId, function (pPlayer) AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinKinFire, 1, 0, 1) end)
end

function Gather:AutoSendRedBag()
	Kin:RedBagAutoSendPrepare()
	Timer:Register(Env.GAME_FPS * Kin.GatherDef.AutoSendRedBagTime, Gather.SendRedBagActive, Gather)
end

function Gather:SendRedBagActive()
	local bSent = Kin:RedBagAutoSend()
	if bSent then
		Timer:Register(Env.GAME_FPS * Kin.GatherDef.AutoSendRedBagInterval, Gather.SendRedBagActive, Gather)
	end
	return false
end

function Gather:KinQuestionActive(nKinId)
	if self.bDisabled then
		return false
	end
	if Kin.MonsterNian:IsEnabled() then
		return false
	end
	local kinData = Kin:GetKinById(nKinId);
	local tbGatherData = kinData:GetGatherData();
	if not next(tbGatherData) then
		return false;
	end

	if tbGatherData.bQuestion then
		local nQuizIndex = tbGatherData.tbQuizIndex[tbGatherData.nCurQuestionIdx];
		if not nQuizIndex then
			Gather:BeginDice(nKinId);
			self:UpdateGatherData(nKinId, { [Kin.GatherDef.QuestionOver] = true })
			return false;
		end

		local tbQuestion = Kin:GetGatherQuizByIndex(tbGatherData.tbQuizIndex, tbGatherData.nCurQuestionIdx, kinData);
		tbQuestion.nIndex = tbGatherData.nCurQuestionIdx;
		tbQuestion.nTimeOut = GetTime() + Kin.GatherDef.QuestionAnwserTime;
		tbGatherData.tbQuestions[tbGatherData.nCurQuestionIdx] = tbQuestion;

		if tbGatherData.nCurQuestionIdx == 1 then
			local szInfo = "帮派总管：藉此酒意由老夫予诸位出题助兴，还请诸位踊跃参与！";
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szInfo, nKinId);
		end
		
		Activity:OnGlobalEvent("Act_KinGather_Question",nKinId,tbGatherData)

		local szMsg = string.format("<开始答题>第%d题：%s", tbGatherData.nCurQuestionIdx, tbQuestion.szQuiz);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId, { nLinkType = ChatMgr.LinkType.KinQuestion, tbQuestionData = tbQuestion });
		self:UpdateGatherData(nKinId, { [Kin.GatherDef.CurQuestionIdx] = tbGatherData.nCurQuestionIdx, [Kin.GatherDef.QuestionOver] = false, [Kin.GatherDef.QuestionData] = tbQuestion })

		Timer:Register(Env.GAME_FPS * Kin.GatherDef.QuestionAnwserTime, Gather.KinQuestionActive, Gather, nKinId);

	else
		local tbWords = {"A", "B", "C", "D"};
		local tbQuestion = tbGatherData.tbQuestions[tbGatherData.nCurQuestionIdx];
		local szAnswer = string.format("第%d题的正确答案为【%s：%s】",
						tbGatherData.nCurQuestionIdx,
						tbWords[tbQuestion.nAnswer],
						tbQuestion.tbOption[tbQuestion.nAnswer] or "?");
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szAnswer, nKinId);
		Timer:Register(Env.GAME_FPS * Kin.GatherDef.NextQuestionTime, Gather.KinQuestionActive, Gather, nKinId);
		tbGatherData.nCurQuestionIdx = tbGatherData.nCurQuestionIdx + 1;
	end

	tbGatherData.bQuestion = not tbGatherData.bQuestion;
	return false;
end

function Gather:BeginDice(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	local tbGatherData = kinData:GetGatherData();
	tbGatherData.bDiceOpen = true;

	local nTimeOut = GetTime() + Kin.GatherDef.DiceTimeOut;
	kinData:TraverseMembers(function (memberData)
		local tbQuizData = memberData:GetQuizData();
		if tbQuizData.nRightCount >= Kin.GatherDef.DiceOpenAnswerCount then
			local player = KPlayer.GetPlayerObjById(memberData.nMemberId);
			if player then
				player.CallClientScript("Kin:BeginDice", nTimeOut);
			end
		end
		return true;
	end);

	Timer:Register(Env.GAME_FPS * Kin.GatherDef.DicePriceTime, Gather.DicePrice, Gather, nKinId);

	local szMsg = string.format("帮派总管：恭喜答对%d题以上的少侠获得抛骰子的机会，最终以点数排名发放奖励！", Kin.GatherDef.DiceOpenAnswerCount);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
end

local function SortDiceList(a, b)
	if a.nScore == b.nScore then
		return a.nTime < b.nTime;
	else
		return a.nScore > b.nScore;
	end
end

function Gather:DicePrice(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	local tbGatherData = kinData:GetGatherData();
	tbGatherData.bDiceOpen = nil;

	local tbList = {};
	local nJoinCount = 0;
	kinData:TraverseMembers(function (memberData)
		local tbQuizData = memberData:GetQuizData();
		if tbQuizData.bAnswered then
			nJoinCount = nJoinCount + 1;
		end

		if tbQuizData.nDiceScore then
			table.insert(tbList, {
				nPlayerId = memberData.nMemberId;
				nScore = tbQuizData.nDiceScore;
				nTime = tbQuizData.nDiceTime;
				szName = memberData:GetName();
			});
		end
		return true;
	end);

	local _, nExtraDiceRate = Kin:GatherGetExtraRewardRate();
	local nPricePercent = Kin.GatherDef.DicePricePercent + nExtraDiceRate;
	local nPriceCount = math.max(math.floor(nJoinCount * nPricePercent + 0.5), 1);
	table.sort(tbList, SortDiceList);

	local tbGatherWinNames = {};
	local szPriceMsg = "帮派总管：恭喜以下少侠获得骰子排名奖励！"
	for i = 1, nPriceCount do
		local tbItem = tbList[i];
		if tbItem then
			szPriceMsg = string.format("%s\n「%s」\t 骰子%d点", szPriceMsg, tbItem.szName, tbItem.nScore);
			Kin.GatherDef.DicePriceMail.To = tbItem.nPlayerId;
			Mail:SendSystemMail(Kin.GatherDef.DicePriceMail);
			table.insert(tbGatherWinNames, tbItem.szName);
		end
	end
	kinData:SetGatherWinNames(tbGatherWinNames);

	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szPriceMsg, nKinId);
end

function Gather:Finish(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	local tbGatherData = kinData:GetGatherData();
	local pFireNpc = KNpc.GetById(tbGatherData.nFireNpcId or 0);

	if pFireNpc then
		pFireNpc.Delete();
	else
		Log("Gather:Finish:ERROR: lost fire npc", kinData.szName, nKinId);
	end

	local nToday = Lib:GetLocalDay();
	local nJoinMembers = 0;
	kinData:TraverseMembers(function (memberData)
		local tbMemberCacheData = memberData:GetMemberCacheData();
		if nToday == tbMemberCacheData.nKinGatherRewardDay then
			nJoinMembers = nJoinMembers + 1;
		end
		return true;
	end);

	local nPrestige = 0;
	if nJoinMembers > 0 then
		nPrestige = Kin.GatherDef.KinPrestigeReward[math.floor((nJoinMembers+4)/5)] or Kin.GatherDef.KinMaxPrestigeReward;
	end

	kinData:AddPrestige(nPrestige, Env.LogWay_KinGather);
	Log("Gather:Finish:AddPerstige", kinData.szName, nKinId, nPrestige);

	kinData:ResetGatherData();

	self:MemberLeaveKinChatRoom(nKinId)

	Activity:OnGlobalEvent("Act_OnKinGatherFinish", nKinId)
end

-- 家族聚集参与奖励...
function Gather:AddJoinReward(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return ;
	end

	if pPlayer.dwKinId == 0 then
		return;
	end

	local memberData = Kin:GetMemberData(nPlayerId);
	if not memberData then
		return
	end
	local tbMemberCacheData = memberData:GetMemberCacheData();
	local nToday = Lib:GetLocalDay();
	if tbMemberCacheData.nKinGatherRewardDay == nToday then
		return;
	end

	SupplementAward:OnJoinActivity(pPlayer, "KinFire");
	EverydayTarget:AddCount(pPlayer, "KinGather", 1);
	Achievement:AddCount(pPlayer, "Family_5");
	TeacherStudent:CustomTargetAddCount(pPlayer, "KinGather", 1)

	tbMemberCacheData.nKinGatherRewardDay = nToday;
	pPlayer.AddMoney("Contrib", Kin.GatherDef.GatherJoinContribution, Env.LogWay_KinGatherAward);
	Activity:OnPlayerEvent(pPlayer, "Act_GatherFirstJoin")
	pPlayer.TLogRoundFlow(Env.LogWay_KinGather, pPlayer.dwKinId, 0, 0, Env.LogRound_SUCCESS, 0, 0);
	pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinGather, 0, 0)
end

function Gather:SendNotify(kinData)
	local tbMsgData = {
		szType = "KinGather";
		nTimeOut = GetTime() + Kin.GatherDef.PrepareTime + Kin.GatherDef.ActivityTime;
	};

	kinData:TraverseMembers(function (memberData)
		local player = KPlayer.GetPlayerObjById(memberData.nMemberId);
		if player and memberData.nCareer ~= Kin.Def.Career_Retire then
			player.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
		end
		return true;
	end);

	local szMsg = "帮派烤火活动将在3分钟後开始，请各位成员前往帮派属地参加活动！";
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, kinData.nKinId);
end

function Gather:_DoDrink()
	if me.dwKinId == 0 then
		return false, "无帮派";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "你不是此帮派成员"
	end
	if memberData:IsRetire() then
		return false, "退隐成员不参加该活动";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local nKinMapId = kinData:GetMapId();

	if me.nMapId ~= nKinMapId then
		return false, "请到帮派属地参与烤火活动";
	end

	local tbGatherData = kinData:GetGatherData();
	if not next(tbGatherData) then
		return false, "烤火活动已结束";
	end

	if tbGatherData.tbDrinkMember[me.dwID] then
		return false, "你已经请大家喝过酒了！";
	end

	if Lib:CountTB(tbGatherData.tbDrinkMember)>=Kin.GatherDef.DrinkMaxCount then
        return false, "喝酒人数已达上限"
    end

	local nGold = me.GetMoney("Gold");
	if nGold < Kin.GatherDef.DrinkCost then
		local fnGotoCharge = function ()
			me.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge")
		end
		me.MsgBox("元宝不足, 是否前去储值介面?", {{"确定", fnGotoCharge}, {"取消"}});
		return false, "元宝不足";
	end

	local pFireNpc = KNpc.GetById(tbGatherData.nFireNpcId);
	if not pFireNpc then
		return false, "篝火哪里去了...";
	end

	local nCurFireAddExp = pFireNpc.tbTmp.nExtraKinAddRate or 0;
	if nCurFireAddExp + pFireNpc.tbTmp.nQuotiety >= Kin.GatherDef.MaxExtraExpBuff then
		self:UpdateGatherData(me.dwKinId, { [Kin.GatherDef.Quotiety] = Kin.GatherDef.MaxExtraExpBuff })
		return false, "已达到最大喝酒上限";
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	me.CostGold(Kin.GatherDef.DrinkCost, Env.LogWay_GatherDrink, nil, function (nPlayerId, bSuccess, szBillNo, kinData)
		if not bSuccess then
			return false;
		end

		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false, "喝酒支付过程中您下线了";
		end

		local tbGatherData = kinData:GetGatherData();
		if not next(tbGatherData) then
			return false, "帮派聚集活动结束了";
		end

		if tbGatherData.tbDrinkMember[nPlayerId] then
			return false, "你已经请大家喝过酒了！";
		end

		if Lib:CountTB(tbGatherData.tbDrinkMember)>=Kin.GatherDef.DrinkMaxCount then
	        return false, "喝酒人数已达上限"
	    end

		local pFireNpc = KNpc.GetById(tbGatherData.nFireNpcId);
		if not pFireNpc then
			return false, "篝火不见了";
		end

		local nCurFireAddExp = pFireNpc.tbTmp.nExtraKinAddRate or 0;
		if nCurFireAddExp + pFireNpc.tbTmp.nQuotiety >= Kin.GatherDef.MaxExtraExpBuff then
			self:UpdateGatherData(pPlayer.dwKinId, { [Kin.GatherDef.Quotiety] = Kin.GatherDef.MaxExtraExpBuff })
			return false, "已达到最大喝酒上限";
		end

		tbGatherData.tbDrinkMember[pPlayer.dwID] = true;
		pFireNpc.tbTmp.nQuotiety = pFireNpc.tbTmp.nQuotiety + Kin.GatherDef.DrinkExpBuff;
		tbGatherData.nQuotiety   = pFireNpc.tbTmp.nQuotiety
		self:UpdateGatherData(pPlayer.dwKinId, { [Kin.GatherDef.Quotiety] = pFireNpc.tbTmp.nQuotiety + nCurFireAddExp })

		local szMsg = string.format("「%s」请大夥喝酒，篝火经验加成增加了5%%！", pPlayer.szName);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, kinData.nKinId);
		pPlayer.SendAward(Kin.GatherDef.DrinkReward, true, false, Env.LogWay_GatherDrink);
		pPlayer.CallClientScript("Kin:AfterDrink")
		Activity:OnPlayerEvent(pPlayer, "Act_KinGatherDrink")
		pPlayer.TLog("KinMemberFlow", pPlayer.dwKinId, Env.LogWay_KinGatherDrink, tbGatherData.nQuotiety, 0)
		return true;
	end, kinData);
	return true;
end

function Gather:Drink()
	if me.dwKinId == 0 then
		return false, "无帮派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local tbGatherData = kinData:GetGatherData();
	if not next(tbGatherData) then
		return false, "帮派聚集活动结束了";
	end

	if tbGatherData.tbDrinkMember[me.dwID] then
		local tbAct = Activity:GetClass("ZhongQiuJie")
		if Activity:IsRunning("ZhongQiuJie") and me.nLevel>=tbAct.nJoinLevel then
			Activity:OnPlayerEvent(me, "Act_KinGatherDrunk")
			return true
		end
		return false, "你已经请大家喝过酒了！"
	end

    if Lib:CountTB(tbGatherData.tbDrinkMember)>=Kin.GatherDef.DrinkMaxCount then
        return false, "喝酒人数已达上限"
    end

	local function fnConfirm()
		local bOk, szErr = self:_DoDrink()
		if not bok and szErr then
			me.CenterMsg(szErr)
		end
	end
	local tbAward = Lib:GetAwardDesCount2(Kin.GatherDef.DrinkReward, me)
	local szMsg = string.format("少侠确定要花费 [FFFE0D]60元宝[-] 请大夥喝酒吗？\n喝酒後可以获得[FFFE0D]%s[-]，篝火经验加成增加[FFFE0D]5%%%%[-]", tbAward[1])
	me.MsgBox(szMsg, {{"同意", fnConfirm}, {"取消"}})
	return true
end

function Gather:Answer(nQuizIndex, nAnswer)
	if me.dwKinId == 0 then
		return false, "无帮派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local nKinMapId = kinData:GetMapId();

	if me.nMapId ~= nKinMapId then
		return false, "请到帮派属地参与烤火活动";
	end

	local tbGatherData = kinData:GetGatherData();
	if not next(tbGatherData) then
		return false, "烤火活动已结束";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "你不是此帮派成员"
	end
	if memberData:IsRetire() then
		return false, "退隐成员不参加该活动";
	end

	if nQuizIndex ~= tbGatherData.nCurQuestionIdx then
		return false, "该答题时间已结束";
	end

	local tbQuizData = memberData:GetQuizData();
	tbQuizData.bAnswered = true;
	if tbQuizData.tbAnswered[nQuizIndex] then
		return false, "你已经回答过该题了"
	end

	local nRewardAdditionRate = 0;
	local _, nCurKinMapPlayerCount = KPlayer.GetMapPlayer(me.nMapId);
	if nCurKinMapPlayerCount and nCurKinMapPlayerCount >= 10 then
		nRewardAdditionRate = memberData:GetRewardAdditionRate();
	end

	local nExtraAnwserRate = Kin:GatherGetExtraRewardRate();
	nRewardAdditionRate = nRewardAdditionRate + nExtraAnwserRate;
	tbQuizData.tbAnswered[nQuizIndex] = true;

	local tbCurQuiz = tbGatherData.tbQuestions[nQuizIndex];
	if tbCurQuiz.nAnswer ~= nAnswer then
		local tbAnswerRewardWrong = {
			{"Contrib", Kin.GatherDef.AnswerWrongRewardContrib * (1 + nRewardAdditionRate)},
		};
		local _1, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(me, "KinGather", tbAnswerRewardWrong)
		me.SendAward(tbFinalAward, nil, true, Env.LogWay_GatherAnswer);
		if szMsg then
			me.CenterMsg(szMsg, true)
		end
		Activity:OnPlayerEvent(me, "Act_GatherAnswerWrong");
		return false, "答案将在稍後公布，请留意帮派频道！";
	end

	tbQuizData.nRightCount = tbQuizData.nRightCount + 1;

	local tbAnswerRightReward = {
		{"Contrib", Kin.GatherDef.AnswerRightRewardContrib * (1 + nRewardAdditionRate)},
		Kin.GatherDef.AnswerRightRewardItem,
	};
	local _1, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(me, "KinGather", tbAnswerRightReward)
	me.SendAward(tbFinalAward, nil, true, Env.LogWay_GatherAnswerRight);
	if szMsg then
		me.CenterMsg(szMsg, true)
	end
	Activity:OnPlayerEvent(me, "Act_GatherAnswerRight");
	me.CallClientScript("Kin:OnSyncGatherAnswerRightCount", tbQuizData.nRightCount);
	return true;
end

function Gather:DiceShake()
	if me.dwKinId == 0 then
		return false, "无帮派";
	end

	local kinData = Kin:GetKinById(me.dwKinId);
	local tbGatherData = kinData:GetGatherData();
	if not next(tbGatherData) then
		return false, "烤火活动已结束";
	end

	local memberData = Kin:GetMemberData(me.dwID);
	if not memberData then
		return false, "你不是此帮派成员"
	end
	if memberData:IsRetire() then
		return false, "退隐成员不参加该活动";
	end

	if not tbGatherData.bDiceOpen then
		return false, "对不起你来晚了..";
	end

	local nAllScore = 0;
	local tbScore = {};
	for i = 1, 3 do
		local nScore = MathRandom(6);
		nAllScore = nAllScore + nScore;
		table.insert(tbScore, nScore);
	end

	local tbQuizData = memberData:GetQuizData();
	tbQuizData.nDiceScore = nAllScore;
	tbQuizData.nDiceTime = GetTime();

	local szMsg = string.format("我投抛了%s%s%s（共%d点）",
					ChatMgr.DiceEmtionMap[tbScore[1]],
					ChatMgr.DiceEmtionMap[tbScore[2]],
					ChatMgr.DiceEmtionMap[tbScore[3]],
					nAllScore);

	ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Kin, me.dwID, me.szName, me.nFaction, me.nPortrait, me.nSex, me.nLevel, szMsg)
	me.CallClientScript("Kin:OnSyncGatherDice", tbScore);
	return true;
end

function Gather:IsActivityLive(nKinId)
	local kinData = Kin:GetKinById(nKinId)
	if not kinData then
		return false
	end

	local tbGatherData = kinData:GetGatherData()
	if not tbGatherData or not next(tbGatherData) then
		return false
	end
	return true
end

function Gather:GetMapPlayerCount(nKinId)
	local kinData         = Kin:GetKinById(nKinId)
	local nKinMapId       = kinData:GetMapId()
	if not nKinMapId then
		return 0
	end

	local _, nMemberCount = KPlayer.GetMapPlayer(nKinMapId)
	return nMemberCount
end

function Gather:GetFireData(nKinId)
	if not self:IsActivityLive(nKinId) then
		return
	end

	local kinData      = Kin:GetKinById(nKinId)
	local tbGatherData = kinData:GetGatherData()
	local nMemberCount = self:GetMapPlayerCount(nKinId)
	local nLastTime    = Kin.GatherDef.ActivityTime - GetTime() + tbGatherData.nOpenTime

	local nQuizIndex = math.min(Kin.GatherDef.QuizCount, tbGatherData.nCurQuestionIdx)
	local tbData = {
		[Kin.GatherDef.CurQuestionIdx] = tbGatherData.nCurQuestionIdx,
		[Kin.GatherDef.MemberNum]      = nMemberCount,
		[Kin.GatherDef.Quotiety]       = tbGatherData.nQuotiety,
		[Kin.GatherDef.LastTime]       = nLastTime,
		[Kin.GatherDef.QuestionData]   = tbGatherData.tbQuestions[nQuizIndex],
		[Kin.GatherDef.QuestionOver]   = tbGatherData.bDiceOpen,
	}

	return tbData
end

function Gather:OnLogin(pPlayer)
	if pPlayer.nMapTemplateId ~= Kin.Def.nKinMapTemplateId then
		return
	end

	self:OnPlayerEnterKin(pPlayer.dwKinId)
end

function Gather:OnPlayerEnterKin(nKinId)
	if not self:IsActivityLive(nKinId) then
		return
	end

	local tbFireData   = self:GetFireData(nKinId)
	local kinData      = Kin:GetKinById(nKinId)
	local tbGatherData = kinData:GetGatherData()
	tbFireData[Kin.GatherDef.DrinkFlag] = tbGatherData.tbDrinkMember[me.dwID]
	me.CallClientScript("Kin:OpenKinFireUi", tbFireData)

	local memberData = Kin:GetMemberData(me.dwID);
	if memberData then
		local tbQuizData = memberData:GetQuizData() or {};
		me.CallClientScript("Kin:OnSyncGatherAnswerRightCount", tbQuizData.nRightCount);
	end

	self:UpdateGatherData(nKinId, { [Kin.GatherDef.MemberNum] = tbFireData[Kin.GatherDef.MemberNum], [Kin.GatherDef.LastTime] = tbFireData[Kin.GatherDef.LastTime] })

	--加入实时语音
	Kin:JoinChatRoom(me);

	AssistClient:ReportQQScore(me, Env.QQReport_IsJoinKinFire, 1, 0, 1)
end


function Gather:OnPlayerLeaveKin(nKinId)
	if not nKinId or not self:IsActivityLive(nKinId) then
		return
	end

	local nMemberCount = self:GetMapPlayerCount(nKinId)
	self:UpdateGatherData(nKinId, { [Kin.GatherDef.MemberNum] = nMemberCount })

	ChatMgr:LeaveKinChatRoom(me);
end

function Gather:UpdateGatherData(nKinId, tbData)
	local function fnSync(pPlayer)
		pPlayer.CallClientScript("Kin:OnSyncGatherOtherData", tbData)
	end
	self:TraverseInKinMap(nKinId, fnSync)
end

function Gather:OpenKinMemberFireUi(nKinId)
    local kinData = Kin:GetKinById(nKinId)
    if not kinData then
        return;
    end
    local nMapId = kinData:GetMapId();
    if not nMapId then
        return;
    end

    if not IsLoadFinishMap(nMapId) then
        return
    end

	local tbFireData = self:GetFireData(nKinId)
	local function fnOpen(pPlayer)
		pPlayer.CallClientScript("Kin:OpenKinFireUi", tbFireData)
	end
	self:TraverseInKinMap(nKinId, fnOpen)
end

function Gather:CloseKinMemberFireUi(nKinId)
	local function fnClose(pPlayer)
		pPlayer.CallClientScript("Ui:CloseWindow", "KinFireDisplay")
	end
	self:TraverseInKinMap(nKinId, fnClose)
end

function Gather:TraverseInKinMap(nKinId, fnCall, ...)
	local tbMember  = Kin:GetKinMembers(nKinId)
	local kinData   = Kin:GetKinById(nKinId)
	local nKinMapId = kinData:GetMapId()
	for nPlayerId, _ in pairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer and pPlayer.nMapId == nKinMapId then
			fnCall(pPlayer, ...)
		end
	end
end

function Gather:MemberJoinKinChatRoom(nKinId)
	local function fnJoin(pPlayer)
		Kin:JoinChatRoom(pPlayer)
	end
	self:TraverseInKinMap(nKinId, fnJoin)
end

function Gather:MemberLeaveKinChatRoom(nKinId)
	local function fnLeave(pPlayer)
		ChatMgr:LeaveKinChatRoom(pPlayer);
	end
	self:TraverseInKinMap(nKinId, fnLeave)
end

function Gather:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
	if not self:IsActivityLive(dwKinId) then
		return false;
	end

	self:MemberJoinKinChatRoom(dwKinId);

	return true;
end


local tbGatherInterface = {
	Drink     = true;
	Answer    = true;
	DiceShake = true;
}

function Kin:GatherClientRequest(szRequestType, ...)
	Log("Kin:GatherClientRequest", szRequestType, ...)
	if tbGatherInterface[szRequestType] then
		local bSuccess, szInfo = Gather[szRequestType](Gather, ...);
		if not bSuccess and szInfo then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG Gather Request:", szRequestType, ...);
	end
end
