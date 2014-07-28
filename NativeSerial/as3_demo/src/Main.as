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
		private var port:SerialPort;
		
		public function Main():void 
		{
			NativeSerial.init();
			
			if (NativeSerial.ports.length > 0)
			{
				port = NativeSerial.ports[0];
				port.open();
				port.addEventListener(SerialEvent.DATA, serialData);
			}
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function serialData(e:SerialEvent):void 
		{
			
			//trace("Received :", port.buffer.readUTFBytes(port.buffer.bytesAvailable));
			
			port.buffer.position = 0;
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(10, 10, port.buffer[0] * 3, 20);
			//graphics.drawRect(10, 40, port.buffer[1] * 3, 20);
			//graphics.drawRect(10, 70, port.buffer[2] * 3, 20);
			graphics.endFill();
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.ENTER:
					port.write(255);
					break;
					
				case Keyboard.SPACE:
					var ba:ByteArray = new ByteArray();
					for (var i:int = 0; i < 200; i++)
					{
						ba.writeByte(0);
					}
					ba.writeByte(255);
					port.writeBytes(ba);
					break;
					
				default:
					port.write(e.keyCode);
					break; 
			}
		}
		
	}
	
}