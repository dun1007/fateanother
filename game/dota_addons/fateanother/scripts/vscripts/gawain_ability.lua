function OnIRStart(keys)
	local caster = keys.caster
	local target = keys.target

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:EmitSound("Hero_Omniknight.Purification")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_ally", {})
	else
		target:EmitSound("Hero_Omniknight.Purification")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_invigorating_ray_enemy", {})
	end
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
end

function OnIRTickAlly(keys)
	local caster = keys.caster
	local target = keys.target
	target:SetHealth(target:GetHealth() + keys.Damage/5)
end

function OnIRTickEnemy(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(caster, target, keys.Damage/5, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
end

function OnDevoteStart(keys)
	local caster = keys.caster
	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_blade_of_the_devoted") then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 
			
			for k,v in pairs(targets) do
				keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_blade_of_the_devoted_ally_deniable",{})
			end
		end
		return 0.1
	end)

	caster:EmitSound("Hero_EmberSpirit.FireRemnant.Cast")
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( lightFx1, 0, caster:GetAbsOrigin())
end

function OnDevoteHit(keys)
	local caster = keys.caster
	local target = keys.target

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		-- process team effect
		target:SetHealth(target:GetHealth() + keys.Damage + caster:GetAttackDamage())
	else
		-- process enemy effect
		DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
		target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.1})
	end


	target:EmitSound("Hero_Invoker.ColdSnap")
	local lightFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( lightFx1, 0, target:GetAbsOrigin())
	local flameFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( flameFx1, 0, target:GetAbsOrigin())
end

function OnGalatineStart(keys)
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local orbLoc = caster:GetAbsOrigin()
	local dist = (targetPoint - casterLoc):Length2D()
	local diff = (targetPoint - caster:GetAbsOrigin()):Normalized()
	local timeElapsed = 0
	local flyingDist = 0
	local InFirstLoop = true

	caster.IsGalatineActive = true

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 1.75)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur_galatine_anim",{})
	EmitGlobalSound("Gawain.Galatine")


	local castFx1 = ParticleManager:CreateParticle("particles/custom/saber_excalibur_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx1, 0, caster:GetAbsOrigin())

	local castFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( castFx2, 0, caster:GetAbsOrigin())

	local galatineDummy = CreateUnitByName("gawain_galatine_dummy", Vector(20000,20000,0), true, nil, nil, caster:GetTeamNumber())
	local flameFx1 = ParticleManager:CreateParticle("particles/custom/gawain/gawain_excalibur_galatine_orb.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
	ParticleManager:SetParticleControl( flameFx1, 0, galatineDummy:GetAbsOrigin())


	Timers:CreateTimer(1.5, function()
		if caster:IsAlive() and timeElapsed < 1.5 and flyingDist < dist and caster.IsGalatineActive then
			if InFirstLoop then
				caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, true)
				InFirstLoop = false
			end
			orbLoc = orbLoc + diff * 33
			galatineDummy:SetAbsOrigin(orbLoc)
			flyingDist = (casterLoc - orbLoc):Length2D()
			timeElapsed = timeElapsed + 0.033
			return 0.033
		else 
			if caster:GetAbilityByIndex(2):GetAbilityName() == "gawain_excalibur_galatine_detonate" then
				caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, true)
			end
			-- Explosion on allies
			local targets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				v:SetHealth(v:GetHealth() + keys.Damage * 66/100)
			end

			-- Explosion on enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), galatineDummy:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end

			local explodeFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf", PATTACH_ABSORIGIN, galatineDummy )
			ParticleManager:SetParticleControl( explodeFx1, 0, galatineDummy:GetAbsOrigin())			

			local explodeFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, galatineDummy )
			ParticleManager:SetParticleControl( explodeFx2, 0, galatineDummy:GetAbsOrigin())

			galatineDummy:EmitSound("Ability.LightStrikeArray")

			galatineDummy:ForceKill(true) 
			ParticleManager:DestroyParticle( flameFx1, false )
			ParticleManager:ReleaseParticleIndex( flameFx1 )
			ParticleManager:DestroyParticle( castFx1, false )
			ParticleManager:ReleaseParticleIndex( castFx1 )
			return
		end
	end)
end

function OnGalatineDetonate(keys)
	local caster = keys.caster
	caster.IsGalatineActive = false
	if caster:GetAbilityByIndex(2):GetAbilityName() == "gawain_excalibur_galatine_detonate" then
		caster:SwapAbilities("gawain_excalibur_galatine", "gawain_excalibur_galatine_detonate", true, true)
	end
end

function OnEmbraceStart(keys)
	local caster = keys.caster
	local target = keys.target

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		-- process team effect
		local currentHealth = target:GetMaxHealth() - target:GetHealth()
		target:SetHealth(target:GetHealth() + currentHealth/2)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_suns_embrace_ally",{})
	else
		-- process enemy effect
		--DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_suns_embrace_enemy",{})
	end
end

function OnEmbraceTickAlly(keys)
	local caster = keys.caster
	local target = keys.target
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_suns_embrace_burn",{})
	end
end

function OnEmbraceTickEnemy(keys)
	local caster = keys.caster
	local target = keys.target
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_suns_embrace_burn",{})
	end
end

function OnEmbraceDamageTick(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(caster, target, keys.Damage/32 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnSupernovaStart(keys)
end

function OnDawnAcquired(keys)
end

function OnFairyAcquired(keys)
end

function OnMeltdownAcquired(keys)
end

function OnSunlightAcquired(keys)
end

function OnEclipseAcquired(keys)
end

