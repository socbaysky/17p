
local tbAct = Activity:GetClass("RechargeCardAct");

tbAct.tbTimerTrigger = { }
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, }


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin");
		self.nCardActExtAmount = tonumber(self.tbParam[1])
		if self.nCardActExtAmount == 0 then
			self.nCardActExtAmount = nil;
		end
		
		Recharge:OnCardActStart(self.nCardActExtAmount, self.tbParam[2]) -- 周年庆
		KPlayer.BoardcastScript(1, "Recharge:OnCardActStart", self.nCardActExtAmount,self.tbParam[2])
	elseif szTrigger == "End" then
		self.nCardActExtAmount = nil;
		Recharge:OnCardActEnd()
		KPlayer.BoardcastScript(1, "Recharge:OnCardActEnd")
	end
end

function tbAct:OnLogin(pPlayer)
	pPlayer.CallClientScript("Recharge:OnCardActStart", self.nCardActExtAmount,self.tbParam[2])
end
