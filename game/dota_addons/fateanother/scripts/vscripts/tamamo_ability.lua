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
	local a1 = caster:GetAbilityByIndex(0) -- Soulstream
	local a2 = caster:GetAbilityByIndex(1) -- Subterranean Grasp
	local a3 = caster:GetAbilityByIndex(2) -- Mantra
	local a4 = caster:GetAbilityByIndex(3) -- Armed Up
	local a5 = caster:GetAbilityByIndex(4) -- fate_empty1
	local a6 = caster:GetAbilityByIndex(5) -- Amaterasu

	caster:SwapAbilities("tamamo_fiery_heaven", a1:GetName(), true, true) 
	caster:SwapAbilities("tamamo_frigid_heaven", a2:GetName(), true, true) 
	caster:SwapAbilities("tamamo_gust_heaven", a3:GetName(), true, true) 
	caster:SwapAbilities("fate_empty2", a4:GetName(), true, true) 
	caster:SwapAbilities("tamamo_close_spellbook", a5:GetName(), true,true) 
	caster:SwapAbilities("fate_empty3", a6:GetName(), true, true) 
end

function OnFireCharmLoaded(keys)
	local caster = keys.caster
	CharmHandle = keys.ability
	CurrentCharmName = "modifier_fiery_heaven_indicator"
	CloseCharmList(keys)

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
	local a1 = caster:GetAbilityByIndex(0) -- Fiery Heaven
	local a2 = caster:GetAbilityByIndex(1) -- Frigid Heaven
	local a3 = caster:GetAbilityByIndex(2) -- Gust Heaven
	local a4 = caster:GetAbilityByIndex(3) -- fate_empty2
	local a5 = caster:GetAbilityByIndex(4) -- close spellbook
	local a6 = caster:GetAbilityByIndex(5) -- fate_empty3/Void Cleft

	caster:SwapAbilities("tamamo_soulstream", a1:GetName(), true, true) 
	caster:SwapAbilities("tamamo_subterranean_grasp", a2:GetName(), true, true) 
	caster:SwapAbilities("tamamo_mantra", a3:GetName(), true, true) 
	caster:SwapAbilities("tamamo_armed_up", a4:GetName(), true, true) 
	caster:SwapAbilities("fate_empty1", a5:GetName(), true,true) 
	caster:SwapAbilities("tamamo_amaterasu", a6:GetName(), true, true) 

end

--[[function OnSoulStreamInitialize(keys)
	local caster = keys.caster
	caster.CharmTable1 = {}
	caster.CharmTable2 = {}
	Timers:CreateTimer(2.0, function()
		for i=1, 5 do
			local soldier = CreateUnitByName("tamamo_charm", Vector(-10000,-10000,0), true, nil, nil, caster:GetTeamNumber())
			soldier:SetAbsOrigin(Vector(-10000,-10000,0))
			table.insert(caster.CharmTable1, soldier)
			caster.Charms = soldier
		end
		for i=1, 5 do
			local soldier = CreateUnitByName("tamamo_charm", Vector(-10000,-10000,0), true, nil, nil, caster:GetTeamNumber())
			soldier:SetAbsOrigin(Vector(-10000,-10000,0))
			table.insert(caster.CharmTable2, soldier)
			caster.Charms = soldier
		end
	end)
end]]

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
		local projectile = CreateUnitByName("tamamo_charm", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())

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

	damage = damage + damage*caster.CurrentSoulstreamStack*keys.StackBonus/100

	local radius, charmDamage, stackDamage, ccDuration, StackStunDuration, mrReduction = 0
	-- Is Charm loaded for current projectile?
	if target.IsCharmLoaded then
		if target.LoadedCharm == "modifier_fiery_heaven_indicator" then
			radius = target.LoadedCharmHandle:GetLevelSpecialValueFor("radius", 0)
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
	local targets = FindUnitsInRadius(caster:GetTeam(), casterLoc, nil, 75+radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	if #targets ~= 0 then


		for k,v in pairs(targets) do
			if target.LoadedCharm == "modifier_fiery_heaven_indicator" then
				-- 6 stacks
				if IncrementCharmStack(target, v, target.LoadedCharmHandle, "modifier_fiery_heaven_indicator_enemy") == 6 then
					v:RemoveModifierByName("modifier_fiery_heaven_indicator_enemy")
					DoDamage(caster, v, (v:GetMaxHealth()-v:GetHealth())*stackDamage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
					v:EmitSound("Ability.LightStrikeArray")
				else
					DoDamage(caster, v, v:GetHealth()*charmDamage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end
			elseif target.LoadedCharm == "modifier_frigid_heaven_indicator" then
				-- 6 stacks
				if IncrementCharmStack(target, v, target.LoadedCharmHandle, "modifier_frigid_heaven_indicator_enemy") == 6 then
					v:RemoveModifierByName("modifier_frigid_heaven_indicator_enemy")
					v:AddNewModifier(caster, v, "modifier_stunned", {Duration = StackStunDuration})
					v:EmitSound("Ability.FrostBlast")
				else
					v:AddNewModifier(caster, v, "modifier_disarmed", {Duration = ccDuration})
					v:AddNewModifier(caster, v, "modifier_silence", {Duration = ccDuration})
				end
			elseif target.LoadedCharm == "modifier_gust_heaven_indicator" then
				-- 6 stacks
				if IncrementCharmStack(target, v, target.LoadedCharmHandle, "modifier_gust_heaven_indicator_enemy") == 6 then
					v:RemoveModifierByName("modifier_gust_heaven_indicator_enemy")
					target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_gust_heaven_purge", {}) 
					target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_gust_heaven_purge_slow_tier1", {}) 
					target.LoadedCharmHandle:ApplyDataDrivenModifier(caster, v, "modifier_gust_heaven_purge_slow_tier2", {}) 
					v:EmitSound("DOTA_Item.DiffusalBlade.Activate")

				else
				end 
			end	
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
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
	caster.MantraTarget = target
	target.IsMantraProcOnCooldown = false 

	if target:GetTeamNumber() == caster:GetTeamNumber() then
		modifierName = "modifier_mantra_ally"
	else
		if IsSpellBlocked(keys.target) then return end
		modifierName = "modifier_mantra_enemy"
	end

	local castFx = ParticleManager:CreateParticle('particles/units/heroes/hero_oracle/oracle_purifyingflames_halo.vpcf', PATTACH_CUSTOMORIGIN, target) 
    ParticleManager:SetParticleControl(castFx, 0, target:GetOrigin())
    target:EmitSound("Item.LotusOrb.Target")

	-- Set stack amount
	ability:ApplyDataDrivenModifier(caster, target, modifierName, {}) 
	target:SetModifierStackCount(modifierName, ability, orbAmount)
	for i=1, orbAmount do ability:ApplyDataDrivenModifier(caster, target, "modifier_mantra_vfx", {}) end
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
		if currentHealth + (orbDamage - keys.DamageTaken) <= 0 then
			print("lethal")
		else
			target:SetHealth(currentHealth + keys.DamageTaken)
		end
	else
		if target.IsMantraProcOnCooldown then 
			return
		else
			target.IsMantraProcOnCooldown = true
			DoDamage(attacker, target, orbDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
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
	caster.AmaterasuCastLoc = caster:GetAbsOrigin()
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_amaterasu_aura", {})

	-- Particle
	EmitGlobalSound("Tamamo.Amaterasu")
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
	end
end

function OnKickStart(keys)
end

function OnSpiritTheftAcquired(keys)
end

function OnSeveredFateAcquired(keys)
end

function OnPCFAcquired(keys)
end

function OnWitchcraftAcquired(keys)
end