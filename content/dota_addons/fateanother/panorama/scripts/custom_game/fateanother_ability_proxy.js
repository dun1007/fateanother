var abilityLayoutNumber = {
    gille_oceanic_demon: 1,
    caster_5th_ancient_dragon: 3,
    avenger_remain: 1,
};

var AbilityProxy = function(panel) {
    this.panel = panel;
    this.unit = Players.GetLocalPlayerPortraitUnit();
    this.tooltipAbility = null;
    this.tooltipIndex = null;
    this.resolutionClass = null;

    for (var i = 0; i < 6; i++) {
        this.bindMouseEvents(i);
    }

    this.UpdateLayout();
}

AbilityProxy.prototype.bindMouseEvents = function(index) {
    var that = this;
    $("#Ability" + index).SetPanelEvent(
        "onactivate",
        function() {
            that.OnActivate(index);
        }
    )

    $("#Ability" + index).SetPanelEvent(
        "onmouseover",
        function() {
            that.OnMouseOver(index);
        }
    )

    $("#Ability" + index).SetPanelEvent(
        "onmouseout",
        function() {
            that.OnMouseOut(index);
        }
    )
}

AbilityProxy.prototype.UpdateSelectedUnit = function() {
    this.unit = Players.GetLocalPlayerPortraitUnit();
    this.UpdateLayout();
}

AbilityProxy.prototype.UpdateQueryUnit = function() {
    var queryUnit = Players.GetQueryUnit(Players.GetLocalPlayer());
    if (queryUnit != -1) {
        this.unit = queryUnit;
        this.UpdateLayout();
    }
}

AbilityProxy.prototype.UpdateLayout = function() {
    this.layout = abilityLayoutNumber[Entities.GetUnitName(this.unit)] || 6;
    this.panel.SetHasClass("Big", this.layout < 6);
}

AbilityProxy.prototype.OnActivate = function(index) {
    var ability = Entities.GetAbility(this.unit, index)
    if (ability == -1) {
        return;
    }
    if (Game.IsInAbilityLearnMode()) {
        Abilities.AttemptToUpgrade(ability);
    } else if (GameUI.IsAltDown()) {
        Abilities.PingAbility(ability);
    } else {
        Abilities.ExecuteAbility(ability, this.unit, false);
    }
}

AbilityProxy.prototype.Update = function() {
    var hud = GameUI.CustomUIConfig().hud;
    var resolutionHeight = hud.actuallayoutheight;
    var resolutionWidth = hud.actuallayoutwidth;

    if (resolutionHeight <= 576 || resolutionWidth <= 720) {
        this.panel.visible = false;
        return;
    }

    if (!this.tooltipIndex) {
        return;
    }

    var resolutionClass = "r" + resolutionWidth + "x" + resolutionHeight;

    if (resolutionClass != this.resolutionClass) {
        this.panel.SetHasClass(this.resolutionClass, false);
        this.panel.SetHasClass(resolutionClass, true);
        this.resolutionClass = resolutionClass;
    }

    this.panel.visible = true;


    var ability = Entities.GetAbility(this.unit, this.tooltipIndex)
    if (ability != this.tooltipAbility) {
        $.DispatchEvent("DOTAHideAbilityTooltip");

        this.tooltipIndex = null;
        this.tooltipAbility = null;
    }
}

AbilityProxy.prototype.OnMouseOver = function(index) {
    var ability = Entities.GetAbility(this.unit, index);
    if (ability == -1) {
        return;
    }
    var name = Abilities.GetAbilityName(ability);
    $.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", $("#Ability" + index).GetChild(0), name, this.unit);

    this.tooltipAbility = ability;
    this.tooltipIndex = index;
}

AbilityProxy.prototype.OnMouseOut = function(index) {
    $.DispatchEvent("DOTAHideAbilityTooltip");

    this.tooltipIndex = null;
    this.tooltipAbility = null;
}

var abilityProxy = new AbilityProxy($.GetContextPanel());

GameEvents.Subscribe("dota_player_update_selected_unit", function() {
    abilityProxy.UpdateSelectedUnit();
});
GameEvents.Subscribe("dota_player_update_query_unit", function() {
    abilityProxy.UpdateQueryUnit();
});

function UpdateAbilityProxy() {
    abilityProxy.Update();
    $.Schedule(1/60, UpdateAbilityProxy);
}

UpdateAbilityProxy();
