local tbAct = Activity:GetClass(WuLinDaHui.szActNameBaoMing);
local tbDef = WuLinDaHui.tbDef;

tbAct.tbTimerTrigger =
{
}

tbAct.tbTrigger =
{
	Init = {},
	Start ={},
	End = {},
};


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then	
		WuLinDaHui:InitAtNewBaoMing();
	elseif szTrigger == "Start" then	
		local _,nEndTime = self:GetOpenTimeInfo()
		NewInformation:AddInfomation(tbDef.szNewsKeyNotify, nEndTime, {}, {szTitle = "武林大会开启", nReqLevel = 1, szUiName = "Normal2"} )    
		Timer:Register(1, function ()
			KPlayer.BoardcastScript(1, "Player:ServerSyncData", "UpdateTopButton"); 
		end)

	elseif szTrigger == "End" then	
	end
end

function tbAct:GetUiData( )
	local tbSaveData = WuLinDaHui:GetSaveData()
	return {nLastStartBaoMingTime = tbSaveData.nLastStartBaoMingTime }
end