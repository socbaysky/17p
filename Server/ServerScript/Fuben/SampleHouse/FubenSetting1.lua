local tbFubenSetting = {};
Fuben:SetFubenSetting(4006, tbFubenSetting)      -- 绑定副本内容和地图

tbFubenSetting.szFubenClass     = "SampleHouseFuben";                                 -- 副本类型
tbFubenSetting.szName           = "样板房"                                            -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile   = "Setting/Fuben/SampleHouse/NpcPos.tab"              -- NPC点
tbFubenSetting.szPathFile       = "Setting/Fuben/SampleHouse/NpcPath.tab"             -- 寻路点
tbFubenSetting.tbBeginPoint     = {2322, 18120}                                        -- 副本出生点

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
}

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2330, nLevel = -1, nSeries = -1},  --林更新
    [2] = {nTemplate = 2331, nLevel = -1, nSeries = -1},  --赵丽颖
}

-- 文字内容集
tbFubenSetting.TEXT_CONTNET =
{
    LinGengXin_Talk = 
    {
        [1] = "我有酒，你有故事麽？",
        [2] = "常年在外，方知家的温暖。",
        [3] = "如若可以，我想与她简简单单的过着平淡的生活。",
        [4] = "来，少侠与我畅饮一杯~",
        [5] = "夜月一帘幽梦，春风十里柔情。",
        [6] = "欢迎到访寒舍做客~",
    },

    ZhaoLiYing_Talk = 
    {
        [1] = "欢迎到访寒舍做客~",
        [2] = "原本都是一粒沙，被人宠爱，所以才变得珍贵，岁月打磨，终成珍珠。",
        [3] = "只求与他相厮守……",
        [4] = "青山遮不住，大江东流去，识时务者方为俊杰。",
        [5] = "深深夜色柳月中，爱若轻歌吟朦胧。",
    },
}


tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {    
            --林更新
            { "AddNpc", 1, 1, nil, "LinGengXin", "LinGengXinBornPos" },
            {"RaiseEvent", "StartMultiPathMove", "LinGengXin", { {"LinGengXin_Path1", 10}, { "LinGengXin_Path2", 10 }, { "LinGengXin_Path3", 20 }, { "LinGengXin_Path4", 30 }, { "LinGengXin_Path5", 0 } }, true},
            { "StartTimeCycle", "LinGengXin_Talk", 15, nil, {"NpcRandomTalk", "LinGengXin", "LinGengXin_Talk", 6, 0}, },

            --赵丽颖
            { "AddNpc", 2, 1, nil, "ZhaoLiYing", "ZhaoLiYingBornPos", nil, 49 },
            { "StartTimeCycle", "ZhaoLiYing_Talk", 22, nil, {"NpcRandomTalk", "ZhaoLiYing", "ZhaoLiYing_Talk", 6, 0}, },
        },
        tbUnLockEvent = 
        {
        },
    },
}