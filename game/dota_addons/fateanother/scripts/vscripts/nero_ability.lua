function OnIPStart(keys)
end

function OnIPRespawn(keys)
	local caster = keys.caster
end

function OnGBStart(keys)
	local caster = keys.caster
	caster.IsGBActive = true
	caster:EmitSound("Hero_DoomBringer.ScorchedEarthAura")
	Timers:CreateTimer(function()
		if keys.ability:IsChanneling() then
			keys.ability:ApplyDataDrivenModifier(caster,caster, "modifier_gladiusanus_blauserum", {})
		else
			return
		end
		return 0.5
	end)
end

function OnGBEnd(keys)
	local caster = keys.caster
	-- destroy particle
end

function OnGBStrike(keys)
	local caster = keys.caster
	local target = keys.target
	if not caster.IsGBActive then return end
	caster.IsGBActive = false
	caster:EmitSound("Hero_Clinkz.DeathPact")
	StopSoundEvent("Hero_DoomBringer.ScorchedEarthAura",caster)
	CreateSlashFx(caster, target:GetAbsOrigin()+Vector(250, 250, 0), target:GetAbsOrigin()+Vector(-250,-250,0))
	
	local flameFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(flameFx, 2, target:GetAbsOrigin())

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle, 1, Vector(300, 300, 300)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(300, 300, 300)) 

	-- add effect and handle attribute
end

function OnTFAStart(keys)
end

function OnTFACleave(keys)
end

function OnRIStart(keys)
end

function OnRIHit(keys)
end
function OnTheatreStart(keys)
end

function OnTheatreEnd(keys)
end


function OnNeroComboStart(keys)
end

function OnLSCStart(keys)
end

function OnISStart(keys)
end


function OnPTBAcquired(keys)
end

function OnPrivilegeImproved(keys)
end

function OnISAcquired(keys)
end

function OnGloryAcquired(keys)
end