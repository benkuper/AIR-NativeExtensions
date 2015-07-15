package benkuper.nativeExtensions

{
	import flash.events.EventDispatcher;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
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
		public var buffer2:ByteArray;
		
		private var _isOpened:Boolean;
		
		public static var instances:Vector.<SerialPort>;
		
		static public const MODE_BYTE255:String = "modeByte255";
		static public const MODE_NEWLINE:String = "modeNewline";
		static public const MODE_RAW:String = "modeRaw";
		static public const MODE_COBS:String = "modeCobs";
		
		public var mode:String = MODE_RAW;
		
		public function SerialPort(fullName:String)
		{
			buffer2 = new ByteArray();
			
			this.fullName = fullName;
			if (instances == null)
				instances = new Vector.<SerialPort>();
			instances.push(this);
		
			//trace("new Serial Port :", name, COMID, COMIndex);
		}
		
		public static function create(fullName:String):SerialPort
		{
			if (instances == null)
				instances = new Vector.<SerialPort>();
			
			for each (var p:SerialPort in instances)
			{
				if (p.fullName == fullName)
					return p;
			}
			
			//trace("No port found with that name : "+fullName+", creating a new one");
			return new SerialPort(fullName);
		}
		
		public function open(baudRate:int = 9600):Boolean
		{
			var result:Boolean = NativeSerial.instance.openPort(COMID, baudRate);
			if (result)
			{
				dispatchEvent(new SerialEvent(SerialEvent.PORT_OPENED))
			}
			return result;
		}
		
		public function close():void
		{
			var result:Boolean = NativeSerial.instance.closePort(COMID);
			if(result) dispatchEvent(new SerialEvent(SerialEvent.PORT_CLOSED)); 
		}
		
		public function updateBuffer(readBuffer:ByteArray, bytesRead:int):void
		{
			var evt:SerialEvent;
			if (bytesRead > 0)
			{
				buffer = new ByteArray();
				readBuffer.readBytes(buffer, 0, bytesRead);
				evt = new SerialEvent(SerialEvent.DATA, this);
				evt.data = buffer;
				dispatchEvent(evt);
			}
			
			if (mode == MODE_BYTE255 || mode == MODE_NEWLINE ||mode == MODE_COBS)
			{
				var endByte:int = 255;
				if (mode == MODE_NEWLINE) endByte = 10; // \n
				else if (mode == MODE_COBS) endByte = 0;
				
				readBuffer.position = 0;
				for (var i:int = 0; i < bytesRead; i++)
				{
					var b:int = readBuffer.readByte();
					if (b < 0)
						b += 256;
					
					
					switch (b)
					{
						case endByte: 
							
							var targetBuffer:ByteArray = buffer2;
							buffer2.position = 0;
							
							var evtType:String = SerialEvent.DATA_255;
							if (mode == MODE_NEWLINE) evtType = SerialEvent.DATA_NEWLINE;
							else if (mode == MODE_COBS) 
							{
								evtType = SerialEvent.DATA_COBS;
								targetBuffer = decodeCOBS(buffer2);
								if (targetBuffer == null) return;
								buffer2.position = 0;
							}
							
							evt = new SerialEvent(evtType, this);
							evt.data = targetBuffer;
							
							if (mode == MODE_NEWLINE)
							{
								evt.stringData = buffer2.readUTFBytes(buffer2.bytesAvailable);
								buffer2.position = 0;
							}
							
							dispatchEvent(evt);
							buffer2.clear();
							break;
						
						default: 
							buffer2.writeByte(b);
							break;
					}
				}
			}
		}
		
		public function encodeCOBS(data:ByteArray):ByteArray
		{
			data.position = 0;
			var numBytes:int = data.bytesAvailable;
			var encodedData:ByteArray = new ByteArray();
			encodedData.writeByte(0);
			encodedData.writeBytes(data);
			var zeroCount:int = 1;
			
			for(var i:int=numBytes;i>0;i--)
			{
				encodedData.position = i;
				var byte:int = encodedData.readByte();
				encodedData.position--;
				
				if(byte == 0) 
				{
				  encodedData.writeByte(zeroCount);
				  zeroCount = 1;
				}else 
				{
				  zeroCount++;
				}
			}
			
			encodedData.position = 0;
			encodedData.writeByte(zeroCount);
			encodedData.position = 0;
			return encodedData;
		}
		
		public function decodeCOBS(data:ByteArray):ByteArray
		{
			if (!isOpened) return null;
			
			data.position = 0;
			var numBytes:int = data.bytesAvailable -1;
			
			try
			{
				var nextZeroIndex:int = data.readByte();  
			}catch (e:Error)
			{
				trace("Error decoding COBS :", e.message);
				return null;
			}
			
			if (nextZeroIndex < 0) nextZeroIndex += 256;
			
			//trace("decoding cobs..., code byte = "+nextZeroIndex);
			//for (var i:int = 0; i < numBytes; i++) trace(data.readByte());
			//data.position = 0;
			
		    while(nextZeroIndex < numBytes)
		    { 
				data.position = nextZeroIndex;
				var nextAddIndex:int = data.readByte();
				if (nextAddIndex < 0) nextAddIndex += 256;
				data.position--;
				data.writeByte(0);
				nextZeroIndex += nextAddIndex;
		    }
		   
		  var decodedData:ByteArray = new ByteArray();
		  data.position = 1;
		  data.readBytes(decodedData);
		  return decodedData;
		}
		
		public function write(... bytes):void
		{
			NativeSerial.instance.write(COMID, bytes);
		}
		
		public function writeBytes(bytes:ByteArray):void
		{
			var targetBytes:ByteArray = bytes;
			if (mode == MODE_COBS) 
			{
				targetBytes = encodeCOBS(bytes);
				targetBytes.position += targetBytes.bytesAvailable;
				targetBytes.writeByte(0);
			}
			
			NativeSerial.instance.writeBytes(COMID, targetBytes);
		}
		
		//cleaning
		public function clean():void
		{
			if (isOpened)
				close();
		}
		
		//getter setter
		
		public function get fullName():String
		{
			return _fullName;
		}
		
		public function set fullName(value:String):void
		{
			_fullName = value;
			
			if (Capabilities.os.indexOf("Win") != -1)
			{
				this.COMID = fullName.match(/COM\d+/)[0];
				this.COMIndex = int(Number(COMID.slice(3)));
				this.name = this.fullName.slice(0, this.fullName.indexOf("(COM"));
			}
			else
			{
				this.COMID = fullName;
				this.COMIndex = -1;
				this.name = fullName.split("/tty.")[1];
			}
		
		}
		
		public function get isOpened():Boolean
		{
			return NativeSerial.instance.isPortOpened(COMID);
		}
		
		override public function toString():String
		{
			return "[SerialPort name=" + name + ", COMID=" + COMID + "]";
		}
	}

}