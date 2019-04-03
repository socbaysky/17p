local tbNpc = Npc:GetClass("IndifferChangeFaction")

function tbNpc:OnCreate()
	local nChangeToFactionId = MathRandom(1, Faction.MAX_FACTION_COUNT)
	him.nChangeToFactionId = nChangeToFactionId
	him.SetName( string.format("%s门派之力", Faction:GetName(nChangeToFactionId)) )
end

function tbNpc:OnDialog()
	local nTime = tonumber(him.szScriptParam)
	if (nTime <= 0) then
		Log(debug.traceback())
		return
	end
	if me.nFightMode == 2 then
		me.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	if not him.nChangeToFactionId then
		me.CenterMsg("无效的npc")
		return
	end
	if me.nFaction == him.nChangeToFactionId then
		me.CenterMsg("门派相同")
		return
	end
	me.DoChangeActionMode(Npc.NpcActionModeType.act_mode_none);
	me.AddSkillState(2783, 1, 0, 1)
	
	GeneralProcess:StartProcess(me, nTime * Env.GAME_FPS, "开启中...", self.EndProcess, self, me.dwID, him.nId);
end

function tbNpc:EndProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		pPlayer.CenterMsg("该采集物已消失")
		return;
	end

	local nChangeToFactionId = pNpc.nChangeToFactionId
	if not nChangeToFactionId then
		return
	end
	
	local tbInst = InDifferBattle.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end

	local bRet = tbInst:ChangePlayerFactionFight(pPlayer, nChangeToFactionId)
	if not bRet then
		return
	end
	tbInst:DeleteNpc(nNpcId)
end
