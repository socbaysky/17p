
local tbItem = Item:GetClass("GoldEvoMaterialMap");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUseSetting = {szFirstName = "使用"};
	tbUseSetting.fnFirst = function ()
		Ui:CloseWindow("ItemTips")
		local nTarItem = Item.GoldEquip:GetCosumeItemAutoSelectEquipId(nTemplateId)
		Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Evolution", nTarItem)
	end
	
	if Shop:CanSellWare(me, nItemId, 1) then
		tbUseSetting.fnSecond = "SellItem";
		tbUseSetting.szSecondName = "出售";
	end

	return tbUseSetting;		
end

