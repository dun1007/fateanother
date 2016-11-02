chainTargetsTable = nil
ubwTargets = nil
ubwTargetLoc = nil
ubwCasterPos = nil
ubwCenter = Vector(5600, -4398, 200)
aotkCenter = Vector(500, -4800, 208)
ATTR_PROJECTION_PASSIVE_WEAPON_DAMAGE = 50

function FarSightVision(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local radius = keys.ability:GetLevelSpecialValueFor( "radius", keys.ability:GetLevel() - 1 )
	local targetLoc = keys.target_points[1]

	local visiondummy = SpawnVisionDummy(caster, targetLoc, radius, keys.Duration, false)
	
	if caster.IsEagleEyeAcquired then 
		SpawnVisionDummy(caster, targetLoc, radius, keys.Duration, true)
	end

	if caster.IsHruntingAcquired then
		caster:SwapAbilities("archer_5th_clairvoyance", "archer_5th_hrunting", true, true) 
		Timers:CreateTimer(8, function() caster:SwapAbilities("archer_5th_clairvoyance", "archer_5th_hrunting", true, false) return end)
	end
	
	--EmitGlobalSound("Hero_KeeperOfTheLight.BlindingLight")
	--EmitSoundOnLocationWithCaster(targetLoc, "Hero_KeeperOfTheLight.BlindingLight", visiondummy)
	
	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( 8, 0, 0 ) )
	ParticleManager:SetParticleControl( circleFxIndex, 3, Vector( 100, 255, 255 ) )
	
	local dustFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_dust.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( dustFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
	
	visiondummy.circle_fx = circleFxIndex
	visiondummy.dust_fx = dustFxIndex
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
			
	-- Destroy particle after delay
	Timers:CreateTimer( keys.Duration, function()
			ParticleManager:DestroyParticle( circleFxIndex, false )
			ParticleManager:DestroyParticle( dustFxIndex, false )
			ParticleManager:ReleaseParticleIndex( circleFxIndex )
			ParticleManager:ReleaseParticleIndex( dustFxIndex )
			return nil
		end
	)

    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and player and playerHero then
        	AddFOWViewer(playerHero:GetTeamNumber(), targetLoc, 50, 0.5, false)
        	
        end
    end)
	-- Particles
	--visiondummy:EmitSound("Hero_KeeperOfTheLight.BlindingLight") 
	Timers:CreateTimer(0.033, function()
		EmitSoundOnLocationWithCaster(targetLoc, "Hero_KeeperOfTheLight.BlindingLight", visiondummy)
	end)
		
end

function FarSightEnd(dummy)
	dummy:RemoveSelf()
	return nil
end

function KBStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()

	local info = {
		Target = target, -- chainTarget
		Source = caster, -- chainSource
		Ability = ability,
		EffectName = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1000
	}
	ProjectileManager:CreateTrackingProjectile(info) 
	
	--[[if caster.IsOveredgeAcquired then
		GrantOveredgeStack(caster)
	end

	if caster:HasModifier("modifier_ubw_death_checker") then
		--print("UBW up")
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(3.0)
		caster:GiveMana(ability:GetManaCost(1))
	end	

	if caster.IsProjectionImproved and caster:HasModifier("modifier_ubw_death_checker") then
		local barrage = caster:FindAbilityByName("archer_5th_sword_barrage")
		local barrageCD = barrage:GetCooldownTimeRemaining()
		if barrageCD > 1 then
			barrage:EndCooldown()
			barrage:StartCooldown(barrageCD-1)
		else
			barrage:EndCooldown()
		end
	end]]
end

function KBHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local KBCount = 0

	if caster.IsProjectionImproved then keys.DamagePerTick = keys.DamagePerTick + caster:GetIntellect() end

	Timers:CreateTimer(function() 
		if KBCount == 4 then return end
		DoDamage(keys.caster, keys.target, keys.DamagePerTick , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)

		local KBHitFx = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(KBHitFx, 0, target:GetAbsOrigin()) 
		-- Destroy particle after delay
		Timers:CreateTimer( 2, function()
			ParticleManager:DestroyParticle( KBHitFx, false )
			ParticleManager:ReleaseParticleIndex( KBHitFx )
		end)

		caster:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
		KBCount = KBCount + 1
		return 0.25
	end)
end

function OnBPCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	ability:EndCooldown()
	caster:GiveMana(ability:GetManaCost(1))

	caster.BPparticle = ParticleManager:CreateParticleForTeam("particles/custom/archer/archer_broken_phantasm/archer_broken_phantasm_crosshead.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

	ParticleManager:SetParticleControl( caster.BPparticle, 0, target:GetAbsOrigin() + Vector(0,0,100)) 
	ParticleManager:SetParticleControl( caster.BPparticle, 1, target:GetAbsOrigin() + Vector(0,0,100)) 
	if keys.target:IsHero() then
		Say(ply, "Broken Phantasm targets " .. FindName(keys.target:GetName()) .. ".", true)
	end
end

function OnBPStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle(caster.BPparticle, true)
	if not caster:CanEntityBeSeenByMyTeam(target) or caster:GetRangeToUnit(target) > 3000 or caster:GetMana() < ability:GetManaCost(1) or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then 
		Say(ply, "Broken Phantasm failed.", true)
		return 
	end
	ability:StartCooldown(ability:GetCooldown(1))
	caster:SetMana(caster:GetMana() - ability:GetManaCost(1))
	local info = {
		Target = keys.target,
		Source = keys.caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 3000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDodgeable = true
	}
	ProjectileManager:CreateTrackingProjectile(info) 
	-- give vision for enemy
	if IsValidEntity(target) then
		SpawnVisionDummy(target, caster:GetAbsOrigin(), 500, 3, false)
	end
	
	if keys.target:IsHero() then
		Say(ply, "Broken Phantasm fired at " .. FindName(keys.target:GetName()) .. ".", true)
	end
end

function OnBPInterrupted(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle(caster.BPparticle, true)
	Say(ply, "Broken Phantasm failed.", true)
end

function OnBPHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	keys.target:EmitSound("Misc.Crash")
	DoDamage(caster, target, keys.TargetDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, keys.SplashDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
    end


    local BpHitFx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(BpHitFx, 3, target:GetAbsOrigin())
	--ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()) -- target location
	Timers:CreateTimer( 2, function()
		ParticleManager:DestroyParticle( BpHitFx, false )
		ParticleManager:ReleaseParticleIndex( BpHitFx )
	end)

	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
	end
end

rhoTarget = nil

function OnRhoStart(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	if caster.IsProjectionImproved then 
		local knockBackUnits = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false )
	 
		local modifierKnockback =
		{
			center_x = target:GetAbsOrigin().x,
			center_y = target:GetAbsOrigin().y,
			center_z = target:GetAbsOrigin().z,
			duration = 0.5,
			knockback_duration = 0.5,
			knockback_distance = 200,
			knockback_height = 200,
		}

		for _,unit in pairs(knockBackUnits) do
	--		print( "knock back unit: " .. unit:GetName() )
			unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback );
		end
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_rho_aias_shield", {})
	rhoTarget = target 
	target.rhoShieldAmount = keys.ShieldAmount


	caster:EmitSound("Archer.RhoAias" ) 
	caster:EmitSound("Hero_EmberSpirit.FlameGuard.Cast")

	
	-- Attach particle for shield facing the forward vector
	local rhoShieldParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_rhoaias_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	-- Update the control point as long as modifer is up
	Timers:CreateTimer( function()
			-- Origin
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 0, target:GetAbsOrigin() )
			
			local origin = target:GetAbsOrigin()
			local forwardVec = target:GetForwardVector()
			local rightVec = target:GetRightVector()
			
			-- Hard coded value, these values have to be adjusted manually for core and end point of each petal
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 1, Vector( origin.x + 150 * forwardVec.x, origin.y + 150 * forwardVec.y, origin.z + 225 ) ) -- petal_core, center of petals
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 2, Vector( origin.x - 30 * forwardVec.x, origin.y - 30 * forwardVec.y, origin.z + 375 ) ) -- petal_a
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 3, Vector( origin.x + 150 * forwardVec.x, origin.y + 150 * forwardVec.y, origin.z ) ) -- petal_d
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 4, Vector( origin.x + 150 * rightVec.x, origin.y + 150 * rightVec.y, origin.z + 300 ) ) -- petal_b
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 5, Vector( origin.x - 150 * rightVec.x, origin.y - 150 * rightVec.y, origin.z + 300 ) ) -- petal_c
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 6, Vector( origin.x + 150 * rightVec.x + 60 * forwardVec.x, origin.y + 150 * rightVec.y + 60 * forwardVec.y, origin.z + 25 ) ) -- petal_e
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 7, Vector( origin.x - 150 * rightVec.x + 60 * forwardVec.x, origin.y - 150 * rightVec.y + 60 * forwardVec.y, origin.z + 25 ) ) -- petal_f
			
			-- Check if it should be destroyed
			if target:HasModifier( "modifier_rho_aias_shield" ) then
				return 0.1
			else
				ParticleManager:DestroyParticle( rhoShieldParticleIndex, false )
				ParticleManager:ReleaseParticleIndex( rhoShieldParticleIndex )
				return nil
			end
		end
	)
end

function OnRhoDamaged(keys)
	local currentHealth = rhoTarget:GetHealth() 

	-- Create particles
	local onHitParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit_sphere.vpcf", PATTACH_CUSTOMORIGIN, keys.unit )
	ParticleManager:SetParticleControl( onHitParticleIndex, 2, keys.unit:GetAbsOrigin() )
	
	Timers:CreateTimer( 0.5, function()
			ParticleManager:DestroyParticle( onHitParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( onHitParticleIndex )
		end
	)

	rhoTarget.rhoShieldAmount = rhoTarget.rhoShieldAmount - keys.DamageTaken
	if rhoTarget.rhoShieldAmount <= 0 then
		if currentHealth + rhoTarget.rhoShieldAmount <= 0 then
			--print("lethal")
		else
			--print("rho broken, but not lethal")
			rhoTarget:RemoveModifierByName("modifier_rho_aias_shield")
			rhoTarget:SetHealth(currentHealth + keys.DamageTaken + rhoTarget.rhoShieldAmount)
			rhoTarget.rhoShieldAmount = 0
		end
	else
		--print("rho not broken, remaining shield : " .. rhoTarget.rhoShieldAmount)
		rhoTarget:SetHealth(currentHealth + keys.DamageTaken)
	end
end

function OnUBWLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("archer_5th_sword_barrage_retreat_shot"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("archer_5th_sword_barrage"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("archer_5th_sword_barrage_confine"):SetLevel(keys.ability:GetLevel())
	caster:FindAbilityByName("archer_5th_nine_lives"):SetLevel(keys.ability:GetLevel())
end

-- Starts casting UBW
function OnUBWCastStart(keys)
	local caster = keys.caster
	local casterLocation = caster:GetAbsOrigin()
	local castDelay = 2
	if caster:GetAbsOrigin().y < -3500 then
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Already_In_Marble")
		caster:SetMana(caster:GetMana() + 800)
		keys.ability:EndCooldown()
		return
	end 
	EmitGlobalSound("Archer.UBW")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", castDelay)
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_ubw_freeze",{})
	Timers:CreateTimer({
		endTime = castDelay,
		callback = function()
		if keys.caster:IsAlive() then 
		    caster.UBWLocator = CreateUnitByName("ping_sign2", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		    caster.UBWLocator:FindAbilityByName("ping_sign_passive"):SetLevel(1)
		    caster.UBWLocator:AddNewModifier(caster, caster, "modifier_kill", {duration = 12.5})
		    caster.UBWLocator:SetAbsOrigin(caster:GetAbsOrigin())
			OnUBWStart(keys)

			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_ubw_death_checker",{})
			if caster.IsMartinAcquired then
				keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_shroud_of_martin_str_bonus", {})
			end

			local entranceFlashParticle = ParticleManager:CreateParticle("particles/custom/archer/ubw/entrance_flash.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(entranceFlashParticle, 0, casterLocation)
			ParticleManager:CreateParticle("particles/custom/archer/ubw/exit_flash.vpcf", PATTACH_ABSORIGIN, caster)
		end
	end
	})
	ArcherCheckCombo(keys.caster, keys.ability)

	-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, keys.Radius, true, 2.5)

	for i=2, 3 do
		local dummy = CreateUnitByName("dummy_unit", casterLocation, false, caster, caster, i)
		dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		dummy:SetAbsOrigin(ubwCenter)
		AddFOWViewer(i, ubwCenter, 1800, 3, false)

		local particle = ParticleManager:CreateParticleForTeam("particles/custom/archer/ubw/firering.vpcf", PATTACH_ABSORIGIN, dummy, i)
		ParticleManager:SetParticleControl(particle, 6, casterLocation)
		local particleRadius = 0
		Timers:CreateTimer(0, function()
			if particleRadius < keys.Radius then
				particleRadius = particleRadius + keys.Radius * 0.03 / 2
				ParticleManager:SetParticleControl(particle, 1, Vector(particleRadius,0,0))
				return 0.03
			end
		end)
	end
end

--ubwQuest = nil
ubwdummies = nil
-- Begins UBW 
function OnUBWStart(keys)
	print("started UBW")
	CreateUITimer("Unlimited Blade Works", 12, "ubw_timer")
	--ubwQuest = StartQuestTimer("ubwTimerQuest", "Unlimited Blade Works", 12)
	local caster = keys.caster
	local ability = keys.ability
	local info = {
		Target = nil,
		Source = nil, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = ubwCenter + Vector(RandomFloat(-800,800),RandomFloat(-800,800), 500),
		iMoveSpeed = 1000
	}

	local ubwdummyLoc1 = ubwCenter + Vector(600,-600, 1000)
	local ubwdummyLoc2 = ubwCenter + Vector(600,600, 1000)
	local ubwdummyLoc3 = ubwCenter + Vector(-600,600, 1000)
	local ubwdummyLoc4 = ubwCenter + Vector(-600,-600, 1000)

    -- swap Archer's skillset with UBW ones
    caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "archer_5th_sword_barrage", true, true) 
    caster:SwapAbilities("archer_5th_kanshou_bakuya", "archer_5th_sword_barrage_retreat_shot", true, true) 
    caster:SwapAbilities("archer_5th_broken_phantasm", "archer_5th_sword_barrage_confine", true, true) 
    caster:SwapAbilities("archer_5th_ubw", "archer_5th_nine_lives", true, true) 
    -- Find eligible UBW targets
	ubwTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	caster.IsUBWDominant = true
	
	-- Remove any dummy or hero in jump
	i = 1
	while i <= #ubwTargets do
		if IsValidEntity(ubwTargets[i]) and not ubwTargets[i]:IsNull() then
			ProjectileManager:ProjectileDodge(ubwTargets[i]) -- Disjoint particles
			if ubwTargets[i]:HasModifier("jump_pause") or string.match(ubwTargets[i]:GetUnitName(),"dummy") or ubwTargets[i]:HasModifier("spawn_invulnerable") and ubwTargets[i] ~= caster then 
				table.remove(ubwTargets, i)
				i = i - 1
			end
		end
		i = i + 1
	end

	if caster:GetAbsOrigin().x < 3000 and caster:GetAbsOrigin().y < -2000 then
		ubwdummyLoc1 = aotkCenter + Vector(600,-600, 1000)
		ubwdummyLoc2 = aotkCenter + Vector(600,600, 1000)
		ubwdummyLoc3 = aotkCenter + Vector(-600,600, 1000)
		ubwdummyLoc4 = aotkCenter + Vector(-600,-600, 1000)
		caster.IsUBWDominant = false
	end
	caster.IsUBWActive = true
	--[[-- If Iskander's AOTK is active, place the dummy and center of UBW accordingly
	for i=1, #ubwTargets do
		if IsValidEntity(ubwTargets[i]) and not ubwTargets[i]:IsNull() then 
			if ubwTargets[i]:GetName() == "npc_dota_hero_chen" and ubwTargets[i]:HasModifier("modifier_army_of_the_king_death_checker") then
				ubwdummyLoc1 = aotkCenter + Vector(600,-600, 1000)
				ubwdummyLoc2 = aotkCenter + Vector(600,600, 1000)
				ubwdummyLoc3 = aotkCenter + Vector(-600,600, 1000)
				ubwdummyLoc4 = aotkCenter + Vector(-600,-600, 1000)
				caster.IsUBWDominant = false
				break
			end
		end
	end]]

    -- DUN DUN DUN DUN
    local dunCounter = 0
	Timers:CreateTimer(function() 
		if dunCounter == 5 then return end 
		if caster:IsAlive() then EmitGlobalSound("Archer.UBWAmbient") else return end 
		dunCounter = dunCounter + 1
		return 3.0 
	end)
	-- Add sword shooting dummies
	local ubwdummy1 = CreateUnitByName("dummy_unit", ubwdummyLoc1, false, caster, caster, caster:GetTeamNumber())
	local ubwdummy2 = CreateUnitByName("dummy_unit", ubwdummyLoc2, false, caster, caster, caster:GetTeamNumber())
	local ubwdummy3 = CreateUnitByName("dummy_unit", ubwdummyLoc3, false, caster, caster, caster:GetTeamNumber())
	local ubwdummy4 = CreateUnitByName("dummy_unit", ubwdummyLoc4, false, caster, caster, caster:GetTeamNumber())
	ubwdummies = {ubwdummy1, ubwdummy2, ubwdummy3, ubwdummy4}
	Timers:CreateTimer(function()
		ubwdummy1:SetAbsOrigin(ubwdummyLoc1)
		ubwdummy2:SetAbsOrigin(ubwdummyLoc2)
		ubwdummy3:SetAbsOrigin(ubwdummyLoc3)
		ubwdummy4:SetAbsOrigin(ubwdummyLoc4)
	end)
	
	for i=1, #ubwdummies do
		ubwdummies[i]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		ubwdummies[i]:SetDayTimeVisionRange(1000)
		ubwdummies[i]:SetNightTimeVisionRange(1000)
		ubwdummies[i]:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 1000})
	end
	-- spawn sight dummy for enemies
	--[[local enemyTeamNumber = 0
	if caster:GetTeamNumber() == 0 then enemyTeamNumber = 1 end
	local truesightdummy2 = CreateUnitByName("sight_dummy_unit", ubwdummyLoc1, false, keys.caster, keys.caster, enemyTeamNumber)
	truesightdummy2:AddNewModifier(caster, caster, "modifier_kill", {duration = 12}) 
	truesightdummy2:SetDayTimeVisionRange(2500)
	truesightdummy2:SetNightTimeVisionRange(2500)
	local unseen2 = truesightdummy2:FindAbilityByName("dummy_unit_passive")
	unseen2:SetLevel(1)]]

	-- Automated weapon shots
	if caster.IsProjection2Improved then
		Timers:CreateTimer(function() 
			if caster:IsAlive() and caster:HasModifier("modifier_ubw_death_checker") then
				local weaponTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2000
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				local targetIndex = RandomInt(1, #weaponTargets)
				local swordTarget = weaponTargets[targetIndex]
				local swordOrigin = caster:GetAbsOrigin() + Vector(0,0,500) + RandomVector(1000)
				local swordVector = (weaponTargets[targetIndex]:GetAbsOrigin() - swordOrigin):Normalized()

				local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( swordFxIndex, 0, swordOrigin )
				ParticleManager:SetParticleControl( swordFxIndex, 1, swordVector * 5000 )
				Timers:CreateTimer(0.1, function()
					if swordTarget:IsAlive() then
						DoDamage(caster, swordTarget, ATTR_PROJECTION_PASSIVE_WEAPON_DAMAGE+caster:GetIntellect()*0.3 , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
					end
					ParticleManager:DestroyParticle( swordFxIndex, false )
					ParticleManager:ReleaseParticleIndex( swordFxIndex )
				end)
				--[[local weaponTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3000
	            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	            local targetIndex = RandomInt(1, #weaponTargets)
	            local dummyIndex = RandomInt(1,4)
	            info.Target = weaponTargets[targetIndex]
	            info.Source = ubwdummies[dummyIndex]
	            info.vSpawnOrigin = ubwdummies[dummyIndex]:GetAbsOrigin()
	            ProjectileManager:CreateTrackingProjectile(info) ]]
			else return end 
			return 0.2
		end)
	end

	if not caster.IsUBWDominant then return end -- If UBW is not dominant right now, do not teleport units 


	ubwTargetLoc = {}
	local diff = nil
	local ubwTargetPos = nil
	ubwCasterPos = caster:GetAbsOrigin()
	
	--breakpoint
	-- record location of units and move them into UBW(center location : 6000, -4000, 200)
	for i=1, #ubwTargets do
		if ubwTargets[i]:GetName() ~= "npc_dota_ward_base" then
			ubwTargetPos = ubwTargets[i]:GetAbsOrigin()
	        ubwTargetLoc[i] = ubwTargetPos
	        diff = (ubwCasterPos - ubwTargetPos) -- rescale difference to UBW size(1200)
	        ubwTargets[i]:SetAbsOrigin(ubwCenter - diff)
	        ubwTargets[i]:Stop()
			FindClearSpaceForUnit(ubwTargets[i], ubwTargets[i]:GetAbsOrigin(), true)
			Timers:CreateTimer(0.1, function() 
				if caster:IsAlive() and IsValidEntity(ubwTargets[i]) then
					ubwTargets[i]:AddNewModifier(ubwTargets[i], ubwTargets[i], "modifier_camera_follow", {duration = 1.0})
				end
			end)
		end
    end
end

function OnUBWWeaponHit(keys)
	local caster = keys.caster
	local target = keys.target 
	if ubwdummies ~= nil then
		DoDamage(caster, keys.target, 50+caster:GetIntellect()*0.5 , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	end
end


function OnUBWDeath(keys)
	local caster = keys.caster
	print("ubw death checker removed")
	Timers:CreateTimer(0.033, function()
		EndUBW(caster)
	end)
end

function EndUBW(caster)
	if caster.IsUBWActive == false then return end
	print("UBW ended")
    caster:SwapAbilities("archer_5th_clairvoyance", caster:GetAbilityByIndex(4):GetName(), true, false) 
    caster:SwapAbilities("archer_5th_kanshou_bakuya", "archer_5th_sword_barrage_retreat_shot", true, false)
    caster:SwapAbilities("archer_5th_broken_phantasm", "archer_5th_sword_barrage_confine", true, false) 
    caster:SwapAbilities("archer_5th_ubw", "archer_5th_nine_lives", true, false) 
    
    if caster:GetAbilityByIndex(4):GetName()=="archer_5th_clairvoyance" and caster:GetAbilityByIndex(7):GetName()=="archer_5th_hrunting" and caster:GetAbilityByIndex(10):GetName()=="archer_5th_sword_barrage" then
    	print("fix for start hrunt start ubw end ubw end hrunt")
    	caster:SwapAbilities("archer_5th_clairvoyance", "archer_5th_sword_barrage", true, true)
    	caster:SwapAbilities("archer_5th_hrunting", "archer_5th_sword_barrage", true, true)
    end

	CreateUITimer("Unlimited Blade Works", 0, "ubw_timer")
	caster.IsUBWActive = false
	if not caster.UBWLocator:IsNull() and IsValidEntity(caster.UBWLocator) then
		caster.UBWLocator:RemoveSelf()
	end


	for i=1, #ubwdummies do
		if not ubwdummies[i]:IsNull() and IsValidEntity(ubwdummies[i]) then 
			ubwdummies[i]:ForceKill(true) 
		end
	end


    local units = FindUnitsInRadius(caster:GetTeam(), ubwCenter, nil, 1300
    , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

    for i=1, #units do
    	if IsValidEntity(units[i]) and not units[i]:IsNull() then
			if string.match(units[i]:GetUnitName(),"dummy") then 
				table.remove(units, i)
			end
		end
	end

    for i=1, #units do
    	print("removing units in UBW")
    	if IsValidEntity(units[i]) and not units[i]:IsNull() then
	    	ProjectileManager:ProjectileDodge(units[i])
	   		if units[i]:GetName() == "npc_dota_hero_chen" and units[i]:HasModifier("modifier_army_of_the_king_death_checker") then
	   			units[i]:RemoveModifierByName("modifier_army_of_the_king_death_checker")
	   		end
	    	local IsUnitGeneratedInUBW = true
	    	if ubwTargets ~= nil then
		    	for j=1, #ubwTargets do
		    		if not ubwTargets[j]:IsNull() and IsValidEntity(ubwTargets[j]) then 
			    		if units[i] == ubwTargets[j] then
			    			if ubwTargetLoc[j] ~= nil then
				    			units[i]:SetAbsOrigin(ubwTargetLoc[j]) 
				    			units[i]:Stop()
				    		end
			    			FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true)
			    			Timers:CreateTimer(0.1, function() 
								units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
							end)
			    			IsUnitGeneratedInUBW = false
			    			break 
			    		end
			    	end
		    	end 
	    	end
	    	if IsUnitGeneratedInUBW then
	    		diff = ubwCenter - units[i]:GetAbsOrigin()
	    		if ubwCasterPos ~= nil then
	    			units[i]:SetAbsOrigin(ubwCasterPos - diff)
	    			units[i]:Stop()
	    		end
	    		FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true) 
				Timers:CreateTimer(0.1, function() 
					if not units[i]:IsNull() and IsValidEntity(units[i]) then
						units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
					end
				end)
	    	end 
	    end
    end

    ubwTargets = nil
    ubwTargetLoc = nil

    Timers:RemoveTimer("ubw_timer")
end

-- combo
function OnRainStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster.IsUBWActive then return end
	caster:FindAbilityByName("archer_5th_rho_aias"):StartCooldown(27.0)
	local ascendCount = 0
	local descendCount = 0
	local radius = 1000
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_arrow_rain_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	caster:EmitSound("Archer.Combo") 
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 3000
	}

	local BrownSplashFx = ParticleManager:CreateParticle("particles/custom/screen_brown_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	Timers:CreateTimer( 4.0, function()
		ParticleManager:DestroyParticle( BrownSplashFx, false )
		ParticleManager:ReleaseParticleIndex( BrownSplashFx )
	end)
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 4.5)

	Timers:CreateTimer('rain_ascend', {
		endTime = 0,
		callback = function()
	   	if ascendCount == 20 then return end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z+40))
		ascendCount = ascendCount + 1;
		return 0.01
	end
	})

	-- Barrage attack
	local barrageCount = 0
	Timers:CreateTimer( 0.3, function()
		if barrageCount == 30 or not caster:IsAlive() then return end
		local arrowVector = Vector( RandomFloat( -radius, radius ), RandomFloat( -radius, radius ), 0 )
		caster:EmitSound("Hero_DrowRanger.FrostArrows")
		-- Create Arrow particles
		-- Main variables
		local speed = 3000				-- Movespeed of the arrow

		-- Side variables
		local groundVector = caster:GetAbsOrigin() - Vector(0,0,1000)
		local spawn_location = caster:GetAbsOrigin()
		local target_location = groundVector + arrowVector
		local forwardVec = ( target_location - caster:GetAbsOrigin() ):Normalized()
		local delay = ( target_location - caster:GetAbsOrigin() ):Length2D() / speed
		local distance = delay * speed
		
		local arrowFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_arrow_rain_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( arrowFxIndex, 0, spawn_location )
		ParticleManager:SetParticleControl( arrowFxIndex, 1, forwardVec * speed )
		
		-- Delay Damage
		Timers:CreateTimer( delay, function()
				-- Destroy arrow
				ParticleManager:DestroyParticle( arrowFxIndex, false )
				ParticleManager:ReleaseParticleIndex( arrowFxIndex )
				
				-- Delay damage
				local targets = FindUnitsInRadius(caster:GetTeam(), groundVector + arrowVector, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				for k,v in pairs(targets) do
					DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				end
				
				-- Particles on impact
				local explosionFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( explosionFxIndex, 0, groundVector + arrowVector + Vector(0,0,200))
				
				local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( impactFxIndex, 0, groundVector + arrowVector + Vector(0,0,200))
				ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(300, 300, 300))
				
				-- Destroy Particle
				Timers:CreateTimer( 0.5, function()
						ParticleManager:DestroyParticle( explosionFxIndex, false )
						ParticleManager:DestroyParticle( impactFxIndex, false )
						ParticleManager:ReleaseParticleIndex( explosionFxIndex )
						ParticleManager:ReleaseParticleIndex( impactFxIndex )
						return nil
					end
				)
				return nil
			end
		)
		
	    barrageCount = barrageCount + 1
		return 0.1
    end)

	-- BP Attack
	local bpCount = 0 
	Timers:CreateTimer(2.8, function()
		if bpCount == 5 or not caster:IsAlive() then return end
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		info.Target = units[math.random(#units)]
		if info.Target ~= nil then 
			ProjectileManager:CreateTrackingProjectile(info) 
		end
		bpCount = bpCount + 1
		return 0.2
    end)

	Timers:CreateTimer('rain_descend', {
		endTime = 3.8,
		callback = function()
	   	if descendCount == 20 then return end
		caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z-40))
		descendCount = descendCount + 1;
		return 0.01
	end
	})
end

ARROWRAIN_BP_DAMAGE_RATE = 0.66

function OnArrowRainBPHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ability = caster:FindAbilityByName("archer_5th_broken_phantasm")
	local targetdmg = ability:GetLevelSpecialValueFor("target_damage", ability:GetLevel()-1) * ARROWRAIN_BP_DAMAGE_RATE
	local splashdmg = ability:GetLevelSpecialValueFor("splash_damage", ability:GetLevel()-1) * ARROWRAIN_BP_DAMAGE_RATE
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel())
	local stunDuration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel()-1)

	DoDamage(caster, keys.target, targetdmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	local targets = FindUnitsInRadius(caster:GetTeam(), keys.target:GetOrigin(), nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, splashdmg, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    end
    local ArrowExplosionFx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
    ParticleManager:SetParticleControl(ArrowExplosionFx, 3, keys.target:GetAbsOrigin())
	-- Destroy Particle
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( ArrowExplosionFx, false )
		ParticleManager:ReleaseParticleIndex( ArrowExplosionFx )
		return nil
	end)
	keys.target:AddNewModifier(caster, keys.target, "modifier_stunned", {Duration = stunDuration})
end



function OnUBWBarrageStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local ply = caster:GetPlayerOwner()
	if caster.IsProjectionImproved then 
		keys.Damage = keys.Damage + (caster:GetStrength() + caster:GetIntellect())*2
	end	

	local barrageCount = 0
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sword_barrage", {})
	-- Vector
	local forwardVec = ( targetPoint - caster:GetAbsOrigin() ):Normalized()
	
	Timers:CreateTimer( function()
		if caster:HasModifier("modifier_sword_barrage") then			
			local swordVector = Vector(RandomFloat(-radius, radius), RandomFloat(-radius, radius), 0)
			
			-- Create sword particles
			-- Main variables
			local delay = 0.5				-- Delay before damage
			local speed = 3000				-- Movespeed of the sword
			
			-- Side variables
			local distance = delay * speed
			local height = distance * math.tan( 30 / 180 * math.pi )
			local spawn_location = ( targetPoint + swordVector ) - ( distance * forwardVec )
			spawn_location = spawn_location + Vector( 0, 0, height )
			local target_location = targetPoint + swordVector
			local newForwardVec = ( target_location - spawn_location ):Normalized()
			target_location = target_location + 100 * newForwardVec
			
			local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( swordFxIndex, 0, spawn_location )
			ParticleManager:SetParticleControl( swordFxIndex, 1, newForwardVec * speed )
			
			-- Delay
			Timers:CreateTimer( delay, function()
					-- Destroy particles
					ParticleManager:DestroyParticle( swordFxIndex, false )
					ParticleManager:ReleaseParticleIndex( swordFxIndex )
					
					-- Delay damage
					local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint + swordVector, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
					for k,v in pairs(targets) do
						DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
						v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.1})
					end
					
					-- Particles on impact
					local explosionFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
					ParticleManager:SetParticleControl( explosionFxIndex, 0, targetPoint + swordVector )
					
					local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
					ParticleManager:SetParticleControl( impactFxIndex, 0, targetPoint + swordVector )
					ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(300, 300, 300))
					
					-- Destroy Particle
					Timers:CreateTimer( 0.5, function()
							ParticleManager:DestroyParticle( explosionFxIndex, false )
							ParticleManager:DestroyParticle( impactFxIndex, false )
							ParticleManager:ReleaseParticleIndex( explosionFxIndex )
							ParticleManager:ReleaseParticleIndex( impactFxIndex )
						end
					)
					
					return nil
				end
			)
			
		    barrageCount = barrageCount + 1
			return 0.055
		else 
			return
		end
    end)

	caster:EmitSound("Archer.UBWAmbient")

	if math.random(1,2) == 1 then
		caster:EmitSound("Archer.Bladeoff")
	else
		caster:EmitSound("Archer.Yuke")
	end
end

function OnBarrageCanceled(keys)
	keys.caster:RemoveModifierByName("modifier_sword_barrage")
end

function OnUBWBarrageRetreatStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.Damage
	local radius = keys.Radius
	local retreatDist = keys.RetreatDist
	local forwardVec = caster:GetForwardVector()
	local range = keys.Range
	local interval = range/6
	local casterPos = caster:GetAbsOrigin()
	local counter  = 1
	local archer = Physics:Unit(caster)


	caster:PreventDI()
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(-forwardVec * retreatDist * 4/2 + Vector(0,0,750))
	caster:SetPhysicsAcceleration(Vector(0,0,-2000))
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)


  	Timers:CreateTimer(0.5, function()
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	end)

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)
	caster:EmitSound("Archer.NineFinish")
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ATTACK, rate=1.0})
	rotateCounter = 1
	Timers:CreateTimer(function()
		if rotateCounter == 9 then return end
		caster:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0,45*rotateCounter,0), forwardVec))
		rotateCounter = rotateCounter + 1
		return 0.03
	end)
	Timers:CreateTimer(function()
		if counter > 6 then return end
		local targetPoint = casterPos + forwardVec * interval * counter
		local swordOrigin = casterPos - forwardVec * retreatDist + RandomVector(250) + Vector(0,0,500)
		local swordVector = (targetPoint - swordOrigin):Normalized()
		
		local swordFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_model.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( swordFxIndex, 0, swordOrigin )
		ParticleManager:SetParticleControl( swordFxIndex, 1, swordVector*3000 )

		Timers:CreateTimer(0.25, function()
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), targetPoint, caster, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
			for k,v in pairs(targets) do
				DoDamage(caster, v, damage , DAMAGE_TYPE_MAGICAL, 0, ability, false)
				giveUnitDataDrivenModifier(caster, v, "stunned", 0.1)
				if caster.IsProjectionImproved then 
					ability:ApplyDataDrivenModifier(caster, v, "modifier_barrage_retreat_shot_slow", {})
				end
			end
			-- Particles on impact
			local explosionFxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( explosionFxIndex, 0, targetPoint )
			
			local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( impactFxIndex, 0, targetPoint )
			ParticleManager:SetParticleControl( impactFxIndex, 1, Vector(200,200,200))
		end)
		counter = counter+1
		return 0.1
	end)
end

function OnUBWBarrageConfineStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if caster.IsProjectionImproved then 
		giveUnitDataDrivenModifier(caster, keys.target, "rb_sealdisabled", 3.0)
		giveUnitDataDrivenModifier(caster, target, "locked",3.0)
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_sword_barrage_confine", {})
	target:AddNewModifier(caster, target, "modifier_stunned", {duration = 0.1})
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	for i=1,8 do
		local confineDummy = CreateUnitByName("ubw_sword_confine_dummy", Vector(target:GetAbsOrigin().x + math.cos(i*0.8) * 150, target:GetAbsOrigin().y + math.sin(i*0.8) * 150, -200)  , false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
		confineDummy:FindAbilityByName("dummy_visible_unit_passive_no_fly"):SetLevel(1)
		confineDummy:SetAbsOrigin(confineDummy:GetAbsOrigin() - Vector(0,0,-200)) 
		confineDummy:SetForwardVector(Vector(0,0,-1))
		Timers:CreateTimer(keys.TrapDuration, function()
			if confineDummy:IsNull() == false then
				confineDummy:RemoveSelf()
			end
		end)
	end
	target:EmitSound("FA.Quickdraw")
end

function OnUBWRBStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if caster.IsProjectionImproved then 
		keys.StunDuration = keys.StunDuration + 0.2
		giveUnitDataDrivenModifier(caster, keys.target, "rb_sealdisabled", 2.0)
	end
	keys.target:AddNewModifier(caster, target, "modifier_stunned", {duration = keys.StunDuration})
	EmitGlobalSound("Caster.RuleBreaker") 
end


function OnUBWNineStart(keys)
	local caster = keys.caster
	local travelCounter = 0
	local targetPoint = keys.target_points[1]
	local ply = caster:GetPlayerOwner()

	local archer = Physics:Unit(caster)
	local origin = caster:GetAbsOrigin()
	local distance = (targetPoint - origin):Length2D()
	local forward = (targetPoint - origin):Normalized() * distance
	EmitGlobalSound("Archer.NineLives" )

	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(forward)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2.0)
	Timers:CreateTimer(1.00, function() 
		if caster:HasModifier("modifier_ubw_nine_anim") == false and not caster.NineLanded then
			caster:RemoveModifierByName("modifier_ubw_nine_anim")
			OnUBWNineLanded(caster, keys.ability) 
		end
	return end)

	--[[caster:OnPhysicsFrame(function(unit)
		local diff = unit:GetAbsOrigin() - origin
		-- print(distance .. " and " .. diff:Length2D())
		if diff:Length2D() > distance then
			unit:PreventDI(false)
			unit:OnPhysicsFrame(nil)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			unit:OnPhysicsFrame(nil)
		end
	end)]]

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		OnUBWNineLanded(caster, keys.ability)
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		unit:OnPreBounce(nil)
		if caster:IsAlive() and not caster.NineLanded then
			caster:RemoveModifierByName("modifier_ubw_nine_anim")
			OnUBWNineLanded(caster, keys.ability)
		end
	end)
end

function OnUBWNineLanded(caster, ability)
	local tickdmg = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local lasthitdmg = ability:GetLevelSpecialValueFor("damage_lasthit", ability:GetLevel() - 1)
	local radius = ability:GetSpecialValueFor("radius")
	local lasthitradius = ability:GetSpecialValueFor("radius_lasthit")
	local stun = ability:GetSpecialValueFor("stun_duration")
	local casterInitOrigin = caster:GetAbsOrigin() 
	local nineCounter = 0

	local ply = caster:GetPlayerOwner()


	ability:ApplyDataDrivenModifier(caster, caster, "modifier_nine_anim", {})
	Timers:CreateTimer(function()
		if caster:IsAlive() then -- only perform actions while caster stays alive
			if nineCounter == 8 then -- if nine is finished
				caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact") 
				caster:EmitSound("Archer.NineFinish") 
				caster:RemoveModifierByName("pause_sealdisabled") 
				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, lasthitradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
				for k,v in pairs(lasthitTargets) do
					if caster.IsProjectionImproved then 
						DoDamage(caster, v, lasthitdmg+v:GetHealth()*0.05 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
					else
						DoDamage(caster, v, lasthitdmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
					end
					v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.0})
					-- push enemies back
					local pushback = Physics:Unit(v)
					v:PreventDI()
					v:SetPhysicsFriction(0)
					v:SetPhysicsVelocity((v:GetAbsOrigin() - casterInitOrigin):Normalized() * 300)
					v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
					v:FollowNavMesh(false)
					Timers:CreateTimer(0.5, function()  
						v:PreventDI(false)
						v:SetPhysicsVelocity(Vector(0,0,0))
						v:OnPhysicsFrame(nil)
					return end)		
				end
				
				-- Particles
				local explosionParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", PATTACH_ABSORIGIN, caster )
				ParticleManager:SetParticleControl( explosionParticleIndex, 1, Vector( lasthitradius, lasthitradius, lasthitradius ) )
				
				local magmaParticleIndex = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_magma_cracks_egset.vpcf", PATTACH_ABSORIGIN, caster )
	   			
				-- Destroy particles
				Timers:CreateTimer( 1.0, function()
						ParticleManager:DestroyParticle( explosionParticleIndex, false )
						ParticleManager:DestroyParticle( magmaParticleIndex, false )
						ParticleManager:ReleaseParticleIndex( explosionParticleIndex )
						ParticleManager:ReleaseParticleIndex( magmaParticleIndex )
						return nil
					end
				)
		
				return 
			end
			
			caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
			for k,v in pairs(targets) do
				if caster.IsProjectionImproved then 
					DoDamage(caster, v, tickdmg+v:GetHealth()*0.05 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
				else
					DoDamage(caster, v, tickdmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
				end	
				v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.0})
			end

			-- Particles
			local fireParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ember_spirit/ember_spirit_hit_shockwave.vpcf", PATTACH_ABSORIGIN, caster )
			local magmaParticleIndex = ParticleManager:CreateParticle( "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_magma_low_egset.vpcf", PATTACH_ABSORIGIN, caster )
			local waveParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_warstomp_shockwave.vpcf", PATTACH_ABSORIGIN, caster )

			-- Destroy particles
			Timers:CreateTimer( 1.0, function()
					ParticleManager:DestroyParticle( fireParticleIndex, false )
					ParticleManager:DestroyParticle( magmaParticleIndex, false )
					ParticleManager:DestroyParticle( waveParticleIndex, false )
					ParticleManager:ReleaseParticleIndex( fireParticleIndex )
					ParticleManager:ReleaseParticleIndex( magmaParticleIndex )
					ParticleManager:ReleaseParticleIndex( waveParticleIndex )
					return nil
				end
			)
			
			nineCounter = nineCounter + 1
			-- print(nineCounter)
			return 0.12
		end 
	end)
end

function OnHruntCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	if keys.target:IsHero() then
		Say(ply, "Hrunting targets " .. FindName(keys.target:GetName()) .. ".", true)
	end
	ability:EndCooldown()
	-- Show hrunting cast
	if caster.hrunting_particle ~= nil then
		ParticleManager:DestroyParticle( caster.hrunting_particle, false )
		ParticleManager:ReleaseParticleIndex( caster.hrunting_particle )
	end
	Timers:CreateTimer(4.0, function() 
		if caster.hrunting_particle ~= nil then
			ParticleManager:DestroyParticle( caster.hrunting_particle, false )
			ParticleManager:ReleaseParticleIndex( caster.hrunting_particle )
		end
		return
	end)
	caster.hrunting_particle = ParticleManager:CreateParticle( "particles/econ/events/ti4/teleport_end_ti4.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( caster.hrunting_particle, 2, Vector( 255, 0, 0 ) )
	ParticleManager:SetParticleControlEnt(caster.hrunting_particle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(caster.hrunting_particle, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	caster.hruntingCrosshead = ParticleManager:CreateParticleForTeam("particles/custom/archer/archer_broken_phantasm/archer_broken_phantasm_crosshead.vpcf", PATTACH_OVERHEAD_FOLLOW, target, caster:GetTeamNumber())

end

function OnHruntStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle(caster.hruntingCrosshead, true)
	if not caster:CanEntityBeSeenByMyTeam(target) or caster:GetRangeToUnit(target) > 4000 or not IsInSameRealm(caster:GetAbsOrigin(), target:GetAbsOrigin()) then 
		Say(ply, "Hrunting failed.", true)
		return 
	end
	ability:StartCooldown(ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_hrunting_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	caster.HruntDamage =  250 + caster:FindAbilityByName("archer_5th_broken_phantasm"):GetLevel() * 100  + caster:GetMana()
	caster:SetMana(0) 
	
	local info = {
		Target = keys.target,
		Source = keys.caster, 
		Ability = keys.ability,
		EffectName = "particles/custom/archer/archer_hrunting_orb.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 3000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDodgeable = true
	}

	ProjectileManager:CreateTrackingProjectile(info) 
	-- give vision for enemy
	if IsValidEntity(target) then
		SpawnVisionDummy(target, caster:GetAbsOrigin(), 500, 3, false)
	end
	EmitGlobalSound("Archer.Hrunting_Fireoff")
	if keys.target:IsHero() then
		Say(ply, "Hrunting fired at " .. FindName(keys.target:GetName()) .. ".", true)
	end
end

function OnHruntInterrupted(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	ParticleManager:DestroyParticle( caster.hrunting_particle, false )
	ParticleManager:ReleaseParticleIndex( caster.hrunting_particle )
	ParticleManager:DestroyParticle(caster.hruntingCrosshead, true)
	caster:StopSound("Hero_Invoker.EMP.Charge")
	Say(ply, "Hrunting failed.", true)
end

function OnHruntHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	keys.target:EmitSound("Misc.Crash")
	-- Create Particle
	local explosionParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_hrunting_area.vpcf", PATTACH_CUSTOMORIGIN, keys.target )
	ParticleManager:SetParticleControl( explosionParticleIndex, 0, keys.target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( explosionParticleIndex, 1, Vector( 1000, 1000, 0 ) )
	
	-- Destroy Particle
	Timers:CreateTimer( 1.0, function()
			ParticleManager:DestroyParticle( explosionParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( explosionParticleIndex )
			return nil
		end
	)
	
	local caster = keys.caster
	DoDamage(keys.caster, keys.target, keys.caster.HruntDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	local targets = FindUnitsInRadius(caster:GetTeam(), keys.target:GetAbsOrigin(), nil, 1000
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		if v ~= keys.target then DoDamage(keys.caster, v, keys.caster.HruntDamage/2, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false) end
	end
	if not keys.target:IsMagicImmune() then
		keys.target:AddNewModifier(caster, keys.target, "modifier_stunned", {Duration = 2.0})
	end
end

function OnOveredgeStart(keys)
	local caster = keys.caster 
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local dist = (caster:GetAbsOrigin() - targetPoint):Length2D() * 10/6
	local castRange = keys.castRange

	-- When you exit the ubw on the last moment, dist is going to be a pretty high number, since the targetPoint is on ubw but you are outside it
	-- If it's, then we can't use it like that. Either cancel Overedge, or use a default one.
	-- 2000 is a fixedNumber, just to check if dist is not valid. Over 2000 is surely wrong. (Max is close to 900)
	if dist > 2000 then
		dist = 500 --Default one
		--[[keys.ability:EndCooldown() --Cancel overedge
		caster:GiveMana(600) 
		return--]]
	end

	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(600) 
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Travel")
		return 
	end 
	--caster.OveredgeCount = -1
	--caster:RemoveModifierByName("modifier_overedge_stack")
	--keys.ability:SetActivated(false)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_overedge_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.59)
    local archer = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 800))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)
    caster:SetPhysicsAcceleration(Vector(0,0,-2666))

	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	StartAnimation(caster, {duration=0.6, activity=ACT_DOTA_ATTACK, rate=0.8})
	--[[ability:ApplyDataDrivenModifier(caster, caster, "modifier_overedge_anim", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_overedge_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	caster:RemoveModifierByName("modifier_overedge_stack") ]]


	Timers:CreateTimer({
		endTime = 0.6,
		callback = function()
		caster:EmitSound("Hero_Centaur.DoubleEdge") 
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:SetAutoUnstuck(true)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

		-- Create particles
		-- Variable for cross slash
		local origin = caster:GetAbsOrigin()
		local forwardVec = caster:GetForwardVector()
		local rightVec = caster:GetRightVector()
		local backPoint1 = origin - keys.Radius * forwardVec + keys.Radius * rightVec
		local backPoint2 = origin - keys.Radius * forwardVec - keys.Radius * rightVec
		local frontPoint1 = origin + keys.Radius * forwardVec - keys.Radius * rightVec
		local frontPoint2 = origin + keys.Radius * forwardVec + keys.Radius * rightVec
		backPoint1.z = backPoint1.z + 250
		backPoint2.z = backPoint2.z + 250
		
		-- Cross slash
		local slash1ParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_overedge_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( slash1ParticleIndex, 2, backPoint1 )
		ParticleManager:SetParticleControl( slash1ParticleIndex, 3, frontPoint1 )
		
		local slash2ParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_overedge_slash.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( slash2ParticleIndex, 2, backPoint2 )
		ParticleManager:SetParticleControl( slash2ParticleIndex, 3, frontPoint2 )
		
		-- Stomp
		local stompParticleIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( stompParticleIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( stompParticleIndex, 1, Vector( keys.Radius, keys.Radius, keys.Radius ) )
		
		-- Destroy particle
		Timers:CreateTimer( 1.0, function()
				ParticleManager:DestroyParticle( slash1ParticleIndex, false )
				ParticleManager:DestroyParticle( slash2ParticleIndex, false )
				ParticleManager:DestroyParticle( stompParticleIndex, false )
				ParticleManager:ReleaseParticleIndex( slash1ParticleIndex )
				ParticleManager:ReleaseParticleIndex( slash2ParticleIndex )
				ParticleManager:ReleaseParticleIndex( stompParticleIndex )
			end
		)
		
        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	         DoDamage(caster, v, 700 + 20 * caster:GetIntellect() , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    end
	end
	})
end


function ArcherCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("archer_5th_ubw") and caster:FindAbilityByName("archer_5th_rho_aias"):IsCooldownReady() and caster:FindAbilityByName("archer_5th_arrow_rain"):IsCooldownReady() then
			caster:SwapAbilities("archer_5th_rho_aias", "archer_5th_arrow_rain", true, true) 
			Timers:CreateTimer({
				endTime = 5,
				callback = function()
				caster:SwapAbilities("archer_5th_rho_aias", "archer_5th_arrow_rain", true, true) 
			end
			})			
		end
	end
end

function OnEagleEyeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("archer_5th_clairvoyance"):SetLevel(2)
	hero:SetDayTimeVisionRange(hero:GetDayTimeVisionRange() + 200)
	hero:SetNightTimeVisionRange(hero:GetNightTimeVisionRange() + 200) 
	hero.IsEagleEyeAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnHruntingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsHruntingAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnShroudOfMartinAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetBaseMagicalResistanceValue(15)
	hero.IsMartinAcquired = true
	hero.ExtraARMORgained = 10

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveProjectionAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local ability = keys.ability
	
	if hero.IsProjectionImproved then
		hero.IsProjection2Improved = true
		ability:StartCooldown(9999)
	else
		hero.IsProjectionImproved = true
		ability:EndCooldown()
	end
	

	--caster:AddAbility("archer_5th_attribute_improve_projection_level2")
	--caster:FindAbilityByName("archer_5th_attribute_improve_projection_level2"):SetLevel(1)
	--caster:SwapAbilities(keys.ability:GetAbilityName(), "archer_5th_attribute_improve_projection_level2", true, true)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveProjection2Acquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsProjection2Improved = true


	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnOveredgeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsOveredgeAcquired = true
	hero.OveredgeCount = 0
	hero:FindAbilityByName("archer_5th_overedge"):SetLevel(1)
	hero:FindAbilityByName("archer_5th_overedge"):SetActivated(true)
	--GrantOveredgeStack(hero)

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OveredgeStackExpired(keys)
	GrantOveredgeStack(keys.caster)
end

function GrantOveredgeStack(hero)
	--print("Adding overedge stack")
	if hero.OveredgeCount < 4 then
		hero.OveredgeCount = hero.OveredgeCount + 1
	end
	if not hero:HasModifier("modifier_overedge_stack") then
		hero:FindAbilityByName("archer_5th_overedge"):ApplyDataDrivenModifier(hero, hero, "modifier_overedge_stack", {})
	end
	hero:SetModifierStackCount("modifier_overedge_stack", hero, hero.OveredgeCount)
	if hero.OveredgeCount == 4 then
		hero:FindAbilityByName("archer_5th_overedge"):SetActivated(true)
	end
end