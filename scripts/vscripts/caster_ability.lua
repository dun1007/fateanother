require("Physics")
require("util")

sac = false
mt = false
territory = nil

function OnTerritoryCreated(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local targetPoint = keys.target_points[1]

	--if Entities:FindAllByName("caster_5th_territory") then print("Territory already exists") return end

	-- Create territory unit at location
	territory = CreateUnitByName("caster_5th_territory", targetPoint, true, caster, caster, caster:GetTeamNumber()) 
	territory:SetControllableByPlayer(pid, true)
	LevelAllAbility(territory)

	local territoryHealth = 1000
	if ply.IsTerritoryImproved then 
		
		territory:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 600, duration = 9999})
		territory:SetMaxHealth(2000) 
		Timers:CreateTimer(function()
		    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
		         if v ~= territory then 
		         	keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_territory_mana_regen", {Duration = 1.0}) 
		         end
		    end
			return 1.0
			end
		)
	end

	-- Initialize territory
	territory:SetHealth(1)
	territory:SetMana(0)
	territory:SetBaseManaRegen(3) 
	territory:AddItem(CreateItem("item_summon_skeleton_warrior" , nil, nil))
	territory:AddItem(CreateItem("item_summon_skeleton_archer" , nil, nil))
	if ply.IsTerritoryImproved then
		territory:AddItem(CreateItem("item_summon_ancient_dragon"  , nil, nil))
	end
	giveUnitDataDrivenModifier(caster, territory, "pause_sealdisabled", 5.0)
	territory:AddNewModifier(caster, nil, 'modifier_rooted', {})
	local territoryConstTimer = 0
	Timers:CreateTimer(function()
		if territoryConstTimer == 10 then return end
		territory:SetHealth(territory:GetHealth() + territory:GetMaxHealth() / 10)
		territoryConstTimer = territoryConstTimer + 1
		return 0.5
		end
	)


end

function OnTerritoryOwnerDeath(keys)
	territory:Kill(keys.ability, territory)
end

function OnTerritoryExplosion(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local damage = 300 + 10 * hero:GetIntellect() + caster:GetMana()/2


	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
	Timers:CreateTimer(1.0, function()
		if caster:IsAlive() then
			local damage = 300 + 10 * hero:GetIntellect() + caster:GetMana()/2
			if ply.IsTerritoryImproved then damage = damage + 300 end
		    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
		         DoDamage(hero, v, damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		    end
			caster:Kill(keys.ability, caster)
		end
	return end)
end

function OnManaDrainStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local particleName = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"
	caster.ManaDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, caster)

	md = true
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		Timers:CreateTimer(function()  
			if md == false or caster:GetMana() == 0 or target:GetMana() == target:GetMaxMana() then return end
			caster:ReduceMana(30) 
			target:GiveMana(30) 
		return 0.25
		end)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	else
		Timers:CreateTimer(function()  
			if md == false or target:GetMana() == 0 or caster:GetMana() == caster:GetMaxMana() then return end
			target:ReduceMana(20) 
			caster:GiveMana(20) 
		return 0.25
		end)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end

end

function OnManaDrainEnd(keys)
	local target = keys.target
	local caster = keys.caster
	md = false
	ParticleManager:DestroyParticle(caster.ManaDrainParticle,false) 
end


function OnSummonSkeleton(keys)
	local caster = keys.caster
	local ability = keys.ability
	local pid = caster:GetMainControllingPlayer()
	local unitname = nil
	if ability:GetName()  == "item_summon_skeleton_warrior"  then
		unitname =  "caster_5th_skeleton_warrior"
	elseif ability:GetName()  == "item_summon_skeleton_archer" then
		unitname = "caster_5th_skeleton_archer"
	end

	local spooky = CreateUnitByName(unitname, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	spooky:SetPlayerID(pid) 
	spooky:SetControllableByPlayer(pid, true)
	
	LevelAllAbility(spooky)
	FindClearSpaceForUnit(spooky, spooky:GetAbsOrigin(), true)
	spooky:AddNewModifier(caster, nil, "modifier_kill", {duration = 60})
end

function OnSummonDragon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local pid = caster:GetMainControllingPlayer()

	local drag = CreateUnitByName("caster_5th_ancient_dragon", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	drag:SetPlayerID(pid) 
	drag:SetControllableByPlayer(pid, true)
	
	LevelAllAbility(drag)
	FindClearSpaceForUnit(drag, drag:GetAbsOrigin(), true)
	drag:AddNewModifier(caster, nil, "modifier_kill", {duration = 60})
end

function CasterFarSight(keys)
end

function OnTerritoryMobilize(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_rooted")
	caster:SwapAbilities("caster_5th_mobilize", "caster_5th_immobilize", true, true) 

	caster:SwapAbilities("caster_5th_mana_drain", "fate_empty1", true, true)
	caster:SwapAbilities("caster_5th_territory_explosion", "fate_empty2", true, true)
	caster:SwapAbilities("caster_5th_summon_skeleton", "fate_empty4", true, true)
	caster:SwapAbilities("caster_5th_recall", "fate_empty5", true, true)
end

function OnTerritoryImmobilize(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_mobilize")
	caster:AddNewModifier(caster, nil, 'modifier_rooted', {})
	caster:SwapAbilities("caster_5th_mobilize", "caster_5th_immobilize", true, true) 	

	caster:SwapAbilities("caster_5th_mana_drain", "fate_empty2", true, true)
	caster:SwapAbilities("caster_5th_territory_explosion", "fate_empty3", true, true)
	caster:SwapAbilities("caster_5th_summon_skeleton", "fate_empty4", true, true)
	caster:SwapAbilities("caster_5th_recall", "fate_empty5", true, true)
end

function OnTerritoryRecall(keys)
	local caster = keys.caster
	local target = keys.target 
	print(target:GetName())
	if target:GetName() == "npc_dota_hero_crystal_maiden" then
		print("Casted on caster")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_recall", {}) 

		caster.IsRecallCanceled = false
		Timers:CreateTimer(3.0, function()  
		if not caster.IsRecallCanceled and caster:IsAlive()  then 
			target:SetAbsOrigin(caster:GetAbsOrigin())
			FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		end
		return end)
	end
end

function OnRecallCanceled(keys)
	local caster = keys.caster
	caster.IsRecallCanceled = true
end

function OnTerritoryOrbStart(keys)
	local caster = keys.caster

	local visiondummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	visiondummy:SetDayTimeVisionRange(900)
	visiondummy:SetNightTimeVisionRange(900)
	local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)

	Timers:CreateTimer(8, function() return visiondummy:RemoveSelf() end)
end


function OnItemStart(keys)
	local caster = keys.caster
	local randomitem = math.random(3)
	local item = nil
	if randomitem == 1 then 
		item = CreateItem("item_b_scroll", caster, caster) 
	elseif randomitem == 2 then
		item = CreateItem("item_a_scroll", caster, caster) 
	elseif randomitem == 3 then
		item = CreateItem("item_s_scroll", caster, caster) 
	end
	caster:AddItem(item)
end

function OnArgosStart(keys)
	local caster = keys.caster
	if caster.argosShieldAmount == nil then 
		caster.argosShieldAmount = keys.ShieldAmount
	else
		caster.argosShieldAmount = caster.argosShieldAmount + keys.ShieldAmount
	end
	if caster.argosShieldAmount > keys.MaxShield then
		caster.argosShieldAmount = keys.MaxShield
	end
end

function OnArgosDamaged(keys)
	local caster = keys.caster 
	local currentHealth = caster:GetHealth() 


	caster.argosShieldAmount = caster.argosShieldAmount - keys.DamageTaken
	if caster.argosShieldAmount <= 0 then
		if currentHealth + caster.argosShieldAmount <= 0 then
			print("lethal")
		else
			print("argos broken, but not lethal")
			caster:RemoveModifierByName("modifier_argos_shield")
			caster:SetHealth(currentHealth + keys.DamageTaken + caster.argosShieldAmount)
			caster.argosShieldAmount = 0
		end
	else
		print("argos not broken, remaining shield : " .. caster.argosShieldAmount)
		caster:SetHealth(currentHealth + keys.DamageTaken)
	end
end

function OnAncientStart(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)

	caster:SwapAbilities("caster_5th_wall_of_flame", a1:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_silence", a2:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_divine_words", a3:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_mana_transfer", a4:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_close_spellbook", a5:GetName(), true,true) 
	caster:SwapAbilities("caster_5th_sacrifice", a6:GetName(), true, true) 
end

function OnFirewallStart(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()

    local targets = FindUnitsInRadius(caster:GetTeam(), casterPos, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

    for k,v in pairs(targets) do
    	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)

		giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
		local pushback = Physics:Unit(v)
		v:PreventDI()
		v:SetPhysicsFriction(0)
		v:SetPhysicsVelocity((v:GetAbsOrigin() - casterPos):Normalized() * keys.Pushback * 2)
		v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		v:FollowNavMesh(false)
		Timers:CreateTimer(0.5, function()  
			print("kill it")
			v:PreventDI(false)
			v:SetPhysicsVelocity(Vector(0,0,0))
			v:OnPhysicsFrame(nil)
		return end) 
	end
end

function OnSilenceStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do
		v:AddNewModifier(caster, nil, "modifier_silence", {duration=keys.Duration})
	end
end

function OnDWStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	local rainCount = 0

    Timers:CreateTimer(0.5, function()
    	if rainCount == 3 then return end
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 

        for k,v in pairs(targets) do
        	DoDamage(caster, v, keys.Damage/3, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		end
		rainCount = rainCount + 1
      	return 0.25
    end
    )
end

function OnSacrificeStart(keys)
	local caster = keys.caster
	sac = true
	Timers:CreateTimer(function()
		if sac then 
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		    for k,v in pairs(targets) do
		    	if v ~= caster then
		    		v:AddNewModifier(caster, nil, "modifier_invulnerable", {duration = 1.00})
		    	end
			end
		else return end
		caster:RemoveModifierByName("modifier_invulnerable")
	    return 0.03
    end
    )
end

function OnSacrificeEnd(keys)
	local caster = keys.caster
	sac = false
	caster:RemoveModifierByName("modifier_sac_check")
end

function OnMTStart(keys)
	local caster = keys.caster
	local target = keys.target
	local duration = keys.Duration
	local durCount = 0
	mt = true
	Timers:CreateTimer(function()
		if durCount > duration then return end
		if caster:GetMana() == 0 then return end
		if target:GetMaxMana() == target:GetMana() then return end
		if mt then 
			local currentMana = caster:GetMana()
			local targetCurrentMana = target:GetMana()
			caster:SetMana(currentMana - 30)
			target:SetMana(targetCurrentMana + 30)
			durCount = durCount + 0.5
		else return end
	    return 0.5
    end
    )
end

function OnMTEnd(keys)
	mt = false
end

function OnAncientClosed(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)

	caster:SwapAbilities(a1:GetName(), "caster_5th_argos", true ,true) 
	caster:SwapAbilities(a2:GetName(), "caster_5th_ancient_magic", true, true) 
	caster:SwapAbilities(a3:GetName(), "caster_5th_rule_breaker", true, true) 
	caster:SwapAbilities(a4:GetName(), "caster_5th_territory_creation", true, true) 
	caster:SwapAbilities(a5:GetName(), "caster_5th_item_construction", true, true) 
	caster:SwapAbilities(a6:GetName(), "caster_5th_hecatic_graea", true, true )
end

function OnRBStart(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	EmitGlobalSound("Caster.RuleBreaker") 
	CasterCheckCombo(keys.caster,keys.ability)
	keys.target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})

end

function OnHGStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = 750
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local diff = targetPoint - caster:GetAbsOrigin()

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(800) 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Travel to Targeted Location" } )
		return 
	end 
	--EmitGlobalSound("Caster.Hecatic") 

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 4.0)
	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), 750))
	--allows caster to jump over walls
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)

	Timers:CreateTimer(1.0, function()  
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
	return end) 
	Timers:CreateTimer(3.0, function()  
		caster:SetPhysicsVelocity(Vector(0,0,-750))
	return end) 
	Timers:CreateTimer(4.0, function()  
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		
	return end)


	local bolt = {
		attacker = caster,
		victim = nil,
		damage = keys.Damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}

	Timers:CreateTimer(1.0, function()
		if boltCount == 13 then return end
		boltvector = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)
  	  	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	    ParticleManager:SetParticleControl(particle, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,1500)) -- height of the bolt
	    ParticleManager:SetParticleControl(particle, 1, targetPoint + boltvector) -- point landing
	    ParticleManager:SetParticleControl(particle, 2, targetPoint + boltvector) -- point origin

		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint + boltvector, nil, keys.RadiusBolt, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
        	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
		end
	    boltCount = boltCount + 1
		return 0.1
    end
    )
	Timers:CreateTimer(1.0, function() EmitGlobalSound("Caster.Hecatic") EmitGlobalSound("Caster.Hecatic_Spread") caster:EmitSound("Misc.Crash") return end)
end

function OnHGPStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = 750
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(800) 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Travel to Targeted Location" } )
		return 
	end 

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 6.0)
	local diff = targetPoint - caster:GetAbsOrigin()
	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), 750))
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)
	Timers:CreateTimer(1.0, function()  
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
	return end) 
	Timers:CreateTimer(5.0, function()  
		caster:SetPhysicsVelocity(Vector(0,0,-750))
	return end) 
	Timers:CreateTimer(6.0, function()  
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
	return end)


	local bolt = {
		attacker = caster,
		victim = nil,
		damage = keys.Damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}

	Timers:CreateTimer(1.0, function()
		if boltCount == 13 then return end
		boltvector = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)
  	  	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
	    ParticleManager:SetParticleControl(particle, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,1500)) -- height of the bolt
	    ParticleManager:SetParticleControl(particle, 1, targetPoint + boltvector) -- point landing
	    ParticleManager:SetParticleControl(particle, 2, targetPoint + boltvector) -- point origin

		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint + boltvector, nil, keys.RadiusBolt, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
        	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
		end
	    boltCount = boltCount + 1
		return 0.1
    end
    )

	Timers:CreateTimer(3.5, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
        	DoDamage(caster, v, 1500, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	--v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
		end
		return
    end
    )
	Timers:CreateTimer(1.0, function() EmitGlobalSound("Caster.Hecatic_Spread") EmitGlobalSound("Caster.Hecatic") caster:EmitSound("Misc.Crash") return end)
end

function CasterCheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("caster_5th_rule_breaker") then
		caster:SwapAbilities("caster_5th_hecatic_graea", "caster_5th_hecatic_graea_powered", false, true) 
	end
	Timers:CreateTimer({
		endTime = 5,
		callback = function()
		caster:SwapAbilities("caster_5th_hecatic_graea", "caster_5th_hecatic_graea_powered", true, false) 
	end
	})

end

function OnImproveTerritoryCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsTerritoryImproved = true
end

function OnImproveArgosAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsArgosImproved = true
end

function OnImproveHGAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsHGImproved = true
end

function OnDaggerOfTreacheryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsRBImproved = true
end