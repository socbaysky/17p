Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1611

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/LoverRecallFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/LoverRecallFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "心魔幻境"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5000, 9800}  
tbFubenSetting.tbTempRevivePoint = {5000, 9800}  


-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    
}

tbFubenSetting.ANIMATION = 
{
   
}

--NPC模版ID，NPC等级，NPC五行；
--[[

]]

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 2288, nLevel = -1, nSeries = 0},  --纳兰真
    [2] = {nTemplate = 2287, nLevel = -1, nSeries = 0},  --杨影枫
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 756, nLevel = -1, nSeries = 0},  --毒蜂
    [5] = {nTemplate = 757, nLevel = -1, nSeries = 0},  --大型毒蜂
    [6] = {nTemplate = 758, nLevel = -1, nSeries = 0},  --大型毒蜂         
}

-- ChangeRoomState              更改房间title
--                              参数：nFloor 层, nRoomIdx 房间序列, szTitile 标题, nX, nY自动寻路点坐标, bKillBoss 是否杀死了BOSS
--                              示例：{"AddNpc", "NpcIndex2", "NpcNum2", 3, "Test1", "NpcPos2", true, 30, 2, 206, 1},

tbFubenSetting.LOCK = 
{
    -- 1号锁不能不填，默认1号为起始锁，nTime是到时间自动解锁，nNum表示需要解锁的次数，如填3表示需要被解锁3次才算真正解锁，可以配置字符串
    [1] = {nTime = 1, nNum = 0,
        --tbPrelock 前置锁，激活锁的必要条件{1 , 2, {3, 4}}，代表1和2号必须解锁，3和4任意解锁一个即可
        tbPrelock = {},
        --tbStartEvent 锁激活时的事件
        tbStartEvent = 
        {
            {"OpenWindow", "RockerGuideNpcPanel", "心魔幻境 纯真"},
            {"SetKickoutPlayerDealyTime", 20},

            {"SetTargetPos", 6000, 7500},

            {"SetFubenProgress", -1, "四处探索"}, 
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
            {"BlackMsg", "这是…心魔幻境？不知杨少侠与纳兰姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --杨影枫 
            --{"AddNpc", 1, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 0, 0, 0, 0},

            --纳兰真 
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 30, 0, 0, 0},   
            {"SetNpcProtected", "Npc2", 1},

            --解锁
            {"TrapUnlock", "TrapLock1", 2},        
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },
    [3] = {nTime = 20, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
            --纳兰真 
            --{"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos1", false, 0, 0, 0, 0},

            {"NpcBubbleTalk", "Npc2", "杨大哥受伤很重，我一定要采来银丝草为他疗伤……", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "帮他恢复内功，他一定会很高兴的！想想就觉得开心！", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "可是，也许他恢复内功，就要离开了……", 4, 11, 1},
            {"NpcBubbleTalk", "Npc2", "若真是那样…我还会觉得高兴吗…", 4, 16, 1},         

            {"BlackMsg", "杨少侠从悬崖坠落，身受重伤，是纳兰姑娘救了他，因此结缘"},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [4] = {nTime = 0, nNum = 12,
        tbPrelock = {3},
        tbStartEvent = 
        {
            --刷毒蜂
            {"AddNpc", 4, 8, 4, "guaiwu1", "guaiwu1_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 5, 3, 4, "guaiwu1", "guaiwu2_pos", 1, 0, 0, 0, 0},
            {"AddNpc", 6, 1, 4, "guaiwu1", "guaiwu3_pos", 1, 0, 0, 0, 0},

            --纳兰真
            {"NpcBubbleTalk", "Npc2", "这麽多毒蜂…我该怎麽办…", 4, 1, 1},

            {"BlackMsg", "前方忽然出现了大批的毒蜂！帮帮纳兰姑娘！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"BlackMsg", "纳兰姑娘的幻影忽然消失了"}, 
            {"SetFubenProgress", -1, "继续前进"}, 
        },
    },   
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos2", false, 42, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos2", false, 12, 0, 0, 0},

            {"TrapUnlock", "TrapLock2", 5},   
            
            {"SetTargetPos", 5500, 3100},
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
            {"BlackMsg", "唉，纳兰姑娘实在是太善良了"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "杨大哥…刚才掉下来的时候，我、我很害怕你会扔下我…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "怎麽会呢？我怎麽会扔下你不管呢？", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "可若是我们无法离开，你要成为天下第一的愿望就会落空", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "方才倒是未曾多想，只知不可扔你一人不管。", 4, 16, 1}, 
            {"NpcBubbleTalk", "Npc2", "谢、谢谢你…杨大哥…", 4, 21, 1},
            {"NpcBubbleTalk", "Npc1", "嗯。只不过，这到底是哪儿呢？", 4, 26, 1}, 
            {"NpcBubbleTalk", "Npc2", "（杨大哥…有那麽一瞬，你愿为我暂放天下第一，我已心满意足…）", 4, 26, 1},   

            {"SetFubenProgress", -1, "聆听二人对话"},  
        },
        tbUnLockEvent = 
        {
            --删除杨影枫
            {"PlayEffect", 9005, 5800, 2400, 0, 1},
            {"DelNpc", "Npc1"},
            --删除纳兰真
            {"PlayEffect", 9005, 5380, 2240, 0, 1},
            {"DelNpc", "Npc2"},            
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },
    [7] = {nTime = 3, nNum = 0,
        tbPrelock = {6},
        tbStartEvent = 
        {
 
            {"SetFubenProgress", -1, "继续前进"},  
        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos3", false, 42, 0, 0, 0},
        },
    },    
    [8] = {nTime = 0, nNum = 1,
        tbPrelock = {6},
        tbStartEvent = 
        {
            {"SetTargetPos", 3000, 4500},

            {"TrapUnlock", "TrapLock3", 8},   

        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },       
    [9] = {nTime = 20, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "影枫哥哥，我好担心你再次陷入绝境…不要走", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "真儿，不必为我担心，男子汉大丈夫若有所做为，怎能缩头缩尾！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "除非你杀了我！否则你休想离开忘忧岛半步！", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "想来这便是我心中的贪逸所幻化，如果我不能破除此结，将来行道江湖决心必不会坚定！", 4, 16, 1},

            {"SetFubenProgress", -1, "聆听二人对话"},  
        },
        tbUnLockEvent = 
        {

        },
    },    
    [10] = {nTime = 3, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },
    [11] = {nTime = 2, nNum = 0,
        tbPrelock = {10},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },      
    [12] = {nTime = 20, nNum = 0,
        tbPrelock = {11},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "影枫哥哥，你怎麽如此狠心？", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "真儿，你知道我必须完成爹爹的遗愿！相信我会再回来的！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "不，我不要听……我不让你走，我不管什麽遗愿，什麽天下第一！", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "怎麽会变成这样……？魔由心出……心魔，一定是心魔！", 4, 16, 1},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [13] = {nTime = 3, nNum = 0,
        tbPrelock = {12},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },
    [14] = {nTime = 2, nNum = 0,
        tbPrelock = {13},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },  
    [15] = {nTime = 20, nNum = 0,
        tbPrelock = {14},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "天下第一真的那麽重要？成为了天下第一你又能如何？你会後悔的……", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "又是心魔！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "影枫，你很讨厌我，要离开我是吗？你会後悔的……", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "不是这样的，真儿！你……不是真儿，是我的心结！", 4, 16, 1},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [16] = {nTime = 3, nNum = 0,
        tbPrelock = {15},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },
    [17] = {nTime = 2, nNum = 0,
        tbPrelock = {16},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },  
    [18] = {nTime = 20, nNum = 0,
        tbPrelock = {17},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "天下第一真的那麽重要？成为了天下第一你又能如何？你会後悔的……", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "又是心魔！", 4, 6, 1}, 
            {"NpcBubbleTalk", "Npc2", "影枫，你很讨厌我，要离开我是吗？你会後悔的……", 4, 11, 1}, 
            {"NpcBubbleTalk", "Npc1", "不是这样的，真儿！你……不是真儿，是我的心结！", 4, 16, 1},
        },
        tbUnLockEvent = 
        {

        },
    },    
    [19] = {nTime = 3, nNum = 0,
        tbPrelock = {18},
        tbStartEvent = 
        {
            --杨影枫秀一波
            {"DoCommonAct", "Npc1", 16, 0, 0, 0},
            {"CastSkill", "Npc1", 1763, 1, 2350, 5000},
            --重伤动作
            {"DoCommonAct", "Npc2", 36, 0, 1, 0},
        },
        tbUnLockEvent = 
        {
            --定时器自杀
            {"CastSkill", "Npc2", 3, 1, -1, -1},            
        },
    },   
    [20] = {nTime = 2, nNum = 0,
        tbPrelock = {19},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    },  
    [21] = {nTime = 10, nNum = 0,
        tbPrelock = {20},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "大丈夫在世有所为，有所不为，我宁可出不了此阵，也万万不会对真儿下手", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc2", "你……我不理你了！", 4, 6, 1}, 
        },
        tbUnLockEvent = 
        {
            --删除纳兰真
            {"PlayEffect", 9005, 2350, 5000, 0, 1},
            {"DelNpc", "Npc2"},            
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
        },
    },  
    [22] = {nTime = 2, nNum = 0,
        tbPrelock = {21},
        tbStartEvent = 
        {
 

        },
        tbUnLockEvent = 
        {
            --纳兰真
            {"AddNpc", 1, 1, 1, "Npc2", "LoverRecall_Npc2_Pos3", false, 10, 0, 0, 0},

        },
    }, 
    [23] = {nTime = 15, nNum = 0,
        tbPrelock = {22},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "真儿，此时此刻，我才知道你在我心中有多重要！", 4, 1, 1},   --Npc2已经挂了，这句执行不到
            {"NpcBubbleTalk", "Npc2", "谢谢你，杨大哥…你竟为了我克制住了幻境中的心魔…", 4, 6, 1},
            {"NpcBubbleTalk", "Npc1", "真儿，此生此世，我们再也不分开了！", 4, 11, 1},   --Npc2已经挂了，这句执行不到
        },
        tbUnLockEvent = 
        {

        },
    },
    [24] = {nTime = 5, nNum = 0,
        tbPrelock = {23},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
        },
    },       
    [100] = {nTime = 600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            {"SetShowTime", 100},
            --{"SetFubenProgress", -1, "即将离开"}, 
        },
        tbUnLockEvent = 
        {
            {"GameLost"},
        },
    },
}