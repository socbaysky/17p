Kin.AuctionDef = {

nAddRatePerTime = 0.05; -- 每次加价的倍率
nBidOverRate = 2.5; -- 一口价的倍率
nBidTimeOut = 30; --秒

nAuctionPrepareTime = 10 * 60; -- 拍卖会准备时间十分钟
nKinAuctionLastingTime = 30 * 60; -- 普通拍卖持续时间
nDealerAuctionLastingTime = 35 * 60; -- 西域行商拍卖持续时间
nGlobalAuctionLastingTime = 12 * 60 * 60; -- 全服拍卖持续时间
nPersonalAuctionWaitingTime = 0; -- 个人物品等待进入拍卖的时间..

nServerRestartLastingTime = 5 * 60; -- 重启后尚未结束拍卖持续时间

nRecycleRate = 0.8; --回收费率
nAuctionLevelLimit = 11; -- 可参与拍卖活动的最小等级
nMaxDealListNum = 100; -- 最大拍卖历史记录

nBaseBonusDeductionRate     = 0.3; -- 初始价值分红的抵扣比例
nAdditionBonusDeductionRate = 0.5; -- 增加分红的抵扣比例

nBidOverValidDelayTime = 2; -- 一口价在拍卖开始后的生效时间
};

local AuctionDef = Kin.AuctionDef;
Kin.Auction = Kin.Auction or {};
local Auction = Kin.Auction;

-- 拍卖分红需特殊处理的拍卖类型：攻城战，始皇降世
AuctionDef.tbSpecialBonusType = {
	ImperialTombEmperor = true;
	ImperialTombFemaleEmperor = true;
	DomainBattle = true;
	DomainBattleCross = true;
	Boss = true;
	CrossBoss = true;
	BossLeader_Boss = true;
};

-- 各类型拍卖的vip限制
AuctionDef.tbVipLimit = {
	Dealer = 6;
};

-- 拍卖增量归入分红的系数，根据小号，VIP等级进行限制
AuctionDef.nLimitPlayerBonusRate = 0.1;
AuctionDef.tbVipBonusRate = {
	[0]  = 0.1;
	[1]  = 0.1;
	[2]  = 0.1;
	[3]  = 0.1;
	[4]  = 0.2;
	[5]  = 0.3;
	[6]  = 0.4;
	[7]  = 0.6;
	[8]  = 0.8;
	[9]  = 1;
	[10] = 1;
	[11] = 1;
	[12] = 1;
	[13] = 1;
	[14] = 1;
	[15] = 1;
	[16] = 1;
	[17] = 1;
	[18] = 1;
};

-- 特殊处理的拍卖分红规则：
-- 当原始总价值（元宝）大于nTotalBaseGold时，分红至少被分为nMinPlayer份
AuctionDef.tbSpecialBonusRule = {
	{nTotalBaseGold = 500, nMinPlayer = 5},
	{nTotalBaseGold = 2000, nMinPlayer = 6},
	{nTotalBaseGold = 3000, nMinPlayer = 7},
	{nTotalBaseGold = 4000, nMinPlayer = 8},
	{nTotalBaseGold = 5000, nMinPlayer = 9},
	{nTotalBaseGold = 6000, nMinPlayer = 10},
	{nTotalBaseGold = 8000, nMinPlayer = 12},
	{nTotalBaseGold = 10000, nMinPlayer = 15},
	{nTotalBaseGold = 15000, nMinPlayer = 20},
	{nTotalBaseGold = 20000, nMinPlayer = 25},
	{nTotalBaseGold = 25000, nMinPlayer = 30},
	{nTotalBaseGold = 30000, nMinPlayer = 35},
	{nTotalBaseGold = 35000, nMinPlayer = 40},
	{nTotalBaseGold = 40000, nMinPlayer = 45},
	{nTotalBaseGold = 50000, nMinPlayer = 50},
};

-- 每种类型的拍卖对应的最小分红
AuctionDef.tbMinBonusForPlayer = {
	Default               = 0, -- 默认值
	Boss                  = 0, -- 武林盟主
	BossLeader_Boss       = 40, -- 历代名将
	BossLeader_Leader     = 0, -- 野外首领
	DomainBattle          = 60, -- 攻城战
	DomainBattleCross = 60,
	KinTrain              = 0, -- 家族试炼
	DomainBattleAct       = 0, -- 领地行商
	ImperialTombEmperor   = 85, -- 始皇降世
	ImperialTombFemaleEmperor = 85, -- 女帝疑冢
	WhiteTigerFuben_Cross = 30, -- 白虎堂
	MonsterNianAuction    = 0, -- 年兽拍卖
	KinSecretFubenAuction = 0,	--家族秘境拍卖
};

Kin.AuctionName = {
	MyBiding = "我的拍卖", -- 客户端显示用
	Global = "全服拍卖",
	Dealer = "西域行商",
	Boss   = "武林盟主",
	CrossBoss = "跨服盟主",
	BossLeader_Boss = "历代名将";
	BossLeader_Leader = "野外首领";
	DomainBattle = "攻城战";
	DomainBattleCross = "跨服攻城战";
	KinTrain = "帮派试炼";
	DomainBattleAct = "领地行商";
	ImperialTombEmperor = "始皇降世";
	ImperialTombFemaleEmperor = "女帝疑塚";
	WhiteTigerFuben_Cross = "白虎堂";
	--TODO 后面的拍卖类型不要带下划线，不然对应拼成的szSaleOrderId 不好区分
	MonsterNianAuction = "年兽拍卖";
	KinSecretFubenAuction = "帮派秘境";
}


Kin.AuctionItemTimeFrame = {
	Price1 = "OpenLevel49";
	Price2 = "OpenLevel59";
	Price3 = "OpenLevel69";
	Price4 = "OpenLevel79";
	Price5 = "OpenLevel89";
	Price6 = "OpenLevel99";
	Price7 = "OpenLevel109";
	Price8 = "OpenLevel119";
};

-- 西域行商对应物品时间轴
AuctionDef.DealerItemTimeFrame = {
	TimeFrame1  = "OpenLevel59";
	TimeFrame2  = "OpenLevel69";
	TimeFrame3  = "OpenLevel79";
	TimeFrame4  = "OpenLevel89";
	TimeFrame5  = "OpenLevel99";
	TimeFrame6  = "OpenLevel109";
	TimeFrame7  = "OpenLevel119";
	TimeFrame8  = "OpenLevel129";
	TimeFrame9  = "OpenLevel139";
	TimeFrame10 = "OpenLevel149";
	TimeFrame11 = "OpenLevel159";
	TimeFrame12 = "OpenLevel169";
};
AuctionDef.nDealerAutionOpenCount = 3; -- 西域行商对应时间轴开启后的前n天开启

-- 西域行商全服红包相关配置
AuctionDef.tbDealerLuckybagGoldInfo = {
	{RedBagId = "travel_seller_1", Cost = 1000},
	{RedBagId = "travel_seller_2", Cost = 2000},
	{RedBagId = "travel_seller_3", Cost = 5000},
	{RedBagId = "travel_seller_4", Cost = 10000},
	{RedBagId = "travel_seller_5", Cost = 20000},
	{RedBagId = "travel_seller_6", Cost = 50000},
	{RedBagId = "travel_seller_7", Cost = 100000},
	{RedBagId = "travel_seller_8", Cost = 120000},
	{RedBagId = "travel_seller_9", Cost = 150000},
	{RedBagId = "travel_seller_10", Cost = 180000},
	{RedBagId = "travel_seller_11", Cost = 200000},
};


local tbAuctionMaxPriceRateTimeFrame = {
	MaxPriceRate1 = "OpenLevel39";
	MaxPriceRate2 = "OpenLevel49";
	MaxPriceRate3 = "OpenLevel59";
	MaxPriceRate4 = "OpenLevel69";
	MaxPriceRate5 = "OpenLevel79";
	MaxPriceRate6 = "OpenLevel89";
	MaxPriceRate7 = "OpenLevel99";
	MaxPriceRate8 = "OpenLevel109";
	MaxPriceRate9 = "OpenLevel119";
	MaxPriceRate10 = "OpenLevel129";
	MaxPriceRate11 = "OpenLevel139";
	MaxPriceRate12 = "OpenLevel149";
}

local function LoadAuctionSetting()
	local szItemType = "ddddss";
	local tbItemName = {"ItemId", "MaxItemCount", "OrgPrice", "OrgSilverPrice", "TypeName", "Silver2GoldRate"};
	local nPriceCount = Lib:CountTB(Kin.AuctionItemTimeFrame);
	local nMaxPriceCount = Lib:CountTB(tbAuctionMaxPriceRateTimeFrame);
	for i = 1, nPriceCount do
		table.insert(tbItemName, "Price" .. i);
		table.insert(tbItemName, "SilverPrice" .. i);
		szItemType = szItemType .. "dd";
	end

	for i = 1, nMaxPriceCount do
		table.insert(tbItemName, "MaxPriceRate" .. i);
		szItemType = szItemType .. "s";
	end

	local tbAuctionSetting = LoadTabFile("Setting/Auction/Auction.tab", szItemType, "ItemId", tbItemName);
	for _, tbItem in pairs(tbAuctionSetting) do
		tbItem.tbTimePrice = {};
		tbItem.tbTimeMaxPriceRate = {};
		tbItem.tbTimeSilverPrice = {};
		tbItem.Silver2GoldRate = tonumber(tbItem.Silver2GoldRate) or 1;

		for i = 1, nMaxPriceCount do
			local szPriceName = "Price" .. i;
			local nPrice = tbItem[szPriceName];
			local szTimeFrame = Kin.AuctionItemTimeFrame[szPriceName];
			if nPrice and szTimeFrame then
				nPrice = tonumber(nPrice);
				table.insert(tbItem.tbTimePrice, {nPrice, szTimeFrame});
			end
			tbItem[szPriceName] = nil;

			local szSilverPriceName = "SilverPrice" .. i;
			local nSilverPrice = tbItem[szSilverPriceName];
			if nSilverPrice and szTimeFrame then
				nSilverPrice = tonumber(nSilverPrice);
				table.insert(tbItem.tbTimeSilverPrice, {nSilverPrice, szTimeFrame});
			end
			tbItem[szSilverPriceName] = nil;

			local szMaxPriceRateName = "MaxPriceRate" .. i;
			local nMaxRate = tbItem[szMaxPriceRateName];
			local szTimeFrame = tbAuctionMaxPriceRateTimeFrame[szMaxPriceRateName];
			if nMaxRate and szTimeFrame then
				nMaxRate = tonumber(nMaxRate);
				assert(nMaxRate >= 1, "Auction Max Rate must >= 1");
				table.insert(tbItem.tbTimeMaxPriceRate, {nMaxRate, szTimeFrame});
			end
			tbItem[szMaxPriceRateName] = nil;
		end

		-- 清除客户端无用信息，实测少1M内存
		if MODULE_GAMECLIENT then
			tbItem.tbTimePrice = nil;
			tbItem.tbTimeMaxPriceRate = nil;
			tbItem.tbTimeSilverPrice = nil;
			tbItem.MaxItemCount = nil;
			tbItem.ItemId = nil;
			tbItem.Silver2GoldRate = nil;
			tbItem.OrgPrice = nil;
			tbItem.OrgSilverPrice = nil;
		end
	end
	return tbAuctionSetting;
end

Kin.tbAuctionSetting = LoadAuctionSetting();

function Auction:LoadDealerItemsSetting(szTabFilePath)
	local tbSetting = {};
	local tbItems = LoadTabFile(szTabFilePath, "dssssssssssssddd" , nil, {"ItemId",
								"ItemCount1","ItemCount2","ItemCount3","ItemCount4","ItemCount5",
								"ItemCount6","ItemCount7","ItemCount8","ItemCount9", "ItemCount10","ItemCount11","ItemCount12",
								"SilverBoard", "OneUp", "ForbidStall"});

	for _, szTimeFrame in pairs(AuctionDef.DealerItemTimeFrame) do
		tbSetting[szTimeFrame] = {};
	end

	for _, tbItemInfo in pairs(tbItems) do
		for i = 1, 12 do
			local szTimeFrame = AuctionDef.DealerItemTimeFrame["TimeFrame" .. i] or "";
			if tbSetting[szTimeFrame] then
				local nCount = tonumber(tbItemInfo["ItemCount" .. i]) or 0;
				local bSilver = (tbItemInfo.SilverBoard == 1);
				local bOneUp = (tbItemInfo.OneUp == 1);
				local bForbidStall = (tbItemInfo.ForbidStall == 1);
				if nCount > 0 then
					table.insert(tbSetting[szTimeFrame], {
							nItemId = tbItemInfo.ItemId,
							nCount = nCount,
							bSilver = bSilver,
							bOneUp = bOneUp,
							bForbidStall = bForbidStall,
						});
				end
			end
		end
	end

	return tbSetting;
end

if MODULE_GAMESERVER then
	AuctionDef.tbDealerItemsSetting = Auction:LoadDealerItemsSetting("Setting/Auction/DealerItems.tab");
end

function Auction:IsKinAuction(szAuctionType)
	return not string.find(szAuctionType, "Global") 
			and not string.find(szAuctionType, "Dealer") 
			and not string.find(szAuctionType, "MyBiding");
end

function Auction:CanDealerOpen()
	return GetTimeFrameState(AuctionDef.DealerItemTimeFrame.TimeFrame1) == 1;
end

function Auction:GetCurrentDealerItems()
	local tbSetting = {}
	local szMaxTimeFrame = ""
	if Auction:IsOnSpecialDealerAct() then
		tbSetting = Auction:GetSpecialDealerSetting()
	else
		tbSetting = AuctionDef.tbDealerItemsSetting
	end
	local tbAutionItems, szMaxTimeFrame = Auction:GetDealerItemsBySetting(tbSetting)

	local tbActItems = {};
	if Auction:IsOnDealerAct() then
		tbActItems = Auction:GetDealerActData();
		Lib:MergeTable(tbAutionItems, tbActItems);
	end

	return tbAutionItems, szMaxTimeFrame, tbActItems;
end

function Auction:GetDealerItemsBySetting(tbSetting)
	local szMaxTimeFrame = Lib:GetMaxTimeFrame(tbSetting or {});
	local tbItems = tbSetting[szMaxTimeFrame] or {};
	local tbAutionItems = {};
	for _, tbItemInfo in pairs(tbItems) do
		local nCount = math.floor(tbItemInfo.nCount);
		nCount = nCount + (((tbItemInfo.nCount - nCount) >= MathRandom()) and 1 or 0);
		if nCount then
			table.insert(tbAutionItems, {tbItemInfo.nItemId, nCount, tbItemInfo.bSilver, tbItemInfo.bOneUp, false, tbItemInfo.bForbidStall});
		end
	end
	return tbAutionItems, szMaxTimeFrame
end

function Auction:SetDealerActData(tbAutionItems)
	self.tbDealerAuctionActData = self.tbDealerAuctionActData or {};
	self.tbDealerAuctionActData.tbAutionItems = tbAutionItems;
end

function Auction:GetDealerActData()
	local tbActData = self.tbDealerAuctionActData or {};
	return tbActData.tbAutionItems;
end

function Auction:IsOnDealerAct()
	local tbActItems = Auction:GetDealerActData();
	return tbActItems and next(tbActItems);
end

function Auction:GetDealerLuckybagIdByCost(nCostGold)
	local szRedBagId = nil;
	for _, tbInfo in ipairs(AuctionDef.tbDealerLuckybagGoldInfo) do
		if nCostGold >= tbInfo.Cost then
			szRedBagId = tbInfo.RedBagId;
		else
			break;
		end
	end
	if szRedBagId then
		return Kin.tbRedBagEvents[szRedBagId];
	end
end

function Auction:GetPlayerAuctionBonusRate(pPlayer)
	if MarketStall:CheckIsLimitPlayer(pPlayer) then
		return AuctionDef.nLimitPlayerBonusRate;
	end
	return AuctionDef.tbVipBonusRate[pPlayer.GetVipLevel()] or 1;
end

function Auction:GetBidBidVipLimitByType(szAuctionType)
	return AuctionDef.tbVipLimit[szAuctionType] or 0;
end

function Kin:GetAuctionItemMaxCount(nItemId)
	return self.tbAuctionSetting[nItemId] and self.tbAuctionSetting[nItemId].MaxItemCount or 1;
end

function Kin:GetAuctionItemPrice(nItemId, bSilver)
	local tbItemInfo = self.tbAuctionSetting[nItemId];
	if not tbItemInfo then
		Log("ERROR:Auction:GetItemPrice:", nItemId);
		Log(debug.traceback())
		--assert(false, "ERROR:Auction:GetItemPrice:" .. nItemId)
		return 0;
	end
	local nRealPrice = bSilver and tbItemInfo.OrgSilverPrice or tbItemInfo.OrgPrice;
	local tbTimePrice = bSilver and tbItemInfo.tbTimeSilverPrice or tbItemInfo.tbTimePrice;
	for _, tbPriceInfo in ipairs(tbTimePrice) do
		local nPrice, szTimeFrame = unpack(tbPriceInfo);
		if GetTimeFrameState(szTimeFrame) ~= 1 then
			break;
		end
		nRealPrice = nPrice;
	end
	return nRealPrice;
end

function Auction:GetMaxPrice(nItemId, nOrgPrice, bOneUp)
	if bOneUp then
		return Env.INT_MAX;
	end

	local nMaxRate = Auction:GetMaxPriceRate(nItemId);
	return math.ceil(nOrgPrice * nMaxRate);
end

function Auction:GetMaxPriceRate(nItemId)
	local nBidOverRate = Kin.AuctionDef.nBidOverRate;
	local tbItemInfo = Kin.tbAuctionSetting[nItemId];
	if not tbItemInfo then
		return nBidOverRate;
	end

	for _, tbMaxRateInfo in ipairs(tbItemInfo.tbTimeMaxPriceRate) do
		local nMaxRate, szTimeFrame = unpack(tbMaxRateInfo);
		if GetTimeFrameState(szTimeFrame) ~= 1 then
			break;
		end
		nBidOverRate = nMaxRate;
	end
	return nBidOverRate;
end

function Auction:GetOneUpNextPrice(nCurPrice)
	local nNextPrice = math.max(nCurPrice + 49, nCurPrice * 1.1);
	nNextPrice = math.ceil(nNextPrice / 50) * 50;
	return nNextPrice;
end

function Auction:GetPriceInfo(tbItemData)
	local tbPriceInfo = {};

	tbPriceInfo.szMoneyType = tbItemData.bSilver and "SilverBoard" or "Gold";
	tbPriceInfo.nCurPrice   = tbItemData.nCurPrice;
	tbPriceInfo.nMaxPrice   = tbItemData.nMaxPrice;
	tbPriceInfo.nOrgPrice   = tbItemData.nOrgPrice;
	tbPriceInfo.nNextPrice  = tbPriceInfo.nCurPrice;

	if tbItemData.nBidderId then
		if tbItemData.bOneUp then
			tbPriceInfo.nNextPrice = Auction:GetOneUpNextPrice(tbPriceInfo.nCurPrice);
		else
			tbPriceInfo.nNextPrice = tbPriceInfo.nCurPrice + math.ceil(tbPriceInfo.nOrgPrice * Kin.AuctionDef.nAddRatePerTime);
		end
	end

	tbPriceInfo.nNextPrice = math.min(tbPriceInfo.nNextPrice, tbPriceInfo.nMaxPrice);
	return tbPriceInfo;
end

function Auction:GetItemRealPrice(nItemId, nOrgPrice, nMaxPrice, bOneUp)
	if bOneUp then
		return 1;
	end

	if nOrgPrice >= nMaxPrice then
		return math.ceil(nMaxPrice * Kin.AuctionDef.nRecycleRate);
	end
	return nOrgPrice;
end

function Auction:CalcFinalTargetPrice(nItemId, nCurPrice, bSilver, bBonusSilver)
	local tbItemInfo = Kin.tbAuctionSetting[nItemId] or {};
	if bSilver and not bBonusSilver then
		return math.floor(nCurPrice * tbItemInfo.Silver2GoldRate);
	elseif not bSilver and bBonusSilver then
		return math.floor(nCurPrice / tbItemInfo.Silver2GoldRate);
	end

	return nCurPrice;
end

function Auction:GetSilver2GoldRate(nItemId)
	return Kin.tbAuctionSetting[nItemId] and Kin.tbAuctionSetting[nItemId].Silver2GoldRate or 1;
end

function Kin:AuctionGetItemType(nItemId)
	return self.tbAuctionSetting[nItemId] and self.tbAuctionSetting[nItemId].TypeName or "null";
end

function Kin:CalculateAuctionBonusCount(szAuctionType, nTotalBaseGold, nPlayerCount)
	if not AuctionDef.tbSpecialBonusType[szAuctionType] then
		return nPlayerCount;
	end

	for _, tbRule in ipairs(AuctionDef.tbSpecialBonusRule) do
		if nTotalBaseGold > tbRule.nTotalBaseGold then
			nPlayerCount = math.max(nPlayerCount, tbRule.nMinPlayer);
		end
	end

	return nPlayerCount;
end

function Kin:AuctionGetMinBonusPrice(szAuctionType)
	return AuctionDef.tbMinBonusForPlayer[szAuctionType] or AuctionDef.tbMinBonusForPlayer.Default;
end

function Auction:SetSpecialDealerActSetting(tbSetting)
	self.tbSpecialDealerActData = self.tbSpecialDealerActData or {}
	self.tbSpecialDealerActData.tbSetting = tbSetting
end

function Auction:GetSpecialDealerSetting()
	local tbData = self.tbSpecialDealerActData or {}
	return tbData.tbSetting
end

function Auction:IsOnSpecialDealerAct()
	local tbSetting = Auction:GetSpecialDealerSetting()
	return tbSetting and next(tbSetting) 
end