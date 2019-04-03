
local tbFubenSetting = Fuben.RandomFuben:GetRandomFubenSetting("d_9");

tbFubenSetting.tbMultiBeginPoint = {{941, 1201},{1241, 942},{1249, 1473},{1521, 1169}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint = {1137, 1117};
tbFubenSetting.nStartDir		 = 8;


--NPC模版ID，NPC等级，NPC五行；

--[[

447  霹雳火

]]

tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 1582, nLevel = -1, nSeries = -1}, --张如梦-首领
	[2] = {nTemplate = 104,  nLevel = -1, nSeries = 0},  --动态障碍墙
	[3] = {nTemplate = 1623, nLevel = -1, nSeries = -1}, --蝎子
	[4] = {nTemplate = 1867, nLevel = -1, nSeries = -1}, --流浪剑客
	[5] = {nTemplate = 1369, nLevel = -1, nSeries = -1}, --神射手
	[6] = {nTemplate = 1868, nLevel = -1, nSeries = -1}, --红衣剑客
	[7] = {nTemplate = 1869, nLevel = -1, nSeries = -1}, --苗疆女子
	[8] = {nTemplate = 1870, nLevel = -1, nSeries = -1}, --天机工匠
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
			{"SetNearbyRange", 6},

			--调整摄像机基础参数
			{"ChangeCameraSetting", 28, 35, 20},

			{"SetFubenProgress", -1,"等待秘境开启"},
			{"AddNpc", 2, 2, 1, "wall", "wall_1_1",false, 24},
			{"OpenWindow", "LingJueFengLayerPanel", "Info",3, 9, "第四层 峰顶雪松岭"},
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
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "ops1"},
			{"SetTargetPos", 2466, 2403},
		},
	},
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"ChangeFightState", 1},
			{"SetFubenProgress", 0, "探索凌绝峰"},
			{"TrapUnlock", "TrapLock1", 3},

			--张如梦
			{"AddNpc", 1, 1, 7, "BOSS", "RandomFuben4_9_BOSS", false, 36, 0, 0, 0},	
			{"NpcHpUnlock", "BOSS", 30, 85},
			{"SetNpcProtected", "BOSS", 1},
			{"SetAiActive", "BOSS", 0},
			{"SetNpcBloodVisable", "BOSS", false, 1},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},			
			{"NpcBubbleTalk", "BOSS", "没想到竟会在这淩绝峰碰到你们，张某与诸位还真是颇有缘分！", 3, 0, 1},				
		},
	},
	[4] = {nTime = 3, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "闲来无事不如我们来切磋一下武艺吧！", 3, 0, 1},	
			{"DoCommonAct", "BOSS", 6, 0, 0, 0},
		},
	},
	[5] = {nTime = 2, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"PlayerBubbleTalk", "那就请张兄赐招吧！！"},
		},
	},
	[6] = {nTime = 1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"SetNpcProtected", "BOSS", 0},
			{"SetAiActive", "BOSS", 1},
			{"SetNpcBloodVisable", "BOSS", true, 0},
			{"SetFubenProgress", 50, "击败张如梦"},
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
			--每场战斗会出现不同的助战NPC
			{"Random", {500000, 31},{500000, 35}},

			{"NpcBubbleTalk", "BOSS", "痛快！！与你们的战斗果然酣畅淋漓！！", 4, 1, 1},		
			{"NpcHpUnlock", "BOSS", 40, 60},
		},
	},
	[31] = {nTime = 0.1, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Elite", "哈哈哈，有架打怎麽能少得了我！张大哥，兄弟们来助你一臂之力！！！", 4, 3, 1},
			{"NpcBubbleTalk", "Elite", "没想到你们还有点本事，那麽让你们看看我秘术的威力吧！！", 4, 6, 1},
			{"AddNpc", 6, 1, 34, "Elite", "RandomFuben4_9_Elite1", false, 0, 1, 9011, 1},
			{"AddNpc", 4, 6, 0, "guaiwu", "RandomFuben4_9_Jianke", false, 0, 4, 9008, 0.5},
			{"AddNpc", 5, 3, 0, "guaiwu", "RandomFuben4_9_Shensheshou", false, 0, 4, 9008, 0.5},
		},
	},
	[32] = {nTime = 2, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{				
			{"BlackMsg", "[FFFE0D]江湖侠士[-]前来助阵，请各位小心应对！！"},
		},
	},
	[33] = {nTime = 7, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "这股力量.... 我感觉到自己坚若磐石！！！", 4, 0, 1},	
			{"NpcAddBuff", "BOSS", 1509, 1, 150},
			{"BlackMsg", "击败[FFFE0D]红衣剑客[-]，阻止其释放秘术强化张如梦！"},
		},
	},
	[34] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcRemoveBuff", "BOSS", 1509},
		},
	},
	[35] = {nTime = 0.1, nNum = 0,
		tbPrelock = {},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "Elite", "张大哥莫慌，小女子前来助你一臂之力！！！", 4, 3, 1},
			{"NpcBubbleTalk", "Elite", "让你们见识一下我苗疆蛊术的威力！！", 4, 7, 1},
			{"AddNpc", 7, 1, 38, "Elite", "RandomFuben4_9_Elite2", false, 0, 1, 9011, 1},
		},
	},
	[36] = {nTime = 2, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"BlackMsg", "[FFFE0D]苗疆女子[-]前来助阵，请各位小心应对！！"},
		},
	},
	[37] = {nTime = 7, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "BOSS", "这就是苗疆的蛊术吗？当真是神奇！！", 4, 3, 1},	
			{"NpcAddBuff", "BOSS", 1881, 10, 150},
			{"BlackMsg", "尽速击杀[FFFE0D]苗疆女子[-]，阻止其释放蛊术！"},
		},
	},
	[38] = {nTime = 0, nNum = 1,
		tbPrelock = {35},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcRemoveBuff", "BOSS", 1881},

			--如果苗疆女子被提前杀死则关闭刷蝎子的锁	
			{"CloseLock", 39}, 
		},
	},
	[39] = {nTime = 15, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			--召唤蝎子
			{"AddNpc", 3, 8, 0, "guaiwu", "RandomFuben4_9_Xiezi", false, 0, 0, 9008, 0.5},
			{"NpcBubbleTalk", "Elite", "尝尝我苗疆蛊虫的威力吧！", 4, 0, 1},
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
			{"NpcHpUnlock", "BOSS", 50, 30},	

			{"NpcBubbleTalk", "Elite_1", "张兄弟莫慌，兄弟前来助阵了！！", 4, 3, 1},
			{"NpcBubbleTalk", "Elite_1", "让你们见识一下我天机坊秘术的威力吧！！", 4, 6, 1},
			{"AddNpc", 8, 1, 42, "Elite_1", "RandomFuben4_9_Elite3", false, 0, 1, 9011, 1},			
		},
	},
	[41] = {nTime = 6, nNum = 0,
		tbPrelock = {40},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "BOSS", "天机坊的秘术当真厉害，我感觉体内充满了洪荒之力！！", 4, 1, 1},

			--加攻击力BUFF
			{"NpcAddBuff", "BOSS", 2946, 1, 150},
			{"BlackMsg", "尽速击杀[FFFE0D]天机工匠[-]，阻止其释放秘术！"},
		},
	},
	[42] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{		
		},
		tbUnLockEvent = 
		{	
			{"NpcRemoveBuff", "BOSS", 2946},	
		},
	},
----------------------阶段3---------------------------
	[50] = {nTime = 0, nNum = 1,
		tbPrelock = {40},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{	
			{"NpcHpUnlock", "BOSS", 200, 5},	
			{"NpcHpUnlock", "BOSS", 60, 1},	
			{"NpcBubbleTalk", "BOSS", "没想到诸位武艺竟如此高强，张某可要全力以赴了！！", 4, 1, 1},	

			--火焰光环
			{"NpcAddBuff", "BOSS", 2944, 15, 150},
		},
	},
----------------------结束剧情---------------------------
	[60] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败张如梦"},			
			{"NpcBubbleTalk", "BOSS", "哈哈哈，诸位武艺高强，张某甘拜下风！！", 3, 0, 1},
			{"NpcBubbleTalk", "BOSS", "张某还有要事要办，就不在此处耽搁了，咱们就在此别过！", 3, 3, 1},	
			{"NpcBubbleTalk", "BOSS", "青山不改绿水长流，咱们後会有期！", 3, 6, 1},		
			{"NpcRemoveBuff", "BOSS", 2944},	
			{"SetNpcProtected", "BOSS", 1},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetAiActive", "BOSS", 0},	

			{"StopEndTime"},

			--加副本后台时间
			{"ChangeTime", -10},

			--秒杀小兵
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"CastSkill", "Elite", 3, 1, -1, -1},
			{"CastSkill", "Elite_1", 3, 1, -1, -1},
		},
	},
	[61] = {nTime = 4, nNum = 0,
		tbPrelock = {60},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "张兄一路保重！"},

			--BOSS加跑速
			{"NpcAddBuff", "BOSS", 2452, 1, 10},
			{"ChangeNpcAi", "BOSS", "Move", "Path1", 62, 0, 0, 0, 1},
			{"SetAiActive", "BOSS", 1},	
		},
	},
	[62] = {nTime = 0, nNum = 1,
		tbPrelock = {61},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 7}, 
		},
	},
----------------------结束剧情的倒计时---------------------------
	[70] = {nTime = 6, nNum = 0,
		tbPrelock = {60},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 7}, 
		},
	},
----------------------保险锁---------------------------
	[200] = {nTime = 0, nNum = 1,
		tbPrelock = {50},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[201] = {nTime = 10, nNum = 0,
		tbPrelock = {200},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 60}, 
		},
	},
------------胜利判定------------------------
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 100, "击败张如梦"},

			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_win"},

			{"ResumeLock", 8},
			{"SetShowTime", 8},
			
			--房间掉落——张如梦
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/zhangrumeng.tab", 2666, 2885},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/zhangrumeng.tab", 2936, 2707},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/zhangrumeng.tab", 2463, 2652},
			{"RaiseEvent", "DropAward", "Setting/Npc/DropFile/RandomFuben/House_D/zhangrumeng.tab", 2721, 2483},
			{"OpenWindow", "LingJueFengLayerPanel", "Win"},
			{"GameWin"},
		},
	},
-------------闯关时间------------------------

	[8] = {nTime = "d_9_time", nNum = 0,
		tbPrelock = {2},
		tbStartEvent = 
		{
			{"SetShowTime", 8},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "张如梦的武艺果真非同凡响！"},
			{"NpcBubbleTalk", "BOSS", "看来这场比比试，是张某略胜一筹！", 3, 0, 1},
			{"NpcBubbleTalk", "BOSS", "张某还有要事要办，就不在此处耽搁了，咱们就在此别过！", 3, 3, 1},	
			{"NpcRemoveBuff", "BOSS", 2944},	
			{"SetNpcProtected", "BOSS", 1},
			{"ChangeNpcFightState", "BOSS", 0, 0},
			{"SetNpcBloodVisable", "BOSS", false, 0},
			{"SetAiActive", "BOSS", 0},	

			--秒杀小兵
			{"CastSkill", "guaiwu", 3, 1, -1, -1},
			{"CastSkill", "Elite", 3, 1, -1, -1},
			{"CastSkill", "Elite_1", 3, 1, -1, -1},
		},
	},
	[9] = {nTime = 4, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--BOSS加跑速
			{"NpcAddBuff", "BOSS", 2452, 1, 10},
			{"ChangeNpcAi", "BOSS", "Move", "Path1", 62, 0, 0, 0, 1},
			{"SetAiActive", "BOSS", 1},	
		},
	},
	[10] = {nTime = 6, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--判断模式获得积分
			{"RaiseEvent", "AddMissionScore", "d_score_lost"},

			{"OpenWindow", "LingJueFengLayerPanel", "Fail"},
			{"GameLost"},
		},
	},

}

