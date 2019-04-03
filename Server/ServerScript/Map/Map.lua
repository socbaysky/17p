
function Map:Init()

	self.tbTemplateMapList = self.tbTemplateMapList or {};

	-- Map基础模板，详细的在default.lua中定义
	self.tbMapBase	= self.tbMapBase or {};
	-- Map类库
	self.tbClass = self.tbClass or {};

	self.tbAllMapStatue = self.tbAllMapStatue or {};
end
Map:Init()

-- 取得特定ID的Map类
function Map:GetClass(nMapTemplateId, bNotCreate)
	local tbClass	= self.tbClass[nMapTemplateId];
	-- 如果没有bNotCreate，当找不到指定模板时会自动建立新模板
	if (not tbClass and bNotCreate ~= 1) then
		-- 新模板从基础模板派生
		tbClass	= Lib:NewClass(self.tbMapBase);
		tbClass.nMapTemplateId	= nMapTemplateId;

		tbClass.tbTransmit		= {};
		-- 加入到模板库里面
		self.tbClass[nMapTemplateId]	= tbClass;
	end
	return tbClass;
end

function Map:OnCreate(nMapTemplateId, nMapId)
	self.tbTemplateMapList[nMapTemplateId] = self.tbTemplateMapList[nMapTemplateId] or {};
	self.tbTemplateMapList[nMapTemplateId][nMapId] = true;

	local tbMap	= self:GetClass(nMapTemplateId);
	tbMap:OnCreate(nMapId);

	Fuben:OnCreateMap(nMapTemplateId, nMapId);
	if MODULE_ZONESERVER then   -- ZoneServer 就不往后了
		return;
	end

	BossLeader:OnCreateMap(nMapTemplateId, nMapId);
	PunishTask:OnCreateMap(nMapTemplateId, nMapId);
	SeriesFuben:OnCreateMap(nMapTemplateId, nMapId);
	Activity:OnGlobalEvent("Act_OnMapCreate", nMapTemplateId, nMapId)
	Lib:CallBack({Map.OnCrateaStatue, Map, nMapTemplateId, nMapId})
	Lib:CallBack({WeatherMgr.OnMapCreate, WeatherMgr, nMapId, nMapTemplateId});
	Lib:CallBack({ServerNpc.OnMapCreate, ServerNpc, nMapId, nMapTemplateId})
end

function Map:OnDestroy(nMapTemplateId, nMapId)
	if self.tbAllMapWaiYiInfo and self.tbAllMapWaiYiInfo[nMapId] then
		self.tbAllMapWaiYiInfo[nMapId] = nil;
	end
	self.tbTemplateMapList[nMapTemplateId] = self.tbTemplateMapList[nMapTemplateId] or {};
	self.tbTemplateMapList[nMapTemplateId][nMapId] = nil;

	Fuben:OnDestroyMap(nMapId);

	local tbMap	= self:GetClass(nMapTemplateId);
	tbMap:OnDestroy(nMapId);

	Lib:CallBack({Decoration.OnMapDestroy, Decoration, nMapTemplateId, nMapId});
	Lib:CallBack({WeatherMgr.OnMapDestroy, WeatherMgr, nMapId, nMapTemplateId});
end

function Map:OnEnter(nMapTemplateId, nMapId)

    local pNpc = me.GetNpc()
    if pNpc and pNpc.IsDeath() then
        me.Revive(1)
    end

	local szCurMapClassDesc = Map:GetClassDesc(nMapTemplateId)
	if szCurMapClassDesc == "city" then
		if me.nLastLeaveMap and Map:GetClassDesc(me.nLastLeaveMap) ~= "fight" then
			me.SetPkMode(0);		-- 从非野外回城重置一下PK模式
		end
	elseif szCurMapClassDesc ~= "fight" then
		if me.nLastLeaveMap and Map:GetClassDesc(me.nLastLeaveMap) == "city" then
			me.SetPkMode(0);		-- 从城市去非野外地图重置一下PK模式
		end
	end

	local forcePkMode = self:GetForcePkMode(nMapTemplateId)
	if forcePkMode and forcePkMode>0 then
		me.SetPkMode(forcePkMode)
		me.bForbidChangePk = 1
	end

	Lib:CallBack({WeatherMgr.OnMapEnter, WeatherMgr});

	Task:OnEnterMap();
	Fuben:OnEnter(nMapTemplateId, nMapId);

	TeamMgr:OnEnterMap(me, nMapTemplateId, nMapId);
	SeriesFuben:OnEnterMap(nMapTemplateId, nMapId)

	ImperialTomb:OnEnterAllMap(nMapTemplateId, nMapId)

	local tbMap	= self:GetClass(nMapTemplateId);
	tbMap:OnEnter(nMapId);

	me.OnEvent("OnEnterMap", nMapTemplateId, nMapId);
	Activity:OnPlayerEvent(me, "Act_OnEnterMap", nMapTemplateId, nMapId)

	local tbAct = Activity:GetClass("BeautyPageant")
	Lib:CallBack({tbAct.OnEnterMap, tbAct, me, nMapTemplateId, nMapId});

	local tbAct = Activity:GetClass("GoodVoice")
	Lib:CallBack({tbAct.OnEnterMap, tbAct, me, nMapTemplateId, nMapId});

	Lib:CallBack({Wedding.OnEnterMap, Wedding, nMapTemplateId, nMapId});

	Lib:CallBack({ZhenFa.OnEnterMap, ZhenFa, me, nMapId});
	Lib:CallBack({Map.CheckPushToPrison, Map, me});

	if self.tbAllMapWaiYiInfo and self.tbAllMapWaiYiInfo[nMapId] then
		me.CallClientScript("Map:OnSyncAllWaiYiInfo", nMapId, self.tbAllMapWaiYiInfo[nMapId]);
	end

	Log(me.dwID, nMapId, "Server Map:OnEnter......");
end

function Map:CheckPushToPrison(pPlayer)
	if pPlayer.CanPushPrison() and not pPlayer.IsInPrison() then
		local nTemplateId = pPlayer.nMapTemplateId;
		if Map:IsCityMap(nTemplateId) or (Map:IsFieldFightMap(nTemplateId) and pPlayer.nFightMode == 0) then
			local nPosX, nPosY = Map:GetDefaultPos(Map.PRISON_MAP_TEAMPLATE_ID);
			pPlayer.SwitchMap(Map.PRISON_MAP_TEAMPLATE_ID, nPosX, nPosY);
			return true;
		end
	end
	return false;
end

function Map:OnLeave(nMapTemplateId, nMapId)
	Wedding:ChangeDressState(me, false)

	local forcePkMode = self:GetForcePkMode(nMapTemplateId)
	if forcePkMode and forcePkMode>0 then
		me.bForbidChangePk = 0
	end

	Fuben:OnLeave(nMapTemplateId, nMapId);

	me.nLastLeaveMap = nMapTemplateId;	-- 记录玩家上次离开的地图模板

	local tbMap	= self:GetClass(nMapTemplateId);
	tbMap:OnLeave(nMapId);

	me.OnEvent("OnLeaveMap", nMapTemplateId, nMapId);
	Activity:OnPlayerEvent(me, "Act_OnLeaveMap", nMapTemplateId, nMapId)
	Lib:CallBack({Wedding.OnLeaveMap, Wedding, nMapTemplateId, nMapId});
	Lib:CallBack({ZhenFa.OnLeaveMap, ZhenFa, me, nMapId});
	Log(me.dwID, nMapId, "Server Map:OnLeave......");
end

function Map:OnPlayerTrap(nMapTemplateID, nMapID, szTrapName)
	if Task:CheckIsTaskTrap(me, nMapTemplateID, szTrapName) then
		if not Task:GetTaskTrapTrack(me, nMapTemplateID, szTrapName) then
			return;
		end
	end

	Task:OnPlayerTrap(nMapTemplateID, nMapID, szTrapName);
	Fuben:OnPlayerTrap(nMapID, szTrapName);

	local tbMap	= self:GetClass(nMapTemplateID);
	tbMap:OnPlayerTrap(nMapID, szTrapName);

	local tbTransSetting = self.tbTransferSetting[nMapTemplateID] or {};
	local tbTrapSetting = tbTransSetting[szTrapName];

	if tbTrapSetting then
		if tbTrapSetting.JumpKind > 0 then
			local nJumpSkillID = Faction:GetJumpSkillId(me.nFaction, tbTrapSetting.JumpKind);
			local bJumping = me.GetDoing() == Npc.Doing.jump;
			local bCanJump = not bJumping or tbTrapSetting.JumpGroup == me.szLastJumpGroup;

			if nJumpSkillID > 0 and bCanJump then
				ActionMode:DoForceNoneActMode(me, "目前不能骑马！");
				ActionInteract:UnbindLinkInteract(me);
				local pNpc = me.GetNpc();
				pNpc.DelayCastSkill(nJumpSkillID, 1, tbTrapSetting.ToPosX, tbTrapSetting.ToPosY);
				me.szLastJumpGroup = tbTrapSetting.JumpGroup;
			end

			if nJumpSkillID <= 0 then
				Log("Error Map:OnPlayerTrap nJumpSkillI", nMapTemplateID, nMapID, szTrapName);
			end
		elseif tbTrapSetting.ToMapID == me.nMapTemplateId then
			me.SetPosition(tbTrapSetting.ToPosX, tbTrapSetting.ToPosY);
		else
			local nToMapID = tbTrapSetting.ToMapID
			if me.nLevel < Map:GetEnterLevel(nToMapID) then
				me.CenterMsg(string.format("前往十分凶险，侠士需先升到%d级再来尝试", Map:GetEnterLevel(nToMapID)))
				return
			end

			if Map:IsTransForbid(nToMapID) then
				me.CenterMsg("无法前往该地图")
				Log("[Map OnPlayerTrap Error]", me.dwID, me.nMapID, szTrapName, nToMapID)
				return
			end

			if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
				return;
			end

			me.SwitchMap(self:GetMapIdByTemplate(nToMapID) or nToMapID, tbTrapSetting.ToPosX, tbTrapSetting.ToPosY);
		end
	end

	-- 对于野外地图, 设置和平区域
	if Map:IsFieldFightMap(nMapTemplateID) or Map:IsBossMap(nMapTemplateID) then

		local szMsg = nil;
		if szTrapName == "TrapPeace" and me.nFightMode ~= 0 then
			me.nFightMode = 0;
			szMsg = "已进入安全区";
		elseif szTrapName == "TrapFight" and me.nFightMode ~= 1 then
			me.nFightMode = 1;
			szMsg = "已进入野外区，可能会受到其他玩家的攻击";
		end

		if szMsg and me.nLevel < 40 then
			me.SendBlackBoardMsg(szMsg);
		end
	end
end

function Map:OnNpcTrap(nMapTemplateID, nMapID, szTrapName)
	Fuben:OnNpcTrap(nMapID, szTrapName)
	
	local tbMap	= self:GetClass(him.nMapTemplateId);
	tbMap:OnNpcTrap(nMapID, szTrapName)
	--Log(nMapTemplateID, szTrapName, "Server Map:OnNpcTrap.....");
end

function Map:OnLogin(nMapId)
	local tbMap	= self:GetClass(me.nMapTemplateId);
	tbMap:OnLogin(me.nMapId)
end

function Map:SwitchMap(nMapId, nRequestMapTemplateId)
	if not me.CanTranOpt() then
		return false, "当前所在地图不可进行传送";
	end

	if nMapId == me.nMapTemplateId then
		return;
	end
	if nMapId == Kin.Def.nKinMapTemplateId then
		return Map:SwitchKinMap(me);
	end

	if BossLeader:IsCrossBossMap(nRequestMapTemplateId, nMapId) then
		return BossLeader:ApplyEnterFuben(me, "Boss", nRequestMapTemplateId);
	end

	local nMapTemplateId, bFuben = GetMapInfoById(nMapId);
	if not nMapTemplateId then
		return false, "目标地图无法传送";
	end

	if House:IsNormalHouse(nMapTemplateId) then
		local dwOwnerId, tbMapInfo = House:GetHouseInfoByMapId(nMapId);
		if not dwOwnerId then
			return false, "此家园已升级扩建，该位置不存在";
		end
	end

	if WuLinDaShi:IsMyMap(nMapTemplateId) then
		local bRet, szMsg = WuLinDaShi:CheckEnter(me)
		if not bRet then
			return false, szMsg
		end
	end

	if nRequestMapTemplateId ~= nil and nRequestMapTemplateId ~= nMapTemplateId then
		return false, "目标地图无法传送";
	end

	local bRet = Map:IsForbidTransEnter(nMapTemplateId);
	if bRet then
		return false, "目标地图无法传送";
	end

	if bFuben and ImperialTomb:IsTombMap(nMapTemplateId)then
		return ImperialTomb:SwitchMapDirectly(nMapId, nMapTemplateId);
	end

	if bFuben and Fuben.WhiteTigerFuben:IsPrepareMap(nMapTemplateId) then
		return Fuben.WhiteTigerFuben:TryEnterPrepareMap(me)
	end

	if bFuben and BossLeader:IsBossLeaderMap(nMapTemplateId, "Boss") then
		return BossLeader:ApplyEnterFuben(me, "Boss", nMapTemplateId)
	end

	if bFuben and (not Map:IsHouseMap(nMapTemplateId)) then
		return false, "不可由此进入副本";
	end

	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		return false, "目前状态不允许切换地图";
	end

	local nMapLevel = Map:GetEnterLevel(nMapTemplateId);
	if me.nLevel < nMapLevel then
		return false, string.format("达到%d级才可进入该地图", nMapLevel);
	end

	if not Map:IsTimeFrameOpen(nMapTemplateId) then
		return false, "目前地图尚未开放";
	end

	if (Map:IsFieldFightMap(me.nMapTemplateId) or
	 BossLeader:IsBossLeaderMap(me.nMapTemplateId) or
	 ImperialTomb:IsTombMap(me.nMapTemplateId)) and me.nFightMode == 1 then	-- 野外传送读条
		GeneralProcess:StartProcess(me, 5 * Env.GAME_FPS, "传送中...", self.SwitchMapDirectly, self, nMapId, nMapTemplateId);
		return true;
	end

	return Map:SwitchMapDirectly(nMapId, nMapTemplateId);
end

function Map:SwitchKinMap(pPlayer)
	if not pPlayer then
		pPlayer = me;
	end

	local nKinId = pPlayer.dwKinId;
	local nMemberId = pPlayer.dwID;
	if nKinId == 0 then
		return false, "你没有帮派";
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
		return false, "目前状态不允许切换地图";
	end

	if (Map:IsFieldFightMap(pPlayer.nMapTemplateId) or BossLeader:IsBossLeaderMap(pPlayer.nMapTemplateId)) and pPlayer.nFightMode == 1 then
		GeneralProcess:StartProcess(pPlayer, 5 * Env.GAME_FPS, "传送中...", function ()
			local kinData = Kin:GetKinById(nKinId);
			return kinData:GoMap(nMemberId);
		end);

		return true;
	end

	return Kin:GoKinMap(pPlayer);
end

function Map:SwitchMapDirectly(nMapId, nMapTemplateId)
	local nPosX, nPosY = Map:GetDefaultPos(nMapTemplateId);
	me.SwitchMap(nMapId, nPosX, nPosY);
	return true;
end

function Map:ClientRequest(szType, ...)
	if szType == "SwitchMap" then
		local bSuccess, szInfo = Map:SwitchMap(...);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	end
end

--需要跨服的添加
function Map:SwitchZoneMap(nMapId, nRequestMapTemplateId)
	if not me.CanTranOpt() then
		return false, "当前所在地图不可进行传送";
	end

	local nMapTemplateId, bFuben = GetMapInfoById(nMapId);
	if not nMapTemplateId then
		return false, "目标地图无法传送";
	end

	if nRequestMapTemplateId ~= nil and nRequestMapTemplateId ~= nMapTemplateId then
		return false, "目标地图无法传送";
	end

	local bRet = Map:IsForbidTransEnter(nMapTemplateId);
	if bRet then
		return false, "目标地图无法传送";
	end

	if bFuben and BossLeader:IsBossLeaderMap(nMapTemplateId, "Boss") then
		return BossLeader:ApplyEnterFuben(me, "Boss", nMapTemplateId)
	end

	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		return false, "目前状态不允许切换地图";
	end

	local nMapLevel = Map:GetEnterLevel(nMapTemplateId);
	if me.nLevel < nMapLevel then
		return false, string.format("达到%d级才可进入该地图", nMapLevel);
	end

	return false, "当前所在地图不可进行传送";
end

--需要跨服的添加
function Map:ClientRequestZ(szType, ...)
    if szType == "SwitchMap" then
		local bSuccess, szInfo = Map:SwitchZoneMap(...);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	end
end

function Map:GetMapIdByTemplate(nMapTemplateId)
	local tbList = self.tbTemplateMapList[nMapTemplateId];
	if not tbList then
		return nil
	end

	for nMapId,_ in pairs(tbList) do
		return nMapId
	end

	return nil
end

function Map:OnCrateaStatue(nMapTemplateId, nMapId)
    local tbMapStatue = self.tbAllMapStatue[nMapId];
    if not tbMapStatue then
    	return;
    end

    for _, tbTypeStatue in pairs(tbMapStatue) do
    	for _, tbStatue in pairs(tbTypeStatue.tbAllStatue) do
    		self:CreateMapStatueNpc(nMapId, tbStatue);
    	end
    end
end

function Map:CreateMapStatueNpc(nMapId, tbStatue)
	if tbStatue.nCreateNpcID then
		Log("Error CreateMapStatueNpc CreateNpcID", tbStatue.nNpcTID, nMapId);
		return;
	end

	local pNpc = KNpc.Add(tbStatue.nNpcTID, 1, 0, nMapId, tbStatue.nX, tbStatue.nY, 0, tbStatue.nDir);
	if not pNpc then
		Log("Error CreateMapStatueNpc", tbStatue.nNpcTID, nMapId);
		return
	end

	pNpc.SetName(tbStatue.szName);
	if tbStatue.nTitleID then
		pNpc.SetTitleID(tbStatue.nTitleID);
	elseif not Lib:IsEmptyStr(tbStatue.szTitle) then
		pNpc.SetTitle(tbStatue.szTitle);
	end

	tbStatue.nCreateNpcID = pNpc.nId;
end

function Map:ClearMapStatue(nMapId, szType)
    local tbMapStatue = self.tbAllMapStatue[nMapId];
    if not tbMapStatue then
    	return;
    end

	local tbTypeStatue = tbMapStatue[szType];
	if not tbTypeStatue then
		return;
	end

	for _, tbStatue in pairs(tbTypeStatue.tbAllStatue) do
		if tbStatue.nCreateNpcID then
			local pNpc = KNpc.GetById(tbStatue.nCreateNpcID);
            if pNpc then
                pNpc.Delete();
            end
		end
    end

    tbMapStatue[szType] = nil;
    Log("Map ClearMapStatue", szType, nMapId);
end

function Map:GetMapStatueType(nMapId, szType)
    self.tbAllMapStatue[nMapId] = self.tbAllMapStatue[nMapId] or {};
    local tbMapStatue = self.tbAllMapStatue[nMapId];
    tbMapStatue[szType] = tbMapStatue[szType] or {};
    local tbStatueType = tbMapStatue[szType];
    tbStatueType.tbMiniMap = tbStatueType.tbMiniMap or {};
    tbStatueType.tbAllStatue = tbStatueType.tbAllStatue or {};
    return tbStatueType;
end

function Map:AddMapStatue(nMapId, szType, tbStatue)
	local tbTypeStatue = Map:GetMapStatueType(nMapId, szType);
    table.insert(tbTypeStatue.tbAllStatue, tbStatue);
  	local bFinish = IsLoadFinishMap(nMapId);
    if bFinish then
    	Map:CreateMapStatueNpc(nMapId, tbStatue);
    end

    Log("Map AddMapStatue", nMapId, szType, tbStatue.nNpcTID);
end

function Map:RequestMiniStatueData(pPlayer, nMapId)
    local tbMapStatue = self.tbAllMapStatue[nMapId];
    if not tbMapStatue then
    	return;
    end

    local tbSyncData = {};
    tbSyncData.nMapId = nMapId;
    tbSyncData.tbShow = {};
    for _, tbInfo in pairs(tbMapStatue) do
    	if tbInfo.tbMiniMap then
    		for szType, szName in pairs(tbInfo.tbMiniMap) do
    			tbSyncData.tbShow[szType] = szName;
    		end
    	end
    end

    pPlayer.CallClientScript("Player:ServerSyncData", "MiniStatue", tbSyncData);
end

-- 临安城通用事件回调
function Map:InitLinAnMapCallBack()
	local fnOnPlayerTrap = function (tbMap, nMapId, szTrapName)
		Lib:CallBack({Wedding.tbDoubleFly.OnPlayerLinAnTrap, Wedding.tbDoubleFly, me, szTrapName, nMapId});
	end;
	local tbMapClass = Map:GetClass(15)
	tbMapClass.OnPlayerTrap = fnOnPlayerTrap;
end

Map:InitLinAnMapCallBack()