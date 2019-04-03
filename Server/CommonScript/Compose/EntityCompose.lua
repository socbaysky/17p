Compose.EntityCompose = Compose.EntityCompose or {};
local EntityCompose = Compose.EntityCompose;
local nMaxChildCount = 8;

EntityCompose.tbChildInfo = {};
EntityCompose.tbTargeInfo = {};
EntityCompose.tbShowFragTemplates = {};

function EntityCompose:LoadSetting()

	local szTabPath = "Setting/Item/ItemCompose/EntityCompose.tab";
	local szParamType = "ddddsddds";
	local szKey = "TargetTemplateID";
	local tbParams = {"TargetTemplateID", "IsShowFrag", "NoSellAttachTarget", "IsHideTip", "ConsumeType","ConsumeCount", "BagSort", "KinMsg", "ValidTime",};
	for i=1,nMaxChildCount do
		szParamType = szParamType .."dd";
		table.insert(tbParams,"ChildTemplateID" ..i);
		table.insert(tbParams,"NeedCount" ..i);
	end
	local tbSettings = LoadTabFile(szTabPath, szParamType, szKey, tbParams);

	local tbPieceToId = {}
	for nTargetTemplateID,tbRowInfo in pairs(tbSettings) do
		assert(not self.tbTargeInfo[nTargetTemplateID], "EntityCompose assert fail repeat nTargetTemplateID")
		self.tbTargeInfo[nTargetTemplateID] = self.tbTargeInfo[nTargetTemplateID] or {}
		self.tbTargeInfo[nTargetTemplateID]["nBagSort"] = tbRowInfo.BagSort;
		if tbRowInfo.ConsumeType and tbRowInfo.ConsumeCount and tbRowInfo.ConsumeType ~= "" and tbRowInfo.ConsumeCount ~= 0 then
			self.tbTargeInfo[nTargetTemplateID]["szConsumeType"] = tbRowInfo.ConsumeType;
			self.tbTargeInfo[nTargetTemplateID]["nConsumeCount"] = tbRowInfo.ConsumeCount;	
			self.tbTargeInfo[nTargetTemplateID]["nKinMsg"] = tbRowInfo.KinMsg;	
		end
		if tbRowInfo.IsHideTip and tbRowInfo.IsHideTip == 1 then
			self.tbTargeInfo[nTargetTemplateID]["bIsHideTip"] = true
		end
		if tbRowInfo.NoSellAttachTarget and tbRowInfo.NoSellAttachTarget == 1 then
			self.tbTargeInfo[nTargetTemplateID]["bNoSellAttachTarget"] = true
		end
		for i=1,nMaxChildCount do
			local szChildKey = "ChildTemplateID" ..i;
			if tbRowInfo[szChildKey] and tbRowInfo[szChildKey] ~=0 then
				local nChildItemId = tbRowInfo[szChildKey];
				local nCount = tbRowInfo["NeedCount" ..i];
				assert(not self.tbChildInfo[nChildItemId], "EntityCompose assert fail repeat nChildItemId")
				self.tbChildInfo[nChildItemId] = nTargetTemplateID;
				self.tbTargeInfo[nTargetTemplateID][nChildItemId] = nCount;
				if tbRowInfo.IsShowFrag == 1 then
					self.tbShowFragTemplates[nChildItemId] = 1;
				end
			end
		end
		--合成道具的有效期
		if tbRowInfo.ValidTime and tbRowInfo.ValidTime ~= "" then 
			self.tbTargeInfo[nTargetTemplateID]["nValidTime"] = Lib:ParseDateTime(tbRowInfo.ValidTime)
		end
		tbPieceToId[tbRowInfo.ChildTemplateID1] = nTargetTemplateID
	end
	self.tbPieceToId = tbPieceToId
end

EntityCompose:LoadSetting();

function EntityCompose:CheckIsComposeMaterial(nTemplateId)

	local szMsg = "找不到该合成材料";
	if not nTemplateId then
		return false,szMsg;
	end
	local nTargetID = self.tbChildInfo[nTemplateId];
	if not nTargetID then
		return false,szMsg;
	end

	if not self.tbTargeInfo[nTargetID] then
		return false,szMsg;
	end

	if not self.tbTargeInfo[nTargetID][nTemplateId] then
		return false,szMsg;
	end

	return true;
end

function EntityCompose:GetIdFromPiece(nPieceId)
	return self.tbPieceToId[nPieceId]
end

--只能是一种碎片数量合成的，不然现在无法定出售(或者列NoSellAttachTarget配1也无法出售)
function EntityCompose:GetEquipComposeInfo(nTemplateId)
	local nTargetID = self.tbChildInfo[nTemplateId];
	local nNeedTotal = 0;
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	if tbTargeInfo.bNoSellAttachTarget then
		return
	end
	for nChildId,nNeed in pairs(tbTargeInfo) do
		if tonumber(nChildId) then
			if  nChildId ~= nTemplateId then
				return
			end
			nNeedTotal = nNeedTotal + nNeed
		end
		
	end
	return nTargetID, nNeedTotal
end

function EntityCompose:CheckIsCanCompose(pPlayer,nTemplateId)
	local nTargetID = self.tbChildInfo[nTemplateId];
	local bIsCan = true
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	for nChildId,nNeed in pairs(tbTargeInfo) do
		if tonumber(nChildId) then
			local nHave = pPlayer.GetItemCountInAllPos(nChildId);
			if nHave < nNeed then
				bIsCan = false
				break;
			end
		end
	end
	local szTip = string.format("您的材料不足，无法合成【%s】",KItem.GetItemShowInfo(nTargetID, pPlayer.nFaction, pPlayer.nSex));
	return bIsCan,szTip,nTargetID;
end

function EntityCompose:GetTip(it)
	local nTemplateId = it.dwTemplateId
	return self:GetMaterialList(nTemplateId)
end

function EntityCompose:GetMaterialList(nTemplateId, bColorTxt)
	if not self:CheckIsComposeMaterial(nTemplateId) then
		return ""
	end
	local nTargetID = self.tbChildInfo[nTemplateId];
	local tbTargeInfo = self.tbTargeInfo[nTargetID]
	local szTip = "";
	local szName = "";
	local nHave = 0;
    local szTxtColor = "[-]"
    if bColorTxt then
	    local _, _, _, nQuality = KItem.GetItemShowInfo(nTemplateId)
	    local _, _, _, _, szColor = Item:GetQualityColor(nQuality)
	    szTxtColor = "[" .. szColor .. "]"
    end
	for nChildId,nNeed in pairs(tbTargeInfo) do
		if tonumber(nChildId) and nChildId ~= nTemplateId then
			szName = KItem.GetItemShowInfo(nChildId, me.nFaction, me.nSex)
			nHave = me.GetItemCountInAllPos(nChildId);
			szTip = (szTip == "") and szTip or (szTip .. "\n")
			szTip = string.format("%s%s%s：[FFFE0D]%d/%d[-]", szTip, szTxtColor, szName,nHave,nNeed);
		end
	end
	return szTip;
end

function EntityCompose:IsNeedConsume(nTemplateId)
	local nTargetID = self.tbChildInfo[nTemplateId];
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.szConsumeType
end

function EntityCompose:GetConsumeInfo(nTemplateId)
	local nTargetID = self.tbChildInfo[nTemplateId];
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.szConsumeType,tbTargeInfo.nConsumeCount;
end

function EntityCompose:GetBagSort(nTemplateId)
	local nTargetID = self.tbChildInfo[nTemplateId];
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.nBagSort;
end


function EntityCompose:GetMaterialCount(nTemplateId)
	local nTargetID = self.tbChildInfo[nTemplateId] or 0
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	local nCount = 0
	for nChildId in pairs(tbTargeInfo) do
		if tonumber(nChildId) and nChildId ~= nTemplateId then
			nCount = nCount + 1
		end
	end
	return nCount
end