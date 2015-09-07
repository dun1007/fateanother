require("Physics")
require("util")

enkiduTarget = nil

function OnBarrageStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local dot = keys.Damage

	local rainCount = 0
	caster:EmitSound("Archer.UBWAmbient")
    Timers:CreateTimer(function()
		if rainCount == 15 then return end
	
		-- Create sword particles
		-- Main variables
		local delay = 0.5				-- Delay before damage
		local speed = 3000				-- Movespeed of the sword
			
		-- Side variables
		local distance = delay * speed
		local height = distance * math.tan( 60 / 180 * math.pi )
		local spawn_location = targetPoint - ( distance * caster:GetForwardVector() )
		spawn_location = spawn_location + Vector( 0, 0, height )
		local target_location = targetPoint
		local newForwardVec = ( target_location - spawn_location ):Normalized()
		target_location = target_location + 100 * newForwardVec
			
		local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_sword_barrage_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( swordFxIndex, 0, spawn_location )
		ParticleManager:SetParticleControl( swordFxIndex, 1, newForwardVec * speed )
		
		-- Delay
		Timers:CreateTimer( delay, function()
				-- Destroy particles
				ParticleManager:DestroyParticle( swordFxIndex, false )
				ParticleManager:ReleaseParticleIndex( swordFxIndex )
    	
				-- Damage
				local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				for k,v in pairs(targets) do
					DoDamage(caster, v, dot, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				end
				
				-- Particles on impact
				local explosionFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( explosionFxIndex, 0, targetPoint )

				local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( impactFxIndex, 0, targetPoint )
				ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(keys.Radius,keys.Radius,keys.Radius) )
					
				-- Destroy Particle
				Timers:CreateTimer( 0.5, function()
						ParticleManager:DestroyParticle( explosionFxIndex, false )
						ParticleManager:DestroyParticle( impactFxIndex, false )
						ParticleManager:ReleaseParticleIndex( explosionFxIndex )
						ParticleManager:ReleaseParticleIndex( impactFxIndex )
					end
				)
			end
		)
		rainCount = rainCount + 1
      	return 0.15
    end
    )
end

function OnGoldenRuleThink(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
    if caster:IsAlive() and GameRules:GetGameTime() > 75 then keys.caster:ModifyGold(keys.GoldGain, true, 0) end
end


function OnChainStart(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target
	local targetloc = target:GetAbsOrigin()
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_enkidu_hold", {})
	caster:EmitSound("Gilgamesh.Enkidu" ) 
	enkiduTarget = target
	
	-- Check if caster already had particle
	if caster.enkiduBind ~= nil then
		ParticleManager:DestroyParticle( caster.enkiduBind, true )
		ParticleManager:ReleaseParticleIndex( caster.enkiduBind )
	end

	caster.enkiduBind = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_enkidu.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt( caster.enkiduBind, 0, target, PATTACH_POINT_FOLLOW, "attach_origin", targetloc, true )
	ParticleManager:SetParticleControl( caster.enkiduBind, 1, targetloc )

	if caster.IsRainAcquired then
		local rainCount = 0
	    Timers:CreateTimer(function()
	    	if rainCount == 15 then return end
	       	local targets = FindUnitsInRadius(caster:GetTeam(), targetloc, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	        for k,v in pairs(targets) do
	        	DoDamage(caster, v, 25, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end
			-- Create sword particles
			-- Main variables
			local delay = 0.5				-- Delay before damage
			local speed = 3000				-- Movespeed of the sword
				
			-- Side variables
			local distance = delay * speed
			local height = distance * math.tan( 60 / 180 * math.pi )
			local spawn_location = targetloc - ( distance * caster:GetForwardVector() )
			spawn_location = spawn_location + Vector( 0, 0, height )
			local target_location = targetloc
			local newForwardVec = ( target_location - spawn_location ):Normalized()
			target_location = target_location + 100 * newForwardVec
				
			local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_sword_barrage_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( swordFxIndex, 0, spawn_location )
			ParticleManager:SetParticleControl( swordFxIndex, 1, newForwardVec * speed )
			
			-- Delay
			Timers:CreateTimer( delay, function()
					-- Destroy particles
					ParticleManager:DestroyParticle( swordFxIndex, false )
					ParticleManager:ReleaseParticleIndex( swordFxIndex )
	    	
					
					-- Particles on impact
					local explosionFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
					ParticleManager:SetParticleControl( explosionFxIndex, 0, targetloc )
						
					local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
					ParticleManager:SetParticleControl( impactFxIndex, 0, targetloc )
					ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(500,500,500) )
						
					-- Destroy Particle
					Timers:CreateTimer( 0.5, function()
							ParticleManager:DestroyParticle( explosionFxIndex, false )
							ParticleManager:DestroyParticle( impactFxIndex, false )
							ParticleManager:ReleaseParticleIndex( explosionFxIndex )
							ParticleManager:ReleaseParticleIndex( impactFxIndex )
						end
					)
				end
			)
			rainCount = rainCount + 1
	      	return 0.15
	    end
	    )
	end

	print(caster.IsGOBUp)
	if caster.IsGOBUp and caster.IsSumerAcquired then 
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

function OnChainThink(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(caster, target, target:GetHealth() * keys.Damage/100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnChainBroken(keys)
	local caster = keys.caster
	if enkiduTarget ~= nil then enkiduTarget:RemoveModifierByName("modifier_enkidu_hold") end
	ParticleManager:DestroyParticle( caster.enkiduBind, true )
	ParticleManager:ReleaseParticleIndex( caster.enkiduBind )
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
		iMoveSpeed = 1000
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
	caster:EmitSound("Saber_Alter.Derange")
	caster:EmitSound("Gilgamesh.GOB" ) 
	caster:EmitSound("Archer.UBWAmbient")
	
	-- Create particle
	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin() - 250 * frontward, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:SetForwardVector( caster:GetForwardVector() )
	
	local portalFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_gob.vpcf", PATTACH_CUSTOMORIGIN, dummy )
	ParticleManager:SetParticleControlEnt( portalFxIndex, 0, dummy, PATTACH_CUSTOMORIGIN, "attach_origin", dummy:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( portalFxIndex, 1, Vector( 400, 400, 400 ) )
	
	Timers:CreateTimer( duration, function()
			ParticleManager:DestroyParticle( portalFxIndex, false )
			ParticleManager:ReleaseParticleIndex( portalFxIndex )
			dummy:RemoveSelf()
			return nil
		end
	)
	
	local gobWeapon = 
	{
		Ability = keys.ability,
        EffectName = "particles/custom/gilgamesh/gilgamesh_gob_model.vpcf",
        iMoveSpeed = 1300,
        vSpawnOrigin = casterloc - 150 * frontward,
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
	local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_ABSORIGIN, keys.target)
	ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin())
	-- Destroy particle after delay
	Timers:CreateTimer( 1.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)
	keys.target:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
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
	local ply = caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 5.0)
	-- Create casting particle
	local chargeFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_enuma_elish_charge_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	local enuma = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = keys.Range - keys.EndRadius, -- We need this to take end radius of projectile into account
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
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	if caster.IsEnumaImproved then 
		enuma.fEndRadius = enuma.fEndRadius * 1.5
		enuma.fDistance = enuma.fDistance + 150
	end

	Timers:CreateTimer(2.0, function() 
		if caster:IsAlive() then

			EmitGlobalSound("Gilgamesh.Enuma" ) 
		end
		return
	end)

	Timers:CreateTimer(3.0, function() 
		if caster:IsAlive() then
			enuma.vSpawnOrigin = caster:GetAbsOrigin() 
			enuma.vVelocity = caster:GetForwardVector() * keys.Speed
			projectile = ProjectileManager:CreateLinearProjectile(enuma)
			ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 10000, 0, true)
			-- Destroy particle
			ParticleManager:DestroyParticle( chargeFxIndex, false )
			ParticleManager:ReleaseParticleIndex( chargeFxIndex )
		end
	end)

	for i=0,1 do
		Timers:CreateTimer(3.0, function() 
			if caster:IsAlive() then
				-- Create particle
				local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, i)
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				Timers:CreateTimer( function()
						if dummy then
							local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.03 * caster:GetForwardVector()
							dummy:SetAbsOrigin( newLoc )
							return 0.03
						else
							return nil
						end
					end
				)
				
				local tornadoFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/enuma_elish.vpcf", PATTACH_CUSTOMORIGIN, dummy )
				ParticleManager:SetParticleControl( tornadoFxIndex, 0, dummy:GetAbsOrigin() )
				ParticleManager:SetParticleControl( tornadoFxIndex, 1, caster:GetForwardVector() * keys.Speed )
				ParticleManager:SetParticleControl( tornadoFxIndex, 2, Vector( keys.EndRadius+100, 0, 0 ) )
				ParticleManager:SetParticleControl( tornadoFxIndex, 3, Vector( keys.Range / keys.Speed, 0, 0 ) )
				
				Timers:CreateTimer( 6.0, function()
						ParticleManager:DestroyParticle( tornadoFxIndex, false )
						ParticleManager:ReleaseParticleIndex( tornadoFxIndex )
						Timers:CreateTimer( 0.5, function()
								dummy:RemoveSelf()
								return nil
							end
						)
						return nil
					end
				)		
			end
			return
		end)
	end
end

function OnEnumaHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMaxEnumaStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster:FindAbilityByName("gilgamesh_enuma_elish"):StartCooldown(47)
	local targetPoint = keys.target_points[1]
	local casterloc = caster:GetAbsOrigin()
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 6.0)
	
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	-- Create charge particle
	local chargeFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/gilgamesh_enuma_elish_charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	
	local enuma = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = nil,
        fDistance = keys.Range - keys.EndRadius, -- We need this to take end radius of projectile into account
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
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	if caster.IsEnumaImproved then 
		enuma.fEndRadius = enuma.fEndRadius * 1.5
	end

	Timers:CreateTimer(2.75, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Gilgamesh.Enuma" ) 
		end
		return
	end)
	Timers:CreateTimer(3.75, function()
		if caster:IsAlive() then
			enuma.vSpawnOrigin = caster:GetAbsOrigin() 
			enuma.vVelocity = caster:GetForwardVector() * keys.Speed
			projectile = ProjectileManager:CreateLinearProjectile(enuma)
			ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 10000, 0, true)
			ParticleManager:CreateParticle("particles/custom/screen_scarlet_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
			-- Destroy particle
			ParticleManager:DestroyParticle( chargeFxIndex, false )
			ParticleManager:ReleaseParticleIndex( chargeFxIndex )
		end
	end)
	for i=0,1 do
		Timers:CreateTimer(3.75, function()
			if caster:IsAlive() then
				-- Create particle
				local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, i)
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				Timers:CreateTimer( function()
						if dummy then
							local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.03 * caster:GetForwardVector()
							dummy:SetAbsOrigin( newLoc )
							return 0.03
						else
							return nil
						end
					end
				)
				
				local tornadoFxIndex = ParticleManager:CreateParticle( "particles/custom/gilgamesh/enuma_elish.vpcf", PATTACH_CUSTOMORIGIN, dummy )
				ParticleManager:SetParticleControl( tornadoFxIndex, 0, dummy:GetAbsOrigin() )
				ParticleManager:SetParticleControl( tornadoFxIndex, 1, caster:GetForwardVector() * keys.Speed )
				ParticleManager:SetParticleControl( tornadoFxIndex, 2, Vector( keys.EndRadius, 0, 0 ) )
				ParticleManager:SetParticleControl( tornadoFxIndex, 3, Vector( keys.Range / keys.Speed, 0, 0 ) )
				
				Timers:CreateTimer( 6.0, function()
						ParticleManager:DestroyParticle( tornadoFxIndex, false )
						ParticleManager:ReleaseParticleIndex( tornadoFxIndex )
						Timers:CreateTimer( 0.5, function()
								dummy:RemoveSelf()
								return nil
							end
						)
						return nil
					end
				)
			end
			return
		end)
	end
end

function OnMaxEnumaHit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if caster.IsEnumaImproved then
		keys.Damage = keys.Damage * 2
	end
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function GilgaCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("gilgamesh_gate_of_babylon") and caster:FindAbilityByName("gilgamesh_enuma_elish"):IsCooldownReady() and caster:FindAbilityByName("gilgamesh_max_enuma_elish"):IsCooldownReady() then
			caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_max_enuma_elish", true, true) 
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster:SwapAbilities("gilgamesh_enuma_elish", "gilgamesh_max_enuma_elish", true, true) 
			end
			})			
		end
	end
end

function OnImproveGoldenRuleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsGoldenRuleImproved = true
	hero:FindAbilityByName("gilgamesh_golden_rule"):SetLevel(2)
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPowerOfSumerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsSumerAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnRainOfSwordsAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsRainAcquired = true
	hero:SwapAbilities("gilgamesh_sword_barrage","gilgamesh_sword_barrage_improved", true, true)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSwordOfCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsEnumaImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end