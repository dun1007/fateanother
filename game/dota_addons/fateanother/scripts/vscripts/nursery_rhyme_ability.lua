function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]
	local duration = keys.Duration
	local pid = caster:GetPlayerID()

	-- create illusion
	local illusion = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber()) 
	illusion:SetPlayerID(pid) 
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = 0, incoming_damage = 300 })
	illusion:MakeIllusion()
	illusion:AddNewModifier(caster, nil, "modifier_phased", {duration = duration})
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_nursery_rhyme_shapeshift_clone", {})
	caster:AddNewModifier(caster, nil, "modifier_phased", {duration = duration})
	caster.ShapeShiftIllusion = illusion
	caster.bIsSwapUsed = false 
	caster.ShapeShiftDest = targetPoint
	caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", false, true)
	
	caster:EmitSound("Hero_Terrorblade.ConjureImage")
	-- enable sub-ability that swaps position 
end

-- check if there is a valid target around clone
function OnShapeShiftTargetLookout(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	local target = keys.target
	local targetPoint = keys.target_points[1]

	target:MoveToPosition(caster.ShapeShiftDest)
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	if targets[1] ~= nil and targets[1]:IsHero() then
		for k,v in pairs(targets) do
	        DoDamage(caster, v, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	        ability:ApplyDataDrivenModifier(caster, v, "modifier_nursery_rhyme_shapeshift_slow", {})
	    end
	    target:ForceKill(false)
	end
end

function OnShapeShiftEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	caster:RemoveModifierByName("modifier_phased")
    EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Terrorblade.Metamorphosis", target)
	local cloneKillFx = ParticleManager:CreateParticle( "particles/generic_gameplay/illusion_killed.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( cloneKillFx, 0, target:GetAbsOrigin()+Vector(0,0,100) )
	local explosionFx = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(explosionFx, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 1, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(explosionFx, 2, target:GetAbsOrigin())
    caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", true, false)
end

function OnShapeShiftSwap(keys)
	local caster = keys.caster
	local ability = keys.ability
	local casterPos = caster:GetAbsOrigin()
	if caster.bIsSwapUsed then return end

	caster:SetAbsOrigin(caster.ShapeShiftIllusion:GetAbsOrigin())
	caster.ShapeShiftIllusion:SetAbsOrigin(casterPos)
	caster.bIsSwapUsed = true
end


function OnNamelessStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if IsSpellBlocked(target) or target:IsMagicImmune() then return end -- Linken effect checker
	caster.NamelessTarget = target
	ApplyPurge(target)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_nameless_forest", {})
end

function OnNamelessDebuffStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:AddEffects(EF_NODRAW)
	target:EmitSound("Hero_Winter_Wyvern.ColdEmbrace")
end

function OnNamelessEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:RemoveEffects(EF_NODRAW)
	target:StopSound("Hero_Winter_Wyvern.ColdEmbrace")
end

function OnReminiscenceStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster.NamelessTarget:RemoveModifierByName("modifier_nameless_forest")
end

function OnEnigmaStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = keys.target_points[1]

	local enigmaProjectile = 
	{
		Ability = ability,
        EffectName = "particles/units/heroes/hero_tusk/tusk_ice_shards_projectile.vpcf",
        iMoveSpeed = 1500,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 900,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = true,
		vVelocity = caster:GetForwardVector() * 1500
	}	

	local projectile = ProjectileManager:CreateLinearProjectile(enigmaProjectile)
	caster:EmitSound("Hero_Tusk.IceShards.Projectile")
	--caster:EmitSound("Hero_Tusk.IceShards.Cast")
	Timers:CreateTimer(1.0, function()
		caster:StopSound("Hero_Tusk.IceShards.Projectile")
	end)
end

CCTable = {
	"silenced",
	"stunned",
	"revoked",
	"locked",
	"rooted",
	"disarmed"
}

function OnEnigmaHit(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local BaseStunDuration = keys.DefaultStunDuration
	local NumOfCC = keys.CCNum
	local damage = keys.Damage
	local tempCCTable = {
		"silenced",
		"stunned",
		"revoked",
		"locked",
		"rooted",
		"disarmed"
	}

	giveUnitDataDrivenModifier(caster, target, "stunned", BaseStunDuration)
	DoDamage(caster, target, target:GetHealth()*damage/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	for i=1, NumOfCC do
		local CCChoice = math.random(#tempCCTable)
		local CC = tempCCTable[CCChoice]
		--print("applying CC " .. CC)
		giveUnitDataDrivenModifier(caster, target, CC, keys[CC])
		table.remove(tempCCTable, CCChoice)
	end

	local iceFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff_model.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( iceFx, 0, target:GetAbsOrigin()+Vector(0,0,100) )
	Timers:CreateTimer(BaseStunDuration, function()
		ParticleManager:DestroyParticle( iceFx, false )
		ParticleManager:ReleaseParticleIndex( iceFx )
		return nil
	end)
	target:EmitSound("Hero_Tusk.IceShards")

end
--[[

function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end

function OnShapeShiftStart(keys)
	local caster = keys.caster
	local ability = keys.ability
end]]