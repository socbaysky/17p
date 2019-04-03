local tbAct = Activity:GetClass("SnowmanAct")

tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

local Snowman = Kin.Snowman

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		self:InitAct()
	elseif szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerWrong", "OnGatherAnswerWrong")
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerRight", "OnGatherAnswerRight")
		Activity:RegisterPlayerEvent(self, "Act_DialogSnowman", "OnDialogSnowman")
		Activity:RegisterGlobalEvent(self, "Act_OnKinMapCreate", "OnKinMapCreate")
		Activity:RegisterGlobalEvent(self, "Act_OnKinMapDestroy", "OnKinMapDestroy")
		Activity:RegisterGlobalEvent(self, "Act_OnKinGatherJoin", "OnKinGatherJoin")
		Activity:RegisterGlobalEvent(self, "Act_KinGather_Close", "OnKinGatherClose")
		Activity:RegisterGlobalEvent(self, "Act_KinGather_Question", "OnKinGatherQuestion")
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
		self:OnStartAct()
	elseif szTrigger == "End" then
		self:OnEndAct()
	end
	Log("SnowmanAct OnTrigger:", szTrigger)
end

function tbAct:OnKinGatherQuestion(nKinId,tbGatherData)
	local kinData = Kin:GetKinById(nKinId)
	if not kinData or not kinData:IsMapOpen() then
		return 
	end

	if tbGatherData and tbGatherData.nCurQuestionIdx and tbGatherData.nCurQuestionIdx == 2 then
		local nPosX,nPosY = unpack(Snowman.tbSnowmanNpcPos)
		local szMsg = string.format("获得铲子後，前去帮派地图<%d,%d>养护帮派许愿树吧！",nPosX* Map.nShowPosScale,nPosY* Map.nShowPosScale)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId, {nLinkType = ChatMgr.LinkType.Position, linkParam = {kinData:GetMapId(),nPosX,nPosY, Kin.Def.nKinMapTemplateId}});
	end
end

function tbAct:OnGatherAnswerWrong(pPlayer)
	if not Snowman.tbAnswerWrongBegin or not Snowman.tbAnswerWrongEnd or not Snowman:CheckAlive() then
		return
	end
	if not Snowman:CheckLevel(pPlayer) then
		Log("[SnowmanAct] OnGatherAnswerWrong level limit",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
		return
	end

	local nCount = MathRandom(Snowman.tbAnswerWrongBegin,Snowman.tbAnswerWrongEnd)

	pPlayer.SendAward({{"item", Snowman.nSnowflakeItemId, nCount, Snowman.nTrueEndTime}}, nil, true, Env.LogWay_SnowmanAct);
	Log("[SnowmanAct] OnGatherAnswerWrong ",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
end

function tbAct:OnGatherAnswerRight(pPlayer)
	if not Snowman.tbAnswerRightBegin or not Snowman.tbAnswerRightEnd or not Snowman:CheckAlive() then
		return
	end
	if not Snowman:CheckLevel(pPlayer) then
		Log("[SnowmanAct] OnGatherAnswerRight level limit",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
		return
	end

	local nCount = MathRandom(Snowman.tbAnswerRightBegin,Snowman.tbAnswerRightEnd)

	pPlayer.SendAward({{"item", Snowman.nSnowflakeItemId, nCount, Snowman.nTrueEndTime}}, nil, true, Env.LogWay_SnowmanAct);

	Log("[SnowmanAct] OnGatherAnswerRight ",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
end

function tbAct:OnDialogSnowman(pPlayer,pNpc)
	local nKinId = pNpc.tbTmp and pNpc.tbTmp.nKey
	if not nKinId or nKinId ~= pPlayer.dwKinId then
		Log("[SnowmanNpc] no match kin id",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,nKinId or 0)
		return
	end

	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanNpc] no kinData",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,nKinId)
		return 
	end

	local fnDetail = function (dwID)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			pPlayer.CallClientScript("Kin.Snowman:Detail","ArborDayCure")
		end
	end

	local fnMakeWish = function (dwID)
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			pPlayer.CallClientScript("Kin.Snowman:MakeWish")
		end
	end 

	local tbSnowmanData = kinData:GetSnowmanData()
	local tbOptList = {
		{Text = "进行养护", Callback = self.MakingSnowman, Param = {self, pNpc.nId,pPlayer.dwID}},
		{Text = "我要许愿", Callback = fnMakeWish, Param = {pPlayer.dwID}},
		--{Text = "领取雪人礼盒", Callback = self.GetGiftBox, Param = {self, pPlayer.dwID}},
		{Text = "了解详情", Callback = fnDetail, Param = {pPlayer.dwID}}
	}

	if not Snowman:CheckAlive() then
		tbOptList = {
		{Text = "查看愿望列表", Callback = fnMakeWish, Param = {pPlayer.dwID}},
		--{Text = "领取雪人礼盒", Callback = self.GetGiftBox, Param = {self, pPlayer.dwID}},
		--{Text = "了解详情", Callback = fnDetail, Param = {pPlayer.dwID}}
	}
	end

    Dialog:Show(
    {
        Text    = "树木的生长需要良好的环境，还望大侠能够多帮我调整土壤的舒适度。",
        OptList = tbOptList,
    }, pPlayer, pNpc);
end

function tbAct:GetGiftBox(dwID)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end

	local kinData = Kin:GetKinById(pPlayer.dwKinId);
	if not kinData then
		pPlayer.CenterMsg("请先加入帮派")
		return
	end

	local tbSnowmanData = kinData:GetSnowmanData()
	if not tbSnowmanData.nProcess or tbSnowmanData.nProcess ~= Snowman.Process_Type.MAKING then
		pPlayer.CenterMsg("帮派聚集烤火时才能领取宝箱！")
		return
	end

	-- 因为对话框所以检查
	if not Snowman:IsRunning() then
		pPlayer.CenterMsg("活动已经结束")
		return 
	end

	local nAward = DegreeCtrl:GetDegree(pPlayer, "SnowmanActAward")
	if nAward < 1 then
		pPlayer.CenterMsg("今日你已领取过奖励了！")
		return
	end

	if not Snowman:CheckLevel(pPlayer) then
		pPlayer.CenterMsg(string.format("请先将等级提升到%d级！",Snowman.JOIN_LEVEL))
		return
	end

	if not DegreeCtrl:ReduceDegree(pPlayer, "SnowmanActAward", 1) then
		pPlayer.CenterMsg("领取礼盒次数扣除失败", true)
		return 
	end

	pPlayer.SendAward(Snowman.tbDayAward, nil, true, Env.LogWay_SnowmanAct);
end

function tbAct:MakingSnowman(nNpcId,dwID)
	if not nNpcId or not dwID then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end

	local bRet,szMsg = self:CheckMaking(pPlayer,nNpcId)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end
   
    local fnMaking = function (dwID,nNpcId)
   		local pMaker = KPlayer.GetPlayerObjById(dwID)
		if not pMaker then
			return
		end
		local bRet,szMsg = self:CheckMaking(pMaker,nNpcId)
		if not bRet then
			pMaker.CenterMsg(szMsg)
			return
		end
		local nHave,kinData = unpack(szMsg)
		local nKinId = kinData.nKinId
		local nConsume = pMaker.ConsumeItemInAllPos(Snowman.nSnowflakeItemId,nHave, Env.LogWay_SnowmanAct);
	    if nConsume < nHave then
	    	pMaker.CenterMsg("扣除铲子失败！",true);
	    	Log("[SnowmanNpc] MakingSnowman no kinData",pMaker.dwID,pMaker.szName,nKinId,nConsume,nHave)
	    	return
	    end
	    local nNpcLevel = Snowman:GetLevelBySnowflake(kinData.nSnowflake)
	    local nSnowflake = (kinData.nSnowflake or 0) + nHave
	    kinData:SetSnowflake(nSnowflake)
	    pPlayer.AddExperience(nConsume * Snowman.nSnowFlakeExp,Env.LogWay_SnowmanAct)
	    tbAct:OnUpdateSnowman(pMaker)
	    Dialog:SendBlackBoardMsg(pMaker, string.format("成功进行了%d次养护，帮派许愿树似乎长大了些！",nConsume));
	    Log("[SnowmanNpc] MakingSnowman ok ",pMaker.dwID,pMaker.szName,nKinId,kinData.szName,nSnowflake,nNpcLevel,nConsume,nHave)
	end

	local nHave = unpack(szMsg)
	pPlayer.MsgBox(string.format("您当前拥有「铲子」%d个，是否确定全部用来养护帮派许愿树？",nHave),
		{
			{"确定", fnMaking, pPlayer.dwID,nNpcId},
			{"取消"},
		})
end

function tbAct:CheckMaking(pPlayer,nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[SnowmanNpc] MakingSnowman no pNpc",nNpcId,dwID)
		return false,"许愿树不见了?"
	end

	local nKinId = pNpc.tbTmp and pNpc.tbTmp.nKey
	if not nKinId or pPlayer.dwKinId ~= nKinId then
		Log("[SnowmanNpc] MakingSnowman no match kin id ",nNpcId,dwID,pPlayer.szName,pPlayer.dwKinId,nKinId or 0)
		return false,"哪个帮派的许愿树?"
	end

	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanNpc] MakingSnowman no kinData",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,nKinId)
		return false,"你是哪个帮派的?"
	end

	if not Snowman:CheckLevel(pPlayer) then
		return false,string.format("请先将等级提升到%d级",Snowman.JOIN_LEVEL)
	end

    local nHave = pPlayer.GetItemCountInAllPos(Snowman.nSnowflakeItemId)
    if nHave <= 0 then
    	return false,"请收集一些「铲子」再来堆许愿树"
    end

	-- 因为对话框所以检查
	if not Snowman:IsRunning() then
		return false,"活动已经结束"
	end

	if not Snowman:CheckAlive() then
		return false, "活动结束"
	end

    return true,{nHave,kinData}
end

function tbAct:TraverseInKinMap(kinData, fnCall, ...)
	local tbMember  = Kin:GetKinMembers(kinData.nKinId)
	local nKinMapId = kinData:GetMapId()
	for nPlayerId, _ in pairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer and pPlayer.nMapId == nKinMapId then
			fnCall(pPlayer, ...)
		end
	end
end

function tbAct:OnStartAct()
	local fnCall = function (pPlayer)
		pPlayer.CallClientScript("Kin.Snowman:ShowEffect")
	end
	Kin:TraverseKin(function (kinData)
		kinData:ResetSnowmanData()
		self:CreateNpc(kinData)
		if kinData:IsMapOpen() then
			Lib:CallBack({tbAct.TraverseInKinMap,tbAct,kinData,fnCall});
		end
	end);

	local nStartTime = self:GetOpenTimeInfo()
	local nNowTime = GetTime()
	local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        self:TryResetTimes(pPlayer,nNowTime,nStartTime)
    end
end

function tbAct:TryResetTimes(pPlayer,nNowTime,nStartTime)
	local nUpdateTime = pPlayer.GetUserValue(Snowman.SAVE_ONHOOK_GROUP, Snowman.Update_Time);
    if nUpdateTime < nStartTime then
    	pPlayer.SetUserValue(Snowman.SAVE_ONHOOK_GROUP,Snowman.Award_Count,0)
    	pPlayer.SetUserValue(Snowman.SAVE_ONHOOK_GROUP,Snowman.Update_Time,nNowTime)
    end
end

function tbAct:OnPlayerLogin()
	local nStartTime = self:GetOpenTimeInfo()
	local nNowTime = GetTime()
	self:TryResetTimes(me,nNowTime,nStartTime)
end

function tbAct:InitAct()
	Kin:TraverseKin(function (kinData)
		kinData:SetSnowflake(0)
		kinData:ResetMakingPlayer()
	end);
	Log("[SnowmanAct] InitAct ")
end

function tbAct:OnEndAct()
	Kin:TraverseKin(function (kinData)
		if kinData:IsMapOpen() then
			self:RemoveNpc(kinData)
		end
		kinData:ResetSnowmanData()
		kinData:SetSnowflake(0)
		kinData:ResetMakingPlayer()
	end);
end

function tbAct:OnKinGatherClose()
	Kin:TraverseKin(function (kinData)
			local tbSnowmanData = kinData:GetSnowmanData()
			if tbSnowmanData.nProcess and tbSnowmanData.nProcess == Snowman.Process_Type.MAKING then
				tbSnowmanData.nProcess = nil
			else
				Log("[SnowmanAct] OnKinGatherClose no match process",nKinId,tbSnowmanData.nProcess or 0)
			end
		end)
end

-- function tbAct:PlayEffect(kinData)
-- 	local tbSnowmanData = kinData:GetSnowmanData()
-- 	local tbSnowHeadNpc = tbSnowmanData.tbSnowHeadNpc or {}
-- 	for nNpcId,tbPos in pairs(tbSnowHeadNpc) do
-- 		local pNpc = KNpc.GetById(nNpcId);
-- 		if pNpc then
-- 			-- 放技能播特效
-- 			pNpc.CastSkill(Snowman.nFireWorksSkill, 1, tbPos[1], tbPos[2]);
-- 		end
-- 	end
-- end

function tbAct:OnKinGatherJoin(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanAct] OnKinGatherJoin no kinData",nKinId)
		return
	end
	local tbSnowmanData = kinData:GetSnowmanData()
	local nSnowflake = kinData.nSnowflake or 0
	local nNewSnowmanNpcLevel = Snowman:GetLevelBySnowflake(nSnowflake)
	tbSnowmanData.nSnowmanNpcLevel = nNewSnowmanNpcLevel
	tbSnowmanData.nProcess = Snowman.Process_Type.MAKING
	tbSnowmanData.tbPlayerCount = {}
end

function tbAct:OnUpdateSnowman(pPlayer)
	local nKinId = pPlayer.dwKinId or 0
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanAct] OnUpdateSnowman no kinData",pPlayer.dwID,pPlayer.szName,nKinId)
		return 
	end
	if not kinData:IsMapOpen() then
		Log("[SnowmanAct] OnUpdateSnowman no kin map",pPlayer.dwID,pPlayer.szName,nKinId)
		return 
	end
	local tbSnowmanData = kinData:GetSnowmanData()
	local nSnowflake = kinData.nSnowflake or 0
	local nNewSnowmanNpcLevel,nSnowmanNpcTId = Snowman:GetLevelBySnowflake(nSnowflake)
	local nOldSnowmanNpcLevel = tbSnowmanData.nSnowmanNpcLevel
	-- 记录堆雪人玩家
	kinData:SetMakingPlayer(nOldSnowmanNpcLevel + 1,pPlayer.dwID)

	if nNewSnowmanNpcLevel ~= nOldSnowmanNpcLevel then
		local nOldLevelSnowflake = Snowman.tbSnowmanLevel[nOldSnowmanNpcLevel]
		local nOldNpcId = tbSnowmanData.nSnowmanNpcId
		local pSnowmanNpc = KNpc.Add(nSnowmanNpcTId, 1, 0, kinData:GetMapId(), Snowman.tbSnowmanNpcPos[1], Snowman.tbSnowmanNpcPos[2],0,Snowman.nSnowmanDir);
		if pSnowmanNpc then
			tbSnowmanData.nSnowmanNpcId = pSnowmanNpc.nId
			tbSnowmanData.nSnowmanNpcLevel = nNewSnowmanNpcLevel
			pSnowmanNpc.tbTmp = {nKey = nKinId}
			local pNpc = KNpc.GetById(nOldNpcId)
			if pNpc then
				pNpc.Delete()
			end

			local nCrossLevel = nNewSnowmanNpcLevel - nOldSnowmanNpcLevel

			for nLevel = 1,nCrossLevel do
				local nContribLevel = nOldSnowmanNpcLevel + nLevel
				local nUpLevelSnowflake = Snowman.tbSnowmanLevel[nContribLevel - 1]
				-- 如果玩家堆的雪花使雪人跨等级，两级都有玩家的贡献
				if nSnowflake > nUpLevelSnowflake then
					kinData:SetMakingPlayer(nContribLevel + 1,pPlayer.dwID)
					Log("[SnowmanAct] OnUpdateSnowman CrossLevel",pPlayer.dwID,pPlayer.szName,nContribLevel,nUpLevelSnowflake)
				end
			end

			for nLevel = 1,nCrossLevel do
				local nUpLevel = nOldSnowmanNpcLevel + nLevel
				self:SnownmanUpdateAward(kinData,nUpLevel)
				local szColor = Snowman.tbColor[nUpLevel] or "-"
				local szTip = string.format("本帮派的帮派许愿树长大了，品质提升为%s色！本次许愿树长大过程中，进行了养护的帮派成员均将获得奖励，请注意查收邮件！",szColor)
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szTip, nKinId);
			end
			--Lib:CallBack({tbAct.PlayEffect,tbAct,kinData});
			Log("[SnowmanAct] OnUpdateSnowman pSnowmanNpc ok",nMapId,nSnowmanNpcTId,nKinId,nNewSnowmanNpcLevel,nOldSnowmanNpcLevel,nSnowflake,nCrossLevel)
		else
			Log("[SnowmanAct] OnUpdateSnowman no pSnowmanNpc",nMapId,nSnowmanNpcTId,nKinId,nNewSnowmanNpcLevel,nOldSnowmanNpcLevel,nSnowflake)
		end
	end
end

function tbAct:SnownmanUpdateAward(kinData,nLevel)
	local tbAward = Snowman.tbMakinkAward[nLevel]
	if tbAward then
		local tbMakingPlayer = kinData.tbMakingPlayer or {}
		local tbPlayer = tbMakingPlayer[nLevel] or {}
		if not next(tbPlayer) then
			Log("[SnowmanAct] SnownmanUpdateAward no tbPlayer",nLevel,kinData.nKinId,kinData.nSnowflake or 0)
			return
		end
		for nPlayerId,_ in pairs(tbPlayer) do
			local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerId) or {};
  			local nKinId = pPlayerStay.dwKinId or -1
  			-- 防止退出家族
  			if nKinId == kinData.nKinId then
				local tbMail = {
					To = nPlayerId;
					Title = "养护礼盒";
					From = "帮派管理员";
					Text = "侠士，由於您和帮派成员的不懈努力，帮派的许愿树快速成长！诸位辛苦了，武林为了多谢诸位作出的贡献，特备上薄礼让我送给大家，请查收！";
					tbAttach = tbAward;
					nLogReazon = Env.LogWay_SnowmanAct;
					};
				Mail:SendSystemMail(tbMail);
			else
				Log("[SnowmanAct] SnownmanUpdateAward out kin",nLevel,kinData.nKinId,nKinId,kinData.nSnowflake or 0)
			end
		end
	end
	Log("[SnowmanAct] SnownmanUpdateAward ",nLevel,kinData.nKinId,kinData.nSnowflake or 0,tbAward and "ok" or "NoAward")
end

function tbAct:CreateNpc(kinData)
	if not kinData:IsMapOpen() then
		return
	end
	self:RemoveNpc(kinData)
	local nMapId = kinData:GetMapId()
	local tbSnowmanData = kinData:GetSnowmanData()
	local nSnowflake = kinData.nSnowflake or 0
	local nSnowmanNpcLevel,nSnowmanNpcTId = Snowman:GetLevelBySnowflake(nSnowflake)
	local pSnowmanNpc = KNpc.Add(nSnowmanNpcTId, 1, 0,nMapId,Snowman.tbSnowmanNpcPos[1], Snowman.tbSnowmanNpcPos[2],0,Snowman.nSnowmanDir);
	if pSnowmanNpc then
		tbSnowmanData.nSnowmanNpcId = pSnowmanNpc.nId
		tbSnowmanData.nSnowmanNpcLevel = nSnowmanNpcLevel
		pSnowmanNpc.tbTmp = {nKey = kinData.nKinId}
		Log("[SnowmanAct] CreateNpc pSnowmanNpc ok",kinData.nKinId,nSnowmanNpcLevel,nSnowflake,nSnowmanNpcTId)
	else
		Log("[SnowmanAct] CreateNpc no pSnowmanNpc",kinData.nKinId,nSnowmanNpcLevel,nSnowflake,nSnowmanNpcTId)
	end
	-- tbSnowmanData.tbSnowHeadNpc = tbSnowmanData.tbSnowHeadNpc or {}
	-- for nIndex,tbPos in ipairs(Snowman.tbSnowHead) do
	-- 	local pHeadNpc = KNpc.Add(Snowman.nSnowHeadNpcId, 1, 0, nMapId,tbPos[1], tbPos[2]);
	-- 	if pHeadNpc then
	-- 		tbSnowmanData.tbSnowHeadNpc[pHeadNpc.nId] = tbPos
	-- 	else
	-- 		Log("[SnowmanAct] CreateNpc pHeadNpc fail",kinData.nKinId)
	-- 	end
	-- end
	Log("[SnowmanAct] CreateNpc >>> ",kinData.nKinId)
end

function tbAct:RemoveNpc(kinData)
	local tbSnowmanData = kinData:GetSnowmanData()
	if tbSnowmanData.nSnowmanNpcId then
		local pNpc =  KNpc.GetById(tbSnowmanData.nSnowmanNpcId)
		if pNpc then
			pNpc.Delete()
		end
		tbSnowmanData.nSnowmanNpcId = nil
	end
	-- tbSnowmanData.tbSnowHeadNpc = tbSnowmanData.tbSnowHeadNpc or {}
	-- if next(tbSnowmanData.tbSnowHeadNpc) then
	-- 	for nNpcId,_ in pairs(tbSnowmanData.tbSnowHeadNpc) do
	-- 		local pHeadNpc = KNpc.GetById(nNpcId);
	-- 		if pHeadNpc then
	-- 			pHeadNpc.Delete()
	-- 		end
	-- 		tbSnowmanData.tbSnowHeadNpc[nNpcId] = nil
	-- 	end
	-- end
end

function tbAct:OnKinMapCreate(nMapId)
	local nKinId = Kin:GetKinIdByMapId(nMapId) or 0
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanAct] OnKinMapCreate no kinData",nMapId,nKinId)
		return 
	end
	self:CreateNpc(kinData)
end

function tbAct:OnKinMapDestroy(nMapId)
	local nKinId = Kin:GetKinIdByMapId(nMapId) or 0
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanAct] OnKinMapDestroy no kinData",nMapId,nKinId)
		return 
	end
    self:RemoveNpc(kinData)
end
