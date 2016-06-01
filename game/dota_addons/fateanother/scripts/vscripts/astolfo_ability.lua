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
	target:AddEffects(EF_NODRAW)
	--target:SetModel("models/development/invisiblebox.vmdl")
	--target:SetOriginalModel("models/development/invisiblebox.vmdl")
	target:EmitSound("Hero_Oracle.PurifyingFlames.Damage")
end

function OnVanishDebuffEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:RemoveEffects(EF_NODRAW)
	--target:SetModel(target.OriginalModel)
	--target:SetOriginalModel(target.OriginalModel)

	if target:GetName() == "npc_dota_hero_queenofpain" then
		Attachments:AttachProp(target, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
	end
end

function OnDownStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local damage = keys.Damage
	local range = keys.Range
	local attackCount = keys.AttackCount
	local counter = 1

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)

	Timers:CreateTimer(function()
		if counter > 4 then return end
		local forwardVec = RotatePosition(Vector(0,0,0), QAngle(0,RandomFloat(12, -12),0), caster:GetForwardVector())
		local spearProjectile = 
		{
			Ability = ability,
	        EffectName = "particles/custom/false_assassin/fa_quickdraw.vpcf",
	        iMoveSpeed = range * 5,
	        vSpawnOrigin = caster:GetOrigin(),
	        fDistance = range - 100,
	        fStartRadius = 200,
	        fEndRadius = 200,
	        Source = caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = true,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
	        fExpireTime = GameRules:GetGameTime() + 2.0,
			bDeleteOnHit = false,
			vVelocity = forwardVec * range * 5
		}
		local projectile = ProjectileManager:CreateLinearProjectile(spearProjectile)
		StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK, rate=4.0})
		caster:EmitSound("Hero_Sniper.AssassinateDamage")
		counter = counter + 1
		return 0.12
	end)

end

function OnDownHit(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	local ability = keys.ability
	local lockDuration = keys.LockDuration

	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow", {})
	giveUnitDataDrivenModifier(caster, target, "locked", lockDuration)
end

function OnDownSlowTier1End(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow_2", {})
end

function OnDownSlowTier2End(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow_3", {})
end

function OnHornStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	


	--[[

	if not enough mana, return 
		
	for all enemy heroes
		apply silencer vsnd on their client 
	end 
	for all allied heroes 
		apply legion horn vsnd on their client
	end
	for enemies in slow/damage/silence radius 
		apply CC/damage respectively
	end
	]]


end