local tbDlgNpc = Npc:GetClass("cross_domain_throne");

function tbDlgNpc:OnDialog(szParam)
	local tbInst = DomainBattle.tbCross.tbInstList[him.nMapId]
	if tbInst then
		tbInst:OccupyThroneReq(me)
	end
end

local tbFightNpc = Npc:GetClass("cross_domain_throne_fight");

function tbFightNpc:OnDeath(pKillNpc)
	DomainBattle.tbCross:OnNpcDeath(him, pKillNpc)
end
