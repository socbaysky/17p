
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_7");

tbFubenSetting.tbMultiBeginPoint = {{2447, 3344},{2685, 3044},{2135, 3062},{2382, 2836}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2413, 3084}
tbFubenSetting.nStartDir		 = 11;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1367, nLevel = -1, nSeries = -1}, --藏剑弟子
	[2] = {nTemplate = 1368, nLevel = -1, nSeries = -1}, --藏剑精英
	[3] = {nTemplate = 1369, nLevel = -1, nSeries = -1}, --神射手
	[4] = {nTemplate = 1370, nLevel = -1, nSeries = -1}, --喷射机关
	[5] = {nTemplate = 1371, nLevel = -1, nSeries = -1}, --火焰
	[6] = {nTemplate = 569,	nLevel = -1, nSeries = -1}, --卓非凡（展示NPC）
	[7] = {nTemplate = 1372, nLevel = -1, nSeries = -1}, --卓非凡
	[8] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙

	[9] = {nTemplate = 1822,  nLevel = -1, nSeries = 0},  --卡片收集
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
			{"AddNpc", 8, 2, 1, "wall_1", "wall_1_1",false, 26},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四层 熔岩密洞"},
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
			{"ShowTaskDialog", 10003, false},
			{"DoDeath", "wall_1"},
			{"OpenDynamicObstacle", "ops1"},
			{"AddNpc", 8, 2, 1, "wall_2", "wall_1_2",false, 25},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 3660, 3666},

			--藏剑弟子
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben4_7_1",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},			
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben4_7_2",false, 0, 2, 9005, 0.5},
			{"AddNpc", 2, 1, 4, "Elite", "RandomFuben4_7_Elite1",false, 0, 1, 9011, 1},
			{"SetFubenProgress", 20, "击败藏剑弟子"},
			{"NpcBubbleTalk", "guaiwu", "来者何人，这熔洞已经被我们承包了，闲杂人等赶紧滚出去！", 4, 1, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "探索凌绝峰"},
			{"SetTargetPos", 6012, 6584},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},

			--卓非凡（非战斗NPC） & 藏剑弟子
			{"AddNpc", 6, 1, 0, "Temporary", "RandomFuben4_7_Temporary",false, 41, 0, 0, 0},
			{"AddNpc", 1, 6, 6, "guaiwu", "RandomFuben4_7_3",false, 41, 0, 0, 0},
			{"AddNpc", 2, 1, 6, "Elite", "RandomFuben4_7_Elite2",false, 0, 0, 0, 0},
			{"SetNpcProtected", "Temporary", 1},
			{"SetAiActive", "guaiwu", 0},
			{"ChangeNpcFightState", "Temporary", 0, 1},
			{"SetNpcBloodVisable", "Temporary", false, 1},	
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 5},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 40, "击败藏剑弟子"},
			{"NpcBubbleTalk", "guaiwu", "哪里来的家伙，大夥将他们擒下！", 4, 1, 1},
			{"NpcBubbleTalk", "Temporary", "可恶，又是你们！！！藏剑弟子给我拿下他们！", 4, 0, 1},
			{"SetAiActive", "guaiwu", 1},
		},
	},

	[6] = {nTime = 0, nNum = 7,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "跟随卓非凡"},
			{"SetTargetPos", 4561, 4538},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
			{"NpcBubbleTalk", "Temporary", "哼，倒还有两下子！这里地方太施展不开，去前方决战吧！", 4, 0, 1},
			{"ChangeNpcAi", "Temporary", "Move", "Path1", 7, 1, 1, 0},
			{"NpcAddBuff", "Temporary", 2452, 2, 100},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"DelNpc", "Temporary"},
			{"SetFubenProgress", 80, "击败卓非凡"},

			--卓非凡
			{"AddNpc", 7, 1, 9, "BOSS", "RandomFuben4_7_BOSS",false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "BOSS", "哼，此处就是你们的葬身之地！！", 4, 1, 1},
			{"NpcHpUnlock", "BOSS", 8, 80},	
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			--喷射机关
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame1",false, 26, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame2",false, 42, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame3",false, 40, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame4",false, 53, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame5",false, 54, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame6",false, 2, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame7",false, 9, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Flam", "RandomFuben4_7_Flame8",false, 22, 0, 0, 0},

			{"NpcBubbleTalk", "BOSS", "不要以为就这麽结束了，来尝尝我火龙阵的威力吧！！", 4, 1, 1},
		},
	},

-------------胜利判定------------------------
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败卓非凡"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------

	[10] = {nTime = "d_7_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 10},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "此地危险重重，不宜久留！"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

---------------卡片收集----------------
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"RaiseEvent", "CheckCollectionAct", {"UnLock", 20}},
		},
		tbUnLockEvent = 
		{
			{"Random", {250000, 21}},
		},
	},
	[21] = {nTime = 0.2, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 9, 1, 0, "Card", "RandomFuben4_7_Temporary",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "卓非凡好像留下了什麽东西在地上！！"},
		},
	},

}

