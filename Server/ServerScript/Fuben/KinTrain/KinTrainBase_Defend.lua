--家族试炼-守卫襄阳
Require("ServerScript/Fuben/KinTrain/KinTrainBase.lua")
local tbFuben = Fuben:CreateFubenClass("KinTrainBase_Defend", "KinTrainBase")
local tbDFDef = Fuben.KinTrainMgr.DefendFubenDef

function tbFuben:OnCreate(dwKinId)
    self:OnPreCreate(dwKinId, true)
    self.tbS1Boss         = {}--第一阶段的boss
    self.nS1BossTimer     = nil
    self.tbCollection     = {0, 0, 0, 0}
    self.tbCreateNpcNum   = {0, 0, 0, 0}
    self.tbRevivePos      = Fuben.KinTrainMgr.ENTRY_POS_DEFEND
    self:Start()
end

function tbFuben:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
    self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
end

local fnCB = function ()
    local tbInst = Fuben:GetFubenInstanceByMapId(him.nMapId)
    if tbInst then
        tbInst:OnS1BossDeath()
    end
end

function tbFuben:OnAddNpc(pNpc, nBossIdx)
    if not nBossIdx then
        return
    end
    pNpc.AddSkillState(2466, 1, 0, -1)
    Npc:RegisterNpcHpPercent(pNpc, 0.1, fnCB)
    self.tbS1Boss[pNpc.nId] = {}
end

function tbFuben:OnS1BossDeath()
    if not self.tbS1Boss[him.nId] then
        return
    end

    for nNpcId, tbInfo in pairs(self.tbS1Boss) do
        if nNpcId ~= him.nId and not tbInfo.bDeath then
            self.tbS1Boss[him.nId].bDeath = true
            him.DoCommonAct(20, 5002)
            him.SetProtected(1)
            if him.szFubenNpcGroup then
                self:BlackMsg("金军三雄已破一路，10秒内速破另外两路")
            end
            if not self.nS1BossTimer then
                self.nS1BossTimer = Timer:Register(Env.GAME_FPS * 10, self.ReviveS1Boss, self)
            end
            return
        end
    end
    self:DelS1Boss()
end

function tbFuben:ReviveS1Boss()
    self.nS1BossTimer = nil
    local tbGroup = {}
    for nNpcId, tbInfo in pairs(self.tbS1Boss) do
        local pNpc = KNpc.GetById(nNpcId)
        if tbInfo.bDeath and pNpc then
            Npc:RegisterNpcHpPercent(pNpc, 0.1, fnCB)
            local _, nX, nY = pNpc.GetWorldPos()
            pNpc.CastSkill(3084, 1, nX, nY)
            pNpc.DoCommonAct(Npc.Doing.stand, 0)
            pNpc.SetCurLife(pNpc.nMaxLife)
            pNpc.SetProtected(0)
            tbInfo.bDeath = false
        end
        tbGroup[pNpc.szFubenNpcGroup] = true
    end
    for szGroup in pairs(tbGroup) do
        self:NpcBubbleTalk(szGroup, self.tbSetting.szS1BossNotifyMsg, 5, 0)
    end
end

function tbFuben:DelS1Boss()
    for nNpcId in pairs(self.tbS1Boss) do
        local pNpc = KNpc.GetById(nNpcId)
        if pNpc then
            Fuben:OnKillNpc(pNpc)
            Fuben:NpcUnLock(pNpc)
            pNpc.Delete()
        end
    end
    if self.nS1BossTimer then
        Timer:Close(self.nS1BossTimer)
        self.nS1BossTimer = nil
    end
    self.tbS1Boss = {}
end

function tbFuben:LoadMaterialPos()
    self.tbNpcCreatePos = {}
    local tbFile = Lib:LoadTabFile("Setting/Fuben/KinTrail/MaterialNpcPos_Defend.tab", {Type = 1, X = 1, Y = 1})
    for _, tbInfo in ipairs(tbFile) do
        self.tbNpcCreatePos[tbInfo.Type] = self.tbNpcCreatePos[tbInfo.Type] or {}
        table.insert(self.tbNpcCreatePos[tbInfo.Type], {tbInfo.X, tbInfo.Y})
    end
end

function tbFuben:OnS3Begin()
    self:LoadMaterialPos()
    self:BeginMaterial()
    local nLevel = self:GetAverageLevel()
    local pOtherCar = KNpc.Add(tbDFDef.nOtherCarTID, nLevel, -1, self.nMapId, unpack(tbDFDef.tbOtherCarPos)) --物资车
    if pOtherCar then
        self.nOtherCar = pOtherCar.nId
    end
end

function tbFuben:AddMeterialNpc(nTemplateId, nNum)
    if self.bClose == 1 or self.nMaterialBoss then
        return
    end

    local nLevel = self:GetAverageLevel()
    local nType  = self:GetMaterialType(nTemplateId)
    for i = 1, nNum do
        local nRan  = MathRandom(#self.tbNpcCreatePos[nType])
        local tbPos = self.tbNpcCreatePos[nType][nRan]
        local pNpc  = KNpc.Add(nTemplateId, nLevel, -1, self.nMapId, unpack(tbPos))
        if pNpc then
            self.tbMaterialGroup[pNpc.nId] = true
            self.tbCreateNpcNum[nType] = self.tbCreateNpcNum[nType] + 1
        end
    end
end

function tbFuben:OnDeleteMaterialNpc()
    if self.nOtherCar then
        local pOtherCar = KNpc.GetById(self.nOtherCar)
        if pOtherCar then
            pOtherCar.Delete()
        end
        self.nOtherCar = nil
    end
end

function tbFuben:OnAddAttackMaterialNpc(tbEvent)
    if self.bClose == 1 or self.nMaterialBoss then
        return
    end

    for _, tbInfo in ipairs(tbEvent or {}) do
        self:OnEvent(unpack(tbInfo))
    end
end

function tbFuben:OnDepart()
    KPlayer.MapBoardcastScriptByFuncName(self.nMapId, "Fuben.KinTrainMgr:OnCreateMatBoss", self.nMaterialBossTID, self.nMaterialBoss)
    self:UnLock(self.tbSetting.nMatBossLockId)
end