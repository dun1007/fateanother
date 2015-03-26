require("physics")
require("timers")

avalonCooldown = true -- UP if true, 
vectorA = Vector(0,0,0)
combo_available = false
currentHealth = 0


function CreateWind(keys)
end

function InvisibleAirPull(keys)
	local caster = keys.caster
	local target = keys.target

	giveUnitDataDrivenModifier(caster, target, "invisibleair_pause", 1.0)
	

    local pullTarget = Physics:Unit(keys.target)
    target:PreventDI()
    target:SetPhysicsFriction(0)
    target:SetPhysicsVelocity((keys.caster:GetAbsOrigin() - keys.target:GetAbsOrigin()):Normalized() * 800)
    target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    target:FollowNavMesh(false)

	target:OnPhysicsFrame(function(unit)
	  local diff = caster:GetAbsOrigin() - unit:GetAbsOrigin()
	  local dir = diff:Normalized()
	  unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * dir)
	  if diff:Length() < 100 then
	  	target:RemoveModifierByName("invisibleair_pause")
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		unit:OnPhysicsFrame(nil)
                FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	  end
	end)
end

function OnCaliburnHit(keys) 
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local targetdmg = {
		attacker = caster,
		victim = target,
		damage = keys.Damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	ApplyDamage(targetdmg)

	local splashdmg = {
		attacker = caster,
		victim = nil,
		damage = keys.Damage * keys.AoEDamage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         splashdmg.victim = v
         ApplyDamage(splashdmg)
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())

    caster:EmitSound("Saber.Caliburn")

end

function OnExcaliburStart(keys)
	print("pls")
	EmitGlobalSound("Saber.Excalibur_Ready")
	Timers:CreateTimer({
				endTime = 1, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
			    EmitGlobalSound("Saber.Excalibur")
			    end
			})
end


function OnAvalonStart(keys)
	currentHealth = keys.caster:GetHealth()
	EmitGlobalSound("Saber.Avalon")
	EmitGlobalSound("Saber.Avalon_Shout")
end

function AvalonOnTakeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local pid = caster:GetPlayerID() 
	local diff = 0
	local damageTaken = keys.DamageTaken
	local newCurrentHealth = caster:GetHealth()
	local emitwhichsound = RandomInt(1, 2)
	if (damageTaken > keys.Threshold) then
		if avalonCooldown then
			if emitwhichsound == 1 then attacker:EmitSound("Saber.Avalon_Counter1") else attacker:EmitSound("Saber.Avalon_Counter2") end
			AvalonDash(caster, attacker, keys.Damage)
			-- dash attack 3 seconds cooldown
			avalonCooldown = false
			Timers:CreateTimer({
				endTime = 3, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
				callback = function()
			    avalonCooldown = true
			    end
			})
		end
	end
	-- if damage would have been lethal without Avalon, set Saber's health to health when Avalon was cast
	if newCurrentHealth == 0 then
		caster:SetHealth(currentHealth)
	else
		caster:SetHealth(newCurrentHealth + damageTaken)
	end
end -- function end

function AvalonDash(caster, attacker, counterdamage)
	local targetPoint = attacker:GetAbsOrigin()
	print("yay")
	local casterDash = Physics:Unit(caster)
	local distance = targetPoint - caster:GetAbsOrigin()

	giveUnitDataDrivenModifier(caster, caster, "avalon_pause", 0.5)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(distance:Normalized() * distance:Length2D()*2)
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(true)
	local splashdmg = {
		attacker = caster,
		victim = nil,
		damage = counterdamage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}
	Timers:CreateTimer({
		endTime = 0.5,
		callback = function()
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	        splashdmg.victim = v
	        ApplyDamage(splashdmg)
	        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
	    end

	    --stop the dash
	    caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end
	})
end

function OnStrikeAirStart(keys)
	EmitGlobalSound("Saber.StrikeAir_Cast")
	print("Strike air is cast")
end

function StrikeAirPush(keys)
	local sound = RandomInt(1,2)
	if sound == 1 then EmitGlobalSound("Saber.StrikeAir_Release1") else EmitGlobalSound("Saber.StrikeAir_Release2") end

    local pushTarget = Physics:Unit(keys.target)
    keys.target:PreventDI()
    keys.target:SetPhysicsFriction(0)
	local vectorC = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()) 
	-- get the direction where target will be pushed back to
	local vectorB = vectorC - vectorA
	keys.target:SetPhysicsVelocity(vectorB:Normalized() * 1000)
    keys.target:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	local initialUnitOrigin = keys.target:GetAbsOrigin()
	
	keys.target:OnPhysicsFrame(function(unit) -- pushback distance check
		local unitOrigin = unit:GetAbsOrigin()
		local diff = unitOrigin - initialUnitOrigin
		local n_diff = diff:Normalized()
		unit:SetPhysicsVelocity(unit:GetPhysicsVelocity():Length() * n_diff) -- track the movement of target being pushed back
		if diff:Length() > 500 then -- if pushback distance is over 500, stop it
			unit:PreventDI(false)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		end
	end)
	
	keys.target:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		
		
	end)
end

function giveUnitDataDrivenModifier(source, target, modifier,dur)
    --source and target should be hscript-units. The same unit can be in both source and target
    local item = CreateItem( "item_apply_modifiers", source, source)
    item:ApplyDataDrivenModifier( source, target, modifier, {duration=dur} )
end