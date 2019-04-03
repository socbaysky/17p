function ZhenFa:OnGenerate(pItem)
    if pItem.szClass ~= "JueYao" then
        Log("JueYao OnGenerate ClassName Err", pItem.szClass)
        return
    end
    local tbDetailInfo    = self.tbAttribs[pItem.nDetailType]
    local nMaxProbability = tbDetailInfo.nTotalWeight
    local nRate           = MathRandom(1, nMaxProbability)
    local nRateSum        = 0
    for nIdx, tbInfo in ipairs(tbDetailInfo.tbRandomAttrib) do
        nRateSum = nRateSum + tbInfo.nWeigth
        if nRate <= nRateSum then
            pItem.SetIntValue(self.JUEYAO_ATT_INDEX, nIdx)
            return
        end
    end
    local nIdx = MathRandom(#tbDetailInfo.tbRandomAttrib)
    pItem.SetIntValue(self.JUEYAO_ATT_INDEX, nIdx)
    Log("JueYao OnGenerate Err:", pItem.dwId)
end

function ZhenFa:GetItemInfo(nPos)
    return self.tbAttribs[nPos]
end

function ZhenFa:CheckFriend(pP1, pP2)
    return FriendShip:IsFriend(pP1.dwID, pP2.dwID)
end

function ZhenFa:CheckTeacherStudent(pP1, pP2)
    return TeacherStudent:_IsConnected(pP1, pP2)
end

function ZhenFa:CheckSwornFriends(pP1, pP2)
    return SwornFriends:IsConnected(pP1.dwID, pP2.dwID)
end

function ZhenFa:CheckMarriage(pP1, pP2)
    return Wedding:IsLover(pP1.dwID, pP2.dwID)
end

function ZhenFa:CheckBiWuZhaoQin(pP1, pP2)
    return pP2.dwID == BiWuZhaoQin:GetLover(pP1.dwID)
end

function ZhenFa:CheckFaction(pP1, pP2)
    return pP1.nFaction == pP2.nFaction
end

function ZhenFa:CheckKin(pP1, pP2)
    return pP1.dwKinId > 0 and pP1.dwKinId == pP2.dwKinId
end

function ZhenFa:IsRelationSame(pP1, pP2, nPos)
    if MODULE_ZONESERVER then
        return self:IsRelationSameZ(pP1, pP2, nPos)
    end
    local tbInfo = self.tbJueYao[nPos] or {}
    local szCheckFn = tbInfo.szCheckFn
    if Lib:IsEmptyStr(szCheckFn) or not self[szCheckFn] then
        return
    end

    return self[szCheckFn](self, pP1, pP2)
end

function ZhenFa:GetTeamer(nMe, tbMember, nMapId)
    local tbTeamer = {}
    for _, player in pairs(tbMember) do
        local pPlayer = player
        if type(pPlayer) == "number" then
            pPlayer = KPlayer.GetPlayerObjById(player)
        end
        if pPlayer and (not nMe or pPlayer.dwID ~= nMe) and (not nMapId or nMapId == pPlayer.nMapId) then
            table.insert(tbTeamer, pPlayer)
        end
    end
    return tbTeamer
end

function ZhenFa:ResetExternAttrib(pPlayer, nPos, nNewLv, bForceReset)
    local tbItemInfo = self:GetItemInfo(nPos)
    if not tbItemInfo then
        return
    end

    local tbInfo = self.tbJueYao[nPos]
    if not tbInfo then
        return
    end

    local nItemTID = pPlayer.GetUserValue(self.GROUP, tbInfo.nCurItemTID)
    local nIdx     = pPlayer.GetUserValue(self.GROUP, tbInfo.nAttribIdx)
    if nItemTID <= 0 or nIdx <= 0 then
        return
    end
    local tbAttrib = tbItemInfo.tbRandomAttrib[nIdx]
    if not tbAttrib then
        return
    end

    local nNewLevel, nRemoveGroupId, nApplyGroupId, nApplyLevel
    local nOldLv = pPlayer.GetUserValue(self.GROUP, tbInfo.nCurLevel)
    if nOldLv > 0 then
        nRemoveGroupId = tbAttrib.tbAttribGroupId[nOldLv]
        nNewLevel = 0
    end

    if (nNewLv and nNewLv ~= nOldLv) or bForceReset then
        nNewLevel = nNewLv or nOldLv
        nNewLevel = math.min(nNewLevel, self.MAX_ACTIVE_LEVEL)
        nApplyGroupId = tbAttrib.tbAttribGroupId[nNewLevel]
        if nApplyGroupId then
            local tbLevelInfo  = self.tbRealLevel[nItemTID] or {}
            local nAttribLevel = tbLevelInfo.tbLevel[nNewLevel]
            if not nAttribLevel then
                return
            end

            local nStrengthLevel = pPlayer.GetUserValue(self.GROUP, tbInfo.nStrengthLv)
            nApplyLevel = nAttribLevel + nStrengthLevel
        end
    end

    if nNewLevel then
        pPlayer.SetUserValue(self.GROUP, tbInfo.nCurLevel, nNewLevel)
    end
    if nRemoveGroupId and nRemoveGroupId ~= nApplyGroupId then
        pPlayer.RemoveExternAttrib(nRemoveGroupId)
    end
    if nApplyGroupId and nApplyLevel then
        pPlayer.ApplyExternAttrib(nApplyGroupId, nApplyLevel)
    end
    pPlayer.CallClientScript("ZhenFa:ResetExternAttribC", nRemoveGroupId, nApplyGroupId, nApplyLevel)
end

function ZhenFa:GetPlayerEquipIdx(pPlayer, nPos)
    local tbInfo = self.tbJueYao[nPos]
    if not tbInfo then
        return
    end
    local nIdx = pPlayer.GetUserValue(self.GROUP, tbInfo.nAttribIdx)
    local nCurLevel = pPlayer.GetUserValue(self.GROUP, tbInfo.nCurLevel)
    if nIdx > 0 then
        return nIdx, nCurLevel
    end
end

function ZhenFa:__AddLevel2Team(pNewJoinPlayer, tbAllMember, nMapId)
    local tbPosLevel = {}
    for nPos = 1, self.JUEYAO_TYPE_LEN do
        local nAttribIdx, nCurLevel = self:GetPlayerEquipIdx(pNewJoinPlayer, nPos)
        if nAttribIdx then
            tbPosLevel[nPos] = {nOrgLv = nCurLevel, nNewLv = 0}
        end
    end

    local tbRelationTmp = {}
    local tbNeedReinit  = {}
    local tbTeamer      = self:GetTeamer(pNewJoinPlayer.dwID, tbAllMember, nMapId or pNewJoinPlayer.nMapId)
    for _, pOtherMember in pairs(tbTeamer) do
        for nPos = 1, self.JUEYAO_TYPE_LEN do
            local nAttribIdx = self:GetPlayerEquipIdx(pNewJoinPlayer, nPos)
            if nAttribIdx then
                local szRelation = string.format("%d_%d_%s", pNewJoinPlayer.dwID, pOtherMember.dwID, nPos)
                if tbRelationTmp[szRelation] or self:IsRelationSame(pNewJoinPlayer, pOtherMember, nPos) then
                    tbRelationTmp[szRelation] = true
                    tbPosLevel[nPos].nNewLv = tbPosLevel[nPos].nNewLv + 1
                end
            end
            local nAttribIdx, nCurLevel = self:GetPlayerEquipIdx(pOtherMember, nPos)
            if nAttribIdx then
                local szRelation = string.format("%d_%d_%s", pNewJoinPlayer.dwID, pOtherMember.dwID, nPos)
                if tbRelationTmp[szRelation] or self:IsRelationSame(pNewJoinPlayer, pOtherMember, nPos) then
                    self:ResetExternAttrib(pOtherMember, nPos, nCurLevel + 1)
                    tbRelationTmp[szRelation] = true
                end
            end
        end
    end
    for nPos, tbLv in pairs(tbPosLevel) do
        local nAttribIdx = self:GetPlayerEquipIdx(pNewJoinPlayer, nPos)
        if nAttribIdx then
            if tbLv.nOrgLv ~= tbLv.nNewLv then
                self:ResetExternAttrib(pNewJoinPlayer, nPos, tbLv.nNewLv)
            end
        end
    end
end

function ZhenFa:OnJoinTeam(pNewJoin, tbAllMember)
    self:__AddLevel2Team(pNewJoin, tbAllMember)
end

function ZhenFa:OnEnterMap(pPlayer, nMapId)
    if pPlayer.dwTeamID == 0 then
        return
    end

    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if not teamData then
        return
    end

    local tbAllMember = teamData:GetMembers()
    self:__AddLevel2Team(pPlayer, tbAllMember, nMapId)
end

function ZhenFa:OnAddFriend(nPlayer1, nPlayer2)
    local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1)
    local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2)
    if not pPlayer1 or not pPlayer2 then
        return
    end
    if pPlayer1.nMapId ~= pPlayer2.nMapId then
        return
    end
    if pPlayer1.dwTeamID ~= pPlayer2.dwTeamID or pPlayer1.dwTeamID == 0 then
        return
    end
    local tbPlayer = {pPlayer1, pPlayer2}
    for _, pPlayer in ipairs(tbPlayer) do
        for nPos = 1, self.JUEYAO_TYPE_LEN do
            local _, nCurLevel = self:GetPlayerEquipIdx(pPlayer, nPos)
            nCurLevel = nCurLevel or 0
            self:ResetExternAttrib(pPlayer, nPos, nCurLevel + 1)
        end
    end
end

--[[
诀要作为道具（原做成装备，但装备位置需换包才可实现多对一），装备上会消耗掉该诀要，这样玩家在聊天频道无法发送已装备上的诀要
为了解决这个问题，给装备上的道具设个标志并且不消耗掉，UI中不显示改道具
每个玩家只会真正执行一次返还道具操作
]]
function ZhenFa:RestoreItem(pPlayer)
    local tbData = pPlayer.GetScriptTable("ZhenFaData")
    if not tbData.bRestoreFlag then
        tbData.bRestoreFlag = 1
        for nPos = 1, self.JUEYAO_TYPE_LEN do
            local tbInfo = self.tbJueYao[nPos]
            if pPlayer.GetUserValue(self.GROUP, tbInfo.nCurItemTID) > 0 then
                local nOldItemTID   = pPlayer.GetUserValue(self.GROUP, tbInfo.nCurItemTID)
                local nOldAttribIdx = pPlayer.GetUserValue(self.GROUP, tbInfo.nAttribIdx)
                local pItem = pPlayer.AddItem(nOldItemTID, 1, nil, Env.LogWay_ZhenFa)
                if not pItem then
                    Log(pPlayer.dwID, debug.traceback(), nOldItemTID, nOldAttribIdx)
                else
                    pItem.SetIntValue(self.JUEYAO_ATT_INDEX, nOldAttribIdx)
                    pItem.SetIntValue(self.JUEYAO_EQUIP_FLAG, 1)
                end
            end
        end
        Log("ZhenFa RestoreItem:", pPlayer.dwID)
    end
end

function ZhenFa:OnLogin(pPlayer)
    local nFightPower = self:GetFightPower(pPlayer)
    if nFightPower > 0 then
        RankBoard:UpdateRankVal("FightPower_ZhenFa", pPlayer.dwID, nFightPower)
    end
    self:RestoreItem(pPlayer)
    for nPos = 1, self.JUEYAO_TYPE_LEN do
        self:ResetExternAttrib(pPlayer, nPos)
    end
    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if not teamData then
        return
    end

    local tbAllMember = teamData:GetMembers()
    self:__AddLevel2Team(pPlayer, tbAllMember, nMapId)
end

function ZhenFa:__RemoveLevel2Team(player, tbAllMember, nMapId)
    local pMe = player
    if type(pMe) == "number" then
        pMe = KPlayer.GetPlayerObjById(player)
    end
    if pMe then
        local tbTeamer = self:GetTeamer(pMe.dwID, tbAllMember, nMapId or pMe.nMapId)
        for nPos = 1, self.JUEYAO_TYPE_LEN do
            local nAttribIdx = self:GetPlayerEquipIdx(pMe, nPos)
            if nAttribIdx then
                self:ResetExternAttrib(pMe, nPos)
            end
        end
        for _, pPlayer in ipairs(tbTeamer) do
            for nPos = 1, self.JUEYAO_TYPE_LEN do
                local nAttribIdx, nCurLevel = self:GetPlayerEquipIdx(pPlayer, nPos)
                if nAttribIdx and self:IsRelationSame(pMe, pPlayer, nPos) then
                    if nCurLevel > 0 then
                        self:ResetExternAttrib(pPlayer, nPos, nCurLevel - 1)
                    end
                end
            end
        end
    else
        local tbRelationTmp = {}
        local tbTeamer = self:GetTeamer(player, tbAllMember)
        for _, pPlayer in ipairs(tbTeamer) do
            local tbMyTeamer = self:GetTeamer(pPlayer.dwID, tbTeamer, pPlayer.nMapId)
            for nPos = 1, self.JUEYAO_TYPE_LEN do
                local nAttribIdx, nCurLevel = self:GetPlayerEquipIdx(pPlayer, nPos)
                if nAttribIdx then
                    local nLevel = 0
                    for _, pTeamer in ipairs(tbMyTeamer) do
                        local szRelation  = string.format("%d_%d_%s", pPlayer.dwID, pTeamer.dwID, nPos)
                        local szBRelation = string.format("%d_%d_%s", pTeamer.dwID, pPlayer.dwID, nPos)
                        if szRelation or szBRelation or self:IsRelationSame(pPlayer, pTeamer, nPos) then
                            nLevel = nLevel + 1
                            tbRelationTmp[szRelation] = true
                            tbRelationTmp[szBRelation] = true
                        end
                    end
                    if nCurLevel ~= nLevel then
                        self:ResetExternAttrib(pPlayer, nPos, nLevel)
                    end
                end
            end
        end
    end
end

function ZhenFa:OnLeaveTeam(player, tbAllMember)
    self:__RemoveLevel2Team(player, tbAllMember)
end

function ZhenFa:OnLeaveMap(pPlayer, nMapId)
    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if not teamData then
        return
    end

    local tbAllMember = teamData:GetMembers()
    self:__RemoveLevel2Team(pPlayer, tbAllMember, nMapId)
end

function ZhenFa:OnDelFriend(nPlayer1, nPlayer2)
    local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1)
    local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2)
    if not pPlayer1 or not pPlayer2 then
        return
    end
    if pPlayer1.nMapId ~= pPlayer2.nMapId then
        return
    end
    if pPlayer1.dwTeamID ~= pPlayer2.dwTeamID or pPlayer1.dwTeamID == 0 then
        return
    end
    local tbPlayer = {pPlayer1, pPlayer2}
    for _, pPlayer in ipairs(tbPlayer) do
        for nPos = 1, self.JUEYAO_TYPE_LEN do
            local _, nCurLevel = self:GetPlayerEquipIdx(pPlayer, nPos)
            nCurLevel = nCurLevel or 0
            self:ResetExternAttrib(pPlayer, nPos, math.max(nCurLevel - 1, 0))
        end
    end
end

function ZhenFa:TryEquipJueYao(pPlayer, pJueYao)
    local nPos = pJueYao.nDetailType
    local bRet = self:TryUnEquip(pPlayer, nPos, true)
    if not bRet then
        return
    end

    local nItemTID = pJueYao.dwTemplateId
    local nAttribIdx = pJueYao.GetIntValue(self.JUEYAO_ATT_INDEX)
    if not self.tbAttribs[nPos] or not self.tbAttribs[nPos].tbRandomAttrib[nAttribIdx] then
        pPlayer.CenterMsg("属性错误")
        return
    end
    pJueYao.SetIntValue(self.JUEYAO_EQUIP_FLAG, 1)

    local tbInfo = self.tbJueYao[nPos]
    pPlayer.SetUserValue(self.GROUP, tbInfo.nCurItemTID, nItemTID)
    pPlayer.SetUserValue(self.GROUP, tbInfo.nAttribIdx, nAttribIdx)
    pPlayer.SetUserValue(self.GROUP, tbInfo.nCurLevel, 0)
    self:OnEquipJueYao(pPlayer, nPos)
    FightPower:ChangeFightPower("ZhenFa", pPlayer)
    pPlayer.CallClientScript("ZhenFa:OnDataChange")
    pPlayer.CenterMsg("装备成功")
end

function ZhenFa:OnEquipJueYao(pPlayer, nPos)
    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID)
    if not teamData then
        return
    end

    local tbAllMember = teamData:GetMembers()
    local tbTeamer = self:GetTeamer(pPlayer.dwID, tbAllMember, pPlayer.nMapId)
    local nLevel = 0
    for _, pOtherMember in pairs(tbTeamer) do
        if self:IsRelationSame(pPlayer, pOtherMember, nPos) then
            nLevel = nLevel + 1
        end
    end
    if nLevel <= 0 then
        return
    end

    self:ResetExternAttrib(pPlayer, nPos, nLevel)
end

function ZhenFa:FindEquipedJYInBag(pPlayer, nJyTID, nAttIdx)
    local tbItems = pPlayer.FindItemInBag(nJyTID)
    for _, pItem in ipairs(tbItems or {}) do
        if pItem.GetIntValue(self.JUEYAO_EQUIP_FLAG) == 1 and pItem.GetIntValue(self.JUEYAO_ATT_INDEX) == nAttIdx then
            return pItem
        end
    end
end

function ZhenFa:TryUnEquip(pPlayer, nPos, bCallByEquip)
    local tbInfo = self.tbJueYao[nPos]
    if not tbInfo then
        pPlayer.CenterMsg("非诀要")
        return
    end

    local nOldItemTID = pPlayer.GetUserValue(self.GROUP, tbInfo.nCurItemTID)
    local nOldAttribIdx = pPlayer.GetUserValue(self.GROUP, tbInfo.nAttribIdx)
    if nOldItemTID > 0 then
        self:ResetExternAttrib(pPlayer, nPos)
        local pItem = self:FindEquipedJYInBag(pPlayer, nOldItemTID, nOldAttribIdx)
        if pItem then
            pItem.SetIntValue(self.JUEYAO_EQUIP_FLAG, 0)
        else
            Log("ZhenFa TryUnEquip Err:", pPlayer.dwID, nOldItemTID, nOldAttribIdx)
        end
    end
    if not bCallByEquip then
        if nOldItemTID > 0 then
            pPlayer.SetUserValue(self.GROUP, tbInfo.nCurItemTID, 0)
            pPlayer.SetUserValue(self.GROUP, tbInfo.nAttribIdx, 0)
            pPlayer.SetUserValue(self.GROUP, tbInfo.nCurLevel, 0)
        end
        FightPower:ChangeFightPower("ZhenFa", pPlayer)
        pPlayer.CallClientScript("ZhenFa:OnDataChange")
    end
    return true
end

function ZhenFa:TryStrength(pPlayer, nPos, tbMaterial)
    local tbJYInfo = self.tbJueYao[nPos]
    if not tbJYInfo then
        return
    end
    if not next(tbMaterial) then
        return
    end

    local nPlayerMaxLv = ZhenFa:GetPlayerStrengthMaxLv(pPlayer)
    local nSystemMaxLv = self:GetStrengthMaxLv()
    local nCurLv = pPlayer.GetUserValue(self.GROUP, tbJYInfo.nStrengthLv)
    if nCurLv >= nPlayerMaxLv or nCurLv >= nSystemMaxLv then
        pPlayer.CenterMsg("已达最大等级")
        return
    end

    local nMaterialExp = 0
    for nItemTID, nConsume in pairs(tbMaterial) do
        local tbInfo = KItem.GetItemBaseProp(nItemTID)
        if not tbInfo or tbInfo.szClass ~= "JueYaoMaterial" then
            pPlayer.CenterMsg("不能使用该道具强化")
            return
        end
        local nExp = KItem.GetItemExtParam(nItemTID, 1)
        local nCount = pPlayer.GetItemCountInAllPos(nItemTID)
        if nConsume > nCount then
            pPlayer.CenterMsg("道具数量不足，请重试")
            return
        end
        nMaterialExp = nMaterialExp + nExp * nConsume
    end
    if nMaterialExp == 0 then
        return
    end
    local nCurExp = pPlayer.GetUserValue(self.GROUP, tbJYInfo.nCurExp) + nMaterialExp
    local nFinalLv = nCurLv
    for nLvTmp = nCurLv + 1, math.min(nPlayerMaxLv, nSystemMaxLv) do
        local nNeed = nCurExp - self:GetStrengthNeedExp(nLvTmp)
        if nNeed < 0 then
            break
        end
        nCurExp = nNeed
        nFinalLv = nFinalLv + 1
    end
    if nFinalLv > nPlayerMaxLv and nPlayerMaxLv < nSystemMaxLv then
        pPlayer.CenterMsg("选择的道具过多，请重新选择")
        return
    end
    for nItemTID, nConsume in pairs(tbMaterial) do
        if pPlayer.ConsumeItemInAllPos(nItemTID, nConsume, Env.LogWay_ZhenFa) ~= nConsume then
            Lib:LogTB(tbMaterial)
            Log(pPlayer.dwID, nItemTID, nConsume, debug.traceback())
            return
        end
    end
    if nFinalLv == math.min(nPlayerMaxLv, nSystemMaxLv) then
        Log("ZhenFa TryStrength Eat Exp:", pPlayer.dwID, nPos, nCurExp)
        nCurExp = 0
    end
    pPlayer.SetUserValue(self.GROUP, tbJYInfo.nCurExp, nCurExp)
    if nFinalLv ~= nCurLv then
        pPlayer.SetUserValue(self.GROUP, tbJYInfo.nStrengthLv, nFinalLv)
        self:ResetExternAttrib(pPlayer, nPos, nil, true)
        FightPower:ChangeFightPower("ZhenFa", pPlayer)
    end
    pPlayer.CallClientScript("ZhenFa:OnStrengthSuccess", nFinalLv ~= nCurLv)
    Log("ZhenFa TryStrength Consume:", pPlayer.dwID, nMaterialExp)
end

function ZhenFa:TryDecompose(pPlayer, nItemID)
    local pItem = KItem.GetItemObj(nItemID)
    if not pItem or pItem.nCount <= 0 then
        return
    end

    if pItem.GetIntValue(self.JUEYAO_EQUIP_FLAG) > 0 then
        pPlayer.CenterMsg("已装备，无法分解")
        return
    end

    local tbResult = ZhenFa:GetDecomposeResult(pItem.dwTemplateId)
    if Item:Consume(pItem, 1) ~= 1 then
        pPlayer.CenterMsg("道具消耗失败")
        return
    end
    local tbAward = {}
    for _, tbInfo in ipairs(tbResult) do
        table.insert(tbAward, {"Item", tbInfo[1], tbInfo[2]})
    end
    if not next(tbAward) then
        pPlayer.CenterMsg("本次分解并无所获，请再接再厉！")
        return
    end
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_ZhenFa)
    pPlayer.CallClientScript("ZhenFa:OnDataChange")
    Log("ZhenFa TryDecompose:", pPlayer.dwID, pItem.dwTemplateId)
end

function ZhenFa:GetFightPower(pPlayer)
    local nFightPower = 0
    for _, tbInfo in ipairs(self.tbJueYao) do
        local nLevel = pPlayer.GetUserValue(self.GROUP, tbInfo.nStrengthLv)
        local nStrengthFP = self:GetStrengthPower(nLevel) or 0
        nFightPower = nFightPower + nStrengthFP

        local nItemTID = pPlayer.GetUserValue(self.GROUP, tbInfo.nCurItemTID)
        if nItemTID > 0 and self.tbRealLevel[nItemTID] then
            local nItemFP = self.tbRealLevel[nItemTID].nFightPower
            nFightPower = nFightPower + nItemFP
        end
    end
    return nFightPower
end

function ZhenFa:OnPlayerAdvatar(pPlayer)
    if not MODULE_ZONESERVER then
        return
    end
    if pPlayer.bAvatarInZone then
        return
    end
    pPlayer.bAvatarInZone = true
    for nPos = 1, self.JUEYAO_TYPE_LEN do
        self:ResetExternAttrib(pPlayer, nPos)
    end
end

ZhenFa.tbSafeFunc =
{
    TryUnEquip = true,
    TryStrength = true,
    TryDecompose = true,
}
function ZhenFa:OnClientCall(szFunc, ... )
    if not self.tbSafeFunc[szFunc] then
        return
    end
    self[szFunc](self, me, ...)
end