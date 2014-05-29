package benkuper.nativeExtensions
{
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SerialPort
	{
		public var name:String;
		public var fullName:String;
		public var COMIndex:int;
		public var COMID:String;
		
		public function SerialPort(fullName:String)
		{
			this.fullName = fullName;
			
			this.COMID = fullName.match(/COM\d+/)[0];
			this.COMIndex = int(Number(COMID.slice(3)));
			this.name = this.fullName.slice(0, this.fullName.indexOf("(COM"));
			
			trace("new Serial Port :", name, COMID, COMIndex);
			
		}
	}
	
} 