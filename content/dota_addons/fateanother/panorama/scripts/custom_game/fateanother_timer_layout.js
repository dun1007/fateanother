var timerTable = {

};

function CreateTimer(data) {

	var parent = $("#RoundTimerPanel");
	if (!parent)
		return;

	var message = data.timerMsg;
	var duration = data.timerDuration;
	var desc = data.timerDescription;
	var timerPanel = 0;
	//If timer is already present
	if (desc in timerTable)
	{
		if (timerTable[desc] == null)
		{
			$.Msg("existing object is null, creating new panel")

		}
		else
		{
			$.Msg("object is already present, deleting if new duration input is 0");
			timerPanel = timerTable[desc]
			timerTable[desc].RemoveAndDeleteChildren();
			delete timerTable[desc];
			//return;
		}
	}
	else
	{
	}
	timerPanel = $.CreatePanel("Panel", parent, "");
	timerTable[desc] = timerPanel;
	timerPanel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_timer.xml", false, false );
	timerPanel.SetTimer(message, duration);
	timerPanel.SetPanelEvent(
		"onactivate",
		timerPanel.TimerClicked
	);
}




(function () {
	//GameEvents.Subscribe( "display_timer", DisplayTimer );
 	GameEvents.Subscribe( "display_timer", CreateTimer);
})();
