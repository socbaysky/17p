
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("c_10");

tbFubenSetting.tbMultiBeginPoint = {{5089, 4017},{5346, 4020},{5104, 3803},{5361, 3806}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5226, 3905}
tbFubenSetting.nStartDir		 = 46;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1575, nLevel = -1, nSeries = -1}, --月眉儿
	[2] = {nTemplate = 1616, nLevel = -1, nSeries = -1}, --杨影枫
	[3] = {nTemplate = 1617, nLevel = -1, nSeries = 0},  --冰冻NPC
	[4] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1719, nLevel = -1, nSeries = 0},  --隐藏NPC
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
			--设置同步范围
			{"SetNearbyRange", 3},

			{"SetFubenProgress", -1,"等待秘境开启"},
			{"AddNpc", 4, 1, 1, "wall", "wall_1_1",false, 33},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第三层 山腰小路"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"ShowTaskDialog", 10002, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 3546, 3159},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌绝峰"},

			--月眉儿 & 杨影枫
			{"AddNpc", 1, 1, 6, "BOSS", "RandomFuben3_10_BOSS", false, 58, 0, 0, 0},	
			{"AddNpc", 2, 1, 0, "NPC", "RandomFuben3_10_Yangyingfeng", false, 26, 0, 0, 0},
			{"SetNpcProtected", "BOSS", 1},
			{"SetNpcProtected", "NPC", 1},
			{"UseSkill", "NPC", 1535, -1, -1},
			{"SetAiActive", "BOSS", 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "BOSS", "杨影枫，今日....  就让我们来做个了断吧！！！", 3, 0, 1},
			{"NpcBubbleTalk", "NPC", "月眉儿，当日之事确是我爹咄咄逼人，只是....", 3, 1, 1},
			{"NpcBubbleTalk", "BOSS", "杨影枫...... 不必多言，今日我们只有一人能离开这里！你拔剑吧！！", 3, 3, 1},
			{"NpcHpUnlock", "BOSS", 30, 70},
		},
	},
	[4] = {nTime = 4, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "击败月眉儿"},
			{"SetAiActive", "BOSS", 1},
			{"NpcBubbleTalk", "BOSS", "你们是什麽人，莫非是想阻止我报仇不成？？", 3, 0, 1},
			{"NpcBubbleTalk", "NPC", "先制服月眉儿让她冷静下来吧，我便来助各位一臂之力！！", 3, 5, 1},
			{"SetNpcProtected", "BOSS", 0},
			{"BlackMsg", "击败月眉儿，阻止两人之间的对决！！"},
		},
	},
	[5] = {nTime = 5, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UseSkill", "NPC", 1535, -1, -1},
			{"DoCommonAct", "NPC", 16, 0, 0, 0},
			{"BlackMsg", "杨影枫释放鼓舞光环，我方全体[FFFE0D]攻击力[-]提升！！"},
		},
	},



---------------------------------流程阶段--------------------------------------------
----------------阶段1---------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 40, 40},
			{"SetHeadVisiable", "NPC", false, 0},
		},
	},
	[31] = {nTime = 1, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "你们不要得意忘形了，试试这招吧！！！", 3, 0, 1},
			{"CastSkill", "BOSS", 346, 1, -1, -1},
			{"UseSkill", "NPC", 1535, -1, -1},

			--冰冻NPC & 隐藏NPC
			{"AddNpc", 3, 1, 0, "Ice1", "RandomFuben3_10_Yangyingfeng", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 33, "Hide1", "RandomFuben3_10_Yangyingfeng", false, 0, 0, 0, 0},
			{"DoCommonAct", "NPC", 1, 5006, 1, 0},
		},
	},
	[32] = {nTime = 1, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "杨影枫被冻结，将[FFFE0D]冰块击碎[-]解救杨影枫！"},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Ice1"},
			{"UseSkill", "NPC", 1535, -1, -1},
			{"DoCommonAct", "NPC", 16, 0, 0, 0},
			{"SetHeadVisiable", "NPC", true, 0},
			{"NpcBubbleTalk", "NPC", "总算是挣脱了，这滋味还真不好受！！", 3, 0, 1},
			{"CloseLock", 50}, 
		},
	},

	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UseSkill", "NPC", 1535, -1, -1},
		},
	},
----------------阶段2---------------------
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--删除上个阶段的NPC
			{"DelNpc", "Ice1"},
			{"DelNpc", "Hide1"},
			{"UseSkill", "NPC", 1535, -1, -1},

			{"UnLock", 50}, 

			{"SetHeadVisiable", "NPC", false, 0},
		},
	},
	[41] = {nTime = 1, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "你们不要得意忘形了，试试这招吧！！！", 3, 0, 1},
			{"CastSkill", "BOSS", 346, 1, -1, -1},

			--冰冻NPC & 隐藏NPC
			{"AddNpc", 3, 1, 0, "Ice2", "RandomFuben3_10_Yangyingfeng", false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 43, "Hide2", "RandomFuben3_10_Yangyingfeng", false, 0, 0, 0, 0},
			{"DoCommonAct", "NPC", 1, 5006, 1, 0},
		},
	},
	[42] = {nTime = 1, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "杨影枫被冻结，将[FFFE0D]冰块击碎[-]解救杨影枫！"},
		},
	},
	[43] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "Ice2"},
			{"UseSkill", "NPC", 1535, -1, -1},
			{"DoCommonAct", "NPC", 16, 0, 0, 0},
			{"SetHeadVisiable", "NPC", true, 0},
			{"NpcBubbleTalk", "NPC", "总算是挣脱了，这滋味还真不好受！！", 3, 0, 1},
		},
	},
-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败月眉儿"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_win"},
					
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间和积分------------------------
	[7] = {nTime = "c_10_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "c_score_lost"},
			
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

--------------卡片收集特殊掉落------------
	-- [100] = {nTime = 1, nNum = 0,
	-- 	tbPrelock = {33, 43},
	-- 	tbStartEvent = 
	-- 	{
	-- 		{"RaiseEvent", "DropCard", 2605, -1},
	-- 	},
	-- 	tbUnLockEvent = 
	-- 	{
	-- 	},
	-- },

}

