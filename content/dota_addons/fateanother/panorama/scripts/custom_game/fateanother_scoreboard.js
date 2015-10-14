"use strict";

function UpdateTimer( data )
{
	//$.Msg( "UpdateTimer: ", data );
	//var timerValue = Game.GetDOTATime( false, false );

	//var sec = Math.floor( timerValue % 60 );
	//var min = Math.floor( timerValue / 60 );

	//var timerText = "";
	//timerText += min;
	//timerText += ":";

	//if ( sec < 10 )
	//{
	//	timerText += "0";
	//}
	//timerText += sec;

	var timerText = "";
	timerText += data.timer_minute_10;
	timerText += data.timer_minute_01;
	timerText += ":";
	timerText += data.timer_second_10;
	timerText += data.timer_second_01;

	$( "#Timer" ).text = timerText;

	//$.Schedule( 0.1, UpdateTimer );
}

function UpdateWinCondition( data )
{
	//var victory_condition = CustomNetTables.GetTableValue( "game_state", "victory_condition" );
	//if ( victory_condition )
	$.Msg("victory condition updated")
	$("#VictoryPoints").text = data.victoryCondition;
	
}

(function()
{
	// We use a nettable to communicate victory conditions to make sure we get the value regardless of timing.
	//UpdateKillsToWin();
	//CustomNetTables.SubscribeNetTableListener( "game_state", OnGameStateChanged );
    GameEvents.Subscribe( "victory_condition_set", UpdateWinCondition );
    GameEvents.Subscribe( "timer_think", UpdateTimer );
    //GameEvents.Subscribe( "show_timer", ShowTimer );
    //GameEvents.Subscribe( "timer_alert", AlertTimer );
    //GameEvents.Subscribe( "overtime_alert", HideTimer );
	//UpdateTimer();
})();

