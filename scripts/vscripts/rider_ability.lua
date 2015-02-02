require("physics")
nailUsed = false
nailTime = 0

function OnMonstrousStrengthProc(keys)
	DoDamage(keys.caster, keys.target, 400 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function NailPull(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
	RiderCheckCombo(caster, keys.ability)
	caster:EmitSound("Rider.NailSwing")
	
	-- Create Particle
	local pullFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_nail_swing.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pullFxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pullFxIndex, 1, Vector( radius, radius, radius ) )
	Timers:CreateTimer( 1.5, function()
			ParticleManager:DestroyParticle( pullFxIndex, false )
			ParticleManager:ReleaseParticleIndex( pullFxIndex )
		end
	)

	for k,v in pairs(targets) do
		giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
		DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		
		local pullTarget = Physics:Unit(v)
		v:PreventDI()
		v:SetPhysicsFriction(0)
		v:SetPhysicsVelocity((caster:GetAbsOrigin() - v:GetAbsOrigin()):Normalized() * 1000)
		v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		v:FollowNavMesh(false)

	  	Timers:CreateTimer('nailpull', {
			endTime = 0.5,
			callback = function()
			v:PreventDI(false)
			v:SetPhysicsVelocity(Vector(0,0,0))
			v:OnPhysicsFrame(nil)
		end
		})

		v:OnPhysicsFrame(function(unit)
			local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
			local dir = diff:Normalized()
			unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
			if diff:Length() < 50 then
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
			end
		end)
	end
end

function OnBGStart(keys)
	RiderCheckCombo(keys.caster, keys.ability)
	local caster = keys.caster
	local ply = keys.caster:GetPlayerOwner()
	caster:EmitSound("Rider.BreakerGorgon") 
	if ply.IsSealAcquired then  
		if math.random(100) < 20 then
			giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 3.0)
		end
	end
end

-- Show particle on start
function OnBloodfortCast( keys )
	local sparkFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_emp_charge.vpcf", PATTACH_ABSORIGIN, keys.caster )
	ParticleManager:SetParticleControl( sparkFxIndex, 0, keys.caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( sparkFxIndex, 1, keys.caster:GetAbsOrigin() )
	Timers:CreateTimer( 2.5, function()
			ParticleManager:DestroyParticle( sparkFxIndex, false )
			ParticleManager:ReleaseParticleIndex( sparkFxIndex )
		end
	)
end

function OnBloodfortStart(keys)

	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local initCasterPoint = caster:GetAbsOrigin() 
	local duration = keys.Duration
	local radius = keys.Radius
	local ability = keys.ability
	local bloodfortCount = 0
	caster:EmitSound("Rider.BloodFort"  ) 

	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
	local dummy_ability = dummy:FindAbilityByName("dummy_unit_passive")
	dummy_ability:SetLevel(1)
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=5.0})
	Timers:CreateTimer( duration, function()  DummyEnd(dummy) return end )

	local forcemove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
		Position = initCasterPoint
	}


	Timers:CreateTimer(function()
		if bloodfortCount ==  duration then return end
		
		local targets = FindUnitsInRadius(caster:GetTeam(), initCasterPoint, nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if ply.IsSealAcquired then  
				forcemove.UnitIndex = v:entindex()
				ExecuteOrderFromTable(forcemove) 
				giveUnitDataDrivenModifier(caster, v, "pause_sealenabled", 0.5)
			end
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_slow", {})
	    end
		bloodfortCount = bloodfortCount + 1
		return 1.0
		end
	)
	
	-- Create Particle
	local sphereFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bloodfort_andromeda_sphere.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( sphereFxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( sphereFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( sphereFxIndex, 6, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( sphereFxIndex, 10, Vector( radius, radius, radius ) )
	
	Timers:CreateTimer( duration, function()
			ParticleManager:DestroyParticle( sphereFxIndex, false )
			ParticleManager:ReleaseParticleIndex( sphereFxIndex )
			return nil
		end
	)
end

-- Particle for starting to cast belle2
function OnBelle2Cast( keys )
	local caster = keys.caster
	local chargeFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker/invoker_emp_charge.vpcf", PATTACH_ABSORIGIN, caster )
	local eyeFxIndex = ParticleManager:CreateParticle( "particles/items_fx/dust_of_appearance_true_sight.vpcf", PATTACH_ABSORIGIN, caster )
	
	Timers:CreateTimer( 2.5, function()
			ParticleManager:DestroyParticle( chargeFxIndex, false )
			ParticleManager:DestroyParticle( eyeFxIndex, false )
			ParticleManager:ReleaseParticleIndex( chargeFxIndex )
			ParticleManager:ReleaseParticleIndex( eyeFxIndex )
		end
	)
end

function OnBelle2Start(keys)
	local caster = keys.caster
	local belle2 = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 99999,
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
        fExpireTime = GameRules:GetGameTime() + 1.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 99999
	}
	ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	EmitGlobalSound("Rider.Bellerophon") 
	local projectile = ProjectileManager:CreateLinearProjectile(belle2)
	
	-- Create Particle for projectile
	local belle2FxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bellerophon_2_beam_charge.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( belle2FxIndex, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( belle2FxIndex, 1, Vector( keys.Width, keys.Width, keys.Width ) )
	ParticleManager:SetParticleControl( belle2FxIndex, 2, caster:GetForwardVector() * 3000 )
	ParticleManager:SetParticleControl( belle2FxIndex, 6, Vector( 2, 0, 0 ) )
			
	Timers:CreateTimer( 2, function()
			ParticleManager:DestroyParticle( belle2FxIndex, false )
			ParticleManager:ReleaseParticleIndex( belle2FxIndex )
		end
	)
	
	caster:SetAbsOrigin(caster:GetAbsOrigin() + caster:GetForwardVector() * keys.Range) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function OnBelle2Hit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsRidingAcquired then keys.Damage = keys.Damage + 250 end 
	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnBelleStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local ply = caster:GetPlayerOwner()
	local ascendCount = 0
	local descendCount = 0
	local dist = (caster:GetAbsOrigin() - targetPoint):Length2D() 
	local dmgdelay = 360/dist
	if ply.IsRidingAcquired then keys.Damage = keys.Damage + 200 end 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 1.0)
	Timers:CreateTimer(0.5, function()
		EmitGlobalSound("Rider.Bellerophon") 
	end)

	local descendVec = Vector(0,0,0)
	descendVec = (targetPoint - Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, 1150)):Normalized()
	Timers:CreateTimer(function()
		if ascendCount == 23 then 
		 	return
		end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+50))
		ascendCount = ascendCount + 1
		return 0.033
	end)


	Timers:CreateTimer(0.7, function()
		if descendCount == 9 then return end

		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x + descendVec.x * dist/6 ,
									caster:GetAbsOrigin().y + descendVec.y * dist/6,
									caster:GetAbsOrigin().z - 127))
		descendCount = descendCount + 1
		return 0.033
	end)

	-- this is when Rider makes a landing 
	Timers:CreateTimer(1.0, function() 
		caster:SetAbsOrigin(targetPoint)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end)

	-- this is when the damage actually applies(Put slam effect here)
	Timers:CreateTimer(1.0+dmgdelay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 2.0})
	    end
	end)
end

function RiderCheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("rider_5th_nail_swing") then
		nailUsed = true
		nailTime = GameRules:GetGameTime()
		Timers:CreateTimer({
			endTime = 7,
			callback = function()
			nailUsed = false
		end
		})
	elseif ability == caster:FindAbilityByName("rider_5th_breaker_gorgon") then
		if nailUsed == true then 
			caster:SwapAbilities("rider_5th_bloodfort_andromeda", "rider_5th_bellerophon_2", false, true)
			local newTime =  GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 7 - (newTime - nailTime),
				callback = function()
				caster:SwapAbilities("rider_5th_bloodfort_andromeda", "rider_5th_bellerophon_2", true, false)
				nailUsed = false
			end
			})
		end
	end
end

function OnImproveMysticEyesAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsMysticEyeImproved = true
	hero:FindAbilityByName("rider_5th_mystic_eye_improved"):SetLevel(1)
	hero:SwapAbilities("rider_5th_mystic_eye","rider_5th_mystic_eye_improved", false, true)
end

function OnRidingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed() + 50) 
	ply.IsRidingAcquired = true
end

function OnSealAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsSealAcquired = true
end

function OnMonstrousStrengthAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetBaseMagicalResistanceValue(15)
	hero:SetBaseStrength(hero:GetBaseStrength()+10) 
	hero:FindAbilityByName("rider_5th_monstrous_strength_passive"):SetLevel(1)
	ply.IsMonstrousStrengthAcquired = true
end