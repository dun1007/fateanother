require("statcollection/init")
require('lishuwen_ability')
require('archer_ability')
require('master_ability')
require('gille_ability')
require('libraries/notifications')
require('items')
require('modifiers/attributes')
require('libraries/util' )
require('libraries/timers')
require('libraries/popups')
require('libraries/animations')
require('libraries/crowdcontrol')
require('libraries/physics')
require('libraries/attachments')
--require('libraries/vector_target')


_G.IsPickPhase = true
_G.IsPreRound = true
_G.RoundStartTime = 0
_G.nCountdown = 0
_G.CurrentGameState = "FATE_PRE_GAME"
_G.GameMap = ""

ENABLE_HERO_RESPAWN = false -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false -- Should we let people select the same hero as each other
HERO_SELECTION_TIME = 60.0 -- How long should we let people select their hero?
PRE_GAME_TIME = 0 -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0 -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0 -- How long should it take individual trees to respawn after being cut down/destroyed?
GOLD_PER_TICK = 0 -- How much gold should players get per tick?
GOLD_TICK_TIME = 0 -- How long should we wait in seconds between gold ticks?
RECOMMENDED_BUILDS_DISABLED = false -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1250.0 -- How far out should we allow the camera to go? 1134 is the default in Dota
MINIMAP_ICON_SIZE = 1 -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1 -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1 -- What icon size should we use for runes?
RUNE_SPAWN_TIME = 120 -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true -- Should we use a custom buyback time?
BUYBACK_ENABLED = false -- Should we allow people to buyback when they die?
DISABLE_FOG_OF_WAR_ENTIRELY = false -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?
USE_CUSTOM_TOP_BAR_VALUES = true -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals) Requires USE_CUSTOM_TOP_BAR_VALUES
ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false -- Should we disable the gold sound when players get gold?
END_GAME_ON_KILLS = false -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 9999 -- How many kills for a team should signify an end of game?
USE_CUSTOM_HERO_LEVELS = true -- Should we allow heroes to have custom levels?
MAX_LEVEL = 24 -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true -- Should we use custom XP values to level up heroes, or the default Dota numbers?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
VICTORY_CONDITION = 12 -- Round required for win


XP_TABLE = {}
_G.XP_PER_LEVEL_TABLE = {}
BOUNTY_PER_LEVEL_TABLE = {}
XP_BOUNTY_PER_LEVEL_TABLE = {}
PRE_ROUND_DURATION = 6
PRESENCE_ALERT_DURATION = 60
ROUND_DURATION = 120
FIRST_BLESSING_PERIOD = 300
BLESSING_PERIOD = 600
BLESSING_MANA_REWARD = 15
SPAWN_POSITION_RADIANT_DM = Vector(-7650, 2200, 900)
SPAWN_POSITION_DIRE_DM = Vector(7600, 2000, 340)
SPAWN_POSITION_T1_TRIO = Vector(-796,7032,512)
SPAWN_POSITION_T2_TRIO = Vector(5676,6800,512)
SPAWN_POSITION_T3_TRIO = Vector(5780,2504,512)
SPAWN_POSITION_T4_TRIO = Vector(-888,1748,512)
TRIO_RUMBLE_CENTER = Vector(2436,4132,1000)
FFA_CENTER = Vector(368,3868,1000)
mode = nil
FATE_VERSION = "v1.16d"
roundQuest = nil
IsGameStarted = false

-- XP and XP Bounty stuffs
XP_TABLE[0] = 0
XP_TABLE[1] = 200
for i=2,(MAX_LEVEL-1) do
    XP_TABLE[i] = XP_TABLE[i-1] + i * 100 -- XP required per level formula : Previous level XP requirement + Level * 100
end

-- EXP required to reach next level
_G.XP_PER_LEVEL_TABLE[0] = 0
_G.XP_PER_LEVEL_TABLE[1] = 200
_G.XP_PER_LEVEL_TABLE[24] = 0
for i=2,MAX_LEVEL-2 do
    _G.XP_PER_LEVEL_TABLE[i] = XP_TABLE[i+1] - XP_TABLE[i] -- XP required per level formula : Previous level XP requirement + Level * 100
end
_G.XP_PER_LEVEL_TABLE[MAX_LEVEL-1] = _G.XP_PER_LEVEL_TABLE[MAX_LEVEL-2] + 2400

for i=1, MAX_LEVEL do
    BOUNTY_PER_LEVEL_TABLE[i] = 1025 + i * 75
end

XP_BOUNTY_PER_LEVEL_TABLE[1] = 120
for i=2, MAX_LEVEL do
    XP_BOUNTY_PER_LEVEL_TABLE[i] = XP_BOUNTY_PER_LEVEL_TABLE[i-1]*0.95 + i*4 + 100 -- Bounty XP formula : Previous level XP + Current Level * 4 + 120(constant)
end

-- Client to Server message data tables
local winnerEventData = {
    winnerTeam = 3, -- 0: Radiant, 1: Dire, 2: Draw
    radiantScore = 0,
    direScore = 0
}
local victoryConditionData = {
    victoryCondition = 12
}


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
model_lookup["npc_dota_hero_enchantress"] = "models/tamamo/tamamo.vmdl"
model_lookup["npc_dota_hero_bloodseeker"] = "models/lishuen/lishuen.vmdl"
model_lookup["npc_dota_hero_mirana"] = "models/jeanne/jeanne.vmdl"
model_lookup["npc_dota_hero_queenofpain"] = "models/astolfo/astolfo.vmdl"


DoNotKillAtTheEndOfRound = {
    "tamamo_charm",
    "jeanne_banner"
}
voteResultTable = {
    0, -- 12 kills
    0,  -- 10
    0, -- 8
    0,  -- 6
    0  -- 4
}
--[[voteResultTable = {
    v_OPTION_1 = 0, -- 12 kills
    v_OPTION_2 = 0,  -- 10
    v_OPTION_3 = 0, -- 8
    v_OPTION_4 = 0,  -- 6
    v_OPTION_5 = 0  -- 4
}]]--
voteResults_DM = {
    12, 10, 8, 6, 4
}

voteResults_TRIO = {
    45, 40, 35, 30, 25
}

voteResults_FFA = {
    30, 27, 24, 21, 18
}

gameState = {
    "FATE_PRE_GAME",
    "FATE_PRE_ROUND",
    "FATE_ROUND_ONGOING",
    "FATE_POST_ROUND"
}

gameMaps = {
    "fate_elim_6v6",
    "fate_ffa",
    "fate_trio_rumble_3v3v3v3"
}


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
    --PrecacheUnitByNameSync("npc_precache_everything", context)

    --PrecacheResource("soundfile", "soundevents/music/*.vsndevts", context)
    --[[Kill the default sound files
    PrecacheResource("soundfile", "soundevents/music/valve_dota_001/soundevents_stingers.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/music/valve_dota_001/soundevents_music.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/music/valve_dota_001/game_sounds_music.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/music/valve_dota_001/music/game_sounds_music.vsndevts", context)

    PrecacheResource("soundfile", "soundevents/bgm.vsndevts", context)]]
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
    PrecacheResource("soundfile", "soundevents/hero_tamamo.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_lishuwen.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/hero_ruler.vsndevts", context)
    PrecacheResource( "soundfile", "soundevents/hero_astolfo.vsndevts", context )
    PrecacheResource("soundfile", "soundevents/sounds_test.vsndevts", context)
    PrecacheResource( "soundfile", "soundevents/soundevents_conquest.vsndevts", context )

    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_silencer.vsndevts", context)

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

    -- Master, Stash, and System stuffs
    PrecacheResource("model", "models/shirou/shirouanim.vmdl", context)
    PrecacheResource("model", "models/items/courier/catakeet/catakeet_boxes.vmdl", context)
    PrecacheResource("model", "models/tohsaka/tohsaka.vmdl", context)
    PrecacheResource( "particle", "particles/units/heroes/hero_silencer/silencer_global_silence_sparks.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup_magical.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup_physical.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/damage_popup_pure.vpcf", context)
    PrecacheResource( "particle", "particles/custom/system/gold_popup.vpcf", context)

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
    PrecacheResource("model", "models/tamamo/tamamo.vmdl", context)
    PrecacheResource("model", "models/lishuen/lishuen.vmdl", context)
    PrecacheResource("model", "models/jeanne/jeanne.vmdl", context)
    PrecacheResource("model", "models/astolfo/astolfo.vmdl", context)
    PrecacheResource("model", "models/astolfo/astolfo_hippogriff.vmdl", context)
    PrecacheResource("model", "models/astolfo/astolfo_horn.vmdl", context)
    PrecacheResource("model", "models/astolfo/astolfo_sword.vmdl", context)
    PrecacheResource("model", "models/nurseryrhyme/nurseryrhyme.vmdl", context)

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

    -- Vector target
    --VectorTarget:Precache( context )

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
    GameRules:SendCustomMessage("#Fate_Choose_Hero_Alert_60", 0, 0)
    FireGameEvent('cgm_timer_display', { timerMsg = "Hero Select", timerSeconds = 61, timerEnd = true, timerPosition = 100})

    -- initialize vector targeting
    --VectorTarget:Init({noOrderFilter = true })
    -- Send KV to fatepedia
    -- Announce the goal of game
    -- Reveal the vote winner
    local maxval = voteResultTable[1]
    local maxkey = 1
    local votePool = nil
    if _G.GameMap == "fate_elim_6v6" then
        votePool = voteResults_DM
        maxkey = voteResults_DM[1]
    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
        votePool = voteResults_TRIO
        maxkey = voteResults_TRIO[1]
    elseif _G.GameMap == "fate_ffa" then
        votePool = voteResults_FFA
        maxkey = voteResults_FFA[1]
    end

    for i=1, 5 do
        if voteResultTable[i] > maxval then
            maxval = i
            maxkey = votePool[i]
        end
    end

    VICTORY_CONDITION = maxkey
    victoryConditionData.victoryCondition = VICTORY_CONDITION
    --VICTORY_CONDITION = 1
    GameRules:SendCustomMessage("<font color='#FF3399'>Vote Result:</font> Players have decided for victory score: <font color='#FF3399'>" .. VICTORY_CONDITION .. ".</font>", 0, 0)


    --[[
    -- Turn on music
    for i=0, 11 do
        local player = PlayerResource:GetPlayer(i)
        if player ~= nil then
            SendToConsole("stopsound")
            PlayBGM(player)
        end
    end]]

    Timers:CreateTimer('30secondalert', {
        endTime = 30,
        callback = function()

        GameRules:SendCustomMessage("#Fate_Choose_Hero_Alert_30_1", 0, 0)
        GameRules:SendCustomMessage("#Fate_Choose_Hero_Alert_30_2", 0, 0)
        DisplayTip()
        end
    })

    Timers:CreateTimer('startgame', {
        endTime = 60,
        callback = function()
            -- Set a think function for timer
            local CENTER_POSITION = Vector(0,0,0)
            local SHARD_DROP_PERIOD = 0
            if _G.GameMap == "fate_elim_6v6" then
                self.nCurrentRound = 1
                self:InitializeRound() -- Start the game after forcing a pick for every player
                BLESSING_PERIOD = 600
            elseif _G.GameMap == "fate_ffa" then
                BLESSING_PERIOD = 300
                SHARD_DROP_PERIOD = 180
                CENTER_POSITION = FFA_CENTER
                CreateUITimer("Next Holy Grail's Shard", SHARD_DROP_PERIOD, "shard_drop_timer")
                _G.CurrentGameState = "FATE_ROUND_ONGOING"
            elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
                BLESSING_PERIOD = 300
                SHARD_DROP_PERIOD = 180
                CENTER_POSITION = TRIO_RUMBLE_CENTER
                CreateUITimer("Next Holy Grail's Shard", SHARD_DROP_PERIOD, "shard_drop_timer")
                _G.CurrentGameState = "FATE_ROUND_ONGOING"

            end
            GameRules:GetGameModeEntity():SetThink( "OnGameTimerThink", self, 1 )
            IsPickPhase = false
            IsGameStarted = true
            GameRules:SendCustomMessage("#Fate_Game_Begin", 0, 0)
            CreateUITimer("Next Holy Grail's Blessing", FIRST_BLESSING_PERIOD, "ten_min_timer")

            Timers:CreateTimer('round_10min_bonus', {
                endTime = FIRST_BLESSING_PERIOD,
                callback = function()
                    CreateUITimer("Next Holy Grail's Blessing", BLESSING_PERIOD, "ten_min_timer")
                    self:LoopOverPlayers(function(player, playerID, playerHero)
                        local hero = playerHero
                        hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
                        hero.MasterUnit:SetMana(hero.MasterUnit:GetMana()+BLESSING_MANA_REWARD)
                        hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
                        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana()+BLESSING_MANA_REWARD)
                        MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
                    end)
                    --Notifications:TopToAll("#Fate_Timer_10minute", 5, nil, {color="rgb(255,255,255)", ["font-size"]="25px"})
                    Notifications:TopToAll({text="#Fate_Timer_10minute", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})


                    return BLESSING_PERIOD
            end})
            if _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_ffa" then
                Timers:CreateTimer('shard_drop_alert', {
                    endTime = SHARD_DROP_PERIOD - 5,
                    callback = function()
                    Notifications:TopToAll({text="<font color='#58ACFA'>Shard of Holy Grail </font> inbound! It will drop onto random location within center area.", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="35px"}})
                    EmitGlobalSound( "powerup_03" )
                    return SHARD_DROP_PERIOD
                end})
                Timers:CreateTimer('shard_drop_event', {
                    endTime = SHARD_DROP_PERIOD,
                    callback = function()
                    CreateUITimer("Next Holy Grail's Shard", SHARD_DROP_PERIOD, "shard_drop_timer")
                    --Notifications:TopToAll("#Fate_Timer_10minute", 5, nil, {color="rgb(255,255,255)", ["font-size"]="25px"})
                    for i=1, 2 do
                        local itemVector = CENTER_POSITION + Vector(RandomInt(-1300,1300), RandomFloat(-1300, 1300), 0)
                        CreateShardDrop(itemVector)
                    end
                    return SHARD_DROP_PERIOD
                end})
            end
        end
    })
end



--[[
This function is called once and only once when the game completely begins (about 0:00 on the clock). At this point,
    gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc. This function
        is useful for starting any game logic timers/thinkers, beginning the first round, etc.
        ]]
function FateGameMode:OnGameInProgress()
    print("[FATE] The game has officially begun")
    -- add xp granter and level its skills
    local bIsDummyNeeded = true
    local dummyLevel = 0
    local dummyLoc = Vector(0,0,0)
    if _G.GameMap == "fate_ffa" then
        dummyLevel = 1
        dummyLoc = FFA_CENTER
    elseif _G.GameMap == "fate_elim_6v6" then
        bIsDummyNeeded = false
    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
        dummyLevel = 2
        dummyLoc = TRIO_RUMBLE_CENTER
    end

    if bIsDummyNeeded then
        local xpGranter = CreateUnitByName("dummy_unit", Vector(0, 0, 1000), true, nil, nil, DOTA_TEAM_NEUTRALS)
        xpGranter:AddAbility("fate_experience_thinker")
        xpGranter:FindAbilityByName("fate_experience_thinker"):SetLevel(dummyLevel)
        xpGranter:FindAbilityByName("dummy_unit_passive"):SetLevel(1)
        xpGranter:SetAbsOrigin(dummyLoc)
    end

end

-- Cleanup a player when they leave
function FateGameMode:OnDisconnect(keys)
    print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
    --PrintTable(keys)

    local name = keys.name
    local networkid = keys.networkid
    local reason = keys.reason
    local userid = keys.userid
    --local playerID = self.vPlayerList[userid]
    --print(name .. " just got disconnected from game! Player ID: " .. playerID)
    --PlayerResource:GetSelectedHeroEntity(playerID):ForceKill(false)
    --table.remove(self.vPlayerList, userid) -- remove player from list
end

function SendChatToPanorama(string)
    local table =
    {
        text = string
    }
    CustomGameEventManager:Send_ServerToAllClients( "player_chat_lua", table )
end

function FateGameMode:OnPlayerChat(keys)
    --print ('[BAREBONES] PlayerSay')
    if keys == nil then print("empty keys") end
    -- Get the player entity for the user speaking
    local text = keys.text
    --SendChatToPanorama(text)
    local userID = keys.userid
    local localUserID = self.vUserIds[userID]
    if not localUserID then return end
    local plyID = localUserID:GetPlayerID()

    --local plyID = self.vPlayerList[userID]
    --if not plyID then return end
    --if IsDedicatedServer() then plyID = plyID - 1 end -- the index is off by 1 on dedi
    if GameRules:IsCheatMode() then
        SendChatToPanorama(text .. " by player " .. plyID)
    end
    local ply = PlayerResource:GetPlayer(plyID)
    if not ply then return end
    local hero = ply:GetAssignedHero()

    -- Match the text against something
    local matchA, matchB = string.match(text, "^-swap%s+(%d)%s+(%d)")
    if matchA ~= nil and matchB ~= nil then
        -- Act on the match
    end

    -- Below two commands are solely for test purpose, not to be used in normal games
    if text == "-testsetup" then
        if GameRules:IsCheatMode() then
            self:LoopOverPlayers(function(player, playerID, playerHero)
                local hero = playerHero
                hero.MasterUnit:SetMana(1000)
                hero.MasterUnit2:SetMana(1000)
                hero.MasterUnit:SetMaxHealth(1000)
                hero.MasterUnit:SetHealth(1000)
                hero.MasterUnit2:SetMaxHealth(1000)
                hero.MasterUnit2:SetHealth(1000)
                if hero:GetName() == "npc_dota_hero_juggernaut" then
                    hero:SetBaseStrength(25)
                    hero:SetBaseAgility(25)
                else
                    hero:SetBaseStrength(20)
                    hero:SetBaseAgility(20)
                    hero:SetBaseIntellect(20)
                end
            end)
        end
    end
    if text == "-unpause" then
        --[[for _,plyr in pairs(self.vPlayerList) do
        local hr = plyr:GetAssignedHero()
        hr:RemoveModifierByName("round_pause")
    end]]
        if GameRules:IsCheatMode() then
            self:LoopOverPlayers(function(player, playerID, playerHero)
                local hr = playerHero
                hr:RemoveModifierByName("round_pause")
                --print("Looping through player" .. ply)
            end)
        end
    end
    if text == "-errortest" then
        --[[for _,plyr in pairs(self.vPlayerList) do
        local hr = plyr:GetAssignedHero()
        hr:RemoveModifierByName("round_pause")
    end]]
        if GameRules:IsCheatMode() then
            SendErrorMessage(plyID, "#test_msg")
        end
    end


    if text == "-declarewinner" then
        if Convars:GetBool("sv_cheats") then
            GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        end
    end
    -- manually end the round
    if text == "-finishround" then
        if Convars:GetBool("sv_cheats") then
            self:FinishRound(true, 1)
        end
    end


    if text == "-tt" then
        if Convars:GetBool("sv_cheats") then
            hero.ShardAmount = 10
            print("10 shards")
        end
    end

    if text == "-silence" then
        if Convars:GetBool("sv_cheats") then
            EmitGlobalSound("Silence_Test")
        end
    end

    if text == "-bgmon" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "player_bgm_on", {} )
    end

    if text == "-bgmoff" then
        CustomGameEventManager:Send_ServerToPlayer( ply, "player_bgm_off", {} )
    end

    -- Sends a message to request gold
    local pID, goldAmt = string.match(text, "^-(%d%d?) (%d+)")
    if pID ~= nil and goldAmt ~= nil then
        --if GameRules:IsCheatMode() then
        --SendChatToPanorama("player " .. plyID .. " is trying to send " .. goldAmt .. " gold to player " .. pID)
        --end
        if PlayerResource:GetReliableGold(plyID) > tonumber(goldAmt) and plyID ~= tonumber(pID) and PlayerResource:GetTeam(plyID) == PlayerResource:GetTeam(tonumber(pID)) then
            local targetHero = PlayerResource:GetPlayer(tonumber(pID)):GetAssignedHero()
            hero:ModifyGold(-tonumber(goldAmt), true , 0)
            targetHero:ModifyGold(tonumber(goldAmt), true, 0)

            --GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> sent " .. goldAmt .. " gold to <font color='#58ACFA'>" .. targetHero.name .. "</font>" , hero:GetTeamNumber(), hero:GetPlayerOwnerID())
        end
    end

    -- handles -all commands
    local limit = string.match(text, "^-all (%d+)")
    -- distribute excess gold above 5K
    if text == "-all" then
        if PlayerResource:GetReliableGold(plyID) >= 5000 then
            DistributeGoldV2(hero, 4950)
        end
    end
    -- distribute excess gold above specified amount
    if limit then
        DistributeGoldV2(hero, tonumber(limit))
    end

    local goldamountinchat = string.match(text, "^-getgold (%d+)")

    if goldamountinchat then
        if Convars:GetBool("sv_cheats") then
            PlayerResource:SetGold(plyID, tonumber(goldamountinchat), true)
        end
    end

    if text == "-resetgold" then
        if Convars:GetBool("sv_cheats") then
            LoopOverPlayers(function(ply, plyID, playerHero)
                PlayerResource:SetGold(plyID, 0, true)
                PlayerResource:SetGold(plyID, 0, false)
            end)
        end
    end

    if text == "-reconnect" then
        if GameRules:IsCheatMode() then
            self:OnPlayerReconnect({PlayerID=plyID})
        end
    end

    if text == "-sealtest" then
        if Convars:GetBool("sv_cheats") then
            hero.MasterUnit:SetMana(10)
            hero.MasterUnit2:SetMana(10)
        end
    end

    -- Asks team for gold
    if text == "-goldpls" then
        --GameRules:SendCustomMessage("<font color='#58ACFA'>" .. hero.name .. "</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (gold amount) </font>to help him out!" , hero:GetTeamNumber(), hero:GetPlayerOwnerID())
        Notifications:RightToTeamGold(hero:GetTeam(), "<font color='#FF5050'>" .. FindName(hero:GetName()) .. "</font> at <font color='#FFD700'>" .. hero:GetGold() .. "g</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (goldamount)</font> to send gold!", 5, nil, {color="rgb(255,255,255)", ["font-size"]="20px"}, false)
    end
end

function OnPlayerAltClick(eventSourceIndex, keys)
	local playerId = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerId)
	local altClickTime = player.altClickTime
	local currentTime = GetSystemTime()
	if currentTime == altClickTime then
		return
	end
	player.altClickTime = currentTime
  local message = SubstituteMessageCodes(keys.message)
	Say(player, message, keys.toAll and false or true)
end

function DistributeGold(hero, cutoff)
    -- get gold amount of teammates
    -- exclude from table if more than stated amount
    -- sort them by amount of current gold
    local playerTable = {}
    local playerID = hero:GetPlayerID()
    if PlayerResource:GetReliableGold(playerID) < cutoff then return end
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() == hero:GetTeamNumber() and plyID ~= playerID then
            local pGold = PlayerResource:GetReliableGold(plyID)
            if pGold < 5000 then
                playerTable[plyID] = pGold
                print(playerHero:GetName())
            end
        end
    end)

    -- local sortedTable = spairs(playerTable, function(t,a,b) return t[b] < t[a] end)
    local residue = 0
    local goldPerPerson =  (PlayerResource:GetReliableGold(playerID)-cutoff)/#playerTable

    -- eligible players
    for pID,curGold in spairs(playerTable, function(t,a,b) return t[b] < t[a] end) do
        local eligibleGoldAmt = 5000 - PlayerResource:GetReliableGold(pID)
        -- only grant eligible amount of gold and save the rest on residue
        if goldPerPerson > eligibleGoldAmt then
            residue = residue + goldPerPerson - eligibleGoldAmt
            GiveGold(playerID, pID, eligibleGoldAmt)
        -- add residue up
        else
            if goldPerPerson + residue > eligibleGoldAmt then
                residue = goldPerPerson + residue - eligibleGoldAmt
                GiveGold(playerID, pID, eligibleGoldAmt)
            else
                GiveGold(playerID, pID, goldPerPerson+residue)
            end
        end
    end
end

function DistributeGoldV2(hero, cutoff)
    -- get gold amount of teammates
    -- exclude from table if more than stated amount
    -- sort them by amount of current gold
    local goldTable = {}
    local plyIDTable = {}
    local playerID = hero:GetPlayerID()
    if PlayerResource:GetReliableGold(playerID) < cutoff then return end
    LoopOverPlayers(function(ply, plyID, playerHero)
        if playerHero:GetTeamNumber() == hero:GetTeamNumber() and plyID ~= playerID then
            local pGold = PlayerResource:GetReliableGold(plyID)
            if pGold < 4950 then
                table.insert(goldTable, pGold)
                table.insert(plyIDTable, plyID)
                print(plyID)
                print(pGold)
            end
        end
    end)

    -- local sortedTable = spairs(playerTable, function(t,a,b) return t[b] < t[a] end)
    local residue = 0
    local goldPerPerson =  math.floor((PlayerResource:GetReliableGold(playerID)-cutoff)/#plyIDTable)

    -- eligible players
    for k,curGold in spairs(goldTable, function(t,a,b) return t[b] < t[a] end) do
        local eligibleGoldAmt = 4950 - PlayerResource:GetReliableGold(plyIDTable[k])
        -- only grant eligible amount of gold and save the rest on residue
        if goldPerPerson + residue> eligibleGoldAmt then
            residue = residue + goldPerPerson - eligibleGoldAmt --update surplus residue
            GiveGold(playerID, plyIDTable[k], eligibleGoldAmt)
        else
            GiveGold(playerID, plyIDTable[k], goldPerPerson+residue)
            residue = 0 --resets residue to 0
        end
    end
end


-- The overall game state has changed
function FateGameMode:OnGameRulesStateChange(keys)
    print("[BAREBONES] GameRules State Changed")

    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
        self.bSeenWaitForPlayers = true
    elseif newState == DOTA_GAMERULES_STATE_INIT then
        --Timers:RemoveTimer("alljointimer")
    elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        Timers:CreateTimer(2.0, function()
            FateGameMode:OnAllPlayersLoaded()
        end)
    elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        FateGameMode:OnGameInProgress()
    end
end

-- An NPC has spawned somewhere in game. This includes heroes
function FateGameMode:OnNPCSpawned(keys)
    --print("[BAREBONES] NPC Spawned")
    --PrintTable(keys)
    local hero = EntIndexToHScript(keys.entindex)

    if hero:IsRealHero() and hero.bFirstSpawned == nil and hero:GetPlayerOwner() ~= nil then
        FateGameMode:OnHeroInGame(hero)
    end
end

--[[
This function is called once and only once for every player when they spawn into the game for the first time. It is also called
    if the player's hero is replaced with a new hero for any reason. This function is useful for initializing heroes, such as adding
        levels, changing the starting gold, removing/adding abilities, adding physics, etc.
        The hero parameter is the hero entity that just spawned in
        ]]
local team2HeroesSpawned = 0
local team3HeroesSpawn = 0
function FateGameMode:OnHeroInGame(hero)
    --print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
    --Add a non-player hero to player list if it's missing(i.e generated by -createhero)
    if self.vBots[hero:GetPlayerID()] == 1 then
        print((hero:GetPlayerID()) .." is a bot!")
        self.vPlayerList[hero:GetPlayerID()] = hero:GetPlayerID()
    end
    -- Initialize stuffs
    hero:SetCustomDeathXP(0)
    hero.bFirstSpawned = true
    hero.PresenceTable = {}
    hero.bIsDmgPopupDisabled = false
    hero.bIsAlertSoundDisabled = false
    hero:SetAbilityPoints(0)
    hero:SetGold(0, false)
    hero.OriginalModel = hero:GetModelName()
    LevelAllAbility(hero)
    Timers:CreateTimer(0.85, function()
        hero:AddItem(CreateItem("item_blink_scroll", nil, nil) ) -- Give blink scroll
    end)
    hero.CStock = 10
    hero.ShardAmount = 0

    Timers:CreateTimer(1.0, function()
        local team = hero:GetTeam()
        local currentRound = self.nCurrentRound
        if team == 2 then
            if currentRound == 0 or currentRound == 1 then
                hero.RespawnPos = SPAWN_POSITION_RADIANT_DM
            elseif currentRound % 2 == 0 then
                hero.RespawnPos = SPAWN_POSITION_DIRE_DM
            end
        elseif team == 3 then
            if currentRound == 0 or currentRound == 1 then
                hero.RespawnPos = SPAWN_POSITION_DIRE_DM
            elseif currentRound % 2 == 0 then
                hero.RespawnPos = SPAWN_POSITION_RADIANT_DM
            end
        end
        --print("Respawn location registered : " .. hero.RespawnPos.x .. " BY " .. hero:GetName() )
        if _G.GameMap == "fate_elim_6v6" then
            local index
            if team == 2 then
                index = team2HeroesSpawned
                team2HeroesSpawned = team2HeroesSpawned + 1
            else
                index = team3HeroesSpawn
                team3HeroesSpawn = team3HeroesSpawn + 1
            end
            local currentRound = self.nCurrentRound
            -- round 0 uses initial spawn position
            local spawnPos = GetRespawnPos(hero, currentRound == 0 and 1 or currentRound, index)
            -- hero seems to spawn in the air so we have to get ground position here
            hero:SetAbsOrigin(GetGroundPosition(spawnPos, nil))
        end
    end)
    hero.bIsDirectTransferEnabled = true -- True by default
    Attributes:ModifyBonuses(hero)
    -- Set music off
    local player = PlayerResource:GetPlayer(hero:GetPlayerID())
    player:SetMusicStatus(DOTA_MUSIC_STATUS_NONE, 100000)

    -- Create Command Seal master for hero
    master = CreateUnitByName("master_1", Vector(4500 + hero:GetPlayerID()*320,-7050,0), true, hero, hero, hero:GetTeamNumber())
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
    MinimapEvent( hero:GetTeamNumber(), hero, master:GetAbsOrigin().x, master:GetAbsOrigin().y + 500, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5 )

    -- Create attribute/stat master for hero
    master2 = CreateUnitByName("master_2", Vector(4500 + hero:GetPlayerID()*320,-7400,0), true, hero, hero, hero:GetTeamNumber())
    master2:SetControllableByPlayer(hero:GetPlayerID(), true)
    master2:SetMana(0)
    hero.MasterUnit2 = master2
    AddMasterAbility(master2, hero:GetName())
    LevelAllAbility(master2)
    local playerData = {
        masterUnit = master2:entindex(),
        shardUnit = master:entindex(),
        hero = hero:entindex()
    }
    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "player_selected_hero", playerData)
    CustomGameEventManager:Send_ServerToAllClients("player_register_master_unit", playerData)
    --[[-- Create personal stash for hero
    masterStash = CreateUnitByName("master_stash", Vector(4500 + hero:GetPlayerID()*350,-7250,0), true, hero, hero, hero:GetTeamNumber())
    masterStash:SetControllableByPlayer(hero:GetPlayerID(), true)
    masterStash:SetAcquisitionRange(200)
    hero.MasterStash = masterStash
    LevelAllAbility(masterStash)]]
    -- Create item transfer master for hero
    master3 = CreateUnitByName("npc_dota_courier", Vector(4500 + hero:GetPlayerID()*320,-7225,0), true, hero, hero, hero:GetTeamNumber())
    master3:SetControllableByPlayer(hero:GetPlayerID(), true)

    master3:RemoveAbility("courier_return_to_base")
    master3:RemoveAbility("courier_go_to_secretshop")
    master3:RemoveAbility("courier_return_stash_items")
    master3:RemoveAbility("courier_take_stash_items")
    master3:RemoveAbility("courier_transfer_items")
    master3:RemoveAbility("courier_burst")
    master3:RemoveAbility("courier_morph")
    master3:RemoveAbility("courier_take_stash_and_transfer_items")

    master3:AddAbility("master_item_transfer_1")
    master3:AddAbility("master_item_transfer_2")
    master3:AddAbility("master_item_transfer_3")
    master3:AddAbility("master_item_transfer_4")
    master3:AddAbility("master_item_transfer_5")
    master3:AddAbility("master_item_transfer_6")
    master3:AddAbility("master_passive")
    LevelAllAbility(master3)


    -- Ping master location on minimap
    local pingsign = CreateUnitByName("ping_sign", Vector(0,0,0), true, hero, hero, hero:GetTeamNumber())
    pingsign:FindAbilityByName("ping_sign_passive"):SetLevel(1)
    pingsign:SetAbsOrigin(Vector(4500 + hero:GetPlayerID()*350,-6500,0))
    -- Announce the summon
    local heroName = FindName(hero:GetName())
    hero.name = heroName
    GameRules:SendCustomMessage("Servant <font color='#58ACFA'>" .. heroName .. "</font> has been summoned. Check your Master in the bottom right of the map.", 0, 0)

    if _G.GameMap == "fate_elim_6v6" then
        if self.nCurrentRound == 0 then
            giveUnitDataDrivenModifier(hero, hero, "round_pause", 60)
        elseif self.nCurrentRound >= 1 then
            hero:ModifyGold(3000, true, 0)
            giveUnitDataDrivenModifier(hero, hero, "round_pause", 10)
        end
    else
        hero:ModifyGold(3000, true, 0)
        if _G.CurrentGameState == "FATE_PRE_GAME" then
            giveUnitDataDrivenModifier(hero, hero, "round_pause", 60)
        end
    end

    if Convars:GetBool("sv_cheats") then
        hero:RemoveModifierByName("round_pause")
        hero.MasterUnit:SetMana(hero.MasterUnit:GetMaxMana())
        hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMaxMana())

        hero:SetBaseStrength(20)
        hero:SetBaseAgility(20)
        hero:SetBaseIntellect(20)
    end


    -- Wait 1 second for loadup
    Timers:CreateTimer(1.0, function()
        if _G.GameMap == "fate_ffa" or _G.GameMap == "fate_trio_rumble_3v3v3v3" then
            hero:HeroLevelUp(false)
            hero:HeroLevelUp(false)
        end
        CustomGameEventManager:Send_ServerToAllClients( "victory_condition_set", victoryConditionData ) -- Display victory condition for player
        --SendKVToFatepedia(player) -- send KV to fatepedia

        if hero:GetName() == "npc_dota_hero_crystal_maiden" then
            for i=6, 11 do
                hero:GetAbilityByIndex(i):SetHidden(false)
            end
        elseif hero:GetName() == "npc_dota_hero_queenofpain" then
            --Attachments:AttachProp(hero, "attach_sword", "models/astolfo/astolfo_sword.vmdl")
        end
    end)
end

-- This is for swapping hero models in
function FateGameMode:OnHeroSpawned( keys )

end

-- An entity somewhere has been hurt. This event fires very often with many units so don't do too many expensive
-- operations here
function FateGameMode:OnEntityHurt(keys)
    --print("[BAREBONES] Entity Hurt")
    --PrintTable(keys)
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function FateGameMode:OnItemPickedUp(keys)

    local heroEntity = nil
    local player = nil
    local item = EntIndexToHScript( keys.ItemEntityIndex )
    if keys.HeroEntityIndex ~= nil then
        heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
        player = PlayerResource:GetPlayer(keys.PlayerID)
    end
    local itemname = keys.itemname
    if itemname == "item_shard_drop" then
        -- add shard
        UTIL_Remove( item ) -- otherwise it pollutes the player inventory
        if heroEntity then AddRandomShard(heroEntity) end
    end
end


function CreateShardDrop(location)
    --Spawn the treasure chest at the selected item spawn location
    local newItem = CreateItem( "item_shard_drop", nil, nil )
    local drop = CreateItemOnPositionForLaunch( location + Vector(0,0,1500), newItem )
    newItem:LaunchLootInitialHeight( false, 700, 50, 0.5, location )
end

function AddRandomShard(hero)
    local shardDropTable = {
        "master_shard_of_avarice",
        "master_shard_of_anti_magic",
        "master_shard_of_replenishment",
        "master_shard_of_prosperity"
    }
    local shardRealNameTable = {
        "Shard of Avarice",
        "Shard of Anti-Magic",
        "Shard of Replenishment",
        "Shard of Prosperity"
    }
    if not hero.ShardAmount then
        hero.ShardAmount = 1
    else
        hero.ShardAmount = hero.ShardAmount + 1
    end
    local masterUnit = hero.MasterUnit
    local choice = math.random(#shardDropTable)
    local ability = masterUnit:FindAbilityByName(shardDropTable[choice])
    masterUnit:CastAbilityImmediately(ability, hero:GetPlayerOwnerID())
    Notifications:TopToAll({text=FindName(hero:GetName()) .. " has acquired <font color='#FF6600'>" .. shardRealNameTable[choice] .. "</font>!", duration=5.0, style={color="rgb(255,255,255)", ["font-size"]="25px"}})

end

-- A player has reconnected to the game. This function can be used to repaint Player-based particles or change
-- state as necessary
function FateGameMode:OnPlayerReconnect(keys)
    print ( '[BAREBONES] OnPlayerReconnect' )
    --PrintTable(keys)
    Timers:CreateTimer(3.0, function()
        print("reinitiating the UI")
        local userid = keys.PlayerID
        local ply = PlayerResource:GetPlayer(keys.PlayerID)
        local hero = ply:GetAssignedHero()

        local playerData = {
            masterUnit = hero.MasterUnit2:entindex(),
            shardUnit = hero.MasterUnit:entindex()
        }
        CustomGameEventManager:Send_ServerToPlayer( ply, "player_selected_hero", playerData )
        --CustomGameEventManager:Send_ServerToAllClients( "victory_condition_set", victoryConditionData ) -- Send the winner to Javascript

        local masterUnits = {}
        self:LoopOverPlayers(function(player, playerID, hero)
            if hero == nil then
              return
            end
            local masterUnit = hero.MasterUnit
            if masterUnit == nil then
              return
            end

            local masterEntIndex = masterUnit:entindex()
            local heroEntIndex = hero:entindex()
            masterUnits[heroEntIndex] = masterEntIndex
        end)
        CustomGameEventManager:Send_ServerToPlayer(ply, "player_register_all_master_units", masterUnits)

        RecreateUITimer(ply, "round_10min_bonus", "Next Holy Grail's Blessing", "ten_min_timer")
        RecreateUITimer(ply, "shard_drop_event", "Next Holy Grail's Shard", "shard_drop_timer")
        RecreateUITimer(ply, "beginround", "Pre-Round", "pregame_timer")
        RecreateUITimer(ply, "round_timer", "Round " .. self.nCurrentRound, "round_timer" .. self.nCurrentRound)

        return
    end)
end

function RecreateUITimer(playerID, timerName, message, description)
    local timer = Timers.timers[timerName]
    if timer == nil then
      return
    end

    local endTime = timer.endTime
    if endTime == nil then
      return
    end

    local gameTime = GameRules:GetGameTime()
    local duration = endTime - gameTime

    local timerData = {
        timerMsg = message,
        timerDuration = duration,
        timerDescription = description
    }

    CustomGameEventManager:Send_ServerToPlayer(playerID, "display_timer", timerData)
end

-- An item was purchased by a player
function FateGameMode:OnItemPurchased( keys )
    --print ( '[BAREBONES] OnItemPurchased : Purchased ' .. keys.itemname )
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
    CheckItemCombinationInStash(hero)

    local isPriceIncreased = true
    if hero.IsInBase then
        if itemName == "item_c_scroll" then
            if hero.CStock > 0 then
                hero.CStock = hero.CStock - 1
                isPriceIncreased = false
            else
                SendErrorMessage(plyID, "#Out_Of_Stock_C_Scroll")
            end
        else
            isPriceIncreased = false
        end
    end

    if isPriceIncreased then
        if PlayerResource:GetGold(plyID) >= itemCost * 0.5 then
            -- account for unreliable gold
            local unreliableGold = PlayerResource:GetUnreliableGold(plyID)
            hero:ModifyGold(-itemCost * 0.5, false, 0)
            local diff = math.max(itemCost * 0.5 - unreliableGold, 0)
            hero:ModifyGold(-diff, true, 0)
        else
            SendErrorMessage(plyID, "#Not_Enough_Gold_Item")
            hero:ModifyGold(itemCost, true, 0)
            local isItemDropped = true

            local stash = GetStashItems(hero)
            local oldStash = hero.stashState or {}
            for i = 1,6 do
                if stash[i] ~= oldStash[i] then
                    isItemDropped = false
                    break
                end
            end

            if not isItemDropped then
                LoadStashState(hero)
            else
                local itemsWithSameName = Entities:FindAllByName(itemName)
                local droppedItem
                local purchasedTime = -9999 
                for i = 1,#itemsWithSameName do
                    local item = itemsWithSameName[i]
                    if item:GetPurchaser() == hero and item:GetPurchaseTime() > purchasedTime then
                        droppedItem = item
                        purchasedTime = item:GetPurchaseTime()
                    end
                end

                if droppedItem == nil then
                    print("Unexpected: Item was nil - " .. itemName)
                else
                    droppedItem:GetContainer():RemoveSelf()
                    droppedItem:RemoveSelf()
                end
            end
        end
    end

    SaveStashState(hero)

    if PlayerResource:GetGold(plyID) < 200 and hero.bIsAutoGoldRequestOn then
        Notifications:RightToTeamGold(hero:GetTeam(), "<font color='#FF5050'>" .. FindName(hero:GetName()) .. "</font> at <font color='#FFD700'>" .. hero:GetGold() .. "g</font> is requesting gold. Type <font color='#58ACFA'>-" .. plyID .. " (goldamount)</font> to send gold!", 7, nil, {color="rgb(255,255,255)", ["font-size"]="20px"}, true)
    end
end

function GetStashItems(hero)
    local stashTable = {}
    for i=1,6 do
        local item = hero:GetItemInSlot(i + 5)
        table.insert(stashTable, i, item and item:GetName())
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

local spellBooks = {
    "lancer_5th_rune_magic",
    "lancer_5th_close_spellbook",
    "caster_5th_ancient_magic",
    "caster_5th_close_spellbook",
    "lancelot_knight_of_honor",
    "lancelot_close_spellbook",
    "diarmuid_double_spear_strike",
    "nero_imperial_privilege",
    "nero_close_spellbook",
    "tamamo_armed_up",
    "tamamo_close_spellbook"
}
-- An ability was used by a player
function FateGameMode:OnAbilityUsed(keys)
    --print('[BAREBONES] AbilityUsed')
    local player = EntIndexToHScript(keys.PlayerID)
    local abilityname = keys.abilityname
    local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()



    -- Check whether ability is an item active or not
    if not string.match(abilityname,"item") then
        -- Check if hero is affected by Amaterasu
        if hero:HasModifier("modifier_amaterasu_ally") then
            for i=1, #spellBooks do
                if abilityname == spellBooks[i] then return end
            end
            hero:SetMana(hero:GetMana()+200)
            hero:SetHealth(hero:GetHealth()+300)
            hero:EmitSound("DOTA_Item.ArcaneBoots.Activate")
            local particle = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
        end

        -- Check if a hero with Martial Arts is nearby
        if hero:HasModifier("modifier_martial_arts_aura_enemy") then
            local targets = FindUnitsInRadius(hero:GetTeam(), hero:GetOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
            for k,v in pairs(targets) do
                if v:HasAbility("lishuwen_martial_arts") then
                    local abil = v:FindAbilityByName("lishuwen_martial_arts")
                    --abil:ApplyDataDrivenModifier(v, hero, "modifier_mark_of_fatality", {})
                    ApplyMarkOfFatality(v, hero)
                    SpawnAttachedVisionDummy(v, hero, abil:GetLevelSpecialValueFor("vision_radius", abil:GetLevel()-1 ), abil:GetLevelSpecialValueFor("duration", abil:GetLevel()-1 ), false)
                end
            end
        end
    end
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function FateGameMode:OnNonPlayerUsedAbility(keys)
    --print('[BAREBONES] OnNonPlayerUsedAbility')
    --PrintTable(keys)

    local abilityname= keys.abilityname
end

-- A player changed their name
function FateGameMode:OnPlayerChangedName(keys)
    print('[BAREBONES] OnPlayerChangedName')
    --PrintTable(keys)

    local newName = keys.newname
    local oldName = keys.oldName
end

-- A player leveled up an ability
function FateGameMode:OnPlayerLearnedAbility( keys)
    --print ('[BAREBONES] OnPlayerLearnedAbility')
    --PrintTable(keys)

    local player = EntIndexToHScript(keys.player)
    local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function FateGameMode:OnAbilityChannelFinished(keys)
    --print ('[BAREBONES] OnAbilityChannelFinished')
    --PrintTable(keys)

    local abilityname = keys.abilityname
    local interrupted = keys.interrupted == 1
end

-- A player leveled up
function FateGameMode:OnPlayerLevelUp(keys)
    --print ('[BAREBONES] OnPlayerLevelUp')
    --PrintTable(keys)

    local player = EntIndexToHScript(keys.player)
    local hero = player:GetAssignedHero()
    local level = keys.level
    hero.MasterUnit:SetMana(hero.MasterUnit:GetMana() + 3)
    hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana() + 3)
    --Notifications:Top(player, "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has gained a level. Master has received <font color='#58ACFA'>3 mana.</font>", 5, nil, {color="rgb(255,255,255)", ["font-size"]="20px"})

    Notifications:Top(player, {text= "<font color='#58ACFA'>" .. FindName(hero:GetName()) .. "</font> has gained a level. Master has received <font color='#58ACFA'>3 mana.</font>", duration=5, style={color="rgb(255,255,255)", ["font-size"]="20px"}, continue=true})
    MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
end

-- A player last hit a creep, a tower, or a hero
function FateGameMode:OnLastHit(keys)
    --print ('[BAREBONES] OnLastHit')
    --PrintTable(keys)

    local isFirstBlood = keys.FirstBlood == 1
    local isHeroKill = keys.HeroKill == 1
    local isTowerKill = keys.TowerKill == 1
    local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A player picked a hero
function FateGameMode:OnPlayerPickHero(keys)
    --print ('[BAREBONES] OnPlayerPickHero')
    --PrintTable(keys)
    local heroClass = keys.hero
    local heroEntity = EntIndexToHScript(keys.heroindex)
    local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function FateGameMode:OnTeamKillCredit(keys)
    --print ('[BAREBONES] OnTeamKillCredit')
    --PrintTable(keys)
    local p = keys.splitscreenplayer
    local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
    local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
    local numKills = keys.herokills
    local killerTeamNumber = keys.teamnumber
end


-- An entity died
function FateGameMode:OnEntityKilled( keys )
    --print( '[BAREBONES] OnEntityKilled Called' )
    --PrintTable( keys )

    -- The Unit that was Killed
    local killedUnit = EntIndexToHScript( keys.entindex_killed )
    -- The Killing entity
    local killerEntity = nil

    if keys.entindex_attacker ~= nil then
        killerEntity = EntIndexToHScript( keys.entindex_attacker )
    end
    -- Check if Caster(4th) is around and grant him 1 Madness
    if not string.match(killedUnit:GetUnitName() ,"dummy") then
        local targets = FindUnitsInRadius(0, killedUnit:GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        for k,v in pairs(targets) do
            if v:GetName() == "npc_dota_hero_shadow_shaman" then
                AdjustMadnessStack(v, 1)
            end
        end
    end
    -- Change killer to be owning hero
    if not killerEntity:IsHero() then
        --print("Killed by neutral unit")
        if IsValidEntity(killerEntity:GetPlayerOwner()) then
            killerEntity = killerEntity:GetPlayerOwner():GetAssignedHero()
        end
    end
    if killedUnit:IsRealHero() then
        self.bIsCasuallyOccured = true -- someone died this round
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel() + 3)
        -- if killed by illusion, change the killer to the owner of illusion instead
        if killerEntity:IsIllusion() then
            killerEntity = PlayerResource:GetPlayer(killerEntity:GetPlayerID()):GetAssignedHero()
        end

        -- if TK occured, do nothing and announce it
        if killerEntity:GetTeam() == killedUnit:GetTeam() then
            GameRules:SendCustomMessage("<font color='#FF5050'>" .. killerEntity.name .. "</font> has slain friendly Servant <font color='#FF5050'>" .. killedUnit.name .. "</font>!", 0, 0)
        else
            -- Add to death count
            if killedUnit.DeathCount == nil then
                killedUnit.DeathCount = 1
            else
                killedUnit.DeathCount = killedUnit.DeathCount + 1
            end
            -- Add to kill count if victim is Ruler
            if killedUnit:GetName() == "npc_dota_hero_mirana" and killedUnit.IsSaintImproved then
                --print("killed ruler with attribute. current kills: " .. killerEntity:GetKills() .. ". adding 2 extra kills...")
                if _G.GameMap == "fate_elim_6v6" then
                    killerEntity:IncrementKills(1)
                    killerEntity:IncrementKills(1)
                end

            end
            -- check if unit can receive a shard
            if killedUnit.DeathCount == 7 then
                if killedUnit.ShardAmount == nil then
                    killedUnit.ShardAmount = 1
                    killedUnit.DeathCount = 0
                else
                    killedUnit.ShardAmount = killedUnit.ShardAmount + 1
                    killedUnit.DeathCount = 0
                end
                local statTable = CreateTemporaryStatTable(killedUnit)
                CustomGameEventManager:Send_ServerToPlayer( killedUnit:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS
            end
            -- Distribute XP to allies
            local alliedHeroes = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
            local realHeroCount = 0
            for i=1, #alliedHeroes do
                if alliedHeroes[i]:IsHero() then
                    realHeroCount = realHeroCount + 1
                end
            end

            for i=1, #alliedHeroes do
                if alliedHeroes[i]:IsHero() then
                    alliedHeroes[i]:AddExperience(XP_BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()]/realHeroCount, false, false)
                end
            end

            -- Give kill bounty
            local bounty = BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()]
            killerEntity:ModifyGold(bounty , true, 0)
            -- if killer has Golden Rule attribute, grant 50% more gold
            if killerEntity:FindAbilityByName("gilgamesh_golden_rule") and killerEntity:FindAbilityByName("gilgamesh_golden_rule"):GetLevel() == 2 then
                killerEntity:ModifyGold(BOUNTY_PER_LEVEL_TABLE[killedUnit:GetLevel()] / 2, true, 0)
            end
            --Granting XP to all heroes who assisted
            local assistTable = {}
            local allHeroes = HeroList:GetAllHeroes()
            for _,atker in pairs( allHeroes ) do
                for i = 0, killedUnit:GetNumAttackers() - 1 do
                    local attackerID = killedUnit:GetAttacker( i )
                    if atker:GetPlayerID() == attackerID then
                        local assister = PlayerResource:GetSelectedHeroEntity(attackerID)
                        if atker:GetTeam() == assister:GetTeam() and assister ~= killerEntity then
                            table.insert(assistTable, assister)
                            assister:ModifyGold(300 , true, 0)
                            local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, assister:GetPlayerOwner())
                            --local goldPopupFx = ParticleManager:CreateParticleForTeam("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetTeamNumber())
                            ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                            ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,300,0))
                            ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                            ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
                        end
                    end
                end
            end
            --print("Player collected bounty : " .. bounty - killedUnit:GetGoldBounty())
            -- Create gold popup
            if killerEntity:GetPlayerOwner() ~= nil then
                local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetPlayerOwner())
                --local goldPopupFx = ParticleManager:CreateParticleForTeam("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetTeamNumber())
                ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,bounty,0))
                ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
            end

            -- Display gold message
            local assistString = "plus <font color='#FFFF66'>" .. #assistTable * 300 .. "</font> gold split between contributors!"
            GameRules:SendCustomMessage("<font color='#FF5050'>" .. killerEntity.name .. "</font> has slain <font color='#FF5050'>" .. killedUnit.name .. "</font> for <font color='#FFFF66'>" .. bounty .. "</font> gold, " .. assistString, 0, 0)

            --[[-- Give assist bounty
            for k, _ in pairs(killedUnit.assistTable) do
                if k:GetTeam() == killerEntity:GetTeam() then
                    k:ModifyGold(300 , true, 0)
                    local goldPopupFx = ParticleManager:CreateParticleForPlayer("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, k:GetPlayerOwner())
                    --local goldPopupFx = ParticleManager:CreateParticleForTeam("particles/custom/system/gold_popup.vpcf", PATTACH_CUSTOMORIGIN, nil, killerEntity:GetTeamNumber())
                    ParticleManager:SetParticleControl( goldPopupFx, 0, killedUnit:GetAbsOrigin())
                    ParticleManager:SetParticleControl( goldPopupFx, 1, Vector(10,300,0))
                    ParticleManager:SetParticleControl( goldPopupFx, 2, Vector(3,#tostring(bounty)+1, 0))
                    ParticleManager:SetParticleControl( goldPopupFx, 3, Vector(255, 200, 33))
                end
            end]]


        end

        -- Need condition check for GH
        --if killedUnit:GetName() == "npc_dota_hero_doom_bringer" and killedUnit:GetPlayerOwner().IsGodHandAcquired then

        if _G.GameMap == "fate_trio_rumble_3v3v3v3" or _G.GameMap == "fate_ffa" then
            --print(PlayerResource:GetTeamKills(killerEntity:GetTeam()))
            --print(VICTORY_CONDITION)
            if PlayerResource:GetTeamKills(killerEntity:GetTeam()) >= VICTORY_CONDITION then
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( killerEntity:GetTeam() )
            end
        elseif _G.GameMap == "fate_elim_6v6" then
            if killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killedUnit:IsRealHero() then
                self.nRadiantDead = self.nRadiantDead + 1
            else
                self.nDireDead = self.nDireDead + 1
            end

            local nRadiantAlive = 0
            local nDireAlive = 0
            self:LoopOverPlayers(function(player, playerID, playerHero)
                if playerHero:IsAlive() then
                    if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                        nRadiantAlive = nRadiantAlive + 1
                    else
                        nDireAlive = nDireAlive + 1
                    end
                end
            end)
            --print(_G.CurrentGameState)
            -- check for game state before deciding round
            if _G.CurrentGameState ~= "FATE_POST_ROUND" then
                if nRadiantAlive == 0 then
                    --print("All Radiant heroes eliminated, removing existing timers and declaring winner...")
                    Timers:RemoveTimer('round_timer')
                    Timers:RemoveTimer('alertmsg')
                    Timers:RemoveTimer('alertmsg2')
                    Timers:RemoveTimer('timeoutmsg')
                    Timers:RemoveTimer('presence_alert')
                    self:FinishRound(false, 1)
                elseif nDireAlive == 0 then
                    --print("All Dire heroes eliminated, removing existing timers and declaring winner...")
                    Timers:RemoveTimer('round_timer')
                    Timers:RemoveTimer('alertmsg')
                    Timers:RemoveTimer('alertmsg2')
                    Timers:RemoveTimer('timeoutmsg')
                    Timers:RemoveTimer('presence_alert')
                    self:FinishRound(false, 0)
                end
            end
        end
    end
end

function OnVoteFinished(Index,keys)
    print("[FateGameMode]vote finished by player with result :" .. keys.killsVoted)
    local voteResult = keys.killsVoted
    voteResultTable[voteResult] = voteResultTable[voteResult] + 1
    --[[if voteResult == 1 then
        voteResultTable.v_OPTION_1 = voteResultTable.v_OPTION_1+1
    elseif voteResult == 2 then
        voteResultTable.v_OPTION_2 = voteResultTable.v_OPTION_2+1
    elseif voteResult == 3 then
        voteResultTable.v_OPTION_3 = voteResultTable.v_OPTION_3+1
    elseif voteResult == 4 then
        voteResultTable.v_OPTION_4 = voteResultTable.v_OPTION_4+1
    elseif voteResult == 5 then
        voteResultTable.v_OPTION_5 = voteResultTable.v_OPTION_5+1
    end]]
end

function OnDirectTransferChanged(Index, keys)
    local playerID = keys.player
    local transferEnabled = keys.directTransfer

    PlayerResource:GetPlayer(playerID):GetAssignedHero().bIsDirectTransferEnabled = transferEnabled
    print("Direct tranfer set to " .. transferEnabled .. " for " .. PlayerResource:GetPlayer(playerID):GetAssignedHero():GetName())
end


function OnServantCustomizeActivated(Index, keys)
    local caster = EntIndexToHScript(keys.unitEntIndex)
    local ability = EntIndexToHScript(keys.abilEntIndex)
    local hero = caster:GetPlayerOwner():GetAssignedHero()
    if ability:GetBehavior() ~= 6293508 then
        return
    end
    if ability:GetManaCost(1) > caster:GetMana() then
        SendErrorMessage(hero:GetPlayerOwnerID(), "#Not_Enough_Master_Mana")
        return
    end
    if ability:IsCooldownReady() == false then
        return
    end
    caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
    local statTable = CreateTemporaryStatTable(hero)
    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "servant_stats_updated", statTable ) -- Send the current stat info to JS

    hero:EmitSound("Item.DropGemWorld")
    local tomeFx = ParticleManager:CreateParticle("particles/units/heroes/hero_silencer/silencer_global_silence_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(tomeFx, 1, hero:GetAbsOrigin())

    --EmitSoundOnLocationForAllies(hero:GetAbsOrigin(), "Item.PickUpGemShop", hero)

    --ability:StartCooldown(ability:GetCooldown(1))
    --caster:SetMana(caster:GetMana() - ability:GetManaCost(1))
end

function OnConfig1Checked(index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()
    if keys.bOption == 1 then hero.bIsAutoGoldRequestOn = true else hero.bIsAutoGoldRequestOn = false end
end

function OnConfig2Checked(index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()
    if keys.bOption == 1 then hero.bIsDmgPopupDisabled = true else hero.bIsDmgPopupDisabled = false end
end

function OnConfig4Checked(index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()
    if keys.bOption == 1 then hero.bIsAlertSoundDisabled = true else hero.bIsAlertSoundDisabled = false end
end

function OnHeroClicked(Index, keys)
    local playerID = EntIndexToHScript(keys.player)
    local hero = PlayerResource:GetPlayer(keys.player):GetAssignedHero()


    if hero.IsIntegrated or hero.IsMounted then
        -- Find the transport
        local units = FindUnitsInRadius(hero:GetTeam(), hero:GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
        for k,v in pairs(units) do
            local unitname = v:GetUnitName()
            if hero:IsAlive() and v:IsAlive() then
                if unitname == "caster_5th_ancient_dragon" or unitname == "gille_gigantic_horror" then
                    local playerData = {
                        transport = v:entindex()
                    }
                    CustomGameEventManager:Send_ServerToPlayer( hero:GetPlayerOwner(), "player_selected_hero_in_transport", playerData )
                    return
                end
            end
        end
    end
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function FateGameMode:InitGameMode()
    FateGameMode = self

    -- Find out which map we are using
    _G.GameMap = GetMapName()
    if _G.GameMap == "fate_elim_6v6" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 6)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 6)
        GameRules:SetHeroRespawnEnabled(false)
        GameRules:SetGoldPerTick(0)

    elseif _G.GameMap == "fate_trio_rumble_3v3v3v3" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 3)
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 3)
        GameRules:SetGoldPerTick(7.5)

    elseif _G.GameMap == "fate_ffa" then
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )
        GameRules:SetGoldPerTick(7.5)
    end
    -- Set game rules
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetSameHeroSelectionEnabled(false)
    GameRules:SetHeroSelectionTime(0)
    GameRules:SetPreGameTime(60)
    GameRules:SetUseCustomHeroXPValues(true)
    GameRules:SetUseBaseGoldBountyOnHeroes(false)
    GameRules:SetCustomGameSetupTimeout(20)
    GameRules:SetFirstBloodActive(false)
    GameRules:SetCustomGameEndDelay(30)
    GameRules:SetCustomVictoryMessageDuration(30)

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
    ListenToGameEvent('player_chat', Dynamic_Wrap(FateGameMode, 'OnPlayerChat'), self)
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
    -- Listen to vote result
    CustomGameEventManager:RegisterListener( "vote_finished", OnVoteFinished )
    CustomGameEventManager:RegisterListener( "direct_transfer_changed", OnDirectTransferChanged )
    CustomGameEventManager:RegisterListener( "servant_customize", OnServantCustomizeActivated )
    CustomGameEventManager:RegisterListener( "check_hero_in_transport", OnHeroClicked )
    CustomGameEventManager:RegisterListener( "config_option_1_checked", OnConfig1Checked )
    CustomGameEventManager:RegisterListener( "config_option_2_checked", OnConfig2Checked )
    CustomGameEventManager:RegisterListener( "config_option_4_checked", OnConfig4Checked )
    -- CustomGameEventManager:RegisterListener( "player_chat_panorama", OnPlayerChat )
    CustomGameEventManager:RegisterListener( "player_alt_click", OnPlayerAltClick )
    -- LUA modifiers
    LinkLuaModifier("modifier_ms_cap", "modifiers/modifier_ms_cap", LUA_MODIFIER_MOTION_NONE)


    -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
    Convars:RegisterCommand( "command_example", Dynamic_Wrap(FateGameMode, 'ExampleConsoleCommand'), "A console command example", 0 )
    function FateGameMode:ExampleConsoleCommand()
    end

    --[[-- Convars:RegisterCommand( "player_say", Dynamic_Wrap(FateGameMode, 'PlayerSay'), "Reads player chat", 0)
    Convars:RegisterCommand('player_say', function(...)
        local arg = {...}
        table.remove(arg,1)
        local cmdPlayer = Convars:GetCommandClient()
        keys = {}
        keys.ply = cmdPlayer
        keys.text = table.concat(arg, " ")
        self:PlayerSay(keys)
    end, "Player said something", 0)]]

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

function CountdownTimer()
    nCountdown = nCountdown + 1
    local t = nCountdown

    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer =
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
        }
    CustomGameEventManager:Send_ServerToAllClients( "timer_think", broadcast_gametimer )
end

---------------------------------------------------------------------------
-- A timer that thinks every second
---------------------------------------------------------------------------
function FateGameMode:OnGameTimerThink()
    -- Stop thinking if game is paused
    if GameRules:IsGamePaused() == true then
        return 1
    end
    CountdownTimer()
    return 1
end

function FateGameMode:ModifyGoldFilter(filterTable)
    -- Disable gold gain from hero kills
    --local hero = PlayerResource:GetSelectedHeroEntity(filterTable.player_id_const)
    --local leaverCount = HasLeaversInTeam(hero)

    if filterTable["reason_const"] == DOTA_ModifyGold_HeroKill then
        filterTable["gold"] = 0
        return false
    end

    -- filterTable["gold"] = filterTable["gold"] + filterTable["gold"] * (0.15 * leaverCount)
    return true
end

function FateGameMode:ModifyExperienceFilter(filterTable)
    --[[local hero = PlayerResource:GetSelectedHeroEntity(filterTable.player_id_const)
    local leaverCount = HasLeaversInTeam(hero)

    filterTable["experience"] = filterTable["experience"] + filterTable["experience"] * (0.15 * leaverCount)]]
    return true
end

function FateGameMode:TakeDamageFilter(filterTable)
    local damage = filterTable.damage
    local damageType = filterTable.damagetype_const
    local attacker = EntIndexToHScript(filterTable.entindex_attacker_const)
    local inflictor = nil
    if filterTable.entindex_inflictor_const then
        inflictor = EntIndexToHScript(filterTable.entindex_inflictor_const) -- the skill name
    end
    local victim = EntIndexToHScript(filterTable.entindex_victim_const)

    --[[if victim:IsHero() and victim.assistTable then
        local attackerHero = PlayerResource:GetSelectedHeroEntity(attacker:GetPlayerID())
        victim.assistTable[attackerHero] = 0
    end]]
    --if inflictor then print(inflictor:GetName() .. damage) end

    if attacker:HasModifier("modifier_love_spot_charmed") and victim:GetName() == "npc_dota_hero_huskar" then
        local loveSpotAbil = victim:FindAbilityByName("diarmuid_love_spot")
        local reduction = loveSpotAbil:GetLevelSpecialValueFor("damage_reduction", loveSpotAbil:GetLevel() - 1)
        filterTable.damage = filterTable.damage/100 * (100-reduction)
        damage = damage/100 * (100-reduction)
    end


    -- if target is affected by Verg and damage is not lethal
    if (victim:HasModifier("modifier_verg_avesta") or victim:HasModifier("modifier_endless_loop")) and (victim:GetHealth() - damage) > 0 then
        -- check if the damage source is not eligible for return
        if not attacker:IsRealHero() and inflictor then
            attacker = PlayerResource:GetSelectedHeroEntity(attacker:GetPlayerID())
        elseif attacker:IsRealHero() and inflictor then
            if inflictor:GetName() == "archer_5th_ubw" then
                return true
            end
        end

        -- calculate return damage
        local vergHandle = victim:FindAbilityByName("avenger_verg_avesta")
        local multiplier = vergHandle:GetLevelSpecialValueFor("multiplier", vergHandle:GetLevel()-1)
        if victim.IsDIAcquired then multiplier = multiplier + 25 end
        local returnDamage = damage * multiplier / 100
        if attacker:IsMagicImmune() then
            returnDamage = returnDamage * (100 - attacker:GetMagicalArmorValue())/100
            DoDamage(victim, attacker, returnDamage, DAMAGE_TYPE_PURE, {DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_IMMUNITY}, vergHandle, false)
        else
            DoDamage(victim, attacker, returnDamage, DAMAGE_TYPE_MAGICAL, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, vergHandle, false)
        end
        if attacker:IsRealHero() then attacker:EmitSound("Hero_WitchDoctor.Maledict_Tick") end
        local particle = ParticleManager:CreateParticle("particles/econ/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 1, attacker:GetAbsOrigin())
    end
    if not attacker.bIsDmgPopupDisabled then
        if damageType == 1 or damageType == 2 or damageType == 4 then
            PopupDamage(victim, math.floor(damage), Vector(255,255,255), damageType)
        end
    end
    return true
end

function FateGameMode:ExecuteOrderFilter(filterTable)
    local ability = EntIndexToHScript(filterTable.entindex_ability) -- the handle of item
    local target = EntIndexToHScript(filterTable.entindex_target)
    local units = filterTable.units
    local targetIndex = filterTable.entindex_target-- the inventory target
    local playerID = filterTable.issuer_player_id_const
    local orderType = filterTable.order_type
    local xPos = tonumber(filterTable.position_x)
    local yPos = tonumber(filterTable.position_y)
    local zPos = tonumber(filterTable.position_z)
    local caster = nil
    if units["0"] then
        caster = EntIndexToHScript(units["0"])
    end
    -- Find items
    -- DOTA_UNIT_ORDER_PURASE_ITEM = 16
    -- DOTA_UNIT_ORDER_SELL_ITEM = 17
    -- DOTA_UNIT_ORDER_DISASSEMBLE_ITEM = 18
    -- DOTA_UNIT_ORDER_MOVE_ITEM = 19(drag and drop)

    -- attack command
    if orderType == 4 then
        if caster:GetName() == "npc_dota_hero_bloodseeker" and caster:HasModifier("modifier_lishuwen_concealment") and target:IsRealHero() then
            caster:FindAbilityByName("lishuwen_concealment"):ApplyDataDrivenModifier(caster, caster, "modifier_concealment_speed_boost", {})
        end
    end
    -- What do we do when handling the move between inventory and stash?
    if orderType == 11 then
        PrintTable(filterTable)
    end

    if orderType == DOTA_UNIT_ORDER_RADAR then
        return false
    end
    if orderType == 19 then
        local currentItemIndex, itemName = nil
        local charges = -1
        for i=0, 11 do
            if ability == caster:GetItemInSlot(i) then
                currentItemIndex = i
                itemName = ability:GetName()
                charges = ability:GetCurrentCharges()
                break
            end
        end
        -- Item is currently placed in inventory, while target is in stash
        if (currentItemIndex >= 0 and currentItemIndex <= 5) and (targetIndex >= 6 and targetIndex <= 11) then
            ability:RemoveSelf()
            CreateItemAtSlot(caster, itemName, targetIndex, charges, false, true)
            SaveStashState(caster)
            return false
        -- Item is currently placed in stash, while target is in inventory
        elseif (currentItemIndex >= 6 and currentItemIndex <= 11) and (targetIndex >= 0 and targetIndex <=5) then
            ability:RemoveSelf()
            CreateItemAtSlot(caster, itemName, targetIndex, charges, true, false)
            SaveStashState(caster)
            return false
        -- Item is currently placed in stash, and it is just being moved within there
        elseif (currentItemIndex >= 6 and currentItemIndex <= 11) and (targetIndex >= 6 and targetIndex <=11) then
            ability:RemoveSelf()
            CreateItemAtSlot(caster, itemName, targetIndex, charges, false, true)
            SaveStashState(caster)
            return false
        end
    -- What do we do when item is bought?
    elseif orderType == 16 then
        --[[
        -- Check price
        -- Check C scroll
        -- Emit error sound and msg
       if caster.IsInBase == false then
            if PlayerResource:GetReliableGold(playerID) < itemCost * 1.5 then
                -- This will take care of non-component items
                FireGameEvent( 'custom_error_show', { player_ID = plyID, _error = "Not Enough Gold(Items cost 50% more)" } )
                return false
            else
                print("Deducing extra cost" .. ability:GetCost()*0.5 .. "from player gold")
                hero:ModifyGold(ability:GetCost() *0.5, true , 0)
            end
        -- If hero is in base, check for C scroll stock
        else
            -- If hero is in base, check for C scroll stock
            if ability:GetName() == "item_c_scroll" then
                if caster.CStock > 0 then
                    caster.CStock = hero.CStock - 1
                else
                    FireGameEvent( 'custom_error_show', { player_ID = plyID, _error = "Out Of Stock" } )
                    return false
                end
            end
        end

        -- If everything is fine, check whether player has direct transfer checked and place item in right inventory
        if caster.bIsDirectTransferEnabled then
            local itemName = ability:GetName()
            CreateItemAtSlot(caster, itemName, 0, -1)
        else
        end]]
    -- What do we do when we sell items?
    elseif orderType == 17 then
        EmitSoundOnClient("General.Sell", caster:GetPlayerOwner())
        caster:ModifyGold(GetItemCost(ability:GetName()) *0.5, true , 0)
        ability:RemoveSelf()
        SaveStashState(caster)
        return false
    end
    return true
end

function FateGameMode:InitializeRound()
    -- do first round stuff
    if self.nCurrentRound == 1 then
        --[[print("[FateGameMode]First round started, initiating 10 minute timer...")
        IsGameStarted = true
        GameRules:SendCustomMessage("#Fate_Game_Begin", 0, 0)
        CreateUITimer("Next Holy Grail's Blessing", BLESSING_PERIOD-1, "ten_min_timer")
        Timers:CreateTimer('round_10min_bonus', {
            endTime = BLESSING_PERIOD,
            callback = function()
                CreateUITimer("Next Holy Grail's Blessing", 599, "ten_min_timer")
                self:LoopOverPlayers(function(player, playerID, playerHero)
                    local hero = playerHero
                    hero.MasterUnit:SetHealth(hero.MasterUnit:GetMaxHealth())
                    hero.MasterUnit:SetMana(hero.MasterUnit:GetMana()+BLESSING_MANA_REWARD)
                    hero.MasterUnit2:SetHealth(hero.MasterUnit2:GetMaxHealth())
                    hero.MasterUnit2:SetMana(hero.MasterUnit2:GetMana()+BLESSING_MANA_REWARD)
                    MinimapEvent( hero:GetTeamNumber(), hero, hero.MasterUnit:GetAbsOrigin().x, hero.MasterUnit2:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 2 )
                end)
                Notifications:TopToAll("#Fate_Timer_10minute", 5, nil, {color="rgb(255,255,255)", ["font-size"]="25px"})

                return BLESSING_PERIOD
        end})]]
    end

    -- Flag game mode as pre round, and display tip
    _G.IsPreRound = true
    CreateUITimer("Pre-Round", PRE_ROUND_DURATION, "pregame_timer")
    --FireGameEvent('cgm_timer_display', { timerMsg = "Pre-Round", timerSeconds = 16, timerEnd = true, timerPosition = 0})
    DisplayTip()
    Say(nil, string.format("Round %d will begin in " .. PRE_ROUND_DURATION .. " seconds.", self.nCurrentRound), false)


    local msg = {
        message = "Round " .. self.nCurrentRound .. " has begun!",
        duration = 4.0
    }
    local alertmsg = {
        message = "#Fate_Timer_30_Alert",
        duration = 4.0
    }
    local alertmsg2 = {
        message = "#Fate_Timer_10_Alert",
        duration = 4.0
    }
    local timeoutmsg = {
        message = "#Fate_Timer_Timeout",
        duration = 4.0
    }

    -- Set up heroes for new round
    self:LoopOverPlayers(function(ply, plyID, playerHero)
        local hero = playerHero

        ResetAbilities(hero)
        hero:RemoveModifierByName("round_pause")
        giveUnitDataDrivenModifier(hero, hero, "round_pause", PRE_ROUND_DURATION) -- Pause all heroes
        hero:SetGold(0, false)
        hero.CStock = 10

        -- Grant gold
        if hero:GetGold() < 5000 then --
            --print("[FateGameMode] " .. hero:GetName() .. " gained 3000 gold at the start of round")
            if hero.AvariceCount ~= nil then
                hero:ModifyGold(3000 + hero.AvariceCount * 1500, true, 0)
            else
                hero:ModifyGold(3000, true, 0)
            end
        end

        if self.nCurrentRound ~= 1 then
            local multiplier = (0.5+0.01*(hero:GetDeaths()-hero:GetKills()))
            --print("[FateGameMode]" .. hero:GetName() .. " of player " .. hero:GetPlayerID() .. " gained " .. (_G.XP_PER_LEVEL_TABLE[hero:GetLevel()] * multiplier) .. " experience at the start of round")
            hero:AddExperience(_G.XP_PER_LEVEL_TABLE[hero:GetLevel()] * multiplier , false, false)
        end
    end)


    Timers:CreateTimer('beginround', {
        endTime = PRE_ROUND_DURATION,
        callback = function()
            print("[FateGameMode]Round started.")
            _G.CurrentGameState = "FATE_ROUND_ONGOING"
            _G.IsPreRound = false
            _G.RoundStartTime = GameRules:GetGameTime()
            CreateUITimer(("Round " .. self.nCurrentRound), ROUND_DURATION, "round_timer" .. self.nCurrentRound)
            --FireGameEvent('cgm_timer_display', { timerMsg = ("Round " .. self.nCurrentRound), timerSeconds = 151, timerEnd = true, timerPosition = 0})
            --roundQuest = StartQuestTimer("roundTimerQuest", "Round " .. self.nCurrentRound, 150)

            self:LoopOverPlayers(function(player, playerID, playerHero)
                playerHero:RemoveModifierByName("round_pause")
            end)

            FireGameEvent("show_center_message",msg)
        end
    })

    Timers:CreateTimer('presence_alert', {
        endTime = PRESENCE_ALERT_DURATION + PRE_ROUND_DURATION,
        callback = function()
            GameRules:SendCustomMessage("#Fate_Presence_Alert", 0, 0)
        end
    })

    Timers:CreateTimer('round_30sec_alert', {
        endTime = PRE_ROUND_DURATION + ROUND_DURATION - 30,
        callback = function()
            FireGameEvent("show_center_message",alertmsg)
        end
    })

    Timers:CreateTimer('round_10sec_alert', {
        endTime = PRE_ROUND_DURATION + ROUND_DURATION - 10,
        callback = function()
            FireGameEvent("show_center_message",alertmsg2)
        end
    })

    Timers:CreateTimer('round_timer', {
        endTime = PRE_ROUND_DURATION + ROUND_DURATION,
        callback = function()
            print("[FateGameMode]Round timeout.")
            FireGameEvent("show_center_message",timeoutmsg)
            local nRadiantAlive = 0
            local nDireAlive = 0
            -- Check how many people are alive in each team
            self:LoopOverPlayers(function(player, playerID, playerHero)
                if playerHero:IsAlive() then
                    if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                        nRadiantAlive = nRadiantAlive + 1
                    else
                        nDireAlive = nDireAlive + 1
                    end
                elseif playerHero:GetName() == "npc_dota_hero_mirana" and playerHero.bIsLaPucelleActivatedThisRound then
                    print("ruler special round condition triggered")
                    playerHero.bIsLaPucelleActivatedThisRound = false
                    if playerHero:GetTeam() == DOTA_TEAM_GOODGUYS then
                        nRadiantAlive = nRadiantAlive + 1
                    else
                        nDireAlive = nDireAlive + 1
                    end
                end
            end)

            if nRadiantAlive > 6 then nRadiantAlive = 6 end
            if nDireAlive > 6 then nDireAlive = 6 end
            -- if remaining players are equal
            if nRadiantAlive == nDireAlive then
                -- Default Radiant Win
                if self.nRadiantScore < self.nDireScore then
                    self:FinishRound(true,3)
                -- Default Dire Win
                elseif self.nRadiantScore > self.nDireScore then
                    self:FinishRound(true,4)
                -- Draw
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
    --UTIL_RemoveImmediate( roundQuest ) -- Stop round timer

    _G.CurrentGameState = "FATE_POST_ROUND"
    CreateUITimer(("Round " .. self.nCurrentRound), 0, "round_timer" .. self.nCurrentRound)
    CreateUITimer("Pre-Round", 0, "pregame_timer")

    -- clean up marbles and pause heroes for 5 seconds
    self:LoopOverPlayers(function(player, playerID, playerHero)
        if playerHero:IsAlive() then
            giveUnitDataDrivenModifier(playerHero, playerHero, "round_pause", 5.0)
        end
        if playerHero:GetName() == "npc_dota_hero_ember_spirit" and playerHero:HasModifier("modifier_ubw_death_checker") then
            playerHero:RemoveModifierByName("modifier_ubw_death_checker")
        end
        if playerHero:GetName() == "npc_dota_hero_chen" and playerHero:HasModifier("modifier_army_of_the_king_death_checker") then
            playerHero:RemoveModifierByName("modifier_army_of_the_king_death_checker")
        end
        if playerHero:GetName() == "npc_dota_hero_doom_bringer" then
            if playerHero.RespawnPos then
                playerHero:SetRespawnPosition(playerHero.RespawnPos)
            end
        end
        if playerHero:HasModifier("modifier_saint_debuff") then
            playerHero:RemoveModifierByName("modifier_saint_debuff")
        end
    end)

    -- Remove all units
    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
    local units2 = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
    for k,v in pairs(units) do
        if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
            for i=1, #DoNotKillAtTheEndOfRound do
                if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                    v:ForceKill(true)
                end
            end
        end
    end
    for k,v in pairs(units2) do
        if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
            for i=1, #DoNotKillAtTheEndOfRound do
                if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                    v:ForceKill(true)
                end
            end
        end
    end

    -- decide the winner
    if winner == 0 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_1", 0, 0)
        self.nRadiantScore = self.nRadiantScore + 1
        winnerEventData.winnerTeam = 0
        GameRules.Winner = 2
        statCollection:submitRound(false)
    elseif winner == 1 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_2", 0, 0)
        self.nDireScore = self.nDireScore + 1
        winnerEventData.winnerTeam = 1
        GameRules.Winner = 3
        statCollection:submitRound(false)
    elseif winner == 2 then
        GameRules:SendCustomMessage("#Fate_Round_Draw", 0, 0)
        winnerEventData.winnerTeam = 2
    elseif winner == 3 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_1_By_Default", 0, 0)
        self.nRadiantScore = self.nRadiantScore + 1
        winnerEventData.winnerTeam = 0
        GameRules.Winner = 2
        statCollection:submitRound(false)
    elseif winner == 4 then
        GameRules:SendCustomMessage("#Fate_Round_Winner_2_By_Default", 0, 0)
        self.nDireScore = self.nDireScore + 1
        winnerEventData.winnerTeam = 1
        GameRules.Winner = 3
        statCollection:submitRound(false)
    end

    winnerEventData.radiantScore = self.nRadiantScore
    winnerEventData.direScore = self.nDireScore
    CustomGameEventManager:Send_ServerToAllClients( "winner_decided", winnerEventData ) -- Send the winner to Javascript
    GameRules:SendCustomMessage("#Fate_Round_Gold_Note", 0, 0)
    self:LoopOverPlayers(function(player, playerID, playerHero)
        local pHero = playerHero
        -- radiant = 2(equivalent to 0)
        -- dire = 3(equivalent to 1)
        if pHero:GetTeam() - 2 ~= winnerEventData.winnerTeam and winnerEventData.winnerTeam ~= 2 then
            pHero.MasterUnit:GiveMana(1)
            pHero.MasterUnit2:SetMana(pHero.MasterUnit:GetMana())
            --print("granted 1 mana to " .. pHero:GetName())
        end
    end)
    -- Set score
    mode = GameRules:GetGameModeEntity()
    mode:SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireScore )
    mode:SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantScore )
    self.nCurrentRound = self.nCurrentRound + 1

    -- check for win condition
    if self.nRadiantScore == VICTORY_CONDITION then
        Say(nil, "Radiant Victory!", false)
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        return
    elseif self.nDireScore == VICTORY_CONDITION then
        Say(nil, "Dire Victory!", false)
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
        return
    end

    Timers:CreateTimer('roundend', {
        endTime = 5,
        callback = function()
            -- Remove all units
            local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
            local units2 = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)
            for k,v in pairs(units) do
                if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
                    for i=1, #DoNotKillAtTheEndOfRound do
                        --print(v:GetUnitName())
                        if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                            v:ForceKill(true)
                        end
                    end
                end
            end
            for k,v in pairs(units2) do
                if not v:IsNull() and IsValidEntity(v) and not v:IsRealHero() then
                    for i=1, #DoNotKillAtTheEndOfRound do
                        --print(v:GetUnitName())
                        if not v:IsNull() and IsValidEntity(v) and v:GetUnitName() ~= DoNotKillAtTheEndOfRound[i] and v:GetAbsOrigin().y > -7000 then
                            v:ForceKill(true)
                        end
                    end
                end
            end
            _G.IsPreRound = true

            local team2Index = 0
            local team3Index = 0

            self:LoopOverPlayers(function(player, playerID, playerHero)
                local respawnPos = playerHero.RespawnPos
                if self.nCurrentRound >= 2 then
                    local index
                    local team = playerHero:GetTeam()
                    if team == 2 then
                        index = team2Index
                        team2Index = team2Index + 1
                    else
                        index = team3Index
                        team3Index = team3Index + 1
                    end
                    respawnPos = GetRespawnPos(playerHero, self.nCurrentRound, index)
                end
                playerHero:SetRespawnPosition(respawnPos)
                playerHero:RespawnHero(false, false, false)
                ProjectileManager:ProjectileDodge(playerHero)
            end)
            self:InitializeRound()
            _G.CurrentGameState = "FATE_PRE_ROUND"
        end
    })

end

function GetRespawnPos(playerHero, currentRound, index)
    local vColumn = Vector(0, -200 ,0)
    local vRow = Vector(200, 0, 0)

    -- [0] [1]
    -- [2] [3]
    -- [4] [x] x is default spawn
    local radiantOffset = vColumn * -2 + vRow * -1
    local radiantSpawn = SPAWN_POSITION_RADIANT_DM + radiantOffset

    -- [0] [1]
    -- [2] [x]
    -- [4] [5] x is default spawn
    local direOffset = vColumn * -1 + vRow * -1
    local direSpawn = SPAWN_POSITION_DIRE_DM + direOffset

    local row = index % 2
    local column = math.floor(index / 2)
    local offset = vRow * row + vColumn * column

    local team = playerHero:GetTeam()
    local respawnSide = (team + currentRound) % 2
    local defaultRespawnPos = respawnSide == 1 and radiantSpawn or direSpawn
    return defaultRespawnPos + vRow * row + vColumn * column
end

function FateGameMode:LoopOverPlayers(callback)
    for i=0, 11 do
        local playerID = i
        local player = PlayerResource:GetPlayer(i)
        local playerHero = PlayerResource:GetSelectedHeroEntity(playerID)
        if playerHero then
            --print("Looping through hero " .. playerHero:GetName())
            if callback(player, playerID, playerHero) then
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


        --mode:SetCameraDistanceOverride(1600)
        mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
        mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
        mode:SetBuybackEnabled( BUYBACK_ENABLED )
        mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
        mode:SetUseCustomHeroLevels ( true )
        mode:SetCustomXPRequiredToReachNextLevel( XP_TABLE )
        mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
        mode:SetGoldSoundDisabled( true )
        mode:SetRemoveIllusionsOnDeath( true )
        mode:SetStashPurchasingDisabled ( false )
        mode:SetAnnouncerDisabled( true )
        mode:SetLoseGoldOnDeath( false )
        mode:SetExecuteOrderFilter( Dynamic_Wrap( FateGameMode, "ExecuteOrderFilter" ), FateGameMode )
        mode:SetModifyGoldFilter(Dynamic_Wrap(FateGameMode, "ModifyGoldFilter"), FateGameMode)
        mode:SetDamageFilter(Dynamic_Wrap(FateGameMode, "TakeDamageFilter"), FateGameMode)
        mode:SetModifyExperienceFilter(Dynamic_Wrap(FateGameMode, "ModifyExperienceFilter"), FateGameMode)
        mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
        self:OnFirstPlayerLoaded()

        if _G.GameMap == "fate_elim_6v6" then
            mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
        end
    end
end


-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function FateGameMode:PlayerConnect(keys)
    --print('[BAREBONES] PlayerConnect')
    --PrintTable(keys)

    if keys.bot == 1 then
        -- This user is a Bot, so add it to the bots table
        self.vBots[keys.userid] = 1
    end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
-- Assign players
function FateGameMode:OnConnectFull(keys)
    --print ('[BAREBONES] OnConnectFull')
    --PrintTable(keys)
    FateGameMode:CaptureGameMode()

    local entIndex = keys.index+1
    -- The Player entity of the joining user
    local ply = EntIndexToHScript(entIndex)
    local userID = keys.userid
    self.vUserIds = self.vUserIds or {}
    self.vUserIds[userID] = ply

    --[[local playerID = ply:GetPlayerID()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
        playerID = keys.index
        print("teams not assigned yet, using index as player ID = " .. playerID)
    end
    self.vPlayerList = self.vPlayerList or {}
    self.vPlayerList[keys.userid] = playerID
    SendChatToPanorama("player " .. playerID .. " got assigned to " .. keys.userid .. "index in player list")
    --print(self.vPlayerList[keys.userid])]]
end
