
local tbFubenSetting = {};
Fuben:SetFubenSetting(7001, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "TeachersDayActFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "师徒试炼"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/Shitufuben/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/Shitufuben/NpcPath.tab"			-- 寻路点
tbFubenSetting.szKillBossTip 			= "必须由[FFFE0D]徒弟[-]完成最後一击，打败魔君！"
tbFubenSetting.nKillBossTopDur 			= 7
--因为师徒出生点，复活点不一样，所以配置中不设置这些参数，由脚本控制

tbFubenSetting.ANIMATION = 
{
	[1] = "Scenes/Maps/yw_luoyegu/Main Camera.controller",
}

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2559,	nLevel = -1,	nSeries = -1},	--上官飞龙
	[2] = {nTemplate = 2560,	nLevel = -1,	nSeries = -1},	--大学·幻象
	[3] = {nTemplate = 2561,	nLevel = -1,	nSeries = -1},	--论语·幻象
	[4] = {nTemplate = 2562,	nLevel = -1,	nSeries = -1},	--中庸·幻象
	[5] = {nTemplate = 2563,	nLevel = -1,	nSeries = -1},	--孟子·幻象
	[6] = {nTemplate = 2564,	nLevel = -1,	nSeries = -1},	--诗经·幻象
	[7] = {nTemplate = 2565,	nLevel = -1,	nSeries = -1},	--尚书·幻象
	[8] = {nTemplate = 2566,	nLevel = -1,	nSeries = -1},	--礼记·幻象
	[9] = {nTemplate = 2567,	nLevel = -1,	nSeries = -1},	--周易·幻象
	[10] = {nTemplate = 2568,	nLevel = -1,	nSeries = -1},	--春秋·幻象
	[11] = {nTemplate = 2569,	nLevel = -1,	nSeries = -1},	--礼·幻象
	[12] = {nTemplate = 2570,	nLevel = -1,	nSeries = -1},	--乐·幻象
	[13] = {nTemplate = 2571,	nLevel = -1,	nSeries = -1},	--射·幻象
	[14] = {nTemplate = 2572,	nLevel = -1,	nSeries = -1},	--御·幻象
	[15] = {nTemplate = 2573,	nLevel = -1,	nSeries = -1},	--书·幻象
	[16] = {nTemplate = 2574,	nLevel = -1,	nSeries = -1},	--数·幻象
	[17] = {nTemplate = 2575,	nLevel = -1,	nSeries = -1},	--武林高手
	[18] = {nTemplate = 2576,	nLevel = -1,	nSeries = -1},	--后起之秀
	[19] = {nTemplate = 2577,	nLevel = -1,	nSeries = -1},	--无面魔君
	[20] = {nTemplate = 2578,	nLevel = -1,	nSeries = 0},	--《大学》
	[21] = {nTemplate = 2579,	nLevel = -1,	nSeries = 0},	--《论语》
	[22] = {nTemplate = 2580,	nLevel = -1,	nSeries = 0},	--《中庸》
	[23] = {nTemplate = 2581,	nLevel = -1,	nSeries = 0},	--《孟子》
	[24] = {nTemplate = 2582,	nLevel = -1,	nSeries = 0},	--《孔子》
	[25] = {nTemplate = 2583,	nLevel = -1,	nSeries = 0},	--《平庸》
	[26] = {nTemplate = 2584,	nLevel = -1,	nSeries = 0},	--《中学》
	[27] = {nTemplate = 2585,	nLevel = -1,	nSeries = 0},	--《小学》
	[28] = {nTemplate = 2586,	nLevel = -1,	nSeries = 0},	--《老子》
	[29] = {nTemplate = 2587,	nLevel = -1,	nSeries = 0},	--《孙子兵法》
	[30] = {nTemplate = 2588,	nLevel = -1,	nSeries = 0},	--《诗经》
	[31] = {nTemplate = 2589,	nLevel = -1,	nSeries = 0},	--《尚书》
	[32] = {nTemplate = 2590,	nLevel = -1,	nSeries = 0},	--《礼记》
	[33] = {nTemplate = 2591,	nLevel = -1,	nSeries = 0},	--《周易》
	[34] = {nTemplate = 2592,	nLevel = -1,	nSeries = 0},	--《春秋》
	[35] = {nTemplate = 2593,	nLevel = -1,	nSeries = 0},	--《战国策》
	[36] = {nTemplate = 2594,	nLevel = -1,	nSeries = 0},	--《小雅》
	[37] = {nTemplate = 2595,	nLevel = -1,	nSeries = 0},	--《离骚》
	[38] = {nTemplate = 2596,	nLevel = -1,	nSeries = 0},	--《左传》
	[39] = {nTemplate = 2597,	nLevel = -1,	nSeries = 0},	--《史记》
	[40] = {nTemplate = 2598,	nLevel = -1,	nSeries = 0},	--礼
	[41] = {nTemplate = 2599,	nLevel = -1,	nSeries = 0},	--乐
	[42] = {nTemplate = 2600,	nLevel = -1,	nSeries = 0},	--射
	[43] = {nTemplate = 2601,	nLevel = -1,	nSeries = 0},	--御
	[44] = {nTemplate = 2602,	nLevel = -1,	nSeries = 0},	--书
	[45] = {nTemplate = 2603,	nLevel = -1,	nSeries = 0},	--数
	[46] = {nTemplate = 2604,	nLevel = -1,	nSeries = 0},	--骑
	[47] = {nTemplate = 2605,	nLevel = -1,	nSeries = 0},	--琴
	[48] = {nTemplate = 2606,	nLevel = -1,	nSeries = 0},	--画
	[49] = {nTemplate = 2607,	nLevel = -1,	nSeries = 0},	--棋

	[100] = {nTemplate = 104,		nLevel = -1,	nSeries = 0},	--障碍门
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
			{"SetShowTime", 2},
			{"SetNearbyRange", 10},
		},
	},
	[2] = {nTime = 600, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{

		},
		tbUnLockEvent = 
		{
			{"GameLost"},
		},
	},
	[3] = {nTime = 0.5, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"AddNpc", 1, 1, 0, "zhiyin", "zhiyin",false, 38, 0, 9010, 0},
			{"AddNpc", 100, 5, 0, "wall", "wall_1",false, 24, 0, 0, 0},
			{"AddNpc", 100, 1, 0, "wall", "wall_2",false, 8, 0, 0, 0},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", 10, "捡起《四书》"},
			{"ShowTaskDialog", 40001, false},
			{"SetAiActive", "zhiyin", 0},
			{"SetNpcProtected", "zhiyin", 1},
		},
	},
	[50] = {nTime = 0.1, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetNpcBloodVisable", "zhiyin", false, 0},
		},
	},
---------第一阶段四书部分--------------
	[4] = {nTime = 3, nNum = 0,
		tbPrelock = {3},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			------经书
			{"AddNpc", 20, 1, 5, "dauxe", "daxue",false, 0, 0, 0, 0},
			{"AddNpc", 21, 1, 6, "lunyu", "lunyu",false, 0, 0, 0, 0},
			{"AddNpc", 22, 1, 7, "zhongyong", "zhongyong",false, 0, 0, 0, 0},
			{"AddNpc", 23, 1, 8, "mengzi", "mengzi",false, 0, 0, 0, 0},
			{"AddNpc", 24, 1, 100, "jingshu1", "jingshu1_1",false, 0, 0, 0, 0},
			{"AddNpc", 25, 1, 100, "jingshu1", "jingshu1_2",false, 0, 0, 0, 0},
			{"AddNpc", 26, 1, 100, "jingshu1", "jingshu1_3",false, 0, 0, 0, 0},
			{"AddNpc", 27, 1, 100, "jingshu1", "jingshu1_4",false, 0, 0, 0, 0},
			{"AddNpc", 28, 1, 100, "jingshu1", "jingshu1_5",false, 0, 0, 0, 0},
			{"AddNpc", 29, 1, 100, "jingshu1", "jingshu1_6",false, 0, 0, 0, 0},
			-----经书幻象
			{"AddNpc", 2, 1, 9, "daxue_guai", "daxue_guai",false, 0, 0, 0, 0},
			{"AddNpc", 3, 1, 9, "lunyu_guai", "lunyu_guai",false, 0, 0, 0, 0},
			{"AddNpc", 4, 1, 9, "zhongyong_guai", "zhongyong_guai",false, 0, 0, 0, 0},
			{"AddNpc", 5, 1, 9, "mengzi_guai", "mengzi_guai",false, 0, 0, 0, 0},
			{"NpcAddBuff", "daxue_guai", 2417, 1, 600},
			{"NpcAddBuff", "lunyu_guai", 2417, 1, 600},
			{"NpcAddBuff", "zhongyong_guai", 2417, 1, 600},
			{"NpcAddBuff", "mengzi_guai", 2417, 1, 600},
		},
	},
	[5] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "daxue_guai", 2417},
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "lunyu_guai", 2417},
		},
	},
	[7] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "zhongyong_guai", 2417},
		},
	},
	[8] = {nTime = 0, nNum = 1,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "mengzi_guai", 2417},
		},
	},
---------第一阶段五经部分--------------
	[9] = {nTime = 0, nNum = 4,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "jingshu1"},
			{"SetFubenProgress", 20, "捡起《五经》"},
			{"ShowTaskDialog", 40002, false},
			------经书
			{"AddNpc", 30, 1, 10, "shijing", "shijing",false, 0, 0, 0, 0},
			{"AddNpc", 31, 1, 11, "shangshu", "shangshu",false, 0, 0, 0, 0},
			{"AddNpc", 32, 1, 12, "liji", "liji",false, 0, 0, 0, 0},
			{"AddNpc", 33, 1, 13, "yijing", "yijing",false, 0, 0, 0, 0},
			{"AddNpc", 34, 1, 14, "chunqiu", "chunqiu",false, 0, 0, 0, 0},
			{"AddNpc", 35, 1, 100, "jingshu2", "jingshu2_1",false, 0, 0, 0, 0},
			{"AddNpc", 36, 1, 100, "jingshu2", "jingshu2_2",false, 0, 0, 0, 0},
			{"AddNpc", 37, 1, 100, "jingshu2", "jingshu2_3",false, 0, 0, 0, 0},
			{"AddNpc", 38, 1, 100, "jingshu2", "jingshu2_4",false, 0, 0, 0, 0},
			{"AddNpc", 39, 1, 100, "jingshu2", "jingshu2_5",false, 0, 0, 0, 0},
			-----经书幻象
			{"AddNpc", 6, 1, 15, "shijing_guai", "shijing_guai",false, 0, 0, 0, 0},
			{"AddNpc", 7, 1, 15, "shangshu_guai", "shangshu_guai",false, 0, 0, 0, 0},
			{"AddNpc", 8, 1, 15, "liji_guai", "liji_guai",false, 0, 0, 0, 0},
			{"AddNpc", 9, 1, 15, "yijing_guai", "yijing_guai",false, 0, 0, 0, 0},
			{"AddNpc", 10, 1, 15, "chunqiu_guai", "chunqiu_guai",false, 0, 0, 0, 0},
			{"NpcAddBuff", "shijing_guai", 2417, 1, 600},
			{"NpcAddBuff", "shangshu_guai", 2417, 1, 600},
			{"NpcAddBuff", "liji_guai", 2417, 1, 600},
			{"NpcAddBuff", "yijing_guai", 2417, 1, 600},
			{"NpcAddBuff", "chunqiu_guai", 2417, 1, 600},
		},
	},
	[10] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "shijing_guai", 2417},
		},
	},
	[11] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "shangshu_guai", 2417},
		},
	},
	[12] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "liji_guai", 2417},
		},
	},
	[13] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "yijing_guai", 2417},
		},
	},
	[14] = {nTime = 0, nNum = 1,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "chunqiu_guai", 2417},
		},
	},
---------第一阶段六艺部分--------------	
	[15] = {nTime = 0, nNum = 5,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "jingshu2"},
			{"ShowTaskDialog", 40003, false},
			{"SetFubenProgress", 30, "找出六艺"},
			------经书
			{"AddNpc", 40, 1, 16, "li", "li",false, 0, 0, 0, 0},
			{"AddNpc", 41, 1, 17, "yue", "yue",false, 0, 0, 0, 0},
			{"AddNpc", 42, 1, 18, "she", "she",false, 0, 0, 0, 0},
			{"AddNpc", 43, 1, 19, "yu", "yu",false, 0, 0, 0, 0},
			{"AddNpc", 44, 1, 20, "shufa", "shufa",false, 0, 0, 0, 0},
			{"AddNpc", 45, 1, 21, "shuxue", "shuxue",false, 0, 0, 0, 0},
			{"AddNpc", 46, 1, 100, "jingshu3", "jingshu3_1",false, 0, 0, 0, 0},
			{"AddNpc", 47, 1, 100, "jingshu3", "jingshu3_2",false, 0, 0, 0, 0},
			{"AddNpc", 48, 1, 100, "jingshu3", "jingshu3_3",false, 0, 0, 0, 0},
			{"AddNpc", 49, 1, 100, "jingshu3", "jingshu3_4",false, 0, 0, 0, 0},
			-----经书幻象
			{"AddNpc", 11, 1, 22, "li_guai", "li_guai",false, 0, 0, 0, 0},
			{"AddNpc", 12, 1, 22, "yue_guai", "yue_guai",false, 0, 0, 0, 0},
			{"AddNpc", 13, 1, 22, "she_guai", "she_guai",false, 0, 0, 0, 0},
			{"AddNpc", 14, 1, 22, "yu_guai", "yu_guai",false, 0, 0, 0, 0},
			{"AddNpc", 15, 1, 22, "shufa_guai", "shufa_guai",false, 0, 0, 0, 0},
			{"AddNpc", 16, 1, 22, "shuxue_guai", "shuxue_guai",false, 0, 0, 0, 0},
			{"NpcAddBuff", "li_guai", 2417, 1, 600},
			{"NpcAddBuff", "yue_guai", 2417, 1, 600},
			{"NpcAddBuff", "she_guai", 2417, 1, 600},
			{"NpcAddBuff", "yu_guai", 2417, 1, 600},
			{"NpcAddBuff", "shufa_guai", 2417, 1, 600},
			{"NpcAddBuff", "shuxue_guai", 2417, 1, 600},
		},
	},
	[16] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "li_guai", 2417},
		},
	},
	[17] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "yue_guai", 2417},
		},
	},
	[18] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "she_guai", 2417},
		},
	},
	[19] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "yu_guai", 2417},
		},
	},
	[20] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "shufa_guai", 2417},
		},
	},
	[21] = {nTime = 0, nNum = 1,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "shuxue_guai", 2417},
		},
	},
	[22] = {nTime = 0, nNum = 6,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "jingshu3"},
			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
			{"OpenDynamicObstacle", "obs3"},
			{"AddNpc", 100, 1, 0, "wall", "wall_3",false, 0, 0, 0, 0},
			{"NpcBubbleTalk", "zhiyin", "从今天的表现看来，少侠平时还是下了不少功夫的，那就请随我来吧。", 7, 0, 1},
			{"SetNpcAi", "zhiyin", "Setting/Npc/Ai/fuben/Boss11.ini"},
			{"NpcAddBuff", "zhiyin", 2452, 2, 7},
			{"ChangeNpcAi", "zhiyin", "Move", "path3", 36, 0, 0, 0, 0},
			{"SetTargetPos", 5115, 2853},
		},
	},
	[100] = {nTime = 0, nNum = 100,
		tbPrelock = {1},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[36] = {nTime = 0, nNum = 1,
		tbPrelock = {22},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "zhiyin", "Move", "path1", 23, 0, 0, 0, 0},
		},
	},
--------------第二阶段第一部分------------
	[23] = {nTime = 0, nNum = 2,
		tbPrelock = {22},
		tbStartEvent = 
		{
			{"IfTrapCount", "trap1", -1, {"UnLock", 23}},
		},
		tbUnLockEvent = 
		{
			{"ShowTaskDialog", 40004, false},
		},
	},
	[24] = {nTime = 3, nNum = 0,
		tbPrelock = {23},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcCamp", "zhiyin", 1},
			{"SetFubenProgress", 60, "击败上官飞龙"},
			{"SetNpcBloodVisable", "zhiyin", true, 0},
			{"SetAiActive", "zhiyin", 1},
			{"NpcAddBuff", "zhiyin", 2466, 1, 600},
			{"NpcHpUnlock", "zhiyin", 25, 80},
			{"NpcHpUnlock", "zhiyin", 27, 20},
			{"SetNpcProtected", "zhiyin", 0},
		},
	},
	[25] = {nTime = 0, nNum = 1,
		tbPrelock = {24},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 18, 1, 26, "zhiyu", "zhiyu",false, 0, 0.5, 9010, 0.5,"OnlyStudent"},
		},
	},
	[60] = {nTime = 2, nNum = 0,
		tbPrelock = {25},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "zhiyu", "在下初入江湖，资历尚浅，能否与[FFFE0D]徒弟[-]切磋讨教一番？", 600, 0, 1},
		},
	},
	[26] = {nTime = 0, nNum = 1,
		tbPrelock = {25},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 17, 1, 27, "fantan", "fantan",false, 0, 0.5, 9010, 0.5,"OnlyTeacher"},
		},
	},
	[70] = {nTime = 2, nNum = 0,
		tbPrelock = {26},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "fantan", "行走江湖，从不欺负弱小无辜，想和我过招还是叫[FFFE0D]师父[-]来吧！", 600, 0, 1},
		},
	},
	[27] = {nTime = 0, nNum = 2,
		tbPrelock = {26},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "fantan"},
			{"DoDeath", "zhiyu"},
			{"DoDeath", "wall"},
			{"ChangeNpcCamp", "zhiyin", 0},
			{"SetNpcBloodVisable", "zhiyin", false, 0},	
			{"SetNpcProtected", "zhiyin", 1},
			{"OpenDynamicObstacle", "obs2"},
			{"ShowTaskDialog", 40004, false},
			{"SetTargetPos", 2345, 2459},
			{"NpcAddBuff", "zhiyin", 2452, 2, 15},
			{"ChangeNpcAi", "zhiyin", "Move", "path4", 80, 0, 0, 0, 0},
		},
	},
	[80] = {nTime = 0, nNum = 1,
		tbPrelock = {27},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "zhiyin", "Move", "path2", 28, 0, 0, 0, 0},
		},
	},	
	[28] = {nTime = 0, nNum = 2,
		tbPrelock = {80},
		tbStartEvent = 
		{
			{"IfTrapCount", "trap2", -1, {"UnLock", 28}},
		},
		tbUnLockEvent = 
		{
			{"SetNpcAi", "zhiyin", "Setting/Npc/Ai/Stay.ini"},
			{"SetNpcDir", "zhiyin", 16},
			{"NpcBubbleTalk", "zhiyin", "师者，传道授业解惑也。师父带你入门，随你入世，可偌大江湖，闯荡天涯师父定不能常伴左右。", 7, 0, 1},
			{"AddNpc", 19, 1, 33, "boss", "huanxiang",false, 0, 0.5, 9010, 1,"TopBoss"},
			{"SetFubenProgress", 80, "击败无面魔君"},
		},
	},
	[29] = {nTime = 2, nNum = 0,
		tbPrelock = {28},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcHpUnlock", "boss", 30, 80},
			{"NpcAddBuff", "boss", 2466, 1, 600},
		},
	},
	[30] = {nTime = 0, nNum = 1,
		tbPrelock = {29},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "zhiyin", "师徒也好，侠侣也罢，茫茫江湖相遇人海，想想也是令人艳羡的缘分。", 5, 0, 1},
			{"NpcHpUnlock", "boss", 31, 50},
		},
	},
	[31] = {nTime = 0, nNum = 1,
		tbPrelock = {30},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "zhiyin", "突破自我，修成正果，称一代名侠，还是要靠自己不懈的努力才行。", 5, 0, 1},
			{"NpcHpUnlock", "boss", 32, 20},
		},
	},
	[32] = {nTime = 0, nNum = 1,
		tbPrelock = {31},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "zhiyin", tbFubenSetting.szKillBossTip, tbFubenSetting.nKillBossTopDur, 0, 1},
		},
	},
	[33] = {nTime = 0, nNum = 1,
		tbPrelock = {28},
		tbStartEvent = 
		{				
		},
		tbUnLockEvent = 
		{	
			{"NpcBubbleTalk", "zhiyin", "恭喜你们成功通过了师徒试炼！", 7, 0, 1},
		},
	},
	[34] = {nTime = 2.1, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
			{"SetGameWorldScale", 0.1},		-- 慢镜头开始
		},
		tbUnLockEvent = 
		{
			{"SetGameWorldScale", 1},		-- 慢镜头结束
			{"GameWin"},
		},
	},
}

