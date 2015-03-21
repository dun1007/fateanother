function OnLoveSpotStart(keys)
	local caster = keys.caster
	local lovespotCount = 0
	local forcemove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION ,
		Position = nil
	}
	caster:EmitSound("Hero_Warlock.ShadowWord")

	Timers:CreateTimer(function()
		if lovespotCount == keys.Duration then caster:StopSound("Hero_Warlock.ShadowWord") return end
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		for k,v in pairs(targets) do
			print(IsFemaleServant(v))
			if IsFemaleServant(v) then
				forcemove.UnitIndex = v:entindex()
				forcemove.Position = caster:GetAbsOrigin() 
				ExecuteOrderFromTable(forcemove) 
				giveUnitDataDrivenModifier(caster, v, "pause_sealenabled", 0.5)
			    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
			    ParticleManager:SetParticleControl(particle, 0, v:GetAbsOrigin())
			end
		end
	    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
		lovespotCount = lovespotCount + 1
		return 1.0
	end)
	

end

function OnChargeStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

	if caster:HasModifier("modifier_double_spearsmanship") then keys.Damage = keys.Damage * 2 end
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetOrigin(), nil, keys.Radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
         keys.target:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.5})
    end

    --particle
    caster:EmitSound("Hero_Huskar.Life_Break")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
    ParticleManager:SetParticleControl(particle, 3, keys.target:GetAbsOrigin())
end

function OnRampantWarriorStart(keys)
end

function OnGaeCastStart(keys)
	local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin()) -- target effect location
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()) -- circle effect location
	if keys.ability == caster:FindAbilityByName("diarmuid_gae_buidhe") then
		caster:EmitSound("ZL.Buidhe_Cast")
	elseif keys.ability == caster:FindAbilityByName("diarmuid_gae_dearg") then 
		caster:EmitSound("ZL.Dearg_Cast")
	end
end

function OnBuidheStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
		
	local MR = 0
	if target:IsHero() then MR = target:GetMagicalArmorValue() end
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	local targetHealthPercentage = target:GetHealth() / target:GetMaxHealth()

	local currentStack = target:GetModifierStackCount("modifier_gae_buidhe", keys.ability)
	if currentStack == 0 and target:HasModifier("modifier_gae_buidhe") then currentStack = 1 end
	target:RemoveModifierByName("modifier_gae_buidhe") 
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_gae_buidhe", {}) 
	target:SetModifierStackCount("modifier_gae_buidhe", keys.ability, currentStack + 1)
	if target:IsRealHero() then target:CalculateStatBonus() end

	local targetNewHealth = target:GetHealth() + keys.Damage * (1-MR) * targetHealthPercentage 
    print(targetNewHealth)
    target:SetHealth(targetNewHealth)

	EmitGlobalSound("ZL.Gae_Buidhe")
	target:EmitSound("Hero_Lion.Impale")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_diarmuid_gae_buidhe_anim", {})
	PlayGaeEffect(target)
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
end

function OnDeargStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	ApplyStrongDispel(target)

	local damage = 0
	local maxDamageDist = 100
	local minDamageDist = 650
	local distDiff = minDamageDist - maxDamageDist
	local damageDiff = keys.MaxDamage - keys.MinDamage
	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() 
	if distance <= maxDamageDist then 
		damage = keys.MaxDamage
	elseif maxDamageDist < distance and distance < minDamageDist then
		damage = keys.MinDamage + damageDiff * (minDamageDist - distance) / distDiff
	elseif minDamageDist <= distance then
		damage = keys.MinDamage
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)


	EmitGlobalSound("ZL.Gae_Dearg")
	target:EmitSound("Hero_Lion.Impale")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_diarmuid_gae_dearg_anim", {})
	PlayGaeEffect(target)
	-- Add dagon particle
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 600
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
end

function PlayGaeEffect(target)
	local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)
end 

function OnLoveSpotImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsLoveSpotImproved = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMindEyeAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsMindEyeAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnRosebloomAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsRoseBloonAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDoubleSpearAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    ply.IsDoubleSpearAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end