local tbNpc = Npc:GetClass("NYSnowmanNpc");

local NYSnowman = Kin.NYSnowman

function tbNpc:OnDialog()
	if not NYSnowman:IsRunning() then
		me.CenterMsg("活动未开放",true)
		return
	end

	Activity:OnPlayerEvent(me, "Act_DialogNYSnowman",him);
end