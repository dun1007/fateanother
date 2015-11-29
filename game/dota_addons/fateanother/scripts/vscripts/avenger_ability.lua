function OnDPStart(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	local currentHealthCost = 0
    local ply = caster:GetPlayerOwner()
    if caster.IsDPImproved then
    	keys.Range = 1000
    	keys.ability:EndCooldown() 
    	keys.ability:StartCooldown(1)
    end

	if caster:HasModifier("modifier_purge") or caster:HasModifier("modifier_aestus_domus_aurea_lock") or caster:HasModifier("locked") then 
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot blink while Purged" } )
		keys.ability:EndCooldown()
		return
	end


	if GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) then
		keys.ability:EndCooldown()  
		FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerOwnerID(), _error = "Cannot Travel to Targeted Location" } )
		return 
	end 
	local currentStack = caster:GetModifierStackCount("modifier_dark_passage", keys.ability)
	currentHealthCost = keys.HealthCost * 2 ^ currentStack
	if currentStack == 0 and caster:HasModifier("modifier_dark_passage") then currentStack = 1 end
	caster:RemoveModifierByName("modifier_dark_passage") 
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_dark_passage", {}) 
	caster:SetModifierStackCount("modifier_dark_passage", keys.ability, currentStack + 1)

	if caster:GetHealth() < currentHealthCost then
		caster:SetHealth(1)
		keys.ability:StartCooldown(45)
	else
		caster:SetHealth(caster:GetHealth() - currentHealthCost)
	end
	
	-- Create particle at start point
	local startParticleIndex = ParticleManager:CreateParticle( "particles/custom/avenger/avenger_dark_passage_start.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( startParticleIndex, 0, caster:GetAbsOrigin() )
	Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( startParticleIndex, false )
			ParticleManager:ReleaseParticleIndex( startParticleIndex )
		end
	)
	
	caster:EmitSound("Hero_Antimage.Blink_out")
	
	local diff = targetPoint - caster:GetAbsOrigin()
	Timers:CreateTimer(0.033, function()
			if diff:Length2D() > keys.Range then
				targetPoint = caster:GetAbsOrigin() + diff:Normalized() * keys.Range
			end

			local i = 1
			while GridNav:IsBlocked(targetPoint) or not GridNav:IsTraversable(targetPoint) do
				i = i+1
				targetPoint = caster:GetAbsOrigin() + diff:Normalized() * (keys.Range - i*50)
			end
			caster:SetAbsOrigin(targetPoint)
			FindClearSpaceForUnit(caster, targetPoint, true)
			ProjectileManager:ProjectileDodge(caster)
			caster:EmitSound("Hero_Antimage.Blink_in")
			
			-- Create end particle
			-- Create particle at start point
			local endParticleIndex = ParticleManager:CreateParticle( "particles/custom/avenger/avenger_dark_passage_end.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( endParticleIndex, 0, caster:GetAbsOrigin() )
			Timers:CreateTimer( 2.0, function()
					ParticleManager:DestroyParticle( endParticleIndex, false )
					ParticleManager:ReleaseParticleIndex( endParticleIndex )
				end
			)
		end
	)
end

function OnMurderStart(keys)
end

function OnMurderLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("avenger_unlimited_remains"):SetLevel(keys.ability:GetLevel())
end

function OnMurder(keys)
	local caster = keys.caster
	local target = keys.unit
	local manareg = 0
	if target:GetName() == "npc_dota_creature" then 
		--print("Avenger killed a unit")
		manareg = caster:GetMaxMana() * keys.ManaRegen / 100
	elseif target:IsHero() then
		--print("Avenger killed a hero")
		manareg = caster:GetMaxMana() * keys.ManaRegenHero / 100
	end
	caster:SetMana(caster:GetMana() + manareg)
end

function OnAttackRemain(keys)
	local caster = keys.caster
	local target = keys.target
	print(target:GetName())
	if target:GetUnitName() == "avenger_remain" then
		DoDamage(caster, target, 9999, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)

	end
end

function OnBashSuccess(keys)
	local caster = keys.caster
	local target = keys.target

	if target:HasModifier("modifier_murderous_instinct_bash_checker") then
		-- do nothing
	else
		target:AddNewModifier(caster, target, "modifier_stunned", {Duration = 1.0})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_murderous_instinct_bash_checker", {}) 
	end
end

function OnRemainStart(keys)
	local caster = keys.caster
	local attackmove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = nil
	}
	caster:EmitSound("Hero_Nevermore.Shadowraze")
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + caster:GetForwardVector() * 200) 
	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	for i=1, keys.SpawnNumber do
		local remain = CreateUnitByName("avenger_remain", caster:GetAbsOrigin() + caster:GetForwardVector() * 200, true, nil, nil, caster:GetTeamNumber()) 
		--remain:SetControllableByPlayer(caster:GetPlayerID(), true)
		remain:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
		LevelAllAbility(remain)
		FindClearSpaceForUnit(remain, remain:GetAbsOrigin(), true)
		remain:FindAbilityByName("avenger_remain_passive"):SetLevel(keys.ability:GetLevel())
		remain:AddNewModifier(caster, nil, "modifier_kill", {duration = 45})
		Timers:CreateTimer(3.0, function() 
			if not remain:IsAlive() then return end
			attackmove.UnitIndex = remain:entindex()
			attackmove.Position = remain:GetAbsOrigin() + RandomVector(1000) 
			ExecuteOrderFromTable(attackmove)
			return 3.0
		end)
	end


end

function OnRemainDeath(keys)
	local caster = keys.caster
	local summons = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 20000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
	for k,v in pairs(summons) do
		--print("Found unit " .. v:GetUnitName())
		if v:GetUnitName() == "avenger_remain" then
			v:ForceKill(true) 
		end
	end
end

function OnRemainExplode(keys)
	local caster = keys.caster
	local target = keys.target
	if (target:GetName() == "npc_dota_ward_base") or caster.IsDamageDone then
		return
	end
	caster.IsDamageDone = true
	caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsImpact")
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, 250
            , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do
         DoDamage(caster, v, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
    end
    caster:ForceKill(true)
end

function OnRemainMultiplyStart(keys)
	local caster = keys.caster
	Timers:CreateTimer(0.033, function()
		local avenger = caster:GetPlayerOwner():GetAssignedHero()
		local remainabil = avenger:FindAbilityByName("avenger_unlimited_remains")
		local period = remainabil:GetLevelSpecialValueFor("multiply_period", remainabil:GetLevel()-1)	
		Timers:CreateTimer(period, function() 
			if not IsValidEntity(caster) or not caster:IsAlive() then return end
			OnRemainMultiply(keys)
			return period
		end)	
	end)

end

function OnRemainMultiply(keys)
	local caster = keys.caster
	local attackmove = {
		UnitIndex = nil,
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = nil
	}
	local remain = CreateUnitByName("avenger_remain", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber()) 
	--remain:SetControllableByPlayer(caster:GetPlayerID(), true)
	remain:SetOwner(caster:GetPlayerOwner():GetAssignedHero())
	LevelAllAbility(remain)
	FindClearSpaceForUnit(remain, remain:GetAbsOrigin(), true)
	remain:FindAbilityByName("avenger_remain_passive"):SetLevel(keys.ability:GetLevel()-1)
	remain:AddNewModifier(caster, nil, "modifier_kill", {duration = 45})
	Timers:CreateTimer(3.0, function() 
		if not remain:IsAlive() then return end
		attackmove.UnitIndex = remain:entindex()
		attackmove.Position = remain:GetAbsOrigin() + RandomVector(1000) 
		ExecuteOrderFromTable(attackmove)
		return 3.0
	end)
end

function OnTZStart(keys)
	local caster = keys.caster
	local target = keys.target
	local TZCount = 0
	if IsSpellBlocked(keys.target) then return end
	if not IsImmuneToSlow(keys.target) then keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_tawrich_slow", {}) end
	Timers:CreateTimer(0.033, function() 
		if TZCount == 6 then return end
		caster:EmitSound("Hero_BountyHunter.Jinada")
		local particle = ParticleManager:CreateParticle("particles/econ/courier/courier_mechjaw/mechjaw_death_sparks.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
		DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
		TZCount = TZCount + 1
		return 0.10
	end)

	target:AddNewModifier(caster, target, "modifier_disarmed", {Duration = keys.Duration})
	target:AddNewModifier(caster, target, "modifier_silence", {Duration = keys.Duration})
end

function OnTZLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("avenger_vengeance_mark"):SetLevel(keys.ability:GetLevel())
end

function OnVengeanceStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_vengeance_mark", {})
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnVengeanceEnd(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(target, caster, keys.Damage * keys.ReturnAmount/100, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function OnBloodStart(keys)
	local caster = keys.caster
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end
	local initHealth = caster:GetHealth() 
	local initTargetHealth = target:GetHealth()

	if initHealth > caster:GetMaxHealth() then
		target:SetHealth(caster:GetMaxHealth())
	else
		target:SetHealth(initHealth)
	end
	if initTargetHealth > target:GetMaxHealth() then
		caster:SetHealth(target:GetMaxHealth())
	else
		caster:SetHealth(initTargetHealth)
	end
end

function OnTFStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_true_form", {}) 
	AvengerCheckCombo(keys.caster, keys.ability)
	--local a1 = caster:GetAbilityByIndex(0)
	--local a2 = caster:GetAbilityByIndex(1):GetAbilityName()
    caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains", true, true) 
    if caster.IsBloodMarkAcquired then 
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_blood_mark", true, true) 
    else
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark", true, true) 
   	end
    caster:SwapAbilities("avenger_true_form", "avenger_demon_core", true, true)
    caster:SetModel("models/avenger/trueform/trueform.vmdl")
    caster:SetOriginalModel("models/avenger/trueform/trueform.vmdl")
    caster:SetModelScale(1.1)

    caster:EmitSound("Hero_Terrorblade.Metamorphosis")
end

function OnTFLevelUp(keys)
	local caster = keys.caster
	caster:FindAbilityByName("avenger_demon_core"):SetLevel(keys.ability:GetLevel())
end


function OnTFEnd(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
    caster:SwapAbilities("avenger_murderous_instinct", "avenger_unlimited_remains", true, true) 
    local a2 = caster:GetAbilityByIndex(1):GetAbilityName()
    caster:SwapAbilities("avenger_tawrich_zarich", a2, true, true) 
    --[[if caster.IsBloodMarkAcquired then 
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_blood_mark", true, true) 
    else
    	caster:SwapAbilities("avenger_tawrich_zarich", "avenger_vengeance_mark", true, true) 
   	end]]
    caster:SwapAbilities("avenger_true_form", "avenger_demon_core", true, true)
    local demoncore = caster:FindAbilityByName("avenger_demon_core")
    if demoncore:GetToggleState() then
    	demoncore:ToggleAbility()
    end
    caster:SetModel("models/avenger/avenger.vmdl")
    caster:SetOriginalModel("models/avenger/avenger.vmdl")

    caster:SetModelScale(0.8)
end


function OnDCTick(keys)
	local caster = keys.caster
	local ability = keys.ability
	-- If Demon Core is not toggled on or caster has less than 25 mana, remove buff 
	if not ability:GetToggleState() or caster:GetMana() < 25 or not caster:HasModifier("modifier_true_form") then 
		caster:RemoveModifierByName("modifier_demon_core")
		return
	end
	-- Reduce mana and process attribute stuffs
	caster:SetMana(caster:GetMana() - 25) 
	if caster.IsDIAcquired then 
		local trueform = caster:FindAbilityByName("avenger_true_form")
		local trueformcd = trueform:GetCooldownTimeRemaining() 
		trueform:EndCooldown()
		trueform:StartCooldown(trueformcd - 0.5)
	end
end

function TurnDCOff(keys)
	local caster = keys.caster
	local demoncore = caster:FindAbilityByName("avenger_demon_core")
    if demoncore:GetToggleState() then
    	demoncore:ToggleAbility()
    end
end
function OnVergStart(keys)
	local caster = keys.caster
	EmitGlobalSound("Avenger.Berg")

end

function OnVergTakeDamage(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local attacker = keys.attacker
	if caster.IsDIAcquired then keys.Multiplier = keys.Multiplier + 25 end
	local returnDamage = keys.DamageTaken * keys.Multiplier / 100
	if caster:GetHealth() ~= 0 then
		DoDamage(caster, attacker, returnDamage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, keys.ability, false)
		if attacker:IsRealHero() then attacker:EmitSound("Hero_WitchDoctor.Maledict_Tick") end
		local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_ABSORIGIN, attacker)
		ParticleManager:SetParticleControl(particle, 1, attacker:GetAbsOrigin())
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
	end
end

function OnEndlessStart(keys)
	local caster = keys.caster
	local resetCounter = 0
	local initHealth = caster:GetHealth()

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	EmitGlobalSound("Avenger.Berg")
	EmitGlobalSound("Hero_Nightstalker.Darkness")
	Timers:CreateTimer(3.0, function() 
		if resetCounter == 4 or not caster:IsAlive() then return end
	caster:SetHealth(initHealth) 
		ResetAbilities(caster)
		ResetItems(caster)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
		caster:EmitSound("Hero_LifeStealer.Consume")
		resetCounter = resetCounter + 1
		return 3.0
	end)
end

function OnEndlessTakeDamage(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local attacker = keys.attacker
	local verg = caster:FindAbilityByName("avenger_verg_avesta")
	local multiplier = verg:GetLevelSpecialValueFor("multiplier", verg:GetLevel()-1)
	if caster.IsDIAcquired then multiplier = multiplier + 25 end
	local returnDamage = keys.DamageTaken * multiplier / 100

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))

	if caster:GetHealth() ~= 0 then
		DoDamage(caster, attacker, returnDamage, DAMAGE_TYPE_MAGICAL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, verg, false)
		if attacker:IsRealHero() then attacker:EmitSound("Hero_WitchDoctor.Maledict_Tick") end
		local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_ABSORIGIN, attacker)
		ParticleManager:SetParticleControl(particle, 1, attacker:GetAbsOrigin())
		Timers:CreateTimer( 2.0, function()
			ParticleManager:DestroyParticle( particle, false )
			ParticleManager:ReleaseParticleIndex( particle )
		end)
	end
end

function OnOverdriveAttack(keys)
	local caster = keys.caster
	print("hey attack actually started")
	if caster:HasModifier("modifier_overdrive_tier1") or caster:HasModifier("modifier_overdrive_tier2") or caster:HasModifier("modifier_overdrive_tier3") or caster:HasModifier("modifier_overdrive_tier4") or caster:HasModifier("modifier_overdrive_tier5") or caster:HasModifier("modifier_overdrive_tier6") then
		print("overdrive already present")
	else
		print("applying speed buff")
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_overdrive_tier1", {}) 
	end
end

function AvengerCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.5 and caster:GetAgility() >= 19.5 and caster:GetIntellect() >= 19.5 then
		if ability == caster:FindAbilityByName("avenger_true_form") and caster:FindAbilityByName("avenger_verg_avesta"):IsCooldownReady() and caster:FindAbilityByName("avenger_endless_loop"):IsCooldownReady()  then
			caster:SwapAbilities("avenger_verg_avesta", "avenger_endless_loop", false, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				caster:SwapAbilities("avenger_verg_avesta", "avenger_endless_loop", true, true) 
			end
			})
		end
	end
end

function OnDarkPassageImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsDPImproved = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnBloodMarkAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsBloodMarkAcquired = true
    -- swap vengeance mark with blood mark
    caster:SwapAbilities("avenger_vengeance_mark", "avenger_blood_mark", false, true) 
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnOverdriveAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero:FindAbilityByName("avenger_overdrive"):SetLevel(1)
    -- enable overdrive passive
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnDIAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsDIAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end