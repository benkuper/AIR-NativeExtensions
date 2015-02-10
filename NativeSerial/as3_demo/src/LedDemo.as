package  
{
	import benkuper.nativeExtensions.NativeSerial;
	import benkuper.nativeExtensions.SerialEvent;
	import benkuper.nativeExtensions.SerialPort;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class LedDemo extends Sprite 
	{
		private var p:SerialPort;
		
		public function LedDemo() 
		{
			super();
			NativeSerial.init();
			trace(NativeSerial.ports);
			p = NativeSerial.getPort("COM19");
			var op:Boolean = p.open();
			trace("port opened ?", op);
			p.mode = SerialPort.MODE_NEWLINE;
			p.addEventListener(SerialEvent.DATA_NEWLINE, newLine);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		
		private function newLine(e:SerialEvent):void 
		{
			trace("New line : "+e.stringData);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			var ba:ByteArray = new ByteArray();
			switch(e.keyCode)
			{
				case Keyboard.A:
					ba.writeUTFBytes("a");
					p.writeBytes(ba);
					break;
					
				case Keyboard.B:
					ba.writeUTFBytes("b");
					p.writeBytes(ba);
					break;
			}
		}
		
	}

}