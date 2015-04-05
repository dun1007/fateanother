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

function StartCharismaTimer(keys)
	local caster = keys.caster
	Timers:CreateTimer('charisma_passive_timer', {
		endTime = 0,
		callback = function()
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if v ~= caster then 
				if IsFacingUnit(v, caster, 120) then
					keys.ability:ApplyDataDrivenModifier(caster,v, "modifier_charisma_movespeed", {})
				end
			end
			
	    end
	    return 0.25
	end})
end
function OnForwardStart(keys)
	local caster = keys.caster
	
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() )

	
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
        , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster,v, "modifier_forward", {})
		v:EmitSound("Hero_LegionCommander.Overwhelming.Location")
    end
end

function OnPhalanxStart(keys)
	local caster = keys.caster
    local targetPoint = keys.target_points[1]
    local forwardVec = caster:GetForwardVector()
    caster.PhalanxSoldiers = {}

	local leftvec = Vector(-forwardVec.y, forwardVec.x, 0)
	local rightvec = Vector(forwardVec.y, -forwardVec.x, 0)

	-- Spawn soldiers from target point to left end
	for i=0,3 do
		local soldier = CreateUnitByName("iskander_phalanx_soldier", targetPoint + leftvec * 75 * i, true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = 3})

		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
		ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
		soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
		table.insert(caster.PhalanxSoldiers, soldier)
	end

	-- Spawn soldiers on right side
	for i=1,4 do
		local soldier = CreateUnitByName("iskander_phalanx_soldier", targetPoint + rightvec * 75 * i, true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = 3})

		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
		ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
		soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
		table.insert(caster.PhalanxSoldiers, soldier)
	end
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

			  	Timers:CreateTimer('phalanx_pull', {
					endTime = 0.5,
					callback = function()
					v:PreventDI(false)
					v:SetPhysicsVelocity(Vector(0,0,0))
					v:OnPhysicsFrame(nil)
				end
				})

			  	giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
				DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				local forwardVec = v:GetForwardVector()
				v:SetForwardVector(Vector(forwardVec.x*-1, forwardVec.y, forwardVec.z))
			end
	    end
	end
end

function OnChariotStart(keys)
	local caster = keys.caster

	caster:AddNewModifier(caster, nil, "modifier_bloodseeker_thirst_speed", { duration = keys.Duration+1})
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

    Timers:CreateTimer(1.0, function() 
    	if caster:IsAlive() then
    		OnChariotRide(keys)
    	end
    end)
end

function OnChariotRide(keys)
	local caster = keys.caster
	local damageDiff = keys.MaxDamage - keys.MinDamage

	caster:SwapAbilities("iskander_gordius_wheel", "fate_empty2", true, true) 
	caster:SwapAbilities("iskander_army_of_the_king", "iskander_via_expugnatio", true, true) 

   	Timers:CreateTimer(function() 
   		if caster:HasModifier("modifier_gordius_wheel") then 
			local currentStack = caster:GetModifierStackCount("modifier_gordius_wheel_speed_boost", keys.ability)
			if currentStack == 0 and caster:HasModifier("modifier_gordius_wheel_speed_boost") then currentStack = 1 end
			caster:RemoveModifierByName("modifier_gordius_wheel_speed_boost") 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_speed_boost", {}) 
			caster:SetModifierStackCount("modifier_gordius_wheel_speed_boost", keys.ability, currentStack + 1)

			
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

			local groundcrack = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			caster:EmitSound("Hero_Centaur.HoofStomp")
			return 1.0
		else
			return
		end
	end)

	-- Apply diminishing mitigation over time
	Timers:CreateTimer(function()	
		if caster:HasModifier("modifier_gordius_wheel") then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation_tier1", {}) 
		end
	end)
	Timers:CreateTimer(2.5, function()	
		if caster:HasModifier("modifier_gordius_wheel") then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation_tier2", {}) 
		end
	end)
	Timers:CreateTimer(5.5, function()	
		if caster:HasModifier("modifier_gordius_wheel") then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gordius_wheel_mitigation_tier3", {}) 
		end
	end)
end

function OnChariotEnd(keys)
	local caster = keys.caster

	caster:SwapAbilities("iskander_gordius_wheel", "fate_empty2", true, true) 
	caster:SwapAbilities("iskander_army_of_the_king", "iskander_via_expugnatio", true, true) 

    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")
    caster:SetModelScale(1.0)

    caster:RemoveModifierByName("modifier_gordius_wheel_speed_boost")
end

function OnChariotChargeStart(keys)
	local caster = keys.caster
	caster:EmitSound("Iskander.Charge")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 2.0)
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
    	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_CUSTOMORIGIN, caster)
    	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_CUSTOMORIGIN, caster)
    	ParticleManager:SetParticleControl(particle3, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle3, 2, caster:GetAbsOrigin())
    	ParticleManager:SetParticleControl( particle, 0, vector + Vector(randomVec, 0, 250))
    	ParticleManager:SetParticleControl( particle2, 0, vector + Vector(randomVec, 0, 100))
    	fieldCounter = fieldCounter + 0.5
    	return 0.5
    end)
        
end

aotkQuest = nil
function OnAOTKCastStart(keys)
	local caster = keys.caster
	EmitGlobalSound("Iskander.AOTK")
	
	Timers:CreateTimer({
		endTime = 2,
		callback = function()
		if keys.caster:IsAlive() then 
			OnAOTKStart(keys)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_army_of_the_king_death_checker",{})
		end
	end
	})
end

aotkTargets = nil
aotkCenter = Vector(500, -4800, 208)
aotkCasterPos = nil
function OnAOTKStart(keys)
	aotkQuest = StartQuestTimer("aotkTimerQuest", "Army of the King", 12)
	local caster = keys.caster
	local ability = keys.ability
	aotkTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	aotkTargetLoc = {}
	local diff = nil
	local aotkTargetPos = nil
	aotkCasterPos = caster:GetAbsOrigin()
	caster.IsAOTKActive = true

	-- record location of units and move them into UBW(center location : 6000, -4000, 200)
	for i=1, #aotkTargets do
		if aotkTargets[i]:GetName() ~= "npc_dota_ward_base" then
			aotkTargetPos = aotkTargets[i]:GetAbsOrigin()
	        aotkTargetLoc[i] = aotkTargetPos
	        diff = (aotkCasterPos - aotkTargetPos)

	        local forwardVec = aotkTargets[i]:GetForwardVector()
	        local qangle = aotkTargets[i]:GetAngles()
	        print(qangle)
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
				aotkTargets[i]:AddNewModifier(aotkTargets[i], aotkTargets[i], "modifier_camera_follow", {duration = 1.0})
				
			end)
			Timers:CreateTimer(0.033, function()
				ExecuteOrderFromTable({
					UnitIndex = aotkTargets[i]:entindex(),
					OrderType = DOTA_UNIT_ORDER_STOP,
					Queue = false
				})
				aotkTargets[i]:SetForwardVector(forwardVec)
			end)
		end
    end

	Timers:CreateTimer("aotk_timer", {
	    endTime = 12,
	    callback = function()
		if caster:IsAlive() and caster.IsAOTKActive then 
			EndAOTK(caster)
		end
	end
	})
end

function OnAOTKDeath(keys)
	local caster = keys.caster
	EndAOTK(caster)
end

function EndAOTK(caster)
	if caster.IsAOTKActive == false then return end
	print("AOTK ended")

	UTIL_RemoveImmediate(aotkQuest)
	caster.IsAOTKActive = false

    local units = FindUnitsInRadius(caster:GetTeam(), aotkCenter, nil, 2000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    for i=1, #units do
    	ProjectileManager:ProjectileDodge(units[i])
    	local IsUnitGeneratedInAOTK = true
    	if aotkTargets ~= nil then
	    	for j=1, #aotkTargets do
	    		if units[i] == aotkTargets[j] then
	    			units[i]:SetAbsOrigin(aotkTargetLoc[j]) 
	    			FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true)
	    			Timers:CreateTimer(0.1, function() 
						units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
					end)
	    			IsUnitGeneratedInAOTK = false
	    			break 
	    		end
	    	end 
    	end
    	if IsUnitGeneratedInAOTK then
    		diff = aotkCenter - units[i]:GetAbsOrigin()
    		units[i]:SetAbsOrigin(aotkCasterPos - diff)
    		FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true) 
			Timers:CreateTimer(0.1, function() 
				units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
			end)
    	end 
    end

    aotkTargets = nil
    aotkTargetLoc = nil

    Timers:RemoveTimer("aotk_timer")
end


function OnCavalrySummon(keys)
end

function OnMageSummon(keys)
end

function OnBattleHornStart(keys)
end

function OnHammerStart(keys)
end

function OnBrillianceStart(keys)
end 

function OnAnnihilateStart(keys)
end

function OnIskanderCharismaImproved(keys)
end

function OnThundergodAcquired(keys)
end

function OnChariotChargeAcquired(keys)
end

function OnBeyondTimeAcquired(keys)
end