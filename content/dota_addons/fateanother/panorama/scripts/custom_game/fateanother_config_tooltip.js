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
    $.DispatchEvent('DOTAShowTextTooltip', attrText, "#FA_Config_Option1_Context");
}

function Config1HideTooltip()
{
    var attrText = $("#option1"); 
    $.DispatchEvent( 'DOTAHideTextTooltip', attrText );
}

function Config3ShowTooltip()
{
    var attrText = $("#option3"); 
    $.DispatchEvent('DOTAShowTextTooltip', attrText, "#FA_Config_Option3_Context");
}


function Config3HideTooltip()
{
    var attrText = $("#option3"); 
    $.DispatchEvent( 'DOTAHideTextTooltip', attrText );
}