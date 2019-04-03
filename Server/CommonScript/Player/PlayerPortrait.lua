PlayerPortrait.Def = {
    SAVE_GROUP = 39;
}

function PlayerPortrait:LoadSetting()
    local tbSaveIdx = {}
    local tbSetting = Lib:LoadTabFile("Setting/Player/Portrait.tab", 
        {Id = 1, FaceID = 1, BigFaceID = 1, FactionDefault = 1, Faction = 1, Sex = 1, FactionDefault = 1, Basic = 1, SaveIdx = 1})
    assert(tbSetting, "[PlayerPortrait LoadSetting Fail]")

    self.tbPortraitSetting = {}
    self.tbDefault = {}
    for _,v in pairs(tbSetting) do
        assert((v.Basic > 0 and v.SaveIdx == 0) or (v.Basic == 0 and v.SaveIdx > 0 and v.SaveIdx < 32*255), "[PlayerPortrait LoadSetting] Error, Basic Or SaveIdx Err")

        local tbInfo = self.tbPortraitSetting[v.Id] or {}
        tbInfo.nId             = v.Id
        tbInfo.nFaction        = v.Faction
        tbInfo.szDesc          = v.Desc
        tbInfo.szName          = v.Name
        tbInfo.szOpenUi        = v.OpenUi
        tbInfo.bBasic          = v.Basic > 0
        tbInfo.nSaveIdx        = v.SaveIdx
        tbInfo.nSex            = v.Sex
        tbInfo.nFaceID         = v.FaceID
        tbInfo.nBigFaceID      = v.BigFaceID
        tbInfo.szIcon          = v.Icon
        tbInfo.szIconAtlas     = v.IconAtlas
        tbInfo.bFactionDefault = v.FactionDefault > 0
        assert(not tbSaveIdx[v.SaveIdx], "[PlayerPortrait LoadSetting] Error, SaveIdx Repeat")
        if v.SaveIdx > 0 then
            tbSaveIdx[v.SaveIdx] = true
        end

        self.tbPortraitSetting[v.Id] = tbInfo
        if tbInfo.bFactionDefault then
            if tbInfo.nSex > 0 then
                self.tbDefault[v.Faction] = self.tbDefault[v.Faction] or {}
                self.tbDefault[v.Faction][tbInfo.nSex] = v.Id
            else
                self.tbDefault[v.Faction] = v.Id
            end
        end
    end
    for nFaction = 1, Faction.MAX_FACTION_COUNT do
        assert(self.tbDefault[nFaction], string.format("[PlayerPortrait LoadSetting] Error, No Default Id:%d", nFaction))
    end
end
PlayerPortrait:LoadSetting();

function PlayerPortrait:IsAvaliablePortraits(nPortrait)
    local tbSetting = self.tbPortraitSetting[nPortrait] or {}
	if tbSetting.bBasic then
		return true;
	end

    local nSaveIdx = self:GetSaveIdx(nPortrait)
    if not nSaveIdx then
        return
    end

    local nSaveKey, nBit = self:GetSaveInfo(nSaveIdx)
    local nFlag = me.GetUserValue(self.Def.SAVE_GROUP, nSaveKey)
    local nRet  = KLib.GetBit(nFlag, nBit)
    return nRet == 1
end

function PlayerPortrait:GetSaveIdx(nPortraitID)
    if not nPortraitID then
        return
    end

    local tbInfo = self.tbPortraitSetting[nPortraitID]
    if not tbInfo then
        return
    end

    return tbInfo.nSaveIdx
end

function PlayerPortrait:GetSaveInfo(nSaveIdx)
    if nSaveIdx == 0 then
        return
    end

    nSaveIdx = nSaveIdx - 0.1
    local nSaveKey = math.ceil(nSaveIdx/31)
    local nBit     = math.ceil(nSaveIdx%31)

    return nSaveKey, nBit
end

function PlayerPortrait:CheckFaction(nPortrait, nFaction, nSex)
    local tbInfo = self.tbPortraitSetting[nPortrait]
    if not tbInfo then
        return
    end
    return (tbInfo.nFaction == 0 or tbInfo.nFaction == nFaction) and (tbInfo.nSex == 0 or tbInfo.nSex == nSex)
end

function PlayerPortrait:GetDefaultId(nFaction, nSex)
    local info = self.tbDefault[nFaction]
    if type(info) == "table" then
        return info[nSex]
    elseif type(info) == "number" then
        return info
    end
    Log("PlayerPortrait GetDefaultId Err", nFaction, nSex)
    return 1
end

if MODULE_GAMESERVER then
    return
end

---------------------------------------------------Client---------------------------------------------------
function PlayerPortrait:OnAddPortrait()
    UiNotify.OnNotify(UiNotify.emNOTIFY_ADD_PORTRAIT)
end

function PlayerPortrait:GetPortraitIcon(nPortrait)
    if not nPortrait or not self.tbPortraitSetting[nPortrait] then
        Log("PlayerPortrait:GetPortraitIcon Err", nPortrait)
        nPortrait = 1
    end
    local tbInfo = self.tbPortraitSetting[nPortrait]
    return tbInfo.szIcon, tbInfo.szIconAtlas
end

function PlayerPortrait:GetFaceIcon(nPortrait, bBig)
    if not nPortrait or not self.tbPortraitSetting[nPortrait] then
        Log("PlayerPortrait:GetFaceIcon Err", nPortrait)
        nPortrait = 1
    end
    local tbInfo  = self.tbPortraitSetting[nPortrait]
    local szKey   = bBig and "nBigFaceID" or "nFaceID"
    local nFaceId = tbInfo[szKey]
    local szIconAtlas, szIcon = Npc:GetFace(nFaceId)
    if not szIcon then
        szIcon, szIconAtlas = self:GetPortraitIcon(nPortrait)
    end
    return szIcon, szIconAtlas
end

function PlayerPortrait:GetSmallIcon(nPortrait)
    return self:GetFaceIcon(nPortrait, false)
end

function PlayerPortrait:GetPortraitBigIcon(nPortrait)
    return self:GetFaceIcon(nPortrait, true)
end

function PlayerPortrait:GetShowList()
    local tbRet    = {}
    local nFaction = me.nFaction
    local nSex     = Player:Faction2Sex(nFaction, me.nSex)
    for _, tbInfo in pairs(self.tbPortraitSetting) do
        if self:CheckFaction(tbInfo.nId, nFaction, nSex) and
            self:IsAvaliablePortraits(tbInfo.nId) then
            table.insert(tbRet, tbInfo.nId)
        end
    end

    return tbRet
end

function PlayerPortrait:GetDesc(nPortrait)
    local tbSetting = self.tbPortraitSetting[nPortrait]
    if not tbSetting then
        return
    end

    return tbSetting.szDesc, tbSetting.szLimit, tbSetting.szOpenUi, tbSetting.szName
end