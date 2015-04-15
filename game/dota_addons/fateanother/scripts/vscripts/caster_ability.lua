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


	local terr = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(terr) do
		print(v:GetClassname())
		if v:GetUnitName() == "caster_5th_territory" then
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Territory Already Exists" } )
			return 
		end
	end

	-- Create territory unit at location
	territory = CreateUnitByName("caster_5th_territory", targetPoint, true, caster, caster, caster:GetTeamNumber()) 
	territory:SetControllableByPlayer(pid, true)
	LevelAllAbility(territory)
	keys.ability:ApplyDataDrivenModifier(caster, territory, "modifier_territory_death_checker", {}) --[[Returns:void
	No Description Set
	]]

	local territoryHealth = 1000
	if ply.IsTerritoryImproved then 
		-- add true sight
		truesightdummy = CreateUnitByName("sight_dummy_unit", territory:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
		truesightdummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 600}) 
		local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
		unseen:SetLevel(1)
		Timers:CreateTimer(function() 
			truesightdummy:SetAbsOrigin(territory:GetAbsOrigin())
			return 1.0
		end)

		territory:SetMaxHealth(2000) 
		Timers:CreateTimer(function()
			if not territory:IsAlive() then return end
		    local targets = FindUnitsInRadius(caster:GetTeam(), territory:GetOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
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
		territory:AddItem(CreateItem("item_all_seeing_orb" , nil, nil))
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

function OnTerritoryDeath(keys)
	local caster = keys.caster
	local summons = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(summons) do
		print("Found unit " .. v:GetUnitName())
		if v:GetUnitName() == "caster_5th_skeleton_warrior" or v:GetUnitName() == "caster_5th_skeleton_archer" or v:GetUnitName() == "caster_5th_ancient_dragon" then
			v:ForceKill(true) 
		end
	end
	if truesightdummy ~= nil then 
		truesightdummy:ForceKill(true)
	end
end

function OnTerritoryExplosion(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local damage = 300 + 10 * hero:GetIntellect() + caster:GetMana()/2


	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
	Timers:CreateTimer(1.0, function()
		if caster:IsAlive() then
			caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
			local damage = 300 + 10 * hero:GetIntellect() + caster:GetMana()/2
			if ply.IsTerritoryImproved then damage = damage + 300 end
		    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
		         DoDamage(hero, v, damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		    end
		    -- particle
	  	  	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_CUSTOMORIGIN, caster)
	  	  	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- height of the bolt
		    ParticleManager:SetParticleControl(particle, 1, Vector(1000, 0, 0)) -- height of the bolt
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
	caster:StopSound("Hero_Lion.ManaDrain")
end


function OnSummonSkeleton(keys)
	local caster = keys.caster
	local ability = keys.ability
	local pid = caster:GetPlayerOwner():GetPlayerID()
	local unitname = nil
	if ability:GetName()  == "item_summon_skeleton_warrior"  then
		unitname =  "caster_5th_skeleton_warrior"
	elseif ability:GetName()  == "item_summon_skeleton_archer" then
		unitname = "caster_5th_skeleton_archer"
	end

	local spooky = CreateUnitByName(unitname, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	--spooky:SetPlayerID(pid) 
	spooky:SetControllableByPlayer(pid, true)
	spooky:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	
	LevelAllAbility(spooky)
	FindClearSpaceForUnit(spooky, spooky:GetAbsOrigin(), true)
	spooky:AddNewModifier(caster, nil, "modifier_kill", {duration = 60})
end

function OnSummonDragon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local pid = caster:GetPlayerOwner():GetPlayerID()

	-- Kill the existing dragon
	local dragFind = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(dragFind) do
		print(v:GetClassname())
		if v:GetUnitName() == "caster_5th_ancient_dragon" then
			v:ForceKill(true)
		end
	end

	local drag = CreateUnitByName("caster_5th_ancient_dragon", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	--drag:SetPlayerID(pid) 
	drag:SetControllableByPlayer(pid, true)
	drag:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	
	LevelAllAbility(drag)
	FindClearSpaceForUnit(drag, drag:GetAbsOrigin(), true)
	drag:AddNewModifier(caster, nil, "modifier_kill", {duration = 60})
end

function CasterFarSight(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local hero = caster:GetPlayerOwner():GetAssignedHero() 
	local dist = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	print(dist)
	if dist > 500 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Caster must be within 500 radius of Territory" } )
		keys.ability:EndCooldown() 
		caster:GiveMana(100)
		return
	end

	local truesightdummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	truesightdummy:SetDayTimeVisionRange(radius)
	truesightdummy:SetNightTimeVisionRange(radius)
	truesightdummy:EmitSound("Hero_KeeperOfTheLight.BlindingLight") 

	local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)

	
	Timers:CreateTimer(8, function() DummyEnd(truesightdummy) return end)

	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_CUSTOMORIGIN, truesightdummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, truesightdummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( 8, 0, 0 ) )
	
	local dustFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_dust.vpcf", PATTACH_CUSTOMORIGIN, truesightdummy )
	ParticleManager:SetParticleControl( dustFxIndex, 0, truesightdummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
	
	truesightdummy.circle_fx = circleFxIndex
	truesightdummy.dust_fx = dustFxIndex
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
			
	-- Destroy particle after delay
	Timers:CreateTimer( 8, function()
			ParticleManager:DestroyParticle( circleFxIndex, false )
			ParticleManager:DestroyParticle( dustFxIndex, false )
			ParticleManager:ReleaseParticleIndex( circleFxIndex )
			ParticleManager:ReleaseParticleIndex( dustFxIndex )
			return nil
		end
	)
end

function OnTerritoryMobilize(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_rooted")
	caster:SwapAbilities("caster_5th_mobilize", "caster_5th_immobilize", true, true) 

	caster:SwapAbilities("caster_5th_mana_drain", "fate_empty1", true, true)
	caster:SwapAbilities("caster_5th_territory_explosion", "fate_empty2", true, true)
	caster:SwapAbilities("caster_5th_recall", "fate_empty3", true, true)
end

function OnTerritoryImmobilize(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_mobilize")
	caster:AddNewModifier(caster, nil, 'modifier_rooted', {})
	caster:SwapAbilities("caster_5th_mobilize", "caster_5th_immobilize", true, true) 	

	caster:SwapAbilities("caster_5th_mana_drain", "fate_empty1", true, true)
	caster:SwapAbilities("caster_5th_territory_explosion", "fate_empty2", true, true)
	caster:SwapAbilities("caster_5th_recall", "fate_empty3", true, true)
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

	local truesightdummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	truesightdummy:SetDayTimeVisionRange(900)
	truesightdummy:SetNightTimeVisionRange(900)
	local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)

	Timers:CreateTimer(8, function() return truesightdummy:RemoveSelf() end)
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
	
	-- Create particle
	if caster.argosDurabilityParticleIndex == nil then
		local prev_amount = 0.0
		Timers:CreateTimer( function()
				-- Check if shield still valid
				if caster.argosShieldAmount > 0 and caster:HasModifier( "modifier_argos_shield" ) then
					-- Check if it should update
					if prev_amount ~= caster.argosShieldAmount then
						-- Change particle
						local digit = 0
						if caster.argosShieldAmount > 999 then
							digit = 4
						elseif caster.argosShieldAmount > 99 then
							digit = 3
						elseif caster.argosShieldAmount > 9 then
							digit = 2
						else
							digit = 1
						end
						if caster.argosDurabilityParticleIndex ~= nil then
							-- Destroy previous
							ParticleManager:DestroyParticle( caster.argosDurabilityParticleIndex, true )
							ParticleManager:ReleaseParticleIndex( caster.argosDurabilityParticleIndex )
						end
						-- Create new one
						caster.argosDurabilityParticleIndex = ParticleManager:CreateParticle( "particles/custom/caster/caster_argos_durability.vpcf", PATTACH_CUSTOMORIGIN, caster )
						ParticleManager:SetParticleControlEnt( caster.argosDurabilityParticleIndex, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true )
						ParticleManager:SetParticleControl( caster.argosDurabilityParticleIndex, 1, Vector( 0, math.floor( caster.argosShieldAmount ), 0 ) )
						ParticleManager:SetParticleControl( caster.argosDurabilityParticleIndex, 2, Vector( 1, digit, 0 ) )
						ParticleManager:SetParticleControl( caster.argosDurabilityParticleIndex, 3, Vector( 100, 100, 255 ) )
						
						prev_amount = caster.argosShieldAmount	
					end
					
					return 0.1
				else
					if caster.argosDurabilityParticleIndex ~= nil then
						ParticleManager:DestroyParticle( caster.argosDurabilityParticleIndex, true )
						ParticleManager:ReleaseParticleIndex( caster.argosDurabilityParticleIndex )
						caster.argosDurabilityParticleIndex = nil
					end
					return nil
				end
			end
		)
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

function AncientLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("caster_5th_wall_of_flame"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("caster_5th_silence"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("caster_5th_divine_words"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("caster_5th_mana_transfer"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("caster_5th_sacrifice"):SetLevel(keys.ability:GetLevel())
end

function OnFirewallStart(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()

	-- Flame spread particle
	local caster = keys.caster
	local angle = 0
	local increment_factor = 45
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector() * 1150
	local destination = origin + forward
	local ubwflame = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
        iMoveSpeed = 500,
        vSpawnOrigin = origin,
        fDistance = 300,
        fStartRadius = 500,
        fEndRadius = 500,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_NONE,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = forward 
	}
	for i=1, 8 do
		-- Start rotating
		local theta = ( angle - i * increment_factor ) * math.pi / 180
		local px = math.cos( theta ) * ( destination.x - origin.x ) - math.sin( theta ) * ( destination.y - origin.y ) + origin.x
		local py = math.sin( theta ) * ( destination.x - origin.x ) + math.cos( theta ) * ( destination.y - origin.y ) + origin.y
		local new_forward = ( Vector( px, py, origin.z ) - origin ):Normalized()
		ubwflame.vVelocity = new_forward * 500
		local projectile = ProjectileManager:CreateLinearProjectile(ubwflame)
	end 
	

    local targets = FindUnitsInRadius(caster:GetTeam(), casterPos, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 

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
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_silence.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0 , targetPoint)
end

function OnDWStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	local rainCount = 0

    Timers:CreateTimer(0.5, function()
    	if rainCount == 3 then return end
    	caster:EmitSound("Hero_Luna.LucentBeam.Target")
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, targetPoint)
		ParticleManager:SetParticleControl(particle, 1, targetPoint)
		ParticleManager:SetParticleControl(particle, 5, targetPoint)
		ParticleManager:SetParticleControl(particle, 6, targetPoint)

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

function MaledictStop( event )
	local caster = event.caster
	
	caster:StopSound("Hero_WitchDoctor.Maledict_Loop")
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
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	if caster:GetName() == "npc_dota_hero_crystal_maiden" then
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_caster_rule_breaker", {}) 
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_lancelot_rule_breaker", {}) 
	end
	EmitGlobalSound("Caster.RuleBreaker") 
	CasterCheckCombo(keys.caster,keys.ability)

	ApplyStrongDispel(target)
	if ply.IsRBImproved then
		keys.ability:StartCooldown(25)
		giveUnitDataDrivenModifier(caster, target, "rb_sealdisabled", 3.0)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_dagger_of_treachery", {}) 
	end

	keys.target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})

end

function OnRBSealStolen(keys)
	local victim = keys.unit
	local caster = keys.caster

	victim:EmitSound("Hero_Silencer.LastWord.Cast")
	victim.MasterUnit:SetMana(victim.MasterUnit:GetMana() - 1) 
	victim.MasterUnit2:SetMana(victim.MasterUnit2:GetMana() - 1) 
	
	caster.MasterUnit:SetMana(caster.MasterUnit:GetMana() + 1)
	caster.MasterUnit2:SetMana(caster.MasterUnit2:GetMana() + 1)
end

function OnHGStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local radius = 750
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local diff = targetPoint - caster:GetAbsOrigin()
	local maxBolt = 13
	if ply.IsHGImproved then
		maxBolt = 16
	end 

	local initTargets = 0

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
		local dummy = CreateUnitByName( "sight_dummy_unit", caster:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber() );
		caster:SetPhysicsVelocity( Vector( 0, 0, dummy:GetAbsOrigin().z - caster:GetAbsOrigin().z ) )
		dummy:RemoveSelf()
	return end) 
	Timers:CreateTimer(4.0, function()
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	return end)


	local bolt = {
		attacker = caster,
		victim = nil,
		damage = keys.Damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}

	local isFirstLoop = false
	Timers:CreateTimer(1.0, function()
		if isFirstLoop == false then 
			isFirstLoop = true
			initTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(initTargets) do
				print("inital ray")
				DropRay(keys, v:GetAbsOrigin())
			end
			maxBolt = maxBolt - #initTargets
		else
			if maxBolt <= boltCount then return end
		end

		boltvector = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)
		while GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) do
			boltvector = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)
		end
		DropRay(keys, boltvector)

	    boltCount = boltCount + 1
		return 0.1
    end
    )
	Timers:CreateTimer(1.0, function() EmitGlobalSound("Caster.Hecatic") EmitGlobalSound("Caster.Hecatic_Spread") caster:EmitSound("Misc.Crash") return end)
end

function DropInitialRay(keys)

end

function DropRay(keys, boltvector)
	local caster = keys.caster
	local targetPoint = caster:GetAbsOrigin() 
	-- Particle
	-- These two values for making the bolt starts randomly from sky
	local randx = RandomInt( 0, 200 )
	if randx < 100 then randx = -100 - randx end
	local randy = RandomInt( 0, 200 )
	if randy < 100 then randy = -100 - randy end
	
	local fxIndex = ParticleManager:CreateParticle( "particles/custom/caster/caster_hecatic_graea.vpcf", PATTACH_CUSTOMORIGIN, caster )
	print(targetPoint)
	print(boltvector)
	ParticleManager:SetParticleControl( fxIndex, 0, targetPoint + boltvector + Vector(0, 0, -750) ) -- This is where the bolt will land
	ParticleManager:SetParticleControl( fxIndex, 1, targetPoint + boltvector + Vector( randx, randy, 250 ) ) -- This is where the bolt will start
	ParticleManager:SetParticleControl( fxIndex, 2, Vector( keys.RadiusBolt, 0, 0 ) )
	
	Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( fxIndex, false )
			ParticleManager:ReleaseParticleIndex( fxIndex )
			return nil
		end
	)

		
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint + boltvector, nil, keys.RadiusBolt, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
    	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
	end
end

function OnHGPStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local radius = 750
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local maxBolt = 13
	local barrageRadius = keys.Radius

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	
	if ply.IsHGImproved then
		maxBolt = 16
		barrageRadius = keys.Radius+300
	end 

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
		ParticleManager:CreateParticle("particles/custom/screen_purple_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
	return end) 
	Timers:CreateTimer(5.0, function()  
		local dummy = CreateUnitByName( "sight_dummy_unit", caster:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber() );
		caster:SetPhysicsVelocity( Vector( 0, 0, dummy:GetAbsOrigin().z - caster:GetAbsOrigin().z ) )
		dummy:RemoveSelf()
	return end) 
	Timers:CreateTimer(6.0, function()  
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
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
		if boltCount == maxBolt then return end
		boltvector = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)
  	  	
		-- Particle
		-- These two values for making the bolt starts randomly from sky
		local randx = RandomInt( 0, 200 )
		if randx < 100 then randx = -100 - randx end
		local randy = RandomInt( 0, 200 )
		if randy < 100 then randy = -100 - randy end

		print(targetPoint)
		print(boltvector)
		
		local fxIndex = ParticleManager:CreateParticle( "particles/custom/caster/caster_hecatic_graea.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, targetPoint + boltvector ) -- This is where the bolt will land
		ParticleManager:SetParticleControl( fxIndex, 1, targetPoint + boltvector + Vector( randx, randy, 1000 ) ) -- This is where the bolt will start
		ParticleManager:SetParticleControl( fxIndex, 2, Vector( keys.RadiusBolt, 0, 0 ) )
		
		Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( fxIndex, false )
				ParticleManager:ReleaseParticleIndex( fxIndex )
				return nil
			end
		)

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
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, barrageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
        	DoDamage(caster, v, 1500, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	--v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
		end
  	  	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_CUSTOMORIGIN, caster)
  	  	ParticleManager:SetParticleControl(particle, 0, targetPoint) -- height of the bolt
	    ParticleManager:SetParticleControl(particle, 1, Vector(barrageRadius, 0, 0)) -- height of the bolt
		return
    end
    )
	Timers:CreateTimer(1.0, function() 
		EmitGlobalSound("Caster.Hecatic_Spread") 
		--EmitGlobalSound("Caster.Hecatic") 
		caster:EmitSound("Misc.Crash") 
	return end)
end

function CasterCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("caster_5th_rule_breaker") and caster:FindAbilityByName("caster_5th_hecatic_graea"):IsCooldownReady() and caster:FindAbilityByName("caster_5th_hecatic_graea_powered"):IsCooldownReady() then
			caster:SwapAbilities("caster_5th_hecatic_graea", "caster_5th_hecatic_graea_powered", false, true) 
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster:SwapAbilities("caster_5th_hecatic_graea", "caster_5th_hecatic_graea_powered", true, false) 
			end
			})			
		end
	end
end

function OnImproveTerritoryCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsTerritoryImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveArgosAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsArgosImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveHGAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsHGImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDaggerOfTreacheryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsRBImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end