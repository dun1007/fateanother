package  {
	
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import flash.geom.Point;
	import scaleform.clik.events.*;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.data.DataProvider;
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;
	import flash.text.TextFormat;
	
	public class HeroPanel extends MovieClip {
		public var heroPanel:MovieClip;	
		public var gameAPI:Object;
		public var globals:Object;
		public var abilityIconScale = 0.3515625;
		public var hName:String;
		public var realName:String;
		public var abilities:Object;
		public var heroes:Object; 
		public var skill_choice:String;

		private var ScreenWidth:int;
		private var ScreenHeight:int;
		//originalHeroName : Name of dota 2 hero overriden
		//servantHeroName : Name as Servant in Fate series
		public function HeroPanel(originalHeroName:String, realHeroName:String, api:Object, globals:Object) {
			this.gameAPI = api;
			this.visible = true;
			this.globals = globals;
			this.hName = originalHeroName;
			this.realName = realHeroName;
			this.abilities = this.globals.GameInterface.LoadKVFile('scripts/npc/npc_abilities_custom.txt'); //Load ability KV
			this.heroes = this.globals.GameInterface.LoadKVFile('scripts/npc/npc_heroes_custom.txt'); //Load hero KV
			
			//var myFont:TextFormat = new TextFormat();
			//myFont.font = "MyFont";
			//myFont.size = 15;
			//Add portrait
			var heroPortrait:MovieClip = new MovieClip;
			this.globals.LoadImage("images/heroes/" + hName + ".png", heroPortrait, false);
			heroPortrait.x = -495;//
			heroPortrait.y = -769;
			heroPortrait.scaleY = 1; //24px
			heroPortrait.scaleX = 1; //24px
			this.addChild(heroPortrait);
			
			//Set texts
			this.Title.text = realName;	//Hero Title
			//this.Innate.embedFonts = true
			//this.Innate.defaultTextFormat = myFont
			this.Innate.text = "#Fatepedia_Innate"
			
			this.Attr.text = "#Fatepedia_Attributes"
			//this.BuildSuggestion.text = "#Fatepedia_Build_Suggestion"
			//this.SkillOrder.text = "#Fatepedia_Skill_Order"
			//this.CoreAttr.text = "#Fatepedia_Core_Attributes_Stats"
			this.PlayingAs.text = "#Fatepedia_Playing_As"
			this.PlayingAgainst.text = "#Fatepedia_Playing_Against"
			this.PlayingAs1.text = "#Fatepedia_playing_as_" + realName + "_1"
			this.PlayingAs2.text = "#Fatepedia_playing_as_" + realName + "_2"
			this.PlayingAs3.text = "#Fatepedia_playing_as_" + realName + "_3"
			this.PlayingAgainst1.text = "#Fatepedia_playing_against_" + realName + "_1"
			this.PlayingAgainst2.text = "#Fatepedia_playing_against_" + realName + "_2"
			this.PlayingAgainst3.text = "#Fatepedia_playing_against_" + realName + "_3"
			
			
			setupAbilityResource(-492.5,-660,4); //Innate 1
			setupAbilityResource(-442.5,-660,5); //Innate 2
			setupAbilityResource(-392.5,-660,1); //Q
			setupAbilityResource(-342.5,-660,2); //W
			setupAbilityResource(-292.5,-660,3); //E
			setupAbilityResource(-242.5,-660,6); //R
			
			setupAbilityResource(-492.5,-589,11); //Attr 1
			setupAbilityResource(-442.5,-589,12); //Attr 2
			setupAbilityResource(-392.5,-589,13); //Attr 3
			setupAbilityResource(-342.5,-589,14); //Attr 4
			if (parseInt(findAttributeCount(hName)) > 4) {
				trace("5th attribute detected");
				setupAbilityResource(-292.5,-589,15); //Attr 5
			}
			setupAbilityResource(-155,-630,7); //Combo
			
			
			trace("Fatepedia hero panel constructed")
		}
		
		//Index 1~6 : regular skills
		//Index 7 : Combo
		//Index 11~15 : Attributes
		public function setupAbilityResource(xLoc:int, yLoc:int, abilIndex:int)
		{
			if (abilIndex == 7) {
				var abil:ResourceIcon = new ResourceIcon(findComboName(hName, abilIndex));
			}
			else if (abilIndex < 10) {
				var abil:ResourceIcon = new ResourceIcon(findAbilityName(hName, abilIndex));
			} 
			else {
				var abil:ResourceIcon = new ResourceIcon(findAttributeName(hName, abilIndex - 10));
			}
			abil.x = xLoc;
			abil.y = yLoc;
			abil.scaleX = abilityIconScale;
			abil.scaleY = abilityIconScale;
			abil.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			abil.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			this.addChild(abil);		
		}

		public function getAbilityTextureName(abilName:String) {
			for (var k:String in abilities)
			{
				if (k == abilName) {
					for (var k2:String in abilities[k]) {
						if (k2 == "AbilityTextureName") {
							return abilities[k][k2]
						}
					}
				}
			}
		}
		public function findAbilityName(heroName:String, abilIndex:int) {
			for (var k:String in heroes)
			{
				for (var k2:String in heroes[k]) {
					if ((k2 == "override_hero") && (heroes[k][k2] == "npc_dota_hero_" + heroName)) { //upon finding the matching hero name
						for (var k3:String in heroes[k]){
							if (k3 == "Ability" + abilIndex) {
								return heroes[k][k3]
							}
						}
					}
				}
			}
		}

		public function findAttributeName(heroName:String, attrIndex:int) {
			for (var k:String in heroes)
			{
				for (var k2:String in heroes[k]) {
					if ((k2 == "override_hero") && (heroes[k][k2] == "npc_dota_hero_" + heroName)) { //upon finding the matching hero name
						trace(heroName + " found, retrieving attribute name")
						for (var k3:String in heroes[k]){
							if (k3 == "Attribute" + attrIndex) {
								return heroes[k][k3]
							}
						}
					}
				}
			}
		}
		public function findAttributeCount(heroName:String) {
			for (var k:String in heroes)
			{
				for (var k2:String in heroes[k]) {
					if ((k2 == "override_hero") && (heroes[k][k2] == "npc_dota_hero_" + heroName)) { //upon finding the matching hero name
						for (var k3:String in heroes[k]){
							if (k3 == "AttributeNumber") {
								return heroes[k][k3]
							}
						}
					}
				}
			}
		}
		public function findComboName(heroName:String, attrIndex:int) {
			for (var k:String in heroes)
			{
				for (var k2:String in heroes[k]) {
					if ((k2 == "override_hero") && (heroes[k][k2] == "npc_dota_hero_" + heroName)) { //upon finding the matching hero name
						for (var k3:String in heroes[k]){
							if (k3 == "Combo") {
								return heroes[k][k3]
							}
						}
					}
				}
			}
		}	
		public function onMouseRollOver(keys:MouseEvent){
       		var s:Object = keys.target;
            var lp:Point = s.localToGlobal(new Point(0, 0));
            skill_choice = s.getResourceName();
			trace("Roll over ",s.getResourceName())
            globals.Loader_heroselection.gameAPI.OnSkillRollOver(lp.x, lp.y, skill_choice);
       	}
		
		public function onMouseRollOut(keys:MouseEvent){	
			globals.Loader_heroselection.gameAPI.OnSkillRollOut();
		}
	}
	
}
