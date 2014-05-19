package  benkuper.nativeExtensions
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class DMXEvent extends Event 
	{
		
		static public const DEVICE_CONNECTED:String = "deviceConnected";
		static public const DEVICE_DISCONNECTED:String = "deviceDisconnected";
		
		public var device:DMXDevice;
		
		public function DMXEvent(type:String, device:DMXDevice = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.device = device;
		} 
		
		public override function clone():Event 
		{ 
			return new DMXEvent(type, device, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DMXEvent", "type", "device", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}