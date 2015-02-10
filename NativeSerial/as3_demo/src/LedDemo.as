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
			NativeSerial.instance.addEventListener(SerialEvent.PORT_ADDED, portAdded);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function portAdded(e:SerialEvent):void 
		{
			if (e.port.COMID == "COM21")
			{
				p = e.port;
				var op:Boolean = p.open();
				trace("port opened ?", op);
				p.addEventListener(SerialEvent.DATA, newLine);
			}
			
		}
		
		private function newLine(e:SerialEvent):void 
		{
			trace(e.data.readUTFBytes(e.data.bytesAvailable));
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