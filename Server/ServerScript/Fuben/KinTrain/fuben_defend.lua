Require("ServerScript/Fuben/KinTrain/KinTrainMgr.lua")

local tbFubenSetting = {};
local nMapTemplateId = Fuben.KinTrainMgr.MAP_TID_DEFEND
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = "KinTrainBase_Defend";                      -- 副本类型
tbFubenSetting.szName         = Fuben.KinTrainMgr.ACTIVITY_NAME         -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile = "Setting/Fuben/KinTrail/NpcPos_Defend.tab"  -- NPC点

tbFubenSetting.nS1BossEffectId = 9125
tbFubenSetting.szS1BossNotifyMsg = "金军三雄一条心，单破我一路是无法击退我们的！"
tbFubenSetting.nMatBossLockId = 200


--{"OpenDynamicObstacle", "ops1"},开障碍

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    NpcIndex3       = {23, 13, 3},--金军斥候
    NpcIndex4       = {24, 14, 4},--机关战车（冲刺）
    NpcIndex5       = {25, 15, 5},--铜锤蛮士
    NpcIndex6       = {26, 16, 6},--反弹卫士
    NpcIndex7       = {27, 17, 7},--蒙面杀手（无形蛊）
    NpcIndex8       = {28, 18, 8},--金军斥候·精英
    NpcIndex9       = {29, 19, 9},--火炮
    NpcIndex10      = {46, 43, 40},--大雄
    NpcIndex11      = {47, 44, 41},--二雄
    NpcIndex12      = {48, 45, 42},--三雄
    NpcIndex13      = {82, 81, 80},--金军士兵（劫车）

    NpcNum1         = {1, 1},---障碍墙
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 104,  nLevel = -1, nSeries = -1},---障碍墙
    [2] = {nTemplate = 1189,  nLevel = -1, nSeries = -1},--旗帜
    [3] = {nTemplate = 1190,  nLevel = -1, nSeries = -1},--金军斥候
    [4] = {nTemplate = 1254,  nLevel = -1, nSeries = -1},--机关战车（冲刺）
    [5] = {nTemplate = 1255,  nLevel = -1, nSeries = -1},--铜锤蛮士
    [6] = {nTemplate = 1256,  nLevel = -1, nSeries = -1},--反弹卫士
    [7] = {nTemplate = 1257,  nLevel = -1, nSeries = -1},--蒙面杀手（无形蛊）
    [8] = {nTemplate = 1259,  nLevel = -1, nSeries = -1},--金军斥候·精英
    [9] = {nTemplate = 1260,  nLevel = -1, nSeries = -1},--火炮
    [10] = {nTemplate = 1258,  nLevel = -1, nSeries = -1},--宝箱

    [13] = {nTemplate = 1290,  nLevel = -1, nSeries = -1},--金军斥候--弱
    [14] = {nTemplate = 1291,  nLevel = -1, nSeries = -1},--机关战车（冲刺）--弱
    [15] = {nTemplate = 1292,  nLevel = -1, nSeries = -1},--铜锤蛮士--弱
    [16] = {nTemplate = 1293,  nLevel = -1, nSeries = -1},--反弹卫士--弱
    [17] = {nTemplate = 1294,  nLevel = -1, nSeries = -1},--蒙面杀手（无形蛊）--弱
    [18] = {nTemplate = 1295,  nLevel = -1, nSeries = -1},--金军斥候·精英--弱
    [19] = {nTemplate = 1296,  nLevel = -1, nSeries = -1},--火炮--弱

    [23] = {nTemplate = 1297,  nLevel = -1, nSeries = -1},--金军斥候--弱弱
    [24] = {nTemplate = 1298,  nLevel = -1, nSeries = -1},--机关战车（冲刺）--弱弱
    [25] = {nTemplate = 1299,  nLevel = -1, nSeries = -1},--铜锤蛮士--弱弱
    [26] = {nTemplate = 1300,  nLevel = -1, nSeries = -1},--反弹卫士--弱弱
    [27] = {nTemplate = 1301,  nLevel = -1, nSeries = -1},--蒙面杀手（无形蛊）--弱弱
    [28] = {nTemplate = 1302,  nLevel = -1, nSeries = -1},--金军斥候·精英--弱弱
    [29] = {nTemplate = 1303,  nLevel = -1, nSeries = -1},--火炮--弱弱


    [40] = {nTemplate = 2753,  nLevel = -1, nSeries = 0},--大雄
    [41] = {nTemplate = 2754,  nLevel = -1, nSeries = 0},--二雄
    [42] = {nTemplate = 2755,  nLevel = -1, nSeries = 0},--三雄

    [43] = {nTemplate = 2756,  nLevel = -1, nSeries = 0},--大雄--弱
    [44] = {nTemplate = 2757,  nLevel = -1, nSeries = 0},--二雄--弱
    [45] = {nTemplate = 2758,  nLevel = -1, nSeries = 0},--三雄--弱

    [46] = {nTemplate = 2759,  nLevel = -1, nSeries = 0},--大雄--弱弱
    [47] = {nTemplate = 2760,  nLevel = -1, nSeries = 0},--二雄--弱弱
    [48] = {nTemplate = 2761,  nLevel = -1, nSeries = 0},--三雄--弱弱

    [60] = {nTemplate = 2762,  nLevel = -1, nSeries = 0},--日耀龙柱
    [61] = {nTemplate = 2763,  nLevel = -1, nSeries = 0},--月华龙柱
    [62] = {nTemplate = 2764,  nLevel = -1, nSeries = 0},--星辉龙柱

    [70] = {nTemplate = 2765,  nLevel = -1, nSeries = 0},--宋军指挥官
    [71] = {nTemplate = 2772,  nLevel = -1, nSeries = 0},--城墙
    [72] = {nTemplate = 2773,  nLevel = -1, nSeries = 0},--旗（金军据点）

    [80] = {nTemplate = 2780,  nLevel = -1, nSeries = -1},--金军士兵（劫车，没有古铜币奖励）
    [81] = {nTemplate = 2781,  nLevel = -1, nSeries = -1},--金军士兵（劫车，没有古铜币奖励）弱
    [82] = {nTemplate = 2782,  nLevel = -1, nSeries = -1},--金军士兵（劫车，没有古铜币奖励）弱弱
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

    [2] = {nTime = 1, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
        --准备阶段
        {"SetFubenProgress", -1, "等待试炼开启"},

        --起始的障碍npc
        {"AddNpc", 1, 1, nil, "Gate_go", "Gate_go1", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "Gate_go", "Gate_go2", false, 0, 0, 0, 0},

        --将玩家分割成3路进行
        {"AddNpc", 1, 1, nil, "store", "store_47_1", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_2", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_3", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_4", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_5", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_6", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_7", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_8", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_9", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_10", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_11", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_12", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_13", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_14", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_15", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_16", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_17", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_47_18", false, 47, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_1", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_2", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_3", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_4", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_5", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_6", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_7", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_8", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_9", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_10", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_11", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_12", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_13", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_14", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_15", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_16", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_17", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_18", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_19", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_20", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_21", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_22", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_23", false, 0, 0, 0, 0},
        {"AddNpc", 1, 1, nil, "store", "store_0_24", false, 0, 0, 0, 0},
        --添加龙柱
        {"AddNpc", 60, 1, nil, "Longzhu", "Longzhu_sun", false, 0, nil, nil, nil},
        {"AddNpc", 61, 1, nil, "Longzhu", "Longzhu_moon", false, 0, nil, nil, nil},
        {"AddNpc", 62, 1, nil, "Longzhu", "Longzhu_star", false, 0, nil, nil, nil},
        --添加城门
        {"AddNpc", 71, 1, nil, "Gate", "GateR", false, 48, nil, nil, nil},
        {"AddNpc", 71, 1, nil, "Gate", "GateD", false, 48, nil, nil, nil},
        {"AddNpc", 71, 1, nil, "Gate", "GateL", false, 48, nil, nil, nil},

        --旗（金军据点）
        {"AddNpc", 72, 1, nil, "soldier_pos", "soldier_pos_r", false, 48, nil, nil, nil},
        {"AddNpc", 72, 1, nil, "soldier_pos", "soldier_pos_d", false, 48, nil, nil, nil},
        {"AddNpc", 72, 1, nil, "soldier_pos", "soldier_pos_l", false, 48, nil, nil, nil},

        --添加宋军指挥官
        {"AddNpc", 70, 1, nil, "shibing_dh", "shibing_dh", false, 23, nil, nil, nil},
        {"NpcBubbleTalk", "shibing_dh", "金军三雄击破一路後，需[FFFE0D]10秒[-]内击破另外两路，切记切记……", 8, 12},

        },
        tbUnLockEvent = 
        {
        },
    },

    [100] = {nTime = 99999, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {},
        tbUnLockEvent = 
        {},
    },

    [3] = {nTime = 1, nNum = 0,
        tbPrelock = {100},
        tbStartEvent = 
        {
            --删除动态障碍NPC
            {"DoDeath", "Gate_go"},
        },
        tbUnLockEvent = 
        {
            --打开动态障碍
            {"OpenDynamicObstacle", "gate_go"},
            {"BlackMsg", "金军大肆来犯，请诸位侠士击退金军保卫襄阳城！"},
        },
    },

    --第一阶段：三路先锋
    [6] = {nTime = 8, nNum = 0,
        tbPrelock = {100},
        tbStartEvent = 
        {
            {"SetFubenProgress", -1, "击退金军三雄"},
            {"AddNpc", "NpcIndex10", 1, 8, "daxiong", "Captain_daxiong", false, 0, 0, 0, 0, 1},
            {"AddNpc", "NpcIndex11", 1, 8, "erxiong", "Captain_erxiong", false, 0, 0, 0, 0, 2},
            {"AddNpc", "NpcIndex12", 1, 8, "sanxiong", "Captain_sanxiong", false, 0, 0, 0, 0, 3},

            --小怪：30%的概率掉落1个古铜币
            {"AddNpc", "NpcIndex3", 6, 7, "enemy", "erxiong_enemy", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 7, "enemy", "daxiong_enemy", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 7, "enemy", "sanxiong_enemy", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "daxiong", tbFubenSetting.szS1BossNotifyMsg, 8, 12},
            {"NpcBubbleTalk", "erxiong", tbFubenSetting.szS1BossNotifyMsg, 8, 12},
            {"NpcBubbleTalk", "sanxiong", tbFubenSetting.szS1BossNotifyMsg, 8, 12},
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "金军三雄兄弟同心，击破一路後需10秒内击破另两路"},
        },
    },

    --第一阶段，小怪被击杀后，再刷一波
    [7] = {nTime = 0, nNum = 18,
        tbPrelock = {6},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            --小怪：30%的概率掉落1个古铜币
            {"AddNpc", "NpcIndex3", 6, nil, "enemy", "erxiong_enemy", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, nil, "enemy", "daxiong_enemy", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, nil, "enemy", "sanxiong_enemy", false, 0, 0, 0, 0},

            --小怪：50%的概率掉落1个古铜币
            {"AddNpc", "NpcIndex4", 3, nil, "enemy", "erxiong_enemy", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex4", 3, nil, "enemy", "daxiong_enemy", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex4", 3, nil, "enemy", "sanxiong_enemy", false, 0, 0, 0, 0},

            {"BlackMsg", "更多金军来袭！"},
        },
    },

    --第二阶段：城外金军
    [8] = {nTime = 0, nNum = 3,
        tbPrelock = {6},
        tbStartEvent = 
        {
        
        },
        tbUnLockEvent = 
        {
            --打开障碍
            {"DelNpc", "enemy"},
            {"DoDeath", "Gate"},
            {"OpenDynamicObstacle", "gate_r"},
            {"OpenDynamicObstacle", "gate_d"},
            {"OpenDynamicObstacle", "gate_l"},

            {"SetFubenProgress", -1, "击退城外金军1/5"},

            {"AddNpc", "NpcIndex3", 6, 9, "soldier1", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 9, "soldier2", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 9, "soldier3", "soldier_l", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "soldier1", "先锋将军竟然败了？拦住他们……", 8, 12, 1},
            {"NpcBubbleTalk", "soldier2", "先锋将军竟然败了？拦住他们……", 8, 12, 1},
            {"NpcBubbleTalk", "soldier3", "先锋将军竟然败了？拦住他们……", 8, 12, 1},
        },
    },

    [9] = {nTime = 0, nNum = 18,
        tbPrelock = {8},
        tbStartEvent = 
        {
        
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "击退城外金军2/5"},

            {"AddNpc", "NpcIndex4", 3, 10, "soldier", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex4", 3, 10, "soldier", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex4", 3, 10, "soldier", "soldier_l", false, 0, 0, 0, 0},
            
            {"AddNpc", "NpcIndex8", 2, 10, "soldier1", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex8", 2, 10, "soldier2", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex8", 2, 10, "soldier3", "soldier_l", false, 0, 0, 0, 0},


            {"NpcBubbleTalk", "soldier1", "今我大军压境，势必拿下襄阳城！", 8, 1, 1},
            {"NpcBubbleTalk", "soldier2", "今我大军压境，势必拿下襄阳城！", 8, 1, 1},
            {"NpcBubbleTalk", "soldier3", "今我大军压境，势必拿下襄阳城！", 8, 1, 1},
        },
    },

    [10] = {nTime = 0, nNum = 15,
        tbPrelock = {9},
        tbStartEvent = 
        {
        
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "击退城外金军3/5"},

            {"AddNpc", "NpcIndex5", 4, 11, "soldier1", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex5", 4, 11, "soldier2", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex5", 4, 11, "soldier3", "soldier_l", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "soldier1", "吃我一锤！", 8, 1, 1},
            {"NpcBubbleTalk", "soldier2", "吃我一锤！", 8, 1, 1},
            {"NpcBubbleTalk", "soldier3", "吃我一锤！", 8, 1, 1},
        },
    },

    [11] = {nTime = 0, nNum = 12,
        tbPrelock = {10},
        tbStartEvent = 
        {
        
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "击退城外金军4/5"},

            {"AddNpc", "NpcIndex3", 6, 12, "soldier", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 12, "soldier", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 12, "soldier", "soldier_l", false, 0, 0, 0, 0},

            {"AddNpc", "NpcIndex6", 2, 12, "soldier1", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex6", 2, 12, "soldier2", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex6", 2, 12, "soldier3", "soldier_l", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "soldier1", "试试我的软蝟甲！", 8, 1, 1},
            {"NpcBubbleTalk", "soldier2", "试试我的软蝟甲！", 8, 1, 1},
            {"NpcBubbleTalk", "soldier3", "试试我的软蝟甲！", 8, 1, 1},
        },
    },

    [12] = {nTime = 0, nNum = 24,
        tbPrelock = {11},
        tbStartEvent = 
        {
        
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "击退城外金军5/5"},

            {"AddNpc", "NpcIndex3", 6, 13, "soldier", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 13, "soldier", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex3", 6, 13, "soldier", "soldier_l", false, 0, 0, 0, 0},

            {"AddNpc", "NpcIndex9", 1, 13, "soldier1", "soldier_r", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex9", 1, 13, "soldier2", "soldier_d", false, 0, 0, 0, 0},
            {"AddNpc", "NpcIndex9", 1, 13, "soldier3", "soldier_l", false, 0, 0, 0, 0},
        },
    },


    --第三阶段：收集物资，只负责开锁
    [13] = {nTime = 0, nNum = 21,
        tbPrelock = {8},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "收集军资"},
            --GO指引
            {"SetTargetPos", 9177,8930},
            {"BlackMsg", "进入金军後营，收集军资"},
            {"RaiseEvent", "S3Begin"},
        },
    },

    --第三阶段，每间隔30秒刷一波怪劫车，共5波
    [14] = {nTime = 30, nNum = 0,
        tbPrelock = {13},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "AddAttackMaterialNpc", {{"AddNpc", "NpcIndex13", 6, nil, "car_enemy", "car_enemy", false, 0, 0, 0, 0},
                                      {"NpcBubbleTalk", "car_enemy", "嘿嘿！弟兄们，劫下这批军资……", 8, 1, 1},
                                      {"BlackMsg", "金军突袭军资车，请诸位侠士击退他们！"},
                                     }
            },
        },
    },

    [15] = {nTime = 30, nNum = 0,
        tbPrelock = {14},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "AddAttackMaterialNpc", {{"AddNpc", "NpcIndex13", 6, nil, "car_enemy", "car_enemy", false, 0, 0, 0, 0},
                                      {"NpcBubbleTalk", "car_enemy", "嘿嘿！弟兄们，劫下这批军资……", 8, 1, 1},
                                      {"BlackMsg", "金军突袭军资车，请诸位侠士击退他们！"},
                                     }
            },
        },
    },

    [16] = {nTime = 30, nNum = 0,
        tbPrelock = {15},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "AddAttackMaterialNpc", {{"AddNpc", "NpcIndex13", 6, nil, "car_enemy", "car_enemy", false, 0, 0, 0, 0},
                                      {"NpcBubbleTalk", "car_enemy", "嘿嘿！弟兄们，劫下这批军资……", 8, 1, 1},
                                      {"BlackMsg", "金军突袭军资车，请诸位侠士击退他们！"},
                                     }
            },
        },
    },

    [17] = {nTime = 30, nNum = 0,
        tbPrelock = {16},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "AddAttackMaterialNpc", {{"AddNpc", "NpcIndex13", 6, nil, "car_enemy", "car_enemy", false, 0, 0, 0, 0},
                                      {"NpcBubbleTalk", "car_enemy", "嘿嘿！弟兄们，劫下这批军资……", 8, 1, 1},
                                      {"BlackMsg", "金军突袭军资车，请诸位侠士击退他们！"},
                                     }
            },
        },
    },

    [18] = {nTime = 30, nNum = 0,
        tbPrelock = {17},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "AddAttackMaterialNpc", {{"AddNpc", "NpcIndex13", 6, nil, "car_enemy", "car_enemy", false, 0, 0, 0, 0},
                                      {"NpcBubbleTalk", "car_enemy", "嘿嘿！弟兄们，劫下这批军资……", 8, 1, 1},
                                      {"BlackMsg", "金军突袭军资车，请诸位侠士击退他们！"},
                                     }
            },
        },
    },

    --最后一阶段，刷小兵
    [200] = {nTime = 99999, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "回防襄阳"},
        },
    },
    [201] = {nTime = 10, nNum = 0,
        tbPrelock = {200},
        tbStartEvent = 
        {
                
        },
        tbUnLockEvent = 
        {
            --GO指引
            {"SetTargetPos", 15159,8238},
            {"AddNpc", "NpcIndex3", 6, nil, "enemy", "daxiong_enemy", false, 0, 0, 0, 0},
            {"BlackMsg", "金军大将亲率精兵偷袭襄阳城……"},
        },
    },
}