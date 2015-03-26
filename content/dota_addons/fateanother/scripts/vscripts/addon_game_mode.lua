-- Generated from template
require( "timers")
require( "saber_ability")
require( 'spell_shop_UI' )
require( 'util' )

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end


-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end


function PrecacheEveryThingFromKV( context )
	local kv_files = {"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_abilities_override.txt","npc_items_custom.txt"}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
end
function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end
end
function Precache( context )
	PrecacheEveryThingFromKV( context )
end


function CAddonTemplateGameMode:InitGameMode()
	SpellShopUI:InitGameMode();
	GameRules:SetHeroSelectionTime(60.0)
	GameRules:SetPreGameTime(0)
	GameRules:SetPostGameTime(0)
	GameRules:SetGoldPerTick(0)
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))
	--ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CAddonTemplateGameMode, "OnPlayerPicked" ), self )
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonTemplateGameMode, "OnNPCSpawned" ), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(CAddonTemplateGameMode, 'OnGameRulesStateChange'), self)
end

function CAddonTemplateGameMode:OnGameRulesStateChange(keys)
  	print("GameRules State Changed")

  	local newState = GameRules:State_Get()
  	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    	CAddonTemplateGameMode:OnGameInProgress()
  	end
end

function CAddonTemplateGameMode:OnGameInProgress()
	 Timers:CreateTimer(function()
      	local choice = RandomInt(1,4)
      	print(choice)
		print("playing music!")
		if choice == 1 then EmitGlobalSound("BGM.Excalibur")
			elseif choice == 2 then EmitGlobalSound("BGM.Mightywind")
			elseif choice == 3 then EmitGlobalSound("BGM.Emiya")
			else EmitGlobalSound("BGM.Unmeinoyoru")
		end
		return 181
    end
  	)
end


-- Give everyone basic abilities at level 1
function CAddonTemplateGameMode:OnNPCSpawned(keys)
    local hero = EntIndexToHScript(keys.entindex)
    print(hero:GetAbilityCount())
    for i=0, 30 do
    	local ability = hero:GetAbilityByIndex(i)
    	if ability ~= nil then
        	ability:SetLevel(1)
        else
        	return
        end
    end
end

function CAddonTemplateGameMode:OnAbilityCast(event)
	--GameRules:SendCustomMessage("<font color='#58ACFA'>COMBO : Max Excalibur</font> is now ready to use. (Command : R-E)", PlayerResource:GetTeam(event.PlayerID-1), 0)
	--local messageinfo = {
	--	message = "Combo Ready(Command : R-E)",
	--	duration = 10
	--}
	--FireGameEvent("show_center_message", messageinfo)
	--ShowCustomHeaderMessage("lawlawlalw", event.PlayerID-1, 0, 5)

end

function CAddonTemplateGameMode:CheckComboRequirement(event)
	combo_table = {
		saber_combo = {5,2}, -- ability index : Avalon(5) - Excalibur(2)
		archer_5th_combo = {5, 4}, -- UBW(5) - Rho Aias(4)
		lancer_5th_combo = {1, 2} -- Relentless Spear(1) - Gae Bolg(2)
	}
end

function PlaySpawnSound(player) 
end
