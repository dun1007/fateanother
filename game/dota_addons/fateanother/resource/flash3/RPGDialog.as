package  
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.controls.Button;
	import scaleform.clik.events.ButtonEvent;
	import ValveLib.Globals;
	import com.greensock.TimelineLite;
	import ValveLib.ResizeManager;
	import scaleform.gfx.InteractiveObjectEx;
	import scaleform.clik.managers.FocusHandler;
	
	/**
	 * ...
	 * @author XavierCHN 2015/3/31 21:18
	 */
	public class RPGDialog extends MovieClip 
	{
		
		public var dialogRoot:MovieClip;
		private var _npcPortrait:MovieClip;
		private var _npcNameLabel:TextField;
		private var _dialogString:TextField;
		private var _buttonContinue:Button;
		private var _buttonEnd:Button;
		
		public var globals:Object;
		public var gameAPI:Object;
		public var elementName:String = "XavierCHN's RPGDialog";
		
		private var playerID:Number = -1;
		private var _bStillHasDialog:Boolean;
		private var _bShowingDialog:Boolean;
		private var _dialogStrings:Array = new Array();
		private var _npcName:String;
		private var _dialogID:Number;
		private var _allowEndDialogAnySentence:String;
		private var _dialogSentencesCount:Number;
		private var _currentShowingSentenceIndex:Number;
		private var _originalActionPanelY:Number;
		private var _originalInventoryY:Number;
		
		public function RPGDialog()
		{
			this.addFrameScript(0, this.frame1);
		}
		
		public function onLoaded() {
			Globals.instance.resizeManager.AddListener(this);
			gameAPI.SubscribeToGameEvent("xgui_show_rpg_dialog", onOrderShowRPGDialog);
			this.visible = false;
			this.gameAPI.OnReady();
		}
		
		public function onOrderShowRPGDialog(args:Object):void 
		{
			if (this.playerID == -1) { this.playerID = globals.Players.GetLocalPlayer(); }
			if (this.playerID != args.playerID && args.playerID != -1) {
				return;
			}
			_dialogID = args.dialogID as Number;
			_dialogStrings = (args.dialogContent as String).split("|");
			_npcName = args.npcName as String;
			_allowEndDialogAnySentence = args.allowEndDialogAnySentence;
			_currentShowingSentenceIndex = 0;
			_dialogSentencesCount = _dialogStrings.length;
			this.replaceNPCPortrait();
			this.showRPGDialog();
		}
		
		public function replaceNPCPortrait():void 
		{
			Globals.instance.LoadImageWithCallback("images/rpg/npc_portraits/" + this._npcName + ".png", this._npcPortrait, true, this.onNPCPortraitLoadFinished);
			InteractiveObjectEx.setHitTestDisable(this._npcPortrait, true);
		}
		
		public function onNPCPortraitLoadFinished():void 
		{
			trace("npc portrait load finished!");
		}
		
		public function showRPGDialog():void 
		{
			var __dialogString:String = _dialogStrings[_currentShowingSentenceIndex];
			_currentShowingSentenceIndex = _currentShowingSentenceIndex + 1;
			this._npcNameLabel.text = "#" + this._npcName;
			this._dialogString.text = __dialogString;
			this.visible = true;
			this.dialogRoot.visible = true;
			if (this.bStillHasDialog) {
				this._buttonContinue.visible = true;
				if (_allowEndDialogAnySentence != "yes") {
					this._buttonEnd.visible = false;
				}else {
					this._buttonEnd.visible = true;
				}
				FocusHandler.getInstance().setFocus(this._buttonContinue);
			}else {
				this._buttonContinue.visible = false;
				this._buttonEnd.visible = true;
				FocusHandler.getInstance().setFocus(this._buttonEnd);
			}
		}
		
		public function onResize(re:ResizeManager) {
			var screenWidth = re.ScreenWidth;
			var screenHeight = re.ScreenHeight;
			this.dialogRoot.y = screenHeight;
			this.dialogRoot.scaleX = 1920 / screenWidth;
			this.dialogRoot.scaleY = this.dialogRoot.scaleX;
		}
		
		public function frame1():void 
		{
			this._npcPortrait = this.dialogRoot.npcPortrait;
			this._npcNameLabel = this.dialogRoot.npcNameLabel;
			this._dialogString = this.dialogRoot.dialogString;
			this._buttonContinue = this.dialogRoot.buttonContinue;
			this._buttonEnd = this.dialogRoot.buttonEnd;
			
			this._buttonEnd.addEventListener(ButtonEvent.CLICK, this.buttonEndCLicked);
			this._buttonContinue.addEventListener(ButtonEvent.CLICK, this.buttonContinueClicked);
			
			this.visible = false;
		}
		
		private function buttonContinueClicked(e:ButtonEvent):void 
		{
			if (this.bStillHasDialog) {
				this.showRPGDialog();
			}
		}
		
		private function buttonEndCLicked(e:ButtonEvent):void 
		{
			this.visible = false;
			gameAPI.SendServerCommand("xgui_player_end_rpg_dialog" + this._dialogID + " " + this.playerID);
		}
		
		public function get bStillHasDialog():Boolean 
		{
			return _currentShowingSentenceIndex < _dialogStrings.length;
		}
	}
}