function OnGKStart(keys)
	FACheckCombo(keys.caster, keys.ability)
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


function OnWBStart(keys)
	EmitGlobalSound("FA.Windblade" )
	local caster = keys.caster
	local radius = keys.Radius
	local casterInitOrigin = caster:GetAbsOrigin() 

	
	
	local targets = FindUnitsInRadius(caster:GetTeam(), casterInitOrigin, nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local risingwind = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

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
end

function OnQuickdrawAcquired(keys)
end

function OnVitrificationAcquired(keys)
end