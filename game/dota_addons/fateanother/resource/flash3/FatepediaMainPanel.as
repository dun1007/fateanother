package  {
	
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
		
	public class FatepediaMainPanel extends MovieClip {
	
		public var heroPanel:MovieClip;	
		public var gameAPI:Object;
		public var globals:Object
		private var ScreenWidth:int;
		private var ScreenHeight:int;
		
		public function FatepediaMainPanel(globals:Object) {
			visible = true;
			this.AddClickListeners();
			this.ScreenWidth = 1920;
			this.ScreenHeight = 1080;	
			this.globals = globals
			trace("FatepediaMainPanel constructed")
		}
		public function AddClickListeners() {
			//this.mainPanelCloseButton.addEventListener(MouseEvent.CLICK, onMainPanelClosed);
			
			this.SaberButton.addEventListener(MouseEvent.CLICK, onSaberClicked);
			this.Lancer5thButton.addEventListener(MouseEvent.CLICK, onLancer5thClicked);
			this.Archer5thButton.addEventListener(MouseEvent.CLICK, onArcher5thClicked);
			this.Rider5thButton.addEventListener(MouseEvent.CLICK, onRider5thClicked);
			this.Assassin5thButton.addEventListener(MouseEvent.CLICK, onAssassin5thClicked);
			this.Berserker5thButton.addEventListener(MouseEvent.CLICK, onBerserker5thClicked);
			this.Caster5thButton.addEventListener(MouseEvent.CLICK, onCaster5thClicked);
			this.TAssassin5thButton.addEventListener(MouseEvent.CLICK, onTAssassin5thClicked);
			this.SaberAlterButton.addEventListener(MouseEvent.CLICK, onSaberAlterClicked);
			this.Archer4thButton.addEventListener(MouseEvent.CLICK, onArcher4thClicked);
			this.AvengerButton.addEventListener(MouseEvent.CLICK, onAvengerClicked);
			this.Lancer4thButton.addEventListener(MouseEvent.CLICK, onLancer4thClicked);
			this.Caster4thButton.addEventListener(MouseEvent.CLICK, onCaster4thClicked);
			this.Berserker4thButton.addEventListener(MouseEvent.CLICK, onBerserker4thClicked);
			this.Rider4thButton.addEventListener(MouseEvent.CLICK, onRider4thClicked);
			this.RedSaberExtraButton.addEventListener(MouseEvent.CLICK, onRedSaberExtraClicked);
			this.WhiteSaberExtraButton.addEventListener(MouseEvent.CLICK, onWhiteSaberExtraClicked);
		}

		public function createHeroPanel(hName:String, rName:String) {
			if ((heroPanel != null) && contains(heroPanel)) {
				removeChild(heroPanel)
			}
			trace("Loading ", rName, "'s introduction page...")
			this.heroPanel = new HeroPanel(hName,rName, gameAPI, globals);
			this.addChild(heroPanel);
			//trace("Panel sizes", ScreenWidth, ScreenHeight, heroPanel.width, heroPanel.height);
			trace(heroPanel.height, this.height);
			heroPanel.x = -heroPanel.width;
			heroPanel.y = heroPanel.height * 0.1;
			//heroPanel.width = 
			//heorPanel.height = 
			//heroPanel.x = ScreenWidth;
			//heroPanel.y = ScreenHeight - heroPanel.height/2;
			trace("Current location...", heroPanel.x, heroPanel.y);
			
		}
		
		public function onMainPanelClosed(event:MouseEvent)
        {
			this.visible = false;
			if (heroPanel != null) {
				removeChild(heroPanel)
			}
			trace("Closing main panel...")
            return;
        }
		public function onSaberClicked(event:MouseEvent)
        {
			createHeroPanel("legion_commander", "Saber");
            return;
        }
		public function onLancer5thClicked(event:MouseEvent)
        {
			createHeroPanel("phantom_lancer", "Lancer(5th)");
            return;
        }
		public function onArcher5thClicked(event:MouseEvent)
        {
			createHeroPanel("ember_spirit", "Archer(5th)");
            return;
        }
		public function onRider5thClicked(event:MouseEvent)
        {
			createHeroPanel("templar_assassin", "Rider(5th)");
            return;
        }
		public function onAssassin5thClicked(event:MouseEvent)
        {
			createHeroPanel("juggernaut", "Assassin(5th)");
            return;
        }
		public function onBerserker5thClicked(event:MouseEvent)
        {
			createHeroPanel("doom_bringer", "Berserker(5th)");
            return;
        }
		public function onCaster5thClicked(event:MouseEvent)
        {
			createHeroPanel("crystal_maiden", "Caster(5th)");
            return;
        }
		public function onTAssassin5thClicked(event:MouseEvent)
        {
			createHeroPanel("bounty_hunter", "TrueAssassin(5th)");
            return;
        }
		public function onSaberAlterClicked(event:MouseEvent)
        {
			createHeroPanel("spectre", "SaberAlter");
            return;
        }
		public function onArcher4thClicked(event:MouseEvent)
        {
			createHeroPanel("skywrath_mage", "Archer(4th)");
            return;
        }
		public function onAvengerClicked(event:MouseEvent)
        {
			createHeroPanel("vengefulspirit", "Avenger");
            return;
        }
		public function onLancer4thClicked(event:MouseEvent)
        {
			createHeroPanel("huskar", "Lancer(4th)");
            return;
        }
		public function onBerserker4thClicked(event:MouseEvent)
        {
			createHeroPanel("sven", "Berserker(4th)");
            return;
        }
		public function onCaster4thClicked(event:MouseEvent)
        {
			createHeroPanel("shadow_shaman", "Caster(4th)");
            return;
        }
		public function onRider4thClicked(event:MouseEvent)
        {
			createHeroPanel("chen", "Rider(4th)");
            return;
        }
		public function onRedSaberExtraClicked(event:MouseEvent)
        {
			createHeroPanel("lina", "RedSaber(Extra)");
            return;
        }
		public function onWhiteSaberExtraClicked(event:MouseEvent)
        {
			createHeroPanel("omniknight", "WhiteSaber(Extra)");
            return;
        }
	}
	
}
