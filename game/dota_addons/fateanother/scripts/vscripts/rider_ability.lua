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
	-- Destroy particle
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

		Timers:CreateTimer(0.5, function()
			v:PreventDI(false)
			v:SetPhysicsVelocity(Vector(0,0,0))
			v:OnPhysicsFrame(nil)
		end)

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
	local ability = keys.ability
	local ply = keys.caster:GetPlayerOwner()
	local targetPoint = keys.target_points[1]

	caster:EmitSound("Rider.BreakerGorgon") 
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 200
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if not IsImmuneToSlow(v) then ability:ApplyDataDrivenModifier(caster, v, "modifier_breaker_gorgon", {Duration = keys.duration}) end
		if caster.IsSealAcquired then  
			local rngesus = math.random(100)
			if rngesus < 30 then
				v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 2.5})
				ParticleManager:CreateParticle("particles/status_fx/status_effect_medusa_stone_gaze.vpcf", PATTACH_ROOTBONE_FOLLOW, v)

			end
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
	caster:EmitSound("Rider.BloodFort") 

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
			if caster.IsSealAcquired then  
				forcemove.UnitIndex = v:entindex()
				ExecuteOrderFromTable(forcemove) 
				giveUnitDataDrivenModifier(caster, v, "pause_sealenabled", 0.5)
			end
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        if not IsImmuneToSlow(v) then ability:ApplyDataDrivenModifier(caster,v, "modifier_bloodfort_slow", {}) end
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
	caster:FindAbilityByName("rider_5th_bloodfort_andromeda"):StartCooldown(27.0)
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	
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
	ParticleManager:SetParticleControl( belle2FxIndex, 2, caster:GetForwardVector() * 2000 )
	ParticleManager:SetParticleControl( belle2FxIndex, 6, Vector( 2, 0, 0 ) )
			
	Timers:CreateTimer( 2, function()
			ParticleManager:DestroyParticle( belle2FxIndex, false )
			ParticleManager:ReleaseParticleIndex( belle2FxIndex )
		end
	)
	


	locationDelta = caster:GetForwardVector() * keys.Range
	newLocation = caster:GetAbsOrigin() + locationDelta
	for i=1, 20 do
		if GridNav:IsBlocked(newLocation) or not GridNav:IsTraversable(newLocation) then
			locationDelta =  caster:GetForwardVector() * (keys.Range - 100)
			newLocation = caster:GetAbsOrigin() + locationDelta
		else
			break
		end
	end 
	caster:SetAbsOrigin(newLocation) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

end

function OnBelle2Hit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if caster.IsRidingAcquired then keys.Damage = keys.Damage + 250 end 
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
	local dmgdelay = dist * 0.000416
	
	-- Attach particle
	local belleFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bellerophon_1.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( belleFxIndex, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( belleFxIndex, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	
	if caster.IsRidingAcquired then keys.Damage = keys.Damage + 200 end 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "jump_pause", 1.0)
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
		if (caster:GetAbsOrigin() - targetPoint):Length2D() > 2000 then return end
		if descendCount == 9 then return end

		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x + descendVec.x * dist/6 ,
									caster:GetAbsOrigin().y + descendVec.y * dist/6,
									caster:GetAbsOrigin().z - 127))
		descendCount = descendCount + 1
		return 0.033
	end)

	-- this is when Rider makes a landing 
	Timers:CreateTimer(1.0, function() 
		if (caster:GetAbsOrigin() - targetPoint):Length2D() < 2000 then 
			caster:SetAbsOrigin(targetPoint)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end
		caster:EmitSound("Misc.Crash")
	end)

	-- this is when the damage actually applies(Put slam effect here)
	Timers:CreateTimer(1.0+dmgdelay, function()

		-- Destroy particles
		ParticleManager:DestroyParticle( belleFxIndex, false )
		ParticleManager:ReleaseParticleIndex( belleFxIndex )
		
		-- Crete particle
		local belleImpactFxIndex = ParticleManager:CreateParticle( "particles/custom/rider/rider_bellerophon_1_impact.vpcf", PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControl( belleImpactFxIndex, 0, targetPoint)
		ParticleManager:SetParticleControl( belleImpactFxIndex, 1, Vector( keys.Radius, keys.Radius, keys.Radius ) )
		
		Timers:CreateTimer( 1, function()
				ParticleManager:DestroyParticle( belleImpactFxIndex, false )
				ParticleManager:ReleaseParticleIndex( belleImpactFxIndex )
			end
		)
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 2.0})
	    end

	    ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
	end)
end

function RiderCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("rider_5th_nail_swing") then
			nailUsed = true
			nailTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 7,
				callback = function()
				nailUsed = false
			end
			})
		elseif ability == caster:FindAbilityByName("rider_5th_breaker_gorgon") and caster:FindAbilityByName("rider_5th_bloodfort_andromeda"):IsCooldownReady() and caster:FindAbilityByName("rider_5th_bellerophon_2"):IsCooldownReady() then
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
end

function OnImproveMysticEyesAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsMysticEyeImproved = true
	hero:FindAbilityByName("rider_5th_mystic_eye"):SetLevel(2)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnRidingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed() + 50) 
	hero.IsRidingAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSealAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsSealAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMonstrousStrengthAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetBaseMagicalResistanceValue(15)
	hero:SetBaseStrength(hero:GetBaseStrength()+10) 
	hero:FindAbilityByName("rider_5th_monstrous_strength_passive"):SetLevel(1)
	hero.IsMonstrousStrengthAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end