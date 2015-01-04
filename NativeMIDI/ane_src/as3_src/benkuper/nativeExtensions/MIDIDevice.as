package benkuper.nativeExtensions
{
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MIDIDevice extends EventDispatcher
	{
		public var name:String;
		public var uniqueName:String;
		
		public var opened:Boolean;
		
		public var nativePointer:int;
		
		public function MIDIDevice(name:String):void
		{
			this.uniqueName = name;
			this.name = name;
		}
		
		//
		public function open():Boolean
		{
			//to be overriden
			return false;
		}
		
		public function close():void
		{
			//to be overriden
		}
		
		override public function toString():String
		{
			return "[MIDIDevice name=\"" + name+"\"]";
		}
	}
	
}