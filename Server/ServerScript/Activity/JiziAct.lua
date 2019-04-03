local tbAct     = Activity:GetClass("JiziAct")
tbAct.tbTrigger = {Init = {}, Start = {}, End = {}}
tbAct.tbNpcBubbleTalk = {
    --{nMapId, nNpcTemplateId, szContent}
    {10, 620, "我姓唐，唐门的唐。我们会在江湖盛典再见的……"},
    {10, 621, "近来无事，我打算去江湖盛典散散心，你去吗？"},
    {10, 630, "江湖盛典盛况空前！必是鱼龙混杂……要确保万无一失才行！"},
    {10, 90, "江湖盛典一定很好玩吧？好担心爹爹不许我去……"},
    {10, 622, "江湖盛典即将召开，各位豪侠要积极参与哦！"},
    {10, 629, "江湖盛典，一年一度的武林盛事！怎麽能少了老夫？"},
    {10, 623, "有没有人带我去江湖盛典看看热闹呀？一定有不少好宝贝！"},
    {10, 100, "江湖盛典你们这些有为後辈去见识下就好，老夫就不去凑热闹了。"},
    {10, 97, "万众瞩目的江湖盛典，那……那杨影枫也会去吧？"},
    {10, 99, "往来商旅皆谈论这江湖盛典，想必是热闹非凡了！"},
    {10, 626, "尔等後辈皆注目于此江湖盛典，而老夫意不在此……"},
    {10, 627, "与帮派成员相聚江湖盛典，把酒言欢，可不要忘了老夫啊！"},
    {10, 624, "这武林盛事在下怎能缺席？我们江湖盛典见！"},
    {10, 88, "江湖盛典即将於[FFFE0D]2017.10.29[-]召开，望武林之中各位豪侠，均能到场共同庆贺！"},
    {10, 631, "陪着飞云一同去江湖盛典也未尝不可，但是……"},
    {10, 632, "我要去江湖盛典找影枫哥哥！"},
    {10, 625, "江湖盛典即将召开，还请各位豪侠持续关注！"},
    {10, 694, "江湖盛典即将召开，各位豪侠要积极参与哦！"},
    {10, 91, "一年一度的江湖盛典，若有闲时，老夫也想去一睹盛况……"},
    {10, 633, "什麽？江湖盛典哪里有不去的道理？"},
    {10, 1350, "不知道这江湖盛典之中有没有可以自省增进之处，我要去看看……"},
    {10, 89, "这江湖盛典定是高手云集啊，要去见见世面，交几个朋友哈哈哈！"},
    {10, 92, "江湖盛典这种整个武林的大事，也难说……不行，我必须走一趟！"},
    {10, 1529, "去江湖盛典消遣散心可以，但为师的吩咐可万万不能忘。"},
    {10, 1528, "有趣有趣，这江湖盛典本公子也要去看看！"},
    {10, 1530, "不要只想着江湖盛典！哼！要记得来桃花岛找我玩哦！"},
    {10, 190, "江湖盛典？嘿嘿嘿，又是发财的好机会……"},
    {10, 1666, "号外号外，江湖盛典即将召开！"},
    {10, 1667, "挺哥整天惦记着江湖盛典，也不知道来找我，唉……"},
    {10, 1829, "阿弥陀佛，盛典之热闹欢腾实非贫僧所喜，还是静心看守罢……"},
    {10, 2279, "我将在[FFFE0D]2017.10.29[-]出席江湖盛典，各位少侠一定要来捧场哦！"},
    {10, 2326, "我将在[FFFE0D]2017.10.29[-]出席江湖盛典，各位少侠一定要来捧场哦！"},
    {10, 2371, "江湖一线牵，珍惜这段缘……"},
    {10, 2372, "还不准备去江湖盛典？你心心念念的另一半兴许就在那等着你！"},
    {10, 2373, "你真的要自己一个人孤零零的去江湖盛典麽？"},
}
tbAct.tbAward = {
    [1] =
    {
        tbFixedItem  = {{"Item", 6775, 1}},
        tbRandomItem = {{6686, 12500},{6687, 12500},{6688, 12500},{6689, 12500},{6691, 12500},{6690, 12500},{6692, 12500},{6693, 12500},}
    },
    [2] =
    {
        tbFixedItem  = {{"Item", 6776, 1}},
        tbRandomItem = {{6686, 37500},{6687, 37500},{6688, 37500},{6689, 37500},{6691, 37500},{6690, 37500},{6692, 37500},{6693, 37500},}
    },
    [3] =
    {
        tbFixedItem  = {{"Item", 6777, 1}},
        tbRandomItem = {{6686, 50000},{6687, 50000},{6688, 50000},{6689, 50000},{6691, 50000},{6690, 50000},{6692, 50000},{6693, 50000},}
    },
    [4] =
    {
        tbFixedItem  = {{"Item", 6778, 1}},
        tbRandomItem = {{6686, 87500},{6687, 87500},{6688, 87500},{6689, 87500},{6691, 87500},{6690, 87500},{6692, 87500},{6693, 87500},}
    },
    [5] =
    {
        tbFixedItem  = {{"Item", 6779, 1}},
        tbRandomItem = {{6686, 125000},{6687, 125000},{6688, 125000},{6689, 125000},{6691, 125000},{6690, 125000},{6692, 125000},{6693, 125000},}
    },
}
tbAct.MAX_RANDOM = 1000000
function tbAct:OnTrigger(szEvent)
    if szEvent == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_EverydayTargetGainAward", "OnEverydayAward")
        Timer:Register(Env.GAME_FPS, self.AddNpcBubbleTalk, self)
    end
end

function tbAct:AddNpcBubbleTalk()
    if not self.tbParam[2] then
        return
    end
    local tbBubbleTime = Lib:SplitStr(self.tbParam[2], "-")
    if GetTime() >= Lib:ParseDateTime(tbBubbleTime[2]) then
        return
    end

    for _, tbInfo in ipairs(self.tbNpcBubbleTalk) do
        tbInfo[4] = tbBubbleTime[1]
        tbInfo[5] = tbBubbleTime[2]
        NpcBubbleTalk:Add(unpack(tbInfo))
    end
end

function tbAct:OnEverydayAward(pPlayer, nAwardIdx)
    if self.tbParam[1] and GetTime() > Lib:ParseDateTime(self.tbParam[1]) then
        return
    end

    local tbAwardInfo = self.tbAward[nAwardIdx]
    if not tbAwardInfo then
        return
    end

    local tbAward = Lib:CopyTB(tbAwardInfo.tbFixedItem)
    local nRate = MathRandom(self.MAX_RANDOM)
    local nRateSum = 0
    for i, tbItem in ipairs(tbAwardInfo.tbRandomItem) do
        nRateSum = nRateSum + tbItem[2]
        if nRate <= nRateSum then
            local nEndTime = Lib:ParseDateTime(self.tbParam[1])
            table.insert(tbAward, {"Item", tbItem[1], 1, nEndTime})
            break
        end
    end
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_JiziAct)
    Log("JiziAct OnEverydayAward:", pPlayer.dwID, nAwardIdx, nRate)
end