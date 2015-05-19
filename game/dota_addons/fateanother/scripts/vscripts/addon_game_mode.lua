require("timers")
require('util' )
require('archer_ability')
require('master_ability')
require('xLib/xDialog')
require('gille_ability')

-- Load Stat collection (statcollection should be available from any script scope)
require('lib.statcollection')
statcollection.addStats({
  modID = '8b2dca1df6a65593f2eb2c5a1d8038f1' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

ENABLE_HERO_RESPAWN = false             -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 60.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 0                       -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                       -- How much gold should players get per tick?
GOLD_TICK_TIME = 0                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1250.0        -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false      -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = true       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false               -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 9999         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 24                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

XP_TABLE = {}
XP_PER_LEVEL_TABLE = {}
BOUNTY_PER_LEVEL_TABLE = {}
XP_BOUNTY_PER_LEVEL_TABLE = {}
mode = nil
FATE_VERSION = "Beta Version"
IsPickPhase = true
IsPreRound = false

XP_TABLE[0] = 0
XP_TABLE[1] = 200
for i=2,MAX_LEVEL do
  XP_TABLE[i] = XP_TABLE[i-1] + i * 100  -- XP required per level formula : Previous level XP requirement + Level * 100
end

-- EXP required to reach next level
XP_PER_LEVEL_TABLE[0] = 0
XP_PER_LEVEL_TABLE[1] = 200
XP_PER_LEVEL_TABLE[24] = 0
for i=2,MAX_LEVEL-1 do
  XP_PER_LEVEL_TABLE[i] = XP_TABLE[i+1] - XP_TABLE[i]  -- XP required per level formula : Previous level XP requirement + Level * 100
end

for i=1, MAX_LEVEL do
  BOUNTY_PER_LEVEL_TABLE[i] = 1000 + i * 100 -- Bounty gold formula : 1000 + Level * 100
end

XP_BOUNTY_PER_LEVEL_TABLE[1] = 124
for i=2, MAX_LEVEL do
  XP_BOUNTY_PER_LEVEL_TABLE[i] = XP_BOUNTY_PER_LEVEL_TABLE[i-1]*1 + i*4 + 120 -- Bounty XP formula : Previous level XP + Current Level * 4 + 120(constant)
end

if FateGameMode == nil then
	FateGameMode = class({})
end


-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = FateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

--[[
	Lookup table
	models/saber/saber.vmdl					npc_dota_hero_legion_commander
	models/lancer/lancer.vmdl				npc_dota_hero_phantom_lancer
	models/saber_alter/sbr_alter.vmdl		npc_dota_hero_spectre
	models/archer/archertest.vmdl			npc_dota_hero_ember_spirit
	models/rider/rider.vmdl					npc_dota_hero_templar_assassin
	models/berserker/berserker.vmdl			npc_dota_hero_doom_bringer
	models/assassin/asn.vmdl				npc_dota_hero_juggernaut
	models/true_assassin/ta.vmdl			npc_dota_hero_bounty_hunter
	models/caster/caster.vmdl				npc_dota_hero_crystal_maiden
	models/gilgamesh/gilgamesh.vmdl			npc_dota_hero_skywrath_mage
		
	For adding more model
	model_lookup[""] = ""
]]
model_lookup = {}
model_lookup["npc_dota_hero_legion_commander"] = "models/saber/saber.vmdl"
model_lookup["npc_dota_hero_phantom_lancer"] = "models/lancer/lancer2.vmdl"
model_lookup["npc_dota_hero_spectre"] = "models/saber_alter/sbr_alter.vmdl"
model_lookup["npc_dota_hero_ember_spirit"] = "models/archer/archertest.vmdl"
model_lookup["npc_dota_hero_templar_assassin"] = "models/rider/rider.vmdl"
model_lookup["npc_dota_hero_doom_bringer"] = "models/berserker/berserker.vmdl"
model_lookup["npc_dota_hero_juggernaut"] = "models/assassin/asn.vmdl"
model_lookup["npc_dota_hero_bounty_hunter"] = "models/true_assassin/ta.vmdl"
model_lookup["npc_dota_hero_crystal_maiden"] = "models/caster/caster.vmdl"
model_lookup["npc_dota_hero_skywrath_mage"] = "models/gilgamesh/gilgamesh.vmdl"
model_lookup["npc_dota_hero_sven"] = "models/lancelot/lancelot.vmdl"
model_lookup["npc_dota_hero_vengefulspirit"] = "models/avenger/avenger.vmdl"
model_lookup["npc_dota_hero_huskar"] = "models/diarmuid/diarmuid2.vmdl"
model_lookup["npc_dota_hero_chen"] = "models/iskander/iskander.vmdl"
model_lookup["npc_dota_hero_shadow_shaman"] = "models/zc/gille.vmdl"
model_lookup["npc_dota_hero_lina"] = "models/nero/nero.vmdl"
model_lookup["npc_dota_hero_omniknight"] = "models/gawain/gawain.vmdl"

function Precache( context )
    print("Starting precache")
  	--PrecacheUnitByNameSync("npc_precache_everything", context)

    -- Sound files
    PrecacheResource("soundfile", "soundevents/bgm.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/misc_sound.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_archer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_avenger.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_caster.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_berserker.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_fa.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_gilg.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_iskander.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_lancelot.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_lancer.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_rider.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_saber.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_saber_alter.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_ta.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_zc.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_zl.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_nero.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_gawain.vsndevts", context)

    -- Items
    PrecacheItemByNameSync("item_apply_modifiers", context)
    PrecacheItemByNameSync("item_mana_essence", context)
    PrecacheItemByNameSync("item_condensed_mana_essence", context)
    PrecacheItemByNameSync("item_teleport_scroll", context)
    PrecacheItemByNameSync("item_gem_of_speed", context)
    PrecacheItemByNameSync("item_scout_familiar", context)
    PrecacheItemByNameSync("item_berserk_scroll", context)
    PrecacheItemByNameSync("item_ward_familiar", context)
    PrecacheItemByNameSync("item_mass_teleport_scroll", context)
    PrecacheItemByNameSync("item_gem_of_resonance", context)
    PrecacheItemByNameSync("item_blink_scroll", context)
    PrecacheItemByNameSync("item_spirit_link" , context)
    PrecacheItemByNameSync("item_c_scroll", context)
    PrecacheItemByNameSync("item_b_scroll", context)
    PrecacheItemByNameSync("item_a_scroll", context)
    PrecacheItemByNameSync("item_a_plus_scroll", context)
    PrecacheItemByNameSync("item_s_scroll", context)
    PrecacheItemByNameSync("item_ex_scroll", context)
    PrecacheItemByNameSync("item_summon_skeleton_warrior", context)
    PrecacheItemByNameSync("item_summon_skeleton_archer", context)
    PrecacheItemByNameSync("item_summon_ancient_dragon", context)
    PrecacheItemByNameSync("item_all_seeing_orb", context)
    PrecacheItemByNameSync("item_shard_of_anti_magic", context)
    PrecacheItemByNameSync("item_shard_of_replenishment", context)

    -- Master and Stash
    PrecacheResource("model", "models/shirou/shirouanim.vmdl", context)
    PrecacheResource("model", "models/items/courier/catakeet/catakeet_boxes.vmdl", context)
    PrecacheResource("model", "models/tohsaka/tohsaka.vmdl", context)

    -- Servants
    PrecacheResource("model", "models/saber/saber.vmdl", context)
    PrecacheResource("model", "models/lancer/lancer2.vmdl", context)
    PrecacheResource("model", "models/saber_alter/sbr_alter.vmdl", context)
    PrecacheResource("model", "models/archer/archertest.vmdl", context)
    PrecacheResource("model", "models/rider/rider.vmdl", context)
    PrecacheResource("model", "models/berserker/berserker.vmdl", context)
    PrecacheResource("model", "models/assassin/asn.vmdl", context)
    PrecacheResource("model", "models/true_assassin/ta.vmdl", context)
    PrecacheResource("model", "models/caster/caster.vmdl", context)
    PrecacheResource("model", "models/gilgamesh/gilgamesh.vmdl", context)
    PrecacheResource("model", "models/lancelot/lancelot.vmdl", context)
    PrecacheResource("model", "models/avenger/avenger.vmdl", context)
    PrecacheResource("model", "models/diarmuid/diarmuid.vmdl", context)
    PrecacheResource("model", "models/diarmuid/diarmuid2.vmdl", context)
    PrecacheResource("model", "models/iskander/iskander.vmdl", context)
    PrecacheResource("model", "models/zc/gille.vmdl", context)
    PrecacheResource("model", "models/nero/nero.vmdl", context)
    PrecacheResource("model", "models/gawain/gawain.vmdl", context)

    -- AOTK Soldier assets
    PrecacheResource("model_folder", "models/heroes/chen", context)
    PrecacheResource("model_folder", "models/items/chen", context)
    PrecacheResource("model_folder", "models/heroes/dragon_knight", context)
    PrecacheResource("model_folder", "models/items/dragon_knight", context)
    PrecacheResource("model_folder", "models/heroes/chaos_knight", context)
 	  PrecacheResource("model_folder", "models/items/chaos_knight", context)
    PrecacheResource("model_folder", "models/heroes/silencer", context)
    PrecacheResource("model_folder", "models/items/silencer", context)
    PrecacheResource("model_folder", "models/heroes/windrunner", context)
    PrecacheResource("model_folder", "models/items/windrunner", context)

  	print("precache complete")
end

function FateGameMode:PostLoadPrecache()
  print("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_legion_commander", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_phantom_lancer", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_spectre", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_ember_spirit", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_templar_assassin", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_doom_bringer", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_juggernaut", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_bounty_hunter", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_crystal_maiden", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_skywrath_mage", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_sven", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_vengefulspirit", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_huskar", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_chen", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_shadow_shaman", function(...) end)
  --PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitFateGameMode() but needs to be done before everyone loads in.
]]
function FateGameMode:OnFirstPlayerLoaded()
  print("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function FateGameMode:OnAllPlayersLoaded()
  	print("[BAREBONES] All Players have loaded into the game")
	GameRules:SendCustomMessage("Fate/Another " .. FATE_VERSION .. " by Dun1007", 0, 0)
	--GameRules:SendCustomMessage("Game is currently in alpha phase of development and you may run into major issues that I hope to address ASAP. Please wait patiently for the official release.", 0, 0)
	GameRules:SendCustomMessage("Choose your heroic spirit. The game will start in 60 seconds.", 0, 0)
  --GameStartTimerStart()
  StartQuestTimer("pickTimerQuest", "Hero Pick Time Remaining", 60)

  	Timers:CreateTimer('30secondalert', {
		endTime = 30,
		callback = function()

  	GameRules:SendCustomMessage("The game will start in 30 seconds. Anyone who haven't picked hero by then will be assigned a random hero.", 0, 0)
    GameRules:SendCustomMessage("Forced random is disbled for the time being, but please decide on your pick as soon as possible before 60 seconds mark.", 0, 0)
    DisplayTip()
	end
	})
  	Timers:CreateTimer('startgame', {
		endTime = 60,
		callback = function()
    IsPickPhase = false
    for i=0,9 do
      local ply = PlayerResource:GetPlayer(i)
      if ply and ply:GetAssignedHero() == nil then
        --ply:MakeRandomHeroSelection()
        --AssignRandomHero(ply)
      end
    end
    self.nCurrentRound = 1
    self:InitializeRound() -- Start the game after forcing a pick for every player
	end
	})
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.
  The hero parameter is the hero entity that just spawned in
]]
function FateGameMode:OnHeroInGame(hero)
  print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

    hero:SetGold(0, false)
    LevelAllAbility(hero)
    hero:AddItem(CreateItem("item_blink_scroll", nil, nil) )  -- Give blink scroll
    hero.CStock = 10
    hero.RespawnPos = hero:GetAbsOrigin() 
    --HideWearables(hero)
    if self.nCurrentRound == 0 then
      giveUnitDataDrivenModifier(hero, hero, "round_pause", 75)
    elseif self.nCurrentRound >= 1 then 
      hero:ModifyGold(3000, true, 0) 
      giveUnitDataDrivenModifier(hero, hero, "round_pause", 10)
    end

    local heroName = FindName(hero:GetName())
    hero.name = heroName
    GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. heroName .. "</font> has been summoned. Check your Master in the bottom right of the map.", 0, 0)
    --[[UTIL_MessageText(hero:GetPlayerID()+1,"IMPORTANT : You can provide your hero with item support, customize your hero and cast powerful Command Seal as a Master, located on the right bottom of the map. ",255,255,255,255)
    Timers:CreateTimer(30.0, function() 
      UTIL_ResetMessageText(hero:GetPlayerID()+1)
    end)  ]]

  -- This is needed because model is somehow not yet rendered while this is called, so we need a little bit of delay
  Timers:CreateTimer( 3.0, function()
      -- Setup variables\
      local model_name = ""
      
      -- Check if npc is hero
      if IsValidEntity(hero) then
       if not hero:IsHero() then return end
      else return 
      end
      
      -- Getting model name
      if model_lookup[ hero:GetName() ] ~= nil and hero:GetModelName() ~= model_lookup[ hero:GetName() ] then
        model_name = model_lookup[ hero:GetName() ]
        -- print( "Swapping in: " .. model_name )
      else
        return nil
      end
      
      -- Check if it's correct format
      if hero:GetModelName() ~= "models/development/invisiblebox.vmdl" then return nil end
      
      -- Never got changed before
      local toRemove = {}
      local wearable = hero:FirstMoveChild()
      while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
          -- print( "Removing wearable: " .. wearable:GetModelName() )
          table.insert( toRemove, wearable )
        end
        wearable = wearable:NextMovePeer()
      end
      
      -- Remove wearables
      for k, v in pairs( toRemove ) do
        v:SetModel( "models/development/invisiblebox.vmdl" )
        v:RemoveSelf()
      end
      
      -- Set model
      hero:SetModel( model_name )
      hero:SetOriginalModel( model_name )     -- This is needed because when state changes, model will revert back
      hero:MoveToPosition( hero:GetAbsOrigin() )  -- This is needed because when model is spawned, it will be in T-pose
    end
  )
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function FateGameMode:OnGameInProgress()
	print("[FATE] The game has officially begun")
  local lastChoice = 0
  local delayInBetween = 2.0
  for i=0, 10 do
      local player = PlayerResource:GetPlayer(i)
      if player ~= nil then
        PlayBGM(player)
      end
  end
end

choice = 0 --
function PlayBGM(player)
  local delayInBetween = 2.0

  Timers:CreateTimer("BGMTimer" .. player:GetPlayerID(), {
    endTime = 0,
    callback = function()
    choice = RandomInt(1,8)
    if choice == lastChoice then return 0.1 end
    print("Playing BGM No. " .. choice)
    local songName = "BGM." .. choice
    player.CurrentBGM = songName
    if choice == 1 then EmitSoundOnClient(songName, player) lastChoice = 1 return 186+delayInBetween
    elseif choice == 2 then EmitSoundOnClient(songName, player) lastChoice = 2 return 327+delayInBetween
    elseif choice == 3 then EmitSoundOnClient(songName, player)  lastChoice = 3 return 138+delayInBetween
    elseif choice == 4 then  EmitSoundOnClient(songName, player) lastChoice = 4 return 149+delayInBetween
    elseif choice == 5 then  EmitSoundOnClient(songName, player) lastChoice = 5 return 183+delayInBetween
    elseif choice == 6 then  EmitSoundOnClient(songName, player) lastChoice = 6 return 143+delayInBetween
    elseif choice == 7 then  EmitSoundOnClient(songName, player) lastChoice = 7 return 184+delayInBetween
    else EmitSoundOnClient(songName, player) lastChoice = 8 return 181+delayInBetween end
  end})
end



-- Cleanup a player when they leave
function FateGameMode:OnDisconnect(keys)
  print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid
  
  table.remove(self.vPlayerList, userid) -- remove player from list

end

function FateGameMode:PlayerSay(keys)
  print ('[BAREBONES] PlayerSay')
  if keys == nil then print("empty keys") end
  PrintTable(keys)

  -- Get the player entity for the user speaking
  local ply = keys.ply
  local hero = ply:GetAssignedHero()
  -- Get the player ID for the user speaking
  local plyID = ply:GetPlayerID()
  if not PlayerResource:IsValidPlayer(plyID) then
    return
  end
  
  -- Should have a valid, in-game player saying something at this point
  -- The text the person said
  local text = keys.text
  
  -- Match the text against something
  local matchA, matchB = string.match(text, "^-swap%s+(%d)%s+(%d)")
  if matchA ~= nil and matchB ~= nil then
    -- Act on the match
  end

  if text == "-endgame" then 
    GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
    GameRules:Defeated()
  end 
  -- Below two commands are solely for test purpose, not to be used in normal games
  if text == "-testsetup" then
    hero.MasterUnit:SetMana(hero.MasterUnit:GetMaxMana()) 
    hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMaxMana())
    if hero:GetName() == "npc_dota_hero_juggernaut" then
      hero:SetBaseStrength(25)
      hero:SetBaseAgility(25) 
    else 
      hero:SetBaseStrength(20) 
      hero:SetBaseAgility(20) 
      hero:SetBaseIntellect(20) 
    end
  end

  if text == "-unpause" then
    --[[for _,plyr in pairs(self.vPlayerList) do
      local hr = plyr:GetAssignedHero()
      hr:RemoveModifierByName("round_pause")
    end]]
    self:LoopOverPlayers(function(player, playerID)
      local hr = player:GetAssignedHero()
      hr:RemoveModifierByName("round_pause")
      --print("Looping through player" .. ply)
    end)
  end

  -- Turns BGM on and off
  if text == "-bgmoff" then
    print("Turning BGM off")
    Timers:RemoveTimer("BGMTimer" .. ply:GetPlayerID())
    ply:StopSound(ply.CurrentBGM)
  end

  if text == "-bgmon" then
    PlayBGM(ply)
  end

  if text == "-xptable" then
    PrintTable(XP_TABLE)
  end

  if text == "-xplvltable" then
    PrintTable(XP_PER_LEVEL_TABLE)
  end

  if text == "-xpbountytable" then
    PrintTable(XP_BOUNTY_PER_LEVEL_TABLE)
  end

  -- Sends a message to request gold
  local pID, goldAmt = string.match(text, "^-(%d) (%d+)")
  if pID ~= nil and goldAmt ~= nil then
    if PlayerResource:GetReliableGold(plyID) > tonumber(goldAmt) and plyID ~= tonumber(pID) then 
      local targetHero = PlayerResource:GetPlayer(tonumber(pID)):GetAssignedHero()
      hero:ModifyGold(-tonumber(goldAmt), true , 0) 
      targetHero:ModifyGold(tonumber(goldAmt), true, 0)

      GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> sent " .. goldAmt .. " gold to <font color='#58ACFA'>" .. targetHero.name .. "</font>" , ply:GetTeam(), 0)
    end
  end

  -- Asks team for gold
  if text == "-goldpls" then
    GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (gold amount) </font>to help him out!" , ply:GetTeam(), 0)
  end
end
-- The overall game state has changed
function FateGameMode:OnGameRulesStateChange(keys)
  print("[BAREBONES] GameRules State Changed")
  PrintTable(keys)

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        if PlayerResource:HaveAllPlayersJoined() then
          --FateGameMode:PostLoadPrecache()
          FateGameMode:OnAllPlayersLoaded()
          return 
        end
        return 1
      end
      })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    FateGameMode:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function FateGameMode:OnNPCSpawned(keys)
    print("[BAREBONES] NPC Spawned")
	--PrintTable(keys)
	local hero = EntIndexToHScript(keys.entindex)

	if hero:IsRealHero() and hero.bFirstSpawned == nil and hero:GetPlayerOwner() ~= nil then
      print("Set unit's EXP bounty to " .. XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()])
      hero:SetCustomDeathXP(XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()])
	    hero.bFirstSpawned = true
      hero.PresenceTable = {}
	    FateGameMode:OnHeroInGame(hero)
      hero:SetAbilityPoints(0)
	    local player = PlayerResource:GetPlayer(hero:GetPlayerID())
      --Add a non-player hero to player list if it's missing(i.e generated by -createhero)
      if self.vBots[hero:GetPlayerID() + 1] == 1 then 
        print((hero:GetPlayerID()+1) .." is a bot!") 
        self.vPlayerList[hero:GetPlayerID() + 1] = player
      end

      -- Create Command Seal master for hero
	    master = CreateUnitByName("master_1", Vector(4500 + hero:GetPlayerID()*350,-7150,0), true, hero, hero, hero:GetTeamNumber())
	    master:SetControllableByPlayer(hero:GetPlayerID(), true) 
      master:SetMana(0)
      hero.MasterUnit = master
      LevelAllAbility(master)
      master:AddItem(CreateItem("item_master_transfer_items1", nil, nil))
      master:AddItem(CreateItem("item_master_transfer_items2", nil, nil))
      master:AddItem(CreateItem("item_master_transfer_items3", nil, nil))
      master:AddItem(CreateItem("item_master_transfer_items4", nil, nil))
      master:AddItem(CreateItem("item_master_transfer_items5", nil, nil))
      master:AddItem(CreateItem("item_master_transfer_items6", nil, nil))

      -- Create attribute/stat master for hero
      master2 = CreateUnitByName("master_2", Vector(4500 + hero:GetPlayerID()*350,-7350,0), true, hero, hero, hero:GetTeamNumber())
      master2:SetControllableByPlayer(hero:GetPlayerID(), true) 
      master2:SetMana(0)
      hero.MasterUnit2 = master2
      AddMasterAbility(master2, hero:GetName())
      LevelAllAbility(master2)

      -- Create personal stash for hero
      masterStash = CreateUnitByName("master_stash", Vector(4500 + hero:GetPlayerID()*350,-7250,0), true, hero, hero, hero:GetTeamNumber())
      masterStash:SetControllableByPlayer(hero:GetPlayerID(), true)
      masterStash:SetAcquisitionRange(200)
      hero.MasterStash = masterStash
      LevelAllAbility(masterStash)

      local pingsign = CreateUnitByName("ping_sign", Vector(0,0,0), true, hero, hero, hero:GetTeamNumber())
      pingsign:FindAbilityByName("ping_sign_passive"):SetLevel(1)
      pingsign:SetAbsOrigin(Vector(4500 + hero:GetPlayerID()*350,-6500,0))

	end
end

-- This is for swapping hero models in
function FateGameMode:OnHeroSpawned( keys )

end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function FateGameMode:OnEntityHurt(keys)
  --print("[BAREBONES] Entity Hurt")
  --PrintTable(keys)
  local entCause = EntIndexToHScript(keys.entindex_attacker)
  local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function FateGameMode:OnItemPickedUp(keys)
  print ( '[BAREBONES] OnItemPickedUp' )
  PrintTable(keys)

  local heroEntity = nil
  local player = nil
  if keys.HeroEntityIndex ~= nil then
    heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
    player = PlayerResource:GetPlayer(keys.PlayerID)
  end
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function FateGameMode:OnPlayerReconnect(keys)
  print ( '[BAREBONES] OnPlayerReconnect' )
  PrintTable(keys) 
  local userid = keys.PlayerID
end

-- An item was purchased by a player
function FateGameMode:OnItemPurchased( keys )
    print ( '[BAREBONES] OnItemPurchased : Purchased ' .. keys.itemname )
    --PrintTable(keys)

    -- The playerID of the hero who is buying something
    local plyID = keys.PlayerID
    local ply = PlayerResource:GetPlayer(plyID)
    if not plyID then return end

    -- The name of the item purchased
    local itemName = keys.itemname 
      -- The cost of the item purchased
    local itemCost = keys.itemcost

    local hero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
    --[[ItemsKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    for k,v in pairs(ItemsKV) do
      if string.find(v, "recipe") then
      end
    end]]
    local oldStash = GetStashItems(hero)



    if hero.IsInBase == false then
      if PlayerResource:GetReliableGold(plyID) + itemCost < itemCost * 1.5 then
        -- This will take care of non-component items
        for i = 1, #oldStash do
          if oldStash[i]:GetName() == itemName then
            FireGameEvent( 'custom_error_show', { player_ID = plyID, _error = "Not Enough Gold(Items cost 50% more)" } )
            hero:RemoveItem(oldStash[i])
            hero:ModifyGold(itemCost, true, 0)
            break
          end
        end
      else
        print("Deducing extra cost" .. itemCost*0.5 .. "from player gold")
        hero:ModifyGold(-itemCost*0.5, true , 0) 
      end
    -- If hero is in base, check for C scroll stock
    else
       -- If hero is in base, check for C scroll stock
      if itemName == "item_c_scroll" then
        if hero.CStock > 0 then 
          hero.CStock = hero.CStock - 1
        else 
          for i = 1, #oldStash do
            if oldStash[i]:GetName() == "item_c_scroll" then
              FireGameEvent( 'custom_error_show', { player_ID = plyID, _error = "Out Of Stock" } )
              hero:RemoveItem(oldStash[i])
              hero:ModifyGold(itemCost, true, 0)
              break
            end
          end
        end
      end
    end

    --[[Timers:CreateTimer(0.033, function()
      local purchasedItem = FindItemInStash(hero, itemName)
      local IsComponent = false
      local newStash = GetStashItems(hero)
      local itemDifference = FindStashDifference(oldStash, newStash)
      for i = 1, #newStash do
        print("New Item in Stash : " .. newStash[i]:GetName())
      end
      for i = 1, #itemDifference do
        print("Item Difference : " .. itemDifference[i]:GetName())
      end

      -- If hero is out of base and does not have enough gold
      if hero.IsInBase == false and hero:GetGold() + itemCost < itemCost * 1.5 then
        print("Hero owning gold : " .. hero:GetGold())
        print("Item cost outside of base : " .. itemCost*1.5)
        FireGameEvent( 'custom_error_show', { player_ID = plyID, _error = "Not Enough Gold(Items cost 50% more)" } )
        -- process component items
        if itemName == "item_c_scroll" then
          local BScroll = FindItemInStash(hero, "item_b_scroll") -- check if c scroll is already combined
          if BScroll ~= nil then 
            IsComponent = true
            print("B Scroll found, removing it and creating C scroll")
            hero:RemoveItem(BScroll)
            CreateItemAtSlot(hero, "item_c_scroll", 6)
          end
        end
        if itemName == "item_mana_essence" then
          local pot = FindItemInStash(hero, "item_condensed_mana_essence")
          if pot ~= nil then
            IsComponent = true
            print("Condesned Mana Essence found, removing it and creating regular pot")
            hero:RemoveItem(pot)
            CreateItemAtSlot(hero,"item_mana_essence", 6)
          end
        end
        if itemName == "item_recipe_healing_scroll" then
          print("reached")
          local healScroll =  FindItemInStash(hero, "item_healing_scroll")
          if healScroll ~= nil then
            IsComponent = true
            print("Heal Scroll found, removing it and creating mana essence")
            hero:RemoveItem(healScroll)
            CreateItemAtSlot(hero,"item_mana_essence", 6)
          end
        end
        if itemName == "item_recipe_a_plus_scroll" then
          local APlusScroll =  FindItemInStash(hero, "item_a_plus_scroll")
          if APlusScroll ~= nil then
            IsComponent = true
            print("A Plus Scroll found, removing it and creating A scroll")
            hero:RemoveItem(APlusScroll)
            CreateItemAtSlot(hero,"item_a_scroll", 6)
          end
        end
        if not IsComponent then
          hero:RemoveItem(purchasedItem)
        end

        hero:ModifyGold(itemCost, true, 0)

      -- if hero has enough gold, deduce the extra cost
      else
        hero:ModifyGold(-itemCost*0.5, true , 0) 
      end
      
      return 
    end
    )]]

end


function GetStashItems(hero)
  local stashTable = {}
  for i=6,11 do
    local heroItem = hero:GetItemInSlot(i) 
    if heroItem ~= nil then
      table.insert(stashTable, heroItem)
    end
  end
  return stashTable
end

function FindItemInStash(hero, itemname)
  for i=6, 11 do
    local heroItem = hero:GetItemInSlot(i) 
    if heroItem == nil then return nil end
    if heroItem:GetName() == itemname then
      return heroItem
    end
  end
  return nil
end 

function CreateItemAtSlot(hero, itemname, slot)
  local dummyitemtable = {}
  for i = 0, slot-1 do
    if hero:GetItemInSlot(i) == nil then
      local dummyitem = CreateItem("item_blink_scroll", nil, nil)
      table.insert(dummyitemtable, dummyitem)
      hero:AddItem(dummyitem)
    end
  end
  hero:AddItem(CreateItem(itemname, hero, hero))

  for i = 1, #dummyitemtable do
    hero:RemoveItem(dummyitemtable[i]) 
  end

end

-- stash1 : old stash
-- stash2 : new stash
function FindStashDifference(stash1, stash2)
  local addedItems = {}
  for i=1, #stash2 do
    local IsItemFound = false
    for j=1, #stash1 do
      if stash1[j] == stash2[i] then IsItemFound = true break end -- Set flag to true and break from inner loop if same item is found
    end
    -- If item was not found, add item to return table
    if IsItemFound == false then 
      table.insert(addedItems, stash2[i])
    end
  end

  return addedItems
end

-- An ability was used by a player
function FateGameMode:OnAbilityUsed(keys)
  print('[BAREBONES] AbilityUsed')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname
  --print("Is this ability resetable? : " .. player:GetAssignedHero():FindAbilityByName(abilityname).IsResetable)
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function FateGameMode:OnNonPlayerUsedAbility(keys)
  print('[BAREBONES] OnNonPlayerUsedAbility')
  PrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function FateGameMode:OnPlayerChangedName(keys)
  print('[BAREBONES] OnPlayerChangedName')
  PrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function FateGameMode:OnPlayerLearnedAbility( keys)
  print ('[BAREBONES] OnPlayerLearnedAbility')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function FateGameMode:OnAbilityChannelFinished(keys)
  print ('[BAREBONES] OnAbilityChannelFinished')
  PrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function FateGameMode:OnPlayerLevelUp(keys)
  print ('[BAREBONES] OnPlayerLevelUp')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local hero = player:GetAssignedHero() 
  local level = keys.level
  print("Set unit's EXP bounty to " .. XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()])
  hero:SetCustomDeathXP(XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()])
  hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 4)
  hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 4)
end

-- A player last hit a creep, a tower, or a hero
function FateGameMode:OnLastHit(keys)
  print ('[BAREBONES] OnLastHit')
  PrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A player picked a hero
function FateGameMode:OnPlayerPickHero(keys)
  print ('[BAREBONES] OnPlayerPickHero')
  PrintTable(keys)
  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function FateGameMode:OnTeamKillCredit(keys)
  print ('[BAREBONES] OnTeamKillCredit')
  PrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end


-- An entity died
function FateGameMode:OnEntityKilled( keys )
	print( '[BAREBONES] OnEntityKilled Called' )
	PrintTable( keys )

	  -- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	  -- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
	    killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end
  -- Check if Caster(4th) is around and grant him 1 Madness
  if killedUnit:GetUnitName() ~= "gille_corpse" then
    local targets = FindUnitsInRadius(0, killedUnit:GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for k,v in pairs(targets) do
      if v:GetName() == "npc_dota_hero_shadow_shaman" then
        AdjustMadnessStack(v, 1)
      end
    end
  end

  if killedUnit:IsRealHero() then
    self.bIsCasuallyOccured = true
    -- Add to death count
    if killedUnit.DeathCount == nil then
      killedUnit.DeathCount = 1
    else
      killedUnit.DeathCount = killedUnit.DeathCount + 1
    end
    print("Current death count for " .. killedUnit.name .. " : " .. killedUnit.DeathCount)

    -- check if unit can receive a shard
    if killedUnit.DeathCount == 7 then
      killedUnit.DeathCount = 0
      if killedUnit.ShardAmount == nil then 
        killedUnit.ShardAmount = 1
      else
        killedUnit.ShardAmount = killedUnit.ShardAmount + 1
      end
    end
    local bounty = BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] - killedUnit:GetGoldBounty()
    if not killerEntity:IsHero() then
      print("Killed by neutral unit")
      killerEntity = killerEntity:GetPlayerOwner():GetAssignedHero()
    end

    killerEntity:ModifyGold(bounty , true, 0) 
    -- if killer has Golden Rule attribute, grant 50% more gold
    if killerEntity:FindAbilityByName("gilgamesh_golden_rule") and killerEntity:FindAbilityByName("gilgamesh_golden_rule"):GetLevel() == 2 then 
      killerEntity:ModifyGold(BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] / 2, true, 0) 
    end 
    print("Player collected bounty : " .. 1000 - killedUnit:GetGoldBounty())
  
    -- Need condition check for GH
    --if killedUnit:GetName() == "npc_dota_hero_doom_bringer" and killedUnit:GetPlayerOwner().IsGodHandAcquired then
  	if killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killedUnit:IsRealHero() then 
  		self.nRadiantDead = self.nRadiantDead + 1
  	else 
  		self.nDireDead = self.nDireDead + 1
  	end

  	local nRadiantAlive = 0
  	local nDireAlive = 0
    self:LoopOverPlayers(function(player, playerID)
      if player:GetAssignedHero():IsAlive() then
        if player:GetAssignedHero():GetTeam() == DOTA_TEAM_GOODGUYS then
          nRadiantAlive = nRadiantAlive + 1
        else 
          nDireAlive = nDireAlive + 1
        end
      end
    end)
   	
   	if nRadiantAlive == 0 then
      print("All Radiant heroes eliminated, removing existing timers and declaring winner...")
   		Timers:RemoveTimer('round_timer')
  	 	Timers:RemoveTimer('alertmsg')
  		Timers:RemoveTimer('alertmsg2')
  		Timers:RemoveTimer('timeoutmsg')
   		self:FinishRound(false, 1)
   	elseif nDireAlive == 0 then 
      print("All Dire heroes eliminated, removing existing timers and declaring winner...")
   		Timers:RemoveTimer('round_timer')
  	 	Timers:RemoveTimer('alertmsg')
  		Timers:RemoveTimer('alertmsg2')
  		Timers:RemoveTimer('timeoutmsg')
   		self:FinishRound(false, 0)
   	end
 end
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function FateGameMode:InitGameMode()
  FateGameMode = self
 	print('[BAREBONES] Starting to load Barebones FateGameMode...')
	-- Set game rules
	GameRules:SetHeroRespawnEnabled(false) 
	GameRules:SetUseUniversalShopMode(true) 
	GameRules:SetSameHeroSelectionEnabled(false)
	GameRules:SetHeroSelectionTime(1)
	GameRules:SetPreGameTime(0)
	GameRules:SetPostGameTime(60)
	GameRules:SetUseCustomHeroXPValues(true)
	GameRules:SetGoldPerTick(0)
  GameRules:SetUseBaseGoldBountyOnHeroes(false)

	-- Random seed for RNG
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt)) 


  -- Event Hooks
  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(FateGameMode, 'OnPlayerLevelUp'), self)
  --ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(FateGameMode, 'OnAbilityChannelFinished'), self)
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(FateGameMode, 'OnPlayerLearnedAbility'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(FateGameMode, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(FateGameMode, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(FateGameMode, 'OnDisconnect'), self)
  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(FateGameMode, 'OnItemPurchased'), self)
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(FateGameMode, 'OnItemPickedUp'), self)
  --ListenToGameEvent('last_hit', Dynamic_Wrap(FateGameMode, 'OnLastHit'), self)
  --ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(FateGameMode, 'OnNonPlayerUsedAbility'), self)
  ListenToGameEvent('player_changename', Dynamic_Wrap(FateGameMode, 'OnPlayerChangedName'), self)
  --ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(FateGameMode, 'OnRuneActivated'), self)
  --ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(FateGameMode, 'OnPlayerTakeTowerDamage'), self)
  --ListenToGameEvent('tree_cut', Dynamic_Wrap(FateGameMode, 'OnTreeCut'), self)
  ListenToGameEvent('entity_hurt', Dynamic_Wrap(FateGameMode, 'OnEntityHurt'), self)
  ListenToGameEvent('player_connect', Dynamic_Wrap(FateGameMode, 'PlayerConnect'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(FateGameMode, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(FateGameMode, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(FateGameMode, 'OnNPCSpawned'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(FateGameMode, 'OnPlayerPickHero'), self)
  ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(FateGameMode, 'OnTeamKillCredit'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(FateGameMode, 'OnPlayerReconnect'), self)
  ListenToGameEvent('player_say', Dynamic_Wrap(FateGameMode, 'PlayerSay'), self)
  --ListenToGameEvent('player_spawn', Dynamic_Wrap(FateGameMode, 'OnPlayerSpawn'), self)
  --ListenToGameEvent('dota_unit_event', Dynamic_Wrap(FateGameMode, 'OnDotaUnitEvent'), self)
  --ListenToGameEvent('nommed_tree', Dynamic_Wrap(FateGameMode, 'OnPlayerAteTree'), self)
  --ListenToGameEvent('player_completed_game', Dynamic_Wrap(FateGameMode, 'OnPlayerCompletedGame'), self)
  --ListenToGameEvent('dota_match_done', Dynamic_Wrap(FateGameMode, 'OnDotaMatchDone'), self)
  --ListenToGameEvent('dota_combatlog', Dynamic_Wrap(FateGameMode, 'OnCombatLogEvent'), self)
  --ListenToGameEvent('dota_player_killed', Dynamic_Wrap(FateGameMode, 'OnPlayerKilled'), self)
  --ListenToGameEvent('player_team', Dynamic_Wrap(FateGameMode, 'OnPlayerTeam'), self)
  
  -- For models swapping
  ListenToGameEvent( 'npc_spawned', Dynamic_Wrap( FateGameMode, 'OnHeroSpawned' ), self )

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(FateGameMode, 'ExampleConsoleCommand'), "A console command example", 0 )
  function FateGameMode:ExampleConsoleCommand()
    print("im here")
  end

  -- Convars:RegisterCommand( "player_say", Dynamic_Wrap(FateGameMode, 'PlayerSay'), "Reads player chat", 0) 
  Convars:RegisterCommand('player_say', function(...)
      local arg = {...}
      table.remove(arg,1)
      local cmdPlayer = Convars:GetCommandClient()
      keys = {}
      keys.ply = cmdPlayer
      keys.text = table.concat(arg, " ")
      self:PlayerSay(keys) 
    end, "Player said something", 0)


  -- Fill server with fake clients
  -- Fake clients don't use the default bot AI for buying items or moving down lanes and are sometimes necessary for debugging
  Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')
        
      Timers:CreateTimer('assign_fakes', {
        useGameTime = false,
        endTime = Time(),
        callback = function(barebones, args)
          local userID = 20
          for i=0, 9 do
            userID = userID + 1
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
                self:OnConnectFull({
                  userid = userID,
                  index = ply:entindex()-1
                })

                ply:GetAssignedHero():SetControllableByPlayer(0, true)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

  --[[This block is only used for testing events handling in the event that Valve adds more in the future
  Convars:RegisterCommand('events_test', function()
      FateGameMode:StartEventTest()
    end, "events test", 0)]]

  -- Initialized tables for tracking state
  self.nRadiantScore = 0
  self.nDireScore = 0

  self.nCurrentRound = 0
  self.nRadiantDead = 0
  self.nDireDead = 0
  self.nLastKilled = nil
  self.fRoundStartTime = 0

  self.bIsCasualtyOccured = false

  -- userID map
  self.vUserNames = {}
  self.vPlayerList = {}
  self.vSteamIds = {}
  self.vBots = {}
  self.vBroadcasters = {}

  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}

  self.vPlayerShield = {}
  --IsFirstSeal = {}

  self.bSeenWaitForPlayers = false
    -- Active Hero Map
  self.vPlayerHeroData = {}
  self.bPlayersInit = false
end


IsGameStarted = false
roundQuest = nil 

function FateGameMode:InitializeRound()
  -- do first round stuff
	if self.nCurrentRound == 1 then
    print("[FateGameMode]First round started, initiating 10 minute timer...")
    IsGameStarted = true
		GameRules:SendCustomMessage("The game has begun!", 0, 0)
    local blessingQuest = StartQuestTimer("roundTimerQuest", "Time Remaining until Next Holy Grail's Blessing", 599)
    Timers:CreateTimer('round_10min_bonus', {
      endTime = 600,
      callback = function()
      blessingQuest = StartQuestTimer("roundTimerQuest", "Time Remaining until Next Holy Grail's Blessing", 599)
      self:LoopOverPlayers(function(player, playerID)
        local hero = player:GetAssignedHero()
        hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth()) 
        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana()+10) 
        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana()+10)
      end)
      GameRules:SendCustomMessage("10 minutes passed. The Holy Grail's blessings restore all Master to full health and grant 10 Mana to them.", 0, 0)
      return 600
    end})
	end
  
  -- Flag game mode as pre round, and display tip
  IsPreRound = true  
  DisplayTip()
	Say(nil, string.format("Round %d will begin in 15 seconds.", self.nCurrentRound), false) 


    local msg = {
		message = "Round " .. self.nCurrentRound .. " has begun!",
		duration = 4.0
	}
	local alertmsg = {
		message = "30 seconds remaining!",
		duration = 4.0
	}
	local alertmsg2 = {
		message = "10 seconds remaining!",
		duration = 4.0
	}
	local timeoutmsg = {
		message = "Timeout!",
		duration = 4.0
	}

  self:LoopOverPlayers(function(ply, plyID)
    ResetAbilities(ply:GetAssignedHero())
    giveUnitDataDrivenModifier(ply:GetAssignedHero(), ply:GetAssignedHero(), "round_pause", 15.0) -- Pause all heroes
    ply:GetAssignedHero():SetGold(0, false) 
    ply:GetAssignedHero().CStock = 10

    -- Grant gold 
    if ply:GetAssignedHero():GetGold() < 5000 then -- 
      print("[FateGameMode] " .. ply:GetAssignedHero():GetName() .. " gained 3000 gold at the start of round")
      if ply.AvariceCount ~= nil then
        ply:GetAssignedHero():ModifyGold(3000 + ply.AvariceCount * 1500, true, 0) 
      else
        ply:GetAssignedHero():ModifyGold(3000, true, 0) 
      end
    end

    if self.nCurrentRound ~= 1 then 
      print("[FateGameMode]" .. ply:GetAssignedHero():GetName() .. " of player " .. ply:GetAssignedHero():GetPlayerID() .. "  gained " .. XP_PER_LEVEL_TABLE[ply:GetAssignedHero():GetLevel()] * 4/10 ..  " experience at the start of round")
      ply:GetAssignedHero():AddExperience(XP_PER_LEVEL_TABLE[ply:GetAssignedHero():GetLevel()] * 4/10 , false, false) 
    end
  end)


  Timers:CreateTimer('beginround', {
		endTime = 15,
		callback = function()
    print("[FateGameMode]Round started.")
    IsPreRound = false
    roundQuest = StartQuestTimer("roundTimerQuest", "Round " .. self.nCurrentRound, 150)

    self:LoopOverPlayers(function(player, playerID)
      player:GetAssignedHero():RemoveModifierByName("round_pause")
    end)

    FireGameEvent("show_center_message",msg)
	end
	})

  Timers:CreateTimer('round_30sec_alert', {
		endTime = 135,
		callback = function()
	    FireGameEvent("show_center_message",alertmsg)
	end
	})

  Timers:CreateTimer('round_10sec_alert', {
		endTime = 155,
		callback = function()
	    FireGameEvent("show_center_message",alertmsg2)
	end
	})

  Timers:CreateTimer('round_timer', {
		endTime = 165,
		callback = function()
    print("[FateGameMode]Round timeout.")
		FireGameEvent("show_center_message",timeoutmsg)
		local nRadiantAlive = 0
		local nDireAlive = 0
    -- Check how many people are alive in each team
    self:LoopOverPlayers(function(ply, plyID)
      if ply:GetAssignedHero():IsAlive() then -- BUGG(C++)
        if ply:GetAssignedHero():GetTeam() == DOTA_TEAM_GOODGUYS then
          nRadiantAlive = nRadiantAlive + 1
        else 
          nDireAlive = nDireAlive + 1
        end
      end
    end)
    -- if remaining players are equal
    if nRadiantAlive == nDireAlive then
      --[[print("Same number of players remaining on both teams.")
      -- if no one died this round, delcare winner based on current score standing
      if self.bIsCasualtyOccured == false  then
        print("No one died, the team losing right now wins.")
        if self.nRadiantScore < self.nDireScore then
          self:FinishRound(true,3)
        elseif self.nRadiantScore > self.nDireScore then
          self:FinishRound(true,4)
        elseif self.nRadiantScore == self.nDireScore then
          print("However two teams are tied, so it's a draw")
          self:FinishRound(true,2)
        end
      elseif self.bIsCasualtyOccured then
        print("Someone died, so it's a draw")
    	  self:FinishRound(true, 2)
      end]]
      if self.nRadiantScore < self.nDireScore then
        self:FinishRound(true,3)
      elseif self.nRadiantScore > self.nDireScore then
        self:FinishRound(true,4)
      elseif self.nRadiantScore == self.nDireScore then
        self:FinishRound(true, 2)
      end
    -- if remaining players are not equal
    elseif nRadiantAlive > nDireAlive then
    	self:FinishRound(true, 0)
    elseif nRadiantAlive < nDireAlive then
    	self:FinishRound(true, 1)
    end
	end
	})
end

--[[ 
0 : Radiant 
1 : Dire 
2 : Draw 
3 : Radiant(by default)
4 : Dire(by default)]]
function FateGameMode:FinishRound(IsTimeOut, winner)
	print("[FATE] Winner decided")
  UTIL_RemoveImmediate( roundQuest ) -- Stop round timer

  self:LoopOverPlayers(function(ply, plyID)
    if ply:GetAssignedHero():IsAlive() then
      giveUnitDataDrivenModifier(ply:GetAssignedHero(), ply:GetAssignedHero(), "round_pause", 5.0)
    end
    if ply:GetAssignedHero():GetName() == "npc_dota_hero_ember_spirit" and ply:GetAssignedHero():HasModifier("modifier_ubw_death_checker") then
      ply:GetAssignedHero():RemoveModifierByName("modifier_ubw_death_checker")
    end
    if ply:GetAssignedHero():GetName() == "npc_dota_hero_doom_bringer" then
      ply:GetAssignedHero():SetRespawnPosition(ply:GetAssignedHero().RespawnPos)
    end
  end)
  -- Remove all units
  local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
  local units2 = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
  for k,v in pairs(units) do
    if not v:IsRealHero() and IsValidEntity(v) then
      v:ForceKill(true)
    end
  end
  for k,v in pairs(units2) do
    if not v:IsRealHero() and IsValidEntity(v) then
      v:ForceKill(true)
    end
  end
  -- decide the winner
	if winner == 0 then 
		GameRules:SendCustomMessage("The Radiant has won the round!", 0, 0)
		self.nRadiantScore = self.nRadiantScore + 1
	elseif winner == 1 then
		GameRules:SendCustomMessage("The Dire has won the round!", 0, 0)
		self.nDireScore = self.nDireScore + 1
	elseif winner == 2 then
		GameRules:SendCustomMessage("This round is a draw.", 0, 0)
  elseif winner == 3 then
    GameRules:SendCustomMessage("Because the same amount of Servants are alive on both teams, the losing team(Radiant) has won.", 0, 0)
    self.nRadiantScore = self.nRadiantScore + 1
  elseif winner == 4 then
    GameRules:SendCustomMessage("Because the same amount of Servants are alive on both teams, the losing team(Dire) has won.", 0, 0)
    self.nDireScore = self.nDireScore + 1
	end
  GameRules:SendCustomMessage("All players with less than 5,000 gold will receive starting gold in 5 seconds.", 0, 0)

  -- Set score 
  mode:SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireScore )
  mode:SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantScore )
  self.nCurrentRound = self.nCurrentRound + 1

  -- check for win condition
  if self.nRadiantScore == 12 then
    Say(nil, "Radiant Victory!", false)
    GameRules:SetSafeToLeave( true )
    GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
    return
  elseif self.nDireScore == 12 then
    Say(nil, "Dire Victory!", false)
    GameRules:SetSafeToLeave( true )
    GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
    return
  end

  Timers:CreateTimer('roundend', {
		endTime = 5,
		callback = function()
    IsPreRound = true
    self:LoopOverPlayers(function(ply, plyID)
      ply:GetAssignedHero():RespawnHero(false, false, false)
      ProjectileManager:ProjectileDodge(ply:GetAssignedHero())
    end)
    self:InitializeRound()
	end
	})

end

function FateGameMode:LoopOverPlayers(callback)
  for i=0, 9 do
    local player = PlayerResource:GetPlayer(i)
    if player ~= nil and player:GetAssignedHero() ~= nil then 
      if callback(player, player:GetPlayerID()) then
        break
      end 
    end
  end
end

-- This function is called as the first player loads and sets up the FateGameMode parameters
function FateGameMode:CaptureGameMode()
	print("First player loaded in, setting parameters")
  if mode == nil then
    -- Set FateGameMode parameters
    mode = GameRules:GetGameModeEntity()    
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    mode:SetCameraDistanceOverride(1500)
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( true )
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    mode:SetCustomXPRequiredToReachNextLevel( XP_TABLE )

    --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
    --GameRules:GetGameModeEntity():SetThink( "Think", self, "GlobalThink", 2 )
    self:OnFirstPlayerLoaded()

  end 
end


-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function FateGameMode:PlayerConnect(keys)
  print('[BAREBONES] PlayerConnect')
  PrintTable(keys)
  
  if keys.bot == 1 then
    -- This user is a Bot, so add it to the bots table
    self.vBots[keys.userid] = 1
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
-- Assign players 
function FateGameMode:OnConnectFull(keys)
  print ('[BAREBONES] OnConnectFull')
  PrintTable(keys)
  FateGameMode:CaptureGameMode()
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  --[[if(ply~=nil)then
    ply:SetContextThink(DoUniqueString("heroselected"),
      function()
        local hero = ply:GetAssignedHero()
        if (hero ~= nil) then
              hero:SetContextThink(DoUniqueString("removecosmetic"),
                  function()
                      HideWearables(hero)
                      return 0.5
                  end
              ,0.5)
          return nil
        end
        return 0.1
      end
    ,0.1)
  end]]
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()

  self.vPlayerList[keys.userid] = ply
-- If the player is a broadcaster flag it in the Broadcasters table
  if PlayerResource:IsBroadcaster(playerID) then
    self.vBroadcasters[keys.userid] = 1
    return
  end
  -- Update the Steam ID table
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply
  
  playerID = ply:GetPlayerID()
  if self.vPlayers[playerID] ~= nil then
    self.vPlayerList[keys.userid] = ply
    return
  end
end

--[[ This is an example console command
function FateGameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end]]


