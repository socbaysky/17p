local tbNpc = Npc:GetClass("HouseDefendNpc");

function tbNpc:OnDialog()
    local szDialog = "唉，说来有些惭愧，我们遭人下毒，武功暂失，所住之地如今为人霸占，还望侠士施以援手";
    local tbOpt = {};
    local dwOwnerId = House:GetHouseInfoByMapId(him.nMapId);
    if not dwOwnerId then
        Dialog:Show(
        {
            Text = szDialog,
            OptList = tbOpt,
        }, me, him)
        return;
    end

    if dwOwnerId == me.dwID then
        table.insert(tbOpt, { Text = "开启新颖小筑夺回战", Callback = function ()
            Activity:OnPlayerEvent(me, "Act_HouseDefend_OpenFuben");
        end, Param = {} });
    end

    table.insert(tbOpt, { Text = "前往新颖小筑夺回战", Callback = function ()
        Activity:OnPlayerEvent(me, "Act_HouseDefend_EnterFuben", dwOwnerId);
    end, Param = {} });

    Dialog:Show(
    {
        Text = szDialog,
        OptList = tbOpt,
    }, me, him)
end