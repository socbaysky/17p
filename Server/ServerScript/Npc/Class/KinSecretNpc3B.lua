local tbNpc = Npc:GetClass("KinSecretNpc3B")

function tbNpc:OnCreate(szParam)
	local nBuffId, nLevel = unpack(Fuben.KinSecretMgr.Def.nBoss3BBuff)
	him.AddSkillState(nBuffId, nLevel, 0, 9999 * Env.GAME_FPS)
end

function tbNpc:OnDeath(pKiller)
	if not MODULE_GAMESERVER then
		return;
	end

	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);
	SeriesFuben:OnKillNpc(him, pKiller)

	local tbFuben = self:GetFubenInst(him)
	tbFuben:OnBoss3BDeath()
end

function tbNpc:GetFubenInst(pNpc)
	return Fuben.tbFubenInstance[pNpc.nMapId]
end
