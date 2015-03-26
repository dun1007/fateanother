require("physics")

vortigernCount = 0

function Vortigern(keys)

	local caster = keys.caster
	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = keys.EffectName,
		iMoveSpeed = keys.MoveSpeed,
		vSpawnOrigin = keys.caster:GetAbsOrigin(),
		fDistance = keys.FixedDistance,
		fStartRadius = keys.EndRadius,
		Source = keys.caster,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = 0.4,
		bDeleteOnHit = false,
		vVelocity = 0.0,
	}
	
	print("im here")
	local initAngle = 120
	Timers:CreateTimer(function() 
			vortigernBeam.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,initAngle,0), caster:GetForwardVector()) * keys.MoveSpeed 
			projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			initAngle = initAngle - 6.66;
			vortigernCount = vortigernCount + 1; 
			if vortigernCount == 36 then vortigernCount = 0 return end -- finish spell
			
			return .01 -- tick every 0.5
		end
	)
end

function OnVortigernHit(keys)
	local target = keys.target
	local caster = keys.caster
	
	if keys.target:GetContext("IsVortigernHit") ~= nil or keys.target:GetContext("IsVortigernHit") == 1 then
		print("already hit")
	else
		local damageTable = {
			victim = keys.target,
			attacker = keys.caster,
			damage = keys.Damage * (0.85+vortigernCount*0.01),
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		ApplyDamage(damageTable)	
		print("dealt "..damageTable.damage)
		
		target:AddNewModifier(caster, nil, "modifier_stunned", {duration = keys.StunDuration})
		
		target:SetContextNum("IsVortigernHit",1.0, 1.0)
		Timers:CreateTimer(0.4, function() return VortigernThinker(target,1) end)
	end
end

function VortigernThinker(target, runCount)
	target:SetContextNum("IsVortigernHit",0,0)
	return nil
end