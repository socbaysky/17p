Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1603

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {5920, 1970}  
tbFubenSetting.tbTempRevivePoint = {5950, 1680}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {6070, 1940}, nDir = 48},              -- 使用道具者
    {tbPos = {5880, 1630}, nDir = 60},             -- 协助者
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
    [2] = {nTemplate = 2242, nLevel = -1, nSeries = 0},  --张琳心
    [3] = {nTemplate = 2251, nLevel = -1, nSeries = 0},  --独孤剑
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_2_ShiBei", false, 18},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_2_Npc1", false, 49, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 凤凰山"},
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
            {"BlackMsg", "不远处有一块碑石，这是……凤凰山？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "独孤大侠，这是怎麽回事？你怎会在这里？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_2_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path2", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 49}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "夫君，这是真的麽？我竟能再见到你……", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "纵使知晓这心魔幻境乃虚妄之地，但能再见到你，便是痴狂亦无妨！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "夫君，这麽多年不见，你苍老了许多……", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "失去你，此生本已了无生趣，只是抗金大业未成，我不忍抛下他们！", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "夫君，千万不可，你曾答应我要好好地活下去，对了，杨姑娘呢？她……", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "唉，琳儿，你应该清楚，除了你以外，我心中再容不下其他人，杨瑛是个好姑娘，但……", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "杨姑娘如此忠烈，想必亦是终生未嫁，我已是久死之人，你们这又是何苦呢？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "琳儿，此事休要再提，若真有来生，我亦要继续寻你觅你。", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "夫君…你对我情深至此…琳儿便不再多言，若有来生，我自会静静相待，非君不嫁。", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "只愿来生你我均生在一个普通的小家庭，莫要再被国仇家恨所纠缠。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "夫君，身体要紧，此後你可不能再这般放纵自己了。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "好，琳儿，你放心，我这把老骨头尚有用处，我定会……琳儿，你……", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "看来时候差不多了，琳儿与你就此别过了，夫君，珍重……", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "琳儿……", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 5400, 2000, 18}, 

            --纳兰真 
            {"AddSimpleNpc", 2251, 5780, 1980, 49}, 
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