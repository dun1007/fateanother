astolfo_hippogriff_rush = class({})

function astolfo_hippogriff_rush:OnSpellStart()
	local caster = self:GetCaster()
	local rideHandle = caster:FindAbilityByName("astolfo_hippogriff_ride")
	local range = rideHandle:GetSpecialValueFor("linear_range")
	local damage = rideHandle:GetSpecialValueFor("damage")
	local midPos = self:GetCursorPosition()
	local randomVec = RandomVector(1):Normalized()
	local startPos = midPos - randomVec * range/2
	local endPos = midPos + randomVec * range/2
	--local startPos = self:GetInitialPosition()
	--local endPos = startPos + self:GetDirectionVector() * range
	local markerCounter = 0
	if (startPos - caster:GetAbsOrigin()):Length2D() > 3500 or not IsInSameRealm(caster:GetAbsOrigin(), startPos) then
		self:EndCooldown() 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Out_Of_Range")
		return
	end
	Timers:CreateTimer(function()
		if markerCounter >= 5 then return end
		local diff = startPos + randomVec * (range/5 * markerCounter + 100)
		local beaconIndex = ParticleManager:CreateParticle("particles/custom/astolfo/astolfo_ground_mark_smile.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( beaconIndex, 0, diff)
		EmitSoundOnLocationWithCaster(diff, "Astolfo.Dash_Alert", caster)
		AddFOWViewer(caster:GetTeamNumber(), diff, 500, 3, false)

		Timers:CreateTimer(0.8, function()
			local targets = FindUnitsInRadius(caster:GetTeam(), diff, nil, 300
		            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if not v.bIsDamagedByHippoRush then 
		        	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, self, false)
		        	caster:PerformAttack( v, true, true, true, true, false, false, true )
		        	v.bIsDamagedByHippoRush = true
		        	Timers:CreateTimer(0.75, function()
		        		v.bIsDamagedByHippoRush = false
		        	end)
		        end
		    end

			local thunderFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_ride_thunder.vpcf", PATTACH_CUSTOMORIGIN, nil)
    		ParticleManager:SetParticleControl(thunderFx, 0, diff)
    		ParticleManager:SetParticleControl(thunderFx, 1, diff)
			ParticleManager:SetParticleControl(thunderFx, 2, diff)
		end)
		markerCounter = markerCounter + 1
		return 0.12
	end)

	Timers:CreateTimer(0.8, function()
		if RandomInt(1, 2) == 1 then 
			EmitSoundOnLocationWithCaster(midPos, "Astolfo.Hippo_Shout1", caster)
		else
			EmitSoundOnLocationWithCaster(midPos, "Astolfo.Hippo_Shout2", caster)
		end
		local forwardVec = (endPos  - startPos):Normalized()
		local hippoVector = forwardVec * range * 3
		local portalFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_rush_portal.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( portalFx, 0, startPos)
		ParticleManager:SetParticleControlForward(portalFx, 0, forwardVec)

		local hippoFx = ParticleManager:CreateParticle( "particles/custom/astolfo/astolfo_hippogriff_raid_flyer.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( hippoFx, 0, startPos + Vector(0,0,200))
		ParticleManager:SetParticleControl( hippoFx, 1,  hippoVector)
		Timers:CreateTimer(0.35, function()
			ParticleManager:DestroyParticle( hippoFx, true )
			ParticleManager:ReleaseParticleIndex( hippoFx )
			local portalFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_rush_portal.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl( portalFx, 0, endPos)
			ParticleManager:SetParticleControlForward(portalFx, 0, forwardVec)
		end)
	end)
end

