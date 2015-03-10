function OnEternalStart(keys)
end

function OnSMGStart(keys)
    LancelotCheckCombo(keys.caster, keys.ability)
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
    LancelotCheckCombo(keys.caster, keys.ability)
end


function OnKnightStart(keys)
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local ability = keys.ability
        if caster:HasModifier("modifier_arondite") then
                FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Be Used" } )
                return 
        end


        local a1 = caster:GetAbilityByIndex(0)
        local a2 = caster:GetAbilityByIndex(1)
        local a3 = caster:GetAbilityByIndex(2)
        local a4 = caster:GetAbilityByIndex(3)
        local a5 = caster:GetAbilityByIndex(4)
        local a6 = caster:GetAbilityByIndex(5)

        local NPLevel = 1
        if ply.KnightLevel ~= nil then NPLevel = NPLevel + ply.KnightLevel end
        
        caster:SwapAbilities("lancelot_close_spellbook", a5:GetName(), true,true) 
        caster:GetAbilityByIndex(5):SetLevel(1)
        if ability:GetLevel() == 1 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(NPLevel) 
                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true)

                caster:SwapAbilities("fate_empty1", a2:GetName(), true, true) 
                caster:SwapAbilities("fate_empty2", a3:GetName(), true, true) 
                caster:SwapAbilities("fate_empty3", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true) 
        elseif ability:GetLevel() == 2 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("fate_empty2", a3:GetName(), true, true) 
                caster:SwapAbilities("fate_empty3", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true)                 
        elseif ability:GetLevel() == 3 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(NPLevel)

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("fate_empty3", a3:GetName(), true, true) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true)               
        elseif ability:GetLevel() == 4 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_rule_breaker"):SetLevel(NPLevel)
                caster:AddAbility("fate_empty4")

                caster:SwapAbilities("lancelot_caliburn", a1:GetName(), true, true) 
                caster:SwapAbilities("lancelot_gae_bolg", a2:GetName(), true, true) 
                caster:SwapAbilities("lancelot_rule_breaker", a3:GetName(), true, true) 
                caster:SwapAbilities("lancelot_nine_lives", a4:GetName(), true, true) 
                caster:SwapAbilities("fate_empty4", a6:GetName(), true, true)                    
        elseif ability:GetLevel() == 5 then
                caster:FindAbilityByName("lancelot_caliburn"):SetLevel(NPLevel) 
                caster:FindAbilityByName("lancelot_gae_bolg"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_nine_lives"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_rule_breaker"):SetLevel(NPLevel)
                caster:FindAbilityByName("lancelot_tsubame_gaeshi"):SetLevel(NPLevel)

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
end

function KnightInitialize(keys)
        local caster = keys.caster
        local ability = keys.ability

        if caster.KnightInitialized ~= true then
                print("knight initialized")
                caster:RemoveAbility("lancelot_caliburn") 
                caster:RemoveAbility("lancelot_gae_bolg") 
                caster:RemoveAbility("lancelot_nine_lives") 
                caster:RemoveAbility("lancelot_rule_breaker") 
                caster:RemoveAbility("lancelot_tsubame_gaeshi") 
                caster.KnightInitialized = true
        end

        if ability:GetLevel() == 1 then
                print("ability lvl 1")
                caster:AddAbility("lancelot_caliburn")
                caster:AddAbility("fate_empty1")
                caster:AddAbility("fate_empty2")
                caster:AddAbility("fate_empty3")
                caster:AddAbility("fate_empty4")
        elseif ability:GetLevel() == 2 then
                caster:RemoveAbility("fate_empty1")
                --caster:AddAbility("lancelot_caliburn")
                caster:AddAbility("lancelot_gae_bolg")
        elseif ability:GetLevel() == 3 then
                caster:RemoveAbility("fate_empty2")
                --caster:AddAbility("lancelot_caliburn")
               -- caster:AddAbility("lancelot_gae_bolg")
                caster:AddAbility("lancelot_nine_lives")
        elseif ability:GetLevel() == 4 then
                caster:RemoveAbility("fate_empty3") 
                --caster:AddAbility("lancelot_caliburn")
                --caster:AddAbility("lancelot_gae_bolg")
                --caster:AddAbility("lancelot_nine_lives")
                caster:AddAbility("lancelot_rule_breaker")
        elseif ability:GetLevel() == 5 then
                caster:RemoveAbility("fate_empty4")
                --caster:AddAbility("lancelot_caliburn")
                --caster:AddAbility("lancelot_gae_bolg")
                --caster:AddAbility("lancelot_nine_lives")
                --caster:AddAbility("lancelot_rule_breaker")
                caster:AddAbility("lancelot_tsubame_gaeshi")
        end
end

function OnKnightUsed(keys)
        print("dududu")
        local caster = keys.caster
        local ply = caster:GetPlayerOwner()
        local ability = keys.ability
        if ply.KnightLevel == nil then
                OnKnightClosed(keys)
                caster:FindAbilityByName("lancelot_knight_of_honor"):StartCooldown(ability:GetCooldown(ability:GetLevel())) 
        end
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

function OnNukeStart(keys)
    local caster = keys.caster
    local targetPoint = keys.target_points[1]
    EmitGlobalSound("Lancelot.Nuke_Alert") 

    local nukemsg = {
        message = "Engaging Enemy, HQ.",
        duration = 2.0
    }
    FireGameEvent("show_center_message",nukemsg)


    local visiondummy = CreateUnitByName("sight_dummy_unit", targetPoint, false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
    visiondummy:SetDayTimeVisionRange(1500)
    visiondummy:SetNightTimeVisionRange(1500)
    visiondummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 8})

    local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
    unseen:SetLevel(1)
    local nukeMarker = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( nukeMarker, 0, targetPoint)
    ParticleManager:SetParticleControl( nukeMarker, 1, Vector(300, 300, 300))

    -- Create F16 nunit
    Timers:CreateTimer(1.97, function()
        EmitGlobalSound("Lancelot.Nuke_Beep")
        -- Set up unit
        f16 = CreateUnitByName("f16_dummy", targetPoint, true, nil, nil, caster:GetTeamNumber())
        LevelAllAbility(f16)
        FindClearSpaceForUnit(f16, f16:GetAbsOrigin(), true)
        f16:SetAbsOrigin(targetPoint)
        Timers:CreateTimer(0.033, function()
            f16:EmitSound("Hero_Gyrocopter.Rocket_Barrage")
        end)
    end)
    
    
    -- Move jet around
    local flyCount = 0
    local t = 0
    Timers:CreateTimer(2.0, function()
        if flyCount == 121 then f16:ForceKill(true) return end
        t = t+0.12
        SpinInCircle(f16, targetPoint, t, 650)
        flyCount = flyCount + 1
        return 0.033
    end)

    local barrageCount = 0
    Timers:CreateTimer(2.0, function()
        if flyCount == 121 then f16:ForceKill(true) return end
        local barrageVec1 = RandomVector(RandomInt(100, 800))
        local targets1 = FindUnitsInRadius(caster:GetTeam(), targetPoint + barrageVec1, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets1) do
            DoDamage(caster, v, 300, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
            v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.50})
        end
        -- particle
        local barrageImpact1 = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
        ParticleManager:SetParticleControl( barrageImpact1, 0, targetPoint+barrageVec1)
        visiondummy:EmitSound("Hero_Gyrocopter.Rocket_Barrage.Launch")
        barrageCount = barrageCount + 1
        return 0.033
    end)

    Timers:CreateTimer(4.5, function()
        EmitGlobalSound("Lancelot.TacticalNuke") 
    end)

    Timers:CreateTimer(7.0, function()
        EmitGlobalSound("Hero_Gyrocopter.CallDown.Damage") 
        local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 1500, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
        for k,v in pairs(targets) do
            DoDamage(caster, v, 2000, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
            v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.0})
        end
        -- particle
        local impactFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", PATTACH_CUSTOMORIGIN, caster )
        ParticleManager:SetParticleControl( impactFxIndex, 0, targetPoint)
        ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(2500, 2500, 1500))
        ParticleManager:SetParticleControl( impactFxIndex, 2, Vector(2500, 2500, 2500))
        ParticleManager:SetParticleControl( impactFxIndex, 3, targetPoint)
        ParticleManager:SetParticleControl( impactFxIndex, 4, Vector(2500, 2500, 2500))
        ParticleManager:SetParticleControl( impactFxIndex, 5, Vector(2500, 2500, 2500))
    end)
end

function SpinInCircle(unit, center, t, multiplier)
    local x = math.cos(t) * multiplier
    local y = math.sin(t) * multiplier
    unit:SetAbsOrigin(Vector(center.x + x, center.y + y, 750))
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
                keys.ability:EndCooldown()
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

function LancelotCheckCombo(caster, ability)
    if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
        if ability == caster:FindAbilityByName("lancelot_double_edge") then
            WUsed = true
            WTime = GameRules:GetGameTime()
            Timers:CreateTimer({
                endTime = 3,
                callback = function()
                WUsed = false
            end
            })
        elseif ability == caster:FindAbilityByName("lancelot_smg_barrage") and caster:FindAbilityByName("lancelot_nuke"):IsCooldownReady()  then
            if WUsed == true then 
                caster:SwapAbilities("lancelot_nuke", "rubick_empty1", true, true) 
                local newTime =  GameRules:GetGameTime()
                Timers:CreateTimer({
                    endTime = 3,
                    callback = function()
                    caster:SwapAbilities("lancelot_nuke", "rubick_empty1", true, true) 
                    WUsed = false
                end
                })
            end
        end
    end
end