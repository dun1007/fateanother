require("physics")
require("util")

bolgdummy = nil

function LancerOnTakeDamage(keys)
	local caster = keys.caster
	local currentHealth = caster:GetHealth()
	local ply = caster:GetPlayerOwner()

	local lowend = 300
	local highend = 1000
	local cd = 60
	local health = 1
	if caster.IsBCImproved == true then
		lowend = 200
		highend = 1200
		cd = 30
		health = 500
	end
	if currentHealth == 0 and keys.ability:IsCooldownReady() and keys.DamageTaken <= highend and keys.DamageTaken >= lowend  then
		caster:SetHealth(health)
		keys.ability:StartCooldown(cd) 
		local reviveFx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(reviveFx, 3, caster:GetAbsOrigin())

		Timers:CreateTimer( 3.0, function()
			ParticleManager:DestroyParticle( reviveFx, false )
		end)
	end
end

function RuneMagicOpen(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)
	caster:SwapAbilities("lancer_5th_rune_of_disengage", a1:GetName(), true, true) 
	caster:SwapAbilities("lancer_5th_rune_of_replenishment", a2:GetName(), true, true) 
	caster:SwapAbilities("lancer_5th_rune_of_trap", a3:GetName(), true, true) 
	caster:SwapAbilities("lancer_5th_rune_of_flame", a4:GetName(), true, true) 
	caster:SwapAbilities("lancer_5th_close_spellbook", a5:GetName(), true, true) 
	caster:SwapAbilities("lancer_5th_rune_of_conversion", a6:GetName(), true, true) 
end

function RuneLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("lancer_5th_rune_of_disengage"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("lancer_5th_rune_of_replenishment"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("lancer_5th_rune_of_trap"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("lancer_5th_rune_of_flame"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("lancer_5th_rune_of_conversion"):SetLevel(keys.ability:GetLevel())
end

function RuneMagicUsed(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)
	a1:StartCooldown(20)
	a2:StartCooldown(20)
	a3:StartCooldown(20)
	a4:StartCooldown(20)
	a6:StartCooldown(20)
	caster:SwapAbilities(a1:GetName(), "lancer_5th_rune_magic", true, true) 
	caster:SwapAbilities(a2:GetName(), "lancer_5th_relentless_spear", true, true) 
	caster:SwapAbilities(a3:GetName(), "lancer_5th_gae_bolg", true, true) 
	caster:SwapAbilities(a4:GetName(), "lancer_5th_battle_continuation", true, true) 
	caster:SwapAbilities(a5:GetName(), "rubick_empty1", true, true) 
	caster:SwapAbilities(a6:GetName(), "lancer_5th_gae_bolg_jump", true, true) 
	caster:GetAbilityByIndex(0):StartCooldown(20) 
end

function RuneMagicClose(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0)
	local a2 = caster:GetAbilityByIndex(1)
	local a3 = caster:GetAbilityByIndex(2)
	local a4 = caster:GetAbilityByIndex(3)
	local a5 = caster:GetAbilityByIndex(4)
	local a6 = caster:GetAbilityByIndex(5)
	caster:SwapAbilities(a1:GetName(), "lancer_5th_rune_magic", true, true) 
	caster:SwapAbilities(a2:GetName(), "lancer_5th_relentless_spear", true, true) 
	caster:SwapAbilities(a3:GetName(), "lancer_5th_gae_bolg", true, true) 
	caster:SwapAbilities(a4:GetName(), "lancer_5th_battle_continuation", true, true) 
	caster:SwapAbilities(a5:GetName(), "rubick_empty1", true, true) 
	caster:SwapAbilities(a6:GetName(), "lancer_5th_gae_bolg_jump", true, true) 
	caster:GetAbilityByIndex(0):EndCooldown() 

end

function Disengage(keys)
	local caster = keys.caster
	local backward = caster:GetForwardVector() * keys.Distance
	local newLoc = caster:GetAbsOrigin() - backward
	local diff = newLoc - caster:GetAbsOrigin()

	HardCleanse(caster)
	local i = 1
	while GridNav:IsBlocked(newLoc) or not GridNav:IsTraversable(newLoc) or i == 100 do
		i = i+1
		newLoc = caster:GetAbsOrigin() + diff:Normalized() * (keys.Distance - i*10)
	end
	Timers:CreateTimer(0.033, function() 
		caster:SetAbsOrigin(newLoc)
		ProjectileManager:ProjectileDodge(caster) 
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end)
end

function Trap(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local stunDuration = keys.StunDuration
	local trapDuration = 0
	local radius = keys.Radius

	local lancertrap = CreateUnitByName("lancer_trap", targetPoint, true, caster, caster, caster:GetTeamNumber())
	Timers:CreateTimer(1.0, function()
		LevelAllAbility(lancertrap)
		return
	end)


	local targets = nil
	
    Timers:CreateTimer(function()
    	if not lancertrap:IsAlive() then return end
        targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) -- find enemies in radius

        -- if enemy is found, spring the trap
        for k,v in pairs(targets) do
        	if v ~= nil then
				SpringTrap(lancertrap, caster, stunDuration, targetPoint, radius) -- activate trap
				return
			end
		end

        trapDuration = trapDuration + 1;
        if trapDuration == 450 then
        	trapDuration =0 
        	lancertrap:ForceKill(true)
        	return 
        end
      	return 0.1
    end
    )
end

function SpringTrap(trap, caster, stunduration, targetpoint, radius)
	trap:RemoveAbility("lancer_trap_passive") 
	Timers:CreateTimer({
		endTime = 1,
		callback = function()
		if trap:IsAlive() then
			trap:EmitSound("Hero_Techies.StasisTrap.Stun")
			local targets = FindUnitsInRadius(caster:GetTeam(), targetpoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				v:AddNewModifier(caster, v, "modifier_stunned", {Duration = stunduration})
			end
			trap:ForceKill(true) 
		end
	end
	})
end

function Conversion(keys)
	local caster = keys.caster
	local currentHealth = caster:GetHealth()
	local currentMana = caster:GetMana()
	local healthLost = currentHealth * keys.Percentage / 100
	local finalHealth = currentHealth - healthLost

	if finalHealth > 1 then 
		caster:SetHealth(currentHealth - healthLost) 
	else
		caster:SetHealth(1)
	end
	caster:SetMana(currentMana + healthLost)
end

function OnIncinerateHit(keys)
	local caster = keys.caster
	local target = keys.target


	local currentStack = target:GetModifierStackCount("modifier_lancer_incinerate", keys.ability)

	if currentStack == 0 and target:HasModifier("modifier_lancer_incinerate") then currentStack = 1 end
	target:RemoveModifierByName("modifier_lancer_incinerate") 
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_lancer_incinerate", {}) 
	target:SetModifierStackCount("modifier_lancer_incinerate", keys.ability, currentStack + 1)

	DoDamage(caster, target, keys.ExtraDamage*currentStack, DAMAGE_TYPE_PURE, 0, keys.ability, false)
end

function OnRAStart(keys)
	 LancerCheckCombo(keys.caster, keys.ability)
end

function GBAttachEffect(keys)
	local caster = keys.caster
	local GBCastFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(GBCastFx, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(GBCastFx, 2, caster:GetAbsOrigin()) -- circle effect location
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( GBCastFx, false )
	end)

	if keys.ability == caster:FindAbilityByName("lancer_5th_gae_bolg") then
		caster:EmitSound("Lancer.GaeBolg")
	elseif keys.ability == caster:FindAbilityByName("lancelot_gae_bolg") then 
		caster:EmitSound("Lancelot.Growl" )
	end

end


function OnGBTargetHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if caster.IsGaeBolgImproved == true then keys.HBThreshold = keys.HBThreshold + caster:GetAttackDamage()*3 end


	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
	if target:GetHealth() < keys.HBThreshold then 
		if target:GetHealth() ~= 0 then 
			PlayHeartBreakEffect(target)
		end 
		target:Kill(keys.ability, caster)
	end  -- check for HB

	-- if Gae Bolg is improved, do 3 second dot over time
	if caster.IsGaeBolgImproved == true then 
		local dotCount = 0
		Timers:CreateTimer(function() 
			if dotCount == 3 then return end
			DoDamage(caster, target, target:GetHealth()/30, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			dotCount = dotCount + 1
			return 1.0 
		end)
	end

	--[[
	-- if Heart Seeker attribute is acquired, check for HB condition every 0.3 seconds
	if caster.IsHeartSeekerAcquired == true then
		local dotCount = 0
		Timers:CreateTimer(function() 
			if dotCount == 10 then return end
			if target:GetHealth() < keys.HBThreshold then 
				if target:GetHealth() ~= 0 then 
					PlayHeartBreakEffect(target)

				end 
				target:Kill(keys.ability, caster) 
			end 
			dotCount = dotCount + 1
			return 0.3
		end)
	end]]
	

	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	target:EmitSound("Hero_Lion.Impale")
	PlayNormalGBEffect(target)
	-- Blood splat
	local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, target)

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( dagon_particle, false )
		ParticleManager:DestroyParticle( splat, false )
	end)
end

function PlayHeartBreakEffect(target)
	local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)

	local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break_txt.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())

	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( culling_kill_particle, false )
		ParticleManager:DestroyParticle( hb, false )
	end)
end

function PlayNormalGBEffect(target)
	local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)
	
	Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( culling_kill_particle, false )
	end)
end 

function OnGBComboHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local HBThreshold = target:GetMaxHealth() * keys.HBThreshold / 100
	
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	if caster.IsHeartSeekerAcquired == true then HBThreshold = HBThreshold + caster:GetAttackDamage()*1.5 + target:GetStrength() end

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 3.0)
	EmitGlobalSound("Lancer.Heartbreak")
	caster:FindAbilityByName("lancer_5th_gae_bolg"):StartCooldown(27.0)
	if target:IsAlive() then
	  	Timers:CreateTimer(1.8, function() 
		    local lancer = Physics:Unit(caster)
		    caster:PreventDI()
		    caster:SetPhysicsFriction(0)
		    caster:SetPhysicsVelocity((keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized() * 3000)
		    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		    caster:FollowNavMesh(false)	
		    caster:SetAutoUnstuck(false)
		    keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_wesen_gae_bolg_pierce_anim", {})
		    caster:OnPhysicsFrame(function(unit)
				local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
				local dir = diff:Normalized()
				unit:SetPhysicsVelocity(dir * 3000)
				if diff:Length() < 100 then
				  	caster:RemoveModifierByName("pause_sealdisabled")
					unit:PreventDI(false)
					unit:SetPhysicsVelocity(Vector(0,0,0))
					unit:OnPhysicsFrame(nil)
					unit:SetAutoUnstuck(true)
			        FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)

			        if caster:IsAlive() then 
			        	local RedScreenFx = ParticleManager:CreateParticle("particles/custom/screen_red_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
			        	Timers:CreateTimer( 3.0, function()
							ParticleManager:DestroyParticle( RedScreenFx, false )
						end)
			        	target:EmitSound("Hero_Lion.Impale")
				    	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
						target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})

						if target:GetHealth() < HBThreshold then 
							if target:GetHealth() ~= 0 then 
								PlayHeartBreakEffect(target)
							end 
							target:Kill(keys.ability, caster)
						else
							PlayNormalGBEffect(target)
						end
					end
				end
			end)
			return
		end)
	end
end

function OnGBAOEStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local ply = caster:GetPlayerOwner()
	local ascendCount = 0
	local descendCount = 0
	print(keys.ability.IsResetable)

	bolgdummy = CreateUnitByName("dummy_unit", targetPoint, false, caster, caster, caster:GetTeamNumber())
	local dummy_ability = bolgdummy:FindAbilityByName("dummy_unit_passive")
	bolgdummy:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	dummy_ability:SetLevel(1)
	Timers:CreateTimer(1.5, function() GaeBolgDummyEnd(bolgdummy) return end)

	local info = {
		Target = bolgdummy,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/custom/lancer/lancer_gae_bolg_projectile.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,300),
		iMoveSpeed = 2000
	}
	
	EmitGlobalSound("Lancer.GaeBolg")
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.6)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gae_jump_throw_anim", {})

  	Timers:CreateTimer('gb_throw', {
		endTime = 0.3,
		callback = function()
	   	ProjectileManager:CreateTrackingProjectile(info) 
	end
	})

	Timers:CreateTimer('gb_ascend', {
		endTime = 0,
		callback = function()
	   	if ascendCount == 10 then return end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+50))
		ascendCount = ascendCount + 1;
		return 0.033
	end
	})

	Timers:CreateTimer("gb_descend", {
	    endTime = 0.3,
	    callback = function()
	    	if descendCount == 10 then return end
			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-50))
			descendCount = descendCount + 1;
	      	return 0.033
	    end
	})
end

function OnGBAOEHit(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local ply = caster:GetPlayerOwner()
	if caster.IsGaeBolgImproved == true then keys.Damage = keys.Damage + 250 end

	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
    end

	local crack = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cracks.vpcf", PATTACH_ABSORIGIN_FOLLOW, bolgdummy)
	local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_breakout_fallback_mid.vpcf", PATTACH_ABSORIGIN_FOLLOW, bolgdummy)
	local explodeFx1 = ParticleManager:CreateParticle("particles/custom/lancer/lancer_gae_bolg_hit.vpcf", PATTACH_ABSORIGIN, bolgdummy )
	ParticleManager:SetParticleControl( explodeFx1, 0, bolgdummy:GetAbsOrigin())	
	ScreenShake(caster:GetOrigin(), 7, 1.0, 2, 2000, 0, true)
	caster:EmitSound("Misc.Crash")

    Timers:CreateTimer( 3.0, function()
		ParticleManager:DestroyParticle( crack, false )
		ParticleManager:DestroyParticle( fire, false )
		ParticleManager:DestroyParticle( explodeFx1, false )
	end)
end

function GaeBolgDummyEnd(dummy)
	dummy:RemoveSelf()
	return nil
end

function LancerCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("lancer_5th_relentless_spear") and caster:FindAbilityByName("lancer_5th_gae_bolg"):IsCooldownReady() and caster:FindAbilityByName("lancer_5th_wesen_gae_bolg"):IsCooldownReady()  then
			caster:SwapAbilities("lancer_5th_gae_bolg", "lancer_5th_wesen_gae_bolg", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				if caster:GetAbilityByIndex(2):GetName() == "lancer_5th_wesen_gae_bolg" then 
					caster:SwapAbilities("lancer_5th_gae_bolg", "lancer_5th_wesen_gae_bolg", true, true) 
				end
			end
			})
		end
	end
end

function OnImrpoveBCAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsBCImproved = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImrpoveGaeBolgAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsGaeBolgImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPFAAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("lancer_5th_protection_from_arrows"):SetLevel(1) 
	hero.IsPFAAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnHeartseekerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsHeartSeekerAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end