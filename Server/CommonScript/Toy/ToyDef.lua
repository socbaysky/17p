Require("CommonScript/Player/PlayerDef.lua")
Toy.Def = {
	nInterval = 30,	--使用间隔（秒）

	szOpenTimeframe = "OpenLevel49",	--开放时间轴
	nGuideId = 51,	--引导id
	tbValidMaps = {	--生效的地图
	99999
		-- 10, 15, 999, 1000, 1004,
		-- 4000, 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008,
	},

	nHideBuffId = 2321,	--隐身buff

	nWindmillResId = 1249,	--风车ResId
	nChildResId = 1248,	--迎客小童ResId

	tbStatueId = { --各门派对应的雕像npcid 分别为男女
		[1]	 = {1841, 1841};--天王
		[2]	 = {1842, 1842};--峨嵋
		[3]	 = {1843, 1843};--桃花
		[4]	 = {1844, 1844};--逍遥
		[5]	 = {1845, 2911};--武当
		[6]	 = {1846, 1846};--天忍
		[7]	 = {1847, 1847};--少林
		[8]	 = {1848, 1848};--翠烟
		[9]	 = {2000, 2000};--唐门
		[10] = {2968, 2002};--昆仑
		[11] = {2215, 2215};--丐帮
		[12] = {2216, 2216};--五毒
		[13] = {2379, 2379};--藏剑山庄
		[14] = {2380, 2380};--长歌门
		[15] = {2655, 2656};--天山
		[16] = {2909, 2910};--霸刀
		[17] = {2966, 2967};--华山
	},

	nDanceRange = 1000,	--天魔笛作用范围

	nStickId = 9565,	--糖葫芦道具id
	nStickRange = 1000,	--糖葫芦作用范围
	tbStickBuff = {4751, 1, 300},	--糖葫芦buff {id, 等级, 持续时间（秒）}

	nMaskId = 9566,	--面具道具id
	nMaskLastTime = 30,	--面具效果持续时间（秒）
	nMaskRange = 1000,	--面具对话距离
	tbMasks = {	--面具配置
		[Player.SEX_MALE] = {	--男性玩家变身
			{
				nResId = 5032,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"吾辈当以家国天下为己任！",
					"习武如逆水行舟，不进则退。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5200] = {	--其他玩家变身ResId
						"守这天下却没了你，琳儿，你可曾怪我。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"晚辈拜见盟主！",
				},
			},
			{
				nResId = 5027,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"独战天下只为她！",
					"我本塞外客，天下任我行。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[6129] = {	--其他玩家变身ResId
						"若雪，可还记得当初的相遇。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"人间风光阅尽，大侠羡煞旁人。",
				},
			},
			{
				nResId = 6101,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"有人见到眉儿了吗？",
					"不知道轩儿最近过得如何。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5177] = {	--其他玩家变身ResId
						"你是古灵精怪的小女孩真儿吗？",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"大侠与几位姑娘的姻缘皆由我见证。",
				},
			},
			{
				nResId = 5119,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"看我漫天花雨，哈哈，骗你的。",
					"少侠可愿往唐家堡一游？",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5158] = {	--其他玩家变身ResId
						"我寻了半生的春天，你一笑便是了。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"见过唐门大公子！",
					"公子可是在找去翠烟门的路？",
				},
			},
			{
				nResId = 5193,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"情不敢至深，恐大梦一场。",
					"此生如梦如幻，终是逃不开宿命。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5126] = {	--其他玩家变身ResId
						"此生纷繁如梦，还好有你，彩虹。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"谁的人生不是大梦一场。",
					"执子之手，与子偕老，大侠终成眷侣。",
				},
			},
		},
		[Player.SEX_FEMALE] = {	--女性玩家变身
			{
				nResId = 5200,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"人间不过机缘巧合，都是缘分。",
					"一往情深是你，血海深仇也是你。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[34] = {	--其他玩家变身ResId
						"独孤大哥，相遇已是不易，还愿你不忘当年之志。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"姑娘历尽风波，心胸令人敬佩。",
				},
			},
			{
				nResId = 6129,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"世界上最远的距离，就是不能爱你。",
					"对错是非都已经看不清了。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5027] = {	--其他玩家变身ResId
						"经年浮华，终不过你的眼眸。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"此生得一人，愿倾盖如故。",
				},
			},
			{
				nResId = 5177,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"你可见过枫哥？",
					"也不知道爹爹最近如何了。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[6101] = {	--其他玩家变身ResId
						"杨大哥是不是又招惹了哪家姑娘？",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"纳兰姑娘何时从忘忧岛出来的？",
				},
			},
			{
				nResId = 5158,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"少侠可敢往翠烟门一游？",
					"我翠烟门人自是天生丽质。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5119] = {	--其他玩家变身ResId
						"影哥为我独闯翠烟，这一生便是你了。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"在下见过翠烟门主。",
				},
			},
			{
				nResId = 5126,	--变身ResId
				tbTalkSelf = {	--自言自语候选语句列表
					"此生斑驳复杂，谁又说的清。",
					"心有所托，方能安身。",
				}, 
				tbTalkSelfInterval = {10, 20},	--自言自语间隔（秒） {最小, 最大}
				tbSpecialTalk = {	--与其他变身玩家特殊对话
					[5193] = {	--其他玩家变身ResId
						"如梦，往事已去，只愿伴君朝朝暮暮。",
					},
				},
				tbOtherTalk = {	--其他非变身玩家对话
					"请教姑娘塞外风光如何。",
				},
			},
		},
	},

	nGreenHatId = 9542,	--绿帽子道具id
	nGreenHatGivenId = 9564,	--可穿戴绿帽子道具id

	nLightNpcId = 3252,	--琉璃灯NPC id
	nLightDuration = 10,	--琉璃灯存活时间（秒）

	--
	-- 以下由程序配置
	--
	nUnlockSaveGrp = 178,
	nUseCountSaveGrp = 179,
}

Toy.Def.tbMustHaveItem = {
	ToyHat = Toy.Def.nGreenHatId,
	ToyMask = Toy.Def.nMaskId,
	ToyStick = Toy.Def.nStickId,
}

Toy.Def.tbNeedTarget = {
	ToyHat = true,
	ToyLaugh = true,
	ToyStick = true,
}