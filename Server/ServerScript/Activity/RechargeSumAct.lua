
local tbAct = Activity:GetClass("RechargeSumAct");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		local tbFile = LoadTabFile(self.tbParam[1], "dss", nil, {"nMoney", "AwardList", "NameList"});
		local tbAllAward = {};
		for i,v in ipairs(tbFile) do
			table.insert(tbAllAward, { nMoney = v.nMoney, tbAward = Lib:GetAwardFromString(v.AwardList), tbItemName = Lib:SplitStr(v.NameList, "|") })
		end
		self.tbAllAward = tbAllAward;

		Activity:RegisterPlayerEvent(self, "OnRecharge", "OnRecharge");
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin");
		local nStartTime = self:GetOpenTimeInfo()
		Recharge:OnSumActStart(nStartTime)
		KPlayer.BoardcastScript(1, "Recharge:OnSumActStart", nStartTime)
	elseif szTrigger == "End" then
		Recharge:OnSumActEnd()
		KPlayer.BoardcastScript(1, "Recharge:OnSumActEnd")
	end
end

function tbAct:OnLogin(pPlayer)
	local nStartTime = self:GetOpenTimeInfo()
	pPlayer.CallClientScript("Recharge:OnSumActStart", nStartTime)
end

function tbAct:OnRecharge(pPlayer, nGoldRMB, nCardRMB , nRechargeGold)
	local nStartTime = self:GetOpenTimeInfo()
	local nLastRestTime = Recharge:GetActRechageSumTime(pPlayer) --pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME)
	if nLastRestTime < nStartTime then
		if nLastRestTime ~= 0 then
			Log("RechargeSumAct Reset", pPlayer.dwID, nLastRestTime, Recharge:GetActRechageSumVal(pPlayer)) --.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM)
		end
		Recharge:SetActRechageSumVal(pPlayer, 0)
		Recharge:SetActRechageSumTake(pPlayer, 0)
		Recharge:SetActRechageSumTime(pPlayer, nStartTime)
	end

	local nSumRecharge = Recharge:GetActRechageSumVal(pPlayer) + nRechargeGold
	Recharge:SetActRechageSumVal(pPlayer, nSumRecharge)

	local nTakeVal = Recharge:GetActRechageSumTake(pPlayer)
	local tbBit = KLib.GetBitTB(nTakeVal)
	for i,v in ipairs(self.tbAllAward) do
		if nSumRecharge >= v.nMoney then
			if tbBit[i] == 0 then
				tbBit[i] = 1;
				nTakeVal = KLib.SetBit(nTakeVal, i, 1)
				Recharge:SetActRechageSumTake(pPlayer, nTakeVal)

				Mail:SendSystemMail({
					To = pPlayer.dwID,
					Title = "活动奖励",
					Text = string.format("      尊敬的侠士！恭喜您在累计储值活动中达成要求，获得活动奖励", i),
					tbAttach = v.tbAward,
					nLogReazon = Env.LogWay_RechargeSumAct,
					});
			end
		else
			break;
		end
	end
end

function tbAct:GetUiData()
	if not self.tbUiData then
		local tbUiData = {}
		self.tbUiData = tbUiData
		tbUiData.nShowLevel = 1;
		tbUiData.szTitle = "累计储值活动";
		local nStartTime, nEndTime = self:GetOpenTimeInfo()
		local tbTime1 = os.date("*t", nStartTime)
		local tbTime2 = os.date("*t", nEndTime)
		--文字如果前面要空格不要用tab
		tbUiData.szContent = string.format([[活动时间：[c8ff00]%d年%d月%d日0点-%d月%d日24点[-]
活动内容：
尊敬的侠士，活动期间累计储值达到[FFFF00]指定元宝数（有且仅有储值金额直接兑换的元宝计算入内，系统赠送的元宝不计入累计储值金额）[-]，即可获得额外奖励，活动在[FFFF00]凌晨24点[-]结束，千万不要错过哦！
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day);
		tbUiData.szBtnText = "前去储值"
		tbUiData.szBtnTrap = "[url=openwnd:test, CommonShop, 'Recharge', 'Recharge']";

		local tbSubInfo = {}
		for i,v in ipairs(self.tbAllAward) do
			table.insert(tbSubInfo, 
				{ szType = "Item3", szSub = "Recharge", nParam = v.nMoney, tbItemList = v.tbAward, tbItemName = v.tbItemName}
			)
		end
		tbUiData.tbSubInfo = tbSubInfo
	end
	return self.tbUiData;	
end
