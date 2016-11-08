var g_GameConfig = FindCustomUIRoot($.GetContextPanel());

function OnRepeatToggle()
{
    g_GameConfig.bRepeat = !g_GameConfig.bRepeat;
}

function OnDropDownChanged()
{
    if (g_GameConfig.bIsAutoChange) {
        return
    }

    var selection = $("#FateConfigBGMList").GetSelected();
    g_GameConfig.nextBGMIndex = parseInt(selection.id);
    //$.Msg("Next BGM Index: " + selection.id);
    if (g_GameConfig.BGMSchedule != 0) {
        $.CancelScheduled(g_GameConfig.BGMSchedule, {});
    }
    PlayBGM();
}

function PlayBGM()
{
    if (g_GameConfig.curBGMentindex != 0) {
        Game.StopSound(g_GameConfig.curBGMentindex);
    }
    g_GameConfig.curBGMIndex = g_GameConfig.nextBGMIndex;

    var BGMname = "BGM." + g_GameConfig.curBGMIndex.toString();
    var BGMduration = g_GameConfig.duration[g_GameConfig.curBGMIndex-1]+2;
    var dropPanel = $("#FateConfigBGMList");
    $.Msg("Playing " + BGMname + " for " + BGMduration.toString() + " seconds");

    // Set a flag so that OnDropDownChange() does not run due to SetSelected()
    g_GameConfig.bIsAutoChange = true;
    $.Schedule(0.033, function(){g_GameConfig.bIsAutoChange = false;})

    if (dropPanel) {dropPanel.SetSelected(g_GameConfig.nextBGMIndex)};
    g_GameConfig.curBGMentindex = Game.EmitSound(BGMname);

    g_GameConfig.BGMSchedule = $.Schedule(BGMduration, function(){
        if (!g_GameConfig.bRepeat) {
            g_GameConfig.nextBGMIndex = Math.floor((Math.random() * 8) + 1);
        }
        PlayBGM();
    });
}

function StopBGM()
{
    if (g_GameConfig.curBGMentindex != 0) {
        Game.StopSound(g_GameConfig.curBGMentindex);
    }
    if (g_GameConfig.BGMSchedule != 0) {
        $.CancelScheduled(g_GameConfig.BGMSchedule, {});
    }
}
