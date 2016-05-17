function FindCustomUIRoot(panel)
{
	var targetPanel = panel;
	while (targetPanel.id != "CustomUIRoot")
	{
		//$.Msg(targetPanel.id)
		targetPanel = targetPanel.GetParent();
	}
	return targetPanel;
}

// create an ability button
function CreateAbilityPanel(panel, unit, abilityIndex, bIsAttribute)
{
	var ability = Entities.GetAbility(unit, abilityIndex); 
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_ability.xml", false, false );
	abilityPanel.SetAbility(ability, unit, Game.IsInAbilityLearnMode(), bIsAttribute);
}

function CreateAbilityPanelByName(panel, unit, abilityName, bIsAttribute)
{
	var ability = Entities.GetAbilityByName(unit, abilityName); 
	var abilityPanel = $.CreatePanel("Panel", panel, "");
	abilityPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_ability.xml", false, false );
	abilityPanel.SetAbility(ability, unit, Game.IsInAbilityLearnMode(), bIsAttribute);
	var buttonPanel = abilityPanel.FindChildTraverse("AbilityButton")
	buttonPanel.style["width"] = "45px";
	buttonPanel.style["height"] = "45px";
	var hotkeyPanel = abilityPanel.FindChildTraverse("HotkeyText");
	if (abilityName == "caster_5th_wall_of_flame")
	{
		hotkeyPanel.text = "Q";
	}
	else if (abilityName == "caster_5th_silence")
	{
		hotkeyPanel.text = "W";
	}
	else if (abilityName == "caster_5th_divine_words")
	{
		hotkeyPanel.text = "E";
	}
	else if (abilityName == "caster_5th_mana_transfer")
	{
		hotkeyPanel.text = "D";
	}
	else if (abilityName == "caster_5th_close_spellbook")
	{
		hotkeyPanel.text = "F";
	}
	else if (abilityName == "caster_5th_sacrifice")
	{
		hotkeyPanel.text = "R";
	}
}
