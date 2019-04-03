Require("CommonScript/DomainBattle/define.lua");
Require("CommonScript/DomainBattle/cross_common.lua");

DomainBattle.tbCross = DomainBattle.tbCross or {};
local tbCross = DomainBattle.tbCross

function tbCross:init()

if MODULE_ZONESERVER then
	self.tbInstList = {};
	self.tbType2Inst = {};
	self.tbPlayerList = {};
	self.nPkCampIndex = 1;
	self.nMaxNpcLevel = 105;
	self.nSiegeBuffLevel = 1;
	self.nKingCampAssignCounter = 1;
	self.tbKinRank = {}
	self.tbPlayerRank = {}

	self.tbOccupySyncInfo = {} --{[nMapId]={[szNpcName]=szKinName,},}
	self.tbTopKinSyncInfo = {} --{[nRank]={nRank=, nScore=, szName=, szMasterName=}}
	self.nTopKinSyncVersion = 0
	self.tbTopPlayerSyncInfo = {} --[[{
		[nKinId] =
		{
			nVersion = 0,
			tbList=
			{
				[nRank]={nRank=, nScore=, nKillCount=, szName=, bAid=},
			}
		},
	}]]
	self.nTopPlayerSyncVersion = 0
else
	self.nMaxNpcLevel = self:GetMaxNpcLevel()
	self.nSiegeBuffLevel = self:GetSiegeBuffLevel();
	self.tbScore = {}
	self.tbAidListSyncInfo = {}
end
	--本服存储参赛资格家族列表，跨服存储所有参赛家族
	self.tbKinList = {}
	self.tbAidList = {} --[nPlayerId]=nKinId
	self.tbKinAidPlayer = {} -- {[nKinId]={[nPlayerId]=true}}
end

function tbCross:OnServerStart()
	self:init();

	self:LoadConfig();

if MODULE_ZONESERVER then
	self:InitMapCallBack();
else
	self:LoadLocalData();
	self:CheckAidSignUp();
end

end

function tbCross:LoadConfig()
	--营地配置
	self.tbCampCfg = {}
	local tbCampList = LoadTabFile("Setting/DomainBattle/CrossCamp.tab", "dddd", nil, {"nMapTemplateId", "nCampIndex", "nX", "nY"})

	for _, tbCamp in pairs( tbCampList ) do
		self.tbCampCfg[tbCamp.nMapTemplateId] = self.tbCampCfg[tbCamp.nMapTemplateId] or {}
		local tbMapCampList = self.tbCampCfg[tbCamp.nMapTemplateId]
		tbMapCampList[tbCamp.nCampIndex] = tbCamp
	end

	--动态障碍
	self.tbDynObsCfg = {}
	local tbDynObsList = LoadTabFile("Setting/DomainBattle/CrossObstacle.tab", "dssdddds", nil, {"nMapTemplateId", "szType", "szName", "nX", "nY", "nNpcTemplate", "nDir", "szMiniMapSyncKey"})

	for _, tbDyncObs in pairs( tbDynObsList ) do
		self.tbDynObsCfg[tbDyncObs.nMapTemplateId] = self.tbDynObsCfg[tbDyncObs.nMapTemplateId] or {}
		local tbList = self.tbDynObsCfg[tbDyncObs.nMapTemplateId]
		table.insert(tbList, tbDyncObs)
	end

	--trap
	self.tbTrapCfg = {}
	local tbTrapList = LoadTabFile("Setting/DomainBattle/CrossTrap.tab", "dsssddddddddddddd", nil,
				{"nMapTemplateId", "szTrapType", "szTrapName", "szTrapNpcName", "nIndex", "nX", "nY",
				"nToX1", "nToY1", "nToX2", "nToY2", "nToX3", "nToY3",
				"nToX4", "nToY4", "nToX5", "nToY5"})

	for _, tbTrapInfo in pairs( tbTrapList ) do
		self.tbTrapCfg[tbTrapInfo.nMapTemplateId] = self.tbTrapCfg[tbTrapInfo.nMapTemplateId] or {}
		local tbList = self.tbTrapCfg[tbTrapInfo.nMapTemplateId]
		local tbInfo =
		{
			nMapTemplateId = tbTrapInfo.nMapTemplateId,
			szTrapType = tbTrapInfo.szTrapType,
			szTrapName = tbTrapInfo.szTrapName,
			szTrapNpcName = tbTrapInfo.szTrapNpcName,
			nIndex = tbTrapInfo.nIndex,
			nX = tbTrapInfo.nX, nY = tbTrapInfo.nY,
			tbToPos = {},
		}
		for i=1,5 do
			local tbPos = {nX = tbTrapInfo["nToX"..i], nY = tbTrapInfo["nToY"..i]}
			if tbPos.nX > 0 then
				table.insert(tbInfo.tbToPos, tbPos)
			end
		end

		tbList[tbTrapInfo.szTrapName] = tbList[tbTrapInfo.szTrapName] or {}
		local nIndex = tbTrapInfo.nIndex or 0

		if tbList[tbTrapInfo.szTrapName][nIndex] then
			Log("[Error]", "DomainBattleCross", "Load Trap Config Dup Trap Name")
			Lib:Tree(tbTrapInfo);
		else
			tbList[tbTrapInfo.szTrapName][nIndex] = tbInfo
		end
	end

	--npc
	self.tbNpcCfg = {}
	local tbNpcList = LoadTabFile("Setting/DomainBattle/CrossNpc.tab", "ddssddds", nil, {"nMapTemplateId", "nNpcTemplate", "szNpcName", "szNpcClass", "nX", "nY", "nDir", "szMiniMapSyncKey"})

	for _, tbNpcInfo in pairs( tbNpcList ) do
		self.tbNpcCfg[tbNpcInfo.nMapTemplateId] = self.tbNpcCfg[tbNpcInfo.nMapTemplateId] or {}
		local tbList = self.tbNpcCfg[tbNpcInfo.nMapTemplateId]
		table.insert(tbList, tbNpcInfo)
	end
end

function tbCross:GetCampPos(nMapTemplateId, nCampIndex)
	local tbMapCamp = self.tbCampCfg[nMapTemplateId]
	if not tbMapCamp then
		return
	end

	local tbCampInfo = tbMapCamp[nCampIndex]

	if not tbCampInfo then
		return
	end

	return tbCampInfo.nX, tbCampInfo.nY
end
