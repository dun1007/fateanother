IWActive = false

function OnFACrit(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_minds_eye_crit_hit", {})
end

function OnMindsEyeAttacked(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ratio = keys.Ratio
	local revokedRatio = keys.RatioRevoked

	if IsRevoked(target) then
		DoDamage(caster, target, caster:GetAgility() * revokedRatio , DAMAGE_TYPE_PURE, 0, keys.ability, false)
	else
		DoDamage(caster, target, caster:GetAgility() * ratio , DAMAGE_TYPE_PURE, 0, keys.ability, false)
	end
end

function OnGKStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()
	FACheckCombo(keys.caster, keys.ability)
	if caster.IsQuickdrawAcquired then 
		caster:SwapAbilities("false_assassin_gate_keeper", "false_assassin_quickdraw", true, true) 
		Timers:CreateTimer(5, function() return caster:SwapAbilities("false_assassin_gate_keeper", "false_assassin_quickdraw", true, true)   end)
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gate_keeper_self_buff", {})

	local gkdummy = CreateUnitByName("sight_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	gkdummy:SetDayTimeVisionRange(1300)
	gkdummy:SetNightTimeVisionRange(1100)

	local gkdummypassive = gkdummy:FindAbilityByName("dummy_unit_passive")
	gkdummypassive:SetLevel(1)

	local eyeCounter = 0

	Timers:CreateTimer(function() 
		if eyeCounter > 5.0 then DummyEnd(gkdummy) return end
		gkdummy:SetAbsOrigin(caster:GetAbsOrigin()) 
		eyeCounter = eyeCounter + 0.2
		return 0.2
	end)

end

-- Create Gate keeper's particles
function GKParticleStart( keys )
	local caster = keys.caster
	if caster.fa_gate_keeper_particle ~= nil then
		return
	end
	
	caster.fa_gate_keeper_particle = ParticleManager:CreateParticle( "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( caster.fa_gate_keeper_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControl( caster.fa_gate_keeper_particle, 1, Vector( 100, 100, 100 ) )
end

-- Destroy Gate keeper's particles
function GKParticleDestroy( keys )
	local caster = keys.caster
	if caster.fa_gate_keeper_particle ~= nil then
		ParticleManager:DestroyParticle( caster.fa_gate_keeper_particle, false )
		ParticleManager:ReleaseParticleIndex( caster.fa_gate_keeper_particle )
		caster.fa_gate_keeper_particle = nil
	end
end

function OnHeartStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ply = caster:GetPlayerOwner()

	if caster.IsVitrificationAcquired then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_heart_of_harmony_invisible", {})
	else
		-- set global cooldown
		caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_windblade"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_tsubame_gaeshi"):StartCooldown(keys.GCD) 
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_heart_of_harmony", {})
	caster:EmitSound("Hero_Abaddon.AphoticShield.Cast")
end

function OnHeartLevelUp(keys)
	local caster = keys.caster
	--caster.ArmorPen = keys.ArmorPen
end

function OnHeartAttackLanded(keys)
	PrintTable(keys)
	local caster = keys.caster
	-- Process armor pen
	local target = keys.target
	--local multiplier = GetPhysicalDamageReduction(target:GetPhysicalArmorValue()) * caster.ArmorPen / 100
	--DoDamage(caster, target, caster:GetAttackDamage() * multiplier , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	

end

function OnHeartDamageTaken(keys)
	-- process counter
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local damageTaken = keys.DamageTaken
	if damageTaken > keys.Threshold and caster:GetHealth() ~= 0 and (caster:GetAbsOrigin()-target:GetAbsOrigin()):Length2D() < 3000 and not target:IsInvulnerable() then

		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
		--local multiplier = GetPhysicalDamageReduction(target:GetPhysicalArmorValue()) * caster.ArmorPen / 100
		--local damage = caster:GetAttackDamage() * keys.Damage/100
		--DoDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
		caster:RemoveModifierByName("modifier_heart_of_harmony")
		caster:RemoveModifierByName("modifier_heart_of_harmony_invisible")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_heart_of_harmony_movespeed_bonus", {})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_heart_of_harmony_resistance_linger", {})
		caster:AddNewModifier(caster, caster, "modifier_camera_follow", {duration = 1.0})
		-- cooldown
		ReduceCooldown(caster:FindAbilityByName("false_assassin_gate_keeper"), 15)
		ReduceCooldown(caster:FindAbilityByName("false_assassin_windblade"), 15)
		ReduceCooldown(caster:FindAbilityByName("false_assassin_tsubame_gaeshi"), 15)

		local counter = 0
		Timers:CreateTimer(function()
			if counter == keys.AttackCount then return end 
			caster:PerformAttack(target, true, true, true, true, false)
			CreateSlashFx(caster, target:GetAbsOrigin()+RandomVector(500), target:GetAbsOrigin()+RandomVector(500))
			counter = counter+1
			return 0.1
		end)

		local cleanseCounter = 0
		Timers:CreateTimer(function()
			if cleanseCounter >= 10 then return end
			HardCleanse(caster)
			cleanseCounter = cleanseCounter + 1
			return 0.05
		end)


		target:EmitSound("FA.Omigoto")
		EmitGlobalSound("FA.Quickdraw")
	end
	
end


function OnHeartAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	--damage = damage * (target:GetPhysicalArmorValue() + targetSTR) / 100
	--DoDamage(keys.caster, keys.target, damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)

end

function OnInvisibilityBroken(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_heart_of_harmony_invisible")
end

function OnPCDeactivate(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_fa_invis")
end

function PCStopOrder(keys)
	--keys.caster:Stop() 
	local stopOrder = {
		UnitIndex = keys.caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
end

function OnTMStart(keys)
	if not keys.caster:IsRealHero() then
		keys.ability:EndCooldown()
		return
	end
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai", {})
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})
	
end

function OnTMLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local tgabil = caster:FindAbilityByName("false_assassin_tsubame_gaeshi")
	keys.Damage = tgabil:GetLevelSpecialValueFor("damage", tgabil:GetLevel()-1)
	keys.LastDamage = tgabil:GetLevelSpecialValueFor("lasthit_damage", tgabil:GetLevel()-1)
	keys.StunDuration = tgabil:GetLevelSpecialValueFor("stun_duration", tgabil:GetLevel()-1)
	keys.GCD = 0

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100)
	caster:AddNewModifier(caster, caster, "modifier_camera_follow", {duration = 1.0}) 
	ApplyAirborne(caster, target, 2.0)
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "jump_pause", 2.8)
	caster:RemoveModifierByName("modifier_tsubame_mai")
	EmitGlobalSound("FA.Owarida")
	EmitGlobalSound("FA.Quickdraw")
	CreateSlashFx(caster, target:GetAbsOrigin()+Vector(300, 300, 0), target:GetAbsOrigin()+Vector(-300,-300,0))

	local slashCounter = 0
	Timers:CreateTimer(0.8, function()
		if slashCounter == 0 then caster:SetModel("models/development/invisiblebox.vmdl") ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai_baseattack_reduction", {}) end
		if slashCounter == 5 or not caster:IsAlive() then caster:SetModel("models/assassin/asn.vmdl") return end
		caster:PerformAttack(target, true, true, true, true, false)
		CreateSlashFx(caster, target:GetAbsOrigin()+RandomVector(400), target:GetAbsOrigin()+RandomVector(400))
		caster:SetAbsOrigin(target:GetAbsOrigin()+RandomVector(400))
		EmitGlobalSound("FA.Quickdraw") 

		slashCounter = slashCounter + 1
		return 0.2-slashCounter*0.03
	end)

	Timers:CreateTimer(2.0, function()
		if caster:IsAlive() then
			caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,target:GetAbsOrigin().z))
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai_tg_cast_anim", {})
			EmitGlobalSound("FA.TGReady")
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_STOP,
				Queue = false
			})
			caster:SetForwardVector((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()) 
		end
	end)

	Timers:CreateTimer(2.8, function()
		if caster:IsAlive() then
			keys.IsCounter = true
			OnTGStart(keys)
		end
	end)
end

function OnTMDamageTaken(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damageTaken = keys.DamageTaken

	-- if caster is alive and damage is above threshold, do something
	if damageTaken > keys.Threshold and caster:GetHealth() ~= 0 and (caster:GetAbsOrigin()-attacker:GetAbsOrigin()):Length2D() < 3000 and not attacker:IsInvulnerable() then
		keys.target = keys.attacker
		OnTMLanded(keys)
	end
end

function OnFADeath(keys)
	local caster = keys.caster
	--[[if caster:IsRealHero() then
		if caster.IllusionTable ~= nil then
			for i=1, #caster.IllusionTable do
				if IsValidEntity(caster.IllusionTable[i]) then
					caster.IllusionTable[i]:ForceKill(true)
				end
			end
			caster.IllusionTable = nil
		end
	end]]
end

function SpawnFAIllusion(keys, amount)
	local caster = keys.caster
	if not caster:IsAlive() then return end

	--[[if not caster:IsHero() then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Cast With Unit" } )
		ability:EndCooldown()
		return
	end]]
	local pid = caster:GetPlayerID()
	local ability = keys.ability
	local origin = caster:GetAbsOrigin() + RandomVector(100) 

	if caster.IllusionTable == nil then
		print("created new table")
		caster.IllusionTable = {}
	end
	for ilu = 0, amount - 1 do
		local illusion = CreateUnitByName(caster:GetUnitName(), origin, true, caster, nil, caster:GetTeamNumber()) 
		table.insert(caster.IllusionTable, illusion)
		--print(illusion:GetPlayerOwner())
		illusion:SetPlayerID(pid) 
		illusion:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
		illusion:SetControllableByPlayer(pid, true) 

		illusion:SetBaseStrength(caster:GetStrength())
		illusion:SetBaseAgility(caster:GetAgility())
		illusion:SetAbilityPoints(0)
		--[[
		illusion:SetBaseMaxHealth(caster:GetMaxHealth())
		illusion:SetBaseDamageMin(caster:GetBaseDamageMin())
		illusion:SetBaseDamageMax(caster:GetBaseDamageMax())
		illusion:SetBaseMoveSpeed(caster:GetBaseMoveSpeed())
		illusion:SetBaseAttackTime(1/caster:GetAttacksPerSecond())
		print(illusion:GetBaseAttackTime())]]
		illusion:AddAbility("false_assassin_illusion_passive")
		illusion:FindAbilityByName("false_assassin_illusion_passive"):SetLevel(1)
		illusion:FindAbilityByName("false_assassin_minds_eye"):SetLevel(caster:FindAbilityByName("false_assassin_minds_eye"):GetLevel())
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = 50, outgoing_damage = -35, incoming_damage = 300 })
		giveUnitDataDrivenModifier(caster, illusion, "invulnerable", 0.5)
		--ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_psuedo_omnislash", {})
		illusion:MakeIllusion()
		illusion.STRgained = caster.STRgained
		illusion.AGIgained = caster.AGIgained
		illusion.INTgained = caster.INTgained
		illusion.DMGgained = caster.DMGgained
		illusion.ARMORgained = caster.ARMORgained
		illusion.HPREGgained = caster.HPREGgained
		Attributes:ModifyIllusionAttackSpeed(illusion, caster)
		
		FindClearSpaceForUnit( illusion, origin, true )
		ExecuteOrderFromTable({
			UnitIndex = illusion:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = illusion:GetAbsOrigin()
		})
		
		-- Create delay for particle to be able to attach properly
		Timers:CreateTimer( 0.1, function()
				local swordFx = ParticleManager:CreateParticle( "particles/custom/false_assassin/fa_illusory_wanderer_sword_glow.vpcf", PATTACH_POINT_FOLLOW, illusion )
				ParticleManager:SetParticleControlEnt( swordFx, 0, illusion, PATTACH_POINT_FOLLOW, "attach_sword", illusion:GetAbsOrigin(), true )
				illusion.illusory_wanderer_particle_index = swordFx
			end
		)
	end
end

function TPOnAttack(keys)
	local caster = keys.caster
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local rand = RandomInt(1, #targets) 
	caster:SetAbsOrigin(targets[1]:GetAbsOrigin() + Vector(RandomFloat(-100, 100),RandomFloat(-100, 100),RandomFloat(-100, 100) ))		
	FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
end

-- Destroy effect particle
function OnIWDestroy( keys )
	if keys.caster.illusory_wanderer_particle_index ~= nil then
		ParticleManager:DestroyParticle( keys.caster.illusory_wanderer_particle_index, false )
		ParticleManager:ReleaseParticleIndex( keys.caster.illusory_wanderer_particle_index )
	end
end

function OnQuickdrawStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local qdProjectile = 
	{
		Ability = keys.ability,
        EffectName = "particles/custom/false_assassin/fa_quickdraw.vpcf",
        iMoveSpeed = 1500,
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = 750,
        fStartRadius = 150,
        fEndRadius = 150,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = true,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1500
	}

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_quickdraw_baseattack_reduction", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_quickdraw_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	local projectile = ProjectileManager:CreateLinearProjectile(qdProjectile)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.4)
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local sin = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*1500)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("quickdraw_dash", {
		endTime = 0.5,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("quickdraw_dash")
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)

end

function OnQuickdrawHit(keys)
	local caster = keys.caster
	local target = keys.target

	local damage = 500 + keys.caster:GetAgility() * 13
	DoDamage(keys.caster, keys.target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	caster:PerformAttack(target, true, true, true, true, false)

	local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(firstImpactIndex, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(800,0,150))
    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(0.3,0,0))
end


function OnWBStart(keys)
	EmitGlobalSound("FA.Windblade" )
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local ability = keys.ability
	local radius = keys.Radius
	local casterInitOrigin = caster:GetAbsOrigin() 

	-- make FA's damage zero 
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_wb_baseattack_reduction", {})

	if not caster.IsGanryuAcquired then
		caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_heart_of_harmony"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_tsubame_gaeshi"):StartCooldown(keys.GCD) 
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), casterInitOrigin, nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

	if caster.IsGanryuAcquired then
		Timers:CreateTimer(0.1, function()
			for i=1, #targets do
				if targets[i]:IsAlive() and targets[i]:GetName() ~= "npc_dota_ward_base" then
					--local diff = (caster:GetAbsOrigin() - targets[i]:GetAbsOrigin()):Normalized()
					caster:SetAbsOrigin(targets[i]:GetAbsOrigin() - targets[i]:GetForwardVector():Normalized()*100)
					FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
					break
				end
			end
		return end)
	end

	for k,v in pairs(targets) do
		if (v:GetName() == "npc_dota_hero_bounty_hunter" and v.IsPFWAcquired) or v:GetUnitName() == "ward_familiar" then 
			-- do nothing
		else
			giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
			DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			caster:PerformAttack(v, true, true, true, true, false)
			local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
		    ParticleManager:SetParticleControl(slashIndex, 0, v:GetAbsOrigin())
		    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
		    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
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
	end

	local risingWindFx = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	-- Destroy particle after delay
	Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( risingWindFx, false )
			ParticleManager:ReleaseParticleIndex( risingWindFx )
			return nil
	end)
end

function TGPlaySound(keys)
	local caster = keys.caster
	local target = keys.target
	if caster:GetName() == "npc_dota_hero_juggernaut" then
		EmitGlobalSound("FA.TGReady")

	elseif caster:GetName() == "npc_dota_hero_sven" then
		EmitGlobalSound("Lancelot.Growl" )
	end

	local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
	local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(firstImpactIndex, 0, caster:GetAbsOrigin() + diff/2)
    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(600,0,150))
    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(0.4,0,0))
	--[[local firstImpactIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator.vpcf", PATTACH_CUSTOMORIGIN, nil )
    ParticleManager:SetParticleControl(firstImpactIndex, 0, Vector(1,0,0))
    ParticleManager:SetParticleControl(firstImpactIndex, 1, Vector(300-50,0,0))
    ParticleManager:SetParticleControl(firstImpactIndex, 2, Vector(0.5,0,0))
    ParticleManager:SetParticleControl(firstImpactIndex, 3, keys.target:GetAbsOrigin())
    ParticleManager:SetParticleControl(firstImpactIndex, 4, Vector(0,0,0))]]
end

function OnTGStart(keys)
	local caster = keys.caster
	local casterName = caster:GetName()
	local target = keys.target
	local ability = keys.ability
	if IsSpellBlocked(keys.target) then return end -- Linken effect checker
	EmitGlobalSound("FA.Chop")

	-- Check if caster is FA or Lancelot
	if caster:GetName() == "npc_dota_hero_juggernaut" then
		EmitGlobalSound("FA.TG")
		caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_heart_of_harmony"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_windblade"):StartCooldown(keys.GCD) 
	elseif caster:GetName() == "npc_dota_hero_sven" then
		Timers:CreateTimer(0.15, function() 
			EmitGlobalSound("Lancelot.Roar2")
			StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK2, rate=2})
			Timers:CreateTimer(0.3, function()
				StartAnimation(caster, {duration=0.3, activity=ACT_DOTA_ATTACK, rate=2})
				Timers:CreateTimer(0.3, function()
					StartAnimation(caster, {duration=0.2, activity=ACT_DOTA_ATTACK2, rate=2})
				end)
			end)
			return
		end)
	end

	caster:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	giveUnitDataDrivenModifier(caster, caster, "dragged", 1.0)
	giveUnitDataDrivenModifier(caster, caster, "revoked", 1.0)
	if caster.IsGanryuAcquired then 
		Timers:CreateTimer(0.4, function()
			giveUnitDataDrivenModifier(caster, target, "silenced", 0.11)
		end)
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tg_baseattack_reduction", {})

	local particle = ParticleManager:CreateParticle("particles/custom/false_assassin/tsubame_gaeshi/slashes.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 

	Timers:CreateTimer(0.5, function()  
		if caster:IsAlive() and target:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			if caster.IsGanryuAcquired then 
				giveUnitDataDrivenModifier(caster, target, "silenced", 0.31)
				DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
				caster:PerformAttack(target, true, true, true, true, false)
				local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
				--[[local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for i=1, #targets do 
					DoDamage(caster, targets[i], keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
					caster:PerformAttack(targets[i], true, true, true, true, false)
					local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
				    ParticleManager:SetParticleControl(slashIndex, 0, targets[i]:GetAbsOrigin())
				    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
				    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
				end]]
			else
				DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
				caster:PerformAttack(target, true, true, true, true, false)
				local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
			end

			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		else
			ParticleManager:DestroyParticle(particle, true)
		end
	return end)

	Timers:CreateTimer(0.7, function()  
		if caster:IsAlive() and target:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			if caster.IsGanryuAcquired then 
				giveUnitDataDrivenModifier(caster, target, "silenced", 0.31)
				DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
				caster:PerformAttack(target, true, true, true, true, false)
				local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
				--[[local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				for i=1, #targets do 
					DoDamage(caster, targets[i], keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
					caster:PerformAttack(targets[i], true, true, true, true, false)
					local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
				    ParticleManager:SetParticleControl(slashIndex, 0, targets[i]:GetAbsOrigin())
				    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
				    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
				end]]
			else
				DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
				caster:PerformAttack(target, true, true, true, true, false)
				local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
			end
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		else
			ParticleManager:DestroyParticle(particle, true)
		end
	return end)

	Timers:CreateTimer(0.9, function()  
		if caster:IsAlive() and target:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			if IsSpellBlocked(keys.target) and target:GetName() == "npc_dota_hero_legion_commander" then return end -- if target has instinct up, block the last hit
			if caster.IsGanryuAcquired then
				local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
				DoDamage(caster, target, keys.LastDamage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
				caster:PerformAttack(target, true, true, true, true, false)
				target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.5})
				local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
				--[[for i=1, #targets do 
					DoDamage(caster, targets[i], keys.LastDamage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
					caster:PerformAttack(targets[i], true, true, true, true, false)
					targets[i]:AddNewModifier(caster, targets[i], "modifier_stunned", {Duration = 1.5})
					local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
				    ParticleManager:SetParticleControl(slashIndex, 0, targets[i]:GetAbsOrigin())
				    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
				    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
				end]]
			else
				DoDamage(caster, target, keys.LastDamage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
				caster:PerformAttack(target, true, true, true, true, false)
				target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.5})
				local slashIndex = ParticleManager:CreateParticle( "particles/custom/false_assassin/tsubame_gaeshi/tsubame_gaeshi_windup_indicator_flare.vpcf", PATTACH_CUSTOMORIGIN, nil )
			    ParticleManager:SetParticleControl(slashIndex, 0, target:GetAbsOrigin())
			    ParticleManager:SetParticleControl(slashIndex, 1, Vector(500,0,150))
			    ParticleManager:SetParticleControl(slashIndex, 2, Vector(0.2,0,0))
			end
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		else
			ParticleManager:DestroyParticle(particle, true)
		end

	return end)
end


function FACheckCombo(caster, ability)
	if caster:GetStrength() >= 24.1 and caster:GetAgility() >= 24.1 then
		if ability == caster:FindAbilityByName("false_assassin_gate_keeper") and caster:FindAbilityByName("false_assassin_heart_of_harmony"):IsCooldownReady() and caster:FindAbilityByName("false_assassin_tsubame_mai"):IsCooldownReady() then
			caster:SwapAbilities("false_assassin_heart_of_harmony", "false_assassin_tsubame_mai", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				caster:SwapAbilities("false_assassin_heart_of_harmony", "false_assassin_tsubame_mai", true, true) 
			end
			})			
		end
	end
end

function OnGanryuAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsGanryuAcquired = true
	print("Ganryu acquired")
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnEyeOfSerenityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsEyeOfSerenityAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnQuickdrawAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsQuickdrawAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnVitrificationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsVitrificationAcquired = true
	hero:FindAbilityByName("false_assassin_presence_concealment"):SetLevel(1) 
	hero:SwapAbilities("fate_empty1", "false_assassin_presence_concealment", true, true) 

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnMindsEyeImproved(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero.IsMindsEyeAcquired = true
	hero:FindAbilityByName("false_assassin_minds_eye"):SetLevel(2) 

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end