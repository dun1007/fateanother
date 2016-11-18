function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local duration = keys.Duration
	local pid = caster:GetPlayerID()

	-- create illusion
	local illusion = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber()) 
	illusion:SetPlayerID(pid) 
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = 0, incoming_damage = 300 })
	illusion:MakeIllusion()
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_nursery_rhyme_shapeshift_clone", {})
	caster.ShapeShiftIllusion = illusion
	caster.bIsSwapUsed = false 
	caster.ShapeShiftDest = targetPoint
	caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", false, true)
	
	caster:EmitSound("Hero_Terrorblade.ConjureImage")
	-- enable sub-ability that swaps position 
end

-- check if there is a valid target around clone
function OnShapeShiftTargetLookout(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	local target = keys.target
	local targetPoint = keys.target_points[1]

	target:MoveToPosition(caster.ShapeShiftDest)
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	if targets[1] ~= nil and targets[1]:IsHero() then
		for k,v in pairs(targets) do
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        ability:ApplyDataDrivenModifier(caster, v, "modifier_nursery_rhyme_shapeshift_slow", {})
	    end
	    target:ForceKill(false)
	end
end

function OnShapeShiftEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Terrorblade.Metamorphosis", target)
	local cloneKillFx = ParticleManager:CreateParticle( "particles/generic_gameplay/illusion_killed.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( cloneKillFx, 0, target:GetAbsOrigin()+Vector(0,0,100) )
	local explosionFx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 2, target:GetAbsOrigin())
    caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", true, false)
end

function OnShapeShiftSwap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()
	if caster.bIsSwapUsed then return end

	caster:SetAbsOrigin(caster.ShapeShiftIllusion:GetAbsOrigin())
	caster.ShapeShiftIllusion:SetAbsOrigin(casterPos)
	caster.bIsSwapUsed = true
end

--[[
function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end]]