if not Attributes then
    Attributes = class({})
end

function Attributes:Init()
    local v = LoadKeyValues("scripts/npc/attributes.txt")

    -- Default Dota Values
    local DEFAULT_HP_PER_STR = 19
    local DEFAULT_HP_REGEN_PER_STR = 0.03
    local DEFAULT_MANA_PER_INT = 13
    local DEFAULT_MANA_REGEN_PER_INT = 0.04
    local DEFAULT_ARMOR_PER_AGI = 0.14
    local DEFAULT_ATKSPD_PER_AGI = 1

    Attributes.hp_adjustment = v.HP_PER_STR - DEFAULT_HP_PER_STR
    Attributes.hp_regen_adjustment = v.HP_REGEN_PER_STR - DEFAULT_HP_REGEN_PER_STR
    Attributes.mana_adjustment = v.MANA_PER_INT - DEFAULT_MANA_PER_INT
    Attributes.mana_regen_adjustment = v.MANA_REGEN_PER_INT - DEFAULT_MANA_REGEN_PER_INT
    Attributes.armor_adjustment = v.ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI
    Attributes.attackspeed_adjustment = v.ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI
    Attributes.ms_adjustment = v.MS_PER_AGI

    Attributes.additional_movespeed_adjustment = v.MS_PER_STAT
    Attributes.additional_armor_adjustment = v.ARMOR_PER_STAT
    Attributes.additional_mana_regen_adjustment = v.MPREG_PER_STAT
    Attributes.additional_hp_regen_adjustment = v.HPREG_PER_STAT

    Attributes.applier = CreateItem("item_stat_modifier", nil, nil)
end

function Attributes:ModifyIllusionAttackSpeed(illusion, original)
    if not illusion:HasModifier("modifier_attackspeed_bonus_constant") then
        Attributes.applier:ApplyDataDrivenModifier(illusion, illusion, "modifier_attackspeed_bonus_constant", {})
    end

    local attackspeed_stacks = math.abs(illusion:GetAgility() * Attributes.attackspeed_adjustment)
    illusion:SetModifierStackCount("modifier_attackspeed_bonus_constant", Attributes.applier, attackspeed_stacks)
   
    illusion:SetBaseDamageMin(original:GetBaseDamageMin() - illusion:GetAgility())
    illusion:SetBaseDamageMax(original:GetBaseDamageMax() - illusion:GetAgility())

end
function Attributes:ModifyBonuses(hero)

    print("Modifying Stats Bonus of hero "..hero:GetUnitName())

    hero:AddNewModifier(hero, nil, "modifier_movespeed_cap", {})
    hero.STRgained = 0
    hero.AGIgained = 0
    hero.INTgained = 0
    hero.DMGgained = 0
    hero.ARMORgained = 0
    hero.HPREGgained = 0
    hero.MPREGgained = 0
    hero.MSgained = 0
    hero.BaseArmor = hero:GetPhysicalArmorBaseValue()
    hero.BaseMS = hero:GetBaseMoveSpeed()
    Timers:CreateTimer(function()

        if not IsValidEntity(hero) then
            return
        end

        -- Initialize value tracking
        if not hero.custom_stats then
            hero.custom_stats = true
            hero.strength = 0
            hero.agility = 0
            hero.intellect = 0
        end

        -- Get player attribute values
        local strength = hero:GetStrength()
        local agility = hero:GetAgility()
        local intellect = hero:GetIntellect()
        
        -- Base Armor Bonus
        local armor = hero.BaseArmor + agility * Attributes.armor_adjustment + hero.ARMORgained * Attributes.additional_armor_adjustment
        hero:SetPhysicalArmorBaseValue(armor)

        -- Base MS bonus
        local ms = hero.BaseMS + agility * Attributes.ms_adjustment + hero.MSgained * Attributes.additional_movespeed_adjustment
        hero:SetBaseMoveSpeed(ms)

        -- STR
        if strength ~= hero.strength then
            
            -- HP Bonus
            if not hero:HasModifier("modifier_health_bonus") then
                Attributes.applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_bonus", {})
            end

            local health_stacks = math.abs(strength * Attributes.hp_adjustment)
            hero:SetModifierStackCount("modifier_health_bonus", Attributes.applier, health_stacks)

            -- HP Regen Bonus
            if not hero:HasModifier("modifier_health_regen_constant") then
                Attributes.applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_regen_constant", {})
            end

            local health_regen_stacks = math.abs(strength * Attributes.hp_regen_adjustment * 100)
            hero:SetModifierStackCount("modifier_health_regen_constant", Attributes.applier, health_regen_stacks)
        end

        -- AGI
        if agility ~= hero.agility then    
            -- Attack Speed Bonus
            if not hero:HasModifier("modifier_attackspeed_bonus_constant") then
                Attributes.applier:ApplyDataDrivenModifier(hero, hero, "modifier_attackspeed_bonus_constant", {})
            end

            local attackspeed_stacks = math.abs(agility * Attributes.attackspeed_adjustment)
            hero:SetModifierStackCount("modifier_attackspeed_bonus_constant", Attributes.applier, attackspeed_stacks)
        end

        -- INT
        if intellect ~= hero.intellect then
            
            -- Mana Bonus
            if not hero:HasModifier("modifier_mana_bonus") then
                Attributes.applier:ApplyDataDrivenModifier(hero, hero, "modifier_mana_bonus", {})
            end

            local mana_stacks = math.abs(intellect * Attributes.mana_adjustment)
            hero:SetModifierStackCount("modifier_mana_bonus", Attributes.applier, mana_stacks)

            -- Mana Regen Bonus
            if not hero:HasModifier("modifier_base_mana_regen") then
                Attributes.applier:ApplyDataDrivenModifier(hero, hero, "modifier_base_mana_regen", {})
            end

            local mana_regen_stacks = math.abs(intellect * Attributes.mana_regen_adjustment * 100)
            hero:SetModifierStackCount("modifier_base_mana_regen", Attributes.applier, mana_regen_stacks)
        end

        -- Update the stored values for next timer cycle
        hero.strength = strength
        hero.agility = agility
        hero.intellect = intellect

        hero:CalculateStatBonus()

        return 0.25
    end)
end

if not Attributes.applier then Attributes:Init() end