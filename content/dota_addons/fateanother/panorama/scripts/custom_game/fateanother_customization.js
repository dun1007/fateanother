function OnCustomizeButtonPressed()
{
    var customizePanel = $("#CustomizationBoard");
    if (!customizePanel)
        return;

    customizePanel.visible = !customizePanel.visible;
}

function UpdateAttributeList(data)
{
	var attributePanel = $("#CustomizationAttributeLayout");
	var statPanel = $("#CustomizationStatLayout");
	var cooldownPanel = $("#CustomizationCooldownLayout");
	if (!attributePanel || !statPanel)
		return;

	var queryUnit = data.masterUnit; //Players.GetLocalPlayerPortraitUnit();
	for(i=0; i<5; i++) {
		CreateAbilityPanel(attributePanel, queryUnit, i);
	}
	CreateAbilityPanel(cooldownPanel, queryUnit, 5);
	for(i=6; i<14; i++) {
		CreateAbilityPanel(statPanel, queryUnit, i);
	}
}

function CreateAbilityPanel(panel, unit, abilityIndex)
{
	var ability = Entities.GetAbility(unit, abilityIndex); 
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_ability.xml", false, false );
	abilityPanel.data().SetAbility(ability, unit, Game.IsInAbilityLearnMode());
}

function UpdateStatPanel(data)
{
	$("#STRAmount").text = data.STR;
	$("#AGIAmount").text = data.AGI;
	$("#INTAmount").text = data.INT;
	$("#DMGAmount").text = data.DMG;
	$("#ARMORAmount").text = data.ARMOR;
	$("#HPREGAmount").text = data.HPREG;
	$("#MPREGAmount").text = data.MPREG;
	$("#MSAmount").text = data.MS;
}

(function()
{
    //$.RegisterForUnhandledEvent( "DOTAAbility_LearnModeToggled", OnAbilityLearnModeToggled);

	//GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	//GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	//GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	//GameEvents.Subscribe( "dota_ability_changed", UpdateAbilityList );
	//GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdateAbilityList );

	GameEvents.Subscribe( "player_selected_hero", UpdateAttributeList);
	GameEvents.Subscribe( "servant_stats_updated", UpdateStatPanel );
	OnCustomizeButtonPressed();
})();