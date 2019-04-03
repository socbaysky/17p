local tbNpc = Npc:GetClass("IndifferBox")

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
	--大宝箱的话需要去掉天忍的隐身
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
		pPlayer.CenterMsg("该宝箱已消失")
		return;
	end
	if pNpc.bFinish then
		pPlayer.CenterMsg("已被其他人抢先打开")
		return
	end

	pNpc.bFinish = true;

	--特定npc的打开动作，先不传参了。。
	local nTimeDel = 8 --宝箱打开后删除时间
	if pNpc.nTemplateId == 1994 then  --宝箱
		pNpc.DoCommonAct(16, 5001 , 1)	
	elseif pNpc.nTemplateId == 2101 then --幻象
		nTimeDel = 20 --幻象打开后删除时间
		pNpc.CastSkill(1678, 1, -1, -1)
	end

	local tbInst = InDifferBattle.tbMapInst[pPlayer.nMapId]
	if 	tbInst then
		tbInst:OnOpenIndifferBox(pPlayer, pNpc)
	end

	Timer:Register(nTimeDel, function ()
		tbInst:DeleteNpc(nNpcId)
	end)
end
