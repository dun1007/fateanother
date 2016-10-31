function OnIPStart(keys)
	local caster = keys.caster

	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_acquire_divinity", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_acquire_golden_rule", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_acquire_martial_arts", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_close_spellbook", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_acquire_clairvoyance", true, true)
end

function OnIPRespawn(keys)
	print("respawned")
	local caster = keys.caster
 	keys.ability:EndCooldown()
end

PassiveModifiers = {
	"modifier_divinity_damage_block",
	"modifier_golden_rule",
	"modifier_minds_eye_crit",
	"modifier_martial_arts_critical"
}
function OnDivinityAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local currentPassive = caster:GetAbilityByIndex(3):GetName()
	if currentPassive ~= "fate_empty1" then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "fate_empty1", true, true)
		caster:RemoveAbility(currentPassive)
	end
	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	caster:AddAbility("berserker_5th_divinity")
	if caster.IsPrivilegeImproved then
		caster:FindAbilityByName("berserker_5th_divinity"):SetLevel(2)
	else
		caster:FindAbilityByName("berserker_5th_divinity"):SetLevel(1)
	end
	caster:SwapAbilities("berserker_5th_divinity", "fate_empty1", true, true)
	caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)

	OnIPClose(keys)
end

function OnCasaAcquired(keys)
end

function OnGoldenRuleAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local currentPassive = caster:GetAbilityByIndex(3):GetName()
	if currentPassive ~= "fate_empty1" then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "fate_empty1", true, true)
		caster:RemoveAbility(currentPassive)
	end
	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	caster:AddAbility("gilgamesh_golden_rule")
	if caster.IsPrivilegeImproved then
		caster:FindAbilityByName("gilgamesh_golden_rule"):SetLevel(2)
	else
		caster:FindAbilityByName("gilgamesh_golden_rule"):SetLevel(1)
	end
	caster:SwapAbilities("gilgamesh_golden_rule", "fate_empty1", true, true)
	caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
	OnIPClose(keys)
end

function OnMindEyeAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local currentPassive = caster:GetAbilityByIndex(3):GetName()
	if currentPassive ~= "fate_empty1" then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "fate_empty1", true, true)
		caster:RemoveAbility(currentPassive)
	end
	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	caster:AddAbility("false_assassin_minds_eye")
	if caster.IsPrivilegeImproved then
		caster:FindAbilityByName("false_assassin_minds_eye"):SetLevel(2)
	else
		caster:FindAbilityByName("false_assassin_minds_eye"):SetLevel(1)
	end
	caster:SwapAbilities("false_assassin_minds_eye", "fate_empty1", true, true)
	caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
	OnIPClose(keys)
end

function OnMartialArtsAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local currentPassive = caster:GetAbilityByIndex(3):GetName()
	if currentPassive ~= "fate_empty1" then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "fate_empty1", true, true)
		caster:RemoveAbility(currentPassive)
	end
	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	caster:AddAbility("lishuwen_martial_arts")
	if caster.IsPrivilegeImproved then
		caster:FindAbilityByName("lishuwen_martial_arts"):SetLevel(2)
	else
		caster:FindAbilityByName("lishuwen_martial_arts"):SetLevel(1)
	end
	caster:SwapAbilities("lishuwen_martial_arts", "fate_empty1", true, true)
	caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
	OnIPClose(keys)
end

function OnClairvoyanceAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local currentPassive = caster:GetAbilityByIndex(3):GetName()
	if currentPassive ~= "fate_empty1" then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "fate_empty1", true, true)
		caster:RemoveAbility(currentPassive)
	end
	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	caster:AddAbility("archer_5th_clairvoyance")
	if caster.IsPrivilegeImproved then
		caster.IsEagleEyeAcquired = true
		caster:FindAbilityByName("archer_5th_clairvoyance"):SetLevel(2)
	else
		caster:FindAbilityByName("archer_5th_clairvoyance"):SetLevel(1)
	end
	caster:SwapAbilities("archer_5th_clairvoyance", "fate_empty1", true, true)
	caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
	OnIPClose(keys)
end

function OnItemConstructionAcquired(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local currentPassive = caster:GetAbilityByIndex(3):GetName()
	if currentPassive ~= "fate_empty1" then
		caster:SwapAbilities(caster:GetAbilityByIndex(3):GetName(), "fate_empty1", true, true)
		caster:RemoveAbility(currentPassive)
	end
	for i=1, #PassiveModifiers do
		if caster:HasModifier(PassiveModifiers[i]) then
			caster:RemoveModifierByName(PassiveModifiers[i])
		end
	end
	caster:AddAbility("caster_5th_item_construction")
	caster:FindAbilityByName("caster_5th_item_construction"):SetLevel(1)
	caster:SwapAbilities("caster_5th_item_construction", "fate_empty1", true, true)
	caster:FindAbilityByName("nero_imperial_privilege"):StartCooldown(9999)
	OnIPClose(keys)
end

function OnIPClose(keys)
	local caster = keys.caster
	caster:SwapAbilities(caster:GetAbilityByIndex(0):GetName(), "nero_gladiusanus_blauserum", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(1):GetName(), "nero_tres_fontaine_ardent", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(2):GetName(), "nero_rosa_ichthys", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(4):GetName(), "nero_imperial_privilege", true, true)
	caster:SwapAbilities(caster:GetAbilityByIndex(5):GetName(), "nero_aestus_domus_aurea", true, true)
end
function OnGBStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gladiusanus_blauserum_mitigation", {})
	caster.IsGBActive = true
	caster:EmitSound("Hero_DoomBringer.ScorchedEarthAura")
	Timers:CreateTimer(0.033, function()
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_gladiusanus_blauserum",{})
	end)
	Timers:CreateTimer(0.5,function()
		if keys.ability:IsChanneling() then
			caster:SetModifierStackCount("modifier_gladiusanus_blauserum", caster, caster:GetModifierStackCount("modifier_gladiusanus_blauserum", caster)+1)
			return 0.49
		else
			return
		end
	end)
end

function OnGBAttackStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_gladiusanus_blauserum_anim", {})
end

function OnGBEnd(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_gladiusanus_blauserum_mitigation")
	Timers:CreateTimer(0.033, function()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_gladiusanus_blauserum_mitigation", {duration=0.5})
	end)
end

function OnGBStrike(keys)
	local caster = keys.caster
	local target = keys.target
	local ply = caster:GetPlayerOwner()
	caster:EmitSound("Hero_Clinkz.DeathPact")
	if caster.IsPTBAcquired then
		local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
		for k,v in pairs(targets) do
			DoDamage(caster, v, caster:GetAgility() * 5, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
			target:AddNewModifier(caster, v, "modifier_stunned", {Duration = 0.75})
		end
	end

	CreateSlashFx(caster, target:GetAbsOrigin()+Vector(250, 250, 0), target:GetAbsOrigin()+Vector(-250,-250,0))
	
	local flameFx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(flameFx, 2, target:GetAbsOrigin())

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()) 
	ParticleManager:SetParticleControl(particle, 1, Vector(300, 300, 300)) 
	ParticleManager:SetParticleControl(particle, 3, Vector(300, 300, 300)) 

	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( flameFx, false )
		ParticleManager:ReleaseParticleIndex( flameFx )
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )
	end)

	-- add effect and handle attribute
end

function OnGBDestroy(keys)
	local caster = keys.caster
	StopSoundEvent("Hero_DoomBringer.ScorchedEarthAura", caster)
end

function OnTFAStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_tres_fontaine_ardent", {})
end

function OnTFACleave(keys)
	local caster = keys.caster
	local target = keys.target
	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	for k,v in pairs(targets) do
		DoDamage(caster, v, caster:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL, 0, keys.ability, false)
	end

end

function OnRIStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if IsSpellBlocked(keys.target) then return end
	
	if caster.IsFieryFinaleActivated then 
		OnLSCStart(keys)
		return
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rosa_ichthys_anim", {})
	caster:EmitSound("Nero.Rosa")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.25)
	local slash = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 99999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 0,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 99999
	}
	
	Timers:CreateTimer(1.25, function()
		if (caster:GetAbsOrigin().y < -2000 and target:GetAbsOrigin().y > -2000) or (caster:GetAbsOrigin().y > -2000 and target:GetAbsOrigin().y < -2000) then 
			return 
		end
		if caster:IsAlive() then
			local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
			local dist = 0
			if diff:Length2D() > keys.MaxRange then 
				dist = keys.MaxRange
			else 
				dist = diff:Length2D()
			end
			slash.vSpawnOrigin = caster:GetAbsOrigin()
			slash.vVelocity = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 99999
			slash.fDistance = dist

			local projectile = ProjectileManager:CreateLinearProjectile(slash)
			CreateSlashFx(caster, caster:GetAbsOrigin(), caster:GetAbsOrigin() + diff:Normalized() * dist)
			caster:SetAbsOrigin(caster:GetAbsOrigin() + diff:Normalized() * (dist - 100))
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

			caster:MoveToTargetToAttack(target)
		end
	end)
	
end

function OnRIHit(keys)
	local caster = keys.caster
	local target = keys.target
	DoDamage(caster, target, keys.Damage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
	target:AddNewModifier(caster, target, "modifier_stunned", {Duration = keys.StunDuration})
	target:EmitSound("Hero_Lion.FingerOfDeath")
	local slashFx = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_start_text_burst_flare.vpcf", PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( slashFx, 0, target:GetAbsOrigin() + Vector(0,0,300))

	Timers:CreateTimer( 2.0, function()
		ParticleManager:DestroyParticle( slashFx, false )
		ParticleManager:ReleaseParticleIndex( slashFx )
	end)
end

function OnTheatreCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_theatre_anim", {})


	if caster:HasModifier("modifier_aestus_domus_aurea") then 
		caster:SetMana(caster:GetMana()+800)
		keys.ability:EndCooldown()
		return 
	end
	EmitGlobalSound("Nero.Domus")
	giveUnitDataDrivenModifier(caster, caster, "pause_sealdisabled", 1.5)

	Timers:CreateTimer(1.5, function()
		if caster:IsAlive() then
			OnTheatreStart(keys)
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_aestus_domus_aurea",{})
		end
	end)
	NeroCheckCombo(caster, keys.ability)
end
function OnTheatreStart(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()

	caster:EmitSound("Hero_LegionCommander.Duel.Victory")

	--local theatreFx = ParticleManager:CreateParticle("particles/custom/nero/nero_domus_ring_energy.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	local theatreFx2 = ParticleManager:CreateParticle("particles/custom/nero/nero_domus_ring_border.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( theatreFx2, 1, Vector(keys.Radius,0,0))

	Timers:CreateTimer( keys.Duration, function()
		ParticleManager:DestroyParticle( theatreFx2, false )
		ParticleManager:ReleaseParticleIndex( theatreFx2 )
	end)	

	local banners = CreateBannerInCircle(caster, caster:GetAbsOrigin(), keys.Radius)
	--local blockers = CreateBlockerInCircle(caster:GetAbsOrigin(), keys.Radius)

	-- banner loop
	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_aestus_domus_aurea") and caster:IsAlive() then
			for i=1, #banners do
				banners[i]:SetAbsOrigin(caster:GetAbsOrigin()+banners[i].Diff)
			end

			--[[for i=1, #blockers do
				blockers[i]:SetAbsOrigin(caster:GetAbsOrigin()+blockers[i].Diff)
				--blockers = CreateBlockerInCircle(caster:GetAbsOrigin(), keys.Radius)
			end]]
			return 0.033
		else
			for i=1, #banners do
				banners[i]:RemoveSelf()
			end
			--[[for i=1, #blockers do
				DoEntFireByInstanceHandle(blockers[i], "Disable", "1", 0, nil, nil)
   				DoEntFireByInstanceHandle(blockers[i], "Kill", "1", 1, nil, nil)
			end]]
			return
		end
	end)

	-- light particle loop
	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_aestus_domus_aurea") and caster:IsAlive() then
			local lightFx = ParticleManager:CreateParticle("particles/custom/nero/nero_domus_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
			ParticleManager:SetParticleControl( lightFx, 7, caster:GetAbsOrigin())
			return 0.25
		else
			return
		end
	end)

	-- attribute loop
	if caster.IsGloryAcquired then
		Timers:CreateTimer(1.0, function()
			if caster:HasModifier("modifier_aestus_domus_aurea") and caster:IsAlive() then

				local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				local newDamage = keys.Damage * 0.35
				for k,v in pairs(targets) do
					DoDamage(caster, v, newDamage, DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
					if not IsFacingUnit(v, caster, 180) then
						local currentStack = v:GetModifierStackCount("modifier_aestus_domus_aurea_debuff_attribute", keys.ability)
						if currentStack == 0 and v:HasModifier("modifier_aestus_domus_aurea_debuff_attribute") then currentStack = 1 end
						v:RemoveModifierByName("modifier_aestus_domus_aurea_debuff_attribute")
						keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_debuff_attribute",{})
						v:SetModifierStackCount("modifier_aestus_domus_aurea_debuff_attribute", keys.ability, currentStack + 1)
					end
				end
				return 1.0
			else 
				return
			end
		end)
	end

	-- main loop
	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_aestus_domus_aurea") and caster:IsAlive() then
			--apply debuff to faceaway enemies
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_lock",{})
				if not IsFacingUnit(v, caster, 180) then
					keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_debuff",{})
					if not IsImmuneToSlow(v) then
						keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_debuff_slow",{})
					end
				end
			end

			-- buff allies
			--[[if caster.IsGloryAcquired then
				local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
				for k,v in pairs(targets) do
					keys.ability:ApplyDataDrivenModifier(keys.caster, v, "modifier_aestus_domus_aurea_ally_buff",{})
				end
			end]]
			return 0.1
		else 
			return
		end
	end)
end

function OnTheatreApplyDamage(keys)
	local target = keys.target
	local caster = keys.caster
	DoDamage(caster, target, keys.Damage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
end

function CreateBannerInCircle(handle, center, multiplier)
	local bannerTable = {}
	for i=1, 8 do
		local x = math.cos(i*math.pi/4) * multiplier
		local y = math.sin(i*math.pi/4) * multiplier
		local banner = CreateUnitByName("nero_banner", Vector(center.x + x, center.y + y, 0), true, nil, nil, handle:GetTeamNumber())

		local diff = (handle:GetAbsOrigin() - banner:GetAbsOrigin())
    	banner:SetForwardVector(diff:Normalized()) 
    	banner.Diff = diff
		table.insert(bannerTable, banner)
	end
	return bannerTable
end

function CreateBlockerInCircle(center, multiplier)
	local blockerTable = {}
	for i=-24, 24 do
		local x = math.cos(i*math.pi/24) * multiplier
		local y = math.sin(i*math.pi/24) * multiplier

		local gridNavBlocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = Vector(center.x + x, center.y + y, 0)})
		local diff = (center - gridNavBlocker:GetAbsOrigin())
		gridNavBlocker.Diff = diff
		table.insert(blockerTable, gridNavBlocker)
	end
	return blockerTable
end

function OnTheatreEnd(keys)
end


function OnNeroComboStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.IsFieryFinaleActivated = true
	local radius = caster:FindAbilityByName("nero_aestus_domus_aurea"):GetSpecialValueFor("radius")
	local flamePillarRadius = 300

	-- Set master's combo cooldown
	local masterCombo = caster.MasterUnit2:FindAbilityByName(keys.ability:GetAbilityName())
	masterCombo:EndCooldown()
	masterCombo:StartCooldown(keys.ability:GetCooldown(1))
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fiery_finale_cooldown", {duration = ability:GetCooldown(ability:GetLevel())})

	caster:FindAbilityByName("nero_tres_fontaine_ardent"):StartCooldown(21.0)

	caster.ScreenOverlay = ParticleManager:CreateParticle("particles/custom/screen_lightred_splash.vpcf", PATTACH_EYES_FOLLOW, caster)

	Timers:CreateTimer(function()
		if caster:HasModifier("modifier_aestus_domus_aurea") then
			local targetPoint = RandomPointInCircle(caster:GetAbsOrigin(), radius)
			local targets = FindUnitsInRadius(caster:GetTeam(), targetPoint, nil, flamePillarRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			-- DebugDrawCircle(targetPoint, Vector(255,0,0), 0.5, flamePillarRadius, true, 30)
			for k,v in pairs(targets) do
				DoDamage(caster, v, keys.FlameDamage , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.1})
			end

			local flameFx = ParticleManager:CreateParticle("particles/custom/nero/nero_fiery_finale_eruption.vpcf", PATTACH_ABSORIGIN, caster )
			ParticleManager:SetParticleControl( flameFx, 0, targetPoint)
			Timers:CreateTimer( 12.0, function()
				ParticleManager:DestroyParticle( flameFx, false )
				ParticleManager:ReleaseParticleIndex( flameFx )
			end)
			caster:EmitSound("Hero_Batrider.Firefly.Cast")
			--print("rawr")
			return 0.1
		else
			OnNeroComboEnd(keys)
			return
		end
	end)
end

function OnLSCStart(keys)
	local caster = keys.caster
	local target = keys.target
	EmitGlobalSound("Nero.Laus")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_laus_anim",{})
	giveUnitDataDrivenModifier(caster, caster, "jump_pause", 1.75)

	local slash = 
	{
		Ability = keys.ability,
        EffectName = "",
        iMoveSpeed = 99999,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 0,
        fStartRadius = 200,
        fEndRadius = 200,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 2.0,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * 99999
	}

	Timers:CreateTimer(0.2, function()
		OnNeroComboEnd(keys)
		if caster:IsAlive() then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				DoDamage(caster, v, v:GetMaxHealth() * 0.20 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.1})
			end		
			CreateSlashFx(caster, caster:GetAbsOrigin()+Vector(1200, 1200, 300),caster:GetAbsOrigin()+Vector(-1200, -1200, 300))
			EmitGlobalSound("FA.Quickdraw")
		end
	end)
	Timers:CreateTimer(0.5, function()
		if caster:IsAlive() then
			local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false) 
			for k,v in pairs(targets) do
				DoDamage(caster, v, v:GetMaxHealth() * 0.20 , DAMAGE_TYPE_MAGICAL, 0, keys.ability, false)
				v:AddNewModifier(caster, caster, "modifier_stunned", {Duration = 0.1})
			end		
			CreateSlashFx(caster, caster:GetAbsOrigin()+Vector(1200, -1200, 300),caster:GetAbsOrigin()+Vector(-1200, 1200, 300))
			EmitGlobalSound("FA.Quickdraw")
		end
	end)

	Timers:CreateTimer(1.75, function()
		if caster:IsAlive() then

			local diff = target:GetAbsOrigin() - caster:GetAbsOrigin()
			local dist = 3000

			slash.vSpawnOrigin = caster:GetAbsOrigin() - diff:Normalized() * 1000
			slash.vVelocity = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized() * 99999
			slash.fDistance = dist

			local projectile = ProjectileManager:CreateLinearProjectile(slash)
			CreateSlashFx(caster, slash.vSpawnOrigin, slash.vSpawnOrigin + diff:Normalized() * 3000 + Vector(0,0,300))
			if diff:Length2D() > 2000 then
				caster:SetAbsOrigin(caster:GetAbsOrigin() + diff:Normalized() * 2000)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			else
				caster:SetAbsOrigin(target:GetAbsOrigin() - diff:Normalized() * 100)
				FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			end
			EmitGlobalSound("Hero_Lion.FingerOfDeath")
		end
	end)	

end

function OnNeroComboEnd(keys)
	local caster = keys.caster
	caster.IsFieryFinaleActivated = false
	ParticleManager:DestroyParticle( caster.ScreenOverlay, false )
	ParticleManager:ReleaseParticleIndex( caster.ScreenOverlay )
	caster:RemoveModifierByName("modifier_aestus_domus_aurea")
end

function NeroTakeDamage(keys)
	local caster = keys.caster
	local ply = caster:GetPlayerOwner()
	local damageTaken = keys.damageTaken
	local healCounter = 0


	if caster:GetHealth() == 0 and IsRevivePossible(caster) and caster.IsISAcquired and not caster:HasModifier("modifier_invictus_spiritus_cooldown") and not IsRevoked(caster) then
		
		caster:EmitSound("Hero_SkeletonKing.Reincarnate")
		caster:SetHealth(1)
		Timers:CreateTimer(function()
			if healCounter == 3 or not caster:IsAlive() then return end
			caster:SetHealth(caster:GetHealth() + caster:GetMaxHealth() * 0.1)
			healCounter = healCounter + 1
			return 1.0
		end)
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_invictus_spiritus",{})
		giveUnitDataDrivenModifier(keys.caster, keys.caster, "rb_sealdisabled", 4.5)
		caster:FindAbilityByName("nero_invictus_spiritus"):ApplyDataDrivenModifier(caster, caster, "modifier_invictus_spiritus_cooldown", {duration = 60})
	end
end

function OnISStart(keys)
end

function NeroCheckCombo(caster, ability)
	if caster:GetStrength() >= 19.1 and caster:GetAgility() >= 19.1 and caster:GetIntellect() >= 19.1 then
		if ability == caster:FindAbilityByName("nero_aestus_domus_aurea") and caster:FindAbilityByName("nero_tres_fontaine_ardent"):IsCooldownReady() and caster:FindAbilityByName("nero_fiery_finale"):IsCooldownReady() then
			caster:SwapAbilities("nero_tres_fontaine_ardent", "nero_fiery_finale", true, true) 
			Timers:CreateTimer({
				endTime = 3,
				callback = function()
				caster:SwapAbilities("nero_tres_fontaine_ardent", "nero_fiery_finale", true, true) 
			end
			})			
		end
	end
end


function OnPTBAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsPTBAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnPrivilegeImproved(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsPrivilegeImproved = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnISAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsISAcquired = true
    hero.IsISOnCooldown = false
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end

function OnGloryAcquired(keys)
    local caster = keys.caster
    local ply = caster:GetPlayerOwner()
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    hero.IsGloryAcquired = true
    -- Set master 1's mana 
    local master = hero.MasterUnit
    master:SetMana(master:GetMana() - keys.ability:GetManaCost(keys.ability:GetLevel()))
end