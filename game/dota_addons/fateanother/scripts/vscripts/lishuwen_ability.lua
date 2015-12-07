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
	if not target:HasModifier("modifier_martial_arts_indicator_enemy") then return end
	local roll = math.random(100)
	if roll < chance then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_martial_arts_crit_hit", {})
	end
end

function OnMartialAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability:GetLevel() == 2 and target:HasModifier("modifier_martial_arts_indicator_enemy") then
		DoDamage(caster, target, target:GetMaxHealth() * 3.5/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end

end


function ApplyMarkOfFatality(caster,target)
	local abil = caster:FindAbilityByName("lishuwen_martial_arts")
	abil:ApplyDataDrivenModifier(caster, target, "modifier_martial_arts_indicator_enemy", {})
	SpawnAttachedVisionDummy(caster, target, abil:GetLevelSpecialValueFor("vision_radius", abil:GetLevel()-1 ), abil:GetLevelSpecialValueFor("duration", abil:GetLevel()-1 ), false)
end