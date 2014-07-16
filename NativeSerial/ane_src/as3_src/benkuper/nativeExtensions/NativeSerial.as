package benkuper.nativeExtensions
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  NativeSerial extends EventDispatcher
	{
		private var extContext:ExtensionContext;
		
		public static var ports:Vector.<SerialPort>;
		
		private var readTimer:Timer;
		private var readFPS:int = 100; //100 read / secs
		
		private var readBuffer:ByteArray;
		public var buffer:ByteArray;
		private var maxBuffer:int = 4096; //maxBuffer Length
		
		public function NativeSerial():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeSerial", "serial");
			
			trace("extContext test :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
			ports = new Vector.<SerialPort>();
			
			listPorts();
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);
			
			
			readBuffer = new ByteArray();
			for (var i:int = 0; i < maxBuffer; i++) //init buffer with maxBuffer initial value
			{
				readBuffer.writeByte(0);
			}
			readBuffer.position = 0;
			
			readTimer = new Timer(1000 / readFPS);
			readTimer.addEventListener(TimerEvent.TIMER, readTimerTick);
			
			readTimer.start();
		}
		
		public function listPorts():Vector.<SerialPort>
		{
			trace("[NativeSerial :: listPorts]");
			
			ports = new Vector.<SerialPort>();
			var r:Vector.<String> = extContext.call("listPorts") as Vector.<String>;
			
			for each(var s:String in r)
			{
				ports.push(new SerialPort(s));
				trace("Port : " + s);
			}
			
			return ports;
		}
		
		public function openPort(portName:String = "COM1", baudRate:int = 9600):void
		{
			trace("[NativeSerial :: openPort ("+portName +", baud :"+baudRate+")]");
			extContext.call("openPort", portName, baudRate);
		}
		
		
		private function readTimerTick(e:TimerEvent):void 
		{
			readBuffer.position = 0;
			var bytesRead:int = extContext.call("update", readBuffer) as int;
			readBuffer.position = 0;
			if (bytesRead > 0)
			{
				//trace("Read " + bytesRead + " bytes");
				buffer = new ByteArray();
				readBuffer.readBytes(buffer, 0, bytesRead);
				dispatchEvent(new SerialEvent(SerialEvent.DATA));
			}
			
		} 
		
		
		
		public function write(...bytes):void
		{
			var ba:ByteArray = new ByteArray();
			for each(var b:int in bytes)
			{
				ba.writeByte(b);
			}
			
			writeBytes(ba);
		}
		
		public function writeBytes(bytes:ByteArray):void
		{
			bytes.position = 0;
			extContext.call("write",bytes);
		}
		
		
		public function closePort():void
		{
			extContext.call("closePort");
		}
		
		
		public function clean():void
		{
			closePort();
			readTimer.removeEventListener(TimerEvent.TIMER, readTimerTick);
		}
		
		
		private function appExiting(e:Event):void 
		{
			clean();
		}
	}
	
} 