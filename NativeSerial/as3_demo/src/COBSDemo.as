package 
{
	import benkuper.nativeExtensions.NativeSerial;
	import benkuper.nativeExtensions.SerialEvent;
	import benkuper.nativeExtensions.SerialPort;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class COBSDemo extends Sprite 
	{
		private var port:SerialPort;
		
		public function COBSDemo():void 
		{			
			port = NativeSerial.getPort("COM6");
			port.mode = SerialPort.MODE_COBS;
			port.open();
			port.addEventListener(SerialEvent.DATA_COBS, dataCobs);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function dataCobs(e:SerialEvent):void 
		{
			trace("got value feedback = ",e.data.readShort());
		}
		
		private function portClosed(e:SerialEvent):void 
		{
			trace("port closed");
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			var ba:ByteArray;
			switch(e.keyCode)
			{
				case Keyboard.D:
					ba = new ByteArray();
					ba.writeUTFBytes("m");
					ba.writeShort(640);
					ba.position = 0;
					port.writeBytes(ba);
					break;
					
				case Keyboard.F:
					ba = new ByteArray();
					ba.writeUTFBytes("m");
					ba.writeShort(2400);
					ba.position = 0;
					port.writeBytes(ba);
					break;
					
				case Keyboard.C:
					trace("close port");
					port.close();
					break;
			}
		}
		
	}
	
}