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
	EmitGlobalSound("Iskander.Charge")
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