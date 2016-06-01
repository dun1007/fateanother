function OnCasaThink(keys)
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_passive_mr", {})
	end
end

function OnCasaStart(keys)
	local caster = keys.caster
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_casa_active_mr", {})
end

function OnVanishStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local info = {
		Target = target, -- chainTarget
		Source = caster, -- chainSource
		Ability = ability,
		EffectName = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1000
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

	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.5)

	Timers:CreateTimer(function()
		if counter > 4 then return end
		local forwardVec = RotatePosition(Vector(0,0,0), QAngle(0,RandomFloat(12, -12),0), caster:GetForwardVector())
		local spearProjectile = 
		{
			Ability = ability,
	        EffectName = "particles/custom/false_assassin/fa_quickdraw.vpcf",
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
	ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow", {})
	giveUnitDataDrivenModifier(caster, target, "locked", lockDuration)
end

function OnDownSlowTier1End(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow_2", {})
end

function OnDownSlowTier2End(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "modifier_down_with_a_touch_slow_3", {})
end

function OnHornStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster.currentHornManaCost = ability:GetManaCost(ability:GetLevel())


    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
        	-- apply legion horn + silencer vsnd on their client
        else
        	-- apply legion horn vsnd on their client
        end
    end)



end

function OnHornThink(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.currentHornManaCost = caster.currentHornManaCOst + ability:GetManaCost(ability:GetLevel())
	if caster.currentHornManaCost > caster:GetMana() then 
		caster:Stop() -- stop channeling
	end

    local slowTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, slowRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(slowTargets) do
		-- apply slow
    end

    local damageTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, damageRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(damageTargets) do
		-- apply damageend
    

    local silenceTargets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, silenceRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(silenceTargets) do
		-- apply silence
    end
end

function OnHornInterrupted(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveModifierByName("modifier_la_black_luna")

	-- loop through players
		-- stop sound on client
end


function OnRaidStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local firstDmgPct = keys.FirstDamagePct
	local radius = keys.Radius
	local stunDuration = keys.StunDuration
	local secondDmg = keys.SecondDamage

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
