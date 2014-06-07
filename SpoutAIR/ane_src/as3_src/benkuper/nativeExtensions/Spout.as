package benkuper.nativeExtensions
{
	import flash.display.BitmapData;
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  Spout
	{
		private var extContext:ExtensionContext;
		
		
		
		public function Spout():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.Spout", "spout");
			
			
			new BitmapData(1,1); //avoid Error illegal default value for uint when creating after Spout init. ????
			
			
			trace("extContext test :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
		}
		
		public function shareTexture(sharingName:String, texture:BitmapData):Boolean
		{
			trace("[Spout :: shareTexture] "+sharingName);
			var result:Boolean = extContext.call("shareTexture", sharingName, texture) as Boolean;
			trace("[ >> result :"+ result + "]");
			return result;
		}
		
		
		public function updateTexture(sharingName:String, texture:BitmapData):Boolean
		{
			//trace("[Spout :: seTexture] "+sharingName);
			var result:Boolean = extContext.call("updateTexture", sharingName, texture) as Boolean;
			//trace("[ >> result :"+ result + "]");
			return result;
		}
		
	}
	
} 