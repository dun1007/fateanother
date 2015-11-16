require('util')

SaberAttribute = {
	"saber_attribute_improve_excalibur",
	"saber_attribute_improve_instinct",
	"saber_attribute_chivalry",
	"saber_attribute_strike_air",
	"saber_max_excalibur",
	attrCount = 4
}

LancerAttribute = {
	"lancer_attribute_improve_battle_continuation",
	"lancer_attribute_improve_gae_bolg",
	"lancer_attribute_protection_from_arrows",
	"lancer_attribute_the_heartseeker",
	"lancer_5th_wesen_gae_bolg",
	attrCount = 4
}

SaberAlterAttribute = {
	"saber_alter_attribute_mana_shroud",
	"saber_alter_attribute_mana_blast",
	"saber_alter_attribute_improve_ferocity",
	"saber_alter_attribute_ultimate_darklight",
	"saber_alter_max_mana_burst",
	attrCount = 4
}

RiderAttribute = {
	"rider_5th_attribute_improve_mystic_eyes",
	"rider_5th_attribute_riding",
	"rider_5th_attribute_seal",
	"rider_5th_attribute_monstrous_strength",
	"rider_5th_bellerophon_2",
	attrCount = 4
}

ArcherAttribute = {
	"archer_5th_attribute_eagle_eye",
	"archer_5th_attribute_hrunting",
	"archer_5th_attribute_shroud_of_martin",
	"archer_5th_attribute_improve_projection",
	"archer_5th_attribute_overedge",
	"archer_5th_arrow_rain",
	attrCount = 5
}

BerserkerAttribute = {
	"berserker_5th_attribute_improve_divinity",
	"berserker_5th_attribute_berserk",
	"berserker_5th_attribute_god_hand",
	"berserker_5th_attribute_reincarnation",
	"berserker_5th_madmans_roar",
	attrCount = 4
}

FAAttribute = {
	"false_assassin_attribute_ganryu",
	"false_assassin_attribute_eye_of_serenity",
	"false_assassin_attribute_quickdraw",
	"false_assassin_attribute_vitrification",
	"false_assassin_tsubame_mai",
	attrCount = 4
}

TAAttribute = {
	"true_assassin_attribute_improve_presence_concealment",
	"true_assassin_attribute_protection_from_wind",
	"true_assassin_attribute_weakening_venom",
	"true_assassin_attribute_shadow_strike",
	"true_assassin_combo",
	attrCount = 4
}

GilgaAttribute = {
	"gilgamesh_attribute_improve_golden_rule",
	"gilgamesh_attribute_power_of_sumer",
	"gilgamesh_attribute_rain_of_swords",
	"gilgamesh_attribute_sword_of_creation",
	"gilgamesh_max_enuma_elish",
	attrCount = 4
}

CasterAttribute = {
	"caster_5th_attribute_improve_territory_creation",
	"caster_5th_attribute_improve_argos",
	"caster_5th_attribute_improve_hecatic_graea",
	"caster_5th_attribute_dagger_of_treachery",
	"caster_5th_hecatic_graea_powered",
	attrCount = 4
}

LancelotAttribute = {
	"lancelot_attribute_blessing_of_fairy",
	"lancelot_attribute_improve_eternal",
	"lancelot_attribute_improve_knight_of_honor",
	"lancelot_attribute_total_assault",
	"lancelot_nuke",
	attrCount = 4
}

AvengerAttribute = {
	"avenger_attribute_improve_dark_passage",
	"avenger_attribute_blood_mark",
	"avenger_attribute_overdrive",
	"avenger_attribute_demon_incarnate",
	"avenger_endless_loop",
	attrCount = 4
}

DiarmuidAttribute = {
	"diarmuid_attribute_improve_love_spot",
	"diarmuid_attribute_minds_eye",
	"diarmuid_attribute_rosebloom",
	"diarmuid_attribute_double_spear_strike",
	"diarmuid_rampant_warrior",
	attrCount = 4
}

IskanderAttribute = {
	"iskander_attribute_improve_charisma",
	"iskander_attribute_thundergods_wrath",
	"iskander_attribute_via_expugnatio",
	"iskander_attribute_bond_beyond_time",
	"iskander_annihilate",
	attrCount = 4
}

GillesAttribute = {
	"gille_attribute_eye_for_art",
	"gille_attribute_improve_black_magic",
	"gille_attribute_mental_pollution",
	"gille_attribute_abyssal_connection",
	"gille_attribute_abyssal_connection_2",
	"gille_larret_de_mort",
	attrCount = 5
}

NeroAttribute = {
	"nero_attribute_pari_tenu_blauserum",
	"nero_attribute_improve_imperial_privilege",
	"nero_attribute_invictus_spiritus",
	"nero_attribute_soverigns_glory",
	"nero_fiery_finale",
	attrCount = 4
}

GawainAttribute = {
	"gawain_attribute_dawnbringer",
	"gawain_attribute_blessing_of_fairy",
	"gawain_attribute_divine_meltdown",
	"gawain_attribute_sunlight",
	"gawain_attribute_eclipse",
	"gawain_supernova",
	attrCount = 5
}

TamamoAttribute = {
	"tamamo_attribute_spirit_theft",
	"tamamo_attribute_severed_fate",
	"tamamo_attribute_tamamo_escape",
	"tamamo_attribute_witchcraft",
	"tamamo_polygamist_castration_fist",
	attrCount = 4
}

function OnSeal1Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if caster:GetHealth() == 1 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Not Enough Health(Wait for Health Reset Every 10 Minutes)" } )
		caster:SetMana(caster:GetMana()+2) 
		keys.ability:EndCooldown() 
		return 
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+2) 
		keys.ability:EndCooldown() 
		return
	end

	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(master2:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	-- Set master's health
	caster:SetHealth(caster:GetHealth()-1) 

	-- Particle
	hero:EmitSound("Misc.CmdSeal")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_ancestral_spirit_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 2, hero:GetAbsOrigin())


	keys.ability:ApplyDataDrivenModifier(keys.caster, hero, "modifier_command_seal_1",{})
	caster.IsFirstSeal = true

	caster:FindAbilityByName("cmd_seal_1"):StartCooldown(60)
	Timers:CreateTimer({
		endTime = 20.0,
		callback = function()
		caster.IsFirstSeal = false
	end
	})
end

function ResetAbilities(hero)
	-- Reset all resetable abilities
	for i=0, 15 do 
		local ability = hero:GetAbilityByIndex(i)
		if ability ~= nil then
			if ability.IsResetable ~= false then
				ability:EndCooldown()
			end
		else 
			break
		end
	end
end

function ResetItems(hero)
	-- Reset all items
	for i=0, 11 do
		local item = hero:GetItemInSlot(i) 
		if item ~= nil then
			item:EndCooldown()
		end
	end
end

function OnSeal2Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if caster:GetHealth() == 1 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Not Enough Health(Wait for Health Reset Every 10 Minutes)" } )
		caster:SetMana(caster:GetMana()+1) 
		keys.ability:EndCooldown() 
		return 
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+1) 
		keys.ability:EndCooldown() 
		return
	end

	print(caster:GetMana()-1)
	caster:SetMana(caster:GetMana()-1)
	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(caster:GetMana())
	-- Set master's health
	caster:SetHealth(caster:GetHealth()-1) 

	ResetAbilities(hero)
	ResetItems(hero)

	-- Particle
	hero:EmitSound("DOTA_Item.Refresher.Activate")
	local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


	-- Set cooldown
	if caster.IsFirstSeal == true then
		keys.ability:EndCooldown()
		caster:SetMana(caster:GetMana()+1)  --refund 1 mana
		master2:SetMana(master2:GetMana() +1)
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(30)
		keys.ability:ApplyDataDrivenModifier(keys.caster, hero, "modifier_command_seal_2",{})
	end
end

function OnSeal3Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if caster:GetHealth() == 1 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Not Enough Health(Wait for Health Reset Every 10 Minutes)" } )
		caster:SetMana(caster:GetMana()+1) 
		keys.ability:EndCooldown() 
		return 
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		print("Cannot use seals")
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+1) 
		keys.ability:EndCooldown() 
		return
	end

	hero:EmitSound("DOTA_Item.UrnOfShadows.Activate")

	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(master2:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	-- Set master's health
	caster:SetHealth(caster:GetHealth()-1) 

	local particle = ParticleManager:CreateParticle("particles/items2_fx/urn_of_shadows_heal_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
	hero:Heal(hero:GetMaxHealth(), hero)

	if caster.IsFirstSeal == true then
		keys.ability:EndCooldown()
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(30)
		keys.ability:ApplyDataDrivenModifier(keys.caster, hero, "modifier_command_seal_3",{})
	end
end

function OnSeal4Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if caster:GetHealth() == 1 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Not Enough Health(Wait for Health Reset Every 10 Minutes)" } )
		caster:SetMana(caster:GetMana()+1) 
		keys.ability:EndCooldown() 
		return 
	end

	if not hero:IsAlive() or IsRevoked(hero) then
		print("Cannot use seals")
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+1) 
		keys.ability:EndCooldown() 
		return
	end

	-- Set master 2's mana 
	local master2 = hero.MasterUnit2
	master2:SetMana(master2:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	-- Set master's health
	caster:SetHealth(caster:GetHealth()-1) 

	-- Particle
	hero:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target")
	local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


	hero:SetMana(hero:GetMaxMana()) 


	if caster.IsFirstSeal == true then
		keys.ability:EndCooldown()
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(30)
		keys.ability:ApplyDataDrivenModifier(keys.caster, hero, "modifier_command_seal_4",{})
	end
end

function AddMasterAbility(master, name)
    --local ply = master:GetPlayerOwner()
    local attributeTable = FindAttribute(name)
    LoopThroughAttr(master, attributeTable)
	master:AddAbility("master_strength")
	master:AddAbility("master_agility")
	master:AddAbility("master_intelligence")
	master:AddAbility("master_damage")
	master:AddAbility("master_armor")
	master:AddAbility("master_health_regen")
	master:AddAbility("master_mana_regen")
	master:AddAbility("master_movement_speed")
	master:AddAbility("master_2_passive")
end

function LoopThroughAttr(hero, attrTable)
    for i=1, #attrTable do
        print("Added " .. attrTable[i])
        hero:AddAbility(attrTable[i])
    end
    if #attrTable-1 == 4 then
    	hero:AddAbility("fate_empty1")
    	hero:SwapAbilities(attrTable[#attrTable], "fate_empty1", true, true)
   	end
    hero.ComboName = attrTable[#attrTable]
    --print(attrTable[#attrTable])
    --hero:SwapAbilities(attrTable[#attrTable], hero:GetAbilityByIndex(4):GetName(), true, true)
    --hero:SwapAbilities("master_close_list", "fate_empty1", true, true)
    hero:FindAbilityByName(attrTable[#attrTable]):StartCooldown(9999) 
end

function FindAttribute(name)
    local attributes = nil
    if name == "npc_dota_hero_legion_commander" then
        attributes = SaberAttribute
    elseif name == "npc_dota_hero_phantom_lancer" then
        attributes = LancerAttribute
    elseif name == "npc_dota_hero_spectre" then
        attributes = SaberAlterAttribute
    elseif name == "npc_dota_hero_ember_spirit" then
        attributes = ArcherAttribute
    elseif name == "npc_dota_hero_templar_assassin" then
        attributes = RiderAttribute
    elseif name == "npc_dota_hero_doom_bringer" then
        attributes = BerserkerAttribute
    elseif name == "npc_dota_hero_juggernaut" then
        attributes = FAAttribute
    elseif name == "npc_dota_hero_bounty_hunter" then
        attributes = TAAttribute
    elseif name == "npc_dota_hero_crystal_maiden" then
        attributes = CasterAttribute
    elseif name == "npc_dota_hero_skywrath_mage" then
        attributes = GilgaAttribute
    elseif name == "npc_dota_hero_sven" then
        attributes = LancelotAttribute
    elseif name == "npc_dota_hero_vengefulspirit" then
        attributes = AvengerAttribute
    elseif name == "npc_dota_hero_huskar" then
        attributes = DiarmuidAttribute
    elseif name == "npc_dota_hero_chen" then
        attributes = IskanderAttribute
    elseif name == "npc_dota_hero_shadow_shaman" then
        attributes = GillesAttribute
    elseif name == "npc_dota_hero_lina" then
        attributes = NeroAttribute
    elseif name == "npc_dota_hero_omniknight" then
        attributes = GawainAttribute
    elseif name == "npc_dota_hero_enchantress" then
        attributes = TamamoAttribute
    end
    return attributes
end 

function OnAttributeListOpen(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	local attributeTable = FindAttribute(hero:GetName())

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), attributeTable[1], true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), attributeTable[2], true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), attributeTable[3], true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "master_close_list", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), attributeTable[4], true, true)
	

	--if attributeTable[5] ~= nil then 

	if attributeTable.attrCount == 5 then 
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), attributeTable[5], true, true)
	else 
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), fate_empty1, true, true)
	end
end

function OnListClose(keys)
	local caster = keys.caster

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "master_attribute_list", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "master_stat_list1", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "master_stat_list2", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "master_shard_of_holy_grail", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), caster.ComboName, true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "fate_empty2", true, true)
end

function OnStatList1Open(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_strength")
	caster:AddAbility("master_agility")
	caster:AddAbility("master_intelligence")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("master_damage")
	caster:AddAbility("master_armor")
	caster:AddAbility(caster.ComboName)
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
	caster:GetAbilityByIndex(4):SetLevel(1)
	caster:GetAbilityByIndex(5):SetLevel(1)
end

function OnStatList2Open(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_health_regen")
	caster:AddAbility("master_mana_regen")
	caster:AddAbility("master_movement_speed")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("fate_empty1")
	caster:AddAbility("fate_empty2")
	caster:AddAbility(caster.ComboName)
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
end

function OnShardOpen(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_shard_of_avarice")
	caster:AddAbility("master_shard_of_anti_magic")
	caster:AddAbility("master_shard_of_replenishment")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("master_shard_of_prosperity")
	caster:AddAbility("fate_empty2")
	caster:AddAbility(caster.ComboName)
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
	caster:GetAbilityByIndex(4):SetLevel(1)
end

function OnStatListClose(keys)
	local caster = keys.caster
	for i=0,5 do
		caster:RemoveAbility(caster:GetAbilityByIndex(i):GetName())
	end
	caster:RemoveAbility(caster.ComboName)
	for i=1, 20 do
		if caster.SavedList[i] == nil then break
		else
			caster:AddAbility(caster.SavedList[i])
		end
		LevelAllAbility(caster)
	end
end

-- Remove all abilities and save it to caster handle
function RemoveAllAbility(caster)
	local abilityList = {}
	for i=0,20 do
		if caster:GetAbilityByIndex(i) ~= nil then 
			local abil = caster:GetAbilityByIndex(i):GetName()
			abilityList[i+1] = abil
			caster:RemoveAbility(caster:GetAbilityByIndex(i):GetName())
		else 
			break
		end
	end
	caster.SavedList = abilityList
end

function OnStrengthGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.STRgained == nil then
		hero.STRgained = 1
	else 
		if hero.STRgained < 50 then
			hero.STRgained = hero.STRgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetBaseStrength(hero:GetBaseStrength()+1) 
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnAgilityGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.AGIgained == nil then
		hero.AGIgained = 1
	else 
		if hero.AGIgained < 50 then
			hero.AGIgained = hero.AGIgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetBaseAgility(hero:GetBaseAgility()+1) 
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnIntelligenceGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()


	if hero.INTgained == nil then
		hero.INTgained = 1
	else 
		if hero.INTgained < 50 then
			hero.INTgained = hero.INTgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetBaseIntellect(hero:GetBaseIntellect()+1) 
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDamageGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.DMGgained == nil then
		hero.DMGgained = 1
	else 
		if hero.DMGgained < 50 then
			hero.DMGgained = hero.DMGgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	local primaryStat = 0
	local attr = hero:GetPrimaryAttribute() -- 0 strength / 1 agility / 2 intelligence
	if attr == 0 then
		primaryStat = hero:GetStrength()
	elseif attr == 1 then
		primaryStat = hero:GetAgility()
	elseif attr == 2 then
		primaryStat = hero:GetIntellect()
	end

	hero:SetBaseDamageMax(hero:GetBaseDamageMax() - primaryStat + 3)
	hero:SetBaseDamageMin(hero:GetBaseDamageMin() - primaryStat + 3)
	hero:CalculateStatBonus()

	print("Current base damage : " .. hero:GetBaseDamageMin()  .. " to " .. hero:GetBaseDamageMax())
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnArmorGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.ARMORgained == nil then
		hero.ARMORgained = 1
	else 
		if hero.ARMORgained < 50 then
			hero.ARMORgained = hero.ARMORgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetPhysicalArmorBaseValue(hero:GetPhysicalArmorBaseValue()+1.5)
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnHPRegenGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.HPREGgained == nil then
		hero.HPREGgained = 1
	else 
		if hero.HPREGgained < 50 then
			hero.HPREGgained = hero.HPREGgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetBaseHealthRegen(hero:GetBaseHealthRegen()+2)
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnManaRegenGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.MPREGgained == nil then
		hero.MPREGgained = 1
	else 
		if hero.MPREGgained < 50 then
			hero.MPREGgained = hero.MPREGgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetBaseManaRegen(hero:GetManaRegen()+1)
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMovementSpeedGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	if hero.MSgained == nil then
		hero.MSgained = 1
	else 
		if hero.MSgained < 50 then
			hero.MSgained = hero.MSgained + 1
		else
			FireGameEvent( 'custom_error_show', { player_ID = ply:GetPlayerID(), _error = "Cannot Upgrade Base Stats over 50 times" } )
			caster:GiveMana(1)
			return
		end
	end 

	hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed()+5) 
	hero:CalculateStatBonus()
	-- Set master 1's mana 
	local master1 = hero.MasterUnit
	master1:SetMana(master1:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnAvariceAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Have Not Died 7 Times Yet" } )
		return 
	else 
		hero.ShardAmount = hero.ShardAmount - 1
	end


	if hero.AvariceCount == nil then 
		hero.AvariceCount = 1
	else
		hero.AvariceCount = hero.AvariceCount + 1
	end

	local teamTable = {}
	for i=0, 9 do
		local player = PlayerResource:GetPlayer(i)
		if player ~= nil then 
			hero = PlayerResource:GetPlayer(i):GetAssignedHero()
			if hero:GetTeam() == caster:GetTeam() then
				table.insert(teamTable, hero)
			end
		end
	end

	for i=1,#teamTable do
		local goldperperson = 20000/#teamTable
		print("Distributing " .. goldperperson .. " per person")
		teamTable[i]:ModifyGold(goldperperson, true, 0)
	end
end

function OnAMAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Have Not Died 7 Times Yet" } )
		return
	else 
		hero.ShardAmount = hero.ShardAmount - 1
	end

	hero:AddItem(CreateItem("item_shard_of_anti_magic" , nil, nil)) 
	
end

function OnReplenishmentAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Have Not Died 7 Times Yet" } )
		return
	else 
		hero.ShardAmount = hero.ShardAmount - 1
	end

	hero:AddItem(CreateItem("item_shard_of_replenishment" , nil, nil)) 
	
end

function OnProsperityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if hero.ShardAmount == 0 or hero.ShardAmount == nil then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Have Not Died 7 Times Yet" } )
		return
	else 
		hero.ShardAmount = hero.ShardAmount - 1
	end


	local master = hero.MasterUnit 
	local master2 = hero.MasterUnit2
	master:SetMana(master:GetMana()+20)
	master:SetMaxHealth(master:GetMaxHealth()+1) 
	master:SetHealth(master:GetHealth()+1)
	master2:SetMana(master:GetMana())
	master2:SetMaxHealth(master:GetMaxHealth()) 
	master2:SetHealth(master:GetHealth())
end

function test(keys)
	print("detection started")
end

function OnPresenceDetectionThink(keys)
	local caster = keys.caster
	local hasSpecialPresenceDetection = false
	if caster:GetName() == "npc_dota_hero_juggernaut" and caster.IsEyeOfSerenityAcquired then 
		hasSpecialPresenceDetection = true
	elseif caster:GetName() == "npc_dota_hero_shadow_shaman" and caster.IsEyeForArtAcquired then
		hasSpecialPresenceDetection = true
	end

	if GameRules:GetGameTime() < RoundStartTime + 60 then
		if hasSpecialPresenceDetection == false then return end 
	end

	local oldEnemyTable = caster.PresenceTable
	local newEnemyTable = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

	-- Flag everyone in range as true before comparing two tables
	for i=1, #newEnemyTable do
		newEnemyTable[i].IsPresenceDetected = true
	end

	-- If enemy has not moved out of range since last presence detection, flag them as false
	for i=1,#oldEnemyTable do
		for j=1, #newEnemyTable do
			if oldEnemyTable[i] == newEnemyTable[j] then 
				--print(" " .. newEnemyTable[j]:GetName() .. " has not been out of range since last presence detection")
				newEnemyTable[j].IsPresenceDetected = false
				break
			end
		end
	end

	-- Do the ping for everyone with IsPresenceDetected marked as true
	for i=1, #newEnemyTable do
		local enemy = newEnemyTable[i]

		-- Filter TA from ping if he has improved presence concealment attribute
		if enemy:GetName() == "npc_dota_hero_bounty_hunter" and enemy.IsPCImproved  then 
			if enemy:HasModifier("modifier_ta_invis") or enemy:HasModifier("modifier_ambush") then break end
		end

		if enemy.IsPresenceDetected == true or enemy.IsPresenceDetected == nil then
			--print("Pinged " .. enemy:GetPlayerOwnerID() .. " by player " .. caster:GetPlayerOwnerID())
			MinimapEvent( caster:GetTeamNumber(), caster, enemy:GetAbsOrigin().x, enemy:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Enemy Servant's presence has been detected" } )
			local dangerping = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster, PlayerResource:GetPlayer(caster:GetPlayerID()))


			ParticleManager:SetParticleControl(dangerping, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(dangerping, 1, enemy:GetAbsOrigin())
			
			--GameRules:AddMinimapDebugPoint(caster:GetPlayerID(), enemy:GetAbsOrigin(), 255, 0, 0, 500, 3.0)
			EmitSoundOnClient("Misc.BorrowedTime", PlayerResource:GetPlayer(caster:GetPlayerID())) 
			-- Process Eye of Serenity attribute
			if caster:GetName() == "npc_dota_hero_juggernaut" and caster.IsEyeOfSerenityAcquired == true and enemy.IsSerenityOnCooldown ~= true then
				enemy.IsSerenityOnCooldown = true
				Timers:CreateTimer(10.0, function() 
					enemy.IsSerenityOnCooldown = false
				end)					
				FAEyeAttribute(caster, enemy)
			end
			-- Process Eye for Art attribute
			if caster:GetName() == "npc_dota_hero_shadow_shaman" and caster.IsEyeForArtAcquired == true then
				local choice = math.random(1,3)
				if choice == 1 then
					Say(caster:GetPlayerOwner(), FindName(enemy:GetName()) .. ", dare to enter the demon's lair on your own?", true) 
				elseif choice == 2 then
					Say(caster:GetPlayerOwner(), "This presence...none other than " .. FindName(enemy:GetName()) .. "!", true) 
				elseif choice == 3 then
					Say(caster:GetPlayerOwner(), "Come forth, " .. FindName(enemy:GetName()) .. "...The fresh terror awaits you!", true) 
				end
			end
		end
	end
	caster.PresenceTable = newEnemyTable
end


-- Scrapped it(can have only 1 instance of AddMinimapDebugPoint at time)
function CustomPing(playerid, location)
	print("Custom Ping Issued")
	GameRules:AddMinimapDebugPoint(playerid, location, 255, 0, 0, 300, 3.0)
end 

function FAEyeAttribute(caster, enemy)
	local eye = ParticleManager:CreateParticleForPlayer("particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN, caster, PlayerResource:GetPlayer(caster:GetPlayerID()))
	ParticleManager:SetParticleControl(eye, 0, enemy:GetAbsOrigin())

	local eyedummy = CreateUnitByName("sight_dummy_unit", enemy:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	eyedummy:SetDayTimeVisionRange(500)
	eyedummy:SetNightTimeVisionRange(500)
	eyedummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 100}) 
	

	local eyedummypassive = eyedummy:FindAbilityByName("dummy_unit_passive")
	eyedummypassive:SetLevel(1)

	local eyeCounter = 0

	Timers:CreateTimer(function() 
		if eyeCounter > 3.0 then DummyEnd(eyedummy) return end
		eyedummy:SetAbsOrigin(enemy:GetAbsOrigin()) 
		eyeCounter = eyeCounter + 0.2
		return 0.2
	end)
end