Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1617

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
    [1] = {nTemplate = 2296, nLevel = -1, nSeries = 0},  --燕若雪
    [2] = {nTemplate = 2295, nLevel = -1, nSeries = 0},  --南宫飞云
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 1916, nLevel = -1, nSeries = 0},  --飞龙堡弟子
    [5] = {nTemplate = 1917, nLevel = -1, nSeries = 0},  --飞龙堡护法
    [6] = {nTemplate = 1918, nLevel = -1, nSeries = 0},  --飞龙堡头目         
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
            {"BlackMsg", "这是…心魔幻境？不知南宫少侠与燕姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --杨影枫 
            --{"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},

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

            {"NpcBubbleTalk", "Npc2", "唉，想不到我堂堂金国公主，竟会落入贼匪之手", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "看来他们也知道我来历不凡，只是希望捞一笔钱", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "这寨子贼匪众多，要逃出去还真是有些不容易", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "这可怎麽办呢？虽然我也没什麽要事，也不能一直在这啊", 4, 16, 1},         

            {"BlackMsg", "燕姑娘曾误入贼匪营寨，一时之间无法脱身"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 0, nNum = 12,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --刷毒蜂
            {"AddNpc", 4, 8, 4, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 4, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 4, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc2", "哼，你们终於是等不及要准备动手了吗？", 4, 1, 1},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0}, 
            --{"SetNpcProtected", "Npc1", 1},
            {"NpcBubbleTalk", "Npc1", "住手！小仙女岂是你们这些脏手能碰的？", 4, 3, 1},   

            {"BlackMsg", "前方忽然出现了大批的贼匪！帮帮燕姑娘！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "燕姑娘和南宫少侠的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "继续前进"}, 
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
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "南宫少侠与燕姑娘的初次相逢有些戏剧性，堪称英雄救美"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [6] = {nTime = 33, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "多美的黄昏", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "我们一生一世都这样在黄昏里漫步好不好？", 4, 5, 1}, 
            {"NpcBubbleTalk", "Npc2", "但愿上天保佑我们", 4, 10, 1},
            {"NpcBubbleTalk", "Npc1", "你放心，我一定做一番大事业，然後风风光光明媒正娶，让你成为天下最幸福的新娘子", 4, 15, 1}, 
            {"NpcBubbleTalk", "Npc2", "好久没看到你这麽自信了", 4, 20, 1},
            {"NpcBubbleTalk", "Npc2", "（请原谅我的懦弱，不能和你远走高飞，我不能背叛父亲。但愿来世还能相见）", 4, 25, 1},
            {"NpcBubbleTalk", "Npc2", "谢谢你，飞云，遇见你是我此生最美好的事…和你一起的日子是我此生最美好的时光…", 4, 30, 1},

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
    [9] = {nTime = 28, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "为什麽天下的英雄，不是杀人，就是被杀？为什麽这些人，不看重别人甚至自己的生命？", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "你宝剑出鞘的时候，又何曾想过别人的生命？你孤身犯险的时候，又何曾想过自己的生命？", 4, 5, 1},
            {"NpcBubbleTalk", "Npc1", "若雪，你告诉我，这是为什麽？为什麽会这样？", 4, 10, 1}, 
            {"NpcBubbleTalk", "Npc2", "我也不知道，或许，这就是传说中的命吧！", 4, 15, 1},
            {"NpcBubbleTalk", "Npc1", "你说得对，若雪，我们走吧…从此退隐江湖", 4, 20, 1}, 
            {"NpcBubbleTalk", "Npc2", "好，不管你要去哪里，我都陪着你", 4, 25, 1},   

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