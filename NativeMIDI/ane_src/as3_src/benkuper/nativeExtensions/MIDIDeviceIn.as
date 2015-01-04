package benkuper.nativeExtensions
{
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MIDIDeviceIn extends MIDIDevice
	{
		
		public function MIDIDeviceIn(name:String):void
		{
			super(name);
			var filterName:Array = name.split(" ");
			if (filterName.length > 1) filterName.pop();
			this.name = filterName.join(" "); //RTMidi adds index at the end of the name, remove it for real device name
		}
		
		override public function open():Boolean 
		{
			super.open();
			nativePointer = NativeMIDI.openInputDevice(this);
			return nativePointer != -1;
		}
		
		
		
		public function updateData(message:MIDIMessage):void
		{
			var evt:MIDIEvent = MIDIEvent.getEventForMessage(message);
			evt.device = this;
			dispatchEvent(evt);
		}
		
		override public function close():void
		{
			super.close();
			NativeMIDI.closeInputDevice(this);
		}
		
		override public function toString():String
		{
			return "[MIDIDeviceIn name=\"" + name+"\"]";
		}
	}
	
}