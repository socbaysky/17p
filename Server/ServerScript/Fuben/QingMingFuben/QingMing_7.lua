Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1608

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2400, 6300}  
tbFubenSetting.tbTempRevivePoint = {2400, 6300}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {2460, 74200}, nDir = 31},              -- 使用道具者
    {tbPos = {2290, 7060}, nDir = 13},             -- 协助者
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
    [2] = {nTemplate = 2246, nLevel = -1, nSeries = 0},  --张风
    [3] = {nTemplate = 2256, nLevel = -1, nSeries = 0},  --张如梦
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_7_ShiBei", false, 38},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_7_Npc1", false, 7, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 临安驿道"},
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
            {"BlackMsg", "不远处有一块碑石，这是……临安驿道？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "张少侠，这是怎麽回事？你怎会在这里？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_7_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path7", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 7}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "这里是……我竟然还没死？南宫灭，南宫灭呢！梦儿？你怎麽会在这里？此处危险，快走！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "这传说竟是真的……心魔幻境，竟然真的能让人梦想成真！爹爹，孩儿不孝，请受孩儿一拜！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "哎呀！你这孩子，这是干什麽？我说了，此处不宜久留，你还不速速离开！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹，不必担心，南宫灭早已死去多时，就连您，也不过是虚假的幻像…是孩儿心中的一抹执念…", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "你说什麽？原来我并未记错，我确是被南宫灭重伤，不久後便撒手人寰了？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "确实如此。此地名为心魔幻境，传闻能够将人内心深处的梦想化为现实，我也没想到竟然是真的。", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "如此也好，如此也好啊，我毕竟双手沾满了罪孽，能够死得其所，已经很好了！对了！独孤兄的遗孤如何？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹放心，独孤兄好得很，他把一切真相都告诉我了，原来爹爹您当年是忍辱负重，都怪孩儿愚昧！一直错怪爹了！", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "呵呵，不怪你，不怪你，这麽多年你也一直很痛苦，爹也知道，只是有些话，却不能坦白告诉你。", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "爹，我有一事，还需要您老人家原谅，希望你莫要生气……", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "你这小子，终日沉溺于酒色之时，老子也没少生你的气，如今又做出什麽坏事来了？", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…我、我与金国女子南宫彩虹真心相爱，已结为夫妇，隐居大漠。再不理世事！还请爹…爹你的身体…", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "梦儿，你至情至性，为父一直清楚，此事并无过错，只可惜我见不到我的儿媳妇了。呵呵，隐居也好，爹祝福你们！要保重！", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "多谢爹爹！", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 2680, 7180, 38}, 

            --纳兰真 
            {"AddSimpleNpc", 2256, 2440, 6810, 7}, 
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