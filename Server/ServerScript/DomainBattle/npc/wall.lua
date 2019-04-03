local tbNpc = Npc:GetClass("cross_domain_wall");

function tbNpc:OnDeath(pKillNpc)
	DomainBattle.tbCross:OnWallDeath(him, pKillNpc)
end
