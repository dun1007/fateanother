var m_Duration = 0;

function FormatTime( seconds ) {
	var hours = Math.floor(seconds / 3600);
	var remainder = seconds % 3600;
	var minutes = Math.floor(remainder / 60);
	var seconds = Math.floor(remainder % 60);
	var s = "";
	var m = "";
	var h = "";
	if (seconds < 10)
		s = "0";
	if (minutes < 10)
		m = "0";
	if (hours < 10)
		h = "0";
	return h + hours + ":" + m + minutes + ":" + s + seconds;
}

function SetTimer( message, duration )
{
	var messageLabel = $("#TimerMsg");
	var timeLabel = $("#TimerRemaining");
	if (!messageLabel || !timeLabel) {
		return;
	}
	var time = duration;
	var gameTime = Game.GetGameTime();
	var msg = message;
	messageLabel.text = msg;
	timeLabel.text = FormatTime(time);


	$.Schedule(1, function(){
		if (gameTime != Game.GetGameTime())
		{
			time = duration - 1;
		}
		if (time <= 0) {
			$.GetContextPanel().RemoveAndDeleteChildren();
			return;
		}
		SetTimer(msg, time);
	});
}


function UpdateTimer(message, duration)
{

}

(function()
{
	$.GetContextPanel().data().SetTimer = SetTimer;
	//GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	//AutoUpdateAbility(); // initial update of dynamic state
})();