package {
	
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import scaleform.clik.events.*;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.data.DataProvider;
	
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	//import flashx.textLayout.formats.Float;
	
	public class Fatepedia extends MovieClip{
		//these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		public var mainPanel:MovieClip;		
		private var ButtonOriginalWidth:int;
		private var ButtonOriginalHeight:int;
		private var MainPanelOriginalWidth:int;
		private var MainPanelOriginalHeight:int;
		private var ScreenWidth:int;
		private var ScreenHeight:int;
		private var scaleRatioX:Number;
		private var scaleRatioY:Number;
		
        public function Fatepedia() {
			// Just for test purpose in flash
			this.myOpenButton.addEventListener(MouseEvent.CLICK, onFatepediaClicked);
			this.ButtonOriginalWidth = this.myOpenButton.width;
			this.ButtonOriginalHeight = this.myOpenButton.height;
			this.MainPanelOriginalWidth = 525;
			this.MainPanelOriginalHeight = 652;
        }
		
		public function onLoaded() : void {			
			visible = true;
			this.myOpenButton.addEventListener(MouseEvent.CLICK, onFatepediaClicked);
			Globals.instance.resizeManager.AddListener(this);
			trace("Fatepedia Loaded");
		}

		public function createMainPanel() {
			this.mainPanel = new FatepediaMainPanel(this.globals);
			addChild(mainPanel);
			trace("Panel sizes", ScreenWidth, ScreenHeight, mainPanel.width, mainPanel.height);
			mainPanel.width =  MainPanelOriginalWidth * scaleRatioX;
			mainPanel.height =  MainPanelOriginalHeight * scaleRatioY;
			mainPanel.x = ScreenWidth;
			mainPanel.y = (ScreenHeight - mainPanel.height/2 * scaleRatioY);
			trace("Current location...", mainPanel.x, mainPanel.y);
			
		}
		public function onFatepediaClicked(event:MouseEvent)
        {
            trace("Fatepedia button clicked");
			if (mainPanel == null) {
				createMainPanel();
				mainPanel.visible = true;
			}
			else
			{
				mainPanel.visible = false;
				removeChild(this);
				mainPanel = null;
			}	
			
            return;
        }// end function
				
		public function onResize(re:ResizeManager) : * {
			// calculate by what ratio the stage is scaling
			this.scaleRatioX = re.ScreenWidth/1920;
			this.scaleRatioY = re.ScreenHeight/1080;
			
			this.myOpenButton.width = ButtonOriginalWidth * scaleRatioX;
			this.myOpenButton.height = ButtonOriginalHeight * scaleRatioY;
			this.myOpenButton.x = re.ScreenWidth;
			this.myOpenButton.y = this.myOpenButton.height;			
			trace("Current size :" + re.ScreenWidth + " " + re.ScreenHeight)
			trace("##### RESIZE #########");
					
			ScreenWidth = re.ScreenWidth;
			ScreenHeight = re.ScreenHeight;
					
		}

	}
}