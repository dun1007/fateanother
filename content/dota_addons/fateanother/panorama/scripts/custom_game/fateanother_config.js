function OnFateConfigButtonPressed()
{
    var configPanel = $("#FateConfigBoard");
    if (!configPanel)
        return;
    configPanel.visible = !configPanel.visible;
}

(function()
{
    $("#FateConfigBoard").visible = false;
})();