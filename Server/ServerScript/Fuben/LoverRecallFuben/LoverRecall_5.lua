Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1615

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/LoverRecallFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/LoverRecallFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5000, 9800}  
tbFubenSetting.tbTempRevivePoint = {5000, 9800}  


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
    [1] = {nTemplate = 2293, nLevel = -1, nSeries = 0},  --张琳心
    [2] = {nTemplate = 2292, nLevel = -1, nSeries = 0},  --独孤剑
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 1700, nLevel = -1, nSeries = 0},  --采花贼
    [5] = {nTemplate = 1701, nLevel = -1, nSeries = 0},  --采花贼精英
    [6] = {nTemplate = 851, nLevel = -1, nSeries = 0},  --采花贼头目         
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
            {"OpenWindow", "RockerGuideNpcPanel", "心魔幻境 纯真"},
            {"SetKickoutPlayerDealyTime", 20},

            {"SetTargetPos", 6000, 7500},

            {"SetFubenProgress", -1, "四处探索"}, 
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
            {"BlackMsg", "这是…心魔幻境？不知独孤大侠与张姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {          
            --张琳心 
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 30, 0, 0, 0},   
            {"SetNpcProtected", "Npc2", 1},
            --解锁
            {"TrapUnlock", "TrapLock1", 2},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [3] = {nTime = 6, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --纳兰真 
            --{"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 0, 0, 0, 0},


            {"NpcBubbleTalk", "Npc2", "可恶，想不到我竟会落在这麽一群小贼的手上…", 4, 1, 1},
            --独孤剑 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 28, 0, 0, 0},
            --{"SetNpcProtected", "Npc1", 1},
            {"NpcBubbleTalk", "Npc1", "姑娘！张姑娘！你没事吧？", 4, 3, 1},    

            {"BlackMsg", "张姑娘一时不慎，落入采花贼之手，是独孤少侠拼死相救才得以幸免"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 0, nNum = 12,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --刷怪
            {"AddNpc", 4, 8, 4, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 4, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 4, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc1", "竟有这麽多埋伏！即使拼了这条命也得护张姑娘周全！", 4, 1, 1},

            {"BlackMsg", "前方忽然出现了大批的采花贼！帮帮独孤少侠！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "独孤少侠和张姑娘的幻影忽然消失了"}, 
        },
    },   
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 5},   
            {"SetFubenProgress", -1, "继续前进"},             
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "独孤少侠真侠义！想必张姑娘是因此才对他产生好感！"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "独孤云？我听我爹每次提起他，都是一脸敬重的神色，仿佛是个很了不起的人物", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "真的吗？你爹倒是一个识英雄重英雄的人！敢问你爹是谁？", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "我爹就是当今殿前都指挥使张风张大人！", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "什麽？！你……你是张风的女儿！就是你爹“飞剑客”，害死了我的父亲！", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc2", "不！这不可能！你、你是不是後悔救了我——你杀父仇人的女儿？", 4, 21, 1},
            {"NpcBubbleTalk", "Npc1", "我後悔……认识了你……", 4, 26, 1}, 
            {"NpcBubbleTalk", "Npc2", "（独孤大哥，你说这话的时候可知道，那比你後悔救我更令人心痛…）", 4, 26, 1},   
            {"BlackMsg", "独孤少侠救下张姑娘时，发现她竟是杀父仇人之女，初尝甜蜜却又令人痛苦"},

            {"SetFubenProgress", -1, "聆听二人对话"}, 
        },
        tbUnLockEvent = 
        {
            --删除杨影枫
            {"PlayEffect", 9005, 5800, 2400, 0, 1},
            {"DelNpc", "Npc1"},
            --删除纳兰真
            {"PlayEffect", 9005, 5380, 2240, 0, 1},
            {"DelNpc", "Npc2"},            
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 3, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos3", false, 42, 0, 0, 0},
        },
    },    
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 8},   

            {"SetFubenProgress", -1, "继续前进"}, 
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },       
    [9] = {nTime = 20, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "独孤哥哥！", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "原来你并没有死！这真是太好了，太好了！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "独孤哥哥，全靠真正的方勉大侠。琳儿便是为他所救，我们再也不会分开了……", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "我们再也不分开了！", 4, 16, 1},

            {"BlackMsg", "张姑娘曾坠落山崖，其时独孤大侠生不如死，所幸苍天有眼，两人得以重逢"},

            {"SetFubenProgress", -1, "聆听二人对话"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [10] = {nTime = 5, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
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