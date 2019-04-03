
local tbFubenSetting = {};
Fuben:SetFubenSetting(300, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "藏剑山庄"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_1/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile				= "Setting/Fuben/TeamFuben/1_1/NpcPath.tab"				-- 寻路点
tbFubenSetting.tbMultiBeginPoint        = {{5988, 1594},{5982, 1350},{5666, 1584},{5658, 1333}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {5818, 1460}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 0;													-- 方向


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM =
{
	NpcIndex1	 	= {1, 1},
	NpcIndex2	 	= {2, 2},
	NpcIndex3	 	= {3, 3},
	NpcIndex4	 	= {4, 4},
	NpcIndex5	 	= {5, 5},
	NpcIndex6	 	= {6, 6},
	NpcIndex7	 	= {7, 7},
	NpcIndex8	 	= {8, 8},
	NpcIndex9	 	= {9, 9},
	NpcIndex10	 	= {10, 10},
	NpcIndex11	 	= {11, 11},
	NpcIndex12	 	= {12, 12},
	NpcIndex13	 	= {13, 13},
	NpcIndex14	 	= {14, 14},
	NpcIndex15	 	= {15, 15},
	NpcIndex16	 	= {16, 16},
	NpcIndex17	 	= {17, 17},
	NpcIndex18	 	= {18, 18},
	NpcIndex19	 	= {19, 19},
	NpcIndex20	 	= {20, 20},
	NpcIndex21	 	= {21, 21},
	NpcIndex22	 	= {22, 22},
	NpcIndex23	 	= {23, 23},
	NpcIndex24	 	= {24, 24},
	NpcIndex25	 	= {25, 25},
	NpcNum1 		= {1, 1},
	NpcNum2 		= {2, 2},
	NpcNum3 		= {3, 3},
	NpcNum4 		= {4, 4},
	NpcNum5 		= {5, 5},
	NpcNum6 		= {6, 6},
	NpcNum7 		= {7, 7},
	NpcNum8 		= {8, 8},
	NpcNum9 		= {9, 9},
	NpcNum10 		= {10, 10},
	NpcNum11 		= {11, 11},
	NpcNum12 		= {12, 12},
	NpcNum13 		= {19, 19},
	NpcNum14 		= {20, 20},
	LockNum1		= {3, 6},
	LockNum2		= {7, 12},
	LockNum3		= {1, 1},
}

tbFubenSetting.ANIMATION =
{
	[1] = "Scenes/Maps/fb_cangjian/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
--[[

436 篝火

]]

tbFubenSetting.NPC =
{
	[1] = {nTemplate = 51,    nLevel = -1, nSeries = -1},  --卓非凡
	[2] = {nTemplate = 959,   nLevel = -1, nSeries = -1},  --紫轩
	[3] = {nTemplate = 960,   nLevel = -1, nSeries = -1},  --蔷薇
	[4] = {nTemplate = 967,   nLevel = -1, nSeries = -1},  --庄丁
	[5] = {nTemplate = 968,   nLevel = -1, nSeries = -1},  --庄丁头目
	[6] = {nTemplate = 969,   nLevel = -1, nSeries = -1},  --山庄护卫
	[7] = {nTemplate = 970,   nLevel = -1, nSeries = -1},  --山庄高手
	[8] = {nTemplate = 971,   nLevel = -1, nSeries = -1},  --武林人士
	[9] = {nTemplate = 972,   nLevel = -1, nSeries = -1},  --武林高手1
	[10] = {nTemplate = 973,  nLevel = -1, nSeries = -1},  --武林高手2
	[11] = {nTemplate = 974,  nLevel = -1, nSeries = -1},  --武林高手3
	[12] = {nTemplate = 975,  nLevel = -1, nSeries = -1},  --藏剑弟子
	[13] = {nTemplate = 976,  nLevel = -1, nSeries = -1},  --藏剑精英
	[14] = {nTemplate = 1319, nLevel = -1, nSeries = -1},  --内堂弟子
	[15] = {nTemplate = 1320, nLevel = -1, nSeries = -1},  --贴身护卫
	[16] = {nTemplate = 74,   nLevel = -1, nSeries = 0},  --上升气流
	[17] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[18] = {nTemplate = 957,  nLevel = -1, nSeries = 0},  --弩车（变身）
	[19] = {nTemplate = 958,  nLevel = 15, nSeries = 0},  --弩车
	[20] = {nTemplate = 993,  nLevel = -1, nSeries = -1},  --山庄侍女
	[21] = {nTemplate = 994,  nLevel = -1, nSeries = -1},  --神射手
	[22] = {nTemplate = 1492,  nLevel = -1, nSeries = 0},  --月明瑶（稀有）
	[23] = {nTemplate = 1601,  nLevel = -1, nSeries = -1},  --无忧杀手
	[24] = {nTemplate = 991,  nLevel = -1, nSeries = 0},  --卓非凡(非战斗NPC)
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
			{"SetShowTime", 32},

			--设置同步范围
			{"SetNearbyRange", 3},
		},
	},
	[2] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent =
		{
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 2},
			{"SetTargetPos", 5831, 2097},
			{"SetFubenProgress", -1,"探索藏剑山庄"},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_1", "wall_1_1", false, 16},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_2", "wall_1_2", false, 32},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_3", "wall_1_3", false, 32},
			{"AddNpc", "NpcIndex17", 1, 1, "wall_4", "wall_1_4", false, 16},
			{"AddNpc", "NpcIndex17", 2, 1, "wall_5", "wall_1_5", false, 16},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"击败敌人"},
			{"NpcBubbleTalk", "guaiwu1", "何人擅闯藏剑山庄，还不速速退去！", 3, 2, 1},

			--刷怪
			{"AddNpc", "NpcIndex4", "NpcNum2", 3, "guaiwu", "TeamFuben1_1_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex20", "NpcNum2", 3, "guaiwu", "TeamFuben1_1_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex5", "NpcNum1", 3, "guaiwu1", "TeamFuben1_1_3", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum4", 3, "guaiwu", "TeamFuben1_1_4", false, 0, 5, 9005, 0.5},
		},
	},
	[3] = {nTime = 0, nNum = "NpcNum9",
		tbPrelock = {2},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetTargetPos", 5830, 4922},
			{"SetFubenProgress", -1,"探索藏剑山庄"},
			{"RaiseEvent", "AddMissionScore", 5},
			{"OpenDynamicObstacle", "ops1"},
			{"DoDeath", "wall_1"},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock2", 4},

			--紫轩
			{"AddNpc", "NpcIndex2", "NpcNum1", 0, "Leader", "TeamFuben1_Leader_1", false, 31, 0, 0, 0},
			{"SetNpcProtected", "Leader", 1},
			{"ChangeNpcFightState", "Leader", 0, 0},
			{"SetAiActive", "Leader", 0},
		},
		tbUnLockEvent =
		{
			{"SetNpcBloodVisable", "Leader", false, 0},
			{"SetFubenProgress", -1,"击败守卫"},
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "Leader", "你们是什麽人？为何擅闯藏剑山庄！", 4, 2, 1},
			{"NpcBubbleTalk", "Leader", "守卫何在！赶紧将这群不速之客赶出山庄！", 4, 3, 1},
			{"NpcBubbleTalk", "Leader", "没想到你们还有点本事！守卫们，继续给我上！", 4, 8, 1},


			{"AddNpc", "NpcIndex6", "NpcNum4", 5, "guaiwu", "TeamFuben1_2_2", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum2", 5, "guaiwu", "TeamFuben1_2_3", false, 0, 6, 9005, 0.5},
			{"AddNpc", "NpcIndex7", "NpcNum1", 5, "guaiwu", "TeamFuben1_2_4", false, 0, 6, 9005, 0.5},
			{"AddNpc", "NpcIndex6", "NpcNum2", 5, "guaiwu", "TeamFuben1_2_5", false, 0, 10, 9005, 0.5},
			{"AddNpc", "NpcIndex7", "NpcNum1", 5, "guaiwu", "TeamFuben1_2_6", false, 0, 10, 9005, 0.5},
		},
	},
	[5] = {nTime = 0, nNum = "NpcNum10",
		tbPrelock = {4},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "AddMissionScore", 9},
			{"SetFubenProgress", -1,"击败紫轩"},
			{"NpcBubbleTalk", "Leader", "就让小女子亲自来领教各位的高招吧！", 4, 1, 1},
			{"SetNpcProtected", "Leader", 0},
			{"ChangeNpcFightState", "Leader", 1, 0},
			{"SetNpcBloodVisable", "Leader", true, 0},
			{"SetAiActive", "Leader", 1},
			{"NpcHpUnlock", "Leader", 50, 70},
		},
	},
	[50] = {nTime = 1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader", "讨厌的家伙，我会让你们吃些苦头的！", 3, 1, 1},
			{"NpcHpUnlock", "Leader", 51, 30},
		},
	},
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader", "可恶.... 不要以为这就结束了！", 3, 1, 1},
			{"NpcHpUnlock", "Leader", 6, 1},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zixuan.tab", 5706, 5501},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zixuan.tab", 5892, 5556},
			{"NpcBubbleTalk", "Leader", "藏剑山庄卧虎藏龙，总有你们无法匹敌的对手！", 4, 1, 1},
			{"SetNpcProtected", "Leader", 1},
			{"ChangeNpcFightState", "Leader", 0, 0},
			{"SetNpcBloodVisable", "Leader", false, 0},
			{"SetAiActive", "Leader", 0},

			{"RaiseEvent", "AddMissionScore", 10},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
			{"SetTargetPos", 8597, 5809},
			{"SetFubenProgress", -1,"探索藏剑山庄"},

			--重新设置复活点
			{"SetDynamicRevivePoint", 5836, 5201},

			--稀有几率
			{"Random", {330000, 60}},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock3", 7},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_1", false, 45, 0, 0, 0},
			{"AddNpc", "NpcIndex21", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_2", false, 45, 0, 0, 0},
			{"AddNpc", "NpcIndex9", "NpcNum1", 8, "guaiwu1", "TeamFuben1_3_3", false, 45, 0, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"DelNpc", "Leader"},
			{"NpcBubbleTalk", "guaiwu1", "你们是什麽人？大夥一起拿下他们！", 3, 1, 1},
			{"SetFubenProgress", -1,"击败武林人士"},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_4", false, 28, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_4", false, 28, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum2", 8, "guaiwu", "TeamFuben1_3_4", false, 28, 5, 9005, 0.5},
		},
	},
	[8] = {nTime = 0, nNum = "NpcNum11",
		tbPrelock = {6},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "AddMissionScore", 6},
			{"OpenDynamicObstacle", "ops3"},
			{"DoDeath", "wall_3"},
			{"SetTargetPos", 7892, 7846},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock4", 9},
			{"AddNpc", "NpcIndex8", "NpcNum4", 10, "guaiwu", "TeamFuben1_4_1", false, 32, 0, 9005, 0.5},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "guaiwu1", "不知死活的家伙，就让我们送你上路吧！", 3, 1, 1},
		},
	},
	[10] = {nTime = 0, nNum = "NpcNum4",
		tbPrelock = {8},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetTargetPos", 8233, 8667},
			{"AddNpc", "NpcIndex8", "NpcNum2", 12, "guaiwu", "TeamFuben1_4_2", false, 32, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex21", "NpcNum2", 12, "guaiwu", "TeamFuben1_4_3", false, 32, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex9", "NpcNum1", 12, "guaiwu1", "TeamFuben1_4_4", false, 32, 0, 9005, 0.5},
		},
	},

	--藏剑山庄稀有
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {},
		tbStartEvent =
		{
			{"TrapUnlock", "Xiyou", 60},

			--关闭锁
			{"CloseLock", 12},

			--月明瑶
			{"AddNpc", "NpcIndex22", "NpcNum1", 0, "Xiyou", "TeamFuben1_Xiyou", false, 14, 0, 0, 0},
			{"SetNpcProtected", "Xiyou", 1},
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "前方的姑娘似乎遇到了麻烦，去助她一臂之力"},
			{"SetNpcProtected", "Xiyou", 0},
			{"NpcBubbleTalk", "guaiwu", "小娘子，遇到我们你就乖乖的留下来吧！", 4, 0, 1},
			{"NpcBubbleTalk", "Xiyou", "可恶的家伙，你们休要阻我！！", 4, 2, 1},
		},
	},
	[61] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			--寻路
			{"ChangeNpcAi", "Xiyou", "Move", "Path1", 61, 0, 0, 0, 0},
			{"NpcBubbleTalk", "Xiyou", "多谢各位侠士相助，还请继续护送小女子一程！", 4, 0, 1},
			{"NpcBubbleTalk", "Xiyou", "小女子受父亲所托前往此处寻找一物，也不知究竟藏匿於何处...", 4, 3, 1},
		},
		tbUnLockEvent =
		{

		},
	},
	[62] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent =
		{
			--寻路
			{"ChangeNpcAi", "Xiyou", "Move", "Path2", 62, 1, 1, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},

			--无忧杀手
			{"AddNpc", "NpcIndex23", "NpcNum1", 63, "Xiyou_Guaiwu", "TeamFuben1_XiyouGuaiwu", false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "Xiyou_Guaiwu", "月明瑶，总算是找到你了！交出《武道德经》然後乖乖的跟我们走吧！", 4, 1, 1},
			{"NpcBubbleTalk", "Xiyou", "糟糕，是无忧教的人！！", 4, 2, 1},
			{"BlackMsg", "击败无忧教刺客，保护月明瑶！"},
		},
	},
	[63] = {nTime = 0, nNum = 1,
		tbPrelock = {62},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Xiyou", "一路上给诸位添了不少麻烦，小女子在此谢过各位！", 4, 0, 1},

			{"SetTargetPos", 7833, 9315},
			{"RaiseEvent", "AddMissionScore", 6},
			{"AddNpc", 16, 1, 1, "TeamFuben1_4", "TeamFuben1_4", 1},
			{"ChangeTrap", "Jump1", nil, {7129, 9404, 2}},
			{"ChangeTrap", "Jump2", nil, {6587, 8832, 2}},
			{"ChangeTrap", "Jump3", nil, {6132, 9045, 2}},
		},
	},

	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock7", 11},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
		},
	},
	[12] = {nTime = 0, nNum = "NpcNum5",
		tbPrelock = {10},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetTargetPos", 7833, 9315},
			{"RaiseEvent", "AddMissionScore", 6},
			{"AddNpc", 16, 1, 1, "TeamFuben1_4", "TeamFuben1_4", 1},
			{"ChangeTrap", "Jump1", nil, {7129, 9404, 2}},
			{"ChangeTrap", "Jump2", nil, {6587, 8832, 2}},
			{"ChangeTrap", "Jump3", nil, {6132, 9045, 2}},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{
			{"TrapUnlock", "Jump1", 13},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},

			--蔷薇
			{"AddNpc", "NpcIndex3", "NpcNum1", 0, "Leader1", "TeamFuben1_Leader_2", false, 0, 0, 0, 0},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{
			{"TrapUnlock", "Jump3", 14},
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader1", "你们是什麽人，莫非也是爹爹派来的人吗？", 3, 1, 1},
			{"NpcBubbleTalk", "Leader1", "哼！想要带我回去的话，就让我看看你们的本事吧！", 4, 4, 1},
			{"SetFubenProgress", -1,"击败蔷薇"},
			{"NpcHpUnlock", "Leader1", 52, 70},
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader1", "没想到你们还有点本事，本小姐也要认真了！", 4, 1, 1},
			{"AddNpc", "NpcIndex8", "NpcNum3", 0, "guaiwu", "TeamFuben1_5_2", false, 0, 1, 9005, 0.5},
			{"AddNpc", "NpcIndex8", "NpcNum3", 0, "guaiwu", "TeamFuben1_5_3", false, 0, 1, 9005, 0.5},
			{"NpcHpUnlock", "Leader1", 53, 30},
		},
	},
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {52},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "Leader1", "可恶... 没想到你们竟会如此棘手！", 3, 1, 1},
			{"AddNpc", "NpcIndex9", "NpcNum1", 0, "guaiwu", "TeamFuben1_5_4", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex10", "NpcNum1", 0, "guaiwu", "TeamFuben1_5_5", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex11", "NpcNum1", 0, "guaiwu", "TeamFuben1_5_6", false, 0, 0, 9005, 0.5},
			{"BlackMsg", "武林高手会增强蔷薇的能力，优先将其击杀！"},
			{"NpcHpUnlock", "Leader1", 15, 1},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/qiangwei.tab", 5630, 8427},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/qiangwei.tab", 5611, 8235},
			{"CastSkill", "guaiwu", 3, 1, -1, -1},

			{"RaiseEvent", "AddMissionScore", 10},
			{"NpcBubbleTalk", "Leader1", "哼，算你们厉害！", 4, 1, 1},
			{"SetNpcProtected", "Leader1", 1},
			{"ChangeNpcFightState", "Leader1", 0, 0},
			{"SetNpcBloodVisable", "Leader1", false, 0},
			{"SetAiActive", "Leader1", 0},

			{"SetFubenProgress", -1,"探索藏剑山庄"},
			{"OpenDynamicObstacle", "ops4"},
			{"DoDeath", "wall_4"},
			{"SetTargetPos", 2796, 5051},

			--重新设置复活点
			{"SetDynamicRevivePoint", 5675, 8216},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock5", 16},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"DelNpc", "Leader1"},
			{"NpcBubbleTalk", "guaiwu1", "你们是什麽人？大夥一起拿下他们！", 3, 1, 1},
			{"SetFubenProgress", -1,"击败藏剑弟子"},
		}
	},
	[17] = {nTime = 3, nNum = 0,
		tbPrelock = {16},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "弩车出现！击杀弩车後可操控弩车攻击敌人！"},
			{"AddNpc", "NpcIndex19", "NpcNum1", 18, "nuche", "TeamFuben1_6_4", false, 17, 0, 9005, 0.5},
			{"SaveNpcInfo", "nuche"},
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"BlackMsg", "弩车出现！操纵弩车来攻击藏剑弟子！"},
			{"CloseLock", 21},
			{"AddNpc", "NpcIndex18", "NpcNum1", 0, "nuche", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[19] = {nTime = 0, nNum = "NpcNum14", 
		tbPrelock = {18},
		tbStartEvent =
		{
			{"AddNpc", "NpcIndex12", "NpcNum10",19, "guaiwu", "TeamFuben1_6_7", false, 0, 2, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum10",19, "guaiwu", "TeamFuben1_6_7", false, 0, 6, 9005, 0.5},
		},
		tbUnLockEvent =
		{
		},
	},
	[20] = {nTime = 0, nNum = "NpcNum13",
		tbPrelock = {16},
		tbStartEvent =
		{
			{"AddNpc", "NpcIndex12", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_1", false, 11, 0, 0, 0},
			{"AddNpc", "NpcIndex21", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_2", false, 11, 0, 0, 0},
			{"AddNpc", "NpcIndex13", "NpcNum1", 20, "guaiwu1", "TeamFuben1_6_3", false, 11, 0, 0, 0},
			{"AddNpc", "NpcIndex12", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_5", false, 0, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum2", 20, "guaiwu", "TeamFuben1_6_6", false, 0, 5, 9005, 0.5},
			{"AddNpc", "NpcIndex12", "NpcNum10",20, "guaiwu", "TeamFuben1_6_7", false, 0, 9, 9005, 0.5},
		},
		tbUnLockEvent =
		{
			{"UnLock", 21},
		}
	},
	[21] = {nTime = 0, nNum = 1,  --杀弩车后关闭此锁
		tbPrelock = {15},
		tbStartEvent =
		{			
		},
		tbUnLockEvent =
		{
		},
	},
	[22] = {nTime = 0.1, nNum = 0, 
		tbPrelock = {19, 20},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
		},
	},
	[23] = {nTime = 0.1, nNum = 0,  
		tbPrelock = {{21, 22}},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"RaiseEvent", "AddMissionScore", 14},
			{"SetFubenProgress", -1,"探索藏剑山庄"},
			{"DelNpc", "nuche"},
			{"RemovePlayerSkillState", 2215},
			{"OpenDynamicObstacle", "ops5"},
			{"DoDeath", "wall_5"},
			{"SetTargetPos", 1925, 6898},

			--重新设置复活点
			{"SetDynamicRevivePoint", 1920, 4330},
		},
	},
	[24] = {nTime = 0, nNum = 1,
		tbPrelock = {23},
		tbStartEvent =
		{
			{"TrapUnlock", "TrapLock6", 24},

			--卓非凡
			{"AddNpc", "NpcIndex1", "NpcNum1", 31, "BOSS", "TeamFuben1_BOSS", false, 0, 0, 0, 0},
		},
		tbUnLockEvent =
		{
			{"ClearTargetPos"},
			{"NpcBubbleTalk", "BOSS", "没想到你们竟能闯入这里！但是，到此为止了！", 4, 1, 1},
			{"AddNpc", "NpcIndex14", "NpcNum4", 0, "guaiwu", "TeamFuben1_7_1", false, 0, 6, 9005, 0.5},
			{"SetFubenProgress", -1,"击败卓非凡"},
			{"NpcHpUnlock", "BOSS", 25, 70},
		},
	},
	[25] = {nTime = 0, nNum = 1,
		tbPrelock = {23},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"NpcBubbleTalk", "BOSS", "哼，没想到你们还有点本事，既然如此卓某也能不能托大了！", 3, 1, 1},
			{"AddNpc", "NpcIndex14", "NpcNum4", 0, "guaiwu", "TeamFuben1_7_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_2", false, 0, 3, 9005, 0.5},
			{"AddNpc", "NpcIndex15", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_4", false, 0, 3, 9005, 0.5},
			{"NpcHpUnlock", "BOSS", 28, 40},
		},
	},
	[26] = {nTime = 3, nNum = 0,
		tbPrelock = {25},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex19", "NpcNum1", 27, "nuche", "TeamFuben1_7_6", false, 48, 0, 9005, 0.5},
			{"SaveNpcInfo", "nuche"},
			{"BlackMsg", "弩车出现！利用弩车来击败敌人！"},
		},
	},
	[27] = {nTime = 0, nNum = 1,
		tbPrelock = {26},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex18", "NpcNum1", 0, "nuche", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[28] = {nTime = 0, nNum = 1,
		tbPrelock = {25},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"DelNpc", "nuche"},
			{"NpcBubbleTalk", "BOSS", "可恶... 没想到竟会如此棘手！藏剑弟子们，都给我上！", 3, 1, 1},
			{"AddNpc", "NpcIndex14", "NpcNum4", 0, "guaiwu", "TeamFuben1_7_1", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_2", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex15", "NpcNum1", 0, "guaiwu", "TeamFuben1_7_3", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex14", "NpcNum2", 0, "guaiwu", "TeamFuben1_7_4", false, 0, 0, 9005, 0.5},
			{"AddNpc", "NpcIndex15", "NpcNum1", 0, "guaiwu", "TeamFuben1_7_5", false, 0, 0, 9005, 0.5},
		},
	},
	[29] = {nTime = 3, nNum = 0,
		tbPrelock = {28},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex19", "NpcNum1", 30, "nuche", "TeamFuben1_7_6", false, 48, 0, 9005, 0.5},
			{"SaveNpcInfo", "nuche"},
			{"BlackMsg", "弩车出现！利用弩车来击败敌人！"},
		},
	},
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {29},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"AddNpc", "NpcIndex18", "NpcNum1", 0, "nuche", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
		},
	},
	[31] = {nTime = 0, nNum = "NpcNum1",
		tbPrelock = {23},
		tbStartEvent =
		{

		},
		tbUnLockEvent =
		{
			--奖励掉落
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zhuofeifan.tab", 1826, 7928},
			--{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/zhuofeifan.tab", 2008, 7908},

			{"SetFubenProgress", -1,"闯关成功"},
			{"RaiseEvent", "AddMissionScore", 15},
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"DelNpc", "nuche"},
			{"RemovePlayerSkillState", 2215},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 70},
			{"BlackMsg", "闯关成功！篝火已刷出，可持续获得经验！"},
			{"GameWin"},
			{"AddSimpleNpc", 1610, 1932, 7223, 0},
			{"AddSimpleNpc", 991, 1944, 7593, 32},

		},
	},
	[32] = {nTime = 900, nNum = 0,
		tbPrelock = {1},
		tbStartEvent =
		{
		},
		tbUnLockEvent =
		{
			{"SetFubenProgress", -1,"闯关失败"},
			{"RaiseEvent", "KickOutAllPlayer", 10},
			{"BlackMsg", "时间耗尽，本次挑战失败！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}