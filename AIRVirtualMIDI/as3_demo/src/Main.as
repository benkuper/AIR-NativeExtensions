package 
{
	import benkuper.nativeExtensions.MIDIEvent;
	import benkuper.nativeExtensions.NativeMIDI;
	import benkuper.nativeExtensions.VirtualMIDI;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void    
		{
			VirtualMIDI.init();
			VirtualMIDI.createDevice("AIR VirtualMIDI");
			
			NativeMIDI.init();
			NativeMIDI.instance.addEventListener(MIDIEvent.DEVICE_OUT_ADDED, deviceAdded);
			
		}
		
		private function deviceAdded(e:MIDIEvent):void 
		{
			trace("Device out added :" + e.device);
		}
	}	
}