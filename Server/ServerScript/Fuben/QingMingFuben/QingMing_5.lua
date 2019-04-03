Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1606

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4030, 3670}  
tbFubenSetting.tbTempRevivePoint = {4030, 3670}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {4320, 3700}, nDir = 29},              -- 使用道具者
    {tbPos = {4020, 3400}, nDir = 15},             -- 协助者
}

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
   
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2257, nLevel = -1, nSeries = 0},  --纪念石碑
    [2] = {nTemplate = 2244, nLevel = -1, nSeries = 0},  --杨熙烈
    [3] = {nTemplate = 2254, nLevel = -1, nSeries = 0},  --杨影枫
    [4] = {nTemplate = 2276, nLevel = -1, nSeries = 0},  --纪念石碑（展示）
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            --纪念石碑 
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_5_ShiBei", false, 57},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_5_Npc1", false, 23, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 淩绝峰"},
            {"SetKickoutPlayerDealyTime", 20},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
        },
    },
    [2] = {nTime = 3, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "不远处有一块碑石，这是……淩绝峰？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "杨少侠，这是怎麽回事？你怎会在这里？"}
        },
    },
    [3] = {nTime = 3, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "前方的石碑上似乎有些文字，不妨去看看上面写了什麽"},   
            {"SetFubenProgress", -1, "查看石碑"}, 
        },
    },
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            --祭拜开始时解锁，刷出Npc纳兰潜凛
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_5_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path5", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 23}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "嗯？此地……是淩绝峰？哼，上官小儿！你在哪，给老子滚出来再大战三百回合！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…多年不见…想不到你风采依旧…仍是……咳咳，这般的豪气干云！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "你、你叫我什麽？爹爹？小子，你是哪块石头里蹦出来的，我可没你这麽大的儿子！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "咳咳，爹爹，距你与上官叔叔比武已过了十数年，说出来你可能不信，但你看这一招，喝！", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "这…这是我家传剑法中的烈火晴天！原来如此，原来当年我确实死了，上官小儿呢？他如今怎麽样了？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹，当年您与上官叔叔比武，两败俱伤，上官叔叔也死于重伤，而且，上官叔叔的妻子也跳崖自尽了……", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "什麽！这……我不过想要与他比试一番，这……料不到竟会导致他家破人亡！实在不该！那、那个小女孩呢？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "您说的那个小女孩名叫月眉儿，如今是孩儿的红颜知己，孩儿自当好生照料。", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "好！这般便好！枫儿，既是我理亏，你定要好好待她，决不可负她。对了，你武功如何，可成为天下第一了？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "唉，爹爹，事到如今，你还如此执着於天下第一这个名头吗？", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "废话！为父穷尽一生精力，便是要攀上剑道高峰，成为天下第一人，你、你莫非忘记老子的训导了？", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹不必担心，如今我也算得上是天下第一人，您的心愿，孩儿已经替你完成了", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "很好，哈哈哈，既夺得天下第一，又赢得美人芳心，有子如此，为父深感欣慰！哈哈哈！你去吧！老子可以安息了！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "唉，爹。保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4580, 3150, 57}, 

            --纳兰真 
            {"AddSimpleNpc", 2254, 4300, 3400, 23}, 
        },
    },
    [100] = {nTime = 600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetShowTime", 100},
            --{"SetFubenProgress", -1, "即将离开"}, 
        },
        tbUnLockEvent = 
        {
            {"GameLost"},
        },
    },
}