package benkuper.nativeExtensions
{
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MIDIDeviceIn 
	{
		public var opened:int;
		public var name:String;
		
		
		public function MIDIDeviceIn(name:String):void
		{
			this.name = name;
			
		}
		
		public function toString():String
		{
			return "[MIDIDeviceIn name=" + name+"]";
		}
	}
	
}