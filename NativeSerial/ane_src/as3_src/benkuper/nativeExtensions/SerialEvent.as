package  benkuper.nativeExtensions
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SerialEvent extends Event 
	{
		
		static public const PORT_ADDED:String = "portAdded";
		static public const PORT_REMOVED:String = "portRemoved";
		static public const PORT_OPENED:String = "portOpened";
		static public const PORT_CLOSED:String = "portClosed";
		
		static public const DATA:String = "data";
		static public const DATA_255:String = "data255";
		static public const DATA_NEWLINE:String = "dataNewline";
		
		public var data:ByteArray;
		public var stringData:String;
		public var port:SerialPort;
		
		public function SerialEvent(type:String, port:SerialPort = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.port = port;
			
		} 
		
		public override function clone():Event 
		{ 
			return new SerialEvent(type, port, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SerialEvent", "type", "port", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}