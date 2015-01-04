package 
{
	import benkuper.nativeExtensions.MIDIDeviceIn;
	import benkuper.nativeExtensions.MIDIDeviceOut;
	import benkuper.nativeExtensions.MIDIEvent;
	import benkuper.nativeExtensions.NativeMIDI;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite 
	{
		private var deviceIn:MIDIDeviceIn;
		private var deviceIn2:MIDIDeviceIn;
		private var deviceOut:MIDIDeviceOut;
		
		public function Main():void 
		{
			NativeMIDI.init();
			NativeMIDI.instance.addEventListener(MIDIEvent.DEVICE_IN_ADDED, deviceInAdded);
			NativeMIDI.instance.addEventListener(MIDIEvent.DEVICE_IN_REMOVED, deviceInRemoved);
			NativeMIDI.instance.addEventListener(MIDIEvent.DEVICE_OUT_ADDED, deviceOutAdded);
			NativeMIDI.instance.addEventListener(MIDIEvent.DEVICE_OUT_REMOVED, deviceOutRemoved);
			
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			//stage.addEventListener(KeyboardEvent.KEY_UP, keyDown);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		
		
		private function deviceInAdded(e:MIDIEvent):void 
		{
			trace("device added !", e.device.name);
			if (e.device.name.match("Keystation") != null)
			{
				deviceIn = e.device as MIDIDeviceIn; 
				var isOpen:Boolean = deviceIn.open();
				trace("Device " + deviceIn.name+" open ?" + isOpen);
				deviceIn.addEventListener(MIDIEvent.NOTE_ON, midiNoteOn);
				deviceIn.addEventListener(MIDIEvent.NOTE_OFF, midiNoteOff);
				deviceIn.addEventListener(MIDIEvent.CONTROLLER_CHANGE, midiControllerChange);
			}
			
			if (e.device.name.match("LPK") != null)
			{
				deviceIn2 = e.device as MIDIDeviceIn; 
				var isOpen2:Boolean = deviceIn2.open();
				trace("Device " + deviceIn2.name+" open ?" + isOpen2);
				deviceIn2.addEventListener(MIDIEvent.NOTE_ON, midiNoteOn);
				deviceIn2.addEventListener(MIDIEvent.NOTE_OFF, midiNoteOff);
				deviceIn2.addEventListener(MIDIEvent.CONTROLLER_CHANGE, midiControllerChange);
			}
		}
		
		private function deviceInRemoved(e:MIDIEvent):void 
		{
			trace("device removed !", e.device.name);
		}
		
		
		private function deviceOutAdded(e:MIDIEvent):void 
		{
			trace("device Out added",e.device.name);
		}
		
		private function deviceOutRemoved(e:MIDIEvent):void 
		{
			trace("device Out removed",e.device.name);
		}
		
		
		private function midiControllerChange(e:MIDIEvent):void 
		{
			trace("midi controller change",e.channel,e.value);
		}
		
		private function midiNoteOn(e:MIDIEvent):void 
		{
			trace("midi note on from", e.device, e.pitch, e.velocity);
		}
		
		private function midiNoteOff(e:MIDIEvent):void 
		{
			trace("midi note off", e.pitch, e.velocity);
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			if (deviceOut == null) return;
			deviceOut.sendFullNote(1, 30, 127,.05);
		}
		
		//keyboard
		
		private function keyDown(e:KeyboardEvent):void 
		{
			if (deviceOut == null) return;
			
			if (e.keyCode == Keyboard.SHIFT) return;
			
			if (!e.shiftKey)
			{
				if (e.type == KeyboardEvent.KEY_DOWN) deviceOut.sendNoteOn(1, e.keyCode);
				else deviceOut.sendNoteOff(1, e.keyCode);
			}else {
				if(e.type == KeyboardEvent.KEY_DOWN) deviceOut.sendControllerChange(1, e.keyCode, int(Math.random() * 126));
			}
		}
		
		
		//MIDI Handlers
		
		//private function noteOn(e:MIDIEvent):void 
		//{
			//trace("[Main] Note On !",e.channel,e.pitch,e.velocity);
		//}
		//
		//private function noteOff(e:MIDIEvent):void 
		//{
			//trace("[Main] Note Off !",e.channel,e.pitch,e.velocity);
		//}
		//
		//private function controllerChange(e:MIDIEvent):void 
		//{
			//trace("[Main] controller change !",e.channel,e.number,e.value);
		//}
			
		
		
	}
	
}