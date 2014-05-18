package benkuper.nativeExtensions
{
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  BaseExtension
	{
		
		
		
		public function BaseExtension():void
		{
			
			var extContext:ExtensionContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.BaseExtension", "base");
			
			trace("extContext test :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
		}
		
	}
	
} 