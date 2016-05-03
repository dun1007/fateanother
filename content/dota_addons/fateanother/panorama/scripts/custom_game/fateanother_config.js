var g_GameConfig = FindCustomUIRoot($.GetContextPanel());
var transport = null;
var bIsMounted = false;

function OnFateConfigButtonPressed()
{
    var configPanel = $("#FateConfigBoard");
    if (!configPanel)
        return;
    configPanel.visible = !configPanel.visible;
}


function OnCameraDistSubmitted()
{
    var panel = $("#FateConfigCameraValue");
    var number = parseFloat(panel.text);
    if (number > 1600)
    {
        number = 1600;
    }
    GameUI.SetCameraDistance(number);
    panel.text = number.toString();
}

function OnConfig1Toggle()
{
    g_GameConfig.bIsConfig1On = !g_GameConfig.bIsConfig1On;
}

function OnConfig2Toggle()
{
    g_GameConfig.bIsConfig2On = !g_GameConfig.bIsConfig2On;
    GameEvents.SendCustomGameEventToServer("config_option_2_checked", {player: Players.GetLocalPlayer(), bOption: g_GameConfig.bIsConfig2On})
}


function OnConfig3Toggle()
{
    g_GameConfig.bIsConfig3On = !g_GameConfig.bIsConfig3On;
}


function OnConfig4Toggle()
{
    g_GameConfig.bIsConfig4On = !g_GameConfig.bIsConfig4On;
    GameEvents.SendCustomGameEventToServer("config_option_4_checked", {player: Players.GetLocalPlayer(), bOption: g_GameConfig.bIsConfig4On})
}

function PlayerChat(event)
{
    var txt = event.text;
    if (txt == "-bgmoff" && g_GameConfig.bIsBGMOn) {
        StopBGM();
        g_GameConfig.bIsBGMOn = false;
    }
    if (txt == "-bgmon" && !g_GameConfig.bIsBGMOn) {
        PlayBGM();
        g_GameConfig.bIsBGMOn = true;
    }
}

function CheckTransportSelection(data)
{
    if (g_GameConfig.bIsConfig3On) { return 0; }
    var playerID = Players.GetLocalPlayer();
    var mainSelected = Players.GetLocalPlayerPortraitUnit();
    var hero = Players.GetPlayerHeroEntityIndex( playerID )

    if (mainSelected == hero && transport && bIsMounted)
    {
        // check if transport is currently carrying Caster inside
        if (Entities.IsAlive( transport ))
        {
            GameUI.SelectUnit(transport, false);
        }
    }

}
function RegisterTransport(data)
{
    transport = data.transport;
}
function UpdateMountStatus(data)
{
    bIsMounted = data.bIsMounted;
    $.Msg(bIsMounted);
}


(function()
{
    $("#FateConfigBoard").visible = false;
    $("#FateConfigBGMList").SetSelected(1);
    GameEvents.Subscribe( "player_chat", PlayerChat);
    GameEvents.Subscribe( "dota_player_update_selected_unit", CheckTransportSelection );
    GameEvents.Subscribe( "player_summoned_transport", RegisterTransport);
    GameEvents.Subscribe( "player_mount_status_changed", UpdateMountStatus);
})();