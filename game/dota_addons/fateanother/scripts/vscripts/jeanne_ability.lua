
function OnMREXDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
	if caster.IsSaintImproved and attacker:HasModifier("modifier_saint_debuff") then return end
	print("asdasd")
	ChangeMREXStack(keys, -1)
end


function OnMREXRecharge(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
	ChangeMREXStack(keys, 1)
end

function OnMREXRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
	ChangeMREXStack(keys, 4)
end

function ChangeMREXStack(keys, modifier)
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = keys.MaxStack

	if not caster.nMREXStack then caster.nMREXStack = 0 end
	if not caster:HasModifier("modifier_magic_resistance_ex_shield") then ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex_shield", {}) end 

	local newStack = caster.nMREXStack + modifier
	if newStack < 0 then 
		newStack = 0 
	elseif newStack > maxStack then
		newStack = maxStack
	end

	if newStack == 0 then
		caster:RemoveModifierByName("modifier_magic_resistance_ex_shield")
	else
		caster:SetModifierStackCount("modifier_magic_resistance_ex_shield", caster, newStack)
	end
	caster.nMREXStack = newStack
end

function OnSaintRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability

    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
        	if playerHero:HasModifier("modifier_saint_debuff") then
        		playerHero:RemoveModifierByName("modifier_saint_debuff")
        	end

        	if playerHero:GetKills() > playerHero:GetDeaths() then
	        	ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_saint_debuff", {})
	        	playerHero:EmitSound("Hero_Chen.TestOfFaith.Cast")
        	end

        end
    end)
end

function OnIDPing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = keys.Duration
	GameRules:SendCustomMessage("#identity_discernment_alert", 0, 0)
    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
        	MinimapEvent( caster:GetTeamNumber(), caster, playerHero:GetAbsOrigin().x, playerHero:GetAbsOrigin().y + 500, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5 )
        	ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_identity_discernment_unjust", {})
        	if playerHero:HasModifier("modifier_saint_debuff") then
        		SpawnAttachedVisionDummy(caster, playerHero, 200, duration, true)
        	end
        end
     end)
end

function OnIDRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- reset CD
	ability:EndCooldown()
end


function OnIRStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = keys.Radius
	local duration = keys.Duration

	local primaryStat = target:GetPrimaryAttribute()

	if primaryStat == 0 then 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_str", {})
	elseif primaryStat == 1 then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_agi", {})
	elseif primaryStat == 2 then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jeanne_charisma_int", {})
	end 
	SpawnAttachedVisionDummy(caster, target, radius, duration, true)

	target:EmitSound("Hero_Dazzle.Shadow_Wave")

	if not target.jeanne_charisma_particle then
		target.jeanne_charisma_particle = ParticleManager:CreateParticle("particles/custom/ruler/charisma/buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	end
	ParticleManager:SetParticleControl(target.jeanne_charisma_particle, 1, Vector(radius,0,0))
	-- DebugDrawCircle(caster:GetAbsOrigin(), Vector(255,0,0), 0.5, radius, true, 0.5)
end

function OnCharismaBuffEnd(keys)
	ParticleManager:DestroyParticle(keys.target.jeanne_charisma_particle, false)
	keys.target.jeanne_charisma_particle = nil
end

ATTRIBUTE_PUNISHMENT_BONUS_DAMAGE = 45
function OnPurgeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local delay = keys.Delay
	local damage = keys.Damage
	local damagePerKill = keys.DamagePerKill
	local silenceDuration = keys.SilenceDuration

	if caster.IsPunishmentAcquired then
		damagePerKill = ATTRIBUTE_PUNISHMENT_BONUS_DAMAGE
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if not IsImmuneToSlow(v) then ability:ApplyDataDrivenModifier(caster, v, "modifier_purge_the_unjust_slow", {}) end
		end
	end

	local markFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_marker.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( markFx, 0, targetPoint)
	EmitSoundOnLocationWithCaster(targetPoint, "Hero_Chen.PenitenceImpact", caster)	

	Timers:CreateTimer(delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			local targetDamage = damage
			if v:HasModifier("modifier_saint_debuff") and  (v:GetKills() - v:GetDeaths()) > 0 then
				DoDamage(caster, v, damagePerKill * (v:GetKills() - v:GetDeaths()), DAMAGE_TYPE_PURE, 0, ability, false)
			end
	        DoDamage(caster, v, targetDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        giveUnitDataDrivenModifier(caster, v, "silenced", silenceDuration)
	    end

	    EmitSoundOnLocationWithCaster(targetPoint, "Hero_Chen.TestOfFaith.Target", caster)		
		local purgeFx = ParticleManager:CreateParticle("particles/custom/ruler/purge_the_unjust/ruler_purge_the_unjust_a.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( purgeFx, 0, targetPoint)
		ParticleManager:SetParticleControl( purgeFx, 1, targetPoint)
		ParticleManager:SetParticleControl( purgeFx, 2, targetPoint)
	end)
end


function OnGodResolutionProc(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = keys.RevokeDuration
	local damage = target:GetHealth() * keys.Damage/100
	if caster.IsPunishmentAcquired then
		damage = target:GetMaxHealth() * keys.Damage/100
	end

	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	giveUnitDataDrivenModifier(caster, target, "revoked", duration)
	if target:HasModifier("modifier_saint_debuff") then
		 giveUnitDataDrivenModifier(caster, target, "stunned", 0.1)
	end


	target:EmitSound("Hero_Chen.TeleportOut")
	local bashFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_teleport_flash_sparks.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( bashFx, 0, target:GetAbsOrigin())
	local bashFx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_penitence_c.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( bashFx2, 0, target:GetAbsOrigin())
end

function OnGodResolutionStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local tickDamage = keys.TickDamage
	local radius = keys.Radius
	local duration = keys.Duration
	if caster.IsPunishmentAcquired then
		duration = keys.Duration + 1
	end
	local elapsedTime = 0
	local tickPeriod = 0.2

	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", duration)
	Timers:CreateTimer(0.1, function()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gods_resolution_anim", {})
	end)

	caster:EmitSound("Hero_ArcWarden.MagneticField")

	Timers:CreateTimer(function()
		elapsedTime = elapsedTime + tickPeriod
		if elapsedTime > duration then 
			caster:StopSound("Hero_ArcWarden.MagneticField")
			if caster:HasModifier("modifier_gods_resolution_anim") then caster:RemoveModifierByName("modifier_gods_resolution_anim") end
			return 
		end
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			if v:HasModifier("modifier_saint_debuff") then
				 giveUnitDataDrivenModifier(caster, v, "stunned", 0.1)
			end
	        DoDamage(caster, v, tickDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        if not IsImmuneToSlow(v) then ability:ApplyDataDrivenModifier(caster, v, "modifier_gods_resolution_slow", {}) end

	    end

		local purgeFx = ParticleManager:CreateParticle("particles/custom/ruler/gods_resolution/gods_resolution_active_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( purgeFx, 0, caster:GetAbsOrigin())

		return tickPeriod
	end)
end

function OnLECastStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	EmitGlobalSound("Hero_Chen.HandOfGodHealHero")
	EmitGlobalSound("Ruler.Luminosite")

	if caster.LETargetTable then
		for i=1, #caster.LETargetTable do
			if IsValidEntity(caster.LETargetTable[i]) and caster.LETargetTable[i]:IsAlive() then
				caster.LETargetTable[i]:RemoveModifierByName("rooted")
				caster.LETargetTable[i]:RemoveModifierByName("locked")
			end
		end
	end
end

function OnLEStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local delay = keys.Delay
	local range = keys.Range
	local duration = keys.FlagDuration
	if caster.IsDivineSymbolAcquired then
		duration = duration+0.7
	end
	local health = keys.FlagHealth
	local travelTime = 1/3

	if caster.CurrentFlag and not caster.CurrentFlag:IsNull() then
		caster.CurrentFlag:RemoveModifierByName("modifier_luminosite_eternelle_flag_aura")
	end
	caster.LETargetTable = {}

	local projectileDestination = caster:GetAbsOrigin() + caster:GetForwardVector() * range
	for i=1, 20 do
		if GridNav:IsBlocked(projectileDestination) or not GridNav:IsTraversable(projectileDestination) then
			projectileDestination = projectileDestination - caster:GetForwardVector() * range/20 * i
		else
			break
		end
	end 
	local projectileRange = (caster:GetAbsOrigin() - projectileDestination):Length2D()

	-- Create invisible linear projectile to check for enemies on the trail
	local linearProjectile = 
	{
		Ability = keys.ability,
        -- EffectName = "particles/custom/reference/luminosite_eternelle/luminosite_eternelle.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = projectileRange - 300,
        fStartRadius = 300,
        fEndRadius = 300,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + travelTime,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * projectileRange / travelTime
	}
	ProjectileManager:CreateLinearProjectile(linearProjectile)

	-- Create particle dummy
	local origin_location = caster:GetAbsOrigin()
	local projectile = CreateUnitByName("dummy_unit", origin_location, false, caster, caster, caster:GetTeamNumber())
	projectile:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
	projectile:SetAbsOrigin(origin_location)

	local particle_name = "particles/custom/ruler/luminosite_eternelle/luminosite_eternelle.vpcf"
	local throw_particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, projectile)
	ParticleManager:SetParticleControl(throw_particle, 1, (projectileDestination - projectile:GetAbsOrigin()) / travelTime)
	projectile:SetForwardVector(caster:GetForwardVector())


	EmitGlobalSound("Ruler.Eternelle")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_luminosite_eternelle_anim", {})

	Timers:CreateTimer(travelTime, function()
		projectile:RemoveSelf()

		local flag = CreateUnitByName("jeanne_banner", projectileDestination, true, caster, caster, caster:GetTeamNumber())
		flag:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
		--flag:SetAbsOrigin(projectileDestination)
		FindClearSpaceForUnit(flag, flag:GetAbsOrigin(), true)
		flag:SetBaseMaxHealth(health)
		caster.CurrentFlag = flag
		caster.CurrentFlagHealth = health
		ability:ApplyDataDrivenModifier(caster, flag, "modifier_luminosite_eternelle_flag_aura", {})

		local targets = FindUnitsInRadius(caster:GetTeam(), flag:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			local newKeys = keys
			newKeys.ability = caster:FindAbilityByName("jeanne_charisma")
			newKeys.target = v
			newKeys.Radius = newKeys.ability:GetSpecialValueFor("radius_modifier")
	 		newKeys.Duration = newKeys.ability:GetSpecialValueFor("duration")
			OnIRStart(newKeys)
		end

		-- wow control points are an adventure
		local sacredZoneFx = ParticleManager:CreateParticle("particles/custom/ruler/luminosite_eternelle/sacred_zone.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(sacredZoneFx, 0, projectileDestination)
		ParticleManager:SetParticleControl(sacredZoneFx, 1, Vector(1,1,range))
		ParticleManager:SetParticleControl(sacredZoneFx, 14, Vector(range,range,0))
		ParticleManager:SetParticleControl(sacredZoneFx, 4, Vector(-range * .9,0,0) + projectileDestination) -- Cross arm lengths
		ParticleManager:SetParticleControl(sacredZoneFx, 5, Vector(range * .9,0,0) + projectileDestination)
		ParticleManager:SetParticleControl(sacredZoneFx, 6, Vector(0,-range * .9,0) + projectileDestination)
		ParticleManager:SetParticleControl(sacredZoneFx, 7, Vector(0,range * .9,0) + projectileDestination)
		caster.CurrentFlagParticle = sacredZoneFx

		EmitSoundOnLocationWithCaster(projectileDestination, "Hero_Omniknight.GuardianAngel.Cast", caster)

		-- DebugDrawCircle(projectileDestination, Vector(255,0,0), 0.5, range, true, duration)
	end)
end

function OnLEHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = keys.CCDuration
	--print(target:GetName() .. " hit by Luminosite Eternelle")
	-- apply CC
	table.insert(caster.LETargetTable, target)
	giveUnitDataDrivenModifier(caster, target, "locked", duration)
	giveUnitDataDrivenModifier(caster, target, "rooted", duration)
	target:EmitSound("Hero_ArcWarden.Flux.Cast")
end

function OnLEAllyDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	local victim = keys.unit
	local attacker = keys.attacker
	if caster.IsSaintImproved and attacker:HasModifier("modifier_saint_debuff") then
		return
	end

	if not caster.CurrentFlag:IsNull() then
		caster.CurrentFlagHealth = caster.CurrentFlagHealth - 1
		if caster.CurrentFlagHealth <= 0 then
			caster.CurrentFlag:RemoveModifierByName("modifier_luminosite_eternelle_flag_aura")
		else
			caster.CurrentFlag:SetHealth(caster.CurrentFlagHealth)
		end
	end
end

function OnFlagCleanup(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not caster.CurrentFlag:IsNull() then
		caster.CurrentFlag:RemoveSelf()
		ParticleManager:DestroyParticle( caster.CurrentFlagParticle, false )
		ParticleManager:ReleaseParticleIndex( caster.CurrentFlagParticle )
	end
end

function OnLaPucelleTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	local pid = caster:GetPlayerID()
	local duration = keys.Duration
	local delay = keys.Delay
	local originalScale = caster:GetModelScale()

	if caster:GetHealth() == 0 then
		if caster:GetStrength() >= 19.5 and caster:GetAgility() >= 19.5 and caster:GetIntellect() >= 19.5 and ability:IsCooldownReady() and not IsTeamWiped(caster) then
			caster:SetHealth(caster:GetMaxHealth())
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_pucelle_spirit_form", {})
			giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", delay)
			giveUnitDataDrivenModifier(caster, caster, "revoked", duration+delay)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_pucelle_anim", {})
			GameRules:SendCustomMessage("#la_pucelle_alert_1", 0, 0)
			caster.bIsLaPucelleActivatedThisRound = true
			caster.LaPucelleKiller = attacker

			ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_pucelle_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

			ability:StartCooldown(ability:GetCooldown(1))
			-- Set master's combo cooldown
			local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
			masterCombo:EndCooldown()
			masterCombo:StartCooldown(keys.ability:GetCooldown(1))

			caster:EmitSound("mirana_mir_attack_06")
			EmitGlobalSound("Hero_Phoenix.SuperNova.Explode")

			Timers:CreateTimer(delay, function()
				caster:EmitSound("Hero_Phoenix.SunRay.Loop")
				caster:EmitSound("Hero_DoomBringer.ScorchedEarthAura")
				caster:MoveToPositionAggressive(Vector(0,0,0))
				caster:SetModelScale(1.5)
				caster.JeanneOriginalScale = originalScale
			end)
		end
	end
end

-- spread fire
function OnLaPucelleThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	LeaveFireTrail(keys, caster:GetAbsOrigin() + Vector(RandomFloat(0, 400), RandomFloat(0, 400), 0), 2)
end

function OnLaPucelleDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetModelScale(caster.JeanneOriginalScale)
	caster:StopSound("Hero_DoomBringer.ScorchedEarthAura")
	caster:StopSound("Hero_Phoenix.SunRay.Loop")

	if _G.CurrentGameState == "FATE_ROUND_ONGOING" or _G.CurrentGameState == "FATE_PRE_GAME" then
		caster:Kill(ability, caster.LaPucelleKiller)
		if not IsTeamWiped(caster) then
			GameRules:SendCustomMessage("#la_pucelle_alert_2", 0, 0)
		end
	end
	-- announce message
end

function LeaveFireTrail(keys, location, duration)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.Damage

	local fireFx = ParticleManager:CreateParticle("particles/custom/ruler/la_pucelle/la_pucelle_flame.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(fireFx, 0, location)
	ParticleManager:SetParticleControl(fireFx, 1, Vector(duration,0,0))

	local counter = 0
	local period = 1.0
	Timers:CreateTimer(function()
		counter = counter + period
		if counter > duration then return end
		local targets = FindUnitsInRadius(caster:GetTeam(), location, nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
		for k,v in pairs(targets) do
			DoDamage(caster, v, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
		end
		return period
	end)
end

function OnIDAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	hero:SwapAbilities("jeanne_saint", "jeanne_identity_discernment", true, true) 
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnSaintImproved(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	hero.IsSaintImproved = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPunishmentAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	hero.IsPunishmentAcquired = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDivineSymbolAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	hero.IsDivineSymbolAcquired = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end




function template(keys)
	local caster = keys.caster
	local ability = keys.ability
end



			--[[local spirit = CreateUnitByName("jeanne_spirit_form", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber()) 
			spirit:SetOwner(caster)
			spirit:SetControllableByPlayer(pid, true)
			spirit:FindAbilityByName("jeanne_gods_resolution"):SetLevel(caster:FindAbilityByName("jeanne_gods_resolution"):GetLevel())]]

			-- clone based method
			--[[local illusion = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber()) 

			illusion:SetPlayerID(pid) 
			illusion:SetOwner(caster)
			illusion:SetControllableByPlayer(pid, true) 
			illusion:SetBaseStrength(caster:GetStrength())
			illusion:SetBaseAgility(caster:GetAgility())
			illusion:SetBaseIntellect(caster:GetIntellect())
			illusion:SetAbilityPoints(0)


			illusion:AddAbility("jeanne_gods_resolution")
			illusion:FindAbilityByName("jeanne_gods_resolution"):SetLevel(caster:FindAbilityByName("jeanne_gods_resolution"):GetLevel())
			illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration})
			illusion:MakeIllusion()
			illusion.STRgained = caster.STRgained
			illusion.AGIgained = caster.AGIgained
			illusion.INTgained = caster.INTgained
			illusion.DMGgained = caster.DMGgained
			illusion.ARMORgained = caster.ARMORgained
			illusion.HPREGgained = caster.HPREGgained
			--Attributes:ModifyIllusionAttackSpeed(illusion, caster)
			ability:ApplyDataDrivenModifier(caster, illusion, "modifier_la_pucelle_spirit_form", {})
			FindClearSpaceForUnit( illusion, illusion:GetAbsOrigin(), true )
			ExecuteOrderFromTable({
				UnitIndex = illusion:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = illusion:GetAbsOrigin()
			})
			Timers:CreateTimer(0.1, function()
				ability:ApplyDataDrivenModifier(caster, illusion, "modifier_la_pucelle_spirit_form", {})
			end)
			
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_la_pucelle_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
			ability:StartCooldown(ability:GetCooldown(1))
			-- Set master's combo cooldown
			local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
			masterCombo:EndCooldown()
			masterCombo:StartCooldown(keys.ability:GetCooldown(1))]]