function OnFateConfigButtonPressed()
{
    var configPanel = $("#FateConfigBoard");
    if (!configPanel)
        return;
    configPanel.visible = !configPanel.visible;
}

function OnFateConfigButtonShowTooltip()
{
    var attrText = $("#FateConfigButton");
    $.DispatchEvent('DOTAShowTextTooltip', attrText, "#FA_Config_Button");
}

function OnFateConfigButtonHideTooltip()
{
    var attrText = $("#FateConfigButton"); 
    $.DispatchEvent( 'DOTAHideTextTooltip', attrText );
}


(function()
{
    $("#FateConfigBoard").visible = false;
})();