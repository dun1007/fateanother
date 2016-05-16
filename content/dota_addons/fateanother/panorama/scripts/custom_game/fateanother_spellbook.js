var bIsBookOpen = false;
var bIsQuickCast = true;

var heroes = [
	"npc_dota_hero_crystal_maiden"
]

var spellbookLists = [
    ["caster_5th_wall_of_flame", "caster_5th_silence", "caster_5th_divine_words", "caster_5th_mana_transfer", "caster_5th_close_spellbook", "caster_5th_sacrifice"]
]

function CreateSpellbookPanel(index)
{
	var playerID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( playerID );
	var heroName = Players.GetPlayerSelectedHero( playerID );
	var contents = spellbookLists[heroes.indexOf(heroName)];
	var spellbookPanel = $("#SpellbookBoard");

	for (i=0; i<heroes.length; i++) {
		if (heroes[i] == heroName) {
			$.Msg("Creating ability panel");
			for (j=0; j<contents.length; j++) {
				$.Msg("loop ");
				CreateAbilityPanelByName(spellbookPanel, hero, spellbookLists[i][j], false);
			}
		}
	} 
}

function OnAbilButtonPressed(event)
{
	var playerID = Players.GetLocalPlayer();
	var hero = Players.GetPlayerHeroEntityIndex( playerID );
	var abil = null;

	if (event == "+CustomGameExecuteAbility1")
	{
		if (bIsBookOpen)
		{
			abil = Entities.GetAbility(hero, 6);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
		else
		{
			abil = Entities.GetAbility(hero, 0);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
	}
	else if (event == "+CustomGameExecuteAbility2")
	{
		if (bIsBookOpen)
		{
			abil = Entities.GetAbility(hero, 7);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
		else
		{
			$.Msg("opening spellbook");
			bIsBookOpen = true
			$("#SpellbookBoard").visible = true
		}
	}
	else if (event == "+CustomGameExecuteAbility3")
	{
		if (bIsBookOpen)
		{
			abil = Entities.GetAbility(hero, 8);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
		else
		{
			abil = Entities.GetAbility(hero, 2);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
	}
	else if (event == "+CustomGameExecuteAbility4") //mana transfer
	{
		if (bIsBookOpen)
		{
			abil = Entities.GetAbility(hero, 9);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
		else
		{
			abil = Entities.GetAbility(hero, 3);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
	}
	else if (event == "+CustomGameExecuteAbility5")
	{
		if (bIsBookOpen)
		{
			$.Msg("closing spellbook");
			bIsBookOpen = false
			$("#SpellbookBoard").visible = false
		}
		else
		{
			abil = Entities.GetAbility(hero, 4);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
	}
	else if (event == "+CustomGameExecuteAbility6")
	{
		if (bIsBookOpen)
		{
			abil = Entities.GetAbility(hero, 11);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
		else
		{
			abil = Entities.GetAbility(hero, 5);
			if (abil) {
				Abilities.ExecuteAbility( abil, hero, bIsQuickCast );
			}
		}
	}
}
(function()
{
	$("#SpellbookBoard").visible = false
	GameEvents.Subscribe( "player_selected_hero", CreateSpellbookPanel);

	Game.AddCommand( "+CustomGameExecuteAbility1", OnAbilButtonPressed, "", 0 );
	Game.AddCommand( "+CustomGameExecuteAbility2", OnAbilButtonPressed, "", 0 );
	Game.AddCommand( "+CustomGameExecuteAbility3", OnAbilButtonPressed, "", 0 );
	Game.AddCommand( "+CustomGameExecuteAbility4", OnAbilButtonPressed, "", 0 );
	Game.AddCommand( "+CustomGameExecuteAbility5", OnAbilButtonPressed, "", 0 );
	Game.AddCommand( "+CustomGameExecuteAbility6", OnAbilButtonPressed, "", 0 );

})();
