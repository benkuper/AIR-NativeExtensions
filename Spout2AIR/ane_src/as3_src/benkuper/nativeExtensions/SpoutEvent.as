package benkuper.nativeExtensions
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SpoutEvent extends Event 
	{
		
		static public const SHARING_STARTED:String = "sharingStarted";
		static public const SHARING_STOPPED:String = "sharingStopped";
		
		public var sharingName:String;
		
		public function SpoutEvent(type:String, sharingName:String = "none", bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.sharingName = sharingName;
		} 
		
		public override function clone():Event 
		{ 
			return new SpoutEvent(type, sharingName, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SpoutEvent", "type", "sharingName", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}