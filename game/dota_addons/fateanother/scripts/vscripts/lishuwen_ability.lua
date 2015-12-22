function OnMartialStart(keys)
	local caster = keys.caster
	local target = keys.target
	local duration = keys.Duration
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	giveUnitDataDrivenModifier(caster, target, "silenced", duration)
	ApplyMarkOfFatality(caster, target)
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

function GrantCosmicOrbitResist(caster)
	local abil = caster:FindAbilityByName("lishuwen_cosmic_orbit")
	abil:ApplyDataDrivenModifier(caster, caster, "modifier_lishuwen_cosmic_orbit_momentary_resistance", {})
	caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")
end

function OnConcealmentStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	GrantCosmicOrbitResist(caster)
	LishuwenCheckCombo(caster, ability)
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

function OnTigerStrike1Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	-- apply mark of fatality if attribute was acquired
	--[[if IsMarkAcquired then
		ApplyMarkOfFatality(caster, target)
	end]]
	local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
	ParticleManager:SetParticleControl( trailFx, 1, caster:GetAbsOrigin() )
	-- do damage and apply CC
	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
	ParticleManager:SetParticleControl( trailFx, 0, target:GetAbsOrigin() )
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_fierce_tiger_strike_1_slow", {})
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
    --ParticleManager:SetParticleControlOrientation(groundFx, 0, RandomVector(300), Vector(0,1,0), Vector(1,0,0))
end


function OnTigerStrike2Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	-- apply mark of fatality if attribute was acquired
	--[[if IsMarkAcquired then
		ApplyMarkOfFatality(caster, target)
	end]]
	-- do damage and apply CC
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	keys.target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 0.1})
	-- switch strike 1 with 2
	caster:SwapAbilities("lishuwen_fierce_tiger_strike_2", "lishuwen_fierce_tiger_strike_3", false, true) 
	caster:EmitSound("Hero_EarthShaker.Fissure")
    local groundFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControl( groundFx, 1, target:GetAbsOrigin())
end

function OnTigerStrike3Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)

	-- apply mark of fatality if attribute was acquired
	--[[if IsMarkAcquired then
		ApplyMarkOfFatality(caster, target)
	end]]
	-- do damage and apply CC
	local damage = target:GetMaxHealth()*keys.DamagePercent/100
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_fierce_tiger_strike_3_slow", {})
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
end

function OnNSSStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	-- apply mark of fatality if attribute was acquired
	--[[if IsMarkAcquired then
		ApplyMarkOfFatality(caster, target)
	end]]
	-- do damage and apply CC
	local damage = keys.Damage
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
end

function OnNSSDelayFinished(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = target:GetMana() * keys.DelayedDamagePercentage/100
	if target:GetName() == "npc_dota_hero_juggernaut" or target:GetName() == "npc_dota_hero_shadow_shaman" then
		damage = (target:GetMaxHealth() - target:GetHealth()) * keys.DelayedDamagePercentage/100
	end
	
	target:SetMana(target:GetMana() - damage)
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, 0, keys.ability, false)

	local manaBurnFx = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
	target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
	-- do damage and apply CC
end

function OnDragonStrike1Start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end

	GrantCosmicOrbitResist(caster)
	caster.targetTable = {} 
	-- fire linear projectile 
	local projectile = 
	{
		Ability = keys.ability,
        EffectName = "particles/econ/generic/generic_projectile_linear_1/generic_projectile_linear_1.vpcf",
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
        fExpireTime = GameRules:GetGameTime() + 0.3,
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
	end)

	caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_raging_dragon_strike_2", false, true) 
	caster.bIsCurrentDSCycleFinished = false


	-- start a timer to revert layout back after set time(4 sec)
    Timers:CreateTimer('raging_dragon_timer', {
        endTime = 4,
        callback = function()
		local currentAbil = caster:GetAbilityByIndex(2)
		if currentAbil:GetAbilityName() ~= "lishuwen_raging_dragon_strike" or not caster.bIsCurrentDSCycleFinished then
			caster:SwapAbilities("lishuwen_fierce_tiger_strike",currentAbil:GetAbilityName() , true, false) 
		end
	end})
	-- do damage to all of them and create projectile accordingly
end

function OnDragonStrike1ProjectileHit(keys)
	local caster = keys.caster
	local target = keys.target 
	table.insert(caster.targetTable,target)
end

function OnDragonStrike2Start(keys)
	local caster = keys.caster
	local ability = keys.ability

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, ability, false)
		if v:HasModifier("modifier_mark_of_fatality") then v:AddNewModifier(caster, v, "modifier_stunned", {Duration = keys.StunDuration}) end
	end

	local risingWindFx = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
end

function OnDragonStrike3Start(keys)
	local caster = keys.caster
	local ability = keys.ability

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	if #targets == 0 then return end

	local startpoint = caster:GetAbsOrigin()
	local beginpoint = startpoint
	local endpoint = nil
	local counter = 0
	-- apply pause

	for k,v in pairs(targets) do
		ApplyAirborne(caster, target, duration)
	end

	Timers:CreateTimer(0.4, function()
		if counter > 7 then
			
			Timers:CreateTimer(0.3, function()
				-- do the slam
				return end
			end)
			return end
		end

		local targets = FindUnitsInRadius(caster:GetTeam(), startpoint, nil, 500
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		local target = targets[math.random(#targets)]

		if target.nDragonStrikeComboCount == nil then
			target.nDragonStrikeComboCount = 0
		elseif target.nDragonStrikeComboCount > 3 then 
			table.remove(targets, target)
			print("finding new target")
			return 0
		end
		target.nDragonStrikeComboCount = target.nDragonStrikeComboCount + 1
		counter = counter+1

		
		DoCompositeDamage(caster, target, keys.Damage, DAMAGE_TYPE_COMPOSITE, 0, keys.ability, false)


		newpoint = Vector(startpoint.x + RandomInt(1,400), startpoint.y + RandomInt(1, 400), startpoint.y+500)
		caster:SetAbsOrigin(newpoint)
		local trailFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf", PATTACH_CUSTOMORIGIN, target )
		ParticleManager:SetParticleControl( trailFx, 1, beginpoint )
		ParticleManager:SetParticleControl( trailFx, 0, newpoint )
		beginpoint = newpoint

		return 0.15
	end)
end

function LishuwenCheckCombo(caster, ability)
    if caster:GetStrength() >= 19.5 and caster:GetAgility() >= 19.5 and caster:GetIntellect() >= 19.5 then
        if ability == caster:FindAbilityByName("lishuwen_concealment") then
            QUsed = true
            Qtime = GameRules:GetGameTime()
            Timers:CreateTimer({
                endTime = 4,
                callback = function()
                QUsed = false
            end
            })
        elseif ability == caster:FindAbilityByName("lishuwen_cosmic_orbit") and caster:FindAbilityByName("lishuwen_raging_dragon_strike"):IsCooldownReady()  then
            if QUsed == true then 
                caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_fierce_tiger_strike", true, false) 
                Timers:CreateTimer({
                    endTime = 4,
                    callback = function()
                    caster:SwapAbilities("lishuwen_raging_dragon_strike", "lishuwen_fierce_tiger_strike", false, true) 
                    QUsed = false
                end
                })
            end
        end
    end
end

function OnCirculatoryShockAcquired(keys)
end

function OnMartialArtsImproved(keys)
end

function OnDualClassAcquired(keys)
end

function OnFuriousChainAcquired(keys)
end