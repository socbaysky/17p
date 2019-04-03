local tbNpc = Npc:GetClass("TaoHuaNpc")

function tbNpc:OnDialog()
    Activity:OnPlayerEvent(me, "Act_TryGetTaoHua", him)
end