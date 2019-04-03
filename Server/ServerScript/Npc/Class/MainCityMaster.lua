local tbNpc = Npc:GetClass("MainCityMaster")

function tbNpc:OnDialog(szParam)

	local nTargetFaction = tonumber(szParam);
	if nTargetFaction ~= me.nFaction then
		return;
	end

	if him.bCross then
		if him.nCrossLeaderId ~= me.dwID then
			return
		end

		local nCurServerId = GetServerIdentity();
		if him.nCrossServerId ~= nCurServerId then
			return
		end
	else
		if DomainBattle:GetMasterLeaderId() ~= me.dwID then
			return;
		end
	end

	me.CallClientScript("Ui:OpenWindow", "MainShowOffPanel", "MainCity", {bCross = him.bCross});
end