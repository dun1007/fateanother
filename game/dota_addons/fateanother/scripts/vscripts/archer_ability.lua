require("physics")
require("util")

chainTargetsTable = nil
ubwTargets = nil
ubwTargetLoc = nil
ubwCasterPos = nil
ubwCenter = Vector(5600, -4398, 200)
aotkCenter = Vector(500, -4800, 208)

function FarSightVision(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local radius = keys.ability:GetLevelSpecialValueFor( "radius", keys.ability:GetLevel() - 1 )

	local visiondummy = CreateUnitByName("sight_dummy_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber())
	visiondummy:SetDayTimeVisionRange(radius)
	visiondummy:SetNightTimeVisionRange(radius)
	visiondummy:EmitSound("Hero_KeeperOfTheLight.BlindingLight") 
	if ply.IsEagleEyeAcquired then 
		visiondummy:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 1400}) 
	end

	local unseen = visiondummy:FindAbilityByName("dummy_unit_passive")
	unseen:SetLevel(1)

	if ply.IsHruntingAcquired then
		caster:SwapAbilities("archer_5th_clairvoyance", "archer_5th_hrunting", true, true) 
		Timers:CreateTimer(8, function() caster:SwapAbilities("archer_5th_clairvoyance", "archer_5th_hrunting", true, false) return end)
	end
	
	Timers:CreateTimer(8, function() FarSightEnd(visiondummy) return end)
	
	-- Particles
	
	
	local circleFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_circle.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( circleFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( circleFxIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:SetParticleControl( circleFxIndex, 2, Vector( 8, 0, 0 ) )
	
	local dustFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_clairvoyance_dust.vpcf", PATTACH_CUSTOMORIGIN, visiondummy )
	ParticleManager:SetParticleControl( dustFxIndex, 0, visiondummy:GetAbsOrigin() )
	ParticleManager:SetParticleControl( dustFxIndex, 1, Vector( radius, radius, radius ) )
	
	visiondummy.circle_fx = circleFxIndex
	visiondummy.dust_fx = dustFxIndex
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
	
	if ply.IsOveredgeAcquired and caster.OveredgeCount < 3 then
		caster.OveredgeCount = caster.OveredgeCount + 1
		caster:RemoveModifierByName("modifier_overedge_stack") 
		caster:FindAbilityByName("archer_5th_overedge"):ApplyDataDrivenModifier(caster, caster, "modifier_overedge_stack", {}) 
		caster:SetModifierStackCount("modifier_overedge_stack", caster, caster.OveredgeCount)

	elseif caster.OveredgeCount == 3 then 
		if caster:GetAbilityByIndex(3):GetName() ~= "archer_5th_overedge" then
			caster:SwapAbilities("rubick_empty1", "archer_5th_overedge", true, true) 
		end
	end

	if caster:HasModifier("modifier_ubw_death_checker") then
		print("UBW up")
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(3.0)
	end	

	if ply.IsProjectionImproved and caster:HasModifier("modifier_ubw_death_checker") then
		keys.ability:EndCooldown()
		keys.ability:StartCooldown(2.0)
	end
end

function KBHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local KBCount = 0

	Timers:CreateTimer(function() 
		if KBCount == 4 then return end
		DoDamage(keys.caster, keys.target, keys.DamagePerTick , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 
		caster:EmitSound("Hero_Juggernaut.OmniSlash.Damage")
		KBCount = KBCount + 1
		return 0.25
	end)
end

function OnBPCast(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if keys.target:IsHero() then
		Say(ply, "Broken Phantasm targets " .. FindName(keys.target:GetName()) .. ".", true)
	end
end

function OnBPStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if keys.target:IsHero() then
		Say(ply, "Broken Phantasm fired at " .. FindName(keys.target:GetName()) .. ".", true)
	end
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


    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin())
	--ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()) -- target location
	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
	end
end

rhoTarget = nil

function OnRhoStart(keys)
	local target = keys.target
	rhoTarget = target 
	target.rhoShieldAmount = keys.ShieldAmount
	EmitGlobalSound("Archer.RhoAias" ) --[[Returns:void
	Play named sound for all players
	]]
	
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
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 1, Vector( origin.x + 100 * forwardVec.x, origin.y + 100 * forwardVec.y, origin.z + 150 ) ) -- petal_core, center of petals
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 2, Vector( origin.x - 20 * forwardVec.x, origin.y - 20 * forwardVec.y, origin.z + 250 ) ) -- petal_a
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 3, Vector( origin.x + 100 * forwardVec.x, origin.y + 100 * forwardVec.y, origin.z ) ) -- petal_d
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 4, Vector( origin.x + 100 * rightVec.x, origin.y + 100 * rightVec.y, origin.z + 200 ) ) -- petal_b
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 5, Vector( origin.x - 100 * rightVec.x, origin.y - 100 * rightVec.y, origin.z + 200 ) ) -- petal_c
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 6, Vector( origin.x + 100 * rightVec.x + 40 * forwardVec.x, origin.y + 100 * rightVec.y + 40 * forwardVec.y, origin.z + 50 ) ) -- petal_e
			ParticleManager:SetParticleControl( rhoShieldParticleIndex, 7, Vector( origin.x - 100 * rightVec.x + 40 * forwardVec.x, origin.y - 100 * rightVec.y + 40 * forwardVec.y, origin.z + 50 ) ) -- petal_f
			
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
			print("lethal")
		else
			print("rho broken, but not lethal")
			rhoTarget:RemoveModifierByName("modifier_rho_aias_shield")
			rhoTarget:SetHealth(currentHealth + keys.DamageTaken + rhoTarget.rhoShieldAmount)
			rhoTarget.rhoShieldAmount = 0
		end
	else
		print("rho not broken, remaining shield : " .. rhoTarget.rhoShieldAmount)
		rhoTarget:SetHealth(currentHealth + keys.DamageTaken)
	end
end

-- Starts casting UBW
function OnUBWCastStart(keys)
	local caster = keys.caster
	EmitGlobalSound("Archer.UBW")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 2.0)
	Timers:CreateTimer({
		endTime = 2,
		callback = function()
		if keys.caster:IsAlive() then 
			OnUBWStart(keys)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_ubw_death_checker",{})
		end
	end
	})
	ArcherCheckCombo(keys.caster, keys.ability)

	-- Flame spread particle
	local angle = 0
	local increment_factor = 45
	local origin = caster:GetAbsOrigin()
	local forward = caster:GetForwardVector() * 1150
	local destination = origin + forward
	local ubwflame = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
        iMoveSpeed = 575,
        vSpawnOrigin = origin,
        fDistance = 1150,
        fStartRadius = 1000,
        fEndRadius = 1000,
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
		ubwflame.vVelocity = new_forward * 575
		local projectile = ProjectileManager:CreateLinearProjectile(ubwflame)
	end 
	
end

ubwQuest = nil
ubwdummies = nil
-- Begins UBW 
function OnUBWStart(keys)
	ubwQuest = StartQuestTimer("ubwTimerQuest", "Unlimited Blade Works", 12)
	local caster = keys.caster
	local ability = keys.ability
	local ubwdummyLoc1 = ubwCenter + Vector(600,-600, 1000)
	local ubwdummyLoc2 = ubwCenter + Vector(600,600, 1000)
	local ubwdummyLoc3 = ubwCenter + Vector(-600,600, 1000)
	local ubwdummyLoc4 = ubwCenter + Vector(-600,-600, 1000)
	ubwTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	caster.IsUBWDominant = true
	for i=1, #ubwTargets do
		if ubwTargets[i]:GetName() == "npc_dota_hero_chen" and ubwTargets[i]:HasModifier("modifier_army_of_the_king_death_checker") then
			ubwdummyLoc1 = aotkCenter + Vector(600,-600, 1000)
			ubwdummyLoc2 = aotkCenter + Vector(600,600, 1000)
			ubwdummyLoc3 = aotkCenter + Vector(-600,600, 1000)
			ubwdummyLoc4 = aotkCenter + Vector(-600,-600, 1000)
			caster.IsUBWDominant = false
			break
		end
	end
	caster.IsUBWActive = true

	local info = {
		Target = nil,
		Source = nil, 
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
		vSpawnOrigin = ubwCenter + Vector(RandomFloat(-800,800),RandomFloat(-800,800), 500),
		iMoveSpeed = 1000
	}

    -- swap Archer's skillset with UBW ones
    caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "archer_5th_sword_barrage", true, true) 
    caster:SwapAbilities("archer_5th_broken_phantasm", "archer_5th_rule_breaker", true, true) 
    caster:SwapAbilities("archer_5th_ubw", "archer_5th_nine_lives", true, true) 

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
	Timers:CreateTimer(function()
		ubwdummy1:SetAbsOrigin(ubwdummyLoc1)
		ubwdummy2:SetAbsOrigin(ubwdummyLoc2)
		ubwdummy3:SetAbsOrigin(ubwdummyLoc3)
		ubwdummy4:SetAbsOrigin(ubwdummyLoc4)
	end)
	ubwdummies = {ubwdummy1, ubwdummy2, ubwdummy3, ubwdummy4}
	for i=1, #ubwdummies do
		ubwdummies[i]:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
		ubwdummies[i]:SetDayTimeVisionRange(1000)
		ubwdummies[i]:SetNightTimeVisionRange(1000)
		ubwdummies[i]:AddNewModifier(caster, caster, "modifier_item_ward_true_sight", {true_sight_range = 1000})
	end

	Timers:CreateTimer(function() 
		if caster:IsAlive() and caster:HasModifier("modifier_ubw_death_checker") then
			local weaponTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3000
            , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
            for i=1, #weaponTargets do
            	if weaponTargets[i]:GetTeam() ~= caster:GetTeam() then
            		info.Target = weaponTargets[i]
            		info.Source = ubwdummies[RandomInt(1,4)]
            		info.vSpawnOrigin = ubwdummies[RandomInt(1,4)]:GetAbsOrigin()
            		break
            	end
            end
            ProjectileManager:CreateTrackingProjectile(info) 
		else return end 
		return 0.1
	end)

	if not caster.IsUBWDominant then return end -- If UBW is not dominant right now, do not teleport units 


	ubwTargetLoc = {}
	local diff = nil
	local ubwTargetPos = nil
	ubwCasterPos = caster:GetAbsOrigin()
	
	-- record location of units and move them into UBW(center location : 6000, -4000, 200)
	for i=1, #ubwTargets do
		if ubwTargets[i]:GetName() ~= "npc_dota_ward_base" then
			ubwTargetPos = ubwTargets[i]:GetAbsOrigin()
	        ubwTargetLoc[i] = ubwTargetPos
	        diff = (ubwCasterPos - ubwTargetPos) -- rescale difference to UBW size(1200)
	        ubwTargets[i]:SetAbsOrigin(ubwCenter - diff)
			FindClearSpaceForUnit(ubwTargets[i], ubwTargets[i]:GetAbsOrigin(), true)
			Timers:CreateTimer(0.1, function() 
				if caster:IsAlive() then
					ubwTargets[i]:AddNewModifier(ubwTargets[i], ubwTargets[i], "modifier_camera_follow", {duration = 1.0})
				end
			end)
		end
    end


end


function OnUBWDeath(keys)
	local caster = keys.caster
	print("ubw death checker removed")
	EndUBW(caster)
end

function EndUBW(caster)
	if caster.IsUBWActive == false then return end
	print("UBW ended")

	UTIL_RemoveImmediate(ubwQuest)
	caster.IsUBWActive = false

    caster:SwapAbilities("archer_5th_clairvoyance", caster:GetAbilityByIndex(4):GetName(), true, true) 
    caster:SwapAbilities("archer_5th_broken_phantasm", "archer_5th_rule_breaker", true, true) 
    caster:SwapAbilities("archer_5th_ubw", "archer_5th_nine_lives", true, true) 

	for i=1, #ubwdummies do
		ubwdummies[i]:ForceKill(true) 
	end


    local units = FindUnitsInRadius(caster:GetTeam(), ubwCenter, nil, 1300
    , DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

    for i=1, #units do
    	ProjectileManager:ProjectileDodge(units[i])
   		if units[i]:GetName() == "npc_dota_hero_chen" and units[i]:HasModifier("modifier_army_of_the_king_death_checker") then
   			units[i]:RemoveModifierByName("modifier_army_of_the_king_death_checker")
   		end
    	local IsUnitGeneratedInUBW = true
    	if ubwTargets ~= nil then
	    	for j=1, #ubwTargets do
	    		if units[i] == ubwTargets[j] then
	    			units[i]:SetAbsOrigin(ubwTargetLoc[j]) 
	    			FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true)
	    			Timers:CreateTimer(0.1, function() 
						units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
					end)
	    			IsUnitGeneratedInUBW = false
	    			break 
	    		end
	    	end 
    	end
    	if IsUnitGeneratedInUBW then
    		diff = ubwCenter - units[i]:GetAbsOrigin()
    		units[i]:SetAbsOrigin(ubwCasterPos - diff)
    		FindClearSpaceForUnit(units[i], units[i]:GetAbsOrigin(), true) 
			Timers:CreateTimer(0.1, function() 
				units[i]:AddNewModifier(units[i], units[i], "modifier_camera_follow", {duration = 1.0})
			end)
    	end 
    end

    ubwTargets = nil
    ubwTargetLoc = nil

    Timers:RemoveTimer("ubw_timer")
end

-- combo
function OnRainStart(keys)
	local caster = keys.caster
	caster:FindAbilityByName("archer_5th_rho_aias"):StartCooldown(27.0)
	local ascendCount = 0
	local descendCount = 0
	local radius = 1200

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

	ParticleManager:CreateParticle("particles/custom/screen_brown_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 4.0)

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
				ParticleManager:SetParticleControl( explosionFxIndex, 0, groundVector + arrowVector + Vector( 0, 0, 150 ) )
				
				local impactFxIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_sword_barrage_impact_circle.vpcf", PATTACH_CUSTOMORIGIN, caster )
				ParticleManager:SetParticleControl( impactFxIndex, 0, groundVector + arrowVector + Vector( 0, 0, 150 ) )
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
		if bpCount == 5 then return end
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
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

function OnArrowRainBPHit(keys)
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	local caster = keys.caster
	local ability = caster:FindAbilityByName("archer_5th_broken_phantasm")
	local targetdmg = ability:GetLevelSpecialValueFor("target_damage", ability:GetLevel())
	local splashdmg = ability:GetLevelSpecialValueFor("splash_damage", ability:GetLevel())
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel())
	local stunDuration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel())

	DoDamage(caster, keys.target, targetdmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	local targets = FindUnitsInRadius(caster:GetTeam(), keys.target:GetOrigin(), nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, splashdmg, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    end
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
    ParticleManager:SetParticleControl(particle, 3, keys.target:GetAbsOrigin())
	keys.target:AddNewModifier(caster, keys.target, "modifier_stunned", {Duration = stunDuration})
end

function OnUBWWeaponHit(keys)
	if keys.caster:GetPlayerOwner().IsProjectionImproved then 
		keys.Damage = keys.Damage + 10
	end	
	if ubwdummies ~= nil then
		DoDamage(ubwdummies[1], keys.target, keys.Damage , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	end
end

function OnUBWBarrageStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local ply = caster:GetPlayerOwner()
	if ply.IsProjectionImproved then 
		keys.Damage = keys.Damage + 100
	end	
	caster:EmitSound("Archer.UBWAmbient")
	local barrageCount = 0
	
	-- Vector
	local forwardVec = ( targetPoint - caster:GetAbsOrigin() ):Normalized()
	
	Timers:CreateTimer( function()
		if barrageCount == 25 then return end
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
			return 0.08
		end
    end)
end

function OnBarrageCanceled(keys)
	keys.caster:RemoveModifierByName("modifier_sword_barrage")
end

function OnUBWRBStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsProjectionImproved then 
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
		if caster:HasModifier("modifier_ubw_nine_anim") == false then
			OnUBWNineLanded(caster, keys.ability) 
		end
	return end)

	caster:OnPhysicsFrame(function(unit)
		local diff = unit:GetAbsOrigin() - origin
		-- print(distance .. " and " .. diff:Length2D())
		if diff:Length2D() > distance then
			unit:PreventDI(false)
			unit:OnPhysicsFrame(nil)
			unit:SetPhysicsVelocity(Vector(0,0,0))
			FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
			unit:OnPhysicsFrame(nil)
		end
	end)

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		OnUBWNineLanded(caster, keys.ability)
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		unit:OnPreBounce(nil)
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
	if ply.IsProjectionImproved then 
		tickdmg = tickdmg + 15
		lasthitdmg = lasthitdmg + 200
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_nine_anim", {})
	Timers:CreateTimer(function()
		if caster:IsAlive() then -- only perform actions while caster stays alive
			if nineCounter == 8 then -- if nine is finished
				caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact") 
				caster:EmitSound("Archer.NineFinish") 
				caster:RemoveModifierByName("pause_sealdisabled") 
				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, lasthitradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
				for k,v in pairs(lasthitTargets) do
					DoDamage(caster, v, lasthitdmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
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
				DoDamage(caster, v, tickdmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
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
	local ply = caster:GetPlayerOwner()
	if keys.target:IsHero() then
		Say(ply, "Hrunting targets " .. FindName(keys.target:GetName()) .. ".", true)
	end
	caster:EmitSound("Hero_Invoker.EMP.Charge") 
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
end

function OnHruntStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if keys.target:IsHero() then
		Say(ply, "Hrunting fired at " .. FindName(keys.target:GetName()) .. ".", true)
	end
	caster.HruntDamage =  250 + caster:FindAbilityByName("archer_5th_broken_phantasm"):GetLevel() * 100  + caster:GetMana()
	print(caster:FindAbilityByName("archer_5th_broken_phantasm"):GetLevel() * 100 .. " " .. caster:GetMana())
	caster:SetMana(0) 
	
	caster:EmitSound("Hero_Mirana.ArrowCast")
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
	local targetPoint = keys.target_points[1]
	local dist = (caster:GetAbsOrigin() - targetPoint):Length2D() * 10/6
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	caster:RemoveModifierByName("modifier_overedge_stack") 
	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown() 
		caster:GiveMana(600) 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Travel to Targeted Location" } )
		return 
	end 
	caster.OveredgeCount = 0

	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 0.59)
	caster:SwapAbilities("rubick_empty1", "archer_5th_overedge", true, true) 
    local archer = Physics:Unit(caster)
    caster:PreventDI()
    caster:SetPhysicsFriction(0)
    caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, 400))
    caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
    caster:FollowNavMesh(false)	
    caster:SetAutoUnstuck(false)

	Timers:CreateTimer({
		endTime = 0.3,
		callback = function()
		print("ascend")
		caster:SetPhysicsVelocity(Vector(caster:GetForwardVector().x * dist, caster:GetForwardVector().y * dist, -400))
	end
	})

	Timers:CreateTimer({
		endTime = 0.6,
		callback = function()
		print("descend")
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
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
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
	ply.IsEagleEyeAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnHruntingAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsHruntingAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnShroudOfMartinAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetPhysicalArmorBaseValue(hero:GetPhysicalArmorBaseValue() + 10) 
	hero:SetBaseMagicalResistanceValue(15)
	ply.IsMartinAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveProjectionAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsProjectionImproved = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnOveredgeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsOveredgeAcquired = true
	hero.OveredgeCount = 0

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))

	Timers:CreateTimer(function()  
		print("Adding overedge stack")
		if ply.IsOveredgeAcquired and hero.OveredgeCount < 3 then
			hero.OveredgeCount = hero.OveredgeCount + 1
			hero:RemoveModifierByName("modifier_overedge_stack") 
			hero:FindAbilityByName("archer_5th_overedge"):ApplyDataDrivenModifier(hero, hero, "modifier_overedge_stack", {}) 
			hero:SetModifierStackCount("modifier_overedge_stack", hero, hero.OveredgeCount)
		elseif hero.OveredgeCount == 3 then 
			if hero:GetAbilityByIndex(3):GetName() ~= "archer_5th_overedge" then
				hero:SwapAbilities("rubick_empty1", "archer_5th_overedge", true, true) 
			end
		end
		return 20
	end)

end