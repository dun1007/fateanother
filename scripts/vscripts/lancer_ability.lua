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
	if ply.IsBCImproved == true then
		lowend = 200
		highend = 1200
		cd = 30
		health = 500
	end
	if currentHealth == 0 and keys.ability:IsCooldownReady() and keys.DamageTaken <= highend and keys.DamageTaken >= lowend  then
		caster:SetHealth(health)
		keys.ability:StartCooldown(cd) 
		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
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
	caster:SetAbsOrigin(caster:GetAbsOrigin() - backward)
	ProjectileManager:ProjectileDodge(caster) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
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

	caster:SetHealth(currentHealth - healthLost) 
	caster:SetMana(currentMana + healthLost)
end

function IncinerateOnHit(keys)
	local caster = keys.caster
	local target = keys.target

	if target:HasModifier("modifier_lancer_incinerate") then
		local stacks = target:GetModifierStackCount("modifier_lancer_incinerate", nil)
		target:SetModifierStackCount("modifier_lancer_incinerate", nil, stacks+1)
	else
		caster:FindAbilityByName("lancer_5th_rune_of_flame"):ApplyDataDrivenModifier(caster, target, "modifier_lancer_incinerate", {})
	end
end

function OnRAStart(keys)
	 LancerCheckCombo(keys.caster, keys.ability)
end

function GBAttachEffect(keys)
	local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) -- circle effect location
	if keys.ability == caster:FindAbilityByName("lancer_5th_gae_bolg") then
		caster:EmitSound("Lancer.GaeBolg")
	end
end


function OnGBTargetHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if ply.IsGaeBolgImproved == true then keys.HBThreshold = keys.HBThreshold + 150 end

	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	if target:GetHealth() < keys.HBThreshold then 
		target:Kill(keys.ability, caster)
		local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
		ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
	end  -- check for HB

	-- if Gae Bolg is improved, do 3 second dot over time
	if ply.IsGaeBolgImproved == true then 
		local dotCount = 0
		Timers:CreateTimer(function() 
			if dotCount == 3 then return end
			DoDamage(caster, target, target:GetHealth()/30, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			dotCount = dotCount + 1
			return 1.0 
		end)
	end

	-- if Heart Seeker attribute is acquired, check for HB condition every 0.3 seconds
	if ply.IsHeartSeekerAcquired == true then
		local dotCount = 0
		Timers:CreateTimer(function() 
			if dotCount == 10 then return end
			if target:GetHealth() < keys.HBThreshold then 
				target:Kill(keys.ability, caster) 
				local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
				ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
			end 
			return 0.3
		end)
	end
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
	-- attach blood effect
	local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(blood, 1, target , 0, "attach_hitloc", target:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(blood, 4, target:GetAbsOrigin())

	local splat = ParticleManager:CreateParticle("particles/generic_gameplay/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, caster)

end

function OnGBComboHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local HBThreshold = target:GetMaxHealth() * keys.HBThreshold / 100
	print(HBThreshold)
	if ply.IsHeartSeekerAcquired == true then HBThreshold = HBThreshold + 150 + target:GetStrength() end
	
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 3.0)
	EmitGlobalSound("Lancer.Heartbreak")
	caster:FindAbilityByName("lancer_5th_gae_bolg"):StartCooldown(27.0)
  	Timers:CreateTimer(1.5, function() 
	    local lancer = Physics:Unit(caster)
	    caster:PreventDI()
	    caster:SetPhysicsFriction(0)
	    caster:SetPhysicsVelocity((keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Normalized() * 3000)
	    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	    caster:FollowNavMesh(false)	
	    caster:SetAutoUnstuck(false)

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
		        	ParticleManager:CreateParticle("particles/custom/screen_red_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
			    	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
					target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
					print(target:GetHealth())
					if target:GetHealth() < HBThreshold then 
						target:Kill(keys.ability, caster)
						local hb = ParticleManager:CreateParticle("particles/custom/lancer/lancer_heart_break.vpcf", PATTACH_OVERHEAD_FOLLOW, target) 
						ParticleManager:SetParticleControl( hb, 0, target:GetAbsOrigin())
					end
					-- attach blood effect
					local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(blood, 1, target , 0, "attach_hitloc", target:GetAbsOrigin(), false)
					ParticleManager:SetParticleControl(blood, 4, target:GetAbsOrigin())
				end
			end
		end)
		return
	end)

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
		EffectName = "particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 2000
	}
	
	EmitGlobalSound("Lancer.GaeBolg")
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.6)

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
	if ply.IsGaeBolgImproved == true then keys.Damage = keys.Damage + 250 end

	local crack = ParticleManager:CreateParticle("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cracks.vpcf", PATTACH_ABSORIGIN_FOLLOW, bolgdummy)
	local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_rainofchaos_start_breakout_fallback_mid.vpcf", PATTACH_ABSORIGIN_FOLLOW, bolgdummy)

	caster:EmitSound("Misc.Crash")
	local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
    end
end

function GaeBolgDummyEnd(dummy)
	dummy:RemoveSelf()
	return nil
end

function LancerCheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("lancer_5th_relentless_spear") then
		caster:SwapAbilities("lancer_5th_gae_bolg", "lancer_5th_wesen_gae_bolg", true, true) 
	end
	Timers:CreateTimer({
		endTime = 3,
		callback = function()
		caster:SwapAbilities("lancer_5th_gae_bolg", "lancer_5th_wesen_gae_bolg", true, true) 
	end
	})
end

function OnImrpoveBCAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsBCImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImrpoveGaeBolgAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsGaeBolgImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPFAAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("lancer_5th_protection_from_arrows"):SetLevel(1) 
	ply.IsPFAAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnHeartseekerAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsHeartSeekerAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end