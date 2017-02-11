"use strict";

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_SetTextSafe( panel, childName, textValue )
{
	if ( panel === null )
		return;
	var childPanel = panel.FindChildInLayoutFile( childName )
	if ( childPanel === null )
		return;
	
	childPanel.text = textValue;
}


//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdatePlayerPanel( scoreboardConfig, playersContainer, playerId, localPlayerTeamId )
{
	var playerPanelName = "_dynamic_player_" + playerId;
	var playerPanel = playersContainer.FindChild( playerPanelName );
	if ( playerPanel === null )
	{
		playerPanel = $.CreatePanel( "Panel", playersContainer, playerPanelName );
		playerPanel.SetAttributeInt( "player_id", playerId );
		playerPanel.BLoadLayout( scoreboardConfig.playerXmlName, false, false );

		playerPanel.SetPanelEvent(
			"onactivate",
			function() {
				if (GameUI.IsAltDown()) {
					var playerInfo = Game.GetPlayerInfo(playerId);
					var isDead = playerInfo.player_respawn_seconds >= 0;
					var localPlayerId = Game.GetLocalPlayerID();
					var message;
					if (localPlayerId == playerId) {
						message = "_gray__arrow_ _default_I am _gold_" + (isDead ? "dead" : "alive") + "_default_!";
					} else {
						var localPlayerInfo = Game.GetPlayerInfo(localPlayerId);
						if (playerInfo.player_team_id != localPlayerInfo.player_team_id) {
							var heroName = playerInfo.player_selected_hero
							message = "_gray__arrow_ _default_Enemy _gold_" + heroName + "_default_ is " + (isDead ? "dead" : "missing") + "!";
						}
					}
					if (message) {
						GameEvents.SendCustomGameEventToServer("player_alt_click", {message: message});
					}
				} else if (GameUI.IsControlDown()) {
					var localPlayerId = Game.GetLocalPlayerID();
					if (localPlayerId != playerId) {
						return;
					}
					var hero = Players.GetPlayerHeroEntityIndex(playerID);
					var comboStatus = GetComboStatus(hero)
					var message = "_gold_ Combo _gray__arrow_ _default_";
					if (comboStatus == 0) {
						message += "Ready"
					} else if (comboStatus == -1) {
						message += "Unavailable"
					} else {
						message += "On cooldown ( " + Math.ceil(comboStatus) + " seconds remain )"
					}
					GameEvents.SendCustomGameEventToServer("player_alt_click", {message: message});
				} else {
							Players.PlayerPortraitClicked(playerId, false, false);
				}
			}
		);
	}

	playerPanel.SetHasClass( "is_local_player", ( playerId == Game.GetLocalPlayerID() ) );
	
	var ultStateOrTime = PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_HIDDEN; // values > 0 mean on cooldown for that many seconds
	var goldValue = -1;
	var isTeammate = false;

	var playerInfo = Game.GetPlayerInfo( playerId );
	if ( playerInfo )
	{
		//$.Msg(playerInfo);
		isTeammate = ( playerInfo.player_team_id == localPlayerTeamId );
		if ( isTeammate )
		{
			ultStateOrTime = Game.GetPlayerUltimateStateOrTime( playerId );
		}
		goldValue = playerInfo.player_gold;
		
		playerPanel.SetHasClass( "player_dead", ( playerInfo.player_respawn_seconds >= 0 ) );
		playerPanel.SetHasClass( "local_player_teammate", isTeammate && ( playerId != Game.GetLocalPlayerID() ) );

		_ScoreboardUpdater_SetTextSafe( playerPanel, "RespawnTimer", ( playerInfo.player_respawn_seconds + 1 ) ); // value is rounded down so just add one for rounded-up
		_ScoreboardUpdater_SetTextSafe( playerPanel, "PlayerName", playerInfo.player_name );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Level", playerInfo.player_level );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Kills", playerInfo.player_kills );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Deaths", playerInfo.player_deaths );
		_ScoreboardUpdater_SetTextSafe( playerPanel, "Assists", playerInfo.player_assists );

		var playerPortrait = playerPanel.FindChildInLayoutFile( "HeroIcon" );
		if ( playerPortrait )
		{
			if ( playerInfo.player_selected_hero !== "" )
			{
				//$.Msg(playerInfo.player_selected_hero);
				playerPortrait.SetImage( "file://{images}/heroes/" + playerInfo.player_selected_hero + ".png" );
			}
			else
			{
				playerPortrait.SetImage( "file://{images}/custom_game/unassigned.png" );
			}
		}
		
		if ( playerInfo.player_selected_hero_id == -1 )
		{
			_ScoreboardUpdater_SetTextSafe( playerPanel, "HeroName", $.Localize( "#DOTA_Scoreboard_Picking_Hero" ) )
		}
		else
		{
			_ScoreboardUpdater_SetTextSafe( playerPanel, "HeroName", $.Localize( "#"+playerInfo.player_selected_hero ) )
		}
		
		var heroNameAndDescription = playerPanel.FindChildInLayoutFile( "HeroNameAndDescription" );
		if ( heroNameAndDescription )
		{
			if ( playerInfo.player_selected_hero_id == -1 )
			{
				heroNameAndDescription.SetDialogVariable( "hero_name", $.Localize( "#DOTA_Scoreboard_Picking_Hero" ) );
			}
			else
			{
				heroNameAndDescription.SetDialogVariable( "hero_name", $.Localize( "#"+playerInfo.player_selected_hero ) );
			}
			heroNameAndDescription.SetDialogVariableInt( "hero_level",  playerInfo.player_level );
		}		

		playerPanel.SetHasClass( "player_connection_abandoned", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED );
		playerPanel.SetHasClass( "player_connection_failed", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED );
		playerPanel.SetHasClass( "player_connection_disconnected", playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED );

		var playerAvatar = playerPanel.FindChildInLayoutFile( "AvatarImage" );
		if ( playerAvatar )
		{
			playerAvatar.steamid = playerInfo.player_steamid;
		}		

		var playerColorBar = playerPanel.FindChildInLayoutFile( "PlayerColorBar" );
		if ( playerColorBar !== null )
		{
			var playerColor = Players.GetPlayerColor(playerId);
			if (playerColor >= 0) {
				var red = playerColor & 255;
				var green = playerColor >> 8 & 255;
				var blue = playerColor >> 16 & 255;
				var hexColor = "rgb(" + red + "," + green + "," + blue + ")";
				playerColorBar.style.backgroundColor = hexColor;
			} else {
				playerColorBar.style.backgroundColor = "black";
			}
			// if ( GameUI.CustomUIConfig().team_colors )
			// {
				// var teamColor = GameUI.CustomUIConfig().team_colors[ playerInfo.player_team_id ];
				// if ( teamColor )
				// {
					// playerColorBar.style.backgroundColor = teamColor;
				// }
			// }
			// else
			// {
				// var playerColor = "#000000";
				// playerColorBar.style.backgroundColor = playerColor;
			// }
		}

		var playerIDPanel = playerPanel.FindChildInLayoutFile( "PlayerID" );
		var playerGoldPanel = playerPanel.FindChildInLayoutFile( "PlayerGold" );
		var playerSealPanel = playerPanel.FindChildInLayoutFile( "SealIndicator" );
		var playerID = playerInfo.player_id;
		var playerTeam = playerInfo.player_team_id;
		if ( playerIDPanel !== null)
		{
			playerIDPanel.text = playerID;
			playerGoldPanel.text = Players.GetGold(playerID) + "G";
		}

		if (playerGoldPanel !== null)
		{
			if (playerTeam == Players.GetTeam(Players.GetLocalPlayer()))
			{
				var gold = Players.GetGold(playerID);
				playerGoldPanel.text = gold + "G";
			} 
			else
			{
				playerGoldPanel.text = "";
			}
		}
		if ( playerSealPanel !== null)
		{
			if (playerTeam == Players.GetTeam(Players.GetLocalPlayer()))
			{
				var bIsRevoked = ScoreboardUpdater_IsRevoked(Players.GetPlayerHeroEntityIndex(playerID));
				if (bIsRevoked)
				{
					playerSealPanel.SetImage("file://{images}/spellicons/cmd_seal_4_disabled.png") ;
				}
				else
				{
					playerSealPanel.SetImage("file://{images}/spellicons/cmd_seal_4.png") ;
				}

			}
			//playerSealPanel = 0;
		}



	}
	
	var playerItemsContainer = playerPanel.FindChildInLayoutFile( "PlayerItemsContainer" );
	if ( playerItemsContainer )
	{
		var playerItems = Game.GetPlayerItems( playerId );
		if ( playerItems )
		{
	//		$.Msg( "playerItems = ", playerItems );
			for ( var i = playerItems.inventory_slot_min; i < playerItems.inventory_slot_max; ++i )
			{
				var itemPanelName = "_dynamic_item_" + i;
				var itemPanel = playerItemsContainer.FindChild( itemPanelName );
				if ( itemPanel === null )
				{
					itemPanel = $.CreatePanel( "Image", playerItemsContainer, itemPanelName );
					itemPanel.AddClass( "PlayerItem" );
				}

				var itemInfo = playerItems.inventory[i];
				if ( itemInfo )
				{
					var item_image_name = "file://{images}/items/" + itemInfo.item_name.replace( "item_", "" ) + ".png"
					if ( itemInfo.item_name.indexOf( "recipe" ) >= 0 )
					{
						item_image_name = "file://{images}/items/recipe.png"
					}
					itemPanel.SetImage( item_image_name );
				}
				else
				{
					itemPanel.SetImage( "" );
				}
			}
		}
	}

	if ( isTeammate )
	{
		_ScoreboardUpdater_SetTextSafe( playerPanel, "TeammateGoldAmount", goldValue );
	}

	_ScoreboardUpdater_SetTextSafe( playerPanel, "PlayerGoldAmount", goldValue );

	var hero = Players.GetPlayerHeroEntityIndex(playerID);
	var comboStatus = isTeammate ? GetComboStatus(hero) : -2;
	playerPanel.SetHasClass( "player_ultimate_ready", comboStatus == 0);
	// playerPanel.SetHasClass( "player_ultimate_no_mana", ( ultStateOrTime == PlayerUltimateStateOrTime_t.PLAYER_ULTIMATE_STATE_NO_MANA) );
	playerPanel.SetHasClass( "player_ultimate_not_leveled", comboStatus == -1);
	playerPanel.SetHasClass( "player_ultimate_hidden", comboStatus == -2);
	playerPanel.SetHasClass( "player_ultimate_cooldown", comboStatus > 0);
	// _ScoreboardUpdater_SetTextSafe( playerPanel, "PlayerUltimateCooldown", ultStateOrTime );
}


//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdateTeamPanel( scoreboardConfig, containerPanel, teamDetails, teamsInfo )
{
	if ( !containerPanel )
		return;

	var teamId = teamDetails.team_id;
//	$.Msg( "_ScoreboardUpdater_UpdateTeamPanel: ", teamId );

	var teamPanelName = "_dynamic_team_" + teamId;
	var teamPanel = containerPanel.FindChild( teamPanelName );
	if ( teamPanel === null )
	{
//		$.Msg( "UpdateTeamPanel.Create: ", teamPanelName, " = ", scoreboardConfig.teamXmlName );
		teamPanel = $.CreatePanel( "Panel", containerPanel, teamPanelName );
		teamPanel.SetAttributeInt( "team_id", teamId );
		teamPanel.BLoadLayout( scoreboardConfig.teamXmlName, false, false );

		var logo_xml = GameUI.CustomUIConfig().team_logo_xml;
		if ( logo_xml )
		{
			var teamLogoPanel = teamPanel.FindChildInLayoutFile( "TeamLogo" );
			if ( teamLogoPanel )
			{
				teamLogoPanel.SetAttributeInt( "team_id", teamId );
				teamLogoPanel.BLoadLayout( logo_xml, false, false );
			}
		}
	}
	
	var localPlayerTeamId = -1;
	var localPlayer = Game.GetLocalPlayerInfo();
	if ( localPlayer )
	{
		localPlayerTeamId = localPlayer.player_team_id;
	}
	teamPanel.SetHasClass( "local_player_team", localPlayerTeamId == teamId );
	teamPanel.SetHasClass( "not_local_player_team", localPlayerTeamId != teamId );

	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId )
	var playersContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	if ( playersContainer )
	{
		for ( var playerId of teamPlayers )
		{
			_ScoreboardUpdater_UpdatePlayerPanel( scoreboardConfig, playersContainer, playerId, localPlayerTeamId )
		}
	}
	

	teamPanel.SetHasClass( "no_players", (teamPlayers.length == 0) )
	teamPanel.SetHasClass( "one_player", (teamPlayers.length == 1) )
	
	if ( teamsInfo.max_team_players < teamPlayers.length )
	{
		teamsInfo.max_team_players = teamPlayers.length;
	}

	if (Game.GetMapInfo().map_display_name == "fate_elim_6v6") { 
		if (teamId == 2)
		{
			_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamScore", g_RadiantScore );
		} else if (teamId == 3)
		{
			_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamScore", g_DireScore );
		}
	} else _ScoreboardUpdater_SetTextSafe( teamPanel, "TeamScore", teamDetails.team_score );

	_ScoreboardUpdater_SetTextSafe( teamPanel, "TeamName", $.Localize( teamDetails.team_name ) )
	
	if ( GameUI.CustomUIConfig().team_colors )
	{
		var teamColor = GameUI.CustomUIConfig().team_colors[ teamId ];
		var teamColorPanel = teamPanel.FindChildInLayoutFile( "TeamColor" );
		
		teamColor = teamColor.replace( ";", "" );

		if ( teamColorPanel )
		{
			teamNamePanel.style.backgroundColor = teamColor + ";";
		}
		
		var teamColor_GradentFromTransparentLeft = teamPanel.FindChildInLayoutFile( "TeamColor_GradentFromTransparentLeft" );
		if ( teamColor_GradentFromTransparentLeft )
		{
			var gradientText = 'gradient( linear, 0% 0%, 800% 0%, from( #00000000 ), to( ' + teamColor + ' ) );';
//			$.Msg( gradientText );
			teamColor_GradentFromTransparentLeft.style.backgroundColor = gradientText;
		}
	}
	
	return teamPanel;
}

//=============================================================================
//=============================================================================
function _ScoreboardUpdater_ReorderTeam( scoreboardConfig, teamsParent, teamPanel, teamId, newPlace, prevPanel )
{
//	$.Msg( "UPDATE: ", GameUI.CustomUIConfig().teamsPrevPlace );
	var oldPlace = null;
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length > teamId )
	{
		oldPlace = GameUI.CustomUIConfig().teamsPrevPlace[ teamId ];
	}
	GameUI.CustomUIConfig().teamsPrevPlace[ teamId ] = newPlace;
	
	if ( newPlace != oldPlace )
	{
//		$.Msg( "Team ", teamId, " : ", oldPlace, " --> ", newPlace );
		teamPanel.RemoveClass( "team_getting_worse" );
		teamPanel.RemoveClass( "team_getting_better" );
		if ( newPlace > oldPlace )
		{
			teamPanel.AddClass( "team_getting_worse" );
		}
		else if ( newPlace < oldPlace )
		{
			teamPanel.AddClass( "team_getting_better" );
		}
	}

	teamsParent.MoveChildAfter( teamPanel, prevPanel );
}

// sort / reorder as necessary
function compareFunc( a, b ) // GameUI.CustomUIConfig().sort_teams_compare_func;
{
	var scoreA;
	var scoreB;
	if (Game.GetMapInfo().map_display_name == "fate_elim_6v6") {
		scoreA = a.team_id == 2 ? g_RadiantScore : g_DireScore;
		scoreB = b.team_id == 2 ? g_RadiantScore : g_DireScore;
	} else {
		scoreA = a.team_score;
		scoreB = b.team_score;
	}
	if (scoreA < scoreB) {
		return 1; // [ B, A ]
	} else if (scoreA > scoreB) {
		return -1; // [ A, B ]
	}
	return 0;
};

function stableCompareFunc( a, b )
{
	var unstableCompare = compareFunc( a, b );
	if ( unstableCompare != 0 )
	{
		return unstableCompare;
	}
	
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length <= a.team_id )
	{
		return 0;
	}
	
	if ( GameUI.CustomUIConfig().teamsPrevPlace.length <= b.team_id )
	{
		return 0;
	}
	
//			$.Msg( GameUI.CustomUIConfig().teamsPrevPlace );

	var a_prev = GameUI.CustomUIConfig().teamsPrevPlace[ a.team_id ];
	var b_prev = GameUI.CustomUIConfig().teamsPrevPlace[ b.team_id ];
	if ( a_prev < b_prev ) // [ A, B ]
	{
		return -1; // [ A, B ]
	}
	else if ( a_prev > b_prev ) // [ B, A ]
	{
		return 1; // [ B, A ]
	}
	else
	{
		return 0;
	}
};


//=============================================================================
//=============================================================================
function _ScoreboardUpdater_UpdateAllTeamsAndPlayers( scoreboardConfig, teamsContainer )
{
//	$.Msg( "_ScoreboardUpdater_UpdateAllTeamsAndPlayers: ", scoreboardConfig );
	
	// Retrieve team information and store them in teamsList
	var teamsList = [];
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		teamsList.push( Game.GetTeamDetails( teamId ) );
	}

	// update/create team panels
	var teamsInfo = { max_team_players: 0 };
	var panelsByTeam = [];
	for ( var i = 0; i < teamsList.length; ++i )
	{
		var teamPanel = _ScoreboardUpdater_UpdateTeamPanel( scoreboardConfig, teamsContainer, teamsList[i], teamsInfo );
		if ( teamPanel )
		{
			panelsByTeam[ teamsList[i].team_id ] = teamPanel;
		}
	}

	if ( teamsList.length > 1 )
	{
//		$.Msg( "panelsByTeam: ", panelsByTeam );

		// sort
		if ( scoreboardConfig.shouldSort )
		{
			teamsList.sort( stableCompareFunc );
		}

//		$.Msg( "POST: ", teamsAndPanels );

		// reorder the panels based on the sort
		var prevPanel = panelsByTeam[ teamsList[0].team_id ];
		for ( var i = 0; i < teamsList.length; ++i )
		{
			var teamId = teamsList[i].team_id;
			var teamPanel = panelsByTeam[ teamId ];
			_ScoreboardUpdater_ReorderTeam( scoreboardConfig, teamsContainer, teamPanel, teamId, i, prevPanel );
			prevPanel = teamPanel;
		}
//		$.Msg( GameUI.CustomUIConfig().teamsPrevPlace );
	}

//	$.Msg( "END _ScoreboardUpdater_UpdateAllTeamsAndPlayers: ", scoreboardConfig );
}


//=============================================================================
//=============================================================================
function ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, scoreboardPanel )
{
	GameUI.CustomUIConfig().teamsPrevPlace = [];
	if ( typeof(scoreboardConfig.shouldSort) === 'undefined')
	{
		// default to true
		scoreboardConfig.shouldSort = true;
	}
	_ScoreboardUpdater_UpdateAllTeamsAndPlayers( scoreboardConfig, scoreboardPanel );

	return { "scoreboardConfig": scoreboardConfig, "scoreboardPanel":scoreboardPanel }
}


//=============================================================================
//=============================================================================
function ScoreboardUpdater_SetScoreboardActive( scoreboardHandle, isActive )
{
	if ( scoreboardHandle.scoreboardConfig === null || scoreboardHandle.scoreboardPanel === null )
	{
		return;
	}
	
	if ( isActive )
	{
		_ScoreboardUpdater_UpdateAllTeamsAndPlayers( scoreboardHandle.scoreboardConfig, scoreboardHandle.scoreboardPanel );
	}
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_GetTeamPanel( scoreboardHandle, teamId )
{
	if ( scoreboardHandle.scoreboardPanel === null )
	{
		return;
	}
	
	var teamPanelName = "_dynamic_team_" + teamId;
	return scoreboardHandle.scoreboardPanel.FindChild( teamPanelName );
}

//=============================================================================
//=============================================================================
function ScoreboardUpdater_GetSortedTeamInfoList( scoreboardHandle )
{
	var teamsList = [];
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		teamsList.push( Game.GetTeamDetails( teamId ) );
	}

	if ( teamsList.length > 1 )
	{
		teamsList.sort( stableCompareFunc );		
	}
	
	return teamsList;
}

var revokes = [
    "modifier_subterranean_grasp_revoke",
    "modifier_enkidu_hold",
    "jump_pause",
    "pause_sealdisabled",
    "rb_sealdisabled",
    "revoked",
    "modifier_command_seal_2",
    "modifier_command_seal_3",
    "modifier_command_seal_4"
]

function ScoreboardUpdater_IsRevoked(hero)
{
	/* var buffCount = Entities.GetNumBuffs(hero) + 1;
	$.Msg(buffCount);
	for (var i=0;i<buffCount + 1; i++)
	{
		var buffName = Buffs.GetName(hero,i);
		$.Msg(buffName);
		for (var j=0; j<revokes.length; j++)
		{
			if (buffName == revokes[j])
			{
				return true
			}
		}
	}
	return false */
	for (var j=0; j<revokes.length; j++)
	{
		if (Entities.HasModifier(hero, revokes[j]))
		{
			return true
		}
	}
	return false
}

Entities.HasModifier = function(entIndex, modifierName){
	var nBuffs = Entities.GetNumBuffs(entIndex)
	for (var i = 0; i < nBuffs; i++) {
		if (Buffs.GetName(entIndex, Entities.GetBuff(entIndex, i)) == modifierName)
			return true
	};
	return false
};

function GetComboStatus(heroEntIndex) {
	var config = GameUI.CustomUIConfig();
	var entIndex = config.masterUnits && config.masterUnits[heroEntIndex];
	if (!entIndex) {
		return -1
	}
	var nBuffs = Entities.GetNumBuffs(entIndex)
	for (var i = 0; i < nBuffs; i++) {
		var buff = Entities.GetBuff(entIndex, i);
		var buffName = Buffs.GetName(entIndex, buff);
		if (buffName == "combo_unavailable") {
			return -1
		}
		if (buffName == "combo_cooldown") {
			return Buffs.GetRemainingTime(entIndex, buff);
		}
	};
	return 0;
}
