
local tb    = {
    partner_huzhu_tw = --护主-天王-不动如山阵
    {
		strength_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		wood_resist_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		all_series_resist_v={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_em = --护主-峨眉-傲寒不灭体
    {
		ignore_all_resist_v={{{1,100},{20,100}},{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		fire_resist_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		state_palsy_resisttime={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_xy = --护主-逍遥-踏星摘月步
    {
		strength_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		earth_resist_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		defense_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_th = --护主-桃花-红鸾牵丝手
    {
		ignore_all_resist_v={{{1,100},{20,100}},{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		metal_resist_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		state_hurt_resisttime={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_wd = --护主-武当-一川镇海诀
    {
		basic_damage_v={
			[1]={{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}},
			[3]={{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}
			},
		water_resist_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		defense_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_tr = --护主-天忍-天火琉璃步
    {
		deadlystrike_damage_p={{{1,4},{2,8},{4,20},{10,25},{16,30},{20,40},{25,45},{30,50}}},
		energy_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		attackrate_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_sl = --护主-少林-混元金刚体
    {
		physical_metaldamage_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		vitality_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		state_zhican_resisttime={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_cy = --护主-翠烟-流风回雪舞
    {
		physical_waterdamage_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		vitality_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		weaken_deadlystrike_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_wudu = --护主-五毒-七巧玲珑步
    {
		physical_wooddamage_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		dexterity_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		lifemax_p={{{1,3},{2,8},{4,15},{10,20},{16,25},{20,30},{25,30},{30,30}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_kl = --护主-昆仑-搬山填海劲
    {
		physical_earthdamage_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		weaken_deadlystrike_damage_p={{{1,4},{2,8},{4,20},{10,25},{16,30},{20,40},{25,45},{30,50}}},
		state_slowall_resisttime={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_tm = --护主-唐门-天罗千机步
    {
		deadlystrike_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		energy_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		state_stun_resisttime={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173},{25,213},{30,266}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_gb = --护主-丐帮-八荒炎龙劲
    {
		physical_firedamage_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		dexterity_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}},
		ignore_defense_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_3s_jin = --护主3S-浮屠鎏金体
    {
		strength_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260}}},
		wood_resist_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520}}},
		all_series_resist_v={{{1,6},{2,26},{4,66},{10,100},{16,133},{20,173}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_3s_mu = --护主3S-森罗万象步
    {
		enhance_final_damage_p={{{1,1},{2,1},{4,2},{10,5},{16,10},{20,15},{25,18},{30,23}}},
		defense_p={{{1,5},{2,10},{4,25},{10,35},{16,45},{20,65},{25,80},{30,100}}},
		add_seriesstate_rate_v={{{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,300},{30,400}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_3s_shui = --护主3S-瀚海无涯诀
    {
		enhance_final_damage_p={{{1,1},{2,1},{4,2},{10,5},{16,10},{20,15},{25,18},{30,23}}},
		lifecurmax_p={{{1,1},{2,1},{4,2},{10,5},{16,10},{20,15},{25,18},{30,23}}},
		weaken_deadlystrike_damage_p={{{1,5},{2,10},{4,15},{10,20},{16,30},{20,40},{30,60}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_3s_huo = --护主3S-修罗焚狱劲
    {
		enhance_final_damage_p={{{1,1},{2,1},{4,2},{10,5},{16,10},{20,15},{25,18},{30,23}}},
		deadlystrike_p={{{1,5},{2,10},{4,25},{10,35},{16,45},{20,65},{25,80},{30,100}}},
		ignore_all_resist_v={{{1,100},{30,100}},{{1,12},{2,52},{4,132},{10,200},{16,266},{20,346},{25,426},{30,532}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_huzhu_3s_tu = --护主3S-土-至尊囚天手
    {
		enhance_final_damage_p={{{1,1},{2,1},{4,2},{10,5},{16,10},{20,15},{25,18},{30,23}}},
		basic_damage_v={
			[1]={{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}},
			[3]={{1,10},{2,40},{4,100},{10,150},{16,200},{20,260},{25,320},{30,400}}
			},
		ignore_defense_v={{{1,20},{2,80},{4,200},{10,300},{16,400},{20,520},{25,640},{30,800}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
}

FightSkill:AddMagicData(tb)