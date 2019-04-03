local tbNpc   = Npc:GetClass("YueLaoNpc")
function tbNpc:OnDialog()
    local nOpenDay, nOpenTime = Wedding:CheckTimeFrame()
    if nOpenDay then
         Dialog:Show(
        {
            Text = string.format("千里姻缘一线牵，少侠可是来寻红线的另一头？\n[FFFE0D]结婚系统将在%d天后开放！[-]", nOpenDay),
            OptList = {},
        }, me, him)
        return 
    end
    -- 主城常驻NPC
    if him.szScriptParam == "CityNpc" then
        local tbOptList = {
            { Text = "预定婚礼", Callback = self.OrderWedding, Param = {self, me.dwID} };
            { Text = "参加婚宴", Callback = self.EnterWedding, Param = {self, me.dwID} };
        }
        local nLevel, tbPlayerBookInfo, nOpen = Wedding:CheckPlayerHadBook(me.dwID)
        if nLevel then
            local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
            if tbMapSetting and tbMapSetting.fnCheckBookIsOpen(nOpen) then
                table.insert(tbOptList, 1, { Text = "开始举行婚礼", Callback = self.TryStartWedding, Param = {self, me.dwID} })
            end
        end
        local nLover = Wedding:GetLover(me.dwID)
        if nLover then
            table.insert(tbOptList, { Text = "更改夫妻称号", Callback = self.ChangeTitle, Param = {self} })
        end
        Dialog:Show(
        {
            Text = "千里姻缘一线牵，少侠可是来寻红线的另一头？",
            OptList = tbOptList,
        }, me, him)
    -- 婚礼现场NPC
    elseif him.szScriptParam == "FubenNpc" then
        local tbInst = Fuben.tbFubenInstance[him.nMapId]
        if tbInst then
            tbInst:OnDialogYueLao(me, him)
        end
    end
	
end

function tbNpc:TryStartWedding(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    local nLevel = Wedding:CheckPlayerHadBook(dwID)
    local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nLevel]
    if not tbMapSetting then
        return
    end
    if tbMapSetting.szStartWeddingTip then
        pPlayer.MsgBox(tbMapSetting.szStartWeddingTip, {{"举行婚礼", self.StartWedding, self, dwID}, {"取消"}})
    else
        self:StartWedding(dwID)
    end
end

function tbNpc:StartWedding(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    Wedding:TryStartBookWedding(pPlayer)
end

function tbNpc:OrderWedding(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
    	return
	end
    if not Wedding:CheckOpen() then
        pPlayer.CenterMsg("婚礼预定将择良日开放，敬请期待！")
        return
    end
	pPlayer.CallClientScript("Ui:OpenWindow", "WeddingBookPanel")
end

function tbNpc:EnterWedding(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end
    if not Wedding.tbWeddingMap or not next(Wedding.tbWeddingMap) then
        pPlayer.CenterMsg("暂无正在举行的婚礼", true)
        return
    end
    pPlayer.CallClientScript("Ui:OpenWindow", "WeddingEnterPanel")
end

--------

function tbNpc:ChangeTitle()
    local nOtherId = Wedding:GetLover(me.dwID)
    if not nOtherId then
        Npc:ShowErrDlg(me, him, "你尚未结婚")
        return
    end

    local bOk, szErr = Wedding:CheckLoveTeam(me, true)
    if not bOk then
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    bOk, szErr = Npc:IsTeammateNearby(me, him, true)
    if not bOk then
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    local pOther = KPlayer.GetRoleStayInfo(nOtherId)
    local szHusbandName, szWifeName = me.szName, pOther.szName
    if me.GetUserValue(Wedding.nSaveGrp, Wedding.nSaveKeyGender)~=Gift.Sex.Boy then
        szHusbandName, szWifeName = szWifeName, szHusbandName
    end
    me.CallClientScript("Ui:OpenWindow", "MarriageTitlePanel", szHusbandName, szWifeName)
end