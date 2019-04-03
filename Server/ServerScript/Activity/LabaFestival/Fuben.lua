local tbAct = Activity:GetClass("LabaFuben")
tbAct.tbTimerTrigger = {
	{szType = "Day", Time = "19:30" , Trigger = "StartFuben"},  
	{szType = "Day", Time = "23:30" , Trigger = "EndFuben"},  
}
tbAct.tbTrigger = {
	Init={},
	Start={{"StartTimerTrigger", 1},{"StartTimerTrigger", 2}},
	End={},
	StartFuben = {},
	EndFuben = {},
}

tbAct.tbSettings = {
	nNestNpcNum = 100,
	nNestNpcLevel = 50,
}

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		--self:OnStart()
	elseif szTrigger == "End" then
		--self:OnEnd()
	elseif szTrigger == "StartFuben" then
		self:OnStart()
	elseif szTrigger == "EndFuben" then
		self:OnEnd()
	end
	Log("LabaFuben:OnTrigger", szTrigger)
end

function tbAct:OnStart()
	Kin:TraverseKin(function(tbKinData)
		Kin.KinNest:ForceOpen(tbKinData.nKinId, self.tbSettings.nNestNpcNum, self.tbSettings.nNestNpcLevel)
    end)
    Log("[KinNestFuben] start ")
end

function tbAct:OnEnd()
	Kin:TraverseKin(function(tbKinData)
		Kin.KinNest:EndKinNest(tbKinData.nKinId)
    end)
    Log("[KinNestFuben] end ")
end
