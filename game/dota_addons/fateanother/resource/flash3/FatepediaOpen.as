package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import scaleform.clik.events.*;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.data.DataProvider;
	
	import ValveLib.*;
	import flash.text.TextFormat;
	
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;	
	
	public class FatepediaOpen extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		var mainPanel:Object;

		var SpellPanelActive:Boolean;
		
		public function FatepediaOpen() { 
			this.addEventListener(MouseEvent.CLICK, onFatepediaClicked); 
		}
		
		public function setup(api:Object, globals:Object, panel:Object)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
			this.mainPanel = panel;
			//this.addEventListener(MouseEvent.CLICK, onFatepediaClicked);
			//this.visible = false;
			
			// Game Event Listening
			this.addEventListener(MouseEvent.CLICK, onFatepediaClicked); 
			this.gameAPI.SubscribeToGameEvent("show_fatepedia_main_panel", this.showFatepediaMainPanel);
			trace("FatepediaOpen setup complete");
		}
		
		public function showFatepediaMainPanel(args:Object) : void {			
			
			// Show for this player
			var pID:int = globals.Players.GetLocalPlayer();
			if (args.player_ID == pID) {
				this.visible = true;
				trace("Fatepedia now visible for "+args.player_ID);
			}
		}
		
		public function onFatepediaClicked(event:MouseEvent)
        {
            trace("Spell List Toggle");
			if (this.mainPanel.visible == false)
			{
				this.mainPanel.visible = true;
				trace("Spell Panel Visible");
			}
			else
			{
				this.mainPanel.visible = false;
				trace("Spell Panel Hidden");
			}			
			
            return;
        }// end function
		
		public function screenResize(stageW:int, stageH:int, xScale:Number, yScale:Number, wide:Boolean){
			
			trace("Stage Size: ",stageW,stageH);
						
			this.x = stageW/2 + 378*yScale;
			this.y = stageH/2 + 335*yScale;
			
			this.width = this.width*yScale;
			this.height	 = this.height*yScale;
			
			trace("#Result Resize: ",this.x,this.y,yScale);
					 
			//Now we just set the scale of this element, because these parameters are already the inverse ratios
			this.scaleX = xScale;
			this.scaleY = yScale;
			
			trace("#Highscore Panel  Resize");
		}
	}
	
}
