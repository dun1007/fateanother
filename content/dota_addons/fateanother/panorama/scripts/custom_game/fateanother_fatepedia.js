var heroes = [
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_spectre",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_huskar",
	"npc_dota_hero_sven",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_chen",
	"npc_dota_hero_lina",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_mirana"

]

function OnFatepediaButtonPressed()
{
    var fatepediaPanel = $("#FatepediaBoard");
    if (!fatepediaPanel)
        return;
    fatepediaPanel.visible = !fatepediaPanel.visible;
}

function SetFatepediaHeroButtons()
{
	var directory = "url('file://{images}/heroes/";
	for (i=0; i<heroes.length; i++) {
		var heroButton = $.CreatePanel("Panel", $("#FatepediaHeroesPanel"), "");
		heroButton.BLoadLayout("file://{resources}/layout/custom_game/fateanother_fatepedia_herobutton.xml", false, false );
		heroButton.SetAttributeString("heroname", heroes[i]);
		heroButton.style["background-image"] = directory +  heroes[i] + ".png');";
	}
}


(function()
{
	$("#FatepediaBoard").visible = false;
	$("#FatepediaHeroInfoPanel").visible = false;
	//GameEvents.Subscribe( "fatepedia_kv_sent", GetKV);
	SetFatepediaHeroButtons();
	//for (i=0; i<6; i++) {
	//	CreateContextAbilityPanel($("#FatepediaHeroSkillPanel"), "saber_invisible_air");
	//}
	//for (i=0; i<4; i++) {
	//	CreateContextAbilityPanel($("#Fate pediaHeroAttrPanel"), "saber_invisible_air");
	//}
	//CreateContextAbilityPanel($("#FatepediaBoard"), "saber_invisible_air");
})();