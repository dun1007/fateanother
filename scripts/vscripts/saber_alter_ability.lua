require("physics")
require("util")

vortigernCount = 0
isLeftside = nil

function OnDerangeStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsManaBlastAcquired then
		local chance = RandomInt(1, 100) 
		if chance > 1 and chance < 34 then
			caster.ManaBlastCount = caster.ManaBlastCount + 1
		elseif chance > 34 and chance < 67 then
			caster.ManaBlastCount = caster.ManaBlastCount + 2
		elseif chance > 67 and chance < 100 then
			caster.ManaBlastCount = caster.ManaBlastCount + 3
		end
	end
	DSCheckCombo(keys.caster, keys.ability)
end

function OnDarklightProc(keys)
	DoDamage(keys.caster, keys.target, 400 , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
end
function OnUFStart(keys)
	local caster = keys.caster
	local UFCount = 0

	DSCheckCombo(caster, keys.ability)
	Timers:CreateTimer(function()
		if UFCount == 5 then return end
		local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_n_cowlofice.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	         DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    end
		UFCount = UFCount + 1;
		return 0.5
		end
	)
end

function OnMBStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()


	if ply.IsManaShroudImproved == true then keys.Radius = keys.Radius + 200 end
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_e_cowlofice.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_n_cowlofice.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	local particle = ParticleManager:CreateParticle("particles/prototype_fx/item_linkens_buff_explosion_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 400
	}

	if ply.IsManaBlastAcquired then
		while caster.ManaBlastCount ~= 0 do
			info.Target = targets[math.random(#targets)]
			ProjectileManager:CreateTrackingProjectile(info) 
		end
	end

	for k,v in pairs(targets) do
	    DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
end

function OnManaBlastHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMMBStart(keys)
	local caster = keys.caster
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local dmg = caster:GetMaxMana()
	if ply.IsManaShroudImproved == true then dmg = dmg + 200 end
	local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_e_cowlofice.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_n_cowlofice.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	local particle = ParticleManager:CreateParticle("particles/prototype_fx/item_linkens_buff_explosion_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	for k,v in pairs(targets) do
	    DoDamage(caster, v, dmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability)
	end
end

function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local casterVec = caster:GetForwardVector()
	local targetVec = Vector(0,0,0)
	local damage = keys.Damage
	if ply.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end

	local angle = 0
	EmitGlobalSound("Saber_Alter.Vortigern")

	local vortigerndmg = {
		attacker = caster,
		victim = nil,
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        targetVec = v:GetAbsOrigin() - caster:GetAbsOrigin() 
        degree = CalculateAngle(casterVec, targetVec)*180/math.pi -- degree from caster to target
        -- Starts at 120(85% damage), ends at -120(120% damage)
        if degree <= 120 and degree >= -120 then
        	local multiplier = 0.85 + (120 - degree)/(240/0.35)
        	DoDamage(caster, v, damage * multiplier , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	--print(degree .. " " .. multiplier)
        	v:AddNewModifier(caster, target, "modifier_stunned", {duration = keys.StunDuration})
        end
    end
end

function OnDexStart(keys)
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	
	EmitGlobalSound("Saber.Caliburn")
	local dex = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = nil,
        fDistance = keys.Range,
        fStartRadius = keys.Width,
        fEndRadius = keys.Width,
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
	Timers:CreateTimer(0.75, function() 
		EmitGlobalSound("Saber_Alter.Excalibur")
	end)
	Timers:CreateTimer(2.75, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Saber.Excalibur_Ready")
			dex.vSpawnOrigin = caster:GetAbsOrigin() 
			projectile = ProjectileManager:CreateLinearProjectile(dex)
			return 
		end
	end)
end

function OnDexHit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsDarklightAcquired then keys.Damage = keys.Damage + 300 end
	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

	--[[
	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
		iMoveSpeed = 10000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = keys.Radius,
		Source = caster,
		fStartRadius = 10,
        fEndRadius = 50,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0.0,
	}

	local casterAngle = QAngle(0,120,0)
	EmitGlobalSound("Saber_Alter.Vortigern")
	Timers:CreateTimer(function() 
			vortigernBeam.vVelocity = RotatePosition(Vector(0,0,0), casterAngle, caster:GetForwardVector()) * 10000
			projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 6.66;
			vortigernCount = vortigernCount + 1; 
			if vortigernCount == 36 then vortigernCount = 0 return end -- finish spell
			
			return .01 -- tick every 0.01
		end
	)
end

function OnVortigernHit(keys)
	local target = keys.target
	local caster = keys.caster
	
	if keys.target:GetContext("IsVortigernHit") ~= nil or keys.target:GetContext("IsVortigernHit") == 1 then
		print(vortigernCount .. " already hit")
	else
		local damageTable = {
			victim = keys.target,
			attacker = keys.caster,
			damage = keys.Damage * (0.85+vortigernCount*0.01),
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)	
		print("dealt "..damageTable.damage)
		
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration = keys.StunDuration})
		
		target:SetContextNum("IsVortigernHit",1.0, 1.0)
		Timers:CreateTimer(0.4, function() return VortigernThinker(target,1) end)
	end
end

function VortigernThinker(target, runCount)
	target:SetContextNum("IsVortigernHit",0,0)
	return nil
end]]

DUsed = false
DTime = GameRules:GetGameTime()
UFTime = 0
function DSCheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("saber_alter_derange") then
		DUsed = true
		DTime = GameRules:GetGameTime()
		Timers:CreateTimer({
			endTime = 4,
			callback = function()
			DUsed = false
		end
		})
	elseif ability == caster:FindAbilityByName("saber_alter_unleashed_ferocity") then
		if DUsed == true then 
			caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", false, true)
			local newTime =  GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 4 - (newTime - DTime),
				callback = function()
				caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", true, false)
				DUsed = false
			end
			})
		end
	end
end

function OnImproveManaShroundAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetPhysicalArmorBaseValue(hero:GetPhysicalArmorBaseValue() + 20) 
	hero:SetBaseMagicalResistanceValue(0.25)
	ply.IsManaShroudImproved = true
end

-- needs particle
function OnManaBlastAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsManaBlastAcquired = true
	hero.ManaBlastCount = 0
end

function OnImproveFerocityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsFerocityImproved = true
	hero:SwapAbilities("saber_alter_unleashed_ferocity","saber_alter_unleashed_ferocity_improved", false, true)
end

function OnDarklightAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsDarklightAcquired = true
end