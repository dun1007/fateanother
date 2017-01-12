function OnHeroKilled(data)
{
	$.Msg("[FATE] fate_hero_killed");
	$.Msg(data, "\n------");
	var killer = data.killer
	var victim = data.victim

	var popupCount = $("#CombatEventPanel").GetChildCount();
	//$.Msg(popupCount);
	if (popupCount > 5)
	{
		$("#CombatEventPanel").GetChild(0).DeleteAsync(0);
	}

	var popup = $.CreatePanel('Panel', $("#CombatEventPanel"), '');
	popup.hittest = false;
	if (Entities.IsEnemy(victim))
	{
		popup.AddClass('CombatEventPopupAlly'); //css properties
	}
	else
	{
		popup.AddClass('CombatEventPopupEnemy'); 
	}
	//popup.AddClass('CombatEventPopupAlly'); //css properties
	// do valid checks
	var victimPortrait = $.CreatePanel('DOTAHeroImage', popup, '');
	victimPortrait.heroimagestyle = "landscape";
	victimPortrait.heroname = Entities.GetUnitName(victim);
	victimPortrait.hittest = false;
	victimPortrait.AddClass('CombatEventPortrait');
	victimPortrait.AddClass('VictimOverlay');
	victimPortrait.hittest = false;


	var KDIcon = $.CreatePanel('Image', popup, '');
	if (Entities.IsEnemy(victim))
	{
		KDIcon.SetImage("file://{images}/misc/kill_icon.png");
	}
	else
	{
		KDIcon.SetImage("file://{images}/misc/death_icon.png");
	}
	KDIcon.AddClass('CombatEventIcon');
	KDIcon.hittest = false;

	var killerPortrait = $.CreatePanel('DOTAHeroImage', popup, '');
	killerPortrait.heroimagestyle = "landscape";
	killerPortrait.heroname = Entities.GetUnitName(killer);
	killerPortrait.hittest = false;
	killerPortrait.AddClass('CombatEventPortrait');
	killerPortrait.AddClass('KillerOverlay');
	killerPortrait.hittest = false;

	$.Schedule(8, function(){
		if (popup) {popup.DeleteAsync(0);}
	});
}

function ClearCombatEvent()
{
	$.Schedule(4.5, function() {
		for (var i=0; i<$("#CombatEventPanel").GetChildCount(); i++)
		{
			$("#CombatEventPanel").GetChild(i).DeleteAsync(0);
		}
	});
}

(function () {
    GameEvents.Subscribe("fate_hero_killed", OnHeroKilled );
    //GameEvents.Subscribe("winner_decided", ClearCombatEvent);
})();
