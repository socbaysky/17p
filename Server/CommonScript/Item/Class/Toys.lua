local tbItem = Item:GetClass("Toy")
function tbItem:OnUse(it)
	local nId = KItem.GetItemExtParam(it.dwTemplateId, 1)
	if not nId or nId <= 0 then
		Log("[x] Toy:OnUse, cfg err", it.dwTemplateId, nId)
		me.CenterMsg("道具配置错误")
		return 0
	end
	-- Toy:Unlock(me, nId)
	local useNum = me.GetUserValue(178, nId)
	me.SetUserValue(178, nId,useNum + 1)
	return 1
end