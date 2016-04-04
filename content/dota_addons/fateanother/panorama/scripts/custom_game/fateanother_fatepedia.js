var heroes = [
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_spectre",
    "npc_dota_hero_ember_spirit", 
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_bounty_hunter",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_skywrath_mage",
    "npc_dota_hero_sven", 
    "npc_dota_hero_vengefulspirit",
    "npc_dota_hero_huskar",
    "npc_dota_hero_chen",
    "npc_dota_hero_shadow_shaman",
    "npc_dota_hero_lina",
    "npc_dota_hero_omniknight"
]

var abilKV
var heroKV


function OnFatepediaButtonPressed()
{
    var fatepediaPanel = $("#FatepediaBoard");
    if (!fatepediaPanel)
        return;

    fatepediaPanel.visible = !fatepediaPanel.visible;
}

function CreateContextAbilityPanel(panel, abilityname)
{
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.SetAttributeString("ability_name", abilityname);
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_context_ability.xml", false, false );
}

function SetFatepediaHeroButtons()
{

}

function GetKV(data)
{
	//$.Msg("KV received");
	abilKV = data.abilKV;
	heroKV = data.heroKV;
}

(function()
{
	$("#FatepediaBoard").visible = false;
	GameEvents.Subscribe( "fatepedia_kv_sent", GetKV);
	SetFatepediaHeroButtons();
	//CreateContextAbilityPanel($("#FatepediaBoard"), "saber_invisible_air");
})();