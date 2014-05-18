package benkuper.nativeExtensions
{
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  NativeDMXController
	{
		
		
		
		public function NativeDMXController():void
		{
			
			var extContext:ExtensionContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeDMXController", "dmx");
			
			trace("extContext test :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
		}
		
	}
	
} 