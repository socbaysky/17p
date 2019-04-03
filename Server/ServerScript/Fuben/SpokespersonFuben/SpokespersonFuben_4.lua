Require("ServerScript/Fuben/SpokespersonFuben/ActivityFubenBase.lua")
local tbFubenSetting = Fuben.ActivityFuben:GetFubenSetting("SpokespersonFuben_4")
local nMapTemplateId = 1621

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/SpokespersonFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/SpokespersonFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2100, 4450}  
tbFubenSetting.tbTempRevivePoint = {2100, 4450}  


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
    [1] = {nTemplate = 2318, nLevel = -1, nSeries = 0},  --小怪1
    [2] = {nTemplate = 2319, nLevel = -1, nSeries = 0},  --小怪2
    [3] = {nTemplate = 2320, nLevel = -1, nSeries = 0},  --神秘剑客  
    [4] = {nTemplate  = 74,  nLevel = -1, nSeries = 0}, --上升气流
    [5] = {nTemplate  = 2307,  nLevel = -1, nSeries = 0}, --林更新

}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 10, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            {"SetKickoutPlayerDealyTime", 20},            

            {"SetFubenProgress", -1, "稍等片刻"}, 
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
            {"SetTargetPos", 2466, 2708},   

            {"OpenDynamicObstacle", "ops1"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "继续前进"}, 

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "天霜山庄"},

            {"TrapUnlock", "TrapLock1", 2},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [3] = {nTime = 0, nNum = 10,
        tbPrelock = {2},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "教训这些小剑客"}, 

            --刷怪
            {"AddNpc", 1, 6, 3, "guaiwu1", "Fuben_4_guaiwu_1", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 4, 3, "guaiwu2", "Fuben_4_guaiwu_1", 1, 0, 1, 0, 0},

            {"NpcBubbleTalk", "guaiwu1", "站住！公子说不允许你们通过！", 3, 1, 2},    
            {"NpcBubbleTalk", "guaiwu2", "站住！公子说不允许你们通过！", 3, 2, 2}, 

            {"BlackMsg", "这些剑客年纪竟如此之小，不能下手太狠"},               
        },
        tbUnLockEvent = 
        {   

            {"OpenDynamicObstacle", "ops2"},

            {"BlackMsg", "此人果然不是善类，竟然御使这些少年少女！"}, 
            {"SetFubenProgress", -1, "继续前进"}, 
            {"SetTargetPos", 4671, 2753},
        },
    },
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock2", 4},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [5] = {nTime = 0, nNum = 10,
        tbPrelock = {4},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "教训这些小剑客"}, 
            --刷怪
            {"AddNpc", 1, 5, 5, "guaiwu1", "Fuben_4_guaiwu_2", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 5, 5, "guaiwu2", "Fuben_4_guaiwu_2", 1, 0, 0, 0, 0},

            {"NpcBubbleTalk", "guaiwu1", "今日叫你们知道我们的厉害！", 3, 1, 2},    
            {"NpcBubbleTalk", "guaiwu2", "今日叫你们知道我们的厉害！", 3, 2, 2}, 

            {"BlackMsg", "这些小剑客…算了…先打晕他们吧！"},    

        },
        tbUnLockEvent = 
        {   
            {"OpenDynamicObstacle", "ops3"},
            {"SetFubenProgress", -1, "继续前进"},        
        },
    }, 
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"SetTargetPos", 5121, 3354},

            {"AddNpc", 4, 1, 0, "QiLiu", "QiLiu1", 1},  
            {"ChangeTrap", "Jump1", nil, {5092, 4084}},
            {"ChangeTrap", "Jump2", nil, {5090, 4569}},

            {"TrapUnlock", "TrapLock4", 6},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [7] = {nTime = 0, nNum = 10,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "教训这些小剑客"}, 
            --刷怪
            {"AddNpc", 1, 4, 7, "guaiwu1", "Fuben_4_guaiwu_3", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 6, 7, "guaiwu2", "Fuben_4_guaiwu_3", 1, 0, 0, 0, 0},

            {"NpcBubbleTalk", "guaiwu1", "今日叫你们知道我们的厉害！", 3, 1, 2},    
            {"NpcBubbleTalk", "guaiwu2", "今日叫你们知道我们的厉害！", 3, 2, 2}, 

            {"BlackMsg", "这些小剑客…算了…先打晕他们吧！"},    

        },
        tbUnLockEvent = 
        {   
            {"SetFubenProgress", -1, "继续前进"},    

            {"SetDynamicRevivePoint", 4800, 5000},
        },
    }, 
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {7},
        tbStartEvent = 
        {
            {"SetTargetPos", 8400, 8800},
            {"TrapUnlock", "TrapLock5", 8},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [9] = {nTime = 40, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {
            --刷怪
            {"AddNpc", 3, 1, 9, "guaiwu3", "Fuben_4_guaiwu_4", 1, 0, 0, 0, 0},
 
            {"NpcBubbleTalk", "guaiwu3", "你们胆子到真是不小，竟敢来到我这里！", 3, 2, 1},  
            {"NpcBubbleTalk", "guaiwu3", "只要愿意抛弃另一人，我就绕过你！", 3, 5, 1}, 
            {"NpcBubbleTalk", "guaiwu3", "给你们一个机会，一人生，一人死！", 3, 8, 1},
            {"NpcBubbleTalk", "guaiwu3", "怎麽？还想顽抗挣扎吗？不知死活！", 3, 11, 1},
            {"NpcBubbleTalk", "guaiwu3", "有趣有趣，我看看你们还能坚持多久", 3, 14, 1}, 
            {"NpcBubbleTalk", "guaiwu3", "恐惧吗？恐惧吧！来吧，只要放弃对方", 3, 17, 1},
            {"NpcBubbleTalk", "guaiwu3", "来吧，选择服从我，就将获得解放", 3, 20, 1},
            {"NpcBubbleTalk", "guaiwu3", "你们年轻有为，难道就真的不怕死亡吗？", 3, 21, 1},
            {"NpcBubbleTalk", "guaiwu3", "若仍是痴迷不悟，就别怪我不客气了！", 3, 24, 1},
            {"NpcBubbleTalk", "guaiwu3", "看来你们是一心想要一起寻死了", 3, 27, 1},  
            {"NpcBubbleTalk", "guaiwu3", "想不到在死亡面前，你们竟不愿抛弃彼此，很好", 3, 30, 1},

            {"BlackMsg", "总算是见到此人了"},    
        },
        tbUnLockEvent = 
        {   
            
        },
    }, 
    [10] = {nTime = 15, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"DelNpc", "guaiwu3"},

            {"AddNpc", 5, 1, 0, "Npc1", "Fuben_4_guaiwu_4", 1, 0, 0, 0, 50},

            {"NpcBubbleTalk", "guaiwu3", "哈哈哈，两位果然是情深意重！杨大侠佩服！", 3, 2, 1},  

            {"StartTimeCycle", "cycle_1", 5, 1, {"PlayerBubbleTalk", "怎麽会！这黑衣剑客……杨大侠，怎麽会是你！？"}},

            {"NpcBubbleTalk", "guaiwu3", "此事说来话长，我们先回襄阳城吧！", 3, 8, 1},  
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