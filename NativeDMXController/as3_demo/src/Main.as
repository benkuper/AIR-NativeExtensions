package 
{
	import benkuper.nativeExtensions.DMXEvent;
	import benkuper.nativeExtensions.NativeDMXController;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
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
			
			dmx.addEventListener(DMXEvent.DEVICE_CONNECTED, deviceConnected);
			dmx.addEventListener(DMXEvent.DEVICE_DISCONNECTED, deviceDisconnected);
			dmx.updateDeviceList();
		}
		
		private function deviceConnected(e:DMXEvent):void 
		{
			trace("Main :: device Connected", e.device);
			//dmx.autoSearch = false;
		}
		
		private function deviceDisconnected(e:DMXEvent):void 
		{
			trace("Main :: device disconnected", e.device);
		}
	}
	
}