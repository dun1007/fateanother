require("physics")
require("util")

lastDamageTaken = 0
rhoShieldAmount = 0
currentHealth = 0
chainTargetsTable = nil

function FarSightVision(keys)
	visiondummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())

	local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)
	Timers:CreateTimer(8, function() return FarSightEnd(visiondummy) end)
end

function FarSightEnd(dummy)
	dummy:RemoveSelf()
	return nil
end

function KBStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if chainTargetsTable == nil then
		chainTargetsTable = FindUnitsInRadius(keys.caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	end

	local chainSource = chainTargetsTable[#chainTargetsTable - 1]
	if #chainTargetsTable == 1 then
                chainSource = chainTargetsTable[1]
    end
	local chainTarget = chainTargetsTable[#chainTargetsTable]

	local info = {
		Target = chainTarget, -- chainTarget
		Source = chainSource, -- chainSource
		Ability = ability,
		EffectName = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1000
	}
	ProjectileManager:CreateTrackingProjectile(info) 

	
end

function KBBounce(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage = {
		victim = target,
		attacker = caster,
		damage = keys.DamagePerTick,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
		abilityReturn = nil
	}

	ApplyDamage(damage)

	if #chainTargetsTable < 4 then
		caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID()) 
	else 
		chainTargetsTable = nil
	end
end

function BPHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local targetdmg = {
		attacker = caster,
		victim = target,
		damage = keys.TargetDamage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	ApplyDamage(targetdmg)

	local splashdmg = {
		attacker = caster,
		victim = nil,
		damage = keys.SplashDamage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         splashdmg.victim = v
         ApplyDamage(splashdmg)
    end


    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())
	--ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()) -- target location


	
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
end

function RhoAiasShield(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	rhoShieldAmount = keys.ShieldAmount
	currentHealth = caster:GetHealth()
end


function RhoOnTakeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local pid = caster:GetPlayerID() 
	local diff = 0
	local damageTaken = keys.DamageTaken
	

	rhoShieldAmount = rhoShieldAmount - damageTaken --update shield durability
	-- if shield is broken through, deal residue damage to Archer
	if rhoShieldAmount <= 0 then
		caster:RemoveModifierByName("modifier_rho_aias_shield")
		local damage = {
			attacker = attacker,
			victim = caster,
			damage = rhoShieldAmount,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = 0,
			ability = nil
		}
		ApplyDamage(damage)
	-- if not, heal Archer by the amount of damage taken
	else
		local newCurrentHealth = caster:GetHealth()
		-- if damage would have been lethal without shield, set Archer's health to health when shield was cast
		if newCurrentHealth == 0 then
			caster:SetHealth(currentHealth)
		else
			caster:SetHealth(newCurrentHealth + damageTaken)
		end
	end 
end

function OnUbwStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         -- move them inside UBW
    end
end