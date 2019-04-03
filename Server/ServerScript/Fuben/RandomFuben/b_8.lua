
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("b_8");

tbFubenSetting.tbMultiBeginPoint = {{5423, 5564},{5653, 5379},{5227, 5366},{5450, 5165}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {5423, 5564}
tbFubenSetting.nStartDir		 = 38;


--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 774, nLevel = -1, nSeries = 0},    --杨影枫-护送
	[2] = {nTemplate = 810, nLevel = -1, nSeries = 0},    --杨影枫-对话
	[3] = {nTemplate = 811, nLevel = -1, nSeries = -1},    --心魔-首领
	[4] = {nTemplate = 812, nLevel = -1, nSeries = -1},    --恐惧图腾-标识npc
	[5] = {nTemplate = 813, nLevel = -1, nSeries = -1},    --恐惧幻象-免控npc
	[6] = {nTemplate = 814, nLevel = -1, nSeries = -1},    --恐惧实体-召唤精英
	[7] = {nTemplate = 104, nLevel = -1, nSeries = 0},    --墙
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
		    {"AddNpc", 7, 2, 0, "wall_1", "wall_1_1",false, 24},
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
			{"SetFubenProgress", 0, "探索凌绝峰"},

			--临时NPC（杨影枫）
		    {"AddNpc", 1, 1, 0, "Temporary", "RandomFuben2_8_Temporary",false, 30},
			{"OpenDynamicObstacle", "obs"},
			{"ChangeFightState", 1},
			{"DoDeath", "wall_1"},
			{"SetTargetPos", 4860, 4805},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{	
			{"ClearTargetPos"},
			{"ChangeNpcAi", "Temporary", "Move", "Path1", 5, 0, 0, 1, 0},
			{"NpcBubbleTalk", "Temporary", "此地让我想起在忘忧岛闯心魔阵时的情况，去前面看看吧！", 4, 1, 1},
			{"BlackMsg", "居然在这里遇到了悲魔山庄的杨影枫！"},
			{"SetFubenProgress", 20, "跟随杨影枫"},
			{"SetTargetPos", 3260, 2959},
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{	
			{"TrapUnlock", "TrapLock2", 4},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{	
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "Yangyingfeng", "RandomFuben2_8_Yangyingfeng", false, 30},
			{"NpcBubbleTalk", "Yangyingfeng", "就是这里了，我来告诉你们遭遇心魔时的感受吧！", 4, 1, 1},
		},
	},
	[6] = {nTime = 3, nNum = 0,     --等待BOSS时间
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"AddNpc", 3, 1, 8, "BOSS", "RandomFuben2_8_BOSS", false, 0, 1, 9011, 1},
			{"BlackMsg", "心魔出现，挑战试试看吧！"},
			{"SetFubenProgress", 50, "击败心魔"},
			{"NpcBubbleTalk", "Yangyingfeng", "小心应付，我会提醒你们的！", 4, 0, 1},
		},
	},
	[7] = {nTime = 3, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{            
   		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 30, 70},
		},
	},
------------------------------------流程阶段------------------------------
----------------------阶段1---------------------------	
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "BOSS", 40, 30},
		    {"AddNpc", 5, 2, 31, "Summon_1", "RandomFuben2_8_Summon", false, 0},
		    {"NpcBubbleTalk", "BOSS", "直面自己内心的恐惧吧！！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐惧幻象出现了，小心应付！！！", 3, 1, 1},
			{"BlackMsg", "[FFFE0D]恐惧幻象[-]出现，请尽速将其[FFFE0D]击杀[-]！！"},		
			{"ChangeNpcAi", "Summon_1", "Move", "Path2", 32, 0, 0, 1, 0},	
		},
	},
	[31] = {nTime = 0, nNum = 2,
		tbPrelock = {30},
		tbStartEvent = 
		{		    
		},
		tbUnLockEvent = 
		{	
		    {"NpcBubbleTalk", "BOSS", "不要高兴得太早！", 4, 0, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "就是这样，在恐惧幻象召唤怪物前击退它。", 4, 0, 1},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{            
   		},
		tbUnLockEvent = 
		{
		    {"DelNpc", "Summon_1"},
		    {"AddNpc", 6, 1, 0, "Elite_1", "RandomFuben2_8_BOSS", false, 0, 1, 9011, 1},
		    {"NpcBubbleTalk", "Elite_1", "啊啊啊，我变强大了！", 3, 4, 1},
		    {"NpcBubbleTalk", "BOSS", "向恐惧臣服吧！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐惧实体出现了，小心应付吧！!", 4, 1, 1},
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
			{"AddNpc", 5, 2, 41, "Summon_2", "RandomFuben2_8_Summon", false, 0},
		    {"NpcBubbleTalk", "BOSS", "更大的恐惧来临了！", 3, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐惧幻象来了，小心行事！！", 3, 1, 1},
			{"BlackMsg", "[FFFE0D]恐惧幻象[-]出现，请尽速将其[FFFE0D]击杀[-]！！"},		
			{"ChangeNpcAi", "Summon_2", "Move", "Path2", 42, 0, 0, 1, 0},
		},
	},
	[41] = {nTime = 0, nNum = 2,
		tbPrelock = {40},
		tbStartEvent = 
		{		    
		},
		tbUnLockEvent = 
		{	
		    {"NpcBubbleTalk", "BOSS", "不，我不信你们能抵御心魔！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "接下来只要干掉这个心魔就行了！", 4, 1, 1},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{            
   		},
		tbUnLockEvent = 
		{
		    {"DelNpc", "Summon_2"},
		    {"AddNpc", 6, 1, 0, "Elite_2", "RandomFuben2_8_BOSS", false, 0, 1, 9011, 1},
		    {"NpcBubbleTalk", "Elite_2", "啊啊啊，我变强大了！", 3, 4, 1},
		    {"NpcBubbleTalk", "BOSS", "向恐惧臣服吧！", 4, 1, 1},
			{"NpcBubbleTalk", "Yangyingfeng", "恐惧实体出现了，小心应付吧！", 4, 1, 1},
		},
	},

-------------胜利判定------------------------
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			--掉落房间奖励
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2898, 2890},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 3189, 2915},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 2906, 2632},
			{"RaiseEvent", "DropAward", "Setting/Fuben/RandomFuben/HouseAward/B.tab", 3189, 2636},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_win"},
			
			{"SetFubenProgress", 100, "击败心魔"},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},  
		},
	},
-------------闯关时间------------------------
	[9] = {nTime = "b_8_time", nNum = 0,     --总计时
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 9},
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "b_score_lost"},

			{"BlackMsg", "心魔果然不是好对付的，我们还是不挑战了吧！"},
			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}
