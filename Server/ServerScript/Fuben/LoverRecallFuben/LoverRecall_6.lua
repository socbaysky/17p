Require("CommonScript/Activity/LoverRecallActC.lua");
local tbAct = Activity:GetClass("LoverRecallAct")
local tbFubenSetting = {};
local nMapTemplateId = 1616

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
    [1] = {nTemplate = 2294, nLevel = -1, nSeries = 0},  --杨瑛
    [2] = {nTemplate = 2292, nLevel = -1, nSeries = 0},  --独孤剑
    [3] = {nTemplate = 746, nLevel = -1, nSeries = 0},  --银丝草
    [4] = {nTemplate = 1687, nLevel = -1, nSeries = 0},  --飞龙堡弟子
    [5] = {nTemplate = 1688, nLevel = -1, nSeries = 0},  --飞龙堡护法
    [6] = {nTemplate = 1689, nLevel = -1, nSeries = 0},  --飞龙堡头目         
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
            {"BlackMsg", "这是…心魔幻境？不知独孤少侠与杨姑娘在哪！去前方看看！"},
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        {
            --杨影枫 
            {"AddNpc", 2, 1, 1, "Npc1", "LoverRecall_Npc1_Pos1", false, 28, 0, 0, 0},
            --{"SetNpcProtected", "Npc1", 1},
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

            {"NpcBubbleTalk", "Npc2", "多年来我隐藏身份，唯恐弟兄知道带着他们冒性命之危闯荡江湖的，竟是弱质女流…", 4, 1, 1},
            {"NpcBubbleTalk", "Npc1", "帮主虽然是女子，但胆识过人，顾识大体，没有你，就不会有如今的天王帮", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "独孤公子，我不愿将图交给岳飞，但是我欠你一个人情，既然你要，那我就交给公子", 4, 11, 1},
            {"NpcBubbleTalk", "Npc1", "帮主…（此情此义，却又让我如何报答…）", 4, 16, 1},         

            {"BlackMsg", "独孤少侠刚发现杨姑娘的女儿身，其实当时杨姑娘已对独孤少侠怀有情意"},

            {"SetFubenProgress", -1, "聆听二人对话"}, 
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
            {"NpcBubbleTalk", "Npc2", "是你！封左使！原来你早就包藏祸心，一直监视我的行踪！", 4, 1, 1},

            {"BlackMsg", "前方忽然出现了大批的天王叛徒！帮帮杨姑娘与独孤少侠！"},               
        },
        tbUnLockEvent = 
        {   
            {"PlayEffect", 9005, 5963, 7552, 0, 1},
            {"DelNpc", "Npc2"},
            {"DelNpc", "Npc1"},
            {"BlackMsg", "杨姑娘与独孤少侠的幻影忽然消失了"}, 
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

            {"SetFubenProgress", -1, "继续前进"}, 
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "那时独孤少侠方得知，其实这已经不是他们第一次见面了"}, 
            --设置Npc朝向
            --{"SetNpcDir", "Npc1", 0}
            {"ClearTargetPos"},
        },
    },
    [6] = {nTime = 30, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "可惜让他跑了！杨……姑娘，原来，一直暗中帮助我的人是你……", 4, 1, 1},
            {"NpcBubbleTalk", "Npc2", "独孤大哥，我可以这样叫你吗？碧霞岛上的局是我安排的，为了山河社稷图", 4, 6, 1},
            {"NpcBubbleTalk", "Npc2", "整个事情都在我的计画之中，但是我却没有预料到会遇上你……", 4, 10, 1},
            {"NpcBubbleTalk", "Npc2", "你先别说话，独孤大哥，自从碧霞岛一别後，杨瑛，就已经不再是以前的杨瑛了", 4, 15, 1}, 
            {"NpcBubbleTalk", "Npc2", "独孤大哥，我明白，你和那位张姑娘情投意合，我……是不会让你为难的", 4, 21, 1},
            {"NpcBubbleTalk", "Npc2", "上天真是爱捉弄人！我最恨的人，偏偏是一个大英雄，我最…的人，偏偏又情有所属…", 4, 26, 1}, 
            {"NpcBubbleTalk", "Npc1", "杨姑娘，你一定会遇上一个比我好千百倍的人……", 4, 26, 1},   

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

            {"SetFubenProgress", -1, "继续前进"}, 
        },
        tbUnLockEvent = 
        {
            {"ClearTargetPos"},
        },
    },       
    [9] = {nTime = 18, nNum = 0,
        tbPrelock = {8},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "独孤大哥！", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc1", "……", 4, 5, 1}, 
            {"NpcBubbleTalk", "Npc2", "好风成意秋正浓，纸鸢迭做却难升。天意从来高难问，总把云霞晚鹭分……", 4, 10, 1},
            {"NpcBubbleTalk", "Npc1", "阿瑛……", 4, 15, 1}, 

            {"SetFubenProgress", -1, "聆听二人对话"}, 
        },
        tbUnLockEvent = 
        {

        },
    },  
    [10] = {nTime = 13, nNum = 0,
        tbPrelock = {9},
        tbStartEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "泰山武林大会？还是让年轻人去吧", 4, 1, 1}, 
            {"NpcBubbleTalk", "Npc2", "剑哥，灩心年纪尚小，不会有什麽事吧？", 4, 5, 1},
            {"NpcBubbleTalk", "Npc1", "阿瑛，不必担心，她的武功足以自保，我们也该逍遥自在了", 4, 10, 1}, 

            {"BlackMsg", "光阴转瞬即逝……眨眼来到了十年後……"},
        },
        tbUnLockEvent = 
        {

        },
    },  
    [11] = {nTime = 5, nNum = 0,
        tbPrelock = {10},
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