

SaberAttribute = {
	"saber_attribute_improve_excalibur",
	"saber_attribute_improve_instinct",
	"saber_attribute_chivalry",
	"saber_attribute_strike_air"
}

LancerAttribute = {
	"lancer_attribute_improve_battle_continuation",
	"lancer_attribute_improve_gae_bolg",
	"lancer_attribute_protection_from_arrows",
	"lancer_attribute_the_heartseeker"
}

SaberAlterAttribute = {
	"saber_alter_attribute_mana_shroud",
	"saber_alter_attribute_mana_blast",
	"saber_alter_attribute_improve_ferocity",
	"saber_alter_attribute_ultimate_darklight"
}

RiderAttribute = {
	"rider_5th_attribute_improve_mystic_eyes",
	"rider_5th_attribute_riding",
	"rider_5th_attribute_seal",
	"rider_5th_attribute_monstrous_strength"
}

ArcherAttribute = {
	"archer_5th_attribute_eagle_eye",
	"archer_5th_attribute_hrunting",
	"archer_5th_attribute_shroud_of_martin",
	"archer_5th_attribute_improve_projection",
	"archer_5th_attribute_overedge"
}

BerserkerAttribute = {
	"berserker_5th_attribute_improve_divinity",
	"berserker_5th_attribute_berserk",
	"berserker_5th_attribute_god_hand",
	"berserker_5th_attribute_reincarnation"
}

FAAttribute = {
	"false_assassin_attribute_ganryu",
	"false_assassin_attribute_eye_of_serenity",
	"false_assassin_attribute_quickdraw",
	"false_assassin_attribute_vitrification"
}

TAAttribute = {
	"true_assassin_attribute_improve_presence_concealment",
	"true_assassin_attribute_protection_from_wind",
	"true_assassin_attribute_weakening_venom",
	"true_assassin_attribute_shadow_strike"
}

GilgaAttribute = {
	"gilgamesh_attribute_improve_golden_rule",
	"gilgamesh_attribute_power_of_sumer",
	"gilgamesh_attribute_rain_of_swords",
	"gilgamesh_attribute_sword_of_creation"
}

CasterAttribute = {
	"caster_5th_attribute_improve_territory_creation",
	"caster_5th_attribute_improve_argos",
	"caster_5th_attribute_improve_hecatic_graea",
	"caster_5th_attribute_dagger_of_treachery"
}

function LoopThroughAttr(hero, attrTable)
	for i=1, #attrTable do
		hero:AddAbility(attrTable[i])
	end
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
	elseif name == "npc_dota_hero_gilgamesh" then
		attributes = GilgaAttribute
	end
	return attributes
end 

function AddMasterAbility(master, name)
	--local ply = master:GetPlayerOwner()
	local attributeTable = FindAttribute(name)
	LoopThroughAttr(master, attributes)
end

function OnAttributeListOpen(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()

	local attributeTable = FindAttribute(hero:GetName())
	for 
	caster:SwapAbilities("berserker_5th_divinity","berserker_5th_divinity_improved", false, true)
end

function OnAttributeListClose(keys)
end

function OnStatListOpen(keys)
end

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