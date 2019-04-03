Wedding.tbDoubleFly = Wedding.tbDoubleFly or {}
local tbDoubleFly = Wedding.tbDoubleFly
tbDoubleFly.tbTrapInPlayer = tbDoubleFly.tbTrapInPlayer or {}
local nLinAnMapTID = 15
local function fnAllMember(tbMember, fnSc, ...)
    for _, pMember in ipairs(tbMember or {}) do
        fnSc(pMember, ...);
    end
end
function tbDoubleFly:OnPlayerLinAnTrap(pPlayer, szTrapName)
	if szTrapName == "daqinggongIn" then
		self.tbTrapInPlayer[pPlayer.dwID] = true
		pPlayer.CallClientScript("Wedding:OnDoubleFlyTrapIn")
	elseif szTrapName == "daqinggongOut" or szTrapName == "qinggong2_1" then
		self.tbTrapInPlayer[pPlayer.dwID] = nil
		pPlayer.CallClientScript("Wedding:OnDoubleFlyTrapOut")
	end
end

function tbDoubleFly:TryPlayDoubleFly(pPlayer)
	local bRet, szMsg, pLover = self:CheckPlayDoubleFly(pPlayer)
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return 
	end
	local tbPlayer = {pPlayer, pLover}
	local function fnStart(pPlayer)
	    pPlayer.CallClientScript("Wedding:StartDoubleFly")
	    if Wedding.tbDoubleFlyEndPos then
	    	pPlayer.SetPosition(unpack(Wedding.tbDoubleFlyEndPos))
	    end
	    pPlayer.tbDoubleFly = nil
	    self.tbTrapInPlayer[pPlayer.dwID] = nil
	end

	local nNowTime = GetTime()
	pPlayer.tbDoubleFly = pPlayer.tbDoubleFly or {}
    local nFlyTime = pPlayer.tbDoubleFly[pLover.dwID] or 0
    -- 是否已经请求了双飞
    if nNowTime - nFlyTime < Wedding.nDoubleFlyWaitTime then
    	pPlayer.CenterMsg("等待对方同意双人轻功请求")
    	return
    end
    pLover.tbDoubleFly = pLover.tbDoubleFly or {}
    local nLoveFlyTime = pLover.tbDoubleFly[pPlayer.dwID] or 0
    -- 对方是否请求了双飞
    if nNowTime - nLoveFlyTime < Wedding.nDoubleFlyWaitTime then
    	fnAllMember(tbPlayer, fnStart);
    	return 
    end
    pPlayer.tbDoubleFly[pLover.dwID] = nNowTime
    pPlayer.CallClientScript("Wedding:OnRequestDoubleFly")
    pLover.CallClientScript("Wedding:OnBeRequestDoubleFly")
    pPlayer.CenterMsg(string.format("你请求与%s施展双人轻功", pLover.szName))
    pLover.CenterMsg(string.format("%s请求与你施展双人轻功", pLover.szName))
    Log("tbDoubleFly fnTryPlayDoubleFly ", pPlayer.dwID, pPlayer.szName, pLover.dwID, pLover.szName, nLoveFlyTime, nFlyTime)
end

function tbDoubleFly:CheckPlayDoubleFly(pPlayer)
	if not self:CheckIsInDoubleFlyArena(pPlayer) then
		return false, "该区域不能施展双人轻功"
	end
	local nLoverId = Wedding:GetLover(pPlayer.dwID)
	if not nLoverId then
		return false, "结婚关系才可施展双人轻功"
	end
	local pLover = KPlayer.GetPlayerObjById(nLoverId)
	if not pLover then
		return false, "施展双人轻功需要夫妻双方同时线上"
	end
	if not self.tbTrapInPlayer[pPlayer.dwID] then
		return false, "你不在指定区域，无法施展双人轻功"
	end
	if not self.tbTrapInPlayer[nLoverId] then
		return false, "你的侠侣不再指定区域，无法施展双人轻功"
	end
	local tbPlayer = {pPlayer, pLover}
	for _, pP in ipairs(tbPlayer) do
		if not pP.bWeddingDressOn then
			return false, string.format("「%s」没有穿上婚服", pP.szName)
		end
	end
	local nMapId1, nX1, nY1 = pPlayer.GetWorldPos()
    local nMapId2, nX2, nY2 = pLover.GetWorldPos()
    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    if fDists > (Wedding.nDoubleFlyMinDistance * Wedding.nDoubleFlyMinDistance) or nMapId1 ~= nMapId2 then
        return false, "你的侠侣不在附近"
    end

    return true, nil, pLover
end

function tbDoubleFly:CheckIsInDoubleFlyArena(pPlayer)
	local _, nX, nY = pPlayer.GetWorldPos()
	local fDist = Lib:GetDistance(Wedding.tbDoubleFlyCanterPos[1], Wedding.tbDoubleFlyCanterPos[2], nX, nY)
	if (pPlayer.nMapTemplateId == nLinAnMapTID and fDist < Wedding.nDoubleFlyMaxDistance) then
		return true
	end
end

function tbDoubleFly:OnLogin(pPlayer)
	local bInArena = self:CheckIsInDoubleFlyArena(pPlayer)
	if bInArena then
		pPlayer.CallClientScript("Wedding:OnDoubleFlyTrapIn")
	else
		pPlayer.CallClientScript("Wedding:OnDoubleFlyTrapOut")
	end
end

function tbDoubleFly:OnLeaveMap(pPlayer)
	self.tbTrapInPlayer[pPlayer.dwID] = nil
	pPlayer.CallClientScript("Wedding:OnDoubleFlyTrapOut")
end