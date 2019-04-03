
local tbAct = Activity:GetClass("RechargeCardActExt");

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
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin");
		local szParam1, szParam2 = self.tbParam[1], self.tbParam[2];
		self.nExtWeekAmount = tonumber(szParam1)
		if self.nExtWeekAmount == 0 then
			self.nExtWeekAmount = nil;
		end
		self.nExtMonAmount = tonumber(szParam2)
		if self.nExtMonAmount == 0 then
			self.nExtMonAmount = nil;
		end

		--self:SendNews()
		Recharge:OnCardActStart({self.nExtWeekAmount, self.nExtMonAmount})
		KPlayer.BoardcastScript(1, "Recharge:OnCardActStart", {self.nExtWeekAmount, self.nExtMonAmount})
	elseif szTrigger == "End" then
		self.nExtWeekAmount = nil;
		self.nExtMonAmount = nil;
		Recharge:OnCardActEnd()
		KPlayer.BoardcastScript(1, "Recharge:OnCardActEnd")
	end
end

function tbAct:OnLogin(pPlayer)
	pPlayer.CallClientScript("Recharge:OnCardActStart", {self.nExtWeekAmount, self.nExtMonAmount})
end

function tbAct:SendNews()
	if not self.nExtMonAmount and not self.nExtWeekAmount then
		return
	end

	local nIndex = 0

	local strContent = "[FFFE0D]周末来临，欢庆武林[-]\n     诸位侠士，喜迎周末，武林将开启欢庆活动！\n\n";

	if self.nExtWeekAmount then
		nIndex = nIndex + 1
		strContent = strContent .. string.format("活动%s：\n", Lib:Transfer4LenDigit2CnNum(nIndex)) ;
		strContent = strContent .. string.format("金秋九月，五谷丰登；福利狂欢，元宝为邻；活动期间，福利界面中元宝大礼7日礼包可额外领取[FFFE0D] %d%%元宝[-]\n\n", self.nExtWeekAmount)	
	end

	if self.nExtMonAmount then
		nIndex = nIndex + 1
		strContent = strContent .. string.format("活动%s：\n", Lib:Transfer4LenDigit2CnNum(nIndex)) ;
		strContent = strContent .. string.format("金秋九月，五谷丰登；福利狂欢，元宝为邻；活动期间，福利界面中元宝大礼30日礼包可额外领取[FFFE0D] %d%%元宝[-]\n\n", self.nExtMonAmount)	
	end
	strContent = strContent .. "\n  [url=openwnd:前往储值, CommonShop, 'Recharge', 'Recharge']"

	local _, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("RechargeCardActExt", nEndTime, {strContent}, {szTitle = "周末狂欢", nReqLevel = 1})
end

function tbAct:GetUiData()
	return {self.nExtWeekAmount, self.nExtMonAmount}
end