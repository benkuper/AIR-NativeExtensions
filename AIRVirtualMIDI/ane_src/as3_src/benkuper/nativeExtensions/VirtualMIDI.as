package benkuper.nativeExtensions
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;

	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class VirtualMIDI
	{
		public static var extContext:ExtensionContext;
		
		public function NativeMIDI():void
		{
			
			
		}
		
		public static function init():void
		{
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.VirtualMIDI", "midi");
			extContext.addEventListener(StatusEvent.STATUS, statusHandler);
			
			extContext.call("init") as Boolean;
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);
			
		}
		
		static private function statusHandler(e:StatusEvent):void 
		{
			trace("Status event from extension :", e.code, e.level); 
		}
		
		public static function createDevice(name:String):Boolean
		{
			return extContext.call("createDevice", name+" ") as Boolean; //force whitespace for clean name conversion in extension
		}
		
		public static function closeDevice(name:String):Boolean
		{
			return extContext.call("closeDevice", name) as Boolean;
		}
		
		
		private static function appExiting(e:Event):void 
		{
			extContext.dispose();
		}
		
		
	}
	
} 