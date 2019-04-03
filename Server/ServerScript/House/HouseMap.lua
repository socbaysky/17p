
Require("CommonScript/House/HouseCommon.lua");

function House:GetHouseInfoByMapId(nMapId)
	local tbMapInfo = nil;
	local dwOwnerId = nil;
	for nId, tbInfo in pairs(self.tbHouseMapInfo) do
		if tbInfo.nMapId == nMapId then
			tbMapInfo = tbInfo;
			dwOwnerId = nId;
			break;
		end
	end

	return dwOwnerId, tbMapInfo;
end

function House:OnMapCreate(nMapId)
	local dwOwnerId, tbMapInfo = self:GetHouseInfoByMapId(nMapId);
	if not dwOwnerId then
		return;
	end

	Lib:CallBack({function () Item:GetClass("NpcLoveToken"):OnCreateHouseMap(dwOwnerId, nMapId); end });

	tbMapInfo.bLoadFinish = true;

	for nPlayerId, tbInfo in pairs(self.tbTryEnterList[nMapId] or {}) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local bRet, szMsg = House:CheckCanEnterMap(pPlayer);
			if not bRet then
				pPlayer.CenterMsg(szMsg);
			else
				self:GotoHouse(pPlayer.dwID, dwOwnerId, nil, tbInfo.tbPos, tbInfo.fnGotoHouse);
			end
		end
	end
	self.tbTryEnterList[nMapId] = nil;

	self.tbMapFurnitureInfo = self.tbMapFurnitureInfo or {};
	self.tbMapFurnitureInfo[nMapId] = self.tbMapFurnitureInfo[nMapId] or {};
	local tbHouse = self:GetHouse(dwOwnerId);
	local tbToRemove = {};
	for _, tbInfo in pairs(tbHouse.tbFurnitureSet or {}) do
		local tbFur = self:GetFurnitureInfo(tbInfo.nTemplateId);

		tbInfo.nYaw = Decoration:FormatRotation(tbFur.nDecorationId, tbInfo.nYaw);

		local tbSetting = {
			nX = tbInfo.nX,
			nY = tbInfo.nY,
			nSX = tbInfo.nSX,
			nSY = tbInfo.nSY,
			nRotation = tbInfo.nYaw,
			nTemplateId = tbFur.nDecorationId,
		};

		local bRet, szMsg, nDId = Decoration:NewDecorationByTB(nMapId, tbSetting, true);
		if bRet then
			self.tbMapFurnitureInfo[nMapId][nDId] = {nX = tbInfo.nX, nY = tbInfo.nY, nRotation = tbInfo.nYaw, nTemplateId = tbInfo.nTemplateId};
		else
			table.insert(tbToRemove, {tbInfo.nTemplateId, tbInfo.nX, tbInfo.nY});
		end
	end

	self.tbMapToRemoveInfo = self.tbMapToRemoveInfo or {};
	self.tbMapToRemoveInfo[nMapId] = nil;

	if tbToRemove and #tbToRemove > 0 then
		self.tbMapToRemoveInfo[nMapId] = tbToRemove;
	end

	local tbMainSeatInfo = House.tbMainSeatInfo[tbMapInfo.nMapTemplateId];
	if tbMainSeatInfo then
		local tbInfo = {
			nTemplateId = tbMainSeatInfo[1],
			nX = tbMainSeatInfo[2][1],
			nY = tbMainSeatInfo[2][2],
			nRotation = 0;
		}
		local bRet, szMsg = Decoration:NewDecorationByTB(nMapId, tbInfo, true);
		if not bRet then
			Log("[House] Create Main Seat Fail !!", tbMapInfo.nMapTemplateId, szMsg);
		end
	end

	for nPosId, nWaiYiId in pairs(tbHouse.tbWaiYiSetting or {}) do
		Map:SetMapWaiYiInfo(nPosId, nWaiYiId, nMapId);
	end
end

function House:ForeachMapPlayers(dwOwnerId)
	local tbAllPlayer = nil;
	local tbMapInfo = self.tbHouseMapInfo[dwOwnerId];
	if tbMapInfo then
		tbAllPlayer = KPlayer.GetMapPlayer(tbMapInfo.nMapId);
	end

	local i = 0;
	return function ()
		i = i + 1;
		return tbAllPlayer and tbAllPlayer[i];
	end
end

-- 包含房主
function House:ForeachMapRoomers(dwOwnerId)
	local tbAllPlayer = nil;
	local tbMapInfo = self.tbHouseMapInfo[dwOwnerId];
	if tbMapInfo then
		tbAllPlayer = KPlayer.GetMapPlayer(tbMapInfo.nMapId);
	end

	local i = 1;
	return function ()
		if not tbAllPlayer then
			return;
		end

		while tbAllPlayer[i] do
			local pPlayer = tbAllPlayer[i];
			i = i + 1;

			if pPlayer.dwID == dwOwnerId then
				return pPlayer;
			end

			if Wedding:IsLover(pPlayer.dwID, dwOwnerId) then
				return pPlayer;
			end

			local nLandlordId = pPlayer.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD);
			if nLandlordId ~= 0 and nLandlordId == dwOwnerId then
				return pPlayer;
			end
		end
	end
end

function House:OnMapEnter(nMapId)
	local dwOwnerId, tbMapInfo = self:GetHouseInfoByMapId(nMapId);
	assert(dwOwnerId, "failed to get house info of map: " .. nMapId);

	local tbSetting = self.tbHouseSetting[tbMapInfo.nLevel];
	me.SetPosition(tbSetting.nX, tbSetting.nY);

	self:SyncHouseInfo(me);

	if dwOwnerId == me.dwID and self.tbMapToRemoveInfo and self.tbMapToRemoveInfo[nMapId] and #self.tbMapToRemoveInfo[nMapId] > 0 then
		for _, tbInfo in pairs(self.tbMapToRemoveInfo[nMapId]) do
			local nTemplateId, nX, nY = unpack(tbInfo);
			local tbFurnitureInfo = House:GetFurnitureInfo(nTemplateId);
			if tbFurnitureInfo and tbFurnitureInfo.nType == Furniture.TYPE_LAND then
				HousePlant:PackupLand(dwOwnerId);
			end

			local bRemove, szMsg = House:TryRemoveFurniture(me.dwID, nTemplateId, nX, nY);
			if bRemove then
				Furniture:Add(me, nTemplateId);
				Log("[Furniture] Auto PackupFurniture ", me.dwID, me.szAccount, me.szName, nTemplateId, nX, nY);
			end
		end
		self.tbMapToRemoveInfo[nMapId] = nil;

		Mail:SendSystemMail({
			To = dwOwnerId,
			Title = "家俱收起通知",
			Text = "    大侠！由於家园扩建後格局发生了变化，[FFFE0D]部分家俱本姑娘已经帮你收回到家俱仓库了哦！[-]",
			From = "「家园管理员」真儿",
		});
	end

	Activity:OnGlobalEvent("Act_OnHouseMapEnter", me, nMapId)
end

function House:OnPlayerTrap(nMapId, szTrapName)
	local dwOwnerId = self:GetHouseInfoByMapId(nMapId);
	if szTrapName == "Out_sn" then
		if not House:CheckEnterAccess(me, dwOwnerId) then
			me.CenterMsg("对方房门紧闭，无法进入");
			return;
		end
		Pet:StopFollowPlayer(me)
	end
	self:DoPlayerTrap(szTrapName);
end

function House:DoPlayerTrap(szTrapName)
	local tbSetting = House:GetHouseSetting(me.nMapTemplateId);
	if not tbSetting then
		Log("[ERROR][House] trap failed! unknown house map: ", me.nMapTemplateId);
		return;
	end

	local varDst = tbSetting.tbTrapInfo[szTrapName];
	if type(varDst) == "table" then
		me.SetPosition(unpack(varDst));
		if not self:CheckCanRide(me) and me.GetActionMode() ~= Npc.NpcActionModeType.act_mode_none then
			me.CenterMsg("马儿在庭院拴着，室内还是步行吧");
			ActionInteract:UnbindLinkInteract(me);
			ActionMode:DoChangeActionMode(me, Npc.NpcActionModeType.act_mode_none);
		end
		me.CallClientScript("House:OnSyncSwitchPlace");
	elseif varDst == "GoBack" then
		me.GotoEntryPoint();
	end

	if szTrapName=="Out_ty" then
		local dwOwnerId = self:GetHouseInfoByMapId(me.nMapId)
		Pet:CallAround(me, dwOwnerId, false)
	end
end

function House:OnMapLogin(nMapId)

end

function House:OnMapLeave(nMapId)
	Activity:OnGlobalEvent("Act_OnHouseMapLeave", me, nMapId)
end

function House:OnMapDestroy(nMapId)
	local dwOwnerId = self:GetHouseInfoByMapId(nMapId);
	if dwOwnerId and self.tbHouseMapInfo[dwOwnerId].nMapId == nMapId then
		self.tbHouseMapInfo[dwOwnerId] = nil;
		Lib:CallBack({function () Item:GetClass("NpcLoveToken"):OnDestroyHouseMap(dwOwnerId, nMapId); end });
	end

	self.tbMapFurnitureInfo = self.tbMapFurnitureInfo or {};
	self.tbMapFurnitureInfo[nMapId] = nil;

	self.tbMapToRemoveInfo = self.tbMapToRemoveInfo or {};
	self.tbMapToRemoveInfo[nMapId] = nil;

	Activity:OnGlobalEvent("Act_OnHouseMapDestroy", nMapId)
end

function House:RegisterHouseMap(nMapTemplateId)
	local tbMap = Map:GetClass(nMapTemplateId);
	function tbMap:OnCreate(nMapId)
		House:OnMapCreate(nMapId);
	end

	function tbMap:OnEnter(nMapId)
		House:OnMapEnter(nMapId);
	end

	function tbMap:OnLogin(nMapId)
		House:OnMapLogin(nMapId);
	end

	function tbMap:OnLeave(nMapId)
		House:OnMapLeave(nMapId);
	end

	function tbMap:OnDestroy(nMapId)
		House:OnMapDestroy(nMapId);
	end

	function tbMap:OnPlayerTrap(nMapId, szTrapName)
		House:OnPlayerTrap(nMapId, szTrapName)
	end
end

for _, tbInfo in pairs(House.tbHouseSetting) do
	House:RegisterHouseMap(tbInfo.nMapTemplateId);
end

function House:DeleteMap(dwOwnerId, szMsg)
	local tbMapInfo = self.tbHouseMapInfo[dwOwnerId];
	if not tbMapInfo then
		return;
	end

	local nMapId = tbMapInfo.nMapId;
	local tbAllPlayer = KPlayer.GetMapPlayer(nMapId);
	for _, pOther in pairs(tbAllPlayer) do
		pOther.SendBlackBoardMsg(szMsg, true);
		pOther.GotoEntryPoint();
	end

	self.tbHouseMapInfo[dwOwnerId] = nil;

	Lib:CallBack({function () Item:GetClass("NpcLoveToken"):OnDestroyHouseMap(dwOwnerId, nMapId); end });
end
