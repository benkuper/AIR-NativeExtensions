package benkuper.nativeExtensions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SpoutReceiver extends Sprite
	{
		
		public var textureName:String;
		
		public var textureWidth:int;
		public var textureHeight:int;
		
		protected var bitmap:Bitmap;
		public var bitmapData:BitmapData;
		
		
		
		public function SpoutReceiver(textureName:String,w:int,h:int):void
		{
			setInfos(textureName, w, h);
			
			trace("New SpoutReceiver !", textureName, textureWidth, textureHeight);
			
			bitmap = new Bitmap();
			bitmapData = new BitmapData(textureWidth, textureHeight, true, 0xffff00ff);
			addChild(bitmap);
		}
		
		public function setInfos(textureName:String, w:int, h:int):void
		{
			this.textureName = textureName;
			this.textureWidth = w;
			this.textureHeight = h;
		}
		
		public function update():void
		{
			bitmap.bitmapData = bitmapData;
		}
		
		override public function toString():String
		{
			return "[SpoutReceiver, textureName = " + textureName+", dimensions = " + textureWidth + "*" + textureHeight + "]";
		}
	}
}