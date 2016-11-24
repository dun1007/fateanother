--vortigernCount = 0
--isLeftside = nil

function OnDerangeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	
	DSCheckCombo(keys.caster, keys.ability)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_derange", {} )

	if caster.IsManaBlastAcquired then
		--[[
			Fix a bug where user can have more than 7 charges and add VFX
		]]
		local maximum_charges = keys.ability:GetLevelSpecialValueFor( "maximum_charges", keys.ability:GetLevel() - 1 )
		
		-- Check the amount of next charge
		local next_charge = RandomInt(1, 3)

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

	caster:EmitSound("Saber_Alter.Derange")
end

function OnDerangeAttackStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, target, "modifier_armor_reduction", {} )
end

function OnDerangeDeath(keys)
	local caster = keys.caster
	caster.ManaBlastCount = 0
	caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
end

function OnDarklightProc(keys)
	DoDamage(keys.caster, keys.target, 400 , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
end

function OnUFStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	local UFCount = 0
	local bonusDamage = 0

	if caster.IsFerocityImproved then
		bonusDamage = caster:GetStrength()*1.5 + caster:GetIntellect()*1.5
	end
	DSCheckCombo(caster, keys.ability)
	Timers:CreateTimer(function()
		if UFCount == 5 or not caster:IsAlive() then return end
		caster:EmitSound("Saber_Alter.Unleashed") 
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	         DoDamage(caster, v, v:GetHealth() * keys.Damage / 100 + bonusDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	         v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
	    end
		UFCount = UFCount + 1;
		return 0.5
		end
	)

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_unleashed_ferocity_caster_VFX_controller", {} )
end

function OnUFCreateVfx(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_unleashed_ferocity_caster_VFX", {} )
end

function OnDarklightCrit(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_darklight_crit_hit", {} )
end

function OnMBStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()

	if caster.IsManaShroudImproved == true then 
		keys.Radius = keys.Radius + 200 
		keys.Damage = keys.Damage + 3*caster:GetIntellect()
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
		iMoveSpeed = 500
	}
	
	if caster.IsManaBlastAcquired and #targets ~= 0 then
		print("mana blast activated")
		-- Force remove all particles
		while caster:HasModifier( "modifier_derange_mana_catalyst_VFX" ) do
			caster:RemoveModifierByName( "modifier_derange_mana_catalyst_VFX" )
		end
		
		while caster.ManaBlastCount ~= 0 do
			print("firing mana blast!")
			info.Target = targets[math.random(#targets)]
			ProjectileManager:CreateTrackingProjectile(info) 
			caster.ManaBlastCount = caster.ManaBlastCount - 1
		end
		
		-- Update the charge
		caster:SetModifierStackCount( "modifier_derange_counter", caster, caster.ManaBlastCount )
	end

	for k,v in pairs(targets) do
	    DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
	end

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_mana_burst_VFX", {} )
end

function OnManaBlastHit(keys)
	DoDamage(keys.caster, keys.target, 150 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMMBStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_mana_burst_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	caster:FindAbilityByName("saber_alter_mana_burst"):StartCooldown(15.0)

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	EmitGlobalSound("Saber_Alter.MMB" ) 
	EmitGlobalSound("Saber_Alter.MMBAfter") 
	local BlueSplashFx = ParticleManager:CreateParticle("particles/custom/screen_blue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	ScreenShake(caster:GetOrigin(), 15, 2.0, 2, 10000, 0, true)
	-- Destroy particle
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( BlueSplashFx, false )
	end)

	local dmg = caster:GetMaxMana()
	if caster.IsManaShroudImproved == true then dmg = dmg + caster:GetIntellect()*5 end
	
	for k,v in pairs(targets) do
	    DoDamage(caster, v, dmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability)
	end

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_max_mana_burst_VFX", {} )
end

vortigernCount = 0
function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local forward = ( keys.target_points[1] - caster:GetAbsOrigin() ):Normalized() -- caster:GetForwardVector() 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.8)
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
	if caster.IsFerocityImproved then 
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
	if caster.IsFerocityImproved then 
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

function OnDexVfxControllerStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_vfx_phase_3", {})
end

function OnDexVfxPhase2Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_vfx_phase_2", {})
end


function OnDexStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 4.75)
	keys.Range = keys.Range - keys.Width -- We need this to take end radius of projectile into account
	print(keys.Range)
	EmitGlobalSound("Saber.Caliburn")
	ability:ApplyDataDrivenModifier(caster, caster, "dark_excalibur_VFX_controller", {})
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
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	Timers:CreateTimer(0.75, function() 
		EmitGlobalSound("Saber_Alter.Excalibur")
	end)

	Timers:CreateTimer(2.75, function()
		if caster:IsAlive() then
			EmitGlobalSound("Saber.Excalibur_Ready")
			dex.vSpawnOrigin = caster:GetAbsOrigin() 
			dex.vVelocity = caster:GetForwardVector() * keys.Speed
			projectile = ProjectileManager:CreateLinearProjectile(dex)
			ScreenShake(caster:GetOrigin(), 7, 2.0, 2, 10000, 0, true)
		end
	end)

	local casterFacing = caster:GetForwardVector()
	Timers:CreateTimer(2.75, function()
		if caster:IsAlive() then
			-- Create Particle for projectile
			local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
			dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
			dummy:SetForwardVector(casterFacing)
			Timers:CreateTimer( function()
					if IsValidEntity(dummy) then
						local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.03 * casterFacing
						dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
						-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.StartRadius, true, 0.15)
						return 0.03
					else
						return nil
					end
				end
			)
			
			local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber_alter/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy )

			Timers:CreateTimer( 1.60, function()
					ParticleManager:DestroyParticle( excalFxIndex, false )
					ParticleManager:ReleaseParticleIndex( excalFxIndex )
					Timers:CreateTimer( 0.5, function()
							dummy:RemoveSelf()
							return nil
						end
					)
					return nil
				end
			)
			return 
		end
	end)
end

function OnDexHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if caster.IsDarklightAcquired then keys.Damage = keys.Damage + 300 end
	if target:GetUnitName() == "gille_gigantic_horror" then keys.Damage = keys.Damage*1.3 end
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
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("saber_alter_derange") then
			DUsed = true
			DTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				DUsed = false
			end
			})
		elseif ability == caster:FindAbilityByName("saber_alter_unleashed_ferocity") and caster:FindAbilityByName("saber_alter_mana_burst"):IsCooldownReady() and caster:FindAbilityByName("saber_alter_max_mana_burst"):IsCooldownReady() then
			if DUsed == true then 
				caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", false, true)
				local newTime =  GameRules:GetGameTime()
				Timers:CreateTimer({
					endTime = 5 - (newTime - DTime),
					callback = function()
					caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", true, false)
					DUsed = false
				end
				})
			end
		end
	end
end

function OnImproveManaShroundAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	hero:FindAbilityByName("saber_alter_mana_shroud"):SetLevel(2)
	hero:SetBaseMagicalResistanceValue(25)
	hero:CalculateStatBonus()
	hero.IsManaShroudImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

-- needs particle
function OnManaBlastAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsManaBlastAcquired = true
	hero.ManaBlastCount = 0

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveFerocityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsFerocityImproved = true
	hero:FindAbilityByName("saber_alter_unleashed_ferocity"):SetLevel(2)
	hero:SwapAbilities("saber_alter_unleashed_ferocity","saber_alter_unleashed_ferocity_improved", false, true)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDarklightAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("saber_alter_darklight_passive"):SetLevel(1)
	hero.IsDarklightAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
