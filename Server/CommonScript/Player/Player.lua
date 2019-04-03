Require("CommonScript/Shop/Shop.lua")

local function AddUnknowAward(pPlayer, nLogReazon, nLogReazon2, szType, ...)
	Log("Player Add Award Fail !! Unknow Type: ", szType, ...);
end

local function AddEmptyAward(pPlayer, nLogReazon, nLogReazon2, szType, ...)
	Log("AddEmptyAward", pPlayer.szName, pPlayer.dwID);
end

local function AddItem(pPlayer, nLogReazon, nLogReazon2, szType, nItemTemplateId, nCount, varTimeOut, bForbidStall)
	nLogReazon2 = nLogReazon2 or 0;
	local pItem = pPlayer.AddItem(nItemTemplateId, nCount, varTimeOut, nLogReazon, nLogReazon2, 0, 0, not not bForbidStall);
	if not pItem then
		Log("_LuaPlayer.AddItem fail !! pItem is nil !! ", pPlayer.szName, pPlayer.dwID, nItemTemplateId, nCount, varTimeOut,nLogReazon, nLogReazon2, tostring(bForbidStall));
		return;
	end

	-- LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, "item_" .. nItemTemplateId, nCount, nLogReazon);
	Log("player add item", pPlayer.szName, pPlayer.dwID, pItem.dwId, nItemTemplateId, nCount, tostring(varTimeOut), tostring(bForbidStall))
end

local function AddMoney(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if szType == "coin" then
		szType = "Coin"
	elseif szType == "gold" then
		szType = "Gold"
	elseif szType == "tongbao" then
		szType = "TongBao"
	end

	if not szType or not Shop.tbMoney[szType] then
		Log("_LuaPlayer.AddMoney fail !! unknow money type ", pPlayer.szName, pPlayer.dwID, szType, nCount);
	else
		pPlayer.AddMoney(szType, nCount, nLogReazon, nLogReazon2);
		--LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType, nCount, nLogReazon);
		Log("player add Money", pPlayer.szName, pPlayer.dwID, szType,  nCount);
	end
end

local function AddPartner(pPlayer, nLogReazon, nLogReazon2, szType, nTemplateId, nPartnerCount)
	nPartnerCount = nPartnerCount or 1;
	local _, nQualityLevel = GetOnePartnerBaseInfo(nTemplateId or 0);
	if not nQualityLevel then
		Log("_LuaPlayer:SendAward(tbAward) fail !! nQualityLevel is nil !!", nTemplateId, nPartnerCount);
		return;
	end

	for i = 1, nPartnerCount do
		local nAwareness = Partner:GetPartnerAwareness(pPlayer, nTemplateId);
		local nPId = pPlayer.AddPartner(nTemplateId, nLogReazon or 0, nAwareness);
		if nPId then
			Log("player add partner ", pPlayer.szName, pPlayer.dwID, nPId, nTemplateId);
		end
	end

	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, "Partner_" .. nTemplateId, nPartnerCount, nLogReazon);
end

local function AddSpecialPartner(pPlayer, nLogReazon, nLogReazon2, szType, nTemplateId, szValue)
	local _, nQualityLevel = GetOnePartnerBaseInfo(nTemplateId or 0);
	if not nQualityLevel then
		Log("_LuaPlayer:SendAward(tbAward) fail !! nQualityLevel is nil !!", nTemplateId, szValue);
		return;
	end

	local nAwareness = Partner:GetPartnerAwareness(pPlayer, nTemplateId);
	local nPId = pPlayer.AddPartner(nTemplateId, nLogReazon or 0, nAwareness);
	if not nPId then
		Log("_LuaPlayer:SendAward(tbAward) fail !! nPID is nil !!", nTemplateId, szValue);
		return;
	end

	local pPartner = pPlayer.GetPartnerObj(nPId);
	local tbData = Partner:GetSpecialPartnerData(szValue);
	Partner:SetPartnerData(pPartner, tbData, true);

	local nUseItemProtentialValue = pPartner.GetUseProtentialItemValue();
	if nUseItemProtentialValue > 0 then
		local nItemCount = math.ceil(nUseItemProtentialValue / Partner:GetItemValue(Partner.nPartnerProtentialItem));
		local nSaveInfo = pPlayer.GetUserValue(JingMai.SAVE_GROUP_ID, JingMai.SAVE_INDEX_ID);
		if nSaveInfo > 0 and nItemCount > 0 then
			JingMai:OnUsePartnerProtentialItem(pPlayer, math.min(nSaveInfo, nItemCount), true);
		end
	end

	pPartner.Update();
	pPlayer.SyncPartner(nPId);
	Log("player add partner ", pPlayer.szName, pPlayer.dwID, nPId, nTemplateId, szValue);
	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, "Partner_" .. nTemplateId .. "_" .. szValue, nPartnerCount, nLogReazon);
end

local function AddEquipDebris(pPlayer, nLogReazon, nLogReazon2, szType, nItemTemplateId, nIndex)
	Log("AddEquipDebris failed!!!!!", pPlayer.dwID, nItemTemplateId, nIndex, szMsg)
	--不填碎片索引就从没有的里面随机
	-- local bRet, szMsg;
	-- if not nIndex then
	-- 	bRet, szMsg = Debris:AddRandomDerisToPlayer(pPlayer, nItemTemplateId)
	-- else
	-- 	bRet, szMsg = Debris:AddDerisToPlayer(pPlayer, nItemTemplateId, nIndex)
	-- end
	-- if not bRet then
	--  	Log("AddEquipDebris failed!!", pPlayer.dwID, nItemTemplateId, nIndex, szMsg)
	-- else
	--  	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, "Debris_" .. nItemTemplateId , nIndex, nLogReazon);
	-- end
end

local function AddExp(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not nCount or nCount <= 0 then
		return;
	end

	pPlayer.AddExperience(nCount, nLogReazon);
	--LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nCount, nLogReazon);
end

local function AddTimeTitle(pPlayer, nLogReazon, nLogReazon2, szType, nTitleID, nEndTime, bActive, bShowInfo)
	if not nTitleID or nTitleID <= 0 then
		return;
	end

	if nEndTime == -1 then
		pPlayer.AddTitle(nTitleID, -1, bActive, bShowInfo);
	else
		pPlayer.AddTimeTitle(nTitleID, nEndTime, bActive, bShowInfo);
	end

	Kin:RedBagOnAddTitle(pPlayer, nTitleID)
end

local function AddBasicExp(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer or not nCount or nCount <= 0 then
		return;
	end

	nCount = nCount * pPlayer.GetBaseAwardExp();
	pPlayer.AddExperience(nCount, nLogReazon);
	--LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nCount, nLogReazon);
end

local function AddKinFound(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer or pPlayer.dwKinId <= 0 or not nCount or nCount <= 0 then
		return;
	end

	local tbKin = Kin:GetKinById(pPlayer.dwKinId);
	if not tbKin then
		return;
	end

	tbKin:AddFound(pPlayer.dwID, nCount);
	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nCount, nLogReazon);
end

local function AddComposeValue(pPlayer, nLogReazon, nLogReazon2, szType,nSeqId,nPos,nCount)
	if not pPlayer then
		return
	end
	ValueItem.ValueCompose:ChangeValue(pPlayer,nSeqId,nPos,nCount);
	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nSeqId, nPos, nLogReazon);
end

local function AddFactionHonor(pPlayer, nLogReazon, nLogReazon2, szType,nCount)
	if not pPlayer then
		return
	end

	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID);
	if not pAsync then
		return
	end

	local tbBoxAward = {}
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	nCurHonor, nBoxCount, nLeftHonor = FactionBattle:Honor2Box(pPlayer.dwID, nCount, tbBoxAward)

	pAsync.SetFactionHonor(nLeftHonor);

	if nBoxCount > 0 then
		pPlayer.SendAward(tbBoxAward, true, true, nLogReazon, nLogReazon2)
	end

	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nCount, nLeftHonor - nCurHonor, nLogReazon);
end

local function AddBattleHonor(pPlayer, nLogReazon, nLogReazon2, szType,nCount)
	if not pPlayer then
		return
	end

	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID);
	if not pAsync then
		return
	end

	local tbBoxAward = {}
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	nCurHonor, nBoxCount, nLeftHonor = Battle:Honor2Box(pPlayer.dwID, nCount, tbBoxAward)

	pAsync.SetBattleHonor(nLeftHonor);

	if nBoxCount > 0 then
		pPlayer.SendAward(tbBoxAward, true, true, nLogReazon, nLogReazon2)
	end

	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nCount, nLeftHonor - nCurHonor, nLogReazon);
end

local function AddBattleHonor2(pPlayer, nLogReazon, nLogReazon2, szType,nCount)
	if not pPlayer then
		return
	end

	local tbBoxAward = {}
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	nCurHonor, nBoxCount, nLeftHonor = Battle:Honor2Box2(pPlayer, nCount, tbBoxAward)
	pPlayer.SetUserValue(Battle.SAVE_GROUP, Battle.SAVE_KEY_LEFT_HONOR2, nLeftHonor);

	if nBoxCount > 0 then
		pPlayer.SendAward(tbBoxAward, true, true, nLogReazon, nLogReazon2)
	end

	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nLogReazon2, szType , nCount, nLeftHonor - nCurHonor, nLogReazon);
end

local function AddDomainHonor(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer then
		return
	end

	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID);
	if not pAsync then
		return
	end

	local tbBoxAward = {}
	local nCurHonor = 0;
	local nBoxCount = 0;
	local nLeftHonor = 0;

	nCurHonor, nBoxCount, nLeftHonor = DomainBattle:Honor2Box(pPlayer.dwID, nCount, tbBoxAward)

	pAsync.SetDomainHonor(nLeftHonor);

	if nBoxCount > 0 then
		pPlayer.SendAward(tbBoxAward, true, true, nLogReazon, nLogReazon2)
	end
end

local function AddCrossDomainHonor(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer then
		return
	end

	DomainBattle.tbCross:AddPlayerHonorBox(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
end

local function AddHSLJHonor(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer then
        return
    end

    HuaShanLunJian:AddPlayerHonorBox(pPlayer, nCount, nLogReazon, nLogReazon2)
end

local function AddDXZHonor(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer then
        return
    end

    Activity.tbDaXueZhang:AddPlayerHonorBox(pPlayer, nCount, nLogReazon, nLogReazon2);
end

local function AddIndfiiferHonor(pPlayer, nLogReazon, nLogReazon2, szType, nCount)
	if not pPlayer then
		return
	end
	InDifferBattle:AddPlayerHonorBox(pPlayer, nCount, nLogReazon, nLogReazon2)
end

local function AddVipExp(pPlayer, nLogReazon, nLogReazon2, szType,nCount)
    if not pPlayer then
        return
    end

    local nTotalCardCharge = pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD);
    local nNewTotal = math.max(nTotalCardCharge + nCount, 0); -- nCount 可能小于0
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_TOTAL_CARD, nNewTotal);
    Recharge:CheckVipLevelChange(pPlayer, 0, nCount)
    Log("AddVipExp", pPlayer.dwID, nLogReazon, nLogReazon2, szType, nCount, nTotalCardCharge, nNewTotal, pPlayer.GetVipLevel())
end

local function AddCollectClue(pPlayer, nLogReazon, nLogReazon2, szType, nItemTemplateId, nCount)
	if not pPlayer then
        return
    end

	Activity:OnPlayerEvent(pPlayer,"Act_ModifyClueCount", nItemTemplateId, nCount, nLogReazon, nLogReazon2)
end

local function AddLabaMaterial(pPlayer, nLogReazon, nLogReazon2, szType, nId, nCount)
	if not pPlayer then
        return
    end
	if not Activity:__IsActInProcessByType("LabaAct") then
		pPlayer.CenterMsg("活动已经结束", true)
		return 
	end
	Activity:OnPlayerEvent(pPlayer, "Act_GetMaterial", nId, nCount)
end

local function AddPartnerCard(pPlayer, nLogReazon, nLogReazon2, szType, nCardId, nShowUi)
	if not pPlayer then
        return
    end
    local bShowUi = (nShowUi and nShowUi == 1) and true or false
	PartnerCard:SendCard(pPlayer, nCardId, nil, nLogReazon, nLogReazon2, bShowUi)
end

local function AddPartnerCardView(pPlayer, nLogReazon, nLogReazon2, szType, nCardId)
	if not pPlayer then
        return
    end
	PartnerCard:SendCard(pPlayer, nCardId, nil, nLogReazon, nLogReazon2, true)
end

local function GetDefaultValue()
	return 0;
end

local function GetEmptyValue()
	return 0;
end

local function GetItemValue(szType, nItemId, nCount)
	return nCount * (KItem.GetBaseValue(nItemId) or 0);
end

local function GetOnePartnerValue(szType, nPartnerId)
	return Partner:GetPartnerValueByTemplateId(nPartnerId);
end

local function GetPartnerValue(szType, nPartnerId, nCount)
	nCount = math.max(nCount, 1);
	return nCount * Partner:GetPartnerValueByTemplateId(nPartnerId);
end

local function GetMoneyValue(szType, nCount)
	return nCount * (Shop:GetMoneyValue(szType) or 0);
end

-- 各种奖励类型，要保证每个类型都有对应的发奖励函数
Player.award_type_unkonw           = 0;
Player.award_type_item             = 1;
Player.award_type_partner_familiar = 2;
Player.award_type_partner          = 3;
Player.award_type_money            = 4;
Player.award_type_equip_debris     = 5;
Player.award_type_exp              = 6;
Player.award_type_basic_exp        = 8;
Player.award_type_kin_found        = 9;
Player.award_type_compose_value    = 10;
Player.award_type_empty            = 11;
Player.award_type_faction_honor    = 12;
Player.award_type_battle_honor     = 13;
Player.award_type_add_timetitle    = 14;
Player.award_type_special_partner  = 15;
Player.award_type_add_vip_exp      = 16;
Player.award_type_domain_honor     = 17;
Player.award_type_hslj_honor       = 18;
Player.award_type_indiffer_honor   = 19;
Player.award_type_dxz_honor   	   = 20;
Player.award_type_collect_clue     = 21;
Player.award_type_laba_material    = 22;
Player.award_type_cross_domain_honor = 23;
Player.award_type_add_partner_card = 24; 					-- 增加门客
Player.award_type_add_partner_card_view = 25; 				-- 增加门客并展示
Player.award_type_battle_honor2     = 26;
Player.award_type_end 				= 100; --具体的货币类型使用 award_type_end + nMoneyKey

Player.Type2Func = {
	[Player.award_type_unkonw]           = AddUnknowAward;
	[Player.award_type_item]             = AddItem;
	[Player.award_type_partner_familiar] = AddUnknowAward;
	[Player.award_type_partner]          = AddPartner;
	[Player.award_type_money]            = AddMoney;
	[Player.award_type_equip_debris]     = AddEquipDebris;
	[Player.award_type_exp]              = AddExp;
	[Player.award_type_basic_exp]        = AddBasicExp;
	[Player.award_type_kin_found]        = AddKinFound;
	[Player.award_type_compose_value]    = AddComposeValue;
	[Player.award_type_empty]            = AddEmptyAward;
	[Player.award_type_faction_honor]    = AddFactionHonor;
	[Player.award_type_battle_honor]     = AddBattleHonor;
	[Player.award_type_battle_honor2]    = AddBattleHonor2;
	[Player.award_type_add_timetitle]    = AddTimeTitle;
	[Player.award_type_special_partner]	 = AddSpecialPartner;
	[Player.award_type_add_vip_exp]      = AddVipExp;
	[Player.award_type_domain_honor]     = AddDomainHonor;
	[Player.award_type_hslj_honor]       = AddHSLJHonor;
	[Player.award_type_indiffer_honor]   = AddIndfiiferHonor;
	[Player.award_type_dxz_honor]        = AddDXZHonor;
	[Player.award_type_collect_clue]     = AddCollectClue;
	[Player.award_type_laba_material]    = AddLabaMaterial;
	[Player.award_type_cross_domain_honor] = AddCrossDomainHonor;
	[Player.award_type_add_partner_card] = AddPartnerCard;
	[Player.award_type_add_partner_card_view] = AddPartnerCardView;
}

Player.Type2ValueFunc = {
	[Player.award_type_unkonw]          = GetDefaultValue;
	[Player.award_type_item]            = GetItemValue;
	[Player.award_type_partner]         = GetPartnerValue;
	[Player.award_type_special_partner] = GetOnePartnerValue;
	[Player.award_type_money]           = GetMoneyValue;
	[Player.award_type_empty]           = GetEmptyValue;
}

Player.AwardType = {
	["item"]            = Player.award_type_item,
	["Item"]            = Player.award_type_item,
	["PartnerFamiliar"] = Player.award_type_partner_familiar,
	["Partner"]         = Player.award_type_partner,
	["partner"]         = Player.award_type_partner,
	["Coin"]            = Player.award_type_money,
	["coin"]            = Player.award_type_money,
	["Gold"]            = Player.award_type_money,
	["gold"]            = Player.award_type_money,
	["TongBao"]         = Player.award_type_money,
	["tongbao"]         = Player.award_type_money,
	["EquipDebris"]     = Player.award_type_equip_debris,
	["Exp"]             = Player.award_type_exp,
	["exp"]             = Player.award_type_exp,
	["BasicExp"]        = Player.award_type_basic_exp,
	["KinFound"]        = Player.award_type_kin_found,
	["ComposeValue"]    = Player.award_type_compose_value,
	["Empty"]           = Player.award_type_empty,
	["FactionHonor"]    = Player.award_type_faction_honor,
	["BattleHonor"]     = Player.award_type_battle_honor,
	["BattleHonor2"]     = Player.award_type_battle_honor2,
	["DomainHonor"]     = Player.award_type_domain_honor,
	["HSLJHonor"]       = Player.award_type_hslj_honor;
	["DXZHonor"]        = Player.award_type_dxz_honor;
	["IndifferHonor"]   = Player.award_type_indiffer_honor;
	["AddTimeTitle"]    = Player.award_type_add_timetitle;
	["SpecialPartner"]	= Player.award_type_special_partner;
	["VipExp"]          = Player.award_type_add_vip_exp;
	["Renown"]            = Player.award_type_money;
	["renown"]            = Player.award_type_money;
	["CollectClue"]     = Player.award_type_collect_clue;
	["LabaMatrial"]     = Player.award_type_laba_material;
	["CrossDomainHonor"]     = Player.award_type_cross_domain_honor;
	["PartnerCard"]     = Player.award_type_add_partner_card;
	["PartnerCardView"]     = Player.award_type_add_partner_card_view;

};

Player.AwardType2Name = {
	[Player.award_type_item]             = {"item","道具"},
	[Player.award_type_partner_familiar] = {"PartnerFamiliar",""},
	[Player.award_type_partner]          = {"Partner","同伴"},
	[Player.award_type_equip_debris]     = {"EquipDebris","装备碎片"},
	[Player.award_type_exp]              = {"Exp","经验"},
	[Player.award_type_basic_exp]        = {"BasicExp","基准经验"},
	[Player.award_type_kin_found]        = {"KinFound","帮派资金"},
	[Player.award_type_compose_value]    = {"ComposeValue",""},
	[Player.award_type_empty]            = {"Empty",""},
	[Player.award_type_money]            = {"Money","货币"},
	[Player.award_type_faction_honor]    = {"FactionHonor","门派竞技荣誉"},
	[Player.award_type_battle_honor]     = {"BattleHonor","战场荣誉"},
	[Player.award_type_battle_honor2]     = {"BattleHonor2","战场荣誉"},
	[Player.award_type_domain_honor]     = {"DomainHonor","城战荣誉"},
	[Player.award_type_hslj_honor]       = {"HSLJHonor"; "华山论剑荣誉"},
	[Player.award_type_dxz_honor]        = {"DXZHonor",""},
	[Player.award_type_indiffer_honor]   = {"IndifferHonor","心魔荣誉"},
	[Player.award_type_add_timetitle]    = {"AddTimeTitle","称号"},
	[Player.award_type_special_partner]	 = {"SpecialPartner",""},
	[Player.award_type_add_vip_exp]      = {"VipExp","剑侠尊享经验"},
	[Player.award_type_collect_clue] 	 = {"CollectClue","神州残卷碎片"},
	[Player.award_type_laba_material] 	 = {"LabaMatrial","腊八节材料箱"},
	[Player.award_type_cross_domain_honor]     = {"CrossDomainHonor","跨服城战荣誉"},
	[Player.award_type_add_partner_card]       = {"PartnerCard","同伴门客"},
	[Player.award_type_add_partner_card_view]  = {"PartnerCardView","同伴门客"},
};

for szType in pairs(Shop.tbMoney or {}) do
	Player.AwardType[szType] = Player.award_type_money;
end

function Player:GetAwardFunc(szType)
	local awardType = self.AwardType[szType] or self.award_type_unkonw;
	return self.Type2Func[awardType];
end

function Player:GetAwardValue(tbAward)
	if not tbAward or not tbAward[1] then
		return 0;
	end

	local awardType = self.AwardType[tbAward[1] or "nil"] or self.award_type_unkonw;
	local fnGetValueFunc = self.Type2ValueFunc[awardType] or GetDefaultValue;

	return fnGetValueFunc(unpack(tbAward));
end

function Player:GetAwardTypeName(szType)
	local nType = Player.AwardType[szType]
	if nType == Player.award_type_money then
		return Shop:GetMoneyName(szType)
	end
	local tbNameInfo = self.AwardType2Name[nType]
	return tbNameInfo and tbNameInfo[2] or "未知"
end

function Player:GetAwardType(szAwardType)
	local nType = self.AwardType[szAwardType]
	local tbMoney = Shop.tbMoney[szAwardType]
	if tbMoney then
		return Player.award_type_end + tbMoney.SaveKey
	end
	return nType
end

function Player:GetHonorImgPrefix(nHonorLevel)
	local tbHonorInfo = Player.tbHonorLevelSetting[nHonorLevel];
	if not tbHonorInfo then
		return;
	end

    return tbHonorInfo.ImgPrefix;
end

--获取欠款持续时间
function Player:GetDebtDuration(pPlayer)
	if not pPlayer then
		return 0
	end

	local nStartTime = pPlayer.GetUserValue(Shop.MONEY_DEBT_GROUP, Shop.MONEY_DEBT_START_TIME);

	if nStartTime <= 0 then
		return 0
	end

	return GetTime() - nStartTime
end

--获取欠款能力衰减buff等级
function Player:GetDebtAttrDebuffLevel(pPlayer)
	local nBuffLevel = 0
	--目前只有元宝会加debuff
	local nDebt = pPlayer.GetMoneyDebt("Gold")

	for nIndex=#self.DebtAttrDebuff, 1, -1 do
		local tbInfo = self.DebtAttrDebuff[nIndex];
		if nDebt >= tbInfo.nAmount then
			return tbInfo.nLevel
		end
	end

	return 0
end

--获取欠款战力衰减百分比
function Player:GetDebtFightPowerDebuffLevel(pPlayer)
	local nDuration = self:GetDebtDuration(pPlayer)
	if nDuration < 0 then
		return 0
	end

	if self:GetDebtAttrDebuffLevel(pPlayer) < Player.DEBT_FIGHT_POWER_NEED_LEVEL then
		return 0
	end

	local nPercent = 0
	local nLevel = 0;

	for nIndex=#self.DebtFightPowerDebuff, 1, -1 do
		local tbInfo = self.DebtFightPowerDebuff[nIndex];
		if nDuration >= tbInfo.nDuration then
			nPercent = tbInfo.nPercent
			break;
		end
	end

	local nCurFightPower = pPlayer.GetFightPower();
	local nReduce = nCurFightPower * nPercent / 100;

	return math.floor(nReduce/Player.DEBT_FIGHT_POWER_REDUCE_PER_LEVEL);
end

function Player:GetRewardValueDebt(nPlayerId)
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
	if not pAsyncData then
		Log(debug.traceback())
		return 0;
	end

	return pAsyncData.GetRewardValueDebt();
end

function Player:Faction2Sex(nFaction, nDefaultSex)
	local nSex = Player.SEX_FEMALE;
	if Player.tbBoyFaction[nFaction] then
		nSex = Player.SEX_MALE;
	elseif Player.tbGirlFaction[nFaction] then
		nSex = Player.SEX_FEMALE;
	elseif nDefaultSex and nDefaultSex ~= Player.SEX_NONE then
		nSex = nDefaultSex;
	end
	return nSex;
end

--获取门派可选的性别
function Player:GetFactionSexs(nFaction)
	if Player.tbBoyFaction[nFaction] then
		return {Player.SEX_MALE}
	end
	if Player.tbGirlFaction[nFaction] then
		return {Player.SEX_FEMALE}
	end
	return {Player.SEX_MALE, Player.SEX_FEMALE}
end

function Player:GetSexByName( szSexName )
	for k,v in pairs(self.SEX_NAME) do
		if v == szSexName then
			return k;
		end
	end
end

function Player:GetRandomName( nSex, nFaction )
	if not self.tbRandomName1 then
	 	self.tbRandomName1 = LoadTabFile("Setting/RandomName/Xing.tab", "s", nil, {"Name"});
	 	self.tbRandomName2 = LoadTabFile("Setting/RandomName/Ming.tab", "s", nil, {"Name"}); --只是男的
	 	self.tbRandomName3 = LoadTabFile("Setting/RandomName/Female.tab", "s", nil, {"Name"});
	end
	if nFaction then
		nSex = Player:Faction2Sex(nFaction, nSex)	
	end
	local nPreIndx = MathRandom(#self.tbRandomName1)
	local tbRandomMing = self.tbRandomName2
	if nSex and nSex == Player.SEX_FEMALE then
		tbRandomMing = self.tbRandomName3
	end

	local nSuffiIndx = MathRandom(#tbRandomMing)
	local szName  = tbRandomMing[nSuffiIndx].Name;
	for i = 1, 3 do
		szName = self.tbRandomName1[nPreIndx].Name .. tbRandomMing[nSuffiIndx].Name
		if CheckNameAvailable(szName) then
			break;
		end
	end
	return szName
end

