local tbNpc = Npc:GetClass("KinTrainBox")

function tbNpc:OnCreate()
    him.tbOpenPlayer = {}
    him.nOpenTimes   = 0
end

function tbNpc:OnDialog()
    local szText = string.format("这是一个 5 层宝箱\n目前已开启 %d/5 层", him.nOpenTimes  )
    Dialog:Show(
    {
        Text    = szText,
        OptList = {
            { Text = "开启下一层", Callback = self.Open, Param = {self, me.dwID, him.nId} },
        },
    }, me, him)
end

function tbNpc:Open(dwID, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local pNpc    = KNpc.GetById(nNpcId)
    if not pPlayer or not pNpc then
        return
    end

    local tbParams = Lib:SplitStr(pNpc.szScriptParam, "|")
    local nNeedOpenTimes = tonumber(tbParams[1])
    local nColdSec  = tonumber(tbParams[2])
    local nOpenTime = him.tbOpenPlayer[me.dwID]
    if nOpenTime and GetTime() - nOpenTime < nColdSec then
        me.CenterMsg(string.format("等待%d秒後才能开启", math.max(0, nColdSec - GetTime() + nOpenTime)))
        return
    end

    GeneralProcess:StartProcess(pPlayer, Env.GAME_FPS, "开启中", self.EndProcess, self, dwID, nNpcId, nNeedOpenTimes)
end

function tbNpc:EndProcess(dwID, nNpcId, nNeedOpenTimes)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local pNpc    = KNpc.GetById(nNpcId)
    if not pPlayer or not pNpc then
        return
    end

    pNpc.tbOpenPlayer[dwID] = GetTime()
    pNpc.nOpenTimes = pNpc.nOpenTimes + 1
    local bDelete = pNpc.nOpenTimes >= nNeedOpenTimes
    local tbFubenInst = Fuben.tbFubenInstance[pNpc.nMapId]
    if tbFubenInst then
        tbFubenInst:OnBoxOpen(pNpc, bDelete)
    end
    if bDelete then
        pNpc.DoDeath()
    end
    pPlayer.CenterMsg(string.format("成功开启了宝箱的第%d层", pNpc.nOpenTimes))
end