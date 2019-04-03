local tbFubenSetting = {};
local nMapTemplateId = Fuben.KinSecretMgr.Def.nMapTemplateId
Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szFubenClass   = "KinSecretFuben";                      -- 副本类型
tbFubenSetting.szNpcPointFile = "Setting/Fuben/KinSecretFuben/NpcPos.tab"  -- NPC点
tbFubenSetting.szPathFile = "Setting/Fuben/KinSecretFuben/NpcPath.tab"   -- 寻路点
tbFubenSetting.tbTempRevivePoint = {3041, 5707}                                           -- 临时复活点，副本内有效，出副本则移除

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
}

tbFubenSetting.ANIMATION = 
{
    [1] = "Scenes/camera/Main Camera.controller",
}

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2928, nLevel = -1, nSeries = 0}, ---南宫飞云
    [2] = {nTemplate = 2929, nLevel = -1, nSeries = 0}, ---杨影枫
    [3] = {nTemplate = 2930, nLevel = -1, nSeries = 0}, ---独孤剑
    [4] = {nTemplate = 2931, nLevel = -1, nSeries = 0}, ---张琳心
    [5] = {nTemplate = 2933, nLevel = -1, nSeries = 0}, ---巨大宝箱

    [20] = {nTemplate = 2919, nLevel = -1, nSeries = -1}, ---阵法：金
    [21] = {nTemplate = 2920, nLevel = -1, nSeries = -1}, ---阵法：木
    [22] = {nTemplate = 2921, nLevel = -1, nSeries = -1}, ---阵法：水
    [23] = {nTemplate = 2922, nLevel = -1, nSeries = -1}, ---阵法：火
    [24] = {nTemplate = 2923, nLevel = -1, nSeries = -1}, ---阵法：土

    [11] = {nTemplate = 73, nLevel = -1, nSeries = 0}, --传送门
    [100] = {nTemplate = 104, nLevel = -1, nSeries = 0}, --障碍门

    [1000] = {nTemplate = 2882, nLevel = -1, nSeries = 0}, --奖励宝箱
}

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 0, nNum = 0,
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
		  {"SetFubenProgress", -1, "等待开启"},
          {"SetKickoutPlayerDealyTime", 60},
          {"AddNpc", 100, 1, 0, "wall1", "wall_1", false, 32},
          {"AddNpc", 100, 2, 0, "wall2", "wall_2", false, 16},
          {"AddNpc", 100, 1, 0, "wall3", "wall_3", false, 32},
          {"AddNpc", 11, 1, 0, "Chuansong", "chuansong_1", false, 33},
          {"AddNpc", 11, 1, 0, "Chuansong", "chuansong_2", false, 33},
          {"AddNpc", 11, 1, 0, "Chuansong", "chuansong_3", false, 33},
        },
        tbUnLockEvent = 
        {
        },
    },
    [100] = {nTime = 99999, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"AddNpc", 1, 1, 31, "BOSS1", "boss1_1", false, 48, 0, 0, 0},
            {"SetTargetPos", 7301, 5855},
            {"SetFubenProgress", -1, "击败南宫飞云"},
            {"ChangeTrap", "trap1", {5702, 5709}, nil},
            {"RaiseEvent", "OpenTrap", "trap1"},
            {"TrapAddSkillState", "trap1", 3766, 1, 3, 0, 0, 9999}, 
        },
    },
	[4] = {nTime = 3, nNum = 0,
        tbPrelock = {100},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"StartTimeCycle", "cycle_1", 10, nil, {"RaiseEvent", "PickAOE", "BOSS1"}},
            {"ClearTargetPos"},
        },
    },
    [31] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "PassLevel", 1},
            {"CloseCycle", "cycle_1"},
            {"SetFubenProgress", -1, "休整阶段"},
        },
    },
    [5] = {nTime = 30, nNum = 0,
        tbPrelock = {31},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "击败杨影枫"},
            {"AddNpc", 2, 1, 41, "BOSS2", "boss2_1", false, 16, 0, 0, 0},

            {"AddNpc", 20, 1, 0, "fazhen", "fazhen_j", 0, 0, 0, 0, 0},
            {"AddNpc", 21, 1, 0, "fazhen", "fazhen_m", 0, 0, 0, 0, 0},
            {"AddNpc", 22, 1, 0, "fazhen", "fazhen_s", 0, 0, 0, 0, 0},
            {"AddNpc", 23, 1, 0, "fazhen", "fazhen_h", 0, 0, 0, 0, 0},
            {"AddNpc", 24, 1, 0, "fazhen", "fazhen_t", 0, 0, 0, 0, 0},

            {"ChangeTrap", "trap2", {7412, 9132}, nil},
            {"RaiseEvent", "OpenTrap", "trap2"},
            {"SetTargetPos", 6942, 10636},
            {"TrapAddSkillState", "trap2", 3766, 1, 3, 0, 0, 9999}, 
        },
    },
    [9] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [41] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "PassLevel", 2},
            {"DelNpc", "fazhen"},
            {"SetFubenProgress", -1, "休整阶段"},
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {41},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "击败独孤剑"},
            {"AddNpc", 3, 1, 0, "BOSS3A", "boss3_1", false, 16, 0, 0, 0},
            {"AddNpc", 4, 1, 0, "BOSS3B", "boss3_2", false, 16, 0, 0, 0},
            {"ChangeTrap", "trap3", {10854, 10012}, nil},
            {"RaiseEvent", "OpenTrap", "trap3"},
            {"SetTargetPos", 12130, 9828},
            {"TrapAddSkillState", "trap3", 3766, 1, 3, 0, 0, 9999}, 
        },
    },
    [7] = {nTime = 5, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"StartTimeCycle", "cycle_3a", 20, nil, {"RaiseEvent", "Pick2", "BOSS3A", true}}, 
            {"ClearTargetPos"},
        },
    }, 
    [8] = {nTime = 10, nNum = 0,
        tbPrelock = {7},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"StartTimeCycle", "cycle_3b", 20, nil, {"RaiseEvent", "Pick2", "BOSS3B", false}}, 
        },
    }, 
    [1000] = {nTime = 99999, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"CloseCycle", "cycle_3a"},
            {"CloseCycle", "cycle_3b"},
            {"RaiseEvent", "PassLevel", 3},
            {"DelNpc", "dushui"},
            {"AddNpc", 5, 1, 1001, "rewardbox", "box3", false, 48},
            {"BlackMsg", "闯关成功"},
            {"SetFubenProgress", -1, "开启宝箱"},
        },
    },
    [1001] = {nTime = 0, nNum = 1,
        tbPrelock = {1000},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            {"RaiseEvent", "SendReward"},
            {"SetFubenProgress", -1, "闯关成功"},
            {"GameWin"},
        },
    },
    [2000] = {nTime = 99999, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
             {"RaiseEvent", "SendReward"},
            {"GameWin"},
        },
    },
}