local tbAct = Activity:GetClass("LaoDongJie")
tbAct.tbTimerTrigger = {
}
tbAct.tbTrigger = { 
    Init = {},
    Start = {},
    End = {},
}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
    elseif szTrigger == "Start" then
    elseif szTrigger == "End" then
    end
    Log("LaoDongJie OnTrigger:", szTrigger)
end

function tbAct:GetUiData()
    if not self.tbUiData then
        local tbData = {}
        tbData.nShowLevel = 20
        tbData.szTitle = "劳动最光荣"
        tbData.nBottomAnchor = 0

        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local tbTime1 = os.date("*t", nStartTime)
        local tbTime2 = os.date("*t", nEndTime)
        tbData.szContent = string.format([[活动时间：[c8ff00]%s年%s月%s日%d点-%s年%s月%s日%s点[-]
劳动节来了！
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime1.hour, tbTime2.year, tbTime2.month, tbTime2.day, tbTime2.hour)
        tbData.tbSubInfo = {}
        table.insert(tbData.tbSubInfo, {szType = "Item2", szInfo = [[活动一   奖章争夺战：
活动期间大侠活跃度达到[FFFE0D]60[-]、[FFFE0D]80[-]、[FFFE0D]100[-]，打开对应的[FFFE0D]活跃宝箱[-]，会获得[11adf6][url=openwnd:劳动奖章, ItemTips, "Item", nil, 7699][-]，大侠可以以此为筹码参加奖章争夺战！
奖章争夺战对战时间为[FFFE0D]19:00-19:30[-]，大侠们记得在此期间前往帮派属地通过本页面参与活动，赢取别人的奖章！
最终活动结束时会按照大侠们的奖章数量排行发放奖励，快来争夺[FFFE0D]劳动模范[-]称号吧！结算时满[FFFE0D]10[-]个奖章都会有奖励哦！
[FFFE0D]注[-]：活动期间帮派答题暂时取消
]], szBtnText = "打开参与介面", szBtnTrap = "[url=openwnd:打开参与介面, MedalFightWaitPanel]"})
        table.insert(tbData.tbSubInfo, {szType = "Item2", szInfo = [[活动二   劳动最光荣：
活动期间元宝养护会获得更高的奖励！
]], szBtnText = "打开协助介面", szBtnTrap = "[url=openwnd:打开协助介面, PlantHelpCurePanel]"})

        self.tbUiData = tbData
    end
    return self.tbUiData
end