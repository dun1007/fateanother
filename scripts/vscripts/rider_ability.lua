require("physics")
nailUsed = false
nailTime = 0

function OnMonstrousStrengthProc(keys)
	DoDamage(keys.caster, keys.target, 400 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function NailPull(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
	RiderCheckCombo(caster, keys.ability)
	caster:EmitSound("Rider.NailSwing")

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
	--keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_petrified", {Duration = 3.0})
	--ParticleManager:CreateParticle("particles/status_fx/status_effect_medusa_stone_gaze.vpcf", PATTACH_ROOTBONE_FOLLOW, keys.caster)
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
	Timers:CreateTimer(5.0, function()  DummyEnd(dummy) return end)

	local forcemove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
		Position = initCasterPoint
	}


	Timers:CreateTimer(function()
		if bloodfortCount ==  duration then return end
		
		local fort = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
		
		local targets = FindUnitsInRadius(caster:GetTeam(), initCasterPoint, nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
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
end

function OnBelle2Start(keys)
	local caster = keys.caster
	local belle2 = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
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
	if ply.IsRidingAcquired then keys.Damage = keys.Damage + 200 end 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 1.0)
	Timers:CreateTimer(0.5, function()
		EmitGlobalSound("Rider.Bellerophon") 
	end)

	Timers:CreateTimer(1.0, function() 
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 2.0})
	    end

		caster:SetAbsOrigin(targetPoint)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

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