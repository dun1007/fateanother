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

function SetTimer(message, duration) {
	// offset by 1 since I believe GetGameTime() rounds down
	// this means that if a 10 second timer is created at
	// say 30.8s GameTime the timer will reach 00:00 at
	// 40s GameTime and disappear at 41s (showing 00:00 for around
	// 0.8 seconds). By offseting by 1, the timer instead reaches
	// 00:01 at 40s and disappears  at 41s.
	// This introduces some error but is unavoidable since
	// GetGameTime() only resolves to seconds. It is more intuitive
	// that the timer finishes on the 00:00 tick, instead of waiting
	// on 00:00 for an additional tick.
	SetTimerHelper(message, duration, Game.GetGameTime() + 1);
}

function SetTimerHelper(message, duration, previousTime)
{
	if (duration <= 0) {
		$.GetContextPanel().RemoveAndDeleteChildren();
		return;
	}

	var messageLabel = $("#TimerMsg");
	var timeLabel = $("#TimerRemaining");
	if (!messageLabel || !timeLabel) {
		return;
	}

	messageLabel.text = message;
	timeLabel.text = FormatTime(duration, 0);

	$.Schedule(0.2, function(){
		var currentTime = Game.GetGameTime();
		var timeDifference = currentTime - previousTime;
		SetTimerHelper(message, duration - timeDifference, currentTime);
	});
}

function TimerClicked() {
	if (!GameUI.IsAltDown()) {
		return;
	}
	var messageLabel = $("#TimerMsg");
	var timeLabel = $("#TimerRemaining");
	var message = "_gold_" + messageLabel.text + "_gray_ _arrow_ _default_" + timeLabel.text;
	GameEvents.SendCustomGameEventToServer("player_alt_click", {message: message});
}


function UpdateTimer(message, duration)
{

}

(function()
{
	$.GetContextPanel().SetTimer = SetTimer;
	$.GetContextPanel().TimerClicked = TimerClicked;
	//GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI ); // major rebuild
	//AutoUpdateAbility(); // initial update of dynamic state
})();
