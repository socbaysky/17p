Require("CommonScript/DomainBattle/define.lua");
Require("CommonScript/DomainBattle/cross_common.lua");
Require("ServerScript/DomainBattle/cross_with_throne.lua");

DomainBattle.tbCrossInner = DomainBattle.tbCrossInner or Lib:NewClass(DomainBattle.tbCrossWithThrone)

local tbCrossDef = DomainBattle.tbCrossDef
local tbCrossWithThrone = DomainBattle.tbCrossWithThrone
local tbCrossInner = DomainBattle.tbCrossInner
local tbCross = DomainBattle.tbCross

tbCrossInner.tbTrapFun = Lib:CopyTB(tbCrossWithThrone.tbTrapFun or {})
tbCrossInner.tbOnSpawnNpcFun = Lib:CopyTB(tbCrossWithThrone.tbOnSpawnNpcFun or {})
tbCrossInner.tbOnNpcDeathFun = Lib:CopyTB(tbCrossWithThrone.tbOnNpcDeathFun or {})

function  tbCrossInner:init(nMapId, _, nIndex, tbKinList)
	if not nIndex then
		return
	end

	self.nIndex = nIndex
	self.tbKinList = {unpack(tbKinList)}
	self.tbKinCamp = {}
	for nCampIndex, nKinId in ipairs( self.tbKinList ) do
		local tbKinInfo = tbCross:GetKinInfo(nKinId)
		self.tbKinCamp[nKinId] = nCampIndex
		tbKinInfo.nInnerMapId = nMapId
		Lib:Tree(tbKinInfo)
	end
	Log("[Info]", "DomainBattleCross", "tbCrossInner:init")
end

function tbCrossInner:GetKinCamp(nKinId)
	return self.tbKinCamp[nKinId]
end

function tbCrossInner:OnInnerNotify()
	self.nInnerNotifyTimer = nil

	local nLeftTime = tbCross:GetStateLeftTime()

	local szMsg = string.format("临安内城将於%d秒後坍塌", nLeftTime)
	local function _InnerNotifyMsg(pPlayer)
		pPlayer.SendBlackBoardMsg(szMsg)
	end

	self:ForEachInMap(_InnerNotifyMsg)

	if nLeftTime <= 10 then
		local function _NotifyMsg(pPlayer)
			pPlayer.SendBlackBoardMsg("外城龙柱已重新出现，当前均为无人占领")
		end

		local function _EndNotify()
			self:ForEachInMap(_NotifyMsg)
		end

		Timer:Register((nLeftTime - 3) * Env.GAME_FPS, _EndNotify)
		return
	end

	self.nInnerNotifyTimer = Timer:Register(10 * Env.GAME_FPS, self.OnInnerNotify, self)
end

function tbCrossInner:OnInnerCityStart()
	if tbCrossWithThrone.OnInnerCityStart then
		tbCrossWithThrone.OnInnerCityStart(self)
	end

	--启动计时器通知结束
	self.nInnerNotifyTimer = Timer:Register((tbCross:GetStateLeftTime() - 30) * Env.GAME_FPS, self.OnInnerNotify, self)
end

function tbCrossInner:OnInnerCityEnd()
	if tbCrossWithThrone.OnInnerCityEnd then
		tbCrossWithThrone.OnInnerCityEnd(self)
	end
	--将本地图所有人传回外城
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbPlayer or {}) do
		local tbPlayerInfo = tbCross:GetPlayerInfo(pPlayer.dwID)
		local tbKinInfo = tbCross:GetKinInfo((tbPlayerInfo and tbPlayerInfo.nKinId) or 0)
		if tbPlayerInfo and tbKinInfo then
			local tbOuterInst = tbCross.tbInstList[tbKinInfo.nOuterMapId]
			if tbOuterInst then
				tbOuterInst:TransferToKinCamp(tbPlayerInfo.nKinId, pPlayer);
			else
				Log("[Error]", "DomainBattleCross", "tbCrossInner:OnInnerCityEnd Failed Not Found Outer Inst", pPlayer.dwID)
				Lib:Tree(tbPlayerInfo)
				Lib:Tree(tbKinInfo)
			end
		else
			Log("[Error]", "DomainBattleCross", "tbCrossInner:OnInnerCityEnd Failed Not Found PlayerInfo or KinInfo", pPlayer.dwID)
			Lib:Tree(tbPlayerInfo or {})
			Lib:Tree(tbKinInfo or {})
		end

	end
end

function tbCrossInner:OnStartAward()
	tbCrossWithThrone.OnStartAward(self)

	if self.nInnerNotifyTimer then
		Timer:Close(self.nInnerNotifyTimer)
		self.nInnerNotifyTimer = nil
	end
end

function tbCrossInner:TransferToKinCamp(nKinId, pPlayer)
	local nCampIndex = self:GetKinCamp(nKinId)
	if not nCampIndex then
		Log("[Error]", "DomainBattleCross", "tbCrossInner:TransferToKinCamp Failed Not Found Kin Camp Index", nKinId)
		return
	end

	local nPosX, nPosY = tbCross:GetCampPos(self.nMapTemplateId, nCampIndex)
	if not nPosX then
		Log("[Error]", "DomainBattleCross", "tbCrossInner:TransferToKinCamp Failed Not Found Camp Pos", nCampIndex, nKinId, pPlayer.dwID)
		return
	end

	pPlayer.SwitchMap(self.nMapId, nPosX, nPosY)
end

function tbCrossInner:OnThroneAddScore()
	tbCrossWithThrone.OnThroneAddScore(self)
	tbCross:AddKinScore(self.nOccupyThroneKinId, 60);
	return true
end
