
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("e_2");

tbFubenSetting.tbMultiBeginPoint = {{1392, 1213},{1632, 1122},{1351, 1007},{1585, 926}}
tbFubenSetting.tbTempRevivePoint = {1392, 1213};
tbFubenSetting.nStartDir		 = 3;

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1584, nLevel = -1, nSeries = -1}, --纳兰潜凛
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[3] = {nTemplate = 74,   nLevel = -1, nSeries = 0},  --上升气流
	[4] = {nTemplate = 1778, nLevel = -1, nSeries = -1}, --无忧教精英
	[5] = {nTemplate = 1779, nLevel = -1, nSeries = -1}, --无忧教精英
	[6] = {nTemplate = 1780, nLevel = -1, nSeries = -1}, --无忧教精英
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
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			--设置同步范围
			{"SetNearbyRange", 3},

			--调整摄像机基础参数
			{"ChangeCameraSetting", 29, 35, 20},

			{"SetFubenProgress", -1,"等待秘境开启"},
			{"AddNpc", 2, 1, 0, "wall", "wall_1_1",false, 16},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第五层 千壑雪岭"},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs"},
			{"AddNpc", 3, 1, 0, "Qg", "Qinggong", false},
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"ChangeTrap", "Jump1", nil, {1602, 2805}},
			{"ChangeTrap", "Jump2", nil, {1503, 3475}},	
			{"ChangeTrap", "Jump3", nil, {2228, 4124}},	
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetTargetPos", 1525, 2161},			
			{"TrapUnlock", "Jump1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "Jump4", 4},
		},
		tbUnLockEvent = 
		{
			{"SetTargetPos", 3851, 2930},
			{"CloseLock", 100},
		},
	},
	--轻功保险锁	
	[100] = {nTime = 5, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetPos", 2228, 4124},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 5},

			--纳兰潜凛
			{"AddNpc", 1, 1, 6, "BOSS", "RandomFuben5_2_BOSS", false, 0, 0, 0, 0},	
			{"NpcHpUnlock", "BOSS", 30, 90},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetHeadVisiable", "BOSS", false, 1},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 50, "击败纳兰潜凛"},
			{"ClearTargetPos"},		    
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetHeadVisiable", "BOSS", true, 0},
			{"NpcBubbleTalk", "BOSS", "你们屡次坏我大事，今日我就送你们去见阎王吧！", 4, 1, 1},
		},
	},
------------------------------------流程阶段------------------------------
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "BOSS", 32, 70},

			--抗性光环怪
			{"AddNpc", 4, 1, 0, "Aura_1", "RandomFuben5_2_Aura1", false, 41, 1, 9011, 1},
		},
	},
	[31] = {nTime = 1.5, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "无忧教精英附带[FFFE0D]强体光环[-]，请优先将其击杀！"},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "BOSS", 34, 50},

			--反弹光环怪
			{"AddNpc", 5, 1, 0, "Aura_2", "RandomFuben5_2_Aura2", false, 7, 1, 9011, 1},			
		},
	},
	[33] = {nTime = 1.5, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "无忧教精英附带[FFFE0D]反弹光环[-]，请优先将其击杀！"},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {32},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "BOSS", 36, 30},

			--恢复光环怪
			{"AddNpc", 6, 1, 0, "Aura_3", "RandomFuben5_2_Aura3", false, 48, 1, 9011, 1},
		},
	},
	[35] = {nTime = 1.5, nNum = 0,
		tbPrelock = {34},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "无忧教精英附带[FFFE0D]恢复光环[-]，请优先将其击杀！"},
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {34},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "BOSS", "Move", "Path1", 37, 0, 0, 0, 0},
			{"NpcBubbleTalk", "BOSS", "可恶，你们不要太得意了！！尝尝我无忧教阵法的威力吧！！", 5, 0, 1},
		},
	},
	[37] = {nTime = 0, nNum = 1,
		tbPrelock = {36},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"SetAiActive", "BOSS", 0},			
			{"DoCommonAct", "BOSS", 16, 0, 0, 0},
		},
	},
	[38] = {nTime = 1, nNum = 0,
		tbPrelock = {37},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"SetAiActive", "BOSS", 1},

			--组合光环怪（抗性 + 反弹 + 恢复）
			{"AddNpc", 4, 1, 0, "Aura_1", "RandomFuben5_2_Aura1", false, 0, 1, 9011, 1},
			{"AddNpc", 5, 1, 0, "Aura_2", "RandomFuben5_2_Aura2", false, 0, 1, 9011, 1},
			{"AddNpc", 6, 1, 0, "Aura_3", "RandomFuben5_2_Aura3", false, 0, 1, 9011, 1},			
		},
	},
	[39] = {nTime = 1.5, nNum = 0,
		tbPrelock = {38},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "无忧教精英摆出[FFFE0D]组合光环[-]阵，请小心应对！！"},
		},
	},

-------------胜利判定------------------------
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败纳兰潜凛"},

			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"AddSimpleNpc", 1611, 3870, 2944, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_win"},

			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},										
		},
	},
-------------闯关时间------------------------

	[7] = {nTime = "e_2_time", nNum = 0,   
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 7},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1, "闯关失败"},
			{"BlackMsg", "纳兰潜凛武艺高强，还是先撤退为妙！"},

			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 1",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "e_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

