function FindCustomUIRoot(panel)
{
	var targetPanel = panel;
	while (targetPanel.id != "CustomUIRoot")
	{
		//$.Msg(targetPanel.id)
		targetPanel = targetPanel.GetParent();
	}
	return targetPanel;
}
