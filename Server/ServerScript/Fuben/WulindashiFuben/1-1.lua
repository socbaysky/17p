
local tbFubenSetting = {};
Fuben:SetFubenSetting(153, tbFubenSetting)		-- 绑定副本内容和地图

tbFubenSetting.szFubenClass 			= "WldsFubenBase";									-- 副本类型
tbFubenSetting.szName 					= "龙潭虎穴"											-- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile 			= "Setting/Fuben/WulindashiFuben/NpcPos_1.tab"			-- NPC点
tbFubenSetting.szPathFile 				= "Setting/Fuben/WulindashiFuben/NpcPath_1.tab"			-- 寻路点
tbFubenSetting.tbMultiBeginPoint        = {{1973, 1603},{2159, 1605},{1973, 1450},{2165, 1438}}	-- 副本出生点
tbFubenSetting.tbTempRevivePoint 		= {2065, 1555}											-- 临时复活点，副本内有效，出副本则移除
tbFubenSetting.nStartDir				= 1;

tbFubenSetting.NPC = 
{
	[1]  = {nTemplate = 2823, nLevel = -1, nSeries = 0},  --完颜亲兵
	[2]  = {nTemplate = 2824, nLevel = -1, nSeries = 0},  --天忍教精英
	[3]  = {nTemplate = 2821, nLevel = -1, nSeries = 0},  --完颜洪烈
	[4]  = {nTemplate = 2822, nLevel = -1, nSeries = 0},  --金翅

	[20] = {nTemplate = 104,  nLevel = -1, nSeries = 0},   --障碍门
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
			{"SetNearbyRange", 3},
		},
	},
	[2] = {nTime = 900, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"SetShowTime", 2},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"闯关失败"},
			{"BlackMsg", "风紧，扯呼！"},
			{"GameLost"},
		},
	},
	[3] = {nTime = 1, nNum = 0,
		tbPrelock = {1},
		tbStartEvent = 
		{
			{"AddNpc", 20, 1, 0, "wall", "wall_1",false, 16},
			{"ShowTaskDialog", 1148, false},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"探索此地"},
			{"BlackMsg", "此处暗藏杀机，我等必须小心行事！"},
		    {"DoDeath", "wall"},
			{"OpenDynamicObstacle", "obs1"},	
		},
	},
	[4] = {nTime = 0, nNum = 1,
		tbPrelock = {3},
		tbStartEvent = 
		{
			{"TrapUnlock", "TrapLock1", 4},
			{"SetTargetPos", 2564, 2823},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"击杀敌人"},
			{"AddNpc", 20, 1, 0, "wall", "wall_2",false, 23},
			{"ClearTargetPos"},	
			{"AddNpc", 1, 8, 5, "gw", "guaiwu", false, 0, 0.5, 9005, 0.5},
			{"AddNpc", 2, 4, 5, "jy", "jingying", false, 0, 0.5, 9010, 0.5},	    
		},
	},
	[5] = {nTime = 0, nNum = 12,
		tbPrelock = {4},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"BlackMsg", "金兵跟天忍教妖人居然同时在此出现，完颜洪烈定在此处！"},
			{"DoDeath", "wall"},	
		},
	},
	[6] = {nTime = 0, nNum = 1,
		tbPrelock = {5},
		tbStartEvent = 
		{
			{"AddNpc", 3, 1, 0, "boss", "boss", false, 40, 0, 0, 0},
			{"MoveCameraToPosition", 6, 2, 3971, 4453, 1},
			{"SetAllUiVisiable", false},
			{"SetForbiddenOperation", true},
			{"ChangeFightState", 0},
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss", "独孤剑就派了你们几个小娃娃来对付我？可笑！金翅，你来陪他们玩一下吧！", 3, 0, 1},
		},
	},
	[16] = {nTime = 0.1, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"SetNpcBloodVisable", "boss", false, 0},
		},
	},
	[7] = {nTime = 2, nNum = 0,
		tbPrelock = {5},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"UnLock", 6},
		},
	},
	[8] = {nTime = 2, nNum = 0,
		tbPrelock = {6},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"ChangeNpcAi", "boss", "Move", "Path1", 15, 0, 0, 1, 0},
			{"AddNpc", 4, 1, 10, "boss2", "boss2", false, 40, 4, 9005, 1},
		},
	},
	[17] = {nTime = 5.1, nNum = 0,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{ 
			--{"SetNpcBloodVisable", "boss2", false, 0},
			{"SetNpcProtected", "boss2", 1},
		},
	},
	[15] = {nTime = 0, nNum = 1,
		tbPrelock = {8},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
		},
	},
	[9] = {nTime = 2, nNum = 0,
		tbPrelock = {15},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			--{"SetNpcBloodVisable", "boss2", true, 0},
			{"SetNpcProtected", "boss2", 0},
			{"OpenDynamicObstacle", "obs2"},
			{"LeaveAnimationState", true},
			{"SetAllUiVisiable", true},
			{"SetForbiddenOperation", false},
			{"ChangeFightState", 1},
			{"SetFubenProgress", -1,"击杀金翅"},
			{"SetTargetPos", 4039, 4503},
		},
	},
	[18] = {nTime = 3, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
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
		},
		tbUnLockEvent = 
		{
			{"CloseLock", 11, 12},
		},
	},
	[13] = {nTime = 5, nNum = 0,
		tbPrelock = {10},
		tbStartEvent = 
		{
			{"OpenWindow", "StoryBlackBg", "没想到完颜洪烈的一只鬼鸟的能力居然也恐怖如斯...", nil, 5, 1, 0},
		},
		tbUnLockEvent = 
		{
			{"SetFubenProgress", -1,"闯关成功"},
			{"DoFinishTaskExtInfo", "WLDS_TeamFuben_1"},
			{"SetKickoutPlayerDealyTime", 1},
			{"GameWin"},
		},
	},
-------------------boss玩法--------------------
	[11] = {nTime = 3, nNum = 0,
		tbPrelock = {9},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"NpcBubbleTalk", "boss2", "叽哩哇啦，嘎里卡拉里！", 3, 0, 1},
			{"CastSkill", "boss2", 1523, 1, -1, -1},
			{"BlackMsg", "注意！小心这鸟的邪风！"},
			{"StartTimeCycle", "cycle_1", 10, nil, {"BlackMsg", "注意！小心这鸟的邪风！"}, {"CastSkill", "boss2", 1523, 1, -1, -1}},
		},
	},
	[12] = {nTime = 2, nNum = 0,
		tbPrelock = {11},
		tbStartEvent = 
		{
		},
		tbUnLockEvent = 
		{
			{"CastSkill", "boss2", 4901, 3, -1, -1},
			{"StartTimeCycle", "cycle_1", 10, nil, {"NpcBubbleTalk", "boss2", "叽哩哇啦，嘎里卡拉里！", 3, 0, 1}, {"CastSkill", "boss2", 4901, 3, -1, -1}},
		},
	},
}