--家族试炼
Fuben.KinTrainMgr = Fuben.KinTrainMgr or {}
local KinTrainMgr = Fuben.KinTrainMgr


function KinTrainMgr:Start()
    self.tbKinMap     = {}
    self.tbWaitPlayer = {}
    self.bInProcess   = true
    self.nStartTime   = GetTime()

    self:PushNotify()
    Timer:Register(Env.GAME_FPS * self.PREPARE_TIME, self.BeginTrain, self) --这里不能让副本来控制，因为副本的创建时间是不一定的
    SupplementAward:OnActivityOpen("KinTrain")
    Calendar:OnActivityBegin("KinFuben")
    Log("KinTrainMgr Start", GetTime())
end

function KinTrainMgr:PushNotify()
    local szMsg = "帮派试炼已经开启，各帮派成员可通过活动日历前往试炼地图"
    KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1)
end

function KinTrainMgr:Stop()
    if not self.bInProcess then
        Log("KinTrainMgr Try Stop Nonexistent Train")
        return
    end

    self.bInProcess = false
    for _, nMapId in pairs(self.tbKinMap or {}) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:OnTimeOut()
        end
    end
    Calendar:OnActivityEnd("KinFuben")
    Log("KinTrainMgr Stop", GetTime())
end

function KinTrainMgr:BeginTrain()
    for _, nMapId in pairs(self.tbKinMap) do
        local tbFubenInst = Fuben.tbFubenInstance[nMapId]
        if tbFubenInst then
            tbFubenInst:BeginTrain()
        end
    end
    Log("KinTrainMgr BeginTrain", GetTime())
end

function KinTrainMgr:OnFubenCreateSuccess(dwKinId, nMapId)
    if not self.bInProcess then
        Log("[KinTrainMgr OnFubenCreateSuccess]")
        self.tbWaitPlayer[dwKinId] = nil
        return
    end

    self.tbKinMap[dwKinId] = nMapId
    for dwID, _ in pairs(self.tbWaitPlayer[dwKinId] or {}) do
        local pPlayer = KPlayer.GetPlayerObjById(dwID)
        if pPlayer then
            self:TryEnterMap(pPlayer)
        end
    end
    self.tbWaitPlayer[dwKinId] = nil

    --开启家族实时语音
    if not ChatMgr:IsKinHaveChatRoom(dwKinId) then
        ChatMgr:CreateKinChatRoom(dwKinId)
    end
end

function KinTrainMgr:TryEnterMap(pPlayer)
    local bRet, szMsg = self:CheckEntry(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local dwKinId = pPlayer.dwKinId
    local nMapId = self.tbKinMap[dwKinId]
    local nMapTId, tbPos = self:GetFubenMapInfo()
    if not nMapId then
        if self.tbWaitPlayer[dwKinId] then
            self.tbWaitPlayer[dwKinId][pPlayer.dwID] = 1
            return
        end

        if GetTime() > (self.nStartTime + self.PREPARE_TIME) then
            pPlayer.CenterMsg("帮派试炼已结束")
            return
        end

        self.tbWaitPlayer[dwKinId] = {[pPlayer.dwID] = 1}
        Fuben:ApplyFuben(pPlayer.dwID, nMapTId, 
            function (nMapId)
                self:OnFubenCreateSuccess(dwKinId, nMapId)
            end,
            function ()
                Log("[KinTrainMgr] FubenCreateFail", dwKinId)
            end, dwKinId)
        Log("KinTrainMgr Try CreateMap", dwKinId)
        return
    end

    local tbInst = Fuben.tbFubenInstance[nMapId]
    if not tbInst or tbInst.bClose == 1 then
        pPlayer.CenterMsg("帮派试炼已结束")
        return
    end

    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(nMapId, unpack(tbPos))
    SupplementAward:OnJoinActivity(pPlayer, "KinTrain")
end

function KinTrainMgr:GetFubenMapInfo()
    if GetTimeFrameState(self.OPEN_DEFEND_TF) == 1 then
        return self.MAP_TID_DEFEND, self.ENTRY_POS_DEFEND, self.ONE_PLAYER_VALUE_DEFEND
    else
        return self.MAPTEMPLATEID, self.ENTRY_POS, self.ONE_PLAYER_VALUE
    end
end

function KinTrainMgr:CheckEntry(pPlayer)
    if not self.bInProcess then
        return false, "活动未开启"
    end

    if pPlayer.dwKinId == 0 then
        return false, "没有帮派，无法参加活动"
    end

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前状态不允许切换地图"
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
        return false, "所在地图不允许进入副本！";
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "非安全区不允许进入副本！";
    end

    return true
end

function KinTrainMgr:GetEndTime()
    if not self.bInProcess then
        return
    end

    if GetTime() < (self.nStartTime + self.PREPARE_TIME) then
        return self.nStartTime + self.PREPARE_TIME
    else
        return self.nStartTime + self.TOTAL_TIME
    end
end

function KinTrainMgr:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
    if not self.bInProcess then
        return false
    end

    local nMapId = self.tbKinMap[dwKinId]
    if not nMapId then
        return true
    end

    local tbFubenInst = Fuben.tbFubenInstance[nMapId]
    if tbFubenInst then
        tbFubenInst:MemberJoinKinChatRoom()
    end

    return true;
end

function KinTrainMgr:GetAwardList()
	local tbItemList;
	for _, tbInfo in ipairs(self.tbAuctionItem) do
		local szTimeFrime, tbList = unpack(tbInfo)
		if GetTimeFrameState(szTimeFrime) == 1 then
			tbItemList = tbList;
		else
			break;
		end
	end
	return tbItemList;
end

function KinTrainMgr:GetAward(nJoinNum)
    local tbItem = self:GetAwardList()
    if not tbItem then
        Log("[KinTrainMgr GetAward Err No AuctionAward In Cur Timeframe]", nJoinNum)
        return
    end

    local tbAward = {}
    local _, _, nValue = self:GetFubenMapInfo()
    local nAllValue = nJoinNum * nValue
    for nItemTID, nProp in pairs(tbItem) do
        local nItemValue = nAllValue * nProp
        local nDropNum = nItemValue/self.tbItemAuctionValue[nItemTID]
        local nDec = 1000000*(nDropNum - math.floor(nDropNum))
        nDropNum = math.floor(nDropNum)
        if nDec >= MathRandom(1000000) then
            nDropNum = nDropNum + 1
        end
        if nDropNum > 0 then
            table.insert(tbAward, {nItemTID, nDropNum})
        end
    end
    local tbRealAward = self:GetRealAward(tbAward)
    return tbRealAward
end

function KinTrainMgr:GetRealAward(tbAward)
    local tbResult = {}
    for _, tbInfo in ipairs(tbAward) do
        local tbItemInfo = KItem.GetItemBaseProp(tbInfo[1])
        if not tbItemInfo or not tbItemInfo.szClass or
            (tbItemInfo.szClass ~= "RandomItem" and
            tbItemInfo.szClass ~= "RandomItemByLevel" and
            tbItemInfo.szClass ~= "RandomItemByMaxLevel" and
            tbItemInfo.szClass ~= "RandomItemByTimeFrame") then
            table.insert(tbResult, tbInfo)
        else
            local nParamId = KItem.GetItemExtParam(tbInfo[1], 1)
            if tbItemInfo.szClass == "RandomItemByLevel" or tbItemInfo.szClass == "RandomItemByMaxLevel" then
                nParamId = Item:GetClass("RandomItemByLevel"):GetRandomKindId(GetMaxLevel(), nParamId)
            elseif tbItemInfo.szClass == "RandomItemByTimeFrame" then
                nParamId = Item:GetClass("RandomItemByTimeFrame"):GetRandomKindId(nParamId)
            end

            for i = 1, tbInfo[2] do
                local bRet, szMsg, tbAllAward = Item:GetClass("RandomItem"):RandomItemAward(nil, nParamId, self.ACTIVITY_NAME)
                if not bRet or bRet ~= 1 then
                    Log("[KinTrainMgr GetRealAward] ERR ?? get random item award fail !", unpack(tbInfo))
                else
                    for _, tbAward in ipairs(tbAllAward) do
                        table.insert(tbResult, {tbAward[2], tbAward[3]})
                    end
                end

            end
        end
    end
    return tbResult
end