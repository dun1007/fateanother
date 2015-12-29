require("physics")
require("util")

function OnIskanderCharismaStart(keys)
	local caster = keys.caster
	StartCharismaTimer(keys)
	print("charisma start")
end

function OnIskanderCharismaDeath(keys)
	local caster = keys.caster
	Timers:RemoveTimer("charisma_passive_timer")
	print("charisma end")
end

function OnIskanderCharismaRespawn(keys)
	local caster = keys.caster
	StartCharismaTimer(keys)
end

modName = "modifier_charisma_movespeed"
function StartCharismaTimer(keys)
	local caster = keys.caster
	Timers:CreateTimer('charisma_passive_timer', {
		endTime = 0,
		callback = function()
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if v ~= caster then 
				if IsFacingUnit(v, caster, 120) then
					keys.ability:ApplyDataDrivenModifier(caster,v, modName, {})
				end
			end
			
	    end
	    return 0.25
	end})
end
function OnForwardStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() )
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	if caster.IsCharismaImproved then
		keys.Radius = 20000
	end
	
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
        , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(targets) do
		RemoveSlowEffect(v)
		keys.ability:ApplyDataDrivenModifier(caster,v, "modifier_forward", {})
		v:EmitSound("Hero_LegionCommander.Overwhelming.Location")
    end
end

function OnPhalanxStart(keys)
	local caster = keys.caster
	if caster.AOTKSoldierCount == nil then caster.AOTKSoldierCount = 0 end --initialize soldier count if its not made yet
	local aotkAbility = caster:FindAbilityByName("iskander_army_of_the_king")
    local targetPoint = keys.target_points[1]
    local forwardVec = caster:GetForwardVector()
    caster.PhalanxSoldiers = {}

	local leftvec = Vector(-forwardVec.y, forwardVec.x, 0)
	local rightvec = Vector(forwardVec.y, -forwardVec.x, 0)

	-- Spawn soldiers from target point to left end
	for i=0,3 do
		Timers:CreateTimer(i*0.1, function()
			local soldier = CreateUnitByName("iskander_infantry", targetPoint + leftvec * 75 * i, true, nil, nil, caster:GetTeamNumber())
			soldier:SetOwner(caster)
		    soldier:AddAbility("phalanx_soldier_passive") 
		    soldier:FindAbilityByName("phalanx_soldier_passive"):SetLevel(1)
			soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = keys.Duration})
			caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
			aotkAbility:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{})
			PhalanxPull(caster, soldier, targetPoint, keys.Damage, keys.ability) -- do pullback

			--local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
			--ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
			soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
			if i==0 then
				local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
				ParticleManager:SetParticleControl(particle, 3, targetPoint)
				Timers:CreateTimer( 2.0, function()
					ParticleManager:DestroyParticle( particle, false )
					ParticleManager:ReleaseParticleIndex( particle )
				end)
			end 
			table.insert(caster.PhalanxSoldiers, soldier)
		end)
	end

	-- Spawn soldiers on right side
	for i=1,4 do
		Timers:CreateTimer(i*0.1, function()
			local soldier = CreateUnitByName("iskander_infantry", targetPoint + rightvec * 75 * i, true, nil, nil, caster:GetTeamNumber())
			soldier:SetOwner(caster)
		    soldier:AddAbility("phalanx_soldier_passive") 
		    soldier:FindAbilityByName("phalanx_soldier_passive"):SetLevel(1)
			soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = keys.Duration})
			caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
			aotkAbility:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{})
			PhalanxPull(caster, soldier, targetPoint, keys.Damage, keys.ability) -- do pullback

			--local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
			--ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
			soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
			table.insert(caster.PhalanxSoldiers, soldier)
		end)
	end
	--[[
	for i=1, #caster.PhalanxSoldiers do
		local targets = FindUnitsInRadius(caster:GetTeam(), caster.PhalanxSoldiers[i]:GetAbsOrigin(), nil, 150
	        , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if v.PhalanxSoldiersHit ~= true then 
				v.PhalanxSoldiersHit = true
				Timers:CreateTimer(0.033, function()
					v.PhalanxSoldiersHit = false
				end)

				local pullTarget = Physics:Unit(v)
				local pullVector = (caster:GetAbsOrigin() - targetPoint):Normalized() * 500
				v:PreventDI()
				v:SetPhysicsFriction(0)
				v:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, 500))
				v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
				v:FollowNavMesh(false)

				Timers:CreateTimer({
					endTime = 0.25,
					callback = function()
					v:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, -500))
				end
				})

			  	Timers:CreateTimer(0.5, function()
					v:PreventDI(false)
					v:SetPhysicsVelocity(Vector(0,0,0))
					v:OnPhysicsFrame(nil)
				end)

			  	giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
				DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				local forwardVec = v:GetForwardVector()
				v:SetForwardVector(Vector(forwardVec.x*-1, forwardVec.y, forwardVec.z))
			end
	    end
	end]]
end

function PhalanxPull(caster, soldier, targetPoint, damage, ability)
	local targets = FindUnitsInRadius(caster:GetTeam(), soldier:GetAbsOrigin(), nil, 150
	        , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		if v.PhalanxSoldiersHit ~= true then 
			v.PhalanxSoldiersHit = true
			Timers:CreateTimer(0.5, function()
				v.PhalanxSoldiersHit = false
			end)

			local pullTarget = Physics:Unit(v)
			local pullVector = (caster:GetAbsOrigin() - targetPoint):Normalized() * 500
			v:PreventDI()
			v:SetPhysicsFriction(0)
			v:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, 500))
			v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
			v:FollowNavMesh(false)

			Timers:CreateTimer({
				endTime = 0.25,
				callback = function()
				v:SetPhysicsVelocity(Vector(pullVector.x, pullVector.y, -500))
			end
			})

		  	Timers:CreateTimer(0.5, function()
				v:PreventDI(false)
				v:SetPhysicsVelocity(Vector(0,0,0))
				v:OnPhysicsFrame(nil)
			end)

		  	giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			local forwardVec = v:GetForwardVector()
			v:SetForwardVector(Vector(forwardVec.x*-1, forwardVec.y, forwardVec.z))
		end
    end
end

function OnChariotStart(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_gordius_wheel") or caster:HasModifier("modifier_army_of_the_king_death_checker") then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Cast Now" } )
		caster:GiveMana(400)
		keys.ability:EndCooldown() 
		return 
	end


	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel", {}) 
	caster:AddNewModifier(caster, nil, "modifier_ms_cap", {duration = keys.Duration+1})
	--caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst_speed", { duration = keys.Duration+1})
	caster:SetModel("models/iskander/iskander_chariot.vmdl")
    caster:SetOriginalModel("models/iskander/iskander_chariot.vmdl")
    caster:SetModelScale(1.0)
    caster:EmitSound("Hero_Magnataur.Skewer.Cast")
    caster:EmitSound("Hero_Zuus.GodsWrath")
	local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin())
    local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle3, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle3, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle3, 2, caster:GetAbsOrigin())
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
		ParticleManager:DestroyParticle( particle2, false )
		ParticleManager:ReleaseParticleIndex( particle2 )
		ParticleManager:DestroyParticle( particle3, false )
		ParticleManager:ReleaseParticleIndex( particle3 )
	end)

    Timers:CreateTimer(1.0, function() 
    	if caster:IsAlive() then
    		OnChariotRide(keys)
    	end
    end)
end

function OnChariotRide(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damageDiff = keys.MaxDamage - keys.MinDamage
	local duration = keys.Duration

	if caster.IsVEAcquired then
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "iskander_via_expugnatio", true, true) 
	else
		caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "fate_empty3", true, true)
	end

	local counter = 0
   	Timers:CreateTimer(function() 
   		if caster:HasModifier("modifier_gordius_wheel") and counter < 10 then 
   			if not caster:HasModifier("modifier_army_of_the_king_death_checker") then
				local currentStack = caster:GetModifierStackCount("modifier_gordius_wheel_speed_boost", keys.ability)
				if currentStack == 0 and caster:HasModifier("modifier_gordius_wheel_speed_boost") then currentStack = 1 end
				caster:RemoveModifierByName("modifier_gordius_wheel_speed_boost") 
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_speed_boost", {}) 
				caster:SetModifierStackCount("modifier_gordius_wheel_speed_boost", keys.ability, currentStack + 1)
   			end

			-- do damage around rider
	        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	        for k,v in pairs(targets) do
				local distDiff = 250 -- max damage at 100, min damage at 350
				local distance = (caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() 
				if distance <= 100 then 
					damage = keys.MaxDamage
				elseif distance > 100 then
					damage = keys.MaxDamage - damageDiff * distance/keys.Radius
				end
	            DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        end

	        if caster.IsThundergodAcquired then
		        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		        for k,v in pairs(targets) do
		            DoDamage(caster, v, 200, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
		        end	  
		        local thunderTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		        local thunderTarget = thunderTargets[math.random(#thunderTargets)]
		        if thunderTarget ~= nil then
		        	print(thunderTarget:GetUnitName())
		        	DoDamage(caster, thunderTarget, thunderTarget:GetHealth() * 12/100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		        	--thunderTarget:AddNewModifier(caster, thunderTarget, "modifier_stunned", {Duration = 0.1})
		       		keys.ability:ApplyDataDrivenModifier(caster, thunderTarget, "modifier_gordius_wheel_thunder_slow", {}) 

		       		thunderTarget:EmitSound("Hero_Zuus.LightningBolt")
		        	local thunderFx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf", PATTACH_CUSTOMORIGIN, thunderTarget)
		        	ParticleManager:SetParticleControl(thunderFx, 0, thunderTarget:GetAbsOrigin())
		        	ParticleManager:SetParticleControl(thunderFx, 1, caster:GetAbsOrigin()+Vector(0,0,800))
					Timers:CreateTimer( 2.0, function()
						ParticleManager:DestroyParticle( thunderFx, false )
						ParticleManager:ReleaseParticleIndex( thunderFx )
					end)
		        end
	        end
			local groundcrack = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			caster:EmitSound("Hero_Centaur.HoofStomp")
			counter = counter+1
			return 1.0
		else
			return
		end
	end)

	if not caster:HasModifier("modifier_army_of_the_king_death_checker") then
		-- Apply diminishing mitigation over time
		Timers:CreateTimer(function()	
			if caster:HasModifier("modifier_gordius_wheel") then 
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation_tier1", {}) 
			end
		end)
		Timers:CreateTimer(2.49, function()	
			if caster:HasModifier("modifier_gordius_wheel") and caster:HasModifier("modifier_gordius_wheel_mitigation_tier1") then 
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation_tier2", {}) 
			end
		end)
		Timers:CreateTimer(5.49, function()	
			if caster:HasModifier("modifier_gordius_wheel") and caster:HasModifier("modifier_gordius_wheel_mitigation_tier2") then 
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation_tier3", {}) 
			end
		end)
	end
end

function OnChariotEnd(keys)
	local caster = keys.caster

	if caster:HasModifier("modifier_army_of_the_king_death_checker") then
		caster:SwapAbilities("fate_empty3", caster:GetAbilityByIndex(5):GetName(), true, true) 
	else
		caster:SwapAbilities("iskander_army_of_the_king", caster:GetAbilityByIndex(5):GetName(), true, true) 
	end

    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")
    caster:SetModelScale(1.0)

    caster:RemoveModifierByName("modifier_gordius_wheel_speed_boost")
    caster:RemoveModifierByName("modifier_ms_cap")
end

function OnChariotChargeStart(keys)
	local caster = keys.caster
	caster:EmitSound("Iskander.Charge")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2.0)
	local currentMS = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed())
	print(currentMS)

	local unit = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*keys.Range)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("chariot_dash_damage", {
		endTime = 0.0,
		callback = function()

		CreateLightningField(keys, caster:GetAbsOrigin())
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
			if v.ChariotChargeHit ~= true then 
				v.ChariotChargeHit = true
				Timers:CreateTimer(1.0, function()
					v.ChariotChargeHit = false
				end)

           		DoDamage(caster, v, keys.ChargeDamage * currentMS / 100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
           		v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.25})

           	end
        end
		return 0.1
	end})

	Timers:CreateTimer("chariot_dash", {
		endTime = 1.0,
		callback = function()
		Timers:RemoveTimer("chariot_dash_damage")
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("modifier_gordius_wheel")
		caster:RemoveModifierByName("pause_sealenabled")
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("chariot_dash")
		Timers:RemoveTimer("chariot_dash_damage")
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("modifier_gordius_wheel")
		caster:RemoveModifierByName("pause_sealenabled")
		giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)
end

function CreateLightningField(keys, vector)
	local caster = keys.caster
    local fieldCounter = 0
 	local plusminus = 1
    local currentMS = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed())
    local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	Timers:CreateTimer( 4.0, function()
		ParticleManager:DestroyParticle( particle3, false )
		ParticleManager:ReleaseParticleIndex( particle3 )
	end)
    Timers:CreateTimer(function()	
    	if fieldCounter >= keys.Duration then return end

		local targets = FindUnitsInRadius(caster:GetTeam(), vector, nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
			if v.ChariotTrailHit ~= true then 
				v.ChariotTrailHit = true
				Timers:CreateTimer(0.49, function()
					v.ChariotTrailHit = false
				end)

           		DoDamage(caster, v, keys.TrailDamage * currentMS * 0.5 / 100 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
           	end
        end
        local randomVec = RandomInt(-400,400)
        
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field_c.vpcf", PATTACH_CUSTOMORIGIN, caster)
        local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field_c.vpcf", PATTACH_CUSTOMORIGIN, caster)
    	--local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_CUSTOMORIGIN, caster)
    	--local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_CUSTOMORIGIN, caster)
    	ParticleManager:SetParticleControl(particle3, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle3, 2, caster:GetAbsOrigin())
    	ParticleManager:SetParticleControl( particle, 0, vector + Vector(randomVec, 0, 250))
    	ParticleManager:SetParticleControl( particle2, 0, vector + Vector(randomVec, 0, 100))
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
			ParticleManager:DestroyParticle( particle2, false )
			ParticleManager:ReleaseParticleIndex( particle2 )
		end)
    	fieldCounter = fieldCounter + 0.5
    	return 0.5
    end)
        
end

--aotkQuest = nil
function OnAOTKCastStart(keys)
	-- initialize stuffs
	local caster = keys.caster
	if caster:GetAbsOrigin().y < -3500 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Already Within Reality Marble" } )
		caster:SetMana(caster:GetMana() + 800)
		keys.ability:EndCooldown()
		return
	end 
	caster.AOTKSoldiers = {}
	if caster.AOTKSoldierCount == nil then caster.AOTKSoldierCount = 0 end --initialize soldier count if its not made yet
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_army_of_the_king_freeze",{})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2.0)
	IskanderCheckCombo(caster, keys.ability) -- check combo
	EmitGlobalSound("Iskander.AOTK")

	-- particle
	local aotkParticle = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_aotk.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(aotkParticle, 0, caster:GetAbsOrigin())

	local firstRowPos = aotkCenter + Vector(300, -500,0) 
	local maharajaPos = aotkCenter + Vector(600, 0,0)

	local infantrySpawnCounter = 0
	Timers:CreateTimer(function()
		if infantrySpawnCounter == 10 then return end
		local soldier = CreateUnitByName("iskander_infantry", firstRowPos + Vector(0,infantrySpawnCounter*100,0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{})

		infantrySpawnCounter = infantrySpawnCounter+1
		return 0.1
	end)

	local archerSpawnCounter1 = 0
	Timers:CreateTimer(0.99, function()
		if archerSpawnCounter1 == 5 then return end
		local soldier = CreateUnitByName("iskander_archer", aotkCenter + Vector(800, 600 - archerSpawnCounter1*100, 0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_archer_bonus_stat",{})

		archerSpawnCounter1 = archerSpawnCounter1+1
		return 0.1
	end)

	local archerSpawnCounter2 = 0
	Timers:CreateTimer(1.49, function()
		if archerSpawnCounter2 == 5 then return end
		local soldier = CreateUnitByName("iskander_archer", aotkCenter + Vector(800, -600 + archerSpawnCounter2*100, 0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_archer_bonus_stat",{})

		archerSpawnCounter2 = archerSpawnCounter2+1
		return 0.1
	end)
	
	Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle(aotkParticle, false)
			ParticleManager:ReleaseParticleIndex(aotkParticle)
			return nil
		end
	)
	


	Timers:CreateTimer({
		endTime = 2,
		callback = function()
		if keys.caster:IsAlive() then 
		    caster.AOTKLocator = CreateUnitByName("ping_sign2", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		    caster.AOTKLocator:FindAbilityByName("ping_sign_passive"):SetLevel(1)
		    caster.AOTKLocator:AddNewModifier(caster, caster, "modifier_kill", {duration = 12.5})
		    caster.AOTKLocator:SetAbsOrigin(caster:GetAbsOrigin())
			OnAOTKStart(keys)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_army_of_the_king_death_checker",{})
		end
	end
	})
end

aotkTargets = nil
aotkCenter = Vector(500, -4800, 208)
ubwCenter = Vector(5600, -4398, 200)
aotkCasterPos = nil
aotkAbilityHandle = nil	-- handle of AOTK ability

function OnAOTKLevelUp(keys)
	aotkAbilityHandle = keys.ability -- Store handle in global variable for future use
end

function OnAOTKStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	caster.IsAOTKActive = true
	caster:EmitSound("Ability.SandKing_SandStorm.loop")
	CreateUITimer("Army of the King", 12, "aotk_timer")
	--aotkQuest = StartQuestTimer("aotkTimerQuest", "Army of the King", 12) -- Start timer

	-- Swap abilities
	caster:SwapAbilities("iskander_army_of_the_king", "fate_empty3", true, true)
	caster:SwapAbilities("fate_empty1", "iskander_summon_hephaestion", true, true) 
	if caster.IsBeyondTimeAcquired then
		caster:SwapAbilities("iskander_charisma", "iskander_summon_waver", true, true) 
	else 
		caster:SwapAbilities("iskander_charisma", "fate_empty4", true, true) 
	end

	-- Find eligible targets
	aotkTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	caster.IsAOTKDominant = true

	-- Remove any dummy or hero in jump from table 
	for i=1, #aotkTargets do
		if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
			ProjectileManager:ProjectileDodge(aotkTargets[i]) -- Disjoint particles
			if aotkTargets[i]:HasModifier("jump_pause") or string.match(aotkTargets[i]:GetUnitName(),"dummy") then 
				print("dummy or a hero with jump state detected. Removing current index")
				table.remove(aotkTargets, i)
			end
		end
	end

	if caster:GetAbsOrigin().x > 3000 and caster:GetAbsOrigin().y < -2000 then
		caster.IsAOTKDominant = false
	end

	--[[-- Check if Archer's UBW is already in place 
	for i=1, #aotkTargets do
		if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
			if aotkTargets[i]:GetName() == "npc_dota_hero_ember_spirit" and aotkTargets[i]:HasModifier("modifier_ubw_death_checker") then
				caster.IsAOTKDominant = false
				break
			end
		end
	end]]


 	-- spawn sight dummy
	local truesightdummy = CreateUnitByName("sight_dummy_unit", aotkCenter, false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	truesightdummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 3000}) 
	truesightdummy:AddNewModifier(caster, caster, "modifier_kill", {duration = 12}) 
	truesightdummy:SetDayTimeVisionRange(2500)
	truesightdummy:SetNightTimeVisionRange(2500)
	local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)
	-- spawn sight dummy for enemies
	local enemyTeamNumber = 0
	if caster:GetTeamNumber() == 0 then enemyTeamNumber = 1 end
	local truesightdummy2 = CreateUnitByName("sight_dummy_unit", aotkCenter, false, keys.caster, keys.caster, enemyTeamNumber)
	truesightdummy2:AddNewModifier(caster, caster, "modifier_kill", {duration = 12}) 
	truesightdummy2:SetDayTimeVisionRange(2500)
	truesightdummy2:SetNightTimeVisionRange(2500)
	local unseen2 = truesightdummy2:FindAbilityByName("dummy_unit_passive")
	unseen2:SetLevel(1)

	-- Summon soldiers
	local marbleCenter = 0
	if caster.IsAOTKDominant then marbleCenter = aotkCenter else marbleCenter = ubwCenter end
	local firstRowPos = marbleCenter + Vector(300, -500,0) 
	local maharajaPos = marbleCenter + Vector(600, 0,0)

	for i=1, #caster.AOTKSoldiers do
		local soldierHandle = caster.AOTKSoldiers[i]
		local soldierPos = caster.AOTKSoldiers[i]:GetAbsOrigin()
		local diffFromCenter = soldierPos - aotkCenter
		soldierHandle:SetAbsOrigin(diffFromCenter + marbleCenter)
	end
	--[[
	-- First row
	for i=0,9 do
		local soldier = CreateUnitByName("iskander_infantry", firstRowPos + Vector(0,i*100,0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_infantry_bonus_stat",{})
	end
	-- Second row
	for i=0,4 do
		local soldier = CreateUnitByName("iskander_archer", marbleCenter + Vector(800, 600 - i*100, 0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_archer_bonus_stat",{})
	end
	for i=0,4 do
		local soldier = CreateUnitByName("iskander_archer", marbleCenter + Vector(800, -600 + i*100, 0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_archer_bonus_stat",{})
	end]]
	local maharaja = CreateUnitByName("iskander_maharaja", maharajaPos, true, nil, nil, caster:GetTeamNumber())
	maharaja:SetControllableByPlayer(caster:GetPlayerID(), true)
	maharaja:SetOwner(caster)
	maharaja:FindAbilityByName("iskander_battle_horn"):SetLevel(aotkAbilityHandle:GetLevel())
	table.insert(caster.AOTKSoldiers, maharaja)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, maharaja, "modifier_army_of_the_king_maharaja_bonus_stat",{})

	if not caster.IsAOTKDominant then return end -- If Archer's UBW is already active, do not teleport units


	aotkTargetLoc = {}
	local diff = nil
	local aotkTargetPos = nil
	aotkCasterPos = caster:GetAbsOrigin()

	-- record location of units and move them into UBW(center location : 6000, -4000, 200)
	for i=1, #aotkTargets do
		if IsValidEntity(aotkTargets[i]) and not aotkTargets[i]:IsNull() then
			if aotkTargets[i]:GetName() ~= "npc_dota_ward_base" then
				aotkTargetPos = aotkTargets[i]:GetAbsOrigin()
		        aotkTargetLoc[i] = aotkTargetPos
		        diff = (aotkCasterPos - aotkTargetPos)

		        local forwardVec = aotkTargets[i]:GetForwardVector()
		        -- scale position difference to size of AOTK
		        diff.y = diff.y * 0.7
		        if aotkTargets[i]:GetTeam() ~= caster:GetTeam() then 
		        	if diff.x <= 0 then 
		        		diff.x = diff.x * -1 
		        		forwardVec.x = forwardVec.x * -1
		        	end
		        elseif aotkTargets[i]:GetTeam() == caster:GetTeam() then
		        	if diff.x >= 0 then 
		        		diff.x = diff.x * -1
		        		forwardVec.x = forwardVec.x * -1
		        	end
		        end
		        aotkTargets[i]:SetAbsOrigin(aotkCenter - diff)
				FindClearSpaceForUnit(aotkTargets[i], aotkTargets[i]:GetAbsOrigin(), true)
				Timers:CreateTimer(0.1, function() 
					if caster:IsAlive() then
						aotkTargets[i]:AddNewModifier(aotkTargets[i], aotkTargets[i], "modifier_camera_follow", {duration = 1.0})
					end
				end)
				Timers:CreateTimer(0.033, function()
					if caster:IsAlive() then
						ExecuteOrderFromTable({
							UnitIndex = aotkTargets[i]:entindex(),
							OrderType = DOTA_UNIT_ORDER_STOP,
							Queue = false
						})
						aotkTargets[i]:SetForwardVector(forwardVec)
					end
				end)
			end
		end
    end

end

function OnAOTKSoldierDeath(keys)
	local caster = keys.caster
	caster.AOTKSoldierCount = caster.AOTKSoldierCount - 1
	print("Current number of remaining soldiers : " .. caster.AOTKSoldierCount)
	if caster.AOTKSoldierCount < keys.SustainLimit and caster.IsAOTKActive then
		EndAOTK(caster)
	end
end

function OnAOTKDeath(keys)
	local caster = keys.caster
	Timers:CreateTimer(0.066, function()
		EndAOTK(caster)
	end)
end

function EndAOTK(caster)
	if caster.IsAOTKActive == false then return end
	print("AOTK ended")
	-- Revert abilities
	caster:SwapAbilities("iskander_army_of_the_king", "fate_empty3", true, false)
	caster:SwapAbilities("fate_empty1", "iskander_summon_hephaestion", true, false) 
	caster:SwapAbilities("iskander_charisma", caster:GetAbilityByIndex(3):GetName(), true, false) 
	CreateUITimer("Army of the King", 0, "aotk_timer")
	--UTIL_RemoveImmediate(aotkQuest)
	caster.IsAOTKActive = false
	if not caster.AOTKLocator:IsNull() and IsValidEntity(caster.AOTKLocator) then
		caster.AOTKLocator:RemoveSelf()
	end

	StopSoundEvent("Ability.SandKing_SandStorm.loop", caster)


	-- Remove soldiers 
	for i=1, #caster.AOTKSoldiers do
		if IsValidEntity(caster.AOTKSoldiers[i]) and not caster.AOTKSoldiers[i]:IsNull() then
			if caster.AOTKSoldiers[i]:IsAlive() then
				caster.AOTKSoldiers[i]:ForceKill(true)
			end
		end
	end
	--[[for i=0, 9 do
	    local player = PlayerResource:GetPlayer(i)
	    if player ~= nil and player:GetAssignedHero() ~= nil then 
			player:StopSound("Iskander.AOTK_Ambient")
		end
	end]]
    local units = FindUnitsInRadius(caster:GetTeam(), aotkCenter, nil, 3000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
 
    for i=1, #units do
    	if IsValidEntity(units[i]) and not units[i]:IsNull() then
			if string.match(units[i]:GetUnitName(),"dummy") then 
				table.remove(units, i)
			end
		end
	end

    for i=1, #units do
    	print("removing units in AOTK")
    	if IsValidEntity(units[i]) and not units[i]:IsNull() then 
	    	-- Disjoint all projectiles
	    	ProjectileManager:ProjectileDodge(units[i])
	    	-- If unit is Archer and UBW is active, deactive it as well
			if units[i]:GetName() == "npc_dota_hero_ember_spirit" and units[i]:HasModifier("modifier_ubw_death_checker") then
				units[i]:RemoveModifierByName("modifier_ubw_death_checker")
			end
	    	local IsUnitGeneratedInAOTK = true
	    	if aotkTargets ~= nil then
		    	for j=1, #aotkTargets do
		    		if IsValidEntity(aotkTargets[j]) and not aotkTargets[j]:IsNull() then
			    		if units[i] == aotkTargets[j] then
			    			if aotkTargets[j] ~= nil then
			    				units[i]:SetAbsOrigin(aotkTargetLoc[j]) 
			    			end
			    			FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true)
			    			Timers:CreateTimer(0.1, function() 
			    				if IsValidEntity(units[i]) and not units[i]:IsNull() then 
									units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
								end
							end)
			    			IsUnitGeneratedInAOTK = false
			    			break 
			    		end
			    	end
		    	end 
	    	end
	    	if IsUnitGeneratedInAOTK then
	    		diff = aotkCenter - units[i]:GetAbsOrigin()
	    		if aotkCasterPos ~= nil then 
	    			units[i]:SetAbsOrigin(aotkCasterPos - diff * 0.7)
	    		end
	    		FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true) 
				Timers:CreateTimer(0.1, function() 
					if IsValidEntity(units[i]) and not units[i]:IsNull() then
						units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
					end
				end)
	    	end
	    end
    end

    aotkTargets = nil
    aotkTargetLoc = nil

    Timers:RemoveTimer("aotk_timer")
end


function OnCavalrySummon(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]
	IskanderCheckCombo(caster, keys.ability)
	--caster.AOTKCavalryTable = {}
	caster:EmitSound("Hero_KeeperOfTheLight.SpiritForm")
	for i=0,5 do
		local soldier = CreateUnitByName("iskander_cavalry", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
		--soldier:SetBaseMaxHealth(soldier:GetHealth() + ) 

		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		--table.insert(caster.AOTKCavalryTable, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_cavalry_bonus_stat",{})
	end
	local hepha = CreateUnitByName("iskander_hephaestion", targetPoint, true, nil, nil, caster:GetTeamNumber())
	hepha:SetControllableByPlayer(caster:GetPlayerID(), true)
	hepha:SetOwner(caster)
	hepha:FindAbilityByName("iskander_hammer_and_anvil"):SetLevel(aotkAbilityHandle:GetLevel())
	table.insert(caster.AOTKSoldiers, hepha)
	--table.insert(caster.AOTKCavalryTable, hepha)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, hepha, "modifier_army_of_the_king_hepha_bonus_stat",{})
end

function OnMageSummon(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]
	caster:EmitSound("Hero_Silencer.Curse.Cast")
	for i=0,5 do
		local soldier = CreateUnitByName("iskander_mage", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_mage_bonus_stat",{})
	end
	local waver = CreateUnitByName("iskander_waver", targetPoint, true, nil, nil, caster:GetTeamNumber())
	waver:SetControllableByPlayer(caster:GetPlayerID(), true)
	waver:SetOwner(caster)
	waver:FindAbilityByName("iskander_brilliance_of_the_king"):SetLevel(aotkAbilityHandle:GetLevel())
	table.insert(caster.AOTKSoldiers, waver)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, waver, "modifier_army_of_the_king_waver_bonus_stat",{})
end

function ModifySoldierHealth(keys)
	local unit = keys.target
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local newHP = unit:GetMaxHealth() + keys.HealthBonus
	local newcurrentHP = unit:GetHealth() + keys.HealthBonus
	print(newHP .. " " .. newcurrentHP)

	if caster.IsBeyondTimeAcquired then 
		newHP = newHP + caster:GetMaxHealth() * 30/100
		newcurrentHP = newcurrentHP + caster:GetMaxHealth() * 30/100
	end

	
	unit:SetMaxHealth(newHP)
	unit:SetBaseMaxHealth(newHP)
	unit:SetHealth(newcurrentHP)
end

function OnBattleHornStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local targetPoint = keys.target_points[1]
	caster:EmitSound("Hero_LegionCommander.PressTheAttack")
	for i=1, #hero.AOTKSoldiers do
		if IsValidEntity(hero.AOTKSoldiers[i]) then
			if hero.AOTKSoldiers[i]:IsAlive() then
				keys.ability:ApplyDataDrivenModifier(caster,hero.AOTKSoldiers[i], "modifier_battle_horn_movespeed_buff", {})
				ExecuteOrderFromTable({
			        UnitIndex = hero.AOTKSoldiers[i]:entindex(),
			        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			        Position = targetPoint
			    })
				--[[Timers:CreateTimer(1.0, function()
					if IsValidEntity(hero.AOTKSoldiers[i]) then
						ExecuteOrderFromTable({
							UnitIndex = hero.AOTKSoldiers[i]:entindex(),
							OrderType = DOTA_UNIT_ORDER_STOP,
							Queue = false
						})
					end
				end)]]
			end
		end
	end
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster,v, "modifier_battle_horn_armor_reduction", {})
    end
    if hero:HasModifier("modifier_annihilate_caster") then
		for k,v in pairs(targets) do
			keys.ability:ApplyDataDrivenModifier(caster,v, "modifier_battle_horn_movespeed_debuff", {})
	    end
    end
end

function OnHammerStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local cavalryTable = {}
	table.insert(cavalryTable, caster)
	caster:EmitSound("Hero_Centaur.Stampede.Cast")
	if hero:HasModifier("modifier_annihilate_caster") then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(3.0)
	end

	if hero.IsAOTKDominant then
		caster:SetAbsOrigin(aotkCenter + Vector(-1400, 0, 0)) 
	else
		caster:SetAbsOrigin(ubwCenter + Vector(-1100, 0, 0)) 
	end		

	for i=1, #hero.AOTKSoldiers do
		if IsValidEntity(hero.AOTKSoldiers[i]) then
			if hero.AOTKSoldiers[i]:IsAlive() then
				if hero.AOTKSoldiers[i]:GetUnitName() == "iskander_cavalry" then
					table.insert(cavalryTable, hero.AOTKSoldiers[i])
					if hero.IsAOTKDominant then
						hero.AOTKSoldiers[i]:SetAbsOrigin(aotkCenter + Vector(-1400, -600 + RandomInt(0, 1200), 0)) 
					else
						hero.AOTKSoldiers[i]:SetAbsOrigin(ubwCenter + Vector(-900, -600 + RandomInt(0,1200), 0))
					end
				end
			end
		end
	end

	for i=1,#cavalryTable do
		local counter = 0
		Timers:CreateTimer("hammer_charge" .. i, {
			endTime = 0.0,
			callback = function()
			if counter > 3 then return end
			local targets = FindUnitsInRadius(cavalryTable[i]:GetTeam(), cavalryTable[i]:GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	        for k,v in pairs(targets) do
				if v.HammerChargeHit ~= true then 
					v.HammerChargeHit = true
					Timers:CreateTimer(1.0, function()
						v.HammerChargeHit = false
					end)

	           		DoDamage(cavalryTable[i], v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	           		v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.00})
	           	else
	           		DoDamage(cavalryTable[i], v, keys.Damage/2, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	           	end
	        end
	        counter = counter+0.15
			return 0.15
		end})

		giveUnitDataDrivenModifier(keys.caster, keys.caster, "round_pause", 2.0)
		local cavalryUnit = Physics:Unit(cavalryTable[i])
		cavalryTable[i]:PreventDI()
		cavalryTable[i]:SetPhysicsFriction(0)
		cavalryTable[i]:SetPhysicsVelocity((hero:GetAbsOrigin() - cavalryTable[i]:GetAbsOrigin()):Normalized() * 1500)
		cavalryTable[i]:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		cavalryTable[i]:FollowNavMesh(false)

		cavalryTable[i]:OnPhysicsFrame(function(unit)
			local diff = hero:GetAbsOrigin() - cavalryTable[i]:GetAbsOrigin()
			local dir = diff:Normalized()
			local particle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_end_bots_dust.vpcf", PATTACH_ABSORIGIN, cavalryTable[i])
			ParticleManager:SetParticleControl(particle, 0, cavalryTable[i]:GetAbsOrigin())
			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
			end)
			unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
	   		unit:SetForwardVector(dir) 
			if diff:Length() < 50 then
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				unit:RemoveModifierByName("round_pause")
				Timers:RemoveTimer("hammer_charge" .. i)
			end
		end)
	end
end

function OnBrillianceStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if hero:HasModifier("modifier_annihilate_caster") then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_waver_root_aura", {})
	end
end 

function OnAnnihilateStart(keys)
	local caster = keys.caster
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	EmitGlobalSound("Iskander.Annihilate")
	Timers:CreateTimer(2.0, function()
		EmitGlobalSound("Iskander.Aye")
	end)
	EmitGlobalSound("Hero_LegionCommander.PressTheAttack")
	-- Remove soldiers 
	for i=1, #caster.AOTKSoldiers do
		if IsValidEntity(caster.AOTKSoldiers[i]) then
			if caster.AOTKSoldiers[i]:IsAlive() then
				keys.ability:ApplyDataDrivenModifier(caster,caster.AOTKSoldiers[i], "modifier_annihilate", {})
			end
		end
	end
end

function IskanderCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.5 and caster:GetAgility() >= 19.5 and caster:GetIntellect() >= 19.5 then
		if ability == caster:FindAbilityByName("iskander_army_of_the_king") then
			armyUsed = true
			armyTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				armyUsed = false
			end
			})
		elseif ability == caster:FindAbilityByName("iskander_summon_hephaestion") and caster:FindAbilityByName("iskander_annihilate"):IsCooldownReady() and caster:FindAbilityByName("iskander_forward"):IsCooldownReady() then
			if armyUsed == true then 
				caster:SwapAbilities("iskander_forward", "iskander_annihilate", false, true)
				local newTime =  GameRules:GetGameTime()
				Timers:CreateTimer({
					endTime = 5 - (newTime - armyTime),
					callback = function()
					caster:SwapAbilities("iskander_forward", "iskander_annihilate", true, false)
					armyUsed = false
				end
				})
			end
		end
	end
end

function OnIskanderCharismaImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsCharismaImproved = true
    modName = "modifier_charisma_improved"
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnThundergodAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsThundergodAcquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnChariotChargeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsVEAcquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnBeyondTimeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsBeyondTimeAcquired = true
       -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end