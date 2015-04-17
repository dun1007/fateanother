function OnMadnessStart(keys)
	local caster = keys.caster
	caster.MadnessStackCount = 0
	caster:RemoveModifierByName("modifier_madness_stack")
end

function OnMadnessThink(keys)
	local caster = keys.caster

	if caster.MadnessStackCount < 10 then
		AdjustMadnessStack(caster, 1)
	end
end

function AdjustMadnessStack(caster, adjustValue)
	caster.MadnessStackCount = caster.MadnessStackCount + adjustValue
	caster:RemoveModifierByName("modifier_madness_stack")
	caster:FindAbilityByName("gille_spellbook_of_prelati"):ApplyDataDrivenModifier(caster, caster, "modifier_madness_stack", {})
	caster:SetModifierStackCount("modifier_madness_stack", caster, caster.MadnessStackCount) 
end

function OnSelfishStart(keys)
	local caster = keys.caster
	if caster.MadnessStackCount ~= 0 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_selfish_debuff_aura", {}) 
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_selfish_self_invul", {}) 
		caster:EmitSound("Hero_Warlock.ShadowWord")
		Timers:CreateTimer(function()
			if caster.MadnessStackCount == 0 then 
				caster:StopSound("Hero_Warlock.ShadowWord")
				caster:RemoveModifierByName("modifier_selfish_debuff_aura") 
				caster:RemoveModifierByName("modifier_selfish_self_invul") 
			return end
			AdjustMadnessStack(caster,-1)
			return 0.2
		end)
	end
end

function OnThrowCorpseStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()
	local corpse = CreateUnitByName("gille_corpse", targetPoint, true, nil, nil, caster:GetTeamNumber())
	corpse:ForceKill(true)

end

function OnSummonDemonStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local targets = Entities:FindAllByNameWithin("npc_dota_creature", targetPoint, keys.Radius)
	if #targets ~= 0 then 
		-- Get rid of unit
		local unit = targets[math.random(#targets)]
		for i=0,keys.Number do
			local tentacle = CreateUnitByName("gille_oceanic_demon", unit:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())
			tentacle:SetControllableByPlayer(caster:GetPlayerID(), true)
			tentacle:SetOwner(caster)
			FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)
		end
		unit:RemoveSelf()
	end
end

function OnTormentStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
    local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_torment", {}) 
		v.AccumulatedDamage = 0
	end
end

function OnTormentThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	DoDamage(caster, target, damage/8, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnTormentTakeDamage(keys)
	local victim = keys.unit
	damageTaken = keys.DamageTaken
	victim.AccumulatedDamage = victim.AccumulatedDamage + damageTaken
end

function OnTormentEnd(keys)
	local caster = keys.caster
	local victim = keys.target
	local damage = victim.AccumulatedDamage
	DoDamage(caster, victim, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnECStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	ECExplode(keys, targetPoint)

	local corpseTargets = Entities:FindAllByNameWithin("npc_dota_creature", targetPoint, keys.Radius)
	for k,v in pairs(corpseTargets) do
		if v:GetUnitName() == "gille_corpse" then
			ECExplode(keys, v:GetAbsOrigin())
			v:RemoveSelf()
		end
	end

	local allytargets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(allytargets) do
		if v:GetUnitName() == "gille_oceanic_demon" then
			keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_exquisite_cadaver_demon", {}) 
		end
	end
end

function ECExplode(keys, origin)
	local caster = keys.caster
    local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
end

function OnECDemonExplode(keys)
	local demon = keys.target
	local caster = keys.caster
	local targets = FindUnitsInRadius(caster:GetTeam(), demon:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage/2, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
	demon:ForceKill(true)
end

function OnContractStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
	Timers:CreateTimer(3.0, function()
		if caster:IsAlive() then
			-- Summon Gigantic Horror
			local tentacle = CreateUnitByName("gille_gigantic_horror", targetPoint, true, nil, nil, caster:GetTeamNumber())
			tentacle:AddItem(CreateItem("item_gille_contaminate" , nil, nil))
			tentacle:AddItem(CreateItem("item_gille_integrate" , nil, nil))
			tentacle:SetControllableByPlayer(caster:GetPlayerID(), true)
			tentacle:SetOwner(caster)
			FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)
			tentacle:SetMaxHealth(keys.Health)
			tentacle:SetHealth(keys.Health)
			tentacle:SetBaseDamageMax(50 + keys.ability:GetLevel() * 50) 
			tentacle:SetBaseDamageMin(50 + keys.ability:GetLevel() * 50) 

			-- Damage enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end
		end
	end)
end

function ModifyTentacleHealth(keys)
	local unit = keys.target
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local newHP = unit:GetMaxHealth() + keys.HealthBonus
	local newcurrentHP = unit:GetHealth() + keys.HealthBonus

	if ply.IsBeyondTimeAcquired then 
		newHP = newHP + caster:GetMaxHealth() * 30/100
		newcurrentHP = newcurrentHP + caster:GetMaxHealth() * 30/100
	end

	unit:SetMaxHealth(newHP)
	unit:SetHealth(newcurrentHP)
end

function OnHorrorTakeDamage(keys)
	local caster = keys.caster
	local damageTaken = keys.DamageTaken
	local threshold = keys.Threshold

	if damageTaken > threshold then 
		DoDamage(keys.attacker, caster, damageTaken * 3/10, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end 
end

function OnHorrorDeath(keys)
end

function OnTentacleSummon(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]

	for i=0,2 do
		local tentacle = CreateUnitByName("gille_tentacle_of_destruction", targetPoint, true, nil, nil, caster:GetTeamNumber())
		tentacle:SetControllableByPlayer(hero:GetPlayerID(), true)
		tentacle:SetOwner(hero)
		FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)
	end
end

function OnTentacleAttackLanded(keys)
	local target = keys.target
	local damage = target:GetMaxHealth() * keys.Damage/100
	DoDamage(keys.attacker, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnTentacleHookStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
end

function OnTentacleHookHit(keys)
	local caster = keys.caster
	local target = keys.target
	if target:GetUnitName() == "gille_gigantic_horror" or caster.IsHookHit then return end
	caster.IsHookHit = true
	local diff = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 
	target:AddNewModifier(target, target, "modifier_stunned", {Duration = 0.75})
	local pullTarget = Physics:Unit(target)
	local pullVector = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * diff * 2
	target:PreventDI()
	target:SetPhysicsFriction(0)
	target:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, 2000))
	target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	target:FollowNavMesh(false)

	Timers:CreateTimer({
		endTime = 0.25,
		callback = function()
		target:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, -2000))
	end
	})

  	Timers:CreateTimer(0.5, function()
		target:PreventDI(false)
		target:SetPhysicsVelocity(Vector(0,0,0))
		target:OnPhysicsFrame(nil)

	end)
  	Timers:CreateTimer(1.0, function()
		caster.IsHookHit = false
	end)
end

function OnTentacleWrapStart(keys)
	local caster = keys.caster
	local target = keys.target
	local fxCounter = 0
	Timers:CreateTimer(function()
		if fxCounter > 2 then return end 
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit_wrap.vpcf", PATTACH_CUSTOMORIGIN, target)
		ParticleManager:SetParticleControl(tentacleFx, 0, target:GetAbsOrigin() + Vector(0,0,100))
		ParticleManager:SetParticleControl(tentacleFx, 2, target:GetAbsOrigin() + Vector(0,0,100))
		fxCounter = fxCounter + 0.5
		return 0.5
	end)
end

function OnSubSkewerStart(keys)
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local diff = (targetPoint - casterLoc):Normalized()
	local frontward = caster:GetForwardVector()
	local skewer = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 3000,
        vSpawnOrigin = casterLoc,
        fDistance = 1000,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 3000
	}
	--local projectile = ProjectileManager:CreateLinearProjectile(skewer)
	Timers:CreateTimer(1.0, function()
		local projectile = ProjectileManager:CreateLinearProjectile(skewer)
		print("generated projectile")
	end)

	local tentacleCounter1 = 0
	Timers:CreateTimer(1.0, function()
		if tentacleCounter1 > 10 then return end
		print("tentacles")
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(tentacleFx, 0, casterLoc + diff * 100 * tentacleCounter1)
		tentacleCounter1 = tentacleCounter1 + 1
		return 0.033
	end)
end

function OnSubSkewerHit(keys)
	local target = keys.target
	local caster = keys.caster
	print("hit something")
	ApplyAirborne(caster, target, 1.5)
end

function OnContaminateStart(keys)
	local caster = keys.caster
    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_contaminate", {}) 
	end
end

function OnContaminateThink(keys)
	local caster = keys.caster
	local target = keys.target
	local ult = caster:GetPlayerOwner():GetAssignedHero():FindAbilityByName("gille_abyssal_contract")
	local damage = (250 + 250 * ult:GetLevel()) / 20
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnIntegrateStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if caster.IsIntegrated then
		hero:RemoveModifierByName("modifier_integrate_gille")
		caster:RemoveModifierByName("modifier_integrate")
		caster.IsIntegrated = false
		caster.AttemptingIntegrate = false
	else
		caster.AttemptingIntegrate = true
		ExecuteOrderFromTable({ UnitIndex = caster:GetEntityIndex(), 
								OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, 
								TargetIndex = hero:GetEntityIndex(), 
								Position = hero:GetAbsOrigin(), 
								Queue = false
							}) 

		ExecuteOrderFromTable({ UnitIndex = hero:GetEntityIndex(), 
								OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, 
								TargetIndex = caster:GetEntityIndex(), 
								Position = caster:GetAbsOrigin(), 
								Queue = false
							}) 
		Timers:CreateTimer("integrate_checker", {
			endTime = 0.0,
			callback = function()
			if (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 300 and caster.AttemptingIntegrate then 
				caster.IsIntegrated = true
				caster.AttemptingIntegrate = false
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_integrate_gille", {})
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_integrate", {})  
				return 
			end
			return 0.1
		end})
	end
end

function OnIntegrateDeath(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:RemoveModifierByName("modifier_integrate_gille")
end

function OnIntegrateCanceled(keys)
	local caster = keys.caster
	if caster.AttemptingIntegrate then 
		caster.AttemptingIntegrate = false
		Timers:RemoveTimer("integrate_checker")
		print("integrate canceled")
	end
end

function IntegrateFollow(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,500))
end

function OnZCComboStart(keys)
end

function OnEyeForArtAcquired(keys)
end

function OnBlackMagicImproved(keys)
end

function OnMentalPollutionAcquired(keys)
end

function OnAbyssConnectionAcquired(keys)
end