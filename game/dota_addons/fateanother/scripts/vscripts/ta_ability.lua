require("Physics")
require("util")

function OnDirkStart(keys)
	local caster = keys.caster
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 700
	}

	local targetCount = 0
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 700
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		targetCount = targetCount + 1
        info.Target = v
        ProjectileManager:CreateTrackingProjectile(info) 
        if targetCount == 7 then return end
    end
end

function OnDirkHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	if not IsImmuneToSlow(keys.target) then 
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_dirk_poison", {}) 
	end
	if keys.ability:GetName() == "true_assassin_dirk" then
		DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	else
		DoDamage(keys.caster, keys.target, keys.Damage + keys.caster:GetAgility() , DAMAGE_TYPE_PURE, 0, keys.ability, false)
	end
end

function OnVenomHit(keys)
	local caster = keys.caster
	local target = keys.target 

	if IsImmuneToSlow(target) then return end

	local currentStack = target:GetModifierStackCount("modifier_weakening_venom_debuff", keys.ability)

	if currentStack == 0 and target:HasModifier("modifier_weakening_venom_debuff") then currentStack = 1 end
	target:RemoveModifierByName("modifier_weakening_venom_debuff") 
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_weakening_venom_debuff", {}) 
	target:SetModifierStackCount("modifier_weakening_venom_debuff", keys.ability, currentStack + 1)
end


function OnPCStart(keys)
end

function OnPCAbilityUsed(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.LastActionTime = GameRules:GetGameTime() 

	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(1.5, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + 1.5 then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not ply.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function OnPCAttacked(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	caster.LastActionTime = GameRules:GetGameTime() 

	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(1.5, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + 1.5 then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not ply.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function OnPCMoved(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsPCImproved then return end
	caster.LastActionTime = GameRules:GetGameTime() 



	caster:RemoveModifierByName("modifier_ta_invis")
	Timers:CreateTimer(1.5, function() 
		if GameRules:GetGameTime() >= caster.LastActionTime + 1.5 then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_invis", {}) 
			if not ply.IsPCImproved then PCStopOrder(keys) return end
		end
	end)
end

function PCStopOrder(keys)
	--keys.caster:Stop() 
	local stopOrder = {
		UnitIndex = keys.caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
end


function OnDIStart(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerID()
	local ability = keys.ability
	local DICount = 0
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	
	Timers:CreateTimer(function()
		if DICount > 8.0 then return end 
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 650
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if v.IsDIOnCooldown ~= true then 
				print("Target " .. v:GetName() .. " detected")
				for ilu = 0, 2 do
					v.IsDIOnCooldown = true

					local origin = v:GetAbsOrigin() + RandomVector(650) 
					local illusion = CreateUnitByName("ta_combo_dummy", origin, false, caster, caster, caster:GetTeamNumber()) 
					local illusionzab = illusion:FindAbilityByName("true_assassin_combo_zab") 
					illusionzab:SetLevel(1)
					illusion:CastAbilityOnTarget(v, illusionzab, 1)

					Timers:CreateTimer(3.0, function() 
						illusion:RemoveSelf()
						v.IsDIOnCooldown = false 
					return end)
				end
			end
		end
		DICount = DICount + 0.33
		return 0.33
	end)
end



function OnDIZabStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability

	local info = {
		Target = target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_nevermore/nevermore_base_attack.vpcf",
		vSpawnOrigin = caster,
		iMoveSpeed = 700
	}
	ProjectileManager:CreateTrackingProjectile(info) 
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin()) -- circle effect location
	EmitGlobalSound("TA.Zabaniya") 
	caster:EmitSound("Hero_Nightstalker.Darkness") 
end

function OnDIZabHit(keys)
	print("Projectile hit")
	local caster = keys.caster
	local ply = keys.caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local damage = hero:FindAbilityByName("true_assassin_ambush"):GetLevel() * 60 + 100
	if ply.IsShadowStrikeAcquired then 
		damage = damage + 100
	end
	DoDamage(hero, keys.target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	keys.ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_ta_bleed", {})
end

function DIBleed(keys)
	local caster = keys.caster
	local ply = keys.caster:GetPlayerOwner()
	local hero = ply:GetAssignedHero()
	local damage = hero:FindAbilityByName("true_assassin_ambush"):GetLevel() * 10 + 10
	local bleedCounter = 0

	Timers:CreateTimer(function() 
		if bleedCounter == 5 then return end
		DoDamage(hero, keys.target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		bleedCounter = bleedCounter + 1
		return 1.0
	end)	
end

function OnAmbushStart(keys)
	local caster = keys.caster
	--caster:AddNewModifier(caster, caster, "modifier_invisible", {Duration = 12.0})
	TACheckCombo(caster, keys.ability)
end

function OnAmbushBroken(keys)
	keys.caster:RemoveModifierByName("modifier_ambush")
end

function OnFirstHitStart(keys)
	keys.caster:RemoveModifierByName("modifier_ambush")
end

function OnFirstHitLanded(keys)
	if IsSpellBlocked(keys.target) then keys.caster:RemoveModifierByName("modifier_first_hit") return end -- Linken effect checker
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	keys.caster:EmitSound("Hero_TemplarAssassin.Meld.Attack")
	keys.caster:RemoveModifierByName("modifier_first_hit")
end

function OnAbilityCast(keys)
	Timers:CreateTimer({
		endTime = 0.033,
		callback = function()
		keys.caster:RemoveModifierByName("modifier_ambush")
	end
	})
	keys.caster:RemoveModifierByName("modifier_first_hit")
end

function OnModStart(keys)
	local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_ground_rubble.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	TACheckCombo(caster, keys.ability) 
	--increase stat
end

function SelfModUpgraded(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ta_agi_bonus") 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_agi_bonus", {}) 
	caster:SetModifierStackCount("modifier_ta_agi_bonus", caster, caster:GetKills())
end

function SelfModKilled(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_ta_agi_bonus") 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_agi_bonus", {}) 
	caster:SetModifierStackCount("modifier_ta_agi_bonus", caster, caster:GetKills())
	--[[for i=1, caster:GetKills() do
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_ta_agi_bonus", {}) 
	end]]
end


function OnStealStart(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ply = caster:GetPlayerOwner() 
	local target = keys.target

	if caster:HasModifier("modifier_ambush") and ply.IsShadowStrikeAcquired then
		print("Shadow Strike activated")
		keys.Damage = keys.Damage + 300
	end

	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnZabStart(keys)
	local caster = keys.caster
	local info = {
		Target = keys.target,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_nevermore/nevermore_base_attack.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 700
	}
	if caster:HasModifier("modifier_ambush") then caster.IsShadowStrikeActivated = true print("Shadow Strike activated") end

	ProjectileManager:CreateTrackingProjectile(info) 
	Timers:CreateTimer({
		endTime = 0.033,
		callback = function()
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 1, keys.target:GetAbsOrigin()) -- target effect location
		ParticleManager:SetParticleControl(particle, 2, keys.target:GetAbsOrigin()) -- circle effect location
		EmitGlobalSound("TA.Zabaniya") 
		caster:EmitSound("Hero_Nightstalker.Darkness") 
	end
	})
end

function OnZabHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local target = keys.target
	local stunduration = keys.StunDuration

	local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(blood, 4, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(blood, 1, target , 0, "attach_hitloc", target:GetAbsOrigin(), false)

	if ply.IsShadowStrikeAcquired and caster.IsShadowStrikeActivated then 
		keys.Damage = keys.Damage + 400 
		caster.IsShadowStrikeActivated = false
	end
	DoDamage(keys.caster, keys.target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	caster:Heal(keys.Damage/2, caster)
end

AmbushUsed = false

function TACheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("true_assassin_self_modification") then
			AmbushUsed = true
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				AmbushUsed = false
			end
			})
		elseif ability == caster:FindAbilityByName("true_assassin_ambush") and caster:FindAbilityByName("true_assassin_combo"):IsCooldownReady()  then
			if AmbushUsed == true then 
				caster:SwapAbilities("true_assassin_ambush", "true_assassin_combo", true, true)
				Timers:CreateTimer({
					endTime = 8,
					callback = function()
					caster:SwapAbilities("true_assassin_ambush", "true_assassin_combo", true, true)
				end
				})
			end
		end
	end
end

--requires presence detect mechanism
function OnImprovePresenceConcealmentAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsPCImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnProtectionFromWindAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsPFWAcquired = true
	hero:FindAbilityByName("true_assassin_protection_from_wind"):SetLevel(1) 

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnWeakeningVenomAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsWeakeningVenomAcquired = true
	hero:FindAbilityByName("true_assassin_weakening_venom_passive"):SetLevel(1)
	hero:SwapAbilities("true_assassin_dirk_improved", "true_assassin_dirk", true, false) 

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnShadowStrikeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsShadowStrikeAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end