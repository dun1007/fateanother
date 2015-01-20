require("physics")
require("util")

--vortigernCount = 0
--isLeftside = nil

function OnDerangeStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsManaBlastAcquired then
		if caster.ManaBlastCount < 7 then
			local chance = RandomInt(1, 100) 
			if chance > 1 and chance < 34 then
				caster.ManaBlastCount = caster.ManaBlastCount + 1
			elseif chance > 34 and chance < 67 then
				caster.ManaBlastCount = caster.ManaBlastCount + 2
			elseif chance > 67 and chance < 100 then
				caster.ManaBlastCount = caster.ManaBlastCount + 3
			end
		end
	end
	DSCheckCombo(keys.caster, keys.ability)
end

function OnDarklightProc(keys)
	DoDamage(keys.caster, keys.target, 400 , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
end

function OnUFStart(keys)
	local caster = keys.caster
	local UFCount = 0
	DSCheckCombo(caster, keys.ability)
	Timers:CreateTimer(function()
		if UFCount == 5 then return end
		caster:EmitSound("Saber_Alter.Unleashed") 
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
	         DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	    end
		UFCount = UFCount + 1;
		return 0.5
		end
	)
end

function OnMBStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()


	if ply.IsManaShroudImproved == true then 
		keys.Radius = keys.Radius + 200 
		keys.Damage = keys.Damage + 100
	end
	caster:EmitSound("Saber_Alter.ManaBurst") 
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	
	local info = {
		Target = nil,
		Source = caster, 
		Ability = keys.ability,
		EffectName = "particles/items2_fx/skadi_projectile.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 400
	}
	
	if ply.IsManaBlastAcquired then
		while caster.ManaBlastCount ~= 0 do
			info.Target = targets[math.random(#targets)]
			ProjectileManager:CreateTrackingProjectile(info) 
			caster.ManaBlastCount = caster.ManaBlastCount - 1
		end
	end

	for k,v in pairs(targets) do
	    DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
end

function OnManaBlastHit(keys)
	DoDamage(keys.caster, keys.target, 150 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnMMBStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	EmitGlobalSound("Saber_Alter.MMB" ) 
	EmitGlobalSound("Saber_Alter.MMBAfter") 
	ParticleManager:CreateParticle("particles/custom/screen_blue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

	local dmg = caster:GetMaxMana()
	if ply.IsManaShroudImproved == true then dmg = dmg + 200 end
	
	for k,v in pairs(targets) do
	    DoDamage(caster, v, dmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability)
	end
end

--[[function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage
	local forward = caster:GetForwardVector() 
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.4)
	if ply.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end
	EmitGlobalSound("Saber_Alter.Vortigern")

	local vortigernCount = 0
	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
		iMoveSpeed = 3000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = 600,
		Source = caster,
		fStartRadius = 50,
        fEndRadius = 200,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0,
	}

	local casterAngle = QAngle(0,120,0)
	Timers:CreateTimer(function() 
			if vortigernCount == 10 then vortigernCount = 0 return end -- finish spell
			vortigernBeam.vVelocity = RotatePosition(caster:GetAbsOrigin(), casterAngle, forward * 10000) 
			local projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 24;
			print(casterAngle.y)
			vortigernCount = vortigernCount + 1; 
			
			return 0.040 
		end
	)
end

function OnVortigernHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	local damage = keys.Damage
	print("Vortigern hit")
	if ply.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end
	if target.IsVortigernHit ~= true then
		target.IsVortigernHit = true
		Timers:CreateTimer(0.36, function() target.IsVortigernHit = false return end)
		DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end

end]]

function OnVortigernStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local casterVec = caster:GetForwardVector()
	local targetVec = Vector(0,0,0)
	local damage = keys.Damage
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 0.4)
	if ply.IsFerocityImproved then 
		damage = damage + 100
		keys.StunDuration = keys.StunDuration + 0.3
	end

	local angle = 0
	EmitGlobalSound("Saber_Alter.Vortigern")

	local vortigerndmg = {
		attacker = caster,
		victim = nil,
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = 0,
		ability = ability
	}

	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
        targetVec = v:GetAbsOrigin() - caster:GetAbsOrigin() 
        degree = CalculateAngle(casterVec, targetVec)*180/math.pi -- degree from caster to target
        -- Starts at 120(85% damage), ends at -120(120% damage)
        if degree <= 120 and degree >= -120 then
        	local multiplier = 0.85 + (120 - degree)/(240/0.35)
        	DoDamage(caster, v, damage * multiplier , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
        	--print(degree .. " " .. multiplier)
        	v:AddNewModifier(caster, target, "modifier_stunned", {duration = keys.StunDuration})
        end
    end
end

function OnDexStart(keys)
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "pause_sealdisabled", 4.75)
	EmitGlobalSound("Saber.Caliburn")
	local dex = 
	{
		Ability = keys.ability,
        EffectName = "particles/custom/saber_alter/saber_alter_excalibur.vpcf",
        iMoveSpeed = keys.Speed,
        vSpawnOrigin = nil,
        fDistance = keys.Range,
        fStartRadius = keys.Width,
        fEndRadius = keys.Width,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
		bDeleteOnHit = false,
		vVelocity = frontward * keys.Speed
	}
	Timers:CreateTimer(0.75, function() 
		EmitGlobalSound("Saber_Alter.Excalibur")
	end)
	Timers:CreateTimer(2.75, function() 
		if caster:IsAlive() then
			EmitGlobalSound("Saber.Excalibur_Ready")
			dex.vSpawnOrigin = caster:GetAbsOrigin() 
			projectile = ProjectileManager:CreateLinearProjectile(dex)
			return 
		end
	end)
end

function OnDexHit(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	if ply.IsDarklightAcquired then keys.Damage = keys.Damage + 300 end
	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

	--[[
	local vortigernBeam =
	{
		Ability = keys.ability,
		EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
		iMoveSpeed = 10000,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = keys.Radius,
		Source = caster,
		fStartRadius = 10,
        fEndRadius = 50,
		bHasFrontialCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
		fExpireTime = GameRules:GetGameTime() + 0.4,
		bDeleteOnHit = false,
		vVelocity = 0.0,
	}

	local casterAngle = QAngle(0,120,0)
	EmitGlobalSound("Saber_Alter.Vortigern")
	Timers:CreateTimer(function() 
			vortigernBeam.vVelocity = RotatePosition(Vector(0,0,0), casterAngle, caster:GetForwardVector()) * 10000
			projectile = ProjectileManager:CreateLinearProjectile(vortigernBeam)
			casterAngle.y = casterAngle.y - 6.66;
			vortigernCount = vortigernCount + 1; 
			if vortigernCount == 36 then vortigernCount = 0 return end -- finish spell
			
			return .01 -- tick every 0.01
		end
	)
end]]

DUsed = false
DTime = GameRules:GetGameTime()
UFTime = 0
function DSCheckCombo(caster, ability)
	if ability == caster:FindAbilityByName("saber_alter_derange") then
		DUsed = true
		DTime = GameRules:GetGameTime()
		Timers:CreateTimer({
			endTime = 4,
			callback = function()
			DUsed = false
		end
		})
	elseif ability == caster:FindAbilityByName("saber_alter_unleashed_ferocity") then
		if DUsed == true then 
			caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", false, true)
			local newTime =  GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 4 - (newTime - DTime),
				callback = function()
				caster:SwapAbilities("saber_alter_mana_burst", "saber_alter_max_mana_burst", true, false)
				DUsed = false
			end
			})
		end
	end
end

function OnImproveManaShroundAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	print("mana shroud acquired" .. hero:GetPhysicalArmorBaseValue())
	hero:SetPhysicalArmorBaseValue(hero:GetPhysicalArmorBaseValue() + 20) 
	hero:SetBaseMagicalResistanceValue(25)
	hero:CalculateStatBonus()
	ply.IsManaShroudImproved = true
end

-- needs particle
function OnManaBlastAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsManaBlastAcquired = true
	hero.ManaBlastCount = 0
end

function OnImproveFerocityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsFerocityImproved = true
	hero:SwapAbilities("saber_alter_unleashed_ferocity","saber_alter_unleashed_ferocity_improved", false, true)
end

function OnDarklightAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("saber_alter_darklight_passive"):SetLevel(1)
	ply.IsDarklightAcquired = true

end