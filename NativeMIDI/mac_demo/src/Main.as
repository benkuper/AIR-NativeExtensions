package {

import benkuper.nativeExtensions.MIDIEvent;
import benkuper.nativeExtensions.NativeMIDI;

import flash.display.Sprite;
import flash.text.TextField;

public class Main extends Sprite {

    var midi:NativeMIDI;

    public function Main() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        midi = new NativeMIDI();
        trace(midi.inputDevices);
        var result:Boolean = midi.openInputDeviceByIndex(1);
trace("open ok ?",result);
        midi.addEventListener(MIDIEvent.NOTE_ON, noteOn);
        midi.addEventListener(MIDIEvent.NOTE_OFF, noteOff);
        midi.addEventListener(MIDIEvent.CONTROLLER_CHANGE, controllerChange);
        trace(midi.outputDevices);
    }

    public function noteOn(e:MIDIEvent):void
    {
        trace("Note on !",e.pitch);
    }

    public function noteOff(e:MIDIEvent):void
    {
        trace("Note off !",e.pitch);
    }

    public function controllerChange(e:MIDIEvent):void
    {
        trace("Control change ",e.channel,e.value);
    }
}
}
