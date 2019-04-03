 Require("CommonScript/SdkDef.lua");

Recharge.IS_OPEN = true;
Recharge.IS_OPEN_INVEST = true;--是否开启一本万利
Recharge.IS_OPEN_BUY_ENHANCE = true;--是否开启强化直够
Recharge.IS_OPEN_BUY_DRESS = true;--是否开启购买外装货币

Recharge.nExtInterConnectVipGetGoldPercent = 0.005;  --获得VIP 经验的同时获得其额外元宝赠送

local Define_WeekCard = 1
local Define_MonthCard = 2
local Define_SuperWeekCard = 3


Recharge.SAVE_GROUP 	= 20;
Recharge.KEY_TOTAL_ONLY_GOLD = 1; -- 买金币的累积充值金额，实际总额要加上KEY_TOTAL_CARD --有异步数据进行同步
Recharge.KEY_TOTAL_ONLY_GOLD2 = 57; --超过21亿部分的 买金币的累积充值金额
Recharge.TOTAL_RECHARGE_LARGE = 2^31;

Recharge.KEY_VIP_AWARD  = 3; --玩家已购买哪个档次的礼包，用标识位，从0开始
Recharge.KEY_BUYED_FLAG = 4; -- 玩家已买过的哪个档次的充值，首冲奖励用

Recharge.tbKeyGrowBuyed = {5, 23, 31, 38, 50,59, 65, 74, 75, 79} --一本万利是否购买了
Recharge.tbKeyGrowTaked = {6, 24, 32, 39, 51,60, 66, 76, 77, 80} -- 拿了几档的一本万利奖励 用bit位存
Recharge.KEY_INVEST_ACT_TAKEDAY = 48;
Recharge.KEY_INVEST_BACK_TAKEDAY = 72;

Recharge.tbDayCardTakeKey = {
	[Define_WeekCard] 	= 9; --周卡
	[Define_MonthCard] 	= 8; --月卡
	[Define_SuperWeekCard] = 83;--至尊周卡
}

Recharge.KEY_TOTAL_CARD = 10; --卡类的充值总额

Recharge.KEY_GET_FIRST_RECHARGE = 12; --是否获得了首冲礼包

Recharge.KEY_VIP_AWARD_EX  = 18; --后面对vip的内容又改了所以换了标识 --在一个月后就不检查这个的不同了
Recharge.KEY_BUYED_FLAG_TIME = 19;--上次购买哪个档次的充值的时间，用于活动重置每挡的首冲用

--累计充值
Recharge.KEY_ACT_SUM_R = 25
Recharge.KEY_ACT_SUM_SET_TIME_R = 26
Recharge.KEY_ACT_SUM_TAKE_R = 27
--累计消耗
Recharge.KEY_ACT_SUM_C = 28
Recharge.KEY_ACT_SUM_SET_TIME_C = 29
Recharge.KEY_ACT_SUM_TAKE_C = 30

Recharge.KEY_ACT_CONTINUAL_DATA_DAY = 33 --连续充值相关存储
Recharge.KEY_ACT_CONTINUAL_DAYS = 34
Recharge.KEY_ACT_CONTINUAL_FLAG = 35
Recharge.KEY_ACT_CONTINUAL_RECHARGE = 36
Recharge.KEY_ACT_CONTINUAL_SESSION_TIME = 37

Recharge.KEY_ONE_DAY_CARD_PLUS_COUNT = 62 --剩余的可领取一键礼包次数
Recharge.KEY_ONE_DAY_CARD_PLUS_DAY = 63 --领取一键礼包的天数，每天只能领取一次

Recharge.KEY_ACT_NEWYEARGIFT_RESET = 58 --新年大礼包的活动开启时间，区分版本清除玩家是否已经购买
Recharge.KEY_ACT_INVEST_RESET = 64 --新年一本万利的活动开启时间，区分版本清除玩家是否已经购买

Recharge.RATE 			= 0.1; --1分 与元宝的兑换比例是10：1
Recharge.tbMoneyRMBRate = { --不同币种 分 * rate = 对应RMB 分，决定vip经验，运营后不能改变
    ["RMB"] = 1,
    ["VND"] = 3, --越南币元 对应 0.01分
    ["HKD"] = 0.76, --港币分 对应 1分
    ["TWD"] = 0.2, --台币
    ["USD"] = 6.8, --美元    
    ["THB"] = 0.25, --泰铢
    ["KRW"] = 60 / 13200, --韩币 ,含税
}

if version_kor then
	Recharge.tbMoneyRMBRate["USD"] = 60 / 11;  --含税是1.1
end

--第三个参数是 界面上显示的字符格式
Recharge.tbMoneyName = {
    ["RMB"] = {"元", "￥", "%d", 0.01}, --第四个值是存盘值 与显示值（界面） 的转换比率
    ["VND"] = {"越南币", "VND", "%d", 100},
    ["HKD"] = {"港币","HKD", "%d", 0.01},
    ["TWD"] = {"新台币", "TWD", "%d", 0.01},
    ["USD"] = {"美元", "$", "%.2f", 0.01},
    ["THB"] = {"泰铢", "THB", "%d", 0.01},
    ["KRW"] = {"韩币", "?", "%d", 0.01},
}

--第三方支付的货币分 与元宝的兑换比例
Recharge.tbMoneyThirdRate = {
	["RMB"] = 0.1,
	["TWD"] = 0.022,
	["HKD"] = 0.022 * 3.8,
	["USD"] = 0.022 * 34,
	["VND"] = 0.4, --这里是100越南盾对应的元宝数
	["THB"] = 0.025,
	["KRW"] = 60/132000, 
}

if version_vn and IOS then
	Recharge.tbRechareBuyGoldShowPrice = {
		"45,000";
		"69,000";
		"129,000";
		"699,000";
		"1,299,000";
		"1,999,000";
	}
end

if version_xm then
	Recharge.tbMoneyThirdRate["USD"] = 0.77 --只是已购买项重复买时 1：70 再乘额外的1.1
elseif version_kor then
	Recharge.tbMoneyThirdRate["USD"] = 60/110 --
end


--泰国不同第三方充值渠道对应不同的元宝兑换比率
Recharge.tbMoneyThirdRatePlatform = {
	["PlatformPay"] = 1;
	["PlatformPay_B2"] = 1;
	["PlatformPay_D1"] = 1;
	["PlatformPay_E1"] = 1;
	["PlatformPay_I1"] = 1;
	["PlatformPay_I2"] = 1;
	["PlatformPay_L3"] = 1;
	["PlatformPay_N1"] = 1;
	["PlatformPay_N2"] = 1;
	["PlatformPay_P1"] = 1;
	["PlatformPay_S1"] = 1;
	["PlatformPay_T1"] = 1;
	["PlatformPay_T2"] = 1;
	["PlatformPay_U1"] = 1;
	["PlatformPay_W"] = 1;
};



Recharge.THIRD_GET_GOLD_RATE = 1.1; --新马版的根据传过来的元宝数对应实际赠送元宝数倍率


Recharge.tbDaysCardBuyLimitDay = {
	3, 5, 3 --周卡剩余天数《=3才可重新购买，  --月卡剩余天数《=5才可重新购买
}

Recharge.nFirstAwardItem = 1240--首冲奖励

Recharge.tbDressMoneyBuySetting = {
	{ 
		PropId = {
			[0] = "39336"; --IOS
			[1] = "39258"; --android
		};
		ActionId = "4837";
		ProductId = "com.tencent.jxqy.clothing98";
		nCostRMB = 98;
		nGetMoney = 1000;
	};
	{ 
		PropId = {
			[0] = "74771"; --IOS
			[1] = "74770"; --android
		};
		ActionId = "4837";
		ProductId = "com.tencent.jxqy.clothing298";
		nCostRMB = 298;
		nGetMoney = 3100;
	};
	{ 
		PropId = {
			[0] = "74773"; --IOS
			[1] = "74772"; --android
		};
		ActionId = "4837";
		ProductId = "com.tencent.jxqy.clothing648";
		nCostRMB = 648;
		nGetMoney = 6900;
	};
}

Recharge.MAX_COMPENSATION = 6 -- 晚进服补偿
Recharge.tbCompensationAward = {
	{"Item", 1458, 1},
	{"Item", 1459, 1},
	{"Item", 1460, 1},
	{"Item", 1461, 1},
	{"Item", 1462, 1},
	{"Item", 2275, 1},
}

Recharge.fActivityCardAwardParam = 100; --周月卡的奖励百分比

Recharge.tbDaysCardkeyActiviy = {
	[Define_WeekCard] 		= {14, 8}; --周卡
	[Define_MonthCard] 		= {14, 7}; --月卡
	[Define_SuperWeekCard] 	= {20, 84}; --至尊周卡

}

Recharge.tbSaveKeySuperDaysCard = { --至尊周卡资格的购买次数
	[Define_SuperWeekCard] = 81;
}

--月卡，每天领取奖励
Recharge.tbDayCardAward = {
	[Define_WeekCard] = {
	    { {{"Gold", 180   }}, "OpenLevel39"}; --时间轴从低到高
	    { {{"Gold", 200   }}, "OpenLevel79"};
		{ {{"Gold", 220   }}, "OpenLevel89"};
		{ {{"Gold", 240   }}, "OpenLevel99"};
		{ {{"Gold", 260   }}, "OpenLevel109"};
		{ {{"Gold", 280   }}, "OpenLevel119"};
	}; 
	[Define_MonthCard] = {
		{ {{"Gold", 150   }}, "OpenLevel39"}; 
		{ {{"Gold", 160   }}, "OpenLevel79"};
		{ {{"Gold", 170   }}, "OpenLevel89"};
		{ {{"Gold", 180   }}, "OpenLevel99"};
		{ {{"Gold", 190   }}, "OpenLevel109"};
		{ {{"Gold", 200   }}, "OpenLevel119"};
	};
	[Define_SuperWeekCard] = {
		{ {{"Gold", 400   }}, "OpenLevel39"}; --时间轴从低到高
	    { {{"Gold", 440   }}, "OpenLevel89"};
		{ {{"Gold", 480   }}, "OpenLevel99"};
		{ {{"Gold", 520   }}, "OpenLevel109"};
		{ {{"Gold", 560   }}, "OpenLevel119"};
	};
};

if version_hk or version_tw then
	--周卡，每天领取奖励
	Recharge.tbDayCardAward[Define_WeekCard] = 
	{
		{ {{"Gold", 200   }}, "OpenLevel39"};
	}
elseif version_vn then
	Recharge.tbDayCardAward[Define_MonthCard] = 
	{
		{ {{"Gold", 180   }}, "OpenLevel39"};
	}
end

--活动一本万利配置
Recharge.tbGrowInvestActSetting = {
	szNameInPanel = "通宝基金";
	szTextureInPanel = "UI/Textures/GrowInvest02.png";
	szBuyTimeLimit = "时限：2018年11月12日~11月18日"
};
if version_xm then
	Recharge.tbGrowInvestActSetting.szNameInPanel = "新年专属";
	Recharge.tbGrowInvestActSetting.szBuyTimeLimit = "时限：2018年2月16日-2月28日"
end

-- 活动充值礼包配置
Recharge.tbNewYearBuyGiftActSetting = {
	szNameInPanel = "资料片礼包";
	szPanelLine1  = "苕嶢太华俯咸京";
	szPanelLine2  = "天外三峰削不成";
	szTextureInPanel = "UI/Textures/GrowInvestSpring.png";
};

if version_vn then
	Recharge.tbNewYearBuyGiftActSetting.szNameInPanel = "七夕大礼包"
	Recharge.tbNewYearBuyGiftActSetting.szPanelLine1  = "执手情缘";
	Recharge.tbNewYearBuyGiftActSetting.szPanelLine2  = "浪漫七夕";
	Recharge.tbNewYearBuyGiftActSetting.szTextureInPanel = "UI/Textures/Double11.png";
end

---活动充值礼包的配置项
Recharge.tbNewYearBuySetting =
{
	{ nBuyCount = 5, nCanBuyDay = 0,  nSaveCountKey = 49 }; 
	{ nBuyCount = 1, nCanBuyDay = 0,  nSaveCountKey = 78 }; --活动开启后nCanBuyDay天才可购买
	{ nBuyCount = 1, nCanBuyDay = 0, };
	{ nBuyCount = 1, nCanBuyDay = 0, }; 
}

--领取这些vip礼包的时间key，方便后期奖励调整时进行补偿
Recharge.tbVipAwardTakeTimeKey = {
	[14] = 20, --V14 --saveKey
	[15] = 21,
	[16] = 22,
}

Recharge.tbDirectEnhanceSetting = { --强化直升道具购买的配置
	{OpenTimeFrame = "OpenLevel59", nPlayerLevel = 20; nEnhanceLevel = 20; };
	{OpenTimeFrame = "OpenLevel69", nPlayerLevel = 30; nEnhanceLevel = 30; };
	{OpenTimeFrame = "OpenLevel79", nPlayerLevel = 40; nEnhanceLevel = 40; };
	{OpenTimeFrame = "OpenLevel89", nPlayerLevel = 50; nEnhanceLevel = 50; };
};




--一本万利的推送等级
Recharge.tbProptGrowInvestLevel = {
 	{ 60, 50, 40 },
 	{ 85, 75 },
 	{ 96, 90},
 	{ 999, 999}, --新年的是不推送的
 	{ 106, 100},
 	{ 116, 110},
 	{ 999, 999}, --老玩家回归一本万利
 	{ 126, 130},
 	{ 136, 140},
 	{ 146, 150},
}


-------paulf20181228
--- VIP的设置 ,以分为单位
Recharge.tbVipSetting = {
	--累积充值人民币数
	0,				--V1
	0,				--V2
	0,				--V3
	0,				--V4
	0,				--V5
	0,				--V6
	0,				--V7
	0,				--V8
	0,				--V9
	0,				--V10
	68000,			--V11
	136000,			--V12
	340000,			--V13 50
	680000,			--V14 100
	1360000,			--V15 200
	3400000,			--V16 500
	6800000,			--V17 1000
	13600000,			--V18 2000
}

Recharge.tbVipTimeFrameSetting =
{
	[15] = "OpenLevel69"; --OpenLevel69才开放VIP15
	[16] = "OpenLevel69"; --OpenLevel69才开放VIP16
	[17] = "OpenLevel89";
	[18] = "OpenLevel89";
}

Recharge.nMaxVip = #Recharge.tbVipSetting

Recharge.VIP_SHOW_LEVEL = { --vip特效标识显示
	[1] = "V_Blue_",
	[2] = "V_Blue_",
	[3] = "V_Blue_",
	[4] = "V_Blue_",
	[5] = "V_Blue_",

	[6] = "V_Purple_",
	[7] = "V_Purple_",
	[8] = "V_Purple_",

	[9] = "V_Pink_",
	[10] = "V_Pink_",
	[11] = "V_Pink_",

	[12] = "V_Orange_",
	[13] = "V_Orange_",
	[14] = "V_Orange_",
	[15] = "V_Orange_",
	[16] = "V_Golden_",
	[17] = "V_Golden_",
	[18] = "V_Golden_",
}

assert( #Recharge.VIP_SHOW_LEVEL == #Recharge.tbVipSetting)

--vip特权礼包 ,不能超过32档
Recharge.tbVipAward = {
	--从vip 0 开始
	{
		nShowPrice  = 200,
		nRealPrice  = 8,
		nGiveItemId = 1317, --实际给的道具id
	},

	--VIP1
	{
		nShowPrice  = 400,
		nRealPrice  = 18,
		nGiveItemId = 1318,
	},

	--VIP2
	{
		nShowPrice  = 480,
		nRealPrice  = 28,
		nGiveItemId = 1319,
	},

	--VIP3
	{
		nShowPrice  = 650,
		nRealPrice  = 48,
		nGiveItemId = 1320,
	},

	--VIP4
	{
		nShowPrice  = 1600,
		nRealPrice  = 98,
		nGiveItemId = 1321,
	},

	--VIP5
	{
		nShowPrice  = 1550,
		nRealPrice  = 118,
		nGiveItemId = 1322,
	},

	--VIP6
	{
		nShowPrice  = 1675,
		nRealPrice  = 148,
		nGiveItemId = 1323,
	},

	--VIP7
	{
		nShowPrice  = 2650,
		nRealPrice  = 278,
		nGiveItemId = 1324,
	},

	--VIP8
	{
		nShowPrice  = 6000,
		nRealPrice  = 648,
		nGiveItemId = 1325,
	},

	--VIP9
	{
		nShowPrice  = 7600,
		nRealPrice  = 848,
		nGiveItemId = 1326,
	},

	--VIP10
	{
		nShowPrice  = 7850,
		nRealPrice  = 948,
		nGiveItemId = 1327,
	},

	--VIP11
	{
		nShowPrice  = 7650,
		nRealPrice  = 1048,
		nGiveItemId = 1328,
	},

	--VIP12
	{
		nShowPrice  = 8450,
		nRealPrice  = 1148,
		nGiveItemId = 1329,
	},

	--VIP13
	{
		nShowPrice  = 9400,
		nRealPrice  = 1288,
		nGiveItemId = 1330,
	},

	--VIP14
	{
		nShowPrice  = 14400,
		nRealPrice  = 2388,
		nGiveItemId = 1331,
	},

	--VIP15
	{
		nShowPrice  = 16400,
		nRealPrice  = 2988,
		nGiveItemId = 1332,
	},

	--VIP16
	{
		nShowPrice  = 18500,
		nRealPrice  = 3688,
		nGiveItemId = 1333,
	},

	--VIP17
	{
		nShowPrice  = 24000,
		nRealPrice  = 4688,
		nGiveItemId = 3076,
	},

	--VIP18
	{
		nShowPrice  = 29800,
		nRealPrice  = 5888,
		nGiveItemId = 3077,
	},
}

--VIP的特权设置参数, 具体调用自定义吧
Recharge.tbVipExtSetting = {
	["ExFriendNum"] = {{4, 50}, {18, 50} }, --额外的好友上限, 是累计的

	["public_chat"] = { 6, 15 }, --VIP6 以后公聊间隔变15s

	["ChuangGongLevelMinus"] = { --传功等级差要求
		--vip 等级， 等级差要求
		{0, 	3},
		{9, 	2},
		{15, 	1},
	},

	--vip等级对应家族捐献获得贡献加成
	KinDonateContributeInc = {
		{14, 0.2},	-- vip >= 14,加成20%
	},

	--亲密度提升速度+20%
	AddImity = { 11, 1.2 };

	TeacherStudentConnectLvDiff = {	--师徒拜师收徒最小等级差
		{0, 5},	-- vip>=0, LvDiff=5
		{6, 4},
		{9, 3},
		{12, 2},
	},

	KinGiftBoxInc = {	--vip等级增加家族礼盒数量
		{7, 1},	-- vip>=7, 增加1个（绝对值）
	},
}

--上面的固定描述
Recharge.tbVipDescFix = {
	--VIP0
[[
]],

--VIP1
[[

]],

--VIP2
[[

]],

--VIP3
[[

]],

--VIP4
[[

]],

--VIP5
[[

]],

--VIP6
[[

]],

--VIP7
[[

]],

--VIP8
[[

]],

--VIP9
[[

]],

--VIP10
[[

]],

--VIP11
[[

]],

--VIP12
[[

]],

--VIP13
[[

]],

--VIP14
[[

]],

--VIP15
[[

]],

--VIP16
[[

]],

--VIP17
[[

]],

--VIP18
[[

]],
}

--特权说明, 从0 级开始
Recharge.tbVipDesc = {
--VIP0
[[
●  每天帮派捐献次数：　　[fefb1a]  10[-]次
●  每天世界频道发言次数：[fefb1a]  10[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
]],

--VIP1
[[
●  每天[fefb1a]1[-]元超值礼包购买资格
●  每天传功次数：             [fefb1a]    1→2[-]次
●  每天帮派捐献次数：　　[fefb1a]  10→20[-]次
●  每天世界频道发言次数：[fefb1a]  10→20[-]次
●  每天宝藏探索次数：　　     [fefb1a]    10[-]次
]],

--VIP2
[[
●  每天武神殿购买次数：[fefb1a]  0→5[-]次
●  每天商会协助次数： [fefb1a]10→20[-]次
●  每天[fefb1a]1[-]元超值礼包购买资格
●  每天传功次数:                [fefb1a] 2[-]次
●  每天帮派捐献次数：　　[fefb1a]  20[-]次
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
]],

--VIP3
[[
●  每天帮派捐献次数：[fefb1a] 20→25[-]次
●  每天武神殿购买次数：　[fefb1a]    5[-]次
●  每天商会协助次数：  　[fefb1a]   20[-]次
●  每天[fefb1a]1/3[-]元超值礼包购买资格
●  每天传功次数:               [fefb1a]   2[-]次
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
]],

--VIP4
[[
●  好友数量上限额外增加：[fefb1a]  50[-]人
●  每天武神殿购买次数：　[fefb1a]    5[-]次
●  每天商会协助次数：  　[fefb1a]   20[-]次
●  每天[fefb1a]1/3[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  每天传功次数:                [fefb1a]  2[-]次
●  每天帮派捐献次数：　　[fefb1a]  25[-]次
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
]],

--VIP5
[[
●  获得举办[fefb1a]庄园[-]婚礼的特权
●  每天商会任务求助次数：[fefb1a]3→4[-]次
●  好友数量上限额外增加：  [fefb1a] 50[-]人
●  每天武神殿购买次数：　[fefb1a]    5[-]次
●  每天商会协助次数：  　[fefb1a]   20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  每天传功次数:                [fefb1a]  2[-]次
●  每天帮派捐献次数：　　[fefb1a]  25[-]次
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
]],

--VIP6
[[
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  可拜师/收徒的最低等级差：[fefb1a] 5→4[-]级
●  世界频道发言间隔：    [fefb1a]   30→15[-]秒
●  每天武神殿购买次数：　[fefb1a]   5→10[-]次
●  每天帮派捐献次数：　　[fefb1a] 25→50[-]次
●  拥有举办[fefb1a]庄园[-]婚礼的特权
●  每天商会任务求助次数：[fefb1a]           4[-]次
●  好友数量上限额外增加：[fefb1a]         50[-]人
●  每天商会协助次数：  　[fefb1a]          20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天传功次数:                       [fefb1a]  2[-]次
●  每天世界频道发言次数：[fefb1a]        20[-]次
●  每天宝藏探索次数：　　[fefb1a]        10[-]次
]],

--VIP7
[[
●  帮派礼盒每日兑换次数：[fefb1a]   4→5[-]次
●  每天宝藏探索次数：[fefb1a]     10→15[-]次
●  可剥离魂石：[fefb1a]                   否→是[-]
●  拥有举办[fefb1a]庄园[-]婚礼的特权
●  可拜师/收徒的最低等级差：[fefb1a]    4[-]级
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：    [fefb1a]        15[-]秒
●  每天商会任务求助次数：[fefb1a]        4[-]次
●  好友数量上限额外增加：[fefb1a]      50[-]人
●  每天武神殿购买次数：　[fefb1a]      10[-]次
●  每天商会协助次数：  　[fefb1a]       20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天传功次数:                [fefb1a]      2[-]次
●  每天帮派捐献次数：　　[fefb1a]      50[-]次
●  每天世界频道发言次数：[fefb1a]      20[-]次
]],

--VIP8
[[
●  每天传功/被传功次数:       [fefb1a] 2→3[-]次
●  离线托管获得经验：[fefb1a]100%→110%[-]
●  拥有举办[fefb1a]庄园[-]婚礼的特权
●  帮派礼盒每日兑换次数：[fefb1a]         5[-]次
●  可拜师/收徒的最低等级差：[fefb1a]     4[-]级
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：    [fefb1a]        15[-]秒
●  每天商会任务求助次数：[fefb1a]        4[-]次
●  好友数量上限额外增加：[fefb1a]       50[-]人
●  每天武神殿购买次数：　[fefb1a]      10[-]次
●  每天商会协助次数：  　[fefb1a]       20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：　　[fefb1a]      50[-]次
●  每天世界频道发言次数：[fefb1a]      20[-]次
●  每天宝藏探索次数：　　[fefb1a]      15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP9
[[
●  获得举办[fefb1a]海岛[-]婚礼的特权
●  可传功/被传功最低等级差：[fefb1a] 3→2[-]级
●  可拜师/收徒的最低等级差：[fefb1a] 4→3[-]级
●  每天帮派捐献次数：[fefb1a]     50→200[-]次
●  拥有举办[fefb1a]庄园[-]婚礼的特权
●  每天传功/被传功次数:        [fefb1a]      3[-]次
●  离线托管获得经验：      [fefb1a]      110%[-]
●  帮派礼盒每日兑换次数：[fefb1a]          5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：    [fefb1a]          15[-]秒
●  每天商会任务求助次数：[fefb1a]          4[-]次
●  好友数量上限额外增加：[fefb1a]        50[-]人
●  每天武神殿购买次数：　[fefb1a]        10[-]次
●  每天商会协助次数：  　[fefb1a]         20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天世界频道发言次数：[fefb1a]        20[-]次
●  每天宝藏探索次数：　　[fefb1a]        15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],
--VIP10
[[
●  每天武神殿购买次数：  [fefb1a]10→15[-]次
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  摇钱树获得银两增加[fefb1a]20%[-]
●  拥有举办[fefb1a]庄园、海岛[-]婚礼的特权
●  可传功/被传功最低等级差：    [fefb1a]2[-]级
●  每天传功/被传功次数:            [fefb1a]3[-]次
●  离线托管获得经验：          [fefb1a]110%[-]
●  帮派礼盒每日兑换次数：     [fefb1a]   5[-]次
●  可拜师/收徒的最低等级差：    [fefb1a]3[-]级
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：            [fefb1a]15[-]秒
●  每天商会任务求助次数：      [fefb1a]  4[-]次
●  好友数量上限额外增加：      [fefb1a]50[-]人
●  每天商会协助次数：       　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：          [fefb1a]200[-]次
●  每天世界频道发言次数：    [fefb1a]  20[-]次
●  每天宝藏探索次数：　　    [fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP11
[[
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  摇钱树获得银两增加[fefb1a]20%[-]
●  拥有举办[fefb1a]庄园、海岛[-]婚礼的特权
●  可传功/被传功最低等级差：   [fefb1a]2[-]级
●  每天传功/被传功次数:           [fefb1a]3[-]次
●  离线托管获得经验：         [fefb1a]110%[-]
●  帮派礼盒每日兑换次数：    [fefb1a]   5[-]次
●  可拜师/收徒的最低等级差：   [fefb1a]3[-]级
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：           [fefb1a]15[-]秒
●  每天商会任务求助次数：     [fefb1a]  4[-]次
●  好友数量上限额外增加:       [fefb1a]50[-]人
●  每天武神殿购买次数：　   [fefb1a]  15[-]次
●  每天商会协助次数：      　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：      [fefb1a]   200[-]次
●  每天世界频道发言次数：   [fefb1a]  20[-]次
●  每天宝藏探索次数：　   　[fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP12
[[
●  获得举办[fefb1a]舫舟[-]婚礼的特权
●  离线托管获得经验：[fefb1a]110%→120%[-]
●  每天帮派捐献次数：[fefb1a]  200→500[-]次
●  可拜师/收徒的最低等级差：[fefb1a]3→2[-]级
●  拥有举办[fefb1a]庄园、海岛[-]婚礼的特权
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  摇钱树获得银两增加[fefb1a]20%[-]
●  可传功/被传功最低等级差：     [fefb1a]2[-]级
●  每天传功/被传功次数:             [fefb1a]3[-]次
●  帮派礼盒每日兑换次数：      [fefb1a]   5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：             [fefb1a]15[-]秒
●  每天商会任务求助次数：       [fefb1a]  4[-]次
●  好友数量上限额外增加:         [fefb1a]50[-]人
●  每天武神殿购买次数：     　[fefb1a]  15[-]次
●  每天商会协助次数：        　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天世界频道发言次数：     [fefb1a]  20[-]次
●  每天宝藏探索次数：　     　[fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP13
[[
●  每天武神殿购买次数：[fefb1a]15→20[-]次
●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权
●  同伴经验药水经验增加[fefb1a]20%[-]
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  摇钱树获得银两增加[fefb1a]20%[-]
●  可传功/被传功最低等级差：  [fefb1a]2[-]级
●  每天传功/被传功次数:          [fefb1a]3[-]次
●  离线托管获得经验：        [fefb1a]120%[-]
●  可拜师/收徒的最低等级差：  [fefb1a]2[-]级
●  帮派礼盒每日兑换次数：   [fefb1a]   5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：          [fefb1a]15[-]秒
●  每天商会任务求助次数：    [fefb1a]  4[-]次
●  好友数量上限额外增加:      [fefb1a]50[-]人
●  每天商会协助次数：    　 [fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：       [fefb1a] 500[-]次
●  每天世界频道发言次数：  [fefb1a]  20[-]次
●  每天宝藏探索次数：　　  [fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP14
[[
●  每天修炼丹使用次数：  [fefb1a]1→2[-]次
●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权
●  同伴经验药水经验增加[fefb1a]20%[-]
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  可传功/被传功最低等级差：[fefb1a]2[-]级
●  每天传功/被传功次数:        [fefb1a]3[-]次
●  离线托管获得经验：      [fefb1a]120%[-]
●  可拜师/收徒的最低等级差：[fefb1a]2[-]级
●  摇钱树获得银两增加[fefb1a]20%[-]
●  帮派礼盒每日兑换次数：[fefb1a]    5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：        [fefb1a]15[-]秒
●  每天商会任务求助次数：[fefb1a]    4[-]次
●  好友数量上限额外增加:    [fefb1a]50[-]人
●  每天武神殿购买次数：　[fefb1a]  20[-]次
●  每天商会协助次数：   　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：     [fefb1a] 500[-]次
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP15
[[
●  可传功/被传功最低等级差：[fefb1a]2→1[-]级
●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权
●  每天修炼丹使用次数：            [fefb1a]2[-]次
●  同伴经验药水经验增加[fefb1a]20%[-]
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  每天传功/被传功次数:             [fefb1a]3[-]次
●  离线托管获得经验：           [fefb1a]120%[-]
●  可拜师/收徒的最低等级差：     [fefb1a]2[-]级
●  摇钱树获得银两增加[fefb1a]20%[-]
●  帮派礼盒每日兑换次数：[fefb1a]         5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：             [fefb1a]15[-]秒
●  每天商会任务求助次数：       [fefb1a]  4[-]次
●  好友数量上限额外增加:         [fefb1a]50[-]人
●  每天武神殿购买次数：     　[fefb1a]  20[-]次
●  每天商会协助次数：        　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：          [fefb1a] 500[-]次
●  每天世界频道发言次数：     [fefb1a]  20[-]次
●  每天宝藏探索次数：　    　 [fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP16
[[
●  每天传功/被传功次数:        [fefb1a]3→4[-]次
●  离线托管获得经验：[fefb1a]120%→130%[-]
●  每天帮派捐献次数：[fefb1a]500→3000[-]次
●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权
●  可传功/被传功最低等级差：     [fefb1a]1[-]级
●  每天修炼丹使用次数：            [fefb1a]2[-]次
●  同伴经验药水经验增加[fefb1a]20%[-]
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  摆摊显示商品数量增加[fefb1a]50%[-]
●  可拜师/收徒的最低等级差：     [fefb1a]2[-]级
●  摇钱树获得银两增加[fefb1a]20%[-]
●  帮派礼盒每日兑换次数：      [fefb1a]   5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：             [fefb1a]15[-]秒
●  每天商会任务求助次数：       [fefb1a]  4[-]次
●  好友数量上限额外增加:         [fefb1a]50[-]人
●  每天武神殿购买次数：     　[fefb1a]  20[-]次
●  每天商会协助次数：        　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天世界频道发言次数：     [fefb1a]  20[-]次
●  每天宝藏探索次数：　     　[fefb1a]  15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP17
[[
●  摆摊显示商品数量增加[fefb1a]50%→100%[-]
●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权
●  每天传功/被传功次数:           [fefb1a]4[-]次
●  离线托管获得经验：          [fefb1a]130%[-]
●  可传功/被传功最低等级差：   [fefb1a]1[-]级
●  每天修炼丹使用次数：          [fefb1a]2[-]次
●  同伴经验药水经验增加[fefb1a]20%[-]
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  可拜师/收徒的最低等级差：   [fefb1a]2[-]级
●  摇钱树获得银两增加[fefb1a]20%[-]
●  帮派礼盒每日兑换次数：[fefb1a]       5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：           [fefb1a]15[-]秒
●  每天商会任务求助次数：     [fefb1a]  4[-]次
●  好友数量上限额外增加:       [fefb1a]50[-]人
●  每天武神殿购买次数：   　[fefb1a]  20[-]次
●  每天商会协助次数：      　[fefb1a]  20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：[fefb1a]       3000[-]次
●  每天世界频道发言次数：[fefb1a]     20[-]次
●  每天宝藏探索次数：　　[fefb1a]     15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],

--VIP18
[[
●  摆摊显示商品数量增加[fefb1a]100%[-]
●  好友数量上限额外增加:  [fefb1a]50→100[-]人
●  拥有举办[fefb1a]庄园、海岛、舫舟[-]婚礼的特权
●  每天传功/被传功次数:              [fefb1a]4[-]次
●  离线托管获得经验：             [fefb1a]130%[-]
●  可传功/被传功最低等级差：      [fefb1a]1[-]级
●  每天修炼丹使用次数：             [fefb1a]2[-]次
●  同伴经验药水经验增加[fefb1a]20%[-]
●  好友亲密度提升速度增加[fefb1a]20%[-]
●  可拜师/收徒的最低等级差：      [fefb1a]2[-]级
●  摇钱树获得银两增加[fefb1a]20%[-]
●  帮派礼盒每日兑换次数：[fefb1a]          5[-]次
●  可使用特效白驹丸获得[fefb1a]2.5[-]倍离线经验
●  世界频道发言间隔：    [fefb1a]          15[-]秒
●  每天商会任务求助次数：[fefb1a]          4[-]次
●  每天武神殿购买次数：　[fefb1a]        20[-]次
●  每天商会协助次数：  　[fefb1a]         20[-]次
●  每天[fefb1a]1/3/6[-]元超值礼包购买资格
●  可使用摆摊的[fefb1a]刷新[-]功能
●  可购买[fefb1a]西域行商[-]的商品
●  每天帮派捐献次数：[fefb1a]          3000[-]次
●  每天世界频道发言次数：[fefb1a]        20[-]次
●  每天宝藏探索次数：　　[fefb1a]        15[-]次
●  可剥离魂石：[fefb1a]                         是[-]
]],
}

if version_vn then --越南版vip特权里没有对应的每日礼包
Recharge.tbVipDesc[2] =
--VIP1
[[
●  蓝V标识
●  传功次数每日额外增加[fefb1a]1[-]次
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
●  每天帮派捐献次数：　　[fefb1a]  20[-]次
]];

Recharge.tbVipDesc[4] =
--VIP3
[[
●  可发放2倍红包
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
●  每天帮派捐献次数：　　[fefb1a]  25[-]次
●  每天武神殿购买次数：　[fefb1a]    5[-]次
]];

Recharge.tbVipDesc[6] =
--VIP5
[[
●  可发放3倍红包
●  每天世界频道发言次数：[fefb1a]  20[-]次
●  每天宝藏探索次数：　　[fefb1a]  10[-]次
●  每天帮派捐献次数：　　[fefb1a]  25[-]次
●  每天武神殿购买次数：　[fefb1a]    5[-]次
]];
end

Recharge.DAILY_GIFT_TYPE = 
{
	["YUAN_1"] = 1,
	["YUAN_3"] = 2,
	["YUAN_6"] = 3,
	["YUAN_10"] = 4,
}

Recharge.DAYS_CARD_TYPE = 
{
	["DAYS_7"] = 1,
	["DAYS_30"] = 2,
}

Recharge.tbVipPrivilegeDesc = {
	KinDonate = {
		[0]  = "升级尊1每天最多可捐献20次",
		[1]  = "升级尊3每天最多可捐献25次",
		[2]  = "升级尊3每天最多可捐献25次",
		[3]  = "升级尊7每天最多可捐献50次",
		[4]  = "升级尊7每天最多可捐献50次",
		[5]  = "升级尊7每天最多可捐献50次",
		[6]  = "升级尊7每天最多可捐献50次",
		[7]  = "升级尊9每天最多可捐献200次",
		[8]  = "升级尊9每天最多可捐献200次",
		[9]  = "升级尊12每天最多可捐献500次",
		[10] = "升级尊12每天最多可捐献500次",
		[11] = "升级尊12每天最多可捐献500次",
		[12] = "升级尊14捐献获得贡献增加20%",
		[13] = "升级尊14捐献获得贡献增加20%",
		[14] = "升级尊16每天最多可捐献3000次",
		[15] = "升级尊16每天最多可捐献3000次",
	},
	MoneyTree = {
		[8] = "升级尊10摇钱树获得银两增加20%",
		[9] = "升级尊10摇钱树获得银两增加20%",
	},
	WaiYi = {
		[7] = "升级尊10可赠予好友外装",
		[8] = "升级尊10可赠予好友外装",
		[9] = "升级尊10可赠予好友外装",
	},
	OnHook = {
		[3]  = "升级尊6可使用特效白驹丸托管（离线经验2.5倍）",
		[4]  = "升级尊6可使用特效白驹丸托管（离线经验2.5倍）",
		[5]  = "升级尊6可使用特效白驹丸托管（离线经验2.5倍）",
		[6]  = "升级尊8离线托管经验增加10%",
		[7]  = "升级尊8离线托管经验增加10%",
		[9]  = "升级尊12离线托管经验增加20%",
		[10] = "升级尊12离线托管经验增加20%",
		[11] = "升级尊12离线托管经验增加20%",
		[13] = "升级尊16离线托管经验增加30%",
		[14] = "升级尊16离线托管经验增加30%",
		[15] = "升级尊16离线托管经验增加30%",
	},
	FriendImity = {
		[8]  = "升级尊11好友亲密度提升速度增加20%",
		[9]  = "升级尊11好友亲密度提升速度增加20%",
		[10] = " 升级尊11好友亲密度提升速度增加20%",
	},
	KinGift = {
		[4] = "升级尊7每天帮派礼盒兑换次数增加1次",
		[5] = "升级尊7每天帮派礼盒兑换次数增加1次",
		[6] = "升级尊7每天帮派礼盒兑换次数增加1次",
	},
}

function Recharge:OnSumActStart(nStartTime)
	self.nSumActStartTime = nStartTime
end
function Recharge:OnSumActEnd()
	self.nSumActStartTime = nil
end
function Recharge:GetActRechageSumVal(pPlayer)
	if not self.nSumActStartTime then
		return 0
	end
	local nLastRestTime = Recharge:GetActRechageSumTime(pPlayer)
	if nLastRestTime < self.nSumActStartTime then
		return 0
	end
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_R)
end
function Recharge:SetActRechageSumVal(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_R, nVal)
end
function Recharge:GetActRechageSumTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_R)
end
function Recharge:SetActRechageSumTime(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_R, nVal)
end
function Recharge:GetActRechageSumTake(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_R)
end
function Recharge:SetActRechageSumTake(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_R, nVal)
end

function Recharge:OnConsumeSumActStart(nStartTime)
	self.nConsumeSumStartTime = nStartTime
end
function Recharge:OnConsumeSumActEnd()
	self.nConsumeSumStartTime = nil
end
function Recharge:GetActConsumeSumVal(pPlayer)
	if self.nConsumeSumStartTime <= 0 then
		return 0
	end
	local nLastRestTime = Recharge:GetActConsumeSumTime(pPlayer)
	if nLastRestTime < self.nConsumeSumStartTime then
		return 0
	end
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_C)
end
function Recharge:SetActConsumeSumVal(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_C, nVal)
end
function Recharge:GetActConsumeSumTime(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_C)
end
function Recharge:SetActConsumeSumTime(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME_C, nVal)
end
function Recharge:GetActConsumeSumTake(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_C)
end
function Recharge:SetActConsumeSumTake(pPlayer, nVal)
	 pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_TAKE_C, nVal)
end

--连续充值活动
function Recharge:SetActContinualData(pPlayer, nKey, nValue)
	if nKey < self.KEY_ACT_CONTINUAL_DATA_DAY or nKey > self.KEY_ACT_CONTINUAL_SESSION_TIME then
		return
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, nKey, nValue)
end
function Recharge:GetActContinualData(pPlayer, nKey)
	return pPlayer.GetUserValue(self.SAVE_GROUP, nKey)
end


--这里面是分为单位， val是充值sdk里显示的名字
function Recharge:Init()
	local tbSettingGroup = {};
	local tbProductionSettingAll = {}
	local tbFile = LoadTabFile("Setting/Recharge/Recharge.tab", "sssddsdssssssdsddssss", nil,
			{"ProductId", "szDesc", "szServiceCode", "nLastingDay", "nMoney", "szMoneyType", "nNeedVipLevel","szAward", "szFirstAward","szThirdAward", "szFourthAward",	"szFifthAward", "szGroup","nGroupIndex", "szVersion","nEndTimeKey","nBuyDayKey", "szSprite", "szFirstDesc","szNoromalDesc","Plat"});
	local fnCheck;
	if MODULE_GAMESERVER and (version_hk or version_tw) then
		fnCheck = function (v)
			return(v.szVersion == "version_hk" or v.szVersion == "version_tw")
		end
	else
		fnCheck = function (v)
			if not _G[v.szVersion] then
				return
			end
			if MODULE_GAMECLIENT  and not Lib:IsEmptyStr(v.Plat) then
				if not _G[v.Plat] then
					return
				end
			end
			return true;
		end
	end

	for i,v in ipairs(tbFile) do
		if fnCheck(v) then
			if v.szAward ~= "" then
				v.tbAward = Lib:GetAwardFromString(v.szAward)
			end
			if v.szFirstAward  ~= "" then
				v.tbFirstAward = Lib:GetAwardFromString(v.szFirstAward)
			end
			if v.szThirdAward ~= "" then
				v.tbThirdAward = Lib:GetAwardFromString(v.szThirdAward)
			end
			if v.szFourthAward ~= "" then
				v.szFourthAward = Lib:GetAwardFromString(v.szFourthAward)
			end
			if v.szFifthAward ~= "" then
				v.tbFifthAward = Lib:GetAwardFromString(v.szFifthAward)
			end
			tbProductionSettingAll[v.ProductId] = v
			if v.szGroup ~= "" then
				tbSettingGroup[v.szGroup] = tbSettingGroup[v.szGroup] or {};
				tbSettingGroup[v.szGroup][v.nGroupIndex] = v;
			end
		end
	end

	local tbGrowInvestGroup = {}
	local tbFile = LoadTabFile("Setting/Recharge/GrowInvest.tab", "dddddddddddd", nil,
			{"nGroup", "nIndex",	"nLevel",	"nAwardGold",	"nDay",	"version_tx",	"version_vn",	"version_hk",	"version_xm",	"version_en",	"version_kor",	"version_th"});
	for i,v in ipairs(tbFile) do
		if Lib:CheckVersion(v) then
			tbGrowInvestGroup[v.nGroup] = tbGrowInvestGroup[v.nGroup] or {};
			local tbData = { nLevel = v.nLevel, nAwardGold = v.nAwardGold }
			if v.nDay ~= 0 then
				tbData.nDay = v.nDay
			end
			tbGrowInvestGroup[v.nGroup][v.nIndex] =  tbData
		end
	end

	Recharge.tbGrowInvestGroup = tbGrowInvestGroup

	self.tbProductionSettingAll = tbProductionSettingAll
	self.tbSettingGroup = tbSettingGroup

	--todo 一个版本的vip经验以对应的货币标准为准
	self.szDefMoneyType = self.tbSettingGroup.BuyGold[1].szMoneyType;
	if version_kor then
		if MODULE_GAMESERVER then
			assert(self.szDefMoneyType == "KRW"); --韩国的ios和安卓客户端使用了不同的货币， 但是服务端统一用krw,存盘值也是KRW
		end
		self.szDefMoneyType = "KRW";
	end
	if not version_tx  then
		local nRate = self.tbMoneyRMBRate[self.szDefMoneyType]
		for i,v in ipairs(Recharge.tbVipSetting) do
			if version_kor then
				Recharge.tbVipSetting[i] = v / nRate
			else
				Recharge.tbVipSetting[i] = math.ceil(v / nRate)
			end
			
		end
	end

end
Recharge:Init()



function Recharge:GetDaysCardLeftDay(pPlayer, nIndex)
	if not self.tbSettingGroup.DaysCard then
		return 0;
	end
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	if not tbBuyInfo then
		return 0
	end
	return Lib:GetLocalDay(pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) - 3600 * 4) - Lib:GetLocalDay(GetTime() - 3600 * 4)
end

function Recharge:GetDaysCardLeftTime(pPlayer, nIndex)
	if not self.tbSettingGroup.DaysCard then
		return 0;
	end
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	if not tbBuyInfo then
		return 0
	end
	return pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) - GetTime()
end

function Recharge:GetDaysCardEndTime(pPlayer, nIndex)
	if not self.tbSettingGroup.DaysCard then
		return 0;
	end
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	if not tbBuyInfo then
		return 0
	end
	return pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey);
end

function Recharge:GetTotoalRecharge(pPlayer)
	return self:GetTotoalRechargeGold(pPlayer) + pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD) ;
end

function Recharge:GetTotoalRechargeGold(pPlayer)
	return self.TOTAL_RECHARGE_LARGE * pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD2) + pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD)
end

function Recharge:SetTotoalRechargeGold(pPlayer, nTotal)
	local nHigh = math.floor(nTotal / self.TOTAL_RECHARGE_LARGE) 
	local nLow = nTotal % self.TOTAL_RECHARGE_LARGE
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD2, nHigh)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_ONLY_GOLD, nLow)
end

function Recharge:OnCardActStart(nCardActExtAmount, szCardActName)
	self.nCardActExtAmount = nCardActExtAmount
	self.szCardActName = szCardActName
end
function Recharge:OnCardActEnd()
	self.nCardActExtAmount = nil
	self.szCardActName = nil
end
function Recharge:IsOnActvityDay()
	local nWeekDay = Lib:GetLocalWeekDay(GetTime() - 3600 * 4)
	local nWeekExt;
	if nWeekDay == 6 or nWeekDay == 7 then
		nWeekExt = self.fActivityCardAwardParam
	end
	local nTotal = 0
	if nWeekExt then
		nTotal = nTotal + nWeekExt
	end
	if self.nCardActExtAmount then
		nTotal = nTotal + self.nCardActExtAmount
	end
	return nWeekExt, self.nCardActExtAmount, nTotal
end

function Recharge:GetRefreshDay()
	return Lib:GetLocalDay(GetTime() - 3600 *4)
end

function Recharge:CheckBuyGoldGetNum(pPlayer, szProductId)
	local tbBuyInfo = self.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return 0
	end
	local nMoney = tbBuyInfo.nMoney
	local szGroup = tbBuyInfo.szGroup
	if szGroup ==  "BuyGold" then
		local nSellIdx = tbBuyInfo.nGroupIndex
		local nBuyedFlag = Recharge:GetBuyedFlag(pPlayer);
		local nBuydeBit = KLib.GetBit(nBuyedFlag, nSellIdx)
		if nBuydeBit == 1 then
			return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
		else
			return self:GetGoldNumFromAward(tbBuyInfo.tbFirstAward) --每一项首冲双倍
		end
	elseif szGroup == "DaysCard" then
		return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
	elseif szGroup == "GrowInvest" then
		local tbInfo = self.tbGrowInvestGroup[tbBuyInfo.nGroupIndex][1]
		return tbInfo.nAwardGold
	elseif szGroup == "DayGift" then
		return self:GetGoldNumFromAward(tbBuyInfo.tbAward)
	end
	return 0
end

function Recharge:GetGoldNumFromAward(tbAward)
	if not tbAward then
		return 0
	end
	local nGetGold = 0
	if type(tbAward[1]) ~= "table" then
		if tbAward[1] == "Gold" then
			nGetGold = tbAward[2]
		end 
		return nGetGold
	end
	
	for _,v2 in ipairs(tbAward) do
		if v2[1] == "Gold" then
			nGetGold = nGetGold + v2[2]
		end
	end
	return nGetGold
end



function Recharge:CanBuyProduct(pPlayer, szProductId)
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end
	local szGroup = tbBuyInfo.szGroup
	local bRet,szMsg = true;
	if szGroup == "DaysCard" then
		if not self:CanBuyDaysCard(pPlayer, tbBuyInfo.nGroupIndex) then
			return
		end
	elseif szGroup == "GrowInvest" then
		if not self:CanBuyGrowInvest(pPlayer,tbBuyInfo.nGroupIndex) then
			return
		end
	elseif szGroup == "DayGift" then
		bRet,szMsg = self:CanBuyOneDayCard(pPlayer, szProductId)
	elseif szGroup == "DayGiftSet" then
		bRet,szMsg = self:CanBuyOneDayCardSet(pPlayer)
	elseif szGroup == "YearGift" then
		bRet,szMsg = self:CanBuyYearGift(pPlayer, szProductId)
	elseif szGroup == "DirectEnhance" then
		bRet,szMsg = self:CanBuyDirectEnhance(pPlayer, szProductId)
	elseif szGroup == "DayGiftPlus" then
		bRet,szMsg = self:CanBuyOneDayCardPlus(pPlayer, szProductId)
	elseif szGroup == "DressMoney" then
		bRet, szMsg = self:CanBuyDressMoney()
	elseif szGroup == "BackGift" then
		bRet, szMsg = RegressionPrivilege:CheckCanRecharge(pPlayer)
	end
	if szMsg then
		pPlayer.CenterMsg(szMsg,true)
	end
	return bRet
end

function Recharge:CanBuyYearGift(pPlayer, szProductId)
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end

	if not Activity:__IsActInProcessByType("RechargeNewYearBuyGift") then
		return false, "不在活动时间内不可购买"
	end
	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("达到剑侠尊享%d後可购买", tbBuyInfo.nNeedVipLevel)
    end

	local tbLimitInfo = self.tbNewYearBuySetting[tbBuyInfo.nGroupIndex]
	if tbLimitInfo.nSaveCountKey and  tbLimitInfo.nBuyCount > 1 then
		if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbLimitInfo.nSaveCountKey) >= tbLimitInfo.nBuyCount then
			return false, string.format("最多购买%d次", tbLimitInfo.nBuyCount)
		else
			if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey) == Recharge:GetRefreshDay() then
				return false, "今天已经买过了"
			end
		end
	else
		if pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey) > 0 then
			return false, "最多购买一次"
		end
	end

	local szAwardKey;
	--有的购买项对应时间轴没有的
	if MODULE_GAMESERVER then
		szAwardKey = self.szYearGiftAwardKey
	else
		local tbUiData, tbActData = Activity:GetActUiSetting("RechargeNewYearBuyGift")
		szAwardKey = tbUiData and tbUiData.szAwardKey
	end

	if not szAwardKey then
		return false, "活动已结束"
	end
	local tbInfo = tbBuyInfo[szAwardKey]
	if not tbInfo then
		return false, "未开放对应奖励"
	end

	return true
end

function Recharge:CanBuyDirectEnhance(pPlayer, szProductId)
	if not self.IS_OPEN_BUY_ENHANCE then
		return false, "当前暂时关闭购买"
	end
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return 
	end
	if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey) ~= 0 then
		return false, "当前已经购买"
	end
	local tbLimitSetting = self.tbDirectEnhanceSetting[tbBuyInfo.nGroupIndex]
	if not tbLimitSetting then
		return 
	end
	if GetTimeFrameState(tbLimitSetting.OpenTimeFrame) ~= 1 then
		return 
	end
	if pPlayer.nLevel < tbLimitSetting.nPlayerLevel then
		return false, "等级不够"
	end
	local nMoreCount = 0;
	local tbStrengthen 	= pPlayer.GetStrengthen();
	for nEquipPos = 1,10 do
		local nStrenLevel 	= tbStrengthen[nEquipPos]
		if nStrenLevel >= tbLimitSetting.nEnhanceLevel then
			nMoreCount = nMoreCount + 1;
		end
	end
	if nMoreCount >= 10 then
		return false, string.format("身上没有强化低於%d级的位置", tbLimitSetting.nEnhanceLevel)
	end
	return true;
end

function Recharge:CanBuyOneDayCard(pPlayer, szProductId)
	local tbBuyInfo = Recharge.tbProductionSettingAll[szProductId]
	if not tbBuyInfo then
		return
	end

	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("达到剑侠尊享%d後可购买", tbBuyInfo.nNeedVipLevel)
    end
    local nToday = Recharge:GetRefreshDay()
	if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey) >= nToday then
		return false, "今天已经买过了"
	end
	if self.tbSettingGroup.DayGiftSet then
		local tbBuyInfoSet = self.tbSettingGroup.DayGiftSet[1];
		local nBuySetDay = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfoSet.nBuyDayKey)
		if nBuySetDay >= nToday then
			return false, "已购买组合礼包"
		end
	end
	local bRet,szMsg = self:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
	if not bRet then
		return bRet,szMsg
	end

	return true
end

function Recharge:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
	if pPlayer.GetUserValue(self.SAVE_GROUP ,self.KEY_ONE_DAY_CARD_PLUS_COUNT) > 0 then
		return false, "已购买一三六累积礼包"
	end
	if pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY) >= self:GetRefreshDay() then
		return false, "已领取一三六累积礼包"
	end 
	return true
end

function Recharge:CanBuyOneDayCardSet(pPlayer)
	local tbGroup = self.tbSettingGroup.DayGiftSet
	if not tbGroup then
		return false, "无配置", false
	end
	local tbBuyInfo = tbGroup[1]
	if not tbBuyInfo then
		return false, "无配置", false
	end

	if MODULE_GAMECLIENT and Sdk:IsPCVersion() then
		return false, "PC版不可购买", false
	end

	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("达到剑侠尊享%d後可购买", tbBuyInfo.nNeedVipLevel), true
    end
    local nToday = Recharge:GetRefreshDay()
	if pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey) >= nToday then
		return false, "今天已经买过了", false
	end
	for i,v in ipairs(self.tbSettingGroup.DayGift) do
		if pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) >= nToday then
			return false, "已购买分拆包", false
		end
	end
	local bRet,szMsg = self:IsNotTakeOrBuyedOneDayCardPlus(pPlayer)
	if not bRet then
		return bRet,szMsg, false
	end
	return true, nil, true
end

function Recharge:CanBuyDaysCard(pPlayer, nIndex)
	local tbBuyInfo = self.tbSettingGroup.DaysCard[nIndex]
	if not tbBuyInfo then
		return
	end
	local nLeftDay = self:GetDaysCardLeftDay(pPlayer, nIndex)
	
	if nLeftDay and nLeftDay - 1 >= self.tbDaysCardBuyLimitDay[nIndex] then
		return false, string.format("只有%s剩余时间小於%d天时才能购买新的", tbBuyInfo.szDesc, self.tbDaysCardBuyLimitDay[nIndex])
	end
	local bRet, szMsg = self:IsCanBuySuperDaysCard(nIndex)
	return bRet, szMsg
end

function Recharge:CanBuyGrowInvest(pPlayer, nGroupIndex)
	if nGroupIndex == 4 then
		if not Activity:__IsActInProcessByType("RechargeNewyearGrowInvest") then
			return
		end
	end
	if nGroupIndex == 7 then
		if not RegressionPrivilege:IsShowGrowInvest(pPlayer) then
			return
		end
	end
	if pPlayer.nLevel < Recharge.tbGrowInvestGroup[nGroupIndex][1].nLevel then
		return
	end
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowBuyed[nGroupIndex]) ~= 0 then
		return
	end
	return true
end

function Recharge:CanBuyDressMoney()
	if not Recharge.IS_OPEN_BUY_DRESS then
		return
	end
	if  version_tx then
		if MODULE_GAMECLIENT  then
			if Sdk:IsLoginByGuest() then
				return
			end
		end

	else
		local tbGroup = self.tbSettingGroup.DressMoney
		if not tbGroup then
			return
		end
		if not tbGroup[1] then
			return
		end
	end
	return true
end

function Recharge:GetBuyedFlag(pPlayer)
	return pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_BUYED_FLAG)
end

function Recharge:ClearBuyedFlag(pPlayer)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_BUYED_FLAG, 0)
end

function Recharge:GetRechareRMBToGold(nRechareRMB, bCeil) 
	if bCeil then
		return math.ceil(Recharge.tbMoneyThirdRate[self.szDefMoneyType] * nRechareRMB) 	
	else
		return math.floor(Recharge.tbMoneyThirdRate[self.szDefMoneyType] * nRechareRMB) 	
	end
	
end

function Recharge:GetActRechareRMBToGold(nRechareRMB) --活动用的充值对应元宝数,不计算额外赠送的
	return math.ceil(Recharge.tbMoneyRMBRate[self.szDefMoneyType] *  nRechareRMB / 10)  --tbMoneyRMBRate对应的是vip经验所以除以10
end

--获取领取天数保存的Key
function Recharge:GetDayInvestTaskedDayKey(nGroupIndex)
	if nGroupIndex == 4 then
		return self.KEY_INVEST_ACT_TAKEDAY
	end
	if nGroupIndex == 7 then
		return self.KEY_INVEST_BACK_TAKEDAY
	end
end

--获取活动一本万利，回归一本万利当前可以领的天数
function Recharge:GetActGrowInvestTakeDay(pPlayer, nGroupIndex)
	local nSaveKey = self:GetDayInvestTaskedDayKey(nGroupIndex)
	if not nSaveKey then
		return 0
	end

	local nTakedDay = pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKey)
	local nRefreshDay = Recharge:GetRefreshDay()
	local nNowMinus = nRefreshDay  - nTakedDay
	if nNowMinus > 0  then --放回第一个可领的
		local nTaked = pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbKeyGrowTaked[nGroupIndex])
		local tbSetting = self.tbGrowInvestGroup[nGroupIndex]
		for i, v in ipairs(tbSetting) do
			if KLib.GetBit(nTaked, i) == 0 then
				if i == 1 then
					return i ;
				else
					local nDayMinus = v.nDay - tbSetting[i - 1].nDay
					if nNowMinus >= nDayMinus then
						return i;		
					end
				end
				break;
			end
		end
	end
	return 0;
end


--这是是否可一键领取，还有是否可一键购买
function Recharge:CanTakeOneDayCardPlusAward(pPlayer)
	local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
	if nOldCount <= 0 then
		return false, "没有可领取次数"
	end
	local nTakedDay = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY)
	if self:GetRefreshDay() == nTakedDay then
		return false, "今天已经领取过了，请[FFFE0D]淩晨4点[-]过後再来领取", nOldCount
	end
	return true, nil, nOldCount 
end

function Recharge:CanBuyOneDayCardPlus(pPlayer)
	if not self.tbSettingGroup.DayGiftPlus then
		return false, "无对应购买项", false
	end
	if MODULE_GAMECLIENT and Client:IsCloseIOSEntry() then
        return false, "暂时遮罩", false
    end

	local tbBuyInfo = self.tbSettingGroup.DayGiftPlus[1]
	
	local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
	if nOldCount > 0 then
		return false, "还有可领取次数", true
	end
	if GetTimeFrameState("OpenLevel49") ~= 1 then --时间轴限制是后面加的，如果还有可领的就不做这个限制了
		return false, "暂未开启一键购买，请侠士在开放49级上限後再尝试", false
	end
	if pPlayer.GetVipLevel() < tbBuyInfo.nNeedVipLevel then
        return false, string.format("达到剑侠尊享%d後可购买", tbBuyInfo.nNeedVipLevel), true
    end

	--如果当前已经有买每日礼包 或者一键每日礼包的 都不鞥买了
	local nToday = self:GetRefreshDay()
	if self.tbSettingGroup.DayGiftSet then
		local tbBuyInfoSet = self.tbSettingGroup.DayGiftSet[1];
		local nBuySetDay = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfoSet.nBuyDayKey)
		if nBuySetDay >= nToday then
			return false, "已购买组合礼包", true
		end
	end

	for i,v in ipairs(self.tbSettingGroup.DayGift) do
		if pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) >= nToday then
			return false, "已购买过礼包，无法进行一键购买，请[FFFE0D]淩晨4点[-]後再尝试", true
		end
	end

    return true, nil, true;
end

function Recharge:GetDayCardAward(nIndex)
	local tbAward = {}
	for i,v in ipairs(Recharge.tbDayCardAward[nIndex]) do
		if GetTimeFrameState(v[2]) == 1 then
			tbAward = v[1];
		end 
	end
	return tbAward;
end

function Recharge:IsCanBuySuperDaysCard(pPlayer, nIndex)
	local nSavceKey = self.tbSaveKeySuperDaysCard[nIndex]
	if not nSavceKey then
		return true
	end
	if pPlayer.GetUserValue(self.SAVE_GROUP, nSavceKey) <= 0 then
		return false, "您当前不具备至尊周卡的购买资格"
	end
	return true
end

