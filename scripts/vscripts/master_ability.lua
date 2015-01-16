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
	"false_assassin_illusory_wanderer",
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


function OnSeal1Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	ply.IsFirstSeal = true
	caster:FindAbilityByName("cmd_seal_1"):StartCooldown(60)
	Timers:CreateTimer({
		endTime = 20.0,
		callback = function()
		ply.IsFirstSeal = false
	end
	})
end

function OnSeal2Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	for i=0, 30 do 
		local ability = hero:GetAbilityByIndex(i)
		if ability ~= nil then
			ability:EndCooldown()
		else break end
	end
	if ply.IsFirstSeal == true then
		keys.ability:EndCooldown()
		--print("did it end?")
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(30)
	end
end

function OnSeal3Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	hero:Heal(hero:GetMaxHealth(), hero)
	if ply.IsFirstSeal == true then
		keys.ability:EndCooldown()
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(30)
	end
end

function OnSeal4Start(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	hero:SetMana(hero:GetMaxMana()) 
	if ply.IsFirstSeal == true then
		keys.ability:EndCooldown()
	else
		caster:FindAbilityByName("cmd_seal_1"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_2"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_3"):StartCooldown(30)
		caster:FindAbilityByName("cmd_seal_4"):StartCooldown(30)
	end
end


function LoopThroughAttr(hero, attrTable)
	for i=1, #attrTable do
		print("Added " .. attrTable[i])
		hero:AddAbility(attrTable[i])
	end
	hero.ComboName = attrTable[#attrTable]
	--print(attrTable[#attrTable])
	hero:SwapAbilities(attrTable[#attrTable], hero:GetAbilityByIndex(3):GetName(), true, true)
	hero:SwapAbilities("master_close_list", "fate_empty1", true, true)
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
	end
	return attributes
end 

function AddMasterAbility(master, name)
	--local ply = master:GetPlayerOwner()
	local attributeTable = FindAttribute(name)
	LoopThroughAttr(master, attributeTable)
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
	caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), caster.ComboName, true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "fate_empty1", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "fate_empty2", true, true)
end

function OnStatListClose(keys)
	local caster = keys.caster
	for i=0,5 do
		caster:RemoveAbility(caster:GetAbilityByIndex(i):GetName())
	end
	for i=1, 20 do
		if caster.SavedList[i] == nil then break
		else
			caster:AddAbility(caster.SavedList[i])
		end
		LevelAllAbility(caster)
	end
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
	caster:GetAbilityByIndex(0):SetLevel(1) 
	caster:GetAbilityByIndex(1):SetLevel(1)
	caster:GetAbilityByIndex(2):SetLevel(1)
	caster:GetAbilityByIndex(3):SetLevel(1)
end

-- Remove all abilities and save it to caster handle
function RemoveAllAbility(caster)
	local abilityList = {}
	for i=0,20 do
		if caster:GetAbilityByIndex(i) ~= nil then 
			abilityList[i+1] = caster:GetAbilityByIndex(i):GetName()
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
	hero:SetBaseStrength(hero:GetBaseStrength()+1) 
end

function OnAgilityGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetBaseAgility(hero:GetBaseAgility()+1) 
end

function OnIntelligenceGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetBaseIntellect(hero:GetBaseIntellect()+1) 
end

function OnDamageGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetBaseDamageMin(hero:GetBaseDamageMin()+3)
	hero:SetBaseDamageMax(hero:GetBaseDamageMax()+3)
end

function OnArmorGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetPhysicalArmorBaseValue(hero:GetPhysicalArmorBaseValue()+2)
end

function OnHPRegenGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetBaseHealthRegen(hero:GetBaseHealthRegen()+2) 
end

function OnManaRegenGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetBaseManaRegen(hero:GetManaRegen()+1)
end

function OnMovementSpeedGain(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed()+5) 
end

function PresenceDetection(keys)
	local caster = keys.caster

	EmitGlobalSound("Misc.BorrowedTime") --[[Returns:void
	Play named sound for all players
	]]
	print("Presence detection started by " .. caster:GetName())
	Timers:CreateTimer(function()  
		print("Detecting enemy servants")
		local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false) 
		for i=1, #enemies do
			local enemy = enemies[i]

			if enemy.IsPresenceDetected ~= true or enemy.IsPresenceDetected == nil then
				--enemy.IsPresenceDetected = true
				caster.PresenceDetectionTable = enemies
				print("Pinged " .. enemy:GetPlayerOwnerID() .. " by player " .. caster:GetPlayerOwnerID())
				local dangerping = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster, PlayerResource:GetPlayer(caster:GetPlayerID()))
				ParticleManager:SetParticleControl(dangerping, 0, enemy:GetAbsOrigin())
				ParticleManager:SetParticleControl(dangerping, 1, enemy:GetAbsOrigin())
				--GameRules:AddMinimapDebugPoint(caster:GetPlayerID(), enemy:GetAbsOrigin(), 255, 0, 0, 500, 3.0)
				EmitSoundOnClient("Misc.BorrowedTime", PlayerResource:GetPlayer(caster:GetPlayerID())) 
			end
		end
		return 5.0
	end)
end

function CompareValues(t1,t2)
	local peopleIn = {}
	local peopleOut = {}
	
	for i=1,#ti do
		for j=1, #t2 do
			if t1[i] == t1[j] then 
				return false
				break 
			end
		end
	end

end

function CustomPing(playerid, location)
	print("Custom Ping Issued")
	GameRules:AddMinimapDebugPoint(playerid, location, 255, 0, 0, 300, 3.0)
end 