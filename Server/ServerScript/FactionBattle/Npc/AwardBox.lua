local tbNpc = Npc:GetClass("FactionAwardBox")

function tbNpc:OnCreate(szParam)
	Timer:Register(Env.GAME_FPS * FactionBattle.BOX_EXSIT_TIME, self.TimeUp, self, him.nId);
end

function tbNpc:OnDialog()
	if FactionBattle:GetBoxAwardCount(me.dwID) >= FactionBattle.BOX_MAX_GET  then
		Dialog:SendBlackBoardMsg(me, string.format(XT("本次竞技每人最多可以开启%s个宝箱"), FactionBattle.BOX_MAX_GET));
		return;
	end
	GeneralProcess:StartProcess(me, FactionBattle.PICK_BOX_TIME * Env.GAME_FPS, "开启中...", self.EndProcess, self, me.dwID, him.nId);
end

function tbNpc:EndProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return;
	end

	if FactionBattle:GetBoxAwardCount(pPlayer.dwID) >= FactionBattle.BOX_MAX_GET  then
		return;
	end

	if not MODULE_ZONESERVER then
		local nAwardId = FactionBattle:GetBoxAwardId()
		if nAwardId then
			local nRet, szMsg, tbAward = Item:GetClass("RandomItem"):RandomItemAward(pPlayer, nAwardId, "FactionBattleBox");
			if nRet == 1 then
				FactionBattle:AddBoxAwardRecord(pPlayer.dwID);
				pPlayer.SendAward(tbAward, true, false, Env.LogWay_FactionBattleBox);
				pNpc.Delete();
			end
		end

	else
		pPlayer.CenterMsg("开启成功，奖励将在结束後信件发放")
		FactionBattle:AddBoxAwardRecord(pPlayer.dwID, pPlayer.nZoneServerId, pPlayer.dwOrgPlayerId);
		pNpc.Delete();
	end
end

function tbNpc:TimeUp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return;
	end

	pNpc.Delete();
end