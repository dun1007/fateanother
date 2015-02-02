require("Physics")
require("util")

enkiduTarget = nil

function OnBarrageStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local dot = keys.Damage

	local rainCount = 0

    Timers:CreateTimer(function()
    	if rainCount == 15 then return end
        targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
        	DoDamage(caster, v, dot, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		end
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, targetPoint)
		ParticleManager:SetParticleControl(particle, 1, targetPoint)
		ParticleManager:SetParticleControl(particle, 5, targetPoint)
		ParticleManager:SetParticleControl(particle, 6, targetPoint)
		rainCount = rainCount + 1
      	return 0.15
    end
    )
	--local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	--ParticleManager:SetParticleControl(particle, 3, targetPoint) -- target effect location
end

function OnGoldenRuleStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local goldgain = 10
    Timers:CreateTimer(function()
    	if ply.IsGoldenRuleImproved == true then goldgain = 20 end
    	keys.caster:ModifyGold(goldgain, true, 0) 
      	return 1.0
    end)
end


function OnChainStart(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target
	local targetloc = target:GetAbsOrigin()
	giveUnitDataDrivenModifier(caster, target, "pause_sealenabled", keys.Duration)
	giveUnitDataDrivenModifier(caster, target, "rb_sealdisabled", keys.Duration)
	caster:EmitSound("Gilgamesh.Enkidu" ) 
	enkiduTarget = target

	if ply.IsRainAcquired then
		local rainCount = 0
	    Timers:CreateTimer(function()
	    	if rainCount == 15 then return end
	       	local targets = FindUnitsInRadius(caster:GetTeam(), targetloc, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	        for k,v in pairs(targets) do
	        	DoDamage(caster, v, 25, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, targetloc)
			ParticleManager:SetParticleControl(particle, 1, targetloc)
			ParticleManager:SetParticleControl(particle, 5, targetloc)
			ParticleManager:SetParticleControl(particle, 6, targetloc)
			rainCount = rainCount + 1
	      	return 0.15
	    end
	    )
	end

	print(caster.IsGOBUp)
	if caster.IsGOBUp and ply.IsSumerAcquired then 
		-- Casting by dummy doesn't work for some reason
		local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
		dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
		dummy:AddAbility("gilgamesh_power_of_sumer")
		local dummyAbility = dummy:FindAbilityByName("gilgamesh_power_of_sumer")
		dummyAbility:SetLevel(1)
		dummy:CastAbilityOnTarget(target, dummyAbility, 1) 
		Timers:CreateTimer(1.0, function() dummy:RemoveSelf() return end)
	end
end

function OnChainBroken(keys)
	if enkiduTarget ~= nil then enkiduTarget:RemoveModifierByName("pause_sealdisabled") end
end

function OnGramStart(keys)
	local caster = keys.caster
	local target = keys.target
	local info = {
		Target = target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 700
	}
	ProjectileManager:CreateTrackingProjectile(info) 
end

function OnGramHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_cast_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())

	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
	end
end

function OnGOBStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local duration = keys.Duration
	local frontward = caster:GetForwardVector()
	local casterloc = caster:GetAbsOrigin()
	caster.GOBLocation = casterloc
	caster.IsGOBUp = true
	GilgaCheckCombo(caster, keys.ability)

	local gobWeapon = 
	{
		Ability = keys.ability,
        EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
        iMoveSpeed = 1300,
        vSpawnOrigin = casterloc,
        fDistance = 1300,
        fStartRadius = 100,
        fEndRadius = 100,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 15.0,
		bDeleteOnHit = true,
		vVelocity = frontward * 1300
	}


	local leftvec = Vector(-frontward.y, frontward.x, 0)
	local rightvec = Vector(frontward.y, -frontward.x, 0)
	local projectile = nil
	local gobCount = 0

    Timers:CreateTimer(function()
    	if gobCount > duration then caster.IsGOBUp = false return end

    	local random1 = RandomInt(0, 400) -- position of weapon spawn
		local random2 = RandomInt(0,1) -- whether weapon will spawn on left or right side of hero

    	if random2 == 0 then 
    		gobWeapon.vSpawnOrigin = casterloc + leftvec*random1
    	else 
    		gobWeapon.vSpawnOrigin = casterloc + rightvec*random1
    	end
    	projectile = ProjectileManager:CreateLinearProjectile(gobWeapon)
    	gobCount = gobCount + 0.15
      	return 0.15
    end
    )

end


function OnGOBHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function SumerArrowFire(keys)
	local caster = keys.caster
	local target = keys.target
	local info = {
		Target = target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_drow/drow_base_attack.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 700
	}
	for i=1,10 do
		info.vSpawnOrigin = caster:GetAbsOrigin() + Vector(RandomInt(-100, 100),RandomInt(-100, 100) ,RandomInt(-100, 100))
		ProjectileManager:CreateTrackingProjectile(info) 
	end
end

function OnSumerArrowHit(keys)

	DoDamage(keys.caster:GetPlayerOwner():GetAssignedHero(), keys.target, 50, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end


function OnEnumaStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()
	local enuma = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = casterloc,
        fDistance = keys.Range,
        fStartRadius = keys.StartRadius,
        fEndRadius = keys.EndRadius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = frontward * keys.Speed
	}
	Timers:CreateTimer(2.0, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Gilgamesh.Enuma" ) return 
		end
	end)
	Timers:CreateTimer(3.0, function() 
		if caster:IsAlive() then
			enuma.vSpawnOrigin = caster:GetAbsOrigin() 
			projectile = ProjectileManager:CreateLinearProjectile(enuma) return 
		end
	end)
end

function OnEnumaHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMaxEnumaStart(keys)
	local caster = keys.caster
	caster:FindAbilityByName("gilgamesh_enuma_elish"):StartCooldown(47)
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()
	local casterloc = caster:GetAbsOrigin()
	local enuma = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = nil,
        fDistance = keys.Range,
        fStartRadius = keys.StartRadius,
        fEndRadius = keys.EndRadius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = frontward * keys.Speed
	}
	Timers:CreateTimer(2.75, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Gilgamesh.Enuma" ) return 
		end
	end)
	Timers:CreateTimer(3.75, function()
		if caster:IsAlive() then
			enuma.vSpawnOrigin = caster:GetAbsOrigin() 
			projectile = ProjectileManager:CreateLinearProjectile(enuma) return 
		end
	end)
end

function OnMaxEnumaHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function GilgaCheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("gilgamesh_gate_of_babylon") then
		caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_max_enuma_elish", true, true) 
	end
	Timers:CreateTimer({
		endTime = 5,
		callback = function()
		caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_max_enuma_elish", true, true) 
	end
	})

end

function OnImproveGoldenRuleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsGoldenRuleImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPowerOfSumerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsSumerAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnRainOfSwordsAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsRainAcquired = true
	hero:SwapAbilities("gilgamesh_sword_barrage","gilgamesh_sword_barrage_improved", true, true)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSwordOfCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsEnumaImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end