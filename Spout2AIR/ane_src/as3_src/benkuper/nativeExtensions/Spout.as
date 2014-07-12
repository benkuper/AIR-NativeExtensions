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
		
		public function createSender(senderName:String, width:int, height:int):void
		{
			
		}
		
		public function createReceiver(senderName:String):SpoutReceiver
		{
			var result:SpoutReceiver = extContext.call("createReceiver", senderName) as SpoutReceiver;
			trace("create Receiver Result :", result);
			return result;
		}
		
		public function receiveTexture(receiver:SpoutReceiver):Boolean
		{
			var result:Boolean = extContext.call("receiveTexture", receiver.textureName, receiver.bitmapData, receiver) as Boolean;
			return result;
		}
		
		public function showPanel():void
		{
			extContext.call("showPanel");
		}
		
		private function appExiting(e:Event):void 
		{
			extContext.dispose();
		}
	}
	
} 