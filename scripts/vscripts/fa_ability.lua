function OnGKStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	FACheckCombo(keys.caster, keys.ability)
	if ply.IsQuickdrawAcquired then 
		caster:SwapAbilities("false_assassin_gate_keeper", "false_assassin_quickdraw", true, true) 
		Timers:CreateTimer(5, function() return caster:SwapAbilities("false_assassin_gate_keeper", "false_assassin_quickdraw", true, true)   end)
	end

end

function OnHeartStart(keys)
	
end

function OnIWStart(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()

	local illusion_caster = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	local dummy_passive = illusion_caster:FindAbilityByName("dummy_unit_passive")
	dummy_passive:SetLevel(1)
	local replicate = illusion_caster:FindAbilityByName("morphling_replicate")
	replicate:SetLevel(1)
	caster:SwapAbilities("rubick_empty1", "false_assassin_combo_passive", false, true) 

	for i=0,3 do
		print("is it cast?")
		illusion_caster:CastAbilityOnTarget(keys.caster, replicate, pid)
	end

	Timers:CreateTimer({
		endTime = 25.0,
		callback = function()
		caster:SwapAbilities("rubick_empty1", "false_assassin_combo_passive", true, false)
		caster:RemoveModifierByName("modifier_psuedo_omnislash") 
	end
	})
end

function TPOnAttack(keys)
	local caster = keys.caster
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local rand = RandomInt(1, #targets) 
	caster:SetAbsOrigin(targets[1]:GetAbsOrigin() + Vector(RandomFloat(-100, 100),RandomFloat(-100, 100),RandomFloat(-100, 100) ))		
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function OnQuickdrawStart(keys)
	local caster = keys.caster
	local quickdraw = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
        iMoveSpeed = 1500,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = 750,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1500
	}
	local projectile = ProjectileManager:CreateLinearProjectile(quickdraw)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.4)

	local sin = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*1500)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("quickdraw_dash", {
		endTime = 0.5,
		callback = function()
		print("dash timer")
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("qickdraw_dash")
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)

end

function OnQuickdrawHit(keys)
	DoDamage(keys.caster, keys.target, 700 + keys.caster:GetAgility() * 10, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end


function OnWBStart(keys)
	EmitGlobalSound("FA.Windblade" )
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local radius = keys.Radius
	local casterInitOrigin = caster:GetAbsOrigin() 

	if not ply.IsGanryuAcquired then
		caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_heart_of_harmony"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_tsubame_gaeshi"):StartCooldown(keys.GCD) 
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), casterInitOrigin, nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local risingwind = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	if ply.IsGanryuAcquired then
		Timers:CreateTimer(0.3, function()
			caster:SetAbsOrigin(targets[math.random(#targets)]:GetAbsOrigin())
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		return end)
	end

	for k,v in pairs(targets) do
		giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		local pushback = Physics:Unit(v)
		v:PreventDI()
		v:SetPhysicsFriction(0)
		v:SetPhysicsVelocity((v:GetAbsOrigin() - casterInitOrigin):Normalized() * 300)
		v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		v:FollowNavMesh(false)
		Timers:CreateTimer(0.5, function()  
			print("kill it")
			v:PreventDI(false)
			v:SetPhysicsVelocity(Vector(0,0,0))
			v:OnPhysicsFrame(nil)
		return end)
	end
end

function TGPlaySound(keys)
	EmitGlobalSound("FA.TGReady")
end

function OnTGStart(keys)
	local caster = keys.caster
	local target = keys.target
	EmitGlobalSound("FA.TG")
	EmitGlobalSound("FA.Chop")

	caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
	caster:FindAbilityByName("false_assassin_heart_of_harmony"):StartCooldown(keys.GCD) 
	caster:FindAbilityByName("false_assassin_tsubame_gaeshi"):StartCooldown(keys.GCD) 


	caster:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	giveUnitDataDrivenModifier(caster, caster, "tg_pause", 1.0)

	Timers:CreateTimer(0.5, function()  
		if caster:IsAlive() then
			caster:SetAbsOrigin(target:GetAbsOrigin())
			DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local tsu = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(tsu, 1, target:GetAbsOrigin())
		end
	return end)

	Timers:CreateTimer(0.7, function()  
		if caster:IsAlive() then
			caster:SetAbsOrigin(target:GetAbsOrigin())
			DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local tsu = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(tsu, 1, target:GetAbsOrigin())
		end
	return end)

	Timers:CreateTimer(0.9, function()  
		if caster:IsAlive() then
			caster:SetAbsOrigin(target:GetAbsOrigin())
			if IsSpellBlocked(keys.target) then return end -- Linken effect checker
			DoDamage(caster, target, keys.LastDamage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
			target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.5})
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local tsu = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(tsu, 1, target:GetAbsOrigin())
		end
	return end)

end


function FACheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("false_assassin_gate_keeper") then
		caster:SwapAbilities("false_assassin_heart_of_harmony", "false_assassin_illusory_wanderer", true, true) 
	end
	Timers:CreateTimer({
		endTime = 3,
		callback = function()
		caster:SwapAbilities("false_assassin_heart_of_harmony", "false_assassin_illusory_wanderer", true, true) 
	end
	})
end

function OnGanryuAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsGanryuAcquired = true
end

function OnEyeOfSerenityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsEyeOfSerenityAcquired = true
end

function OnQuickdrawAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsQuickdrawAcquired = true
end

function OnVitrificationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsVitrificationAcquired = true
end