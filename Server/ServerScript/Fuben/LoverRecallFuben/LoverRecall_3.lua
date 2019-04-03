Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1613

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
    [1] = {nTemplate = 2290, nLevel = -1, nSeries = 0},  --紫轩
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 2300, nLevel = -1, nSeries = 0},  --卓非凡
    [4] = {nTemplate = 846, nLevel = -1, nSeries = 0},  --流氓
    [5] = {nTemplate = 847, nLevel = -1, nSeries = 0},  --流氓头目
    [6] = {nTemplate = 2303, nLevel = -1, nSeries = 0},  --贾少         
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
            {"BlackMsg", "这是…心魔幻境？不知杨少侠与紫轩姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --杨影枫 
            --{"AddNpc", 1, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},

            --纳兰真 
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
    [3] = {nTime = 20, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --纳兰真 
            --{"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "Npc2", "父亲自小离我而去，如今母亲也因病而逝…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "罢了，我孤身一人，无依无靠，还不如去寻我的父母…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "天大地大，竟没有我的容身之所，也无人关怀", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "但愿来生，我能够生於一户三口之家，得享天伦…", 4, 16, 1},         

            {"BlackMsg", "不想紫轩姑娘的身世如此凄凉"},

            {"SetFubenProgress", -1, "聆听二人对话"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 1, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --杨影枫 
            --{"AddNpc", 1, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},              
        },
        tbUnLockEvent = 
        {   

        },
    }, 
    [5] = {nTime = 0, nNum = 12,
        tbPrelock = {4},
        tbStartEvent = 
        {
            --刷毒蜂
            {"AddNpc", 4, 8, 5, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 5, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 5, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc2", "你、你们是谁！不要！不要靠近我！救命！", 4, 1, 1},

            --卓非凡
            {"AddNpc", 3, 1, 1, "Npc3", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},  
            --{"SetNpcProtected", "Npc3", 1},
            {"NpcBubbleTalk", "Npc3", "住手！光天化日之下欺淩弱女！你们这群武林败类！", 4, 3, 1},

            {"BlackMsg", "原来是卓非凡救了她，因此紫轩姑娘才对她言听计从吧"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc3"},
            {"BlackMsg", "卓非凡和紫轩姑娘的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "继续前进"}, 
        },
    },   
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
            --紫轩
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 6},   
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "昔日紫轩听命卓非凡，以美人计接近杨少侠，日久生情，倾心于杨少侠"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 35, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "唉，公子，在你眼中，我便只是一件工具麽？", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "方才的箫声可是姑娘吹奏的吗？为何如此凄凉？", 4, 4, 1}, 
            {"NpcBubbleTalk", "Npc2", "难道公子竟听懂了我的萧韵…？", 4, 8, 1},
            {"NpcBubbleTalk", "Npc1", "箫为心声，在下鲁钝，但也听出姑娘似乎有心事？", 4, 12, 1}, 
            {"NpcBubbleTalk", "Npc2", "（想不到……他……竟是我的知音……）", 4, 16, 1},
            {"NpcBubbleTalk", "Npc1", "是不是在下太冒昧了？", 4, 20, 1}, 
            {"NpcBubbleTalk", "Npc2", "不，公子，我适才只是想起自己的身世，一时感伤……", 4, 24, 1}, 
            {"NpcBubbleTalk", "Npc1", "原来在下无意之中触动了姑娘的心事，惹得姑娘伤心，真是抱歉……", 4, 28, 1}, 
            {"NpcBubbleTalk", "Npc2", "（杨公子，若有机会，你会愿意与我远走高飞吗？）", 4, 32, 1},              

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
    [8] = {nTime = 3, nNum = 0,
        tbPrelock = {7},
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
    [9] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 9},   

            {"SetFubenProgress", -1, "继续前进"}, 
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },        
    [10] = {nTime = 20, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "杨大哥，你还恨我吗？", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "紫轩，我已经原谅你了，你就不要再自责了，好吗？", 4, 4, 1}, 
            {"NpcBubbleTalk", "Npc2", "杨大哥，你还爱我吗？", 4, 9, 1}, 
            {"NpcBubbleTalk", "Npc1", "这个……紫轩……我……", 4, 14, 1},
            {"NpcBubbleTalk", "Npc2", "杨大哥，不用说了，我明白……", 4, 17, 1},

            {"SetFubenProgress", -1, "聆听二人对话"}, 
        },
        tbUnLockEvent = 
        {

        },
    },    
    [11] = {nTime = 15, nNum = 0,
        tbPrelock = {10},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "紫轩！以前的事就不要再提了！", 4, 1, 1},   --Npc2已经挂了，这句执行不到
            {"NpcBubbleTalk", "Npc2", "谢谢你，杨大哥…以後我们再也不分开了…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc1", "紫轩，此生此世，我们再也不分开了！", 4, 11, 1},   --Npc2已经挂了，这句执行不到
        },
        tbUnLockEvent = 
        {

        },
    },   
    [12] = {nTime = 5, nNum = 0,
        tbPrelock = {11},
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