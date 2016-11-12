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
	"npc_dota_hero_mirana",
	"npc_dota_hero_queenofpain"
]

var names = [
	"Saber",
	"Saber Alter",
	"Lancer(5th)",
	"Archer(5th)",
	"Rider(5th)",
	"Caster(5th)",
	"Assassin(5th)",
	"True Assassin(5th)",
	"Berserker(5th)",
	"Archer(4th)",
	"Avenger",
	"Lancer(4th)",
	"Berserker(4th)",
	"Caster(4th)",
	"Rider(4th)",
	"Red Saber(Extra)",
	"White Saber(Extra)",
	"Caster(Extra)",
	"Assassin(Extra)",
	"Ruler(Apocrypha)",
	"Rider of Black(Apocrypha)"
]


var abilities = [
	["saber_invisible_air", "saber_caliburn", "saber_excalibur", "saber_charisma", "saber_instinct", "saber_avalon"],
	["saber_alter_derange", "saber_alter_mana_burst", "saber_alter_vortigern", "saber_alter_mana_shroud", "saber_alter_unleashed_ferocity", "saber_alter_excalibur"],
	["lancer_5th_rune_magic", "lancer_5th_relentless_spear", "lancer_5th_gae_bolg", "lancer_5th_battle_continuation", "fate_empty1", "lancer_5th_gae_bolg_jump"],
	["archer_5th_kanshou_bakuya", "archer_5th_broken_phantasm", "archer_5th_rho_aias", "archer_5th_overedge", "archer_5th_clairvoyance", "archer_5th_ubw"],
	["rider_5th_nail_swing", "rider_5th_breaker_gorgon", "rider_5th_bloodfort_andromeda", "fate_empty1", "rider_5th_mystic_eye", "rider_5th_bellerophon"],
	["caster_5th_argos", "caster_5th_ancient_magic", "caster_5th_rule_breaker", "caster_5th_territory_creation", "caster_5th_item_construction", "caster_5th_hecatic_graea"],
	["false_assassin_gate_keeper", "false_assassin_heart_of_harmony", "false_assassin_windblade", "false_assassin_minds_eye", "fate_empty1", "false_assassin_tsubame_gaeshi"],
	["true_assassin_ambush", "true_assassin_self_modification", "true_assassin_snatch_strike", "true_assassin_dirk", "true_assassin_presence_concealment", "true_assassin_zabaniya"],
	["berserker_5th_fissure_strike", "berserker_5th_courage", "berserker_5th_berserk", "fate_empty1", "berserker_5th_divinity", "berserker_5th_nine_lives"],
	["gilgamesh_enkidu", "gilgamesh_gram", "gilgamesh_gate_of_babylon", "gilgamesh_golden_rule", "gilgamesh_sword_barrage", "gilgamesh_enuma_elish"],
	["avenger_murderous_instinct", "avenger_tawrich_zarich", "avenger_true_form", "fate_empty1", "avenger_dark_passage", "avenger_verg_avesta"],
	["diarmuid_warriors_charge", "diarmuid_double_spearsmanship", "diarmuid_gae_buidhe", "diarmuid_love_spot", "fate_empty1", "diarmuid_gae_dearg" ],
	["lancelot_smg_barrage", "lancelot_double_edge", "lancelot_knight_of_honor", "rubick_empty1", "lancelot_arms_mastership", "lancelot_arondite" ],
	["gille_summon_demon", "gille_torment", "gille_exquisite_cadaver", "gille_spellbook_of_prelati", "gille_throw_corpse", "gille_abyssal_contract"],
	["iskander_forward", "iskander_phalanx", "iskander_gordius_wheel", "iskander_charisma", "fate_empty1", "iskander_army_of_the_king"],
	["nero_gladiusanus_blauserum", "nero_tres_fontaine_ardent", "nero_rosa_ichthys", "fate_empty1", "nero_imperial_privilege", "nero_aestus_domus_aurea"],
	["gawain_invigorating_ray", "gawain_blade_of_the_devoted", "gawain_excalibur_galatine", "gawain_solar_embodiment", "fate_empty1", "gawain_suns_embrace"],
	["tamamo_soulstream", "tamamo_subterranean_grasp", "tamamo_mantra", "fate_empty1", "tamamo_armed_up", "tamamo_amaterasu"],
	["lishuwen_concealment", "lishuwen_cosmic_orbit", "lishuwen_fierce_tiger_strike", "lishuwen_martial_arts", "fate_empty1", "lishuwen_no_second_strike"],
	["jeanne_charisma", "jeanne_purge_the_unjust", "jeanne_gods_resolution", "jeanne_magic_resistance_ex", "jeanne_saint", "jeanne_luminosite_eternelle"],
	["astolfo_hippogriff_vanish", "astolfo_down_with_a_touch", "astolfo_la_black_luna", "fate_empty1", "astolfo_casa_di_logistilla", "astolfo_hippogriff_raid"],
	["nursery_rhyme_white_queens_enigma", "nursery_rhyme_the_plains_of_water", "nursery_rhyme_doppelganger", "nursery_rhyme_shapeshift", "nursery_rhyme_nameless_forest", "nursery_rhyme_queens_glass_game"]
]

var attributes = [
	["saber_attribute_improve_excalibur", "saber_attribute_improve_instinct", "saber_attribute_strike_air", "saber_attribute_strike_air_upstream"],
	["saber_alter_attribute_mana_shroud", "saber_alter_attribute_mana_blast","saber_alter_attribute_improve_ferocity","saber_alter_attribute_ultimate_darklight"],
	["lancer_attribute_improve_battle_continuation", "lancer_attribute_improve_gae_bolg", "lancer_attribute_protection_from_arrows", "lancer_attribute_the_heartseeker"],
	["archer_5th_attribute_eagle_eye","archer_5th_attribute_hrunting","archer_5th_attribute_shroud_of_martin","archer_5th_attribute_improve_projection","archer_5th_attribute_overedge"],
	["rider_5th_attribute_improve_mystic_eyes", "rider_5th_attribute_riding", "rider_5th_attribute_seal", "rider_5th_attribute_monstrous_strength"],
	["caster_5th_attribute_improve_territory_creation", "caster_5th_attribute_improve_argos", "caster_5th_attribute_improve_hecatic_graea", "caster_5th_attribute_dagger_of_treachery"],
	["false_assassin_attribute_ganryu", "false_assassin_attribute_eye_of_serenity", "false_assassin_attribute_quickdraw", "false_assassin_attribute_vitrification"],
	["true_assassin_attribute_improve_presence_concealment", "true_assassin_attribute_protection_from_wind", "true_assassin_attribute_weakening_venom", "true_assassin_attribute_shadow_strike"],
	["berserker_5th_attribute_improve_divinity", "berserker_5th_attribute_berserk", "berserker_5th_attribute_god_hand", "berserker_5th_attribute_reincarnation"],
	["gilgamesh_attribute_improve_golden_rule", "gilgamesh_attribute_power_of_sumer", "gilgamesh_attribute_rain_of_swords", "gilgamesh_attribute_sword_of_creation"],
	["avenger_attribute_improve_dark_passage", "avenger_attribute_blood_mark", "avenger_attribute_overdrive", "avenger_attribute_demon_incarnate"],
	["diarmuid_attribute_improve_love_spot", "diarmuid_attribute_minds_eye", "diarmuid_attribute_rosebloom", "diarmuid_attribute_double_spear_strike"],
	["lancelot_attribute_improve_eternal", "lancelot_attribute_blessing_of_fairy", "lancelot_attribute_improve_knight_of_honor", "lancelot_attribute_eternal_flame"],
	["gille_attribute_eye_for_art", "gille_attribute_improve_black_magic", "gille_attribute_mental_pollution", "gille_attribute_abyssal_connection", "gille_attribute_abyssal_connection_2"],
	["iskander_attribute_improve_charisma", "iskander_attribute_thundergods_wrath", "iskander_attribute_via_expugnatio", "iskander_attribute_bond_beyond_time"],
	["nero_attribute_pari_tenu_blauserum", "nero_attribute_improve_imperial_privilege", "nero_attribute_invictus_spiritus", "nero_attribute_soverigns_glory"],
	["gawain_attribute_dawnbringer", "gawain_attribute_blessing_of_fairy", "gawain_attribute_divine_meltdown", "gawain_attribute_sunlight", "gawain_attribute_eclipse"],
	["tamamo_attribute_spirit_theft", "tamamo_attribute_mystic_shackle", "tamamo_attribute_tamamo_escape", "tamamo_attribute_witchcraft"],
	["lishuwen_attribute_circulatory_shock", "lishuwen_attribute_improve_martial_arts", "lishuwen_attribute_dual_class", "lishuwen_attribute_furious_chain"],
	["jeanne_attribute_identity_discernment", "jeanne_attribute_improve_saint", "jeanne_attribute_punishment", "jeanne_attribute_divine_symbol"],
	["astolfo_attribute_riding", "astolfo_attribute_monstrous_strength", "astolfo_attribute_independent_action", "astolfo_attribute_sanity"],
	["nursery_rhyme_attribute_forever_together","nursery_rhyme_attribute_nightmare","nursery_rhyme_attribute_reminiscence","nursery_rhyme_attribute_improve_queens_glass_game"]
]

var comboes = [
	"saber_max_excalibur",
	"saber_alter_max_mana_burst",
	"lancer_5th_wesen_gae_bolg",
	"archer_5th_arrow_rain",
	"rider_5th_bellerophon_2",
	"caster_5th_hecatic_graea_powered",
	"false_assassin_tsubame_mai",
	"true_assassin_combo",
	"berserker_5th_madmans_roar",
	"gilgamesh_max_enuma_elish",
	"avenger_endless_loop",
	"diarmuid_rampant_warrior",
	"lancelot_nuke",
	"gille_larret_de_mort",
	"iskander_annihilate",
	"nero_fiery_finale",
	"gawain_supernova",
	"tamamo_polygamist_castration_fist",
	"lishuwen_raging_dragon_strike",
	"jeanne_combo_la_pucelle",
	"astolfo_hippogriff_ride",
	"nursery_rhyme_story_for_somebodys_sake"
]

var guidelinks = [
	"http://fa-d2.wikia.com/wiki/Saber#Gameplay",
	"http://fa-d2.wikia.com/wiki/Saber_Alter#Gameplay",
	"http://fa-d2.wikia.com/wiki/Lancer#Gameplay",
	"http://fa-d2.wikia.com/wiki/Archer#Gameplay",
	"http://fa-d2.wikia.com/wiki/Rider#Gameplay",
	"http://fa-d2.wikia.com/wiki/Caster#Gameplay",
	"http://fa-d2.wikia.com/wiki/False_Assassin#Gameplay",
	"http://fa-d2.wikia.com/wiki/True_Assassin#Gameplay",
	"http://fa-d2.wikia.com/wiki/Berserker#Gameplay",
	"http://fa-d2.wikia.com/wiki/Gilgamesh#Gameplay",
	"http://fa-d2.wikia.com/wiki/Avenger#Gameplay",
	"http://fa-d2.wikia.com/wiki/Diarmuid#Gameplay",
	"http://fa-d2.wikia.com/wiki/Lancelot#Gameplay",
	"http://fa-d2.wikia.com/wiki/Gilles_de_Rais#Gameplay",
	"http://fa-d2.wikia.com/wiki/Iskander#Gameplay",
	"http://fa-d2.wikia.com/wiki/Nero#Gameplay",
	"http://fa-d2.wikia.com/wiki/Saber_(Gawain)#Gameplay",
	"http://fa-d2.wikia.com/wiki/Tamamo_no_Mae#Gameplay",
	"http://fa-d2.wikia.com/wiki/Assassin_%28Li_Shu_Wen%29#Gameplay",
	"http://fa-d2.wikia.com/wiki/Jeanne_d%27Arc#Gameplay",
	"http://fa-d2.wikia.com/wiki/Jeanne_d%27Arc#Gameplay",
	"http://fa-d2.wikia.com/wiki/Rider_of_Black#Gameplay",
	"http://fa-d2.wikia.com/wiki/Rider_of_Black#Gameplay"   //placeholder for nursery rhyme's page
]

function CreateContextAbilityPanel(panel, abilityname)
{
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.SetAttributeString("ability_name", abilityname);
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_context_ability.xml", false, false );
}

function OnHeroButtonShowTooltip()
{
    var panel = $.GetContextPanel();
    var name = panel.GetAttributeString("heroname", "");
    $.DispatchEvent('DOTAShowTextTooltip', panel, name);
}

function OnHeroButtonHideTooltip()
{
    var panel = $.GetContextPanel();
    $.DispatchEvent( 'DOTAHideTextTooltip', panel );
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
    var parentPanel = $.GetContextPanel().GetParent().GetParent();
    var infoPanel = parentPanel.FindChildInLayoutFile("FatepediaHeroInfoPanel");
    var portraitPanel = parentPanel.FindChildInLayoutFile("FatepediaHeroIntroImage");
    var namePanel = parentPanel.FindChildInLayoutFile("FatepediaHeroName");
    var skillPanel = parentPanel.FindChildInLayoutFile("FatepediaHeroSkillPanel");
    var attrPanel = parentPanel.FindChildInLayoutFile("FatepediaHeroAttrPanel");
    var linkPanel = parentPanel.FindChildInLayoutFile("WikiLink");
    var directory = "url('file://{images}/heroes/";
    //$.Msg(name + " " + curIndex);
    //$.Msg(skillPanel);

    skillPanel.RemoveAndDeleteChildren();
    attrPanel.RemoveAndDeleteChildren();

    infoPanel.visible = true;
	namePanel.text = names[curIndex];
    portraitPanel.style["background-image"] = directory +  heroes[i] + ".png');"; // portrait
	//namePanel.text = "#npc_dota_hero_legion_commander";
 
    // regular abilities
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][3]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][4]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][0]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][1]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][2]);
    CreateContextAbilityPanel(skillPanel, abilities[curIndex][5]);
    CreateContextAbilityPanel(skillPanel, comboes[curIndex]);
    // attributes 
	for (i=0; i<attributes[curIndex].length; i++) {
		CreateContextAbilityPanel(attrPanel, attributes[curIndex][i]);
	}
	//linkPanel.text = '<a href="http://www.w3schools.com/html/">Visit our HTML tutorial</a>';
	linkPanel.text = '<a href="' + guidelinks[curIndex] + '">Double click here for hero build and tips!</a>';
	//"&lt;a href=&quot;" + guidelinks[curIndex] + "&quot;&gt;Click here for quick build guide and tips!&lt;/a&gt;";
	//linkPanel.text = "FatepediaSkillContextText" id="WikiLink" text="&lt;a href=&quot;http://fa-d2.wikia.com/wiki/Gilgamesh#MAX_Enuma_Elish_.28Combo.29&quot;&gt;Click here for quick build guide and tips!&lt;a&gt;";
	//linkPanel.html = guidelinks[curIndex];

}

(function () {

})();