var abilityLayoutNumber = {
    gille_oceanic_demon: 1,
    caster_5th_ancient_dragon: 3,
};

var AbilityProxy = function(panel) {
    var that = {};
    that.panel = panel;
    // that.unit = null;
    that.unit = Players.GetLocalPlayerPortraitUnit();
    that.layout = abilityLayoutNumber[Entities.GetUnitName(that.unit)];

    that.bindMouseEvents = function(index) {
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

    that.UpdateSelectedUnit = function() {
        that.unit = Players.GetLocalPlayerPortraitUnit();
        that.UpdateLayout();
    }

    that.UpdateQueryUnit = function() {
        var queryUnit = Players.GetQueryUnit(Players.GetLocalPlayer());
        if (queryUnit != -1) {
            that.unit = queryUnit;
            that.UpdateLayout();
        }
    }

    that.UpdateLayout = function() {
        that.layout = abilityLayoutNumber[Entities.GetUnitName(that.unit)] || 6;
        panel.SetHasClass("Big", that.layout < 6);
    }

    that.OnActivate = function(index) {
        var ability = Entities.GetAbility(that.unit, index)
        if (Game.IsInAbilityLearnMode()) {
            Abilities.AttemptToUpgrade(ability);
        } else {
            Abilities.ExecuteAbility(ability, that.unit, false);
        }
    }

    that.OnMouseOver = function(index) {
        var ability = Entities.GetAbility(that.unit, index);
        if (ability == -1) {

            return;
        }
        var name = Abilities.GetAbilityName(ability);
$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", $("#Ability" + index).GetChild(0), name, that.unit);
    }

    that.OnMouseOut = function(index) {
        $.DispatchEvent("DOTAHideAbilityTooltip");
    }

    that.Update = function() {
    }

    for (var i = 0; i < 6; i++) {
        that.bindMouseEvents(i);
    }

    return that;
}

function SetVisiblePanel(panel, visible) {
    panel.SetHasClass("Hidden", !visible);
}


var bar = AbilityProxy($.GetContextPanel());

GameEvents.Subscribe("dota_player_update_selected_unit", bar.UpdateSelectedUnit);
GameEvents.Subscribe("dota_player_update_query_unit", bar.UpdateQueryUnit);
