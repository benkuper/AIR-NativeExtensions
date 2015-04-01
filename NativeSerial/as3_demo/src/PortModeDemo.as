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
	public class PortModeDemo extends Sprite 
	{
		private var port:SerialPort;
		
		public function PortModeDemo():void 
		{			
			port = NativeSerial.getPort("COM19");
			port.mode = SerialPort.MODE_BYTE255;
			port.open();
			port.addEventListener(SerialEvent.DATA, serialData255);
			port.addEventListener(SerialEvent.PORT_CLOSED, portClosed);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function portClosed(e:SerialEvent):void 
		{
			trace("port closed");
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.C:
					trace("close port");
					port.close();
					break;
			}
		}
		
		private function serialData255(e:SerialEvent):void 
		{
			//trace("Data 255 !", e.data.bytesAvailable);
		}
		
	}
	
}