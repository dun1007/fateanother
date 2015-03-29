require("physics")
require("util")

aotkTargets = nil
aotkCenter = Vector(500, -4800, 208)
aotkCasterPos = nil

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
			end
	    end
	end
end

function OnChariotStart(keys)
	local caster = keys.caster
	local damageDiff = keys.MaxDamage - keys.MinDamage
	print("chariot begin")

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
end

function OnChariotEnd(keys)
	local caster = keys.caster
    caster:SetModel("models/iskander/iskander.vmdl")
    caster:SetOriginalModel("models/iskander/iskander.vmdl")
    caster:SetModelScale(1.0)

    caster:RemoveModifierByName("modifier_gordius_wheel_speed_boost")
end

function OnChariotChargeStart(keys)
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

function OnAOTKStart(keys)
	aotkQuest = StartQuestTimer("aotkTimerQuest", "Army of the King", 12)
	local caster = keys.caster
	aotkCasterLoc = caster:GetAbsOrigin()
	caster.IsAOTKActive = true
	caster:SetAbsOrigin(aotkCenter)
	EmitGlobalSound("Iskander.AOTKAmbient")
	Timers:CreateTimer(0.1, function() 
		caster:AddNewModifier(caster, caster, "modifier_camera_follow", {duration = 1.0})
	end)
	--PlayerResource:SetCameraTarget(caster:GetPlayerID(), caster)
	--PlayerResource:SetCameraTarget(caster:GetPlayerID(), nil)

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
	caster:SetAbsOrigin(aotkCasterLoc)
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