function OnLoveSpotStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local lovespotCount = 0
	local forcemove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
		Position = nil
	}
	if caster.IsLoveSpotImproved then keys.Duration = keys.Duration + 2 end
	DiarmuidCheckCombo(caster, keys.ability)

	caster:EmitSound("Hero_Warlock.ShadowWord")

	Timers:CreateTimer(function()
		if lovespotCount == keys.Duration then caster:StopSound("Hero_Warlock.ShadowWord") return end
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if IsFemaleServant(v) then
				forcemove.UnitIndex = v:entindex()
				forcemove.Position = caster:GetAbsOrigin() 
				ExecuteOrderFromTable(forcemove) 
				giveUnitDataDrivenModifier(caster, v, "pause_sealenabled", 0.5)
			    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
			    ParticleManager:SetParticleControl(particle, 0, v:GetAbsOrigin())
				Timers:CreateTimer( 2.0, function()
					ParticleManager:DestroyParticle( particle, false )
					ParticleManager:ReleaseParticleIndex( particle )
				end)
			end
		end
	    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
		lovespotCount = lovespotCount + 1
		return 1.0
	end)
	

end

function OnChargeStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	if caster:HasModifier("modifier_double_spearsmanship") then keys.Damage = keys.Damage * 2 end
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
         v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
    end

    --particle
    caster:EmitSound("Hero_Huskar.Life_Break")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function OnDSStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_double_spearsmanship", {})
end

function OnRampantWarriorStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:EmitSound("Hero_Clinkz.DeathPact")
	caster:FindAbilityByName("diarmuid_double_spearsmanship"):StartCooldown(19)
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior", {})

	caster:FindAbilityByName("diarmuid_double_spearsmanship"):ApplyDataDrivenModifier(caster, caster, "modifier_double_spearsmanship", {})
	local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
end

function OnRampantWarriorCrit(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rampant_warrior_crit_hit", {})
end

function OnGaeCastStart(keys)
	local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	if keys.ability == caster:FindAbilityByName("diarmuid_gae_buidhe") then
		caster:EmitSound("ZL.Buidhe_Cast")
	elseif keys.ability == caster:FindAbilityByName("diarmuid_gae_dearg") then 
		caster:EmitSound("ZL.Dearg_Cast")
	end
end

function OnBuidheStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	if caster.IsRoseBloomAcquired then 
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_mark_of_mortality", {})
	end

	if target:GetHealth() < keys.Damage then
		target:Kill(keys.ability, caster)
	end
	local MR = 0
	if target:IsHero() then MR = target:GetMagicalArmorValue() end
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	local targetHealthPercentage = target:GetHealth() / target:GetMaxHealth()

	if target:GetHealth() > 0 and target:IsAlive() then
		local currentStack = target:GetModifierStackCount("modifier_gae_buidhe", keys.ability)
		if currentStack == 0 and target:HasModifier("modifier_gae_buidhe") then currentStack = 1 end
		target:RemoveModifierByName("modifier_gae_buidhe") 
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_gae_buidhe", {}) 
		target:SetModifierStackCount("modifier_gae_buidhe", keys.ability, currentStack + 1)
		if target:IsRealHero() then target:CalculateStatBonus() end

		local targetNewHealth = target:GetHealth() + keys.Damage * (1-MR) * targetHealthPercentage 
	    target:SetHealth(targetNewHealth)
	end



	EmitGlobalSound("ZL.Gae_Buidhe")
	target:EmitSound("Hero_Lion.Impale")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_diarmuid_gae_buidhe_anim", {})
	PlayGaeEffect(target)
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex( dagon_particle )
	end)

	if caster.IsDoubleSpearAcquired and caster.IsDoubleSpearReady and caster:FindAbilityByName("diarmuid_gae_dearg"):IsCooldownReady() and caster:GetMana() >= 550 then
		--print("Double spear activated")
		local dearg = caster:FindAbilityByName("diarmuid_gae_dearg")
		local minDamage = dearg:GetLevelSpecialValueFor("min_damage", dearg:GetLevel()-1)
		local maxDamage = dearg:GetLevelSpecialValueFor("max_damage", dearg:GetLevel()-1)
		keys.MinDamage = minDamage
		keys.MaxDamage = maxDamage
		Timers:CreateTimer(0.033, function()
			caster:FindAbilityByName("diarmuid_gae_dearg"):StartCooldown(32)
			local doublestrike = caster:FindAbilityByName("diarmuid_double_spear_strike")
			doublestrike:StartCooldown(45)
			doublestrike:ToggleAbility()
			caster:SetMana(caster:GetMana() - 550)
			Timers:CreateTimer(45, function()
				doublestrike:ToggleAbility() 
			end)
			OnDeargStart(keys)
		end)
		--caster:CastAbilityOnTarget(target, caster:FindAbilityByName("diarmuid_gae_dearg"), caster:GetPlayerID())
	end
end

function OnBuidheOwnerDeath(keys)
	local caster = keys.caster
    LoopOverHeroes(function(hero)
    	hero:RemoveModifierByName("modifier_gae_buidhe")
    end)
end

function OnBuidheBearerDeath(keys)
	--PrintTable(keys)
	local unit = keys.unit
	unit:RemoveModifierByName("modifier_gae_buidhe")
end

function OnDeargStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	ApplyStrongDispel(target)

	local damage = 0
	local maxDamageDist = 100
	local minDamageDist = 650
	if caster.IsRoseBloomAcquired then 
		maxDamageDist = 300
	end
	local distDiff = minDamageDist - maxDamageDist
	local damageDiff = keys.MaxDamage - keys.MinDamage
	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 
	if distance <= maxDamageDist then 
		damage = keys.MaxDamage
	elseif maxDamageDist < distance and distance < minDamageDist then
		damage = keys.MinDamage + damageDiff * (minDamageDist - distance) / distDiff
	elseif minDamageDist <= distance then
		damage = keys.MinDamage
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
	--print("Gae Dearg dealt " .. damage .. " damage to target")
	if target:HasModifier("modifier_mark_of_mortality") then
		local detonateDamage = target:GetMaxHealth() * 15/100
		DoDamage(caster, target, detonateDamage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false) 
		target:RemoveModifierByName("modifier_mark_of_mortality")
	end

	EmitGlobalSound("ZL.Gae_Dearg")
	target:EmitSound("Hero_Lion.Impale")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_diarmuid_gae_dearg_anim", {})
	PlayGaeEffect(target)
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:ReleaseParticleIndex( dagon_particle )
	end)

	if caster.IsDoubleSpearAcquired and caster.IsDoubleSpearReady and caster:FindAbilityByName("diarmuid_gae_buidhe"):IsCooldownReady() and caster:GetMana() >= 550 then
		print("Double spear activated")
		local buidhe = caster:FindAbilityByName("diarmuid_gae_buidhe")
		keys.Damage = buidhe:GetLevelSpecialValueFor("damage", buidhe:GetLevel()-1)
		keys.ability = buidhe
		Timers:CreateTimer(0.033, function()
			caster:FindAbilityByName("diarmuid_gae_buidhe"):StartCooldown(32)
			local doublestrike = caster:FindAbilityByName("diarmuid_double_spear_strike")
			doublestrike:StartCooldown(45)
			doublestrike:ToggleAbility()
			caster:SetMana(caster:GetMana() - 550)
			Timers:CreateTimer(45, function()
				doublestrike:ToggleAbility() 
			end)
			OnBuidheStart(keys)
		end)
		--caster:CastAbilityOnTarget(target, caster:FindAbilityByName("diarmuid_gae_dearg"), caster:GetPlayerID())
	end
end

function PlayGaeEffect(target)
	local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( culling_kill_particle, false )
		ParticleManager:ReleaseParticleIndex( culling_kill_particle )
	end)
end 

function OnMindEyeStart(keys)
	local caster = keys.caster
	local sightdummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	sightdummy:SetDayTimeVisionRange(caster:GetDayTimeVisionRange())
	sightdummy:SetNightTimeVisionRange(caster:GetNightTimeVisionRange())

	caster.MindsEyeDummy = sightdummy
	local sightdummypassive = sightdummy:FindAbilityByName("dummy_unit_passive")
	sightdummypassive:SetLevel(1)

	Timers:CreateTimer(function() 
		if not IsValidEntity(sightdummy) then return end
		sightdummy:SetAbsOrigin(caster:GetAbsOrigin())
		return 0.2
	end)
end

function OnMindEyeEnd(keys)
	local caster = keys.caster
	if IsValidEntity(caster.MindsEyeDummy) then 
		caster.MindsEyeDummy:ForceKill(true)
	end
end

function OnDSToggleOn(keys)
	local caster = keys.caster
	print("double spear on")
	caster.IsDoubleSpearReady = true
end

function OnDSToggleOff(keys)
	local caster = keys.caster
	print("double spear off")
	caster.IsDoubleSpearReady = false
end

function OnLoveSpotImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsLoveSpotImproved = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMindEyeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsMindEyeAcquired = true
    hero:AddAbility("diarmuid_minds_eye") 
    hero:FindAbilityByName("diarmuid_minds_eye"):SetLevel(1)
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnRosebloomAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsRoseBloomAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDoubleSpearAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsDoubleSpearAcquired = true
    hero.IsDoubleSpearReady = true
    hero:SwapAbilities("fate_empty1", "diarmuid_double_spear_strike", true, true) 
	hero:FindAbilityByName("diarmuid_double_spear_strike"):ToggleAbility()
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function DiarmuidCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("diarmuid_love_spot") and caster:FindAbilityByName("diarmuid_double_spearsmanship"):IsCooldownReady() and caster:FindAbilityByName("diarmuid_rampant_warrior"):IsCooldownReady()  then
			caster:SwapAbilities("diarmuid_double_spearsmanship", "diarmuid_rampant_warrior", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				caster:SwapAbilities("diarmuid_double_spearsmanship", "diarmuid_rampant_warrior", true, false) 
			end
			})
		end
	end
end