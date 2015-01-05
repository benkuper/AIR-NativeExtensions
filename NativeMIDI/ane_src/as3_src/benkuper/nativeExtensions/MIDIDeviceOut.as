package benkuper.nativeExtensions
{
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MIDIDeviceOut extends MIDIDevice
	{
		
		public function MIDIDeviceOut(name:String):void
		{
			super(name);
		}
		
		override public function open():Boolean 
		{
			super.open();
			nativePointer = NativeMIDI.openOutputDevice(this);
			opened = nativePointer != -1;
			return opened;
		}
		
		override public function close():void
		{
			super.close();
			NativeMIDI.closeOutputDevice(this);
			opened = false;
		}
		
		public function sendNoteOn(channel:int, pitch:int, velocity:int = 127):void
		{
			sendMessage(channel + 143, pitch, velocity);
		}
		
		public function sendNoteOff(channel:int, pitch:int,velocity:int = 0):void
		{
			sendMessage(channel + 127, pitch, velocity);
		}
		
		public function sendFullNote(channel:int, pitch:int, velocity:int, duration:Number):void
		{
			sendNoteOn(channel, pitch, velocity);
			setTimeout(sendNoteOff,duration*1000,channel, pitch);
		}
		
		public function sendControllerChange(channel:int, number:int, value:int):void
		{
			sendMessage(channel + 175, number, value);
		}
		
		public function sendMessage(channel:int, data1:int, data2:int):void
		{
			NativeMIDI.sendMessage(this, channel, data1, data2);
		}
		
		override public function toString():String
		{
			return "[MIDIDeviceOut name=\"" + name+"\"]";
		}
	}
	
}