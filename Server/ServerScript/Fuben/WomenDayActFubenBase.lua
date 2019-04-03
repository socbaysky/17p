local tbBase = Fuben:CreateFubenClass("WomenDayActFubenBase")
function tbBase:OnPreCreate(nGirlId, nBoyId)
    self.nGirlId = nGirlId
    self.nBoyId = nBoyId
end

function tbBase:OnLogin()
   self:OpenFubenUi(pPlayer) 
end

function tbBase:OnJoin(pPlayer)
   self:OpenFubenUi(pPlayer) 
end

function tbBase:OpenFubenUi(pPlayer)
    if self.tbCacheProgressInfo then
        pPlayer.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
    end
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben")
end

function tbBase:OnPlayerDeath()
    me.Revive(0)
end

function tbBase:OnLeaveMap(pPlayer)
    pPlayer.ClearTempRevivePos()
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")
    Activity:OnGlobalEvent("Act_LeaveWomenDayFuben", pPlayer.dwID)
    if self.bClose == 1 then
        return
    end
    self:GameLost()
end

function tbBase:GameLost()
    self.nDealyKickOutAllMapPlayerTime = 1
    self:Close()
end

function tbBase:GameWin()
    Activity:OnGlobalEvent("Act_CompleteWomenDayFuben", self.nGirlId, self.nBoyId)
    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "LingJueFengLayerPanel", "Win")
    self:Close()
end

function tbBase:OnAddOtherBuff(nMyId, nSkillId, nSkillLevel, nTime)
    local nOtherId = nMyId==self.nGirlId and self.nBoyId or self.nGirlId
    local pOther = KPlayer.GetPlayerObjById(nOtherId)
    if not pOther then
        return
    end

    self:OnUseSkillState(nSkillId)
    pOther.AddSkillState(nSkillId, nSkillLevel, 0, nTime * Env.GAME_FPS)
end

function tbBase:OnPlayerTrap(szTrap)
    Fuben.tbBase.OnPlayerTrap(self, szTrap)
    local tbAct = Activity:GetClass("WomenDayFubenAct")
    if szTrap~=tbAct.szFreezeTrapName or me.dwID~=self.nGirlId or self.bFreezed then
        return
    end

    local pGirl = KPlayer.GetPlayerObjById(self.nGirlId)
    local pBoy = KPlayer.GetPlayerObjById(self.nBoyId)
    if not pGirl or not pBoy then
        return
    end

    self.bFreezed = true

    local tbGirlBuff, tbBoyBuff = unpack(tbAct.tbFreezeTrapBuffs)
    local nGirlBuffId, nGirlBuffLvl, nGirlBuffTime = unpack(tbGirlBuff)
    local nBoyBuffId, nBoyBuffLvl, nBoyBuffTime = unpack(tbBoyBuff)
    self:OnUseSkillState(nGirlBuffId)
    self:OnUseSkillState(nBoyBuffId)
    pGirl.AddSkillState(nGirlBuffId, nGirlBuffLvl, 0, nGirlBuffTime*Env.GAME_FPS)
    pBoy.AddSkillState(nBoyBuffId, nBoyBuffLvl, 0, nBoyBuffTime*Env.GAME_FPS)

    self:UnLock(tbAct.nFreezeUnlock)
end

function tbBase:OnUseWomensDayItem(pPlayer)
    local tbAct = Activity:GetClass("WomenDayFubenAct")
    local nMapId, nX, nY = pPlayer.GetWorldPos()
    local tbNpcInfo = {
        nTemplateId = tbAct.nJiguanNpcId,
        nLevel = 1,
        nMapId = nMapId,
        nX = nX,
        nY = nY,
        nDir = 0,
    }
    self:DoAddNpc(tbNpcInfo, nil, tbAct.nJiguanNpcLock, tbAct.szJiguanNpcGroup)
end

function tbBase:OnShowQuickUse(nItemTemplateId)
    local pGirl = KPlayer.GetPlayerObjById(self.nGirlId)
    if not pGirl then
        Log("[x] WomenDayActFubenBase:OnShowQuickUse", self.nGirlId, nItemTemplateId)
        return
    end

    local tbItems = pGirl.FindItemInBag(nItemTemplateId)
    if not next(tbItems or {}) then
        Log("[x] WomenDayActFubenBase:OnShowQuickUse, no item", self.nGirlId, nItemTemplateId)
        return
    end
    local pItem = tbItems[1]
    pGirl.CallClientScript("Ui:OpenQuickUseItem", pItem.dwId)
end