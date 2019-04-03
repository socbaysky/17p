
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_2");

tbFubenSetting.tbMultiBeginPoint = {{2298, 1518},{2615, 1524},{2292, 1192},{2594, 1192}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {2434, 1333};
tbFubenSetting.nStartDir		 = 1;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 643, nLevel = -1, nSeries = -1}, --苏家家丁
	[2] = {nTemplate = 1552,nLevel = -1, nSeries = -1}, --苏墨芸(BOSS)
	[3] = {nTemplate = 646, nLevel = -1, nSeries = -1}, --慕容越(BOSS)
	[4] = {nTemplate = 645, nLevel = -1, nSeries = 0},  --苏墨芸(对话NPC)
	[5] = {nTemplate = 644, nLevel = -1, nSeries = 0},  --慕容越(对话NPC)
	[6] = {nTemplate = 104, nLevel = -1, nSeries = 0},  --动态障碍墙
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
			{"SetFubenProgress", -1,"等待秘境开启"},
			{"AddNpc", 6, 2, 1, "wall_1", "wall_1_1",false, 16},
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
			{"DoDeath", "wall_1"},
			{"AddNpc", 6, 1, 1, "wall_2", "wall_1_2",false, 17},
			{"OpenDynamicObstacle", "ops1"},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetTargetPos", 2445, 2683},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 20, "击退苏家家丁"},

			--苏家家丁
			{"AddNpc", 1, 3, 4, "guaiwu", "RandomFuben2_2_1_1",false, 0, 0, 0, 0},
			{"AddNpc", 1, 4, 4, "guaiwu", "RandomFuben2_2_1_2",false, 0, 3, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "你们是什麽人？这後山已经被我家小姐承包了，闲杂人等赶紧滚出去！", 5, 1, 1},	

		},
	},
	[4] = {nTime = 0, nNum = 7,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "探索凌绝峰"},
			{"SetTargetPos", 2076, 4803},
			{"OpenDynamicObstacle", "ops2"},
			{"DoDeath", "wall_2"},
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
			{"SetFubenProgress", 40, "击退苏家家丁"},

			--苏家家丁
			{"AddNpc", 1, 3, 6, "guaiwu", "RandomFuben2_2_2_1",false, 0, 0, 0, 0},
			{"AddNpc", 1, 4, 6, "guaiwu", "RandomFuben2_2_2_2",false, 0, 3, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "不好，有人来捣乱了！赶紧去通报小姐！", 5, 1, 1},	
		},
	},
	[6] = {nTime = 0, nNum = 7,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 60, "探索凌绝峰"},
			{"SetTargetPos", 4225, 4573},

			--展示NPC
			{"AddNpc", 4, 1, 0, "Temporary1", "RandomFuben2_2_BOSS", false, 13, 0, 0, 0},
			{"AddNpc", 5, 1, 0, "Temporary2", "RandomFuben2_2_murongyue", false, 13, 0, 0, 0},	
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock3", 7},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"SetFubenProgress", 70, "偷听对话"},
			{"BlackMsg", "那不是苏墨芸和慕容越吗？他们在这里做什麽？"},
	
			{"NpcBubbleTalk", "Temporary1", "这凌绝峰内宝物众多，也不知道这次会有什麽收获，当真是期待啊！", 5, 0, 1},	
			{"NpcBubbleTalk", "Temporary2", "有我慕容越在，这凌绝峰的宝物还不是手到擒来！", 5, 1, 1},
		},
	},
	[8] = {nTime = 3, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "击退苏墨芸"},	
			{"DelNpc", "Temporary1"},
			{"DelNpc", "Temporary2"},
			{"AddNpc", 2, 1, 15, "BOSS1", "RandomFuben2_2_BOSS", false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 12, "BOSS2", "RandomFuben2_2_murongyue", false, 0, 0, 0, 0},	
			{"BlackMsg", "糟糕，被发现了！"},
			{"NpcBubbleTalk", "BOSS1", "你们这群家伙三番四次坏本姑娘的兴致！今日我就要好好的教训你们！", 5, 0.5, 1},	
			{"NpcBubbleTalk", "BOSS2", "没错，就让我们一起教训这群不知好歹的家伙！", 5, 1, 1},
		},
	},
	[9] = {nTime = 3, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "BOSS1", 10, 70},
			{"BlackMsg", "提示：请优先击杀苏墨芸！"},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS1", "慕容越，你没吃饱饭啊！就这麽点力气怎麽教训他们！", 5, 0.5, 1},	
			{"NpcBubbleTalk", "BOSS2", "可.. 可恶，你们准备好受死吧！", 5, 0.5, 1},	
			{"NpcHpUnlock", "BOSS1", 11, 30},		
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {10},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS1", "可恶！慕容越你这废物，连这群人都收拾不了！", 5, 0.5, 1},	
			{"NpcBubbleTalk", "BOSS2", "手... 手下留情啊！千万不要打脸！！", 5, 0.5, 1},		
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS1", "可恶！慕容越你这废物，还不快给老娘起来！", 5, 1, 1},	
			{"AddNpc", 3, 1, 13, "BOSS2", "RandomFuben2_2_murongyue", false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS2", "好... 好... 我马上起来！", 5, 2.5, 1},		
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {12},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS1", "可恶！慕容越你这废物，还不快给老娘起来！", 5, 1, 1},	
			{"AddNpc", 3, 1, 14, "BOSS2", "RandomFuben2_2_murongyue", false, 0, 1, 9011, 1},
			{"NpcBubbleTalk", "BOSS2", "好... 好... 我马上起来！", 5, 2.5, 1},		
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {13},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS1", "没用的东西！等着回去跪算盘吧！", 5, 1, 1},	
		},
	},
-------------胜利判定------------------------
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败苏墨芸"},	
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},

			{"GameWin"},
		},
	},
-------------闯关时间------------------------	
	[16] = {nTime = "b_2_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 16},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "这苏墨芸真是厉害，还是赶紧离去为妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

