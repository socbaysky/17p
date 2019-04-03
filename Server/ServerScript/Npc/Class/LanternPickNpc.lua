local tbNpc = Npc:GetClass("LanternPickNpc")

function tbNpc:OnDialog()
    if me.nLevel<Kin.MonsterNianDef.nMinJoinLevel then
        me.CenterMsg("等级不足，无法参与活动")
        return
    end

    him.tbAnsweredPids = him.tbAnsweredPids or {}
    if him.tbAnsweredPids[me.dwID] then
        Dialog:SendBlackBoardMsg(me, "您已经看过这个灯笼了！")
        return
    end

    GeneralProcess:StartProcess(me, Kin.MonsterNianDef.nLanternPickTime*Env.GAME_FPS, "采集中", self.EndProcess, self, me.dwID, him.nId)
end

function tbNpc:EndProcess(nPlayerId, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    local pNpc = KNpc.GetById(nNpcId)
    if not pPlayer then
        return
    end

    if not pNpc or pNpc.IsDelayDelete() then
        pPlayer:CenterMsg("已被其他人抢先采集")
        return
    end
    
    local nQuestionId = pNpc.nQuestionId
    if not nQuestionId or nQuestionId<=0 then
        Log("[x] LanternPickNpc:EndProcess", nPlayerId, nNpcId, tostring(nQuestionId))
        return
    end
    pPlayer.CallClientScript("Ui:OpenWindow", "LanternQuestionPanel", nNpcId, nQuestionId)
end
