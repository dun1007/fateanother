package {
	import flash.display.MovieClip;
	import KeyCodes;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	
	public class AbilityManager extends MovieClip{
		
		public static const MAX_ABILITIES : Number = 16;
		
		//these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		private var keyArray:Array;
		private var abilityArray:Array;
		
		private var xoffset:Number = 0;
		private var yoffset:Number = 0;
		
		private var UIBackground:MovieClip;
		
		//constructor, you usually will use onLoaded() instead
		public function AbilityManager() : void {
		}
		
		//this function is called when the UI is loaded
		public function onLoaded() : void {			
			visible = false;
			
			//let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);
			
			Globals.instance.GameInterface.SetConvar("dota_camera_lock", "1");
			
			globals.GameInterface.AddKeyInputConsumer();
			
			this.gameAPI.SubscribeToGameEvent("update_ability_bar", this.checkInit);
		}
		
		private function checkInit(args:Object) {
			var pID:int = globals.Players.GetLocalPlayer();
			if (args.pid == pID) {
				if (abilityArray == null) {
					this.setup()
				} else {
					this.abilityArray[args.ability_slot].LevelUp();
				}
			}
		}
		
		private function setup() {
			this.visible = true;
		
			this.abilityArray = new Array(MAX_ABILITIES);		// Maximum ability a unit can have
			this.keyArray = new Array(MAX_ABILITIES);
			this.setupKeys();
			
			this.LoadAssets();
			this.OrderAssets();
			this.PositionAssets();
		}
		
		private function LoadAssets() {
			this.UIBackground = this.LoadImage("images/UI/ability_bar_background.png", 894, 146);
			this.UIBackground.visible = true;
			
			var player_id = globals.Players.GetLocalPlayer();
			var hero_entindex = globals.Players.GetPlayerHeroEntityIndex(player_id);
			
			var i:int;
			var ability;
			for (i = 0; i < abilityArray.length / 2; i++) {
				ability = globals.Entities.GetAbility( hero_entindex, i );
				abilityArray[i] = new CustomAbility;
				abilityArray[i].Create(gameAPI, globals, ability, keyArray[i], false, this);
				abilityArray[i].scaleX = 0.5;
				abilityArray[i].scaleY = 0.5;
			}
			
			for (i = abilityArray.length / 2; i < abilityArray.length; i++) {
				ability = globals.Entities.GetAbility( hero_entindex, i );
				abilityArray[i] = new CustomAbility;
				abilityArray[i].Create(gameAPI, globals, ability, keyArray[i], true, this);
				this.addChild(abilityArray[i]);
				abilityArray[i].scaleX = 0.358;
				abilityArray[i].scaleY = 0.358;
			}
		}
		
		private function OrderAssets() {
			this.addChild(this.UIBackground);
			var i:int;
			for (i = 0; i < abilityArray.length; i++) {
				this.addChild(abilityArray[i]);
			}
		}
		
		private function PositionAssets() {
			this.UIBackground.x = this.xoffset;
			this.UIBackground.y = this.yoffset;
		
			var i:int;
			for (i = 0; i < abilityArray.length / 2; i++) {
				abilityArray[i].x = this.xoffset + 217 + 57 * (i % (abilityArray.length / 2));
				abilityArray[i].y = this.yoffset + 65;
			}
			
			for (i = abilityArray.length / 2; i < abilityArray.length; i++) {
				abilityArray[i].x = this.xoffset + 226 + 57 * (i % (abilityArray.length / 2));
				abilityArray[i].y = this.yoffset + 16;
			}
		}
		
		private function setupKeys() {
			keyArray[0] = Keyboard.Q;
			keyArray[1] = Keyboard.W;
			keyArray[2] = Keyboard.E;
			keyArray[3] = Keyboard.R;
			keyArray[4] = Keyboard.T;
			keyArray[5] = Keyboard.Y;
			keyArray[6] = Keyboard.U;
			keyArray[7] = Keyboard.I;
			keyArray[8] = Keyboard.NUMBER_1;
			keyArray[9] = Keyboard.NUMBER_2;
			keyArray[10] = Keyboard.NUMBER_3;
			keyArray[11] = Keyboard.NUMBER_4;
			keyArray[12] = Keyboard.NUMBER_5;
			keyArray[13] = Keyboard.NUMBER_6;
			keyArray[14] = Keyboard.NUMBER_7;
			keyArray[15] = Keyboard.NUMBER_8;
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
		
		private function LoadImage(image_path:String, width:Number, height:Number):MovieClip {
			var image_to_return = new MovieClip();
			
			image_to_return["originalWidth"] = width;
			image_to_return["originalHeight"] = height;
			
			globals.LoadImage(image_path, image_to_return, true);
			
			image_to_return.visible = false;
			
			return image_to_return;
		}
	}
}