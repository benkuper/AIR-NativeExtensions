package benkuper.nativeExtensions 
{
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MIDIMessage 
	{
		public var status:int;
		public var data1:int;
		public var data2:int;
		public var stamp:Number;
		
		public function MIDIMessage(status:int,data1:int,data2:int,stamp:Number ) 
		{
			//trace("new MIDI Message !", status, data1, data2, stamp);
			
			this.status = status;
			this.data1 = data1;
			this.data2 = data2;
			this.stamp = stamp;
			
		}
		
	}

}