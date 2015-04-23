IWActive = false

function OnGKStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	FACheckCombo(keys.caster, keys.ability)
	if ply.IsQuickdrawAcquired then 
		caster:SwapAbilities("false_assassin_gate_keeper", "false_assassin_quickdraw", true, true) 
		Timers:CreateTimer(5, function() return caster:SwapAbilities("false_assassin_gate_keeper", "false_assassin_quickdraw", true, true)   end)
	end

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
	-- set global cooldown
	caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
	caster:FindAbilityByName("false_assassin_windblade"):StartCooldown(keys.GCD) 
	caster:FindAbilityByName("false_assassin_tsubame_gaeshi"):StartCooldown(keys.GCD) 
end

function OnHeartLevelUp(keys)
	local caster = keys.caster
	caster.ArmorPen = keys.ArmorPen
end

function OnHeartAttackLanded(keys)
	PrintTable(keys)
	local caster = keys.caster
	-- Process armor pen
	local target = keys.target
	local multiplier = GetPhysicalDamageReduction(target:GetPhysicalArmorValue()) * caster.ArmorPen / 100
	DoDamage(caster, target, caster:GetAttackDamage() * multiplier , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	print("dealt " .. caster:GetAttackDamage() * multiplier .. " bonus damage")

end

function OnHeartDamageTaken(keys)
	-- process counter
	local caster = keys.caster
	local target = keys.attacker
	local damageTaken = keys.DamageTaken
	if damageTaken > keys.Threshold and caster:GetHealth() ~= 0 then

		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
		local multiplier = GetPhysicalDamageReduction(target:GetPhysicalArmorValue()) * caster.ArmorPen / 100
		local damage = caster:GetAttackDamage() * keys.Damage/100
		DoDamage(caster, target, damage + damage*multiplier , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)


		ReduceCooldown(caster:FindAbilityByName("false_assassin_gate_keeper"), 15)
		ReduceCooldown(caster:FindAbilityByName("false_assassin_windblade"), 15)
		ReduceCooldown(caster:FindAbilityByName("false_assassin_tsubame_gaeshi"), 15)

		target:EmitSound("FA.Omigoto")
		EmitGlobalSound("FA.Quickdraw")
		CreateSlashFx(caster, target:GetAbsOrigin()+Vector(300, 300, 0), target:GetAbsOrigin()+Vector(-300,-300,0))
		caster:RemoveModifierByName("modifier_heart_of_harmony")
	end
end


function OnHeartAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local damage = keys.Damage
	--damage = damage * (target:GetPhysicalArmorValue() + targetSTR) / 100
	--DoDamage(keys.caster, keys.target, damage, DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)

end

function OnPCDeactivate(keys)
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_fa_invis")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_quickdraw_damage_amplifier", {}) 
end

function PCStopOrder(keys)
	--keys.caster:Stop() 
	local stopOrder = {
		UnitIndex = keys.caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
	ExecuteOrderFromTable(stopOrder) 
end

function OnTMLanded(keys)
	local caster = keys.caster
	local target = keys.target

	local tgabil = caster:FindAbilityByName("false_assassin_tsubame_gaeshi")
	keys.Damage = tgabil:GetLevelSpecialValueFor("damage", tgabil:GetLevel()-1)
	keys.LastDamage = tgabil:GetLevelSpecialValueFor("lasthit_damage", tgabil:GetLevel()-1)
	keys.StunDuration = tgabil:GetLevelSpecialValueFor("stun_duration", tgabil:GetLevel()-1)
	keys.GCD = 0

	local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
	caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
	ApplyAirborne(caster, target, 1.5)
	print("Starting Tsubame Mai")
	caster:RemoveModifierByName("modifier_tsubame_mai")
	giveUnitDataDrivenModifier(keys.caster, keys.caster, "jump_pause", 1.5)
	--keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai_anim", {})
	EmitGlobalSound("FA.Kiero")
	EmitGlobalSound("FA.Quickdraw")
	CreateSlashFx(caster, target:GetAbsOrigin()+Vector(300, 300, 0), target:GetAbsOrigin()+Vector(-300,-300,0))

	Timers:CreateTimer(0.7, function()
		if caster:IsAlive() then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai_tg_cast_anim", {})
			EmitGlobalSound("FA.TGReady")
		end
	end)
	Timers:CreateTimer(1.5, function()
		if caster:IsAlive() then
			--keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_tsubame_mai_finish_anim", {})
			OnTGStart(keys)
		end
	end)
end

function OnTMDamageTaken(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local damageTaken = keys.DamageTaken

	-- if caster is alive and damage is above threshold, do something
	if damageTaken > keys.Threshold and caster:GetHealth() ~= 0 then
		print("Starting Tsubame Mai")
		local tgabil = caster:FindAbilityByName("false_assassin_tsubame_gaeshi")
		keys.Damage = tgabil:GetLevelSpecialValueFor("damage", tgabil:GetLevel()-1)
		keys.LastDamage = tgabil:GetLevelSpecialValueFor("lasthit_damage", tgabil:GetLevel()-1)
		keys.StunDuration = tgabil:GetLevelSpecialValueFor("stun_duration", tgabil:GetLevel()-1)
		keys.GCD = 0
		keys.target = attacker
		local target = attacker

		local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
		caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
		ApplyAirborne(caster, target, 2.0)
		giveUnitDataDrivenModifier(keys.caster, keys.caster, "jump_pause", 2.8)
		caster:RemoveModifierByName("modifier_tsubame_mai")
		EmitGlobalSound("FA.Owarida")
		EmitGlobalSound("FA.Quickdraw")
		CreateSlashFx(caster, target:GetAbsOrigin()+Vector(300, 300, 0), target:GetAbsOrigin()+Vector(-300,-300,0))

		local slashCounter = 0
		Timers:CreateTimer(0.6, function()
			if slashCounter == 7 or not caster:IsAlive() then return end
			local multiplier = GetPhysicalDamageReduction(target:GetPhysicalArmorValue()) * caster.ArmorPen / 100
			local damage = target:GetMaxHealth() * 5/100 + caster:GetAttackDamage()
			DoDamage(caster, target, damage + damage*multiplier , DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
			CreateSlashFx(caster, target:GetAbsOrigin()+RandomVector(400), target:GetAbsOrigin()+RandomVector(400))
			caster:SetAbsOrigin(target:GetAbsOrigin()+RandomVector(400))
			EmitGlobalSound("FA.Quickdraw") 

			slashCounter = slashCounter + 1
			return 0.2-slashCounter*0.02
		end)

		Timers:CreateTimer(2.0, function()
			if caster:IsAlive() then
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
				OnTGStart(keys)
			end
		end)
		
	end
end

function CreateSlashFx(source, backpoint, frontpoint)
	local slash1ParticleIndex = ParticleManager:CreateParticle( "particles/custom/archer/archer_overedge_slash.vpcf", PATTACH_CUSTOMORIGIN, source )
	ParticleManager:SetParticleControl( slash1ParticleIndex, 2, backpoint )
	ParticleManager:SetParticleControl( slash1ParticleIndex, 3, frontpoint )
end
function OnFADeath(keys)
	local caster = keys.caster
	for i=1, #caster.IllusionTable do
		if IsValidEntity(caster.IllusionTable[i]) then
			caster.IllusionTable[i]:ForceKill(true)
		end
	end

end

function OnIWStart(keys)
	local caster = keys.caster

	if not caster:IsHero() then
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Cast With Unit" } )
		ability:EndCooldown()
		return
	end
	local pid = caster:GetPlayerID()
	local ability = keys.ability
	local origin = caster:GetAbsOrigin() + RandomVector(100) 

	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	caster:FindAbilityByName("false_assassin_heart_of_harmony"):StartCooldown(17)

	
	-- Create delay to unable enemy to detect which is caster
	Timers:CreateTimer( 0.1, function()
			local swordFx = ParticleManager:CreateParticle( "particles/custom/false_assassin/fa_illusory_wanderer_sword_glow.vpcf", PATTACH_POINT_FOLLOW, caster )
			ParticleManager:SetParticleControlEnt( swordFx, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword", caster:GetAbsOrigin(), true )
			caster.illusory_wanderer_particle_index = swordFx
		end
	)
	
	-- For illusion location
	local maximum_illusion = ability:GetLevelSpecialValueFor( "maximum_illusion", ability:GetLevel() - 1 )
	local illusion_spawn_distance = ability:GetLevelSpecialValueFor( "illusion_spawn_distance", ability:GetLevel() - 1 )
	local destination = caster:GetAbsOrigin() + caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local increment_factor = 360 / maximum_illusion
	
	caster.IllusionTable = {}
	for ilu = 0, maximum_illusion - 1 do
		local illusion = CreateUnitByName(caster:GetUnitName(), origin, true, caster, nil, caster:GetTeamNumber()) 
		caster.IllusionTable[ilu+1] = illusion
		print(illusion:GetPlayerOwner())
		illusion:SetPlayerID(pid) 
		illusion:SetControllableByPlayer(pid, true) 

		for i=1,caster:GetLevel()-1 do
			illusion:HeroLevelUp(false) 
		end

		illusion:SetBaseStrength(caster:GetStrength())
		illusion:SetBaseAgility(caster:GetAgility())

		illusion:SetAbilityPoints(0)

		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = keys.Duration, outgoing_damage = 70, incoming_damage = 200 })
		ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_psuedo_omnislash", {})
		illusion:MakeIllusion()
		
		-- Set location for illusion
		local theta = ( ilu * increment_factor ) * math.pi / 180
		local px = math.cos( theta ) * ( destination.x - origin.x ) - math.sin( theta ) * ( destination.y - origin.y ) + origin.x
		local py = math.sin( theta ) * ( destination.x - origin.x ) + math.cos( theta ) * ( destination.y - origin.y ) + origin.y
		local new_forward = ( Vector( px, py, origin.z ) - origin ):Normalized()
		FindClearSpaceForUnit( illusion, origin + new_forward * illusion_spawn_distance, true )
		
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
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
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
	local quickdraw = 
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
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 1500
	}
	local projectile = ProjectileManager:CreateLinearProjectile(quickdraw)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealenabled", 0.4)
	caster:EmitSound("Hero_PhantomLancer.Doppelwalk") 
	local sin = Physics:Unit(caster)
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*1500)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)

	Timers:CreateTimer("quickdraw_dash", {
		endTime = 0.5,
		callback = function()
		print("dash timer")
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		Timers:RemoveTimer("qickdraw_dash")
		unit:OnPreBounce(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		caster:RemoveModifierByName("pause_sealenabled")
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
	end)

end

function OnQuickdrawHit(keys)
	local damage = 700 + keys.caster:GetAgility() * 10
	if keys.caster:HasModifier("modifier_quickdraw_damage_amplifier") then damage = damage + 300 end
	DoDamage(keys.caster, keys.target, damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end


function OnWBStart(keys)
	EmitGlobalSound("FA.Windblade" )
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local radius = keys.Radius
	local casterInitOrigin = caster:GetAbsOrigin() 

	if not ply.IsGanryuAcquired then
		caster:FindAbilityByName("false_assassin_gate_keeper"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_heart_of_harmony"):StartCooldown(keys.GCD) 
		caster:FindAbilityByName("false_assassin_tsubame_gaeshi"):StartCooldown(keys.GCD) 
	end

	local targets = FindUnitsInRadius(caster:GetTeam(), casterInitOrigin, nil, radius
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	local risingwind = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	if ply.IsGanryuAcquired then
		Timers:CreateTimer(0.3, function()
			if targets[1] ~= nil then
				caster:SetAbsOrigin(targets[1]:GetAbsOrigin())
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			end
		return end)
	end

	for k,v in pairs(targets) do
		print(v:GetName())
		if v:GetName() == "npc_dota_hero_bounty_hunter" and v:GetPlayerOwner().IsPFWAcquired then 
			-- do nothing
		else
			giveUnitDataDrivenModifier(caster, v, "drag_pause", 0.5)
			DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			local pushback = Physics:Unit(v)
			v:PreventDI()
			v:SetPhysicsFriction(0)
			v:SetPhysicsVelocity((v:GetAbsOrigin() - casterInitOrigin):Normalized() * 300)
			v:SetNavCollisionType(PHYSICS_NAV_NOTHING)
			v:FollowNavMesh(false)
			Timers:CreateTimer(0.5, function()  
				print("kill it")
				v:PreventDI(false)
				v:SetPhysicsVelocity(Vector(0,0,0))
				v:OnPhysicsFrame(nil)
			return end)
		end
	end
end

function TGPlaySound(keys)
	local caster = keys.caster
	if caster:GetName() == "npc_dota_hero_juggernaut" then
		EmitGlobalSound("FA.TGReady")

	elseif caster:GetName() == "npc_dota_hero_sven" then
		EmitGlobalSound("Lancelot.Growl" )
	end
end

function OnTGStart(keys)
	local caster = keys.caster
	local target = keys.target
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
			return
		end)
	end


	caster:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.0)


	Timers:CreateTimer(0.5, function()  
		if caster:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local tsu = ParticleManager:CreateParticle( "particles/custom/false_assassin/fa_tsubame_gaeshi_first_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			Timers:CreateTimer( 1.0, function()
					ParticleManager:DestroyParticle( tsu, true )
					ParticleManager:ReleaseParticleIndex( tsu )
					return nil
				end
			)
		end
	return end)

	Timers:CreateTimer(0.7, function()  
		if caster:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local tsu = ParticleManager:CreateParticle( "particles/custom/false_assassin/fa_tsubame_gaeshi_second_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			Timers:CreateTimer( 1.0, function()
					ParticleManager:DestroyParticle( tsu, true )
					ParticleManager:ReleaseParticleIndex( tsu )
					return nil
				end
			)
		end
	return end)

	Timers:CreateTimer(0.9, function()  
		if caster:IsAlive() then
			local diff = (target:GetAbsOrigin() - caster:GetAbsOrigin() ):Normalized() 
			caster:SetAbsOrigin(target:GetAbsOrigin() - diff*100) 
			if IsSpellBlocked(keys.target) then return end -- Linken effect checker
			DoDamage(caster, target, keys.LastDamage, DAMAGE_TYPE_PURE, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, keys.ability, false)
			target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.5})
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			local tsu = ParticleManager:CreateParticle( "particles/custom/false_assassin/fa_tsubame_gaeshi_third_slash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			Timers:CreateTimer( 1.0, function()
					ParticleManager:DestroyParticle( tsu, true )
					ParticleManager:ReleaseParticleIndex( tsu )
					return nil
				end
			)
		end
	return end)

end


function FACheckCombo(caster, ability)
	if caster:GetStrength() >= 25 and caster:GetAgility() >= 25 then
		if ability == caster:FindAbilityByName("false_assassin_gate_keeper") and caster:FindAbilityByName("false_assassin_heart_of_harmony"):IsCooldownReady() and caster:FindAbilityByName("false_assassin_tsubame_mai"):IsCooldownReady() then
			caster:SwapAbilities("false_assassin_heart_of_harmony", "false_assassin_tsubame_mai", true, true) 
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
	ply.IsGanryuAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnEyeOfSerenityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsEyeOfSerenityAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnQuickdrawAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsQuickdrawAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnVitrificationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsVitrificationAcquired = true
	hero:FindAbilityByName("false_assassin_presence_concealment"):SetLevel(1) 
	hero:SwapAbilities("fate_empty2", "false_assassin_presence_concealment", true, true) 

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end