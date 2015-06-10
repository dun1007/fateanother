package {
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	
	
	public class Fatepedia extends MovieClip{
		
		//these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
        public function Fatepedia() {
            //we add a listener to this.button1 (I called my button 'button1')
            //this listener listens to the CLICK mouseEvent, and when it observes it, it cals onButtonClicked
            this.OpenButton.addEventListener(MouseEvent.CLICK, onButtonClicked);
        }
        
        /*this function is new, it is the handler for our listener
         *handlers for mouseEvents always need the event:MouseEvent parameter.
         *the ': void' at the end gives the type of this function, handlers are always voids. */
        private function onButtonClicked(event:MouseEvent) : void {
            trace("click!");
        }
		
		//this function is called when the UI is loaded
		public function onLoaded() : void {			
			//make this UI visible
			visible = true;
			
			//let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);
			
			//this is not needed, but it shows you your UI has loaded (needs 'scaleform_spew 1' in console)
			trace("Fatepedia UI Loaded!");
		}
		
		//this handles the resizes - credits to Nullscope
		public function onResize(re:ResizeManager) : * {
			
			var scaleRatioY:Number = re.ScreenHeight/900;
					
			if (re.ScreenHeight > 900){
				scaleRatioY = 1;
			}
                    
            //You will probably want to scale your elements by here, they keep the same width and height by default.
            //I recommend scaling both X and Y with scaleRatioY.
            
            //The engine keeps elements at the same X and Y coordinates even after resizing, you will probably want to adjust that here.
		}



	}
}