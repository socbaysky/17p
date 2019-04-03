
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("a_8");

tbFubenSetting.tbMultiBeginPoint = {{1396, 1577},{1628, 1374},{1203, 1374},{1467, 1159}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1479, 1381}
tbFubenSetting.nStartDir		 = 8;	


--NPC模版ID，NPC等级，NPC五行；

--[[

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 262, nLevel = -1,  nSeries = 0},  --沐紫衣
	[2] = {nTemplate = 1313, nLevel = -1, nSeries = -1},  --山贼
	[3] = {nTemplate = 1314, nLevel = -1, nSeries = -1},  --顾武
	[4] = {nTemplate = 104, nLevel = -1,  nSeries = 0},  --动态障碍墙
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
			{"AddNpc", 4, 2, 1, "wall", "wall_1_1",false, 23},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第一层 竹林小道"},
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
			{"ShowTaskDialog", 10000, false},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},			

			--沐紫衣
			{"AddNpc", 1, 1, 10, "npc", "RandomFuben1_8_muziyi",false, 0 , 0, 0, 0},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{			
			{"ChangeFightState", 1},
			{"TrapUnlock", "TrapLock1", 3},
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"SetTargetPos", 2058, 1865},
		},
		tbUnLockEvent = 
		{			
			{"SetFubenProgress", 20, "击退山贼"},
			{"BlackMsg", "这不是沐姑娘吗？看样子她似乎遭遇了些麻烦！"},
			{"ClearTargetPos"},

			--山贼
			{"AddNpc", 2, 5, 4, "guaiwu", "RandomFuben1_8_1",false, 0 , 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "小屁孩，总算是抓到你了！乖乖跟我们回去吧！", 4, 1, 1},	
		},
	},
	[4] = {nTime = 0, nNum = 5,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 40, "护送沐紫衣"},
			{"BlackMsg", "护送沐紫衣离开此地！"},
			{"NpcBubbleTalk", "npc", "嘻嘻，居然是你们啊，那就麻烦你们带我离开这里啦！", 4, 1, 1},	
			{"ChangeNpcAi", "npc", "Move", "Path1", 0, 0, 0, 0, 0},
			{"SetTargetPos", 4648, 2406},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 2750, 2415},
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
			{"SetFubenProgress", 60, "击退山贼"},		
			{"ClearTargetPos"},

			--山贼
			{"AddNpc", 2, 5, 6, "guaiwu", "RandomFuben1_8_2",false, 0 , 0, 0, 0},
			{"NpcBubbleTalk", "guaiwu", "你们是什麽人，莫非是那小屁孩的同夥不成？", 4, 1, 1},	
			{"NpcBubbleTalk", "npc", "这群山贼真是可恶，竟敢欺负本姑娘！你们要好好教训他们一顿哦！", 4, 3, 1},
		},
	},
	[6] = {nTime = 0, nNum = 5,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 80, "击退山贼头目"},

			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5318, 2784},			

			--山贼头目 & 山贼			
			{"AddNpc", 3, 1, 7, "BOSS", "RandomFuben1_8_BOSS",false, 0 , 1, 9011, 1},
			{"AddNpc", 2, 4, 7, "guaiwu", "RandomFuben1_8_3",false, 0 , 2, 9004, 0.5},
			{"NpcBubbleTalk", "BOSS", "小屁孩，戏弄完我们就想走？哪有这麽容易的事情！", 4, 2, 1},
			{"NpcBubbleTalk", "npc", "这群山贼真是可恶，竟敢欺负本姑娘！你们要好好教训他们一顿哦！", 4, 4, 1},
		},
	},
	[7] = {nTime = 0, nNum = 5,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5967, 2796},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/A.tab", 5900, 2900},
			{"NpcBubbleTalk", "npc", "你们还真是厉害啊！几下就把这群山贼给打的流落花流水！", 4, 1, 1},
			{"RaiseEvent", "AddMissionScore", 12},
			{"SetFubenProgress", 100, "击退山贼"},	
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
	[8] = {nTime = 90, nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "这群山贼还真是厉害啊！赶紧撤退为妙！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"RaiseEvent", "AddMissionScore", 8},
			{"GameLost"},
		},
	},
	[9] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "糟糕！沐姑娘有危险了！"},
			{"NpcBubbleTalk", "npc", "哎呀，你真是没用！本姑娘先闪了！", 5, 0, 1},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},
}

