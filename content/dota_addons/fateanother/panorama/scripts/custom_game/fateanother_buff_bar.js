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

var buffHasStacks = {
    modifier_lancer_incinerate: true,
    modifier_derange_counter: true,
    modifier_courage_damage_stack_indicator: true,
    modifier_courage_stackable_buff: true,
    modifier_god_hand_stock: true,
    modifier_ta_agi_bonus: true,
    modifier_dark_passage: true,
    modifier_gae_buidhe: true,
    modifier_madness_stack: true,
    modifier_gladiusanus_blauserum: true,
    modifier_fiery_heaven_indicator: true,
    modifier_fiery_heaven_indicator_enemy: true,
    modifier_frigid_heaven_indicator: true,
    modifier_frigid_heaven_indicator_enemy: true,
    modifier_gust_heaven_indicator: true,
    modifier_gust_heaven_indicator_enemy  : true,
    modifier_soulstream_stack: true,
    modifier_mantra_ally: true,
    modifier_mantra_enemy: true,
    modifier_mark_of_fatality: true,
    modifier_furious_chain_buff: true,
    modifier_magic_resistance_ex_shield: true,
    modifier_plains_of_water_int_debuff: true,
    modifier_plains_of_water_int_buff: true,
};

var buffCooldown = {
    modifier_instinct_cooldown: 35,
    modifier_madmans_roar_cooldown: 150,
    modifier_strike_air_cooldown: 60,
    modifier_max_excalibur_cooldown: 150,
    modifier_battle_continuation_cooldown: 60,
    modifier_wesen_gae_bolg_cooldown: 90,
    modifier_max_mana_burst_cooldown: 150,
    modifier_bellerophon_2_cooldown: 100,
    modifier_arrow_rain_cooldown: 180,
    modifier_overedge_cooldown: 60,
    modifier_hrunting_cooldown: 80,
    modifier_quickdraw_cooldown: 60,
    modifier_tsubame_mai_cooldown: 150,
    modifier_delusional_illusion_cooldown: 150,
    modifier_max_enuma_elish_cooldown: 160,
    modifier_hecatic_graea_powered_cooldown: 150,
    modifier_eternal_arms_mastership_cooldown: 45,
    modifier_blessing_of_fairy_cooldown: 45,
    modifier_nuke_cooldown: 150,
    modifier_blood_mark_cooldown: 50,
    modifier_endless_loop_cooldown: 100,
    modifier_rampant_warrior_cooldown: 100,
    modifier_annihilate_cooldown: 140,
    modifier_larret_de_mort_cooldown: 150,
    modifier_fiery_finale_cooldown: 180,
    modifier_laus_saint_cladius_cooldown: 0, // unused
    modifier_invictus_spiritus_cooldown: 60,
    modifier_gawain_blessing_cooldown: 60,
    modifier_meltdown_cooldown: 90,
    modifier_supernova_cooldown: 170,
    modifier_mystic_shackle_cooldown: 30,
    modifier_fates_call_cooldown: 0, // unused
    modifier_polygamist_cooldown: 120,
    modifier_raging_dragon_strike_cooldown: 110,
    modifier_la_pucelle_cooldown: 135,
    modifier_hippogriff_ride_cooldown: 150,
    modifier_story_for_someones_sake_cooldown: 450,
};

var buffIsAura = {
    modifier_aestus_domus_aurea_debuff: true,
    modifier_aestus_domus_aurea_debuff_attribute: true,
    modifier_aestus_domus_aurea_debuff_slow: true,
    modifier_big_bad_voodoo_invulnerability: true,
};


function BuffPanel(parent) {
    var panel = $.CreatePanel("Panel", parent, "");
    panel.BLoadLayout("file://{resources}/layout/custom_game/fateanother_buff.xml", false, false);
    this.panel = panel;
    var that = this;

    this.panel.SetPanelEvent(
        "onactivate",
        function() {
            that.OnActivate();
        }
    )
}

BuffPanel.prototype.SetBuff = function(unit, buff) {
    this.buff = buff;
    this.unit = unit;
    this.name = Buffs.GetName(unit, buff);
    this.image = Buffs.GetTexture(unit, buff);
    this.duration = Buffs.GetDuration(unit, buff);
    this.remainingTime = Buffs.GetRemainingTime(unit, buff);
    this.stackCount = Buffs.GetStackCount(unit, buff);
    this.isDebuff = Buffs.IsDebuff(unit, buff);
    this.hasStacks = !!buffHasStacks[this.name];
}

BuffPanel.prototype.OnActivate = function() {
    if (!Entities.IsHero(this.unit) || !GameUI.IsAltDown()) {
        return;
    }
    $.Msg(this.name)
    var localName = $.Localize("DOTA_Tooltip_" + this.name);
    var colour = this.isDebuff ? "_red_" : "_green_";
    var message;
    if (buffCooldown[this.name]
        && Entities.GetTeamNumber(this.unit) == Players.GetTeam(Game.GetLocalPlayerID())) {
        var remainingTime = Math.ceil(this.remainingTime);
        message = colour + localName + " _default_( _gold_" + remainingTime + "_default_ second" + (remainingTime == 1 ? "" : "s") + " )";
    } else {
        message = "_default_Affected by " + colour + localName + "_default_";
        if (this.hasStacks) {
            message += " ( _gold_" + this.stackCount + "_default_ stack" + (this.stackCount == 1 ? "" : "s") + " )"
        }
    }
    GameEvents.SendCustomGameEventToServer("player_alt_click_buff", {
        message: message,
        ability: this.name,
        unit: this.unit
    });
}

BuffPanel.prototype.SetVisible = function(visible) {
    SetVisiblePanel(this.panel, visible);
}

BuffPanel.prototype.Update = function() {}

var BuffBar = function(panel) {
    this.panel = panel;
    this.buffPanels = [];
    this.unit = Players.GetLocalPlayerPortraitUnit();
    this.resolutionClass = null;
}

BuffBar.prototype.UpdateSelectedUnit = function() {
    this.unit = Players.GetLocalPlayerPortraitUnit();
}

BuffBar.prototype.UpdateQueryUnit = function() {
    var queryUnit = Players.GetQueryUnit(Players.GetLocalPlayer());
    if (queryUnit != -1) {
        this.unit = queryUnit;
    }
}

BuffBar.prototype.Update = function() {
    if (this.unit !== null && this.unit != -1) {

        var hud = GameUI.CustomUIConfig().hud;
        var resolutionHeight = hud.actuallayoutheight;
        var resolutionWidth = hud.actuallayoutwidth;

        if (resolutionHeight <= 576 || resolutionWidth <= 720) {
            this.panel.visible = false;
            return;
        }

        var resolutionClass = "r" + resolutionWidth + "x" + resolutionHeight;

        if (resolutionClass != this.resolutionClass) {
            this.panel.SetHasClass(this.resolutionClass, false);
            this.panel.SetHasClass(resolutionClass, true);
            this.resolutionClass = resolutionClass;
        }

        this.panel.visible = true;

        var visibleBuffs = this.GetVisibleBuffs();
        for (var i = this.buffPanels.length; i < visibleBuffs.length; i++) {
            var buffPanel = new BuffPanel(this.panel);
            this.buffPanels.push(buffPanel);
        }
        for (var i = visibleBuffs.length; i < this.buffPanels.length; i++) {
            this.buffPanels[i].SetVisible(false);
        }
        for (var i = 0; i < visibleBuffs.length; i++) {
              var buff = visibleBuffs[i];
              var buffPanel = this.buffPanels[i];
              buffPanel.SetVisible(true);
              buffPanel.SetBuff(this.unit, buff);
              buffPanel.Update();
        }
    }
}

BuffBar.prototype.GetVisibleBuffs = function() {
    var visibleBuffs = [];
    var nBuffs = Entities.GetNumBuffs(this.unit)
    for (var i = 0; i < nBuffs; i++)  {
        var buff = Entities.GetBuff(this.unit, i)
        if (Buffs.IsHidden(this.unit, buff)
            || !Buffs.GetName(this.unit, buff)) {
            continue;
        }
        visibleBuffs.push(buff);
        if (visibleBuffs.length >= 8) {
            break;
        }
    }
    return visibleBuffs;
}

function SetVisiblePanel(panel, visible) {
    panel.visible = visible;
}

function EndsWith(string, suffix) {
    return string.slice(string.length - suffix.length) == suffix;
}


var buffBar = new BuffBar($.GetContextPanel());

GameEvents.Subscribe("dota_player_update_selected_unit", function() {
    buffBar.UpdateSelectedUnit();
});
GameEvents.Subscribe("dota_player_update_query_unit", function() {
    buffBar.UpdateQueryUnit();
});

function UpdateBuffBar() {
    buffBar.Update();
    $.Schedule(1/60, UpdateBuffBar);
}

UpdateBuffBar();
