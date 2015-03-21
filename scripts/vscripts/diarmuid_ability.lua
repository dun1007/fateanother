function OnLoveSpotStart(keys)
end

function OnChargeStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
         keys.target:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
    end
end

function OnRampantWarriorStart(keys)
end

function OnBuidheCastStart(keys)
end

function OnBuidheStart(keys)
end

function OnDeargCastStart(keys)
end

function OnDeargStart(keys)
end

function OnLoveSpotImproved(keys)
end

function OnMindEyeAcquired(keys)
end

function OnRosebloomAcquired(keys)
end

function OnDoubleSpearAcquired(keys)
end