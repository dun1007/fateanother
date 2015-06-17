package {

	import ValveLib.Globals;
	import flash.events.*;
	import flash.display.MovieClip;

	public class ResourceIcon extends MovieClip{
		public var resourceName:String;
		public var itemName:String;
		public var onClick:Function;

		public function ResourceIcon(resourceName:String, item:Boolean = false){
			this.onClick = onClick;
			this.resourceName = resourceName;
			this.itemName = resourceName;
            if (item) {
                Globals.instance.LoadItemImage(itemName, this);
            } else {
                Globals.instance.LoadAbilityImage(resourceName, this);
            }
		}

		public function getResourceName(){
			return itemName;
		}


	}
}