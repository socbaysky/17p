Require("ServerScript/Fuben/KinTrain/KinTrainBase.lua")
local tbFuben = Fuben:CreateFubenClass("KinTrainBase_Normal", "KinTrainBase")
local tbDef   = Fuben.KinTrainMgr.FubenDef
function tbFuben:OnCreate(dwKinId)
    self:OnPreCreate(dwKinId)
    self.tbCollection     = {0, 0, 0, 0, 0}
    self.tbCreateNpcNum   = {0, 0, 0, 0, 0}
    self.tbRevivePos      = Fuben.KinTrainMgr.ENTRY_POS
    self:Start()
end

function tbFuben:OnBoxOpen(pNpc, bComplete)
    if bComplete then
        self:UnLock(101)
    end

    local tbAwardInfo = tbDef.tbBoxAward[pNpc.nOpenTimes]
    if not tbAwardInfo then
        return
    end

    self:DropAward(pNpc, tbAwardInfo)
end

function tbFuben:OnSecondTrainBegin()
    self:BeginMaterial()
end

function tbFuben:LoadMaterialPos()
    self.tbNpcCreatePos = {}
    local tbPath = Lib:LoadTabFile("Setting/Fuben/KinTrail/MaterialNpcPos.tab", {X = 1, Y = 1})
    for _, tbPos in ipairs(tbPath) do
        table.insert(self.tbNpcCreatePos, {tbPos.X, tbPos.Y})
    end
end

function tbFuben:AddMeterialNpc(nTemplateId, nNum)
    if self.bClose == 1 or self.nMaterialBoss then
        return
    end
    
    if not self.tbNpcCreatePos or #self.tbNpcCreatePos < nNum then
        self:LoadMaterialPos()
    end

    local nLevel = self:GetAverageLevel()
    for i = 1, nNum do
        local nRandom = MathRandom(#self.tbNpcCreatePos)
        local tbPos = table.remove(self.tbNpcCreatePos, nRandom) or {0, 0}
        local pNpc = KNpc.Add(nTemplateId, nLevel, -1, self.nMapId, unpack(tbPos))
        if pNpc then
            self.tbMaterialGroup[pNpc.nId] = true
        end
    end

    local nType = self:GetMaterialType(nTemplateId)
    self.tbCreateNpcNum[nType] = self.tbCreateNpcNum[nType] + nNum
end