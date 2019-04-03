if not MODULE_ZONESERVER then
	return
end
Require("ServerScript/InDifferBattle/BattleBaseJueDi.lua")

local tbBattleBase = InDifferBattle:CreateClass("BattleBaseJueDiAct", "BattleBaseJueDi")
local tbDefine = InDifferBattle.tbDefine
local tbSkillBook = Item:GetClass("SkillBook");

--重载
function tbBattleBase:TryAddTeamAwarad(dwTeamID)
	local tbTeamServerInfo = self.tbTeamServerInfo[dwTeamID]
	local nTimeNow = GetTime();
	if not tbTeamServerInfo.bSendAward then
		tbTeamServerInfo.bSendAward = true;
		local tbTeamReportInfo = self.tbTeamReportInfo[dwTeamID]
		InDifferBattle:SendTeamAwardZAct(dwTeamID, self.dwWinnerTeam, tbTeamReportInfo, nTimeNow - self.nGameStartTime, self.szBattleType)
	end
end