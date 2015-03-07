function OnSMGStart(keys)
       --[[print("dudududu")
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	local smg = 
	{
        	Ability = keys.ability,
                EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
                iMoveSpeed = 2000,
                vSpawnOrigin = nil,
                fDistance = 500,
                fStartRadius = 100,
                fEndRadius = keys.EndRadius,
                Source = caster:GetAbsOrigin(),
                bHasFrontalCone = true,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                iUnitTargetType = DOTA_UNIT_TARGET_ALL,
                fExpireTime = GameRules:GetGameTime() + 2.0,
        	bDeleteOnHit = false,
        	vVelocity = frontward * 2000
	}
	smg.vSpawnOrigin = caster:GetAbsOrigin() 
	ProjectileManager:CreateLinearProjectile(smg)]]
end

function OnSMGHit(keys)
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
        local armorShred = math.floor(target:GetPhysicalArmorBaseValue() * keys.ArmorShred/100)
        target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() - armorShred)
        Timers:CreateTimer( keys.Duration, function()
                target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() + armorShred) 
                return
        end)
end

function OnDEStart(keys)
end

function OnKnightStart(keys)
        local caster = keys.caster
        local a1 = caster:GetAbilityByIndex(0)
        local a2 = caster:GetAbilityByIndex(1)
        local a3 = caster:GetAbilityByIndex(2)
        local a4 = caster:GetAbilityByIndex(3)
        local a5 = caster:GetAbilityByIndex(4)
        local a6 = caster:GetAbilityByIndex(5)

        caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
        caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
        caster:SwapAbilities("lancelot_rule_breaker", a3:GetName(), true, true) 
        caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, true) 
        caster:SwapAbilities("lancelot_close_spellbook", a5:GetName(), true,true) 
        caster:SwapAbilities("lancelot_tsubame_gaeshi", a6:GetName(), true, true) 
end

function OnKnightLevelUp(keys)
end

function OnAronditeStart(keys)
end