local tbItem = Item:GetClass("TeacherStudentToken")

tbItem.nMapId = 999
tbItem.nNpcId = 1839
function tbItem:OnUse(it)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
    me.CallClientScript("SwornFriends:AutoPathToNpc", self.nNpcId, self.nMapId)
end
