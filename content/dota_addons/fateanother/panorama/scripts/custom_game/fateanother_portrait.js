var masterUnit;

function PortraitShowTooltip()
{
	var txt = $("#ServantPortraitImage"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', txt, "#Fateanother_Portrait_Tooltip");
}

function PortraitHideTooltip()
{
	var txt = $("#ServantPortraitImage"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', txt );
}

function PortraitClick()
{
	var playerID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( playerID )
	GameUI.SelectUnit(hero, false);
}

function MasterPortraitClick()
{
	if (!masterUnit) 
		return;
	GameUI.SelectUnit(masterUnit, false);
}
function MasterShowTooltip()
{
	var txt = $("#MasterPortraitImage"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', txt, "#Fateanother_Master_Tooltip");
}

function MasterHideTooltip()
{
	var txt = $("#MasterPortraitImage"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', txt );
}


function MasterHealthShowTooltip()
{
	var txt = $("#MasterHealthText"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', txt, "#Fateanother_Master_Health_Tooltip");
}

function MasterHealthHideTooltip()
{
	var txt = $("#MasterHealthText"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', txt );
}

function MasterManaShowTooltip()
{
	var txt = $("#MasterManaText"); 
	$.DispatchEvent( 'DOTAShowTextTooltip', txt, "#Fateanother_Master_Mana_Tooltip");
}

function MasterManaHideTooltip()
{
	var txt = $("#MasterManaText"); 
	$.DispatchEvent( 'DOTAHideTextTooltip', txt );
}

function UpdateHealthAndMana()
{
	var manaTxt = $("#MasterManaNumber"); 
	var healthTxt = $("#MasterHealthNumber"); 
	if (!manaTxt || !healthTxt || !masterUnit)
		return;

	var currentHealth = Entities.GetHealth(masterUnit);
	var maxHealth = Entities.GetMaxHealth(masterUnit);
	var currentMana = Entities.GetMana(masterUnit);
	healthTxt.text = currentHealth;
	manaTxt.text = currentMana;
	$.Schedule( 0.1, UpdateHealthAndMana);
}

function SetupPortrait(data)
{

	//$.Msg("panels present. linking abilities...")
	//var queryUnit = data.masterUnit; //Players.GetLocalPlayerPortraitUnit();
	var heroPortrait = $("#ServantPortraitImage");
	var playerID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( playerID );
	var imageDir = "file://{images}/heroes/" + Entities.GetUnitName( hero ) + ".png";
	heroPortrait.SetImage(imageDir) ;
	masterUnit = data.shardUnit;
	UpdateHealthAndMana();

	$("#MasterStatusPanel").SetPanelEvent(
		"onactivate",
		MasterClicked
	);
}

function MasterClicked() {
	if (!GameUI.IsAltDown()) {
		return;
	}
	var healthPanel = $("#MasterHealthNumber");
	var manaPanel = $("#MasterManaNumber");
	var health = healthPanel.text;
	var mana = manaPanel.text;
	var message = "_gray__arrow_ _gold_Master _default_has " + health
		+ " _red_health _default_and " + mana + " _blue_mana";
	GameEvents.SendCustomGameEventToServer("player_alt_click", {message: message});
}

(function()
{
	GameEvents.Subscribe( "player_selected_hero", SetupPortrait);
})();
