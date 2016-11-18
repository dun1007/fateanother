ATTR_NSS_BONUS_DAMAGE = 150
ATTR_NSS_STACK_DAMAGE_PERCENTAGE = 10
ATTR_AGI_RATIO = 2.0
ATTR_MANA_REFUND = 200

function OnMartialStart(keys)
	local caster = keys.caster
	local target = keys.target
	local duration = keys.Duration
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	giveUnitDataDrivenModifier(caster, target, "silenced", duration)
	ApplyMarkOfFatality(caster, target)
	if caster:GetName() == "npc_dota_hero_bloodseeker" then
		GrantCosmicOrbitResist(caster)
		if caster.bIsFuriousChainAcquired then
			GrantFuriousChainBuff(caster) 
		end
	end
	target:EmitSound("Hero_Nightstalker.Void")
end

function OnMartialAttackStart(keys)
	local caster = keys.caster
	local target = keys.target
	local chance = keys.Chance
	local ability = keys.ability
	if not target:HasModifier("modifier_mark_of_fatality") then return end
	local roll = math.random(100)
	if roll < chance then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_martial_arts_crit_hit", {})
	end
end

function OnMartialAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability:GetLevel() == 2 and target:HasModifier("modifier_mark_of_fatality") then
		DoDamage(caster, target, target:GetMaxHealth() * 3.5/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end

end

function ApplyMarkOfFatality(caster,target)
	local abil = caster:FindAbilityByName("lishuwen_martial_arts")
	SpawnAttachedVisionDummy(caster, target, abil:GetLevelSpecialValueFor("vision_radius", abil:GetLevel()-1 ), abil:GetLevelSpecialValueFor("duration", abil:GetLevel()-1 ), false)

	-- add new stack
	local currentStack = target:GetModifierStackCount("modifier_mark_of_fatality", abil)
	target:RemoveModifierByName("modifier_mark_of_fatality") 
	abil:ApplyDataDrivenModifier(caster, target, "modifier_mark_of_fatality", {}) 
	target:SetModifierStackCount("modifier_mark_of_fatality", abil, currentStack + 1)
end

function GrantFuriousChainBuff(caster)
	local abil = caster:FindAbilityByName("lishuwen_martial_arts")
	-- add new stack
	local currentStack = caster:GetModifierStackCount("modifier_furious_chain_buff", abil)
	caster:RemoveModifierByName("modifier_furious_chain_buff") 
	abil:ApplyDataDrivenModifier(caster, caster, "modifier_furious_chain_buff", {}) 
	caster:SetModifierStackCount("modifier_furious_chain_buff", abil, currentStack + 1)
end


function GrantCosmicOrbitResist(caster)
	local abil = caster:FindAbilityByName("lishuwen_cosmic_orbit")
	abil:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit_momentary_resistance", {})
	caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")
end

function OnBerserkStart(keys)
    local caster = keys.caster
    if caster.bIsDualClassAcquired ~= true then
        keys.ability:EndCooldown()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Attribute_Not_Earned")
        return
    end

    if IsRevoked(caster) then
        keys.ability:EndCooldown()
        SendErrorMessage(caster:GetPlayerOwnerID(), "#Revoked_Error")
        return
    end
    GrantCosmicOrbitResist(caster)
	if caster.bIsFuriousChainAcquired then
		GrantFuriousChainBuff(caster) 
	end
   	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_berserk", {})
    HardCleanse(caster)
    caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")
    local dispel = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( dispel, 1, caster:GetAbsOrigin())
    -- Destroy particle after delay
    Timers:CreateTimer( 2.0, function()
        ParticleManager:DestroyParticle( dispel, false )
        ParticleManager:ReleaseParticleIndex( dispel )
    end)
end


function OnConcealmentStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	GrantCosmicOrbitResist(caster)
	LishuwenCheckCombo(caster, ability)
	local stopOrder = {
		UnitIndex = keys.caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
	-- grant invisibility and regen modifier
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_concealment", {})
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk")
end

function OnConcealmentBroken(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_lishuwen_concealment") then caster:RemoveModifierByName("modifier_lishuwen_concealment") end
end

function OnCosmicOrbitStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	GrantCosmicOrbitResist(caster)
	LishuwenCheckCombo(caster, ability)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit", {})
	caster:EmitSound("Hero_Sven.WarCry")
end

function OnCosmicOrbitAttackLanded(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.nBaseAttackCount == nil then
		caster.nBaseAttackCount = 0
	end


	if caster.nBaseAttackCount == 3 then
		if not caster:HasModifier("modifier_lishuwen_cosmic_orbit_silence_cooldown") then
			keys.Duration = 1.5
			OnMartialStart(keys)
			caster.nBaseAttackCount = 0
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit_silence_cooldown", {}) 
		end
	else
		caster.nBaseAttackCount = caster.nBaseAttackCount + 1
	end
end

function OnTigerStrikeLevelUp(keys)
	local caster = keys.caster
	local ability = keys.ability

	local t2 = caster:FindAbilityByName("lishuwen_fierce_tiger_strike_2")
	t2:SetLevel(ability:GetLevel())


	local t3 = caster:FindAbilityByName("lishuwen_fierce_tiger_strike_3")
	t3:SetLevel(ability:GetLevel())
end


function OnTigerStrike1Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	if caster.bIsMartialArtsImproved then
		ApplyMarkOfFatality(caster, target)
	end

	local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
	ParticleManager:SetParticleControl( trailFx, 1, caster:GetAbsOrigin() )
	-- do damage and apply CC
	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
	FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( trailFx, 0, target:GetAbsOrigin() )

	if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
		if target:HasModifier("modifier_mark_of_fatality") then
			caster:SetMana(caster:GetMana()+ATTR_MANA_REFUND)
		end
	end
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	if not IsImmuneToSlow(target) then ability:ApplyDataDrivenModifier(caster, target, "modifier_fierce_tiger_strike_1_slow", {}) end
	-- switch strike 1 with 2
	caster:SwapAbilities("lishuwen_fierce_tiger_strike", "lishuwen_fierce_tiger_strike_2", false, true) 
	caster.bIsCurrentTSCycleFinished = false
	-- start a timer to revert layout back after set time(4 sec)
    Timers:CreateTimer('fierce_tiger_timer', {
        endTime = 4,
        callback = function()
		local currentAbil = caster:GetAbilityByIndex(2)
		if currentAbil:GetAbilityName() ~= "lishuwen_fierce_tiger_strike" or not caster.bIsTSCycleFinished then
			caster:SwapAbilities("lishuwen_fierce_tiger_strike",currentAbil:GetAbilityName() , true, false) 
		end
	end})
	-- if ability index 3 is not lishuwen_fierce_tiger_strike, swap current index 3 with lishuwen_fierce_tiger_strike
	caster:EmitSound("Hero_EarthShaker.Attack")
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_first_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
    --ParticleManager:SetParticleControlOrientation(groundFx, 0, RandomVector(300), Vector(0,1,0), Vector(1,0,0))
end


function OnTigerStrike2Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	if caster.bIsMartialArtsImproved then
		ApplyMarkOfFatality(caster, target)
	end
	if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
		if target:HasModifier("modifier_mark_of_fatality") then
			caster:SetMana(caster:GetMana()+ATTR_MANA_REFUND)
		end
	end
	-- do damage and apply CC
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	keys.target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 0.1})
	-- switch strike 1 with 2
	caster:SwapAbilities("lishuwen_fierce_tiger_strike_2", "lishuwen_fierce_tiger_strike_3", false, true) 
	caster:EmitSound("Hero_EarthShaker.Fissure")
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_second_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnTigerStrike3Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	if caster.bIsMartialArtsImproved then
		ApplyMarkOfFatality(caster, target)
	end

	-- do damage and apply CC
	local damage = target:GetMaxHealth()*keys.DamagePercent/100
	if caster.bIsFuriousChainAcquired then
		damage = damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
		if target:HasModifier("modifier_mark_of_fatality") then
			caster:SetMana(caster:GetMana()+ATTR_MANA_REFUND)
		end
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
	if not IsImmuneToSlow(target) then ability:ApplyDataDrivenModifier(caster, target, "modifier_fierce_tiger_strike_3_slow", {}) end
	Timers:RemoveTimer('fierce_tiger_timer')
	-- switch strike 1 with 2
	caster:SwapAbilities("lishuwen_fierce_tiger_strike_3", "lishuwen_fierce_tiger_strike", false, true) 

	caster:EmitSound("Hero_EarthShaker.Totem")
    local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx1, 1, target:GetAbsOrigin())
    local groundFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx2, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControlOrientation(groundFx1, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    ParticleManager:SetParticleControlOrientation(groundFx2, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_third_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnNSSCastStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local windupFx = ParticleManager:CreateParticle( "particles/custom/lishuwen/lishuwen_no_second_strike_windup.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( windupFx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( windupFx, 3, caster:GetAbsOrigin())

    Timers:CreateTimer(keys.CastDelay, function()
		ParticleManager:DestroyParticle( windupFx, false )
		ParticleManager:ReleaseParticleIndex( windupFx )
    end)
end

function OnNSSStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster.ProcDamage = keys.ProcDamage
	caster.ProcStunDuration = keys.ProcStunDuration
	target.IsNSSProcReady = true
	if caster:HasModifier("modifier_lishuwen_berserk") then
		keys.ability:EndCooldown()
		caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(1))
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return			
	end
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	if caster.bIsMartialArtsImproved then
		ApplyMarkOfFatality(caster, target)
	end
	-- do damage and apply CC
	local damage = keys.Damage
	if caster.bIsCirculatoryShockAcquired then
		damage = damage + ATTR_NSS_BONUS_DAMAGE
	end
	if caster.bIsFuriousChainAcquired then
		damage = damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
		if target:HasModifier("modifier_mark_of_fatality") then
			caster:SetMana(caster:GetMana()+ATTR_MANA_REFUND)
		end
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_no_second_strike_delay_indicator", {})
	-- apply delay indicator

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_no_second_strike_anim", {})
	EmitGlobalSound("Lishuwen.NoSecondStrike")
    local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx1, 1, target:GetAbsOrigin())
    local groundFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx2, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControlOrientation(groundFx1, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    ParticleManager:SetParticleControlOrientation(groundFx2, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_no_second_strike_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnNSSTakeDamage(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local attacker = keys.attacker
	local damage = keys.ProcDamage
	local stunDuration = keys.ProcStunDuration

	if attacker:GetName() == "npc_dota_hero_bloodseeker" and target.IsNSSProcReady then
		target.IsNSSProcReady = false
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = stunDuration})
		DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
		Timers:CreateTimer(caster.ProcStunDuration + 0.3, function()
			target.IsNSSProcReady = true
		end)

		target:EmitSound("hero_bloodseeker.rupture.cast")
	end
end

function OnNSSDelayFinished(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = 0

	if caster.bIsCirculatoryShockAcquired ~= true then return end --If without circulatory shock attribute, no damage at end of open_wound_duration (3.5s).
	--[[local damage = target:GetMana() * keys.DelayedDamagePercentage/100
	if target:GetName() == "npc_dota_hero_juggernaut" or target:GetName() == "npc_dota_hero_shadow_shaman" then
		damage = (target:GetMaxHealth() - target:GetHealth()) * keys.DelayedDamagePercentage/100
	end]]

	if target:HasModifier("modifier_mark_of_fatality") then
		local abil = caster:FindAbilityByName("lishuwen_martial_arts")
		local currentStack = target:GetModifierStackCount("modifier_mark_of_fatality", abil)
		damage = (target:GetMaxHealth() - target:GetHealth()) * ATTR_NSS_STACK_DAMAGE_PERCENTAGE * currentStack/100
	end
	print("dealt "	.. damage .. " damage")
	--target:SetMana(target:GetMana() - damage)
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	--target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.DelayedStunDuration})

	local manaBurnFx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
	target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
	-- do damage and apply CC
end

function OnDragonStrike1Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	caster:FindAbilityByName("lishuwen_fierce_tiger_strike"):StartCooldown(29)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
		if target:HasModifier("modifier_mark_of_fatality") then
			caster:SetMana(caster:GetMana()+ATTR_MANA_REFUND)
		end
	end

	caster.targetTable = {} 
	-- fire linear projectile 
	local projectile = 
	{
		Ability = keys.ability,
        EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
        iMoveSpeed = 9999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() - 150, -- give 50 unit buffer 
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 0.1,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 9999
	}
	ProjectileManager:CreateLinearProjectile(projectile)

	-- Wait 1 frame to receive target info
	Timers:CreateTimer(0.033, function()
		local startpoint = caster:GetAbsOrigin()
		local endpoint = nil
		for k,v in pairs(caster.targetTable) do
			DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			endpoint = v:GetAbsOrigin()
			local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, v )
			ParticleManager:SetParticleControl( trailFx, 1, startpoint )
			ParticleManager:SetParticleControl( trailFx, 0, endpoint )
			startpoint = v:GetAbsOrigin()
			v:EmitSound("Hero_EarthShaker.Attack")
		end
		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	end)

	caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_raging_dragon_strike_2", false, true) 
	caster.bIsCurrentDSCycleFinished = false
	caster.bIsCurrentDSCycleStarted = true


	-- start a timer to revert layout back after set time(4 sec)
    --[[Timers:CreateTimer('raging_dragon_timer', {
        endTime = 4,
        callback = function()
		local currentAbil = caster:GetAbilityByIndex(2)
		if currentAbil:GetAbilityName() ~= "lishuwen_raging_dragon_strike" or not caster.bIsCurrentDSCycleFinished then
			caster:SwapAbilities("lishuwen_fierce_tiger_strike",currentAbil:GetAbilityName() , true, false) 
		end
	end})]]

	caster:EmitSound("Hero_EarthShaker.Attack")
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_first_hit.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, target:GetAbsOrigin())
end

function OnDragonStrike1ProjectileHit(keys)
	local caster = keys.caster
	local target = keys.target 
	table.insert(caster.targetTable,target)
end

function OnDragonStrike2Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	GrantCosmicOrbitResist(caster)
	caster:SwapAbilities("lishuwen_raging_dragon_strike_2", "lishuwen_raging_dragon_strike_3", false, true) 
	if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		if v:HasModifier("modifier_mark_of_fatality") then v:AddNewModifier(caster, v, "modifier_stunned", {Duration = keys.StunDuration}) end
	end
	caster:EmitSound("Hero_Centaur.HoofStomp")
	local risingWindFx = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_second_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, caster:GetAbsOrigin())
end

vectors = {
	Vector(500, 500, 500),
	Vector(-500,-500,300),
	Vector(500,-500,400),
	Vector(-300, 400, 500),
	Vector(0,-500, 500),
	Vector(300, 0, 400),
	Vector(500, 500, 500),
	Vector(-500,-500,300),
	Vector(-300, 400, 500),
	Vector(500, 500, 500),
	Vector(-500,-500,300),
	Vector(500,-500,400),
	Vector(-300, 400, 500),
	Vector(0,-500, 500),
	Vector(0,0, 0)
}
--vectorsV2[i] = vectors[i]-vectors[i-1], if i-1==0, then vectors[i-1] == (0,0,0), vectors sum up to 0 for V2.
vectorsV2 = {
	Vector(500, 500, 500),
	Vector(-1000,-1000,-200),
	Vector(1000,0,100),
	Vector(-800, 900, 100),
	Vector(300,-900, 0),
	Vector(300, 500, -100),
	Vector(200, 500, 100),
	Vector(-1000,-1000,-200),
	Vector(200, 900, 200),
	Vector(800, 100, 0),
	Vector(-1000,-1000,-200),
	Vector(1000,0,100),
	Vector(-800, 900, 100),
	Vector(300,-900, 0),
	Vector(0,500, -500)
}

function OnDragonStrike3Start(keys)
	local caster = keys.caster
	local ability = keys.ability
	GrantCosmicOrbitResist(caster)
	caster.bIsCurrentDSCycleFinished = true
	Timers:RemoveTimer('raging_dragon_timer')
	caster:SwapAbilities("lishuwen_fierce_tiger_strike","lishuwen_raging_dragon_strike_3", true, true) 
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	if #targets == 0 then 

    	local abil = caster:FindAbilityByName("lishuwen_raging_dragon_strike")
    	ReduceCooldown(abil, abil:GetCooldown(1)*0.75)
    	caster:RemoveModifierByName("modifier_raging_dragon_strike_cooldown")
    	abil:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_cooldown", {duration = abil:GetCooldown(abil:GetLevel())*0.25})
		local masterabil = caster.MasterUnit2:FindAbilityByName("lishuwen_raging_dragon_strike")
		masterabil:EndCooldown()
		masterabil:StartCooldown(masterabil:GetCooldown(1)*0.25)    
		return 
	end

	local endpoint = nil
	local counter = 0

	if caster.bIsFuriousChainAcquired then
		keys.Damage = keys.Damage + caster:GetAgility() * ATTR_AGI_RATIO
		GrantFuriousChainBuff(caster) 
	end
	-- knock them up and create counter
	for k,v in pairs(targets) do
		v.nDragonStrikeComboCount = 0
		ApplyAirborne(caster, v, keys.KnockupDuration)
	end

	giveUnitDataDrivenModifier(keys.caster, keys.caster, "jump_pause", keys.KnockupDuration)

	Timers:CreateTimer(0.2, function()
		if counter == 15 then 
			FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
			return 
		end

		local target = nil

		for i=1, #targets do
			local curIndex = math.random(#targets)
			if targets[curIndex].nDragonStrikeComboCount < 8 then
				targets[curIndex].nDragonStrikeComboCount = targets[curIndex].nDragonStrikeComboCount + 1
				target = targets[curIndex]
				break
			end
		end
		--[[for k,v in pairs(targets) do
			if v.nDragonStrikeComboCount < 8 then
				v.nDragonStrikeComboCount = v.nDragonStrikeComboCount + 1
				target = v
			end
		end]]
		
		if target ~= nil then
			--print(target:GetName() .. counter)
			DoCompositeDamage(caster, target, keys.Damage, DAMAGE_TYPE_COMPOSITE, 0, keys.ability, false)
			ApplyMarkOfFatality(caster, target)
		end



		--newpoint = Vector(startpoint.x + RandomInt(1,600), startpoint.y + RandomInt(1, 600), startpoint.y+500)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_3_anim", {})
		local currentpoint = caster:GetAbsOrigin()
		local newpoint = currentpoint+vectorsV2[counter+1]*0.5
		caster:SetAbsOrigin(newpoint)
		local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( trailFx, 1, currentpoint )
		ParticleManager:SetParticleControl( trailFx, 0, newpoint )

		if target ~= nil then
		    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN, target )
		    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
	   	end
		caster:EmitSound("Hero_Tusk.WalrusPunch.Target")
		counter = counter + 1
		return 0.08
	end)

	caster:EmitSound("Hero_Earthshaker.Pick")
	EmitGlobalSound("Lishuwen.Shout")
    local groundFx1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( groundFx1, 1, caster:GetAbsOrigin())
    local groundFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControl( groundFx2, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControlOrientation(groundFx1, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    ParticleManager:SetParticleControlOrientation(groundFx2, 0, RandomVector(3), Vector(0,1,0), Vector(1,0,0))
    local firstStrikeFx = ParticleManager:CreateParticle("particles/custom/lishuwen/lishuwen_third_hit.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( firstStrikeFx, 0, caster:GetAbsOrigin())
end

function LishuwenCheckCombo(caster, ability)
    if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
        --[[if ability == caster:FindAbilityByName("lishuwen_concealment") then
            QUsed = true
            Qtime = GameRules:GetGameTime()
            Timers:CreateTimer({
                endTime = 4,
                callback = function()
                QUsed = false
            end
            })
        else]]
    	if ability == caster:FindAbilityByName("lishuwen_cosmic_orbit") and caster:FindAbilityByName("lishuwen_raging_dragon_strike"):IsCooldownReady() and caster:FindAbilityByName("lishuwen_fierce_tiger_strike"):IsCooldownReady() and caster:GetAbilityByIndex(2):GetName() == "lishuwen_fierce_tiger_strike" then
            caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_fierce_tiger_strike", true, false) 
            Timers:CreateTimer('raging_dragon_timer',{
                endTime = 4,
                callback = function()
                if not caster.bIsCurrentDSCycleFinished and caster.bIsCurrentDSCycleStarted then
                	local abil = caster:FindAbilityByName("lishuwen_raging_dragon_strike")
                	ReduceCooldown(abil, abil:GetCooldown(1)*0.75)
                	caster:RemoveModifierByName("modifier_raging_dragon_strike_cooldown")
                	abil:ApplyDataDrivenModifier(caster, caster, "modifier_raging_dragon_strike_cooldown", {duration = abil:GetCooldown(abil:GetLevel())*0.25})
					local masterabil = caster.MasterUnit2:FindAbilityByName("lishuwen_raging_dragon_strike")
					masterabil:EndCooldown()
					masterabil:StartCooldown(masterabil:GetCooldown(1)*0.25)            	
                end	
				local currentAbil = caster:GetAbilityByIndex(2)	
				caster:SwapAbilities("lishuwen_fierce_tiger_strike",currentAbil:GetAbilityName() , true, false)
				caster.bIsCurrentDSCycleStarted = false
            end
            })
        end
    end
end

function OnCirculatoryShockAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.bIsCirculatoryShockAcquired = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMartialArtsImproved(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.bIsMartialArtsImproved = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	hero:FindAbilityByName("lishuwen_martial_arts"):SetLevel(2)
	AuraRefresh(keys)
	-- allow NSS and FTS to apply mark of fatality
end

function OnDualClassAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.bIsDualClassAcquired = true
	hero:SwapAbilities("lishuwen_berserk", "fate_empty1", true, true) 
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnFuriousChainAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.bIsFuriousChainAcquired = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	-- AGI scaling and mana refund on abilities
	-- aspd and ms buff
end

function AuraRefresh(keys)
	local hero = keys.caster:GetPlayerOwner():GetAssignedHero()
	hero:RemoveModifierByName("modifier_martial_arts_aura") 
	hero:FindAbilityByName("lishuwen_martial_arts"):ApplyDataDrivenModifier(hero, hero, "modifier_martial_arts_aura", {}) 
end