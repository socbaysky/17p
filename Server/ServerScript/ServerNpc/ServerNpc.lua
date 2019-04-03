function ServerNpc:LoadSetting()
	self.tbMapNpcSetting = {};
	
	local tbFileData = Lib:LoadTabFile("ServerSetting/ServerNpc/MapNpc.tab", {MapID = 1, NpcID = 1, NpcLevel = 1, PosX = 1, PosY = 1, Dir = 1, Series = 1,
                       BodyResID = 1, HeadResID = 1, WeaponResID = 1, ActID = 1, ActBQType = 1, IsActLoop = 1, ActionEvent = 1})
    for _, tbInfo in pairs(tbFileData) do
        self.tbMapNpcSetting[tbInfo.MapID] = self.tbMapNpcSetting[tbInfo.MapID] or {};
        table.insert(self.tbMapNpcSetting[tbInfo.MapID], tbInfo);
    end
end

ServerNpc:LoadSetting();

function ServerNpc:GetMapNpc(nMapTID)
    return self.tbMapNpcSetting[nMapTID] or {}
end

function ServerNpc:OnMapCreate(nMapId, nMapTemplateId)
	local tbMapNpc = self:GetMapNpc(nMapTemplateId)
	for _, tbNpcInfo in pairs(tbMapNpc) do
		local pNpc = KNpc.Add(tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, tbNpcInfo.Series or -1, nMapId, tbNpcInfo.PosX, tbNpcInfo.PosY, 0, tbNpcInfo.Dir);
		if pNpc then
			if not Lib:IsEmptyStr(tbNpcInfo.FindPathFile) then
				local tbPath = self:GetNpcPath(tbNpcInfo.FindPathFile);
				pNpc.AI_ClearMovePathPoint();
				for _, tbPos in ipairs(tbPath) do
					pNpc.AI_AddMovePos(tbPos.PosX, tbPos.PosY);
				end
				self:StartFindPath(pNpc.nId);
			end

			local tbNpcTInfo = KNpc.GetNpcTemplateInfo(tbNpcInfo.NpcID) or {};
			if tbNpcInfo.BodyResID ~= 0 or tbNpcInfo.HeadResID ~= 0 or tbNpcInfo.WeaponResID ~= 0 then
				pNpc.ChangeFeature(tbNpcTInfo.nNpcResID or 0, Npc.NpcResPartsDef.npc_part_body, tbNpcInfo.BodyResID or 0);
				pNpc.ChangeFeature(tbNpcTInfo.nNpcResID or 0, Npc.NpcResPartsDef.npc_part_weapon, tbNpcInfo.WeaponResID or 0);
				pNpc.ChangeFeature(tbNpcTInfo.nNpcResID or 0, Npc.NpcResPartsDef.npc_part_head, tbNpcInfo.HeadResID or 0);
			end

			if tbNpcInfo.ActID ~= 0 then
				pNpc.DoCommonAct(tbNpcInfo.ActID, tbNpcInfo.ActionEvent or 0, tbNpcInfo.IsActLoop or 0, 0, tbNpcInfo.ActBQType or 0);
			end
		end
	end
end