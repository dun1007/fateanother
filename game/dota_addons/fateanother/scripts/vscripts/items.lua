require("physics")
require("util")
cdummy = nil
itemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt") 


function ParseCombinationKV()
	for k,v in pairs(itemKV) do
		if string.match(k, "recipe") then
			for k2, v2 in pairs(v) do
				if k2 == "ItemRequirements" then
					for k3, v3 in pairs(v2) do

						print("Item Name : " .. k)
						comp1, comp2 = string.match(v3, "([^;]+);([^;]+)")
						if k == "item_recipe_healing_scroll" then
							comp1 = "item_mana_essence"
							comp2 = "item_recipe_healing_scroll"
						elseif k == "item_recipe_a_plus_scroll" then
							comp1 = "item_a_scroll"
							comp2 = "item_recipe_a_plus_scroll"
						end
						print(comp1 .. " " .. comp2)
					end
				end
			end
		end
	end
end


function OnManaEssenceAcquired(keys)
	print("Mana Essence Purchased")
end 

function OnBaseEntered(trigger)
	local hero = trigger.activator
	hero.IsInBase = true
	FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerOwnerID(), _error = "Entered Base(Regular Item Cost)"} )
	print("Base entered")
end

function OnBaseLeft(trigger)
	local hero = trigger.activator
	hero.IsInBase = false
	
	FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerOwnerID(), _error = "Left Base(50% Additiona Item Cost)" } )
	print("Base left")
end

function TransferItem(keys)
	local item = keys.ability
	local caster = keys.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	local stash_item = hero:GetItemInSlot(keys.Slot+5) -- This looks for slot 6/7/8/9/10/11(Stash)
	--PrintTable(stash_item)
	-- If item is found, remove it from stash and add it to hero
	if stash_item ~= nil then
		--[[If hero has empty inventory slot, move item to hero
		local hero_item = hero:GetItemInSlot(i)
		for i=0, 5 do
			if hero_item == nil then
				hero:AddItem(stash_item) 
				caster:RemoveItem(stash_item)
				return
			end
		end]]
		local itemName = stash_item:GetName()
		stash_item:RemoveSelf()
		--Timers:CreateTimer( 0.033, function()
		hero:AddItem(CreateItem(itemName, nil, nil)) 
		CheckItemCombination(hero)
	else
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "No Items Found in Chosen Slot of Stash" } )
	end

end

function PotInstantHeal(keys)
	local caster = keys.caster
	caster:Heal(500, caster)
	caster:GiveMana(300) 

	local healFx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_g.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(healFx, 1, caster:GetAbsOrigin()) -- target effect location

	-- Destroy particle
	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(healFx, false)
	end)
end

function TPScroll(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	print(caster:GetAbsOrigin().y .. " and " .. caster:GetAbsOrigin().x)
	if caster:GetAbsOrigin().y < -2000 or targetPoint.y < -2000 then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Invalid Location" } )
		--caster:AddItem(CreateItem("item_teleport_scroll" , caster, nil))		
		return
	end


	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, 2000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, 0, FIND_CLOSEST, false) 
	if targets[1] == nil then
		caster.TPLoc = nil
	else 
		caster.TPLoc = targets[1]:GetAbsOrigin()
		local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_POINT, caster )
		ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true )

	    local particledummy = CreateUnitByName("sight_dummy_unit", targets[1]:GetAbsOrigin(), false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	    particledummy:SetDayTimeVisionRange(0)
	    particledummy:SetNightTimeVisionRange(0)
	    particledummy:AddNewModifier(caster, nil, "modifier_kill", {duration = 1.0})

		local pfx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_POINT, particledummy )
		ParticleManager:SetParticleControlEnt( pfx2, 0, particledummy, PATTACH_POINT, "attach_hitloc", particledummy:GetAbsOrigin(), true )

		caster:EmitSound("Hero_Wisp.Relocate")
		particledummy:EmitSound("Hero_Wisp.Relocate")

		-- Destroy particle
		Timers:CreateTimer(2.0, function()
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:DestroyParticle(pfx2, false)
		end)
	end

end

function TPSuccess(keys)
	local caster = keys.caster
	print(caster:GetAbsOrigin().y)
	if caster:GetAbsOrigin().y < -2000 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Invalid Location" } )
		caster:AddItem(CreateItem("item_teleport_scroll" , caster, nil))
	elseif caster.TPLoc == nil then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Have Ward Nearby Targeted Location" } )
		caster:AddItem(CreateItem("item_teleport_scroll" , caster, nil))
	else
		caster:EmitSound("Hero_Wisp.Return")
		caster:SetAbsOrigin(caster.TPLoc)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end
end

function MassTPSuccess(keys)
	local caster = keys.caster
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1000
            , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)	
	if caster.TPLoc == nil then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Have Ward Nearby Targeted Location" } )
		caster:AddItem(CreateItem("item_teleport_scroll" , caster, nil))
	else
		caster:EmitSound("Hero_Wisp.Return")
		for k,v in pairs(targets) do
			v:SetAbsOrigin(caster.TPLoc)
			FindClearSpaceForUnit(v, v:GetAbsOrigin(), true)
		end
	end
end

function TPFail(keys)
	print("TP failed")
end

function WardFam(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	caster.ward = CreateUnitByName("ward_familiar", targetPoint, true, caster, caster, caster:GetTeamNumber())
	caster.ward:AddNewModifier(caster, caster, "modifier_invisible", {}) 
	caster.ward:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = keys.Radius, duration = keys.Duration}) 
    caster.ward:AddNewModifier(caster, caster, "modifier_kill", {duration = keys.Duration})

    EmitSoundOnLocationForAllies(targetPoint,"DOTA_Item.ObserverWard.Activate",caster)
end

function OnWardDeath(keys)
	local caster = keys.caster
	--caster.ward:ForceKill(true)
end

function ScoutFam(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()
	local scout = CreateUnitByName("scout_familiar", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	scout:SetControllableByPlayer(pid, true)
	keys.ability:ApplyDataDrivenModifier(caster, scout, "modifier_banished", {}) 
	LevelAllAbility(scout)
   	scout:AddNewModifier(caster, nil, "modifier_kill", {duration = 40})
end

function BecomeWard(keys)
	local caster = keys.caster
	local transform = CreateUnitByName("ward_familiar", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())

	transform:AddNewModifier(caster, caster, "modifier_invisible", {}) 
	transform:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 1600, duration = 105}) 
	transform:AddNewModifier(caster, caster, "modifier_kill", {duration = 105})
	caster:EmitSound("DOTA_Item.ObserverWard.Activate") 
	Timers:CreateTimer({
		endTime = 0.1,
		callback = function()
		caster:RemoveSelf() 
		return
	end
	})
end

function SpiritLink(keys)
	print("Spirit Link Used")
	local caster = keys.caster
	local targets = keys.target_entities
	--local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
	local linkTargets = {}
	caster:EmitSound("Hero_Warlock.FatalBonds" )
	-- set up table for link
	for i=1,#targets do
		linkTargets[i] = targets[i]
		--print("Added hero to link table : " .. targets[i]:GetName())
		RemoveHeroFromLinkTables(targets[i])

		-- particle
    	local pulseFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_warlock/warlock_fatal_bonds_pulse.vpcf", PATTACH_CUSTOMORIGIN, caster )
	    ParticleManager:SetParticleControl( pulseFx, 0, caster:GetAbsOrigin() + Vector(0,0,100))
	    ParticleManager:SetParticleControl( pulseFx, 1, targets[i]:GetAbsOrigin() + Vector(0,0,100))
	end

	-- add list of linked targets to hero table
	for i=1,#targets do	
		targets[i].linkTable = linkTargets
		print("Table Contents " .. i .. " : " .. targets[i]:GetName())
		keys.ability:ApplyDataDrivenModifier(caster, targets[i], "modifier_share_damage", {}) 
	end
end

function OnLinkDamageTaken(keys)
    LoopOverHeroes(function(hero)
        if hero:HasModifier("modifier_share_damage") and hero:GetHealth() == 0 then
            print("Spirit Link broken on " .. hero:GetName())
            hero:SetHealth(1)
            hero:RemoveModifierByName("modifier_share_damage")
            RemoveHeroFromLinkTables(hero)
        end    
    end)
end

function OnLinkDestroyed(keys)
	local caster = keys.caster
	local target = keys.target
end

function GemOfResonance(keys)
	-- body
end


function Blink(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local newTargetPoint = nil

	if caster:HasModifier("modifier_purge") or caster:HasModifier("modifier_aestus_domus_aurea_lock") then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Blink" } )
		keys.ability:EndCooldown()
		return
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown()  
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Travel to Targeted Location" } )
		return 
	end 

	
	-- particle
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, casterPos)
	caster:EmitSound("Hero_Antimage.Blink_out")
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	-- blink
	local diff = targetPoint - caster:GetAbsOrigin()
	if diff:Length() <= 1000 then 
		caster:SetAbsOrigin(targetPoint)
		ProjectileManager:ProjectileDodge(caster)
		--ParticleManager:SetParticleControl(particle2, 0, targetPoint)

	else  
		newTargetPoint = caster:GetAbsOrigin() + diff:Normalized() * 1000
		local i = 1
		while GridNav:IsBlocked(newTargetPoint) or not GridNav:IsTraversable(newTargetPoint) or i == 100 do
			i = i+1
			newTargetPoint = caster:GetAbsOrigin() + diff:Normalized() * (1000 - i*10)
		end

		caster:SetAbsOrigin(newTargetPoint) 
		ProjectileManager:ProjectileDodge(caster)
		ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
	end

	
	caster:EmitSound("Hero_Antimage.Blink_in")
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(particle, false)
		ParticleManager:DestroyParticle(particle2, false)
	end)
end

function StashBlink(keys)
	local caster = keys.caster
	local casterinitloc = caster:GetAbsOrigin() 
	local targetPoint = keys.target_points[1]
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	caster:SetAbsOrigin(hero:GetAbsOrigin())
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	
	Timers:CreateTimer(8.0, function() 
		caster:SetAbsOrigin(casterinitloc) 
		return
	end)

	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	local particle2 = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin()) -- target effect location
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

function CScroll(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()
	cdummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	cdummy:AddNewModifier(caster, caster, "modifier_kill", {duration = 10})
	local dummy_passive = cdummy:FindAbilityByName("dummy_unit_passive")
	dummy_passive:SetLevel(1)
	local fire = cdummy:FindAbilityByName("dummy_c_scroll")
	fire:SetLevel(1)
	if fire:IsFullyCastable() then 
		cdummy:CastAbilityOnTarget(keys.target, fire, pid)
	end

	caster:RemoveItem(keys.ability)

	--[[Timers:CreateTimer(5.0, function()
		if IsValidEntity(cdummy) and not cdummy:IsNull() then
			cdummy:RemoveSelf()
		end
	end)]]

end

function CScrollHit(keys)
	local caster = keys.caster
	local target = keys.target

	if IsSpellBlocked(keys.target) then return end
	DoDamage(keys.caster:GetPlayerOwner():GetAssignedHero(), keys.target, 100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	keys.target:EmitSound("Hero_EmberSpirit.FireRemnant.Explode")
	if not keys.target:IsMagicImmune() then
		keys.target:AddNewModifier(keys.caster:GetPlayerOwner():GetAssignedHero(), keys.target, "modifier_stunned", {Duration = 1.0}) 
	end
end

function CScrollEnd(keys)
	local caster = keys.caster 
	local target = keys.target
	if IsValidEntity(caster) and not caster:IsNull() then
		caster:RemoveSelf()
	end
end

function BScroll(keys)
	local caster = keys.caster
	caster.BShieldAmount = keys.ShieldAmount
	

end


function SScroll(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end

	DoDamage(caster, target, 400, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	ApplyPurge(target)
	local boltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster) 
	ParticleManager:SetParticleControl(boltFx, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

	local lightningBoltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(lightningBoltFx,0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(lightningBoltFx,1, target:GetAbsOrigin())

	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(boltFx, false)
		ParticleManager:DestroyParticle(lightningBoltFx, false)
	end)
end

function EXScroll(keys)
	local caster = keys.caster
	local target = keys.target
	local lightning = {
		attacker = caster,
		victim = target,
		damage = 600,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = keys.ability
	}
	DoDamage(caster, target, 600, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	ApplyPurge(target)

	local boltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster) 
	--local lightningBoltFx = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(boltFx, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+((target:GetBoundingMaxs().z - target:GetBoundingMins().z)/2)))

	local forkCount = 0
	local dist = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin() + dist:Normalized() * dist:Length2D() + 350 , nil, 700
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		if forkCount == 4 then return end
		if v ~= target then 
	        DoDamage(caster, v, 600, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        local bolt = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster) 
	        ParticleManager:SetParticleControl(bolt, 1, Vector(v:GetAbsOrigin().x,v:GetAbsOrigin().y,v:GetAbsOrigin().z+((v:GetBoundingMaxs().z - v:GetBoundingMins().z)/2)))
	        Timers:CreateTimer(2.0, function()
				ParticleManager:DestroyParticle(bolt, false)
			end) 
			
			--ParticleManager:SetParticleControl(lightningBoltFx,0, caster:GetAbsOrigin())
			--ParticleManager:SetParticleControl(lightningBoltFx,1, v:GetAbsOrigin())
	        forkCount = forkCount + 1
    	end
    end

   	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(boltFx, false)
		--ParticleManager:DestroyParticle(lightningBoltFx, false)
	end)
end



function HealingScroll(keys)
	local caster = keys.caster
	local healFx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_g.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 600
            , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		print("heal")
		ParticleManager:SetParticleControl(healFx, 1, v:GetAbsOrigin()) -- target effect location
         v:Heal(500, caster) 
    end

   	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(healFx, false)
	end)
end

function AntiMagic(keys)
	local caster = keys.caster
	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
end

function FullHeal(keys)
	local caster = keys.caster
	caster:SetHealth(caster:GetMaxHealth()) 
	caster:SetMana(caster:GetMaxMana())

	caster:EmitSound("DOTA_Item.Mekansm.Activate")
	local mekFx = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

   	Timers:CreateTimer(2.0, function()
		ParticleManager:DestroyParticle(mekFx, false)
	end)
end