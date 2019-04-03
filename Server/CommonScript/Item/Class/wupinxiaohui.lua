local tbItem = Item:GetClass("wupinxiaohui")

function tbItem:OnUse(it)

	Dialog:Show(--使用物品后弹窗
        {
            Text    = "亲爱的上帝大人，请问找小的有何贵干",
            OptList = {
              
                { Text = "我要销毁物品", Callback = self.Reincarnation, Param = {self, 2} },
                { Text = "没啥事，告辞", Callback = function () end},
            },
        }, me, him);    
		
	return 0
end
function tbItem:Reincarnation()  
	local opt  = {};
	local tbItem = me.GetItemListInBag() --获取背包道具
		for _, pItem in pairs(tbItem) do
			local dwId = pItem.dwId
			table.insert(opt, { Text = "销毁 → "..pItem.szName, Callback = self.delItemSure, Param = {self, dwId} })  
		end
	table.insert(opt, { Text = "抱歉点错了!", Callback = function () end})
		Dialog:Show(
				{
					Text    = "物品销毁后将无法找回,请慎重选择!",
					OptList = opt,
				}, me, him);   
end

function tbItem:delItemSure(dwId) --
	local pItem = KItem.GetItemObj(dwId)
		Dialog:Show(
		{
			Text    = "亲爱的上帝大人，您确定要销毁 → "..pItem.szName.."吗?",
				OptList = {
				{ Text = "确定", Callback = self.delItem, Param = {self, dwId} }, 
				{ Text = "取消", Callback = function () end},
				},
		}, me, him);   
	end

function tbItem:delItem(dwId) --执行销毁
	local pItem = KItem.GetItemObj(dwId)
		me.CenterMsg("成功为您销毁物品:"..pItem.szName.."", true) 
	pItem.Delete(1)
end