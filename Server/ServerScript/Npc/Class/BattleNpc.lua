--战场npc 包括建筑
local tbNpc = Npc:GetClass("BattleNpc") 

function tbNpc:OnDeath(pKiller)
	Battle:OnNpcDeath(him, pKiller)
end