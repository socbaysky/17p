TeamMgr.QuickTeamUp = TeamMgr.QuickTeamUp or {};
local TeamUp = TeamMgr.QuickTeamUp;
local CTeamMgr = GetCTeamMgr();

function TeamMgr:GetMembers(nTeamId)
	return CTeamMgr.TeamGetMember(nTeamId) or {};
end

function TeamMgr:Invite(nTargetPlayerID)
	local target = KPlayer.GetPlayerObjById(nTargetPlayerID);
	if not target then
		return false, "对方已离线";
	end

	if me.nLevel < TeamMgr.OPEN_LEVEL then
		return false, "4级以上才允许组队";
	end

	if target.nLevel < TeamMgr.OPEN_LEVEL then
		return false, "对方未达到组队等级";
	end

	if target.dwTeamID ~= 0 then
		return false, target.dwTeamID == me.dwTeamID and string.format("「%s」已在队伍中", target.szName) or "对方已有队伍";
	end

	if me.dwID == nTargetPlayerID then
		return false, "不可邀请自己";
	end

	if not TeamMgr:CanTeam(target.nMapTemplateId) then
		return false, "对方所在地图不可组队";
	end

	if target.nState == Player.emPLAYER_STATE_ZONE then
		return false ,"对方当前状态不可组队"
	end

	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if teamData and teamData:TeamFull() then
		return false, "队伍已满";
	end

	local nTargetActivityId = teamData and teamData:GetTargetActivityId();
	local szTargetName = TeamUp:GetActivityName(nTargetActivityId)
	target.CallClientScript("TeamMgr:OnInvited", me.dwTeamID, me.dwID, me.szName,
				 me.nLevel,me.nFaction, me.nPortrait,me.nHonorLevel,szTargetName);
	me.CenterMsg(string.format("已成功邀请「%s」加入队伍", target.szName));
	return true;
end

function TeamMgr:Apply(nTargetPlayerID, bNoFeedback)
	local targetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerID);
	if not targetPlayer or me.dwID == nTargetPlayerID then
		return false, "对方已离线";
	end

	if not targetPlayer.CanTeamOpt() then
		return false, "目标队伍在活动地图，暂时无法加入";
	end

	local teamData = TeamMgr:GetTeamById(targetPlayer.dwTeamID);
	if not teamData then
		return false, "对方没有队伍哦";
	end

	local bRet, szInfo = teamData:Available2Join(me);
	if not bRet then
		return false, szInfo;
	end

	local nTargetActivityId = teamData:GetTargetActivityId();
	local bCanJoin = TeamUp:Check(me, nTargetActivityId);
	local bCanHelp = TeamUp:CheckHelp(me, nTargetActivityId);
	if not bNoFeedback and nTargetActivityId and not bCanJoin then
		if bCanHelp and not TeamMgr:CanQuickTeamHelp(me) then
			me.MsgBox("是否以协助状态申请加入队伍？",
				{
					{"确认申请", function (nTargetPlayerID)
						TeamMgr:SetQuickTeamHelpState(true);
						TeamMgr:Apply(nTargetPlayerID);
					end, nTargetPlayerID},
					{"取消"},
				}
				);
			return;
		end
	end

	if teamData:IsAutoAgree() then
		if nTargetActivityId and (not bCanJoin and not bCanHelp) then
			return false, "你不符合参加目标活动的要求";
		end

		return teamData:AddMember(me.dwID);
	end

	teamData:Add2ApplyerList(me);
	if not bNoFeedback then
		local nCaptainId = teamData:GetCaptainId();
		if nTargetPlayerID == nCaptainId then
			me.CenterMsg(string.format("已申请加入[FFFE0D]%s[-]的队伍", targetPlayer.szName));
		else
			local pCaptain = KPlayer.GetPlayerObjById(nCaptainId);
			if pCaptain then
				me.CenterMsg(string.format("已申请加入[FFFE0D]%s[-]所在的[FFFE0D]%s[-]的队伍", targetPlayer.szName, pCaptain.szName));
			end
		end
	end
	return true;
end

--直接把pMember 加入队长的队伍中，没队直接创，pMember 有队则直接退
function TeamMgr:DirectAddMember(dwLeaderId, pMember)
	local targetPlayer = KPlayer.GetPlayerObjById(dwLeaderId);
	if not targetPlayer or pMember.dwID == dwLeaderId then
		return false, "对方已离线";
	end

	if pMember.dwTeamID ~= 0 then
		TeamMgr:QuiteTeam(pMember.dwTeamID, pMember.dwID);
	end

	if pMember.nLevel < TeamMgr.OPEN_LEVEL or targetPlayer.nLevel < TeamMgr.OPEN_LEVEL then
		return false, "4级以上才允许组队";
	end

	if not TeamMgr:CanTeam(targetPlayer.nMapTemplateId)
		or not TeamMgr:CanTeam(pMember.nMapTemplateId) then
		return false, "所在地图不可组队";
	end

	local teamData = TeamMgr:GetTeamById(targetPlayer.dwTeamID);
	if not teamData then
		return TeamMgr:Create(dwLeaderId, pMember.dwID, true)
	end

	if teamData:TeamFull() then
		return false, "队伍已满";
	end

	return teamData:AddMember(pMember.dwID, true);
end

-- 队长同意/拒绝 入队申请
function TeamMgr:Agree(nApplyerID, bAgree)
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData then
		return false, "没有队伍";
	end

	if teamData:GetCaptainId() ~= me.dwID then
		return false, "没有许可权";
	end

	local tbApplyData = teamData:RemoveFromApplyerList(nApplyerID);
	if not tbApplyData then
		return false, "该请求已过期";
	end

	if bAgree then
		local applyer = KPlayer.GetPlayerObjById(nApplyerID);
		if not applyer then
			return false, "玩家已下线";
		end

		local bRet, szMsg = teamData:Available2Join(applyer);
		if not bRet then
			return false, szMsg;
		end

		local bRet, szMsg = teamData:AddMember(nApplyerID);
		if bRet then
			applyer.nTargetTeamActivityId = tbApplyData.nActivityId;
		end
		return bRet, szMsg;
	end

	return true;
end

function TeamMgr:ClearApplyerList()
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData then
		return false, "没有队伍";
	end

	if teamData:GetCaptainId() ~= me.dwID then
		return false, "没有许可权";
	end

	teamData:ClearApplyerList();
	me.CenterMsg("清除申请列表成功");
	return true;
end

function TeamMgr:AcceptInvitation(nTeamID, nInviterID)
	local inviter = KPlayer.GetPlayerObjById(nInviterID);

	-- 邀请者改变队伍, 则邀请失效
	if not inviter or (inviter.dwTeamID ~= nTeamID and nTeamID ~= 0) then
		return false, "该申请已过期";
	end

	local teamData = TeamMgr:GetTeamById(inviter.dwTeamID);
	if not teamData then
		return false, "队伍不存在了";
	end

	local bRet, szMsg = teamData:Available2Join(me);
	if not bRet then
		return false, szMsg;
	end

	-- 邀请者是队长, 或 队伍设置为自动入队, 则直接加入队伍
	if inviter.dwID == teamData:GetCaptainId() or teamData:IsAutoAgree() then
		return teamData:AddMember(me.dwID);
	end

	teamData:Add2ApplyerList(me);
	return true;
end

function TeamMgr:Quite()
	return TeamMgr:QuiteTeam(me.dwTeamID, me.dwID);
end

function TeamMgr:OnLogout(player)
	TeamMgr:QuiteTeam(player.dwTeamID, player.dwID);
	TeamUp:RemoveFromWaitingList(player);
end

function TeamMgr:QuiteTeam(nTeamId, nMemberId)
	local teamData = TeamMgr:GetTeamById(nTeamId);
	if not teamData then
		return false, "队伍不存在";
	end

	local nTargetActivityId = teamData:GetTargetActivityId();
	if teamData.nEnterActivityTimer and nTargetActivityId then
		TeamMgr:AgreeEnterActivity(nTargetActivityId, false);
	end

	teamData:Quite(nMemberId);
	return true;
end

function TeamMgr:KickOutMember(nTargetPlayerID)
	local targetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerID);
	if not targetPlayer then
		return false, "未找到目标";
	end

	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData or teamData:GetCaptainId() ~= me.dwID then
		return false, "没有许可权";
	end

	if me.dwTeamID ~= targetPlayer.dwTeamID then
		return false, "不在同一队伍";
	end

	if teamData:GetMemberCount() == 1 then
		TeamMgr:DeleteTeam(me.dwTeamID);
		return true;
	end

	teamData:RemoveMember(nTargetPlayerID);
	return true;
end

function TeamMgr:SetAutoAgree(bAutoAgree)
	local nTeamID = me.dwTeamID;
	if nTeamID == 0 then
		return false, "队伍已满";
	end

	local tbTeamData = TeamMgr:GetTeamById(nTeamID);
	if tbTeamData:GetCaptainId() ~= me.dwID then
		return false, "没有许可权";
	end

	tbTeamData:SetAutoAgree(bAutoAgree);
	return true;
end

function TeamMgr:ChangeCaptain(nTargetPlayerId)
	if me.dwTeamID == 0 then
		return false, "没有队伍";
	end

	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if teamData:GetCaptainId() ~= me.dwID then
		return false, "没有许可权";
	end

	return teamData:ChangeCaptain(nTargetPlayerId);
end

function TeamMgr:AskTeammate2Follow()
	if me.dwTeamID == 0 then
		return false, "没有队伍";
	end
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if teamData:GetCaptainId() ~= me.dwID then
		return false, "只有队长可以进行召回";
	end

	if MODULE_ZONESERVER then
		return false, "跨服无法进行此操作";
	end

	local pNpc = me.GetNpc()
	local nNpcId = pNpc.nId;
	local bHasInvited = false;
	teamData:TraversMembers(function (member)
		if member.dwID ~= me.dwID and FriendShip:IsFriend(me.dwID, member.dwID) then
			bHasInvited = true;
			member.CallClientScript("TeamMgr:OnFollowCaptainInvited", nNpcId, me.szName);
		end
	end);

	if bHasInvited then
		me.CenterMsg("已向好友关系的队员发起召回跟战", true);
	else
		me.CenterMsg("队伍中暂无好友，无法发起召回跟战");
	end
	return true;
end

function TeamMgr:AskTeammateNot2Follow()
	if me.dwTeamID == 0 then
		return false, "没有队伍";
	end
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if teamData:GetCaptainId() ~= me.dwID then
		return false, "只有队长可以进行取消召回";
	end

	local pNpc = me.GetNpc()
	local nNpcId = pNpc.nId;
	local bHasCanceled = false;
	teamData:TraversMembers(function (member)
		if member.dwID ~= me.dwID then
			member.CallClientScript("TeamMgr:OnCancelFollowAttack", nNpcId, me.szName);
			bHasCanceled = true;
		end
	end);

	if bHasCanceled then
		me.CenterMsg("已取消队员跟战你的状态");
	else
		me.CenterMsg("当前没有队员跟战你");
	end
	return true;
end

function TeamMgr:Apply2BeCaptain(nCaptainId)
	if me.dwTeamID == 0 then
		return false, "没有队伍";
	end
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData:IsCaptain(nCaptainId) then
		return false, "对方已经不是队长了";
	end

	if MODULE_ZONESERVER then
		return false, "跨服无法进行此操作";
	end

	if not FriendShip:IsFriend(me.dwID, nCaptainId) then
		return false, "你们不是好友，不可以申请成为队长";
	end

	local pCaptain = KPlayer.GetPlayerObjById(nCaptainId);
	if not pCaptain then
		return false, "队长不见啦~~~";
	end

	local nTeamId = me.dwTeamID;
	local nApplyerId = me.dwID;
	local function fnAgree()
		local pApplyer = KPlayer.GetPlayerObjById(nApplyerId);
		if not pApplyer then
			me.CenterMsg("对方已离线");
			return;
		end

		if me.dwTeamID ~= nTeamId then
			me.CenterMsg("你已经在不该队伍");
			return;
		end

		if pApplyer.dwTeamID ~= nTeamId then
			me.CenterMsg("对方已经离开队伍");
			return;
		end

		local teamData = TeamMgr:GetTeamById(nTeamId);
		if not teamData:IsCaptain(me.dwID) then
			me.CenterMsg("你已经不是队长了");
			return;
		end

		local bRet = TeamMgr:ChangeCaptain(nApplyerId);
		if bRet then
			pApplyer.CenterMsg("你已成为队长");
		end
	end

	local function fnDisagree()
		local pApplyer = KPlayer.GetPlayerObjById(nApplyerId);
		if pApplyer then
			pApplyer.CenterMsg(string.format("队长「%s」拒绝了你的请求", me.szName));
		end
	end

	local szMsg = string.format("队伍成员[FFFE0D]「%s」[-]申请成为本小队的队长，是否同意？（%%d秒後自动同意）", me.szName);
	pCaptain.MsgBox(szMsg, {{"同意", fnAgree}, {"拒绝", fnDisagree}}, nil, TeamMgr.Def.nApplyBeCaptainWaitingTime, fnAgree);

	me.CenterMsg("正在申请成为队长，请等待片刻");
	return true;
end

function TeamMgr:UpdateFollowState(nFollowPlayerId)
	if me.dwTeamID == 0 then
		return false, "没有队伍";
	end
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData then
		return false, "没有队伍";
	end

	local pFollower = KPlayer.GetPlayerObjById(nFollowPlayerId);
	if pFollower and pFollower.dwTeamID == me.dwTeamID then
		local nValidTime = GetTime() + TeamMgr.Def.nFollowFightStateLastingTime;
		
		-- print("TeamMgr:OnSynFollowState", me.dwID, nValidTime)
		pFollower.CallClientScript("TeamMgr:OnSynFollowState", me.dwID, nValidTime);
	end
	return true;
end

local tbTeamMgrCmd = {
	AcceptInvitation      = true;
	Invite                = true;
	Quite                 = true;
	Agree                 = true;
	Apply                 = true;
	SetAutoAgree          = true;
	KickOutMember         = true;
	ChangeCaptain         = true;
	ClearApplyerList      = true;
	AskTeammate2Follow    = true;
	AskTeammateNot2Follow = true;
	Apply2BeCaptain       = true;
	UpdateFollowState     = true;
}

function TeamMgr:ClientRequest(szRequestType, ... )
	if tbTeamMgrCmd[szRequestType] then
		local bSuccess, szInfo  = TeamMgr[szRequestType](TeamMgr, ...);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	else
		Log("ERROR: TeamMgr, Wrong cmd", szRequestType, ...);
	end
end

-----------------------------快速组队-----------------------------------------

local TeamActivityCountDownTime = 20;  --队员自动同意时间，单位：秒

function TeamMgr:EnterActivity(nActivityId)
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData then
		return false, "没有队伍";
	end

	if teamData:GetCaptainId() ~= me.dwID then
		return false, "你不是队长";
	end

	local tbActivity = TeamUp:GetActivity(nActivityId);
	if not tbActivity then
		return false, "活动不存在";
	end

	if teamData:GetMemberCount() < tbActivity.nMinOpenMember then
		return false, "队伍人数不满足进入条件";
	end

	local szActivityName = TeamUp:GetActivityName(nActivityId) or "";
	local bCanEnter, szInfo = TeamUp:CheckEnter(me.dwID, nActivityId);
	if not bCanEnter then
		teamData:SendTeamInfo(szInfo);
		return false;
	end

	me.nTargetTeamActivityId = nActivityId;

	local bAllTheGreen = true;
	local tbMembers = teamData:GetMembers();
	for _, nMemberID in pairs(tbMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberID);
		if not member then
			return false, "找不到成员";
		end

		if member.nTargetTeamActivityId ~= nActivityId then
			bAllTheGreen = false;
			member.CallClientScript("TeamMgr:NoticeEnterActivity", nActivityId, TeamActivityCountDownTime, szActivityName);
		end
	end

	if bAllTheGreen then
		TeamUp:Enter(me.dwID, nActivityId);
	else
		teamData.nEnterActivityTimer = Timer:Register(Env.GAME_FPS * TeamActivityCountDownTime, function (nPlayerId)
			if teamData.nEnterActivityTimer then
				TeamUp:Enter(nPlayerId, nActivityId);
				teamData.nEnterActivityTimer = nil;
			end
			return false;
		end, me.dwID);
		me.CallClientScript("TeamMgr:CaptainWaitingMsgBox", TeamActivityCountDownTime);
	end

	return true;
end

function TeamMgr:SetQuickTeamHelpState(bHelp, pPlayer)
	pPlayer = pPlayer or me;
	if (not pPlayer.bQuickTeamHelp) == (not bHelp) then
		return true;
	end

	pPlayer.bQuickTeamHelp = bHelp;
	pPlayer.CallClientScript("TeamMgr:OnSynTeamHelpState", bHelp);
	TeamMgr:PlayerInfoChange(pPlayer);
	return true;
end

function TeamMgr:CanQuickTeamHelp(pPlayer)
	return pPlayer.bQuickTeamHelp;
end

function TeamMgr:AgreeEnterActivity(nActivityId, bAgree)
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData then
		return false, "队伍已经不存在了";
	end

	if not teamData.nEnterActivityTimer then
		return false, "超时了";
	end

	local tbMembers = teamData:GetMembers();
	if bAgree then
		me.nTargetTeamActivityId = nActivityId;
		if TeamUp:CheckActivitySelect(tbMembers, nActivityId) then
			local master = KPlayer.GetPlayerObjById(teamData:GetCaptainId());
			if not master then
				return false, "队长跑路啦~"
			end
			TeamUp:Enter(master.dwID, nActivityId);
			Timer:Close(teamData.nEnterActivityTimer);
			teamData.nEnterActivityTimer = nil;

			for _, nMemberId in pairs(tbMembers) do
				local member = KPlayer.GetPlayerObjById(nMemberId);
				member.CallClientScript("TeamMgr:EnterActivityResult", true);
			end
		end
	else
		local tbActivity = TeamUp:GetActivity(nActivityId) or {};
		for _, nMemberId in pairs(tbMembers) do
			local member = KPlayer.GetPlayerObjById(nMemberId);
			if member then
				member.CallClientScript("TeamMgr:EnterActivityResult", false, me.szName, tbActivity.szName);
			end
		end

		local szTips = string.format("「%s」拒绝进入%s", me.szName, tbActivity.szName or "");
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTips, me.dwTeamID);
		Timer:Close(teamData.nEnterActivityTimer);
		teamData.nEnterActivityTimer = nil;
	end

	return true;
end

function TeamMgr:CreateOnePersonTeam(nActivityId)
	if me.dwTeamID ~= 0 then
		return false, "已有队伍";
	end

	if me.nLevel < TeamMgr.OPEN_LEVEL then
		me.CenterMsg("4级以上才允许组队");
		return;
	end

	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		return false, "所在地图不可组队";
	end

	local bRet, szInfo = TeamUp:Check(me, nActivityId);
	if nActivityId and not bRet then
		return false, szInfo or "你不符合参加该活动的要求";
	end

	local teamData = {
		nTeamID = TeamMgr.NextTeamID;
		nCaptainID = me.dwID;
		tbApplyerList = {};
	};

	setmetatable(teamData, {__index = self._TeamData});
	TeamMgr.tbAllTeamData[teamData.nTeamID] = teamData;
	CTeamMgr.CreateTeam(teamData.nTeamID, me.dwID);
	me.CallClientScript("TeamMgr:OnSynNewTeam", teamData.nTeamID, me.dwID, {});
	teamData:ChangeTargetActivity(nActivityId);
	TeamUp:RemoveFromWaitingList(me);

	TeamMgr.NextTeamID = TeamMgr.NextTeamID + 1;
	return true;
end

function TeamMgr:QuickTeamUpSetting(nActivityId)
	local teamData = TeamMgr:GetTeamById(me.dwTeamID);
	if not teamData then
		return false, "队伍已满";
	end

	if teamData:GetCaptainId() ~= me.dwID then
		return false, "你不是队长";
	end

	local tbActivity = TeamUp:GetActivity(nActivityId);
	if nActivityId and not tbActivity then
		return false, "活动不存在";
	end

	local bRet, szInfo = teamData:ChangeTargetActivity(nActivityId);
	if not bRet then
		return false, szInfo;
	end

	TeamMgr:Ask4ActivityTeams(nActivityId)
	return true;
end

function TeamMgr:Ask4Activitys(nVersion)
	local tbActivityList, nListVersion = TeamUp:GetActivitySyncList(nVersion);
	if tbActivityList then
		me.CallClientScript("TeamMgr:OnSynActivityList", tbActivityList, nListVersion);
	end
	return true;
end

function TeamMgr:Ask4ActivityTeams(nActivityId)
	if not nActivityId then
		return;
	end

	local teams = TeamUp:GetActivityTeams4Show(nActivityId, me);

	me.CallClientScript("TeamMgr:OnSynActivityTeams", nActivityId, teams);
	return true;
end

function TeamMgr:ApplyActivityTeam(nActivityId, nTeamId)
	local teamData = TeamMgr:GetTeamById(nTeamId);
	if not teamData then
		return false, "队伍不存在";
	end

	local bRet, szInfo = teamData:Available2Join(me);
	if not bRet then
		return false, szInfo;
	end

	if teamData:GetTargetActivityId() ~= nActivityId then
		return false, "队伍的活动目标已改变";
	end

	local nRet, szInfo = TeamUp:Check(me, nActivityId);
	if not nRet then
		local bCanHelp = TeamUp:CheckHelp(me, nActivityId);
		if bCanHelp then
			if not TeamMgr:CanQuickTeamHelp(me) then
				me.MsgBox("是否以协助状态申请加入队伍？",
					{
						{"确认申请", function (nActivityId, nTeamId)
							TeamMgr:SetQuickTeamHelpState(true);
							TeamMgr:ApplyActivityTeam(nActivityId, nTeamId);
						end, nActivityId, nTeamId},
						{"取消"},
					}
					);
				return true;
			end
		else
			return false, szInfo or "你没有达到进入该活动的要求";
		end
	end

	if teamData:IsAutoAgree() then
		local bRet, szInfo  = teamData:AddMember(me.dwID);
		if not bRet then
			return false, szInfo;
		end
		me.nTargetTeamActivityId = nActivityId;
		return true;
	end

	teamData:Add2ApplyerList(me);
	me.CenterMsg(string.format("已申请加入【%s】队伍", TeamUp:GetActivityName(nActivityId) or ""));
	return true;
end

-- 计算一个玩家与队伍的亲密度.., 用于队伍快速匹配
local nTeamScoreEnemy = -20;
local nTeamScoreSameFaction = -20;
local nTeamScoreSameKin = 10;
local tbTeamScoreFriendIntimacy = {10, 15, 20, 25, 30};

local function GetTeamScoreWithPlayer(player, nTeamId)
	local teamData = TeamMgr:GetTeamById(nTeamId);
	if teamData:TeamFull() then
		return false;
	end

	local nScore = 0;
	local bSameFaction = false;
	local tbTeamMembers = teamData:GetMembers();
	for _, nMemberId in pairs(tbTeamMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberId);
		if not member then
			break;
		end

		if not bSameFaction and member.nFaction == player.nFaction then
			bSameFaction = true;
			nScore = nScore + nTeamScoreSameFaction;
		end

		local nIntimacy = MODULE_GAMESERVER and FriendShip:GetImity(player.dwID, member.dwID) or 0;
		nScore = nScore + (tbTeamScoreFriendIntimacy[math.min(math.floor((nIntimacy + 4) / 5), #tbTeamScoreFriendIntimacy)] or 0);

		if player.dwKinId ~= 0 and player.dwKinId == member.dwKinId then
			nScore = nScore + nTeamScoreSameKin;
		elseif MODULE_GAMESERVER and FriendShip:IsHeIsMyEnemy(player.dwID, nMemberId) then
			nScore = nScore + nTeamScoreEnemy;
		end
	end

	return nScore;
end

function TeamMgr:ActivityQuickMatch(tbActivitys)
	if me.dwTeamID ~= 0 then
		return false, "已有队伍";
	end

	TeamUp:RemoveFromWaitingList(me);
	if not next(tbActivitys) then
		me.CallClientScript("TeamMgr:OnSynQuickMatch", {});
		return true;
	end

	local bCheckFail = false;
	for nActivityId, _ in pairs(tbActivitys) do
		local bRet, szInfo = TeamUp:Check(me, nActivityId);
		if not bRet then
			bCheckFail = true;
			tbActivitys[nActivityId] = nil;
		end
	end

	if not next(tbActivitys) then
		me.CallClientScript("TeamMgr:OnSynQuickMatch", {});
		return false, "请先回安全区";
	end

	if bCheckFail then
		me.CenterMsg("请先回安全区");
	end

	local tbTeamDatas = {};
	for nActivityId, _ in pairs(tbActivitys) do
		local tbTeamIds = TeamUp:GetActivityAllTeams(nActivityId) or {};
		for _, nTeamId in pairs(tbTeamIds) do
			local nScore = GetTeamScoreWithPlayer(me, nTeamId);
			if nScore then
				table.insert(tbTeamDatas, {nTeamId, nScore});
			end
		end
	end

	table.sort(tbTeamDatas, function (a, b)
		return a[2] > b[2];
	end);

	for _, tbTeamData in pairs(tbTeamDatas) do
		local teamData = TeamMgr:GetTeamById(tbTeamData[1]);
		if teamData and not teamData:TeamFull() then
			if teamData:IsAutoAgree() then
				if teamData:AddMember(me.dwID) then
					me.nTargetTeamActivityId = teamData:GetTargetActivityId();
					return true;
				end
			else
				teamData:Add2ApplyerList(me);
			end
		end
	end

	me.CallClientScript("TeamMgr:OnSynQuickMatch", tbActivitys);
	TeamUp:Add2WaitingJoinList(tbActivitys, me);
	return true;
end

function TeamMgr:RemoveFromQuickTeamWaitingList(pPlayer)
	TeamUp:RemoveFromWaitingList(pPlayer);
	pPlayer.CallClientScript("TeamMgr:OnSynQuickMatch", {});
end

-- -- test
-- function TeamMgr:True()
-- 	return true;
-- end

-- TeamMgr:RegisterActivity("test1", "subtype", "I am name", {"TeamMgr:True"}, {"TeamMgr:True"}, {"TeamMgr:True"});
-- TeamMgr:RegisterActivity("haha", "subtype", "test2", {"TeamMgr:True"}, {"TeamMgr:True"}, {"TeamMgr:True"});

function TeamMgr:RegisterActivity(szType, subtype, szName, tbCheckShow, tbCheckJoin, tbCheckEnter, tbEnter, nMinOpenMember, tbCheckHelpJoin)
	return TeamUp:RegisterActivity(szType, subtype, szName, tbCheckShow, tbCheckJoin, tbCheckEnter, tbEnter, nMinOpenMember, tbCheckHelpJoin);
end

function TeamMgr:UnregisterActivity(nActivityId)
	return TeamUp:UnregisterById(nActivityId);
end

function TeamMgr:UnregisterByType(szType, subtype)
	local nActivityId = TeamUp:GetActivityIdByType(szType, subtype);
	return TeamUp:UnregisterById(nActivityId);
end

function TeamMgr:GetActivityIdByType(szType, subtype)
    return TeamUp:GetActivityIdByType(szType, subtype);
end

local tbTeamUpCmd = {
	EnterActivity         = true;
	AgreeEnterActivity    = true;
	CreateOnePersonTeam   = true;
	QuickTeamUpSetting    = true;
	Ask4Activitys         = true;
	Ask4ActivityTeams     = true;
	ApplyActivityTeam     = true;
	ActivityQuickMatch    = true;
	SetQuickTeamHelpState = true;
}

function TeamMgr:QuickTeamUpRequest(szRequestType, ...)
	if tbTeamUpCmd[szRequestType] then
		local bSuccess, szInfo  = TeamMgr[szRequestType](TeamMgr, ...);
		if not bSuccess and szInfo then
			me.CenterMsg(szInfo);
		end
	else
		Log("ERROR: QuickTeamUp, Wrong cmd", szRequestType, ...);
	end
end

function TeamMgr:OnEnterMap(pPlayer, nMapTemplateId, nMapId)
	if not TeamMgr:CanTeam(nMapTemplateId) then
		TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
		TeamUp:RemoveFromWaitingList(pPlayer);
	end

	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if not teamData then
		return;
	end
	if pPlayer.dwID == teamData:GetCaptainId() and not pPlayer.CanTeamOpt() then
		teamData:ChangeTargetActivity(nil);
	end

	local nPlayerId = pPlayer.dwID;
	local _, nX, nY = pPlayer.GetWorldPos();
	teamData:TraversMembers(function (member)
		if member.dwID ~= nPlayerId then
			member.CallClientScript("TeamMgr:OnSynTeammateChangeMap", nPlayerId, nMapTemplateId, nMapId, nX, nY);
		end
	end);
end

function TeamMgr:OnSyncNearbyTeamsReq(tbTeamIds)
	local tbTeams = {}
	for nTeamID in pairs(tbTeamIds) do
		local tbTeamData = TeamMgr:GetTeamById(nTeamID)
		if tbTeamData then
			local nCaptainID = tbTeamData:GetCaptainId()
			local pCaptain = KPlayer.GetPlayerObjById(nCaptainID)
			if pCaptain then
				table.insert(tbTeams, {
					nTeamID = nTeamID,
					tbCaptainInfo = {
						nPlayerID = nCaptainID,
						szName = pCaptain.szName,
						nFaction = pCaptain.nFaction,
						nPortrait = pCaptain.nPortrait,
						nLevel = pCaptain.nLevel,
						nHonorLevel = pCaptain.nHonorLevel,
					},
					nMemberCount = tbTeamData:GetMemberCount(),
					nTargetActivityId = tbTeamData:GetTargetActivityId() or 0,
				})
			end
		end
	end
	if next(tbTeams) then
		table.sort(tbTeams, function(tbA, tbB)
			return tbA.nMemberCount<tbB.nMemberCount or (tbA.nMemberCount==tbB.nMemberCount and tbA.nTeamID<tbB.nTeamID)
		end)
		me.CallClientScript("TeamMgr:OnSyncNearbyTeams", tbTeams)
	end
end

function TeamMgr:PlayerInfoChange(pPlayer)
	local nTeamId = pPlayer.dwTeamID
	if not nTeamId or nTeamId<=0 then
		return
	end

	local tbTeamData = TeamMgr:GetTeamById(nTeamId)
	if not tbTeamData then
		return
	end

	local tbMemberData = tbTeamData:GetMemberData(pPlayer.dwID)
	if not tbMemberData then
		return
	end

	local tbMembers = TeamMgr:GetMembers(nTeamId)
	for _, nMemberId in ipairs(tbMembers) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId)
		if pMember then
			pMember.CallClientScript("TeamMgr:OnMemberInfoChange", tbMemberData)
		end
	end
end


function TeamMgr:OnCreateChatRoom(dwTeamID, uRoomHighId, uRoomLowId)
	local bNeedClose = true;
	if InDifferBattle.OnCreateChatRoom and InDifferBattle:OnCreateChatRoom(dwTeamID, uRoomHighId, uRoomLowId) and bNeedClose then
		bNeedClose = false;
	end
	if Battle:OnCreateChatRoom(dwTeamID, uRoomHighId, uRoomLowId) and bNeedClose then
		bNeedClose = false;
	end
	if bNeedClose then
		KChat.CloseChatRoom(uRoomHighId, uRoomLowId);
	end
end
