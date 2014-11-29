package benkuper.nativeExtensions
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
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
		
		private var updateTimer:Timer;
		private var updateFPS:int = 100; //100 reads / sec		
		
		
		private var readBuffer:ByteArray;
		public var maxBuffer:int = 4096; //maxBuffer Length
		
		public static var instance:NativeSerial;
		
		public function NativeSerial():void
		{
			instance = this;
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeSerial", "serial");
			
			var b:Boolean = extContext.call("init") as Boolean;
			
			trace("NativeSerial init, success ?", b);
			
			extContext.addEventListener(StatusEvent.STATUS, extensionStatusHandler);
			
			ports = new Vector.<SerialPort>();
			openedPorts = new Vector.<SerialPort>();
			
			readBuffer = new ByteArray();
			for (var i:int = 0; i < maxBuffer; i++) //init buffer with maxBuffer initial value
			{
				readBuffer.writeByte(0);
			}
			readBuffer.position = 0;
			
			updateTimer = new Timer(1000 / updateFPS);
			updateTimer.addEventListener(TimerEvent.TIMER, updateTimerTick);
			updateTimer.start();
			
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);			
		}
		
		
		public static function init():void
		{
			if (instance != null) return;
			new NativeSerial();
		}
		
		
		public function listPortsFilter(filter:*):Vector.<SerialPort>
		{
			var fPorts:Vector.<SerialPort> = new Vector.<SerialPort>();
			
			for each(var p:SerialPort in ports)
			{
				var matches:Array = p.fullName.match(filter);
				if (matches != null && matches.length > 0) fPorts.push(p);
			}
			
			return fPorts;
		}
		
		public static function getPort(COMPort:String):SerialPort
		{
			if (instance == null) init();
			
			for each(var p:SerialPort in ports)
			{
				if (p.COMID == COMPort) return p;
			}
			
			return null;
		}
		
		//extension calls
		
		protected function updatePortsList():void
		{
			var p:SerialPort;
			var newPortNames:Vector.<String> = extContext.call("listPorts") as Vector.<String>;
			
			//removed ports detection
			var portsToRemove:Vector.<SerialPort> = new Vector.<SerialPort>;
			
			
			for each(p in ports)
			{
				if (newPortNames.indexOf(p.fullName) == -1) //port doesn't exist anymore
				{
					portsToRemove.push(p);
				}
			}
			
			for each(p in portsToRemove) removePort(p);
			
			
			//added ports detection
			//trace("New port detection :");
			var portsToAdd:Vector.<String> = new Vector.<String>;
			for each(var n:String in newPortNames)
			{
				
				var nameIsFound:Boolean = false;
				for each(p in ports)
				{
					if (p.fullName == n) 
					{
						nameIsFound = true;
						break;
					}
				}
				if (!nameIsFound) portsToAdd.push(n);
				//trace("	> " + n + " is Found ? " + nameIsFound);
			}
			
			for each(var pn:String in portsToAdd) addPort(pn);
			
		}
		
		public function openPort(portName:String = "COM1", baudRate:int = 9600):Boolean
		{
			var result:Boolean = extContext.call("openPort", portName, baudRate);
			if (result) 
			{
				openedPorts.push(getPort(portName));
				dispatchEvent(new SerialEvent(SerialEvent.PORT_OPENED))
			}
			
			return result;
		}
		
		
		public function isPortOpened(portName:String):Boolean 
		{
			return extContext.call("isPortOpened", portName);
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
			openedPorts.splice(openedPorts.indexOf(getPort(portName)), 1);
			dispatchEvent(new SerialEvent(SerialEvent.PORT_OPENED));
		}
		
		//data
		private function addPort(portFullName:String):void
		{
			var p:SerialPort = SerialPort.create(portFullName);
			ports.push(p);
			dispatchEvent(new SerialEvent(SerialEvent.PORT_ADDED, p));
			trace("Port added !",p.fullName);
		}
		
		private function removePort(p:SerialPort):void
		{
			trace("Remove port", p.COMID);
			p.clean();
			
			ports.splice(ports.indexOf(p), 1);
			openedPorts.splice(openedPorts.indexOf(p), 1);
			
			dispatchEvent(new SerialEvent(SerialEvent.PORT_REMOVED, p));
			trace("Port removed ",p.fullName);
		}
		
		//handlers
		private function updateTimerTick(e:TimerEvent):void 
		{
			//read data on opened ports
			for each(var p:SerialPort in openedPorts)
			{
				readBuffer.position = 0;
				var bytesRead:int = extContext.call("update", p.COMID, readBuffer) as int;
				readBuffer.position = 0;
				p.updateBuffer(readBuffer,bytesRead);
 			}
		}
		
		
		private function extensionStatusHandler(e:StatusEvent):void 
		{
			trace("Extension Status received, code :", e.code, ", level :", e.level);
			switch(e.code)
			{
				case "updatePorts":
					updatePortsList();
					break;
			}
		}
		
		
		
		//cleaning
		
		public function clean():void
		{
			while (ports.length > 0) removePort(ports[0]);
			
			updateTimer.stop();
			updateTimer.removeEventListener(TimerEvent.TIMER, updateTimerTick);
		}
		
		
		
		private function appExiting(e:Event):void 
		{
			clean();
		}
	}
	
} 