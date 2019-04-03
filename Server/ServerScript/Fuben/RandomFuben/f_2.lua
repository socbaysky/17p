
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("f_2");

tbFubenSetting.tbMultiBeginPoint = {{5578, 723},{5900, 720},{5562, 976},{5889, 991}}  
tbFubenSetting.tbTempRevivePoint = {5738, 843};
tbFubenSetting.nStartDir		 = 2;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1795, nLevel = -1, nSeries = -1}, --召唤NPC1
	[2] = {nTemplate = 1796, nLevel = -1, nSeries = -1}, --召唤NPC2
	[3] = {nTemplate = 1797, nLevel = -1, nSeries = -1}, --召唤NPC3
	[4] = {nTemplate = 1798, nLevel = -1, nSeries = -1}, --秋依水
	[5] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[6] = {nTemplate = 74,   nLevel = -1, nSeries = 0},  --上升气流
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
			{"AddNpc", 5, 2, 0, "wall", "wall_1_1",false, 16},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第六层 雪山之巅"},
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
			{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"AddNpc", 6, 1, 1, "Qinggong", "RandomFuben6_2_qinggong", false},
			{"SetTargetPos", 5674, 1358},
			{"ChangeTrap", "Jump1", nil, {5737, 1734}},
			{"ChangeTrap", "Jump2", nil, {5501, 1942}},	
			{"ChangeTrap", "Jump3", nil, {5445, 2321}},	
			{"ChangeTrap", "Jump4", nil, {4796, 2389}},	
		},
	},
	[100] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump1", 100},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[101] = {nTime = 0, nNum = 1,
		tbPrelock = {100},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump4", 101},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 4191, 3235},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 3},

			--秋依水
			{"AddNpc", 4, 1, 4, "BOSS", "RandomFuben6_2_BOSS", false, 0, 0, 0, 0},	
			{"NpcHpUnlock", "BOSS", 30, 80},  
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetHeadVisiable", "BOSS", false, 1},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "击败秋依水"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "没想到竟会在此处遇到你们，那就让我们来切磋一番吧！！", 4, 1, 1},
		},
	},
------------------------------------流程阶段------------------------------
----------------------阶段1---------------------------	
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "没想到各位武艺竟如此高强，既然如此那小女子也要认真了！！", 4, 1, 1},
			{"NpcHpUnlock", "BOSS", 40, 40},

			--召唤NPC
			{"AddNpc", 2, 3, 50, "guaiwu", "RandomFuben6_2_guaiwu1", false, 0, 0, 9005, 0.5},	
		},
	},
	[31] = {nTime = 2, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "秋依水[FFFE0D]召集援手助阵[-]，请各位侠士小心应对！！"},
		},
	},
	[32] = {nTime = 5, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "提示：请不要将助阵的援手全部击杀！"},
		},
	},
----------------------阶段2---------------------------	
	[40] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 52}, 
			{"NpcBubbleTalk", "BOSS", "真是没想到... 你们竟会如此棘手！！", 4, 1, 1},

			--召唤NPC
			{"AddNpc", 1, 1, 51, "guaiwu", "RandomFuben6_2_guaiwu2", false, 0, 0, 9005, 0.5},	
			{"AddNpc", 3, 2, 51, "guaiwu", "RandomFuben6_2_guaiwu3", false, 0, 0, 9005, 0.5},	
		},
	},
	[41] = {nTime = 2, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "秋依水[FFFE0D]召集援手助阵[-]，请各位侠士小心应对！！"},
		},
	},
	[42] = {nTime = 5, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "提示：请不要将助阵的援手全部击杀！"},
		},
	},
-----------------召唤怪物被杀后的处理锁----------------------
	[50] = {nTime = 0, nNum = 3,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[51] = {nTime = 0, nNum = 3,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[52] = {nTime = 0.1, nNum = 0,
		tbPrelock = {{50, 51}},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "没想到助阵的援手竟被你们全部击败了！但你们也不要太得意了，尝尝这招的厉害吧！！", 4, 1, 1},

			{"BlackMsg", "秋依水释放秘术，各位侠士请小心应对！！"},

			--BOSS狂暴
			{"NpcAddBuff", "BOSS", 2405, 1, 30},
			{"NpcAddBuff", "BOSS", 1690, 7, 30},
		},
	},
	[53] = {nTime = 0.1, nNum = 0,
		tbPrelock = {50, 51},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "没想到助阵的援手竟被你们全部击败了！但你们也不要太得意了，尝尝这招的厉害吧！！", 4, 1, 1},
			
			{"BlackMsg", "秋依水释放秘术，各位侠士请小心应对！！"},
			--BOSS狂暴
			{"NpcAddBuff", "BOSS", 2405, 1, 30},
			{"NpcAddBuff", "BOSS", 1690, 7, 30},
		},
	},
	-------------胜利判定------------------------
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败秋依水"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"AddSimpleNpc", 1611, 3537, 3944, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	-------------闯关时间------------------------
	[5] = {nTime = "f_2_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 5},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闯关失败"},
			{"BlackMsg", "秋依水武艺高强，还是先撤退为妙！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 2",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "f_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

