require("physics")

ability1Level = 0
ability2Level = 0
ability3Level = 0
ability4Level = 0
ability5Level = 0

function LancerOnTakeDamage(keys)
	local caster = keys.caster
	local currentHealth = caster:GetHealth()
	if currentHealth == 0 and keys.ability:IsCooldownReady()  then
		caster:SetHealth(1)
		keys.ability:StartCooldown(60) 
		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
	end
end

function RuneMagicOpen(keys)
	local caster = keys.caster
	ability1Level = keys.ability:GetLevel()
	ability2Level = keys.caster:GetAbilityByIndex(1):GetLevel()
	ability3Level = keys.caster:GetAbilityByIndex(2):GetLevel()
	ability4Level = keys.caster:GetAbilityByIndex(3):GetLevel()
	ability5Level = keys.caster:GetAbilityByIndex(4):GetLevel()

	caster:RemoveAbility("lancer_5th_rune_magic")
	caster:RemoveAbility("lancer_5th_relentless_spear")
	caster:RemoveAbility("lancer_5th_gae_bolg")
	caster:RemoveAbility("lancer_5th_battle_continuation")
	caster:RemoveAbility("lancer_5th_gae_bolg_jump")
	--[[for i=0,5 do
		caster:RemoveAbility(caster:GetAbilityByIndex(i):GetAbilityName())
	end ]]
	caster:AddAbility("lancer_5th_rune_of_disengage") 
	caster:AddAbility("lancer_5th_rune_of_replenishment")
	caster:AddAbility("lancer_5th_rune_of_trap")
	caster:AddAbility("lancer_5th_rune_of_flame")
	caster:AddAbility("lancer_5th_close_spellbook")
	caster:AddAbility("lancer_5th_rune_of_conversion") 

	caster:GetAbilityByIndex(0):SetLevel(ability1Level)
	caster:GetAbilityByIndex(1):SetLevel(ability1Level)
	caster:GetAbilityByIndex(2):SetLevel(ability1Level)
	caster:GetAbilityByIndex(3):SetLevel(ability1Level)
	caster:GetAbilityByIndex(4):SetLevel(1)
	caster:GetAbilityByIndex(5):SetLevel(ability1Level)
--[[
	for i=0,5 do
		caster:GetAbilityByIndex(i):SetLevel(abilityLevel)
	end]]
end

function RuneMagicUsed(keys)
	local caster = keys.caster
	caster:RemoveAbility("lancer_5th_rune_of_disengage") 
	caster:RemoveAbility("lancer_5th_rune_of_replenishment")
	caster:RemoveAbility("lancer_5th_rune_of_trap")
	caster:RemoveAbility("lancer_5th_rune_of_flame")
	caster:RemoveAbility("lancer_5th_close_spellbook")
	caster:RemoveAbility("lancer_5th_rune_of_conversion") 

	caster:AddAbility("lancer_5th_rune_magic")
	caster:AddAbility("lancer_5th_relentless_spear")
	caster:AddAbility("lancer_5th_gae_bolg")
	caster:AddAbility("lancer_5th_battle_continuation")
	caster:AddAbility("lancer_5th_gae_bolg_jump")

	caster:GetAbilityByIndex(0):SetLevel(ability1Level)
	caster:GetAbilityByIndex(1):SetLevel(ability2Level)
	caster:GetAbilityByIndex(2):SetLevel(ability3Level)
	caster:GetAbilityByIndex(3):SetLevel(ability4Level)
	caster:GetAbilityByIndex(4):SetLevel(ability5Level)
	caster:GetAbilityByIndex(0):StartCooldown(20) 
end

function RuneMagicClose(keys)
	local caster = keys.caster
	caster:RemoveAbility("lancer_5th_rune_of_disengage") 
	caster:RemoveAbility("lancer_5th_rune_of_replenishment")
	caster:RemoveAbility("lancer_5th_rune_of_trap")
	caster:RemoveAbility("lancer_5th_rune_of_flame")
	caster:RemoveAbility("lancer_5th_close_spellbook")
	caster:RemoveAbility("lancer_5th_rune_of_conversion") 

	caster:AddAbility("lancer_5th_rune_magic")
	caster:AddAbility("lancer_5th_relentless_spear")
	caster:AddAbility("lancer_5th_gae_bolg")
	caster:AddAbility("lancer_5th_battle_continuation")
	caster:AddAbility("lancer_5th_gae_bolg_jump")

	caster:GetAbilityByIndex(0):SetLevel(ability1Level)
	caster:GetAbilityByIndex(1):SetLevel(ability2Level)
	caster:GetAbilityByIndex(2):SetLevel(ability3Level)
	caster:GetAbilityByIndex(3):SetLevel(ability4Level)
	caster:GetAbilityByIndex(4):SetLevel(ability5Level)
	caster:GetAbilityByIndex(0):EndCooldown()

end

function Disengage(keys)
	local caster = keys.caster
	local backward = caster:GetForwardVector() * keys.Distance
	caster:SetAbsOrigin(caster:GetAbsOrigin() - backward)
	ProjectileManager:ProjectileDodge(caster) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function Trap(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local stunDuration = keys.StunDuration
	local trapDuration = 0
	local radius = keys.Radius

	local lancertrap = CreateUnitByName("lancer_trap", targetPoint, true, caster, caster, caster:GetTeamNumber())


	local targets = nil
	
    Timers:CreateTimer(function()
        targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) -- find enemies in radius
        -- if enemy is found, spring the trap
        for k,v in pairs(targets) do
        	if v ~= nil then
        		print("spring the trap")
				SpringTrap(lancertrap, caster, stunDuration, targetPoint, radius) -- activate trap
				return
			end
		end

        trapDuration = trapDuration + 1;
        print("trap duration incremented")
        if trapDuration == 450 then
        	trapDuration =0 
        	TrapEnd(lancertrap)
        	return 
        end
      	return 0.1
    end
    )
end

function SpringTrap(trap, caster, stunduration, targetpoint, radius)
	Timers:CreateTimer({
		endTime = 1,
		callback = function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
		end
		TrapEnd(trap)
	end
	})
end

function TrapEnd(dummy)
	dummy:RemoveSelf()
	return nil
end

function Conversion(keys)
	local caster = keys.caster
	local currentHealth = caster:GetHealth()
	local currentMana = caster:GetMana()
	local healthLost = currentHealth * keys.Percentage / 100

	caster:SetHealth(currentHealth - healthLost) 
	caster:SetMana(currentMana + healthLost)
end

function IncinerateOnHit(keys)
	local caster = keys.caster
	local target = keys.target

	if target:HasModifier("modifier_lancer_incinerate") then
		local stacks = target:GetModifierStackCount("modifier_lancer_incinerate", nil)
		target:SetModifierStackCount("modifier_lancer_incinerate", nil, stacks+1)
	else
		caster:FindAbilityByName("lancer_5th_rune_of_flame"):ApplyDataDrivenModifier(caster, target, "modifier_lancer_incinerate", {})
	end
end

function GBAttachEffect(keys)
	local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) -- circle effect location
	if keys.ability == caster:FindAbilityByName("lancer_5th_gae_bolg") then
		caster:EmitSound("Lancer.GaeBolg")
	end
end

function OnGBTargetHit(keys)
	local caster = keys.caster
	local target = keys.target
	local dmg = keys.Damage
	local chance = RandomInt(1, 100)
	print(chance)
	if chance <= keys.Chance then 
		dmg = dmg * 2
	end
	local targetdmg = {
		attacker = caster,
		victim = target,
		damage = dmg,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	ApplyDamage(targetdmg)
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
	-- attach blood effect
	local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(blood, 1, target , 0, "attach_hitloc", target:GetAbsOrigin(), false)
end

function OnGBAOEStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local ascendCount = 0
	--[[
	local gaeBolg = {
	    Ability        	 	=   keys.ability,
		EffectName			=	"particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf",
		vSpawnOrigin		=	caster:GetAbsOrigin(),
		fDistance			=	1000,
		fStartRadius		=	500,
		fEndRadius			=	500,
		Source         	 	=   caster,
		bHasFrontalCone		=	false,
		bRepalceExisting 	=  false,
		iUnitTargetTeams		=	"DOTA_UNIT_TARGET_TEAM_ENEMY",
		iUnitTargetTypes		=	"DOTA_UNIT_TARGET_ALL",
		iUnitTargetFlags		=	"DOTA_UNIT_TARGET_FLAG_NONE",
		fExpireTime     =   GameRules:GetGameTime() + 10.0,
		bDeleteOnHit    =   false,
		vVelocity       =   caster:GetForwardVector() * 2000,
		bProvidesVision	=	false,
		iVisionRadius	=	0,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	]]
	local dummy = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
	local dummy_ability = dummy:FindAbilityByName("dummy_unit_passive")
	dummy_ability:SetLevel(1)
	Timers:CreateTimer(1, function() return GaeBolgDummyEnd(dummy) end)

	local info = {
		Target = dummy, -- chainTarget
		Source = caster, -- chainSource
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 2000
	}
	
	EmitGlobalSound("Lancer.GaeBolg")

	-- Handle jump here
	Timers:CreateTimer(function()
		if ascendCount == 50 then 
			--ProjectileManager:CreateLinearProjectile(gaeBolg)
			ProjectileManager:CreateTrackingProjectile(info) 
			GaeBolgDescend(caster) return 
		end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+5))
		ascendCount = ascendCount + 1;
		return 0.01
		end
	)

	

	

	local splashdmg = {
		attacker = caster,
		victim = nil,
		damage = keys.Damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         splashdmg.victim = v
         ApplyDamage(splashdmg)
    end
end

function GaeBolgDescend(caster) 
	local descendCount = 0
	Timers:CreateTimer(function()
		if descendCount == 50 then return end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-5))
		descendCount = descendCount + 1;
		return 0.01
		end
	)
end

function GaeBolgDummyEnd(dummy)
	dummy:RemoveSelf()
	return nil
end

