
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_6");

tbFubenSetting.tbMultiBeginPoint = {{4809, 2447},{5194, 2447},{4816, 2120},{5201, 2109}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5010, 2292}
tbFubenSetting.nStartDir		 = 1;

--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1362, nLevel = -1, nSeries = -1}, --宋兵
	[2] = {nTemplate = 1363, nLevel = -1, nSeries = -1}, --机关人控制器
	[3] = {nTemplate = 1364, nLevel = -1, nSeries = -1}, --刀盾兵
	[4] = {nTemplate = 1365, nLevel = -1, nSeries = -1}, --巡逻机关人
	[5] = {nTemplate = 1366, nLevel = -1, nSeries = -1}, --赵节
	[6] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙

	[7] = {nTemplate = 1821,  nLevel = -1, nSeries = 0},  --卡片收集
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
			{"AddNpc", 6, 2, 1, "wall_1", "wall_1_1",false, 16},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四层 机关密室"},
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
			{"AddNpc", 6, 1, 1, "wall_2", "wall_1_2",false, 32},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索机关密室"},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 20, "躲避巡逻机关人"},
			
			--关闭剧情对话
			{"CloseWindow", "SituationalDialogue"},
			{"PlayCameraEffect", 9119},	
			{"MoveCamera", 0, 1, 43.05, 14.79, 26.12, 35, 45, 0},
			{"SetAllUiVisiable", false}, 

			--巡逻机关人
			{"AddNpc", 4, 1, 0, "Xunluo1", "RandomFuben4_6_xunluo1",false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Xunluo1", "Move", "Path1", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "Xunluo1", 1884, 1, 150},

			--加定身BUFF
			{"AddBuff", 1058, 1, 8, 0, 0},

			--判断是否为普通模式
			{"IfCase", "not self.bElite", 
				{"PauseLock", 14},
			},

			--判断是否为噩梦模式
			{"IfCase", "self.bElite", 
				{"PauseLock", 13},
			},

			--加副本后台时间
			{"ChangeTime", -6},
		},
	},
	[4] = {nTime = 2, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"MoveCamera", 0, 3, 60.9, 14.79, 23.4, 35, 45, 0},
		},
	},
	[5] = {nTime = 4, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "前方出现巡逻机关人，不要被发现了！"},	
			{"PlayCameraEffect", 9119},	
			{"LeaveAnimationState", false},
			{"SetAllUiVisiable", true}, 

			--移除定身
			{"RemovePlayerSkillState", 1058},

			--判断是否为普通模式
			{"IfCase", "not self.bElite", 
				{"ResumeLock", 14},
				{"SetShowTime", 14},
			},

			--判断是否为噩梦模式
			{"IfCase", "self.bElite", 
				{"ResumeLock", 13},
				{"SetShowTime", 13},
			},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock2", 6},

			--宋兵 & 机关人控制器 & 射手						
			{"AddNpc", 1, 3, 7, "guaiwu1", "RandomFuben4_6_1",false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 7, "guaiwu", "RandomFuben4_6_jiguan1",false, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 7, "guaiwu", "RandomFuben4_6_2",false, 0, 3, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 40, "破坏机关装置"},
			{"BlackMsg", "看来这就是控制机关人的装置了，将它破坏掉！！"},	
			{"NpcBubbleTalk", "guaiwu1", "来者何人，这密室已经被我们承包了，闲杂人等赶紧滚出去！", 4, 1, 1},	
		},
	},
	[7] = {nTime = 0, nNum = 6,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "探索机关密室"},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
			{"DelNpc", "Xunluo1"},
			{"BlackMsg", "继续探索机关密室！"},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock5", 8},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 70, "躲避巡逻机关人"},
			{"BlackMsg", "前方出现巡逻机关人！请务必小心行事！"},

			--巡逻机关人
			{"AddNpc", 4, 1, 0, "Xunluo2", "RandomFuben4_6_xunluo2",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 0, "Xunluo3", "RandomFuben4_6_xunluo3",false, 0, 0, 0, 0},
			{"ChangeNpcAi", "Xunluo2", "Move", "Path2", 0, 1, 1, 0, 1},
			{"ChangeNpcAi", "Xunluo3", "Move", "Path3", 0, 1, 1, 0, 1},
			{"NpcAddBuff", "Xunluo2", 1884, 1, 150},
			{"NpcAddBuff", "Xunluo3", 1884, 1, 150},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 9},

			--宋兵 & 机关人控制器 & 射手						
			{"AddNpc", 1, 3, 10, "guaiwu1", "RandomFuben4_6_3",false, 0, 0, 0, 0},
			{"AddNpc", 2, 1, 10, "guaiwu", "RandomFuben4_6_jiguan2",false, 0, 0, 0, 0},
			{"AddNpc", 3, 2, 10, "guaiwu", "RandomFuben4_6_4",false, 0, 3, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 80, "破坏机关装置"},
			{"BlackMsg", "击败敌人，并破坏掉控制机关人的装置！！"},
			{"NpcBubbleTalk", "guaiwu1", "来者何人，这密室已经被我们承包了，闲杂人等赶紧滚出去！", 4, 1, 1},	
		},
	},
	[10] = {nTime = 0, nNum = 6,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "击败赵节"},
			{"DelNpc", "Xunluo2"},
			{"DelNpc", "Xunluo3"},
			{"SetTargetPos", 4337, 9285},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 11},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},

			--赵节
			{"AddNpc", 5, 1, 12, "BOSS", "RandomFuben4_6_BOSS",false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS", "何人敢造次，还不给本将速速领死！", 4, 3, 1},
		},
	},

-------------胜利判定------------------------
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败赵节"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------
	
	[13] = {nTime = "d_6_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 13},
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

----------------------卡片收集----------------
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"RaiseEvent", "CheckCollectionAct", {"UnLock", 15}},
		},
		tbUnLockEvent = 
		{
			{"Random", {250000, 16}},
		},
	},
	[16] = {nTime = 3, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"AddNpc", 7, 1, 0, "Card", "RandomFuben4_6_xunluo2",false, 0, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "好像听到什麽东西掉在地上的声音！！！"},
		},
	},

}

