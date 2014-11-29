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
			port = NativeSerial.getPort("COM10");
			//port.mode = SerialPort.MODE_BYTE;
			port.open();
			port.addEventListener(SerialEvent.DATA, serialData255);
			
		}
		
		private function serialData255(e:SerialEvent):void 
		{
			trace("Data 255 !", e.data.bytesAvailable);
		}
		
	}
	
}