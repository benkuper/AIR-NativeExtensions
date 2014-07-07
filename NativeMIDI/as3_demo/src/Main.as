package 
{
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
		private var midi:NativeMIDI;
		
		public function Main():void 
		{
			midi = new NativeMIDI();
			midi.addEventListener(MIDIEvent.NOTE_ON, noteOn);
			midi.addEventListener(MIDIEvent.NOTE_OFF, noteOff);
			midi.addEventListener(MIDIEvent.CONTROLLER_CHANGE, controllerChange);
			
			//trace("input devices :",midi.inputDevices);
			//trace("output devices :", midi.outputDevices);
			
			//if (midi.inputDevices.length > 0)
			//{
				//
			//}
			//midi.openInputDeviceByName("loopMIDI Port 0");
			midi.openOutputDeviceByName("loopMIDI Port");
			
			//stage.nativeWindow.minimize();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			//stage.addEventListener(MouseEvent.MOUSE_UP, mouseDown);
			
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			midi.sendFullNote(1, 30, 127,.05);
		}
		
		//keyboard
		
		private function keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SHIFT) return;
			
			if (!e.shiftKey)
			{
				if (e.type == KeyboardEvent.KEY_DOWN) midi.sendNoteOn(1, e.keyCode);
				else midi.sendNoteOff(1, e.keyCode);
			}else {
				if(e.type == KeyboardEvent.KEY_DOWN) midi.sendControllerChange(1, e.keyCode, int(Math.random() * 126));
			}
		}
		
		
		//MIDI Handlers
		
		private function noteOn(e:MIDIEvent):void 
		{
			trace("[Main] Note On !",e.channel,e.pitch,e.velocity);
		}
		
		private function noteOff(e:MIDIEvent):void 
		{
			trace("[Main] Note Off !",e.channel,e.pitch,e.velocity);
		}
		
		private function controllerChange(e:MIDIEvent):void 
		{
			trace("[Main] controller change !",e.channel,e.number,e.value);
		}
			
		
		
	}
	
}