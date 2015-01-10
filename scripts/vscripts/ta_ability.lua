require("Physics")
require("util")

function OnDirkStart(keys)
	local caster = keys.caster
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 700
	}

	local targetCount = 0
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 700
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		targetCount = targetCount + 1
        info.Target = v
        ProjectileManager:CreateTrackingProjectile(info) 
        if targetCount == 7 then return end
    end
end

function OnDirkHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
end

function OnPCDeactivate(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ta_invis")
	--print("conventional")
end

function PCStopOrder(keys)
	--keys.caster:Stop() 
	local stopOrder = {
		UnitIndex = keys.caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
end

function OnDIStart(keys)
end

function OnAmbushStart(keys)
	local caster = keys.caster
	caster:AddNewModifier(caster, caster, "modifier_invisible", {Duration = 12.0})
	TACheckCombo(caster, keys.ability)
end

function OnFirstHitStart(keys)

	Timers:CreateTimer({
		endTime = 1.5,
		callback = function()
		keys.caster:RemoveModifierByName("modifier_first_hit")
	end
	})
end

function OnFirstHitLanded(keys)
	print("dagger landed")
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
end

function OnModStart(keys)
	local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	TACheckCombo(caster, keys.ability) 
	--increase stat
end

function OnStealStart(keys)
	Timers:CreateTimer(0.3, function() DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false) return end)
end

function OnZabStart(keys)
	local caster = keys.caster
	local info = {
		Target = keys.target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_nevermore/nevermore_base_attack.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 700
	}
	ProjectileManager:CreateTrackingProjectile(info) 
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, keys.target:GetAbsOrigin()) -- circle effect location
	EmitGlobalSound("TA.Zabaniya") 
end

function OnZabHit(keys)
	local caster = keys.caster
	local target = keys.target
	local stunduration = keys.StunDuration

	local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(blood, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(blood, 1, target , 0, "attach_hitloc", target:GetAbsOrigin(), false)

	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	caster:Heal(keys.Damage/2, caster)
end

AmbushUsed = false

function TACheckCombo(caster, ability)
	print("we got here")
	if ability == caster:FindAbilityByName("true_assassin_ambush") then
		AmbushUsed = true
		Timers:CreateTimer({
			endTime = 5,
			callback = function()
			AmbushUsed = false
		end
		})
	elseif ability == caster:FindAbilityByName("true_assassin_self_modification") then
		if AmbushUsed == true then 
			caster:SwapAbilities("true_assassin_self_modification", "true_assassin_combo", true, true)
			Timers:CreateTimer({
				endTime = 8,
				callback = function()
				caster:SwapAbilities("true_assassin_self_modification", "true_assassin_combo", true, true)
			end
			})
		end
	end
end

function OnImprovePresenceConcealmentAcquired(keys)
end

function OnProtectionFromWindAcquired(keys)
end

function OnWeakeningVenomAcquired(keys)
end

function OnShadowStrikeAcquired(keys)
end