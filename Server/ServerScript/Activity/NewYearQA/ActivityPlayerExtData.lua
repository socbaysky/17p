Activity.ActPlayerExtData = Activity.ActPlayerExtData or {}
local tbExtData = Activity.ActPlayerExtData

--[[
总表:
{
	nCurTabIdx = 1, --当前表ID
	nCurSubNum = 0, --当前表有多少个数据
	nDataCountIn1Table = 100, --多少个数据在一张表，超了自动切到下一张表
	tbPlayerIdxList = { --玩家ID对应的表ID
		[1111] = 1, --玩家ID，表ID
	}
}
子表:
{
	[1111] = {}, --玩家ID = {自定义数据}
}
]]

--创建活动数据总表（有就不创建了），适合在活动Start时使用，每次重启都需要
--nDataCountIn1Table:多少数据在一张表里，需保证不会超
function tbExtData:Create(szActKey, nDataCountIn1Table)
	if Lib:IsEmptyStr(szActKey) then
		return
	end
	if nDataCountIn1Table <= 0 then
		return
	end
	local szMainKey = szActKey .. "_Main"
	ScriptData:AddDef(szMainKey)
	local tbMainData = ScriptData:GetValue(szMainKey)
	if not next(tbMainData) then
		tbMainData.nCurTabIdx = 1
		tbMainData.nCurSubNum = 0
		tbMainData.nDataCountIn1Table = nDataCountIn1Table
		tbMainData.tbPlayerIdxList = {}
		Log("ActPlayerExtData AddDef :", szActKey, nDataCountIn1Table)
	end
end

function tbExtData:Clear(szActKey)
	if Lib:IsEmptyStr(szActKey) then
		return
	end
	local szMainKey = szActKey .. "_Main"
	ScriptData:AddDef(szMainKey)

	local tbMainData = ScriptData:GetValue(szMainKey)
	if not next(tbMainData) then
		return
	end
	for i = 1, tbMainData.nCurTabIdx do
		local szSubKey = string.format("%s_Sub%s", szActKey, i)
		ScriptData:AddDef(szSubKey)
		ScriptData:SaveAtOnce(szSubKey, {})
	end
	ScriptData:SaveAtOnce(szMainKey, {})
	Log("ActPlayerExtData Clear:", szActKey, nDataCountIn1Table)
end

function tbExtData:SaveData(szActKey, nPlayerId, tbPlayerData)
	if Lib:IsEmptyStr(szActKey) then
		return
	end
	if not nPlayerId or not tbPlayerData then
		return
	end

	local szMainKey = szActKey .. "_Main"
	if not ScriptData:CheckDef(szMainKey) then
		return
	end
	local tbData = ScriptData:GetValue(szMainKey)
	local nIdx = tbData.tbPlayerIdxList[nPlayerId]
	local szSubKey
	if not nIdx then
		if tbData.nCurSubNum >= tbData.nDataCountIn1Table then
			tbData.nCurTabIdx = tbData.nCurTabIdx + 1
			tbData.tbPlayerIdxList[nPlayerId] = tbData.nCurTabIdx
			tbData.nCurSubNum = 1
			szSubKey = string.format("%s_Sub%s", szActKey, tbData.nCurTabIdx)
			ScriptData:AddDef(szSubKey)
			local tbSubData = ScriptData:GetValue(szSubKey)
			tbSubData[nPlayerId] = tbPlayerData
			ScriptData:AddModifyFlag(szSubKey)
		else
			tbData.nCurSubNum = tbData.nCurSubNum +  1
			szSubKey = string.format("%s_Sub%s", szActKey, tbData.nCurTabIdx)
			ScriptData:AddDef(szSubKey)
			local tbSubData = ScriptData:GetValue(szSubKey)
			tbSubData[nPlayerId] = tbPlayerData
			ScriptData:AddModifyFlag(szSubKey)
		end
		ScriptData:AddModifyFlag(szMainKey)
	else
		szSubKey = string.format("%s_Sub%s", szActKey, nIdx)
		ScriptData:AddDef(szSubKey)
		local tbSubData = ScriptData:GetValue(szSubKey)
		tbSubData[nPlayerId] = tbPlayerData
		ScriptData:AddModifyFlag(szSubKey)
	end
	return szSubKey
end

function tbExtData:GetData(szActKey, nPlayerId)
	if Lib:IsEmptyStr(szActKey) or not nPlayerId then
		return
	end
	local szMainKey = szActKey .. "_Main"
	if not ScriptData:CheckDef(szMainKey) then
		return
	end
	local tbMainData = ScriptData:GetValue(szMainKey)
	local nSubIdx = tbMainData.tbPlayerIdxList[nPlayerId]
	if not nSubIdx then
		if tbMainData.nCurSubNum >= tbMainData.nDataCountIn1Table then
			tbMainData.nCurTabIdx = tbMainData.nCurTabIdx + 1
			tbMainData.nCurSubNum = 1
		else
			tbMainData.nCurSubNum = tbMainData.nCurSubNum + 1
		end
		nSubIdx = tbMainData.nCurTabIdx
		tbMainData.tbPlayerIdxList[nPlayerId] = nSubIdx
		ScriptData:AddModifyFlag(szMainKey)
	end
	local szSubKey = string.format("%s_Sub%s", szActKey, nSubIdx)
	ScriptData:AddDef(szSubKey)
	local tbSubData = ScriptData:GetValue(szSubKey)
	return tbSubData[nPlayerId], szSubKey
end

function tbExtData:TraversalAllPlayer(szActKey, fnCallback)
	local szMainKey = szActKey .. "_Main"
	if not ScriptData:CheckDef(szMainKey) then
		return
	end
	local tbMainData = ScriptData:GetValue(szMainKey)
	for i = 1, tbMainData.nCurTabIdx do
		local szSubKey = string.format("%s_Sub%s", szActKey, i)
		ScriptData:AddDef(szSubKey)
		local tbSubData = ScriptData:GetValue(szSubKey) or {}
		for nPlayerId, tbData in pairs(tbSubData) do
			fnCallback(nPlayerId, tbData)
		end
	end
end

function ScriptData:CheckDef(szKey)
	return self.tbUseScriptDataDef[szKey]
end