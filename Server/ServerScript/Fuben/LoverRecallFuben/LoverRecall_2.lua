Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1612

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
    [1] = {nTemplate = 2289, nLevel = -1, nSeries = 0},  --月眉儿
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 789, nLevel = -1, nSeries = 0},  --飞龙堡弟子
    [5] = {nTemplate = 790, nLevel = -1, nSeries = 0},  --飞龙堡护法
    [6] = {nTemplate = 791, nLevel = -1, nSeries = 0},  --飞龙堡头目         
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
            {"BlackMsg", "这是…心魔幻境？不知杨少侠与月姑娘在哪！去前方看看！"},
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

            {"NpcBubbleTalk", "Npc2", "杨熙烈…就是他害得我家破人亡…孤苦伶仃…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "爹…娘…你们放心，眉儿一定会替你们报仇！", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "可是杨熙烈已经死了，对了，他还有个儿子！", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "虽然我不知道你叫什麽名字，但我知道，总有一天我们会遇见的…", 4, 16, 1},         

            {"BlackMsg", "杨少侠与月姑娘之父均是名剑客，因杨父要求比剑导致二人俱亡"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 1, nNum = 0,
        tbPrelock = {3},
        tbStartEvent = 
        {
       
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
            {"NpcBubbleTalk", "Npc2", "你们竟敢背叛飞龙堡，加害於我！真是胆大包天！", 4, 1, 1},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0}, 
            --{"SetNpcProtected", "Npc1", 1},
            {"NpcBubbleTalk", "Npc1", "哈哈哈，这麽热闹，让在下也来插一脚怎麽样！", 4, 3, 1},   

            {"BlackMsg", "是飞龙堡的叛徒！帮帮月姑娘！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "杨少侠与月姑娘的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "继续前进"}, 
        },
    },  
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 6},   
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "杨少侠与月姑娘既有杀父之仇，又有儿女之情，错综复杂"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 30, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "月眉儿！你为什麽要绑架纳兰真和蔷薇？", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "杨影枫，如果我说她们被绑架跟我无关，你相信吗？", 4, 6, 1},
            {"NpcBubbleTalk", "Npc1", "不信！这是紫轩亲眼所见，你还让我用《武道德经》到飞龙堡换人", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "哼！杨影枫，你欺人太甚，闲话少说…纳兰真已经被我杀了，有本事你就杀了我替她报仇！", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc1", "什麽！？…真儿！…月眉儿…我要杀了你…给我的真儿报仇！", 4, 21, 1}, 
            {"NpcBubbleTalk", "Npc2", "（我为何会说出这种话？难道是他太过关心真儿，让我生出嫉妒之心吗？）", 4, 26, 1}, 

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
    [8] = {nTime = 1, nNum = 0,
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

            {"SetFubenProgress", -1, "继续前进"}, 
        },
    },    
    [9] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 9},   

        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },       
    [10] = {nTime = 25, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "杨大哥，我千方百计留你在我身边，只是因为，我不想你离开…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "眉儿…你不再找我报仇了吗…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "上一代的仇怨，就让它随风而去吧…", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "眉儿，谢谢你，我一定好好待你，绝不辜负你！", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc2", "谢、谢谢你…杨大哥…", 4, 21, 1}, 

            {"SetFubenProgress", -1, "聆听二人对话"},  
        },
        tbUnLockEvent = 
        {

        },
    },    
    [11] = {nTime = 5, nNum = 0,
        tbPrelock = {10},
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