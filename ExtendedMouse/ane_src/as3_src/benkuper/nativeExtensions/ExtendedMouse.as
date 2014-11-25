package benkuper.nativeExtensions
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  ExtendedMouse
	{
		private static var isInit:Boolean;
		private static var extContext:ExtensionContext;
		
		public function ExtendedMouse():void
		{
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.ExtendedMouse", "mouse");
			
			trace("Mouse extContext check :", extContext);
			var b:Boolean = extContext.call("init") as Boolean;
			trace("init result :", b);
			
		}
		
		public static function init():void
		{
			if (isInit) return;
			new ExtendedMouse();
			isInit = true;
		}
		
		private static function getStagePos():Point
		{
			var bounds:Rectangle = NativeApplication.nativeApplication.activeWindow.bounds;
			var stageWidth:Number = NativeApplication.nativeApplication.activeWindow.stage.stageWidth;
			var stageHeight:Number = NativeApplication.nativeApplication.activeWindow.stage.stageHeight;
			var stagePosX:Number = bounds.x + bounds.width / 2 - stageWidth / 2;
			var borderWidth:Number = (bounds.width - stageWidth) / 2;
			var stagePosY:Number = bounds.y + bounds.height - stageHeight - borderWidth / 2 - 4;
			
			return new Point(stagePosX, stagePosY);
		}
		
		public static function setCursorScreenPos(tx:int,ty:int):void
		{
			if (!isInit) init();
			setCursorNative(tx, ty);
		}
		
		public static function setCursorStagePos(tx:int,ty:int):void
		{
			if (!isInit) init();
			var stagePos:Point = getStagePos();
			setCursorNative(stagePos.x + tx, stagePos.y + ty);
		}
		
		public static function setCursorRelativePos(tx:int,ty:int,relativeTo:DisplayObject):void
		{
			if (!isInit) init();
			
			var stagePos:Point = getStagePos();
			var tPos:Point = relativeTo.localToGlobal(new Point(tx, ty));
			setCursorScreenPos(stagePos.x + tPos.x, stagePos.y+tPos.y);
		}
		
		private static function setCursorNative(tx:int, ty:int):void
		{
			if (!isInit) init();
			extContext.call("setCursorPos", tx, ty);
		}
	}
	
} 