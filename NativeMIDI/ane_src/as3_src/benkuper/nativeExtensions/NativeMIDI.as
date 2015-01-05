package benkuper.nativeExtensions
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExtensionContext;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class NativeMIDI extends EventDispatcher
	{
		public static var extContext:ExtensionContext;		
		
		public static var inputDevices:Vector.<MIDIDeviceIn>;
		public static var outputDevices:Vector.<MIDIDeviceOut>;
		
		public static var instance:NativeMIDI;
		
		private var updateListTimer:Timer;
		
		public function NativeMIDI():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeMIDI", "midi");
			extContext.addEventListener(StatusEvent.STATUS, statusHandler);
			
			extContext.call("init") as Boolean;
			
			inputDevices = new Vector.<MIDIDeviceIn>();
			outputDevices = new Vector.<MIDIDeviceOut>();
			
			
			updateListTimer = new Timer(1000);
			updateListTimer.addEventListener(TimerEvent.TIMER, updateListTimerTick);
			updateListTimer.start();
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);
			
		}
		
		public static function init():void
		{
			if (instance != null) return;
			instance = new NativeMIDI();
		}
		
		private function statusHandler(e:StatusEvent):void 
		{
			//trace("Status from Native Extension", e.code, e.level);
			switch(e.code)
			{
				case "print":
					trace("[NativeMIDIExtension :: print] " + e.level);
					break;
					
				case "data":
					updateData();
					break;
			}
		}
		
		private function updateListTimerTick(e:TimerEvent):void 
		{
			updateDeviceList();
		}
		
		private function updateDeviceList():void 
		{
			var newInputs:Vector.<MIDIDeviceIn> = extContext.call("listInputDevices") as Vector.<MIDIDeviceIn>;
			
			var found:Boolean;
			
			for each(var i:MIDIDeviceIn in inputDevices)
			{
				found = false;
				for each(var ni:MIDIDeviceIn in newInputs)
				{
					if (i.name == ni.name) 
					{
						found = true;
						break;				
					}
				}
				if (!found) //device removed
				{
					removeDeviceIn(i);
				}
			}
			
			for each(var nj:MIDIDeviceIn in newInputs)
			{
				found = false;
				for each(var j:MIDIDeviceIn in inputDevices)
				{
					if (j.name == nj.name) 
					{
						found = true;
						break;
					}
					
				}
				
				if (!found) //device added
				{
					addDeviceIn(nj);
				}
			}
			
			var newOutputs:Vector.<MIDIDeviceOut> = extContext.call("listOutputDevices") as Vector.<MIDIDeviceOut>;
			
			for each(var o:MIDIDeviceOut in outputDevices)
			{
				found = false;
				for each(var no:MIDIDeviceOut in newOutputs)
				{
					if (o.name == no.name) 
					{
						found = true;
						break;
					}
					
				}
				
				if (!found) //device removed
				{
					removeDeviceOut(o);
				}
			}
			
			for each(var np:MIDIDeviceOut in newOutputs)
			{
				found = false;
				for each(var p:MIDIDeviceOut in outputDevices)
				{
					if (p.name == np.name) 
					{
						found = true;
						break;
					}
					
				}
				
				if (!found) //device added
				{
					addDeviceOut(np);
				}
			}
		}
		
		private function addDeviceIn(device:MIDIDeviceIn):void 
		{
			inputDevices.push(device);
			var evt:MIDIEvent = new MIDIEvent(MIDIEvent.DEVICE_IN_ADDED);
			evt.device = device;
			dispatchEvent(evt);
		
		}
		
		private function removeDeviceIn(device:MIDIDeviceIn):void 
		{
			inputDevices.splice(inputDevices.indexOf(device), 1);
			var evt:MIDIEvent = new MIDIEvent(MIDIEvent.DEVICE_IN_REMOVED);
			evt.device = device;
			dispatchEvent(evt);
		}
		
		private function addDeviceOut(device:MIDIDeviceOut):void 
		{
			outputDevices.push(device);
			var evt:MIDIEvent = new MIDIEvent(MIDIEvent.DEVICE_OUT_ADDED);
			evt.device = device;
			dispatchEvent(evt);
		}
		
		private function removeDeviceOut(device:MIDIDeviceOut):void 
		{
			outputDevices.splice(outputDevices.indexOf(device), 1);
			var evt:MIDIEvent = new MIDIEvent(MIDIEvent.DEVICE_OUT_REMOVED);
			evt.device = device;
			dispatchEvent(evt);
		}
		
		
		private function updateData():void 
		{
			var messages:Vector.<MIDIMessage> = extContext.call("updateData") as Vector.<MIDIMessage>;
			for each(var m:MIDIMessage in messages)
			{
				var midiDevice:MIDIDeviceIn = getInDeviceForPointer(m.devicePointer);
				if(midiDevice != null) midiDevice.updateData(m);
			}
		}		
		
		private function getInDeviceForPointer(devicePointer:int):MIDIDeviceIn 
		{
			for each(var m:MIDIDeviceIn in inputDevices)
			{
				if (m.nativePointer == devicePointer) return m;
			}
			
			return null;
		}
		
		public static function openInputDevice(inputDevice:MIDIDeviceIn):int
		{
			return openInputDeviceByIndex(inputDevices.indexOf(inputDevice));
		}
		
		public static function openInputDeviceByIndex(index:int):int
		{
			if (index >= 0 && index < inputDevices.length) return extContext.call("openInputDevice", index) as int;
			
			return -1;
		}
		
		public static function openInputDeviceByName(name:String):int
		{
			for each(var i:MIDIDeviceIn in inputDevices)
			{
				trace(i.name,name);
				if (i.name == name) return openInputDevice(i);
			}
			
			return -1;
		}
		
		public static function openOutputDevice(outputDevice:MIDIDeviceOut):int
		{
			return openOutputDeviceByIndex(outputDevices.indexOf(outputDevice));
		}
		
		public static function openOutputDeviceByIndex(index:int):int
		{
			if (index >= 0 && index < outputDevices.length)  return extContext.call("openOutputDevice", index) as int;
			return -1;
		}
		
		public static function openOutputDeviceByName(name:String):int
		{
			for each(var i:MIDIDeviceOut in outputDevices)
			{
				if (i.name == name) return openOutputDevice(i);
			}
			
			return -1;
		}
		
		public static function closeInputDevice(inputDevice:MIDIDeviceIn):Boolean
		{
			if (!inputDevice.opened) return false;
			//trace("Close device :" + inputDevice);
			var result:Boolean = extContext.call("closeInputDevice", inputDevice.nativePointer) as Boolean;
			return result;
		}
		
		public static function closeOutputDevice(outputDevice:MIDIDeviceOut):Boolean
		{
			if (!outputDevice.opened) return false;
			var result:Boolean = extContext.call("closeOutputDevice", outputDevice.nativePointer) as Boolean;
			return result;
		}
		
		
		//SENDING
		
		public static function sendMessage(outputDevice:MIDIDeviceOut, status:int, data1:int, data2:int):void 
		{
			var result:Boolean = extContext.call("sendMessage", outputDevice.nativePointer, status, data1, data2) as Boolean;
		}
		
		public function clean():void
		{
			trace("Cleaning...");
			for each(var m:MIDIDeviceIn in inputDevices) m.close();
			for each(var o:MIDIDeviceOut in outputDevices) o.close();
			
			updateListTimer.stop();
			updateListTimer.removeEventListener(TimerEvent.TIMER, updateListTimerTick);
			extContext.dispose();
		}
		
		private function appExiting(e:Event):void 
		{
			clean();
		}
		
		
	}
	
} 