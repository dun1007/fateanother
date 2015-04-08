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
	if caster.AOTKSoldierCount == nil then caster.AOTKSoldierCount = 0 end --initialize soldier count if its not made yet
	local aotkAbility = caster:FindAbilityByName("iskander_army_of_the_king")
    local targetPoint = keys.target_points[1]
    local forwardVec = caster:GetForwardVector()
    caster.PhalanxSoldiers = {}

	local leftvec = Vector(-forwardVec.y, forwardVec.x, 0)
	local rightvec = Vector(forwardVec.y, -forwardVec.x, 0)

	-- Spawn soldiers from target point to left end
	for i=0,3 do
		local soldier = CreateUnitByName("iskander_infantry", targetPoint + leftvec * 75 * i, true, nil, nil, caster:GetTeamNumber())
	    soldier:AddAbility("phalanx_soldier_passive") 
	    soldier:FindAbilityByName("phalanx_soldier_passive"):SetLevel(1)
		soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = 3})
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbility:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})

		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, soldier)
		ParticleManager:SetParticleControl(particle, 3, soldier:GetAbsOrigin())
		soldier:EmitSound("Hero_LegionCommander.Overwhelming.Location")
		table.insert(caster.PhalanxSoldiers, soldier)
	end

	-- Spawn soldiers on right side
	for i=1,4 do
		local soldier = CreateUnitByName("iskander_infantry", targetPoint + rightvec * 75 * i, true, nil, nil, caster:GetTeamNumber())
	    soldier:AddAbility("phalanx_soldier_passive") 
	    soldier:FindAbilityByName("phalanx_soldier_passive"):SetLevel(1)
		soldier:AddNewModifier(caster, nil, "modifier_kill", {duration = 3})
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbility:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})

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
    caster:RemoveModifierByName("modifier_bloodseeker_thirst_speed")
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
	
	local aotkParticle = ParticleManager:CreateParticle("particles/custom/iskandar/iskandar_aotk.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(aotkParticle, 0, caster:GetAbsOrigin())
	
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
function OnAOTKStart(keys)
	local caster = keys.caster
	if caster.AOTKSoldierCount == nil then caster.AOTKSoldierCount = 0 end --initialize soldier count if its not made yet
	aotkAbilityHandle = keys.ability -- Store handle in global variable for future use
	aotkQuest = StartQuestTimer("aotkTimerQuest", "Army of the King", 12)
	local ability = keys.ability
	aotkTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	caster.IsAOTKDominant = true
	for i=1, #aotkTargets do
		if aotkTargets[i]:GetName() == "npc_dota_hero_ember_spirit" and aotkTargets[i]:HasModifier("modifier_ubw_death_checker") then
			caster.IsAOTKDominant = false
			break
		end
	end
	caster.IsAOTKActive = true
	caster.AOTKSoldiers = {}
	EmitGlobalSound("Iskander.AOTK_Ambient")

	-- Swap abilities
	caster:SwapAbilities("iskander_army_of_the_king", "fate_empty2", true, true)
	caster:SwapAbilities("fate_empty1", "iskander_summon_hephaestion", true, true) 
	caster:SwapAbilities("iskander_charisma", "iskander_summon_waver", true, true) 
 

	-- Summon soldiers
	local marbleCenter = 0
	if caster.IsAOTKDominant then marbleCenter = aotkCenter else marbleCenter = ubwCenter end
	local firstRowPos = marbleCenter + Vector(300, -500,0) 
	local maharajaPos = marbleCenter + Vector(600, 0,0)

	-- First row
	for i=0,9 do
		local soldier = CreateUnitByName("iskander_infantry", firstRowPos + Vector(0,i*100,0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})
	end
	-- Second row
	for i=0,4 do
		local soldier = CreateUnitByName("iskander_archer", marbleCenter + Vector(800, 600 - i*100, 0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})
	end
	for i=0,4 do
		local soldier = CreateUnitByName("iskander_archer", marbleCenter + Vector(800, -600 + i*100, 0), true, nil, nil, caster:GetTeamNumber())
		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})
	end
	local maharaja = CreateUnitByName("iskander_maharaja", maharajaPos, true, nil, nil, caster:GetTeamNumber())
	maharaja:SetControllableByPlayer(caster:GetPlayerID(), true)
	maharaja:SetOwner(caster)
	table.insert(caster.AOTKSoldiers, maharaja)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, maharaja, "modifier_army_of_the_king_soldier_death_checker",{})

	if not caster.IsAOTKDominant then return end -- If Archer's UBW is already active, do not teleport units


	aotkTargetLoc = {}
	local diff = nil
	local aotkTargetPos = nil
	aotkCasterPos = caster:GetAbsOrigin()

	-- record location of units and move them into UBW(center location : 6000, -4000, 200)
	for i=1, #aotkTargets do
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
	EndAOTK(caster)
end

function EndAOTK(caster)
	if caster.IsAOTKActive == false then return end
	print("AOTK ended")

	UTIL_RemoveImmediate(aotkQuest)
	caster.IsAOTKActive = false

	-- Revert abilities
	caster:SwapAbilities("iskander_army_of_the_king", "fate_empty2", true, true)
	caster:SwapAbilities("fate_empty1", "iskander_summon_hephaestion", true, true) 
	caster:SwapAbilities("iskander_charisma", "iskander_summon_waver", true, true) 

	-- Remove soldiers 
	for i=1, #caster.AOTKSoldiers do
		if IsValidEntity(caster.AOTKSoldiers[i]) then
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
	print("Process units")
    local units = FindUnitsInRadius(caster:GetTeam(), aotkCenter, nil, 3000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    for i=1, #units do
    	-- Disjoint all projectiles
    	ProjectileManager:ProjectileDodge(units[i])
    	-- If unit is Archer and UBW is active, deactive it as well
		if units[i]:GetName() == "npc_dota_hero_ember_spirit" and units[i]:HasModifier("modifier_ubw_death_checker") then
			units[i]:RemoveModifierByName("modifier_ubw_death_checker")
		end
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
    		units[i]:SetAbsOrigin(aotkCasterPos - diff * 0.7)
    		FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true) 
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
	--caster.AOTKCavalryTable = {}
	caster:EmitSound("Hero_Centaur.Stampede.Movement")
	for i=0,5 do
		local soldier = CreateUnitByName("iskander_cavalry", targetPoint + Vector(200, -200 + i*100), true, nil, nil, caster:GetTeamNumber())
		--soldier:SetBaseMaxHealth(soldier:GetHealth() + ) 

		soldier:AddNewModifier(caster, nil, "modifier_phased", {})
		soldier:SetOwner(caster)
		table.insert(caster.AOTKSoldiers, soldier)
		--table.insert(caster.AOTKCavalryTable, soldier)
		caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})
	end
	local hepha = CreateUnitByName("iskander_hephaestion", targetPoint, true, nil, nil, caster:GetTeamNumber())
	hepha:SetControllableByPlayer(caster:GetPlayerID(), true)
	hepha:SetOwner(caster)
	table.insert(caster.AOTKSoldiers, hepha)
	--table.insert(caster.AOTKCavalryTable, hepha)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, hepha, "modifier_army_of_the_king_soldier_death_checker",{})
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
		aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, soldier, "modifier_army_of_the_king_soldier_death_checker",{})
	end
	local waver = CreateUnitByName("iskander_waver", targetPoint, true, nil, nil, caster:GetTeamNumber())
	waver:SetControllableByPlayer(caster:GetPlayerID(), true)
	waver:SetOwner(caster)
	table.insert(caster.AOTKSoldiers, waver)
	caster.AOTKSoldierCount = caster.AOTKSoldierCount + 1
	aotkAbilityHandle:ApplyDataDrivenModifier(keys.caster, waver, "modifier_army_of_the_king_soldier_death_checker",{})
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
			        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			        Position = targetPoint
			    })
				Timers:CreateTimer(1.0, function()
					if IsValidEntity(hero.AOTKSoldiers[i]) then
						ExecuteOrderFromTable({
							UnitIndex = hero.AOTKSoldiers[i]:entindex(),
							OrderType = DOTA_UNIT_ORDER_STOP,
							Queue = false
						})
					end
				end)
			end
		end
	end
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster,v, "modifier_battle_horn_armor_reduction", {})
    end
end

function OnHammerStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local cavalryTable = {}
	table.insert(cavalryTable, caster)
	caster:EmitSound("Hero_Centaur.Stampede.Cast")

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
		Timers:CreateTimer("hammer_charge" .. i, {
			endTime = 0.0,
			callback = function()

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
			local particle = ParticleManager:CreateParticle("particles/econ/items/tinker/boots_of_travel/teleport_start_bots_dust.vpcf", PATTACH_ABSORIGIN, cavalryTable[i])
			ParticleManager:SetParticleControl(particle, 0, cavalryTable[i]:GetAbsOrigin())
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