require("Physics")
require("util")

function OnFissureStart(keys)
	local caster = keys.caster
	local frontward = caster:GetForwardVector()
	local fiss = 
	{
		Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
        iMoveSpeed = 500,
        vSpawnOrigin = nil,
        fDistance = 500,
        fStartRadius = 250,
        fEndRadius = 250,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = frontward * 500
	}
	fiss.vSpawnOrigin = caster:GetAbsOrigin() 
	projectile = ProjectileManager:CreateLinearProjectile(fiss)
	BerCheckCombo(caster, keys.ability)

end

function OnFissureHit(keys)
	DoDamage(keys.caster, keys.target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnCourageStart(keys)

end

function OnRoarStart(keys)
	local caster = keys.caster
	giveUnitDataDrivenModifier(caster, caster, "rb_sealdisabled", 10.0)
	caster:FindAbilityByName("berserker_5th_courage"):StartCooldown(27)
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	-- Remove Berserk modifier and set health to max
	if caster:HasModifier("modifier_berserk_self_buff") then
		caster:RemoveModifierByName("modifier_berserk_self_buff")
	end
	caster:SetHealth(caster:GetMaxHealth())
	local casterloc = caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 3000
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local finaldmg = 0
	for k,v in pairs(targets) do
		local dist = (v:GetAbsOrigin() - casterloc):Length2D() 
		if dist <= 300 then
			finaldmg = keys.Damage1
			v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 3.0})
			giveUnitDataDrivenModifier(caster, v, "rb_sealdisabled", 3.0)
		elseif dist > 300 and dist <= 1000 then
			finaldmg = keys.Damage2
		elseif dist > 1000 and dist <= 2000 then
			finaldmg = keys.Damage3
		elseif dist > 2000 and dist <= 3000 then
			finaldmg = 0
		end

	    DoDamage(caster, v, finaldmg , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
	ParticleManager:CreateParticle("particles/custom/screen_face_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

end

function OnBerserkStart(keys)
	local caster = keys.caster
	local hplock = keys.Health
	local duration = keys.Duration
	local ply = caster:GetPlayerOwner()
	if ply.IsBerserkAcquired then duration = duration + 1 end

	local berserkCounter = 0
	BerCheckCombo(caster, keys.ability)
	EmitGlobalSound("Berserker.Roar") 

	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_berserk_self_buff") == false then return end
		if berserkCounter == duration then return end
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_symbol.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin() )
		caster:SetHealth(hplock)
		berserkCounter = berserkCounter + 0.01
		return 0.01
		end
	)


	if ply.IsBerserkAcquired then 
		local explosionCounter = 0
		local manaregenCounter = 0

		Timers:CreateTimer(function()
			if caster:HasModifier("modifier_berserk_self_buff") == false then return end
			if explosionCounter == duration then return end
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
		        DoDamage(caster, v, 150, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			end
			local berserkExp = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(berserkExp, 1, caster:GetAbsOrigin())

			explosionCounter = explosionCounter + 1.0
			return 1.0
			end
		)

		Timers:CreateTimer(function()
			if manaregenCounter > 2.0 then return end
			caster:SetMana(caster:GetMana() + 30) 

			manaregenCounter = manaregenCounter + 0.2
			return 0.2
		end)
	end
end

function OnBerserkProc(keys)
	local caster = keys.caster
	local targets = FindUnitsInRadius(caster:GetTeam(), keys.target, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
	for k,v in pairs(targets) do
        DoDamage(caster, v, 200, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	end
end

function OnNineStart(keys)
	local caster = keys.caster
	local targetPoint = keys.target_points[1]

	local berserker = Physics:Unit(caster)
	local origin = caster:GetAbsOrigin()
	local distance = (targetPoint - origin):Length2D()
	local forward = (targetPoint - origin):Normalized() * distance

	caster.NineLanded = false
	caster:SetPhysicsFriction(0)
	caster:SetPhysicsVelocity(caster:GetForwardVector()*distance)
	caster:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 4.0)

	Timers:CreateTimer("chariot_dash", {
		endTime = 1.0,
		callback = function()
		caster:OnPreBounce(nil)
		caster:SetBounceMultiplier(0)
		caster:PreventDI(false)
		caster:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		if caster:IsAlive() and not caster.NineLanded then
			caster:RemoveModifierByName("modifier_dash_anim")
			OnNineLanded(caster, keys.ability)
		end
	return end
	})

	caster:OnPreBounce(function(unit, normal) -- stop the pushback when unit hits wall
		unit:OnPreBounce(nil)
		unit:OnPhysicsFrame(nil)
		unit:SetBounceMultiplier(0)
		unit:PreventDI(false)
		unit:SetPhysicsVelocity(Vector(0,0,0))
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		if caster:IsAlive() and not caster.NineLanded then
			caster:RemoveModifierByName("modifier_dash_anim")
			OnNineLanded(caster, keys.ability)
		end
	end)

	


	--[[Timers:CreateTimer(function()
		if travelCounter == 33 then OnNineLanded(caster, keys.ability) return end
		caster:SetAbsOrigin(caster:GetAbsOrigin() + forward) 
		travelCounter = travelCounter + 1
		
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		return 0.03
		end
	)]]
end

-- add pause
function OnNineLanded(caster, ability)
	local tickdmg = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local lasthitdmg = ability:GetLevelSpecialValueFor("damage_lasthit", ability:GetLevel() - 1)
	local radius = ability:GetSpecialValueFor("radius")
	local lasthitradius = ability:GetSpecialValueFor("radius_lasthit")
	local stun = ability:GetSpecialValueFor("stun_duration")
	local nineCounter = 0
	local casterInitOrigin = caster:GetAbsOrigin() 
	caster.NineLanded = true

	if caster:GetName() == "npc_dota_hero_doom_bringer" then 
		Timers:CreateTimer(0.033, function()
			if caster:IsAlive() then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_nine_anim", {}) 
			end
		end)
	end
	Timers:CreateTimer(function()
		if caster:IsAlive() then -- only perform actions while caster stays alive

			if caster:GetName() == "npc_dota_hero_sven" then 
				if math.random(0,1) == 0 then 
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_nine_anim", {}) 
				else
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_nine_anim3", {}) 
				end
			end
			caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact") 
			if nineCounter == 8 then -- if nine is finished
				if caster:GetName() == "npc_dota_hero_doom_bringer" then
					EmitGlobalSound("Berserker.Roar")
				elseif caster:GetName() == "npc_dota_hero_sven" then
					EmitGlobalSound("Lancelot.Roar1" )
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_nine_anim2", {})
				end
				caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
				caster:RemoveModifierByName("pause_sealdisabled") 
				-- do damage to targets
				local lasthitTargets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, lasthitradius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 1, false)
				for k,v in pairs(lasthitTargets) do
					DoDamage(caster, v, lasthitdmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
					v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.0})
					giveUnitDataDrivenModifier(caster, v, "rb_sealdisabled", 1.0)
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
				-- add particles
				local lasthitparticle1 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_magma_low_egset.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	   			ParticleManager:SetParticleControl(lasthitparticle1, 1, caster:GetAbsOrigin())
	   			local lasthitparticle2 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_aftershock_warp_egset.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	   			ParticleManager:SetParticleControl(lasthitparticle2, 1, caster:GetAbsOrigin())
				return 
			end
			
			-- if its not last hit, do regular hit stuffs
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 1, false)
			for k,v in pairs(targets) do
				DoDamage(caster, v, tickdmg , DAMAGE_TYPE_MAGICAL, 0, ability, false)
				v:AddNewModifier(caster, v, "modifier_stunned", {Duration = 1.0})
				giveUnitDataDrivenModifier(caster, v, "rb_sealdisabled", 1.0)
			end

			local particle1 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_magma_cracks_egset.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle1, 1, caster:GetAbsOrigin())
			local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_f_fallback_low.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin())
			nineCounter = nineCounter + 1
			print(nineCounter)
			return 0.3
		end 
	end)
end


QUsed = false
QTime = 0

function BerCheckCombo(caster, ability)
	if caster:GetStrength() >= 20 and caster:GetAgility() >= 20 and caster:GetIntellect() >= 20 then
		if ability == caster:FindAbilityByName("berserker_5th_fissure_strike") then
			QUsed = true
			QTime = GameRules:GetGameTime()
			Timers:CreateTimer({
				endTime = 4,
				callback = function()
				QUsed = false
			end
			})
		elseif ability == caster:FindAbilityByName("berserker_5th_berserk") and caster:FindAbilityByName("berserker_5th_courage"):IsCooldownReady() and caster:FindAbilityByName("berserker_5th_madmans_roar"):IsCooldownReady()  then
			if QUsed == true then 
				caster:SwapAbilities("berserker_5th_madmans_roar", "berserker_5th_courage", true, true) 
				local newTime =  GameRules:GetGameTime()
				Timers:CreateTimer({
					endTime = 4 - (newTime - QTime),
					callback = function()
					caster:SwapAbilities("berserker_5th_madmans_roar", "berserker_5th_courage", true, true) 
					QUsed = false
				end
				})
			end
		end
	end
end

-- Check if anyone on this hero's team is still alive. 
function IsTeamWiped(hero)
	for i=0, 9 do
		local player = PlayerResource:GetPlayer(i)
		if player ~= nil then 
			servant = PlayerResource:GetPlayer(i):GetAssignedHero()
			if servant:GetTeam() == hero:GetTeam() and servant:IsAlive() then 
				return false
			end
		end
	end
	return true
end

function OnGodHandDeath(keys)
	local caster = keys.caster
	local newRespawnPos = caster:GetOrigin()
	local ply = caster:GetPlayerOwner()

	local dummy = CreateUnitByName("dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	dummy:FindAbilityByName("dummy_unit_passive"):SetLevel(1) 
	dummy:AddNewModifier(caster, nil, "modifier_phased", {duration=1.0})
	dummy:AddNewModifier(caster, nil, "modifier_kill", {duration=1.1})

	print("God Hand activated")
	Timers:CreateTimer({
		endTime = 1,
		callback = function()

		if IsTeamWiped(caster) == false and ply.GodHandStock > 0 then
			EmitGlobalSound("Berserker.Roar") 
			local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ply.GodHandStock = ply.GodHandStock - 1
			GameRules:SendCustomMessage("<font color='#FF0000'>----------!!!!!</font> Remaining God Hand stock : " .. ply.GodHandStock , 0, 0)
			caster:SetRespawnPosition(dummy:GetAbsOrigin())
			caster:RespawnHero(false,false,false)
			caster:RemoveModifierByName("modifier_god_hand_stock") 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_god_hand_stock", {}) 
			caster:SetModifierStackCount("modifier_god_hand_stock", caster, ply.GodHandStock)

			if ply.IsReincarnationAcquired then 
				local resExp = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(particle, 3, caster:GetAbsOrigin())
				local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				for k,v in pairs(targets) do
			        DoDamage(caster, v, caster:GetMaxHealth() * 3/10, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				end	
			end
		else
			caster:SetRespawnPosition(caster.RespawnPos)
		end
		--caster:SetRespawnPosition(Vector(7000, 2000, 320)) need to set the respawn base after reviving
	end
	})	

end

function OnImproveDivinityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	ply.IsDivinityImproved = true
	hero:SetBaseMagicalResistanceValue(25)
	hero:SwapAbilities("berserker_5th_divinity","berserker_5th_divinity_improved", false, true)
	hero:FindAbilityByName("berserker_5th_divinity_improved"):SetLevel(1)
	print(hero:GetBaseMagicalResistanceValue())
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnBerserkAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:FindAbilityByName("berserker_5th_berserk_attribute_passive"):SetLevel(1)
	ply.IsBerserkAcquired = true

	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnGodHandAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local ability = hero:FindAbilityByName("berserker_5th_god_hand")
	ability:SetLevel(1)
	ply.IsGodHandAcquired = true
	ply.GodHandStock = 11
	ability:ApplyDataDrivenModifier(hero, hero, "modifier_god_hand_stock", {}) 
	hero:SetModifierStackCount("modifier_god_hand_stock", hero, 11)


	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnReincarnationAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	hero:SetBaseHealthRegen(hero:GetMaxHealth()/100)
	ply.IsReincarnationAcquired = true
	-- Set master 1's mana 
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end
