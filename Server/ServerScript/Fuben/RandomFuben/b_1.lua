
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_1");

tbFubenSetting.tbMultiBeginPoint = {{4654, 1856},{4421, 1667},{4587, 1473},{4815, 1613}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {4626, 1644};
tbFubenSetting.nStartDir		 = 49;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1548,  nLevel = -1, nSeries = -1}, --武林恶徒
	[2] = {nTemplate = 1549,  nLevel = -1, nSeries = -1}, --刺客
	[3] = {nTemplate = 1550,  nLevel = -1, nSeries = -1}, --刺客头目
	[4] = {nTemplate = 104,   nLevel = -1, nSeries = 0},  --动态障碍墙
	[5] = {nTemplate = 1551,  nLevel = -1, nSeries = 0},  --张仲天
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 40},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第二层 後山小道"},
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
			{"ShowTaskDialog", 10001, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 3755, 2091},

			--张仲天
			{"AddNpc", 5, 1, 10, "Zhangzhongtian", "RandomFuben2_1_zhangzhongtian",false, 46, 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 30, "保护张仲天"},
			{"BlackMsg", "前方似乎有人遇到了麻烦！"},

			--武林恶徒 & 刺客
			{"AddNpc", 1, 5, 4, "guaiwu", "RandomFuben2_1_1", false, 0, 0, 0, 0},
			{"AddNpc", 2, 4, 4, "guaiwu", "RandomFuben2_1_2", false, 0, 0, 0, 0},
			
			{"NpcBubbleTalk", "Zhangzhongtian", "可恶，你们究竟是什麽人！！", 4, 0, 1},
			{"NpcBubbleTalk", "guaiwu", "哈哈哈，下地府去问阎王爷吧！", 4, 2, 1},
		},
	},
	[4] = {nTime = 0, nNum = 9,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "护送张仲天"},
			{"NpcBubbleTalk", "Zhangzhongtian", "多谢各位施以援手，还请能护送在下一程！", 4, 1, 1},
			{"SetTargetPos", 2434, 3131},
			{"ChangeNpcAi", "Zhangzhongtian", "Move", "Path1", 1, 1, 0, 0, 0},
			{"OpenDynamicObstacle", "ops2"},
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
			{"SetTargetPos", 3630, 3479},
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
			{"SetTargetPos", 3497, 4421},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{			
			{"TrapUnlock", "TrapLock4", 7},			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "击退敌人"},
			{"NpcBubbleTalk", "Zhangzhongtian", "糟糕，看来是遇到这群人的头目了，大夥小心！", 4, 1, 1},
			{"NpcBubbleTalk", "BOSS", "张仲天，你已经无路可逃了！乖乖受死吧！", 4, 2, 1},

			--刺客头目 & 武林恶徒 & 刺客
			{"AddNpc", 2, 4, 8, "guaiwu", "RandomFuben2_1_3", false, 0, 0, 0, 0},
			{"AddNpc", 1, 5, 8, "guaiwu", "RandomFuben2_1_4", false, 0, 3, 0, 0},
			{"AddNpc", 3, 1, 8, "BOSS", "RandomFuben2_1_BOSS", false, 0, 0, 0, 0},
		},
	},
-------------胜利判定------------------------
	[8] = {nTime = 0, nNum = 10,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落首领奖励 ——  张仲天
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/zhangzhongtian.tab", 3166, 4336},	
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_B/zhangzhongtian.tab", 3200, 4400},	

			{"SetFubenProgress", 100, "击退敌人"},	

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[9] = {nTime = "b_1_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "这群刺客还真是厉害，还是赶紧离去为妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}