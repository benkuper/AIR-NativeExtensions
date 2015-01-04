package benkuper.nativeExtensions
{
	import com.greensock.TweenLite;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class NativeMIDI extends EventDispatcher
	{
		public var extContext:ExtensionContext;		
		
		public var inputDevices:Vector.<MIDIDeviceIn>;
		public var outputDevices:Vector.<MIDIDeviceOut>;
		
		public function NativeMIDI():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeMIDI", "midi");
            extContext.addEventListener(StatusEvent.STATUS, statusHandler);

            var b:Boolean = extContext.call("init") as Boolean;
			
			updateDeviceList();
			

			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);
			
		}
		
		private function statusHandler(e:StatusEvent):void 
		{
			//trace("Status from Native Extension", e.code, e.level);
			switch(e.code)
			{
                case "print":
                    trace("[NativeMIDI Extension::print] "+e.level);
                    break;

				case "data":
					updateData();
					break;
			}
		}
		
		private function updateDeviceList():void 
		{
			inputDevices = extContext.call("listInputDevices") as Vector.<MIDIDeviceIn>;
			outputDevices = extContext.call("listOutputDevices") as Vector.<MIDIDeviceOut>;
		}
		
		private function updateData():void 
		{
			var messages:Vector.<MIDIMessage> = extContext.call("updateData") as Vector.<MIDIMessage>;
			
			for each(var m:MIDIMessage in messages)
			{
				dispatchEvent(MIDIEvent.getEventForMessage(m));
			}
		}		
		
		
		public function openInputDevice(inputDevice:MIDIDeviceIn):Boolean
		{
			return openInputDeviceByIndex(inputDevices.indexOf(inputDevice));
		}
		
		public function openInputDeviceByIndex(index:int):Boolean
		{
			if (index >= 0 && index < inputDevices.length) return extContext.call("openInputDevice", index) as Boolean;
			
			return false;
		}
		
		public function openInputDeviceByName(name:String):Boolean
		{
			for each(var i:MIDIDeviceIn in inputDevices)
			{
				if (i.name == name) return openInputDevice(i);
			}
			
			return false;
		}
		
		public function openOutputDevice(outputDevice:MIDIDeviceOut):Boolean
		{
			return openOutputDeviceByIndex(outputDevices.indexOf(outputDevice));
		}
		
		public function openOutputDeviceByIndex(index:int):Boolean
		{
			if (index >= 0 && index < outputDevices.length)  return extContext.call("openOutputDevice", index) as Boolean;
			return false;
		}
		
		public function openOutputDeviceByName(name:String):Boolean
		{
			for each(var i:MIDIDeviceOut in outputDevices)
			{
				if (i.name == name) return openOutputDevice(i);
			}
			
			return false;
		}
		
		public function closeInputDevice(inputDevice:MIDIDeviceIn):void
		{
			if (!inputDevice.opened) return;
			var result:Boolean = extContext.call("closeInputDevice", inputDevice.name) as Boolean;
		}
		
		public function closeOutputDevice(outputDevice:MIDIDeviceOut):void
		{
			if (!outputDevice.opened) return;
			var result:Boolean = extContext.call("closeOutputDevice", outputDevice.name) as Boolean;
		}
		
		
		//SENDING
		
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
			sendNoteOn(channel,pitch,velocity);
			TweenLite.delayedCall(duration, sendNoteOff, [channel, pitch]);
		}
		
		public function sendControllerChange(channel:int, number:int, value:int):void
		{
			sendMessage(channel + 175, number, value);
		}
		
		public function sendMessage(status:int, data1:int, data2:int):void 
		{
			var result:Boolean = extContext.call("sendMessage", status, data1, data2) as Boolean;
		}
		
		
		
		public function clean():void
		{
			trace("Cleaning...");
			extContext.call("clean");
		}
		
		private function appExiting(e:Event):void 
		{
			clean();
		}
		
		
	}
	
} 