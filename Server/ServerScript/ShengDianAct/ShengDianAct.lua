ShengDianAct.tbRevivePoint = {{4341, 4877}, {15978, 2675}}
ShengDianAct.tbOpenTime = {Lib:ParseDateTime("2017.10.29 20:00:00"), Lib:ParseDateTime("2017.10.29 20:30:00")}
ShengDianAct.nZoneId = 1
function ShengDianAct:GetRandomPoint()
    local nRan = MathRandom(2)
    local nX, nY = unpack(self.tbRevivePoint[nRan])
    return nX, nY
end

if MODULE_ZONESERVER then
    local tbMap = Map:GetClass(ShengDianAct.MAP_ID)
    tbMap.tbDeathCB = {}
    function tbMap:OnEnter(nMapId)
        me.nCanLeaveMapId = nMapId
        me.bSelfAutoRevive = true
        local nX, nY = ShengDianAct:GetRandomPoint()
        me.SetTempRevivePos(ShengDianAct.MAP_ID, nX, nY, 0)
        self.tbDeathCB[me.dwID] = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self)
    end

    function tbMap:OnLeave(nMapId)
        me.nCanLeaveMapId = nil
        me.bSelfAutoRevive = nil
        if self.tbDeathCB[me.dwID] then
            PlayerEvent:UnRegister(me, "OnDeath", self.tbDeathCB[me.dwID])
            self.tbDeathCB[me.dwID] = nil
        end
    end
    
    function tbMap:OnPlayerDeath()
        me.Revive(0)
        local nX, nY = ShengDianAct:GetRandomPoint()
        me.SetTempRevivePos(ShengDianAct.MAP_ID, nX, nY, 0)
    end
    return
end

function ShengDianAct:IsOpen()
    return GetTime() >= self.tbOpenTime[1] and GetTime() < self.tbOpenTime[2]
end

function ShengDianAct:CheckEnter(pPlayer)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_RandomFuben) then
        return false, "目前状态不允许参加该活动"
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
        return false, "所在地图不允许进入"
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "不在安全区，不允许进入"
    end

    if not self:IsOpen() then
        return false, "不在活动时间内"
    end

    return true
end

function ShengDianAct:TryEnter(pPlayer)
    local bRet, szMsg = self:CheckEnter(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end
    pPlayer.SetEntryPoint()
    local nX, nY = self:GetRandomPoint()
    pPlayer.SwitchSubZoneMap(self.nZoneId, self.MAP_ID, nX, nY)
end

--ID:ShengDianAct.tbFakePlayer中的玩家, 赵丽颖-1，林更新-2
--content:从ShengDianAct.tbContent中读取或直接使用
--nVoiceId:语音信息ID，从tbVoice中取
function ShengDianAct:SendMessage(nChannelType, nID, content, nVoiceId, nLevel)
    local bRet, szMsg = ShengDianAct:CheckMessageParam(nChannelType, nID, content, nVoiceId, nLevel)
    if not bRet then
        return bRet, szMsg
    end

    KPlayer.BoardcastScript(nLevel or 1, "ShengDianAct:SendMessage", nChannelType, nID, content, nVoiceId)
    return true
end