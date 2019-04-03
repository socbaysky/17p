
local tbFubenSetting = {};
Fuben:SetFubenSetting(304, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeamFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "呼啸栈道"										-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/TeamFuben/1_5/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/TeamFuben/1_5/NpcPath.tab"				-- 寻路点								
tbFubenSetting.tbMultiBeginPoint        = {{4244, 1906},{4437, 2006},{4616, 2095},{4804, 2173}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {4216, 2554}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 56;


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
	[1]  = {nTemplate = 2258, nLevel = -1, nSeries = -1},  --阴郁剑客-怪物1
	[2]  = {nTemplate = 2259, nLevel = -1, nSeries = -1},  --愤怒武者-怪物2
	[3]  = {nTemplate = 2260, nLevel = -1, nSeries = -1},  --失魂的傀儡-怪物3
	[4]  = {nTemplate = 2261, nLevel = -1, nSeries = -1},  --丧胆的高手-怪物4
	[5]  = {nTemplate = 2262, nLevel = -1, nSeries = -1},  --污衣浪客-怪物5
	[6]  = {nTemplate = 2263, nLevel = -1, nSeries = -1},  --净衣铁面-怪物6
	[7]  = {nTemplate = 2264, nLevel = -1, nSeries = -1},  --苦难行者-怪物7
	[8]  = {nTemplate = 2265, nLevel = -1, nSeries = -1},  --怨灵-精英1
	[9]  = {nTemplate = 2266, nLevel = -1, nSeries = -1},  --怒灵-精英2
	[10] = {nTemplate = 2267, nLevel = -1, nSeries = -1},  --牵线人-精英3
	[11] = {nTemplate = 2268, nLevel = -1, nSeries = -1},  --掌灯人-精英4
	[12] = {nTemplate = 2269, nLevel = -1, nSeries = -1},  --冷面执棒客-精英5
	[13] = {nTemplate = 2270, nLevel = -1, nSeries = -1},  --独臂拳师-精英6
	[14] = {nTemplate = 2271, nLevel = -1, nSeries = -1},  --托钵者-精英7
	[15] = {nTemplate = 2272, nLevel = -1, nSeries = 2},   --唐仇-boss
	[16] = {nTemplate = 2273, nLevel = -1, nSeries = 2},   --黑面郎君-boss
	[17] = {nTemplate = 2274, nLevel = -1, nSeries = 5},   --何人我-boss
	[18] = {nTemplate = 2275, nLevel = -1, nSeries = 0},   --玄天道人-稀有

	[19] = {nTemplate = 74, nLevel = -1, nSeries = 0},   --上身气流
	[20] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --障碍门

}

tbFubenSetting.LOCK = 
{
	-- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
	[1] = {nTime = 2, nNum = 0,
		--tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
		tbPrelock = {},
		--tbStartEvent 锁激活时的事件
		tbStartEvent = 
		{
			--{"HomeScreenTip", "呼啸栈道", "", 5, 0.5},
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
			{"SetFubenProgress", -1,"探索呼啸栈道"},
			{"SetShowTime", 2},	

			--障碍门
			{"AddNpc", 20, 1, 0, "wall1", "wall1", false, 16, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall2", "wall2", false, 16, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall3", "wall3", false, 32, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall4", "wall4", false, 16, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall5", "wall5", false, 32, 0, 0, 0},
			{"AddNpc", 20, 1, 0, "wall6", "wall6", false, 21, 0, 0, 0},
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
			{"BlackMsg", "此处阴风呼啸，前行时小心为妙！"},
			{"TrapUnlock", "trap1", 3},
			{"SetTargetPos", 3705, 4957},
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
			--区域1
			{"AddNpc", 1, 9, 4, "gw", "guaiwu1_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 8, 1, 4, "jy", "guaiwu1_2", false, 0, 0.5, 9010, 0.5},

			{"BlackMsg", "这些怪物散发着阴冷之气！"},
			{"NpcBubbleTalk", "jy", "呵呵，你们想感受来自地狱的怨恨吗？", 4, 2, 1},
			--{"SetFubenProgress", -1,"击退金国武人"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall1"},
			{"OpenDynamicObstacle", "obs1"},

			{"RaiseEvent", "AddMissionScore", 8},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
			{"BlackMsg", "此处徘徊的敌人为何如此奇怪？"},
			{"TrapUnlock", "trap2", 5},
			{"SetTargetPos", 3721, 9225},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[6] = {nTime = 0, nNum = 10,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域2
			{"AddNpc", 2, 9, 6, "gw", "guaiwu2_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 9, 1, 6, "jy", "guaiwu2_2", false, 0, 0.5, 9010, 0.5},

			{"BlackMsg", "这些人脸上是无尽的疯狂与愤怒！"},
			{"NpcBubbleTalk", "jy", "我的怒火会将你燃烧殆尽！", 4, 2, 1},
			--{"SetFubenProgress", -1,"击退金国武人"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall2"},
			{"OpenDynamicObstacle", "obs2"},

			{"RaiseEvent", "AddMissionScore", 8},
		},
	},

	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"BlackMsg", "这些...敌人...好像不是尘世之物！"},
			{"TrapUnlock", "trap3", 7},
			{"SetTargetPos", 5761, 11862},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[8] = {nTime = 0, nNum = 1,			--boss1
		tbPrelock = {7},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域3
			{"AddNpc", 15, 1, 8, "boss1", "boss1", false, 0, 0.5, 9011, 0.5},

			{"BlackMsg", "唐门掌门？不对！一定是幻觉！"},
			{"NpcBubbleTalk", "boss1", "（愤怒）尔等杀我门人无数，今日让你们有来无回！", 4, 2, 1},
			{"SetFubenProgress", -1,"击败唐仇的幻影"},
		},
		tbUnLockEvent = 
		{
			--重新设置复活点
			{"SetDynamicRevivePoint", 7742, 11744},

			{"DoDeath", "gw"},
			{"DoDeath", "jy"},
			{"DoDeath", "wall3"},
			{"OpenDynamicObstacle", "obs3"},

			{"RaiseEvent", "AddMissionScore", 10},
		},
	},

	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"继续探索呼啸栈道"},
			{"BlackMsg", "唐门掌门武功不会仅止於此，他到底是谁？"},
			{"TrapUnlock", "trap4", 9},
			{"SetTargetPos", 7703, 9077},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[10] = {nTime = 0, nNum = 10,
		tbPrelock = {9},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域4
			{"AddNpc", 3, 8, 10, "gw", "guaiwu4_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 10, 2, 10, "jy", "guaiwu4_2", false, 0, 0.5, 9010, 0.5},

			{"BlackMsg", "这些人似乎又与五毒有些关系！"},
			{"NpcBubbleTalk", "jy", "嘿嘿，你们来得正好，我的傀儡刚好不够用了！", 4, 2, 1},
			--{"SetFubenProgress", -1,"击退金国武人"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall4"},
			{"OpenDynamicObstacle", "obs4"},

			{"RaiseEvent", "AddMissionScore", 8},
		},
	},

	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
			--{"BlackMsg", "此处阴风呼啸，前行时小心为妙！"},
			{"TrapUnlock", "trap5", 11},
			{"SetTargetPos", 7899, 4707},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[12] = {nTime = 0, nNum = 1,			--boss2
		tbPrelock = {11},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域5
			{"AddNpc", 16, 1, 12, "boss2", "boss2", false, 0, 0.5, 9011, 0.5},

			{"BlackMsg", "五毒掌门人？看来确实是某种幻觉了！"},
			{"NpcBubbleTalk", "boss2", "这次本座积累多年的行走傀儡损失惨重，就拿你们来做些补充吧！", 4, 2, 1},
			{"SetFubenProgress", -1,"击败黑面郎君幻影"},
		},
		tbUnLockEvent = 
		{
			--重新设置复活点
			{"SetDynamicRevivePoint", 9813, 4042},

			{"DoDeath", "gw"},
			{"DoDeath", "jy"},
			{"DoDeath", "wall5"},
			{"OpenDynamicObstacle", "obs5"},

			{"RaiseEvent", "AddMissionScore", 10},
		},
	},
	
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
			{"SetFubenProgress", -1,"继续探索呼啸栈道"},
			{"BlackMsg", "五毒掌门也在此处？难道我进入了某种幻境？"},
			{"TrapUnlock", "trap6", 13},
			{"SetTargetPos", 11486, 4466},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[14] = {nTime = 0, nNum = 10,
		tbPrelock = {13},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域6
			{"AddNpc", 5, 5, 14, "gw", "guaiwu6_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 6, 5, 14, "gw", "guaiwu6_2", false, 0, 0.5, 9010, 0.5},

			{"BlackMsg", "这些人似乎是丐帮的？"},
			{"NpcBubbleTalk", "gw", "你们也想欺负我们这些叫花子吗？", 4, 2, 2},
			--{"SetFubenProgress", -1,"击退金国武人"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "wall6"},
			{"OpenDynamicObstacle", "obs6"},

			{"RaiseEvent", "AddMissionScore", 8},

			--稀有几率
			{"Random", {330000, 30}},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {14},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap7", 15},
			{"SetTargetPos", 11432, 9163},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[16] = {nTime = 0, nNum = 10,
		tbPrelock = {15},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			--区域7
			{"AddNpc", 7, 8, 16, "gw", "guaiwu7_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 12, 2, 16, "jy", "guaiwu7_2", false, 0, 0.5, 9010, 0.5},

			{"BlackMsg", "江湖传闻唐门、五毒和丐帮曾在呼啸栈道混战。"},
			{"NpcBubbleTalk", "jy", "我们丐帮中人不是好惹的！", 4, 2, 1},
			--{"SetFubenProgress", -1,"击退金国武人"},
		},
		tbUnLockEvent = 
		{
			{"RaiseEvent", "AddMissionScore", 8},
		},
	},

	[17] = {nTime = 0, nNum = 1,	--轻功
		tbPrelock = {16},
		tbStartEvent = 
		{
			{"BlackMsg", "或许这些都是死者不散的冤魂吧！"},
			{"TrapUnlock", "jump1", 17},
			{"SetTargetPos", 11470, 9754},

			{"AddNpc", 19, 1, 0, "qg", "qinggong", false, 0, 0, 0, 0},
			{"ChangeTrap", "jump1", nil, {11619, 10212, 2}},
			{"ChangeTrap", "jump2", nil, {11274, 10659, 2}},
			{"ChangeTrap", "jump3", nil, {11807, 11370, 2}},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},

	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {17},
		tbStartEvent = 
		{
			{"TrapUnlock", "trap8", 18},
		},
		tbUnLockEvent = 
		{
		},
	},	
	[19] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {18},
		tbStartEvent = 
		{
			--区域8
			{"AddNpc", 17, 1, 19, "boss3", "boss3", false, 0, 0.5, 9011, 0.5},

			{"BlackMsg", "这必然是丐帮掌门曾经的怨气凝聚而成的怪物了！"},
			{"NpcBubbleTalk", "boss3", "丐帮兄弟死去如此之多，我还有何面目独活於世？", 4, 2, 1},
			{"SetFubenProgress", -1,"击败何人我的幻影"},
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "gw"},
			{"DoDeath", "jy"},

			{"AddSimpleNpc", 1610, 12233, 12689, 0},
			{"BlackMsg", "闯关成功！篝火已刷出，可持续获得经验！"},
			{"RaiseEvent", "AddMissionScore", 15},
			{"SetFubenProgress", -1,"闯关成功"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"RaiseEvent", "KickOutAllPlayer", 70},
			{"GameWin"},
		},
	},


-----------------------------------boss血量解锁--------------------------------------
	[20] = {nTime = 1.5, nNum = 0,			--boss1
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[21] = {nTime = 0, nNum = 1,			--boss1
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss1", 21, 70},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "哼...欺负我唐门人少麽？！", 4, 0, 1},
			--{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 1, 9, 0, "gw", "guaiwu3_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 8, 1, 0, "jy", "guaiwu3_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[22] = {nTime = 0, nNum = 1,			--boss1
		tbPrelock = {20},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss1", 22, 30},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss1", "你们彻底激怒了我！", 4, 0, 1},
			--{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 2, 9, 0, "gw", "guaiwu3_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 9, 1, 0, "jy", "guaiwu3_2", false, 0, 0.5, 9009, 0.5},
		},
	},


	[23] = {nTime = 1.5, nNum = 0,			--boss2
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[24] = {nTime = 0, nNum = 1,			--boss2
		tbPrelock = {23},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss2", 24, 50},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss2", "来，看看我的杰作！这些可都曾经是所谓的武林高手呢！！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 4, 8, 0, "gw", "guaiwu5_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 11, 2, 0, "jy", "guaiwu5_2", false, 0, 0.5, 9009, 0.5},
		},
	},

	[25] = {nTime = 1.5, nNum = 0,			--boss3
		tbPrelock = {18},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[26] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {25},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss3", 26, 80},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss3", "我丐帮兄弟遍布四海！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 5, 8, 0, "gw", "guaiwu8_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 12, 2, 0, "jy", "guaiwu8_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[27] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {25},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss3", 27, 50},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss3", "丐帮兄弟没这麽好欺负！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 6, 8, 0, "gw", "guaiwu8_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 13, 2, 0, "jy", "guaiwu8_2", false, 0, 0.5, 9009, 0.5},
		},
	},
	[28] = {nTime = 0, nNum = 1,			--boss3
		tbPrelock = {25},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss3", 28, 25},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss3", "啊啊...气煞我也！", 4, 0, 1},
			{"BlackMsg", "帮手出现，小心应付！"},
			--召唤怪物
			{"AddNpc", 7, 8, 0, "gw", "guaiwu8_1", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 14, 2, 0, "jy", "guaiwu8_2", false, 0, 0.5, 9009, 0.5},
		},
	},

--------------------------------稀有锁开始-------------------------------------------
	[30] = {nTime = 0.5, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{
			{"BlackMsg", "好像有绝世高手出现了！"},
			{"AddNpc", 18, 1, 0, "xy", "xiyou", false, 0, 0.5, 9011, 0.5},
		},
		tbUnLockEvent = 
		{
		},
	},
	[31] = {nTime = 1.5, nNum = 0,
		tbPrelock = {30},
		tbStartEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", -1,"击败玄天道人的幻影"},
		},
		tbUnLockEvent = 
		{
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "xy", 32, 50},
			{"NpcBubbleTalk", "xy", "好大的胆子，尔等居然敢来到此处！？", 3, 1, 1},
			{"NpcBubbleTalk", "xy", "小友们可知这呼啸栈道的掌故？", 3, 4, 1},
			{"NpcBubbleTalk", "xy", "曾经唐门、五毒和丐帮在此处混战三日，血流成河，死伤无数！", 3, 7, 1},
			{"NpcBubbleTalk", "xy", "他们的怨气和愤怒久聚不散，习武之人来到此处必产生幻觉！", 3, 10, 1},
			{"NpcBubbleTalk", "xy", "武功修为不够恐怕会走火入魔。让老夫看看你们是否有资格继续走下去吧！", 3, 13, 1},
		},
		tbUnLockEvent = 
		{
		},
	},
	[33] = {nTime = 2, nNum = 0,
		tbPrelock = {32},
		tbStartEvent = 
		{
			{"SetNpcProtected", "xy", 1},
			{"ChangeNpcFightState", "xy", 0, 0},
			{"SetAiActive", "xy", 0},
			{"SetNpcBloodVisable", "xy", false, 0},

			{"NpcBubbleTalk", "xy", "你们功夫还不错！去吧！我想静静！", 3, 0, 1},

			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/TeamFuben/100fb_xiyou.tab", 12062, 4214},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "玄天道人武艺通神，他到底使出了几层功力呢？"},
			{"SetFubenProgress", -1,"继续探索呼啸栈道"},
			{"SetTargetPos", 11432, 9163},
		},
	},

}