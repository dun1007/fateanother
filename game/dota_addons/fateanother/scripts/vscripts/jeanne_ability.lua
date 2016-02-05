
function OnMREXDamageTaken(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
	ChangeMREXStack(keys, -1)
end


function OnMREXRecharge(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
	ChangeMREXStack(keys, 1)
end

function OnMREXRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex", {})
	ChangeMREXStack(keys, 4)
end

function ChangeMREXStack(keys, modifier)
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = keys.MaxStack

	if not caster.nMREXStack then caster.nMREXStack = 0 end
	if not caster:HasModifier("modifier_magic_resistance_ex_shield") then ability:ApplyDataDrivenModifier(caster, caster, "modifier_magic_resistance_ex_shield", {}) end 

	local newStack = caster.nMREXStack + modifier
	if newStack < 0 then 
		newStack = 0 
	elseif newStack > maxStack then
		newStack = maxStack
	end

	if newStack == 0 then
		caster:RemoveModifierByName("modifier_magic_resistance_ex_shield")
	else
		caster:SetModifierStackCount("modifier_magic_resistance_ex_shield", caster, newStack)
	end
	caster.nMREXStack = newStack
end

function OnSaintRespawn(keys)
	local caster = keys.caster
	local ability = keys.ability

    LoopOverPlayers(function(player, playerID, playerHero)
    	--print("looping through " .. playerHero:GetName())
        if playerHero:GetTeamNumber() ~= caster:GetTeamNumber() then
        	if playerHero:HasModifier("modifier_saint_debuff") then
        		playerHero:RemoveModifierByName("modifier_saint_debuff")
        	end
        	ability:ApplyDataDrivenModifier(caster, playerHero, "modifier_saint_debuff", {})
        	playerHero:EmitSound("Hero_Chen.TestOfFaith.Cast")
        end
    end)
end

function template(keys)
	local caster = keys.caster
	local ability = keys.ability
end