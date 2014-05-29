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
	public class Main extends Sprite 
	{
		private var serial:NativeSerial;
		
		public function Main():void 
		{
			serial = new NativeSerial();
			
			if (NativeSerial.ports.length > 0)
			{
				serial.openPort(NativeSerial.ports[0].COMID, 9600);
				serial.addEventListener(SerialEvent.DATA, serialData);
			}
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function serialData(e:SerialEvent):void 
		{
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(10, 10, serial.buffer[0] * 3, 20);
			graphics.endFill();
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.ENTER:
					serial.write(255);
					break;
					
				case Keyboard.SPACE:
					var ba:ByteArray = new ByteArray();
					for (var i:int = 0; i < 200; i++)
					{
						ba.writeByte(0);
					}
					ba.writeByte(255);
					serial.writeBytes(ba);
					break;
					
				default:
					serial.write(e.keyCode);
					break; 
			}
		}
		
	}
	
}