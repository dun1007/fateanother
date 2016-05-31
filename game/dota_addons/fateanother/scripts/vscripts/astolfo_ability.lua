function OnCasaThink(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_passive_mr", {})
	end
end

function OnCasaStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_active_mr", {})
end

function OnVanishStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local info = {
		Target = target, -- chainTarget
		Source = caster, -- chainSource
		Ability = ability,
		EffectName = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1000
	}
	ProjectileManager:CreateTrackingProjectile(info) 

	caster:EmitSound("Hero_Mirana.Leap.MoonGriffon")
end

function OnVanishHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = keys.Damage
	ApplyPurge(target)
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_hippogriff_vanish_banish", {})
end

function OnVanishDebuffStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetName() == "npc_dota_hero_queenofpain" then
		local prop = Attachments:GetCurrentAttachment(target, "attach_sword")
		prop:RemoveSelf()
	end

	target:SetModel("models/development/invisiblebox.vmdl")
	target:SetOriginalModel("models/development/invisiblebox.vmdl")
	target:EmitSound("Hero_Oracle.PurifyingFlames.Damage")
end

function OnVanishDebuffEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:SetModel(target.OriginalModel)
	target:SetOriginalModel(target.OriginalModel)

	if target:GetName() == "npc_dota_hero_queenofpain" then
		Attachments:AttachProp(target, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
	end
end

function OnDownStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
end