Require("CommonScript/Activity/QingMingActC.lua");
local tbAct = Activity:GetClass("QingMingAct")
local tbFubenSetting = {};
local nMapTemplateId = 1609

Fuben:SetFubenSetting(nMapTemplateId, tbFubenSetting)   -- 绑定副本内容和地图

tbFubenSetting.szNpcPointFile           = "Setting/Fuben/QingMingFuben/NpcPos.tab"         -- NPC点
tbFubenSetting.szPathFile               = "Setting/Fuben/QingMingFuben/NpcPath.tab"        -- 寻路点

tbFubenSetting.szFubenClass   = tbAct.szFubenClass;                                  -- 副本类型
tbFubenSetting.szName         = "清明节"                                             -- 单纯的名字，后台输出或统计使用
tbFubenSetting.tbBeginPoint   = {4400, 5400}  
tbFubenSetting.tbTempRevivePoint = {4400, 5400}  

-- 开始祭拜是需要解锁的锁id，填nil则无需解锁,前提是该锁是开始状态并且还没解锁
tbFubenSetting.nStartWorshipUnlockId = 4
-- 完成祭拜是需要解锁的锁id
tbFubenSetting.nFinishWorshipUnlockId = nil
-- 开始祭拜时玩家的坐标和方向
tbFubenSetting.tbWorshipInfo = {
    {tbPos = {5100, 6080}, nDir = 42},              -- 使用道具者
    {tbPos = {4800, 5720}, nDir = 57},             -- 协助者
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
    [2] = {nTemplate = 2247, nLevel = -1, nSeries = 0},  --天星道长
    [3] = {nTemplate = 2277, nLevel = -1, nSeries = 0},  --挺哥
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
            {"AddNpc", 1, 1, 1, "ShiBei", "QingMing_8_ShiBei", false, 32},

            --纳兰真 
            {"AddNpc", 3, 1, 1, "Npc1", "QingMing_8_Npc1", false, 0, 0, 0, 0},


            {"OpenWindow", "LingJueFengLayerPanel", "Info", 3, 9, "心魔幻境 武当山"},
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
            {"BlackMsg", "不远处有一块碑石，这是……武当山？我怎麽会到了这里？"},
            {"PlayerBubbleTalk", "挺哥，这是怎麽回事？你怎会在这里？"}
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
            {"AddNpc", 2, 1, 1, "Npc2", "QingMing_8_Npc2", false, 0, 0, 0, 0},

            {"BlackMsg", "前方忽然出现了一个虚幻的人影"},
            {"SetFubenProgress", -1, "聆听两人对话"}, 

            --Npc移动
            {"ChangeNpcAi", "Npc2", "Move", "QingMing_Path8", 5, 0, 0, 0},

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
            {"NpcBubbleTalk", "Npc2", "可恨！想不到无忧教的势力竟发展至此！我还一直懵然不知！真是老糊涂！", 4, 1, 1},

            {"NpcBubbleTalk", "Npc1", "师祖…竟真的能够见到师祖…弟子拜见师祖！", 4, 6, 1},

            {"NpcBubbleTalk", "Npc2", "嗯？你是谁？看你装束，确实是我武当弟子，只不过为何我从未见过你？", 4, 11, 1},

            {"NpcBubbleTalk", "Npc1", "师祖，容我详细说来，此处乃心魔幻境，能够短暂实现人心深处的梦想。所以师祖您其实早已…", 4, 16, 1},    

            {"NpcBubbleTalk", "Npc2", "嗯，我虽然老糊涂了，可是仍清楚记得败在了纳兰潜凛的手上，唉，武当遭无忧教血洗。", 4, 21, 1},

            {"NpcBubbleTalk", "Npc1", "师祖不必过於伤感，後来武当卧薪嚐胆，如今已重新成为武林中的中流砥柱。", 4, 26, 1}, 

            {"NpcBubbleTalk", "Npc2", "好！声名倒是其次，但我武当派匡扶武林正道的行为举止，决不能变！", 4, 31, 1},

            {"NpcBubbleTalk", "Npc1", "师祖说得对，如今掌教道一师父云游远去，下一任掌门，想必是天目师兄，天目师兄为人正气，定不负师祖所望。", 4, 36, 1},  

            {"NpcBubbleTalk", "Npc2", "那便好，那便好啊！呵呵，想到武林正道仍存，武当再度崛起，老道就深感欣慰啊！无忧教如何了？", 4, 41, 1},

            {"NpcBubbleTalk", "Npc1", "师祖，无忧邪教十年前便已被毁，剿灭无忧教的乃是一位名叫杨影枫的侠少。", 4, 46, 1},   

            {"NpcBubbleTalk", "Npc2", "不错不错，杨少侠能够平息心魔。走入正道，实乃武林之福，武林之福啊！呵呵呵呵！", 4, 51, 1},

            {"NpcBubbleTalk", "Npc1", "师祖，今日乃清明佳节，弟子特带了些美酒菜肴前来，您……师祖您的身体？", 4, 56, 1},  

            {"NpcBubbleTalk", "Npc2", "呵呵，终究是过眼云烟，无妨，正道得以伸张，老道心愿已了，也无甚牵挂，你天资卓绝，将来也必成一方名侠。去吧。", 4, 61, 1},
        },
    },       
    [6] = {nTime = 65, nNum = 0,
        tbPrelock = {5},
        tbStartEvent = 
        {

        },
        tbUnLockEvent = 
        {
            {"NpcBubbleTalk", "Npc1", "师祖告辞！保重。", 4, 63, 1},
            {"SetFubenProgress", -1, "离开幻境"}, 
            {"BlackMsg", "现在可以离开了！"},
            {"GameWin"},
            --纪念石碑 
            {"AddSimpleNpc", 2276, 4340, 6260, 32}, 

            --纳兰真 
            {"AddSimpleNpc", 2277, 4400, 5830, 0}, 
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