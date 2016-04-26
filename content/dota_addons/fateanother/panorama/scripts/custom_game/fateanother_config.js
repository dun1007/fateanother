var g_GameConfig = GameUI.CustomUIConfig();

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
}


function OnConfig3Toggle()
{
    g_GameConfig.bIsConfig3On = !g_GameConfig.bIsConfig3On;
}


function OnConfig4Toggle()
{
    g_GameConfig.bIsConfig4On = !g_GameConfig.bIsConfig4On;
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

(function()
{
    $("#FateConfigBoard").visible = false;
    $("#FateConfigBGMList").SetSelected(1);
    GameEvents.Subscribe( "player_chat", PlayerChat);
})();