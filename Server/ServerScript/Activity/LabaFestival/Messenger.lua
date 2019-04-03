local tbAct = Activity:GetClass("LabaMessenger")
tbAct.tbTimerTrigger = {}
tbAct.tbTrigger = {
	Init={},
	Start={},
	End={},
}

local tbPathPoints1 = {
	-- x, y
	{4300, 5260, "呵呵，看来此地十分热闹啊！"},
    {4980, 4661, "呵呵，诸位莫要紧张，今日有些小贼频繁出没"},
    {4980, 5380, "我已经详细地址告知贵帮派总管"},
    {4980, 6100, "诸位，不必相送，明日还望诸位捧场！"},
    {4900, 6200},    
}

local tbPathPoints2 = {
    {5600, 5210, "李四见过诸位侠士！"},
    {5160, 4661, "多得诸位将之剿灭，我等特来相邀前往侠客岛喝一碗腊八粥"},
    {5160, 5380, "多有叨扰，我们二人就此告辞！"},
    {5160, 6100, "诸位，再会！"},
    {5180, 6200},    
}

tbAct.tbSettings = {
	tbNpcs = {
		-- NpcID 	PathPoints
		{2167, tbPathPoints1},
        {2168, tbPathPoints2},
	},
}

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:OnStart()
	elseif szTrigger == "End" then
		self:OnEnd()
	end
	Log("LabaMessenger:OnTrigger", szTrigger)
end

function tbAct:OnStart()
	Activity:RegisterGlobalEvent(self, "Act_OnKinMapCreate", "OnKinMapCreate")
    Activity:RegisterGlobalEvent(self, "Act_OnKinMapDestroy", "OnKinMapDestroy")
    self:CreateKinMapNpc()
	Log("LabaMessenger:OnStart")
end

function tbAct:OnEnd()
	self:RemoveKinMapNpc()
	Log("LabaMessenger:OnEnd")
end

function tbAct:StartFindPath(nNpcID, tbPathPoints, nIdx)
    local pNpc = KNpc.GetById(nNpcID)
    if not pNpc then
        return
    end

    local tbPrevPos = tbPathPoints[nIdx-1]
    if tbPrevPos then
        local _, nX, nY = pNpc.GetWorldPos()
        if tbPrevPos[1]==nX and tbPrevPos[2]==nY then
            NpcBubbleTalk:ManualTalk(pNpc.nId, tbPrevPos[3])
        end
    end

    local tbPos = tbPathPoints[nIdx]
    if not tbPos then
        pNpc.Delete()
        return
    end

    pNpc.AI_ClearMovePathPoint()
    local x, y = unpack(tbPos)
    pNpc.AI_AddMovePos(x, y)
    pNpc.SetActiveForever(1)
    pNpc.AI_StartPath()
    pNpc.tbOnArrive = {self.StartFindPath, self, nNpcID, tbPathPoints, nIdx+1}
end

function tbAct:CreateNpc(nMapId)
    if not nMapId then
        return
    end
    if self.tbNpcInKinMap and self.tbNpcInKinMap[nMapId] then
        Log("[x] LabaMessenger:CreateNpc", nMapId, #self.tbNpcInKinMap[nMapId])
        return
    end

    self.tbNpcInKinMap = self.tbNpcInKinMap or {}
    self.tbNpcInKinMap[nMapId] = self.tbNpcInKinMap[nMapId] or {}
    for _, tbNpc in ipairs(self.tbSettings.tbNpcs) do
	    local NpcID, tbPathPoints = unpack(tbNpc)
	    local PosX, PosY = unpack(tbPathPoints[1])
	    local pNpc = KNpc.Add(NpcID, 1, -1, nMapId, PosX, PosY, 0, 0)
	    if pNpc then
		    table.insert(self.tbNpcInKinMap[nMapId], pNpc.nId)
		    if tbPathPoints and #tbPathPoints>0 then 
                self:StartFindPath(pNpc.nId, tbPathPoints, 1)
		    end
		end
	end
end

function tbAct:RemoveNpc(nMapId)
	Log("LabaMessenger:RemoveNpc", nMapId)
    if not nMapId or not self.tbNpcInKinMap then
        return
    end

    local tbNpcIds = self.tbNpcInKinMap[nMapId]
    if not tbNpcIds then
        return
    end

    for _, nNpcId in ipairs(tbNpcIds) do
	    local pNpc = KNpc.GetById(nNpcId)
	    if pNpc then
		    pNpc.Delete()
	    end
	end
	self.tbNpcInKinMap[nMapId] = nil
end

function tbAct:CreateKinMapNpc()
    Kin:TraverseKin(function(tbKinData)
        if not tbKinData:IsMapOpen() then
            return
        end

        self:CreateNpc(tbKinData:GetMapId())
    end);
    Log("LabaMessenger:CreateNpc")
end

function tbAct:RemoveKinMapNpc()
    Kin:TraverseKin(function (tbKinData)
        if not tbKinData:IsMapOpen() then
            return
        end

        self:RemoveNpc(tbKinData:GetMapId())
    end)
    Log("LabaMessenger:DeleteNpc")
end

function tbAct:OnKinMapCreate(nMapId)
    self:CreateNpc(nMapId)
    Log("LabaMessenger:OnKinMapCreate", nMapId)
end

function tbAct:OnKinMapDestroy(nMapId)
    self:RemoveNpc(nMapId)
    Log("LabaMessenger:OnKinMapDestroy", nMapId)
end
