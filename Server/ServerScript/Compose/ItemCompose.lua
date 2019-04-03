function Compose:TryComposeItem(nItemID)
    local bRet, szMsg, tbConsumeInfo = self:CheckItemID(nItemID);
    if not bRet then
        me.CenterMsg(szMsg);
        return;
    end

    bRet = self:CheckItemNum(tbConsumeInfo);
    if not bRet then
        me.CenterMsg("合成失败，道具数量不足");
        return;
    end

    bRet = self:ConsumeChildItem(tbConsumeInfo);
    if not bRet then
        me.CenterMsg("合成失败，请重试");
        return;
    end

    Log("Compose:TryComposeItem Success, AddID:", nItemID);
    local pEquip = me.AddItem(nItemID, 1, nil, Env.LogWay_ComposeItem);
    me.CallClientScript("Partner:OnComposeSuccess", nItemID, pEquip.dwId);
end

function Compose:CheckItemID(nItemID)
    if not nItemID or type(nItemID) ~= "number" then
        return false, "合成失败，请重试";
    end

    local tbConsumeInfo = self:GetConsumeInfo(nItemID);
    if not tbConsumeInfo then
        return false, "道具无需合成";
    end

    return true, "", tbConsumeInfo;
end

function Compose:CheckItemNum(tbConsumeInfo)
    for _, tbChildInfo in pairs(tbConsumeInfo) do
        local nCountInBag = me.GetItemCountInAllPos(tbChildInfo.nChildTemplateID);
        if nCountInBag < tbChildInfo.nNeedNum then
            return false;
        end
    end

    return true;
end

function Compose:ConsumeChildItem(tbConsumeInfo)
    for _, tbChildInfo in pairs(tbConsumeInfo) do
        local nConsumeCount = me.ConsumeItemInAllPos(tbChildInfo.nChildTemplateID, tbChildInfo.nNeedNum, Env.LogWay_ComposeUse);
        if nConsumeCount < tbChildInfo.nNeedNum then
            return false;
        end
    end

    return true;
end