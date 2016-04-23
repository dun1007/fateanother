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

function Config1ShowTooltip()
{
    var attrText = $("#option1"); 
    $.DispatchEvent('DOTAShowTextTooltip', attrText, "If checked, any purchase that puts your gold below 200g will automatically trigger -goldpls event.");
}

function Config1HideTooltip()
{
    var attrText = $("#option1"); 
    $.DispatchEvent( 'DOTAHideTextTooltip', attrText );
}

function Config3ShowTooltip()
{
    var attrText = $("#option3"); 
    $.DispatchEvent('DOTAShowTextTooltip', attrText, "When placed on mount(e.g Caster(5th)'s Ancient Dragon, Caster(4th)'s Gigantic Horror), selecting hero automatically reselects his/her mount instead. Check this option if you want to disable reselection.");
}


function Config3HideTooltip()
{
    var attrText = $("#option3"); 
    $.DispatchEvent( 'DOTAHideTextTooltip', attrText );
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



(function()
{
    $("#FateConfigBoard").visible = false;
})();