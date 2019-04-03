local tbAct = Activity:GetClass("WinterAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

tbAct.tbGatherAnswerAward = {}

local Winter = Activity.Winter

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_GatherFirstJoin", "OnGatherFirstJoin")
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerWrong", "OnGatherAnswerWrong")
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerRight", "OnGatherAnswerRight")
	elseif szTrigger == "End" then
		self:OnWinterEnd()
	end
	Log("WinterAct OnTrigger:", szTrigger)
end

function tbAct:OnWinterEnd()
	local nTangYuanCount = SupplementAward:GetMaxSupplementCount()
	local nNowTime = GetTime()
	local tbMail =
		{
			Title = "真儿的冬至暖信",
			Text = "    哼哼，那个说要扬名武林的大侠，不知冬日过得可好？一别经年，你可变成大忙人啦，佳节也不曾回岛探望，我却总惦记你，委托急如风替我捎去自己做的一碗汤圆，一盘饺子，无论你昨夜食用了何等山珍海味，都要乖乖吃下去！否则我会生气的！好啦，要记得趁热，[FFFE0D]过得今日，便不可食用了[-]。\n    冬日佳节，惟愿君健康安好，平安而至。",
			From = '纳兰真',
			LevelLimit = Winter.nLimitLevel,
			tbAttach = {
			{'item', Winter:GetTangYuanItemId(), nTangYuanCount,nNowTime + Winter.nTangYuanValidTime},
			{'item', Winter:GetJiaoZiItemId(), Winter.nSendJiaoZiCount,nNowTime + Winter.nJiaoZiValidTime},
			},
			nLogReazon = Env.LogWay_WinterAct,
		};

	Mail:SendGlobalSystemMail(tbMail);
	Log("[WinterAct] OnWinterEnd Mail ",nTangYuanCount)
end

function tbAct:OnGatherAnswerWrong(pPlayer)
	EverydayTarget:AddActExtActiveValue(pPlayer, Winter.nGatherAnswerWrongActive, "WinterActGatherAnswerWrong")
	Log("[WinterAct] OnGatherAnswerWrong ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.dwKinId)
end

function tbAct:OnGatherAnswerRight(pPlayer)
	EverydayTarget:AddActExtActiveValue(pPlayer, Winter.nGatherAnswerRightActive, "WinterActGatherAnswerRight")
	Log("[WinterAct] OnGatherAnswerRight ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.dwKinId)
end

function tbAct:OnGatherFirstJoin(pPlayer)
	EverydayTarget:AddActExtActiveValue(pPlayer, Winter.nGatherFirstJoinActive, "WinterActGatherFirstJoin")
	Log("[WinterAct] OnGatherFirstJoin ",pPlayer.dwID,pPlayer.szName,pPlayer.nLevel,pPlayer.dwKinId)
end