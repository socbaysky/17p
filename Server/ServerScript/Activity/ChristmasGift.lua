--圣诞礼物
local tbAct = Activity:GetClass("ChristmasGift")

tbAct.MAX_RATE = 1000000
tbAct.tbMapInfo = {
    --[10 地图模板id] = {nRate --产生概率, {nPosX --坐标X, nPosY --坐标Y}}
    [300] = {nRate = 500000, nPosX = 3680, nPosY = 6592}, --藏剑山庄
    [301] = {nRate = 500000, nPosX = 2000, nPosY = 8484}, --武夷禁地
    [302] = {nRate = 500000, nPosX = 4460, nPosY = 7092}, --熔火霹雳
    [303] = {nRate = 500000, nPosX = 2332, nPosY = 3453}, --翠竹幽谷
    [304] = {nRate = 500000, nPosX = 3659, nPosY = 2458}, --呼啸栈道
    [305] = {nRate = 500000, nPosX = 1960, nPosY = 2637}, --雪峰硝烟

    [201] = {nRate = 1000000, nPosX = 3939, nPosY = 1639}, --a1
    [220] = {nRate = 1000000, nPosX = 4035, nPosY = 2690}, --b10
    [225] = {nRate = 1000000, nPosX = 1062, nPosY = 1375}, --c5
    [240] = {nRate = 1000000, nPosX = 4959, nPosY = 5237}, --d10
    [244] = {nRate = 1000000, nPosX = 3076, nPosY = 5722}, --e4
    [260] = {nRate = 1000000, nPosX = 4053, nPosY = 2001}, --f10
    [270] = {nRate = 1000000, nPosX = 1139, nPosY = 6564}, --g10

    [500] = {nRate = 500000, nPosX = 3276, nPosY = 3158}, --山贼秘窟

    [600] = {nRate = 500000, nPosX = 2059, nPosY = 4864}, --藏宝地宫
}
tbAct.nGiftNpcTID = 2123 -- 圣诞老人模板ID
tbAct.nGiftItemTID = 3527 -- 圣诞礼物道具模板ID
tbAct.nRequireLevel = 20
tbAct.MAX_AWARD_COUNT = 60 --活动期间最多只能拿到这么多的道具

tbAct.tbTimerTrigger = 
{
    [1] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify" },
    [2] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify" },
    [3] = {szType = "Day", Time = "19:00" , Trigger = "SendWorldNotify" },
}
tbAct.tbTrigger = { Init = { }, 
                    Start = { {"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}, {"StartTimerTrigger", 3}, },
                    SendWorldNotify = { {"WorldMsg", "各位侠士，[FFFE0D]元旦、圣诞[-]双节同庆活动开始了，大家可通过查询「[FFFE0D]最新消息[-]」了解活动内容！", 1} },
                    End = { }, }
function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:SendNews()
    elseif szTrigger == "Start" then
        Activity:RegisterGlobalEvent(self, "Act_OnMapCreate", "OnMapCreate")
        Activity:RegisterNpcDialog(self, self.nGiftNpcTID,  {Text = "领取圣诞礼物", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterNpcDialog(self, self.nGiftNpcTID,  {Text = "了解详情", Callback = self.OpenClientUi, Param = {self}})
        local _, nEndTime = self:GetOpenTimeInfo()
        self:RegisterDataInPlayer(nEndTime)
    end
end

function tbAct:OnNpcDialog()
    if me.nLevel < self.nRequireLevel then
        me.CenterMsg(string.format("请先将等级提升到%d级！", self.nRequireLevel))
        return
    end
    him.tbGetList = him.tbGetList or {}
    if him.tbGetList[me.dwID] then
        me.CenterMsg("你已经领取过我给的礼物，不要贪心!")
        return
    end

    local tbData = self:GetDataFromPlayer(me.dwID) or {}
    tbData.nGetNum = tbData.nGetNum or 0
    if tbData.nGetNum >= self.MAX_AWARD_COUNT then
        me.CenterMsg("你已经领的够多了！剩下的我还要给其他少侠呢！")
        return
    end
    tbData.nGetNum = tbData.nGetNum + 1
    self:SaveDataToPlayer(me, tbData)

    him.tbGetList[me.dwID] = true
    me.SendAward({{"Item", self.nGiftItemTID, 1}}, true, false, Env.LogWay_ChristmasGift)

    Activity:OnPlayerEvent(me, "Act_ChristmasGetGift", 1)
end

function tbAct:OpenClientUi()
    me.CallClientScript("Ui:OpenWindow", "NewInformationPanel", "ShuangJieTongQing")
end

function tbAct:OnMapCreate(nMapTID, nMapID)
    local tbInfo = self.tbMapInfo[nMapTID]
    if not tbInfo then
        return
    end

    local nRate = MathRandom(self.MAX_RATE)
    if nRate > tbInfo.nRate then
        return
    end

    local pNpc = KNpc.Add(self.nGiftNpcTID, 1, -1, nMapID, tbInfo.nPosX, tbInfo.nPosY)
    Log("ChristmasGift OnMapCreate And CreateNpc Success", nMapTID, nMapID, pNpc.nId)
end

function tbAct:SendNews()
    local szNewInfoMsg = [[
[FFFE0D]元旦、圣诞双节同庆活动开始了！[-]
    [FFFE0D]活动时间[-]：2017年12月25日4点~~2018年1月4日24点
    [FFFE0D]参与等级[-]：20级

    [FFFE0D]1、元旦雪人[-]
    活动期间，[FFFE0D]帮派属地[-]会出现一个[FFFE0D]雪人[-]，[FFFE0D]帮派烤火[-]开始时可找其领取一个[11adf6][url=openwnd:雪人礼盒, ItemTips, "Item", nil, 3533][-]。
    帮派烤火[FFFE0D]答题[-]时，能够得到[11adf6][url=openwnd:雪花, ItemTips, "Item", nil, 3532][-]，可去找雪人进行「[FFFE0D]堆雪人[-]」的操作，能获得[FFFE0D]经验[-]奖励。
    雪人堆积一定次数，可以[FFFE0D]升级变大[-]，同时，对[FFFE0D]上一等级[-]雪人进行过「[FFFE0D]堆雪人[-]」操作的帮派成员能获得额外的「[FFFE0D]雪人礼盒[-]」。
    
    [FFFE0D]2、圣诞礼物[-]
    活动期间，在[FFFE0D]组队秘境[-]、[FFFE0D]凌绝峰[-]、[FFFE0D]山贼秘窟[-]及[FFFE0D]挖宝[-]出现的地宫中，可能遇到[FFFE0D]圣诞老人[-]，与其对话可以获得圣诞礼物[11adf6][url=openwnd:圣诞袜子, ItemTips, "Item", nil, 3527][-]，打开能获得丰厚奖励，或许有机会获得[11adf6][url=openwnd:圣诞糖果, ItemTips, "Item", nil, 3535][-]。
    [FFFE0D]注[-]：大侠在活动期间仅可以获得60份圣诞老人的礼物哦！

    [FFFE0D]3、心想事成[-]
    活动期间，在开启[FFFE0D]活跃宝箱[-]、完成[FFFE0D]家园协助[-]、击杀[FFFE0D]野外精英[-]、攻击[FFFE0D]野外首领[-]时大侠有机会获得[11adf6][url=openwnd:未鉴定的许愿符, ItemTips, "Item", nil, 7346][-]，鉴定後可随机获得[11adf6][url=openwnd:稀有的许愿符, ItemTips, "Item", nil, 7349][-]或者[11adf6][url=openwnd:普通的许愿符, ItemTips, "Item", nil, 7348][-]，许愿符可以拿到[FFFE0D]临安[-]的[FFFE0D]圣诞少女[-]处许愿获得积分，每消耗一张[11adf6][url=openwnd:稀有的许愿符, ItemTips, "Item", nil, 7349][-]可以获得一次留下祝福的机会！活动结束时将按照积分排行发放礼品。
    注意[11adf6][url=openwnd:未鉴定的许愿符, ItemTips, "Item", nil, 7346][-]是有时效的哦！如果大侠[FFFE0D]未鉴定的许愿符[-]用不完，可以选择封印它变成[11adf6][url=openwnd:封印的许愿符, ItemTips, "Item", nil, 7347][-]摆摊售卖，赚取一份外快呢！
    [FFFE0D]注[-]：大侠每天仅可以鉴定15张[FFFE0D]许愿符[-]。

    [FFFE0D]4、手留余香[-]
    活动期间，在进行前三个活动时有机会获得[11adf6][url=openwnd:赠品·佳节礼盒, ItemTips, "Item", nil, 7350][-]，可以把它拿来送给你的好友，你的好友会收到一份精美的[11adf6][url=openwnd:佳节礼盒, ItemTips, "Item", nil, 7351][-]，打开可以获得精美的礼品！祝愿你们的情谊地久天长！
    ]]

    local nEndTime = Activity:GetActEndTime(self.szKeyName)
    NewInformation:AddInfomation("ShuangJieTongQing", nEndTime, {szNewInfoMsg}, { szTitle = "双节同庆"})
end

--礼盒传情
local tbLHAct = Activity:GetClass("LiHeChuanQing")
tbLHAct.tbJoinActInfo = {
    Rank = 10000,
}
tbLHAct.nBoxTID = 10
tbLHAct.MAX_RATE = 1000000

tbLHAct.tbTrigger = { Init = { }, Start = { }, End = { }, }
function tbLHAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnJoinAct", "OnJoinAct")
    end
end

function tbLHAct:OnJoinAct(pPlayer, szAct)
    if not self.tbJoinActInfo[szAct] then
        return
    end

    local nRate = MathRandom(self.MAX_RATE)
    if nRate > self.tbJoinActInfo[szAct] then
        return
    end

    pPlayer.SendAward({{"Item", self.nBoxTID, 1}}, true, false, Env.LogWay_LiHeChuanQing)
    Log("ChristmasGift OnJoinAct And SendAward", pPlayer.dwID, szAct)
end