local tbItem = Item:GetClass("PartnerCardGift");

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	local tbSetting = {
        szFirstName = "赠送",
        fnFirst = function()
            Ui:OpenWindow("GiftSystem", nil, nil, "PartnerCard")
            Ui:CloseWindow("ItemTips")
        end,
    }
	return tbSetting
end