avalonCooldown = true -- UP if true, 
vectorA = Vector(0,0,0)
combo_available = false
currentHealth = 0

function OnInstinctStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_instinct_active", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_instinct_cooldown", {})
	keys.caster:AddNewModifier(keys.caster, nil, "modifier_item_sphere_target", {Duration = 1.0}) -- Just the particles
end

function OnInstinctCrit(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_instinct_crit_hit", {})
end

function CreateWind(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local movespeed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	
	local particleName = "particles/custom/saber/saber_invisible_air_trail.vpcf"
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 3, caster:GetAbsOrigin() )
	
	caster.invisible_air_reach_target = false
	caster.invisible_air_pos = caster:GetAbsOrigin()
	
	local invisAirCounter = 0
	Timers:CreateTimer( function() 
			-- If over 3 seconds
			if invisAirCounter > 3.0 then
				ParticleManager:DestroyParticle( fxIndex, false )
				ParticleManager:ReleaseParticleIndex( fxIndex )
				return
			end
				
			local forwardVec = ( target:GetAbsOrigin() - caster.invisible_air_pos ):Normalized()
				
			caster.invisible_air_pos = caster.invisible_air_pos + forwardVec * movespeed * 0.05
				
			ParticleManager:SetParticleControl( fxIndex, 3, caster.invisible_air_pos )
			
			-- Reach first
			if caster.invisible_air_reach_target then
				ParticleManager:DestroyParticle( fxIndex, false )
				ParticleManager:ReleaseParticleIndex( fxIndex )
				return nil
			else
				invisAirCounter = invisAirCounter + 0.05
				return 0.05
			end
		end
	)
end

function InvisibleAirPull(keys)
	local target = keys.target
	if IsSpellBlocked(target) -- Linken's
		or target:IsMagicImmune() -- Magic immunity
		or target:GetName() == "npc_dota_hero_bounty_hunter" and target.IsPFWAcquired -- Protection from Wind
	then
		return
	end

	keys.caster.invisible_air_reach_target = true					-- Addition
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()

	giveUnitDataDrivenModifier(caster, target, "drag_pause", 1.0)
	target:RemoveModifierByName("modifier_invisible_air_target")
	ability:ApplyDataDrivenModifier(caster, target, "modifier_invisible_air_target", {})


	if target:GetName() == "npc_dota_hero_juggernaut" then keys.Damage = 0 end
	DoDamage(caster, target , keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	if caster.bIsUpstreamAcquired then
		caster:FindAbilityByName("saber_strike_air_upstream"):ApplyDataDrivenModifier(caster, caster, "modifier_strike_air_upstream_ready", {})
	end

	-- physics stuffs
    local pullTarget = Physics:Unit(keys.target)
    local dist = (keys.caster:GetAbsOrigin() - keys.target:GetAbsOrigin()):Length2D() 
    target:PreventDI()
    target:SetPhysicsFriction(0)
    target:SetPhysicsVelocity((keys.caster:GetAbsOrigin() - keys.target:GetAbsOrigin()):Normalized() * dist * 2)
    target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    target:FollowNavMesh(false)

  	Timers:CreateTimer('invispull', {
		endTime = 1.0,
		callback = function()
		target:PreventDI(false)
		target:SetPhysicsVelocity(Vector(0,0,0))
		target:OnPhysicsFrame(nil)
	end
	})

	target:OnPhysicsFrame(function(unit)
	  local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
	  local dir = diff:Normalized()
	  unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
	  if diff:Length() < 100 then
	  	target:RemoveModifierByName("drag_pause")
		target:RemoveModifierByName( "modifier_invisible_air_target" )		-- Addition
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		unit:OnPhysicsFrame(nil)
        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	  end
	end)
end



--[[
	Author: kritth
	Date: 10.01.2015.
	Create yellowish explosion upon hitting unit
]]
function CaliburnExplode( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local slashParticleName = "particles/custom/saber/caliburn/slash.vpcf"
	local explodeParticleName = "particles/custom/saber/caliburn/explosion.vpcf"


	-- Create particle
	local slashFxIndex = ParticleManager:CreateParticle( slashParticleName, PATTACH_ABSORIGIN, target )
	local explodeFxIndex = ParticleManager:CreateParticle( explodeParticleName, PATTACH_ABSORIGIN, target )
	
	Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( slashFxIndex, false )
			ParticleManager:DestroyParticle( explodeFxIndex, false )
			return nil
		end
	)
end

function OnCaliburnHit(keys) 
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()



	if not IsImmuneToSlow(target) then ability:ApplyDataDrivenModifier(caster, target, "modifier_caliburn_slow", {}) end
	local aoedmg = keys.Damage * keys.AoEDamage
	DoDamage(caster, target , keys.Damage - aoedmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	giveUnitDataDrivenModifier(caster, target, "modifier_stunned", 0.2)

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v , aoedmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())

    caster:EmitSound("Saber.Caliburn")

end

function OnExcaliburVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_3", {})
end

function OnExcaliburSwordVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(1.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_2", {})
	end)
end

function OnExcaliburStart(keys)
	EmitGlobalSound("Saber.Excalibur_Ready")
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	keys.Range = keys.Range - keys.EndRadius -- We need this to take end radius of projectile into account
	
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 4.0)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_excalibur", {})
	ability:ApplyDataDrivenModifier(caster, caster, "saber_anim_vfx", {})
	local excal = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = casterloc,
        fDistance = keys.Range,
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
	Timers:CreateTimer(0.5, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Saber.Excalibur") return 
		end
	end)

	-- Create linear projectile
	Timers:CreateTimer(keys.Delay - 0.3, function()
		if caster:IsAlive() then
			excal.vSpawnOrigin = caster:GetAbsOrigin() 
			excal.vVelocity = caster:GetForwardVector() * keys.Speed
			local projectile = ProjectileManager:CreateLinearProjectile(excal)
			ScreenShake(caster:GetOrigin(), 5, 0.1, 2, 20000, 0, true)
		end
	end)
	
	local casterFacing = caster:GetForwardVector()
	-- for i=0,1 do
		Timers:CreateTimer(keys.Delay - 0.3, function() -- Adjust 2.5 to 3.2 to match the sound
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
				
				local excalFxIndex = ParticleManager:CreateParticle( "particles/custom/saber/excalibur/shockwave.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy )
				ParticleManager:SetParticleControl(excalFxIndex, 4, Vector(keys.StartRadius,0,0))

				Timers:CreateTimer( 1.85, function()
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
	-- end
end

function OnExcaliburHit(keys)
	local caster = keys.caster
	local target = keys.target 
	local ply = caster:GetPlayerOwner()
	if caster.IsExcaliburAcquired == true then keys.Damage = keys.Damage + 300 end
	if target:GetUnitName() == "gille_gigantic_horror" then keys.Damage = keys.Damage*1.3 end
	
	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMaxVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_1", {})
	ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_3", {})
end

function OnMaxSwordVfxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(1.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "excalibur_vfx_phase_2", {})
	end)
end

function OnMaxStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	keys.Range = keys.Range - keys.Width -- We need this to take end radius of projectile into account

	caster:FindAbilityByName("saber_excalibur"):StartCooldown(37.0)
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 5.0)
	ability:ApplyDataDrivenModifier(caster, caster, "saber_max_excalibur_anim_vfx", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_excalibur", {})
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_max_excalibur_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	
	local max_excal = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = keys.Range,
        fStartRadius = keys.Width,
        fEndRadius = keys.Width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 6.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * keys.Speed
	}
	
	EmitGlobalSound("Saber.Excalibur_Ready")
	Timers:CreateTimer({
		endTime = 1.5, 
		callback = function()
	    EmitGlobalSound("Saber.Excalibur")
	end})

	-- Charge particles
	ParticleManager:CreateParticle("particles/custom/saber/max_excalibur/charge.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	
	-- Create linear projectile
	Timers:CreateTimer(3.0, function()
		if caster:IsAlive() then
			max_excal.vSpawnOrigin = caster:GetAbsOrigin() 
			max_excal.vVelocity = caster:GetForwardVector() * keys.Speed
			local projectile = ProjectileManager:CreateLinearProjectile(max_excal)
			local YellowScreenFx = ParticleManager:CreateParticle("particles/custom/screen_yellow_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
			ScreenShake(caster:GetOrigin(), 7, 2.0, 2, 10000, 0, true)
			
        	Timers:CreateTimer( 3.0, function()
				ParticleManager:DestroyParticle( YellowScreenFx, false )
			end)
		end
	end)

	local casterFacing = caster:GetForwardVector()
	-- for i=0,1 do
		Timers:CreateTimer({
			endTime = 3, 
			callback = function()
			if caster:IsAlive() then
			-- Create Particle for projectile
				local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
				dummy:SetForwardVector(casterFacing)
				Timers:CreateTimer( function()
						if IsValidEntity(dummy) then
							local newLoc = dummy:GetAbsOrigin() + keys.Speed * 0.03 * casterFacing
							dummy:SetAbsOrigin(GetGroundPosition(newLoc,dummy))
							-- DebugDrawCircle(newLoc, Vector(255,0,0), 0.5, keys.Width, true, 0.15)
							return 0.03
						else
							return nil
						end
					end
				)
				
				local excalFxIndex = ParticleManager:CreateParticle("particles/custom/saber/max_excalibur/shockwave.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
					
				Timers:CreateTimer( 2.00, function()
					ParticleManager:DestroyParticle( excalFxIndex, false )
					ParticleManager:ReleaseParticleIndex( excalFxIndex )
					Timers:CreateTimer( 0.5, function()
							dummy:RemoveSelf()
							return nil
						end
					)
					return nil
				end)
			end
		end})
	-- end
end

function OnMaxHit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if caster.IsExcaliburAcquired == true then keys.Damage = keys.Damage + 2000 end

	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnAvalonStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_avalon")

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_avalon", {})
	currentHealth = keys.caster:GetHealth()

	caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
	EmitGlobalSound("Saber.Avalon")
	EmitGlobalSound("Saber.Avalon_Shout")
	SaberCheckCombo(keys.caster, keys.ability)
end

function AvalonOnTakeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local pid = caster:GetPlayerID() 
	local diff = 0
	local damageTaken = keys.DamageTaken
	local newCurrentHealth = caster:GetHealth()
	local emitwhichsound = RandomInt(1, 2)


	if not caster:HasModifier("pause_sealdisabled") and not caster:HasModifier("modifier_max_excalibur") and caster.IsAvalonProc == true and caster.IsAvalonOnCooldown ~= true and (caster:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D() < 3000 then 
		if emitwhichsound == 1 then attacker:EmitSound("Saber.Avalon_Counter1") else attacker:EmitSound("Saber.Avalon_Counter2") end
		AvalonDash(caster, attacker, keys.Damage, keys.ability)
		caster.IsAvalonOnCooldown = true
		Timers:CreateTimer({
			endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			callback = function()
		    caster.IsAvalonOnCooldown = false
		    end
		})
	end 
	--[[if (damageTaken > keys.Threshold) then
		if avalonCooldown and not caster:HasModifier("pause_sealdisabled") then
			if emitwhichsound == 1 then attacker:EmitSound("Saber.Avalon_Counter1") else attacker:EmitSound("Saber.Avalon_Counter2") end
			
			AvalonDash(caster, attacker, keys.Damage, keys.ability)
			-- dash attack 3 seconds cooldown
			avalonCooldown = false
			Timers:CreateTimer({
				endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
			    avalonCooldown = true
			    end
			})
		end
	end
	-- if damage would have been lethal without Avalon, set Saber's health to health when Avalon was cast
	if newCurrentHealth == 0 then
		caster:SetHealth(currentHealth)
	else
		caster:SetHealth(newCurrentHealth + damageTaken)
	end]]
end -- function end

function AvalonDash(caster, attacker, counterdamage, ability)
	local targetPoint = attacker:GetAbsOrigin()
	local casterDash = Physics:Unit(caster)
	local distance = targetPoint - caster:GetAbsOrigin()

	if caster.bIsUpstreamAcquired then
		caster:FindAbilityByName("saber_strike_air_upstream"):ApplyDataDrivenModifier(caster, caster, "modifier_strike_air_upstream_ready", {})
	end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.6)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(distance:Normalized() * distance:Length2D()*2)
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(true)
	caster:SetAutoUnstuck(false)
	
	Timers:CreateTimer({
		endTime = 0.5,
		callback = function()

	    --stop the dash
	    caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

		-- Original function
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 300
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			DoDamage(caster, v, counterdamage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
	    end


		-- Particles
		--local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_avalon_impact.vpcf", PATTACH_ABSORIGIN, caster )
		local explosionFxIndex = ParticleManager:CreateParticle( "particles/custom/saber_avalon_explosion.vpcf", PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControl( explosionFxIndex, 3, caster:GetAbsOrigin() )
		EmitSoundOn( "Hero_EarthShaker.Fissure", caster )

		
		Timers:CreateTimer( 3.0, function()
				--ParticleManager:DestroyParticle( impactFxIndex, false )
				ParticleManager:DestroyParticle( explosionFxIndex, false )
			end
		)
		
	end
	})
end

function OnStrikeAirStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 1.75)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_strike_air_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	local strikeair = 
	{
		Ability = keys.ability,
        EffectName = "particles/custom/saber_strike_air_blast.vpcf",
        iMoveSpeed = 5000,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 1200,
        fStartRadius = 400,
        fEndRadius = 400,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 6.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 5000
	}

	Timers:CreateTimer(1.5, function()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_strike_air_animation", {})
	end)
	
	Timers:CreateTimer({
		endTime = 1.75, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
		if caster:IsAlive() then 
			strikeair.vSpawnOrigin = caster:GetAbsOrigin() 
			strikeair.vVelocity = caster:GetForwardVector() * 5000
			projectile = ProjectileManager:CreateLinearProjectile(strikeair)
		end
	end})

	EmitGlobalSound("Saber.StrikeAir_Cast")
	caster:EmitSound("Hero_Invoker.Tornado")
	ability:ApplyDataDrivenModifier(caster, caster, "saber_strike_air_anim_vfx", {})
	Timers:CreateTimer(1.75, function()  
		local sound = RandomInt(1,2)
		if sound == 1 then EmitGlobalSound("Saber.StrikeAir_Release1") else EmitGlobalSound("Saber.StrikeAir_Release2") end
	return end)

end

function StrikeAirPush(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if (target:GetName() == "npc_dota_hero_bounty_hunter" and target.IsPFWAcquired) then return end
	local totalDamage = 650 + (keys.caster:FindAbilityByName("saber_caliburn"):GetLevel() + keys.caster:FindAbilityByName("saber_invisible_air"):GetLevel()) * 125
	if target:GetName() == "npc_dota_hero_juggernaut" then totalDamage = 0 end

	DoDamage(keys.caster, keys.target, totalDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	giveUnitDataDrivenModifier(keys.caster, keys.target, "pause_sealenabled", 0.5)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_strike_air_target_VFX", {})

    local pushTarget = Physics:Unit(keys.target)
    keys.target:PreventDI()
    keys.target:SetPhysicsFriction(0)
	local vectorC = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()) 
	-- get the direction where target will be pushed back to
	local vectorB = vectorC - vectorA
	keys.target:SetPhysicsVelocity(vectorB:Normalized() * 1000)
    keys.target:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	local initialUnitOrigin = keys.target:GetAbsOrigin()
	
	keys.target:OnPhysicsFrame(function(unit) -- pushback distance check
		local unitOrigin = unit:GetAbsOrigin()
		local diff = unitOrigin - initialUnitOrigin
		local n_diff = diff:Normalized()
		unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
		if diff:Length() > 500 then -- if pushback distance is over 500, stop it
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end
	end)
	
	keys.target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
	end)
end

function OnUpstreamProc(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not caster.bIsUpstreamReady then return end
	if keys.target:GetName() == "npc_dota_hero_bounty_hunter" and keys.target.IsPFWAcquired then return end
	caster.bIsUpstreamReady = false
	Timers:CreateTimer(4.0, function()
		caster.bIsUpstreamReady = true
	end)
	-- particle

	-- apply knockup
	local damage = caster:GetAttackDamage() * 1.3 + 150
	if target:GetName() == "npc_dota_hero_juggernaut" then damage = 0 end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ApplyAirborne(caster, target, 1.25)
	local sound = RandomInt(1,2)
	if sound == 1 then caster:EmitSound("Saber.StrikeAir_Release1") else caster:EmitSound("Saber.StrikeAir_Release2") end
	local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( upstreamFx, 0, target:GetAbsOrigin() )
end

function OnUpstreamHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if keys.target:GetName() == "npc_dota_hero_bounty_hunter" and keys.target.IsPFWAcquired then return end
	-- particle
	local damage = caster:GetAttackDamage() * 1.3 + 150
	if target:GetName() == "npc_dota_hero_juggernaut" then damage = 0 end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ApplyAirborne(caster, target, 1.25)
	caster:RemoveModifierByName("modifier_strike_air_upstream_ready")
	local sound = RandomInt(1,2)
	if sound == 1 then caster:EmitSound("Saber.StrikeAir_Release1") else caster:EmitSound("Saber.StrikeAir_Release2") end
	local upstreamFx = ParticleManager:CreateParticle( "particles/custom/saber/strike_air_upstream/strike_air_upstream.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( upstreamFx, 0, target:GetAbsOrigin() )
end

function SaberCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("saber_avalon") and caster:FindAbilityByName("saber_excalibur"):IsCooldownReady() and caster:FindAbilityByName("saber_max_excalibur"):IsCooldownReady() then
			caster:SwapAbilities("saber_excalibur", "saber_max_excalibur", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				caster:SwapAbilities("saber_excalibur", "saber_max_excalibur", true, false)
			end
			})			
		end
	end
end



function OnImproveExcaliburAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsExcaliburAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveInstinctAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsInstinctImproved = true

	hero:FindAbilityByName("saber_improved_instinct"):SetLevel(1)
	hero:SwapAbilities("saber_instinct","saber_improved_instinct", false, true)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnChivalryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsChivalryAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnStrikeAirAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SwapAbilities("saber_charisma","saber_strike_air", true, true)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSAUpstreamAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	hero.bIsUpstreamAcquired = true
	hero.bIsUpstreamReady = true
	hero:AddAbility("saber_strike_air_upstream")
	hero:FindAbilityByName("saber_strike_air_upstream"):SetLevel(1)
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
