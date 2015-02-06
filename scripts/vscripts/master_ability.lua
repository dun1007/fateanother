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
	local hero = ply:GetAssignedHero()

	if hero:HasModifier("pause_sealdisabled") or hero:HasModifier("rb_sealdisabled") then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+2) 
		caster:SetHealth(caster:GetHealth()+1) 
		keys.ability:EndCooldown() 
		return
	end

	-- Particle
	hero:EmitSound("DOTA_Item.Dagon.Activate")
	local particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas_radial.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


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

	if hero:HasModifier("pause_sealdisabled") or hero:HasModifier("rb_sealdisabled") or hero:HasModifier("jump_pause") then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+2) 
		caster:SetHealth(caster:GetHealth()+1) 
		keys.ability:EndCooldown() 
		return
	end

	-- Reset all resetable abilities
	for i=0, 30 do 
		local ability = hero:GetAbilityByIndex(i)
		if ability ~= nil then
			if ability.IsResetable ~= false then
				ability:EndCooldown()
			end
		else 
			break
		end
	end

	-- Particle
	hero:EmitSound("DOTA_Item.Refresher.Activate")
	local particle = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


	-- Set cooldown
	if ply.IsFirstSeal == true then
		keys.ability:EndCooldown()
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

	if hero:HasModifier("pause_sealdisabled") or hero:HasModifier("rb_sealdisabled") then
		print("Cannot use seals")
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+1) 
		caster:SetHealth(caster:GetHealth()+1) 
		keys.ability:EndCooldown() 
		return
	end

	hero:EmitSound("DOTA_Item.UrnOfShadows.Activate")

	local particle = ParticleManager:CreateParticle("particles/items2_fx/urn_of_shadows_heal_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
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

	if hero:HasModifier("pause_sealdisabled") or hero:HasModifier("rb_sealdisabled") then
		print("Cannot use seals")
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Command Seal cannot be cast now!" } )
		caster:SetMana(caster:GetMana()+1) 
		caster:SetHealth(caster:GetHealth()+1) 
		keys.ability:EndCooldown() 
		return
	end

	-- Particle
	hero:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target")
	local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())


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

function OnShardOpen(keys)
	local caster = keys.caster

	RemoveAllAbility(caster)
	caster:AddAbility("master_shard_of_avarice")
	caster:AddAbility("master_shard_of_anti_magic")
	caster:AddAbility("master_shard_of_replenishment")
	caster:AddAbility("master_close_stat_list")
	caster:AddAbility("master_shard_of_prosperity")
	caster:AddAbility("fate_empty2")
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
	print(hero:GetAgility())
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

function OnAvariceAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	if ply.AvariceCount == nil then 
		ply.AvariceCount = 1
	else
		ply.AvariceCount = ply.AvariceCount + 1
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
		local goldperperson = 30000/#teamTable
		print("Distributing " .. goldperperson .. " per person3")
		teamTable[i]:ModifyGold(goldperperson, true, 0)
	end
end

function OnAMAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:AddItem(CreateItem("item_shard_of_anti_magic" , nil, nil)) 
	
end

function OnReplenishmentAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	hero:AddItem(CreateItem("item_shard_of_replenishment" , nil, nil)) 
	
end

function OnProsperityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	local master = hero.MasterUnit 
	caster:SetMana(caster:GetMana()+20)
	caster:SetMaxHealth(caster:GetMaxHealth()+1) 
	master:SetMana(master:GetMana()+20)
	master:SetMaxHealth(master:GetMaxHealth()+1) 
end

function PresenceDetection(keys)
	local caster = keys.caster
	print("Presence detection started by " .. caster:GetName())

	Timers:CreateTimer(function()  
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
			if enemy:GetName() == "npc_dota_hero_bounty_hunter" and enemy:GetPlayerOwner().IsPCImproved  then 
				if enemy:HasModifier("modifier_ta_invis") or enemy:HasModifier("modifier_ambush") then break end
			end

			if enemy.IsPresenceDetected == true or enemy.IsPresenceDetected == nil then
				--print("Pinged " .. enemy:GetPlayerOwnerID() .. " by player " .. caster:GetPlayerOwnerID())
				FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Enemy Servant's presence has been detected" } )
				local dangerping = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/ping_world.vpcf", PATTACH_ABSORIGIN, caster, PlayerResource:GetPlayer(caster:GetPlayerID()))
				ParticleManager:SetParticleControl(dangerping, 0, enemy:GetAbsOrigin())
				ParticleManager:SetParticleControl(dangerping, 1, enemy:GetAbsOrigin())
				--GameRules:AddMinimapDebugPoint(caster:GetPlayerID(), enemy:GetAbsOrigin(), 255, 0, 0, 500, 3.0)
				EmitSoundOnClient("Misc.BorrowedTime", PlayerResource:GetPlayer(caster:GetPlayerID())) 
				-- Process Eye of Serenity attribute
				if caster:GetName() == "npc_dota_hero_juggernaut" and caster:GetPlayerOwner().IsEyeOfSerenityAcquired == true and enemy.IsSerenityOnCooldown ~= true then
					print("Eye of Serenity activated")
					enemy.IsSerenityOnCooldown = true
					Timers:CreateTimer(10.0, function() 
						enemy.IsSerenityOnCooldown = false
					end)					
					FAEyeAttribute(caster, enemy)
				end
			end
		end
		caster.PresenceTable = newEnemyTable
		return 0.3
	end)
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