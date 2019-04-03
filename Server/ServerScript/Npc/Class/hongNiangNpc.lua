local tbNpc   = Npc:GetClass("hongNiangNpc")
function tbNpc:OnDialog(szParam)
	local nOpenDay, nOpenTime = Wedding:CheckTimeFrame()
    if nOpenDay then
         Dialog:Show(
        {
            Text = string.format("愿无岁月可回头，且以深情共白首。\n[FFFE0D]结婚系统将在%d天后开放！[-]", nOpenDay),
            OptList = {},
        }, me, him)
        return 
    end
    local tbOptList = {}
    local nLover = Wedding:GetLover(me.dwID)
    if nLover then
        tbOptList = {
            { Text = "离婚处理", Callback = self.DismissMenuDlg, Param = {self} },
            { Text = "领取结婚纪念日奖励", Callback = self.ClaimMemorialDayRewards, Param = {self} },
        }
    else
        tbOptList = {
           { Text = "解除订婚关系", Callback = self.MakeSureDelEngaged, Param = {self, me.dwID}},
        }
    end
	Dialog:Show(
    {
        Text = "愿无岁月可回头，且以深情共白首。",
        OptList = tbOptList,
    }, me, him)
end

function tbNpc:MakeSureDelEngaged(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end
	if Wedding:IsSingle(pPlayer) then
		pPlayer.CenterMsg("你当前没有订婚关系")
		return
	end
	local nEngaged = Wedding:GetEngaged(pPlayer.dwID)
	if nEngaged then
		local pStayInfo = KPlayer.GetPlayerObjById(nEngaged) or KPlayer.GetRoleStayInfo(nEngaged)
		local szName = pStayInfo and pStayInfo.szName or ""
		local bHadBook = Wedding:CheckPlayerHadBook(dwID)
        -- 自动换行将颜色代码隔断会导致变色失败
		local szTip = string.format("确认跟 [FFFE0D]%s[-] 解除订婚关系吗？\n解除关系後[FF6464FF]「缘定今生」道具不退还[-]", szName)
        local szTipNone = string.format("确认跟 [FFFE0D]%s[-] 解除订婚关系吗？", szName) 
        if bHadBook then
            szTip = string.format("你已经预定了婚礼，%s 解除关系後[FF6464FF]预定的婚礼将被取消，所花费的金额不退还。[-]", szTipNone)
        end
		pPlayer.MsgBox(szTip,
			{
				{"确认解除", function () self:ComfirmDelEngaged(dwID) end},
				{"冷静一下"},
			});
	else
		pPlayer.CenterMsg("你们已经完婚，若爱走到了尽头，可以找我申请离婚")
	end
end

function tbNpc:ComfirmDelEngaged(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end
	Wedding:TryDelEngaged(pPlayer)
end

---------
function tbNpc:DismissMenuDlg()
    Dialog:Show({
        Text = "如果爱走到了尽头，分开未必不是好的开始。",
        OptList = {
            { Text = "协议离婚", Callback = self.Dismiss, Param = {self} },
            { Text = "强制离婚", Callback = self.ForceDismiss, Param = {self} },
            { Text = "取消离婚申请", Callback = self.CancelDismiss, Param = {self} },
        },
    }, me, him)
end

function tbNpc:Dismiss()
    local nOtherId = Wedding:GetLover(me.dwID)
    if not nOtherId then
        Npc:ShowErrDlg(me, him, "你尚未结婚")
        return
    end

    local bOk, szErr, szErrType = Npc:IsTeammateNearby(me, him, true)
    if not bOk then
        if szErrType then
            local tbErrs = {
                no_team = "请先和你的伴侣组队，再前来协议离婚",
                not_captain = "请由队长来申请协议离婚",
            }
            szErr = tbErrs[szErrType] or szErr
        end
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    local function fnConfirm()
        local bOk, szErr = Wedding:DismissReq(me)
        if not bOk and szErr then
            Npc:ShowErrDlg(me, him, szErr)
        end
    end

    Dialog:Show({
        Text = "百年修得同船渡，千年修得共枕眠。缘分难得，[FF6464FF]侠士想清楚要和对方解除婚姻关系吗？[-]",
        OptList = {
            { Text = "确定解除婚姻关系", Callback = fnConfirm, Param = {} },
        },
    }, me, him)
end

function tbNpc:ForceDismiss()
    local function fnConfirm()
        local bOk, szErr = Wedding:ForceDismissReq(me)
        if not bOk and szErr then
            Npc:ShowErrDlg(me, him, szErr)
        end
    end

    local nLover = Wedding:GetLover(me.dwID)
    if not nLover then
        Npc:ShowErrDlg(me, him, "你没有结婚")
        return
    end

    local szTxt = ""
    local _, nOfflineSec = Player:GetOfflineDays(nLover)
    if nOfflineSec>=Wedding.nForceDivorcePlayerOffline then
        szTxt = "侠士确定要解除婚姻关系吗？对方已离线超过[FFFE0D]14天[-]，申请後立即生效。"
    else
        local nNow = GetTime()
        local tbNow = os.date("*t", nNow)
        tbNow.day = tbNow.day+1
        tbNow.hour = 0
        tbNow.min = 0
        tbNow.sec = 1
        local nDeadline = os.time(tbNow)+Wedding.nForceDivorceDelayTime
        szTxt = string.format("侠士确定要解除婚姻关系吗？[-]该申请需花费[FFFE0D]%d元宝[-]，将在[FFFE0D]%s[-]後生效，期间可以找我取消申请。", Wedding.nForceDivorceCost, Lib:TimeDesc2(nDeadline-nNow))
    end
    Dialog:Show({
        Text = szTxt,
        OptList = {
            { Text = "确定解除婚姻关系", Callback = fnConfirm, Param = {} },
        },
    }, me, him)
end

function tbNpc:CancelDismiss()
    local tbRecord = Wedding:_IsDismissing(me.dwID)
    if not tbRecord then
        Npc:ShowErrDlg(me, him, "你没有申请离婚")
        return
    end

    local function fnConfirm()
        local bOk, szErr = Wedding:CancelDismissReq(me)
        if not bOk and szErr then
            Npc:ShowErrDlg(me, him, szErr)
        end
    end

    local _, nOtherId = unpack(tbRecord)
    local pOther = KPlayer.GetRoleStayInfo(nOtherId) or {szName=""}
    local szTxt = string.format("你正在申请与 [fffe0d]%s[-] 解除婚姻关系，你确定要取消该离婚申请吗？", pOther.szName)
    Dialog:Show({
        Text = szTxt,
        OptList = {
            { Text = "确认取消离婚申请", Callback = fnConfirm, Param = {} },
        },
    }, me, him) 
end

function tbNpc:ClaimMemorialDayRewards()
    local nOtherId = Wedding:GetLover(me.dwID)
    if not nOtherId then
        Npc:ShowErrDlg(me, him, "你尚未结婚")
        return
    end

    local bOk, szErr, szErrType = Npc:IsTeammateNearby(me, him, true)
    if not bOk then
        if szErrType then
            local tbErrs = {
                no_team = "请先和你的伴侣组队，再前来领取纪念日奖励",
                not_captain = "请由队长来领取纪念日奖励",
            }
            szErr = tbErrs[szErrType] or szErr
        end
        Npc:ShowErrDlg(me, him, szErr)
        return
    end

    local bOk, szErr = Wedding:ClaimMemorialDayRewardsReq(me)
    if not bOk and szErr then
        Npc:ShowErrDlg(me, him, szErr)
    end
end
