require( "timers")
require( 'util' )
require( 'archer_ability')
require( 'master_ability')

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

XP_PER_LEVEL_TABLE = {}
BOUNTY_PER_LEVEL_TABLE = {}
XP_BOUNTY_PER_LEVEL_TABLE = {}
mode = nil
FATE_VERSION = "WIP Version"

XP_PER_LEVEL_TABLE[1] = 100
for i=2,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1] + i * 100  -- XP required per level formula : Previous level XP requirement + Level * 100
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

function Precache( context )
	print("Starting precache")
	PrecacheUnitByNameSync("npc_precache_everything", context)
	print("precache complete")
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
	GameRules:SendCustomMessage("Game is currently in alpha phase of development and you may run into major issues that I hope to address ASAP. Please wait patiently for the official release.", 0, 0)
	GameRules:SendCustomMessage("Choose your heroic spirit. The game will start in 60 seconds.", 0, 0)


  	Timers:CreateTimer('30secondalert', {
		endTime = 30,
		callback = function()
  		GameRules:SendCustomMessage("The game will start in 30 seconds. Anyone who haven't picked hero by then will be assigned a random hero.", 0, 0)
	end
	})
  	Timers:CreateTimer('startgame', {
		endTime = 60,
		callback = function()
	    for _,ply in pairs(self.vPlayerList) do
	    	local playerID = ply:GetPlayerID()
	    	if PlayerResource:IsValidPlayerID(playerID) and ply:GetAssignedHero() == nil then
	    		ply:MakeRandomHeroSelection()
	    		PlayerResource:SetHasRepicked(playerID)
	    	end
	    end
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
    --HideWearables(hero)
  	--giveUnitDataDrivenModifier(hero, hero, "round_pause", 999)
    local heroName = FindName(hero:GetName())
    hero.name = heroName
    GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. heroName .. "</font> has been summoned. Please wait until the battle begins.", 0, 0)

end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function FateGameMode:OnGameInProgress()
	print("[FATE] The game has officially begun")
	Timers:CreateTimer(function()
      	local choice = RandomInt(1,4)
      	print(choice)
		print("playing music!")
		if choice == 1 then EmitGlobalSound("BGM.Excalibur")
			elseif choice == 2 then EmitGlobalSound("BGM.Mightywind")
			elseif choice == 3 then EmitGlobalSound("BGM.Emiya")
			else EmitGlobalSound("BGM.Unmeinoyoru")
		end
		return 180
    end
  	)
end




-- Cleanup a player when they leave
function FateGameMode:OnDisconnect(keys)
  print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end

function FateGameMode:PlayerSay(keys)
  print ('[BAREBONES] PlayerSay')
  if keys == nil then print("empty keys") end
  PrintTable(keys)

  -- Get the player entity for the user speaking
  local ply = keys.ply
  
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

  if text == "-createdummy" then
    print("We got here! yay!!")
  end
  
  -- testing if the dot can be seen by other people
  if text == "-customping" then
    print("Testing custom ping")
    CustomPing(plyID, Vector(0,0,0))
  end

  if text == "-clearcosmetic" then
    HideWearables(ply:GetAssignedHero())
  end

  if text == "-cam 150" then
    GameRules:GetGameModeEntity():SetCameraDistanceOverride(1500)
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
      hero:SetCustomDeathXP(XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()])
	    hero.bFirstSpawned = true
      hero.PresenceTable = {}
	    FateGameMode:OnHeroInGame(hero)
      hero:SetAbilityPoints(0)
	    local player = PlayerResource:GetPlayer(hero:GetPlayerID())
      -- Add a non-player hero to player list if it's missing(i.e generated by -createhero)
      if self.vBots[hero:GetPlayerID() + 1] == 1 then 
        print((hero:GetPlayerID()+1) .." is a bot!") 
        self.vPlayerList[hero:GetPlayerID() + 1] = player
      end

      -- Create Command Seal master for hero
	    master = CreateUnitByName("master_1", Vector(4500 + hero:GetPlayerID()*350,-7150,0), true, hero, hero, hero:GetTeamNumber())
	    master:SetControllableByPlayer(hero:GetPlayerID(), true) 
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
      hero.MasterUnit2 = master2
      AddMasterAbility(master2, hero:GetName())
      LevelAllAbility(master2)

      -- Create personal stash for hero
      masterStash = CreateUnitByName("master_stash", Vector(4500 + hero:GetPlayerID()*350,-7250,0), true, hero, hero, hero:GetTeamNumber())
      masterStash:SetControllableByPlayer(hero:GetPlayerID(), true)
      masterStash:SetAcquisitionRange(200)
      hero.MasterStash = masterStash
      LevelAllAbility(masterStash)


	end
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
end

-- An item was purchased by a player
function FateGameMode:OnItemPurchased( keys )
  print ( '[BAREBONES] OnItemPurchased' )
  PrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function FateGameMode:OnAbilityUsed(keys)
  print('[BAREBONES] AbilityUsed')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname
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
  local level = keys.level
  player:GetAssignedHero():SetCustomDeathXP(XP_BOUNTY_PER_LEVEL_TABLE[player:GetAssignedHero():GetLevel()])
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

  if killedUnit:IsRealHero() then
    --killerEntity:SetGold(0, false)
    local bounty = BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] - killedUnit:GetGoldBounty()
    killerEntity:ModifyGold(bounty , true, 0) 
    -- if killer has Golden Rule attribute, grant 50% more gold
    if killerEntity.IsGoldenRuleImproved then 
      killerEntity:ModifyGold(BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] / 2, true, 0) 
    end 
    print("Player collected bounty : " .. 1000 - killedUnit:GetGoldBounty())
  

  	if killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killedUnit:IsRealHero() then 
  		self.nRadiantDead = self.nRadiantDead + 1
  	else 
  		self.nDireDead = self.nDireDead + 1
  	end

  	local nRadiantAlive = 0
  	local nDireAlive = 0
      for _,ply in pairs(self.vPlayerList) do
      	if ply:GetAssignedHero():IsAlive() then
      		if ply:GetAssignedHero():GetTeam() == DOTA_TEAM_GOODGUYS then
      			nRadiantAlive = nRadiantAlive + 1
      		else 
      			nDireAlive = nDireAlive + 1
      		end
      	end
      end
   	
   	if nRadiantAlive == 0 then
   		Timers:RemoveTimer('round_timer')
  	 	Timers:RemoveTimer('alertmsg')
  		Timers:RemoveTimer('alertmsg2')
  		Timers:RemoveTimer('timeoutmsg')
   		self:FinishRound(false, 1)
   	elseif nDireAlive == 0 then 
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
	GameRules:SetPostGameTime(0)
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

  self.nCurrentRound = 1
  self.nRadiantDead = 0
  self.nDireDead = 0
  self.nLastKilled = nil
  self.fRoundStartTime = 0

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



function FateGameMode:InitializeRound()
	if self.nCurrentRound == 1 then
		GameRules:SendCustomMessage("The game has begun!", 0, 0)
	end

	Say(nil, string.format("Round %d will begin in 15 seconds.", self.nCurrentRound), false)
	-- Remove pause 
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

  -- currently bugged. when you spawn hero by cheat(-createhero), it registers player twice to vPlayerList
	for _,ply in pairs(self.vPlayerList) do
	    giveUnitDataDrivenModifier(ply:GetAssignedHero(), ply:GetAssignedHero(), "round_pause", 15.0)
      ply:GetAssignedHero():SetGold(0, false)
      print(" " .. ply:GetAssignedHero():GetName() .. " gained 3000 gold at the start of round")
      ply:GetAssignedHero():ModifyGold(3000, true, 0) 
      ply:GetAssignedHero():AddExperience(XP_PER_LEVEL_TABLE[ply:GetAssignedHero():GetLevel()] * 4/10 , false, false) 
	end
	
  	Timers:CreateTimer('beginround', {
		endTime = 15,
		callback = function()
	    for _,ply in pairs(self.vPlayerList) do
	    	ply:GetAssignedHero():RemoveModifierByName("round_pause")
	    end
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
		FireGameEvent("show_center_message",timeoutmsg)
		local nRadiantAlive = 0
		local nDireAlive = 0
	    for _,ply in pairs(self.vPlayerList) do
	    	if ply:GetAssignedHero():IsAlive() then
	    		if ply:GetAssignedHero():GetTeam() == DOTA_TEAM_GOODGUYS then
	    			nRadiantAlive = nRadiantAlive + 1
	    		else 
	    			nDireAlive = nDireAlive + 1
	    		end
	    	end
	    end

	    if nRadiantAlive == nDireAlive then
	    	self:FinishRound(true, 2)
	    elseif nRadiantAlive > nDireAlive then
	    	self:FinishRound(true, 0)
	    elseif nRadiantAlive < nDireAlive then
	    	self:FinishRound(true, 1)
	    end
	end
	})
end
-- 0 : Radiant 1 : Dire 2 : Draw
function FateGameMode:FinishRound(IsTimeOut, winner)
	print("[FATE] Winner decided")

	for _,ply in pairs(self.vPlayerList) do
		if ply:GetAssignedHero():IsAlive() then
			giveUnitDataDrivenModifier(ply:GetAssignedHero(), ply:GetAssignedHero(), "round_pause", 5.0)
		end
	end

	if winner == 0 then 
		GameRules:SendCustomMessage("The Radiant has won the round!", 0, 0)
		self.nRadiantScore = self.nRadiantScore + 1
	elseif winner == 1 then
		GameRules:SendCustomMessage("The Dire has won the round!", 0, 0)
		self.nDireScore = self.nDireScore + 1
	elseif winner == 2 then
		GameRules:SendCustomMessage("This round is a draw.", 0, 0)
	end

    mode:SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireScore )
    mode:SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantScore )
    self.nCurrentRound = self.nCurrentRound + 1

  	Timers:CreateTimer('roundend', {
		endTime = 5,
		callback = function()
	    for _,ply in pairs(self.vPlayerList) do
        if ply:GetAssignedHero():GetName() == "npc_dota_hero_ember_spirit" and ply:GetAssignedHero():HasModifier("modifier_ubw_death_checker") then
          EndUBW(ply:GetAssignedHero())
        end 
	    	ply:GetAssignedHero():RespawnHero(false, false, false)
	    end
	    self:InitializeRound()
	end
	})
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
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

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


