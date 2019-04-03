local tbMapClass = Map:GetClass(Map.PRISON_MAP_TEAMPLATE_ID);

tbMapClass.nJuHuaNpcTemplateId = 2830; -- 死后的菊花
tbMapClass.nPrisonTitleId = 2100;

tbMapClass.tbReviePostion = {
	{Map.PRISON_MAP_TEAMPLATE_ID, 2586,4565},
	{Map.PRISON_MAP_TEAMPLATE_ID, 3047,4576},
	{Map.PRISON_MAP_TEAMPLATE_ID, 4241,4583},
	{Map.PRISON_MAP_TEAMPLATE_ID, 4793,4544},
	{Map.PRISON_MAP_TEAMPLATE_ID, 2450,2194},
	{Map.PRISON_MAP_TEAMPLATE_ID, 2960,2208},
	{Map.PRISON_MAP_TEAMPLATE_ID, 4454,2219},
	{Map.PRISON_MAP_TEAMPLATE_ID, 4901,2212},
	{Map.PRISON_MAP_TEAMPLATE_ID, 2504,3702},
	{Map.PRISON_MAP_TEAMPLATE_ID, 2511,3203},
	{Map.PRISON_MAP_TEAMPLATE_ID, 4793,3635},
	{Map.PRISON_MAP_TEAMPLATE_ID, 4804,3221},
};

function tbMapClass:OnCreate(nMapId)
	self.tbPlayer = self.tbPlayer or {};
	self.tbPKModeCustom = {};
end

function tbMapClass:GetNextPKModeCustom()
	if not next(self.tbPKModeCustom) then
		for i = 1, 255 do
			table.insert(self.tbPKModeCustom, i);
		end
	end
	return table.remove(self.tbPKModeCustom);
end

function tbMapClass:ReusePKModeCustom(nCustom)
	if nCustom and nCustom > 0 and nCustom <= 255 then
		table.insert(self.tbPKModeCustom, nCustom);
	end
end

function tbMapClass:OnDestroy(nMapId)
	self.tbPlayer = nil;
end

function tbMapClass:OnEnter()
	Log("Prison OnEnter", me.dwID, me.szName);

	local nPlayerId = me.dwID;
	self.tbPlayer[nPlayerId] = self.tbPlayer[nPlayerId] or {};

	me.bSelfAutoRevive = true;
	me.nInBattleState = 1; --战场模式

	PlayerTitle:AddTitle(me, tbMapClass.nPrisonTitleId, -1, "", true);
	PlayerTitle:ActiveTitle(me, tbMapClass.nPrisonTitleId, false)

	if self.tbPlayer[nPlayerId].nDeathCallbackId then
		PlayerEvent:UnRegister(me, "OnDeath", self.tbPlayer[nPlayerId].nDeathCallbackId);
	end
	self.tbPlayer[nPlayerId].nDeathCallbackId = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);


	local nCustom = self:GetNextPKModeCustom();
	me.SetPkMode(Player.MODE_CUSTOM, nCustom);
	me.nPrisonMapPKCustom = nCustom;

	Env:SetSystemSwitchOff(me, Env.SW_All);
	me.CallClientScript("Ui:OpenWindow", "PrisonRemainTimePanel");
	me.nPrisonMapCheckDebtRegistId = PlayerEvent:Register(me, "CheckMoneyDebt", self.OnMoneyDebtChanged, self);
	self:OnMoneyDebtChanged();
end

function tbMapClass:OnMoneyDebtChanged()
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	if not me.CanPushPrison() then
		me.GetNpc().RemoveSkillState(Player.PRISON_BUFF_ID);
	else
		local nLeftTime = me.GetPrisonLeftTime();
		pNpc.AddSkillState(Player.PRISON_BUFF_ID, 1, 3, math.min(nLeftTime * Env.GAME_FPS, 2000000000), 1, 1);
	end
end

function tbMapClass:OnLeave()
	Log("Prison On Leave", me.dwID, me.szName);

	local nPlayerId = me.dwID;
	me.bSelfAutoRevive = nil;
	me.nInBattleState = 0;

	PlayerTitle:DeleteTitle(me, tbMapClass.nPrisonTitleId, true);

	local pNpc = me.GetNpc();
	if pNpc then
		pNpc.RemoveSkillState(Player.PRISON_BUFF_ID);
	end

	if self.tbPlayer[nPlayerId].nDeathCallbackId then
		PlayerEvent:UnRegister(me, "OnDeath", self.tbPlayer[nPlayerId].nDeathCallbackId);
	end
	self.tbPlayer[nPlayerId] = nil;
	me.SetPkMode(Player.MODE_PEACE, 0);
	self:ReusePKModeCustom(me.nPrisonMapPKCustom);
	me.nPrisonMapPKCustom = nil;

	Env:SetSystemSwitchOn(me, Env.SW_All);
	me.ClearTempRevivePos();

	PlayerEvent:UnRegister(me, "CheckMoneyDebt", me.nPrisonMapCheckDebtRegistId);
	me.nPrisonMapCheckDebtRegistId = nil;
end

function tbMapClass:OnLogin(nMapId)
	Log("Prison On Login", me.dwID, me.szName);
end

function tbMapClass:OnPlayerDeath(pKiller)
	Log("Presion Map OnPlayerDeath", me.dwID, me.szName, pKiller.szName);

	if not me.CanPushPrison() then
		me.SendBlackBoardMsg("天罚期限已到，您可与万金财对话离开此地", true);
	end

	local nPlayerId = me.dwID;
	local nMapId, nX, nY = me.GetWorldPos();
	local pJuHuaNpc = KNpc.Add(self.nJuHuaNpcTemplateId, 1, 0, nMapId, nX, nY, 0, 1);
	local nJuHuaNpcId = pJuHuaNpc.nId;

	Timer:Register(Env.GAME_FPS * 5, function ()
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local tbPos = self.tbReviePostion[MathRandom(#self.tbReviePostion)];
			pPlayer.SetTempRevivePos(unpack(tbPos));
			pPlayer.Revive(0);
		end
	end);

	Timer:Register(Env.GAME_FPS * 7, function ()
		local pJuHuaNpc = KNpc.GetById(nJuHuaNpcId or 0);
		if pJuHuaNpc then
			pJuHuaNpc.Delete();
		end
	end);
end
