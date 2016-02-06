
function OnMREXDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
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
        	end

        	ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_saint_debuff", {})
        	playerHero:EmitSound("Hero_Chen.TestOfFaith.Cast")
        end
    end)
end

function OnIDPing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = keys.Duration
	GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. heroName .. "</font> has been summoned. Check your Master in the bottom right of the map.", 0, 0)
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
end

function OnPurgeStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local radius = keys.Radius
	local delay = keys.Delay
	local damage = keys.Damage
	local damagePerKill = keys.DamagePerKill
	local silenceDuration = keys.SilenceDuration

	local markFx = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_penitence.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( markFx, 0, targetPoint)
	EmitSoundOnLocationWithCaster(targetPoint, "Hero_Chen.PenitenceImpact", caster)	

	Timers:CreateTimer(delay, function()
		local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			local targetDamage = damage
			if v:HasModifier("modifier_saint_debuff") and  (v:GetDeaths() - v:GetKills()) < 0 then
				DoDamage(caster, v, damagePerKill * (v:GetDeaths() - v:GetKills()), DAMAGE_TYPE_PURE, 0, ability, false)
			end
	        DoDamage(caster, v, targetDamage, DAMAGE_TYPE_MAGICAL, 0, ability, false)
	        giveUnitDataDrivenModifier(caster, v, "silenced", silenceDuration)
	    end

	    EmitSoundOnLocationWithCaster(targetPoint, "Hero_Chen.TestOfFaith.Target", caster)		
		local purgeFx = ParticleManager:CreateParticle("particles/custom/jeanne/jeanne_purge_the_unjust.vpcf", PATTACH_CUSTOMORIGIN, nil)
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
	        ability:ApplyDataDrivenModifier(caster, v, "modifier_gods_resolution_slow", {})

	    end

		local purgeFx = ParticleManager:CreateParticle("particles/custom/jeanne/jeanne_purge_the_unjust.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( purgeFx, 0, caster:GetAbsOrigin())

		return tickPeriod
	end)
end

function OnLEStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	-- create linear projectile

	-- create flag unit at where it lands(must check for untraversable destination and choose closest traversable tile)
end

function OnLEHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	-- apply CC
end


function template(keys)
	local caster = keys.caster
	local ability = keys.ability
end