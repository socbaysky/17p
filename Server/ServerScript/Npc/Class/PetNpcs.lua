local tbNpc = Npc:GetClass("DogPetNpc")

function tbNpc:OnGeneralDialog(szParam)
    me.CallClientScript("Ui:OpenWindow", "PetOptUi", "dog", him.nTemplateId, him.nId)
end

------------------------
local tbNpc = Npc:GetClass("CatPetNpc")

function tbNpc:OnGeneralDialog(szParam)
	me.CallClientScript("Ui:OpenWindow", "PetOptUi", "cat", him.nTemplateId, him.nId)
end