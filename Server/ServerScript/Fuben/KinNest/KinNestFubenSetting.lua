
local tbFubenSetting = {};
Fuben:SetFubenSetting(Kin.Def.nKinNestMapTemplateId, tbFubenSetting)        -- 绑定副本内容和地图

tbFubenSetting.nDuraTime                =  3600; -- 副本时长
tbFubenSetting.szFubenClass             = "KinNestFuben";                                   -- 副本类型
tbFubenSetting.szName                   = "侠客岛"                                            -- 单纯的名字，后台输出或统计使用
tbFubenSetting.szNpcPointFile           = "Setting/Fuben/KinNestFuben/NpcPos.tab"           -- NPC点
tbFubenSetting.tbBeginPoint             = {3000, 3300}                                          -- 副本出生点
tbFubenSetting.nStartDir                = 40
tbFubenSetting.tbTempRevivePoint        = {3100, 3300}                                          -- 临时复活点，副本内有效，出副本则移除

-- ID可以随便 普通副本NPC数量 ；精英模式NPC数量
tbFubenSetting.NUM = 
{
    NpcIndex1       = {1, 4, 7, 10, 13, 16, 19, 22},
    NpcIndex2       = {2, 5, 8, 11, 14, 17, 20, 23},
    NpcIndex3       = {3, 6, 9, 12, 15, 18, 21, 24},
}

tbFubenSetting.ANIMATION = 
{

}

--{"RaiseEvent", "OnAddKinRobberNpc", nIndex, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime}, --添加剩余盗贼
--NPC模版ID，NPC等级，NPC五行；

tbFubenSetting.NPC = 
{
    [1] = {nTemplate = 655, nLevel = 35, nSeries = 1},  --大当家
    [2] = {nTemplate = 656, nLevel = 35, nSeries = 1},  --二当家
    [3] = {nTemplate = 657, nLevel = 35, nSeries = 1},  --三当家
    [4] = {nTemplate = 655, nLevel = 45, nSeries = 1},
    [5] = {nTemplate = 656, nLevel = 45, nSeries = 1},
    [6] = {nTemplate = 657, nLevel = 45, nSeries = 1},
    [7] = {nTemplate = 655, nLevel = 55, nSeries = 1},
    [8] = {nTemplate = 656, nLevel = 55, nSeries = 1},
    [9] = {nTemplate = 657, nLevel = 55, nSeries = 1},
    [10] = {nTemplate = 655, nLevel = 65, nSeries = 1},
    [11] = {nTemplate = 656, nLevel = 65, nSeries = 1},
    [12] = {nTemplate = 657, nLevel = 65, nSeries = 1},
    [13] = {nTemplate = 655, nLevel = 75, nSeries = 1},
    [14] = {nTemplate = 656, nLevel = 75, nSeries = 1},
    [15] = {nTemplate = 657, nLevel = 75, nSeries = 1},
    [16] = {nTemplate = 655, nLevel = 85, nSeries = 1},
    [17] = {nTemplate = 656, nLevel = 85, nSeries = 1},
    [18] = {nTemplate = 657, nLevel = 85, nSeries = 1},
    [19] = {nTemplate = 655, nLevel = 95, nSeries = 1},
    [20] = {nTemplate = 656, nLevel = 95, nSeries = 1},
    [21] = {nTemplate = 657, nLevel = 95, nSeries = 1},
    [22] = {nTemplate = 655, nLevel = 100, nSeries = 1},
    [23] = {nTemplate = 656, nLevel = 100, nSeries = 1},
    [24] = {nTemplate = 657, nLevel = 100, nSeries = 1},
    [25] = {nTemplate = 654, nLevel = 1, nSeries = 1},  --篝火
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
            {"RaiseEvent", "OpenOwnerInvitePanel"},
            {"ShowTaskDialog", 10006, false},
            --{"RaiseEvent","AddKinRobberNpc", 2},  --刷盗贼       
            {"BlackMsg", "此处确实是奸商的地窖，但是好像杀气重重！看看到底怎麽回事！"},            
        },
    },
    [2] = {nTime = 0, nNum = 1,
        tbPrelock = {1},
        tbStartEvent = 
        { 
            {"TrapUnlock", "TrapLock1", 2},        
            {"RaiseEvent", "AddKinRobberBoss", "NpcIndex1", 1, 3, "boss", "RobberBoss_1", false, 0 , 0, 9005, 0.5},               
        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"NpcBubbleTalk", "NpcIndex1", "居然有人敢来卢员外的地盘！受死吧！", 10, 2, 1},
            {"BlackMsg", "果然有人守在这里！双拳难敌四手！结果了他！"},
        },
    },
    [3] = {nTime = 0, nNum = 1,
        tbPrelock = {2},
        tbStartEvent = 
        {               

        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"BlackMsg", "此人武功高强，此处危险重重，得小心为上，往前走看看！"},
        },
    },    
    [4] = {nTime = 0, nNum = 1,
        tbPrelock = {3},
        tbStartEvent = 
        { 
            {"TrapUnlock", "TrapLock2", 4},        
            {"RaiseEvent", "AddKinRobberBoss", "NpcIndex2", 1, 5, "boss", "RobberBoss_2", false, 0 , 0, 9005, 0.5},               
        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"NpcBubbleTalk", "NpcIndex2", "嗯？你们怎麽知道这里的，肯定有人走漏了风声！", 10, 2, 1},
            {"BlackMsg", "哼，天网恢恢疏而不漏，你们敢做这种事还怕别人知道麽？"},
        },
    },
    [5] = {nTime = 0, nNum = 1,
        tbPrelock = {4},
        tbStartEvent = 
        {          

        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 4},
            {"BlackMsg", "糟了！这里居然还有陷阱！"},
        },
    },
    [6] = {nTime = 0, nNum = 1,
        tbPrelock = {5},
        tbStartEvent = 
        { 
            {"TrapUnlock", "TrapLock3", 6},        
            {"RaiseEvent", "AddKinRobberBoss", "NpcIndex3", 1, 7, "boss", "RobberBoss_3", false, 0 , 0, 9005, 0.5},               
            {"BlackMsg", "虽然你们到了这里，但是你们觉得有用麽？"},
        },
        tbUnLockEvent = 
        {
            --{"RaiseEvent","AddKinRobberNpc", 3},  
            {"NpcBubbleTalk", "NpcIndex3", "想不到你们倒有些本事，竟要我亲自动手……", 10, 2, 1},
            {"StartTimeCycle", "cycle_1", 5, 1, {"NpcBubbleTalk", "NpcIndex3", "可惜可惜，你们一身武功却要全部葬身於此！", 10, 2, 1}},
            {"BlackMsg", "哼，我们大家兄弟同心，其利断金，又何惧与你？"},
        },
    },
    [7] = {nTime = 0, nNum = 1,
        tbPrelock = {6},
        tbStartEvent = 
        {

        },
        tbUnLockEvent =
        {   
            {"RaiseEvent","UpateKinNestUiBoss"},
            {"BlackMsg", "就凭这几个人就想守住这里，真是痴人说梦！"},   
        },
    },
    [8] = {nTime = 3, nNum = 1,
        tbPrelock = {7},
        tbStartEvent = 
        { 

        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "成功剿灭奸商手下的走狗，篝火已点燃！"},
            {"RaiseEvent", "UpateKinNestUiFire"},
            {"AddNpc", 25, 1, 0, "Gouhuo", "Gouhuo"}, 
        },
    },
    [9] = {nTime = 60, nNum = 1,
        tbPrelock = {8},
        tbStartEvent = 
        { 

        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "篝火已熄灭，大家可以离开地窖了"},             
            {"DelNpc", "Gouhuo"},
            {"RaiseEvent", "LastRewards"},            
            --{"RaiseEvent","EndKinNest", "BackTrap", 73, 2570, 6550},
        },
    },
    [10] = {nTime = 3600, nNum = 0,
        tbPrelock = {1},
        tbStartEvent = 
        { 
            {"SetShowTime", 10},
        },
        tbUnLockEvent = 
        {
            {"BlackMsg", "可恶…有负前线将士重托…"},   
            {"GameLost"},
        },
    },
}
