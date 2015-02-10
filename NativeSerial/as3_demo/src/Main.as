package 
{
	import benkuper.nativeExtensions.NativeSerial;
	import benkuper.nativeExtensions.SerialEvent;
	import benkuper.nativeExtensions.SerialPort;
	//import benkuper.util.Shortcutter;
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
			NativeSerial.instance.addEventListener(SerialEvent.PORT_ADDED, portAdded);
			NativeSerial.instance.addEventListener(SerialEvent.PORT_REMOVED, portRemoved);
			
			/*
			Shortcutter.init(stage);
			Shortcutter.add(this);
			*/
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		
		private function portAdded(e:SerialEvent):void 
		{
			trace("Main :: port added :" + e.port.fullName);
			port = NativeSerial.getPort("COM19");
			
			if (port != null) 
			{
				port.open();
				port.addEventListener(SerialEvent.DATA, serialData);
			}
		}
		
		private function portRemoved(e:SerialEvent):void 
		{
			trace("Main :: port removed");
			if (e.port == port)
			{
				port.removeEventListener(SerialEvent.DATA, serialData);
				port = null;
				graphics.clear();
				graphics.beginFill(0xff00ff);
				graphics.drawCircle(100, 100, 10);
				graphics.endFill();
			}
		}
		
		
		
		//[Shortcut(key="o")]
		public function openPort():void
		{
			
			
		}
		
		private function serialData(e:SerialEvent):void 
		{
			graphics.clear();
			
			trace("Serial data");
			if (port == null) return;
			
			//trace("Received :", port.buffer.readUTFBytes(port.buffer.bytesAvailable));
			
			port.buffer.position = 0;
			
			graphics.beginFill(0);
			graphics.drawRect(10, 10, port.buffer[0] * 3, 20);
			//graphics.drawRect(10, 40, port.buffer[1] * 3, 20);
			//graphics.drawRect(10, 70, port.buffer[2] * 3, 20);
			graphics.endFill();
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			if (port == null) return;
			
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