
-- 服务器启动回调
function Server:OnStartup()
	local nGMTSec = Lib:GetGMTSec();
	SetLogicGMTSec(nGMTSec);
	SetMaxLevel(255);
	Fuben:Load();
	ValueItem:Init();
	Transmit:OnServerStart();
	Lib:CallBack({ChatMgr.Init, ChatMgr})
	Lib:CallBack({FactionBattle.OnServerStart, FactionBattle})
	Lib:CallBack({DomainBattle.tbCross.OnServerStart, DomainBattle.tbCross});

	self:LoadFileServerCfg();
end

local nScriptDataNextSaveTime = 0;

--服务器每秒调用一次
function Server:Activate(nTimeNow)
	Lib:CallBack({ZhenFa.Activate, ZhenFa})
end

function Server:Quite()
end

function Server:OnWSConnected(nConnectIdx, nServerId)
	if not self.tbC2WRegister then
		self.tbC2WRegister = {}
		for szFunction, _ in pairs(c2z) do
			self.tbC2WRegister[szFunction] = 1;
		end
	end
	CallZoneClientScript(nConnectIdx, "Server:OnC2WRegister", self.tbC2WRegister);

	self.tbServerIdToConnectIdx = self.tbServerIdToConnectIdx or {};
	self.tbServerIdToConnectIdx[nServerId] = nConnectIdx;
	self.tbConnectIdxToServerId = self.tbConnectIdxToServerId or {};
	self.tbConnectIdxToServerId[nConnectIdx] = nServerId;
end

function Server:OnShutdownConnection(nConnectIdx, nServerId)
	self.tbServerIdToConnectIdx = self.tbServerIdToConnectIdx or {};
	self.tbServerIdToConnectIdx[nServerId] = nil;
	self.tbConnectIdxToServerId = self.tbConnectIdxToServerId or {};
	self.tbConnectIdxToServerId[nConnectIdx] = nil;
end

function Server:GetConnectIdx(nServerId)
	if not self.tbServerIdToConnectIdx then
		return;
	end

	if nServerId < 10000 then
		Log(debug.traceback());
	end

	return self.tbServerIdToConnectIdx[nServerId];
end

function Server:GetServerId(nConnectIdx)
	self.tbConnectIdxToServerId = self.tbConnectIdxToServerId or {};
	return self.tbConnectIdxToServerId[nConnectIdx]
end

function Server.OnZoneServerScript(nConnectIdx, szFunc, ...)
	local bRet = false
	if string.find(szFunc, ":") then
		local szTable, szFunc = string.match(szFunc, "^(.*):(.*)$");
		local tb = loadstring("return " .. szTable)();
		if tb and tb[szFunc] then
			Server.nCurConnectIdx = nConnectIdx;
			bRet = Lib:CallBack({tb[szFunc], tb, ...});
		end
	else
		local func = loadstring("return " .. szFunc)();
		Server.nCurConnectIdx = nConnectIdx;
		bRet = Lib:CallBack({func, ...});
	end
	Server.nCurConnectIdx = nil;
	if not bRet then
		Log("Server:OnZoneServerScript Error", nConnectIdx, szFunc, ...)
	end
end

function Server:OnTransferLogin(pPlayer, nSubServerIdx)
	local KinMgr = GetKinMgr()

	local szTitle = KinMgr.GetTitle(pPlayer.dwID) or ""
	local szReplace = Sdk:GetServerDesc(pPlayer.nZoneServerId)
	szReplace = string.format("［%s］", szReplace)
	if pPlayer.dwKinId ~= 0 and not Lib:IsEmptyStr(szTitle) then
	    local szNew = string.gsub(szTitle, "［家族］", szReplace)
	    Kin:SyncTitle(pPlayer.dwID, szNew)
	else
		--pPlayer.GetNpc().SetTitle(szReplace, 1, 0)
	end

	self:SyncZoneFileServer(pPlayer)

	Log("Server OnPlayerLogin:", pPlayer.dwID, pPlayer.nZoneServerId)
end

function Server:LoadFileServerCfg()
	local tbCfg = Lib:LoadIniFile("world_server.ini", 0, 1);
	if tbCfg.FileServer then
		self.szFileServerIp = tbCfg.FileServer.IP
		self.nFileServerPort = tonumber(tbCfg.FileServer.Port)
	end
end

function Server:SyncZoneFileServer(pPlayer)
	pPlayer.CallClientScript("FileServer:SyncZoneFileServer", self.szFileServerIp, self.nFileServerPort)
end


function Server:GetServerRoleCombieId(dwOrgPlayerId, nServerId)
	return dwOrgPlayerId + 2^32*nServerId
end

function Server:GetServerRoleUnLinkId(nCombineId)
	local nServerId 		= math.floor(nCombineId / (2^32) );
	local dwOrgPlayerId		= math.floor(nCombineId % (2^32) );
	return nServerId, dwOrgPlayerId;
end