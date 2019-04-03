
------------------取消通过该类道具提升技能等级上限功能 FT-12158 ------------------

local tbItem = Item:GetClass("SkillMaxLevel");
tbItem.nSaveLevelGroup = 134;
tbItem.nSaveLevelMaxCount = 20;


--------策划填写------------
tbItem.tbItemLimitInfo =
{
--- 道具的ID  最大使用次数  添加的技能点  存储的ID改变通知程序
    [4579] = {nMaxCount = 5, nAdd = 1, nSaveID =  1, nLevelUpGroup =  2, tbSell = {"Coin", 5000}};
    [4580] = {nMaxCount = 5, nAdd = 1, nSaveID =  2, nLevelUpGroup =  3, tbSell = {"Coin", 5000}};
    [4581] = {nMaxCount = 5, nAdd = 1, nSaveID =  3, nLevelUpGroup =  4, tbSell = {"Coin", 5000}};
    [4582] = {nMaxCount = 5, nAdd = 1, nSaveID =  4, nLevelUpGroup =  6, tbSell = {"Coin", 5000}};

    [7153] = {nMaxCount = 5, nAdd = 1, nSaveID =  5, nLevelUpGroup =  5, tbSell = {"Coin", 5000}};
    [7154] = {nMaxCount = 5, nAdd = 1, nSaveID =  6, nLevelUpGroup =  7, tbSell = {"Coin", 5000}};
    [7155] = {nMaxCount = 5, nAdd = 1, nSaveID =  7, nLevelUpGroup =  8, tbSell = {"Coin", 5000}};

    [7156] = {nMaxCount = 5, nAdd = 1, nSaveID =  8, nLevelUpGroup =  9, tbSell = {"Coin", 5000}};
    [7157] = {nMaxCount = 5, nAdd = 1, nSaveID =  9, nLevelUpGroup = 11, tbSell = {"Coin", 5000}};
    [7158] = {nMaxCount = 5, nAdd = 1, nSaveID = 10, nLevelUpGroup = 12, tbSell = {"Coin", 5000}};
}

--直接使用道具突破上限
tbItem.tbDirectBreakMaxLv =
{
--- 技能组ID  对应限制道具ID     消耗的道具ID      消耗的道具数量              时间轴限制
    [2]  = {nItemLimit = 4579, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"};
    [3]  = {nItemLimit = 4580, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"};
    [4]  = {nItemLimit = 4581, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"};
    [6]  = {nItemLimit = 4582, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel119"};

    [5]  = {nItemLimit = 7153, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel129"};
    [7]  = {nItemLimit = 7154, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel129"};
    [8]  = {nItemLimit = 7155, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel129"};

    [9]  = {nItemLimit = 7156, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel139"};
    [11] = {nItemLimit = 7157, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel139"};
    [12] = {nItemLimit = 7158, nConsumeItemID = 2424, nConsumeItemNum = 30, szTimeFrame = "OpenLevel139"};
}
---------------End ---------------------

function tbItem:LoadSetting()
    self.tbSkillNameInfo = {};
    for nItemId, tbInfo in pairs(self.tbItemLimitInfo) do
        self.tbSkillNameInfo[tbInfo.nLevelUpGroup] = self.tbSkillNameInfo[tbInfo.nLevelUpGroup] or {};
        self.tbSkillNameInfo[tbInfo.nLevelUpGroup][nItemId] = 1;
    end
end
tbItem:LoadSetting();

function tbItem:GetSkillExtLevelItem(nFactionSkill)
    local tbSkillInfo = FightSkill:GetSkillFactionInfo(nFactionSkill);
    if not tbSkillInfo then
        return;
    end

    if not tbSkillInfo.LevelUpGroup then
        return;
    end

    local tbAllInfo = self.tbSkillNameInfo[tbSkillInfo.LevelUpGroup];
    if not tbAllInfo then
        return;
    end
     
    return tbAllInfo;   
end


function tbItem:GetPlayerSkillLimit(pPlayer, nLevelUpGroup)
    local tbAllInfo = self.tbSkillNameInfo[nLevelUpGroup];
    if not tbAllInfo then
        return 0;
    end

    local nLimitLevel = 0;
    for nItemId, _ in pairs(tbAllInfo) do
        local tbLimitInfo = self.tbItemLimitInfo[nItemId];
        if tbLimitInfo then
            local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbLimitInfo.nSaveID);
            nLimitLevel = nLimitLevel + nCount * tbLimitInfo.nAdd;
        end    
    end

    return nLimitLevel;    
end    

function tbItem:CheckItemLimt(pPlayer, nItemTID)
    local tbInfo = self.tbItemLimitInfo[nItemTID];
    if not tbInfo then
        return false, "不能使用目前的道具";
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveLevelMaxCount then
        return false, "不能使用目前的道具!";
    end

    local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID);
    if nCount >= tbInfo.nMaxCount then
        return false, string.format("该道具最多使用%s个。", tbInfo.nMaxCount);
    end

    local nSkillID = FightSkill:GetSkillIdByLevelUpGroup(pPlayer.nFaction, tbInfo.nLevelUpGroup);
    if not nSkillID then
        return false, "技能不存在";
    end    

    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillID, 1);
    if not tbSkillInfo then
        return false, "技能不存在!";
    end

    return true, "", tbInfo, tbSkillInfo;   
end

-- function tbItem:OnUse(it)
--     local nItemTID = it.dwTemplateId;
--     local bRet, szMsg, tbInfo, tbSkillInfo = self:CheckItemLimt(me, nItemTID);
--     if not bRet then
--         me.CenterMsg(szMsg);
--         return;
--     end
--     return self:_OnUse(me, nItemTID, tbInfo, tbSkillInfo);
-- end

function tbItem:_OnUse(pPlayer, nItemTID, tbInfo, tbSkillInfo)
    local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID);
    nCount = nCount + 1;
    pPlayer.SetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID, nCount);

    pPlayer.CallClientScript("FightSkill:OnSkillMaxLvBreak", tbSkillInfo.SkillName or "-", tbInfo.nAdd)
    Log("SkillMaxLevel OnUse", pPlayer.dwID, nCount, tbInfo.nLevelUpGroup, nItemTID);
    return 1;
end

function tbItem:CheckUseItemBreak(pPlayer, nLevelUpGroup)
    local tbInfo = self.tbDirectBreakMaxLv[nLevelUpGroup]
    if not tbInfo then
        return false, "该技能不能使用道具提升"
    end
    if GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
        return false, "尚未开放"
    end
    local tbBaseInfo = KItem.GetItemBaseProp(tbInfo.nItemLimit)
    if not tbBaseInfo then
        return false, "道具异常"
    end
    local nUseLevel = tbBaseInfo.nRequireLevel
    if pPlayer.nLevel < nUseLevel then
        return false, string.format("%d级之後可使用道具提升该技能最大等级", nUseLevel)
    end

    local bRet, szMsg, tbLimitInfo, tbSkillInfo = self:CheckItemLimt(pPlayer, tbInfo.nItemLimit)
    if not bRet then
        return false, szMsg
    end
    local nCount = pPlayer.GetItemCountInAllPos(tbInfo.nConsumeItemID)
    if nCount < tbInfo.nConsumeItemNum then
        return false, "您的[FFFE0D]门派信物[-]数量不足[FFFE0D]" .. tbInfo.nConsumeItemNum .."[-]个"
    end
    return true, "", tbLimitInfo, tbSkillInfo, tbInfo
end

function tbItem:DoBreakMaxLvByItem(pPlayer, nLevelUpGroup)
    local bRet, szMsg, tbLimitInfo, tbSkillInfo, tbInfo = self:CheckUseItemBreak(pPlayer, nLevelUpGroup);
    if not bRet then
        pPlayer.CenterMsg(szMsg or "");
        return;
    end
    local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbInfo.nConsumeItemID, tbInfo.nConsumeItemNum, Env.LogWay_Item2BreakSkillMaxLv)
    if nConsumeCount ~= tbInfo.nConsumeItemNum then
        Log(debug.traceback(), pPlayer.dwID, nLevelUpGroup, nConsumeCount)
        return false, "道具消耗异常"
    end
    return self:_OnUse(pPlayer, tbInfo.nItemLimit, tbLimitInfo, tbSkillInfo);
end

-- function tbItem:GetIntrol(dwTemplateId)
--     local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
--     if not tbInfo then
--         return
--     end

--     local tbLimitInfo = self.tbItemLimitInfo[dwTemplateId]
--     if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
--         return
--     end

--     local nCount = me.GetUserValue(self.nSaveLevelGroup, tbLimitInfo.nSaveID)
--     return string.format("%s\n使用数量：%d/%d", tbInfo.szIntro, nCount, tbLimitInfo.nMaxCount)
-- end

function tbItem:CheckSellItem(pPlayer, nItemTemplateId)
    -- local tbInfo = self.tbItemLimitInfo[nItemTemplateId];
    -- if not tbInfo or not pPlayer then
    --     return false;
    -- end

    -- if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveLevelMaxCount then
    --     return false;
    -- end

    -- local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID);
    -- if nCount < tbInfo.nMaxCount then
    --     return false;
    -- end

    -- if not tbInfo.tbSell then
    --     return false;
    -- end    

    -- return true, tbInfo.tbSell;
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    if not Compose.UnCompose:CanUnCompose(nItemTemplateId) then
        return
    end
    return {szFirstName = "拆分", fnFirst = "UnCompose"};
end 

-- function tbItem:GetDefineName(it)
--     local szName = KItem.GetItemShowInfo(it.dwTemplateId, me.nFaction, me.nSex);
--     local tbLimitInfo = self.tbItemLimitInfo[it.dwTemplateId];
--     if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
--         return szName;
--     end

--     local nSkillID = FightSkill:GetSkillIdByBtnName(me.nFaction, tbLimitInfo.szSkill);
--     if not nSkillID then
--         return szName;
--     end    

--     local tbSkillInfo = FightSkill:GetSkillSetting(nSkillID, 1);
--     if not tbSkillInfo then
--         return szName;
--     end

--     return string.format("《%s》秘卷", tbSkillInfo.SkillName);
-- end 