local tbNpc = Npc:GetClass("IndifferDeathDropBox")

function tbNpc:OnDialog()
	local nTime = tonumber(him.szScriptParam)
	if me.nFightMode == 2 then
		me.CenterMsg("您已阵亡，无法进行操作")
		return
	end
	--大宝箱的话需要去掉天忍的隐身
	me.AddSkillState(2783, 1, 0, 1)

	if nTime > 0 then
		GeneralProcess:StartProcess(me, nTime * Env.GAME_FPS, "开启中...", self.EndProcess, self, me.dwID, him.nId);	
	else
		self:EndProcess(me.dwID, him.nId)
	end
end

function tbNpc:EndProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		pPlayer.CenterMsg("该宝箱已消失")
		return;
	end

	pPlayer.CallClientScript("Ui:OpenWindow", "DreamlandDangerCollectionPanel", pNpc.tbDropNpcs, pNpc.nId)	
end
