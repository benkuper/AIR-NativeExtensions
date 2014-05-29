package benkuper.nativeExtensions
{
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  NativeSerial
	{
		private var extContext:ExtensionContext;
		
		public static var ports:Vector.<SerialPort>;
		
		public function NativeSerial():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeSerial", "serial");
			
			trace("extContext test :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
			ports = new Vector.<SerialPort>();
			
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
	}
	
} 