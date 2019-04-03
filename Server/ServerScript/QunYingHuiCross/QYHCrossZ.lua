QunYingHuiCross.tbQunYingHuiZ = QunYingHuiCross.tbQunYingHuiZ or {}
local tbQunYingHuiZ = QunYingHuiCross.tbQunYingHuiZ
-- 准备场逻辑基类
tbQunYingHuiZ.tbPreMapLogic = tbQunYingHuiZ.tbPreMapLogic or {}
local tbPreMapLogic = tbQunYingHuiZ.tbPreMapLogic
-- 存放所有准备场逻辑
tbQunYingHuiZ.tbAllPreMapLogic = tbQunYingHuiZ.tbAllPreMapLogic or {};
-- 存放所有准备场创建信息
tbQunYingHuiZ.tbServerPreMapInfo = tbQunYingHuiZ.tbServerPreMapInfo or {}
-- 存放连接信息
tbQunYingHuiZ.tbZoneInfo = tbQunYingHuiZ.tbZoneInfo or {}
-- 用来计算各服最小时间轴
tbQunYingHuiZ.tbTimeFrame = tbQunYingHuiZ.tbTimeFrame or {}
-- 搜集各服的时间轴计算最小时间轴
function tbQunYingHuiZ:PreStart()
    self:Log("fnPreStart")
    self.tbTimeFrame = {}
    CallZoneClientScript(-1, "QunYingHuiCross:OnZoneCallBack", "OnPreStart")
end

function tbQunYingHuiZ:PreStartFinish(szTimeFrame, nMaxLevel)
    table.insert(self.tbTimeFrame, {szTimeFrame = szTimeFrame, nMaxLevel = nMaxLevel})
    self:Log("OnPreStartFinish",szTimeFrame, nMaxLevel)
end

-- 直接跨服触发start
function tbQunYingHuiZ:Start()
    local tbZoneInfo = self:GetZoneInfo()
    tbZoneInfo.szTimeFrame = self:GetMinTimeFrame() or "OpenLevel39"
	local nPreMapId = self:CreatePreMap()
    tbZoneInfo.nPreMapId = nPreMapId
    CallZoneClientScript(-1, "QunYingHuiCross:OnZoneCallBack", "OnStart")
    self:Log("fnStart", tbZoneInfo.szTimeFrame, nPreMapId)
end

function tbQunYingHuiZ:GetMinTimeFrame()
    if #self.tbTimeFrame > 1 then
        table.sort(self.tbTimeFrame, function (a, b) return a.nMaxLevel < b.nMaxLevel end )
    end
    return self.tbTimeFrame[1] and self.tbTimeFrame[1].szTimeFrame
end

function tbQunYingHuiZ:GetZoneInfo()
    return self.tbZoneInfo
end

function tbQunYingHuiZ:CreatePreMap()
    local nCreateMapId = CreateMap(QunYingHuiCross.nPreMapTID);
    local tbMapInfo = self:GetServerPreMapInfo(nCreateMapId);
    tbMapInfo.nMapId = nil;
    tbMapInfo.bApplyMap = true;
    Log("tbQunYingHuiZ fnCreatePreMap", nCreateMapId);
    return nCreateMapId
end

function tbQunYingHuiZ:GetServerPreMapInfo(nMapId)
    local tbInfo = self.tbServerPreMapInfo[nMapId];
    if not tbInfo then
        tbInfo =
        {
            nMapId = nil;
            bApplyMap = false;
        };
        self.tbServerPreMapInfo = tbInfo;
    end
    return tbInfo;
end

function tbQunYingHuiZ:SynPreMapLogic(szFun, ...)
    local szZoneInfo = self:GetZoneInfo()
    local tbPrLogic = self:GetPreMapLogic(szZoneInfo.nPreMapId)
    if tbPrLogic and tbPrLogic[szFun] then
        tbPrLogic[szFun](tbPrLogic, ...)
    else
        self:Log("OnSynPreMapLogic fail", szFun, tbPrLogic and 1 or 0)
    end
end

function tbQunYingHuiZ:GetPreMapLogic(nMapId)
    return self.tbAllPreMapLogic[nMapId];
end

function tbQunYingHuiZ:CreatePreMapLogic(nMapId)
    local tbPrLogic = self:GetPreMapLogic(nMapId);
    if tbPrLogic then
        self:Log("fnCreatePreMapLogic Exist tbPrLogic", nMapId)
        return;
    end
    local tbZoneInfo = self:GetZoneInfo()
    tbPrLogic = Lib:NewClass(tbPreMapLogic);
    self.tbAllPreMapLogic[nMapId] = tbPrLogic;
    if tbPrLogic.OnCreate then
        tbPrLogic:OnCreate(nMapId, tbZoneInfo.szTimeFrame);
    end
    local tbMapInfo = self:GetServerPreMapInfo(nMapId);
    tbMapInfo.nMapId = nMapId;
    tbMapInfo.bApplyMap = false;
    self:Log("fnCreatePreMapLogic PrLogic", nMapId)
end

function tbQunYingHuiZ:ClosePreMapLogic(nMapId)
    local tbPrLogic = self:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end
    if tbPrLogic.OnClose then
        tbPrLogic:OnClose();
    end
    self.tbServerPreMapInfo[nMapId] = nil;
    self.tbAllPreMapLogic[nMapId] = nil;
    self:Log("fnClosePreMapLogic", nMapId or -1)
end

function tbQunYingHuiZ:JoinMatch(pPlayer)
    self:CallPreMapFunc("DoJoinMatch", pPlayer)
end

function tbQunYingHuiZ:QuiteMatch(pPlayer)
    self:CallPreMapFunc("TryDoQuiteMatch", pPlayer)
end

function tbQunYingHuiZ:LeavePreMap(pPlayer)
    self:CallPreMapFunc("DoLeaveMap", pPlayer)
end

function tbQunYingHuiZ:KeepTeam(pPlayer)
    self:CallPreMapFunc("DoKeepTeam", pPlayer)
end

function tbQunYingHuiZ:RequestMatchData(pPlayer)
    self:CallPreMapFunc("DoRequestMatchData", pPlayer)
end

function tbQunYingHuiZ:RequestMatchTime(pPlayer)
    self:CallPreMapFunc("DoRequestMatchTime", pPlayer)
end

function tbQunYingHuiZ:ChooseFaction(pPlayer, nFaction)
    self:CallPreMapFunc("DoChooseFaction", pPlayer, nFaction)
end

function tbQunYingHuiZ:GetWinAward(pPlayer, nWin)
    self:CallPreMapFunc("DoGetWinAward", pPlayer, nWin)
end

function tbQunYingHuiZ:GetJoinAward(pPlayer, nJoin)
    self:CallPreMapFunc("DoGetJoinAward", pPlayer, nJoin)
end

function tbQunYingHuiZ:ChooseFactionChange(pPlayer, nFaction)
    self:CallPreMapFunc("DoChooseFactionChange", pPlayer, nFaction)
end

function tbQunYingHuiZ:CallPreMapFunc(szFun, ...)   
    local tbZoneInfo = self:GetZoneInfo()
    local tbPrLogic = self:GetPreMapLogic(tbZoneInfo.nPreMapId)
    if not tbPrLogic then
        self:Log("fnCallPreMapFunc fail", szFun, tbZoneInfo.nPreMapId)
        return;
    end
    tbPrLogic[szFun](tbPrLogic, ...)
end

function tbQunYingHuiZ:OnClientCall(szFun, ...)
    if self[szFun] then
        self[szFun](self, ...)
    else
        self:Log("fnOnClientCall fail", szFun)
    end
end

function tbQunYingHuiZ:Log(szLog, ...)
    Log("tbQunYingHuiZ ", szLog, ...);
end