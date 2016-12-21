CCTable = {
	"silenced",
	"stunned",
	"revoked",
	"locked",
	"rooted",
	"disarmed",
	-- below are Dota 2 base modifiers that I might have been using previously
	"modifier_stunned",
	"modifier_disarmed",
	"modifier_silenced",
	"modifier_enkidu_hold"
}

-- stores CC duration in script scope
CCDurationTable = {
	stunned = 0,
	silenced = 0,
	revoked = 0,
	locked = 0,
	rooted = 0,
	disarmed = 0
}

itemModifiers = {"modifier_b_scroll","modifier_a_scroll","modifier_healing_scroll","modifier_speed_gem","modifier_berserk_scroll","item_pot_regen"}

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
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_nursery_rhyme_shapeshift_clone", {})
	caster.ShapeShiftIllusion = illusion
	caster.bIsSwapUsed = false 
	caster.ShapeShiftDest = targetPoint
	caster:SwapAbilities("nursery_rhyme_shapeshift", "nursery_rhyme_shapeshift_swap", false, true)

	--illusion:SetControllableByPlayer(pid, true)
	--print(illusion:GetOwner())
	illusion:SetOwner(caster) -- Attempt to change color of illusion on minimap but failed, worked for ZC but not for this. Wtf.
	--print(illusion:GetOwner():GetName())
	--print(illusion:IsClone(),illusion:IsConsideredHero(),illusion:IsControllableByAnyPlayer(),illusion:IsCreature(),illusion:IsCreep(),illusion:IsHero(),illusion:IsIllusion(),illusion:IsNeutralUnitType(),illusion:IsOwnedByAnyPlayer(),illusion:IsRealHero(),illusion:IsSummoned())

	--start of mimic function (work in progress)
	for i=1, (caster:GetLevel()-1) do
		illusion:HeroLevelUp(false)
	end

	for i = 1, #itemModifiers do
		if caster:HasModifier(itemModifiers[i]) then
			ability:ApplyDataDrivenModifier(caster, illusion, itemModifiers[i], {duration = caster:FindModifierByName(itemModifiers[i]):GetRemainingTime()})		
		end
	end

	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			local currCharge = item:GetCurrentCharges()
			--illusion:AddItem(newItem)
			CreateItemAtSlot(illusion, itemName, itemSlot, currCharge, 1, 1)
		end
	end

	for abilitySlot=0,10 do
		if abilitySlot == 9 then goto skip9 end --skip presence_detection_passive
		local abilityCopy = caster:GetAbilityByIndex(abilitySlot)
		if abilityCopy ~= nil then 
			local abilityLevel = abilityCopy:GetLevel()
			local abilityName = abilityCopy:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
		::skip9::
	end

	illusion:SetBaseStrength(caster:GetBaseStrength())
	illusion:SetBaseIntellect(caster:GetBaseIntellect())
	illusion:SetBaseAgility(caster:GetBaseAgility())
	illusion:ModifyAgility(0) --do not remove this seemingly useless line; removing will result in -20 agi and I have no freaking idea why

	illusion:SetMaxHealth(caster:GetMaxHealth())
	illusion:SetHealth(caster:GetHealth())
	-- Only GetMaxMana but no SetMaxMana wth valve
	illusion:SetMana(caster:GetMana())

	illusion:SetBaseHealthRegen(caster:GetHealthRegen() - caster:GetStrength() * (0.03)) -- 0.03 being dota2's base hpregen/str
	illusion:SetBaseManaRegen(caster:GetManaRegen() + caster:GetIntellect() * (0.25 - 0.04)) -- 0.25 being fate's mpregen/int, 0.04 being dota2's
	illusion:SetPhysicalArmorBaseValue(caster:GetPhysicalArmorBaseValue()) -- 1/7 being dota2's base armor/agi

	illusion:SetBaseMoveSpeed(caster:GetBaseMoveSpeed()) --illusion shows 300 movespeed but actual movespeed is mimicked over.
	-- stuff not done: Setting illusion's max mana, bonus stats from leveling strAgiInt+2 
	-- end mimic

	local cloneFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( cloneFx, 0, caster:GetAbsOrigin())
	Timers:CreateTimer( 0.7, function()
		ParticleManager:DestroyParticle( cloneFx, false )
		ParticleManager:ReleaseParticleIndex( cloneFx )
	end)
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
	caster:MoveToPosition(caster.ShapeShiftDest)
	caster.ShapeShiftIllusion:Hold()
end


function OnNamelessStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if IsSpellBlocked(target) or target:IsMagicImmune() then return end -- Linken effect checker
	caster.NamelessTarget = target
	ApplyPurge(target)
	ability:ApplyDataDrivenModifier(caster, target, "modifier_nameless_forest", {})

	if caster.bIsReminiscenceAcquired then
		caster:SwapAbilities("nursery_rhyme_nameless_forest", "nursery_rhyme_reminiscence", false, true)
	end
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
	if caster.bIsReminiscenceAcquired then
		caster:SwapAbilities("nursery_rhyme_nameless_forest", "nursery_rhyme_reminiscence", true, false)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_nameless_forest_stat_steal_buff", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_nameless_forest_stat_steal_debuff", {})
	end
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

function OnEnigmaLevelUp(keys)
	local caster = keys.caster
	local ability = keys.ability

	CCDurationTable.stunned = keys.stunned
	CCDurationTable.silenced = keys.silenced
	CCDurationTable.revoked = keys.revoked
	CCDurationTable.locked = keys.locked
	CCDurationTable.rooted = keys.rooted
	CCDurationTable.disarmed = keys.disarmed
end

function OnPlainStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local bounceCount = keys.MaxBounce

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	if caster.bIsNightmareAcquired then 
		bounceCount = bounceCount + 2
	end

	ChainLightning(keys, caster, target, bounceCount, nil, true)
end

--[[
Iterative function that shoots chain lightning to eligible target until bounce > count
]]
function ChainLightning(keys, source, target, count, CC, bIsFirstItrn)
	local caster = keys.caster
	local ability = keys.ability
	local reduction = keys.DmgRed
	local damage = keys.Damage
	if not CC then CC = {} end -- temporal storage for list of CCs to be applied by W	

	if count == 0 then return end

	-- if first bounce, snapshot the CC target currently has
	if bIsFirstItrn then
		for i=1, #CCTable do
			if target:HasModifier(CCTable[i]) then
				if CCTable[i] == "modifier_stunned" then 
					table.insert(CC, "stunned")
				elseif CCTable[i] == "modifier_silenced" then 
					table.insert(CC, "silenced")
				elseif CCTable[i] == "modifier_disarmed" then 
					table.insert(CC, "disarmed") 
				elseif CCTable[i] == "modifier_enkidu_hold" then
					--print("enkidu")
					table.insert(CC, "stunned")
					table.insert(CC, "disarmed") 
					table.insert(CC, "rooted") 
					table.insert(CC, "revoked")
				else
					table.insert(CC, CCTable[i])
				end  
			end
		end
	end
	--print(#CC)
	-- reduce base damage by reduction amount if not first bounce, and apply CC
	if not bIsFirstItrn then
		keys.Damage = keys.Damage * (100-reduction)/100
		damage = keys.Damage
		for i=1, #CC do
			--print("Applying " .. CC[i] .. " for " .. tostring(CCDurationTable[CC[i]]) .. " seconds")
			giveUnitDataDrivenModifier(caster, target, CC[i], CCDurationTable[CC[i]])
		end
	end

	if caster.bIsNightmareAcquired then 
		-- steal int by 2, duration 15 sec
		if target:IsHero() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_plains_of_water_int_debuff", {})
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_plains_of_water_int_buff", {})
		end
		damage = damage + 1.5*caster:GetIntellect()
	end
	DoDamage(caster, target, damage, DAMAGE_TYPE_MAGICAL, 0, ability, false)

	local lightningFx = ParticleManager:CreateParticle( "particles/custom/nursery_rhyme/plains_of_water.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControlEnt( lightningFx, 0, source, PATTACH_POINT_FOLLOW, "attach_hitloc", source:GetAbsOrigin() + Vector( 0, 0, 96 ), true );
	ParticleManager:SetParticleControlEnt( lightningFx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin() + Vector(0,0,96), true );
	target:EmitSound("Hero_Winter_Wyvern.SplinterBlast.Target")

	Timers:CreateTimer(0.2, function()
		if IsValidEntity(target) and not target:IsNull() then
			local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 550, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			for k,v in pairs(targets) do
				if v ~= target then 
					ChainLightning(keys, target, v, count-1, CC, false)
					return
				end
			end
		end
	end)
end


function OnCloneStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = keys.Duration
	local cloneHealth = target:GetMaxHealth() * keys.Health/100 

	if IsSpellBlocked(keys.target) then return end -- Linken effect checker

	-- check for existing clone 
	if caster.bCloneExists then
		if IsValidEntity(caster.CurrentDoppelganger) and not caster.CurrentDoppelganger:IsNull() then
			caster.CurrentDoppelganger:ForceKill(false)
		end 
	end
	local dist = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	local illusionSpawnLoc = Vector(0,0,0)
	
	if dist > 300 then 
		illusionSpawnLoc = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * 300
	else
		illusionSpawnLoc = target:GetAbsOrigin() + (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized() * dist/2
	end
	local illusion = CreateUnitByName("pseudo_illusion", illusionSpawnLoc, true, target, nil, target:GetTeamNumber()) 
	illusion:SetModel(target:GetModelName())
	illusion:SetOriginalModel(target:GetModelName())
	illusion:SetModelScale(target:GetModelScale())
	--illusion:AddNewModifier(caster, nil, "modifier_kill", {duration = duration})
	StartAnimation(illusion, {duration=duration, activity=ACT_DOTA_IDLE, rate=1})
	--illusion:SetPlayerID(target:GetPlayerID()) 
	--illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = 0, incoming_damage = 0 })
	--illusion:MakeIllusion()
	illusion:SetBaseMagicalResistanceValue(0)
	-- god why do i have to always wait 1 damn frame
	Timers:CreateTimer(0.033, function()
		illusion:SetBaseMaxHealth(cloneHealth)
		illusion:SetMaxHealth(cloneHealth)
		illusion:ModifyHealth(cloneHealth, nil, false, 0)
	end)
	Timers:CreateTimer(duration, function()
		if IsValidEntity(illusion) and not illusion:IsNull() then 
			illusion:ForceKill(false)
			illusion:AddEffects(EF_NODRAW)
			--illusion:SetAbsOrigin(Vector(10000,10000,0))
		end
	end)

	caster.CurrentDoppelganger = illusion
	caster.CurrentDoppelgangerOriginal = target
	caster.bCloneExists = true
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_doppelganger", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_doppelganger_enemy", {})
	giveUnitDataDrivenModifier(caster, illusion, "pause_sealdisabled", duration)

	target:EmitSound("Hero_Terrorblade.Sunder.Target")
	local cloneFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( cloneFx, 0, target:GetAbsOrigin())
	local cloneFx2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( cloneFx2, 0, illusion:GetAbsOrigin())
	Timers:CreateTimer( 0.7, function()
		ParticleManager:DestroyParticle( cloneFx, false )
		ParticleManager:ReleaseParticleIndex( cloneFx )
		ParticleManager:DestroyParticle( cloneFx2, false )
		ParticleManager:ReleaseParticleIndex( cloneFx2 )
	end)
end

function OnCloneTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageTaken = keys.DamageTaken
	local damageShared = keys.SharedDamage

	DoDamage(caster, caster.CurrentDoppelgangerOriginal, damageTaken*damageShared/100, DAMAGE_TYPE_MAGICAL, 0, ability, false)
end

--[[
slow applier when attribute is acquired
]]
function OnCloneThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.bIsFTAcquired then
		if not IsFacingUnit(caster.CurrentDoppelgangerOriginal, caster.CurrentDoppelganger, 180) then
			DoDamage(caster, caster.CurrentDoppelgangerOriginal, caster:GetIntellect()*1.5 , DAMAGE_TYPE_MAGICAL, 0, ability, false)
			ability:ApplyDataDrivenModifier(caster, caster.CurrentDoppelgangerOriginal, "modifier_doppelganger_lookaway_slow", {})
		end
	end
end

function OnCloneOriginalTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageTaken = keys.DamageTaken

	if caster.CurrentDoppelgangerOriginal.bIsInvulDuetoDoppel then
		caster.CurrentDoppelgangerOriginal:SetHealth(1)
		caster.CurrentDoppelgangerOriginal.bIsInvulDuetoDoppel = false

		caster.CurrentDoppelganger:ForceKill(false)
	end
end

function OnCloneDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local cloneKillFx = ParticleManager:CreateParticle( "particles/generic_gameplay/illusion_killed.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( cloneKillFx, 0, caster.CurrentDoppelganger:GetAbsOrigin()+Vector(0,0,100) )

	caster.CurrentDoppelganger:AddEffects(EF_NODRAW)
	--illusion:SetModel("models/development/invisiblebox.vmdl")
	--illusion:SetOriginalModel("models/development/invisiblebox.vmdl")

	--caster.CurrentDoppelganger:SetHealth(1)
	--caster.CurrentDoppelganger:SetAbsOrigin(Vector(10000,10000,0))
	caster.CurrentDoppelgangerOriginal:RemoveModifierByName("modifier_doppelganger_enemy")
	caster.CurrentDoppelganger:ForceKill(false)
	caster.CurrentDoppelgangerOriginal = nil
	caster.bCloneExists = false
end

function OnCloneOriginalDeath(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.CurrentDoppelganger:ForceKill(false)
end

function OnGlassGameStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = keys.Radius
	local instantHeal = keys.InstantHeal
	local instantHealPct = keys.InstantHealPct

	NRCheckCombo(caster, ability)

	if caster.bIsQGGImproved then
		instantHeal = instantHeal+150
		instantHealPct = 20
	end

	-- give caster heal aura modifier
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_queens_glass_game", {})
	if caster.bIsQGGImproved then
		--print("applied aura")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_queens_glass_game_mana_aura", {})
	end
	-- find team units in radius and grant them instant heal
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
		local missingHealth = (v:GetMaxHealth() - v:GetHealth()) * instantHealPct/100
		local totalHeal = instantHeal + missingHealth
		v:Heal(totalHeal, caster)
		if caster.bIsQGGImproved then
			v:GiveMana(totalHeal/2)
		end
		local healFx = ParticleManager:CreateParticle( "particles/units/heroes/hero_chen/chen_hand_of_god.vpcf", PATTACH_CUSTOMORIGIN, nil );
		ParticleManager:SetParticleControl( healFx, 0, v:GetAbsOrigin() + Vector(0,0,50))
		v:EmitSound("Item.GuardianGreaves.Target")
	end

	local shineFx = ParticleManager:CreateParticle( "particles/items_fx/aegis_respawn_aegis_starfall.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( shineFx, 0, caster:GetAbsOrigin())
	EmitGlobalSound("NR.Chronosphere")
	EmitGlobalSound("NR.GlassGame.Begin")
	caster:EmitSound("NR.Tick")
	--[[local SacFx = ParticleManager:CreateParticle("particles/custom/caster/sacrifice/caster_sacrifice_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( SacFx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl( SacFx, 1, Vector(radius,0,0))]]
end

function OnGlassGameEnd(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:RemoveModifierByName("modifier_queens_glass_game")
	if caster.bIsQGGImproved then
		caster:RemoveModifierByName("modifier_queens_glass_game_mana_aura")
	end
	caster:StopSound("NR.Tick")
end

function OnGlassGameThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local manaCost = keys.ManaCost * caster:GetMaxMana() / 100
	--print(manaCost)
	if  manaCost > caster:GetMana() then 
		caster:Stop() -- stop channeling
	else
		caster:SetMana(caster:GetMana() - manaCost)
	end
end

function CreateGlassGameEffect(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.aoeFx = ParticleManager:CreateParticle( "particles/custom/nursery_rhyme/queens_glass_game/queens_glass_game_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( caster.aoeFx, 0, caster:GetAbsOrigin())
	caster.aoeFx2 = ParticleManager:CreateParticle( "particles/custom/nursery_rhyme/queens_glass_game/queens_glass_game_bookswirl.vpcf", PATTACH_CUSTOMORIGIN, nil );
	ParticleManager:SetParticleControl( caster.aoeFx2, 1, caster:GetAbsOrigin())

end

function RemoveGlassGameEffect(keys)
	local caster = keys.caster
	local ability = keys.ability

	ParticleManager:DestroyParticle( caster.aoeFx, false )
	ParticleManager:ReleaseParticleIndex( caster.aoeFx )
	caster.aoeFx = nil

	ParticleManager:DestroyParticle( caster.aoeFx2, false )
	ParticleManager:ReleaseParticleIndex( caster.aoeFx2 )
	caster.aoeFx2 = nil
end


function OnGlassGameAuraApplied(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if not target.reincarnation_particle then target.reincarnation_particle = ParticleManager:CreateParticle("particles/custom/berserker/reincarnation/regen_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) end
end

function OnGlassGameAuraEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	ParticleManager:DestroyParticle(target.reincarnation_particle, false)
	target.reincarnation_particle = nil
end

--[[
Round finish mechanics 
]]
function OnNRComboStart(keys)
	local caster = keys.caster
	local ability = keys.ability	
	local cooldown = keys.ability:GetCooldown(1)
	
	if GameRules:GetGameTime() > 60 + _G.RoundStartTime then
		ability:EndCooldown()
		caster:GiveMana(ability:GetManaCost(1)) 
		caster:Stop()
		SendErrorMessage(caster:GetPlayerOwnerID(), "#Cannot_Be_Cast_Now")
		return 
	end
	if caster.bIsQGGImproved then 
		ReduceCooldown(ability, 70)
		cooldown = cooldown - 70
	end
	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(cooldown)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_someones_sake_cooldown", {duration = cooldown})
	
	caster.bIsNRComboSuccessful = false
	caster.nNRComboQuoteCount = 1

	-- apply timer modifier for caster and all enemy heroes
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_story_for_someones_sake", {})
    LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero ~= caster then
    		ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_story_for_someones_sake_enemy", {})
    	end
    end)

    GameRules:SendCustomMessage("<font color='#FF0000'>You feel the very fabric of time being twisted.</font>", 0, 0)

    EmitGlobalSound("NR.GlobalPing")
    caster:EmitSound("NR.Tick")
end

function PingLocationForEnemies(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster.nNRComboQuoteCount == 3 then
		GameRules:SendCustomMessage("<font color='#FF0000'>This story will go on forever.</font>", 0, 0)
		EmitGlobalSound("Hero_Wisp.Tether.Stop")
		local blueScreenFx = ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	elseif caster.nNRComboQuoteCount == 4 then
		GameRules:SendCustomMessage("<font color='#FF0000'>As long as the slender fingers return to the first page,</font>", 0, 0)
		EmitGlobalSound("Hero_Wisp.Tether.Stop")
		local blueScreenFx = ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	elseif caster.nNRComboQuoteCount == 5 then
		GameRules:SendCustomMessage("<font color='#FF0000'>As if picking up the next volume.</font>", 0, 0)
		EmitGlobalSound("Hero_Wisp.Tether.Stop")
		local blueScreenFx = ParticleManager:CreateParticle("particles/custom/screen_lightblue_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	end
	caster.nNRComboQuoteCount = caster.nNRComboQuoteCount+1

    LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() and player and playerHero then
    		MinimapEvent( playerHero:GetTeamNumber(), playerHero, caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_ENEMY_TELEPORTING, 2 )
    	end
    end)	
end

function OnNRComboEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:StopSound("NR.Tick")
	if caster:IsAlive() and _G.CurrentGameState == "FATE_ROUND_ONGOING" then 
		caster.bIsNRComboSuccessful = true 
		GameRules:SendCustomMessage("<font color='#FF0000'>Once again denying reality to the reader.</font>", 0, 0)
		EmitGlobalSound("Hero_Wisp.Tether.Stun")

		local RedScreenFx = ParticleManager:CreateParticle("particles/custom/screen_red_splash.vpcf", PATTACH_EYES_FOLLOW, caster)
	end
end

function OnNRComboDeath(keys)
	local caster = keys.caster
	local ability = keys.ability

    --[[LoopOverPlayers(function(player, playerID, playerHero)
    	if playerHero ~= caster then
    		playerHero:RemoveModifierByName("modifier_story_for_someones_sake_enemy")
    	end
    end)]]
	EmitGlobalSound("Hero_Wisp.Tether.Stun")
    GameRules:SendCustomMessage("<font color='#58ACFA'>The fabric of time has become normal again.</font>", 0, 0)
end

function NRCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("nursery_rhyme_queens_glass_game") and caster:FindAbilityByName("nursery_rhyme_story_for_somebodys_sake"):IsCooldownReady() and (GameRules:GetGameTime() < 60 + _G.RoundStartTime) then
			caster:SwapAbilities("nursery_rhyme_queens_glass_game", "nursery_rhyme_story_for_somebodys_sake", false, true)
			Timers:CreateTimer({
				endTime = 2,
				callback = function()
				caster:SwapAbilities("nursery_rhyme_queens_glass_game", "nursery_rhyme_story_for_somebodys_sake", true, false)
			end
			})
		end
	end
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

--[[
        "DOTA_Tooltip_Ability_nursery_rhyme_attribute_forever_together"		"Forever Together"
        "DOTA_Tooltip_Ability_nursery_rhyme_attribute_forever_together_Description"		"I Am You, and You Are Me causes target to be slowed 
        and take damage continuously if it is looking away from its doppelganger. Also, improves Shapeshift's max duration and slow, and reduces its cooldown."
        ]]
function OnFTAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	--hero:SwapAbilities("jeanne_saint", "jeanne_identity_discernment", true, true) 
	-- Set master 1's mana 
	hero.bIsFTAcquired = true
	hero:FindAbilityByName("nursery_rhyme_shapeshift"):SetLevel(2)
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnNightmareAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	--hero:SwapAbilities("jeanne_saint", "jeanne_identity_discernment", true, true) 
	-- Set master 1's mana 
	hero.bIsNightmareAcquired = true

	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnReminiscenceAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	--hero:SwapAbilities("jeanne_saint", "jeanne_identity_discernment", true, true) 
	-- Set master 1's mana 
	hero.bIsReminiscenceAcquired = true
	hero:FindAbilityByName("nursery_rhyme_nameless_forest"):SetLevel(2)
	
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnImproveQGGAcquired(keys)
	local caster = keys.caster
	local pid = caster:GetPlayerOwnerID()
	local hero = PlayerResource:GetSelectedHeroEntity(pid)

	--hero:SwapAbilities("jeanne_saint", "jeanne_identity_discernment", true, true) 
	-- Set master 1's mana 
	hero.bIsQGGImproved = true
	
	local master = hero.MasterUnit
	master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end