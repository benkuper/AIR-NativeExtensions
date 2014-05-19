package benkuper.nativeExtensions 
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class DMXDevice extends EventDispatcher 
	{
		
		static public const ENTTEC_DMXPRO:String = "enttecDXMPro";
		static public const ENTTEC_OPENDMX:String = "enttecOpenDMX";
		static public const ENTTEC_DMXPRO_MK2:String = "enttecDMXProMK2";
		
		
		private var deviceIndex:int;
		public var serial:String;
		public var description:String;
		public var type:String;
		
		
		public var opened:Boolean;
		
		public function DMXDevice(deviceIndex:int, description:String,serial:String) 
		{
			//trace("constuctor :", deviceIndex, description, serial);
			this.deviceIndex = deviceIndex;
			this.serial = serial;
			this.description = description;
			
			switch(description)
			{
				case "DMX USB PRO":
					type = ENTTEC_DMXPRO;
					break;
					
				case "OPENDMX":
					type = ENTTEC_OPENDMX;
					break;
					
				case "DMX USB PRO MK2":
					type = ENTTEC_DMXPRO_MK2;
					break;
			}
			
		}
		
		public function open():Boolean
		{
			opened = true;
			return true;
		}
		
		public function close():Boolean
		{
			if (!opened) return false;
			opened = false;
			return true;
		}
		
		public function sendValue (channel:int, value:int) : void
		{
			
		}
		
		public function sendValues (values:Vector.<int>, offset:int = 0) : void
		{
			
		}
		
		
		public function clean():void 
		{
			
		}
		
		
		override public function toString():String
		{
			return "[DMXDevice , index = "+deviceIndex+", serial = " + serial + ", description = " + description + ", type = " + type+", isOpen ? " + opened + "]";
		}
		
		
		
	}

}