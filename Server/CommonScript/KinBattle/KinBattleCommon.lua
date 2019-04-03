
KinBattle.STATE_NONE = 0;
KinBattle.STATE_PRE = 1;
KinBattle.STATE_FIGHT = 2;

KinBattle.PRE_MAP_ID = 1021;
KinBattle.tbPreMapBeginPos = {5609, 8595};

KinBattle.MAX_PLAYER_COUNT = 20;

KinBattle.FIGHT_MAP_ID = 1023;
KinBattle.tbFightMapBeginPoint = {
	{4150,  6788};
	{14244, 6788};
};

KinBattle.nPreTime = 5 * 60;

KinBattle.nNpcRefreshTime = 60;

KinBattle.fileCommNpc = "Setting/Battle/KinBattle/CommNpcSetting.tab";
-- KinBattle.fileDotaNpc = "Setting/Battle/KinBattle/DotaNpcSetting.tab";
KinBattle.fileWildNpc = "Setting/Battle/KinBattle/WildNpcSetting.tab";
KinBattle.fileMovePath= "Setting/Battle/KinBattle/MovePath.tab";

KinBattle.tbKinRankSetting = {6, 11, 21, 31};

KinBattle.nKinBattleTypeCount = 2;

KinBattle.tbStateTrans = KinBattle.STATE_TRANS;

KinBattle.tbResultKinMsg =
{
	[-1] = "本帮派在本轮帮派中与对手战成平局";			--平局
	[0] = "很遗憾，本帮派在本轮帮派战中战败了";				--失败
	[1] = "恭喜本帮派在本轮帮派中战胜对手！";			--胜利
}
KinBattle.tbFightByeMsg = "本轮轮空，没有匹配到对手，直接获胜！";  --轮空

KinBattle.szStartWorldMsg = "帮派战开启新一轮报名，从活动日历选择参加帮派战";

KinBattle.szWinText = "恭喜你帮派在帮派战的一轮比赛中取得了胜利，每位帮派成员可以获得1200点贡献的奖励";
KinBattle.nWinPrestige = 400;
KinBattle.tbWinAward = {
	{"Contrib", 1200};
};

KinBattle.szFailText = "很遗憾，你帮派在帮派战的一轮比赛中战败了，每位帮派成员可以获得600点贡献的奖励";
KinBattle.nFailPrestige = 200;
KinBattle.tbFailAward = {
	{"Contrib", 600};
};

KinBattle.szDrawText = "你帮派在帮派战的一轮比赛中与对手战成平局，每位帮派成员可以获得900点贡献的奖励";
KinBattle.nDrawPrestige = 300;
KinBattle.tbDrawAward = {
	{"Contrib", 900};
};



KinBattle.tbTimeTips = {
[[报名   20:50
开战   21:00]],
[[报名   21:15
开战   21:20]]
};
KinBattle.szTips = [[·帮派战共分两轮，每轮随机另一帮派作为对手。
·每轮比赛同时开启1号和2号场。每一场中，每个帮派最多只能进入20人。
·1号和2号场同时开战，若帮派在1号、2号场均取得胜利，则判定帮派本轮胜利；若帮派在1号、2号场中，只取得1场胜利，则判定帮派本轮战平。

·每场有人数上限，堂主可手动设置帮派成员参与的等级要求，让符合等级要求的帮派成员来参加比赛。

]]

