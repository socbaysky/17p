Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1610

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {2750, 5330}  
tbFubenSetting.tbTempRevivePoint = {2750, 5330}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {2980, 5550}, nDir = 47},              -- 使用道具者
    {tbPos = {2330, 6020}, nDir = 30},             -- 协助者
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
    [2] = {nTemplate = 2249, nLevel = -1, nSeries = 0},  --岳飞
    [3] = {nTemplate = 2278, nLevel = -1, nSeries = 0},  --公孙惜花
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_9_ShiBei", false, 32},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_9_Npc1", false, 60, 0, 0, 0},

            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 风波亭"},
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
            {"BlackMsg", "不远处有一块碑石，这是……风波亭？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "公孙老板娘，这是怎麽回事？你怎会在这里？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_9_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path9", 5, 0, 0, 0},

            --设置Npc朝向
            {"SetNpcDir", "Npc1", 60}
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {
        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc2", "这里…是哪里？是了！是风波亭！秦桧！恶贼！奸党！我要杀了你！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "好了好了，多少岁的人了，还这般动肝火，省省心吧，你还嫌杀的人不够麽？", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "哼！若是杀敌寇，便是再来万千个，也杀不够！若是我宋朝子民，我一个也不杀！", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "哟，大英雄，你倒是说得轻巧，莫要忘了，你方才口口声声要杀之人，可也是我大宋子民。", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "他……他这样的人，留着徒增祸害！置家国於不顾，又岂能称之为我朝子民？", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "唉，岳大将军，你一生戎马，驰骋沙场，也是时候该歇歇了。", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "嗯？对了，我还没问，你这小姑娘伶牙俐齿的，究竟是谁？我现在又身在何处？", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "你和我均处於心魔幻境之中，传闻此阵能够让一些人的幻想短暂化为现实，想不到真有奇效", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "原来如此，我还以为是你救了我，现在看来，终究是无法救万民於水火之中了。如今宋、金情势如何？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "我可没那本事救你。至於情势，没有了你，情势如何还需要我说吗？我来便是像向你请教山河社稷图之事", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "唉，区区一份图谱，又岂能改变天下？还是留着，兴许後世能够有人借此重整旗鼓。", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "岳大将军，我已知道想要的答案，你的身体也越发虚幻，就在此好好休息吧，你的事业，总会有後来者替你完成的", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "姑娘留步，敢问姑娘的名字？", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "树欲静而风不止，子欲养而亲不待，我欲要说，你却又不在了。记住，我叫公孙惜花。保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开副本了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 2620, 6240, 32}, 

            --纳兰真 
            {"AddSimpleNpc", 2278, 2480, 5670, 60}, 
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