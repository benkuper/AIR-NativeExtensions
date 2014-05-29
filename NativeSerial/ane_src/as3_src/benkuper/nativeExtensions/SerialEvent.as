package  benkuper.nativeExtensions
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SerialEvent extends Event 
	{
		static public const DATA:String = "data";
		
		public function SerialEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new SerialEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SerialEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}