require("physics")
require("util")

--vortigernCount = 0
--isLeftside = nil

function OnDerangeStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	
	if ply.IsManaBlastAcquired then
		--[[
			Fix a bug where user can have more than 7 charges and add VFX
		]]
		local maximum_charges = keys.ability:GetLevelSpecialValueFor( "maximum_charges", keys.ability:GetLevel() - 1 )
		
		-- Check the amount of next charge
		local chance = RandomInt( 1, 100 )
		local next_charge = 0
		if chance > 67 then
			next_charge = 3
		elseif chance > 34 then
			next_charge = 2
		elseif chance > 1 then
			next_charge = 1
		end
		
		-- Check if the charges will become over capacity
		if not caster.ManaBlastCount then caster.ManaBlastCount = 0 end	-- This might be because I was debugging it to double check nil value

		if caster.ManaBlastCount + next_charge > maximum_charges then
			if caster.ManaBlastCount == maximum_charges then
				next_charge = 0
			else
				next_charge = caster.ManaBlastCount + next_charge - maximum_charges
			end
			caster.ManaBlastCount = maximum_charges
		else
			caster.ManaBlastCount = caster.ManaBlastCount + next_charge
		end
		
		-- Adding modifiers
		for i = 1, next_charge do
			keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_derange_mana_catalyst_VFX", {} )
		end
		
		-- Update the charge
		caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
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
		caster:EmitSound("Saber_Alter.Unleashed") 
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


	if ply.IsManaShroudImproved == true then 
		keys.Radius = keys.Radius + 200 
		keys.Damage = keys.Damage + 100
	end
	caster:EmitSound("Saber_Alter.ManaBurst") 
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/items2_fx/skadi_projectile.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 400
	}
	
	if ply.IsManaBlastAcquired then
		-- Force remove all particles
		while caster:HasModifier( "modifier_derange_mana_catalyst_VFX" ) do
			caster:RemoveModifierByName( "modifier_derange_mana_catalyst_VFX" )
		end
		
		while caster.ManaBlastCount ~= 0 do
			info.Target = targets[math.random(#targets)]
			ProjectileManager:CreateTrackingProjectile(info) 
			caster.ManaBlastCount = caster.ManaBlastCount - 1
		end
		
		-- Update the charge
		caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
	end

	for k,v in pairs(targets) do
	    DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
end

function OnManaBlastHit(keys)
	DoDamage(keys.caster, keys.target, 150 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMMBStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	EmitGlobalSound("Saber_Alter.MMB" ) 
	EmitGlobalSound("Saber_Alter.MMBAfter") 
	ParticleManager:CreateParticle("particles/custom/screen_blue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

	local dmg = caster:GetMaxMana()
	if ply.IsManaShroudImproved == true then dmg = dmg + 200 end
	
	for k,v in pairs(targets) do
	    DoDamage(caster, v, dmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability)
	end
end

vortigernCount = 0
function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage
	local forward = ( keys.target_points[1] - caster:GetAbsOrigin() ):Normalized() -- caster:GetForwardVector() 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.4)
	if ply.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end
	EmitGlobalSound("Saber_Alter.Vortigern")

	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		iMoveSpeed = 3000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = 600,
		Source = caster,
		fStartRadius = 75,
        fEndRadius = 250,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0,
	}

	
	--[[local casterAngle = QAngle(0, 120 ,0)
	Timers:CreateTimer(function() 
			if vortigernCount == 10 then vortigernCount = 0 return end -- finish spell
			vortigernBeam.vVelocity = RotatePosition(caster:GetAbsOrigin(), casterAngle, forward * 3000) 
			local projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 24;
			print(casterAngle.y)
			vortigernCount = vortigernCount + 1; 
			
			return 0.040 
		end
	)]]
	
	-- Base variables
	local angle = 120
	local increment_factor = 30
	local origin = caster:GetAbsOrigin()
	local destination = origin + forward
	Timers:CreateTimer( function()
			-- Finish spell, need to include the last angle as well
			-- Note that the projectile limit is currently at 9, to increment this, need to create either dummy or thinker to store them
			if vortigernCount == 9 then vortigernCount = 0 return end
			
			-- Start rotating
			local theta = ( angle - vortigernCount * increment_factor ) * math.pi / 180
			local px = math.cos( theta ) * ( destination.x - origin.x ) - math.sin( theta ) * ( destination.y - origin.y ) + origin.x
			local py = math.sin( theta ) * ( destination.x - origin.x ) + math.cos( theta ) * ( destination.y - origin.y ) + origin.y
			local new_forward = ( Vector( px, py, origin.z ) - origin ):Normalized()
			vortigernBeam.vVelocity = new_forward * 3000
			vortigernBeam.fExpireTime = GameRules:GetGameTime() + 0.4
			
			-- Fire the projectile
			local projectile = ProjectileManager:CreateLinearProjectile( vortigernBeam )
			vortigernCount = vortigernCount + 1
			
			-- Create particles
			local fxIndex1 = ParticleManager:CreateParticle( "particles/custom/saber_alter/saber_alter_vortigern_line.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex1, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex1, 1, vortigernBeam.vVelocity )
			ParticleManager:SetParticleControl( fxIndex1, 2, Vector( 0.2, 0.2, 0.2 ) )
			
			Timers:CreateTimer( 0.2, function()
					ParticleManager:DestroyParticle( fxIndex1, false )
					ParticleManager:ReleaseParticleIndex( fxIndex1 )
					return nil
				end
			)
			
			return 0.04
		end
	)
end

function OnVortigernHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage
	print("Vortigern hit")
	damage = damage * (85 + vortigernCount * 5)/100
	if ply.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end
	if target.IsVortigernHit ~= true then
		target.IsVortigernHit = true
		Timers:CreateTimer(0.36, function() target.IsVortigernHit = false return end)
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		target:AddNewModifier(caster, caster, "modifier_stunned", {Duration = keys.StunDuration})
	end

end

--[[ function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local casterVec = caster:GetForwardVector()
	local targetVec = Vector(0,0,0)
	local damage = keys.Damage
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.4)
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
end]]

function OnDexStart(keys)
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 4.75)
	EmitGlobalSound("Saber.Caliburn")
	local dex = 
	{
		Ability = keys.ability,
        EffectName = "",
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
			
			-- Create Particle for projectile
			local excalFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_alter/saber_alter_excalibur_beam_charge.vpcf", PATTACH_ABSORIGIN, caster )
			ParticleManager:SetParticleControl( excalFxIndex, 1, Vector( keys.Width, keys.Width, keys.Width ) )
			ParticleManager:SetParticleControl( excalFxIndex, 2, caster:GetForwardVector() * keys.Speed )
			ParticleManager:SetParticleControl( excalFxIndex, 6, Vector( 2.5, 0, 0 ) )
				
			Timers:CreateTimer( 2.5, function()
					ParticleManager:DestroyParticle( excalFxIndex, false )
					ParticleManager:ReleaseParticleIndex( excalFxIndex )
				end
			)
			
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
	print("mana shroud acquired" .. hero:GetPhysicalArmorBaseValue())
	hero:SetPhysicalArmorBaseValue(hero:GetPhysicalArmorBaseValue() + 20) 
	hero:SetBaseMagicalResistanceValue(25)
	hero:CalculateStatBonus()
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
	hero:FindAbilityByName("saber_alter_darklight_passive"):SetLevel(1)
	ply.IsDarklightAcquired = true

end