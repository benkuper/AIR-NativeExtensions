package 
{
	import benkuper.nativeExtensions.NativeSerial;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite 
	{
		private var serial:NativeSerial;
		
		public function Main():void 
		{
			serial = new NativeSerial();
			serial.listPorts();
		}
		
	}
	
}