
local tbFubenSetting = {};
Fuben:SetFubenSetting(7003, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "WomenDayActFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "通幽曲径"										-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/WomensdayFuben/NpcPos.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/WomensdayFuben/NpcPath.tab"				-- 寻路点								
tbFubenSetting.tbMultiBeginPoint        = {{3217, 839}, {3393, 953}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {3293, 918}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 56;

--NPC模版ID，NPC等级，NPC五行；
tbFubenSetting.NPC = 
{
	[1] = {nTemplate = 2880,	nLevel = -1,	nSeries = 0},     ---毒水陷阱
	[2] = {nTemplate = 2881,	nLevel = -1,	nSeries = 0},     ---指引圈
	[3] = {nTemplate = 1800,    nLevel = -1,    nSeries = -1},    --放技能NPC
	[4] = {nTemplate = 2883,    nLevel = -1,    nSeries = 0},    --boss
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
			{"AddNpc", 1, 34, 0, "dushui", "dushui", false, 0, 0, 0, 0},
			{"AddNpc", 100, 1, 0, "wall", "wall",false, 32},
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
	[3] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetTargetPos", 2643, 1719},
			{"TrapUnlock", "TrapLock1", 3},
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"MoveCameraToPosition", 4, 2, 2043, 3243, 10},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
			{"OpenDynamicObstacle", "obs2"},
		},
	},
	[4] = {nTime = 2.5, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"LeaveAnimationState", true},
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false},
			
		},
	},
	[5] = {nTime = 1, nNum = 0,
		tbPrelock = {4},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"PlayerBubbleTalk", "前方陷阱密布，这可如何是好？"},
		},
	},
	[6] = {nTime = 1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"ShowTaskDialog", 3501, false},
		},
	},
-------------------第一区域循环----------------
	[31] = {nTime = 0.5, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin1_1", "zhiyin1_1", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin1_1", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[32] = {nTime = 2, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin1_1"},
		},
	},
	[33] = {nTime = 3, nNum = 0,
		tbPrelock = {31},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin1_2", "zhiyin1_2", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin1_2", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[34] = {nTime = 2, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin1_2"},
		},
	},
	[35] = {nTime = 3, nNum = 0,
		tbPrelock = {33},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin1_3", "zhiyin1_3", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin1_3", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[36] = {nTime = 2, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin1_3"},
		},
	},
	[37] = {nTime = 3, nNum = 0,
		tbPrelock = {35},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin1_4", "zhiyin1_2", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin1_4", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[38] = {nTime = 2, nNum = 0,
		tbPrelock = {37},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin1_4"},
		},
	},
	[7] = {nTime = 0.5, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_1_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin1_1", "zhiyin1_1", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin1_1", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[8] = {nTime = 2, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_1_2", 12, -1, {"DoDeath", "zhiyin1_1"}},
		},
	},
	[9] = {nTime = 3, nNum = 0,
		tbPrelock = {7},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_2_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin1_2", "zhiyin1_2", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin1_2", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[10] = {nTime = 2, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_2_2", 12, -1, {"DoDeath", "zhiyin1_2"}},
		},
	},
	[11] = {nTime = 3, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_3_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin1_3", "zhiyin1_3", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin1_3", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[12] = {nTime = 2, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_3_2", 12, -1, {"DoDeath", "zhiyin1_3"}},
		},
	},
	[13] = {nTime = 3, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_4_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin1_4", "zhiyin1_2", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin1_4", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[14] = {nTime = 2, nNum = 0,
		tbPrelock = {13},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_1_4_2", 12, -1, {"DoDeath", "zhiyin1_4"}},
		},
	},
-------------------第二区域循环---------------------
	[41] = {nTime = 0.5, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin2_1", "zhiyin2_1", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin2_1", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[42] = {nTime = 2, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin2_1"},
		},
	},
	[43] = {nTime = 3, nNum = 0,
		tbPrelock = {41},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin2_2", "zhiyin2_2", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin2_2", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[44] = {nTime = 2, nNum = 0,
		tbPrelock = {43},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin2_2"},
		},
	},
	[45] = {nTime = 3, nNum = 0,
		tbPrelock = {43},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin2_3", "zhiyin2_3", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin2_3", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[46] = {nTime = 2, nNum = 0,
		tbPrelock = {45},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin2_3"},
		},
	},
	[47] = {nTime = 3, nNum = 0,
		tbPrelock = {45},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 2, 1, 0, "zhiyin2_4", "zhiyin2_2", false, 0, 0, 0, 0}, 
			{"NpcFindEnemyRaiseEvent", "zhiyin2_4", true, "AddOtherBuff", 2417, 1, 5},
		},
	},
	[48] = {nTime = 2, nNum = 0,
		tbPrelock = {47},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"DoDeath", "zhiyin2_4"},
		},
	},
	[15] = {nTime = 0.5, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_1_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin2_1", "zhiyin2_1", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin2_1", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[16] = {nTime = 2, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_1_2", 12, -1, {"DoDeath", "zhiyin2_1"}},
		},
	},
	[17] = {nTime = 3, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_2_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin2_2", "zhiyin2_2", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin2_2", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[18] = {nTime = 2, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_2_2", 12, -1, {"DoDeath", "zhiyin2_2"}},
		},
	},
	[19] = {nTime = 3, nNum = 0,
		tbPrelock = {17},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_3_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin2_3", "zhiyin2_3", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin2_3", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[20] = {nTime = 2, nNum = 0,
		tbPrelock = {19},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_3_2", 12, -1, {"DoDeath", "zhiyin2_3"}},
		},
	},
	[21] = {nTime = 3, nNum = 0,
		tbPrelock = {19},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_4_1", 12, -1, {"AddNpc", 2, 1, 0, "zhiyin2_4", "zhiyin2_2", false, 0, 0, 0, 0}, {"NpcFindEnemyRaiseEvent", "zhiyin2_4", true, "AddOtherBuff", 2417, 1, 5}},
		},
	},
	[22] = {nTime = 2, nNum = 0,
		tbPrelock = {21},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"StartTimeCycle", "cycle_2_4_2", 12, -1, {"DoDeath", "zhiyin2_4"}},
		},
	},
-------------------------------------------
	[53] = {nTime = 0, nNum = 1,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock4", 53},
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "两人同行此路方通！"},
		},
	},
	[23] = {nTime = 0, nNum = 1,
		tbPrelock = {6},
		tbStartEvent = 
		{
			{"IfTrapCount", "TrapLock2", 2, {"UnLock", 23}}
		},
		tbUnLockEvent = 
		{
			{"DelNpc", "dushui"},
			{"DelNpc", "zhiyin1_1"},
			{"DelNpc", "zhiyin1_2"},
			{"DelNpc", "zhiyin1_3"},
			{"DelNpc", "zhiyin1_4"},
			{"DelNpc", "zhiyin2_1"},
			{"DelNpc", "zhiyin2_2"},
			{"DelNpc", "zhiyin2_3"},
			{"DelNpc", "zhiyin2_4"},
			{"CloseCycle", "cycle_1_1_1"},
			{"CloseCycle", "cycle_1_1_2"},
			{"CloseCycle", "cycle_1_2_1"},
			{"CloseCycle", "cycle_1_2_2"},
			{"CloseCycle", "cycle_1_3_1"},
			{"CloseCycle", "cycle_1_3_2"},
			{"CloseCycle", "cycle_1_4_1"},
			{"CloseCycle", "cycle_1_4_2"},
			{"CloseCycle", "cycle_2_1_1"},
			{"CloseCycle", "cycle_2_1_2"},
			{"CloseCycle", "cycle_2_2_1"},
			{"CloseCycle", "cycle_2_2_2"},
			{"CloseCycle", "cycle_2_3_1"},
			{"CloseCycle", "cycle_2_3_2"},
			{"CloseCycle", "cycle_2_4_1"},
			{"CloseCycle", "cycle_2_4_2"},

			{"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},
			{"SetTargetPos", 5504, 4643},
			{"AddNpc", 3, 1, 0, "SkillNpc", "SkillNpc", false, 32, 0, 0, 0},	
			{"CloseLock", 53},
		},
	},
	[24] = {nTime = 0, nNum = 1,
		tbPrelock = {23},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"ClearTargetPos"},
			{"CastSkill", "SkillNpc", 4703, 19, 5455, 3914},
			{"BlackMsg", "不好！女侠踩中陷阱，快帮她挡住[FFFE0D]致命一击[-]！"},
		},
	},
	[25] = {nTime = 6, nNum = 0,
		tbPrelock = {24},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"AddNpc", 4, 1, 29, "boss", "boss", false, 32, 0, 9010, 0},
		},
	},

	[26] = {nTime = 0.1, nNum = 0,
		tbPrelock = {25},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcAddBuff", "boss", 3766, 1, 600},
			{"NpcBubbleTalk", "boss", "此路是我开，此树是我栽，要想从此过，留下买路财！", 5, 2, 1},
			{"RaiseEvent", "ShowQuickUse", 7496},
		},
	},
	[27] = {nTime = 5, nNum = 0,
		tbPrelock = {25},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "哈哈！你们这两个小毛头瞧瞧我的硬功如何？", 3, 1, 1},
			{"BlackMsg", "此人有些蹊跷，也许杨瑛女侠送的神秘物件跟此人有什麽关联！"},
		},
	},
	[50] = {nTime = 20, nNum = 0,
		tbPrelock = {25},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "快使用临行前杨瑛女侠送的神秘物件！"},
		},
	},
	[28] = {nTime = 0, nNum = 1,
		tbPrelock = {24},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			{"NpcRemoveBuff", "boss", 3766},
			{"AddBuff", 1535, 2, 600, 0, 0},
			{"CloseLock", 50},
			{"PlayerBubbleTalk", "此物居然能激发潜能，破其硬功！"},
		},
	},
	[51] = {nTime = 0, nNum = 1,
		tbPrelock = {28},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 51, 90},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "不！这不可能！我的神功不可能被破！", 3, 1, 1},
		},
	},
	[52] = {nTime = 0, nNum = 1,
		tbPrelock = {28},
		tbStartEvent = 
		{
			{"NpcHpUnlock", "boss", 52, 50},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "杨瑛！我与你无仇无怨，为何助敌破我神功！", 3, 1, 1},
		},
	},
	[29] = {nTime = 0, nNum = 1,
		tbPrelock = {25},
		tbStartEvent = 
		{
			
		},
		tbUnLockEvent = 
		{
			--{"AddSimpleNpc", 1611, 5154, 5318, 0},
			{"SetKickoutPlayerDealyTime", 10},
			{"GameWin"},
		},
	},
}