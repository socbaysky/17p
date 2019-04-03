if MODULE_ZONESERVER then
	return
end

RankActivity.LevelRankActivity = RankActivity.LevelRankActivity or {}
local LevelRankActivity = RankActivity.LevelRankActivity

RankActivity.nBindingPhoneGuideLevel = 16

function RankActivity:OnServerStart()
	local tbData = LevelRankActivity:GetData()
	if not tbData.bIsSend then
		NewInformation:AddInfomation("LevelRankActivity",GetTime() + RankActivity.OPEN_SERVER_RANK_LEVEL_INVALID_TIME,{})
		tbData.bIsSend = true
	end
end

function RankActivity:SendGuideMail(nNewLevel)
	if me.nLevel > self.nBindingPhoneGuideLevel then
		return 
	end

	local tbMsdkInfo = me.GetMsdkInfo();
	if tbMsdkInfo.nOsType == Sdk.eOSType_iOS and Server:IsCloseIOSEntry() then
		return 
	end

	if not Sdk:IsMsdk() or not Sdk:IsEfunHKTW() then
		return;
	end

	if me.nLevel == self.nBindingPhoneGuideLevel then
		local tbMail = {
			To = me.dwID;
			Title = "绑定手机提醒";
			From = "系统";
			Text = "    尊敬的侠士，现在绑定手机不但能够让帐号更安全，还将获得元宝*200、黄金钥匙*5、白水晶*10的奖励哦！\n                                      [FFFF0E][url=openwnd:马上去绑定手机, RoleInformationPanel,1][-]";
		};

		Mail:SendSystemMail(tbMail);
	end
end

------------------------等级排名------------------------
function LevelRankActivity:OnPlayerLevelup(nNewLevel)
	Lib:CallBack({RankActivity.SendGuideMail, RankActivity,nNewLevel});
	local tbData = self:GetData() 
	tbData.tbLevelRankPlayer = tbData.tbLevelRankPlayer or {}

	if me.nLevel < RankActivity.LEVEL_RANK_REWARD_LEVEL or Lib:CountTB(tbData.tbLevelRankPlayer) >= RankActivity.MAX_RANK_LEVEL_COUNT then
		return
	end

	if me.nLevel == RankActivity.LEVEL_RANK_REWARD_LEVEL then

		if self:CheckIsGet(me) then
			return
		end

		local nRank = Lib:CountTB(tbData.tbLevelRankPlayer) + 1
		local tbReward = RankActivity:LevelRankReward(nRank)
		if not tbReward or not next(tbReward) then
			Log("LevelRankActivity OnPlayerLevelup can not find Reward .",me.dwID,nRank)
			return
		end

		local szTitle = "等级排名奖励"
		local szText  = string.format("恭喜侠士在冲级活动中一马当先率先达到%d级！这是侠士参与本次活动的奖励！",RankActivity.LEVEL_RANK_REWARD_LEVEL)

		local tbMail = {
			To = me.dwID;
			Title = szTitle;
			From = "系统";
			Text = szText;
			tbAttach = tbReward;
			nLogReazon = Env.LogWay_LevelRankActivity;
		};

		local tbPlayerInfo = 
		{
			nPlayerID = me.dwID or 0,
		}

		table.insert(tbData.tbLevelRankPlayer,tbPlayerInfo)

		Mail:SendSystemMail(tbMail);

		if Lib:CountTB(tbData.tbLevelRankPlayer) == RankActivity.MAX_RANK_LEVEL_COUNT then
			local tbNewInfoData = self:GetTopTen(tbData.tbLevelRankPlayer)
			NewInformation:AddInfomation("LevelRankActivity",GetTime() + RankActivity.RANK_LEVEL_INVALID_TIME,tbNewInfoData)
		end
		
		Log("LevelRankActivity OnPlayerLevelup Send Mail Reward .",me.dwID,Lib:CountTB(tbData.tbLevelRankPlayer))
	end
end

function LevelRankActivity:SynData(pPlayer)
	local tbData = self:GetData()
	tbData.tbLevelRankPlayer = tbData.tbLevelRankPlayer or {}
	pPlayer.CallClientScript("RankActivity:OnSynLevelRankData", Lib:CountTB(tbData.tbLevelRankPlayer))
end

function LevelRankActivity:GetTopTen(tbPlayer)
	local tbData = {}

	for nRank = 1,RankActivity.MAX_NEW_INFO_COUNT do
		if tbPlayer[nRank] then
			local tbPlayerInfo = {}
			local nPlayerID = tbPlayer[nRank].nPlayerID
			local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerID) or {};
			local pKinData = Kin:GetKinById(pPlayerStay.dwKinId or 0) or {};

			tbPlayerInfo.nPlayerID = nPlayerID
			tbPlayerInfo.szName = pPlayerStay.szName or XT("无")
			tbPlayerInfo.nFaction = pPlayerStay.nFaction
			tbPlayerInfo.szKinName = pKinData.szName or "-"

			tbData[nRank] = tbPlayerInfo
		end
	end

	return tbData
end

function LevelRankActivity:CheckIsGet(pPlayer)
	local tbData = self:GetData()
	tbData.tbLevelRankPlayer = tbData.tbLevelRankPlayer or {}
	for _,tbPlayerInfo in pairs(tbData.tbLevelRankPlayer) do
		if tbPlayerInfo.nPlayerID == pPlayer.dwID then
			return true
		end
	end
end

function LevelRankActivity:GetData()
    return ScriptData:GetValue("RankActivity")
end


PlayerEvent:RegisterGlobal("OnLevelUp", LevelRankActivity.OnPlayerLevelup,LevelRankActivity);

----------------------------战力排名----------------------------
RankActivity.PowerRankActivity = RankActivity.PowerRankActivity or {}
local PowerRankActivity = RankActivity.PowerRankActivity

function PowerRankActivity:StartPowerRank()

	Log("PowerRankActivity StartPowerRank ===================================== ")

	local tbData = {}

	for nFaction = 1,Faction.MAX_FACTION_COUNT do
		local szKey = "FightPower_" ..nFaction
		RankBoard:Rank(szKey)
		local nMaxRewardRank = RankActivity:PowerRank(nFaction)
		if nMaxRewardRank ~= 0 then
			local tbRankList = RankBoard:GetRankBoardWithLength(szKey, nMaxRewardRank,1)
			if tbRankList then
				for nRank,tbPlayerInfo in ipairs(tbRankList) do
					local tbReward = RankActivity:PowerRankReward(nFaction,nRank)
					if tbReward and next(tbReward) then
						local szTitle = "战力排名奖励"
						local szText  = "恭喜侠士在战力排名活动中占据本门派战力第一的宝座！这是侠士参与本次活动的奖励！"

						local nPlayerID = tbPlayerInfo.dwUnitID or 0
						local tbMail = {

							To = nPlayerID;
							Title = szTitle;
							From = "系统";
							Text = szText;
							tbAttach = tbReward;
							nLogReazon = Env.LogWay_PowerRankActivity;

						};

						local pPlayerStay = KPlayer.GetRoleStayInfo(nPlayerID)

						if pPlayerStay then
							local tbPlayerInfo = {}
							local pKinData = Kin:GetKinById(pPlayerStay.dwKinId or 0) or {};

							tbPlayerInfo.nPlayerID = nPlayerID
							tbPlayerInfo.szName = pPlayerStay.szName or XT("无")
							tbPlayerInfo.nFaction = pPlayerStay.nFaction
							tbPlayerInfo.szKinName = pKinData.szName or "-"

							tbData[nFaction] = tbData[nFaction] or {}
							tbData[nFaction][nRank] = tbPlayerInfo

							Mail:SendSystemMail(tbMail);

							Log("PowerRankActivity StartPowerRank Send Mail Reward .",nPlayerID,nFaction,szKey,nRank,nMaxRewardRank)
						else
							Log("PowerRankActivity StartPowerRank Send Mail Reward failed,can not find tbRole.",nPlayerID,nFaction,szKey,nRank,nMaxRewardRank)
						end
					else
						Log("PowerRankActivity StartPowerRank can not find reward.",nFaction,szKey,nRank,nMaxRewardRank)
					end
				end

			else
				Log("PowerRankActivity StartPowerRank can not find rank board .",szKey,nFaction,nMaxRewardRank)
			end
		else
			Log("PowerRankActivity StartPowerRank nMaxRewardRank is 0.",szKey,nFaction)
		end	
	end

	local tbNewInfoData = {}
	for nFaction,tbInfo in pairs(tbData) do
		tbNewInfoData[nFaction] = tbInfo[1]
	end
	NewInformation:AddInfomation("PowerRankActivity",GetTime() + RankActivity.RANK_POWER_INVALID_TIME,tbNewInfoData)

	Log("PowerRankActivity EndPowerRank ===================================== ")
end