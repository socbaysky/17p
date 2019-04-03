local tbNpc   = Npc:GetClass("HuaTongNpc")
function tbNpc:OnDialog()
    local nOpenDay, nOpenTime = Wedding:CheckTimeFrame()
    if nOpenDay then
         Dialog:Show(
        {
            Text = string.format("嘻嘻，你是不是有心上人了？说不定月爷爷能帮到你。\n[FFFE0D]结婚系统将在%d天后开放！[-]", nOpenDay),
            OptList = {},
        }, me, him)
        return 
    end
	 Dialog:Show(
        {
            Text = "嘻嘻，你是不是有心上人了？说不定月爷爷能帮到你。",
            OptList = {
                { Text = "婚礼商店", Callback = self.Shop, Param = {self, me.dwID} };
            },
        }, me, him)
end

function tbNpc:Shop(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
       return
	end
	pPlayer.CallClientScript("Ui:OpenWindow", "KinStore", "WeddingShop")
end