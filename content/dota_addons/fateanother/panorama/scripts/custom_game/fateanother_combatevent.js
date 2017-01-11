function OnHeroKilled(data)
{
	$.Msg("[FATE] fate_hero_killed");
	$.Msg(data, "\n------");
	var killer = data.killer
	var victim = data.victim

	var popup = $.CreatePanel('Panel', $("#CombatEventPanel"), '');
	popup.AddClass('CombatEventPopupAlly'); //css properties
	popup.hittest = false;
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
	KDIcon.SetImage("file://{images}/misc/kill_icon.png");
	KDIcon.AddClass('CombatEventIcon');
	KDIcon.hittest = false;

	var killerPortrait = $.CreatePanel('DOTAHeroImage', popup, '');
	killerPortrait.heroimagestyle = "landscape";
	killerPortrait.heroname = Entities.GetUnitName(killer);
	killerPortrait.hittest = false;
	killerPortrait.AddClass('CombatEventPortrait');
	killerPortrait.AddClass('KillerOverlay');
	killerPortrait.hittest = false;

}

(function () {
    GameEvents.Subscribe("fate_hero_killed", OnHeroKilled );
})();
