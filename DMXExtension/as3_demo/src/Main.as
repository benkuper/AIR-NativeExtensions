package 
{
	import benkuper.nativeExtensions.NativeDMXController;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite 
	{
		private var dmx:NativeDMXController;
		
		public function Main():void 
		{
			
			dmx = new NativeDMXController();

		}
		
	}
	
}