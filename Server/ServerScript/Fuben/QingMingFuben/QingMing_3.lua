Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1604

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4000, 3700}  
tbFubenSetting.tbTempRevivePoint = {4000, 3700}  

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
    [2] = {nTemplate = 2248, nLevel = -1, nSeries = 0},  --上官飞龙
    [3] = {nTemplate = 2252, nLevel = -1, nSeries = 0},  --月眉儿
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_3_ShiBei", false, 57},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_3_Npc1", false, 25, 0, 0, 0},

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
            {"PlayerBubbleTalk", "月姑娘，这是怎麽回事？你怎会在这里？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_3_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path3", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 25}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "嗯？此处是……淩绝峰？哼，该不会又让我遇见杨熙烈那个混帐吧！你、你是谁？", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "想不到这心魔幻境竟真能见到爹爹！是我，你忘记了吗？我是你的女儿，月眉儿啊！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "你……你说你是眉儿？！不！不可能，眉儿不过几岁，怎麽可能……", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…此处乃心魔幻境，乃一处可以实现人心中最深处梦想的地方，距你与杨叔叔决斗，已有十数载了。", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "竟有如此神奇之地？等等，你怎地称他为叔叔？哼，若非那混帐，我又岂会抛下你们母子二人？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…此事确是杨叔叔不对，但他也已死去，更何况，我、我结识了他的儿子，杨影枫", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "什麽？这个混帐，与我同归於尽之後，他儿子又来夺走了我女儿的芳心？那个混帐小子呢？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "扑哧，爹爹，你口中的那个混帐小子，也去见他的爹爹了，他答应我，要好好责备杨叔叔的！", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "这还差不多，哼，总算这个臭小子对你还算上心，他个性如何？是否也一心想着天下第一？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "他与杨叔叔不同，对女儿很好，对了爹爹，如今飞龙堡在我的带领下，江湖中尊称御下三盟。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "不错不错，虎父无犬女，你有如此成就，为父甚是欣慰，只是也莫要太过操劳，毕竟你是女儿身。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹，无论武艺才学，我可不输於男子！我告诉你哦，爹、爹爹……你，你的身体怎麽越来越虚幻了？", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "嗯？看来为父的大限已到，哈哈哈，不必如此，为父本就已不在，知你幸福，为父在九泉之下也就无憾了。保重，乖女儿！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "爹爹保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4580, 3150, 57}, 

            --纳兰真 
            {"AddSimpleNpc", 2252, 4300, 3400, 25}, 
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