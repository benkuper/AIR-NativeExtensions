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
		private static var openedPorts:Vector.<SerialPort>;
		
		private var readTimer:Timer;
		private var readFPS:int = 100; //100 read / sec		
		
		private var readBuffer:ByteArray;
		public var maxBuffer:int = 4096; //maxBuffer Length
		
		public static var instance:NativeSerial;
		
		public function NativeSerial():void
		{
			instance = this;
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeSerial", "serial");
			
			trace("extContext test :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
			ports = new Vector.<SerialPort>();
			openedPorts = new Vector.<SerialPort>();
			
			listPorts();
			
			readBuffer = new ByteArray();
			for (var i:int = 0; i < maxBuffer; i++) //init buffer with maxBuffer initial value
			{
				readBuffer.writeByte(0);
			}
			readBuffer.position = 0;
			
			readTimer = new Timer(1000 / readFPS);
			readTimer.addEventListener(TimerEvent.TIMER, readTimerTick);
			readTimer.start();
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);			
		}
		
		public static function init():void
		{
			if (instance != null) return;
			new NativeSerial();
		}
		
		public function listPorts():Vector.<SerialPort>
		{
			trace("[NativeSerial :: listPorts]");
			
			ports = new Vector.<SerialPort>();
			var r:Vector.<String> = extContext.call("listPorts") as Vector.<String>;
			
			for each(var s:String in r)
			{
				trace("list ::", s);
				ports.push(SerialPort.create(s));
			}
			
			return ports;
		}
		
		public static function getPort(COMPort:String):SerialPort
		{
			for each(var p:SerialPort in ports)
			{
				if (p.COMID == COMPort) return p;
			}
			
			return null;
		}
		
		
		public function openPort(portName:String = "COM1", baudRate:int = 9600):void
		{
			trace("[NativeSerial :: openPort ("+portName +", baud :"+baudRate+")]");
			extContext.call("openPort", portName, baudRate);
			openedPorts.push(getPort(portName));
			
		}
		
		
		private function readTimerTick(e:TimerEvent):void 
		{
			for each(var p:SerialPort in openedPorts)
			{
				readBuffer.position = 0;
				var bytesRead:int = extContext.call("update", p.COMID, readBuffer) as int;
				readBuffer.position = 0;
				p.updateBuffer(readBuffer,bytesRead);
				
			}
		} 
		
		
		public function write(portName:String, ...bytes):void
		{
			var ba:ByteArray = new ByteArray();
			for each(var b:int in bytes)
			{
				ba.writeByte(b);
			}
			
			writeBytes(portName,ba);
		}
		
		public function writeBytes(portName:String, bytes:ByteArray):void
		{
			bytes.position = 0;
			extContext.call("write",portName,bytes);
		}
		
		
		public function closePort(portName:String = "COM1"):void
		{
			extContext.call("closePort",portName);
			openedPorts.splice(openedPorts.indexOf(getPort(portName)),1);
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