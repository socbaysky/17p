local tbItem = Item:GetClass("WaiYiTryToken")

function tbItem:OnUse(it)
	me.CallClientScript("Ui:OpenWindow", "WaiYiTryPanel")
	return 0
end
