function OnEternalStart(keys)
end

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
        local ability = keys.ability
        local a1 = caster:GetAbilityByIndex(0)
        local a2 = caster:GetAbilityByIndex(1)
        local a3 = caster:GetAbilityByIndex(2)
        local a4 = caster:GetAbilityByIndex(3)
        local a5 = caster:GetAbilityByIndex(4)
        local a6 = caster:GetAbilityByIndex(5)

        caster:SwapAbilities("lancelot_close_spellbook", a5:GetName(), true,true) 
        caster:AddAbility("lancelot_caliburn")

        caster:GetAbilityByIndex(5):SetLevel(1)
        if ability:GetLevel() == 1 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(1) 
                caster:AddAbility("fate_empty1")
                caster:AddAbility("fate_empty2")
                caster:AddAbility("fate_empty3")
                caster:AddAbility("fate_empty4")

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("fate_empty1", a2:GetName(), true, true) 
                caster:SwapAbilities("fate_empty2", a3:GetName(), true, true) 
                caster:SwapAbilities("fate_empty3", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true) 
        elseif ability:GetLevel() == 2 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(1) 
                caster:AddAbility("lancelot_gae_bolg")
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(1)
                caster:AddAbility("fate_empty2")
                caster:AddAbility("fate_empty3")
                caster:AddAbility("fate_empty4")

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("fate_empty2", a3:GetName(), true, true) 
                caster:SwapAbilities("fate_empty3", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true)                 
        elseif ability:GetLevel() == 3 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(1) 
                caster:AddAbility("lancelot_gae_bolg")
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(1)
                caster:AddAbility("lancelot_nine_lives")
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(1)
                caster:AddAbility("fate_empty3")
                caster:AddAbility("fate_empty4")

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("fate_empty3", a3:GetName(), true, true) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true)               
        elseif ability:GetLevel() == 4 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(1) 
                caster:AddAbility("lancelot_gae_bolg")
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(1)
                caster:AddAbility("lancelot_nine_lives")
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(1)
                caster:AddAbility("lancelot_rule_breaker")
                caster:FindAbilityByName("lancelot_rule_breaker"):SetLevel(1)
                caster:AddAbility("fate_empty4")

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("lancelot_rule_breaker", a3:GetName(), true, true) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true)                    
        elseif ability:GetLevel() == 5 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(1) 
                caster:AddAbility("lancelot_gae_bolg")
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(1)
                caster:AddAbility("lancelot_nine_lives")
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(1)
                caster:AddAbility("lancelot_rule_breaker")
                caster:FindAbilityByName("lancelot_rule_breaker"):SetLevel(1)
                caster:AddAbility("lancelot_tsubame_gaeshi")
                caster:FindAbilityByName("lancelot_tsubame_gaeshi"):SetLevel(1)

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("lancelot_rule_breaker", a3:GetName(), true, true) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, true) 
                caster:SwapAbilities("lancelot_tsubame_gaeshi", a6:GetName(), true, true) 
        end
end

function OnKnightClosed(keys)
        local caster = keys.caster
        local a1 = caster:GetAbilityByIndex(0)
        local a2 = caster:GetAbilityByIndex(1)
        local a3 = caster:GetAbilityByIndex(2)
        local a4 = caster:GetAbilityByIndex(3)
        local a5 = caster:GetAbilityByIndex(4)
        local a6 = caster:GetAbilityByIndex(5)

        caster:SwapAbilities(a1:GetName(), "lancelot_smg_barrage", true ,true) 
        caster:SwapAbilities(a2:GetName(), "lancelot_double_edge", true, true) 
        caster:SwapAbilities(a3:GetName(), "lancelot_knight_of_honor", true, true) 
        caster:SwapAbilities(a4:GetName(), "rubick_empty1", true, true) 
        caster:SwapAbilities(a5:GetName(), "lancelot_arms_mastership", true, true) 
        caster:SwapAbilities(a6:GetName(), "lancelot_arondite", true, true )       

        caster:RemoveAbility("lancelot_caliburn") 
        caster:RemoveAbility("lancelot_gae_bolg") 
        caster:RemoveAbility("lancelot_rule_breaker") 
        caster:RemoveAbility("lancelot_nine_lives")
        caster:RemoveAbility("lancelot_tsubame_gaeshi")  
        caster:RemoveAbility("fate_empty1")  
        caster:RemoveAbility("fate_empty2") 
        caster:RemoveAbility("fate_empty3") 
        caster:RemoveAbility("fate_empty4") 
end

function OnKnightLevelUp(keys)
end

function OnAronditeStart(keys)
        local caster = keys.caster

        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
                DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
        end
end

function OnFairyDmgTaken(keys)
        local caster = keys.caster
        if caster:GetHealth() < 500 and caster:IsAlive() and caster:FindAbilityByName("lancelot_blessing_of_fairy"):IsCooldownReady() then 
                caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
                keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_fairy_magic_immunity", {}) 
                keys.ability:StartCooldown(45)
        end
end

function OnEternalImproved(keys)
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local hero = caster:GetPlayerOwner():GetAssignedHero()
        ply.IsEternalImproved = true
end

function OnBlessingAcquired(keys)
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local hero = caster:GetPlayerOwner():GetAssignedHero()
        hero:AddAbility("lancelot_blessing_of_fairy") 
        hero:FindAbilityByName("lancelot_blessing_of_fairy"):SetLevel(1) 
        hero:SwapAbilities("rubick_empty1", "lancelot_blessing_of_fairy", true, true) 
        hero:RemoveAbility("rubick_empty1") 
end

function OnKnightImproved(keys)
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local hero = caster:GetPlayerOwner():GetAssignedHero()
        if ply.KnightLevel == nil then
                ply.KnightLevel = 1
        else
                ply.KnightLevel = 2
        end 
end

function OnTAAcquired(keys)
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local hero = caster:GetPlayerOwner():GetAssignedHero()
        ply.IsTAAcquired = true
end