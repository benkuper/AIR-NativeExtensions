package benkuper.nativeExtensions
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Spout extends EventDispatcher
	{
		public var extContext:ExtensionContext;
		
		
		
		public function Spout():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.Spout", "spout");
			
			if (extContext == null)
			{
				trace("[SpoutExtension Init Error]");
				return;
			}
			
			new BitmapData(1,1); //avoid Error illegal default value for uint when creating after Spout init. ????
			
			
			var b:Boolean = extContext.call("init") as Boolean;
			trace("[Spout Extension Init : " + b + "]");
			
			extContext.addEventListener(StatusEvent.STATUS, statusHandler);
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);
			
		}
		
		private function statusHandler(e:StatusEvent):void 
		{
			trace("[SpoutExtension] Status from extension : " + e.code+" / " + e.level);
			
			switch(e.code)
			{
				case "sharingStarted":
					dispatchEvent(new SpoutEvent(SpoutEvent.SHARING_STARTED, e.level));
					break;
					
				case "sharingStopped":
					dispatchEvent(new SpoutEvent(SpoutEvent.SHARING_STOPPED, e.level));
					break;
			}
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
		
		
		public function startReceiving():Boolean
		{
			var result:Boolean = extContext.call("startReceiving") as Boolean;
			return result;
		}
		
		public function stopReceiving():Boolean
		{
			var result:Boolean = extContext.call("stopReceiving") as Boolean;
			return result;
		}
		
		public function receiveTexture(sharingName:String):Bitmap
		{
			var bitmapData:BitmapData = new BitmapData(640, 360,true,0);
			var result:Boolean = extContext.call("receiveTexture",sharingName, bitmapData) as Boolean;
			return new Bitmap(bitmapData);
		}
		
		public function updateReceiveTexture(sharingName:String, bitmap:Bitmap):void
		{
			var result:Boolean = extContext.call("updateReceiveTexture",sharingName, bitmap.bitmapData) as Boolean;
		}
		
		private function appExiting(e:Event):void 
		{
			stopReceiving();
			extContext.dispose();
		}
	}
	
} 