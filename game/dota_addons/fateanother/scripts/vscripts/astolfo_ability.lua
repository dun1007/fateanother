function OnCasaThink(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		if caster.bIsSanityAcquired then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_passive_mr_aura", {})
		else
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_passive_mr", {})
		end
	end
end

function OnCasaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		return 
	end 
	if caster.bIsSanityAcquired then
	    local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 350, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			ability:ApplyDataDrivenModifier(caster, v, "modifier_casa_active_mr", {})
			v:EmitSound("Hero_Oracle.FortunesEnd.Target")
	    end
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_active_mr", {})
		caster:EmitSound("Hero_Oracle.FortunesEnd.Target")
	end
end

function OnVanishStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		return 
	end 
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local info = {
		Target = target, -- chainTarget
		Source = caster, -- chainSource
		Ability = ability,
		EffectName = "particles/custom/astolfo/astolfo_hippogriff_vanish.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1800
	}
	ProjectileManager:CreateTrackingProjectile(info) 

	caster:EmitSound("Hero_Mirana.Leap.MoonGriffon")
end

function OnVanishHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = keys.Damage
	ApplyPurge(target)
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_hippogriff_vanish_banish", {})
end

function OnVanishDebuffStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetName() == "npc_dota_hero_queenofpain" then
		local prop = Attachments:GetCurrentAttachment(target, "attach_sword")
		prop:RemoveSelf()
	end
	target:AddEffects(EF_NODRAW)
	--target:SetModel("models/development/invisiblebox.vmdl")
	--target:SetOriginalModel("models/development/invisiblebox.vmdl")
	target:EmitSound("Hero_Oracle.PurifyingFlames.Damage")
end

function OnVanishDebuffEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:RemoveEffects(EF_NODRAW)
	--target:SetModel(target.OriginalModel)
	--target:SetOriginalModel(target.OriginalModel)
	if caster.bIsRidingAcquired then 
		giveUnitDataDrivenModifier(caster, target, "stunned", 0.5)
	end

	if target:GetName() == "npc_dota_hero_queenofpain" then
		Attachments:AttachProp(target, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
	end
end

function OnDownStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local damage = keys.Damage
	local range = keys.Range
	local attackCount = keys.AttackCount
	local counter = 1
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		return 
	end 
	range = 350
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)
	giveUnitDataDrivenModifier(caster, caster, "zero_attack_damage", 0.5)
	giveUnitDataDrivenModifier(caster, caster, "modifier_astolfo_disable_mstrength", 0.5)

	Timers:CreateTimer(function()
		if counter > 4 then return end
		local forwardVec = RotatePosition(Vector(0,0,0), QAngle(0,RandomFloat(12, -12),0), caster:GetForwardVector())
		local spearProjectile = 
		{
			Ability = ability,
	        EffectName = "particles/custom/astolfo/astolfo_down_with_a_touch_projectile.vpcf",
	        iMoveSpeed = range * 5,
	        vSpawnOrigin = caster:GetOrigin(),
	        fDistance = range - 100,
	        fStartRadius = 200,
	        fEndRadius = 200,
	        Source = caster,
	        bHasFrontalCone = true,
	        bReplaceExisting = true,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
	        fExpireTime = GameRules:GetGameTime() + 2.0,
			bDeleteOnHit = false,
			vVelocity = forwardVec * range * 5
		}
		local projectile = ProjectileManager:CreateLinearProjectile(spearProjectile)
		if caster:HasModifier("modifier_astolfo_monstrous_strength") and caster.bIsSanityAcquired then
			DoDamage(caster, caster, 4*caster:GetHealth()/100 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
		StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK, rate=4.0})
		caster:EmitSound("Hero_Sniper.AssassinateDamage")
		counter = counter + 1
		return 0.12
	end)

end

function OnDownHit(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	local ability = keys.ability
	local lockDuration = keys.LockDuration
	DoDamage(caster, target, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	giveUnitDataDrivenModifier(caster, target, "locked", lockDuration)
	if not IsImmuneToSlow(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow", {})
	end

	if caster.bIsSanityAcquired then
		caster:PerformAttack(target, true, true, true, true, false)
	end
end

function OnDownSlowTier1End(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not IsImmuneToSlow(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow_2", {})
	end
end

function OnDownSlowTier2End(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not IsImmuneToSlow(target) then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow_3", {})
	end
end

function OnHornCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		caster:Stop()
		return 
	end 
	caster:EmitSound("Ability.Powershot.Alt")
end

function OnHornStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		caster:Stop()
		return 
	end 
	AstolfoCheckCombo(caster, ability)
	caster.currentHornManaCost = ability:GetManaCost(ability:GetLevel())
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_black_luna", {})

	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_3_END, rate=1.0})
	Attachments:AttachProp(caster, "attach_horn", "models/astolfo/astolfo_horn.vmdl")
	--caster:EmitSound("Hero_LegionCommander.PressTheAttack")
    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() == caster:GetTeamNumber() then
        	-- apply legion horn vsnd on their client
        	CustomGameEventManager:Send_ServerToPlayer(player, "emit_horn_sound", {sound="Astolfo.Horn"})
        	--caster:EmitSound("Hero_LegionCommander.PressTheAttack")
        else
        	-- apply legion horn + silencer vsnd on their client
        	CustomGameEventManager:Send_ServerToPlayer(player, "emit_horn_sound", {sound="Hero_Silencer.GlobalSilence.Effect"})
        end
    end)

    local shockwaveIndex = ParticleManager:CreateParticle("particles/custom/astolfo/la_black_luna/la_black_luna_shockwave.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl( shockwaveIndex, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl( shockwaveIndex, 1, Vector(500,0,0))
    ParticleManager:SetParticleControl( shockwaveIndex, 2, Vector(radius,0,0))
end

function OnHornThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local slowRadius = keys.Radius
	if caster.bIsSanityAcquired then slowRadius = 20000 end
	local damageRadius = keys.DamageRadius
	local silenceRadius = keys.SilenceRadius
	local damage = keys.Damage

	caster.currentHornManaCost = caster.currentHornManaCost + ability:GetManaCost(ability:GetLevel())
	if caster.currentHornManaCost > caster:GetMana() then 
		caster:Stop() -- stop channeling
	else
		caster:SetMana(caster:GetMana() - caster.currentHornManaCost)
	end

    local deafTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for k,v in pairs(deafTargets) do
		ability:ApplyDataDrivenModifier(caster, v, "modifier_la_black_luna_deaf", {})
		if v:GetPlayerOwner() then
			--EmitSoundOnClient("Hero_Silencer.GlobalSilence.Effect", v:GetPlayerOwner())
		end
    end

    local slowTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, slowRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(slowTargets) do
		if not IsImmuneToSlow(v) then
			ability:ApplyDataDrivenModifier(caster, v, "modifier_la_black_luna_slow", {})
		end
    end

    local damageTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, damageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(damageTargets) do
		-- apply damage
		DoDamage(caster, v, v:GetHealth() * damage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end

    local silenceTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, silenceRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(silenceTargets) do
		-- apply silence
		giveUnitDataDrivenModifier(caster, v, "silenced", 0.53)
    end

end

function OnHornInterrupted(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	CustomGameEventManager:Send_ServerToAllClients("stop_horn_sound", {})
	caster:RemoveModifierByName("modifier_la_black_luna")
	local prop = Attachments:GetCurrentAttachment(caster, "attach_horn")
	if not prop:IsNull() then prop:RemoveSelf() end
	-- loop through players
		-- stop sound on client
end

function CreateGroundMark(caster, team, location, duration)
	local counter = 0
	Timers:CreateTimer(function()
		if counter >= duration then return end

		counter = counter + 0.25
		return 0.25
	end)

end

function OnRaidCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then 
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		caster:Stop()
		return 
	end 
	caster:EmitSound("Astolfo.Hippogriff_Raid_Cast")
end

function CreateBeaconForEnemies(caster, targetPoint)
    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and player and playerHero then
        	AddFOWViewer(playerHero:GetTeamNumber(), targetPoint, 150, 2.5, false)
        	local beaconIndex = ParticleManager:CreateParticleForPlayer("particles/custom/astolfo/astolfo_ground_mark_flex.vpcf", PATTACH_CUSTOMORIGIN, nil, player)
			ParticleManager:SetParticleControl( beaconIndex, 0, targetPoint)
        	-- set a timer to check whether affected enemies retain buff
        	Timers:CreateTimer(function()
        		if playerHero:HasModifier("modifier_la_black_luna_deaf") then
        			ParticleManager:SetParticleControl( beaconIndex, 0, Vector(20000,20000,1000))
        		else
        			ParticleManager:SetParticleControl( beaconIndex, 0, targetPoint)
        		end
        		return 0.1
        	end)
        end
    end)
end
function OnRaidStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local firstDmgPct = keys.FirstDamagePct
	if caster.bIsRidingAcquired then firstDmgPct = firstDmgPct + 10 end
	local radius = keys.Radius
	local stunDuration = keys.StunDuration
	local secondDmg = keys.SecondDamage
	if caster:HasModifier("modifier_hippogriff_ride_ascended") or not IsInSameRealm(caster:GetAbsOrigin(), targetPoint) then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot be cast" } )
		caster:GiveMana(caster:GetMana()+ability:GetManaCost(1))
		ability:EndCooldown() 
		return
	end

	if caster.nCurrentRaidAmount then
		if caster.nCurrentRaidAmount >= 2 then
			FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Be Cast Now" } )
			caster:GiveMana(caster:GetMana()+ability:GetManaCost(1))
			ability:EndCooldown() 
			return
		else
			caster.nCurrentRaidAmount = caster.nCurrentRaidAmount+1
		end
	else
		caster.nCurrentRaidAmount = 1
	end

	caster:EmitSound("Astolfo.Hippogriff_Raid_Cast_Success")
	caster:EmitSound("Hero_Phoenix.IcarusDive.Cast")

	local ascendFx = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_ascend.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( ascendFx, 0, caster:GetAbsOrigin())
	-- create beacon for team
	local teamBeacon = ParticleManager:CreateParticleForTeam("particles/custom/astolfo/astolfo_ground_mark_flex.vpcf", PATTACH_CUSTOMORIGIN, nil, caster:GetTeam())
	ParticleManager:SetParticleControl( teamBeacon, 0, targetPoint)

	AddFOWViewer(caster:GetTeamNumber(), targetPoint, radius, 6, false)
	Timers:CreateTimer(2.0, function()
		CreateBeaconForEnemies(caster, targetPoint)
		EmitGlobalSound("Astolfo.Hippogriff_Raid_Shout")
		Timers:CreateTimer(3.0, function()
			EmitGlobalSound("Astolfo.Leap")

			local birdOrigin = caster:GetAbsOrigin() + Vector(0,0,2000) + (caster:GetAbsOrigin() - targetPoint):Normalized()*1000
			local dist = (targetPoint  - birdOrigin):Length2D()
			local birdVector = (targetPoint  - birdOrigin):Normalized() * dist * 3
			local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/astolfo/astolfo_hippogriff_raid_flyer.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( swordFxIndex, 0, birdOrigin)
			ParticleManager:SetParticleControl( swordFxIndex, 1,  birdVector)
		end)

		Timers:CreateTimer(2.0, function()
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius
		            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
		        DoDamage(caster, v, v:GetMaxHealth() * firstDmgPct/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		        giveUnitDataDrivenModifier(caster, v, "stunned", stunDuration)
		    end

			EmitGlobalSound("Astolfo.SolarForge")
			local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_first_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
		    ParticleManager:SetParticleControl(firstImpactIndex, 0, Vector(1,0,0))
		    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(radius-50,0,0))
		    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(1.5,0,0))
		    ParticleManager:SetParticleControl(firstImpactIndex, 3, targetPoint)
		    ParticleManager:SetParticleControl(firstImpactIndex, 4, Vector(0,0,0))

			Timers:CreateTimer(1.5, function()
				if caster.bIsRidingAcquired then radius = radius + 100 end
				local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius
			            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				for k,v in pairs(targets) do
			        DoDamage(caster, v, secondDmg, DAMAGE_TYPE_MAGICAL, 0, ability, false)
			    end

			    if caster.nCurrentRaidAmount >= 1 then
					caster.nCurrentRaidAmount = caster.nCurrentRaidAmount-1
				end

				EmitSoundOnLocationWithCaster(targetPoint, "Misc.Crash", caster)
				local secondImpactIndex = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_second_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(secondImpactIndex, 0, targetPoint)
			    ParticleManager:SetParticleControl(secondImpactIndex, 1, Vector(radius,1,1))
			end)

		end)
	end)
	--[[ 
	2 seconds timer
		create beacon at location
	4 seconds timer
		for enemies in radius at target location
			do damage
			apply stun

	5.5 seconds timer
		for enemies in radius at target loc
			do damage
	--]]
end

function OnRaidCountReset(keys)
	local caster = keys.caster
	caster.nCurrentRaidAmount = 0
	
end
function OnRideStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ascendDelay = keys.Delay
	local radius = keys.Radius
	local duration = keys.Duration
	if caster:HasModifier("modifier_hippogriff_ride_ascended") then return end 
	EmitGlobalSound("Astolfo.Hippogriff_Ride_Cast")
	EmitGlobalSound("Astolfo.SolarForge")
	-- pause for ascend delay
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", ascendDelay)
	StartAnimation(caster, {duration=1.0, activity=ACT_DOTA_CAST_ABILITY_3, rate=0.5})
	local ascendIndex = ParticleManager:CreateParticle("particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_skills/kunkka_spell_torrent_bubbles_swirl_fxset.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ascendIndex, 0, caster:GetAbsOrigin())

	Timers:CreateTimer(ascendDelay, function()
		if caster:IsAlive() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_hippogriff_ride_ascended", {})
			giveUnitDataDrivenModifier(caster, caster, "zero_attack_damage", 10.0)
			for i=2, 13 do
				if caster:GetTeamNumber() ~= i then
					AddFOWViewer(i, caster:GetAbsOrigin(), 500, 10, false)
				end
			end

			local aoeFx = ParticleManager:CreateParticle("particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_ride_aoe_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControl( aoeFx, 1, Vector(radius,0,0))
			local beaconIndex = ParticleManager:CreateParticle("particles/custom/astolfo/astolfo_ground_mark_flex_10sec.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl( beaconIndex, 0, caster:GetAbsOrigin())
		end
	end)
	-- swap ability layout
end

function OnRideAscend(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = keys.Duration
	giveUnitDataDrivenModifier(caster, caster, "jump_pause_nosilence", duration)
	caster:AddEffects(EF_NODRAW)
	caster:SwapAbilities("fate_empty1", "astolfo_hippogriff_rush", true, true)
	local ascendFx = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_raid/astolfo_hippogriff_raid_ascend.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( ascendFx, 0, caster:GetAbsOrigin())
	--local aoeIndicatorFx = ParticleManager:CreateParticle( "particles/custom/astolfo/hippogriff_ride/astolfo_hippogriff_ride_aoe_indicator.vpcf", PATTACH_CUSTOMORIGIN, nil )
    --ParticleManager:SetParticleControl(aoeIndicatorFx, 0, caster:GetAbsOrigin())
    --print("ascended")
	
end

function OnRideAscendEnd(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveEffects(EF_NODRAW)
	caster:SwapAbilities("fate_empty1", "astolfo_hippogriff_rush", true, false)
end

function OnMStrengthHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	DoDamage(caster, target, 4*caster:GetMaxHealth()/100 , DAMAGE_TYPE_PURE, 0, ability, false)
	if not caster:HasModifier("modifier_astolfo_disable_mstrength") then
		DoDamage(caster, caster, 4*caster:GetHealth()/100 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
	end
end

function OnDownAttackHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	giveUnitDataDrivenModifier(caster, target, "rooted", 0.4)
end

function OnIAThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local bIsVisibleToEnemy = false
	LoopOverPlayers(function(player, playerID, playerHero)
		-- if enemy hero can see astolfo, set visibility to true
		if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
			if playerHero:CanEntityBeSeenByMyTeam(caster) then
				bIsVisibleToEnemy = true
				return
			end
		end
	end)
	if IsRevoked(caster) or not bIsVisibleToEnemy then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_astolfo_indepedent_action_conditional_regen", {})
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_astolfo_indepedent_action_regen", {})
	end


end

function AstolfoCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("astolfo_la_black_luna") then
			caster:SwapAbilities("fate_empty1", "astolfo_hippogriff_ride", false, true)
			Timers:CreateTimer({
				endTime = 2,
				callback = function()
				caster:SwapAbilities("fate_empty1", "astolfo_hippogriff_ride", true, false)
			end
			})
		end
	end
end

function OnRidingAcquired(keys)
    local caster = keys.caster
    local hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
    hero.bIsRidingAcquired = true
    -- Set master 1's mana
    local master = hero.MasterUnit
    local master2 = hero.MasterUnit2
    master:SetMana(master2:GetMana())
end

function OnMStrengthAcquired(keys)
    local caster = keys.caster
    local hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
    hero.bIsMStrengthAcquired = true
    -- Set master 1's mana
    local master = hero.MasterUnit
    local master2 = hero.MasterUnit2
    master:SetMana(master2:GetMana())

    hero:SetBaseStrength(hero:GetBaseStrength()+10) 
    hero:AddAbility("astolfo_monstrous_strength")
    hero:FindAbilityByName("astolfo_monstrous_strength"):SetLevel(1)
end

function OnIActionAcquired(keys)
    local caster = keys.caster
    local hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
    hero.bIsIAAcquired = true
    -- Set master 1's mana
    local master = hero.MasterUnit
    local master2 = hero.MasterUnit2
    master:SetMana(master2:GetMana())

    hero:AddAbility("astolfo_independent_action")
    hero:FindAbilityByName("astolfo_independent_action"):SetLevel(1)
end

function OnSanityAcquired(keys)
    local caster = keys.caster
    local hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerOwnerID())
    hero.bIsSanityAcquired = true
    -- Set master 1's mana
    local master = hero.MasterUnit
    local master2 = hero.MasterUnit2
    master:SetMana(master2:GetMana())

    hero:AddAbility("astolfo_down_with_a_touch_passive")
    hero:FindAbilityByName("astolfo_down_with_a_touch_passive"):SetLevel(1)

end
