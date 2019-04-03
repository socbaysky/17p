
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("g_5");

tbFubenSetting.tbMultiBeginPoint = {{1136, 5176},{1158, 4850},{1448, 5184},{1499, 4843}}  
tbFubenSetting.tbTempRevivePoint = {1448, 5184};
tbFubenSetting.nStartDir		 = 16;


tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2036, nLevel = -1, nSeries = -1}, --普通精英
	[2] = {nTemplate = 2037, nLevel = -1, nSeries = -1}, --普通怪物
	[3] = {nTemplate = 2038, nLevel = -1, nSeries = -1}, --冲刺怪物
	[4] = {nTemplate = 2039, nLevel = -1, nSeries = -1}, --预警aoe怪物
	[5] = {nTemplate = 2040, nLevel = -1, nSeries = -1}, --boss黄暮云

	[99] = {nTemplate = 74,   nLevel = -1, nSeries = 0}, -- 上升气流
	[100] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
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
			--{"ChangeCameraSetting", 30, 35, 20},

			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第七层 恸哭城墙"},
		},
	},
	[2] = {nTime = 10, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"等待秘境开启"},
			{"AddNpc", 100, 2, 0, "wall", "wall1",false, 32},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "Start"},
			{"BlackMsg", "此地风雪呼啸，冰冷的城墙上飘来猩红的味道。"},
			--{"ShowTaskDialog", 10004, false},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
			
			
		},
	},
	-------------闯关时间------------------------
	[3] = {nTime = "g_time", nNum = 0,    --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 3},
		},
		tbUnLockEvent = 
		{
			--判断模式踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"RaiseEvent", "KickOutAllPlayer", 10},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_lost"},

			{"SetFubenProgress", -1, "闯关失败"},
			{"BlackMsg", "此地不宜久留，还是另觅他路吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 4},
			{"SetTargetPos", 3377, 5235},
			{"SetFubenProgress", 0, "探索凌绝峰"},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 10, "击败敌人"},
			{"ClearTargetPos"},
		},
	},
	[5] = {nTime = 0, nNum = 9,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"BlackMsg", "有埋伏！"},

			{"AddNpc", 1, 1, 5, "jy", "jingying1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 5, "gw", "guaiwu1", false, 0, 0, 9005, 0.5},

			{"NpcBubbleTalk", "jy", "来到这里，就别想走了！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "兄弟们一起上啊！", 4, 1, 2},

			{"AddNpc", 3, 5, 0, "gw", "guaiwu1_1", false, 0, 5, 9009, 0.5},
			{"NpcBubbleTalk", "jy", "嘿嘿，兄弟们该出手了！", 4, 6, 1},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "gw"},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"BlackMsg", "此处强敌环伺，沿途小心！"},
			{"SetFubenProgress", 25, "继续探索"},

			{"AddNpc", 99, 1, 0, "qg", "qinggong", false, 0, 0, 0, 0},
			{"TrapUnlock", "jump1", 6},
			{"SetTargetPos", 4614, 4423},
			{"ChangeTrap", "jump1", nil, {5278, 3883}},
			{"ChangeTrap", "jump2", nil, {6276, 3601}},	
		},
		tbUnLockEvent = 
		{
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap2", 7},
			{"SetTargetPos", 7139, 3340},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[8] = {nTime = 0, nNum = 9,
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 8, "jy", "jingying2", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 6, 8, "gw", "guaiwu2", false, 0, 0, 9005, 0.5},

			{"NpcBubbleTalk", "jy", "找死！", 4, 1, 1},
			{"NpcBubbleTalk", "gw", "杀啊！", 4, 1, 3},

			{"AddNpc", 4, 2, 8, "gw", "guaiwu2_1", false, 0, 5, 9009, 0.5},
			{"NpcBubbleTalk", "jy", "来人！", 4, 6, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 9},
			{"SetTargetPos", 9196, 7445},
			{"SetFubenProgress", 50, "继续探索"},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"SetFubenProgress", 75, "击败武林高手"},
			{"BlackMsg", "似乎有强敌出没！"},
			{"AddNpc", 5, 1, 10, "boss", "boss1", false, 0, 0, 9010, 0.5},
			{"AddNpc", 2, 8, 0, "gw", "guaiwu3", false, 0, 0, 9005, 0.5},
			{"NpcBubbleTalk", "boss", "你们还有些本事，居然来到了此处！", 4, 1, 1},

			{"AddNpc", 3, 5, 0, "gw", "guaiwu3_1", false, 0, 5, 9009, 0.5},
			{"NpcBubbleTalk", "boss", "小心了！", 4, 6, 1},

			{"AddNpc", 4, 2, 0, "gw", "guaiwu3_2", false, 0, 10, 9009, 0.5},
			{"NpcBubbleTalk", "boss", "是在下轻敌了！", 4, 11, 1},
		},
		tbUnLockEvent = 
		{
			--判断模式篝火&踢出
			{"IfCase", "self.nFubenLevel == 3",
				{"AddSimpleNpc", 1611, 9247, 7579, 0},
				{"RaiseEvent", "KickOutAllPlayer", 40},
			},
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "g_score_win"},

			{"SetFubenProgress", 100, "击败武林高手"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},

}

