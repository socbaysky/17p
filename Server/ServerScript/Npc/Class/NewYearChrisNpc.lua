local tbNpc = Npc:GetClass("NewYearChrisNpc");

function tbNpc:OnDialog()
	if not Activity:__IsActInProcessByType("NewYearChris") then
		me.CenterMsg("活动未开放", true)
		return
	end

	Activity:OnPlayerEvent(me, "Act_DialogNewYearChrisNpc", him)
end