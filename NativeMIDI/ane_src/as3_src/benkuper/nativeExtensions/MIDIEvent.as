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
		
		//
		public var channel:int;
		
		//note
		public var data1:int;
		public var data2:int;

		
		public function MIDIEvent(type:String, channel:int, data1:int, data2:int, bubbles:Boolean=false, cancelable:Boolean=false) 
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
			
			return new MIDIEvent(type,channel,m.data1,m.data2);
		}
		
		
		public override function clone():Event 
		{ 
			return new MIDIEvent(type, channel, data1,data2, bubbles, cancelable);
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