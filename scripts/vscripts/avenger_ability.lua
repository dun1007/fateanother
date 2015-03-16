function OnDPStart(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local newTargetPoint = nil
	local currentHealthCost = 0

	local currentStack = caster:GetModifierStackCount("modifier_dark_passage", keys.ability)
	currentHealthCost = keys.HealthCost * 2 ^ currentStack
	if currentStack == 0 and caster:HasModifier("modifier_dark_passage") then currentStack = 1 end
	caster:RemoveModifierByName("modifier_dark_passage") 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_dark_passage", {}) 
	caster:SetModifierStackCount("modifier_dark_passage", keys.ability, currentStack + 1)


	if caster:HasModifier("modifier_purge") then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot blink while Purged" } )
		keys.ability:EndCooldown()
		return
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown()  
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Travel to Targeted Location" } )
		return 
	end 

	if caster:GetHealth() < currentHealthCost then
		caster:SetHealth(1)
		keys.ability:StartCooldown(30)
	else
		caster:SetHealth(caster:GetHealth() - currentHealthCost)
	end
	
	caster:EmitSound("Hero_Antimage.Blink_out")
	local diff = targetPoint - caster:GetAbsOrigin()
	if diff:Length() <= keys.Range then 
		Timers:CreateTimer(0.033, function() 
			caster:SetAbsOrigin(targetPoint)
			ProjectileManager:ProjectileDodge(caster)
			caster:EmitSound("Hero_Antimage.Blink_in")
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end)
	else  
		newTargetPoint = caster:GetAbsOrigin() + diff:Normalized() * keys.Range
		Timers:CreateTimer(0.033, function() 
			caster:SetAbsOrigin(newTargetPoint) 
			ProjectileManager:ProjectileDodge(caster)
			caster:EmitSound("Hero_Antimage.Blink_in")
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		end)
	end
end

function OnMurderStart(keys)
end

function OnMurderLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("avenger_unlimited_remains"):SetLevel(keys.ability:GetLevel())
end

function OnMurder(keys)
	local caster = keys.caster
	local target = keys.unit
	local manareg = 0

	if target:IsHero() then 
		manareg = caster:GetMaxMana() * keys.ManaRegen / 100
	else 
		manareg = caster:GetMaxMana() * keys.ManaRegenHero / 100
	end
	caster:SetMana(caster:GetMana() + manareg)
end

function OnBashSuccess(keys)
	local caster = keys.caster
	local target = keys.target

	if target:HasModifier("modifier_murderous_instinct_bash_checker") then
		-- do nothing
	else
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_murderous_instinct_bash_checker", {}) 
	end
end

function OnRemainStart(keys)
end

function OnTZStart(keys)
	local caster = keys.caster
	local target = keys.target
	local TZCount = 0
	if IsSpellBlocked(keys.target) then return end
	if not IsImmuneToSlow(keys.target) then keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_tawrich_slow", {}) end
	Timers:CreateTimer(0.033, function() 
		if TZCount == 6 then return end
		caster:EmitSound("Hero_BountyHunter.Jinada")
		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 
		DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		TZCount = TZCount + 1
		return 0.10
	end)

	target:AddNewModifier(caster, target, "modifier_disarmed", {Duration = keys.Duration})
	target:AddNewModifier(caster, target, "modifier_silence", {Duration = keys.Duration})
end

function OnTZLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("avenger_vengeance_mark"):SetLevel(keys.ability:GetLevel())
end

function OnVengeanceStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_vengeance_mark", {})
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnVengeanceEnd(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(target, caster, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnBloodStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end
end

function OnTFStart(keys)
	local caster = keys.caster

    caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains", true, true) 
    caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark", false, true) 
    caster:SwapAbilities("avenger_true_form", "avenger_demon_core", true, true)
    caster:SetOriginalModel("models/avenger/trueform/trueform.vmdl")
    caster:SetModelScale(1.1)
end

function OnTFLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("avenger_demon_core"):SetLevel(keys.ability:GetLevel())
end

function OnTFEnd(keys)
	local caster = keys.caster
    caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains", true, true) 
    caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark", true, false) 
    caster:SwapAbilities("avenger_true_form", "avenger_demon_core", true, true)
    local demoncore = caster:FindAbilityByName("avenger_demon_core")
    if demoncore:GetToggleState() then
    	demoncore:ToggleAbility()
    end
    caster:SetModel("models/avenger/avenger.vmdl")
    caster:SetOriginalModel("models/avenger/avenger.vmdl")

    caster:SetModelScale(0.8)
end

function OnDCToggleOn(keys)
	local caster = keys.caster
	local ability = keys.ability
	local demoncore = caster:FindAbilityByName("avenger_demon_core")

	Timers:CreateTimer(function() 
		if not demoncore:GetToggleState() then return end
		if caster:GetMana() < 25 then 
			demoncore:ToggleAbility()  
			return 
		end
		caster:SetMana(caster:GetMana() - 25) 
		return 0.25
	end)
end

function OnDCToggleOff(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function OnVergStart(keys)
	local caster = keys.caster
	EmitGlobalSound("Avenger.Berg")
end

function OnVergTakeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local returnDamage = keys.DamageTaken * keys.Multiplier / 100
	print(returnDamage)
	if caster:GetHealth() ~= 0 then
		DoDamage(caster, attacker, returnDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		attacker:EmitSound("Hero_WitchDoctor.Maledict_Tick")
		local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_ABSORIGIN, attacker)
		ParticleManager:SetParticleControl(particle, 1, attacker:GetAbsOrigin())
	end
 
end

function OnDarkPassageImproved(keys)
end

function OnBloodMarkAcquired(keys)
end

function OnOverdriveAcquired(keys)
end

function OnDIAcquired(keys)
end