local tbAct = Activity:GetClass("NYSnowmanAct")

tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

local NYSnowman = Kin.NYSnowman

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		self:InitAct()
	elseif szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerWrong", "OnGatherAnswerWrong")
		Activity:RegisterPlayerEvent(self, "Act_GatherAnswerRight", "OnGatherAnswerRight")
		Activity:RegisterPlayerEvent(self, "Act_DialogNYSnowman", "OnDialogSnowman")
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
	Log("NYSnowmanAct OnTrigger:", szTrigger)
end

function tbAct:OnKinGatherQuestion(nKinId,tbGatherData)
	local kinData = Kin:GetKinById(nKinId)
	if not kinData or not kinData:IsMapOpen() then
		return 
	end

	if tbGatherData and tbGatherData.nCurQuestionIdx and tbGatherData.nCurQuestionIdx == 2 then
		local nPosX,nPosY = unpack(NYSnowman.tbSnowmanNpcPos)
		local szMsg = string.format("获得雪花後，去此处<%d,%d>堆积帮派的雪人吧！",nPosX* Map.nShowPosScale,nPosY* Map.nShowPosScale)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId, {nLinkType = ChatMgr.LinkType.Position, linkParam = {kinData:GetMapId(),nPosX,nPosY, Kin.Def.nKinMapTemplateId}});
	end
end

function tbAct:OnGatherAnswerWrong(pPlayer)
	if not NYSnowman:CheckLevel(pPlayer) then
		Log("[NYSnowmanAct] OnGatherAnswerWrong level limit",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
		return
	end

	local nCount = MathRandom(NYSnowman.tbAnswerWrongBegin,NYSnowman.tbAnswerWrongEnd)

	pPlayer.SendAward({{"item", NYSnowman.nSnowflakeItemId, nCount}}, nil, true, Env.LogWay_NYSnowmanActBox);
	Log("[NYSnowmanAct] OnGatherAnswerWrong ",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
end

function tbAct:OnGatherAnswerRight(pPlayer)
	if not NYSnowman:CheckLevel(pPlayer) then
		Log("[NYSnowmanAct] OnGatherAnswerRight level limit",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
		return
	end

	local nCount = MathRandom(NYSnowman.tbAnswerRightBegin,NYSnowman.tbAnswerRightEnd)

	pPlayer.SendAward({{"item", NYSnowman.nSnowflakeItemId, nCount}}, nil, true, Env.LogWay_NYSnowmanActBox);

	Log("[NYSnowmanAct] OnGatherAnswerRight ",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,pPlayer.nLevel)
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
			pPlayer.CallClientScript("Ui:OpenWindow", "NewInformationPanel", "ShuangJieTongQing")
		end
	end

	local tbSnowmanData = kinData:GetSnowmanData()
	local tbOptList = {
		{Text = "堆雪人", Callback = self.MakingSnowman, Param = {self, pNpc.nId,pPlayer.dwID}},
		{Text = "领取雪人礼盒", Callback = self.GetGiftBox, Param = {self, pPlayer.dwID}},
		{Text = "了解详情", Callback = fnDetail, Param = {pPlayer.dwID}}
	}

    Dialog:Show(
    {
        Text    = "新的一年要来了，值此元旦佳节，一起开开心心堆雪人吧！",
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
	if not tbSnowmanData.nProcess or tbSnowmanData.nProcess ~= NYSnowman.Process_Type.MAKING then
		pPlayer.CenterMsg("帮派聚集烤火时才能领取宝箱！")
		return
	end

	-- 因为对话框所以检查
	if not NYSnowman:IsRunning() then
		pPlayer.CenterMsg("活动已经结束")
		return 
	end

	local nAward = DegreeCtrl:GetDegree(pPlayer, "NYSnowmanActAward")
	if nAward < 1 then
		pPlayer.CenterMsg("今日你已领取过奖励了！")
		return
	end

	if not NYSnowman:CheckLevel(pPlayer) then
		pPlayer.CenterMsg(string.format("请先将等级提升到%d级！",NYSnowman.JOIN_LEVEL))
		return
	end

	if not DegreeCtrl:ReduceDegree(pPlayer, "NYSnowmanActAward", 1) then
		pPlayer.CenterMsg("领取礼盒次数扣除失败", true)
		return 
	end

	local nStartTime = self:GetOpenTimeInfo()
	self:TryResetTimes(pPlayer, GetTime(), nStartTime)

	pPlayer.SendAward(NYSnowman.tbDayAward, nil, true, Env.LogWay_NYSnowmanActBox);

	Activity:OnPlayerEvent(pPlayer, "Act_NYSnowmanGetGiftBox", tbSnowmanData.nSnowmanNpcLevel)
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
		local nConsume = pMaker.ConsumeItemInAllPos(NYSnowman.nSnowflakeItemId,nHave, Env.LogWay_NYSnowmanActBox);
	    if nConsume < nHave then
	    	pMaker.CenterMsg("扣除雪花失败！",true);
	    	Log("[SnowmanNpc] MakingSnowman no kinData",pMaker.dwID,pMaker.szName,nKinId,nConsume,nHave)
	    	return
	    end
	    local nNpcLevel = NYSnowman:GetLevelBySnowflake(kinData.nSnowflake)
	    local nSnowflake = (kinData.nSnowflake or 0) + nHave
	    kinData:SetSnowflake(nSnowflake)
	    pPlayer.AddExperience(nConsume * NYSnowman.nSnowFlakeExp,Env.LogWay_NYSnowmanActBox)
	    tbAct:OnUpdateSnowman(pMaker)
	    Dialog:SendBlackBoardMsg(pMaker, string.format("成功进行了%d次堆雪人，雪人似乎变大了些！",nConsume));
	    Log("[SnowmanNpc] MakingSnowman ok ",pMaker.dwID,pMaker.szName,nKinId,kinData.szName,nSnowflake,nNpcLevel,nConsume,nHave)
	end

	local nHave = unpack(szMsg)
	pPlayer.MsgBox(string.format("您当前拥有「雪花」%d个，将全部用来堆雪人？",nHave),
		{
			{"确定", fnMaking, pPlayer.dwID,nNpcId},
			{"取消"},
		})
end

function tbAct:CheckMaking(pPlayer,nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[SnowmanNpc] MakingSnowman no pNpc",nNpcId,dwID)
		return false,"雪人不见了?"
	end

	local nKinId = pNpc.tbTmp and pNpc.tbTmp.nKey
	if not nKinId or pPlayer.dwKinId ~= nKinId then
		Log("[SnowmanNpc] MakingSnowman no match kin id ",nNpcId,dwID,pPlayer.szName,pPlayer.dwKinId,nKinId or 0)
		return false,"哪个帮派的雪人?"
	end

	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[SnowmanNpc] MakingSnowman no kinData",pPlayer.dwID,pPlayer.szName,pPlayer.dwKinId,nKinId)
		return false,"你是哪个帮派的?"
	end

	if not NYSnowman:CheckLevel(pPlayer) then
		return false,string.format("请先将等级提升到%d级",NYSnowman.JOIN_LEVEL)
	end

    local nHave = pPlayer.GetItemCountInAllPos(NYSnowman.nSnowflakeItemId)
    if nHave <= 0 then
    	return false,"请收集一些「雪花」再来堆雪人"
    end

	-- 因为对话框所以检查
	if not NYSnowman:IsRunning() then
		return false,"活动已经结束"
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
		pPlayer.CallClientScript("Kin.NYSnowman:ShowEffect")
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
	local nUpdateTime = pPlayer.GetUserValue(NYSnowman.SAVE_ONHOOK_GROUP, NYSnowman.Update_Time);
    if nUpdateTime < nStartTime then
    	pPlayer.SetUserValue(NYSnowman.SAVE_ONHOOK_GROUP,NYSnowman.Award_Count,0)
    	pPlayer.SetUserValue(NYSnowman.SAVE_ONHOOK_GROUP,NYSnowman.Update_Time,nNowTime)
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
	Log("[NYSnowmanAct] InitAct ")
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
			if tbSnowmanData.nProcess and tbSnowmanData.nProcess == NYSnowman.Process_Type.MAKING then
				tbSnowmanData.nProcess = nil
			else
				Log("[NYSnowmanAct] OnKinGatherClose no match process",nKinId,tbSnowmanData.nProcess or 0)
			end
		end)
end

function tbAct:PlayEffect(kinData)
	local tbSnowmanData = kinData:GetSnowmanData()
	local tbSnowHeadNpc = tbSnowmanData.tbSnowHeadNpc or {}
	for nNpcId,tbPos in pairs(tbSnowHeadNpc) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			-- 放技能播特效
			pNpc.CastSkill(NYSnowman.nFireWorksSkill, 1, tbPos[1], tbPos[2]);
		end
	end
end

function tbAct:OnKinGatherJoin(nKinId)
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[NYSnowmanAct] OnKinGatherJoin no kinData",nKinId)
		return
	end
	local tbSnowmanData = kinData:GetSnowmanData()
	local nSnowflake = kinData.nSnowflake or 0
	local nNewSnowmanNpcLevel = NYSnowman:GetLevelBySnowflake(nSnowflake)
	tbSnowmanData.nSnowmanNpcLevel = nNewSnowmanNpcLevel
	tbSnowmanData.nProcess = NYSnowman.Process_Type.MAKING
	tbSnowmanData.tbPlayerCount = {}
end

function tbAct:OnUpdateSnowman(pPlayer)
	local nKinId = pPlayer.dwKinId or 0
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[NYSnowmanAct] OnUpdateSnowman no kinData",pPlayer.dwID,pPlayer.szName,nKinId)
		return 
	end
	if not kinData:IsMapOpen() then
		Log("[NYSnowmanAct] OnUpdateSnowman no kin map",pPlayer.dwID,pPlayer.szName,nKinId)
		return 
	end
	local tbSnowmanData = kinData:GetSnowmanData()
	local nSnowflake = kinData.nSnowflake or 0
	local nNewSnowmanNpcLevel,nSnowmanNpcTId = NYSnowman:GetLevelBySnowflake(nSnowflake)
	local nOldSnowmanNpcLevel = tbSnowmanData.nSnowmanNpcLevel
	-- 记录堆雪人玩家
	kinData:SetMakingPlayer(nOldSnowmanNpcLevel + 1,pPlayer.dwID)

	if nNewSnowmanNpcLevel ~= nOldSnowmanNpcLevel then
		local nOldLevelSnowflake = NYSnowman.tbSnowmanLevel[nOldSnowmanNpcLevel]
		local nOldNpcId = tbSnowmanData.nSnowmanNpcId
		local pSnowmanNpc = KNpc.Add(nSnowmanNpcTId, 1, 0, kinData:GetMapId(), NYSnowman.tbSnowmanNpcPos[1], NYSnowman.tbSnowmanNpcPos[2],0,NYSnowman.nSnowmanDir);
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
				local nUpLevelSnowflake = NYSnowman.tbSnowmanLevel[nContribLevel - 1]
				-- 如果玩家堆的雪花使雪人跨等级，两级都有玩家的贡献
				if nSnowflake > nUpLevelSnowflake then
					kinData:SetMakingPlayer(nContribLevel + 1,pPlayer.dwID)
					Log("[NYSnowmanAct] OnUpdateSnowman CrossLevel",pPlayer.dwID,pPlayer.szName,nContribLevel,nUpLevelSnowflake)
				end
			end

			for nLevel = 1,nCrossLevel do
				local nUpLevel = nOldSnowmanNpcLevel + nLevel
				self:SnownmanUpdateAward(kinData,nUpLevel)
				local szColor = NYSnowman.tbColor[nUpLevel] or "-"
				local szTip = string.format("本帮派的元旦雪人升级了，品质提升为%s色！为本次升级进行「堆雪人」的帮派成员获得了奖励，请查收邮件！",szColor)
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szTip, nKinId);
			end
			Lib:CallBack({tbAct.PlayEffect,tbAct,kinData});
			Log("[NYSnowmanAct] OnUpdateSnowman pSnowmanNpc ok",nMapId,nSnowmanNpcTId,nKinId,nNewSnowmanNpcLevel,nOldSnowmanNpcLevel,nSnowflake,nCrossLevel)
		else
			Log("[NYSnowmanAct] OnUpdateSnowman no pSnowmanNpc",nMapId,nSnowmanNpcTId,nKinId,nNewSnowmanNpcLevel,nOldSnowmanNpcLevel,nSnowflake)
		end
	end
end

function tbAct:SnownmanUpdateAward(kinData,nLevel)
	local tbAward = NYSnowman.tbMakinkAward[nLevel]
	if tbAward then
		local tbMakingPlayer = kinData.tbMakingPlayer or {}
		local tbPlayer = tbMakingPlayer[nLevel] or {}
		if not next(tbPlayer) then
			Log("[NYSnowmanAct] SnownmanUpdateAward no tbPlayer",nLevel,kinData.nKinId,kinData.nSnowflake or 0)
			return
		end
		for nPlayerId,_ in pairs(tbPlayer) do
			local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerId) or {};
  			local nKinId = pPlayerStay.dwKinId or -1
  			-- 防止退出家族
  			if nKinId == kinData.nKinId then
				local tbMail = {
					To = nPlayerId;
					Title = "雪人宝箱";
					From = "系统";
					Text = "大侠，由於您和帮派成员的不懈努力，帮派的元旦雪人变得更大更好了!为了感谢大家，帮派管理员送给大家一份神秘的礼物，请查收！";
					tbAttach = tbAward;
					nLogReazon = Env.LogWay_NYSnowmanActBox;
					};
				Mail:SendSystemMail(tbMail);
			else
				Log("[NYSnowmanAct] SnownmanUpdateAward out kin",nLevel,kinData.nKinId,nKinId,kinData.nSnowflake or 0)
			end
		end
	end
	Log("[NYSnowmanAct] SnownmanUpdateAward ",nLevel,kinData.nKinId,kinData.nSnowflake or 0,tbAward and "ok" or "NoAward")
end

function tbAct:CreateNpc(kinData)
	if not kinData:IsMapOpen() then
		return
	end
	self:RemoveNpc(kinData)
	local nMapId = kinData:GetMapId()
	local tbSnowmanData = kinData:GetSnowmanData()
	local nSnowflake = kinData.nSnowflake or 0
	local nSnowmanNpcLevel,nSnowmanNpcTId = NYSnowman:GetLevelBySnowflake(nSnowflake)
	local pSnowmanNpc = KNpc.Add(nSnowmanNpcTId, 1, 0,nMapId,NYSnowman.tbSnowmanNpcPos[1], NYSnowman.tbSnowmanNpcPos[2],0,NYSnowman.nSnowmanDir);
	if pSnowmanNpc then
		tbSnowmanData.nSnowmanNpcId = pSnowmanNpc.nId
		tbSnowmanData.nSnowmanNpcLevel = nSnowmanNpcLevel
		pSnowmanNpc.tbTmp = {nKey = kinData.nKinId}
		Log("[NYSnowmanAct] CreateNpc pSnowmanNpc ok",kinData.nKinId,nSnowmanNpcLevel,nSnowflake,nSnowmanNpcTId)
	else
		Log("[NYSnowmanAct] CreateNpc no pSnowmanNpc",kinData.nKinId,nSnowmanNpcLevel,nSnowflake,nSnowmanNpcTId)
	end
	tbSnowmanData.tbSnowHeadNpc = tbSnowmanData.tbSnowHeadNpc or {}
	for nIndex,tbPos in ipairs(NYSnowman.tbSnowHead) do
		local pHeadNpc = KNpc.Add(NYSnowman.nSnowHeadNpcId, 1, 0, nMapId,tbPos[1], tbPos[2]);
		if pHeadNpc then
			tbSnowmanData.tbSnowHeadNpc[pHeadNpc.nId] = tbPos
		else
			Log("[NYSnowmanAct] CreateNpc pHeadNpc fail",kinData.nKinId)
		end
	end
	Log("[NYSnowmanAct] CreateNpc >>> ",kinData.nKinId)
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
	tbSnowmanData.tbSnowHeadNpc = tbSnowmanData.tbSnowHeadNpc or {}
	if next(tbSnowmanData.tbSnowHeadNpc) then
		for nNpcId,_ in pairs(tbSnowmanData.tbSnowHeadNpc) do
			local pHeadNpc = KNpc.GetById(nNpcId);
			if pHeadNpc then
				pHeadNpc.Delete()
			end
			tbSnowmanData.tbSnowHeadNpc[nNpcId] = nil
		end
	end
end

function tbAct:OnKinMapCreate(nMapId)
	local nKinId = Kin:GetKinIdByMapId(nMapId) or 0
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[NYSnowmanAct] OnKinMapCreate no kinData",nMapId,nKinId)
		return 
	end
	self:CreateNpc(kinData)
end

function tbAct:OnKinMapDestroy(nMapId)
	local nKinId = Kin:GetKinIdByMapId(nMapId) or 0
	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("[NYSnowmanAct] OnKinMapDestroy no kinData",nMapId,nKinId)
		return 
	end
    self:RemoveNpc(kinData)
end
