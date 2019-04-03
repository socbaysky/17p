local tbNpc   = Npc:GetClass("WhiteTiger")

local tbIndex = {"一", "二", "三", "四", "五", "六", "七", "八"}
function tbNpc:OnDialog()
    local nRoomId  = tonumber(him.szScriptParam)
    local szIdx    = tbIndex[nRoomId]
    local szDialog = "这里是进入白虎堂一层的入口" .. szIdx .. "，你确定要进入吗？"
    Dialog:Show(
    {
        Text = szDialog,
        OptList = {
            { Text = "进入·入口" .. szIdx, Callback = self.EnterFuben, Param = {self, me.dwID, nRoomId} }
        },
    }, me, him)
end

function tbNpc:EnterFuben(dwID, nRoomId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end

    Fuben.WhiteTigerFuben:TryEnterOutSideFuben(pPlayer, nRoomId)
end