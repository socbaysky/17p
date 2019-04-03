local tbNpc = Npc:GetClass("SnowmanNpc");

local Snowman = Kin.Snowman

function tbNpc:OnDialog()
	if not Snowman:IsRunning() then
		me.CenterMsg("活动未开放",true)
		return
	end

	Activity:OnPlayerEvent(me, "Act_DialogSnowman",him);
end