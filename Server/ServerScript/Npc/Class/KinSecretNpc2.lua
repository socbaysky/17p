local tbNpc = Npc:GetClass("KinSecretNpc2")

function tbNpc:OnCreate(szParam)
	for _, tbCfg in ipairs(Fuben.KinSecretMgr.Def.tbBoss2HpCfg) do
		local nPercent, szKind, nTitleId, szBubble, szBlackMsg = unpack(tbCfg)
		Npc:RegisterNpcHpPercent(him, tbCfg[1], function(nTriggerPercent, nCurPercent)
			if szBubble and szBubble~="" then
				self:NpcBubbleTalk(szBubble)
			end
			if szBlackMsg and szBlackMsg~="" then
				self:BlackMsg(szBlackMsg)
			end
			if nTitleId and nTitleId>0 then
				him.SetTitleID(nTitleId)
			end
			self:DoHpEvent(him, szKind)
		end)
	end
end

function tbNpc:ClearAllBuff(pNpc)
	for _, tbBuff in pairs(Fuben.KinSecretMgr.Def.tbBoss2Buffs) do
		pNpc.RemoveSkillState(tbBuff[1])
	end
end

function tbNpc:DoHpEvent(pNpc, szKind)
	self:ClearAllBuff(pNpc)
	pNpc.szCurState = szKind
	if szKind~="aoe" then
		local tbBuff = Fuben.KinSecretMgr.Def.tbBoss2Buffs[szKind]
		local nBuffId, nBuffLvl = unpack(tbBuff)
		if not nBuffId then
			Log("[x] KinSecretNpc2:DoHpEvent, no buff", szKind)
			return
		end

		local nNpcId = pNpc.nId
		Timer:Register(Env.GAME_FPS*Fuben.KinSecretMgr.Def.nBoss2ChangeBuffDelay, function()
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				pNpc.AddSkillState(nBuffId, nBuffLvl, 0, 9999 * Env.GAME_FPS)
			end
		end)
		return
	end

	self:GoCastAoe(pNpc)
end

function tbNpc:GoCastAoe(pNpc)
	self:BlackMsg("快进入自己职业所属的五行法阵躲避")

	pNpc.CastSkill(Fuben.KinSecretMgr.Def.nBoss2AoePrepareSkillId, 1, 0, 0)

	local nNpcId = pNpc.nId
	Timer:Register(Env.GAME_FPS*Fuben.KinSecretMgr.Def.nBoss2AoeSkillDelay, function()
		local pNpc = KNpc.GetById(nNpcId)
		if not pNpc then
			return
		end
		
		local tbFuben = self:GetFubenInst(pNpc)
		tbFuben:OnBoss2Aoe()
		pNpc.CastSkill(Fuben.KinSecretMgr.Def.nBoss2AoeSkillId, 1, 0, 0)
	end)
end

function tbNpc:OnDeath(pKiller)
	if not MODULE_GAMESERVER then
		return;
	end

	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);
	SeriesFuben:OnKillNpc(him, pKiller)
end

function tbNpc:GetFubenInst(pNpc)
	return Fuben.tbFubenInstance[pNpc.nMapId]
end

function tbNpc:AllPlayerExcute(fnExcute)
	local tbFuben = self:GetFubenInst(him)
	if not tbFuben then
		return
	end
	for nPlayerId in pairs(tbFuben.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and tbFuben.tbPlayer[nPlayerId].bInFuben == 1 then
			fnExcute(pPlayer);
		end
	end
end

function tbNpc:NpcBubbleTalk(szBubble)
	self:AllPlayerExcute(function(pPlayer)
		pPlayer.CallClientScript("Ui:NpcBubbleTalk", {him.nId}, szBubble, 10, 1)
	end)
end

function tbNpc:BlackMsg(szMsg)
	self:AllPlayerExcute(function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg)
	end)
end

local tbRestrain = {
	jin = "mu",
	mu = "tu",
	shui = "huo",
	huo = "jin",
	tu = "shui",
}

function tbNpc:OnTrap(him, szTrap)
	if not him.szCurState or him.szCurState=="aoe" then
		return
	end

	local szIn = Fuben.KinSecretMgr.Def.tbTrapIn[szTrap]
	if szIn then
		if him.szCurState==tbRestrain[szIn] then
			local tbBuff = Fuben.KinSecretMgr.Def.tbBoss2Buffs[him.szCurState]
			him.RemoveSkillState(tbBuff[1])
		end
		return
	end
	local szOut = Fuben.KinSecretMgr.Def.tbTrapOut[szTrap]
	if szOut then
		if him.szCurState==tbRestrain[szOut] then
			local tbBuff = Fuben.KinSecretMgr.Def.tbBoss2Buffs[him.szCurState] 
			local nBuffId, nBuffLvl = unpack(tbBuff)
			him.AddSkillState(nBuffId, nBuffLvl, 0, 9999 * Env.GAME_FPS)
		end
		return
	end
end