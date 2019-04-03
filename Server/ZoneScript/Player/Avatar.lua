
local nMaxStoneCount = 15 			-- 魂石数量扩展
function Player:LoadAvatarSetting()
	self.tbAvatarEquip = {}
	self.tbAvatarInset = {}
	self.tbAvatarSkill = {};
	
	local tbEquipSetting = LoadTabFile("Setting/Avatar/Equip.tab", "sd", nil, {"Key", "EquipId"});

	local szTabPath = "Setting/Avatar/Inset.tab";
	local szParamType = "sd";
	local tbParams = {"Key", "EquipPos"};
	for i=1, nMaxStoneCount do
		szParamType = szParamType .."d";
		table.insert(tbParams, "StoneId" ..i);
	end
	local tbInsetSetting = LoadTabFile(szTabPath, szParamType, nil, tbParams);
	
	for _, tbInfo in pairs(tbEquipSetting) do
		self.tbAvatarEquip[tbInfo.Key] = self.tbAvatarEquip[tbInfo.Key] or {};
		table.insert(self.tbAvatarEquip[tbInfo.Key], tbInfo.EquipId)
	end
	
	for _,v in pairs(tbInsetSetting) do
		self.tbAvatarInset[v.Key] = self.tbAvatarInset[v.Key] or {};
		local tbStone = {}
		for i=1, nMaxStoneCount do
			local nStoneId = v["StoneId" ..i] or 0
			if nStoneId ~= 0 then
				table.insert(tbStone, nStoneId)
			end
		end
		self.tbAvatarInset[v.Key][v.EquipPos] = tbStone;
	end
end

Player:LoadAvatarSetting()

function Player:ChangePlayer2Avatar(pPlayer, nFaction, nLevel, szEquipKey, szInsetKey, nEnhLevel, tbBookType, bNotAddSkill)
	local nSex = Player:Faction2Sex(nFaction, pPlayer.nSex);
	if pPlayer.Change2Avatar(nFaction, nLevel, nSex, bNotAddSkill and 1 or 0) then
		Lib:CallBack({ZhenFa.OnPlayerAdvatar, ZhenFa, pPlayer});
		GameSetting:SetGlobalObj(pPlayer);
		local tbFightPowerData = pPlayer.GetScriptTable("FightPower");
		for szKey, _ in pairs(tbFightPowerData) do
			tbFightPowerData[szKey] = nil
		end
		-- 装备
		if szEquipKey and self.tbAvatarEquip[szEquipKey] then
			local tbSetting = self.tbAvatarEquip[szEquipKey];
			for _, nEquipTemplateId in ipairs(tbSetting) do
				local pEquip = pPlayer.AddItem(nEquipTemplateId, 1);
				pPlayer.UseEquip(pEquip.dwId, -1);
			end
		end
				
		local tbAllEquips = pPlayer.GetEquips();
		-- 镶嵌
		if szInsetKey and self.tbAvatarInset[szInsetKey] then
			for nEquipPos, nEquipId in pairs(tbAllEquips) do
		    	local tbInsetSetting = self.tbAvatarInset[szInsetKey][nEquipPos];
		    	local nInsetPos = 0
		    	for _, nStoneTemplateId in pairs(tbInsetSetting) do
		    		if nStoneTemplateId ~= 0 then
		    			nInsetPos = nInsetPos + 1;
		    			pPlayer.SetInsetInfo(nEquipPos, nInsetPos, nStoneTemplateId)
		    			local nInsetKey = StoneMgr:GetInsetValueKey(nEquipPos, nInsetPos)
						pPlayer.SetUserValue(StoneMgr.USER_VALUE_GROUP,  nInsetKey, nStoneTemplateId)
			    		--StoneMgr:DoInset(pPlayer, nEquipPos, nEquipId, nStoneTemplateId, nil, nInsetPos);
		    		end
		    	end
	    	end
	    end
	    StoneMgr:UpdateInsetAttrib(pPlayer)
	    
	    -- 强化
	    if nEnhLevel and nEnhLevel > 0 then
			for nEquipPos, nEquipId in pairs(tbAllEquips) do
				pPlayer.SetStrengthen(nEquipPos, nEnhLevel)
				pPlayer.SetUserValue(Strengthen.USER_VALUE_GROUP, nEquipPos + 1, nEnhLevel)
	
				--突破次数
				local nBreakCount 	= Strengthen:GetPlayerBreakCount(pPlayer, nEquipPos);
				local nNeed 		= Strengthen:GetNeedBreakCount(nEnhLevel);
				Strengthen:SetPlayerBreakCount(pPlayer, nEquipPos, nNeed)
			end
		end
		Strengthen:UpdateEnhAtrrib(pPlayer)

		--聚宝盆
		pPlayer.tbTmpMagicBowlData = nil
		
		if not bNotAddSkill then
			self:AvatarUpdateSkillLevel(pPlayer, nFaction, nLevel)
		end
		
		pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, nLevel + 19);	

		if tbBookType then
			Player:SkillBook(pPlayer, tbBookType)
		end

		pPlayer.ClearPartnerInfo();
		FightPower:OnLogin(pPlayer);

		local pNpc = pPlayer.GetNpc()
		pNpc.SetCurLife(pNpc.nMaxLife)
		
		GameSetting:RestoreGlobalObj()
		pPlayer.CallClientScript("PlayerEvent:OnReConnectZoneClient")
		return true;
	end
	return false;
end

function Player:AvatarUpdateSkillLevel(pPlayer)
	local nFaction = pPlayer.nFaction;
	local nLevel = pPlayer.nLevel
	local szSkillKey = nFaction.."_"..nLevel
	if not self.tbAvatarSkill[szSkillKey] then
		self.tbAvatarSkill[szSkillKey] = {}
		local tbFactionSkill = FightSkill:GetFactionSkill(nFaction);
		for _,v in pairs(tbFactionSkill) do
			local nSkillId = v.SkillId;
			local tbLevelUp = FightSkill.tbSkillLevelUp[nSkillId];
			if tbLevelUp then
				local nSkillMaxLevel = FightSkill:GetSkillMaxLevel(nSkillId);
				local nToLevel = nSkillMaxLevel;
	
				for i = 1, nSkillMaxLevel do
					local tbNeed = tbLevelUp[i];
					local nReqLevel = tbNeed[1];
					if nLevel < nReqLevel then
						nToLevel = i - 1;
						break;
					end
				end
				table.insert(self.tbAvatarSkill[szSkillKey], {nSkillId, nToLevel})
			end
		end
	end
	for _, tbSkillInfo in pairs(self.tbAvatarSkill[szSkillKey]) do
		local nSkillId, nToLevel = unpack(tbSkillInfo)
		local _, nBaseLevel = pPlayer.GetSkillLevel(nSkillId);
		if nToLevel > 1 and nToLevel > nBaseLevel then
			pPlayer.LevelUpFightSkill(nSkillId, nToLevel - nBaseLevel)
		end
	end
end

function Player:AvatarRelogin(pPlayer)
	FightPower:OnLogin(pPlayer);
	pPlayer.CallClientScript("PlayerEvent:OnReConnectZoneClient")
end

function Player:SkillBook(pPlayer, tbBookType)
	local nEquipPos = Item.EQUIPPOS_SKILL_BOOK - 1
	local tbSkillBook = Item:GetClass("SkillBook");
	for _, nType in ipairs(tbBookType or {}) do
		local nBookId = tbSkillBook:GetFactionTypeBook(nType, pPlayer.nFaction)
		local tbBookInfo = tbSkillBook:GetBookInfo(nBookId);
		if tbBookInfo then
			local pItem = pPlayer.AddItem(nBookId, 1, nil, Env.LogWay_Avatar)
			if pItem then
				nEquipPos = nEquipPos + 1
				if tbSkillBook:CheckUseEquip(pPlayer, pItem, nEquipPos) then
					pItem.SetIntValue(tbSkillBook.nSaveSkillLevel, tbBookInfo.MaxSkillLevel);
					pItem.SetIntValue(tbSkillBook.nSaveBookLevel, tbBookInfo.MaxBookLevel);
					pItem.ReInit();	
					pPlayer.UseEquip(pItem.dwId, nEquipPos);
				end
			end
		end
	end
end