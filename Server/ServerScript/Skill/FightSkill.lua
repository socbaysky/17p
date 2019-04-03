Require("CommonScript/Item/XiuLian.lua");

function FightSkill:SkillLevelUp(pPlayer, nSkillId)
    local bRet, szMsg, nBaseLevel, nNeedPoint = self:CheckSkillLeveUp(pPlayer, nSkillId);
    if not bRet then
        pPlayer.CallClientScript("Player:OnFightSkillLevelUp", false, szMsg);
        return;
    end

    self:CostPlayerSkillPoint(pPlayer, nNeedPoint);
    self:DoSkillLevelUp(pPlayer, nSkillId, 1);
    pPlayer.CallClientScript("Player:OnFightSkillLevelUp", true, nSkillId, nBaseLevel + 1);
    Log("FightSkill SkillLevelUp", pPlayer.dwID, pPlayer.szName, nSkillId, nBaseLevel + 1, nNeedPoint or 0);
end

function FightSkill:DoSkillLevelUp(pPlayer, nSkillId, nUpLevel)
    pPlayer.LevelUpFightSkill(nSkillId, nUpLevel);
    FightPower:ChangeFightPower("Skill", pPlayer);
end

function FightSkill:CostPlayerSkillPoint(pPlayer, nCostPoint)
    --local nSkillPoint = pPlayer.GetMoney("SkillPoint");
    --if not  pPlayer.CostMoney("SkillPoint", nCostPoint, Env.LogWay_SkillLevelUp) then
    --    Log("FightSkill CostPlayerSkillPoint", pPlayer.dwID, nSkillPoint, nCostPoint);
    --    Log(debug.traceback())
    --    return 
    --end
    local nToalCostPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
    nToalCostPoint = nToalCostPoint + nCostPoint;
    pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, nToalCostPoint);
    Log("FightSkill CostPlayerSkillPoint", pPlayer.dwID, nCostPoint, nToalCostPoint);
end

function FightSkill:CheckResetSkillPoint(pPlayer, bNotJudgeGold)
    local nToalCostPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
    if nToalCostPoint <= 0 then
        return false, "没有重置的技能点";
    end

    if not bNotJudgeGold and pPlayer.nLevel >= FightSkill.nCostGoldLevelResetSkill and pPlayer.nMapTemplateId ~= ChangeFaction.tbDef.nMapTID then
        if FightSkill.nCostGoldResetSkill > pPlayer.GetMoney("Gold") then
            return false, string.format("元宝不足%s", FightSkill.nCostGoldResetSkill);
        end
    end    

    return true, "";  
end

function FightSkill.CostGoldResetPointCallBack(nPlayerId, bSuccess)
    if not bSuccess then
        return false;
    end

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then
        return false;
    end

    local bRet, szMsg = FightSkill:CheckResetSkillPoint(pPlayer, true);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return false;
    end

    FightSkill:ResetSkillPoint(pPlayer);
    return true;
end

function FightSkill:DoResetSkillPoint(pPlayer)
    local bRet, szMsg = self:CheckResetSkillPoint(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    if pPlayer.nLevel >= FightSkill.nCostGoldLevelResetSkill and pPlayer.nMapTemplateId ~= ChangeFaction.tbDef.nMapTID then
        pPlayer.CostGold(FightSkill.nCostGoldResetSkill, Env.LogWay_ResetSkill, nil, FightSkill.CostGoldResetPointCallBack);
    else
        FightSkill:ResetSkillPoint(pPlayer);    
    end     
end

function FightSkill:ResetSkillPoint(pPlayer)
    local nToalCostPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
    pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, 0);
    --pPlayer.AddMoney("SkillPoint", nToalCostPoint, Env.LogWay_ResetSkill);
    pPlayer.ResetFactionSkill();
    FightPower:ChangeFightPower("Skill", pPlayer);
    pPlayer.CenterMsg("技能点分配已重置，请重新分配");
    pPlayer.CallClientScript("Player:ServerSyncData", "SkillPanelUpdate");
    Log("ResetSkillPoint", pPlayer.dwID, pPlayer.nLevel, nToalCostPoint);
end


FightSkill.tbMagicCallScriptFun = 
{
    [XiuLian.tbDef.nXiuLianBuffId] = function (pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
        if nEnd == 0 then
            return;
        end
            
        local pPlayer = pNpc.GetPlayer();
        if not pPlayer then
            Log("Error Not Player");
            return;
        end

        XiuLian:ResetResidueExp(pPlayer, "Buff");
    end
}

function FightSkill:MagicCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
    local funCallScript = FightSkill.tbMagicCallScriptFun[nSkillId];
    if funCallScript then
        funCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3);
    end     
end

function FightSkill:DoBreakMaxLvByItem(pPlayer, nSkillId)
    local tbSkillInfo = FightSkill:GetSkillFactionInfo(nSkillId)
    if not tbSkillInfo or not tbSkillInfo.LevelUpGroup then
        return
    end

    local bRet, szMsg, tbInfo = self:CheckUseItemBreak(pPlayer, tbSkillInfo.LevelUpGroup)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end
    local nConsumeCount = pPlayer.ConsumeItemInAllPos(tbInfo.nConsumeItemID, tbInfo.nConsumeItemNum, Env.LogWay_Item2BreakSkillMaxLv)
    if nConsumeCount ~= tbInfo.nConsumeItemNum then
        Log(debug.traceback(), pPlayer.dwID, tbSkillInfo.LevelUpGroup, nConsumeCount)
        pPlayer.CenterMsg("道具消耗异常")
        return
    end

    local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID) + 1
    pPlayer.SetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID, nCount)
    local tbSkillSetting = FightSkill:GetSkillSetting(nSkillId, 1) or {}
    pPlayer.CallClientScript("FightSkill:OnSkillMaxLvBreak", tbSkillSetting.SkillName or "-", tbInfo.nAdd)
    Log("SkillMaxLevel OnUse", pPlayer.dwID, nCount, tbSkillInfo.LevelUpGroup, tbInfo.nConsumeItemID)
    return 1
end