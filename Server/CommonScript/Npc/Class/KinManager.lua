local tbNpc = Npc:GetClass("KinManager");


function tbNpc:OnDialog()
	local tbDlg = {};

	if Task.KinTask:CheckOpen() then
		table.insert(tbDlg, { Text = "帮派任务", Callback = Task.KinTask.TryAcceptTask, Param = {Task.KinTask, me.dwID} });
	end	

	if KinDinnerParty:CanAcceptTask(me) then
		table.insert(tbDlg, { Text = "聚餐任务", Callback = self.AcceptTaskDlg, Param = {self}})
	end

	if KinDinnerParty:IsDoingTask(me) and KinDinnerParty:IsFinishedTask(me) then
		table.insert(tbDlg, { Text = "完成聚餐任务", Callback = KinDinnerParty.FinishTask, Param = {KinDinnerParty, me.dwID}})
	end

	local nKinNestState = Kin.KinNest:GetKinNestState(me.dwKinId);
	if nKinNestState == 1 then
		table.insert(tbDlg, { Text = "开启奸商地窖", Callback = self.DoKinNest, Param = {self} });
	elseif nKinNestState == 2 then
		table.insert(tbDlg, { Text = "前往奸商地窖", Callback = self.DoKinNest, Param = {self} });
	end
	local fnSelfChuanGong = function(dwID,dwKinId)
		local tbKinData = Kin:GetKinById(dwKinId) 
	    if not tbKinData then
	        return
	    end
		Dialog:Show(
		{
		    Text    = string.format("可以消耗[FFFE0D]1次[-]被传功次数打坐修炼，修炼完毕後可获得经验。[FF6464FF]注：打坐修炼所得经验比接受传功所得经验少[-]"),
		    OptList = {
		   		[1] = { Text = "开始打坐修炼", Callback = ChuangGong.SelfChuanGong, Param = {ChuangGong, dwID} },
		   		[2] = {Text = "知道了"}
		    },
		}, me, him);
	end
	table.insert(tbDlg, { Text = "打坐修链", Callback = fnSelfChuanGong, Param = {me.dwID,me.dwKinId} });

	table.insert(tbDlg, {Text = "知道了"});

	Dialog:Show(
	{
	    Text    = "帮派的昌盛需要依靠每一位成员的努力！",
	    OptList = tbDlg,
	}, me, him);
end

function tbNpc:AcceptTaskDlg()
	Dialog:Show({
        Text = "是否确认接受聚餐任务？",
        OptList = {
            { Text = "接受", Callback = KinDinnerParty.AcceptTask, Param = {KinDinnerParty, me.dwID}},
            {Text = "以後再说吧"},
        },
    }, me, him)
end

function tbNpc:Donation()
	me.CallClientScript("Ui:OpenWindow", "KinVaultPanel");
end

function tbNpc:DoKinNest()
	local nKinNestState = Kin.KinNest:GetKinNestState(me.dwKinId);
	local OnOk = function ()
	     Kin.KinNest:ApplyOpenKinNest(me);
	end

	if nKinNestState == 1 then
		me.MsgBox(string.format("奸商地窖危机重重，最好先确保帮派成员大多线上，开启後将给所有成员发送推送，是否确定开启？"), { {"确定", OnOk}, {"取消"}});
	elseif nKinNestState == 2 then
		Kin.KinNest:EnterKinNest(me.dwID);
	end
end