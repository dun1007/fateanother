"use strict";

var m_InventoryPanels = []

// Currently hardcoded: first 6 are inventory, next 6 are stash items
var DOTA_ITEM_STASH_MIN = 6;
var DOTA_ITEM_STASH_MAX = 12;

function UpdateInventory()
{
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	for ( var i = 0; i < DOTA_ITEM_STASH_MAX; ++i )
	{
		var inventoryPanel = m_InventoryPanels[i]
		var item = Entities.GetItemInSlot( queryUnit, i );
		inventoryPanel.data().SetItem( queryUnit, item );
	}
}

function CreateInventoryPanels()
{
	var stashPanel = $( "#stash_row" );
	var firstRowPanel = $( "#inventory_row_1" );
	var secondRowPanel = $( "#inventory_row_2" );
	if ( !stashPanel || !firstRowPanel || !secondRowPanel )
		return;

	stashPanel.RemoveAndDeleteChildren();
	firstRowPanel.RemoveAndDeleteChildren();
	secondRowPanel.RemoveAndDeleteChildren();
	m_InventoryPanels = []

	for ( var i = 0; i < DOTA_ITEM_STASH_MAX; ++i )
	{
		var parentPanel = firstRowPanel;
		if ( i >= DOTA_ITEM_STASH_MIN )
		{
			parentPanel = stashPanel;
		}
		else if ( i > 2 )
		{
			parentPanel = secondRowPanel;
		}

		var inventoryPanel = $.CreatePanel( "Panel", parentPanel, "" );
		inventoryPanel.BLoadLayout( "file://{resources}/layout/custom_game/inventory_item.xml", false, false );
		inventoryPanel.data().SetItemSlot( i );

		m_InventoryPanels.push( inventoryPanel );
	}
}

function TransferShowTooltip() {
	var checkBox = $("#toggle_transfer");
	var sText    = "If unchecked, purchased items will be placed in stash first.";
	$.DispatchEvent('DOTAShowTextTooltip', checkBox, "Purchased items will be placed in stash first if unchecked(Recommended to leave it checked for new players)");
}

function TransferHideTooltip() {
    var checkBox = $('#toggle_transfer');
    $.DispatchEvent( 'DOTAHideTextTooltip', checkBox );
}

function ChangeTransferMode() {
	var checkBox = $('#toggle_transfer');
	GameEvents.SendCustomGameEventToServer( "direct_transfer_changed", { "player" : Players.GetLocalPlayer(), "directTransfer" : checkBox.checked } );
}
(function()
{
	//$("#toggle_transfer").checked = true;
	//CreateInventoryPanels();
	//UpdateInventory();

	//GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
	//GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
	//GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
	//GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
	//GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateInventory );
	//GameEvents.Subscribe( "dota_player_update_query_unit", UpdateInventory );
})();

