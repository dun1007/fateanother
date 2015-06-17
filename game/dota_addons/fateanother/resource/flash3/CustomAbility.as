// ===================================================================
// This class is formatted into 128x128 including the effects
// The image in center is sized at 102x102 including hover and empty icon
// For assigned key to work, you need to put globals.GameInterface.AddKeyInputConsumer();
// in somewhere in order to activate properly
// ===================================================================
package  {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import fl.motion.AdjustColor;
	
	public class CustomAbility extends MovieClip {
		
		// ===================================================================
		// Constant variables section
		// ===================================================================
		public static const ABILITY_TYPE_POINT:Number = 0;
		public static const ABILITY_TYPE_NO_TARGET:Number = 1;
		public static const ABILITY_TYPE_PASSIVE:Number = 2;
		
		public static const ABILITY_STATE_NORMAL:Number = 0;
		public static const ABILITY_STATE_NOT_LEARNT:Number = 1;
		public static const ABILITY_STATE_OUT_OF_MANA:Number = 2;
		public static const ABILITY_STATE_DISABLE:Number = 3;
		public static const ABILITY_STATE_COOLDOWN:Number = 4;
		
		public static const MOUSE_CLICK:Number = 0;
		public static const KEY_CLICK:Number = 1;
		
		public static const COOLDOWN_FONT_SIZE:Number = 32;
		public static const MANA_FONT_SIZE:Number = 24;
		public static const HOTKEY_FONT_SIZE:Number = 24;
		
		public static const DOTA_ABILITY_BEHAVIOR_PASSIVE:Number = 2;
		public static const DOTA_ABILITY_BEHAVIOR_NO_TARGET:Number = 4;
		public static const DOTA_ABILITY_BEHAVIOR_UNIT_TARGET:Number = 8;		// This is currently not supported
		public static const DOTA_ABILITY_BEHAVIOR_POINT:Number = 16;
		
		// ===================================================================
		// Global variables section
		// ===================================================================
		private var gameAPI:Object;
		private var globals:Object;
		
		private var mSuperStage:MovieClip;
		
		private var fCurrentCooldown:Number;
		private var nAbilityEntIndex:Number;
		private var nAbilityType:Number;
		private var nAssignedKey:Number;
		private var bIsCircle:Boolean;
		
		private var bIsFilterActive:Boolean = false;
		private var aBlackWhiteFilter:Array;
		
		private var outerShadowFilter:DropShadowFilter = new DropShadowFilter(
			0.0			// distance:Number
			/*
			 * These are default values
			45,			// angle:Number
			0x000000,	// color:unit
			1.0,		// alpha:Number
			4.0,		// blurX:Number
			4.0,		// blurY:Number
			1.0,		// strength:Number
			1,			// quality:int
			false,		// inner:Boolean
			false,		// knockout:Boolean
			false		// hideObject:Boolean
			*/
		);
		
		private var cooldownTimer:Timer;
		private var manaDetectionTimer:Timer;
		
		// ===================================================================
		// Graphics variables section
		// ===================================================================
		
		// Ability section
		private var abilityTexture:MovieClip;
		private var emptyTexture:MovieClip;
		private var hoverTexture:MovieClip;
		private var activeAbilityBorder:MovieClip;
		private var usingAbilityBorder:MovieClip;
		private var cooldownAbilityBorder:MovieClip;
		private var passiveAbilityBorder:MovieClip;
		private var disableTexture:MovieClip;
		private var mouseDetectionArea:MovieClip;
		
		// Mana section
		private var manaTextFormat:TextFormat;
		private var manaOverlay:Sprite;
		private var manaBackgroundTexture:MovieClip;
		private var manaLabel:TextField;
		
		// Hotkey section
		private var hotkeyTextFormat:TextFormat;
		private var hotkeyBackgroundTexture:MovieClip;
		private var hotkeyLabel:TextField;
		
		// Cooldown section
		private var cooldownTextFormat:TextFormat;
		private var cooldownMasker:Sprite;
		private var cooldownTexture:Sprite;
		private var cooldownLabel:TextField;
		
		// ===================================================================
		// Constructors
		// ===================================================================
		public function CustomAbility() { }
		public function Create(api:Object, globals:Object, entindex:Number, assigned_key:Number, is_circle:Boolean, controller_stage:MovieClip) {
			this.gameAPI = api;
			this.globals = globals;
			this.fCurrentCooldown = 0.0;
			this.nAbilityEntIndex = entindex;
			this.nAssignedKey = assigned_key;
			this.bIsCircle = is_circle;
			this.mSuperStage = controller_stage;
			
			this.SetAbilityType();
			this.CreateTextFormat();
			this.CreateFilters();
			this.LoadAssets();
			this.OrderAssets();
			this.PositionAssets();
			this.SetAssetsVisibility();
			
			this.mouseDetectionArea.addEventListener(MouseEvent.CLICK, OnMouseClick);
			this.mouseDetectionArea.addEventListener(MouseEvent.ROLL_OVER, OnMouseRollOver);
			this.mouseDetectionArea.addEventListener(MouseEvent.ROLL_OUT, OnMouseRollOut);
			this.mSuperStage.stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyClick);
			
			this.Start();
		}
		
		private function SetAbilityType() {
			var behavior = globals.Abilities.GetBehavior(this.nAbilityEntIndex);
			
			if (behavior != null) {
				if (behavior & (CustomAbility.DOTA_ABILITY_BEHAVIOR_PASSIVE)) {
					this.nAbilityType = CustomAbility.ABILITY_TYPE_PASSIVE;
				} else if (behavior & (CustomAbility.DOTA_ABILITY_BEHAVIOR_NO_TARGET)) {
					this.nAbilityType = CustomAbility.ABILITY_TYPE_NO_TARGET;
				} else if (behavior & (CustomAbility.DOTA_ABILITY_BEHAVIOR_POINT)) {
					this.nAbilityType = CustomAbility.ABILITY_TYPE_POINT;
				} else {
					this.nAbilityType = CustomAbility.ABILITY_TYPE_PASSIVE;
				}
			}
		}
		
		private function CreateTextFormat() {
			this.cooldownTextFormat = new TextFormat();
			this.cooldownTextFormat.font = "$TextFont";
			this.cooldownTextFormat.color = 0xFFFFFF;
			this.cooldownTextFormat.size = CustomAbility.COOLDOWN_FONT_SIZE;
			this.cooldownTextFormat.align = TextFormatAlign.CENTER;
			
			this.manaTextFormat = new TextFormat();
			this.manaTextFormat.font = "$TextFont";
			this.manaTextFormat.color = 0xFFFFFF;
			this.manaTextFormat.size = CustomAbility.MANA_FONT_SIZE;
			this.manaTextFormat.align = TextFormatAlign.RIGHT;
			
			this.hotkeyTextFormat = new TextFormat();
			this.hotkeyTextFormat.font = "$TextFont";
			this.hotkeyTextFormat.color = 0xFFFFFF;
			this.hotkeyTextFormat.size = CustomAbility.HOTKEY_FONT_SIZE;
			this.hotkeyTextFormat.align = TextFormatAlign.CENTER;
		}
		
		private function LoadAssets() {
			var ability_name = globals.Abilities.GetAbilityName(this.nAbilityEntIndex);
			this.abilityTexture = this.LoadImage("images/spellicons/" + ability_name + ".png", 102, 102);
			this.emptyTexture = this.LoadImage("images/spellicons/iconeffect/icon_empty_128px.png", 102, 102);
			
			if (this.bIsCircle == true) {
				var abilityMask:Shape = new Shape();
				abilityMask.graphics.beginFill(0x000000);
				abilityMask.graphics.drawCircle(51 + 13, 51 + 13, 51);
				abilityMask.graphics.endFill();
				this.abilityTexture.mask = abilityMask;
				this.addChild(abilityMask);
				
				var emptyMask:Shape = new Shape();
				emptyMask.graphics.beginFill(0x000000);
				emptyMask.graphics.drawCircle(51 + 13, 51 + 13, 51);
				emptyMask.graphics.endFill();
				this.emptyTexture.mask = emptyMask;
				this.addChild(emptyMask);
			}
			
			this.hoverTexture = this.LoadImage("images/spellicons/iconeffect/icon_hover_128px.png", 102, 102);
			this.hoverTexture.alpha = 0.5;
			this.activeAbilityBorder = this.LoadImage("images/spellicons/iconeffect/icon_normal_128px.png", 128, 128);
			this.usingAbilityBorder = this.LoadImage("images/spellicons/iconeffect/icon_using_128px.png", 128, 128);
			this.cooldownAbilityBorder = this.LoadImage("images/spellicons/iconeffect/icon_cooldown_border_128px.png", 128, 128);
			this.passiveAbilityBorder = this.LoadImage("images/spellicons/iconeffect/icon_passive_border_128px.png", 128, 128);
			this.disableTexture = new MovieClip();		// TODO: Add texture
			
			this.mouseDetectionArea = new MovieClip();
			this.mouseDetectionArea.graphics.beginFill(0xFFFFFF);
			this.mouseDetectionArea.graphics.drawRect(0, 0, 102, 102);
			this.mouseDetectionArea.graphics.endFill();
			this.mouseDetectionArea.alpha = 0;
			
			this.manaBackgroundTexture = this.LoadImage("images/spellicons/iconeffect/mana_background_102px.png", 102, 102);
			this.manaLabel = this.CreateLabel(102, CustomAbility.MANA_FONT_SIZE, this.manaTextFormat, "" + globals.Abilities.GetManaCost(this.nAbilityEntIndex));
			
			this.manaOverlay = new Sprite();
			this.manaOverlay.graphics.beginFill(0x000089);
			if (this.bIsCircle == false) {
				this.manaOverlay.graphics.drawRect(0, 0, 102, 102);
			} else {
				this.manaOverlay.graphics.drawCircle(51, 51, 51);
			}
			this.manaOverlay.graphics.endFill();
			this.manaOverlay.alpha = 0.5;
			this.manaOverlay.visible = false;
			
			this.cooldownTexture = new Sprite();
			this.cooldownTexture.graphics.beginFill(0x000000);
			if (this.bIsCircle == false) {
				this.cooldownTexture.graphics.drawRect(0, 0, 102, 102);
			} else {
				this.manaOverlay.graphics.drawCircle(51, 51, 51);
			}
			this.cooldownTexture.graphics.endFill();
			this.cooldownTexture.alpha = 0.5;
			this.cooldownTexture.visible = false;
			
			if (globals.Abilities.GetCooldown(this.nAbilityEntIndex) > 0) {
				this.cooldownLabel = this.CreateLabel(102, CustomAbility.COOLDOWN_FONT_SIZE, this.cooldownTextFormat);
			} else {
				this.cooldownLabel = new TextField();
			}
			
			this.hotkeyBackgroundTexture = this.LoadImage("images/spellicons/iconeffect/icon_empty_128px.png", 32, 32);
			this.hotkeyLabel = this.CreateLabel(102, CustomAbility.HOTKEY_FONT_SIZE, this.hotkeyTextFormat, "" + String.fromCharCode(this.nAssignedKey));
		}
		
		private function OrderAssets() {
			this.addChild(this.emptyTexture);
			this.addChild(this.abilityTexture);
			this.addChild(this.manaOverlay);
			this.addChild(this.manaBackgroundTexture);
			this.addChild(this.manaLabel);
			this.addChild(this.passiveAbilityBorder);
			this.addChild(this.cooldownAbilityBorder);
			this.addChild(this.cooldownTexture);
			this.addChild(this.cooldownLabel);
			this.addChild(this.activeAbilityBorder);
			this.addChild(this.usingAbilityBorder);
			this.addChild(this.hoverTexture);
			this.addChild(this.disableTexture);
			this.addChild(this.hotkeyBackgroundTexture);
			this.addChild(this.hotkeyLabel);
			this.addChild(this.mouseDetectionArea);
		}
		
		private function PositionAssets() {
			this.abilityTexture.x = 13;
			this.abilityTexture.y = 13;
			
			this.emptyTexture.x = 13;
			this.emptyTexture.y = 13;
			
			this.hoverTexture.x = 13;
			this.hoverTexture.y = 13;
			
			this.disableTexture.x = 13;
			this.disableTexture.y = 13;
			
			this.passiveAbilityBorder.x = 0;
			this.passiveAbilityBorder.y = 0;
			
			this.activeAbilityBorder.x = 0;
			this.activeAbilityBorder.y = 0;
			
			this.cooldownAbilityBorder.x = 0;
			this.cooldownAbilityBorder.y = 0;
			
			this.cooldownLabel.x = 13;
			this.cooldownLabel.y = 64 - CustomAbility.COOLDOWN_FONT_SIZE / 2;
			
			this.cooldownTexture.x = 13;
			this.cooldownTexture.y = 13;
			
			this.usingAbilityBorder.x = 0;
			this.usingAbilityBorder.y = 0;
			
			this.manaBackgroundTexture.x = 13;
			this.manaBackgroundTexture.y = 13;
				
			this.manaLabel.x = 8;
			this.manaLabel.y = 19;
			
			this.manaOverlay.x = 13;
			this.manaOverlay.y = 13;
			
			this.mouseDetectionArea.x = 13;
			this.mouseDetectionArea.y = 13;
			
			this.hotkeyBackgroundTexture.x = 51 + 13 - 17;
			this.hotkeyBackgroundTexture.y = 102 + 18 - 17;
			
			this.hotkeyLabel.x = 13 - 2;
			this.hotkeyLabel.y = 102 + 15 - CustomAbility.HOTKEY_FONT_SIZE / 2;			
		}
		
		private function SetAssetsVisibility() {
			this.abilityTexture.visible = true;
			this.emptyTexture.visible = true;
			this.mouseDetectionArea.visible = true;
			
			this.disableTexture.visible = false;
			this.manaOverlay.visible = false;
			
			if (this.bIsCircle == false) {
				if (globals.Abilities.GetManaCost(this.nAbilityEntIndex) > 0) {
					this.manaBackgroundTexture.visible = true;
					this.manaLabel.visible = true;
				} else {
					this.manaBackgroundTexture.visible = false;
					this.manaLabel.visible = false;
				}
				
				this.cooldownAbilityBorder.visible = false;
			
				switch(nAbilityType) {
				case CustomAbility.ABILITY_TYPE_POINT:
				case CustomAbility.ABILITY_TYPE_NO_TARGET:
					this.activeAbilityBorder.visible = true;
					break;
				case CustomAbility.ABILITY_TYPE_PASSIVE:
					this.passiveAbilityBorder.visible = true;
					break;
				default:
					break;
				}
			}
		}
		
		private function LoadImage(image_path:String, width:Number, height:Number):MovieClip {
			var image_to_return = new MovieClip();
			
			image_to_return["originalWidth"] = width;
			image_to_return["originalHeight"] = height;
			
			globals.LoadImage(image_path, image_to_return, true);
			
			image_to_return.visible = false;
			
			return image_to_return;
		}
		
		private function CreateLabel(width:Number, height:Number, format:TextFormat, text:String = ""):TextField {
			var tf:TextField = new TextField();
			tf.selectable = false;
			
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
			tf.text = text;
			tf.setTextFormat(format);
			tf.defaultTextFormat = format;
			
			tf.width = width;
			tf.height = height + 10;
			
			tf.filters = [outerShadowFilter];
			
			tf.visible = false;
			
			return tf;
		}
		
		// ===================================================================
		// Stages visual handling
		// ===================================================================
		
		private function CreateFilters() {
			// Create Black and white filter
			var color : AdjustColor;
			var colorMatrix : ColorMatrixFilter;
			var matrix : Array;
			
			color = new AdjustColor();
			color.brightness = 20;
			color.contrast = 20;
			color.hue = 0;
			color.saturation = -100;
			 
			matrix = color.CalculateFinalFlatArray();
			colorMatrix = new ColorMatrixFilter(matrix);
			this.aBlackWhiteFilter = [colorMatrix];
		}
		public function Start() {
			this.SwitchToState(CustomAbility.ABILITY_STATE_NOT_LEARNT);
		}
		public function LevelUp() {
			this.SwitchToState(CustomAbility.ABILITY_STATE_NORMAL);
			this.SetMana(globals.Abilities.GetManaCost(this.nAbilityEntIndex));
			this.StartManaTimer();
			this.StartCooldownTimer();
		}
		public function OutOfMana() {
			this.SwitchToState(CustomAbility.ABILITY_STATE_OUT_OF_MANA);
		}
		public function EnoughMana() {
			this.SwitchToState(CustomAbility.ABILITY_STATE_NORMAL);
		}
		public function Disable() {
			this.SwitchToState(CustomAbility.ABILITY_STATE_DISABLE);
		}
		public function SwitchToState(ability_state:Number):Boolean {
			this.SetAssetsVisibility();
			switch(ability_state) {
			case CustomAbility.ABILITY_STATE_NORMAL:
				this.abilityTexture.filters = [];
				if (this.bIsCircle == false) {
					this.cooldownAbilityBorder.visible = false;
					this.hotkeyBackgroundTexture.visible = true;
					this.hotkeyLabel.visible = true;
				}
				break;
			case CustomAbility.ABILITY_STATE_NOT_LEARNT:
				this.abilityTexture.filters = this.aBlackWhiteFilter;
				if (this.bIsCircle == false) {
					this.passiveAbilityBorder.visible = false;
					this.activeAbilityBorder.visible = false;
					this.cooldownAbilityBorder.visible = false;
					this.hotkeyBackgroundTexture.visible = false;
					this.hotkeyLabel.visible = false;
				}
				break;
			case CustomAbility.ABILITY_STATE_OUT_OF_MANA:
				this.abilityTexture.filters = this.aBlackWhiteFilter;
				this.manaOverlay.visible = true;
				break;
			case CustomAbility.ABILITY_STATE_DISABLE:
				// TODO
				break;
			case CustomAbility.ABILITY_STATE_COOLDOWN:
				if (this.bIsCircle == false) {
					this.cooldownAbilityBorder.visible = true;
				}
				break;
			default:
				return false;
			}
			return true;
		}
		
		// ===================================================================
		// Listeners
		// ===================================================================
		
		private function OnMouseClick(event:MouseEvent) {
			this.Activate(CustomAbility.MOUSE_CLICK);
		}
		
		private function OnKeyClick(event:KeyboardEvent) {
			if (event.keyCode == this.nAssignedKey) {
				this.Activate(CustomAbility.KEY_CLICK);
			}
		}
		
		private function OnMouseRollOver(event:MouseEvent) {
			this.ShowTooltip();
			if (this.bIsCircle == false) {
				this.hoverTexture.visible = true;
			}
		}
		
		private function OnMouseRollOut(event:MouseEvent) {
			this.HideTooltip();
			this.hoverTexture.visible = false;
		}
		
		// ===================================================================
		// Spell Activations
		// ===================================================================
		
		// This function will activate spell immediately based on mouse position,
		// For dota-like implementation, create another spell usage phase before
		// activate this.
		public function Activate(activate_type:Number):Boolean {
			// Show green border for 0.5 second
			// This will execute regardless of it able to execute or not (mana-wise)
			if (globals.Abilities.GetLevel(this.nAbilityEntIndex) > 0 && this.nAbilityType != CustomAbility.ABILITY_TYPE_PASSIVE) {
				this.ShowUsingBorder();
				var usingTimer:Timer = new Timer(500, 1);
				usingTimer.addEventListener(TimerEvent.TIMER, HideUsingBorder);
				usingTimer.start();
			
				if (globals.Abilities.IsCooldownReady(this.nAbilityEntIndex) && globals.Abilities.IsOwnersManaEnough(this.nAbilityEntIndex)
						&& this.nAbilityType != ABILITY_TYPE_PASSIVE) {
					if (activate_type == CustomAbility.KEY_CLICK) {
						var mouse_position = this.GetWorldPosition();
						trace( this.mouseX );
						trace( this.mouseY );
						this.gameAPI.SendServerCommand("execute_ability "
							+ globals.Abilities.GetAbilityName(this.nAbilityEntIndex) + " " + this.nAbilityType + " " + Math.floor( mouse_position[0] )
							+ " " + Math.floor( mouse_position[1] ) + " " + Math.floor( mouse_position[2] ) );
						this.SwitchToState(CustomAbility.ABILITY_STATE_COOLDOWN);
						return true;
					} else if (activate_type == CustomAbility.MOUSE_CLICK) {
						this.gameAPI.SendServerCommand("execute_ability " + globals.Abilities.GetAbilityName(this.nAbilityEntIndex) + " " + this.nAbilityType);
						this.SwitchToState(CustomAbility.ABILITY_STATE_COOLDOWN);
						return true;
					}
				}
			}
			
			return false;
		}
		
		private function ShowUsingBorder() {
			if (globals.Abilities.IsCooldownReady(this.nAbilityEntIndex) && this.bIsCircle == false) {
				this.usingAbilityBorder.visible = true;
			}
		}
		
		private function HideUsingBorder(event:TimerEvent) {
			this.usingAbilityBorder.visible = false;
			this.hoverTexture.visible = false;
		}
		
		// ===================================================================
		// Tooltips
		// Note: current design will always show the tooltip on the right
		// ===================================================================
		
		public function ShowTooltip() {
			globals.Loader_rad_mode_panel.gameAPI.OnShowAbilityTooltip((this.x + (this.abilityTexture.x + this.abilityTexture.width) * this.scaleX) * this.mSuperStage.scaleX
				, (this.y + this.abilityTexture.y * this.scaleY) * this.mSuperStage.scaleY
				, globals.Abilities.GetAbilityName(this.nAbilityEntIndex));
		}
		
		public function HideTooltip() {
			globals.Loader_rad_mode_panel.gameAPI.OnHideAbilityTooltip();
		}
		
		// ===================================================================
		// Mana
		// ===================================================================
		
		private function StartManaTimer() {
			this.manaDetectionTimer = new Timer(100);
			this.manaDetectionTimer.addEventListener(TimerEvent.TIMER, updateColor);
			this.manaDetectionTimer.start();
		}
		
		private function updateColor(event:TimerEvent) {
			if (!globals.Abilities.IsOwnersManaEnough(this.nAbilityEntIndex)) {
				this.SwitchToState(ABILITY_STATE_OUT_OF_MANA);
			} else {
				this.SwitchToState(ABILITY_STATE_NORMAL);
			}
		}
		
		public function GetMana():Number {
			return Number(this.manaLabel.text);
		}
		
		public function SetMana(new_mana:Number) {
			if (this.manaLabel != null) {
				this.manaLabel.setTextFormat(this.manaTextFormat);
				this.manaLabel.defaultTextFormat = this.manaTextFormat;
				this.manaLabel.text = "" + new_mana;
				this.manaLabel.setTextFormat(this.manaTextFormat);
				this.manaLabel.defaultTextFormat = this.manaTextFormat;
				
				this.manaLabel.filters = [outerShadowFilter];
			}
		}
		
		// ===================================================================
		// Cooldown
		// This section only handles graphics, see Activate() for command handling
		// ===================================================================
		
		private function StartCooldownTimer() {
			if (this.cooldownTimer == null) this.cooldownTimer = new Timer(100);
			this.cooldownTimer.addEventListener(TimerEvent.TIMER, updateCooldown);
			this.cooldownTimer.start();
		}
		private function updateCooldown(event:TimerEvent) {
			if (this.GetCurrentCooldown() > 0) {
				if (this.cooldownMasker != null) {
					this.cooldownTexture.mask = null;
					this.removeChild(this.cooldownMasker);
					this.cooldownMasker = null;
				}
				
				this.cooldownMasker = new Sprite();
				this.addChild(this.cooldownMasker)
				this.cooldownTexture.mask = this.cooldownMasker;
				this.cooldownMasker.x = this.cooldownTexture.x + this.cooldownTexture.width / 4 - this.cooldownTexture.width / 16;
				this.cooldownMasker.y = this.cooldownTexture.y + this.cooldownTexture.height / 4 - this.cooldownTexture.height / 16;
				
				this.cooldownMasker.graphics.beginFill(0);
				this.drawCooldownMask(this.cooldownMasker.graphics, this.GetCurrentCooldown() / this.GetAbilityCooldown(), 80
					, this.cooldownMasker.x, this.cooldownMasker.y, (-(Math.PI) / 2), 8);
				this.cooldownMasker.graphics.endFill();
				
				this.cooldownLabel.setTextFormat(this.cooldownTextFormat);
				this.cooldownLabel.defaultTextFormat = this.cooldownTextFormat;
				this.cooldownLabel.text = "" + Math.floor(this.GetCurrentCooldown() + 1);
				this.cooldownLabel.setTextFormat(this.cooldownTextFormat);
				this.cooldownLabel.defaultTextFormat = this.cooldownTextFormat;
				
				this.cooldownLabel.filters = [outerShadowFilter];
				
				this.cooldownLabel.visible = true;
				this.cooldownTexture.visible = true;
			} else {
				this.StopCooldownListening();
			}
		}
		private function StopCooldownListening() {
			if (this.cooldownMasker != null) {
				this.cooldownTexture.mask = null;
				this.removeChild(this.cooldownMasker);
				this.cooldownMasker = null;
				
				this.cooldownTexture.visible = false;
				this.cooldownLabel.visible = false;
			}
		}
		private function drawCooldownMask(graphics:Graphics, percent:Number, radius:Number, x:Number, y:Number, rotation:Number, sides:int) {
			graphics.moveTo(x,y);
			if (sides < 3) sides = 3;
			
			radius /= Math.cos(1/sides * Math.PI);
			var lineToRadians:Function = function(rads:Number):void {
				graphics.lineTo(Math.cos(rads) * radius + x, Math.sin(rads) * radius + y);
			};
			var sidesToDraw:int = Math.floor(percent * sides);
			for (var i:int = 0; i <= sidesToDraw; i++) {
				lineToRadians((i / sides) * (Math.PI * 2) + rotation);
			}
			if (percent * sides != sidesToDraw) {
				lineToRadians(percent * (Math.PI * 2) + rotation);
			}
		}
		public function GetAbilityCooldown():Number {
			return globals.Abilities.GetCooldown(this.nAbilityEntIndex);
		}
		public function GetCurrentCooldown():Number {
			return globals.Abilities.GetCooldownTimeRemaining(this.nAbilityEntIndex);
		}
		
		// ===================================================================
		// Hotkey
		// ===================================================================
		
		public function GetHotKey():Number {
			return this.nAssignedKey;
		}
		
		public function SetHotKey(new_hotkey:Number) {
			this.nAssignedKey = new_hotkey;
		}
		
		// ===================================================================
		// Visibility setter
		// ===================================================================
		
		public function SetManaVisible(is_visible:Boolean) {
			this.manaBackgroundTexture.visible = is_visible;
			this.manaLabel.visible = is_visible;
		}
		
		public function SetHotKeyVisible(is_visible:Boolean) {
			this.hotkeyBackgroundTexture.visible = is_visible;
			this.hotkeyLabel.visible = is_visible;
		}
		
		// ===================================================================
		// Misc
		// ===================================================================
		
		// Get mouse position that is translated into the world
		// @return array with 3 elements [0] = x, [1] = y, [2] = z
		private function GetWorldPosition():Array {
			return globals.Game.ScreenXYToWorld((this.x + (this.mouseX * this.scaleX)) * this.mSuperStage.scaleX, (this.y + (this.mouseY * this.scaleY)) * this.mSuperStage.scaleY);
		}
	}
}