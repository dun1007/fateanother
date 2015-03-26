require("physics")

function GaeBolgAscend(keys)
 
	local caster = keys.caster
	
	caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+10))
	
	
	Timers:CreateTimer({
		endTime = 0.5,
		callback = function()
			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-10))
		end
	})
end

