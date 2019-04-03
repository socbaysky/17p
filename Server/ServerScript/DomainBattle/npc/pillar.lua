local tbNpc = Npc:GetClass("cross_domain_pillar");

function tbNpc:OnDeath(pKillNpc)
	DomainBattle.tbCross:OnNpcDeath(him, pKillNpc)
end
