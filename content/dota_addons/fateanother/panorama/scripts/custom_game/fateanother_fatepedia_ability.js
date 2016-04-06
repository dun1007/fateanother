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

var abilities = [
	["saber_invisible_air", "saber_caliburn", "saber_excalibur", "saber_charisma", "saber_instinct", "saber_avalon"]
]

var attributes = [
	["saber_attribute_improve_excalibur", "saber_attribute_improve_instinct", "saber_attribute_chivalry", "saber_attribute_strike_air"]
]

function CreateContextAbilityPanel(panel, abilityname)
{
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.SetAttributeString("ability_name", abilityname);
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_context_ability.xml", false, false );
}

function GetIndex(array, object)
{
	for (i=0; i<array.length; i++)
	{
		if (array[i] == object) 
		{
			return i
		}
	}
	return -1
}
function OnHeroButtonPressed() {
    var name = $.GetContextPanel().GetAttributeString("heroname", "");
    var curIndex = GetIndex(heroes, name);
    var skillPanel = $.GetContextPanel().GetParent().GetParent().FindChildInLayoutFile("FatepediaHeroSkillPanel");
    //$.Msg(name + " " + curIndex);
    //$.Msg(skillPanel);
    // regular abilities
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][3]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][4]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][0]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][1]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][2]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][5]);
	//for (i=0; i<4; i++) {
	//	CreateContextAbilityPanel($("#FatepediaHeroAttrPanel"), "saber_invisible_air");
	//}
}

(function () {

})();