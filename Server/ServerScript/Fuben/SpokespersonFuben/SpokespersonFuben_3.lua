Require("ServerScript/Fuben/SpokespersonFuben/ActivityFubenBase.lua")
local tbFubenSetting = Fuben.ActivityFuben:GetFubenSetting("SpokespersonFuben_3")
local nMapTemplateId = 1620

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/SpokespersonFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/SpokespersonFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {1140, 3740}  
tbFubenSetting.tbTempRevivePoint = {1140, 3740}  

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
    [1] = {nTemplate = 2315, nLevel = -1, nSeries = 0},  --小怪1
    [2] = {nTemplate = 2316, nLevel = -1, nSeries = 0},  --小怪2
    [3] = {nTemplate = 2317, nLevel = -1, nSeries = 0},  --采集石柱
    [4] = {nTemplate = 2332, nLevel = -1, nSeries = 0},  --对敌放技能
    [5] = {nTemplate = 2333, nLevel = -1, nSeries = 0},  --对我放技能
    [6] = {nTemplate = 2334, nLevel = -1, nSeries = 0},  --血牛
    [7] = {nTemplate = 2335, nLevel = -1, nSeries = 0},  --柱子只看    
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
            {"SetKickoutPlayerDealyTime", 20},            

            {"SetFubenProgress", -1, "四处探索"}, 
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
           {"SetTargetPos", 2470, 3650},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "熔岩秘窟"},

            {"PlayerBubbleTalk", "实在抱歉，连累你了…不料竟被迫逃到此处…"},

            {"TrapUnlock", "TrapLock1", 2},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [3] = {nTime = 0, nNum = 5,
        tbPrelock = {2},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败敌人"}, 

            --刷隐形人
            {"AddNpc", 4, 1, 0, "Kill_guaiwu", "Fuben_3_shizhu", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 1, 0, "Kill_player", "Fuben_3_shizhu", 1, 0, 0, 0, 0},

            --刷怪
            {"AddNpc", 1, 3, 3, "guaiwu1", "Fuben_3_guaiwu_1", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 2, 3, "guaiwu2", "Fuben_3_guaiwu_1", 1, 0, 1, 0, 0},

            {"PlayerBubbleTalk", "可恶！想不到竟追到这里来了！"},

            {"BlackMsg", "前方忽然出现了埋伏！消灭他们！"},               
        },
        tbUnLockEvent = 
        {   
            {"OpenDynamicObstacle", "ops1"},
            {"BlackMsg", "快走吧，追兵或许马上就到了"}, 
            {"SetFubenProgress", -1, "继续前进"}, 
            {"SetTargetPos", 6250, 3500},
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
    [5] = {nTime = 0, nNum = 5,
        tbPrelock = {4},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败敌人"}, 

            --刷怪
            {"AddNpc", 1, 3, 5, "guaiwu3", "Fuben_3_guaiwu_2", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 2, 5, "guaiwu4", "Fuben_3_guaiwu_2", 1, 0, 0, 0, 0},

            {"BlackMsg", "前方又再出现埋伏！消灭他们！"},    

            --赵丽颖           
            {"AddNpc", 3, 1, 0, "Npc", "ZhaoLiYin", 1, 0, 0, 0, 0},
        },
        tbUnLockEvent = 
        {   
            {"OpenDynamicObstacle", "ops2"},
            {"BlackMsg", "我们得赶紧离开这个地方"}, 
            {"SetFubenProgress", -1, "继续前进"},             
            {"SetTargetPos", 7800, 6200},
        },
    }, 
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock3", 6},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [7] = {nTime = 0, nNum = 5,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败敌人"}, 

            --刷怪
            {"AddNpc", 1, 3, 7, "guaiwu3", "Fuben_3_guaiwu_3", 1, 0, 0, 0, 0},
            {"AddNpc", 2, 2, 7, "guaiwu4", "Fuben_3_guaiwu_3", 1, 0, 0, 0, 0},

            {"BlackMsg", "可恶！没想到追兵已经追到了这里！"},    

            --赵丽颖           
            --{"AddNpc", 3, 1, 0, "Npc", "ZhaoLiYin", 1, 0, 0, 0, 0},
        },
        tbUnLockEvent = 
        {   
            {"OpenDynamicObstacle", "ops3"},
            {"BlackMsg", "此处太过危险，我们不能多加停留"}, 
            {"SetFubenProgress", -1, "继续前进"},              
            {"SetTargetPos", 9500, 9700},
        },
    }, 
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {7},
        tbStartEvent = 
        {
            {"TrapUnlock", "TrapLock4", 8},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [9] = {nTime = 0, nNum = 24,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败敌人"}, 

            --刷怪
            {"AddNpc", 6, 24, 9, "guaiwu6", "Fuben_3_guaiwu_4", 1, 0, 0, 0, 0},
            --刷怪
            {"AddNpc", 3, 1, 50, "shizhu", "Fuben_3_shizhu", 0, 0, 0, 0, 0},

            {"NpcBubbleTalk", "shizhu", "开启我！只要你原意牺牲自己！你就能消灭你的敌人！", 5, 1, 2}, 

            {"StartTimeCycle", "cycle_1", 3, 1, {"PlayerBubbleTalk", "传说中的绝情石龙柱！据闻开启後杀敌一千，自损八百！是同归於尽的机关"}},

            {"StartTimeCycle", "cycle_1", 3, 1, {"BlackMsg", "该怎麽办？是否要牺牲自己，救下自己的伴侣？"}}, 

            {"BlackMsg", "想不到他们竟然追到了这里！"},    
        },
        tbUnLockEvent = 
        {   


        },
    }, 
    --专门用来放技能秒杀怪，可以不解锁不影响正常流程，9号锁用
    [50] = {nTime = 0, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"DelNpc", "shizhu"},

            {"CastSkill", "Kill_guaiwu", 3111, 10, -1, -1},
            {"CastSkill", "Kill_player", 2499, 10, -1, -1},
            --{"UseSkill", "Kill_player", 181, 9511, 9730},  
        },
    },   
    [10] = {nTime = 0, nNum = 24,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败敌人"}, 

            --刷怪
            {"AddNpc", 6, 24, 10, "guaiwu6", "Fuben_3_guaiwu_4", 1, 0, 0, 0, 0},

            {"AddNpc", 3, 1, 51, "shizhu", "Fuben_3_shizhu", 0, 0, 0, 0, 0},

            {"NpcBubbleTalk", "shizhu", "来吧！你离胜利已经很接近了…开启我…", 5, 1, 2}, 

            {"StartTimeCycle", "cycle_1", 3, 1, {"PlayerBubbleTalk", "想不到竟有这麽多追兵…就算是死！我也一定要救你出去！"}},

            {"StartTimeCycle", "cycle_1", 3, 1, {"BlackMsg", "无论如何都得想办法救对方离开这里"}}, 

            {"BlackMsg", "可恶，敌人越来越多了，该怎麽办"},    
        },
        tbUnLockEvent = 
        {   


        },
    }, 
    --专门用来放技能秒杀怪，可以不解锁不影响正常流程，9号锁用
    [51] = {nTime = 0, nNum = 1,
        tbPrelock = {9},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"DelNpc", "shizhu"},

            {"CastSkill", "Kill_guaiwu", 3111, 10, -1, -1},
            {"CastSkill", "Kill_player", 2499, 10, -1, -1},
        },
    },   
    [11] = {nTime = 0, nNum = 24,
        tbPrelock = {10},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击败敌人"}, 

            --刷怪
            {"AddNpc", 6, 24, 11, "guaiwu6", "Fuben_3_guaiwu_4", 1, 0, 0, 0, 0},

            {"AddNpc", 3, 1, 52, "shizhu", "Fuben_3_shizhu", 0, 0, 0, 0, 0},

            {"NpcBubbleTalk", "shizhu", "来吧！你离胜利已经很接近了…开启我…", 5, 1, 2}, 

            {"StartTimeCycle", "cycle_1", 3, 1, {"PlayerBubbleTalk", "不行…我不能放弃…我一定要让你安全离开！"}},

            {"StartTimeCycle", "cycle_1", 3, 1, {"BlackMsg", "已经有些筋疲力尽了…凭藉着意志坚持下去…"}}, 

            {"BlackMsg", "若我无法陪你走完这段路，你定要好好活下去"},    
        },
        tbUnLockEvent = 
        {   


        },
    }, 
    --专门用来放技能秒杀怪，可以不解锁不影响正常流程，9号锁用
    [52] = {nTime = 0, nNum = 1,
        tbPrelock = {10},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"DelNpc", "shizhu"},

            {"CastSkill", "Kill_guaiwu", 3111, 10, -1, -1},
            {"CastSkill", "Kill_player", 2499, 10, -1, -1},
        },
    },  
    [12] = {nTime = 20, nNum = 0,
        tbPrelock = {11},
        tbStartEvent = 
        {
            {"AddNpc", 7, 1, 52, "shizhu1", "Fuben_3_shizhu", 0, 0, 0, 0, 0},

            {"NpcBubbleTalk", "shizhu1", "想不到竟真的有人愿意为了对方牺牲自己，很好…很好…", 5, 3, 2}, 

            {"NpcBubbleTalk", "shizhu1", "你们的真情令我感动，难怪世人常说只羡鸳鸯不羡仙", 5, 10, 2},             

        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "离开问情谷"}, 

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