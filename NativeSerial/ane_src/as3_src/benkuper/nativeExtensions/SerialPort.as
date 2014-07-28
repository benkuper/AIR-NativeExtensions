package benkuper.nativeExtensions
{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SerialPort extends EventDispatcher
	{
		public var name:String;
		private var _fullName:String;
		public var COMIndex:int;
		public var COMID:String;
		
		public var buffer:ByteArray;
		
		public static var instances:Vector.<SerialPort>;
		
		public function SerialPort(fullName:String)
		{
			this.fullName = fullName;
			if (instances == null) instances = new Vector.<SerialPort>();
			instances.push(this);
			
			trace("new Serial Port :", name, COMID, COMIndex);
		}
		
		public static function create(fullName:String):SerialPort
		{
			if (instances == null) instances = new Vector.<SerialPort>();
			
			for each(var p:SerialPort in instances)
			{
				if (p.fullName == fullName) return p;
			}
			
			trace("No port found with that name : "+fullName+", creating a new one");
			return new SerialPort(fullName);
		}
		
		public function open(baudRate:int = 9600):void
		{
			NativeSerial.instance.openPort(COMID, baudRate);
		}
		
		public function close():void
		{
			NativeSerial.instance.closePort();
		}
		
		public function updateBuffer(readBuffer:ByteArray,bytesRead:int):void
		{
			if (bytesRead > 0)
			{
				buffer = new ByteArray();
				readBuffer.readBytes(buffer, 0, bytesRead);
				dispatchEvent(new SerialEvent(SerialEvent.DATA));
			}
			
		}
		
		public function write(...bytes):void
		{
			NativeSerial.instance.write(COMID, bytes);
		}
		
		public function writeBytes(bytes:ByteArray):void
		{
			NativeSerial.instance.writeBytes(COMID, bytes);
		}
		
		public function get fullName():String 
		{
			return _fullName;
		}
		
		public function set fullName(value:String):void 
		{
			_fullName = value;
			
			this.COMID = fullName.match(/COM\d+/)[0];
			this.COMIndex = int(Number(COMID.slice(3)));
			this.name = this.fullName.slice(0, this.fullName.indexOf("(COM"));
		}
	}
	
} 