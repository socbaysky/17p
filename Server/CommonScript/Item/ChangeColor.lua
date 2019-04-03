
Require("CommonScript/Faction.lua")

Item.tbChangeColor 	= Item.tbChangeColor or {};
local tbChangeColor = Item.tbChangeColor;

tbChangeColor.MAX_COLOR = 8
tbChangeColor.CONSUME_ITEM = 2569;
tbChangeColor.MAX_FACTION = Faction.MAX_FACTION_COUNT
tbChangeColor.INIT_CHARM_VALUE = 100

tbChangeColor.GROUP_WAIYI_GB = 145
tbChangeColor.VALUE_WAIYI_GB_SELECT = 1
tbChangeColor.VALUE_WAIYI_GB = 2

-- 存储使用道具后显示的外装
tbChangeColor.ITEM_INT_VALUE_WAIYI_LIMIT = 1;

function tbChangeColor:Init()
	local szParam = "ddd"
	local tbConlumn = {"ChangeId", "Part", "CharmExtern"}
	for i = 1, self.MAX_COLOR do
		szParam = szParam.."ddd";
		table.insert(tbConlumn, "ColorItem"..i);
		table.insert(tbConlumn, "ConsumeItem"..i);
		table.insert(tbConlumn, "ConsumeCount"..i);
	end
	for i = 1, self.MAX_FACTION do
		szParam = szParam.."ss";
		table.insert(tbConlumn, "NameFacionMale"..i);
		table.insert(tbConlumn, "NameFacionFemale"..i)
	end
 	local tbSetting = LoadTabFile("Setting/Item/WaiyiColor.tab", szParam, nil, tbConlumn);

	self.tbColorItem = {};
	self.tbSortGroup = {};
	self.tbConsume = {};
	self.tbCharm = {};

	for _, tbInfo in ipairs(tbSetting) do
		local tbGroup = {nId = tbInfo.ChangeId, nPart = tbInfo.Part, nCharmExtern = tbInfo.CharmExtern,
			tbItemList = {}, tbNameList = {}, tbItemSort = {}};
		table.insert(self.tbSortGroup, tbGroup);
		for i = 1, self.MAX_COLOR do
			local nItemId = tbInfo["ColorItem"..i];
			--local szItemName = tbInfo["ColorName"..i];
			if nItemId and nItemId > 0 then
				if not self.tbColorItem[nItemId] then
					self.tbColorItem[nItemId] = tbGroup;
					local nConsumeItem, nConsumeCount = tbInfo["ConsumeItem"..i], tbInfo["ConsumeCount"..i]
					self.tbConsume[nItemId] = { nConsumeItem, nConsumeCount };
					tbGroup.tbItemList[nItemId] = true;
					table.insert(tbGroup.tbItemSort, nItemId);
				else
					Log("Equip Color is Already Exist!!!", nItemId);
				end
			end
		end
		for i = 1, self.MAX_FACTION do
			tbGroup.tbNameList[i] = { tbInfo["NameFacionMale"..i], tbInfo["NameFacionFemale"..i]};
		end
	end


	self.tbWaiyiRes = {}
	local tbRes = LoadTabFile("Setting/Item/EquipShow.tab", "dsdd", nil, {"ShowType", "Faction", "Sex", "ResId"});
	for _, tbInfo in ipairs(tbRes) do
		if tbInfo.ResId > 0 then
			local tbFactions = Lib:SplitStr(Lib:StrTrim(tbInfo.Faction, "\""), "|")
			for _, szFaction in ipairs( tbFactions ) do
				local nFaction = tonumber(szFaction);
				self.tbWaiyiRes[tbInfo.ShowType] = self.tbWaiyiRes[tbInfo.ShowType] or {}
				self.tbWaiyiRes[tbInfo.ShowType][nFaction] = self.tbWaiyiRes[tbInfo.ShowType][nFaction] or {};
				self.tbWaiyiRes[tbInfo.ShowType][nFaction][tbInfo.Sex] = tbInfo.ResId;
			end
		end
	end

	self.tbWaiyiBg = LoadTabFile("Setting/Item/WaiyiBg.tab", "dsssss", "BgId", {"BgId", "BgName", "BgTipsPic", "BgTexture","ViewBgTexture", "RequirementText",});

	self.tbWaiyiLimitItem = LoadTabFile("Setting/Item/WaiyiLimitColor.tab", "ddd", "LimitColorItem", {"LimitColorItem", "OrgColorItem", "Position"});
end

tbChangeColor:Init();

function tbChangeColor:CanChangeColor(dwTemplateId)
	if not self.tbColorItem[dwTemplateId] then
		return false;
	end
	return true;
end

function tbChangeColor:GetConsumeInfo(dwTemplateId)
	if not self.tbConsume[dwTemplateId] then
		return ;
	end
	return unpack(self.tbConsume[dwTemplateId])
end

function tbChangeColor:GetLimitItemInfo(dwTemplateId)
	return self.tbWaiyiLimitItem[dwTemplateId];
end

function tbChangeColor:GetChangeId(dwTemplateId)
	if self.tbColorItem[dwTemplateId] then
		return self.tbColorItem[dwTemplateId].nId
	end
end

function tbChangeColor:GetChangePart(dwTemplateId)
	if self.tbColorItem[dwTemplateId] then
		return self.tbColorItem[dwTemplateId].nPart
	end
end

function tbChangeColor:GetWaiZhuanRes(dwTemplateId, nFaction, nSex)
	local nShowType = KItem.GetEquipShowType(dwTemplateId)
	if not nShowType then
		return 0;
	end

	if not self.tbWaiyiRes[nShowType] or not self.tbWaiyiRes[nShowType][nFaction] then
		return 0
	end
	
	-- 优先获得无性别装备
	if self.tbWaiyiRes[nShowType][nFaction][0] then
		return self.tbWaiyiRes[nShowType][nFaction][0];
	end

	return self.tbWaiyiRes[nShowType][nFaction][nSex] or 0;
end

function tbChangeColor:DoChangeColorDialogCallback(nItemId, nTargetId, bConfirm)
	self:DoChangeColor(me, nItemId, nTargetId, bConfirm)
end

function tbChangeColor:DoChangeColor(pPlayer, nItemId, nTargetId, bConfirm)
	local pItem;
	local tbItemGroup = {}
	local tbInfo = self.tbColorItem[nTargetId]
	local nConsumeItem, nConsumeCount = self:GetConsumeInfo(nTargetId)
	if not tbInfo then
		return;
	end
	
	if not (nConsumeItem and nConsumeCount and nConsumeItem > 0 and nConsumeCount > 0) then
		print("For free?", nConsumeCount, nConsumeItem)
		return;		-- 应该没有免费染色的
	end

	local tbOptList = {}
	for nId, _ in pairs(tbInfo.tbItemList) do
		local tbItemList = pPlayer.FindItemInPlayer(nId)
		for _, pCurItem in pairs(tbItemList) do
			if pCurItem.dwTemplateId == nTargetId then
				pPlayer.CenterMsg("此外装您已经拥有了这款颜色。");
				return;
			end
			local szName = KItem.GetItemShowInfo(nId, pPlayer.nFaction, pPlayer.nSex)
			table.insert(tbItemGroup, pCurItem)
			table.insert(tbOptList, {Text = szName, Callback = self.DoChangeColorDialogCallback, Param = {self, pCurItem.dwId, nTargetId, true}})
		end
	end
	pItem = pPlayer.GetItemInBag(nItemId);

	if not pItem then
		pPlayer.CenterMsg("外装不存在！")
		return;
	end
	if not self:CanChangeColor(pItem.dwTemplateId) then
		pPlayer.CenterMsg("该装备不可染色！")
		return
	end

	if not tbInfo.tbItemList[pItem.dwTemplateId] then
		pPlayer.CenterMsg("此外装不能染为目标颜色");
		return;
	end

	if not self:CanColorItemShow(pPlayer, nTargetId) then
		pPlayer.CenterMsg("不存在该外装偏色");
		return;
	end

	if pPlayer.ConsumeItemInBag(nConsumeItem, nConsumeCount, Env.LogWay_ChangeColor, nil, nTargetId) < nConsumeCount then
		local tbBaseProp = KItem.GetItemBaseProp(nConsumeItem);
		pPlayer.CenterMsg(string.format("您身上的%s不足，不能进行染色", tbBaseProp.szName));
		return;
	end

	pPlayer.AddItem(nTargetId)
	
	self:UpdateRank(pPlayer)
	pPlayer.CenterMsg("染色成功！");
end

function tbChangeColor:ItemHasShowColor(pItem, nPos)
	local nSaveValue = pItem.GetIntValue(self.ITEM_INT_VALUE_WAIYI_LIMIT);
	return KLib.GetBit(nSaveValue, nPos) == 1;
end

function tbChangeColor:CanColorItemShow(pPlayer, dwTemplateId)
	local tbLimitInfo = self:GetLimitItemInfo(dwTemplateId);
	if not tbLimitInfo then
		return true;
	end

	local pOrgColorItem = unpack(pPlayer.FindItemInPlayer(tbLimitInfo.OrgColorItem) or {});
	if not pOrgColorItem then
		return false;
	end

	return self:ItemHasShowColor(pOrgColorItem, tbLimitInfo.Position);
end

function tbChangeColor:AddShowColor(pPlayer, nTargetId)
	local tbLimitInfo = self:GetLimitItemInfo(nTargetId);
	if not tbLimitInfo then
		pPlayer.CenterMsg("对应外装偏色不存在");
		return false;
	end

	local szOrgItemName = KItem.GetItemShowInfo(tbLimitInfo.OrgColorItem, pPlayer.nFaction, pPlayer.nSex);
	local pOrgColorItem = unpack(pPlayer.FindItemInPlayer(tbLimitInfo.OrgColorItem) or {});
	if not pOrgColorItem then
		pPlayer.CenterMsg(string.format("您尚未拥有初始外装[ffff00]%s[-]，请收藏该外装後再试试", szOrgItemName))
		return false;
	end

	if self:ItemHasShowColor(pOrgColorItem, tbLimitInfo.Position) then
		pPlayer.CenterMsg("你已经学习过该染色方案，不可重复学习哦");
		return false;
	end

	local nSaveValue = pOrgColorItem.GetIntValue(self.ITEM_INT_VALUE_WAIYI_LIMIT);
	nSaveValue = KLib.SetBit(nSaveValue, tbLimitInfo.Position, 1);
	pOrgColorItem.SetIntValue(self.ITEM_INT_VALUE_WAIYI_LIMIT, nSaveValue);

	local szItemName = KItem.GetItemShowInfo(nTargetId, pPlayer.nFaction, pPlayer.nSex);
	pPlayer.CenterMsg(string.format("您已学会[ffff00]%s[-]的染色方案，记得染色後使用该外装哦！", szItemName));
	return true;
end

function tbChangeColor:GetTotalCharm(tbAllWaiyi)
	local tbChangeId = {}
	local tbHasWaiyi = {}
	local nTotalCharm = self.INIT_CHARM_VALUE;		-- 角色初始魅力值
	for _, pCurItem in pairs(tbAllWaiyi)do
		local nTemplateId = pCurItem.dwTemplateId
		
		if (not tbHasWaiyi[nTemplateId]) and (self.tbColorItem[nTemplateId]) then
			tbHasWaiyi[nTemplateId] = true;
			local nChangeId = self.tbColorItem[nTemplateId].nId
			local nCharmFirst, nCharmNext = self:GetCharmInfo(nTemplateId)
			if not tbChangeId[nChangeId] then
				tbChangeId[nChangeId] = true;
				nTotalCharm = nTotalCharm + nCharmFirst
			else
				nTotalCharm = nTotalCharm + nCharmNext
			end
		end
	end
	return nTotalCharm;
end

function tbChangeColor:GetCharmInfo(dwTemplateId)
	if not self.tbCharm[dwTemplateId] then
		local nConsumeItem, nConsumeCount = self:GetConsumeInfo(dwTemplateId)
		if nConsumeItem and nConsumeItem > 0 and nConsumeCount and nConsumeCount > 0 then
			local tbItemInfo = KItem.GetItemBaseProp(nConsumeItem)
			if tbItemInfo then
				local nItemCharm = math.floor(tbItemInfo.nValue * nConsumeCount / 100000);
				self.tbCharm[dwTemplateId] = { (self.tbColorItem[dwTemplateId].nCharmExtern or 0) + nItemCharm, nItemCharm};
			end
		end
	end
	if self.tbCharm[dwTemplateId] then
		return unpack(self.tbCharm[dwTemplateId])
	end
end

tbChangeColor.tbTypeToAchieve = {
	[Item.EQUIP_WAIYI] = "Clothes_1";
	[Item.EQUIP_WAI_WEAPON] = "Arms_1";
	[Item.EQUIP_WAI_HEAD] = "Hat_1";
}

function tbChangeColor:UpdateRank(pPlayer)
	local nOldCharm = self:GetCacheCharm(pPlayer)
	local nTotalCharm, tbTypeCount = self:GetCacheCharm(pPlayer, true)
	Achievement:SetCount(pPlayer, "Charm_1", nTotalCharm)
	if tbTypeCount then
		for k,v in pairs(self.tbTypeToAchieve) do
			local nConut = tbTypeCount[k]
			if nConut then
				Achievement:SetCount(pPlayer, v, nConut)
			end
		end
	end
	RankBoard:UpdateRankVal("Charm", pPlayer.dwID, nTotalCharm)
	pPlayer.CallClientScript("Ui:OpenWindow", "CharmTip", nTotalCharm, nOldCharm)
end

function tbChangeColor:GetCacheCharm(pPlayer, bForceUpdate)
	local tbTypeCount;
	if not pPlayer.nCacheCharm or bForceUpdate  then
		local tbAllWaiyi = pPlayer.FindItemInPlayer("waiyi");
		tbTypeCount = {};
		for i,v in ipairs(tbAllWaiyi) do
			tbTypeCount[v.nItemType] = (tbTypeCount[v.nItemType] or 0) + 1
		end
		pPlayer.nCacheCharm = self:GetTotalCharm(tbAllWaiyi);
	end
	return pPlayer.nCacheCharm, tbTypeCount
end

function tbChangeColor:UnlockBg(pPlayer, nBgId)
	if not self.tbWaiyiBg[nBgId] then
		return;
	end
	if nBgId <= 32 and nBgId > 0 then
		local nValue = pPlayer.GetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB)
		nValue = KLib.SetBit(nValue, nBgId, 1)
		pPlayer.SetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB, nValue)
		return true
	end
end

function tbChangeColor:IsUnlockedBg(pPlayer, nBgId)
	if nBgId == 1 then
		return true;	-- 第一张图默认是开启的
	end
	if nBgId <= 32 and nBgId > 0 then
		local nValue = pPlayer.GetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB)
		return (KLib.GetBit(nValue, nBgId, 1) == 1);
	end
end

function tbChangeColor:ChangeWaiyiBg(pPlayer, nBgId)
	if not self:IsUnlockedBg(pPlayer, nBgId) then
		return;
	end
	pPlayer.SetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB_SELECT, nBgId)
	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID)
	if pAsync then
		pAsync.SetWaiyiBgId(nBgId)
	end

	pPlayer.CallClientScript("Item.tbChangeColor:UpdateBg")
end

function tbChangeColor:GetWaiyiBg(pPlayer)
	local nGbId = pPlayer.GetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB_SELECT)
	if nGbId == 0 then
		nGbId = 1;
	end
	
	return nGbId;
end

function tbChangeColor:UpdateBg()
	local tbUi = Ui("WaiyiPreview")
	if tbUi and Ui:WindowVisible("WaiyiPreview") then
		tbUi:UpdateBg();
	end
end
