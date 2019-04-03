local tbNpc = Npc:GetClass("corss_domain_change");

function tbNpc:OnDialog(szParam)
	local tbPlayerInfo = DomainBattle.tbCross:GetPlayerInfo(me.dwID)
	if not tbPlayerInfo or tbPlayerInfo.nKinId ~= him.dwKinId then
		return
	end

	local _,_ ,szText, nChangeSkillId, nDuraTime= string.find(szParam, "(.*)|(%d+)|(%d+)")
	nChangeSkillId = tonumber(nChangeSkillId)
	nDuraTime = tonumber(nDuraTime)
	Dialog:Show(
	{
		Text = him.szDefaultDialogInfo or "",
		OptList =
		{
			{
				Text = "变身" .. szText, Callback = DomainBattle.tbCross.ChangeToSiegeCar,
				Param = {DomainBattle.tbCross, me, him.nId, nChangeSkillId, szText, nDuraTime},
			},
		},
	}, me)

end