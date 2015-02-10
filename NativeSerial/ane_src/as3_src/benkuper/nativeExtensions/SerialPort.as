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
        public var mode:String = MODE_RAW;



        public function SerialPort(fullName:String)
        {
            buffer2 = new ByteArray();

            this.fullName = fullName;
            if (instances == null) instances = new Vector.<SerialPort>();
            instances.push(this);

            //trace("new Serial Port :", name, COMID, COMIndex);
        }

        public static function create(fullName:String):SerialPort
        {
            if (instances == null) instances = new Vector.<SerialPort>();

            for each(var p:SerialPort in instances)
            {
                if (p.fullName == fullName) return p;
            }

            //trace("No port found with that name : "+fullName+", creating a new one");
            return new SerialPort(fullName);
        }

        public function open(baudRate:int = 9600):Boolean
        {
            var result:Boolean = NativeSerial.instance.openPort(COMID, baudRate);
            return result;
        }

        public function close():void
        {
            NativeSerial.instance.closePort(COMID);
        }

        public function updateBuffer(readBuffer:ByteArray,bytesRead:int):void
        {
            var evt:SerialEvent;
            if (bytesRead > 0)
            {
                buffer = new ByteArray();
                readBuffer.readBytes(buffer, 0, bytesRead);
                evt = new SerialEvent(SerialEvent.DATA,this);
                evt.data = buffer;
                dispatchEvent(evt);
            }

            if (mode == MODE_BYTE255 || mode == MODE_NEWLINE)
            {
				var endByte:int = (mode == MODE_BYTE255)?255:10; // '\n' = 10
				
				
                readBuffer.position = 0;
                for (var i:int = 0; i < bytesRead; i++)
                {
                    var b:int = readBuffer.readByte();
                    if (b < 0) b += 256;
                    switch(b)
                    {
                        case endByte:
                            buffer2.position = 0;
                            evt = new SerialEvent((mode == MODE_BYTE255)?SerialEvent.DATA_255:SerialEvent.DATA_NEWLINE,this);
                            evt.data = buffer2;
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

        public function write(...bytes):void
        {
            NativeSerial.instance.write(COMID, bytes);
        }

        public function writeBytes(bytes:ByteArray):void
        {
            NativeSerial.instance.writeBytes(COMID, bytes);
        }


        //cleaning
        public function clean():void
        {
            if(isOpened) close();
        }


        //getter setter
		
		public function get fullName():String 
		{
			return _fullName;
		}
		
		public function set fullName(value:String):void 
		{
			_fullName = value;

            if(Capabilities.os.indexOf("Win") != -1)
            {
                this.COMID = fullName.match(/COM\d+/)[0];
                this.COMIndex = int(Number(COMID.slice(3)));
                this.name = this.fullName.slice(0, this.fullName.indexOf("(COM"));
            }else
            {
                this.COMID = fullName;
                this.COMIndex = -1;
                this.name =  fullName.split("/tty.")[1];
            }

		}
		
		public function get isOpened():Boolean 
		{
			return NativeSerial.instance.isPortOpened(COMID);
		}
		
		override public function toString():String
		{
			return "[SerialPort name=" + name+", COMID=" + COMID + "]";
		}
	}
	
} 