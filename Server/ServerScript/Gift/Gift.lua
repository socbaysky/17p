Gift.fnSend =
{
	[Gift.GiftType.RoseAndGrass] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.RoseAndGrass)
	end;
	[Gift.GiftType.FlowerBox] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.FlowerBox)
	end;
	[Gift.GiftType.MailGift] = function (pPlayer,nAcceptId,nCount,nItemId)
		local nGiftType = Gift.GiftType.MailGift
		local nTimesType = Gift:GetMailTimesType(nGiftType,nItemId)
		if not nTimesType or not Gift.MailTimesType[nTimesType] then
			Log("[Gift] Mail Time Type Error",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nItemId,nTimesType or -1)
			return
		end
		Gift:SendMailGift(pPlayer,nAcceptId,nCount,nGiftType,nItemId,nTimesType)
	end;
	[Gift.GiftType.Lover] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.Lover)
	end;
	[Gift.GiftType.MoonCake] = function (pPlayer,nAcceptId,nCount)
		Gift:SendGift(pPlayer,nAcceptId,nCount,Gift.GiftType.MoonCake)
	end;
}

Gift.tbLogway = 
{
	[Gift.GiftType.MoonCake] = Env.LogWay_SendGiftMoonCake;
}


-- 因为想灵活返回itemId才特殊处理
Gift.tbMailAcceptItemId = 
{
	[3565] = function (pPlayer,pAcceptPlayer,szKey)
		return DirectLevelUp:GetCanBuyItem()
	end,
}

Gift.tbMailAcceptItemKey = 
{
	["XinDeBook"] = function (pPlayer, pAcceptPlayer, nAcceptItemId)
		local tbXinDe = Item:GetClass("XinDeBook");
		local tbGetAward = tbXinDe:GetItemInfoById(nAcceptItemId);
		if not tbGetAward then
			return nAcceptItemId;
		end
			
		if tbGetAward.GetItemID ~= nAcceptItemId or tbGetAward.SendItemID <= 0 then
			return nAcceptItemId;
		end

		return tbGetAward.SendItemID;
	end,
	["FestivalGiftBox"] = function()
		local tbAct = Activity:GetClass("NewYearChris")
		return tbAct.nFestivalBoxId
	end,
};

Gift.tbMailGiftCheck = 
{
	["LevelUpItem"] = function (pPlayer,pAcceptPlayer,nItemId)
		-- if nItemId == DirectLevelUp.n4SendItemTID then
		-- 	local nGetItemTID = DirectLevelUp:GetCanBuyItem()
		-- 	local bRet, szMsg = DirectLevelUp:IsPlayerCanUse(pAcceptPlayer, nGetItemTID)
		-- 	return bRet, szMsg
		-- end

		-- return true
	end,

	["XinDeBook"] = function (pPlayer,pAcceptPlayer,nItemId)
	    if pAcceptPlayer.nLevel > pPlayer.nLevel then
	    	return false, "不能够赠送等级大於自己的玩家";
	    end	

	    return true;
	end,
}

Gift.tbFormatAward = 
{
	["LevelUpItem"] = function (tbAward,nAcceptItemId)
		-- local nEndTime = RegressionPrivilege:GetPrivilegeTime(pPlayer)
		-- if nEndTime <= GetTime() then
		-- 	return
		-- end

		-- if not tbAward[1] then
		-- 	return
		-- end

		-- table.insert(tbAward[1], nEndTime)
	end,
}

Gift.bIsOpenMailGift = true

function Gift:SendMailGift(pPlayer,nAcceptId,nCount,nGiftType,nItemId,nTimesType)
	if not Gift.bIsOpenMailGift then
		pPlayer.CenterMsg("邮件赠送礼物暂不开放",true)
		return
	end
	nAcceptId = tonumber(nAcceptId);

	if not pPlayer or not nAcceptId or not nCount or nCount < 1 or not nItemId then
		Log("[Gift] SendMailGift illegal data",pPlayer and pPlayer.dwID,nAcceptId,nCount,nGiftType,nItemId)
		return ;
	end

	local szItemName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)

	local tbMailInfo = Gift:GetMailGiftItemInfo(nItemId)

	if not tbMailInfo or not szItemName then
		pPlayer.CenterMsg("该物品不支持赠送!");
		Log("[Gift] SendMailGift illegal opa",pPlayer.dwID,pPlayer.szName,nAcceptId,nCount,nGiftType,nItemId)
		return
	end

	local bAcceptOnline = true
	local pAcceptPlayer = KPlayer.GetPlayerObjById(nAcceptId);
	if not pAcceptPlayer then
		bAcceptOnline = false
		if Gift.MailTimesTypeNeedOnline[nTimesType] then
			pPlayer.CenterMsg("对方不线上!");
			return
		end
		pAcceptPlayer = KPlayer.GetRoleStayInfo(nAcceptId)
		if not pAcceptPlayer then
			pPlayer.CenterMsg("获取资料失败")
			Log("[Gift] SendMailGift GetRoleStayInfo fail", tostring(nAcceptId))
			return
		end
	end

	local bIsFriend = FriendShip:IsFriend(pPlayer.dwID, nAcceptId);
	if not bIsFriend then
		pPlayer.CenterMsg("对方不是你的好友!");
		return
	end

	if pPlayer.GetItemCountInAllPos(nItemId) < nCount then
		pPlayer.CenterMsg("您拥有的数量不足")
		Log("[Gift] SendMailGift not enough count",pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nCount,nGiftType,nItemId)
		return
	end
	
	local bSexLimit = Gift:CheckMailSexLimit(tbMailInfo.szKey)
	local nItemSex = Gift:CheckMailItemSex(nItemId)
	if not nItemSex then
		pPlayer.CenterMsg("未知的赠送物品？")
		Log("[Gift] SendMailGift unknow item sex", pPlayer.dwID, pPlayer.szName, nAcceptId, pAcceptPlayer.szName, nCount, nGiftType, nItemId)
		return
	end
	local nAcceptSex = pAcceptPlayer.nSex;
	if not nAcceptSex or (nItemSex == Gift.Sex.Girl and nAcceptSex ~= Gift.Sex.Girl) or (bSexLimit and nItemSex == Gift.Sex.Boy and nAcceptSex ~= Gift.Sex.Boy) then
		pPlayer.CenterMsg("接受者的性别不符？？")
		Log("[Gift] SendMailGift unknow item sex", pPlayer.dwID, pPlayer.szName, nAcceptId, pAcceptPlayer.szName, nCount, nGiftType, nItemId, nItemSex, nAcceptSex)
		return
	end

	if tbMailInfo.tbData.nVip > 0 then
		if pPlayer.GetVipLevel() < tbMailInfo.tbData.nVip then
			pPlayer.CenterMsg(string.format("VIP达到%d级才可赠送",tbMailInfo.tbData.nVip))
			return
		end
	end 

	if tbMailInfo.tbData.nImityLevel > 0 then
		local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nAcceptId) or 0
		if nImityLevel < tbMailInfo.tbData.nImityLevel then
			pPlayer.CenterMsg(string.format("双方亲密度等级达到%d级才可赠送",tbMailInfo.tbData.nImityLevel))
			return
		end
	end

	local bRet,key,nRemain,szAcceptKey,szAcceptRemain
	if nTimesType == Gift.MailType.Times2Player then
		bRet,key,nRemain = Gift.GiftManager:CheckGiftTimes(pPlayer,nAcceptId,nCount,nGiftType,nItemId)
		if not bRet then
			pPlayer.CenterMsg(key);
			Log("[Gift] SendMailGift CheckGiftTimes fail",pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nCount,nGiftType,nItemId)
			return ;
		end
	elseif nTimesType == Gift.MailType.Times2Item then
		bRet,key,nRemain = Gift.GiftManager:CheckItemSend(pPlayer,nCount,nGiftType,nItemId)
		if not bRet then
			pPlayer.CenterMsg(key);
			return
		end
		bRet,szAcceptKey,szAcceptRemain = Gift.GiftManager:CheckItemAccept(pAcceptPlayer,nCount,nGiftType,nItemId)
		if not bRet then
			pPlayer.CenterMsg(szAcceptKey);
			if tbMailInfo.szKey=="FestivalGiftBox" then
				local nRemain = tonumber(szAcceptRemain)
				if nRemain>0 then
					Dialog:SendBlackBoardMsg(pPlayer, string.format("您的好友今天只能收%d个礼盒了！", nRemain))
				else
					Dialog:SendBlackBoardMsg(pPlayer, "您的好友今天不能再收礼盒了！")
				end
			end
			return
		end
	elseif nTimesType == Gift.MailType.NoLimit then
		-- no limit, do nothing
	else
		pPlayer.CenterMsg("未知类型")
		Log("[Gift] unknow type",pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nCount,nGiftType,nItemId)
		return
	end

	local fnCheck = Gift.tbMailGiftCheck[tbMailInfo.szKey]
	if fnCheck then
		local bResult,szMsg =  fnCheck(pPlayer,pAcceptPlayer,nItemId)
		if not bResult then
			pPlayer.CenterMsg(szMsg or "不支持赠送")
			return 
		end
	end

	if not tbMailInfo.tbData.bNotConsume then
		if pPlayer.ConsumeItemInAllPos(nItemId, nCount, Env.LogWay_SendMailGift) < nCount then
			pPlayer.CenterMsg("扣除道具%s失败！",szItemName);
			Log("[Gift] SendMailGift consume item fail", pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nItemId,nCount,nGiftType,key,nRemain,szAcceptKey,szAcceptRemain);
			return
		end
	end

	if nTimesType == Gift.MailType.Times2Player then
		if nRemain ~= Gift.Times.Forever then
			Gift.GiftManager:ReduceGiftTimes(pPlayer,nAcceptId,key,nRemain,nCount)
		end
		Gift.GiftManager:SynGiftData(pPlayer)
	elseif nTimesType == Gift.MailType.Times2Item then
		if nRemain ~= Gift.Times.Forever then
			Gift.GiftManager:ReduceItemSend(pPlayer,key,nRemain,nCount)
		end
		if szAcceptRemain ~= Gift.Times.Forever then
			Gift.GiftManager:ReduceItemAccept(pAcceptPlayer,szAcceptKey,szAcceptRemain,nCount)
		end
		Gift.GiftManager:SynGiftItemData(pPlayer)
	elseif nTimesType == Gift.MailType.NoLimit then
		Gift.GiftManager:SynNoLimitData(pPlayer)
	end

	local nAcceptItemId = nItemId
	local fnChangeItemId = Gift.tbMailAcceptItemId[nItemId]
	if fnChangeItemId then
		nAcceptItemId = fnChangeItemId(pPlayer,pAcceptPlayer,tbMailInfo.szKey)
		szItemName = KItem.GetItemShowInfo(nAcceptItemId, pPlayer.nFaction, pPlayer.nSex)
	end

	local fnChangeItemKey = Gift.tbMailAcceptItemKey[tbMailInfo.szKey];
	if fnChangeItemKey then
		nAcceptItemId = fnChangeItemKey(pPlayer, pAcceptPlayer, nAcceptItemId)
		szItemName = KItem.GetItemShowInfo(nAcceptItemId, pPlayer.nFaction, pPlayer.nSex)
	end	
	
	local tbAward = {{"item",nAcceptItemId,nCount}}
	local fnFormatAward = Gift.tbFormatAward[tbMailInfo.szKey]
	if fnFormatAward then
		fnFormatAward(tbAward,nAcceptItemId)
	end

	local tbMail = {
				To = nAcceptId;
				Title = "物品赠送";
				From = "系统";
				Text = string.format("    你的好友[FFFE0D]%s[-]给你赠送了[FFFE0D]%s[-]，请查收附件。",pPlayer.szName,szItemName);
				tbAttach = tbAward;
				nLogReazon = Env.LogWay_SendMailGift;
			};
	if not tbMailInfo.tbData.bNotSendMail then
		Mail:SendSystemMail(tbMail);
	end
	if tbMailInfo.szKey=="WaiYiGift" then
		local pAccept = KPlayer.GetRoleStayInfo(nAcceptId)
		if pAccept then
			local szMsg = string.format("「%s」从锦盒中拿出【%s】送给「%s」，说道：岂曰无衣？与子同裳。不妨穿上试试，定是十分俊俏！", pPlayer.szName, szItemName, pAccept.szName)
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	elseif tbMailInfo.szKey=="WaiYiGiftBox" then
		local pAccept = KPlayer.GetRoleStayInfo(nAcceptId)
		if pAccept then
			local szMsg = string.format("「%s」拿出【%s】送给「%s」，并说道：江南无所有，聊赠一枝春！", pPlayer.szName, szItemName, pAccept.szName)
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	elseif tbMailInfo.szKey=="PetGift" then
		local pAccept = KPlayer.GetRoleStayInfo(nAcceptId)
		if pAccept then
			local szMsg = string.format("「%s」捧着【%s】对「%s」说道：送你一只萌萌的小宠，你要好好的照顾它哦！", pPlayer.szName, szItemName, pAccept.szName)
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	elseif tbMailInfo.szKey=="GoodVoice" then
		local pAccept = KPlayer.GetRoleStayInfo(nAcceptId)
		if pAccept then
			local szMsg = string.format("「%s」拿出【%s】对「%s」说道：并说道：江南无所有，聊赠一枝春！", pPlayer.szName, szItemName, pAccept.szName)
			KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1)
		end
	elseif tbMailInfo.szKey=="FestivalGiftBox" then
		Dialog:SendBlackBoardMsg(pPlayer, "大侠送出一份礼物，与挚友关系更进一步")
		local pAccept = KPlayer.GetPlayerObjById(nAcceptId)
		if pAccept then
			Dialog:SendBlackBoardMsg(pAccept, string.format("恭喜大侠收到一份来自「%s」的礼物", pPlayer.szName))
		end
	end

	local nImitity = 0
	if tbMailInfo.tbData.nAddImitity then
		nImitity = tbMailInfo.tbData.nAddImitity * nCount;
		FriendShip:AddImitity(pPlayer.dwID, nAcceptId, nImitity, Env.LogWay_SendMailGift);
	end

	if bAcceptOnline then
		pAcceptPlayer.OnEvent("SendMailGiftSuccess", pAcceptPlayer, nAcceptItemId)
		Activity:OnPlayerEvent(pPlayer, "Act_SendMailGift", pAcceptPlayer, tbMailInfo.szKey);
	end
	Activity:OnPlayerEvent(pPlayer, "Act_SendMailGiftSuccess", tbMailInfo.szKey, nCount);
	pPlayer.CenterMsg("赠送成功")
	Log("[Gift] SendMailGift ok", pPlayer.dwID,pPlayer.szName,nAcceptId,pAcceptPlayer.szName,nItemId,nAcceptItemId,nCount,nGiftType,key,nRemain,szAcceptKey,szAcceptRemain,nImitity,tbMailInfo.tbData.bNotConsume and 1 or 0)
end

function Gift:SpecialCheck(pPlayer, nAcceptId, nCount, nGiftType)
	if nGiftType==Gift.GiftType.MoonCake then
		local pAccept = KPlayer.GetPlayerObjById(nAcceptId)
		if not pAccept then
			return false, "对方未在线"
		end

		local tbAct = Activity:GetClass("ZhongQiuJie")
		if tbAct:IsReceiveMoonCakeEnough(pAccept) then
			return false, "抱歉，该少侠已达到获赠数量上限"
		end
	end
	return true
end

function Gift:SendGift(pPlayer,nAcceptId,nCount,nGiftType)
	nAcceptId = tonumber(nAcceptId);
	if not pPlayer or not nAcceptId or not nCount or nCount < 1 then
		return ;
	end
	local bRet,szMsg,pAcceptPlayer,nSex,nItemId,szItemName = self:CheckCommond(pPlayer,nAcceptId,nCount,nGiftType)
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return ;
	end
	local bRet,key,nRemain = Gift.GiftManager:CheckGiftTimes(pPlayer,nAcceptId,nCount,nGiftType)
	if not bRet then
		pPlayer.CenterMsg(key);
		return
	end
	local bRet, szErr = self:SpecialCheck(pPlayer, nAcceptId, nCount, nGiftType)
	if not bRet then
		pPlayer.CenterMsg(szErr)
		return
	end
	local nSendId = pPlayer.dwID;
	local nLogWay = self.tbLogway[nGiftType] or Env.LogWay_SendGift
	if pPlayer.ConsumeItemInAllPos(nItemId, nCount, nLogWay) < nCount then
		pPlayer.CenterMsg("扣除道具%s失败！",szItemName);
		Log("[Gift] SendGift consume item fail",nSendId,nAcceptId,nItemId,nCount);
		return ;
	end
	if nRemain ~= Gift.Times.Forever then
		Gift.GiftManager:ReduceGiftTimes(pPlayer,nAcceptId,key,nRemain,nCount)
	end
	local nRate = Gift.Rate[nGiftType];
	if nRate then
		local nImitity = nRate * nCount;
		local bRet, szMsg = FriendShip:AddImitity(nSendId, nAcceptId, nImitity, nLogWay);
		if not bRet then
			pPlayer.CenterMsg(szMsg, true)
		end
	else
		Log("[Gift] SendGift no Imitity Rate",nSendId, nAcceptId,nGiftType,nCount,nSex,nItemId)
	end
	Gift.GiftManager:SynGiftData(pPlayer)
	self:EndDeal(pPlayer,pAcceptPlayer,nGiftType,nItemId,nSex,nCount)
	self:SendNotice(pPlayer,pAcceptPlayer,nGiftType,nSex,nImitity,nCount);
	Activity:OnPlayerEvent(pPlayer, "Act_SendGift", pAcceptPlayer, nGiftType, nItemId)
	Log("[Gift] Gift SendGift ",nAcceptId,nSendId,nCount,nGiftType,nImitity,nRate,nSex)
end


function Gift:SendNotice(pPlayer,pAcceptPlayer,nGiftType,nSex,nImitity,nCount)
	local szUnit = Gift:GetItemDesc(nGiftType,nSex) or "礼物"

	local szMeTips = ""
	local szHimTips = ""
	if nGiftType == Gift.GiftType.FlowerBox then
		szMeTips = string.format("你送给了「%s」",pAcceptPlayer.szName) ..szUnit
		szHimTips = string.format("你的好友「%s」送给你",pPlayer.szName) ..szUnit
		if nCount and nCount > 0 then
			for i=1,nCount do
				pPlayer.CenterMsg(szMeTips,true);
				pAcceptPlayer.CenterMsg(szHimTips,true);
			end
		end
	else
		szMeTips = string.format("你送给了「%s」%d",pAcceptPlayer.szName,nCount) ..szUnit
		szHimTips = string.format("你的好友「%s」送给你%d",pPlayer.szName,nCount) ..szUnit
		pPlayer.CenterMsg(szMeTips,true);
		pAcceptPlayer.CenterMsg(szHimTips,true);
	end
end

function Gift:EndDeal(pPlayer, pAcceptPlayer, nGiftType, nItemId, nSex, nCount)
	pPlayer.CallClientScript("Gift:SendGiftSuccess");
	if nGiftType == Gift.GiftType.FlowerBox then
		local szUnit = Gift:GetItemDesc(nGiftType,nSex) or "礼物"
		local nSendSex = pPlayer.nSex;
		local nAcceptSex = pAcceptPlayer.nSex;
		local szTips
		if self.tbWomensDayInst then
			szTips = self.tbWomensDayInst:OnSendGift(pPlayer, pAcceptPlayer, nGiftType, nItemId, nCount)
		end
		szTips = szTips or string.format(Gift:BoxNotice(nSendSex, nAcceptSex), pPlayer.szName, szUnit, pAcceptPlayer.szName)		-- 传回客户端计算滚动时间

		local tbPlayer = KPlayer.GetAllPlayer();
		local tbFriendPlayer = {
			[pPlayer.dwID] = true,
			[pAcceptPlayer.dwID] = true,
		}
		for _, pPlayer in pairs(tbPlayer) do
			local bShowEffect = tbFriendPlayer[pPlayer.dwID]
			pPlayer.CallClientScript("Gift:AcceptGiftSuccess", nGiftType, nItemId, szTips, nCount, bShowEffect);
		end
	else
		 pAcceptPlayer.CallClientScript("Gift:AcceptGiftSuccess",nGiftType,nItemId);
	end

	if nGiftType==Gift.GiftType.MoonCake then
		local tbAct = Activity:GetClass("ZhongQiuJie")
		tbAct:AddReceiveMoonCakeCount(pAcceptPlayer, 1)
	end

	local tbNotice = Gift.tbWorldNotice[nGiftType]
	if tbNotice then
		local szNotice = tbNotice[nSex]
		if szNotice then
			local szItemName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
			KPlayer.SendWorldNotify(1, 999, string.format(szNotice, pPlayer.szName, szItemName, pAcceptPlayer.szName), 1, 1)
		end
	end
end

function Gift:OnWomensDayOpen(tbInst)
	self.tbWomensDayInst = tbInst
end

function Gift:OnWomensDayClose()
	self.tbWomensDayInst = nil
end