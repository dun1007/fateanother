require("Physics")
require("util")
require("projectiles")

CharmModifierList = {
	"modifier_fiery_heaven_indicator",
	"modifier_frigid_heaven_indicator",
	"modifier_gust_heaven_indicator",
	"modifier_void_cleft_indicator"
}

CurrentCharmName = 0
CharmHandle = 0


--[[
Reduce charm stack on ally]]
function DeduceCharmStack(caster, modifierName)
	-- Deduce a stack from damage buff
	local currentStack = caster:GetModifierStackCount(modifierName, CharmHandle)
	caster:RemoveModifierByName(modifierName)
	if currentStack == 1 then
		caster:RemoveModifierByName(modifierName)
	else
		CharmHandle:ApplyDataDrivenModifier(caster, caster, modifierName, {}) 
		caster:SetModifierStackCount(modifierName, CharmHandle, currentStack-1)
	end
end

function OnArmedUpStart(keys)
	local caster = keys.caster
	local a1 = caster:FindAbilityByName("tamamo_soulstream") -- Soulstream 
	local a2 = caster:FindAbilityByName("tamamo_subterranean_grasp") -- Subterranean Grasp
	local a3 = nil
	if caster:GetAbilityByIndex(2):GetAbilityName() == "tamamo_mantra" then
		a3 = caster:FindAbilityByName("tamamo_mantra") -- Mantra
	else
		a3 = caster:FindAbilityByName("tamamo_mystic_shackle")
	end
	local a4 = caster:FindAbilityByName("fate_empty1") -- Armed Up
	local a5 = caster:FindAbilityByName("tamamo_armed_up") -- fate_empty1
	local a6 = caster:FindAbilityByName("tamamo_amaterasu") -- Amaterasu

	caster:SwapAbilities("tamamo_fiery_heaven", a1:GetName(), true, true) 
	caster:SwapAbilities("tamamo_frigid_heaven", a2:GetName(), true, true) 
	caster:SwapAbilities("tamamo_gust_heaven", a3:GetName(), true, true) 
	--caster:SwapAbilities("fate_empty2", a4:GetName(), true, true) 
	caster:SwapAbilities("tamamo_close_spellbook", a5:GetName(), true,true) 
	caster:SwapAbilities("fate_empty2", a6:GetName(), true, true) 
end

function OnFireCharmLoaded(keys)
	local caster = keys.caster
	CharmHandle = keys.ability
	CurrentCharmName = "modifier_fiery_heaven_indicator"
	CloseCharmList(keys)
	if caster.IsWitchcraftAcquired then
		local armedUp = caster:FindAbilityByName("tamamo_armed_up")
		armedUp:EndCooldown()
		armedUp:StartCooldown(15)
	end
	-- Clear up other charm modifiers
	for i=1, #CharmModifierList do
		if caster:HasModifier(CharmModifierList[i]) then
			caster:RemoveModifierByName(CharmModifierList[i])
		end
	end
	-- Apply stacks
	local chargeAmount = caster:FindAbilityByName("tamamo_armed_up"):GetLevelSpecialValueFor("charge", 0)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_heaven_indicator", {}) 
	caster:SetModifierStackCount("modifier_fiery_heaven_indicator", keys.ability, chargeAmount)
end


function OnFreezeCharmLoaded(keys)
	local caster = keys.caster
	CharmHandle = keys.ability
	CurrentCharmName = "modifier_frigid_heaven_indicator"
	CloseCharmList(keys)
	if caster.IsWitchcraftAcquired then
		local armedUp = caster:FindAbilityByName("tamamo_armed_up")
		armedUp:EndCooldown()
		armedUp:StartCooldown(15)
	end

	for i=1, #CharmModifierList do
		if caster:HasModifier(CharmModifierList[i]) then
			caster:RemoveModifierByName(CharmModifierList[i])
		end
	end
	-- Apply stacks
	local chargeAmount = caster:FindAbilityByName("tamamo_armed_up"):GetLevelSpecialValueFor("charge", 0)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_frigid_heaven_indicator", {}) 
	caster:SetModifierStackCount("modifier_frigid_heaven_indicator", keys.ability, chargeAmount)
end

function OnGustCharmLoaded(keys)
	local caster = keys.caster
	CharmHandle = keys.ability
	CurrentCharmName = "modifier_gust_heaven_indicator"
	CloseCharmList(keys)
	if caster.IsWitchcraftAcquired then
		local armedUp = caster:FindAbilityByName("tamamo_armed_up")
		armedUp:EndCooldown()
		armedUp:StartCooldown(15)
	end

	for i=1, #CharmModifierList do
		if caster:HasModifier(CharmModifierList[i]) then
			caster:RemoveModifierByName(CharmModifierList[i])
		end
	end
	-- Apply stacks
	local chargeAmount = caster:FindAbilityByName("tamamo_armed_up"):GetLevelSpecialValueFor("charge", 0)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gust_heaven_indicator", {}) 
	caster:SetModifierStackCount("modifier_gust_heaven_indicator", keys.ability, chargeAmount)
end

--[[function OnVoidCharmLoaded(keys)
	local caster = keys.caster
	CloseCharmList(keys)
	for i=1, #CharmModifierList do
		if caster:HasModifier(CharmModifierList[i]) then
			caster:RemoveModifierByName(CharmModifierList[i])
		end
	end
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_void_cleft_indicator", nil)
end]]

function OnCharmListClosed(keys)
	local caster = keys.caster
	local armedUp = caster:FindAbilityByName("tamamo_armed_up")
	armedUp:EndCooldown() 

	CloseCharmList(keys)
end

function CloseCharmList(keys)
	local caster = keys.caster

	local a1 = caster:FindAbilityByName("tamamo_fiery_heaven") -- Soulstream 
	local a2 = caster:FindAbilityByName("tamamo_frigid_heaven") -- Subterranean Grasp
	local a3 = caster:FindAbilityByName("tamamo_gust_heaven") -- Mantra
	local a4 = caster:FindAbilityByName("fate_empty1") -- Armed Up
	local a5 = caster:FindAbilityByName("tamamo_close_spellbook") -- fate_empty1
	local a6 = caster:FindAbilityByName("fate_empty2") -- Amaterasu


	caster:SwapAbilities("tamamo_soulstream", a1:GetName(), true, true) 
	caster:SwapAbilities("tamamo_subterranean_grasp", a2:GetName(), true, true) 
	if caster:FindAbilityByName("tamamo_mystic_shackle"):IsHidden() then
		caster:SwapAbilities("tamamo_mantra", a3:GetName(), true, true) 
	else
		caster:SwapAbilities("tamamo_mystic_shackle", a3:GetName(), true, true) 
	end
	--caster:SwapAbilities("fate_empty2", a4:GetName(), true, true) 
	caster:SwapAbilities("tamamo_armed_up", a5:GetName(), true,true) 
	caster:SwapAbilities("tamamo_amaterasu", a6:GetName(), true, true) 
end

function OnCharmAttacked(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local loadedCharmName = ability:GetAbilityName()
	-- 6 stacks
	if loadedCharmName == "tamamo_fiery_heaven" then
		DeduceCharmStack(caster, "modifier_fiery_heaven_indicator")
		if IncrementCharmStack(caster, target, ability, "modifier_fiery_heaven_indicator_enemy") == 6 then
			target:RemoveModifierByName("modifier_fiery_heaven_indicator_enemy")
			DoDamage(caster, target, (target:GetMaxHealth()-target:GetHealth())*keys.StackDamage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)


			local explodeFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
			ParticleManager:SetParticleControl( explodeFx, 0, target:GetAbsOrigin())
			target:EmitSound("Ability.LightStrikeArray")
		else
			DoDamage(caster, target, target:GetHealth()*keys.Damage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			local explosionFx = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_soulstream_explosion_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
		end
	elseif loadedCharmName == "tamamo_frigid_heaven" then
		local ccDuration = keys.Duration
		local StackStunDuration = keys.StackStunDuration
		DeduceCharmStack(caster, "modifier_frigid_heaven_indicator")
		-- 6 stacks
		if IncrementCharmStack(caster, target, ability, "modifier_frigid_heaven_indicator_enemy") == 6 then
			target:RemoveModifierByName("modifier_frigid_heaven_indicator_enemy")
			target:AddNewModifier(caster, target, "modifier_stunned", {Duration = StackStunDuration})

			ability:ApplyDataDrivenModifier(caster, target, "modifier_frigid_heaven_stun_fx", {})
			target:EmitSound("Ability.FrostBlast")
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_frigid_heaven_slow", {})
			target:AddNewModifier(caster, target, "modifier_disarmed", {Duration = ccDuration})
			local explosionFx = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_soulstream_explosion_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
		end
	elseif loadedCharmName == "tamamo_gust_heaven" then
		DeduceCharmStack(caster, "modifier_gust_heaven_indicator")
		if IncrementCharmStack(caster, target, ability, "modifier_gust_heaven_indicator_enemy") == 6 then
			target:RemoveModifierByName("modifier_gust_heaven_indicator_enemy")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_gust_heaven_purge", {}) 
			if not IsImmuneToSlow(target) then ability:ApplyDataDrivenModifier(caster, target, "modifier_gust_heaven_purge_slow_tier1", {}) end
			if not IsImmuneToSlow(target) then ability:ApplyDataDrivenModifier(caster, target, "modifier_gust_heaven_purge_slow_tier2", {}) end
			target:EmitSound("DOTA_Item.DiffusalBlade.Activate")
		else
			target:AddNewModifier(caster, target, "modifier_silence", {Duration = 0.1})
			local explosionFx = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_soulstream_explosion_green.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
		end
	end

	target:EmitSound("Hero_Wisp.Spirits.Target")
end

function OnSoulstreamStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local frontward = caster:GetForwardVector()
	local ability = keys.ability

	-- Get the stack amount
	local currentStack = caster:GetModifierStackCount("modifier_soulstream_stack", ability)
	caster.CurrentSoulstreamStack = currentStack
	-- Check if caster has sufficient mana
	local additionalManaCost = 100*currentStack
	if caster:GetMana() < additionalManaCost then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Not Enough Mana" } )
		caster:SetMana(caster:GetMana() + 100) 
		keys.ability:EndCooldown() 
		return
	else
		caster:SetMana(caster:GetMana() - additionalManaCost)
	end
	-- Increment Soulstream stack
	if currentStack == 0 and caster:HasModifier("modifier_soulstream_stack") then currentStack = 1 end
	caster:RemoveModifierByName("modifier_soulstream_stack")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_soulstream_stack", {}) 
	caster:SetModifierStackCount("modifier_soulstream_stack", ability, currentStack + 1)


	local count = 0
	Timers:CreateTimer(function()
		if count == 5 then return end
		local projectile = CreateUnitByName("tamamo_charm_dummy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())

		local particleName, particleExpName = 0
		-- Deduce Charm stack if caster has it
		for i=1, #CharmModifierList do
			if caster:HasModifier(CharmModifierList[i]) then
				DeduceCharmStack(caster, CurrentCharmName)
				projectile.IsCharmLoaded = true
				projectile.LoadedCharm = CurrentCharmName
				projectile.LoadedCharmHandle = CharmHandle
				if CurrentCharmName == "modifier_fiery_heaven_indicator" then
					particleName = "particles/custom/tamamo/tamamo_soulstream_red_.vpcf"
					particleExpName = "particles/custom/tamamo/tamamo_soulstream_explosion_red.vpcf"
				elseif CurrentCharmName == "modifier_frigid_heaven_indicator" then 
					particleName = "particles/custom/tamamo/tamamo_soulstream_blue_.vpcf"
					particleExpName = "particles/custom/tamamo/tamamo_soulstream_explosion_blue.vpcf"
				elseif CurrentCharmName == "modifier_gust_heaven_indicator" then
					particleName = "particles/custom/tamamo/tamamo_soulstream_green_.vpcf"
					particleExpName = "particles/custom/tamamo/tamamo_soulstream_explosion_green.vpcf"
				end
				break
			end
			projectile.IsCharmLoaded = false
			particleName = "particles/units/heroes/hero_wisp/wisp_guardian_.vpcf"
			particleExpName = "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf"
		end
		-- Create particle FX
		local spiritFx = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, projectile)
		projectile.spiritParticle = spiritFx
		projectile.spiritExpParticleName = particleExpName
		local LRVec = Vector(0,0,0)
	    if math.random(2) == 1 then 
	    	LRVec = caster:GetAbsOrigin() + Vector(-frontward.y, frontward.x, 0) * math.random(500) - frontward*math.random(250)
	    else
	    	LRVec = caster:GetAbsOrigin() + Vector(frontward.y, -frontward.x, 0) * math.random(500) - frontward*math.random(250)
	    end
	    projectile.destination = LRVec
	    ability:ApplyDataDrivenModifier(caster, projectile, "modifier_soulstream_projectile", {})
	    Timers:CreateTimer(0.5, function()
	    	projectile.destination = targetPoint + (targetPoint - projectile:GetAbsOrigin()):Normalized() * math.random(500)
	    	return nil
	    end)
	    count = count+1
	    return 0.1
	end)

	--SpinInCircle(projectile, LRvec, 300)
	caster:EmitSound("Hero_Wisp.Spirits.Cast")
end


function OnSoulstreamProjectileTick(keys)
	local caster = keys.caster
	local target = keys.target 
	local casterLoc = target:GetAbsOrigin()
	local ability = keys.ability
	local damage = keys.Damage
	if caster.IsSpiritTheftAcquired then damage = damage+caster:GetIntellect()*0.5 end
	damage = damage + damage*caster.CurrentSoulstreamStack*keys.StackBonus/100

	local radius, charmDamage, stackDamage, ccDuration, StackStunDuration, mrReduction = 0
	-- Is Charm loaded for current projectile?
	if target.IsCharmLoaded then
		if target.LoadedCharm == "modifier_fiery_heaven_indicator" then
			charmDamage = target.LoadedCharmHandle:GetLevelSpecialValueFor("damage", 0)
			stackDamage = target.LoadedCharmHandle:GetLevelSpecialValueFor("stack_damage", 0)
		elseif target.LoadedCharm == "modifier_frigid_heaven_indicator" then
			ccDuration = target.LoadedCharmHandle:GetLevelSpecialValueFor("duration", 0)
			StackStunDuration = target.LoadedCharmHandle:GetLevelSpecialValueFor("stack_stun_duration", 0)
		elseif target.LoadedCharm == "modifier_gust_heaven_indicator" then
			mrReduction = target.LoadedCharmHandle:GetLevelSpecialValueFor("mr_reduction", 0)
		end
	end
	-- If target is found, remove projectile and do damage
	local targets = FindUnitsInRadius(caster:GetTeam(), casterLoc, nil, 75, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	if #targets ~= 0 then


		for k,v in pairs(targets) do
			if target.LoadedCharm == "modifier_fiery_heaven_indicator" then
				-- 6 stacks
				if IncrementCharmStack(target, v, target.LoadedCharmHandle, "modifier_fiery_heaven_indicator_enemy") == 6 then
					v:RemoveModifierByName("modifier_fiery_heaven_indicator_enemy")
					DoDamage(caster, v, (v:GetMaxHealth()-v:GetHealth())*stackDamage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)

					local explodeFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, v )
					ParticleManager:SetParticleControl( explodeFx, 0, v:GetAbsOrigin())
					v:EmitSound("Ability.LightStrikeArray")
				else
					DoDamage(caster, v, v:GetHealth()*charmDamage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			elseif target.LoadedCharm == "modifier_frigid_heaven_indicator" then
				-- 6 stacks
				if IncrementCharmStack(target, v, target.LoadedCharmHandle, "modifier_frigid_heaven_indicator_enemy") == 6 then
					v:RemoveModifierByName("modifier_frigid_heaven_indicator_enemy")
					v:AddNewModifier(caster, v, "modifier_stunned", {Duration = StackStunDuration})

					target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_frigid_heaven_stun_fx", {})
					v:EmitSound("Ability.FrostBlast")
				else
					v:AddNewModifier(caster, v, "modifier_disarmed", {Duration = ccDuration})
					ability:ApplyDataDrivenModifier(caster, v, "modifier_frigid_heaven_slow", {})
				end
			elseif target.LoadedCharm == "modifier_gust_heaven_indicator" then
				-- 6 stacks
				if IncrementCharmStack(target, v, target.LoadedCharmHandle, "modifier_gust_heaven_indicator_enemy") == 6 then
					v:RemoveModifierByName("modifier_gust_heaven_indicator_enemy")
					target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_gust_heaven_purge", {}) 
					if not IsImmuneToSlow(v) then target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_gust_heaven_purge_slow_tier1", {}) end
					if not IsImmuneToSlow(v) then target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_gust_heaven_purge_slow_tier2", {}) end
					v:EmitSound("DOTA_Item.DiffusalBlade.Activate")

				else
					v:AddNewModifier(caster, v, "modifier_silence", {Duration = 0.1})
				end 
			end	
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			if caster.IsSpiritTheftAcquired then 
				v:SetMana(v:GetMana()-25)
				caster:SetMana(caster:GetMana()+25)
			end
		end


		target:EmitSound("Hero_Wisp.Spirits.Target")
		local explosionFx = ParticleManager:CreateParticle(target.spiritExpParticleName, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
		OnSoulstreamProjectileEnd(keys)
	end
	local diff = target.destination - casterLoc
	target:SetAbsOrigin(target:GetAbsOrigin()+diff/10)
end

function IncrementCharmStack(caster, target, handle, modifierName)
	local currentStack = target:GetModifierStackCount(modifierName, handle)
	if currentStack == 0 and target:HasModifier(modifierName) then currentStack = 1 end
	target:RemoveModifierByName(modifierName) 
	handle:ApplyDataDrivenModifier(caster, target, modifierName, {}) 
	target:SetModifierStackCount(modifierName, handle, currentStack + 1)
	return currentStack+1
end

function OnSoulstreamProjectileEnd(keys)
	local caster = keys.caster
	local target = keys.target

	ParticleManager:DestroyParticle( target.spiritParticle, false )
	ParticleManager:ReleaseParticleIndex( target.spiritParticle )
	target:ForceKill(false)
end
--[[
	local LRvec = Vector(0,0,0)
    if math.random(2) == 1 then 
    	LRvec = caster:GetAbsOrigin() + Vector(-frontward.y, frontward.x, 0) * math.random(300)
    else
    	LRvec = caster:GetAbsOrigin() + Vector(frontward.y, -frontward.x, 0) * math.random(300)
    end
    ]]
--[[
Make half rotation
Side : Left(1) or Right(-1)
function SpinInCircle(unit, center, radius)
	local t = 0
	local time = 0
	unit:SetAbsOrigin(center:GetAb)

	Timers:CreateTimer(function() 
		if time > 0.5 then return end
	    local x = math.cos(t) * radius
	    local y = math.sin(t) * radius
	    lastPos = unit:GetAbsOrigin()

	    unit:SetAbsOrigin(Vector(center.x + x, center.y + y, 0))
	    
	    local diff = (unit:GetAbsOrigin() - lastPos):Normalized() 
	    unit:SetForwardVector(diff) 
	    t = t+0.35
	    time = time+0.033
	    return 0.033
    end)
end]]


--[[
Apply root modifier to target.

Author:Dun1007
Date:9/30/2015
]]
function OnSGStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	TamamoCheckCombo(caster, keys.ability)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_subterranean_grasp_delay", {})
	target:EmitSound("Hero_Visage.GraveChill.Cast")
end

function OnSGDestroy(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:StopSound("Hero_Visage.GraveChill.Target")
end 

function OnMantraStart(keys)
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability
	local orbAmount = keys.OrbAmount
	local modifierName = 0
	if caster:GetTeam() ~= target:GetTeam() then
		if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	end
	
	if target:HasModifier("modifier_mantra_ally") or target:HasModifier("modifier_mantra_enemy") then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Target Already Affected By Mantra" } )
		keys.ability:EndCooldown()
		caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(1))
		return	
	end
	caster.MantraTarget = target
	target.IsMantraProcOnCooldown = false 

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		modifierName = "modifier_mantra_ally"
		if caster.IsSeveredFateAcquired then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_mr_buff", {})
		end
	else
		if IsSpellBlocked(keys.target) then return end
		modifierName = "modifier_mantra_enemy"
		if caster.IsSeveredFateAcquired then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_mr_debuff", {})
		end
	end

	if caster.IsSeveredFateAcquired then
		--caster.IsSeveredFateActive = true
		caster.TetheredTarget = target
		
		--ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_tether", {})
		if caster:GetAbilityByIndex(2):GetName() == "tamamo_mantra" then
			caster:SwapAbilities("tamamo_mantra", "tamamo_mystic_shackle", true,true) 
			Timers:CreateTimer(3.0, function()
				caster:SwapAbilities("tamamo_mantra", "tamamo_mystic_shackle", true,false) 
			end)
		end
	end

	local castFx = ParticleManager:CreateParticle('particles/units/heroes/hero_oracle/oracle_purifyingflames_halo.vpcf', PATTACH_CUSTOMORIGIN, target) 
    ParticleManager:SetParticleControl(castFx, 0, target:GetOrigin())
    target:EmitSound("Item.LotusOrb.Target")

	-- Set stack amount1
	ability:ApplyDataDrivenModifier(caster, target, modifierName, {}) 
	target:SetModifierStackCount(modifierName, ability, orbAmount)
	for i=1, orbAmount do ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_vfx", {}) end
end

function OnShackleThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dist = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	if dist > 2500 then
		target:RemoveModifierByName("modifier_mystic_shackle")
	elseif dist > 700 then
		local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
		local normal = diff:Normalized()
		target:SetAbsOrigin(caster:GetAbsOrigin()+normal*700)
		FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
	end
end

function OnShackleStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_mystic_shackle_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	ability:ApplyDataDrivenModifier(caster, caster.MantraTarget, "modifier_mystic_shackle", {})
	giveUnitDataDrivenModifier(caster, caster, "locked", 3.0)
end

function OnShackleEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function OnMantraTakeDamage(keys)
	local caster = keys.caster 
	local target = caster.MantraTarget
	local attacker = keys.attacker
	local ability = keys.ability
	local damageTaken = keys.DamageTaken
	local orbDamage = keys.Damage
	local currentStack = 0
	local modifierName = 0
	local currentHealth = target:GetHealth() 

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		modifierName = "modifier_mantra_ally"
		if currentHealth == 0 then
			print("lethal")
		else
			if orbDamage < keys.DamageTaken then
				target:SetHealth(currentHealth + orbDamage)
			else
				target:SetHealth(currentHealth + keys.DamageTaken)
			end
		end
	else
		if target.IsMantraProcOnCooldown then 
			return
		else
			print(attacker:GetName() .. " attacked " .. target:GetName())
			target.IsMantraProcOnCooldown = true
			DoDamage(caster, target, orbDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			Timers:CreateTimer(0.299, function()
				target.IsMantraProcOnCooldown = false
			end)
		end 
		modifierName = "modifier_mantra_enemy"
	end

	local shieldFx = ParticleManager:CreateParticle('particles/units/heroes/hero_templar_assassin/templar_assassin_refraction_break.vpcf', PATTACH_CUSTOMORIGIN, caster) 
    ParticleManager:SetParticleControl(shieldFx, 1, target:GetOrigin())
	target:EmitSound("Hero_Lich.ChainFrostImpact.Hero")

	-- Set stack amount
	currentStack = target:GetModifierStackCount(modifierName, ability)
	--print("current mantra stack :" .. currentStack)
	target:RemoveModifierByName(modifierName)
	target:RemoveModifierByName("modifier_mantra_vfx")

	if currentStack ~= 1 then
		ability:ApplyDataDrivenModifier(caster, target, modifierName, {}) 
		target:SetModifierStackCount(modifierName, ability, currentStack-1)
		--for i=1, currentStack-1 do ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_vfx", {}) end
	end
end

--[[
Apply the aura modifier to caster
]]
function OnAmaterasuStart(keys)
	local caster = keys.caster
	local ability = keys.ability 
	if caster.CurrentAmaterasuDummy ~= nil then
		if IsValidEntity(caster.CurrentAmaterasuDummy) or not caster.CurrentAmaterasuDummy:IsNull() then
			caster.CurrentAmaterasuDummy:RemoveModifierByName("modifier_amaterasu_aura")
		end
	else
	end

	EmitGlobalSound("Hero_KeeperOfTheLight.ManaLeak.Cast")
	caster.AmaterasuCastLoc = caster:GetAbsOrigin()
	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	caster.CurrentAmaterasuDummy = dummy
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	dummy:AddNewModifier(caster, nil, "modifier_kill", {duration=keys.Duration+0.5})
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_amaterasu_aura", {})
	dummy.TempleDoors = CreateTempleDoorInCircle(caster, caster:GetAbsOrigin(), keys.Radius)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Dazzle.Shallow_Grave", caster)

	if caster.IsWitchcraftAcquired then 
		local targets = FindUnitsInRadius(caster:GetTeam(), caster.AmaterasuCastLoc, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		for k,v in pairs(targets) do
			if not IsImmuneToSlow(v) then ability:ApplyDataDrivenModifier(caster, v, "modifier_amaterasu_witchcraft_slow", {}) end
			v:AddNewModifier(caster, caster, "modifier_silence", {Duration = 1.5})
		end
	end

	-- Particle
	local circleFx = ParticleManager:CreateParticle('particles/units/heroes/hero_dazzle/dazzle_weave.vpcf', PATTACH_CUSTOMORIGIN, dummy) 
    ParticleManager:SetParticleControl(circleFx, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(circleFx, 1, Vector(keys.Radius,0,0))
	local counter = 0
    Timers:CreateTimer(function()
    	if counter > keys.Duration or caster.CurrentAmaterasuDummy:IsNull() or not IsValidEntity(caster.CurrentAmaterasuDummy) then 
			ParticleManager:DestroyParticle( caster.CurrentAmaterasuParticle, false )
			ParticleManager:ReleaseParticleIndex( caster.CurrentAmaterasuParticle )
			return
    	end
    	if not dummy:IsNull() and IsValidEntity(dummy) then
			local circleFx = ParticleManager:CreateParticle('particles/custom/tamamo/tamamo_amaterasu_continuous.vpcf', PATTACH_CUSTOMORIGIN, dummy) 
			caster.CurrentAmaterasuParticle = circleFx
		    ParticleManager:SetParticleControl(circleFx, 0, dummy:GetOrigin())
		    ParticleManager:SetParticleControl(circleFx, 1, Vector(keys.Radius,0,0))
	   	end
	    counter = counter+1
	    return 0.9
    end)

	EmitGlobalSound("Tamamo.Amaterasu")
end

function OnAmaterasuEnd(keys)
	local target = keys.target
	local caster = keys.caster
	target:RemoveSelf()
	for i=1, #target.TempleDoors do
		target.TempleDoors[i]:RemoveSelf()
	end
end

--[[
	Apply regen modifier to nearby allies and enemies
]]
function OnAmaterasuApplyAura(keys)
	local caster = keys.caster
	local ability = keys.ability

	local targets = FindUnitsInRadius(caster:GetTeam(), caster.AmaterasuCastLoc, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		ability:ApplyDataDrivenModifier(caster, v, "modifier_amaterasu_ally", {})
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), caster.AmaterasuCastLoc, nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
		-- Attribute Witchcraft logic
		ability:ApplyDataDrivenModifier(caster, v, "modifier_amaterasu_enemy", {})
		if caster.IsWitchcraftAcquired then 
			if not v.IsWitchcraftStunOnCooldown then
				if v:GetMana() < 5 then
					v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.5})
					v:EmitSound("Hero_KeeperOfTheLight.ManaLeak.Stun")
					v.IsWitchcraftStunOnCooldown = true
					Timers:CreateTimer(6.0, function()
						v.IsWitchcraftStunOnCooldown = false
					end)
				end
			end
		end
	end
end

function CreateTempleDoorInCircle(handle, center, multiplier)
	local bannerTable = {}
	for i=1, 8 do
		local x = math.cos(i*math.pi/4) * multiplier
		local y = math.sin(i*math.pi/4) * multiplier
		local banner = CreateUnitByName("tamamo_templedoor_dummy", Vector(center.x + x, center.y + y, 0), true, nil, nil, handle:GetTeamNumber())
		banner:AddNewModifier(caster, nil, "modifier_kill", {duration=10.5})
		local diff = (handle:GetAbsOrigin() - banner:GetAbsOrigin())
    	banner:SetForwardVector(diff:Normalized()) 
    	banner.Diff = diff
		table.insert(bannerTable, banner)
	end
	return bannerTable
end

function OnKickStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local lungeDelay = keys.LungeDelay
	local damage = keys.Damage
	local expDamageRatio = keys.ExplosionRatio
	local ability = keys.ability
	local nextTarget = caster
	local count = 0
	local targets = 0

	if ability:GetAbilityName() == "tamamo_polygamist_castration_fist" then
		-- Set master's combo cooldown
		local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
		masterCombo:EndCooldown()
		masterCombo:StartCooldown(keys.ability:GetCooldown(1))
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_polygamist_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	end

	if caster.IsEscapeAcquired then
		if IsRevoked(caster) then
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Be Used(Revoked)" } )
			keys.ability:EndCooldown()
			caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(1))
			return			
		end
		lungeDelay = lungeDelay / 2
		damage = damage / 2
		expDamageRatio = expDamageRatio / 2
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_polygamist_shorter", {}) 
	else 
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_polygamist", {}) 
		EmitGlobalSound("Tamamo.Kick")
			
	end

	Timers:CreateTimer(function()
		if count == 3 then 
			-- Do knockback
			nextTarget:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.7})
			local forward = caster:GetForwardVector()
			local backwards = forward * -1
			local dur = 0
			Timers:CreateTimer(function()
				-- If knockback is finished, do damage 
				if dur > 0.4 then 
					FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
					FindClearSpaceForUnit(nextTarget, nextTarget:GetAbsOrigin(), true)
					targets = FindUnitsInRadius(caster:GetTeam(), nextTarget:GetAbsOrigin(), nil, keys.SearchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
					for k,v in pairs(targets) do
						DoDamage(caster, v, expDamageRatio*caster:GetIntellect() ,DAMAGE_TYPE_MAGICAL, 0, ability, false  )
					end
					local explodeFx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf", PATTACH_ABSORIGIN, nextTarget )
					ParticleManager:SetParticleControl( explodeFx1, 0, nextTarget:GetAbsOrigin())
					local explodeFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_ABSORIGIN_FOLLOW, nextTarget )
					ParticleManager:SetParticleControl( explodeFx2, 0, nextTarget:GetAbsOrigin())
					nextTarget:EmitSound("Ability.LightStrikeArray")
					return 
				end 
				caster:SetAbsOrigin(caster:GetAbsOrigin() + backwards*33)
				nextTarget:SetAbsOrigin(nextTarget:GetAbsOrigin() + forward*33)
				dur = dur + 0.033
				return 0.033
			end)
			-- Do knockback 
			return 
		end
		targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.SearchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
		local trailFxIndex = ParticleManager:CreateParticle("particles/custom/tamamo/tamamo_kick_trail.vpcf", PATTACH_CUSTOMORIGIN, nextTarget )
		ParticleManager:SetParticleControl( trailFxIndex, 1, nextTarget:GetAbsOrigin() )
		if #targets ~= 0 then
			nextTarget = targets[math.random(#targets)]
			caster:SetAbsOrigin(nextTarget:GetAbsOrigin() + RandomVector(100))
			DoDamage(caster, nextTarget, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			nextTarget:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})


			ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
			nextTarget:EmitSound("Hero_Tusk.WalrusPunch.Target")
		end
		ParticleManager:SetParticleControl( trailFxIndex, 0, nextTarget:GetAbsOrigin() )
		local splashFx = ParticleManager:CreateParticle("particles/custom/screen_violet_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
		count = count+1
		return lungeDelay 
	end)
end

function OnSpiritTheftAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsSpiritTheftAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(caster:GetMana())
end

function OnSeveredFateAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsSeveredFateAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(caster:GetMana())
end

function OnPCFAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()

	if hero:GetStrength() < 19.5 or hero:GetAgility() < 19.5 or hero:GetIntellect() < 19.5 then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Must Acquire 20 Stats" } )
		keys.ability:EndCooldown()
		caster:SetMana(caster:GetMana()+keys.ability:GetManaCost(1))
		return
	end
	hero.IsEscapeAcquired = true
	hero:RemoveAbility("tamamo_polygamist_castration_fist")
	hero:AddAbility("tamamo_polygamist_castration_fist_2")
	hero:FindAbilityByName("tamamo_polygamist_castration_fist_2"):SetLevel(1)
	hero:FindAbilityByName("tamamo_polygamist_castration_fist_2").IsResetable = false
	Timers:CreateTimer(0.033, function()
		hero:SwapAbilities("fate_empty1", "tamamo_polygamist_castration_fist_2", true, true) 

	end)

    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(caster:GetMana())
end

function OnWitchcraftAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsWitchcraftAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(caster:GetMana())
end

function TamamoCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.5 and caster:GetAgility() >= 19.5 and caster:GetIntellect() >= 19.5 and not caster.IsEscapeAcquired then
		if ability == caster:FindAbilityByName("tamamo_subterranean_grasp") and caster:FindAbilityByName("tamamo_polygamist_castration_fist"):IsCooldownReady()  then
			caster:SwapAbilities("fate_empty1", "tamamo_polygamist_castration_fist", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				caster:SwapAbilities("fate_empty1", "tamamo_polygamist_castration_fist", true, false) 
			end
			})
		end
	end
end

--[[
function OnMantraTetherEnd(keys)
	local caster = keys.caster -- Caster
	local target = keys.target -- Target of tether
	caster:SwapAbilities("tamamo_mantra", "tamamo_fates_call", true,false) 
	caster.IsSeveredFateActive = false
end


function OnMantraTetherTick(keys)
	local caster = keys.caster
	local target = keys.target
	local dist = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	if dist > 1250 then
		target:RemoveModifierByName("modifier_mantra_tether")
	end
end

function OnFatesCallCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.IsInMarbleAtStart = false
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fates_call_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	if caster:GetAbsOrigin().y <  -2000 then
		caster.IsInMarbleAtStart = true
	end
end

function OnFatesCallStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local dist = (caster.TetheredTarget:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	local delay = dist*0.002
	caster.IsStunnedDuringFatesCall = false
	caster.IsInMarbleAtEnd = false


	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_POINT, caster.TetheredTarget )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster.TetheredTarget, PATTACH_POINT, "attach_origin", caster.TetheredTarget:GetAbsOrigin(), true )
	caster.TetheredTarget:EmitSound("Hero_Wisp.Relocate")

	-- Check if Caster got stunned 
	local count = 0
	Timers:CreateTimer(function()
		if count > delay then return end
		if caster:HasModifier("modifier_stunned") then
			caster.IsStunnedDuringFatesCall = true
			print("caster stunned during fate's call, canceling it...")
			return
		end
		count = count + 0.033
		return 0.033
	end)

	Timers:CreateTimer(delay, function()
		if caster:GetAbsOrigin().y <  -2000 then
			caster.IsInMarbleAtEnd = true
		end
		if caster.TetheredTarget:HasModifier("modifier_mantra_tether") and not caster.IsStunnedDuringFatesCall and 
			(caster.IsInMarbleAtStart == caster.IsInMarbleAtEnd) then

			caster.TetheredTarget:SetAbsOrigin(targetPoint)
			caster.TetheredTarget:RemoveModifierByName("modifier_mantra_tether")
			Timers:CreateTimer(0.033, function()
				local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_wisp/wisp_relocate_teleport.vpcf", PATTACH_POINT, caster.TetheredTarget )
				ParticleManager:SetParticleControlEnt( pfx, 0, caster.TetheredTarget, PATTACH_POINT, "attach_origin", caster.TetheredTarget:GetAbsOrigin(), true )
				caster.TetheredTarget:EmitSound("Hero_Wisp.Return")
			end)
		end
	end)
end]]