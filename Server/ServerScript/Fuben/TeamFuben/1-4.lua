
local tbFubenSetting = {};
Fuben:SetFubenSetting(303, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "翠竹幽谷"										-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_4/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/TeamFuben/1_4/NpcPath.tab"				-- 寻路点								
tbFubenSetting.tbMultiBeginPoint        = {{1987, 3468},{2331, 3458},{1991, 3300},{2309, 3282}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {2170, 3400}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 32;


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
	[1]  = {nTemplate = 1898,   nLevel = -1, nSeries = -1},  --金国武士
	[2]  = {nTemplate = 1899,  nLevel = -1, nSeries = -1},  --金国高手
	[3]  = {nTemplate = 1900,  nLevel = -1, nSeries = -1},  --护卫弓手-精英
	[4]  = {nTemplate = 1901,  nLevel = -1, nSeries = 4},  --耶律辟离-boss
	[5]  = {nTemplate = 1902,  nLevel = -1, nSeries = 0},  --铁浮陀-炮车
	[6]  = {nTemplate = 1903, nLevel = -1, nSeries = -1},  --暗影杀手
	[7]  = {nTemplate = 1904, nLevel = -1, nSeries = -1},  --凶悍水贼
	[8]  = {nTemplate = 1905, nLevel = -1, nSeries = -1},  --杀手头目-精英
	[9]  = {nTemplate = 1906, nLevel = -1, nSeries = 1},  --无怒-首领
	[10] = {nTemplate = 1907, nLevel = -1, nSeries = 2},  --无欲-首领
	[11] = {nTemplate = 1908, nLevel = -1, nSeries = 4},  --无惘-首领
	[12] = {nTemplate = 1909, nLevel = -1, nSeries = 5},  --无痴-首领
	[13] = {nTemplate = 1910, nLevel = -1, nSeries = -1},  --护法弟子
	[14] = {nTemplate = 1911, nLevel = -1, nSeries = -1},  --护法精英
	[15] = {nTemplate = 1940, nLevel = -1, nSeries = 4},  --天忍高手-稀有
	[16] = {nTemplate = 1941, nLevel = -1, nSeries = 3},  --燕若雪-稀有
	[17] = {nTemplate = 1912,  nLevel = -1, nSeries = 3},   --秋依水-boss

	[18] = {nTemplate = 1913, nLevel = -1, nSeries = 0},   --唐影
	[19] = {nTemplate = 1914, nLevel = -1, nSeries = 0},   --唐影--重伤
	[20] = {nTemplate = 104, nLevel = -1, nSeries = 0},   --障碍门

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
			--{"HomeScreenTip", "翠竹幽谷", "", 5, 0.5},
		},
		--tbStartEvent 锁解开时的事件
		tbUnLockEvent = 
		{
			--设置同步范围
			{"SetNearbyRange", 3},	
		},
	},
	[2] = {nTime = 900, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"探索翠竹幽谷"},
			{"SetShowTime", 2},	

			--障碍门
			{"AddNpc", 20, 1, 0, "wall1", "wall1", false, 32, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall2", "wall2", false, 48, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall3", "wall3", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"闯关失败"},
			{"BlackMsg", "时间耗尽，本次挑战失败！"},
			{"RaiseEvent", "KickOutAllPlayer", 10},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},	
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 2391,2146},
			--怪堆1-1
			{"AddNpc", 1, 10, 4, "gw", "guaiwu1_1", false, 0, 0, 0, 0},
			{"SetNpcProtected", "gw", 1},
			{"SetNpcBloodVisable", "gw", false, 0},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[4] = {nTime = 0, nNum = 10,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			{"SetNpcProtected", "gw", 0},
			{"SetNpcBloodVisable", "gw", true, 0},
			{"BlackMsg", "糟糕，看来金人先来一步！"},
			{"NpcBubbleTalk", "gw", "嘿嘿，还有来送死的？", 4, 1, 2},
			{"SetFubenProgress", -1,"击退金国武人"},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 5},
		},
	},
	[5] = {nTime = 0, nNum = 10,
		tbPrelock = {4},
		tbStartEvent = 
		{
			--怪堆1-2刷新
			{"AddNpc", 2, 8, 5, "gw", "guaiwu1_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 2, 5, "gw1", "guaiwu1_2", false, 0, 0.5, 9010, 0.5},
			{"BlackMsg", "小心！更多的金人出现了！"},
			{"NpcBubbleTalk", "gw", "吃我一刀！", 4, 1, 2},
			{"NpcBubbleTalk", "gw1", "今日之事只与唐门和翠烟相关，识相的赶紧离开！", 4, 1.5, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},
	[6] = {nTime = 0, nNum = 1,				--boss1死亡掉落
		tbPrelock = {5},
		tbStartEvent = 
		{
			--boss耶律辟离
			{"AddNpc", 4, 1, 6, "boss1", "boss1", false, 0, 0.5, 9011, 0.5},
			{"NpcBubbleTalk", "boss1", "哼！尔等喽罗胆敢坏本座的事，自寻死路！", 4, 1, 1},
			{"SetFubenProgress", -1,"击败耶律辟离"},
			{"BlackMsg", "耶律辟离亲至，要对付的怕是大人物！"},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 10},
			{"DoDeath", "wall1"},
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"DoDeath", "gw2"},
			{"OpenDynamicObstacle", "obs1"},

			--重新设置复活点
			{"SetDynamicRevivePoint", 7375, 3276},
		},
	},
	
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {26},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss1", 7, 85},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "尝尝我教铁浮陀的厉害！", 4, 0, 1},
			{"BlackMsg", "铁浮陀出现，优先摧毁！"},
			--召唤怪物
			{"AddNpc", 2, 4, 0, "gw", "guaiwu1_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 1, 0, "gw1", "guaiwu1_2", false, 0, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "gw", "去死吧！", 4, 0, 2},
			{"NpcBubbleTalk", "gw1", "真是胆大妄为！", 4, 0, 1},
			--召唤炮车
			{"AddNpc", 5, 1, 0, "gw2", "guaiwu1_2", false, 0, 0.5, 9010, 0.5},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {26},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss1", 8, 50},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "可恶！怎麽可能？兄弟们来啊！", 4, 0, 1},
			{"BlackMsg", "铁浮陀出现，优先摧毁！"},
			--召唤怪物
			{"AddNpc", 2, 8, 0, "gw", "guaiwu1_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 3, 2, 0, "gw1", "guaiwu1_2", false, 0, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "gw", "大夥一起上啊！", 4, 0, 2},
			{"NpcBubbleTalk", "gw1", "吃我一箭！", 4, 0, 2},
			--召唤炮车
			{"AddNpc", 5, 2, 0, "gw2", "guaiwu1_2", false, 0, 0.5, 9010, 0.5},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"继续探索翠竹幽谷"},
			{"BlackMsg", "此处怕是有天忍教的人出没，得小心点了！"},

			{"TrapUnlock", "trap2", 9},
			{"SetTargetPos", 6101,2744},
			--怪堆2-1
			{"AddNpc", 6, 10, 10, "gw", "guaiwu2_1", false, 0, 0, 0, 0},
			{"SetNpcProtected", "gw", 1},
		},
		tbUnLockEvent = 
		{
			--稀有几率
			{"Random", {330000, 31}},
		},
	},
	[10] = {nTime = 0, nNum = 10,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			{"SetNpcProtected", "gw", 0},
			{"SetFubenProgress", -1,"击败天忍教众"},
			{"NpcBubbleTalk", "gw", "和天忍作对的人都没有好下场！", 4, 0, 2},	
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 6},
		},
	},
	[11] = {nTime = 0, nNum = 12,
		tbPrelock = {10},
		tbStartEvent = 
		{
			--怪堆2-2
			{"AddNpc", 7, 10, 11, "gw", "guaiwu2_2", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 8, 2, 11, "gw1", "guaiwu2_3", false, 0, 0.5, 9009, 0.5},
			{"NpcBubbleTalk", "gw", "嘿嘿，来水下玩玩如何？", 4, 0, 2},
			{"NpcBubbleTalk", "gw1", "哼，螳臂当车！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 7},
			{"OpenDynamicObstacle", "obs2"},
			{"DoDeath", "wall2"},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap3", 12},	
			{"SetTargetPos", 6397,4449},
			{"SetFubenProgress", -1,"继续探索翠竹幽谷"},

			--刷出boss2首领
			{"AddNpc", 9, 1, 16, "sl1", "boss2_1", false, 32, 0, 0, 0},
			{"AddNpc", 10, 1, 16, "sl2", "boss2_2", false, 48, 0, 0, 0},
			{"AddNpc", 11, 1, 16, "sl3", "boss2_3", false, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 16, "sl4", "boss2_4", false, 16, 0, 0, 0},
			{"SetNpcProtected", "sl1", 1},
			{"SetNpcProtected", "sl2", 1},
			{"SetNpcProtected", "sl3", 1},
			{"SetNpcProtected", "sl4", 1},
			{"SetNpcBloodVisable", "sl1", false, 0},
			{"SetNpcBloodVisable", "sl2", false, 0},
			{"SetNpcBloodVisable", "sl3", false, 0},
			{"SetNpcBloodVisable", "sl4", false, 0},

			--刷出唐影
			{"AddNpc", 18, 1, 0, "npc", "tangying", false, 32, 0, 0, 0},
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"DelNpc", "xy"},		--删除稀有npc
		},
	},
	[13] = {nTime = 4, nNum = 0,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"ChangeTime", -4},
			--移动镜头
			{"MoveCameraToPosition", 0, 3, 5982, 5593, 5},
			{"OpenWindow", "StoryBlackBg", "你们小心翼翼的前行，忽然听到前方似乎有打斗的声音......", nil, 2, 1, 1},

			{"SetForbiddenOperation", true},
			{"SetAllUiVisiable", false},	
		},
		tbUnLockEvent = 
		{	
		},
	},
	[14] = {nTime = 9, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			--剧情表现
			{"ChangeTime", -9},
			{"NpcBubbleTalk", "npc", "我唐门与贵教素无瓜葛，今日为难在下到底为何？", 4, 1, 1},
			{"NpcBubbleTalk", "sl1", "哈哈哈...怪只怪你唐门在宋，我等在金。各为其主，得罪得罪！", 4, 4, 1},
			{"NpcBubbleTalk", "sl2", "大哥别和他废话，绑起来再说！", 4, 7, 1},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "npc"},
		},
	},
	--[15] = {nTime = 2, nNum = 0,
	--	tbPrelock = {14},
	--	tbStartEvent = 
	--	{
	--		--剧情表现，怪物使用技能
	--		{"CastSkill", "sl1", 54, 1, 5982, 5593},
	--		{"CastSkill", "sl2", 57, 1, 5982, 5593},
	--		{"CastSkill", "sl3", 56, 1, 5982, 5593},
	--		{"CastSkill", "sl4", 106, 1, 5982, 5593},
	--	},
	--	tbUnLockEvent = 
	--	{
	--		{"DoDeath", "npc"},
	--	},
	--},
	[16] = {nTime = 0, nNum = 4,		--boss2死亡掉落
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"击败法王救下唐影"},
			{"PlayCameraEffect", 9119},
			{"LeaveAnimationState", true},
			{"SetForbiddenOperation", false},
			{"SetAllUiVisiable", true},
			--刷出唐影重伤
			{"AddNpc", 19, 1, 0, "npc", "tangying", false, 0, 0, 0, 0},
			{"SetNpcProtected", "npc", 1},

			{"SetNpcProtected", "sl1", 0},
			{"SetNpcProtected", "sl2", 0},
			{"SetNpcProtected", "sl3", 0},
			{"SetNpcProtected", "sl4", 0},
			{"SetNpcBloodVisable", "sl1", true, 0},
			{"SetNpcBloodVisable", "sl2", true, 0},
			{"SetNpcBloodVisable", "sl3", true, 0},
			{"SetNpcBloodVisable", "sl4", true, 0},

			{"BlackMsg", "击败金国法王，救下唐影！"},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 10},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/80fb_boss2.tab", 5982, 5593},
			{"DoDeath", "gw"},
			{"DoDeath", "gw1"},
			{"DoDeath", "wall3"},
			{"OpenDynamicObstacle", "obs3"},

			--重新设置复活点
			{"SetDynamicRevivePoint", 7248, 5537},
		},
	},
	[17] = {nTime = 2, nNum = 0,
		tbPrelock = {16},
		tbStartEvent = 
		{
			--剧情表现
			{"NpcBubbleTalk", "npc", "多谢各位少侠相救，在下调息片刻即可动身！", 4, 0, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap4", 18},	
			{"SetTargetPos", 2839,5345},
			{"SetFubenProgress", -1,"继续探索翠竹幽谷"},

			--刷出boss3
			{"AddNpc", 17, 1, 21, "boss3", "boss3", false, 24, 0, 0, 0},
			{"SetAiActive", "boss3", 0},
			{"SetNpcProtected", "boss3", 1},
			{"SetNpcBloodVisable", "boss3", false, 0},

			----刷出怪堆4-1
			--{"AddNpc", 15, 10, 20, "gw", "guaiwu4_1", false, 24, 0, 0, 0},
			--{"SetNpcProtected", "gw", 1},
		},
		tbUnLockEvent = 
		{		
		},
	},
	[19] = {nTime = 3, nNum = 0,
		tbPrelock = {18},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--剧情展现
			{"NpcBubbleTalk", "boss3", "你们就是投靠金人的中原武林人士吧？找死...咳咳！", 4, 0, 1},
			--{"NpcBubbleTalk", "gw", "掌门不要和他们废话，动手吧！", 4, 3, 2},
		},
		tbUnLockEvent = 
		{
		},
	},
	--[20] = {nTime = 0, nNum = 10,
	--	tbPrelock = {19},
	--	tbStartEvent = 
	--	{
	--		{"SetNpcProtected", "gw", 0},
	--	},
	--	tbUnLockEvent = 
	--	{	
	--	},
	--},
	[21] = {nTime = 0, nNum = 1,	--boss3死亡掉落
		tbPrelock = {19},
		tbStartEvent = 
		{
			{"SetAiActive", "boss3", 1},
			{"SetFubenProgress", -1,"制服受伤的秋依水"},
			{"BlackMsg", "此人身受重伤还动手，看来是急怒攻心了！"},
			{"SetNpcProtected", "boss3", 0},
			{"SetNpcBloodVisable", "boss3", true, 0},
			{"SaveNpcInfo", "boss3"},
			--{"NpcHpUnlock", "boss3", 21, 20},
		},
		tbUnLockEvent = 
		{
		},
	},
	[22] = {nTime = 0, nNum = 1,
		tbPrelock = {19},
		tbStartEvent = 
		{
			--阶段1
			{"NpcHpUnlock", "boss3", 22, 85},
		},
		tbUnLockEvent = 
		{
			----刷出npc
			--{"AddNpc", 19, 8, 0, "gw", "guaiwu4_1", false, 24, 0, 0, 0},
			--{"AddNpc", 19, 2, 0, "gw1", "guaiwu4_2", false, 24, 0, 0, 0},
			--boss释放特殊技能
			{"NpcBubbleTalk", "boss3", "尔等见识下我翠烟的绝技！雨打梨花！", 4, 0, 1},
			{"CastSkill", "boss3", 2747, 15, -1, -1},
			{"CastSkill", "boss3", 2747, 15, 2195, 5725},
			{"CastSkill", "boss3", 2747, 15, 2739, 6018},
			{"CastSkill", "boss3", 2747, 15, 2495, 5340},
			{"CastSkill", "boss3", 2747, 15, 2923, 5669},
			{"CastSkill", "boss3", 2747, 15, 2755, 4994},
			{"CastSkill", "boss3", 2747, 15, 3197, 5330},
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
			--阶段2
			{"NpcHpUnlock", "boss3", 23, 45},
		},
		tbUnLockEvent = 
		{
			----刷出npc
			--{"AddNpc", 19, 8, 0, "gw", "guaiwu4_1", false, 24, 0, 0, 0},
			--{"AddNpc", 19, 2, 0, "gw1", "guaiwu4_2", false, 24, 0, 0, 0},
			--boss释放特殊技能
			{"NpcBubbleTalk", "boss3", "没想到你们还有两下子，再来！牧野流星！！", 4, 0, 1},
			{"CastSkill", "boss3", 2747, 15, -1, -1},
			{"CastSkill", "boss3", 2747, 15, 2195, 5725},
			{"CastSkill", "boss3", 2747, 15, 2739, 6018},
			{"CastSkill", "boss3", 2747, 15, 2495, 5340},
			{"CastSkill", "boss3", 2747, 15, 2923, 5669},
			{"CastSkill", "boss3", 2747, 15, 2755, 4994},
			{"CastSkill", "boss3", 2747, 15, 3197, 5330},
		},
	},
	[24] = {nTime = 10, nNum = 0,		--结束剧情阶段
		tbPrelock = {21},
		tbStartEvent = 
		{
			--暂停计时
			{"PauseLock", 2},
			{"StopEndTime"},
			{"ChangeTime", -10},

			{"AddNpc", 17, 1, 0, "boss3", "SAVE_POS", false, "SAVE_DIR", 0, 0, 0},
			{"SetAiActive", "boss3", 0},
			{"SetNpcProtected", "boss3", 1},
			{"SetNpcBloodVisable", "boss3", false, 0.1},
			{"NpcBubbleTalk", "boss3", "咳咳，你们厉害，要杀要剐悉听尊便！", 4, 0.5, 1},
			--删除唐影
			{"DelNpc", "npc"},

			--增加唐影护送
			{"AddNpc", 19, 1, 0, "npc", "tangying1", false, 0, 0, 0, 0},
			{"NpcAddBuff", "npc", 2452, 1, 100},
			{"ChangeNpcAi", "npc", "Move", "path1", 0, 0, 0, 0, 0},

			--结束对白剧情
			{"NpcBubbleTalk", "npc", "大家快住手！！", 4, 3, 1},
			{"NpcBubbleTalk", "boss3", "唐大哥，你怎麽来了？", 4, 5, 1},
			{"NpcBubbleTalk", "npc", "水儿，你误会了，他们都是正义之士，刚刚还救了我！", 4, 3, 1},
			{"NpcBubbleTalk", "boss3", "啊...？原来如此，在下给各位赔礼道歉了！", 4, 5, 1},
			{"NpcBubbleTalk", "npc", "你的伤...？？", 4, 7, 1},
			{"NpcBubbleTalk", "boss3", "还是...回去再说吧。", 4, 9, 1},

			--篝火
			{"AddSimpleNpc", 1610, 2772, 5392, 0},

		},
		tbUnLockEvent = 
		{
		},
	},
	[25] = {nTime = 5, nNum = 0,		--结束剧情阶段
		tbPrelock = {24},
		tbStartEvent = 
		{
			--{"NpcRemoveBuff", "npc", 2452},
			{"NpcAddBuff", "boss3", 2452, 1, 100},
			{"SetAiActive", "boss3", 1},
			{"ChangeNpcAi", "npc", "Move", "path2", 0, 0, 0, 1, 0},
			{"ChangeNpcAi", "boss3", "Move", "path2", 0, 0, 0, 1, 0},
			{"NpcBubbleTalk", "npc", "好的！各位少侠後会有期！", 4, 1, 1},
			{"NpcBubbleTalk", "boss3", "得罪了！再会！", 4, 1, 1},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 15},
			{"RemovePlayerSkillState", 2216},
			{"SetFubenProgress", -1,"闯关成功"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 55},
			{"BlackMsg", "闯关成功！篝火已刷出，可持续获得经验！"},
			{"GameWin"},	
		},
	},

	[26] = {nTime = 2, nNum = 0,		--boss1血量解锁前置
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},

	[27] = {nTime = 0, nNum = 1,			--首领1血量解锁事件
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl1", 27, 25},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 4},
			{"NpcBubbleTalk", "sl1", "啊啊...气煞我也！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 13, 6, 0, "gw", "guaiwu3_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 14, 1, 0, "gw1", "guaiwu3_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[28] = {nTime = 0, nNum = 1,			--首领2血量解锁事件
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl2", 28, 30},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 4},
			{"NpcBubbleTalk", "sl2", "没关系...还是...杀掉你们吧！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 13, 6, 0, "gw", "guaiwu3_1", false, 0, 0.5, 9006, 0.5},
			{"AddNpc", 14, 2, 0, "gw1", "guaiwu3_2", false, 0, 0.5, 9010, 0.5},
		},
	},
	[29] = {nTime = 0, nNum = 1,			--首领3血量解锁事件
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl3", 29, 30},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 4},
			{"NpcBubbleTalk", "sl3", "为什麽...习武多年，还收拾不了你们？", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 13, 6, 0, "gw", "guaiwu3_1", false, 0, 0.5, 9007, 0.5},
			{"AddNpc", 14, 1, 0, "gw1", "guaiwu3_2", false, 0, 0.5, 9010, 0.5},
		},
	},
	[30] = {nTime = 0, nNum = 1,			--首领4血量解锁事件
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "sl4", 30, 30},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 4},
			{"NpcBubbleTalk", "sl4", "...今日躺下的不应该是我！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 13, 6, 0, "gw", "guaiwu3_1", false, 0, 0.5, 9008, 0.5},
			{"AddNpc", 14, 2, 0, "gw1", "guaiwu3_2", false, 0, 0.5, 9010, 0.5},
		},
	},


	[31] = {nTime = 1, nNum = 0,		--稀有锁开始
		tbPrelock = {},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "远处似乎有个少女走了过来！"},
			{"AddNpc", 16, 1, 0, "xy", "npc_xy", false, 0, 0, 0, 0},
			{"ChangeNpcAi", "xy", "Move", "path3", 0, 0, 0, 0, 0},
			{"NpcBubbleTalk", "xy", "各位少侠，真是幸会！", 4, 0.5, 1},
			{"NpcBubbleTalk", "xy", "爹爹派耶律辟离来此处干嘛呢？", 4, 3.5, 1},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {31, 10},
		tbStartEvent = 
		{
			{"AddNpc", 15, 1, 32, "gw_xy", "guaiwu_xy", false, 0, 0.5, 9010, 0.5},
			{"NpcBubbleTalk", "gw_xy", "大小姐，教主让我请您回去！", 3, 1.5, 1},
			{"NpcBubbleTalk", "xy", "讨厌！我才不回去！", 3, 3.5, 1},
			{"NpcBubbleTalk", "gw_xy", "各位如果多管闲事，别怪在下不客气了！", 3, 5.5, 1},
			{"NpcBubbleTalk", "xy", "你说，爹爹派你们来此处所为何事？", 3, 7.5, 1},
			{"NpcBubbleTalk", "gw_xy", "自然是来抓唐门和翠烟的那对小情侣了，嘿嘿！", 3, 9.5, 1},
			{"NpcBubbleTalk", "xy", "就凭你们？", 3, 11.5, 1},
			{"NpcBubbleTalk", "gw_xy", "後面自然是还有人的嘛。", 3, 13.5, 1},
			{"NpcBubbleTalk", "xy", "可恶！", 3, 15.5, 1},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "xy", "少侠，你们继续前去救那两位吧，我要原路返回去阻拦援兵。", 4, 0.5, 1},
		},
	},





}