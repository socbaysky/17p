c2z.OnMsgBoxSelect = c2s.OnMsgBoxSelect
c2z.OnSimpleTapNpc = c2s.OnSimpleTapNpc
c2z.OnDialogSelect = c2s.OnDialogSelect
c2z.ChangeActionMode = c2s.ChangeActionMode
c2z.FocusSelfAllPet = c2s.FocusSelfAllPet
c2z.RequestBossLeaderBossDmgRank = c2s.RequestBossLeaderBossDmgRank;
c2z.BossLeaderEnterFuben = c2s.BossLeaderEnterFuben;
c2z.OnTeamRequest = c2s.OnTeamRequest;
c2z.OnTeamUpRequest = c2s.OnTeamUpRequest;
c2z.OnSyncNearbyTeamsReq = c2s.OnSyncNearbyTeamsReq;

function c2z:PlayerLeaveMap(szMsg)
	local nMapId = me.nMapId;
	local szMsg = szMsg or "确定要离开活动？"
	if me.szCanLeaveMapMsg then
		szMsg = me.szCanLeaveMapMsg;
	end

	me.MsgBox(szMsg, {{"确定", function (nMapId)
		if me.nMapId ~= nMapId then
			return;
		end

    	if (me.nCanLeaveMapId and me.nCanLeaveMapId == me.nMapId) or Map:CheckCanLeave(me.nMapTemplateId) then
    		me.ZoneLogout()
    	end
	end, nMapId}, {"取消"}})
end

function c2z:LeaveFuben(bIsPersonalFuben, bShowStronger, bIsWin)
    if bShowStronger then
        me.CallClientScript("Ui:OpenWindow", "StrongerPanel");
    end

    if bIsPersonalFuben then
        if me.nState ~= Player.emPLAYER_STATE_ALONE then
            return;
        end

        if not bIsWin then
            local nX, nY, nFightMode = Map:GetDefaultPos(me.nMapTemplateId);
            me.SetPosition(nX, nY);
            me.nFightMode = nFightMode;
        end

        me.LeaveClientMap();
        me.CallClientScript("PersonalFuben:OnLeaveSucess");
        PersonalFuben:ClearCurrentFubenData(me);
    else
        if me.nLastMapExploreMapId then --从探索进去的话要返回探索
            Fuben.DungeonFubenMgr:CheckReturnMapExplore(me)
        elseif me.nMapTemplateId == Fuben.WhiteTigerFuben.OUTSIDE_MAPID then --从白虎堂第一层出来要回到准备场
            Fuben.WhiteTigerFuben:TryBackToPrepareMap(me)
        elseif me.nCanLeaveMapId and me.nCanLeaveMapId == me.nMapId then
            me.ZoneLogout();
        else
            Fuben.tbErrorMapTemplate = Fuben.tbErrorMapTemplate or {};
            if not Fuben.tbErrorMapTemplate[me.nMapTemplateId] then
                Log("[LeaveFuben] ERR ?? use LeaveFuben error !!", me.nMapTemplateId);
            end
            Fuben.tbErrorMapTemplate[me.nMapTemplateId] = true;
            me.ZoneLogout();
        end
    end

    -- me.ZoneLogout() 之后 me 就不存在了，所以后面就不要有代码了，容易引起宕机
end

function c2z:ApplyChangeMode(nMode)
    if nMode == Player.MODE_CAMP and Kin.Def.bForbidCamp then
        me.CenterMsg("禁止操作");
        return;
    end

    Player:ChangePKMode(me, nMode);
end

function c2z:InDifferBattleChooseFaction(nFaction)
    InDifferBattle:ChooseFaction(me, nFaction)
end

function c2z:InDifferBattleGiveMoneyTo(dwRoleId2, nMoney)
    InDifferBattle:GiveMoneyTo(me, dwRoleId2, nMoney)
end

function c2z:InDifferBattleRequestInst(...)
    InDifferBattle:RequestInst(me, ...)
end

--目前跨服穿戴装备只是心魔幻境中
function c2z:UseEquip(nId, nEquipPos)
   InDifferBattle:RequestInst(me, "UseEquip", nId, nEquipPos)
end

function c2z:UnuseEquip(nPos)
   InDifferBattle:RequestInst(me, "UnuseEquip", nPos)
end

function c2z:DoRequesWLDH(szType, ... )
    local FunCall = WuLinDaHui.tbC2ZRequest[szType];
    if not FunCall then
        return;
    end

    FunCall(me, ...);
end


function c2z:OnMapRequest(...)
    Map:ClientRequestZ(...);
end

--只允许了部分接口
local tbPartnerApi = {
    SetPartnerPos = 1,
    ChangePartnerFightID = 1,
    CallPartner = 1,
};
function c2z:CallPartnerFunc(szCmd, ...)
    if not tbPartnerApi[szCmd] then
        Log("[Partner] c2s:CallPartnerFunc ERR ?? not tbPartnerApi[szCmd] !!", me.szName, szCmd, ...);
        return;
    end

    local pNpc = me.GetNpc();
    if pNpc.nShapeShiftNpcTID > 0 then
        me.CenterMsg("变身状态时不能操作", true);
        return;
    end

    Partner[szCmd](Partner, me, ...);
    FightPower:ChangeFightPower("Partner", me);
end

function c2z:QYHCrossClientCall(szFun, ...)
    QunYingHuiCross.tbQunYingHuiZ:OnClientCall(szFun, me, ...)
end

function c2z:CrossDomainUseSupplysReq(nItemId)
    DomainBattle.tbCross:UseSupplysReq(me, nItemId)
end

function c2z:CrossDomainSyncSupplyReq(nVersion)
    DomainBattle.tbCross:SyncSupplyReq(me, nVersion)
end

function c2z:CrossDomainLeave()
    DomainBattle.tbCross:LeaveRequest(me)
end

function c2z:CrossDomainKingTransferCountReq(nVersion)
    DomainBattle.tbCross:SyncKingTransferCountInfoReq(me, nVersion)
end

function c2z:CrossDomainKingTransferRightReq()
    DomainBattle.tbCross:SyncKingTransferRightInfoReq(me)
end

function c2z:CrossDomainOuterOccupyReq(nVersion)
    DomainBattle.tbCross:SyncOuterOccupyInfoReq(me, nVersion)
end

function c2z:CrossDomainKingOccupyReq(nVersion)
    DomainBattle.tbCross:SyncKingOccupyInfoReq(me, nVersion)
end

function c2z:CrossDomainTopKinReq(nVersion)
    DomainBattle.tbCross:SyncTopKinInfoReq(me, nVersion)
end

function c2z:CrossDomainTopPlayerReq(nVersion)
    DomainBattle.tbCross:SyncTopPlayerInfoReq(me, nVersion)
end

function c2z:CrossDomainSelfReq()
    DomainBattle.tbCross:SyncSelfInfoReq(me)
end

function c2z:CrossDomainChangeKingCampReq(nCampIndex)
    DomainBattle.tbCross:ChangeKingCampReq(me, nCampIndex)
end

function c2z:CrossDomainKingCampInfoReq()
    DomainBattle.tbCross:KingCampInfoReq(me)
end

function c2z:CrossDomainMiniMapInfoReq(nVersion)
    DomainBattle.tbCross:MiniMapInfoReq(me, nVersion)
end

function c2z:RequestRemoveSkillState(nSkillId)
    me.RemoveSkillState(nSkillId);
end
