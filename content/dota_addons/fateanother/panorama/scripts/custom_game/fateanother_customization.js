function OnCustomizeButtonPressed()
{
    var customizePanel = $("#CustomizationBoard");
    if (!customizePanel)
        return;

    customizePanel.visible = !customizePanel.visible;
}

function RemoveChilds(panel)
{
	for (i=0;i<panel.GetChildCount(); i++)
	{
		panel.GetChild(i).RemoveAndDeleteChildren();
	}
}

function UpdateAttributeList(data)
{
	$.Msg("updating attribute list")
	var attributePanel = $("#CustomizationAttributeLayout");
	var statPanel = $("#CustomizationStatLayout");
	var cooldownPanel = $("#CustomizationCooldownLayout");
	var shardPanel = $("#CustomizationShardLayout");
	if (!attributePanel || !statPanel || !shardPanel)
		return;

	//$.Msg("panels present. linking abilities...")
	var queryUnit = data.masterUnit; //Players.GetLocalPlayerPortraitUnit();
	var queryUnit2 = data.shardUnit;

	for(i=0; i<5; i++) {
		CreateAbilityPanel(attributePanel, queryUnit, i);
	}
	CreateAbilityPanel(cooldownPanel, queryUnit, 5);
	for(i=6; i<14; i++) {
		CreateAbilityPanel(statPanel, queryUnit, i);
	}

	for(i=6; i<10; i++) {
		CreateAbilityPanel(shardPanel, queryUnit2, i);
	}

	$.Msg("done!")
}

// create an ability button
function CreateAbilityPanel(panel, unit, abilityIndex)
{
	var ability = Entities.GetAbility(unit, abilityIndex); 
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_ability.xml", false, false );
	abilityPanel.SetAbility(ability, unit, Game.IsInAbilityLearnMode());
}

// create an ability context button, which does not reference existing ability of unit
function CreateContextAbilityPanel(panel)
{
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_context_ability.xml", false, false );
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
	$("#CustomizationShardNumber").text = data.ShardAmount;
}


function AttributeShowTooltip()
{
	var attrText = $("#CustomizationAttributeText");
	$.DispatchEvent('DOTAShowTextTooltip', attrText, "#Fateanother_Customize_Attributes_Tooltip");
}

function AttributeHideTooltip()
{
	var attrText = $("#CustomizationAttributeText"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', attrText );
}

function StatShowTooltip()
{
	var statText = $("#CustomizationStatText"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', statText, "#Fateanother_Customize_Stats_Tooltip");
}

function StatHideTooltip()
{
	var statText = $("#CustomizationStatText"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', statText );
}

function ComboShowTooltip()
{
	var comboText = $("#CustomizationComboText"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', comboText, "#Fateanother_Customize_Special_Cooldowns_Tooltip");
}

function ComboHideTooltip()
{
	var comboText = $("#CustomizationComboText"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', comboText );
}

function ShardShowTooltip()
{
	var shardText = $("#CustomizationShardText"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', shardText, "#Fateanother_Customize_Special_Shards_Tooltip");
}
function ShardHideTooltip()
{
	var shardText = $("#CustomizationShardText"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', shardText );
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