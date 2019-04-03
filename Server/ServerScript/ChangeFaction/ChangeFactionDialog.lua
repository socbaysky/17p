
local tbNpc = Npc:GetClass("ChangeFactionDialog");
Require("CommonScript/ChangeFaction/ChangeFactionDef.lua");

local tbDef = ChangeFaction.tbDef;

function tbNpc:OnDialog()
    Dialog:Show(
    {
        Text    = "这里是洗髓岛，你可以在这里任意切换各个门派，以及重置技能点",
        OptList = {
            { Text = "选择要转的门派", Callback = self.SelectAllFaction, Param = {self, him.nId} },
            { Text = "我选好了，要离开", Callback = self.LeaveMap, Param = {self, him.nId} },
        };
    }, me, him);
end

function tbNpc:LeaveMap(nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("ChangeFactionDialog SelectAllFaction Not Npc");
        return;
    end

    local tbPlayerInfo = ChangeFaction:GetPlayerInfo(me.dwID);
    local nOrgFaction = me.nFaction;
    local nSaveFaction = me.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveEnterFaction);
    if nSaveFaction > 0 then
        nOrgFaction = nSaveFaction;
    elseif tbPlayerInfo then
        nOrgFaction = tbPlayerInfo.nOrgFaction;
    end

    local nOrgSex = me.nSex;
    local nSaveSex = me.GetUserValue(tbDef.nSaveGroup, tbDef.nSaveEnterSex);
    if nSaveSex > 0 then
        nOrgSex = nSaveSex;
    elseif tbPlayerInfo then
        nOrgSex = tbPlayerInfo.nOrgSex;
    end

    local szMsg = "";
    if nOrgFaction == me.nFaction and nOrgSex == me.nSex then
        szMsg = "你当前所选门派与原门派相同。你确定要[FF0000]消耗转门派[-]的机会，但[FF0000]不转门派或性别[-]吗？";
    else
        local szFaction = Faction:GetName(me.nFaction);
        szMsg = string.format("你选择了[FFFE0D]%s[-]作为新的门派。你确定这样的选择？确认离开洗髓岛後，将不可再改变", szFaction);
    end

    me.MsgBox(szMsg, {{"确认", self.ConfirmLeaveMap, self, me.dwID}, {"取消"}});  
end

function tbNpc:ConfirmLeaveMap(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    pPlayer.GotoEntryPoint();
    Log("ChangeFaction ConfirmLeaveMap", nPlayerID);
end

function tbNpc:SelectAllFaction(nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("ChangeFactionDialog SelectAllFaction Not Npc");
        return;
    end

    -- local tbAllFaction = {};
    -- for nFaction, tbInfo in pairs(Faction.tbFactionInfo) do
    --     tbAllFaction[nFaction] = 1;
    -- end

    me.CallClientScript("Ui:OpenWindow", "ChangeFactionPanel")
end

function tbNpc:AcceptChangeFaction(nNpcID, nChangeFaction)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("PunishTask Accept Not Npc");
        return;
    end

    --ChangeFaction:PlayerChangeFaction(me, nChangeFaction);
end