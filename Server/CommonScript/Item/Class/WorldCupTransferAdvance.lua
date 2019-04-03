local tbItem = Item:GetClass("WorldCupTransferAdvance")

function tbItem:OnUse(it)
	local tbAct = Activity:GetClass("WorldCupAct")
	if GetTime() > tbAct.nTransferTokenExpire then
		me.CenterMsg("已超过使用期限")
		return 1
	end
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:OpenWindow", "WorldCupTransferPanel", false)
	return
end