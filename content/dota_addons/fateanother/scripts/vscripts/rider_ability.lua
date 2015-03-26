require("physics")

function NailPull(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
	for k,v in pairs(targets) do
		local pullTarget = Physics:Unit(v)
		v:PreventDI()
		v:SetPhysicsFriction(0)
		v:SetPhysicsVelocity((caster:GetAbsOrigin() - v:GetAbsOrigin()):Normalized() * 500)
		v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		v:FollowNavMesh(false)

		v:OnPhysicsFrame(function(unit)
			local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
			local dir = diff:Normalized()
			unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
			if diff:Length() < 50 then
				unit:PreventDI(false)
				unit:SetPhysicsVelocity(Vector(0,0,0))
				unit:OnPhysicsFrame(nil)
				FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			end
		end)
	end
end