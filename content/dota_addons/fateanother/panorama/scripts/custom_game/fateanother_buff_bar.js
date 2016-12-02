/**
[   PanoramaScript         ]: GetName
[   PanoramaScript         ]: GetClass
[   PanoramaScript         ]: GetTexture
[   PanoramaScript         ]: GetDuration
[   PanoramaScript         ]: GetDieTime
[   PanoramaScript         ]: GetRemainingTime
[   PanoramaScript         ]: GetElapsedTime
[   PanoramaScript         ]: GetCreationTime
[   PanoramaScript         ]: GetStackCount
[   PanoramaScript         ]: IsDebuff
[   PanoramaScript         ]: IsHidden
[   PanoramaScript         ]: GetCaster
[   PanoramaScript         ]: GetParent
[   PanoramaScript         ]: GetAbility
**/

// var hero = Players.GetPlayerHeroEntityIndex(playerId);
// var nBuffs = Entities.GetNumBuffs(hero)
// var buff = Entities.GetBuff(hero, i)

var buffHasStacks = {
    modifier_courage_damage_stack_indicator: true,
    modifier_courage_stackable_buff: true,
    modifier_madness_stack: true,
    modifier_god_hand_stock: true,
};

function BuffPanel(parent) {
    var that = {};
    var panel = $.CreatePanel("Panel", parent, "");
    panel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_buff.xml", false, false);
    that.panel = panel;
    that.tooltipRoot = panel.FindChild("TooltipRoot");

    that.panel.SetPanelEvent(
        "onmouseover",
        function() {
            that.OnMouseOver();
        }
    )

    that.panel.SetPanelEvent(
        "onmouseout",
        function() {
            that.OnMouseOut();
        }
    )

    that.panel.SetPanelEvent(
        "onactivate",
        function() {
            that.OnActivate();
        }
    )

    that.SetBuff = function(unit, buff) {
        that.buff = buff;
        that.unit = unit;
        that.name = Buffs.GetName(unit, buff);
        that.image = Buffs.GetTexture(unit, buff);
        that.duration = Buffs.GetDuration(unit, buff);
        that.remainingTime = Buffs.GetRemainingTime(unit, buff);
        that.stackCount = Buffs.GetStackCount(unit, buff);
        that.isDebuff = Buffs.IsDebuff(unit, buff);
        that.hasStacks = !!buffHasStacks[that.name];
    }

    that.OnMouseOver = function() {
        if (!that.buff || !that.unit) {
            return;
        }
        $.DispatchEvent("DOTAShowBuffTooltip", that.tooltipRoot, that.unit, that.buff, false);
    }

    that.OnMouseOut = function() {
        $.DispatchEvent("DOTAHideBuffTooltip");
    }

    that.OnActivate = function() {
        if (!Entities.IsHero(that.unit) || !GameUI.IsAltDown()) {
            return;
        }
        var localName = $.Localize("DOTA_Tooltip_" + that.name);
        var colour = that.isDebuff ? "_red_" : "_green_";
        var message = "_default_Affected by " + colour + localName + "_default_";
        if (that.hasStacks) {
            message += " ( _gold_" + that.stackCount + "_default_ stack" + (that.stackCount == 1 ? "" : "s") + " )"
        }
        GameEvents.SendCustomGameEventToServer("player_alt_click_buff", {
            message: message,
            ability: that.name,
            unit: that.unit
        });
    }

    that.SetVisible = function(visible) {
        SetVisiblePanel(that.panel, visible);
    }

    that.Update = function() {
        var buffIconPanel = this.panel.FindChild("BuffIcon");
        buffIconPanel.SetImage( "file://{images}/spellicons/" + that.image + ".png");

        var prefix = that.isDebuff ? "Debuff" : "Buff";
        var otherPrefix = that.isDebuff ? "Buff" : "Debuff";

        SetVisiblePanel(that.panel.FindChild(prefix + "Active"), true);
        SetVisiblePanel(that.panel.FindChild(prefix + "Cooldown"), true);
        SetVisiblePanel(that.panel.FindChild(otherPrefix + "Active"), false);
        SetVisiblePanel(that.panel.FindChild(otherPrefix + "Cooldown"), false);

        var stacksPanel = that.panel.FindChild("BuffStacks");
        SetVisiblePanel(stacksPanel, that.hasStacks);
        stacksPanel.text = that.stackCount;

        var cooldownPanel = that.panel.FindChild(prefix + "Cooldown")
        var progress;
        if (that.duration < 0) {
            progress = 0;
        } else if (that.remainingTime < 0) {
            progress = 360;
        } else {
            progress = 360 - that.remainingTime / that.duration * 360;
            if (isNaN(progress)) {
                progress = 360;
            }
        }
        cooldownPanel.style.clip = "radial(50% 50%, 0deg, " + progress + "deg)";
    }

    return that;
}


var BuffBar = function(panel) {
    var that = {};
    that.panel = panel;
    that.buffPanels = [];
    that.unit = null;

    that.UpdateSelectedUnit = function() {
        that.unit = Players.GetLocalPlayerPortraitUnit();
    }

    that.UpdateQueryUnit = function() {
        var queryUnit = Players.GetQueryUnit(Players.GetLocalPlayer());
        that.unit = queryUnit == -1 ? null : queryUnit;
    }

    that.Update = function() {
        if (that.unit !== null) {
            var visibleBuffs = that.GetVisibleBuffs();
            for (var i = that.buffPanels.length; i < visibleBuffs.length; i++) {
                var buffPanel = BuffPanel(that.panel);
                that.buffPanels.push(buffPanel);
            }
            for (var i = visibleBuffs.length; i < that.buffPanels.length; i++) {
                that.buffPanels[i].SetVisible(false);
            }
            for (var i = 0; i < visibleBuffs.length; i++) {
                  var buff = visibleBuffs[i];
                  var buffPanel = that.buffPanels[i];
                  buffPanel.SetVisible(true);
                  buffPanel.SetBuff(that.unit, buff);
                  buffPanel.Update();
            }
        }
    }

    that.GetVisibleBuffs = function() {
        var visibleBuffs = [];
        var nBuffs = Entities.GetNumBuffs(that.unit)
        for (var i = 0; i < nBuffs; i++)  {
            var buff = Entities.GetBuff(that.unit, i)
            if (Buffs.IsHidden(that.unit, buff)
                || !Buffs.GetName(that.unit, buff)) {
                continue;
            }
            visibleBuffs.push(buff);
        }
        return visibleBuffs;
    }

    return that;
}

function SetVisiblePanel(panel, visible) {
    panel.SetHasClass("Hidden", !visible);
}

function EndsWith(string, suffix) {
    return string.slice(string.length - suffix.length) == suffix;
}


var bar = BuffBar($.GetContextPanel());

function Update() {
    bar.Update();
    $.Schedule(1/60, Update);
}

GameEvents.Subscribe("dota_player_update_selected_unit", bar.UpdateSelectedUnit);
GameEvents.Subscribe("dota_player_update_query_unit", bar.UpdateQueryUnit);

Update();

