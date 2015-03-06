function OnSMGStart(keys)
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	local fiss = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
        iMoveSpeed = 500,
        vSpawnOrigin = nil,
        fDistance = 500,
        fStartRadius = 250,
        fEndRadius = 250,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = frontward * 500
	}
	fiss.vSpawnOrigin = caster:GetAbsOrigin() 
	projectile = ProjectileManager:CreateLinearProjectile(fiss)
end

function OnDEStart(keys)
end

function OnSpellbookOpen(keys)
end

function OnAronditeStart(keys)
end