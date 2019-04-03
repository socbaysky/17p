local tbNpc = Npc:GetClass("SpokesmanTask")

function tbNpc:OnDialog()
    Dialog:Show(
    {
        Text    = "“寂寞双煞”武功高强，少侠可结伴前往追捕。本人终身幸福托於少侠，盼少侠平安带“又缘糕”归来。",
        OptList = {
            { Text = "帮助挺师兄", Callback = self.TryAcceptTask, Param = {self, me.dwID, him.nId} },
        },
    }, me, him)
end

function tbNpc:TryAcceptTask(dwID, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end

    Spokesman:TryAcceptTask(pPlayer, nNpcId)
end