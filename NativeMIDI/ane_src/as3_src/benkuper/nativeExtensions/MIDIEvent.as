package benkuper.nativeExtensions
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MIDIEvent extends Event 
	{
		
		static public const NOTE_ON:String = "noteOn";
		static public const NOTE_OFF:String = "noteOff";
		static public const CONTROLLER_CHANGE:String = "controllerChange";
		
		
		static public const DEVICE_IN_ADDED:String = "deviceInAdded";
		static public const DEVICE_IN_REMOVED:String = "deviceInRemoved";
		
		static public const DEVICE_OUT_ADDED:String = "deviceOutAdded";
		static public const DEVICE_OUT_REMOVED:String = "deviceOutRemoved";
		
		//
		public var device:MIDIDevice;
		
		//
		public var channel:int;
		
		//note
		public var data1:int;
		public var data2:int;

		
		public function MIDIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.channel = channel;
			this.data1 = data1;
			this.data2 = data2;
			
		} 
		
		
		public static function getEventForMessage(m:MIDIMessage):MIDIEvent
		{
			var type:String = "";
			var channel:int = 0;
			
			if (m.status >= 143 && m.status <= 159) 
			{
				type = NOTE_ON;
				channel = m.status - 143;
			}else if (m.status >= 127 && m.status <= 143)
			{
				type = NOTE_OFF;
				channel = m.status - 127;
			}else if (m.status >= 176 && m.status <= 191)
			{
				type = CONTROLLER_CHANGE;
				channel = m.status - 175;
			}
			
			var evt:MIDIEvent = new MIDIEvent(type);
			evt.channel = channel;
			evt.data1 = m.data1;
			evt.data2 = m.data2;
			return evt;
		}
		
		
		public override function clone():Event 
		{ 
			var evt:MIDIEvent = new MIDIEvent(type, bubbles, cancelable);
			evt.channel = channel;
			evt.data1 = data1;
			evt.data2 = data2;
			return evt;
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MIDIEvent", "type", "channel","data1","data2", "bubbles", "cancelable", "eventPhase"); 
		}
		
		//Getters
		
		public function get pitch():int { return data1; } //note 
		public function get number():int { return data1; } //controller
		
		public function get velocity():int { return data2; } //note 
		public function get value():int { return data2; } //controller
		
		
	}
	
}