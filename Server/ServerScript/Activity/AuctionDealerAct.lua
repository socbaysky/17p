local tbAct = Activity:GetClass("AuctionDealerAct");

tbAct.tbTimerTrigger = { };
tbAct.tbTrigger = { Init = { }, Start = { }, End = { }, };

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:OnStart();
	elseif szTrigger == "End" then
		self:OnEnd();
	end
end

function tbAct:OnStart()
	-- 参数1例子：  1396|5|0|1;1395|5|1|0
	-- 对应： ItemId, 数量，黎饰，一元起拍
	local tbAuctionItems = Lib:GetAwardFromString(self.tbParam[1]);
	if not next(tbAuctionItems) then
		Log("AuctionDealer Act Error: no items");
		return;
	end

	local tbExtraItems = {};
	for _, tbItemInfo in ipairs(tbAuctionItems) do
		local nItemId, nCount, nSilver, nOneUp = unpack(tbItemInfo);
		table.insert(tbExtraItems, {nItemId, nCount, nSilver == 1, nOneUp == 1});
		Log("AuctionDealer Act Add Items:", nItemId, nCount, nSilver, nOneUp);
	end

	Kin.Auction:SetDealerActData(tbExtraItems);
	Log("AuctionDealer Act Start");
end

function tbAct:OnEnd()
	Kin.Auction:SetDealerActData(nil);
	Log("AuctionDealer Act End");
end