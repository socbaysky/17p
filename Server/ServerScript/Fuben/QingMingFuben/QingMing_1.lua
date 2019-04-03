Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1602

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5000, 8100}  
tbFubenSetting.tbTempRevivePoint = {5000, 8100}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {4820, 8150}, nDir = 5},              -- 使用道具者
    {tbPos = {5000, 8200}, nDir = 0},             -- 协助者
}

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
    [1] = {nTemplate = 2257, nLevel = -1, nSeries = 0},  --纪念石碑
    [2] = {nTemplate = 2241, nLevel = -1, nSeries = 0},  --纳兰潜凛
    [3] = {nTemplate = 2250, nLevel = -1, nSeries = 0},  --纳兰真
    [4] = {nTemplate = 2276, nLevel = -1, nSeries = 0},  --纪念石碑（展示）
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
            --纪念石碑 
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_1_ShiBei", false, 0, 0, 0, 0},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_1_Npc1", false, 0, 0, 0, 0},

            {"OpenWindow", "RockerGuideNpcPanel", "心魔幻境 忘忧岛"},
            {"SetKickoutPlayerDealyTime", 20},
        },
        --tbStartEvent 锁解开时的事件
        tbUnLockEvent = 
        {            
        },
    },
    [2] = {nTime = 3, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        {
            
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "不远处有一块碑石，这是……忘忧岛？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "纳兰姑娘，这是怎麽回事？你怎会在这里？"}
        },
    },
    [3] = {nTime = 3, nNum = 0,
        tbPrelock = {2},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "前方的石碑上似乎有些文字，不妨去看看上面写了什麽"},   
            {"SetFubenProgress", -1, "查看石碑"}, 
        },
    },
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            --祭拜开始时解锁，刷出Npc纳兰潜凛
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_1_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path1", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 0}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "真儿，许久不见，想不到竟能再次见到你……", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "想不到这心魔幻境竟真能见到爹爹！这几日乃清明佳节，我来看看你", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "哼，那杨影枫对你可好？若他敢负你，我便化作恶鬼，也不放过他！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…你放心…他对我很好，只是我十分想念你", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "如此便好，武林霸业竟已成黄粱一梦，你能幸福快乐，爹爹便心满意足了。", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹… 哎，早知如此，又何必当初？", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "笑话！成王败寇，本应如此！哼，你这小姑娘，又懂得些什麽！", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "唉，爹爹，为了这念头，你害得母亲离去，如今又搭上了自己的性命，值得麽？", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "真儿，这世上何等辽阔，你父亲我若是胸无大志，又岂能成为一代宗师？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "唉，也罢，也许你我所求不同，只愿你在九泉之下，能活的快乐。是女儿不孝。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "为父亦然，见你活的开心，一切安好，为父便放心了，是时候该离去了。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "爹爹…你…", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "好了，为父走了，你也早些回吧。", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "爹爹…保重…", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4900, 8700, 0}, 

            --纳兰真 
            {"AddSimpleNpc", 2250, 4880, 8330, 0}, 
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