territoryAbilHandle = nil -- Ability handle for Create Workshop
ATTRIBUTE_HG_INT_MULTIPLIER = 0

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initializes Workshop
]]
function OnTerritoryCreated(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local hero = ply:GetAssignedHero()
	local targetPoint = keys.target_points[1]
	territoryAbilHandle = keys.ability
	

	-- Check if Workshop already exists 
	if caster.IsTerritoryPresent then
		ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Workshop_Exists")
		return 
	else
		caster.IsTerritoryPresent = true
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_caster_death_checker", {})

	-- Create Workshop at location
	caster.Territory = CreateUnitByName("caster_5th_territory", targetPoint, true, caster, caster, caster:GetTeamNumber()) 
	caster.Territory:SetControllableByPlayer(pid, true)
	LevelAllAbility(caster.Territory)
	keys.ability:ApplyDataDrivenModifier(caster, caster.Territory, "modifier_territory_death_checker", {}) 

	--[[
	-- Create spy unit for enemies
	local enemyTeamNumber = 0
    LoopOverPlayers(function(ply, plyID)
        if ply:GetAssignedHero():GetTeamNumber() ~= caster:GetTeamNumber() then
        	enemyTeamNumber = ply:GetAssignedHero():GetTeamNumber()
        	return
        end
    end)
	enemydummy = CreateUnitByName("sight_dummy_unit", caster.Territory:GetAbsOrigin(), false, keys.caster, keys.caster, enemyTeamNumber)
	enemydummy:SetDayTimeVisionRange(300)
	enemydummy:SetNightTimeVisionRange(300)
	local unseen = enemydummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)
	Timers:CreateTimer(function() 
		if not caster.Territory:IsAlive() then 
			enemydummy:RemoveSelf()
			return 
		else
			if not enemydummy:IsNull() then 
				enemydummy:SetAbsOrigin(caster.Territory:GetAbsOrigin())
			end
			return 1.0
		end
	end)]]

	-- Do special handling for attribute
	if hero.IsTerritoryImproved then 
		truesightdummy = CreateUnitByName("sight_dummy_unit", caster.Territory:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
		truesightdummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 600}) 
		local unseen = truesightdummy:FindAbilityByName("dummy_unit_passive")
		unseen:SetLevel(1)
		Timers:CreateTimer(function() 
			if not caster.Territory:IsAlive() then 
				truesightdummy:RemoveSelf()
				return 
			else
				truesightdummy:SetAbsOrigin(caster.Territory:GetAbsOrigin())
				return 1.0
			end
		end)


		caster.Territory:SetMaxHealth(2000) 
		caster.Territory:SetBaseMaxHealth(2000)
		-- Give out mana regen for nearby allies
		Timers:CreateTimer(function()
			if not caster.Territory:IsAlive() then return end
		    local targets = FindUnitsInRadius(caster:GetTeam(), caster.Territory:GetOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
		        --if v:GetUnitName() ~= "caster_5th_territory" then 
		         	keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_territory_mana_regen", {Duration = 1.0}) 
		        --end
		    end
			return 1.0
			end
		)
	end


	local warriorItem = CreateItem("item_summon_skeleton_warrior" , nil, nil)
	local archerItem = CreateItem("item_summon_skeleton_archer" , nil, nil)
	local dragItem = CreateItem("item_summon_ancient_dragon"  , nil, nil)
	local skillLevel = 1 + (caster:GetLevel() - 1)/3
	if skillLevel > 8 then skillLevel = 8 end
	warriorItem:SetLevel(skillLevel)
	archerItem:SetLevel(skillLevel)
	dragItem:SetLevel(skillLevel)

	-- Initialize territory
	caster.Territory:SetHealth(1)
	caster.Territory:SetMana(0)
	caster.Territory:SetBaseManaRegen(3) 
	caster.Territory:AddItem(warriorItem)
	caster.Territory:AddItem(archerItem)
	if hero.IsTerritoryImproved then
		caster.Territory:AddItem(dragItem)
		caster.Territory:AddItem(CreateItem("item_all_seeing_orb" , nil, nil))
	end
	giveUnitDataDrivenModifier(caster, caster.Territory, "pause_sealdisabled", 5.0)
	keys.ability:ApplyDataDrivenModifier(caster, caster.Territory, "modifier_territory_root", {}) 


	-- Constrcut territory over time
	local territoryConstTimer = 0
	Timers:CreateTimer(function()
		if territoryConstTimer == 10 then return end
		caster.Territory:SetHealth(caster.Territory:GetHealth() + caster.Territory:GetMaxHealth() / 10)
		territoryConstTimer = territoryConstTimer + 1
		return 0.5
		end
	)


end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Called when Caster(5th) is killed in order to clean up existing Workshop.
]]
function OnTerritoryOwnerDeath(keys)
	local caster = keys.caster
	if not caster.Territory:IsNull() and caster.Territory:IsAlive() then
		caster.Territory:Kill(keys.ability, keys.caster.Territory)
	end
end

--[[
	Author: Dun1007
	Date: 9.2.2015.
	
	Ping Caster's Workshop every 15 seconds to enemy
]]
function OnTerritoryPingThink(keys)
	local caster = keys.caster
	local enemyTeamNumber = 0
	--[[
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
        	enemyTeamNumber = playerHero:GetTeamNumber()
        	return
        end
    end)
	MinimapEvent( enemyTeamNumber, caster, caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )]]
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Called when Workshop is killed in order to clean up summons
]]
function OnTerritoryDeath(keys)
	local caster = keys.caster
	caster:GetPlayerOwner():GetAssignedHero().IsTerritoryPresent = false

	-- Find all summons and forcekill them
	local summons = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false) 
	for k,v in pairs(summons) do
		print("Found unit " .. v:GetUnitName())
		if v:GetUnitName() == "caster_5th_skeleton_warrior" or v:GetUnitName() == "caster_5th_skeleton_archer" or v:GetUnitName() == "caster_5th_ancient_dragon" then
			v:ForceKill(true) 
		end
	end
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Explode Workshop and deal damage to nearby enemies

	caster : Workshop
	hero : Caster(5th)
]]
function OnTerritoryExplosion(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local damage = 300 + 10 * hero:GetIntellect() + caster:GetMana()/2


	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)
	Timers:CreateTimer(1.0, function()
		if caster:IsAlive() then
			caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
			local damage = 300 + caster:GetMana()/2 + hero:GetIntellect()*(8+12*caster:GetMana()/caster:GetMaxMana())
			if hero.IsTerritoryImproved then damage = damage + 300 end
		    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
		         DoDamage(hero, v, damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		    end
		    -- particle
	  	  	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_CUSTOMORIGIN, caster)
	  	  	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- height of the bolt
		    ParticleManager:SetParticleControl(particle, 1, Vector(1000, 0, 0)) -- height of the bolt
			-- Destroy particle after delay
			Timers:CreateTimer( 2.0, function()
				ParticleManager:DestroyParticle( particle, false )
				ParticleManager:ReleaseParticleIndex( particle )
				return nil
			end)
			caster:Kill(keys.ability, caster)
		end
	return end)
end

function OnManaDrainCast(keys)
	local caster = keys.caster
	local target = keys.target
	--PrintTable(keys)
	--print(direction)
	--local direction = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	--caster:SetForwardVector(direction)
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize drain mana and run a timer to check if it is resolved

	caster : Workshop
	target : Target
	hero : Caster(5th)
]]
function OnManaDrainStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local ability = keys.ability
	local particleName = "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf"


	caster.ManaDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, caster)
	caster.ManaDrainTarget = target
	if target == caster then 
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target_Self")
		return
	end
	keys.ManaPerSec = keys.ManaPerSec + hero:GetIntellect() * 0.8

	caster.IsManaDrainChanneling = true
	local dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	-- If target is same team, grant mana
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		Timers:CreateTimer(function()  
			dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
			if caster.IsManaDrainChanneling == false or caster:GetMana() == 0 or target:GetMana() == target:GetMaxMana() or dist > 2000 or not target:CanEntityBeSeenByMyTeam(caster) then 
				keys.ability:EndChannel(false)
				return 
			end
			caster:ReduceMana(keys.ManaPerSec/4) 
			target:GiveMana(keys.ManaPerSec/4) 
			return 0.25
		end)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	else
		Timers:CreateTimer(function()  
			dist = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
			if caster.IsManaDrainChanneling == false or target:GetMana() == 0 or caster:GetMana() == caster:GetMaxMana() or dist > 2000 or not target:CanEntityBeSeenByMyTeam(caster) then 
				keys.ability:EndChannel(false)
				return 
			end
			target:ReduceMana(keys.ManaPerSec/4) 
			caster:GiveMana(keys.ManaPerSec/4) 
			return 0.25
		end)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(caster.ManaDrainParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end

end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	End Mana Drain
]]
function OnManaDrainEnd(keys)
	local caster = keys.caster
	caster.IsManaDrainChanneling = false
	ParticleManager:DestroyParticle(caster.ManaDrainParticle,false) 
	caster.ManaDrainTarget:StopSound("Hero_Lion.ManaDrain")
end


--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize Skeleton Summon

	caster : Workshop
	ability : The respective item

	Warrior parameters : keys.Health/keys.Damag/keys.ArmorRatio/keys.HealthRatio/keys.MSRatio
	Archer parameters : keys.DamageRatio instead of ArmorRatio
]]
function OnSummonSkeleton(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local pid = caster:GetPlayerOwner():GetPlayerID()
	local unitname = nil

	if caster.IsMobilized then return end 

	caster:GetItemInSlot(0):StartCooldown(10)
	caster:GetItemInSlot(1):StartCooldown(10)

	if ability:GetName()  == "item_summon_skeleton_warrior"  then
		unitname =  "caster_5th_skeleton_warrior"
	elseif ability:GetName()  == "item_summon_skeleton_archer" then
		unitname = "caster_5th_skeleton_archer"
	end

	-- Summon spooky skeletal 
	local spooky = CreateUnitByName(unitname, caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	spooky:SetControllableByPlayer(pid, true)
	spooky:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	LevelAllAbility(spooky)
	FindClearSpaceForUnit(spooky, spooky:GetAbsOrigin(), true)
	spooky:AddNewModifier(caster, nil, "modifier_kill", {duration = 40})

	-- Set skeletal stat according to parameters
	spooky:SetMaxHealth(keys.Health)
	spooky:SetBaseMaxHealth(keys.Health)
	spooky:SetHealth(keys.Health)
	spooky:SetBaseDamageMax(keys.Damage)
	spooky:SetBaseDamageMin(keys.Damage)

	-- Bonus properties(give it 0.1 sec delay just in case)
	Timers:CreateTimer(0.1, function()
	
		spooky:SetMaxHealth(spooky:GetMaxHealth() + hero:GetIntellect()*keys.HealthRatio)
		spooky:SetHealth(spooky:GetMaxHealth())
		spooky:SetBaseMoveSpeed(spooky:GetBaseMoveSpeed() + hero:GetIntellect()*keys.MSRatio)
		if unitname == "caster_5th_skeleton_warrior" then
			spooky:SetPhysicalArmorBaseValue(spooky:GetPhysicalArmorValue() + hero:GetIntellect()*keys.ArmorRatio)
		else
			spooky:SetBaseDamageMax(spooky:GetBaseDamageMin() + hero:GetIntellect()*keys.DamageRatio)
			spooky:SetBaseDamageMin(spooky:GetBaseDamageMax() + hero:GetIntellect()*keys.DamageRatio)
		end 
	end)


	
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize Dragon Summon

	caster : Workshop
	ability : The respective item
]]
function OnSummonDragon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local pid = caster:GetPlayerOwner():GetPlayerID()

	if caster.IsMobilized then return end 

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
	drag:AddItem(CreateItem("item_caster_5th_mount" , nil, nil))
	FillInventory(drag)
	drag:AddNewModifier(caster, nil, "modifier_kill", {duration = 60})

	drag:SetMaxHealth(keys.Health)
	drag:SetBaseMaxHealth(keys.Health)
	drag:SetHealth(keys.Health)
	drag:SetBaseDamageMax(keys.Damage)
	drag:SetBaseDamageMin(keys.Damage)
	drag:SetMana(drag:GetMaxMana() + hero:GetIntellect()*keys.ManaRatio)
	drag:SetMana(drag:GetMaxMana())

	Timers:CreateTimer(0.1, function()
		-- Bonus properties(give it 0.1 sec delay just in case)
		local newHealth = drag:GetMaxHealth() + hero:GetIntellect()*keys.HealthRatio
		drag:SetMaxHealth(newHealth)
		drag:SetBaseMaxHealth(newHealth)
		drag:SetHealth(newHealth)
		drag:SetBaseMoveSpeed(drag:GetBaseMoveSpeed() + hero:GetIntellect()*keys.MSRatio)
	end)

	local skillLevel = 1 + (hero:GetLevel() - 1)/3
	if skillLevel > 8 then skillLevel = 8 end

	drag:FindAbilityByName("caster_5th_dragon_frostbite"):SetLevel(skillLevel)
	drag:FindAbilityByName("caster_5th_dragon_arcane_wrath"):SetLevel(skillLevel)
    local playerData = {
        transport = drag:entindex()
    }
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "player_summoned_transport", playerData )
end

--[[
	Author: Dun1007
	Date: 8.23.2015.
	
	Initialize Dragon Summon

	caster : Workshop
	ability : The respective item
]]
function CasterFarSight(keys)
	local caster = keys.caster
	local radius = keys.Radius
	local hero = caster:GetPlayerOwner():GetAssignedHero() 
	local dist = (hero:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

	if caster.IsMobilized then return end 

	if dist > 500 then
		keys.ability:EndCooldown() 
		caster:GiveMana(100)
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Caster_Out_Of_Radius")
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
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_territory_root")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mobilize", {})
	caster.IsMobilized = true
	caster:SwapAbilities("caster_5th_mobilize", "caster_5th_immobilize", false, true) 

	caster:SwapAbilities("caster_5th_mana_drain", "fate_empty5", false, true)
	caster:SwapAbilities("caster_5th_territory_explosion", "fate_empty3", false, true)
	caster:SwapAbilities("caster_5th_recall", "fate_empty4", false, true)
	caster:SwapAbilities("fate_empty_nothidden", "caster_5th_dimensional_jump", false, true)
end

function OnTerritoryImmobilize(keys)
	local caster = keys.caster

	if caster.IsMobilized then 
		caster.IsMobilized = false
	else 
		return
	end
	caster:RemoveModifierByName("modifier_mobilize")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_territory_root", {}) 
	caster:SwapAbilities("caster_5th_mobilize", "caster_5th_immobilize", true, false) 

	caster:SwapAbilities("caster_5th_mana_drain", "fate_empty5", true, false)
	caster:SwapAbilities("caster_5th_territory_explosion", "fate_empty3", true, false)
	caster:SwapAbilities("caster_5th_recall", "fate_empty4", true, false)
	caster:SwapAbilities("fate_empty_nothidden", "caster_5th_dimensional_jump", true, false)
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

--[[
	Author: Dun1007
	Date: 8.24.2015.
	
	Issues stop order when Skeleton attempts attack a ward
]]
function StopAttack(keys)
	local caster = keys.caster
	local target = keys.target
	--if target:GetUnitName() == "ward_familiar" then caster:Stop() end
end 

--[[
	Author: Dun1007
	Date: 8.24.2015.
	
	Applies stun when Skeleton's bash is successful
]]
function OnSkeleBashSucceed(keys)
	local caster = keys.caster
	local target = keys.target
	keys.target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.BashDuration})
end

--[[
	Author: Dun1007
	Date: 8.24.2015.
	
	Launch the breath of ice frontward
]]
function OnFrostbiteStart(keys)
	local caster = keys.caster
	local targetPos = keys.target_points[1] 
	local direction = targetPos - caster:GetAbsOrigin()
	direction = direction/direction:Length2D()

	local icebreath = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 1000,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 900 - keys.EndRadius, -- We need this to take end radius of projectile into account
        fStartRadius = 100,
        fEndRadius = keys.EndRadius,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 700
	}
	projectile = ProjectileManager:CreateLinearProjectile(icebreath)

	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl( pfx, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( pfx, 1, direction * 700 * 1.333 )
	ParticleManager:SetParticleControl( pfx, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( pfx, 9, caster:GetAbsOrigin() )

	caster:EmitSound("Hero_Jakiro.DualBreath")

	Timers:CreateTimer(0.8, function()
		ParticleManager:DestroyParticle(pfx, false)
	end)
end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Apply damage and root to enemies hit by ice breath
]]
function OnFrostbiteHit(keys)
	local caster = keys.caster 
	local target = keys.target
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_frostbite_root", {})

end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Attach effect when Arcane Wrath starts casting
]]
function OnArcaneWrathCast(keys)
	local caster = keys.caster 
	local pfx = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_casterribbons_arcana1.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl( pfx, 0, Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, caster:GetAbsOrigin().z+300))
	caster:EmitSound("Hero_Ancient_Apparition.ColdFeetCast")
	Timers:CreateTimer(1.0, function()
		ParticleManager:DestroyParticle(pfx, false)
	end)
end

--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	BOOM
]]
function OnArcaneWrathStart(keys)
	local caster = keys.caster
	local targetPos = keys.target_points[1]
    local targets = FindUnitsInRadius(caster:GetTeam(), targetPos, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
    for k,v in pairs(targets) do
    	DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = keys.StunDuration})
    end


	EmitSoundOnLocationWithCaster(targetPos, "Hero_ObsidianDestroyer.SanityEclipse.Cast", caster)
	local ArcaneWrathFx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf", PATTACH_CUSTOMORIGIN, caster)
  	ParticleManager:SetParticleControl(ArcaneWrathFx, 0, targetPos) 
	ParticleManager:SetParticleControl(ArcaneWrathFx, 1, Vector(400, 0, 0)) 

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(ArcaneWrathFx, false)
	end)
end

function OnMountStart(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	Timers:CreateTimer(0.2, function()
		if caster:IsAlive() and not hero:HasModifier("jump_pause") then
			if hero.IsMounted then
				-- If Caster is attempting to unmount on not traversable terrain
				if GridNav:IsBlocked(caster:GetAbsOrigin()) or not GridNav:IsTraversable(caster:GetAbsOrigin()) then
					keys.ability:EndCooldown()
					SendErrorMessage(hero:GetPlayerOwnerID(), "#Cannot_Unmount")
					return								
				else
					caster:SwapAbilities("caster_5th_dragon_arcane_wrath", "fate_empty2", false, true) 
					hero:RemoveModifierByName("modifier_mount_caster")
					caster:RemoveModifierByName("modifier_mount")
					hero.IsMounted = false
					SendMountStatus(hero)
				end
			elseif (caster:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 400 then
				hero.IsMounted = true
				caster:SwapAbilities("caster_5th_dragon_arcane_wrath", "fate_empty2", true, false) 
				keys.ability:ApplyDataDrivenModifier(caster, hero, "modifier_mount_caster", {})
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_mount", {}) 
				SendMountStatus(hero)

				return
			end 
		end
	end)
end


--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Positions Caster on Dragon's back every tick as long as Caster is mounted
]]
function MountFollow(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	if not caster:IsNull() and IsValidEntity(caster) then
		hero:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,600))
	end
end
--[[
	Author: Dun1007
	Date: 8.25.2015.
	
	Un-mounts Caster
]]
function OnMountDeath(keys)
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:RemoveModifierByName("modifier_mount_caster")
	caster:SwapAbilities("caster_5th_dragon_arcane_wrath", "fate_empty2", true, true) 
	hero.IsMounted = false
	SendMountStatus(hero)
end

function OnItemStart(keys)
	local caster = keys.caster
	local randomitem = math.random(100)
	local item = nil

	if (caster.IsTerritoryPresent and (caster.Territory:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < 500) or caster.IsPrivilegeImproved then 
		if randomitem <= 33 then 
			item = CreateItem("item_s_scroll", nil, nil) 
		elseif randomitem <= 66 then
			item = CreateItem("item_a_scroll", nil, nil) 
		elseif randomitem <= 100 then
			item = CreateItem("item_b_scroll", nil, nil) 
		end	
	else 
		if randomitem <= 25 then 
			item = CreateItem("item_s_scroll", nil, nil) 
		elseif randomitem <= 55 then
			item = CreateItem("item_a_scroll", nil, nil) 
		elseif randomitem <= 100 then
			item = CreateItem("item_b_scroll", nil, nil) 
		end
	end

	caster:AddItem(item)
	CheckItemCombination(caster)

    SaveStashState(caster)
end

function OnArgosStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	if caster.IsArgosImproved then 
		keys.MaxShield = keys.MaxShield + 150 
		keys.ShieldAmount = keys.ShieldAmount + 100
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_argos_shield", {})
	
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
	caster:SwapAbilities("caster_5th_wall_of_flame", a1:GetName(), true, false) 
	caster:SwapAbilities("caster_5th_silence", a2:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_divine_words", a3:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_mana_transfer", a4:GetName(), true, true) 
	caster:SwapAbilities("caster_5th_close_spellbook", a5:GetName(), true,true) 
	caster:SwapAbilities("caster_5th_sacrifice", a6:GetName(), true, false) 
end

function AncientLevelUp(keys)
	local caster = keys.caster
	local a1 = caster:FindAbilityByName("caster_5th_wall_of_flame")
	a1:SetLevel(keys.ability:GetLevel())
	a1:EndCooldown()
	local a2 = caster:FindAbilityByName("caster_5th_silence")
	a2:SetLevel(keys.ability:GetLevel())
	a2:EndCooldown()
	local a3 = caster:FindAbilityByName("caster_5th_divine_words")
	a3:SetLevel(keys.ability:GetLevel())
	a3:EndCooldown()
	local a4 = caster:FindAbilityByName("caster_5th_mana_transfer")
	a4:SetLevel(keys.ability:GetLevel())
	a4:EndCooldown()
	local a5 = caster:FindAbilityByName("caster_5th_sacrifice")
	a5:SetLevel(keys.ability:GetLevel())
	a5:EndCooldown()
end

function OnFirewallStart(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	if caster.IsHGImproved then keys.Damage = keys.Damage + caster:GetIntellect()*ATTRIBUTE_HG_INT_MULTIPLIER end

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
		v:AddNewModifier(caster, nil, "modifier_disarmed", {duration=keys.Duration})
	end
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_silence.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0 , targetPoint)
	ParticleManager:SetParticleControl(particle, 1 , Vector(300,0,0))
	ParticleManager:SetParticleControl(particle, 3 , Vector(300,0,0))

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(particle, false)
		return nil
	end)
end

function OnDWStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local rainCount = 0
	if caster.IsHGImproved then keys.Damage = keys.Damage + caster:GetIntellect()*ATTRIBUTE_HG_INT_MULTIPLIER*3 end

    Timers:CreateTimer(0.5, function()
    	if rainCount == 3 then return end
    	caster:EmitSound("Hero_Luna.LucentBeam.Target")
		local dummy = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		dummy:SetAbsOrigin(targetPoint)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_ABSORIGIN, dummy)
		ParticleManager:SetParticleControl(particle, 0, targetPoint)
		ParticleManager:SetParticleControl(particle, 1, targetPoint)
		ParticleManager:SetParticleControl(particle, 5, targetPoint)
		ParticleManager:SetParticleControl(particle, 6, targetPoint)
		Timers:CreateTimer(2.0, function()
			dummy:RemoveSelf()
		end)

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
	caster.SacFx = ParticleManager:CreateParticle("particles/custom/caster/sacrifice/caster_sacrifice_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( caster.SacFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl( caster.SacFx, 1, Vector(keys.Radius,0,0))
end

function RemoveSacrificeModifier(keys)
	local caster = keys.caster
	keys.caster:RemoveModifierByName("modifier_big_bad_voodoo")
	keys.caster:RemoveModifierByName("modifier_big_bad_voodoo_channeling")

	ParticleManager:DestroyParticle( caster.SacFx, false )
	ParticleManager:ReleaseParticleIndex( caster.SacFx )
	caster.SacFx = nil
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

function CreateSacrificeAllyParticle(keys)
	ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_buff_j.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
end

function OnMTStart(keys)
	local caster = keys.caster
	local target = keys.target
	local duration = keys.Duration
	local durCount = 0
	if target == caster then 
		keys.ability:EndCooldown()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Target_Self")
		return
	end
	caster.IsManaTransferActive = true
	Timers:CreateTimer(function()
		if durCount > duration then return end
		if caster:GetMana() == 0 then return end
		if target:GetMaxMana() == target:GetMana() then return end
		if caster.IsManaTransferActive then 
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
	local caster = keys.caster
	caster.IsManaTransferActive = false
end

function OnAncientClosed(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)

	local ultiName = "caster_5th_hecatic_graea"
	if caster.IsHGComboEnabled then 
		print("combo is currently active")
		ultiName = "caster_5th_hecatic_graea_powered"
	end
	caster:SwapAbilities(a1:GetName(), "caster_5th_argos", true ,true) 
	caster:SwapAbilities(a2:GetName(), "caster_5th_ancient_magic", true, true) 
	caster:SwapAbilities(a3:GetName(), "caster_5th_rule_breaker", false, true) 
	caster:SwapAbilities(a4:GetName(), "caster_5th_territory_creation", true, true) 
	caster:SwapAbilities(a5:GetName(), "caster_5th_item_construction", true, true) 
	caster:SwapAbilities(a6:GetName(), ultiName, false, true )
	local spellbook = caster:FindAbilityByName("caster_5th_ancient_magic")
	if spellbook:GetToggleState() then
		spellbook:ToggleAbility()
	end
end

function OnRBStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	ApplyStrongDispel(target)
	if caster:GetName() == "npc_dota_hero_crystal_maiden" then
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_c_rule_breaker", {}) 
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_l_rule_breaker", {}) 
	end
	EmitGlobalSound("Caster.RuleBreaker") 
	CasterCheckCombo(keys.caster,keys.ability)

	
	if caster.IsRBImproved then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(25)
		giveUnitDataDrivenModifier(caster, target, "revoked", 7.5)
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
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local radius = keys.Radius
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local maxBolt = keys.BoltAmount
	local travelTime = 0.7
	local ascendTime = travelTime+2.0
	local descendTime = ascendTime+1.0
	local diff = (targetPoint - caster:GetAbsOrigin()) * 1/travelTime
	if caster.IsHGImproved then
		maxBolt = maxBolt + 3
	end 
	if caster.IsHGImproved then keys.Damage = keys.Damage + caster:GetIntellect()*ATTRIBUTE_HG_INT_MULTIPLIER end

	local initTargets = 0
	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(800) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_anim", {}) 
	--EmitGlobalSound("Caster.Hecatic") 

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", descendTime)
	Timers:CreateTimer(descendTime, function()
		giveUnitDataDrivenModifier(caster, caster, "jump_pause_postdelay", 0.15)
	end)
	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), 1000))
	--allows caster to jump over walls
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)

	Timers:CreateTimer(travelTime, function()  
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
		--caster:SetAbsOrigin(caster:GetGroundPosition(caster:GetAbsOrigin(), caster)+Vector(0,0,1000))
	return end) 
	Timers:CreateTimer(ascendTime, function()  
		caster:SetPhysicsVelocity( Vector( 0, 0, -650) )
	return end) 

	--[[local floatCounter = 0
	Timers:CreateTimer(ascendTime, function()  
		if floatCounter > (descendTime - ascendTime) then return end
		local curLoc = caster:GetAbsOrigin()
		caster:SetAbsOrigin(Vector(curLoc.x, curLoc.y, curLoc.z + 1000))
		floatCounter = floatCounter + 0.033
		return 0.033
	end)]]

	Timers:CreateTimer(descendTime, function()
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	return end)

	local isFirstLoop = false
	Timers:CreateTimer(0.7, function()
		-- For the first round of shots, find all servants within AoE and guarantee one ray hit
		if isFirstLoop == false then 
			isFirstLoop = true
			initTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(initTargets) do
				DropRay(caster, keys.Damage, keys.RadiusBolt, keys.ability, v:GetAbsOrigin(), "particles/custom/caster/hecatic_graea/ray.vpcf")
			end
			maxBolt = maxBolt - #initTargets
		else
			if maxBolt <= boltCount then return end
		end

		local rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		while GridNav:IsBlocked(rayTarget) or not GridNav:IsTraversable(rayTarget) do
			rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		end
		DropRay(caster, keys.Damage, keys.RadiusBolt, keys.ability, rayTarget, "particles/custom/caster/hecatic_graea/ray.vpcf")
	    boltCount = boltCount + 1
		return 0.1
    end
    )
	Timers:CreateTimer(1.0, function() EmitGlobalSound("Caster.Hecatic") EmitGlobalSound("Caster.Hecatic_Spread") caster:EmitSound("Misc.Crash") return end)
end

function DropRay(caster, damage, radius, ability, targetPoint, particle)
	local casterLocation = caster:GetAbsOrigin()
	
	-- print(damage)
	-- Particle
	local dummy = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)

	local fxIndex = ParticleManager:CreateParticle(particle, PATTACH_POINT, dummy)
	ParticleManager:SetParticleControlEnt(fxIndex, 0, dummy, PATTACH_POINT, "attach_hitloc", dummy:GetAbsOrigin(), true)
	local portalLocation = casterLocation + (targetPoint - casterLocation):Normalized() * 300
	portalLocation.z = casterLocation.z
	ParticleManager:SetParticleControl(fxIndex, 4, portalLocation)

	local casterDirection = (portalLocation - targetPoint):Normalized()
	casterDirection.x = casterDirection.x * -1
	casterDirection.y = casterDirection.y * -1
	dummy:SetForwardVector(casterDirection)

	--DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, radius, true, 0.5)

	Timers:CreateTimer(2, function()
		dummy:RemoveSelf()
	end)
		
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
    	DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    	v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
	end
end

function OnHGPStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local radius = keys.Radius
	local boltradius = keys.RadiusBolt
	local boltvector = nil
	local boltCount  = 0
	local maxBolt = 10
	local barrageRadius = keys.Radius
	local travelTime = 0.7
	local ascendTime = travelTime+4.0
	local descendTime = ascendTime+1.0
	if caster.IsHGImproved then keys.Damage = keys.Damage + caster:GetIntellect()*ATTRIBUTE_HG_INT_MULTIPLIER end

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_powered_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	
	if caster.IsHGImproved then
		barrageRadius = barrageRadius + 300
		maxBolt = 13
	end 

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(800) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_hecatic_graea_anim", {}) 
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", descendTime)
	local diff = (targetPoint - caster:GetAbsOrigin()) * 1/travelTime
	local fly = Physics:Unit(caster)
	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(Vector(diff:Normalized().x * diff:Length2D(), diff:Normalized().y * diff:Length2D(), 1000))
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetAutoUnstuck(false)
	Timers:CreateTimer(travelTime, function()  
		ParticleManager:CreateParticle("particles/custom/screen_purple_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
	return end) 
	Timers:CreateTimer(ascendTime, function()  
		local dummy = CreateUnitByName( "sight_dummy_unit", caster:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber() );
		caster:SetPhysicsVelocity( Vector( 0, 0, dummy:GetAbsOrigin().z - caster:GetAbsOrigin().z ) )
		dummy:RemoveSelf()
	return end) 
	Timers:CreateTimer(descendTime, function()  
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit( caster, caster:GetAbsOrigin(), true )
	return end)

	Timers:CreateTimer(travelTime, function()
		if boltCount == maxBolt then return end

		local rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		while GridNav:IsBlocked(rayTarget) or not GridNav:IsTraversable(rayTarget) do
			rayTarget = RandomPointInCircle(GetGroundPosition(caster:GetAbsOrigin(), caster), radius)
		end
		DropRay(caster, keys.Damage, keys.RadiusBolt, keys.ability, rayTarget, "particles/custom/caster/hecatic_graea_powered/ray.vpcf")

	    boltCount = boltCount + 1
		return 0.1
    end
    )

	
	Timers:CreateTimer(travelTime+2.5, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), GetGroundPosition(caster:GetAbsOrigin(), caster), nil, barrageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
        	DoDamage(caster, v, 1500, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	--v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
		end
  	  	local particle = ParticleManager:CreateParticle("particles/custom/caster/hecatic_graea_powered/area.vpcf", PATTACH_CUSTOMORIGIN, caster)
  	  	ParticleManager:SetParticleControl(particle, 0, GetGroundPosition(caster:GetAbsOrigin(), caster)) 
  	  	-- print(radius)
	    ParticleManager:SetParticleControl(particle, 1, Vector(barrageRadius * 2.5, 1, 1))
	    ParticleManager:SetParticleControl(particle, 2, Vector(barrageRadius * 75, 1, 1))
	    caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
		-- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, barrageRadius, true, 1)
		return
    end
    )

	-- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, radius, true, 1)

	Timers:CreateTimer(1.0, function() 
		EmitGlobalSound("Caster.Hecatic_Spread") 
		--EmitGlobalSound("Caster.Hecatic") 
		caster:EmitSound("Misc.Crash") 
	return end)
end

function CasterCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("caster_5th_rule_breaker") and caster:FindAbilityByName("caster_5th_hecatic_graea"):IsCooldownReady() and caster:FindAbilityByName("caster_5th_hecatic_graea_powered"):IsCooldownReady() then
			caster:SwapAbilities("caster_5th_hecatic_graea", "caster_5th_hecatic_graea_powered", false, true) 
			caster.IsHGComboEnabled = true
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster:SwapAbilities("caster_5th_hecatic_graea", "caster_5th_hecatic_graea_powered", true, false) 
				caster.IsHGComboEnabled = false
			end
			})			
		end
	end
end

function OnImproveTerritoryCreationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsTerritoryImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveArgosAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsArgosImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveHGAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsHGImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
	ATTRIBUTE_HG_INT_MULTIPLIER = 1
end

function OnDaggerOfTreacheryAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsRBImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
