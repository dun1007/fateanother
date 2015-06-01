function OnArmedUpStart(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0) -- Soulstream
	local a2 = caster:GetAbilityByIndex(1) -- Subterranean Grasp
	local a3 = caster:GetAbilityByIndex(2) -- Mantra
	local a4 = caster:GetAbilityByIndex(3) -- Armed Up
	local a5 = caster:GetAbilityByIndex(4) -- fate_empty1
	local a6 = caster:GetAbilityByIndex(5) -- Amaterasu

	caster:SwapAbilities("tamamo_fiery_heaven", a1:GetName(), true, true) 
	caster:SwapAbilities("tamamo_frigid_heaven", a2:GetName(), true, true) 
	caster:SwapAbilities("tamamo_gust_heaven", a3:GetName(), true, true) 
	caster:SwapAbilities("fate_empty2", a4:GetName(), true, true) 
	caster:SwapAbilities("tamamo_close_spellbook", a5:GetName(), true,true) 
	caster:SwapAbilities("fate_empty3", a6:GetName(), true, true) 
end

function OnFireCharmLoaded(keys)
	CloseCharmList(keys)
end

function OnFreezeCharmLoaded(keys)
	CloseCharmList(keys)
end

function OnGustCharmLoaded(keys)
	CloseCharmList(keys)
end

function OnVoidCharmLoaded(keys)
	CloseCharmList(keys)
end

function OnCharmListClosed(keys)
	local caster = keys.caster
	local armedUp = caster:FindAbilityByName("tamamo_armed_up")
	armedUp:EndCooldown() 

	CloseCharmList(keys)
end

function CloseCharmList(keys)
	local caster = keys.caster
	local a1 = caster:GetAbilityByIndex(0) -- Fiery Heaven
	local a2 = caster:GetAbilityByIndex(1) -- Frigid Heaven
	local a3 = caster:GetAbilityByIndex(2) -- Gust Heaven
	local a4 = caster:GetAbilityByIndex(3) -- fate_empty2
	local a5 = caster:GetAbilityByIndex(4) -- close spellbook
	local a6 = caster:GetAbilityByIndex(5) -- fate_empty3/Void Cleft

	caster:SwapAbilities("tamamo_soulstream", a1:GetName(), true, true) 
	caster:SwapAbilities("tamamo_subterranean_grasp", a2:GetName(), true, true) 
	caster:SwapAbilities("tamamo_mantra", a3:GetName(), true, true) 
	caster:SwapAbilities("tamamo_armed_up", a4:GetName(), true, true) 
	caster:SwapAbilities("fate_empty1", a5:GetName(), true,true) 
	caster:SwapAbilities("tamamo_amaterasu", a6:GetName(), true, true) 

end

function OnSoulstreamStart(keys)
end

function OnSGStart(keys)
end

function OnMantraStart(keys)
end

function OnAmaterasuStart(keys)
end

function OnKickStart(keys)
end

function OnSpiritTheftAcquired(keys)
end

function OnSeveredFateAcquired(keys)
end

function OnPCFAcquired(keys)
end

function OnWitchcraftAcquired(keys)
end