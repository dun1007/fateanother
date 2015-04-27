function OnMadnessStart(keys)
	local caster = keys.caster
	caster.MadnessStackCount = 0
	caster:RemoveModifierByName("modifier_madness_stack")
end

function OnMadnessThink(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()

	AdjustMadnessStack(caster, 1)
	if ply.IsMentalPolluted then
		AdjustMadnessStack(caster, 1)
	end
end

function AdjustMadnessStack(caster, adjustValue)
	local ply = caster:GetPlayerOwner()
	local maxMadness = 10
	if ply.IsMentalPolluted then maxMadness = 15 end
	caster.MadnessStackCount = caster.MadnessStackCount + adjustValue


	if caster.MadnessStackCount > maxMadness then
		caster.MadnessStackCount = maxMadness
	end
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

function CleanupGilleSummon(keys)
	local caster = keys.caster
	if IsValidEntity(caster.GiganticHorror) then
		caster.GiganticHorror:ForceKill(true)
	end
end

function OnThrowCorpseStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()

	if caster.MadnessStackCount == 0 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Not Enough Madness" } )
		keys.ability:EndCooldown()
		return
	end
	
	if ply.IsMentalPolluted then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(2)
	end
	AdjustMadnessStack(caster, -1)

	local corpse = CreateUnitByName("gille_corpse", targetPoint, true, nil, nil, caster:GetTeamNumber())
	corpse:EmitSound("Hero_Nevermore.Shadowraze")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, corpse)
	ParticleManager:SetParticleControl(particle, 0, corpse:GetAbsOrigin()) 
	corpse:ForceKill(true)

end

function OnSummonDemonStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	local targets = Entities:FindAllByNameWithin("npc_dota_creature", targetPoint, keys.Radius)
	if ply.IsAbyssalConnection2Acquired then
		keys.Health = keys.Health * 1.3
	end
	if #targets == 0 then
		-- print error and return
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "No Corpse at Location" } )
		keys.ability:EndCooldown()
		return
	else
		-- Get rid of unit
		local unit = 0
		for i=1, #targets do
			if not targets[i]:IsAlive() then 
				print("found dead unit")
				unit = targets[i]
				break
			end
		end
		if unit == 0 then 
			--print error and return
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "No Corpse at Location" } )
			keys.ability:EndCooldown()
			return 
		end
		unit:EmitSound("Hero_Nevermore.Shadowraze")
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, unit)
		ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin()) 
		for i=1,keys.Number do
			local tentacle = CreateUnitByName("gille_oceanic_demon", unit:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())
			if ply.IsAbyssalConnection2Acquired then
				giveUnitDataDrivenModifier(caster, tentacle, "gille_attack_speed_boost", 999.0)
			end
			tentacle:SetControllableByPlayer(caster:GetPlayerID(), true)
			tentacle:SetOwner(caster)
			tentacle:SetMaxHealth(keys.Health)
			tentacle:SetHealth(keys.Health)
			--tentacle:AddNewModifier(caster, nil, "modifier_kill", {duration = 30.0})
			FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)
		end
		unit:RemoveSelf()
	end
end

function OnDemonSuicideStart(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_kill")
	caster:AddNewModifier(caster, nil, "modifier_kill", {duration = 3.0})
end
function OnTormentStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]

	local madnessCost = math.floor(caster.MadnessStackCount / 2)
	if madnessCost ~= 0 then AdjustMadnessStack(caster, -madnessCost) end
	caster.TormentMadnessCost = madnessCost

    local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_torment", {}) 
		v:AddNewModifier(v, v, "modifier_stunned", {Duration = 0.5})
		v.AccumulatedDamage = 0
	end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, targetPoint) 
	ParticleManager:SetParticleControl(particle, 1, Vector(keys.Radius,0,0)) 
end

function OnTormentThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	DoDamage(caster, target, damage/8, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnGilleComboThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = target:GetMaxHealth()*5/100
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	print("dealing damage")
end

function OnTormentTakeDamage(keys)
	local victim = keys.unit
	damageTaken = keys.DamageTaken
	victim.AccumulatedDamage = victim.AccumulatedDamage + damageTaken
end

function OnTormentEnd(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local victim = keys.target
	local multiplier = 5
	if ply.IsBlackMagicImproved then multiplier = 10 end
	local damage = victim.AccumulatedDamage/100 * caster.TormentMadnessCost * multiplier

	DoDamage(caster, victim, damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnECStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]

	local allytargets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(allytargets) do
		if v:GetUnitName() == "gille_gigantic_horror" and caster.IsComboReady then
			OnGilleComboStart(keys)
			return
		end
	end

	local madnessCost = math.floor(caster.MadnessStackCount / 2)
	if madnessCost ~= 0 then AdjustMadnessStack(caster, -madnessCost) end
	caster.ECMadnessCost = madnessCost

	ECExplode(keys, targetPoint)

	local corpseTargets = Entities:FindAllByNameWithin("npc_dota_creature", targetPoint, keys.Radius)
	for k,v in pairs(corpseTargets) do
		if v:GetUnitName() == "gille_corpse" then
			ECExplode(keys, v:GetAbsOrigin())
			v:RemoveSelf()
		end
	end

	for k,v in pairs(allytargets) do
		if v:GetUnitName() == "gille_oceanic_demon" then
			v:AddNewModifier(caster, nil, "modifier_kill", {duration = 1.5})
			keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_exquisite_cadaver_demon", {}) 
		end
	end
end

function ECExplode(keys, origin)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()

    local targets = FindUnitsInRadius(caster:GetTeam(), origin, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		if ply.IsBlackMagicImproved then
			local damageCounter = 0
			Timers:CreateTimer(function()
				if not v:IsAlive() or damageCounter > 9 then return end
				DoDamage(caster, v, 30, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				damageCounter = damageCounter + 1
				return 0.2
			end)
		end
	end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, origin) 
	ParticleManager:SetParticleControl(particle, 1, Vector(keys.Radius,keys.Radius,keys.Radius)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(keys.Radius,keys.Radius,keys.Radius)) 

	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 1, origin) 
	ParticleManager:SetParticleControl(particle2, 2, origin) 
	ParticleManager:SetParticleControl(particle2, 3, origin) 
	ParticleManager:SetParticleControl(particle2, 4, origin) 

	caster:EmitSound("Hero_ShadowDemon.Soul_Catcher.Cast")
end

function OnECDemonExplode(keys)
	local demon = keys.target
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage/100 * 20 * caster.ECMadnessCost
	local targets = FindUnitsInRadius(caster:GetTeam(), demon:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		if ply.IsBlackMagicImproved then
			local damageCounter = 0
			Timers:CreateTimer(function()
				if not v:IsAlive() or damageCounter > 9 then return end
				DoDamage(caster, v, 30, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				damageCounter = damageCounter + 1
				return 0.2
			end)
		end
	end

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle, 1, Vector(keys.Radius,keys.Radius,keys.Radius)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(keys.Radius,keys.Radius,keys.Radius)) 

	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 1, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle2, 2, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle2, 3, demon:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle2, 4, demon:GetAbsOrigin()) 

	demon:EmitSound("Hero_ShadowDemon.Soul_Catcher.Cast")
end

function OnContractStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	if ply.IsAbyssalConnection1Acquired then
		keys.Radius = keys.Radius + 200
		keys.Damage = keys.Damage + 200
	end
	if ply.IsAbyssalConnection2Acquired then
		keys.Health = keys.Health * 1.3
	end

	if caster:HasModifier("modifier_gigantic_horror_penalty_timer") then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Summon Yet" } )
		keys.ability:EndCooldown()
		return
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
	GilleCheckCombo(caster, keys.ability)

	local madnessCost = math.floor(caster.MadnessStackCount / 2)
	if madnessCost ~= 0 then AdjustMadnessStack(caster, -madnessCost) end
	caster.ContractMadnessCost = madnessCost

    local visiondummy = CreateUnitByName("sight_dummy_unit", targetPoint, false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(1000)
    visiondummy:SetNightTimeVisionRange(1000)
    visiondummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 3.1})
   local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)
    visiondummy:EmitSound("Hero_Warlock.Upheaval")

	local contractFx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
	ParticleManager:SetParticleControl(contractFx, 0, targetPoint)
	ParticleManager:SetParticleControl(contractFx, 1, Vector(keys.Radius + 200,0,0))

	local contractFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_death_glyph.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
	ParticleManager:SetParticleControl(contractFx2, 0, targetPoint)

	contractFx4 = 0
	Timers:CreateTimer(1.0, function()
		contractFx4 = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
		ParticleManager:SetParticleControl(contractFx4, 0, targetPoint)
		ParticleManager:SetParticleControl(contractFx4, 1, Vector(keys.Radius + 200, 0, 0))
	end)
	

	Timers:CreateTimer(3.0, function()
		if caster:IsAlive() then
			if IsValidEntity(caster.GiganticHorror) and caster.GiganticHorror:IsAlive() then
				caster.GiganticHorror:SetAbsOrigin(targetPoint) 
			else
				-- Summon Gigantic Horror
				local tentacle = CreateUnitByName("gille_gigantic_horror", targetPoint, true, nil, nil, caster:GetTeamNumber())
				if ply.IsAbyssalConnection2Acquired then
					giveUnitDataDrivenModifier(caster, tentacle, "gille_attack_speed_boost", 999.0)
				end
				if ply.IsAbyssalConnection1Acquired then
					local cont = CreateItem("item_gille_contaminate" , nil, nil)
					tentacle:AddItem(cont)
					tentacle:AddItem(CreateItem("item_gille_integrate" , nil, nil))
					cont:SetLevel(keys.ability:GetLevel())
				end
				if ply.IsAbyssalConnection2Acquired then
					tentacle:AddItem(CreateItem("item_gille_otherworldly_portal" , nil, nil))
				end
				tentacle:SetControllableByPlayer(caster:GetPlayerID(), true)
				tentacle:SetOwner(caster)
				caster.GiganticHorror = tentacle
				FindClearSpaceForUnit(tentacle, tentacle:GetAbsOrigin(), true)

				local skillLevel = 1 + (caster:GetLevel() - 1)/3
				if skillLevel > 8 then skillLevel = 8 end
				-- Level abilities
				tentacle:FindAbilityByName("gille_tentacle_of_destruction"):SetLevel(skillLevel)
				tentacle:FindAbilityByName("gille_subterranean_skewer"):SetLevel(skillLevel) 
				tentacle:FindAbilityByName("gille_gigantic_horror_passive"):SetLevel(skillLevel)  

				tentacle:SetMaxHealth(keys.Health)
				tentacle:SetHealth(keys.Health)
				tentacle:SetBaseDamageMax(50 + keys.ability:GetLevel() * 50) 
				tentacle:SetBaseDamageMin(50 + keys.ability:GetLevel() * 50) 
			end
			-- Damage enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				ApplyAirborne(caster, v, caster.ContractMadnessCost/5)
			end

			local contractFx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
			ParticleManager:SetParticleControl(contractFx3, 0, targetPoint)
			ParticleManager:SetParticleControl(contractFx3, 1, Vector(keys.Radius + 500, 0, 0))
			ParticleManager:SetParticleControl(contractFx3, 2, Vector(keys.Radius + 500, 0, 0))
			EmitGlobalSound("Hero_Warlock.RainOfChaos_buildup")
			StopSoundEvent("Hero_Warlock.Upheaval", visiondummy)

			CreateRavageParticle(visiondummy, visiondummy:GetAbsOrigin(), 300)
			CreateRavageParticle(visiondummy, visiondummy:GetAbsOrigin(), 650)
			CreateRavageParticle(visiondummy, visiondummy:GetAbsOrigin(), 1000)
			visiondummy:EmitSound("Ability.Ravage")
			-- Remove particle
			ParticleManager:DestroyParticle(contractFx, false)
			ParticleManager:ReleaseParticleIndex(contractFx)
			ParticleManager:DestroyParticle(contractFx4, false)
			ParticleManager:ReleaseParticleIndex(contractFx4)
		end
	end)
end

function CreateRavageParticle(handle, center, multiplier)
	for i=1, math.floor(multiplier/60) do
		local x = math.cos(i) * multiplier
		local y = math.sin(i) * multiplier
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_CUSTOMORIGIN, handle)
		ParticleManager:SetParticleControl(tentacleFx, 0, Vector(center.x + x, center.y + y, 100))
		ParticleManager:SetParticleControl(tentacleFx, 2, Vector(center.x + x, center.y + y, 100))
	end
end

function OnHorrorTakeDamage(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local damageTaken = keys.DamageTaken
	local threshold = keys.Threshold
	local multiplier = 0.3
	if ply.IsAbyssalConnection1Acquired then
		multiplier = 0.1
	end
	if damageTaken > threshold then 
		DoDamage(keys.attacker, caster, damageTaken * multiplier, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end 
end

function OnHorrorDeath(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_gigantic_horror_penalty_timer", {}) 
end

function OnTentacleSummon(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]
	if ply.IsAbyssalConnection2Acquired then
		keys.Health = keys.Health * 1.3
	end

	for i=0,2 do
		local tentacle = CreateUnitByName("gille_tentacle_of_destruction", targetPoint, true, nil, nil, caster:GetTeamNumber())
		if ply.IsAbyssalConnection2Acquired then
			giveUnitDataDrivenModifier(caster, tentacle, "gille_attack_speed_boost", 999.0)
		end
		tentacle:SetControllableByPlayer(hero:GetPlayerID(), true)
		tentacle:SetOwner(hero)
		tentacle:SetMaxHealth(keys.Health) 
		tentacle:SetHealth(keys.Health)
		tentacle:SetBaseDamageMin(keys.Damage)
		tentacle:SetBaseDamageMax(keys.Damage)
		tentacle:FindAbilityByName("gille_tentacle_of_destruction_passive"):SetLevel(keys.ability:GetLevel())
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
	target:EmitSound("Hero_Pudge.AttackHookImpact")
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
		caster:EmitSound("Hero_Lion.Impale")
		print("generated projectile")
	end)

	local tentacleCounter1 = 0
	Timers:CreateTimer(1.0, function()
		if tentacleCounter1 > 10 then return end
		print("tentacles")
		local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(tentacleFx, 0, casterLoc + diff * 110 * tentacleCounter1)
		tentacleCounter1 = tentacleCounter1 + 1
		return 0.033
	end)
end

function OnSubSkewerHit(keys)
	local target = keys.target
	local caster = keys.caster
	print("hit something")
	ApplyAirborne(caster, target, keys.StunDuration)
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)

end

function OnContaminateStart(keys)
	local caster = keys.caster
    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_contaminate", {}) 
	end

	local tentacleFx = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(tentacleFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(tentacleFx, 1, Vector(keys.Radius+200,0,0))
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
				caster:EmitSound("ZC.Tentacle1")
				caster:EmitSound("ZC.Laugh")
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

function OnHorrorTeleport(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]
	if (targetPoint - hero:GetAbsOrigin()):Length2D() > 500 then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Locate Within 500 Range from Caster" } )
		keys.ability:EndCooldown()
		return
	else
		caster:SetAbsOrigin(targetPoint)
	end
end

function OnGilleComboStart(keys)
	local caster = keys.caster
	local tentacle = caster.GiganticHorror
	local radius = 1000

	caster:FindAbilityByName("gille_larret_de_mort"):StartCooldown(150)
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName("gille_larret_de_mort")
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(150)

	keys.ability:ApplyDataDrivenModifier(caster, tentacle, "modifier_gigantic_horror_freeze", {})
	-- Damage enemies
	local targets = FindUnitsInRadius(caster:GetTeam(), tentacle:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		ApplyAirborne(tentacle, v, 1.0)
	end
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 300)
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 650)
	CreateRavageParticle(tentacle, tentacle:GetAbsOrigin(), 1000)
	tentacle:EmitSound("Ability.Ravage")
	EmitGlobalSound("ZC.Laugh")

	local contractFx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_upheaval.vpcf", PATTACH_CUSTOMORIGIN, visiondummy)
	ParticleManager:SetParticleControl(contractFx, 0, tentacle:GetAbsOrigin())
	ParticleManager:SetParticleControl(contractFx, 1, Vector(radius + 200,0,0))

	Timers:CreateTimer(1.5, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), tentacle:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_gille_combo", {})
			v:EmitSound("hero_bloodseeker.rupture")
		end
		Timers:CreateTimer(0.5, function()
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_shockwave.vpcf", PATTACH_CUSTOMORIGIN, tentacle)
			ParticleManager:SetParticleControl(particle, 0, tentacle:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(radius+200,0,0))  
			ParticleManager:DestroyParticle(contractFx, false)
			ParticleManager:ReleaseParticleIndex(contractFx)
		end)
		
		tentacle:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
		ParticleManager:CreateParticle("particles/custom/screen_scarlet_splash.vpcf", PATTACH_EYES_FOLLOW, tentacle)
		tentacle:EmitSound("Hero_ShadowDemon.DemonicPurge.Impact")
		tentacle:ForceKill(true)
	end)

end


function GilleCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("gille_abyssal_contract") and caster:FindAbilityByName("gille_larret_de_mort"):IsCooldownReady() then
			caster.IsComboReady = true 
			print("ready to combo")
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster.IsComboReady = false
			end
			})
		end
	end
end

function OnEyeForArtAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsEyeForArtAcquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnBlackMagicImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsBlackMagicImproved = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMentalPollutionAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsMentalPolluted = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnAbyssConnectionAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsAbyssalConnection1Acquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnAbyssConnection2Acquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsAbyssalConnection2Acquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end